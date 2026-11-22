# Deadbeat spec 1.0

*Status: 1.0, implemented by Deadbeat 1.0. History: v0.1 (Deadbeat 0.3), the LDB bridge (0.4), layouts (0.5).*

Deadbeat is a hub bar for WoW: Forever. It draws a bar, a tooltip, a settings console and a dock, and nothing else.
**Modules** (any addon) fill them through the API below. A module must work without Deadbeat and must never break the
bar.

## 1. Versioning

- The spec has its own version, `MAJOR.MINOR`. From 1.0 on, a minor only adds things; only a major may remove or
  change them.
- Everything here is **stable** unless marked **draft** (may still change in a minor). In 1.0 only the band (§4.5) is
  draft.
- `Deadbeat.SPEC` holds the spec version the hub implements (`"1.0"`). A module says what it targets with
  `Deadbeat.Register(name, order, { spec = "1.0" })`; a newer major than the hub's gets one chat line asking the
  player to update Deadbeat, nothing else. Modules written for 0.1 work unchanged.
- Anything not in this document (functions on `Deadbeat` not listed here, fields of module tables, frame names) is
  internal and may change without notice.

## 2. Concepts

| Term | Meaning |
|---|---|
| **Hub** | The Deadbeat addon. Owns the bar, tooltip, settings console, dock. |
| **Module** | An addon (or part of one) that registered with `Deadbeat.Register`. |
| **Bar** | The one bar: four text **fields** on the left, **badges** on the right, a thin **band**, a gear for the settings. Compact (top middle, grows from 420 to 760 px) or full-width on the top or bottom edge (§4.12). |
| **Field** | `label`, `clock`, `primary`, `secondary`. Each shows the value of the module with the highest **priority** that set it. |
| **Badge** | A small frame (14 px high) on the right of the bar that a module draws into. Additive: every shown badge is on the bar. |
| **Band** | A 9 px area under the fields (Haul draws a sparkline there). One module at a time: the highest priority. |
| **Section** | A module's part of the bar's tooltip. Additive, in module order. |
| **Context** | Where the player is: `farm`, `raid`, `dungeon`, `city`, `world`. Decides which badges show. |
| **Settings console** | One window (the gear on the bar) with a tab per page; modules add pages of clickable **rows**. |
| **Dock** | Panels stacked under the bar (a module's own frame). |

## 3. Lifecycle

```
## OptionalDeps: Deadbeat            -- in your TOC: load after Deadbeat when it's there, without it otherwise
```

- The global `Deadbeat` exists once the hub is loaded. Check for it; never assume it.
- Register at `PLAYER_LOGIN` (or later). The bar is built when Deadbeat itself loads, before `PLAYER_LOGIN`.
- Without Deadbeat a module falls back to its own UI or chat lines, or does nothing visible. It must not error.

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not Deadbeat then return end
    local m = Deadbeat.Register("Hello", 70)
    -- fields, badges, sections, options …
end)
```

## 4. API

### 4.1 Registering (stable)

`Deadbeat.Register(name, order, opts) → module`

- `name`: unique, shown in the console and in error lines. Registering the same name again returns the same module.
- `order`: number; lower = further left in badges' module order and higher up in the tooltip. Used today: Bar 0,
  Haul 10, Lockout 20, Catch 30, Flip 40, Hearth 60. Pick 70+ for new modules unless you mean to sit between.
- `opts` (optional): `{ spec = "1.0" }`, the spec version you target.

### 4.2 Fields (stable)

`module:Set(field, text, priority)` · `module:Clear(field)`

- `field`: `"label"` (left, bronze, cut with "…" when long), `"clock"` (small grey, after the label), `"primary"` (the
  big number), `"secondary"` (small, right-aligned before the badges).
- `text`: a string; colour codes, `|T…|t` textures and `Deadbeat.kit.coins(...)` are fine. `""` is a value: it claims
  the field and shows nothing (use it to hide a lower module's text).
- `priority`: number; for each field the module with the highest priority wins, ties go to the lower `order`.
  Conventions:

| Priority | Use | Today |
|---|---|---|
| 0–9 | idle fallback | — |
| 10–19 | everyday | Haul session 10, Hearth world/city 12, Hearth dungeon 15 |
| 20–29 | an activity | Haul run 20, Hearth raid 25 |
| 30–49 | a short moment | Haul "run done" 30 (20 s) |
| 50+ | a focused activity | Catch fishing 50 |

- Clicks on the bar go to the module that owns `label`: `module:OnClick(function(button) end)` (stable).

### 4.3 Badges

`module:Badge(width, opts) → frame`

- Returns a frame `width` × 14 px that you draw into (textures, font strings). Show and hide it as you like; resize it
  with `frame:SetWidth(w)` and call `Deadbeat.Refresh()` so the bar lays out again.
- `opts`: `{ id = "module.thing", label = "Free bag slots", contexts = { raid = true, world = true } }`
  - `id`: unique, stable across versions (the user's choices are saved under it). Prefix it with your module name.
  - `label`: shown in the console's "What shows where" grid.
  - `contexts`: where it shows by default; omitted = everywhere. The user overrides per context in the console.
- Badges sit right to left in module order; within a module, the first badge created is the rightmost.

### 4.4 Contexts

- `Deadbeat.Context() → "farm" | "raid" | "dungeon" | "city" | "world"`; `Deadbeat.CONTEXTS` lists them in order.
- Decided by the hub: **farm** if any module claims it, else **raid** / **dungeon** (instance type), else **city**
  (resting: cities and inns), else **world**. Re-evaluated on zone, resting and claim changes.
- `module:Claim("farm", on)`: you're running a farming activity (Catch while fishing). Release it when done.
- `module:OnContext(function(context) end)`: called when the context changes.

### 4.5 Band (draft)

`module:Band(priority) → frame` · `module:BandPriority(priority, wanted)`

A frame over the bar's lower band (full width minus 16 px, 9 px high). Only the highest-priority wanted band shows.

### 4.6 Tooltip sections (stable)

`module:Section(function(tip, shift) end)`

- `tip` is `GameTooltip`; add lines with `tip:AddLine` / `tip:AddDoubleLine`. Start with a header line in your own
  words; indent detail lines with two spaces.
- `shift` is true while Shift is held: show "nerd stats" only then.
- Return early when you have nothing relevant **for the current context** (Catch only while fishing, raid lockouts
  only in raids). The tooltip is shared; keep it short.
- Errors are caught and shown as one red line with your module's name.
- `Deadbeat.RefreshTooltip()` redraws it if it's open (after your data changed).

### 4.7 Settings

`module:Options(page)` · `Deadbeat.OpenSettings(title)` · `Deadbeat.RefreshSettings()`

```lua
m:Options({ title = "Hello", icon = "Interface\\Icons\\INV_Misc_Rune_01", rows = { ... } })
```

A module may add several pages (`"Catch"`, `"Catch · Sounds"`). Pages are built the first time they're opened; every
time a page shows, each row's `get` is called again. Rows:

| kind | fields | shows |
|---|---|---|
| `header` | `label` | a section title with a line |
| `note` | `label` | grey explanatory text |
| `toggle` | `label`, `get() → bool`, `set(bool)` | an on/off switch |
| `button` | `label`, `text`, `run()`, `confirm` (bool) | a button; with `confirm` the first click asks "Sure?" for 3 s |
| `slider` | `label`, `min`, `max`, `step`, `get() → number`, `set(number)`, `fmt` (`"%.2f"`) | − value + buttons |
| `keys` | `label`, `get(slot) → key`, `set(slot, key or nil)`; `slot` is `"key"` or `"pad"` | key names + Keyboard / Controller / Clear; captures one key (with modifiers) or pad button; not in combat |
| `custom` | `height` (number or function), `build(frame, width)`, `show(frame)` | your own UI in a frame of that size; `show` runs whenever the page shows |

- `Deadbeat.OpenSettings(title)` opens the console on a page (e.g. from a right-click on your own frame).
- **Every setting is a row.** Slash commands may exist as shortcuts, but nothing should only be reachable by typing.

### 4.8 Dock

`module:Dock(frame)`: your frame is stacked under the bar (6 px apart) while shown, in the order docked.

### 4.9 The kit (stable)

`Deadbeat.kit` (`K`) gives modules the hub's look (FlareUI's palette; media from LibSharedMedia when present):

| | |
|---|---|
| `K.P` | palette: `ground`, `bronze1`–`bronze4`, `goldOn`, `warmGrey` (`{r, g, b}`) |
| `K.GREEN`, `K.RED`, `K.soft(r, g, b)` | soft good/bad colours; soften any colour |
| `K.hex(c)` | `"rrggbb"` for `|cff…` codes |
| `K.coins(copper, size, whole)` | money with coin icons, rounded; `whole` = whole gold from 1g |
| `K.clock(seconds)` | `"1:02:05"` / `"4:07"` |
| `K.icon(path, size)` | an inline texture string, edges trimmed |
| `K.swatch(c)` | a 3 px colour swatch for tooltip lines |
| `K.ground(frame, alpha)` | the dark background |
| `K.border(frame, thin)` | the bronze border |
| `K.text(parent, template, color)` | a font string |
| `K.flash(region, parent)` | an animation group: a short warm flash |
| `K.media(kind, name)`, `K.barTexture()` | LibSharedMedia lookups with fallbacks |

### 4.10 Misc (stable)

`Deadbeat.Refresh()` (lay the bar out again), `Deadbeat.version` (the hub's version string), `Deadbeat.frame` (the
bar; anchor to it, don't restyle it).

### 4.11 LibDataBroker bridge

Addons that publish **LibDataBroker-1.1** data objects need no Deadbeat code at all. The hub finds every object
(at login and whenever another addon loads, plus LDB's `DataObjectCreated` callback) and shows it:

- in the **tray**: one badge (`ldb.tray`) that drops down a grid of icons (`icon`, `iconCoords`, `iconR/G/B`, `label`
  or the name); clicks call `OnClick(frame, button)`, hovering calls `OnTooltipShow(GameTooltip)` or
  `OnEnter`/`OnLeave`;
- **pinned** as its own badge (`ldb.<name>`) on the user's choice: icon + `text` (or `value` .. `suffix`), redrawn on
  `LibDataBroker_AttributeChanged`;
- its **LibDBIcon** minimap button (same name) hidden while it's in the tray or pinned, unless the user says otherwise.

The user decides per object on the console's LDB page. For a richer presence (fields, contexts, sections, settings
pages) use the native API instead or as well; an addon can do both.

### 4.12 Layout

There is one bar, never more. The user picks its layout on the Bar page:

- `Deadbeat.Layout() → "compact" | "top" | "bottom"`: compact is the centred, movable bar (34 px, grows 420–760 px);
  top and bottom are full-width edge bars (22 px) with the fields on the left and badges on the right or in a centre
  zone (the user's choice per badge).
- `module:OnLayout(function(layout) end)`: called when it changes.
- If you anchor your own frames to `Deadbeat.frame`, open them **away from the edge**: below the bar for compact and
  top, above it for bottom. Docked panels (`m:Dock`) are handled for you.
- Draw badges for 14 px height in every layout; in full-width the band is a 3 px line.

## 5. Rules for modules

1. **Never break the bar.** Guard WoW calls that can fail (`pcall` around APIs that may be missing on Forever).
2. **Secret values.** Forever returns secret values from some APIs (GUIDs, aura and loot data in some states, even
   `UnitIsAFK`). Check `issecretvalue(v)` before any comparison or `if`; skip the value if it's secret.
3. **No taint.** Never show, hide, move or change attributes of protected frames in combat. Secure buttons are fine
   if you only change them out of combat (`InCombatLockdown()`), and defer otherwise.
4. **One SavedVariables per addon**, named after it. No personal data in code (character names, realms, machines).
5. **Badges have ids, settings are rows, sections are short and context-aware.**
6. **Look like the hub:** use the kit, no default Blizzard panels.
7. **Forever quirks:** there is no `os` library (use `date`, `time`); new files in an addon need a client restart,
   changed files only `/reload`.

## 6. Changes

- **1.0** (Deadbeat 1.0): everything stable except the band; `Deadbeat.SPEC = "1.0"`.
- **0.1 additions** before 1.0: the LibDataBroker bridge (Deadbeat 0.4), layouts (Deadbeat 0.5).
- **0.1** (Deadbeat 0.3.1): the first written spec.
