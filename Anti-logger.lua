--[[
    ╔══════════════════════════════════════════════════════════╗
    ║           GOJO ANTI-LOGGER  •  V4  "SIX EYES"            ║
    ║           made by gojo discord @oghone                   ║
    ║                                                          ║
    ║  • Anti IP-log (URL + body scan, 9 HTTP functions)       ║
    ║  • Anti FPS crash (real-time frame-time monitor)         ║
    ║  • Anti Roblox crash (Instance.new / Sound / VFX flood)  ║
    ║  • Anti force-kick (7-vector)                            ║
    ║  • TradeService remote killer + remake kick              ║
    ║  • Branded "OWNED BY GOJO" toasts                        ║
    ║  • Optimized: capped logs, throttled sampling            ║
    ╚══════════════════════════════════════════════════════════╝
]]

-- ══════════════════ CLEANUP ══════════════════
do
    local g = (getgenv and getgenv()) or _G
    for _, key in ipairs({"GOJO_AL_GUI","GOJO_AL_REOPENER","GOJO_AL_HOOKS","GOJO_AL_CONNS"}) do
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

-- ══════════════════ EXECUTOR CAPABILITIES ══════════════════
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
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local UIS     = game:GetService("UserInputService")
local Tween   = game:GetService("TweenService")
local Run     = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundSvc= game:GetService("SoundService")

local LP      = Players.LocalPlayer
local PG      = LP:WaitForChild("PlayerGui")

-- ══════════════════ BRANDED MESSAGES ══════════════════
local function pick(t) return t[math.random(1, #t)] end
local BRAND = {
    load_block = {
        "🛡️ OWNED BY GOJO — logger pre-blocked",
        "🛡️ Six Eyes saw it. It's gone.",
        "🛡️ Gojo ate your logger for breakfast.",
        "🛡️ Infinity blocked it. Try again, skid.",
        "🛡️ Not on my watch. Logger deleted.",
        "🛡️ Logger? More like logged-by-Gojo.",
        "🛡️ Deleted before you could blink.",
    },
    webhook_block = {
        "🛡️ Webhook owned by Gojo",
        "🛡️ Nice try — your webhook is gone",
        "🛡️ IP-logger? Not today.",
        "🛡️ Discord webhook → deleted by Infinity",
    },
    kick_block = {
        "🛡️ Kick blocked by Infinity",
        "🛡️ Nah. Gojo blocked your kick.",
        "🛡️ You can't kick the strongest.",
        "🛡️ Kick attempt = null and void",
    },
    crash_block = {
        "🛡️ Crash attempt owned by Gojo",
        "🛡️ FPS protected. Six Eyes sees all.",
        "🛡️ Crashing? Not on my server.",
        "🛡️ Crash source vaporized",
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
    "⚡ Anti-Logger V4 says no.",
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

local LOG_CAP = 40
local FPS_SAMPLE_EVERY = 15  -- frames

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
local function gradient(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}
    g.Rotation = rot or 0
    g.Parent = p; return g
end

local sg = Instance.new("ScreenGui")
sg.Name = "GojoAntiLoggerV4"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 2147483647
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okp = pcall(function() sg.Parent = PG end)
if not okp or not sg.Parent then pcall(function() sg.Parent = CoreGui end) end
ENV.GOJO_AL_GUI = sg

-- ─── Toast system ───
local toastHolder = Instance.new("Frame")
toastHolder.Size = UDim2.new(1, 0, 0, 0)
toastHolder.BackgroundTransparency = 1
toastHolder.Parent = sg
local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 6)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastHolder
padding(toastHolder, 10, 0, 0, 0)

local toastOrder = 0
local function showToast(title, subtitle, color, duration)
    color = color or Color3.fromRGB(120, 90, 255)
    duration = duration or 3.5
    toastOrder = toastOrder + 1
    local t = Instance.new("Frame")
    t.Size = UDim2.new(0, 340, 0, 54)
    t.Position = UDim2.new(0.5, -170, 0, -60)
    t.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    t.BorderSizePixel = 0
    t.LayoutOrder = toastOrder
    t.Parent = toastHolder
    corner(t, 12)
    local st = stroke(t, color, 0.3, 1.5)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -12)
    accent.Position = UDim2.new(0, 6, 0, 6)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = t
    corner(accent, 2)

    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 28, 0, 28)
    ic.Position = UDim2.new(0, 16, 0.5, -14)
    ic.BackgroundColor3 = color
    ic.BackgroundTransparency = 0.82
    ic.Text = "🛡"
    ic.TextColor3 = Color3.fromRGB(255,255,255)
    ic.Font = Enum.Font.GothamBlack
    ic.TextSize = 15
    ic.BorderSizePixel = 0
    ic.Parent = t
    corner(ic, 8)

    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, -62, 0, 16)
    tt.Position = UDim2.new(0, 52, 0, 9)
    tt.BackgroundTransparency = 1
    tt.Text = title
    tt.TextColor3 = Color3.fromRGB(240, 240, 250)
    tt.Font = Enum.Font.GothamBold
    tt.TextSize = 11
    tt.TextXAlignment = Enum.TextXAlignment.Left
    tt.TextTruncate = Enum.TextTruncate.AtEnd
    tt.Parent = t

    local ss = Instance.new("TextLabel")
    ss.Size = UDim2.new(1, -62, 0, 14)
    ss.Position = UDim2.new(0, 52, 0, 27)
    ss.BackgroundTransparency = 1
    ss.Text = subtitle
    ss.TextColor3 = Color3.fromRGB(150, 150, 170)
    ss.Font = Enum.Font.Gotham
    ss.TextSize = 9
    ss.TextXAlignment = Enum.TextXAlignment.Left
    ss.TextTruncate = Enum.TextTruncate.AtEnd
    ss.Parent = t

    Tween:Create(t, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -170, 0, 0)}):Play()

    task.delay(duration, function()
        Tween:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -170, 0, -60), BackgroundTransparency = 1}):Play()
        Tween:Create(st, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.35)
        pcall(function() t:Destroy() end)
    end)
end

-- ─── Main Window ───
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 280, 0, 400)
main.Position = UDim2.new(0, 20, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg
corner(main, 16)
stroke(main, Color3.fromRGB(80, 60, 160), 0.35, 1.5)

local bgGrad = Instance.new("Frame")
bgGrad.Size = UDim2.new(1, 0, 1, 0)
bgGrad.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
bgGrad.BackgroundTransparency = 0.82
bgGrad.BorderSizePixel = 0
bgGrad.ZIndex = 0
bgGrad.Parent = main
corner(bgGrad, 16)
gradient(bgGrad, Color3.fromRGB(40, 20, 90), Color3.fromRGB(8, 8, 12), 45)

local accent = Instance.new("Frame")
accent.Size = UDim2.new(1, -28, 0, 3)
accent.Position = UDim2.new(0, 14, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
accent.BorderSizePixel = 0
accent.ZIndex = 2
accent.Parent = main
corner(accent, 2)
gradient(accent, Color3.fromRGB(140, 100, 255), Color3.fromRGB(60, 200, 255), 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 20)
title.Position = UDim2.new(0, 16, 0, 14)
title.BackgroundTransparency = 1
title.Text = "🛡  Anti-Logger V4"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 12)
subtitle.Position = UDim2.new(0, 16, 0, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "made by gojo discord @oghone"
subtitle.TextColor3 = Color3.fromRGB(140, 130, 170)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 3
subtitle.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 12)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 70)
closeBtn.Text = "−"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 4
closeBtn.Parent = main
corner(closeBtn, 8)
stroke(closeBtn, Color3.fromRGB(100, 80, 200), 0.5, 1)

-- Status card
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, -28, 0, 46)
statusCard.Position = UDim2.new(0, 14, 0, 54)
statusCard.BackgroundColor3 = Color3.fromRGB(14, 12, 22)
statusCard.BorderSizePixel = 0
statusCard.ZIndex = 2
statusCard.Parent = main
corner(statusCard, 12)
stroke(statusCard, Color3.fromRGB(60, 50, 110), 0.55, 1)

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 10, 0, 10)
dot.Position = UDim2.new(0, 14, 0.5, -5)
dot.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
dot.BorderSizePixel = 0
dot.ZIndex = 3
dot.Parent = statusCard
corner(dot, 5)

local dotGlow = Instance.new("Frame")
dotGlow.Size = UDim2.new(0, 10, 0, 10)
dotGlow.Position = UDim2.new(0, 14, 0.5, -5)
dotGlow.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
dotGlow.BackgroundTransparency = 0.5
dotGlow.BorderSizePixel = 0
dotGlow.ZIndex = 2
dotGlow.Parent = statusCard
corner(dotGlow, 5)

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -44, 0, 14)
statusTitle.Position = UDim2.new(0, 34, 0, 10)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "Protected"
statusTitle.TextColor3 = Color3.fromRGB(60, 255, 120)
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextSize = 11
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.ZIndex = 3
statusTitle.Parent = statusCard

local statusSub = Instance.new("TextLabel")
statusSub.Size = UDim2.new(1, -44, 0, 12)
statusSub.Position = UDim2.new(0, 34, 0, 24)
statusSub.BackgroundTransparency = 1
statusSub.Text = "All systems online"
statusSub.TextColor3 = Color3.fromRGB(130, 130, 150)
statusSub.Font = Enum.Font.Gotham
statusSub.TextSize = 9
statusSub.TextXAlignment = Enum.TextXAlignment.Left
statusSub.ZIndex = 3
statusSub.Parent = statusCard

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -28, 0, 34)
toggle.Position = UDim2.new(0, 14, 0, 106)
toggle.BackgroundColor3 = Color3.fromRGB(22, 80, 42)
toggle.Text = "◉  PROTECTION ENABLED"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 11
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.ZIndex = 3
toggle.Parent = main
corner(toggle, 10)
local toggleStroke = stroke(toggle, Color3.fromRGB(60, 200, 110), 0.5, 1.5)

local logHdr = Instance.new("TextLabel")
logHdr.Size = UDim2.new(1, -28, 0, 12)
logHdr.Position = UDim2.new(0, 16, 0, 150)
logHdr.BackgroundTransparency = 1
logHdr.Text = "◈  LOGGER FEED"
logHdr.TextColor3 = Color3.fromRGB(255, 110, 110)
logHdr.Font = Enum.Font.GothamBlack
logHdr.TextSize = 9
logHdr.TextXAlignment = Enum.TextXAlignment.Left
logHdr.ZIndex = 3
logHdr.Parent = main

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -28, 1, -202)
logFrame.Position = UDim2.new(0, 14, 0, 166)
logFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 3
logFrame.ScrollBarImageColor3 = Color3.fromRGB(140, 100, 255)
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.ZIndex = 2
logFrame.Parent = main
corner(logFrame, 12)
stroke(logFrame, Color3.fromRGB(45, 40, 75), 0.55, 1)
local LL = Instance.new("UIListLayout")
LL.Padding = UDim.new(0, 5); LL.SortOrder = Enum.SortOrder.LayoutOrder
LL.Parent = logFrame
padding(logFrame, 6, 6, 6, 6)

local emptyLbl = Instance.new("TextLabel")
emptyLbl.Size = UDim2.new(1, 0, 0, 34)
emptyLbl.BackgroundTransparency = 1
emptyLbl.Text = "◌  Nothing detected\nWaiting for loggers…"
emptyLbl.TextColor3 = Color3.fromRGB(90, 90, 110)
emptyLbl.Font = Enum.Font.Gotham
emptyLbl.TextSize = 10
emptyLbl.TextWrapped = true
emptyLbl.Parent = logFrame

local stats = Instance.new("TextLabel")
stats.Size = UDim2.new(1, -28, 0, 14)
stats.Position = UDim2.new(0, 16, 1, -20)
stats.BackgroundTransparency = 1
stats.Text = "Blocked: 0   •   Kicked: 0"
stats.TextColor3 = Color3.fromRGB(160, 150, 190)
stats.Font = Enum.Font.GothamMedium
stats.TextSize = 9
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.ZIndex = 3
stats.Parent = main

-- Reopener
local reopener = Instance.new("TextButton")
reopener.Size = UDim2.new(0, 46, 0, 46)
reopener.Position = UDim2.new(0, 20, 0.5, -23)
reopener.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
reopener.Text = "🛡"
reopener.TextColor3 = Color3.fromRGB(255, 255, 255)
reopener.Font = Enum.Font.GothamBlack
reopener.TextSize = 20
reopener.BorderSizePixel = 0
reopener.AutoButtonColor = false
reopener.Visible = false
reopener.Parent = sg
corner(reopener, 23)
stroke(reopener, Color3.fromRGB(140, 100, 255), 0.25, 2)
ENV.GOJO_AL_REOPENER = reopener

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

task.spawn(function()
    while main.Parent and sg.Parent do
        local info = TweenInfo.new(state.scanning and 0.5 or 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        Tween:Create(dotGlow, info, {BackgroundTransparency = 0.88, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 10, 0.5, -9)}):Play()
        task.wait(state.scanning and 0.5 or 1.2)
        Tween:Create(dotGlow, info, {BackgroundTransparency = 0.4, Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 14, 0.5, -5)}):Play()
        task.wait(state.scanning and 0.5 or 1.2)
    end
end)

-- ══════════════════ LOGGING (optimized, capped) ══════════════════
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
    row.Size = UDim2.new(1, -8, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = bg
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = logFrame
    corner(row, 7)
    padding(row, 6, 8, 6, 8)

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
    -- ⭐ Branded message even without remake
    local brand = pick(BRAND.load_block)
    addLog(brand:gsub("^🛡️ ", ""), "remote: " .. path .. " (pre-blocked)", "brand")
    showToast(brand, "pre-blocked · " .. path:sub(-32), Color3.fromRGB(140, 100, 255), 3)
    pcall(function() inst:Destroy() end)
end

local function handleRemake(inst, path)
    if not inst or not inst.Parent then return end
    local src = identifyCaller()
    state.blocked = state.blocked + 1
    state.kicked = state.kicked + 1
    refreshStats()
    addLog(path .. "  →  REMAKE", "script: " .. src, "kick")
    showToast("💀 LOGGER DETECTED", "Remake → kicking · " .. src:sub(1, 40), Color3.fromRGB(255, 60, 60), 4)
    pcall(function() inst:Destroy() end)
    task.spawn(function()
        ENV.GOJO_AL_ALLOW_KICK = true
        task.wait(0.15)
        pcall(function() LP:Kick(pick(KICK_MESSAGES)) end)
    end)
end

local function scanExisting()
    if not state.enabled then return end
    for _, inst in ipairs(RS:GetDescendants()) do
        local m = matchesWatched(inst)
        if m then destroySilent(inst, m) end
    end
end

table.insert(ENV.GOJO_AL_CONNS, RS.DescendantAdded:Connect(function(inst)
    if not state.enabled then return end
    local m = matchesWatched(inst)
    if m then handleRemake(inst, m); return end
    task.defer(function()
        if not inst.Parent then return end
        for _, d in ipairs(inst:GetDescendants()) do
            local mm = matchesWatched(d)
            if mm then handleRemake(d, mm) end
        end
    end)
end))

-- ══════════════════ ANTI IP-LOG / ANTI DISCORD-BOT ══════════════════
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
            warn("[Gojo V4] Blocked suspicious request: " .. url:sub(1,80))
            addLog("HTTP → " .. url:sub(1, 46), "script: " .. identifyCaller(), "block")
            state.blocked = state.blocked + 1; refreshStats()
            showToast(pick(BRAND.webhook_block), url:sub(1, 46), Color3.fromRGB(255, 140, 40), 3)
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
                addLog("HttpGet → " .. tostring(url):sub(1,46), "script: " .. identifyCaller(), "block")
                state.blocked = state.blocked + 1; refreshStats()
                showToast(pick(BRAND.webhook_block), tostring(url):sub(1,46), Color3.fromRGB(255, 140, 40), 3)
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
                addLog("HttpGetAsync → " .. tostring(url):sub(1,46), "script: " .. identifyCaller(), "block")
                state.blocked = state.blocked + 1; refreshStats()
                showToast(pick(BRAND.webhook_block), tostring(url):sub(1,46), Color3.fromRGB(255, 140, 40), 3)
                return ""
            end
            return old(self, url, ...)
        end)
    end)
end

-- ══════════════════ ANTI-CRASH (FPS + Roblox) ══════════════════
local CRASH = {
    enabled            = true,
    instanceBudget     = 220,     -- Instance.new calls/sec
    heavyBudget        = 60,      -- heavy class instances/sec
    soundBudget        = 25,      -- Sound:Play/sec
    instanceCount      = 0,
    heavyCount         = 0,
    soundCount         = 0,
    lastInstanceReset  = os.clock(),
    lastSoundReset     = os.clock(),
    fpsBaseline        = 60,
    fpsCurrent         = 60,
    fpsSamples         = {},
    sampleCounter      = 0,
    lastFrame          = os.clock(),
    lastEmergency      = 0,
    emergencyCooldown  = 5,
    throttleUntil      = 0,       -- block heavy creation until this time
}

local HEAVY_CLASSES = {
    Sound = true, ParticleEmitter = true, Trail = true, Beam = true,
    Fire = true, Smoke = true, Sparkles = true, Explosion = true,
    PointLight = true, SpotLight = true, SurfaceLight = true,
    MeshPart = true, UnionOperation = true, NegativeOperation = true,
}

-- Hook Instance.new (rate-limit + emergency throttle)
if CAP.hookfunction then
    pcall(function()
        local oldNew = Instance.new
        hookfunction(oldNew, function(cn, par)
            if state.enabled and CRASH.enabled then
                local now = os.clock()
                if now - CRASH.lastInstanceReset >= 1 then
                    CRASH.instanceCount = 0
                    CRASH.heavyCount = 0
                    CRASH.lastInstanceReset = now
                end
                CRASH.instanceCount = CRASH.instanceCount + 1
                local isHeavy = HEAVY_CLASSES[cn] or false
                if isHeavy then CRASH.heavyCount = CRASH.heavyCount + 1 end

                -- Emergency throttle
                if now < CRASH.throttleUntil and isHeavy then
                    state.blocked = state.blocked + 1
                    return nil
                end
                -- Over budget on heavy?
                if isHeavy and CRASH.heavyCount > CRASH.heavyBudget then
                    state.blocked = state.blocked + 1
                    if CRASH.heavyCount == CRASH.heavyBudget + 1 then
                        addLog("VFX flood → " .. cn, "script: " .. identifyCaller(), "block")
                        showToast(pick(BRAND.crash_block), "Blocked flood: " .. cn, Color3.fromRGB(255, 90, 90), 3)
                    end
                    return nil
                end
            end
            return oldNew(cn, par)
        end)
    end)
end

-- Hook Sound:Play
if CAP.hookfunction then
    pcall(function()
        local Sound = Instance.new("Sound")  -- get class
        if Sound and Sound.Play then
            local oldPlay = Sound.Play
            hookfunction(oldPlay, function(self, ...)
                if state.enabled and CRASH.enabled then
                    local now = os.clock()
                    if now - CRASH.lastSoundReset >= 1 then
                        CRASH.soundCount = 0
                        CRASH.lastSoundReset = now
                    end
                    CRASH.soundCount = CRASH.soundCount + 1
                    if CRASH.soundCount > CRASH.soundBudget then
                        state.blocked = state.blocked + 1
                        if CRASH.soundCount == CRASH.soundBudget + 1 then
                            addLog("Sound flood blocked", "script: " .. identifyCaller(), "block")
                            showToast(pick(BRAND.crash_block), "Sound spam", Color3.fromRGB(255, 90, 90), 3)
                        end
                        return
                    end
                end
                return oldPlay(self, ...)
            end)
        end
        pcall(function() Sound:Destroy() end)
    end)
end

-- FPS monitor + auto-recovery
local function emergencyCleanup()
    if os.clock() - CRASH.lastEmergency < CRASH.emergencyCooldown then return end
    CRASH.lastEmergency = os.clock()
    CRASH.throttleUntil = os.clock() + 3  -- block heavy creation for 3s

    -- Clear excess sounds
    local cleared = 0
    for _, s in ipairs(SoundSvc:GetDescendants()) do
        if s:IsA("Sound") and s.IsPlaying then
            pcall(function() s:Stop() end)
            cleared = cleared + 1
            if cleared >= 200 then break end
        end
    end

    -- Disable excessive particles created recently
    local disabled = 0
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ParticleEmitter") and p.Enabled and p.Rate > 200 then
            pcall(function() p.Enabled = false end)
            disabled = disabled + 1
            if disabled >= 150 then break end
            local ref = p
            task.delay(2, function() pcall(function() ref.Enabled = true end) end)
        end
    end

    addLog("Emergency FPS recovery", ("stopped %d sounds, disabled %d particles"):format(cleared, disabled), "block")
    showToast(pick(BRAND.fps_recover), ("cleared %d crash sources"):format(cleared + disabled), Color3.fromRGB(60, 200, 255), 3)
end

table.insert(ENV.GOJO_AL_CONNS, Run.Heartbeat:Connect(function()
    if not state.enabled or not CRASH.enabled then return end
    local now = os.clock()
    local dt = now - CRASH.lastFrame
    CRASH.lastFrame = now

    CRASH.sampleCounter = CRASH.sampleCounter + 1
    if CRASH.sampleCounter < FPS_SAMPLE_EVERY then return end
    CRASH.sampleCounter = 0

    if dt > 0 and dt < 1 then
        local fps = 1 / dt
        table.insert(CRASH.fpsSamples, fps)
        if #CRASH.fpsSamples > 20 then table.remove(CRASH.fpsSamples, 1) end

        local sum = 0
        for _, v in ipairs(CRASH.fpsSamples) do sum = sum + v end
        CRASH.fpsCurrent = sum / #CRASH.fpsSamples

        -- Set baseline once we have enough samples
        if #CRASH.fpsSamples == 20 and CRASH.fpsBaseline == 60 then
            CRASH.fpsBaseline = CRASH.fpsCurrent
        end

        -- Emergency if FPS < 60% of baseline
        if CRASH.fpsBaseline > 20 and CRASH.fpsCurrent < CRASH.fpsBaseline * 0.6 then
            emergencyCleanup()
        end
    end
end))

-- ══════════════════ ANTI FORCE-KICK (7-vector) ══════════════════
local function logKickBlock(vector)
    state.blocked = state.blocked + 1; refreshStats()
    local src = identifyCaller()
    addLog("Blocked " .. vector, "script: " .. src, "block")
    showToast(pick(BRAND.kick_block), vector .. " · " .. src:sub(1, 36), Color3.fromRGB(120, 90, 255), 3)
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
        dotGlow.BackgroundColor3 = Color3.fromRGB(255, 200, 90)
    else
        statusTitle.Text = state.enabled and "Protected" or "Unprotected"
        statusTitle.TextColor3 = state.enabled and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 90, 90)
        statusSub.Text = state.enabled and "All systems online" or "Protection disabled"
        dot.BackgroundColor3 = state.enabled and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 90, 90)
        dotGlow.BackgroundColor3 = state.enabled and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 90, 90)
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
            task.wait(0.35); scanExisting()
            setScanning(true, "Checking scripts…")
            task.wait(0.35); setScanning(false)
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
    task.wait(0.25)
    for i = 1, 5 do
        scanExisting()
        setScanning(true, ("Scanning… (%d/5)"):format(i))
        task.wait(0.3)
    end
    setScanning(false)
    showToast("🛡️ GOJO V4 READY", "made by gojo discord @oghone", Color3.fromRGB(140, 100, 255), 3)
    print("[Gojo Anti-Logger V4] Ready. made by gojo discord @oghone")
end)
