# AGENTS.md: making an addon a Deadbeat module

For AI coding assistants (and people) turning a WoW: Forever addon into a **Deadbeat module**: a citizen of the
shared bar at the top of the screen. Read this file, then [spec.md](spec.md) for details; copy from
[examples/hello](examples/hello). Target: **spec 2.0** (Deadbeat 2.0). The look and rules: [DESIGN.md](DESIGN.md).

## What "done" means

1. The addon still works **without Deadbeat** installed (no errors, its own UI or nothing).
2. With Deadbeat it **registers a module** and offers a few **items** (≤ 3 on the bar by default) with a tooltip
   and, if there's one obvious action, a click.
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
    if not (Deadbeat and Deadbeat.SPEC and Deadbeat.SPEC >= "2.0") then return end
    local m = Deadbeat.Register("YourAddon", { icon = "Interface\\Icons\\…", spec = "2.0" })
    -- …
end)
```

### 3. Pick your items

Ask: *what would the player want to glance at, and where?* Each answer is one item: an icon and a short value.

```lua
local gold = m:Item("gold", { name = "Gold", icon = "Interface\\Icons\\INV_Misc_Coin_01",
                              contexts = { city = true, world = true } })
gold:Set("412g", "normal")                 -- normal | good | warn | bad (the text must say it too)
local extra = m:Item("rate", { name = "Gold per hour", default = false })   -- waits on the shelf
m:Tooltip(function(tip, item, shift)       -- your lines only; the hub draws the header and hints
    tip:AddDoubleLine("  Today", "+18g", 0.56, 0.51, 0.46, 1, 1, 1)
end)
m:Click(function(item, button) ToggleMyWindow() end, "open the window")
```

- **At most three default items;** the rest `default = false` (the player can add them from the shelf).
- **Values short** (≤ 8 characters ideally); **colour only for a state** and never alone.
- **A widget** (`m:Widget(id, { width })`) only when an icon and a value can't say it (≤ 64 × 14 px).
- **Contexts:** where is each item worth the space? `farm`, `raid`, `dungeon`, `city`, `world`.
- **Tooltip:** short, details behind `shift`, nothing outside the current context.
- **Click:** one obvious action, or none. Right-click is the hub's (it opens your settings page).

Don't decide where your group sits: the player does, in edit mode. Keep it small: a module that shouts gets hidden.

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
assert(H.tooltip():find("YourAddon"), "item tooltips")
Deadbeat.OpenSettings("YourAddon")                     -- builds your page: every row's get() runs
print("smoke ok")
```

Stub any WoW API your addon calls that the harness lacks (`function GetNetStats() return 0, 0, 50, 60 end`) before
loading it. Put pure logic in its own file (`Core.lua`, no WoW calls) with plain unit tests (`tests/run.lua`).

### 7. Finish with the checklist

- [ ] Works without Deadbeat (load it alone in your head: every `Deadbeat.` call behind `if Deadbeat`).
- [ ] `Register` once; module name and item ids are unique and stable; an icon for the module.
- [ ] At most three default items; values short; states backed by text.
- [ ] Tooltip lines short and context-aware; details behind `shift`; one obvious click or none.
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
- Don't use the 1.x calls (`Set` fields, `Badge`, `Section`, `OnClick`): they still work, but they're legacy.
- Don't print to chat on every event; one line on real news at most.
