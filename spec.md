# Deadbeat spec 2.0

*Status: 2.0, implemented by Deadbeat 2.0. The look and the rules behind it: [DESIGN.md](DESIGN.md). History in §7.*

Deadbeat is one bar for WoW: Forever that any addon can sit on. The hub draws the bar, the items on it, their
tooltips, the settings console and edit mode; **modules** (any addon) offer items through the API below. A module
must work without Deadbeat and must never break the bar.

## 1. Versioning

- The spec has its own version, `MAJOR.MINOR`. A minor only adds; only a major removes or changes.
- `Deadbeat.SPEC` is the version the hub implements (`"2.0"`). A module says what it targets with
  `Register(name, { spec = "2.0" })`; a newer major than the hub's gets one chat line asking to update Deadbeat.
- Everything in this document is **stable**. Anything not here (other `Deadbeat.*` functions, fields of module or
  item tables, frame names) is internal and may change.

## 2. Concepts

| Term | Meaning |
|---|---|
| **Module** | An addon (or part of one) registered with `Deadbeat.Register`. It owns one **group** on the bar. |
| **Item** | The smallest unit on the bar: a round icon, a short value, an optional label (value item), an icon only (launcher) or a small custom graphic (widget). Owned by one module. |
| **Group** | A module's items, side by side; a thin divider separates groups. |
| **Shelf** | Items not on the bar: the player's hidden ones and modules' non-default ones. Edit mode shows it. |
| **Context** | Where the player is: `farm`, `raid`, `dungeon`, `city`, `world`. Items show in their contexts. |
| **Layout** | `compact` (centred, movable, grows to 760 px, then "…") or full-width `top` / `bottom` with left, centre and right zones. |
| **System items** | The LDB tray and the gear at the right end; not movable. |

The **player** arranges the bar in edit mode: group order, zones, item order within a group, which items show,
where, and with labels. Modules never decide placement; a new module's group is appended at the right end.

## 3. Lifecycle

```
## OptionalDeps: Deadbeat
```

Register at `PLAYER_LOGIN` or later, only when `Deadbeat` exists and `Deadbeat.SPEC >= "2.0"`. Without Deadbeat a
module falls back to its own UI or shows nothing; it must not error.

## 4. API

### 4.1 Registering

`Deadbeat.Register(name, opts) → module`

- `name`: unique; the group's name in tooltips, edit mode and the console. Same name → same module.
- `opts`: `{ icon = path, spec = "2.0" }`. The icon heads your tooltips.

### 4.2 Items

`module:Item(id, opts) → item`

- `id`: unique within the module and stable across versions (the player's choices are saved under `Module.id`).
- `opts`: `name` (tooltips, shelf, console), `icon`, `default` (on the bar out of the box; default `true`; **at most
  three showing at once in any place**), `contexts` (where it shows by default, e.g. `{ raid = true, world = true }`; omitted =
  everywhere), `kind = "launcher"` for an icon-only item.
- `item:Set(value, state)`: a short string (≤ 8 characters ideally, 16 at most) and one of `normal`, `good`,
  `warn`, `bad` (colours the value; the text must say it too).
- `item:SetIcon(path)`, `item:Show()`, `item:Hide()` (e.g. no mail, no item), `item:IsShown()`.
- `Item` again with the same id returns the same item.

### 4.3 Widgets

`module:Widget(id, opts) → frame, item`

A frame `opts.width` × 14 px (≤ 64) to draw into. Show and hide the frame as you like; after `frame:SetWidth(w)` call
`Deadbeat.Refresh()`. Other `opts` as for items. Only where an icon and a value can't say it (Lockout's diamonds).

### 4.4 Tooltip and click

- `module:Tooltip(function(tip, item, shift) end)`: **your lines only** for that item (`tip:AddLine`,
  `tip:AddDoubleLine`, two-space indent). The hub draws the header (icon · module · item) and the hint line. Details
  only when `shift`; about 8 lines at most otherwise; nothing that doesn't matter in `Deadbeat.Context()`.
- `module:Click(function(item, button) end, hint)`: the left-click action; `hint` (a string or `function(item)`)
  shows as "Click: …". One obvious action, or none.
- **Right-click** opens the module's first settings page; **shift-drag** moves the compact bar. Modules can't
  change either.
- `Deadbeat.RefreshTooltip()` redraws an open tooltip after your data changed.

### 4.5 Settings

`module:Options(page)` · `Deadbeat.OpenSettings(title)`

A page in the console: `{ title, icon, rows = { … } }`; right-click opens the first. Rows:

| kind | fields |
|---|---|
| `header` | `label` |
| `note` | `label` |
| `toggle` | `label`, `get() → bool`, `set(bool)` |
| `button` | `label`, `text`, `run()`, `confirm` (a second click within 3 s does it) |
| `slider` | `label`, `min`, `max`, `step`, `get()`, `set(n)`, `fmt` |
| `keys` | `label`, `get(slot)`, `set(slot, key)`; `slot` = `"key"` or `"pad"` |
| `custom` | `height` (number or function), `build(frame, width)`, `show(frame)` |

Every setting is a row; slash commands only as shortcuts.

### 4.6 Contexts

`Deadbeat.Context()` → `farm` | `raid` | `dungeon` | `city` | `world` (`Deadbeat.CONTEXTS` in order).
`module:Claim("farm", on)` while the player farms with your addon. `module:OnContext(fn)`.

### 4.7 Layout and the dock

`Deadbeat.Layout()` → `compact` | `top` | `bottom`; `module:OnLayout(fn)`. Frames you anchor to `Deadbeat.frame` open
away from the edge (below for compact and top, above for bottom). `module:Dock(frame)` stacks your panel under (or
above) the bar; `Deadbeat.DockEnd()` is the last docked frame.

### 4.8 The kit

`Deadbeat.kit` (`K`): `K.P` palette (`ground`, `bronze1`–`bronze4`, `goldOn`, `warmGrey`), `K.GREEN`, `K.RED`,
`K.soft`, `K.hex`, `K.coins(copper, size, whole)`, `K.clock(seconds)`, `K.icon(path, size)`, `K.swatch`,
`K.ground(frame, alpha)`, `K.border(frame, thin)`, `K.text(parent, template, color)`, `K.flash`, `K.media`,
`K.barTexture`. Also `Deadbeat.Refresh()`, `Deadbeat.version`, `Deadbeat.frame`.

### 4.9 LibDataBroker

Addons with LDB data objects need no Deadbeat code: every object sits in the tray (a drop-down of icons) and is an
item of the "LDB" group, on the shelf until pinned. Both clicks and the tooltip go to the object (`OnClick`,
`OnTooltipShow`, `OnEnter`/`OnLeave`); a pinned data source shows its `text`. LibDBIcon minimap buttons can be hidden
while their object is on the bar.

### 4.10 1.x calls (until spec 3.0)

They keep working through 2.x: `Set`/`Clear` fields become one item per module (the fields joined), `Badge` a widget
item, `Section` the module's tooltip, `OnClick` its click, `Band` draws into nothing. One chat note per module.

## 5. Rules for modules

1. **One module, one group,** with a name and an icon.
2. **Items say one thing each;** short values; a state colour always backed by the text; ≤ 3 default items
   showing at once in any place.
3. **Tooltips:** your lines only, short, context-aware, details behind Shift.
4. **Never break the bar:** `pcall` around APIs that may be missing.
5. **Secret values** (Forever): check `issecretvalue(v)` before any comparison or `if`.
6. **No taint:** never show, hide, move or re-attribute protected frames in combat.
7. **One SavedVariables per addon;** no personal data in code.
8. **Forever:** no `os` library (`date`, `time`); a new file needs a client restart.
9. **Stay in your items:** never touch other groups or the bar.

## 6. Testing

The [harness](harness/) loads the hub from its TOC: `H.loadDeadbeat()`, `H.load(addon, files)`, `H.start(addon)`,
`H.fire(event, …)`, `H.tick()`, `H.tooltip(item)` (every item's with no argument). See [examples/hello](examples/hello).

## 7. Changes

- **2.0** (Deadbeat 2.0): the design language. Items owned by modules, groups, one interaction model, edit mode and
  the shelf; `Register(name, opts)`, `Item`, `Widget`, `Tooltip`, `Click`. Shared fields, priorities, badges, bands and
  the whole-bar tooltip are gone (1.x calls keep working until 3.0).
- **1.0** (Deadbeat 1.0): fields, badges, sections, settings, contexts, layouts, the LDB bridge.
