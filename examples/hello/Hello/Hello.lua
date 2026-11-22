-- Hello: the example Deadbeat module (spec 1.0). It counts how often you've been greeted (clicks on its badge or on
-- the bar while it owns the label) and shows every part of the API once. Copy it, rename it, keep what you need.
local ADDON = ...

local db
local m, badge

local function draw()
    if not m then return end
    -- a field: low priority, so other modules' activities win
    if db.showLabel then m:Set("label", "Hello", 5) else m:Clear("label") end
    m:Set("primary", tostring(db.greetings), 5)
    -- a badge: an icon and a number
    badge.text:SetText(tostring(db.greetings))
    badge:SetWidth(16 + (badge.text:GetStringWidth() or 10))
    Deadbeat.Refresh()
end

local function greet()
    db.greetings = db.greetings + db.step
    draw()
    Deadbeat.RefreshTooltip()
end

local function register()
    local K = Deadbeat.kit
    m = Deadbeat.Register("Hello", 70, { spec = "1.0" })

    badge = m:Badge(30, { id = "hello.count", label = "Greetings", contexts = { city = true, world = true } })
    badge.icon = badge:CreateTexture(nil, "ARTWORK")
    badge.icon:SetSize(13, 13)
    badge.icon:SetPoint("LEFT")
    badge.icon:SetTexture("Interface\\Icons\\INV_Misc_Rune_01")
    badge.text = badge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    badge.text:SetPoint("LEFT", 16, 0)

    m:OnClick(function() greet() end)                         -- clicks on the bar while Hello owns the label

    m:Section(function(tip, shift)                            -- the tooltip: short, and only where it matters
        if Deadbeat.Context() == "raid" then return end
        local g = K.P.warmGrey
        tip:AddLine("Hello", K.P.bronze4[1], K.P.bronze4[2], K.P.bronze4[3])
        tip:AddDoubleLine("  Greetings", tostring(db.greetings), g[1], g[2], g[3], 1, 1, 1)
        if shift then tip:AddDoubleLine("  Step", tostring(db.step), g[1], g[2], g[3], 1, 1, 1) end
    end)

    m:OnContext(function() draw() end)                        -- farm / raid / dungeon / city / world

    m:Options({ title = "Hello", icon = "Interface\\Icons\\INV_Misc_Rune_01", rows = {
        { kind = "header", label = "Greetings" },
        { kind = "note", label = "Hello counts greetings. Click its badge or the bar to greet." },
        { kind = "toggle", label = "Show \"Hello\" on the bar", get = function() return db.showLabel end,
          set = function(on) db.showLabel = on draw() end },
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
        if db.showLabel == nil then db.showLabel = true end
    elseif event == "PLAYER_LOGIN" then
        if Deadbeat then register() end                       -- without Deadbeat: nothing to show, no error
    end
end)
