-- Hello: the example Deadbeat module (spec 2.0). It counts how often you've been greeted and shows every part of the
-- API once: two items and a widget in its group, a tooltip, a click, a settings page, contexts. Copy it, rename it,
-- keep what you need. The look and the rules: deadbeat-spec DESIGN.md.
local ADDON = ...

local db
local m, greetings, mood, dots

local function draw()
    if not m then return end
    greetings:Set(tostring(db.greetings), db.greetings >= 10 and "good" or "normal")
    mood:Set(db.greetings > 0 and "happy" or "waiting")
    for i, d in ipairs(dots) do d:SetShown(i <= math.min(5, db.greetings)) end
end

local function greet()
    db.greetings = db.greetings + db.step
    draw()
end

local function register()
    local K = Deadbeat.kit
    m = Deadbeat.Register("Hello", { icon = "Interface\\Icons\\INV_Misc_Rune_01", spec = "2.0" })

    -- items: icon + value; at most three on the bar by default, the rest wait on the shelf
    greetings = m:Item("greetings", { name = "Greetings", icon = "Interface\\Icons\\INV_Misc_Rune_01",
                                      contexts = { city = true, world = true } })
    mood = m:Item("mood", { name = "Mood", icon = "Interface\\Icons\\Spell_Holy_Heal", default = false })

    -- a widget: a small frame (≤ 64 × 14) to draw into
    local canvas = m:Widget("dots", { name = "Dots", width = 40 })
    dots = {}
    for i = 1, 5 do
        local d = canvas:CreateTexture(nil, "ARTWORK")
        d:SetSize(5, 5)
        d:SetPoint("LEFT", (i - 1) * 8, 0)
        d:SetColorTexture(K.P.goldOn[1], K.P.goldOn[2], K.P.goldOn[3], 1)
        dots[i] = d
    end

    -- the tooltip: only your lines (the hub draws the header and the hints); details behind Shift
    m:Tooltip(function(tip, item, shift)
        local g = K.P.warmGrey
        tip:AddDoubleLine("  Greetings", tostring(db.greetings), g[1], g[2], g[3], 1, 1, 1)
        if shift then tip:AddDoubleLine("  Per click", tostring(db.step), g[1], g[2], g[3], 1, 1, 1) end
    end)

    -- left-click: one obvious action, with its hint; right-click opens the settings page (the hub does that)
    m:Click(function() greet() end, "greet")

    m:OnContext(function() draw() end)                        -- farm / raid / dungeon / city / world

    m:Options({ title = "Hello", icon = "Interface\\Icons\\INV_Misc_Rune_01", rows = {
        { kind = "header", label = "Greetings" },
        { kind = "note", label = "Hello counts greetings. Click its item on the bar to greet." },
        { kind = "slider", label = "Greetings per click", min = 1, max = 10, step = 1, fmt = "%d",
          get = function() return db.step end, set = function(v) db.step = v end },
        { kind = "keys", label = "Greet key", get = function(slot) return db.keys[slot] end,
          set = function(slot, key) db.keys[slot] = key end },
        { kind = "button", label = "Forget all greetings", text = "Reset", confirm = true,
          run = function() db.greetings = 0 draw() end },
        { kind = "custom", height = 40, build = function(frame)
              local fs = K.text(frame, "GameFontHighlight", K.P.goldOn)
              fs:SetPoint("LEFT", 4, 0)
              frame.fs = fs
          end,
          show = function(frame) frame.fs:SetText(("You've been greeted %d times."):format(db.greetings)) end },
    } })
    draw()
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == ADDON then
        HelloDB = HelloDB or {}
        db = HelloDB
        db.greetings, db.step, db.keys = db.greetings or 0, db.step or 1, db.keys or {}
    elseif event == "PLAYER_LOGIN" then
        if Deadbeat and Deadbeat.SPEC and Deadbeat.SPEC >= "2.0" then register() end   -- without it: no error
    end
end)
