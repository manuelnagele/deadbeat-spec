-- luajit tests/smoke.lua (from examples/hello): Hello on Deadbeat 2.0, through the harness.
local H = dofile(os.getenv("HARNESS") or "../../harness/wowstub.lua")
H.loadDeadbeat(os.getenv("DEADBEAT") or "../../../deadbeat")
H.load("Hello", { "Hello/Hello.lua" })
H.start("Hello")

assert(HelloDB and HelloDB.greetings == 0, "saved variables set up")
local m
for _, it in ipairs(Deadbeat.Items()) do if it.key == "Hello.greetings" then m = it end end
assert(m and m.value == "0", "the greetings item shows 0")
m.frame:_script("OnClick", "LeftButton")
assert(HelloDB.greetings == 1 and m.value == "1", "a click greets")
local tip = H.tooltip(m)
assert(tip:find("Hello") and tip:find("Greetings") and tip:find("Click: greet"), "tooltip: " .. tip)
m.frame:_script("OnClick", "RightButton")
assert(DeadbeatSettings, "right-click opens the settings page")
print("hello smoke ok")
