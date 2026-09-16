--[[
    ╔══════════════════════════════════════════════════════════╗
    ║      GOJO ANTI-LOGGER  •  V5  "MOBILE STABLE"            ║
    ║      made by gojo discord @oghone                        ║
    ║                                                          ║
    ║  • Anti IP-log                                           ║
    ║  • Anti Roblox/FPS crash (lightweight, no hot hooks)     ║
    ║  • Anti force-kick (7-vector)                            ║
    ║  • TradeService remote killer + remake kick              ║
    ║  • Branded "OWNED BY GOJO" toasts                        ║
    ║  • Optimized for mobile (Delta/Arceus/Codex)             ║
    ╚══════════════════════════════════════════════════════════╝
]]

-- ══════════════════ CLEANUP ══════════════════
do
    local g = (getgenv and getgenv()) or _G
    for _, key in ipairs({"GOJO_AL_GUI","GOJO_AL_REOPENER","GOJO_AL_CONNS"}) do
        pcall(function()
            local v = g[key]
            if typeof(v) == "Instance" then v:Destroy() end
            if typeof(v) == "table" then
                for _, c in ipairs(v) do pcall(function() c:Disconnect() end) end
            end
        end)
        g[key] = nil
    end
    g.GOJO_AL_LOADED = true
    g.GOJO_AL_ALLOW_KICK = false
    g.GOJO_AL_CONNS = {}
end

-- ══════════════════ EXECUTOR CAPS ══════════════════
local CAP = {
    hookfunction   = type(hookfunction) == "function",
    getrawmetatable= type(getrawmetatable) == "function",
    setreadonly    = type(setreadonly) == "function",
    newcclosure    = type(newcclosure) == "function",
    getnamecall    = type(getnamecallmethod) == "function",
    getcallingscr  = type(getcallingscript) == "function",
    debug_info     = (debug and (debug.info or debug.getinfo)) ~= nil,
}
local ENV = (getgenv and getgenv()) or _G

-- ══════════════════ SERVICES ══════════════════
local Players  = game:GetService("Players")
local RS       = game:GetService("ReplicatedStorage")
local UIS      = game:GetService("UserInputService")
local Tween    = game:GetService("TweenService")
local Run      = game:GetService("RunService")
local CoreGui  = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- Mobile detection
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ══════════════════ BRANDED MESSAGES ══════════════════
local function pick(t) return t[math.random(1, #t)] end
local BRAND = {
    load_block = {
        "🛡️ OWNED BY GOJO — logger pre-blocked",
        "🛡️ Six Eyes saw it. It's gone.",
        "🛡️ Gojo ate your logger for breakfast.",
        "🛡️ Infinity blocked it. Try again, skid.",
        "🛡️ Logger? More like logged-by-Gojo.",
        "🛡️ Deleted before you could blink.",
    },
    webhook_block = {
        "🛡️ Webhook owned by Gojo",
        "🛡️ IP-logger? Not today.",
        "🛡️ Discord webhook → deleted by Infinity",
    },
    kick_block = {
        "🛡️ Kick blocked by Infinity",
        "🛡️ Nah. Gojo blocked your kick.",
        "🛡️ You can't kick the strongest.",
    },
    crash_block = {
        "🛡️ Crash attempt owned by Gojo",
        "🛡️ FPS protected. Six Eyes sees all.",
        "🛡️ Crashing? Not on my server.",
    },
    fps_recover = {
        "🛡️ FPS STABILIZED",
        "🛡️ Frame rate recovered",
        "🛡️ Six Eyes stabilized your FPS",
    },
}
local KICK_MESSAGES = {
    "100% logger no anti logger can stop 🛡️",
    "💀 Caught in 4K — logged the logger.",
    "🛡️ Gojo blocked this. Try harder, skid.",
    "⚡ Anti-Logger V5 says no.",
    "🎯 Logger detected → rekt → kicked.",
    "🚫 Nice try, but Gojo sees all.",
    "🔥 Self-destruct triggered. Logging attempt voided.",
    "👁️ Geto would be proud — you got kicked.",
    "💥 Bang. You got domain-expansion'd by the anti-logger.",
    "🛡️ Six Eyes saw you. Cya.",
}

-- ══════════════════ CONFIG ══════════════════
local WATCHED = {
    { full = "Packages.Net.RF/TradeService/SearchUser" },
    { full = "Packages.Net.RE/TradeService/Accept"     },
    { full = "Packages.Net.RF/TradeService/AddBrainrot"},
}
local WATCHED_NAMES = {
    ["RF/TradeService/SearchUser"]  = true,
    ["RE/TradeService/Accept"]      = true,
    ["RF/TradeService/AddBrainrot"] = true,
    ["SearchUser"]                  = true,
    ["AddBrainrot"]                 = true,
    ["Accept"]                      = true,
}

local LOG_CAP = 30
local FPS_SAMPLE_EVERY = IS_MOBILE and 40 or 20

local state = {
    enabled  = true,
    scanning = false,
    blocked  = 0,
    kicked   = 0,
}

-- ══════════════════ GUI HELPERS ══════════════════
local function corner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=p; return c end
local function stroke(p, col, tr, th)
    local s=Instance.new("UIStroke"); s.Color=col; s.Transparency=tr or 0.5
    s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    s.Parent=p; return s
end
local function padding(p, t, r, b, l)
    local u=Instance.new("UIPadding")
    u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0)
    u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0)
    u.Parent=p; return u
end

local sg = Instance.new("ScreenGui")
sg.Name = "GojoAntiLoggerV5"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 2147483647
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okp = pcall(function() sg.Parent = PG end)
if not okp or not sg.Parent then pcall(function() sg.Parent = CoreGui end) end
ENV.GOJO_AL_GUI = sg

-- ─── Toasts (lightweight on mobile) ───
local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.new(1, 0, 0, 0)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = sg
local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 5)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastHolder
padding(toastHolder, 8, 0, 0, 0)

local toastOrder = 0
local activeToasts = 0
local MAX_TOASTS = IS_MOBILE and 2 or 4

local function showToast(title, subtitle, color, duration)
    if activeToasts >= MAX_TOASTS then return end
    activeToasts = activeToasts + 1
    color = color or Color3.fromRGB(120, 90, 255)
    duration = duration or 3
    toastOrder = toastOrder + 1

    local W = IS_MOBILE and 280 or 340
    local t = Instance.new("Frame")
    t.Size = UDim2.new(0, W, 0, 48)
    t.Position = UDim2.new(0.5, -W/2, 0, -55)
    t.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    t.BorderSizePixel = 0
    t.LayoutOrder = toastOrder
    t.Parent = toastHolder
    corner(t, 10)
    local st = stroke(t, color, 0.3, 1.5)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -10)
    accent.Position = UDim2.new(0, 5, 0, 5)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = t
    corner(accent, 2)

    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, -22, 0, 16)
    tt.Position = UDim2.new(0, 14, 0, 7)
    tt.BackgroundTransparency = 1
    tt.Text = title
    tt.TextColor3 = Color3.fromRGB(240, 240, 250)
    tt.Font = Enum.Font.GothamBold
    tt.TextSize = 11
    tt.TextXAlignment = Enum.TextXAlignment.Left
    tt.TextTruncate = Enum.TextTruncate.AtEnd
    tt.Parent = t

    local ss = Instance.new("TextLabel")
    ss.Size = UDim2.new(1, -22, 0, 14)
    ss.Position = UDim2.new(0, 14, 0, 24)
    ss.BackgroundTransparency = 1
    ss.Text = subtitle
    ss.TextColor3 = Color3.fromRGB(150, 150, 170)
    ss.Font = Enum.Font.Gotham
    ss.TextSize = 9
    ss.TextXAlignment = Enum.TextXAlignment.Left
    ss.TextTruncate = Enum.TextTruncate.AtEnd
    ss.Parent = t

    Tween:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -W/2, 0, 0)}):Play()

    task.delay(duration, function()
        Tween:Create(t, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -W/2, 0, -55), BackgroundTransparency = 1}):Play()
        Tween:Create(st, TweenInfo.new(0.25), {Transparency = 1}):Play()
        task.wait(0.3)
        pcall(function() t:Destroy() end)
        activeToasts = activeToasts - 1
    end)
end

-- ─── Main Window (smaller on mobile) ───
local W_MAIN = IS_MOBILE and 240 or 280
local H_MAIN = IS_MOBILE and 340 or 400

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, W_MAIN, 0, H_MAIN)
main.Position = UDim2.new(0, 20, 0.5, -H_MAIN/2)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg
corner(main, 14)
stroke(main, Color3.fromRGB(80, 60, 160), 0.35, 1.5)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, -24, 0, 3)
accent.Position = UDim2.new(0, 12, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(140, 100, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 2
accent.Parent = main
corner(accent, 2)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -56, 0, 18)
title.Position = UDim2.new(0, 14, 0, 12)
title.BackgroundTransparency = 1
title.Text = "🛡  Anti-Logger V5"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = IS_MOBILE and 12 or 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -56, 0, 12)
subtitle.Position = UDim2.new(0, 14, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "made by gojo discord @oghone"
subtitle.TextColor3 = Color3.fromRGB(140, 130, 170)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 3
subtitle.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -32, 0, 12)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
closeBtn.Text = "−"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 4
closeBtn.Parent = main
corner(closeBtn, 8)

local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, -24, 0, 42)
statusCard.Position = UDim2.new(0, 12, 0, 50)
statusCard.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
statusCard.BorderSizePixel = 0
statusCard.ZIndex = 2
statusCard.Parent = main
corner(statusCard, 10)
stroke(statusCard, Color3.fromRGB(60, 50, 110), 0.55, 1)

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 9, 0, 9)
dot.Position = UDim2.new(0, 12, 0.5, -4.5)
dot.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
dot.BorderSizePixel = 0
dot.ZIndex = 3
dot.Parent = statusCard
corner(dot, 5)

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -40, 0, 14)
statusTitle.Position = UDim2.new(0, 30, 0, 8)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "Protected"
statusTitle.TextColor3 = Color3.fromRGB(60, 255, 120)
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextSize = 11
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.ZIndex = 3
statusTitle.Parent = statusCard

local statusSub = Instance.new("TextLabel")
statusSub.Size = UDim2.new(1, -40, 0, 12)
statusSub.Position = UDim2.new(0, 30, 0, 22)
statusSub.BackgroundTransparency = 1
statusSub.Text = "All systems online"
statusSub.TextColor3 = Color3.fromRGB(130, 130, 150)
statusSub.Font = Enum.Font.Gotham
statusSub.TextSize = 9
statusSub.TextXAlignment = Enum.TextXAlignment.Left
statusSub.ZIndex = 3
statusSub.Parent = statusCard

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -24, 0, 32)
toggle.Position = UDim2.new(0, 12, 0, 98)
toggle.BackgroundColor3 = Color3.fromRGB(22, 80, 42)
toggle.Text = "◉  PROTECTION ENABLED"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 11
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.ZIndex = 3
toggle.Parent = main
corner(toggle, 9)
local toggleStroke = stroke(toggle, Color3.fromRGB(60, 200, 110), 0.5, 1.5)

local logHdr = Instance.new("TextLabel")
logHdr.Size = UDim2.new(1, -24, 0, 12)
logHdr.Position = UDim2.new(0, 14, 0, 138)
logHdr.BackgroundTransparency = 1
logHdr.Text = "◈  LOGGER FEED"
logHdr.TextColor3 = Color3.fromRGB(255, 110, 110)
logHdr.Font = Enum.Font.GothamBlack
logHdr.TextSize = 9
logHdr.TextXAlignment = Enum.TextXAlignment.Left
logHdr.ZIndex = 3
logHdr.Parent = main

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -24, 1, -182)
logFrame.Position = UDim2.new(0, 12, 0, 152)
logFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 3
logFrame.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 255)
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.ZIndex = 2
logFrame.Parent = main
corner(logFrame, 10)
stroke(logFrame, Color3.fromRGB(45, 40, 75), 0.55, 1)
local LL = Instance.new("UIListLayout")
LL.Padding = UDim.new(0, 4); LL.SortOrder = Enum.SortOrder.LayoutOrder
LL.Parent = logFrame
padding(logFrame, 5, 5, 5, 5)

local emptyLbl = Instance.new("TextLabel")
emptyLbl.Size = UDim2.new(1, 0, 0, 30)
emptyLbl.BackgroundTransparency = 1
emptyLbl.Text = "◌  Nothing detected\nWaiting for loggers…"
emptyLbl.TextColor3 = Color3.fromRGB(90, 90, 110)
emptyLbl.Font = Enum.Font.Gotham
emptyLbl.TextSize = 10
emptyLbl.TextWrapped = true
emptyLbl.Parent = logFrame

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -24, 0, 14)
stats.Position = UDim2.new(0, 14, 1, -18)
stats.BackgroundTransparency = 1
stats.Text = "Blocked: 0   •   Kicked: 0"
stats.TextColor3 = Color3.fromRGB(160, 150, 190)
stats.Font = Enum.Font.GothamMedium
stats.TextSize = 9
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.ZIndex = 3
stats.Parent = main

local reopener = Instance.new("TextButton")
reopener.Size = UDim2.new(0, 42, 0, 42)
reopener.Position = UDim2.new(0, 20, 0.5, -21)
reopener.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
reopener.Text = "🛡"
reopener.TextColor3 = Color3.fromRGB(255, 255, 255)
reopener.Font = Enum.Font.GothamBlack
reopener.TextSize = 18
reopener.BorderSizePixel = 0
reopener.AutoButtonColor = false
reopener.Visible = false
reopener.Parent = sg
corner(reopener, 21)
stroke(reopener, Color3.fromRGB(140, 100, 255), 0.25, 2)
ENV.GOJO_AL_REOPENER = reopener

-- Drag
local function draggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local t = input.Target
            if t and t:IsA("TextButton") and t ~= frame then return end
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end
draggable(main)
draggable(reopener)

-- ══════════════════ LOGGING ══════════════════
local order = 0
local logRows = {}
local function refreshStats()
    stats.Text = string.format("Blocked: %d   •   Kicked: %d", state.blocked, state.kicked)
end

local function addLog(titleText, sourceText, kind)
    emptyLbl.Visible = false
    order = order + 1
    local bg, tc = Color3.fromRGB(18, 18, 26), Color3.fromRGB(255, 170, 90)
    if kind == "kick" then bg = Color3.fromRGB(45, 10, 15); tc = Color3.fromRGB(255, 90, 90)
    elseif kind == "block" then bg = Color3.fromRGB(30, 20, 10)
    elseif kind == "brand" then bg = Color3.fromRGB(28, 14, 50); tc = Color3.fromRGB(180, 140, 255) end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = bg
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = logFrame
    corner(row, 6)
    padding(row, 5, 7, 5, 7)

    local head = Instance.new("TextLabel")
    head.Size = UDim2.new(1, 0, 0, 12)
    head.BackgroundTransparency = 1
    head.Text = (kind == "kick" and "💀 " or kind == "brand" and "✦ " or kind == "block" and "⛔ " or "⚠ ") .. titleText
    head.TextColor3 = tc
    head.Font = Enum.Font.GothamBold
    head.TextSize = 10
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.TextTruncate = Enum.TextTruncate.AtEnd
    head.Parent = row

    local src = Instance.new("TextLabel")
    src.Position = UDim2.new(0, 0, 0, 12)
    src.Size = UDim2.new(1, 0, 0, 0)
    src.AutomaticSize = Enum.AutomaticSize.Y
    src.BackgroundTransparency = 1
    src.Text = sourceText
    src.TextColor3 = Color3.fromRGB(180, 180, 195)
    src.Font = Enum.Font.Gotham
    src.TextSize = 9
    src.TextWrapped = true
    src.TextXAlignment = Enum.TextXAlignment.Left
    src.Parent = row

    table.insert(logRows, row)
    if #logRows > LOG_CAP then
        local old = table.remove(logRows, 1)
        pcall(function() old:Destroy() end)
    end

    logFrame.CanvasPosition = Vector2.new(0, math.max(0, logFrame.AbsoluteCanvasSize.Y - logFrame.AbsoluteWindowSize.Y))
end

local function identifyCaller()
    if CAP.getcallingscr then
        local okc, s = pcall(getcallingscript)
        if okc and s then
            local ok2, n = pcall(function() return s:GetFullName() end)
            if ok2 and n then return n end
        end
    end
    if CAP.debug_info then
        local dbg = debug.info or debug.getinfo
        local ok2, a = pcall(function() return dbg(4, "snl") end)
        if ok2 and a then return tostring(a) end
    end
    return "Unknown (obfuscated / protected)"
end

-- ══════════════════ REMOTE MATCH ══════════════════
local function matchesWatched(inst)
    if not inst or not inst.Name then return nil end
    if WATCHED_NAMES[inst.Name] then
        if inst.Name:find("/") then return inst.Name end
        local p = inst.Parent
        if p and (p.Name == "Net" or p.Name == "Packages" or p.Name:find("Trade")) then
            local full = inst:GetFullName():gsub("^ReplicatedStorage%.", "")
            if WATCHED_NAMES[full] then return full end
        end
    end
    for _, w in ipairs(WATCHED) do
        local parts = {}
        for p in w.full:gmatch("[^%.]+") do table.insert(parts, p) end
        local cur, okm = inst, true
        for i = #parts, 1, -1 do
            if not cur or cur.Name ~= parts[i] then okm = false; break end
            cur = cur.Parent
        end
        if okm then return w.full end
    end
    return nil
end

local function destroySilent(inst, path)
    if not inst or not inst.Parent then return end
    state.blocked = state.blocked + 1
    refreshStats()
    local brand = pick(BRAND.load_block)
    addLog(brand:gsub("^🛡️ ", ""), "remote: " .. path .. " (pre-blocked)", "brand")
    showToast(brand, "pre-blocked · " .. path:sub(-30), Color3.fromRGB(140, 100, 255), 3)
    pcall(function() inst:Destroy() end)
end

local function handleRemake(inst, path)
    if not inst or not inst.Parent then return end
    local src = identifyCaller()
    state.blocked = state.blocked + 1
    state.kicked = state.kicked + 1
    refreshStats()
    addLog(path .. "  →  REMAKE", "script: " .. src, "kick")
    showToast("💀 LOGGER DETECTED", "Remake → kicking · " .. src:sub(1, 38), Color3.fromRGB(255, 60, 60), 4)
    pcall(function() inst:Destroy() end)
    task.spawn(function()
        ENV.GOJO_AL_ALLOW_KICK = true
        task.wait(0.15)
        pcall(function() LP:Kick(pick(KICK_MESSAGES)) end)
    end)
end

-- Targeted scan (mobile-friendly)
local function scanExisting()
    if not state.enabled then return end
    -- Try targeted path first
    local target = RS:FindFirstChild("Packages")
    if target then
        local net = target:FindFirstChild("Net")
        if net then
            -- Check immediate descendants (not full tree)
            for _, c in ipairs(net:GetChildren()) do
                local m = matchesWatched(c)
                if m then destroySilent(c, m); continue end
                for _, d in ipairs(c:GetChildren()) do
                    local mm = matchesWatched(d)
                    if mm then destroySilent(d, mm) end
                end
            end
        end
    else
        -- Fallback: shallow scan of RS top-level
        for _, c in ipairs(RS:GetChildren()) do
            local m = matchesWatched(c)
            if m then destroySilent(c, m); continue end
            for _, d in ipairs(c:GetChildren()) do
                local mm = matchesWatched(d)
                if mm then destroySilent(d, mm) end
            end
        end
    end
end

table.insert(ENV.GOJO_AL_CONNS, RS.DescendantAdded:Connect(function(inst)
    if not state.enabled then return end
    local m = matchesWatched(inst)
    if m then handleRemake(inst, m); return end
    task.defer(function()
        if not inst.Parent then return end
        for _, d in ipairs(inst:GetChildren()) do
            local mm = matchesWatched(d)
            if mm then handleRemake(d, mm) end
        end
    end)
end))

-- ══════════════════ ANTI IP-LOG ══════════════════
local BAD_URL_PARTS = {
    "discord%.com/api/webhooks","discordapp%.com/api/webhooks",
    "discord%.com/api/v%d+/webhooks",
    "iplogger","grabify","webhook%.site","ipify","2no%.co","blasze",
    "yip%.su","ps3cfw","iplogger%.org","iplogger%.com","whatismyip",
    "ip%-api%.com","geoip","leakcheck","haveibeenpwned","ipinfo%.io",
    "ipwho%.is","api%.ipify%.org","ipgeolocation","ipstack","db%-ip%.com",
    "crashbot","robloxcrash","servercrasher","gamecrasher",
    "freecrash","crashapi","botcrash","crashguard","grabify%.link",
    "iplogger%.ru","iplogger%.info","tracker%.gg","shorturl","bit%.ly",
    "tinyurl%.com","cutt%.ly","rbxcrash","rbxlog",
}
local BAD_BODY_PARTS = {
    "webhook","%.com/api/webhooks","iplogger","grabify","crashbot",
    "robloxcrash","servercrasher","gamecrasher","freecrash","botcrash",
    "cookie","%.ROBLOSECURITY","rbx%-cookie","hitbot",
}
local function scanStr(s, list)
    if type(s) ~= "string" then return false end
    local l = s:lower()
    for _, p in ipairs(list) do if l:find(p) then return true end end
    return false
end
local isBadUrl  = function(u) return scanStr(u, BAD_URL_PARTS) end
local isBadBody = function(b) return scanStr(b, BAD_BODY_PARTS) end

local function patchHttp(name)
    local old = ENV[name] or _G[name]
    if type(old) ~= "function" then return end
    local new = function(opts)
        if not state.enabled then return old(opts) end
        local url, body = "", ""
        if type(opts) == "string" then url = opts
        elseif type(opts) == "table" then
            url  = tostring(opts.Url or opts.url or "")
            body = tostring(opts.Body or opts.body or opts.Data or opts.data or "")
        end
        if isBadUrl(url) or isBadBody(body) then
            warn("[Gojo V5] Blocked suspicious request: " .. url:sub(1,80))
            addLog("HTTP → " .. url:sub(1, 42), "script: " .. identifyCaller(), "block")
            state.blocked = state.blocked + 1; refreshStats()
            showToast(pick(BRAND.webhook_block), url:sub(1, 42), Color3.fromRGB(255, 140, 40), 3)
            return { StatusCode = 200, Body = "{}", Headers = {} }
        end
        return old(opts)
    end
    ENV[name] = new; _G[name] = new
end
for _, n in ipairs({"request","http_request","httpRequest","syn_request","http_request_async","httpget","HttpGet","HttpGetAsync","http_get"}) do
    pcall(patchHttp, n)
end
if CAP.hookfunction and game.HttpGet then
    pcall(function()
        local old = game.HttpGet
        hookfunction(old, function(self, url, ...)
            if state.enabled and isBadUrl(url) then
                addLog("HttpGet → " .. tostring(url):sub(1,42), "script: " .. identifyCaller(), "block")
                state.blocked = state.blocked + 1; refreshStats()
                showToast(pick(BRAND.webhook_block), tostring(url):sub(1,42), Color3.fromRGB(255, 140, 40), 3)
                return ""
            end
            return old(self, url, ...)
        end)
    end)
end
if CAP.hookfunction and game.HttpGetAsync then
    pcall(function()
        local old = game.HttpGetAsync
        hookfunction(old, function(self, url, ...)
            if state.enabled and isBadUrl(url) then
                addLog("HttpGetAsync → " .. tostring(url):sub(1,42), "script: " .. identifyCaller(), "block")
                state.blocked = state.blocked + 1; refreshStats()
                showToast(pick(BRAND.webhook_block), tostring(url):sub(1,42), Color3.fromRGB(255, 140, 40), 3)
                return ""
            end
            return old(self, url, ...)
        end)
    end)
end

-- ══════════════════ ANTI-CRASH (LIGHTWEIGHT, NO HOT HOOKS) ══════════════════
-- No Instance.new hook, no Sound.Play hook. Just FPS monitoring + periodic cleanup.
local CRASH = {
    enabled         = true,
    fpsBaseline     = 60,
    fpsCurrent      = 60,
    sampleSum       = 0,
    sampleCount     = 0,
    lastFrame       = os.clock(),
    framesSinceSample = 0,
    lastEmergency   = 0,
    emergencyCooldown = 6,
    lowFpsStreak    = 0,
}
local BASELINE_LOCKED = false
local FPS_SAMPLE_INTERVAL = IS_MOBILE and 0.5 or 0.33  -- seconds

local function emergencyCleanup()
    local now = os.clock()
    if now - CRASH.lastEmergency < CRASH.emergencyCooldown then return end
    CRASH.lastEmergency = now

    local cleared = 0
    -- Stop excess sounds
    pcall(function()
        local SoundSvc = game:GetService("SoundService")
        for _, s in ipairs(SoundSvc:GetChildren()) do
            if s:IsA("Sound") and s.IsPlaying then
                pcall(function() s:Stop() end)
                cleared = cleared + 1
                if cleared >= 100 then break end
            end
        end
    end)

    -- Disable high-rate particles (top-level workspace children only, capped)
    local disabled = 0
    pcall(function()
        for _, p in ipairs(workspace:GetChildren()) do
            if p:IsA("ParticleEmitter") and p.Enabled and p.Rate > 500 then
                p.Enabled = false
                disabled = disabled + 1
                local ref = p
                task.delay(2, function() pcall(function() ref.Enabled = true end) end)
                if disabled >= 80 then break end
            end
        end
    end)

    if cleared + disabled > 0 then
        addLog("Emergency FPS recovery", ("stopped %d sounds, %d particles"):format(cleared, disabled), "block")
        showToast(pick(BRAND.fps_recover), ("cleared %d sources"):format(cleared + disabled), Color3.fromRGB(60, 200, 255), 3)
    end
end

-- Use a timer loop instead of Heartbeat connect (mobile-safe)
task.spawn(function()
    while sg.Parent do
        task.wait(FPS_SAMPLE_INTERVAL)
        if not state.enabled or not CRASH.enabled then continue end

        local now = os.clock()
        local dt = now - CRASH.lastFrame
        CRASH.lastFrame = now

        if dt > 0.001 and dt < 2 then
            local fps = 1 / dt
            CRASH.sampleSum = CRASH.sampleSum + fps
            CRASH.sampleCount = CRASH.sampleCount + 1

            if CRASH.sampleCount >= 5 then
                CRASH.fpsCurrent = CRASH.sampleSum / CRASH.sampleCount
                CRASH.sampleSum = 0
                CRASH.sampleCount = 0

                if not BASELINE_LOCKED and CRASH.fpsCurrent > 15 then
                    CRASH.fpsBaseline = CRASH.fpsCurrent
                    BASELINE_LOCKED = true
                end

                -- Emergency if sustained drop below 55% of baseline
                if BASELINE_LOCKED and CRASH.fpsBaseline > 20
                and CRASH.fpsCurrent < CRASH.fpsBaseline * 0.55 then
                    CRASH.lowFpsStreak = CRASH.lowFpsStreak + 1
                    if CRASH.lowFpsStreak >= 3 then
                        emergencyCleanup()
                        CRASH.lowFpsStreak = 0
                    end
                else
                    CRASH.lowFpsStreak = 0
                end
            end
        end
    end
end)

-- ══════════════════ ANTI FORCE-KICK ══════════════════
local function logKickBlock(vector)
    state.blocked = state.blocked + 1; refreshStats()
    local src = identifyCaller()
    addLog("Blocked " .. vector, "script: " .. src, "block")
    showToast(pick(BRAND.kick_block), vector .. " · " .. src:sub(1, 34), Color3.fromRGB(120, 90, 255), 3)
end

if CAP.hookfunction then
    pcall(function()
        local old = LP.Kick
        hookfunction(old, function(self, ...)
            if state.enabled and not ENV.GOJO_AL_ALLOW_KICK then
                logKickBlock("Player:Kick"); return
            end
            return old(self, ...)
        end)
    end)
    pcall(function()
        local old = Players.Kick
        hookfunction(old, function(self, ...)
            if state.enabled and not ENV.GOJO_AL_ALLOW_KICK then
                logKickBlock("Players:Kick"); return
            end
            return old(self, ...)
        end)
    end)
    pcall(function()
        if game.Shutdown then
            local old = game.Shutdown
            hookfunction(old, function(self, ...)
                if state.enabled then logKickBlock("game:Shutdown"); return end
                return old(self, ...)
            end)
        end
    end)
    pcall(function()
        local TS = game:GetService("TeleportService")
        if TS.Teleport then
            local old = TS.Teleport
            hookfunction(old, function(self, ...)
                if state.enabled and not ENV.GOJO_AL_ALLOW_KICK then
                    logKickBlock("TeleportService:Teleport"); return
                end
                return old(self, ...)
            end)
        end
    end)
end

pcall(function()
    local prompt = CoreGui:FindFirstChild("RobloxPromptGui")
    if prompt then
        table.insert(ENV.GOJO_AL_CONNS, prompt.DescendantAdded:Connect(function(d)
            if not state.enabled then return end
            if d:IsA("TextLabel") and (d.Text:lower():find("disconnect")
            or d.Text:lower():find("kick") or d.Text:lower():find("error")) then
                logKickBlock("Error prompt")
                pcall(function() prompt:Destroy() end)
            end
        end))
    end
end)

if CAP.getrawmetatable and CAP.setreadonly and CAP.getnamecall then
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        local old = mt.__namecall
        setreadonly(mt, false)
        local wrap = CAP.newcclosure and newcclosure or function(f) return f end
        mt.__namecall = wrap(function(self, ...)
            local method = getnamecallmethod()
            if state.enabled and not ENV.GOJO_AL_ALLOW_KICK
            and (method == "Kick" or method == "Disconnect" or method == "Shutdown"
                 or method == "Teleport" or method == "TeleportToPlaceInstance") then
                if self ~= LP and self ~= Players or method ~= "Kick" then
                    logKickBlock(method .. "()")
                    return nil
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

pcall(function()
    game:BindToClose(function()
        if state.enabled then task.wait(0.05) end
    end)
end)

-- ══════════════════ TOGGLE ══════════════════
local function setScanning(on, label)
    state.scanning = on
    if on then
        statusTitle.Text = "Scanning…"
        statusTitle.TextColor3 = Color3.fromRGB(255, 200, 90)
        statusSub.Text = label or "Checking remotes…"
        dot.BackgroundColor3 = Color3.fromRGB(255, 200, 90)
    else
        statusTitle.Text = state.enabled and "Protected" or "Unprotected"
        statusTitle.TextColor3 = state.enabled and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 90, 90)
        statusSub.Text = state.enabled and "All systems online" or "Protection disabled"
        dot.BackgroundColor3 = state.enabled and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 90, 90)
    end
end

toggle.MouseButton1Click:Connect(function()
    state.enabled = not state.enabled
    if state.enabled then
        toggle.Text = "◉  PROTECTION ENABLED"
        toggle.BackgroundColor3 = Color3.fromRGB(22, 80, 42)
        toggleStroke.Color = Color3.fromRGB(60, 200, 110)
        setScanning(true, "Checking remotes…")
        showToast("🛡️ PROTECTION ON", "Six Eyes activated", Color3.fromRGB(60, 200, 110), 2)
        task.spawn(function()
            task.wait(0.3); scanExisting()
            setScanning(true, "Checking scripts…")
            task.wait(0.3); setScanning(false)
        end)
    else
        toggle.Text = "◯  PROTECTION DISABLED"
        toggle.BackgroundColor3 = Color3.fromRGB(90, 22, 28)
        toggleStroke.Color = Color3.fromRGB(200, 60, 70)
        setScanning(false)
        showToast("⚠️ PROTECTION OFF", "You are no longer protected", Color3.fromRGB(255, 90, 90), 3)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false; reopener.Visible = true
end)
reopener.MouseButton1Click:Connect(function()
    main.Visible = true; reopener.Visible = false
end)

-- ══════════════════ INITIAL SCAN ══════════════════
task.spawn(function()
    setScanning(true, "Initialising…")
    task.wait(0.3)
    for i = 1, 3 do
        scanExisting()
        setScanning(true, ("Scanning… (%d/3)"):format(i))
        task.wait(0.35)
    end
    setScanning(false)
    showToast("🛡️ GOJO V5 READY", "made by gojo discord @oghone", Color3.fromRGB(140, 100, 255), 3)
    print("[Gojo Anti-Logger V5] Ready. made by gojo discord @oghone")
end)
