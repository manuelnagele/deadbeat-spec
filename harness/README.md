# Harness

A stubbed WoW API for testing Deadbeat and its modules with plain LuaJIT, outside the game.

```lua
local H = dofile(os.getenv("HARNESS") or "../deadbeat-spec/harness/wowstub.lua")
H.loadDeadbeat()                                   -- the hub, from $DEADBEAT or ../deadbeat
local ns = H.load("Hello", { "Hello/Hello.lua" })  -- your files, called as (addonName, ns) like the client does
H.start("Hello")                                   -- ADDON_LOADED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
H.tick()                                           -- every C_Timer.NewTicker callback once
H.fire("BAG_UPDATE_DELAYED")                       -- any event, on every frame
assert(H.tooltip():find("Hello"))                  -- hover the bar, get its tooltip lines
Deadbeat.OpenSettings("Hello")                     -- builds your settings page (rows, custom UI)
```

What it gives you:
- `CreateFrame` returns a stub that remembers `SetScript`/`RegisterEvent`; `frame:_fire(event, ...)` and
  `frame:_script("OnClick", ...)` drive them. A named frame becomes a global. Any other method exists and returns nil
  (`GetWidth` 300, `GetHeight` 3, `IsShown` true).
- `C_Timer.After` runs at once; `NewTicker` callbacks are collected (`H.tick()`); `NewTimer` never fires.
- `GameTooltip` records lines (`H.tipLines`; the left text of double lines).
- Common globals: `GetTime`, `time`, `date`, `GetMoney`, `UnitGUID` (`"Player-1-ABC"`), `IsInInstance` (a party
  instance), `GetInstanceInfo`, `GetZoneText`, `strsplit`, `strtrim`, `SlashCmdList`, `C_Item`, `C_Spell`.

Override any global in your test before loading your addon (`function IsResting() return true end`). Things the stub
can't see: secret values, taint, protected frames in combat, real layout. Check those in game.
