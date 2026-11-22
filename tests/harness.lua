-- luajit tests/harness.lua (from the repo root): the harness loads the hub and its helpers work.
local H = dofile("harness/wowstub.lua")
H.loadDeadbeat(os.getenv("DEADBEAT") or "../deadbeat")
local m = Deadbeat.Register("Probe", 99)
local ticked = 0
C_Timer.NewTicker(1, function() ticked = ticked + 1 end)
H.tick()
assert(ticked == 1, "H.tick runs tickers")
m:Section(function(tip) tip:AddLine("probe line") end)
assert(H.tooltip():find("probe line"), "H.tooltip shows sections")
local seen
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(_, e, a) seen = e .. a end)
H.fire("TEST_EVENT", "x")
assert(seen == "TEST_EVENTx", "H.fire reaches frames")
for _, ctx in ipairs(Deadbeat.CONTEXTS) do assert(type(ctx) == "string") end
print("harness ok")
