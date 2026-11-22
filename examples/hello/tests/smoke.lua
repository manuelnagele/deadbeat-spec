-- luajit tests/smoke.lua (from examples/hello): Hello on Deadbeat, through the harness.
local H = dofile(os.getenv("HARNESS") or "../../harness/wowstub.lua")
H.loadDeadbeat(os.getenv("DEADBEAT") or "../../../deadbeat")
H.load("Hello", { "Hello/Hello.lua" })
H.start("Hello")

assert(HelloDB and HelloDB.greetings == 0, "saved variables set up")
local label
rawset(DeadbeatBar.label, "SetText", function(_, t) label = t end)
Deadbeat.Refresh()
assert(label == "Hello", "owns the label at priority 5: " .. tostring(label))
DeadbeatBar:_script("OnClick", "LeftButton")
assert(HelloDB.greetings == 1, "a click on the bar greets")
assert(H.tooltip():find("Hello"), "tooltip section")
Deadbeat.OpenSettings("Hello")
assert(DeadbeatSettings, "settings page")
print("hello smoke ok")
