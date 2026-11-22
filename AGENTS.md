# AGENTS.md: making an addon a Deadbeat module

For AI coding assistants (and people) turning a WoW: Forever addon into a **Deadbeat module**: a citizen of the
shared bar at the top of the screen. Read this file, then [spec.md](spec.md) for details; copy from
[examples/hello](examples/hello). Target: **spec 1.0** (Deadbeat 1.0).

## What "done" means

1. The addon still works **without Deadbeat** installed (no errors, its own UI or nothing).
2. With Deadbeat it **registers a module** and puts something useful on the bar: a field, a badge or a tooltip
   section (usually all three, small).
3. **Every user setting is a row** on its own settings page (no setting reachable only by a slash command).
4. It passes a **smoke test on the harness** (`luajit tests/smoke.lua`).
5. It follows the **rules** below (secret values, taint, look, ids).

## Step by step

### 1. TOC

```
## Interface: 16001
## OptionalDeps: Deadbeat
## SavedVariables: YourAddonDB
```
`OptionalDeps` (not `Dependencies`) unless the addon is useless without the bar.

### 2. Register at PLAYER_LOGIN, only if Deadbeat is there

```lua
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not Deadbeat then return end
    local m = Deadbeat.Register("YourAddon", 70, { spec = "1.0" })   -- unique name; order 70+; the spec you target
    -- …
end)
```

### 3. Pick what goes on the bar

Ask: *what would the player want to glance at, and where?*

- **A field** (`m:Set(field, text, priority)`) when your addon has a headline: a run name, a score, a state. Use a
  low priority (5–19) for everyday info and 20+ only during an activity the player started. Fields are shared:
  higher priority wins. Clear them when your activity ends.
- **A badge** (`m:Badge(width, { id, label, contexts })`) for a small always-there number or icon: an icon (13 px)
  and a short text in a 14 px high frame. Give it an `id` like `"youraddon.thing"` and default `contexts`
  (`farm`, `raid`, `dungeon`, `city`, `world`): where is it worth the space?
- **A tooltip section** (`m:Section(fn(tip, shift))`) for details: a header line, then two-space-indented lines;
  extra detail only when `shift` is true. **Return early when it isn't relevant in `Deadbeat.Context()`.**
- **Clicks:** `m:OnClick(fn)` fires when your module owns the `label`.

Keep it small. The bar is shared by many modules; a module that shouts gets switched off.

### 4. Settings page

Move every option into `m:Options({ title, icon, rows = { … } })`: `toggle` for on/off, `slider` for numbers, `button`
for actions (`confirm = true` for anything destructive), `keys` for key bindings (keyboard + controller), `note` and
`header` to explain, `custom` for your own UI (a list, a picker). Keep slash commands as shortcuts if you like; make
them open your page with `Deadbeat.OpenSettings("YourAddon")`.

### 5. Look

Use `Deadbeat.kit` (`K`): `K.P` palette (bronze, warm grey, gold), `K.GREEN`/`K.RED` for good/bad, `K.coins()` for
money, `K.ground()`/`K.border()` for any frame you make, `K.text()` for font strings. No default Blizzard panels or
bright pure colours. Small motion is fine (`K.flash`), alarms are not.

### 6. Test on the harness

Clone [deadbeat](https://github.com/manuelnagele/deadbeat) and this repo next to your addon, then write
`tests/smoke.lua`:

```lua
local H = dofile(os.getenv("HARNESS") or "../deadbeat-spec/harness/wowstub.lua")
H.loadDeadbeat()                                       -- ../deadbeat or $DEADBEAT
H.load("YourAddon", { "YourAddon/Core.lua", "YourAddon/YourAddon.lua" })
H.start("YourAddon")
H.tick()
assert(H.tooltip():find("YourAddon"), "tooltip section")
Deadbeat.OpenSettings("YourAddon")                     -- builds your page: every row's get() runs
print("smoke ok")
```

Stub any WoW API your addon calls that the harness lacks (`function GetNetStats() return 0, 0, 50, 60 end`) before
loading it. Put pure logic in its own file (`Core.lua`, no WoW calls) with plain unit tests (`tests/run.lua`).

### 7. Finish with the checklist

- [ ] Works without Deadbeat (load it alone in your head: every `Deadbeat.` call behind `if Deadbeat`).
- [ ] `Register` once; module name and badge ids are unique and stable.
- [ ] Field priorities follow the table in spec §4.2; fields cleared when the activity ends.
- [ ] Sections return early outside their context; nerd stats behind `shift`.
- [ ] Every setting is a row; destructive buttons have `confirm = true`.
- [ ] Secret values checked; nothing protected touched in combat.
- [ ] Smoke test green; pure logic unit-tested.
- [ ] An **in-game checklist** written for the human: what to look at in the client to confirm it works.

## Rules (from spec §5)

1. **Never break the bar.** `pcall` around APIs that may be missing.
2. **Secret values** (Forever): `if issecretvalue and issecretvalue(v) then` skip `v`, before any comparison or `if`.
   Seen on GUIDs, aura and loot data, even `UnitIsAFK`.
3. **No taint:** never show/hide/move/re-attribute protected frames in combat (`InCombatLockdown()`); defer to
   `PLAYER_REGEN_ENABLED`.
4. **One SavedVariables per addon.** No personal data in code.
5. **Forever:** no `os` library (`date`, `time` instead); a new file needs a client restart, a changed one `/reload`.

## Don't

- Don't restyle or move `Deadbeat.frame`, don't call internal `Deadbeat.*` functions not in spec.md.
- Don't claim `farm` unless the player is actively farming with your addon.
- Don't use priority 50+ for anything but a focused activity the player chose.
- Don't print to chat on every event; one line on real news at most.
