-- 7UP HUB - can interface edition

local Players            = game:GetService("Players")
local HttpService        = game:GetService("HttpService")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Stats              = game:GetService("Stats")
local CoreGui            = game:GetService("CoreGui")
local SoundService       = game:GetService("SoundService")
local InsertService      = game:GetService("InsertService")

-- ── Lua version compatibility polyfills ──────────────────────
if not math.clamp then
    math.clamp = function(v, lo, hi)
        if v < lo then return lo elseif v > hi then return hi end
        return v
    end
end
if not math.round then
    math.round = function(v) return math.floor(v + 0.5) end
end
if not typeof then
    typeof = function(v) return type(v) end
end

-- ── Volt / executor compatibility shim ───────────────────────
do
    local genv = getgenv and getgenv()
    local function adopt(name, fallback)
        if _G[name] ~= nil then return end
        local v = rawget(_G, name)
        if v == nil and genv then v = rawget(genv, name) end
        if v == nil and fallback then v = fallback end
        if v ~= nil then _G[name] = v end
    end
    adopt("request")
    adopt("http_request")
    adopt("fireproximityprompt")
    adopt("getconnections")
    adopt("getcustomasset")
    adopt("writefile")
    adopt("readfile")
    adopt("isfile")
    adopt("delfile")
    adopt("setclipboard")
    adopt("getclipboard")
    adopt("getrawmetatable")
    adopt("setreadonly")
    adopt("newcclosure")
    adopt("Drawing")
    if identifyexecutor then
        local ok, id = pcall(identifyexecutor)
        if ok then
            local n = type(id) == "table" and (id.Name or id[1]) or tostring(id or "")
            if tostring(n):lower():find("volt") then
                print("[7UP duels] Volt detected")
            end
        end
    end
end

local request = http_request or (getgenv and (getgenv().request or getgenv().http_request)) or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or request
if not request then
    warn("[7UP duels] No HTTP request function — song download may fail, rest of script still runs")
end

local LP = Players.LocalPlayer
if not LP then LP = Players.PlayerAdded:Wait() end

-- Allow re-execute: tear down old GUI if present
pcall(function()
    if _G._K7StopTracerESP then _G._K7StopTracerESP(false) end
end)
pcall(function()
    local pg = game:GetService("Players").LocalPlayer
    pg = pg and pg:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("SevenUpDuelsV2")
        if old then old:Destroy() end
        local oldIntro = pg:FindFirstChild("K7Intro")
        if oldIntro then oldIntro:Destroy() end
        local oldTracer = pg:FindFirstChild("SevenUpTracerReliable")
        if oldTracer then oldTracer:Destroy() end
    end
end)
pcall(function()
    if _G.AceStopAntiDesyncAimbot then _G.AceStopAntiDesyncAimbot() end
    if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end
end)
_G.SevenUpDuelsV2_Running = true
_G.SevenUpDuelsV2_MainExecuted = false
_G._K7AntiDesyncKeyBound = false

local UIS = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer or Players:WaitForChild("LocalPlayer")

local _isfile = isfile or (syn and syn.isfile) or (getgenv and getgenv().isfile) or function() return false end
local _readfile = readfile or (syn and syn.readfile) or (getgenv and getgenv().readfile) or function() return nil end
local _writefile = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile) or function() end
local _delfile = delfile or (syn and syn.delfile) or (getgenv and getgenv().delfile) or function() end
local _setclipboard = setclipboard or toclipboard or (syn and syn.write_clipboard) or (getgenv and (getgenv().setclipboard or getgenv().toclipboard))
local _getclipboard = getclipboard or (syn and syn.read_clipboard) or (getgenv and getgenv().getclipboard)
local getconnections = getconnections or (getgenv and getgenv().getconnections) or get_signal_cons or getconnects or (syn and syn.get_signal_cons)

local activeSpeedValue = 60

local _request = request or http_request or (getgenv and (getgenv().request or getgenv().http_request)) or (syn and syn.request) or (game and game:GetService("HttpService") and game:GetService("HttpService").RequestAsync) or nil

if not fireproximityprompt then
    fireproximityprompt = (getgenv and getgenv().fireproximityprompt)
        or (genv and genv().fireproximityprompt)
        or function(prompt)
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end)
        end
end

repeat task.wait() until game:IsLoaded()

-- ============================================================
-- COLOR SCHEMES (green theme)
-- ============================================================
local COLOR_SCHEMES = {
    ["rbxassetid://102557909116203"] = {  -- 7UP GREEN (default)
        main = Color3.fromRGB(0, 204, 102),
        mainLight = Color3.fromRGB(80, 255, 160),
        mainDark = Color3.fromRGB(0, 150, 75),
        accent = Color3.fromRGB(0, 204, 102),
        text = Color3.fromRGB(255, 255, 255),
        subText = Color3.fromRGB(120, 255, 190),
        border = Color3.fromRGB(0, 204, 102),
        buttonBg = Color3.fromRGB(0, 204, 102),
        buttonText = Color3.fromRGB(255, 255, 255),
        speedText = Color3.fromRGB(0, 204, 102),
        discordText = Color3.fromRGB(0, 204, 102),
        tabActive = Color3.fromRGB(80, 255, 160),
        tabIdle = Color3.fromRGB(0, 204, 102),
        progressBg = Color3.fromRGB(8, 30, 20),
        toggleOn = Color3.fromRGB(0, 204, 102),
        toggleOff = Color3.fromRGB(10, 40, 25),
        inputBg = Color3.fromRGB(6, 20, 14),
        inputBorder = Color3.fromRGB(30, 100, 65),
        inputText = Color3.fromRGB(120, 255, 190),
        rowBg = Color3.fromRGB(10, 25, 18),
        rowHover = Color3.fromRGB(18, 40, 28),
        sectionHeader = Color3.fromRGB(0, 204, 102),
        closeBtn = Color3.fromRGB(30, 120, 70),
        closeBtnHover = Color3.fromRGB(0, 204, 102),
        titleText = Color3.fromRGB(120, 255, 190),
        subtitleText = Color3.fromRGB(0, 204, 102),
        stackBg = Color3.fromRGB(8, 22, 15),
        stackActive = Color3.fromRGB(0, 150, 75),
        stackText = Color3.fromRGB(200, 255, 225),
        stackActiveText = Color3.fromRGB(255, 255, 255),
        stackBorder = Color3.fromRGB(0, 150, 75),
        stackActiveBorder = Color3.fromRGB(0, 204, 102),
        dot = Color3.fromRGB(25, 90, 55),
        dotOn = Color3.fromRGB(0, 204, 102),
        pillOff = Color3.fromRGB(10, 40, 25),
        pillOn = Color3.fromRGB(0, 204, 102),
        modeBtnBg = Color3.fromRGB(6, 20, 14),
        modeBtnActBg = Color3.fromRGB(0, 204, 102),
        modeBtnTxt = Color3.fromRGB(0, 204, 102),
        modeBtnActTx = Color3.fromRGB(10, 30, 18),
        chipBorder = Color3.fromRGB(30, 100, 65),
        chipTxt = Color3.fromRGB(0, 204, 102),
        btnBg = Color3.fromRGB(8, 22, 15),
        btnTxt = Color3.fromRGB(200, 255, 225),
        btnHov = Color3.fromRGB(18, 40, 28),
        infoTxt = Color3.fromRGB(0, 204, 102),
        infoVal = Color3.fromRGB(120, 255, 190),
        infoFill = Color3.fromRGB(0, 204, 102),
        divider = Color3.fromRGB(25, 90, 55),
        winBorder = Color3.fromRGB(0, 204, 102),
        topBg = Color3.fromRGB(4, 14, 9),
        topBtn = Color3.fromRGB(30, 120, 70),
        tabBarBg = Color3.fromRGB(0, 0, 0),
        tabIdleHov = Color3.fromRGB(120, 255, 190),
        tabActiveBg = Color3.fromRGB(8, 30, 18),
        tabUnderline = Color3.fromRGB(0, 204, 102),
        rowBorder = Color3.fromRGB(25, 90, 55),
        rowLabel = Color3.fromRGB(200, 255, 225),
        rowSub = Color3.fromRGB(120, 220, 175),
        rowValue = Color3.fromRGB(120, 255, 190),
        inputFocus = Color3.fromRGB(0, 204, 102),
        dotOff = Color3.fromRGB(25, 90, 55),
        pillBorder = Color3.fromRGB(30, 100, 65),
        modeBtnBrd = Color3.fromRGB(30, 100, 65),
        presetBg = Color3.fromRGB(6, 20, 14),
        presetBrd = Color3.fromRGB(30, 100, 65),
        presetLoad = Color3.fromRGB(0, 204, 102),
        presetDel = Color3.fromRGB(30, 120, 70),
        delBrd = Color3.fromRGB(60, 180, 110),
        lockOn = Color3.fromRGB(0, 204, 102),
        adTitle = Color3.fromRGB(0, 204, 102),
        adSub = Color3.fromRGB(120, 255, 190),
        adKeyLbl = Color3.fromRGB(255, 255, 255),
        adKeyBtn = Color3.fromRGB(0, 204, 102),
        adKeyBtnText = Color3.fromRGB(255, 255, 255),
        adActionBtn = Color3.fromRGB(0, 204, 102),
        adActionBtnText = Color3.fromRGB(255, 255, 255),
        adOffBg = Color3.fromRGB(20, 60, 40),
        adDimText = Color3.fromRGB(255, 255, 255),
        adBorder = Color3.fromRGB(0, 204, 102),
        adStroke = Color3.fromRGB(0, 204, 102),
        adBg = Color3.fromRGB(0, 0, 0),
        autoGrabText = Color3.fromRGB(255, 255, 255),
        autoGrabLine = Color3.fromRGB(0, 204, 102),
    },
    ["rbxassetid://85219527046711"] = {  -- 7UP FIZZ
        main = Color3.fromRGB(120, 220, 80),
        mainLight = Color3.fromRGB(180, 255, 130),
        mainDark = Color3.fromRGB(80, 170, 50),
        accent = Color3.fromRGB(120, 220, 80),
        text = Color3.fromRGB(255, 255, 255),
        subText = Color3.fromRGB(180, 255, 130),
        border = Color3.fromRGB(120, 220, 80),
        buttonBg = Color3.fromRGB(120, 220, 80),
        buttonText = Color3.fromRGB(255, 255, 255),
        speedText = Color3.fromRGB(120, 220, 80),
        discordText = Color3.fromRGB(0, 204, 102),
        tabActive = Color3.fromRGB(180, 255, 130),
        tabIdle = Color3.fromRGB(120, 220, 80),
        progressBg = Color3.fromRGB(20, 40, 10),
        toggleOn = Color3.fromRGB(120, 220, 80),
        toggleOff = Color3.fromRGB(20, 40, 15),
        inputBg = Color3.fromRGB(12, 25, 8),
        inputBorder = Color3.fromRGB(50, 110, 35),
        inputText = Color3.fromRGB(180, 255, 130),
        rowBg = Color3.fromRGB(15, 30, 10),
        rowHover = Color3.fromRGB(25, 50, 18),
        sectionHeader = Color3.fromRGB(120, 220, 80),
        closeBtn = Color3.fromRGB(50, 130, 30),
        closeBtnHover = Color3.fromRGB(120, 220, 80),
        titleText = Color3.fromRGB(180, 255, 130),
        subtitleText = Color3.fromRGB(120, 220, 80),
        stackBg = Color3.fromRGB(12, 25, 8),
        stackActive = Color3.fromRGB(80, 170, 50),
        stackText = Color3.fromRGB(210, 255, 190),
        stackActiveText = Color3.fromRGB(255, 255, 255),
        stackBorder = Color3.fromRGB(80, 170, 50),
        stackActiveBorder = Color3.fromRGB(120, 220, 80),
        dot = Color3.fromRGB(40, 110, 25),
        dotOn = Color3.fromRGB(120, 220, 80),
        pillOff = Color3.fromRGB(20, 40, 15),
        pillOn = Color3.fromRGB(120, 220, 80),
        modeBtnBg = Color3.fromRGB(12, 25, 8),
        modeBtnActBg = Color3.fromRGB(120, 220, 80),
        modeBtnTxt = Color3.fromRGB(120, 220, 80),
        modeBtnActTx = Color3.fromRGB(10, 30, 8),
        chipBorder = Color3.fromRGB(50, 110, 35),
        chipTxt = Color3.fromRGB(120, 220, 80),
        btnBg = Color3.fromRGB(12, 25, 8),
        btnTxt = Color3.fromRGB(210, 255, 190),
        btnHov = Color3.fromRGB(25, 50, 18),
        infoTxt = Color3.fromRGB(120, 220, 80),
        infoVal = Color3.fromRGB(180, 255, 130),
        infoFill = Color3.fromRGB(120, 220, 80),
        divider = Color3.fromRGB(40, 110, 25),
        winBorder = Color3.fromRGB(120, 220, 80),
        topBg = Color3.fromRGB(6, 18, 4),
        topBtn = Color3.fromRGB(50, 130, 30),
        tabBarBg = Color3.fromRGB(0, 0, 0),
        tabIdleHov = Color3.fromRGB(180, 255, 130),
        tabActiveBg = Color3.fromRGB(18, 38, 12),
        tabUnderline = Color3.fromRGB(120, 220, 80),
        rowBorder = Color3.fromRGB(40, 110, 25),
        rowLabel = Color3.fromRGB(210, 255, 190),
        rowSub = Color3.fromRGB(150, 220, 120),
        rowValue = Color3.fromRGB(180, 255, 130),
        inputFocus = Color3.fromRGB(120, 220, 80),
        dotOff = Color3.fromRGB(40, 110, 25),
        pillBorder = Color3.fromRGB(50, 110, 35),
        modeBtnBrd = Color3.fromRGB(50, 110, 35),
        presetBg = Color3.fromRGB(12, 25, 8),
        presetBrd = Color3.fromRGB(50, 110, 35),
        presetLoad = Color3.fromRGB(120, 220, 80),
        presetDel = Color3.fromRGB(50, 130, 30),
        delBrd = Color3.fromRGB(90, 180, 60),
        lockOn = Color3.fromRGB(120, 220, 80),
        adTitle = Color3.fromRGB(120, 220, 80),
        adSub = Color3.fromRGB(180, 255, 130),
        adKeyLbl = Color3.fromRGB(255, 255, 255),
        adKeyBtn = Color3.fromRGB(120, 220, 80),
        adKeyBtnText = Color3.fromRGB(255, 255, 255),
        adActionBtn = Color3.fromRGB(120, 220, 80),
        adActionBtnText = Color3.fromRGB(255, 255, 255),
        adOffBg = Color3.fromRGB(30, 70, 20),
        adDimText = Color3.fromRGB(255, 255, 255),
        adBorder = Color3.fromRGB(120, 220, 80),
        adStroke = Color3.fromRGB(120, 220, 80),
        adBg = Color3.fromRGB(0, 0, 0),
        autoGrabText = Color3.fromRGB(255, 255, 255),
        autoGrabLine = Color3.fromRGB(120, 220, 80),
    },
    ["rbxassetid://139630779093907"] = {  -- 7UP DARK
        main = Color3.fromRGB(0, 160, 80),
        mainLight = Color3.fromRGB(60, 220, 140),
        mainDark = Color3.fromRGB(0, 120, 60),
        accent = Color3.fromRGB(0, 160, 80),
        text = Color3.fromRGB(255, 255, 255),
        subText = Color3.fromRGB(100, 220, 160),
        border = Color3.fromRGB(0, 160, 80),
        buttonBg = Color3.fromRGB(0, 160, 80),
        buttonText = Color3.fromRGB(255, 255, 255),
        speedText = Color3.fromRGB(0, 160, 80),
        discordText = Color3.fromRGB(0, 204, 102),
        tabActive = Color3.fromRGB(60, 220, 140),
        tabIdle = Color3.fromRGB(0, 160, 80),
        progressBg = Color3.fromRGB(8, 25, 15),
        toggleOn = Color3.fromRGB(0, 160, 80),
        toggleOff = Color3.fromRGB(10, 35, 20),
        inputBg = Color3.fromRGB(6, 18, 10),
        inputBorder = Color3.fromRGB(20, 80, 45),
        inputText = Color3.fromRGB(100, 220, 160),
        rowBg = Color3.fromRGB(10, 22, 14),
        rowHover = Color3.fromRGB(18, 35, 22),
        sectionHeader = Color3.fromRGB(0, 160, 80),
        closeBtn = Color3.fromRGB(20, 100, 50),
        closeBtnHover = Color3.fromRGB(0, 160, 80),
        titleText = Color3.fromRGB(100, 220, 160),
        subtitleText = Color3.fromRGB(0, 160, 80),
        stackBg = Color3.fromRGB(8, 20, 12),
        stackActive = Color3.fromRGB(0, 120, 60),
        stackText = Color3.fromRGB(190, 255, 215),
        stackActiveText = Color3.fromRGB(255, 255, 255),
        stackBorder = Color3.fromRGB(0, 120, 60),
        stackActiveBorder = Color3.fromRGB(0, 160, 80),
        dot = Color3.fromRGB(20, 80, 40),
        dotOn = Color3.fromRGB(0, 160, 80),
        pillOff = Color3.fromRGB(10, 35, 20),
        pillOn = Color3.fromRGB(0, 160, 80),
        modeBtnBg = Color3.fromRGB(6, 18, 10),
        modeBtnActBg = Color3.fromRGB(0, 160, 80),
        modeBtnTxt = Color3.fromRGB(0, 160, 80),
        modeBtnActTx = Color3.fromRGB(10, 30, 15),
        chipBorder = Color3.fromRGB(20, 80, 45),
        chipTxt = Color3.fromRGB(0, 160, 80),
        btnBg = Color3.fromRGB(8, 20, 12),
        btnTxt = Color3.fromRGB(190, 255, 215),
        btnHov = Color3.fromRGB(18, 35, 22),
        infoTxt = Color3.fromRGB(0, 160, 80),
        infoVal = Color3.fromRGB(100, 220, 160),
        infoFill = Color3.fromRGB(0, 160, 80),
        divider = Color3.fromRGB(20, 80, 40),
        winBorder = Color3.fromRGB(0, 160, 80),
        topBg = Color3.fromRGB(4, 12, 7),
        topBtn = Color3.fromRGB(20, 100, 50),
        tabBarBg = Color3.fromRGB(0, 0, 0),
        tabIdleHov = Color3.fromRGB(100, 220, 160),
        tabActiveBg = Color3.fromRGB(8, 28, 15),
        tabUnderline = Color3.fromRGB(0, 160, 80),
        rowBorder = Color3.fromRGB(20, 80, 40),
        rowLabel = Color3.fromRGB(190, 255, 215),
        rowSub = Color3.fromRGB(120, 200, 155),
        rowValue = Color3.fromRGB(100, 220, 160),
        inputFocus = Color3.fromRGB(0, 160, 80),
        dotOff = Color3.fromRGB(20, 80, 40),
        pillBorder = Color3.fromRGB(20, 80, 45),
        modeBtnBrd = Color3.fromRGB(20, 80, 45),
        presetBg = Color3.fromRGB(6, 18, 10),
        presetBrd = Color3.fromRGB(20, 80, 45),
        presetLoad = Color3.fromRGB(0, 160, 80),
        presetDel = Color3.fromRGB(20, 100, 50),
        delBrd = Color3.fromRGB(50, 150, 80),
        lockOn = Color3.fromRGB(0, 160, 80),
        adTitle = Color3.fromRGB(0, 160, 80),
        adSub = Color3.fromRGB(100, 220, 160),
        adKeyLbl = Color3.fromRGB(255, 255, 255),
        adKeyBtn = Color3.fromRGB(0, 160, 80),
        adKeyBtnText = Color3.fromRGB(255, 255, 255),
        adActionBtn = Color3.fromRGB(0, 160, 80),
        adActionBtnText = Color3.fromRGB(255, 255, 255),
        adOffBg = Color3.fromRGB(15, 50, 30),
        adDimText = Color3.fromRGB(255, 255, 255),
        adBorder = Color3.fromRGB(0, 160, 80),
        adStroke = Color3.fromRGB(0, 160, 80),
        adBg = Color3.fromRGB(0, 0, 0),
        autoGrabText = Color3.fromRGB(255, 255, 255),
        autoGrabLine = Color3.fromRGB(0, 160, 80),
    },
}

-- The red colorway is derived from whichever soda/background palette is
-- selected, so changing the background never silently switches the UI green.
local function get7UpThemeScheme(baseScheme, mode)
    baseScheme = baseScheme or COLOR_SCHEMES["rbxassetid://102557909116203"]
    if mode ~= "Red" then return baseScheme end
    local themed = {}
    for key, value in pairs(baseScheme) do
        if typeof(value) == "Color3" then
            local hue, saturation, brightness = Color3.toHSV(value)
            local isGreenFamily = value.G > value.R * 1.08 and value.G > value.B * 1.04
            if isGreenFamily and saturation > 0.12 then
                -- Preserve the original brightness/contrast but move the hue
                -- to 7UP red. Dark greens become dark reds, not flat neon.
                themed[key] = Color3.fromHSV(0.985, math.clamp(saturation * 1.04, 0, 1), brightness)
            else
                themed[key] = value
            end
        else
            themed[key] = value
        end
    end
    themed.main = Color3.fromRGB(220, 32, 46)
    themed.mainLight = Color3.fromRGB(255, 92, 105)
    themed.mainDark = Color3.fromRGB(132, 12, 28)
    themed.accent = themed.main
    themed.border = themed.main
    themed.buttonBg = themed.main
    themed.speedText = themed.mainLight
    themed.discordText = themed.mainLight
    themed.sectionHeader = themed.mainLight
    themed.toggleOn = themed.main
    themed.tabActive = themed.mainLight
    themed.tabIdle = themed.main
    themed.tabUnderline = themed.main
    themed.stackActive = themed.mainDark
    themed.stackActiveBorder = themed.main
    themed.dotOn = themed.main
    themed.pillOn = themed.main
    themed.modeBtnActBg = themed.main
    themed.modeBtnTxt = themed.mainLight
    themed.chipTxt = themed.mainLight
    themed.infoTxt = themed.mainLight
    themed.infoFill = themed.main
    themed.winBorder = themed.main
    themed.inputFocus = themed.main
    themed.presetLoad = themed.main
    themed.lockOn = themed.main
    themed.adTitle = themed.mainLight
    themed.adKeyBtn = themed.main
    themed.adActionBtn = themed.main
    themed.adBorder = themed.main
    themed.adStroke = themed.main
    themed.autoGrabLine = themed.main
    return themed
end

local GREEN_7UP_BACKGROUND = "rbxassetid://102557909116203"
local RED_7UP_BACKGROUND = "rbxassetid://4928243956"

_G._K7ThemeMode = _G._K7ThemeMode == "Red" and "Red" or "Green"
_G._K7AccentColor = _G._K7ThemeMode == "Red"
    and Color3.fromRGB(220, 32, 46) or Color3.fromRGB(0, 204, 102)

local currentColorScheme = get7UpThemeScheme(
    COLOR_SCHEMES["rbxassetid://102557909116203"], _G._K7ThemeMode
)
local currentBgImage = _G._K7ThemeMode == "Red" and RED_7UP_BACKGROUND or GREEN_7UP_BACKGROUND

-- One live blend shared by a can's neck and body, so skins/states never split visually.
local function adaptiveCanColorSequence(scheme, active)
    scheme = scheme or currentColorScheme or {}
    local deep = scheme.stackBg or scheme.mainDark or Color3.fromRGB(0,42,22)
    local base = active and (scheme.stackActive or scheme.main) or (scheme.mainDark or deep)
    local bright = scheme.mainLight or scheme.main or Color3.fromRGB(0,190,82)
    local middle = active and (scheme.main or bright) or (scheme.stackBg or base)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,deep),
        ColorSequenceKeypoint.new(0.22,bright),
        ColorSequenceKeypoint.new(0.58,middle),
        ColorSequenceKeypoint.new(1,deep),
    })
end

-- ============================================================
-- AUTO GRAB MODULE (unchanged)
-- ============================================================
local autoGrabModule = (function()
    -- ================================================================
    -- K7 AUTO STEAL MODULE v2 — Normal + Semi modes (ported from Ace)
    -- ================================================================
    local RunService    = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Stats         = game:GetService("Stats")
    local UIS           = game:GetService("UserInputService")
    local TweenService  = game:GetService("TweenService")
    local CoreGui       = game:GetService("CoreGui")

    local Steal = { AutoStealEnabled = false, StealRadius = 10 }
    local selectedStealMode = "Normal"   -- Normal = Auto Grab V3 (80%), Semi = Auto Grab V2
    local StealRadii = { Normal = 63, Semi = 10 }  -- V3 wide ~80% range, V2 tight

    local currentBgImage    = "rbxassetid://102557909116203"
    local currentColorScheme = COLOR_SCHEMES[currentBgImage]

    -- ── StealBar API (shared between Normal and Semi) ─────────────
    local _barGui, _barFrame, _barFill, _barPct, _barBg = nil,nil,nil,nil,nil
    local _barPingLbl, _barFpsLbl, _barStateLbl, _barCarryLbl = nil,nil,nil,nil
    local _barBrandDisc, _barBrandText, _barFillGradient = nil,nil,nil
    local _barCanWash, _barCanGradient = nil, nil
    local _barSmoothPct = 0
    local _barUI = nil
    local _barScale = 1
    local _barFitScale = 1

    _G.StealBar = {
        SetState    = function(s)
            local name = tostring(s or ""):gsub("^%s+",""):gsub("%s+$","")
            if name == "" or name:upper() == "STEALING" or name:upper() == "AUTO GRAB" then
                name = "BRAINROT"
            end
            if _barStateLbl then _barStateLbl.Text = name:upper() end
        end,
        SetProgress = function(p)
            p = math.clamp(tonumber(p) or 0, 0, 1)
            if _barFill then
                _barSmoothPct = _barSmoothPct + (p - _barSmoothPct) * 0.8
                _barFill.Size = UDim2.new(_barSmoothPct, 0, 1, 0)
                _barFill.BackgroundColor3 = currentColorScheme.autoGrabLine or currentColorScheme.main
            end
            if _barPct then _barPct.Text = tostring(math.floor((_barSmoothPct*100)+0.5)).."%" end
        end,
        Reset = function()
            _barSmoothPct = 0
            if _barFill then _barFill.Size  = UDim2.new(0,0,1,0) end
            if _barPct  then _barPct.Text   = "0%" end
        end,
    }

    local _barBgImg = nil  -- direct reference for instant background updates

    local function createAutoGrabUI()
        local old = CoreGui:FindFirstChild("K7StealBarGui")
        if old then old:Destroy() end
        local old2 = (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui")):FindFirstChild("AutoGrab")
        if old2 then old2:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name          = "AutoGrab"
        gui.ResetOnSpawn  = false
        gui.DisplayOrder  = 20
        gui.IgnoreGuiInset = true
        gui.Parent        = LP:WaitForChild("PlayerGui")
        _barGui = gui
        _G._K7AutoGrabGui = gui

        _barFrame = Instance.new("Frame", gui)
        _barFrame.Name   = "StealBar"
        _barFrame.Size   = UDim2.new(0, 580, 0, 70)
        _barFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        _barFrame.Position = UDim2.new(0.5, 0, 0.91, 0)
        _barFrame.BackgroundColor3 = currentColorScheme.mainDark
        _barFrame.BorderSizePixel  = 0
        _barFrame.Active           = true
        _barFrame.ClipsDescendants = true
        _G._K7AutoGrabFrame = _barFrame
        _barUI = Instance.new("UIScale", _barFrame)
        local barViewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
        _barFitScale = math.min(1, math.max(0.56, (barViewport.X - 18) / 580))
        _barUI.Scale = _barScale * _barFitScale
        Instance.new("UICorner", _barFrame).CornerRadius = UDim.new(1, 0)
        local fs = Instance.new("UIStroke", _barFrame)
        fs.Color = currentColorScheme.autoGrabLine or currentColorScheme.main
        fs.Thickness = 2; fs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        fs.Transparency = 1
        _barBgImg = Instance.new("ImageLabel", _barFrame)
        _barBgImg.Name = "BgImg"
        _barBgImg.Size = UDim2.new(1, 0, 1, 0)
        _barBgImg.Image = currentBgImage
        _barBgImg.ScaleType = Enum.ScaleType.Crop
        _barBgImg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
        _barBgImg.BackgroundTransparency = 1
        -- Keep the selected can skin visible instead of burying it under the tint.
        _barBgImg.ImageTransparency = 0.08
        _barBgImg.BorderSizePixel = 0
        _barBgImg.ZIndex = 1
        _barBgImg.Visible = true
        Instance.new("UICorner", _barBgImg).CornerRadius = UDim.new(1, 0)

        -- Soda-can sheen and carbonation bubbles.
        local canWash = Instance.new("Frame", _barFrame)
        _barCanWash = canWash
        canWash.Name = "SodaCanWash"
        canWash.Size = UDim2.new(1,0,1,0)
        canWash.BackgroundColor3 = currentColorScheme.mainDark
        canWash.BackgroundTransparency = 0.78
        canWash.BorderSizePixel = 0
        canWash.ZIndex = 2
        canWash.Active = false
        Instance.new("UICorner", canWash).CornerRadius = UDim.new(1,0)
        local canGradient = Instance.new("UIGradient", canWash)
        _barCanGradient = canGradient
        canGradient.Color = adaptiveCanColorSequence(currentColorScheme, false)
        canGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.12), NumberSequenceKeypoint.new(0.2,0.06),
            NumberSequenceKeypoint.new(0.75,0.18), NumberSequenceKeypoint.new(1,0.08),
        })
        canGradient.Rotation = 0
        local yellowSweep=Instance.new("Frame",_barFrame)
        yellowSweep.Size=UDim2.new(0,14,0,108); yellowSweep.Position=UDim2.new(0,130,0,-16)
        yellowSweep.Rotation=18; yellowSweep.BackgroundColor3=Color3.fromRGB(225,228,45)
yellowSweep.BackgroundTransparency=0.56; yellowSweep.BorderSizePixel=0; yellowSweep.ZIndex=1
        Instance.new("UICorner",yellowSweep).CornerRadius=UDim.new(1,0)
        yellowSweep.Visible=false
        for _, bubbleData in ipairs({{145,9,5},{153,22,3},{136,57,5},{454,10,4}}) do
            local bubble = Instance.new("Frame", _barFrame)
            bubble.Name = "SodaBubble"
            bubble.Size = UDim2.new(0,bubbleData[3],0,bubbleData[3])
            bubble.Position = UDim2.new(0,bubbleData[1],0,bubbleData[2])
            bubble.BackgroundColor3 = Color3.fromRGB(235,255,242)
            bubble.BackgroundTransparency = 0.34
            bubble.BorderSizePixel = 0
            bubble.ZIndex = 3
            bubble.Visible = false
            Instance.new("UICorner",bubble).CornerRadius = UDim.new(1,0)
        end
        for _, rimX in ipairs({4,568}) do
            local rim = Instance.new("Frame",_barFrame)
            rim.Name = "AluminumRim"
            rim.Size = UDim2.new(0,8,1,-12); rim.Position = UDim2.new(0,rimX,0,6)
            rim.BackgroundColor3 = Color3.fromRGB(154,170,160); rim.BackgroundTransparency = 0
            rim.BorderSizePixel = 0; rim.ZIndex = 3
            Instance.new("UICorner",rim).CornerRadius = UDim.new(0,4)
            rim.Visible = false
            local rimGrad = Instance.new("UIGradient",rim)
            rimGrad.Color = ColorSequence.new(Color3.fromRGB(70,88,76),Color3.fromRGB(182,194,186))
            rimGrad.Rotation = 90
        end

        -- Drag
        do
            local dragging, dragStart, frameStart, dragInput = false,nil,nil,nil
            _barFrame.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging   = true
                    dragStart  = inp.Position
                    frameStart = _barFrame.Position
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                end
            end)
            _barFrame.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    dragInput = inp
                end
            end)
            UIS.InputChanged:Connect(function(inp)
                if inp == dragInput and dragging then
                    local dx = inp.Position.X - dragStart.X
                    local dy = inp.Position.Y - dragStart.Y
                    _barFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset+dx, frameStart.Y.Scale, frameStart.Y.Offset+dy)
                end
            end)
        end

        -- Compact 7UP brand block and one large, easy-to-read mode chip.
        _barBrandDisc = Instance.new("Frame", _barFrame)
        _barBrandDisc.Name = "SevenUpRedDisc"
        _barBrandDisc.Size = UDim2.new(0,38,0,38)
        _barBrandDisc.Position = UDim2.new(0,68,0,10)
        _barBrandDisc.BackgroundColor3 = Color3.fromRGB(224,38,45)
        _barBrandDisc.BorderSizePixel = 0
        _barBrandDisc.ZIndex = 5
        Instance.new("UICorner",_barBrandDisc).CornerRadius = UDim.new(1,0)
        local brandStroke = Instance.new("UIStroke",_barBrandDisc)
        brandStroke.Color = Color3.fromRGB(255,255,255); brandStroke.Thickness = 2; brandStroke.Transparency = 0.03

        _barBrandText = Instance.new("TextLabel", _barBrandDisc)
        _barBrandText.Size = UDim2.new(1,0,1,0)
        _barBrandText.BackgroundTransparency = 1
        _barBrandText.Text = "7"
        _barBrandText.TextColor3 = Color3.fromRGB(255,255,255)
        _barBrandText.TextStrokeColor3 = Color3.fromRGB(0,80,35)
        _barBrandText.TextStrokeTransparency = 0.35
        _barBrandText.Font = Enum.Font.GothamBlack
        _barBrandText.TextSize = 25
        _barBrandText.Rotation = -8
        _barBrandText.ZIndex = 6

        local upText = Instance.new("TextLabel", _barFrame)
        upText.Size = UDim2.new(0,40,0,24)
        upText.Position = UDim2.new(0,104,0,15)
        upText.BackgroundTransparency = 1
        upText.Text = "UP"
        upText.TextColor3 = Color3.fromRGB(255,255,255)
        upText.TextStrokeColor3 = Color3.fromRGB(0,70,32)
        upText.TextStrokeTransparency = 0.25
        upText.Font = Enum.Font.GothamBlack
        upText.TextSize = 18
        upText.TextXAlignment = Enum.TextXAlignment.Left
        upText.ZIndex = 6

        local modeChip = Instance.new("TextLabel", _barFrame)
        modeChip.Name = "ModeChip"
        modeChip.Size = UDim2.new(0,80,0,48)
        modeChip.Position = UDim2.new(0,404,0,11)
        modeChip.BackgroundColor3 = currentColorScheme.main
        modeChip.BackgroundTransparency = 0.08
        modeChip.BorderSizePixel = 0
        modeChip.Text = selectedStealMode:upper()
        modeChip.TextColor3 = Color3.fromRGB(255,255,255)
        modeChip.Font = Enum.Font.GothamBlack
        modeChip.TextSize = 14
        modeChip.TextWrapped = true
        modeChip.ZIndex = 6
        Instance.new("UICorner", modeChip).CornerRadius = UDim.new(1, 0)
        _G._K7StealModeChip = modeChip

        -- Carry belongs on its own mobile control, not inside the Auto Grab HUD.
        _barCarryLbl = nil
        _G._K7CarryModeChip = nil
        _G._K7SetCarryStatus = function() end

        -- Scale controls sit on the can's left rim.
        local function makeScaleBtn(symbol, xOff, delta)
            local btn = Instance.new("TextButton", _barFrame)
            btn.Size = UDim2.new(0,22,0,22)
            btn.Position = UDim2.new(0,xOff,0.5,-11)
            btn.BackgroundColor3 = Color3.fromRGB(225,245,230)
            btn.BackgroundTransparency = 0.78
            btn.BorderSizePixel = 0
            btn.Text = symbol
            btn.TextColor3 = currentColorScheme.autoGrabLine or currentColorScheme.main
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 17
            btn.ZIndex = 7
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
            btn.MouseButton1Click:Connect(function()
                _barScale = math.clamp(_barScale + delta, 0.6, 1.6)
                if _barUI then _barUI.Scale = _barScale * _barFitScale end
                if _G._K7RequestSave then pcall(_G._K7RequestSave) end
            end)
        end
        makeScaleBtn("-", 16, -0.1)
        makeScaleBtn("+", 42, 0.1)

        local systemTitle = Instance.new("TextLabel",_barFrame)
        systemTitle.Size = UDim2.new(0,240,0,16); systemTitle.Position = UDim2.new(0,150,0,5)
        systemTitle.BackgroundTransparency = 1; systemTitle.Text = "AUTO GRAB"
        systemTitle.TextColor3 = Color3.fromRGB(205,255,220); systemTitle.Font = Enum.Font.GothamBlack
        systemTitle.TextSize = 8; systemTitle.TextXAlignment = Enum.TextXAlignment.Left; systemTitle.ZIndex = 6
        systemTitle.Visible = false

        -- Carbonated progress window.
        _barBg = Instance.new("Frame", _barFrame)
        _barBg.Name = "BarBg"
        _barBg.Size = UDim2.new(0, 256, 0, 48)
        _barBg.Position = UDim2.new(0, 144, 0.5, -24)
        _barBg.BackgroundColor3 = currentColorScheme.progressBg or Color3.fromRGB(5,25,14)
        _barBg.BackgroundTransparency = 0.08
        _barBg.BorderSizePixel = 0
        _barBg.ClipsDescendants = true
        _barBg.ZIndex = 2
        Instance.new("UICorner", _barBg).CornerRadius = UDim.new(1, 0)
        local bgGrad = Instance.new("UIGradient", _barBg)
        bgGrad.Color = ColorSequence.new(Color3.fromRGB(18, 52, 30), Color3.fromRGB(4, 18, 10))
        bgGrad.Rotation = 90
        local bgStroke = Instance.new("UIStroke", _barBg)
        bgStroke.Color = currentColorScheme.autoGrabLine or currentColorScheme.main
        bgStroke.Thickness = 1
        bgStroke.Transparency = 1

        _barFill = Instance.new("Frame", _barBg)
        _barFill.Name = "Fill"
        _barFill.Size = UDim2.new(0,0,1,0)
        _barFill.BackgroundColor3 = currentColorScheme.autoGrabLine or currentColorScheme.main
        _barFill.BorderSizePixel = 0
        _barFill.ZIndex = 3
        Instance.new("UICorner", _barFill).CornerRadius = UDim.new(1, 0)
        _barFillGradient = Instance.new("UIGradient", _barFill)
        _barFillGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,150,62)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(0,225,96)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(145,255,90)),
        })
        _barFillGradient.Rotation = 5
        local fillShine = Instance.new("Frame",_barFill)
        fillShine.Size = UDim2.new(1,0,0,4); fillShine.Position = UDim2.new(0,0,0,5)
        fillShine.BackgroundColor3 = Color3.fromRGB(255,255,255); fillShine.BackgroundTransparency = 0.55
        fillShine.BorderSizePixel = 0; fillShine.ZIndex = 4
        fillShine.Visible = false
        Instance.new("UICorner",fillShine).CornerRadius = UDim.new(1,0)
        for tickIndex=1,9 do
            local tickMark=Instance.new("Frame",_barBg)
            tickMark.Size=UDim2.new(0,1,1,-16); tickMark.Position=UDim2.new(tickIndex/10,0,0,8)
            tickMark.BackgroundColor3=Color3.fromRGB(255,255,255); tickMark.BackgroundTransparency=0.82
            tickMark.BorderSizePixel=0; tickMark.ZIndex=4
            tickMark.Visible=false
        end

        -- Clean status copy; no legacy branding.
        local k7Lbl = Instance.new("TextLabel", _barBg)
        k7Lbl.Size   = UDim2.new(1,-92,1,0)
        k7Lbl.Position = UDim2.new(0,12,0,0)
        k7Lbl.BackgroundTransparency = 1
        k7Lbl.Text   = "BRAINROT"
        k7Lbl.TextColor3 = Color3.fromRGB(255,255,255)
        k7Lbl.Font   = Enum.Font.GothamBlack
        k7Lbl.TextSize = 12
        k7Lbl.TextXAlignment = Enum.TextXAlignment.Left
        k7Lbl.TextTruncate = Enum.TextTruncate.AtEnd
        k7Lbl.ZIndex = 5
        _barStateLbl = k7Lbl

        -- Percentage inside the progress region (right)
        _barPct = Instance.new("TextLabel", _barBg)
        _barPct.Name = "PctLbl"
        _barPct.Size   = UDim2.new(0,54,1,0)
        _barPct.Position = UDim2.new(1,-64,0,0)
        _barPct.BackgroundTransparency = 1
        _barPct.Text   = "0%"
        _barPct.TextColor3 = Color3.fromRGB(255,255,255)
        _barPct.Font   = Enum.Font.GothamBold
        _barPct.TextSize = 12
        _barPct.TextXAlignment = Enum.TextXAlignment.Right
        _barPct.ZIndex = 5

        -- Performance readout is stacked at the right edge.
        _barFpsLbl = Instance.new("TextLabel", _barFrame)
        _barFpsLbl.Size = UDim2.new(0,78,0,27)
        _barFpsLbl.Position = UDim2.new(1,-88,0,6)
        _barFpsLbl.BackgroundColor3 = Color3.fromRGB(2,22,11)
        _barFpsLbl.BackgroundTransparency = 0.16
        _barFpsLbl.Text  = "--FPS"
        _barFpsLbl.TextColor3 = currentColorScheme.autoGrabText or Color3.fromRGB(230,230,230)
        _barFpsLbl.Font  = Enum.Font.GothamBlack
        _barFpsLbl.TextSize = 14
        _barFpsLbl.TextXAlignment = Enum.TextXAlignment.Center
        _barFpsLbl.ZIndex = 6
        Instance.new("UICorner",_barFpsLbl).CornerRadius = UDim.new(1,0)
        local fpsStroke=Instance.new("UIStroke",_barFpsLbl); fpsStroke.Color=currentColorScheme.main; fpsStroke.Transparency=1

        _barPingLbl = Instance.new("TextLabel", _barFrame)
        _barPingLbl.Size = UDim2.new(0,78,0,27)
        _barPingLbl.Position = UDim2.new(1,-88,0,37)
        _barPingLbl.BackgroundColor3 = Color3.fromRGB(2,22,11)
        _barPingLbl.BackgroundTransparency = 0.16
        _barPingLbl.Text = "--ms"
        _barPingLbl.TextColor3 = currentColorScheme.autoGrabText or Color3.fromRGB(230,230,230)
        _barPingLbl.Font = Enum.Font.GothamBlack
        _barPingLbl.TextSize = 14
        _barPingLbl.TextXAlignment = Enum.TextXAlignment.Center
        _barPingLbl.ZIndex = 6
        Instance.new("UICorner",_barPingLbl).CornerRadius = UDim.new(1,0)
        local pingStroke=Instance.new("UIStroke",_barPingLbl); pingStroke.Color=currentColorScheme.main; pingStroke.Transparency=1

        -- Ping updater
        task.spawn(function()
            while _barPingLbl and _barPingLbl.Parent do
                task.wait(1)
                pcall(function()
                    local stat = Stats.Network.ServerStatsItem["Data Ping"]
                    local p = stat and math.floor(stat:GetValue() or 0) or 0
                    _barPingLbl.Text = tostring(p).."ms"
                    local goodClr = currentColorScheme and currentColorScheme.main or Color3.fromRGB(120,255,190)
                    if p < 70 then _barPingLbl.TextColor3 = goodClr
                    elseif p < 120 then _barPingLbl.TextColor3 = Color3.fromRGB(255,220,80)
                    else _barPingLbl.TextColor3 = Color3.fromRGB(255,80,80) end
                end)
            end
        end)

        -- FPS updater
        task.spawn(function()
            local fc = 0; local lt = tick()
            local rc = RunService.RenderStepped:Connect(function() fc = fc+1 end)
            while _barFpsLbl and _barFpsLbl.Parent do
                task.wait(1)
                local now = tick(); local el = now-lt
                local fps = el>0 and math.floor(fc/el) or 0
                fc = 0; lt = now
                pcall(function()
                    _barFpsLbl.Text = tostring(fps).." FPS"
                    local goodClr = currentColorScheme and currentColorScheme.main or Color3.fromRGB(120,255,190)
                    if fps >= 50 then _barFpsLbl.TextColor3 = goodClr
                    elseif fps >= 30 then _barFpsLbl.TextColor3 = Color3.fromRGB(255,220,80)
                    else _barFpsLbl.TextColor3 = Color3.fromRGB(255,80,80) end
                end)
            end
            rc:Disconnect()
        end)

        print("[Auto Grab v2] UI loaded — Normal + Semi steal bar")
    end

    -- ── updateAutoGrabLineColor (called by changeDuelScriptBackground) ──────
    local function updateAutoGrabLineColor(scheme)
        currentColorScheme = scheme
        -- direct refs — instant, no loop needed
        if _barBgImg then
            _barBgImg.Image = currentBgImage
            -- Both colorways have their own finished art. Keeping this white
            -- prevents the red image from looking like a second tinted layer.
            _barBgImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        if _barFrame then _barFrame.BackgroundColor3 = scheme.mainDark end
        if _barCanWash then
            _barCanWash.BackgroundColor3 = scheme.mainDark
            _barCanWash.BackgroundTransparency = _G._K7ThemeMode == "Red" and 0.86 or 0.78
        end
        if _barCanGradient then
            _barCanGradient.Color = adaptiveCanColorSequence(scheme, false)
        end
        if _barFill   then _barFill.BackgroundColor3  = scheme.autoGrabLine or scheme.main end
        if _barBg     then _barBg.BackgroundColor3    = scheme.progressBg or Color3.fromRGB(8,20,14) end
        if _G._K7StealModeChip then _G._K7StealModeChip.BackgroundColor3 = scheme.main end
        -- stroke color
        if _barFrame then
            for _, obj in ipairs(_barFrame:GetChildren()) do
                if obj:IsA("UIStroke") then obj.Color = scheme.autoGrabLine or scheme.main end
            end
        end
        -- label colors
        if _barPingLbl then _barPingLbl.TextColor3 = scheme.main end
        if _barFpsLbl then _barFpsLbl.TextColor3 = scheme.main end
    end

    -- ================================================================
    -- NORMAL STEAL SYSTEM (simple proximity, no sync required)
    -- ================================================================
    _G.K7NormalSteal = _G.K7NormalSteal or {
        enabled = false, radius = 62, duration = 1.3,
        animals = {}, promptCache = {}, internalCache = {},
        scannerStarted = false, isStealing = false,
        stealConn = nil, lastSteal = 0, cooldown = 0.05,
    }

    local function _normalGetRoot()
        local c = LP.Character
        if not c then return nil end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
    end

    local function _normalIsMyBase(plotName)
        local plots = workspace:FindFirstChild("Plots")
        local plot  = plots and plots:FindFirstChild(plotName)
        if not plot then return false end
        local sign   = plot:FindFirstChild("PlotSign")
        local yourBase = sign and sign:FindFirstChild("YourBase")
        return yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled == true
    end

    local function _normalScanPlots()
        local A = _G.K7NormalSteal
        A.animals = {}
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") and not _normalIsMyBase(plot.Name) then
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, podium in ipairs(podiums:GetChildren()) do
                        if podium:IsA("Model") then
                            local base  = podium:FindFirstChild("Base")
                            local spawn = base and base:FindFirstChild("Spawn")
                            if spawn then
                                table.insert(A.animals, {
                                    plot = plot.Name, slot = podium.Name,
                                    worldPosition = spawn.Position,
                                    uid = plot.Name.."_"..podium.Name,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    local function _normalEnsureScanner()
        local A = _G.K7NormalSteal
        if A.scannerStarted then return end
        A.scannerStarted = true
        task.spawn(function()
            task.wait(1)
            while _G.K7NormalSteal do
                if A.enabled then pcall(_normalScanPlots) end
                task.wait(3)
            end
        end)
    end

    local function _normalFindPrompt(data)
        if not data then return nil end
        local A = _G.K7NormalSteal
        local cached = A.promptCache[data.uid]
        if cached and cached.Parent then return cached end
        local plots  = workspace:FindFirstChild("Plots")
        local plot   = plots and plots:FindFirstChild(data.plot)
        local pds    = plot and plot:FindFirstChild("AnimalPodiums")
        local pod    = pds  and pds:FindFirstChild(data.slot)
        local base   = pod  and pod:FindFirstChild("Base")
        local spawn  = base and base:FindFirstChild("Spawn")
        local attach = spawn and spawn:FindFirstChild("PromptAttachment")
        if not attach then return nil end
        for _, p in ipairs(attach:GetChildren()) do
            if p:IsA("ProximityPrompt") then
                A.promptCache[data.uid] = p; return p
            end
        end
        return nil
    end

    local function _normalCacheCallbacks(prompt)
        local A = _G.K7NormalSteal
        if A.internalCache[prompt] then return end
        local data = {hold={}, trigger={}, ready=true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if type(c.Function)=="function" then table.insert(data.hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if type(c.Function)=="function" then table.insert(data.trigger, c.Function) end
                end
            end
        end)
        if #data.hold>0 or #data.trigger>0 then A.internalCache[prompt]=data end
    end

    local function _normalDoSteal(prompt, animalData)
        local A = _G.K7NormalSteal
        if not prompt or not prompt.Parent or A.isStealing then return end
        if tick()-(A.lastSteal or 0) < (A.cooldown or 0.08) then return end
        _normalCacheCallbacks(prompt)
        local data = A.internalCache[prompt]
        if not data or not data.ready then return end
        data.ready = false; A.isStealing = true; A.lastSteal = tick()
        pcall(function() if _G.StealBar then _G.StealBar.SetState("STEALING") end end)
        task.spawn(function()
            if #data.hold>0 then
                for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end
            end
            local FILL_CAP = 0.8
            local HOLD_TIME = 2
            local COMPLETE_RADIUS = 9
            local function inCompleteRange()
                local root = _normalGetRoot()
                if not root or not animalData or not animalData.worldPosition then return false end
                return (root.Position-animalData.worldPosition).Magnitude <= COMPLETE_RADIUS
            end
            local t0 = tick(); local dur = A.duration or 1.3
            while A.enabled and selectedStealMode=="Normal" and tick()-t0 < dur do
                local p = math.min((tick()-t0)/dur, FILL_CAP)
                pcall(function() if _G.StealBar then _G.StealBar.SetProgress(p) end end)
                if p >= FILL_CAP then break end
                task.wait(0.02)
            end
            if not A.enabled or selectedStealMode~="Normal" then
                data.ready=true; A.isStealing=false
                pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
                return
            end
            local holdT0 = tick(); local completed = false
            while A.enabled and selectedStealMode=="Normal" and tick()-holdT0 < HOLD_TIME do
                pcall(function() if _G.StealBar then _G.StealBar.SetProgress(FILL_CAP) end end)
                if inCompleteRange() then completed = true break end
                task.wait(0.02)
            end
            if not A.enabled or selectedStealMode~="Normal" or not completed then
                data.ready=true; A.isStealing=false
                pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
                return
            end
            local t1 = tick(); local fillDur = dur*(1-FILL_CAP)
            while A.enabled and selectedStealMode=="Normal" and tick()-t1 < fillDur do
                local p = FILL_CAP + math.min((tick()-t1)/fillDur, 1)*(1-FILL_CAP)
                pcall(function() if _G.StealBar then _G.StealBar.SetProgress(p) end end)
                task.wait(0.02)
            end
            if not A.enabled or selectedStealMode~="Normal" then
                data.ready=true; A.isStealing=false
                pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
                return
            end
            pcall(function() if _G.StealBar then _G.StealBar.SetProgress(1) end end)
            if #data.trigger>0 then
                for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end
            end
            task.wait(0.12)
            data.ready=true; A.isStealing=false
            pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
        end)
    end

    local function _normalNearestAnimal()
        local A = _G.K7NormalSteal
        local root = _normalGetRoot()
        if not root then return nil end
        local best, bestDist = nil, math.huge
        for _, data in ipairs(A.animals) do
            if data.worldPosition and not _normalIsMyBase(data.plot) then
                local dist = (root.Position-data.worldPosition).Magnitude
                if dist < bestDist then best=data; bestDist=dist end
            end
        end
        if best and bestDist <= (tonumber(A.radius) or 62) then return best end
        return nil
    end

    _G.K7NormalAutoStealStop = function()
        local A = _G.K7NormalSteal
        A.enabled = false; A.isStealing = false
        if A.stealConn then A.stealConn:Disconnect(); A.stealConn=nil end
        pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
    end

    _G.K7NormalAutoStealStart = function()
        local A = _G.K7NormalSteal
        A.radius  = StealRadii.Normal
        A.duration = 1.3
        A.enabled  = true
        _normalEnsureScanner()
        pcall(_normalScanPlots)
        if A.stealConn then A.stealConn:Disconnect(); A.stealConn=nil end
        A.stealConn = RunService.Heartbeat:Connect(function()
            if not A.enabled then return end
            if selectedStealMode~="Normal" then _G.K7NormalAutoStealStop(); return end
            if A.isStealing then return end
            local target = _normalNearestAnimal()
            if not target then return end
            local prompt = _normalFindPrompt(target)
            if prompt then _normalDoSteal(prompt, target) end
        end)
    end

    _G.K7NormalAutoStealSync = function()
        if selectedStealMode=="Normal" and Steal.AutoStealEnabled then
            _G.K7NormalAutoStealStart()
        else
            _G.K7NormalAutoStealStop()
        end
    end

    -- ================================================================
    -- SEMI STEAL SYSTEM (sync-based, tight proximity, waits for range)
    -- ================================================================
    _G.K7SemiSteal = _G.K7SemiSteal or {}
    local AS = _G.K7SemiSteal
    AS.conn         = AS.conn
    AS.scanThread   = AS.scanThread
    AS.enabled      = false
    AS.holdMin      = 1.3
    AS.holdMax      = 2.6
    AS.entryDelay   = 0.3
    AS.cooldown     = 0.05
    AS.primeRange   = 80
    AS.radius       = StealRadii.Semi
    AS.plotSync     = AS.plotSync or {caches={}, connections={}}
    AS.animals      = AS.animals or {}
    AS.promptCache  = AS.promptCache or {}
    AS.internalCache = AS.internalCache or {}
    AS.state        = AS.state or {active=false, startTime=0, phase="idle", label="", lastResult="", lastResultTime=0}

    local function _semiBarSet(p, label)
        pcall(function()
            if _G.StealBar then
                _G.StealBar.SetState(label or "STEALING")
                _G.StealBar.SetProgress(math.clamp(tonumber(p) or 0, 0, 1))
            end
        end)
    end
    local function _semiBarReset()
        pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
    end

    local function _semiRoot()
        local c = LP.Character
        return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")) or nil
    end

    -- path diff helpers
    local function _splitPath(path)
        if typeof(path)=="table" then return path end
        local out = {}
        for p in string.gmatch(tostring(path), "[^%.]+") do
            table.insert(out, tonumber(p) or p)
        end
        return out
    end
    local function _resolvePath(path, root)
        local cur, par, key = root, nil, nil
        for _, p in ipairs(_splitPath(path)) do par=cur; key=p; cur=cur and cur[p] or nil end
        return cur, par, key
    end
    local function _applyDiff(channelName, packet)
        local cache = AS.plotSync.caches[channelName]
        if typeof(cache)~="table" then return end
        local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
        local cur, par, key = _resolvePath(path, cache)
        if action=="Changed" then if par then par[key]=a end
        elseif action=="ArrayInsert" then if cur then table.insert(cur, b, a) end
        elseif action=="ArrayRemoved" then if cur then table.remove(cur, b) end
        elseif action=="DictionaryInsert" then if cur then cur[b]=a end
        elseif action=="DictionaryRemoved" then if cur then cur[b]=nil end
        end
    end

    local function _semiAttachChannel(remote, plots, requestData)
        if AS.plotSync.connections[remote] then return end
        local channelName = tostring(remote.Name)
        if not plots:FindFirstChild(channelName) then return end
        if requestData and AS.plotSync.caches[channelName]==nil then
            local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
            AS.plotSync.caches[channelName] = (ok and typeof(data)=="table") and data or {}
        elseif AS.plotSync.caches[channelName]==nil then
            AS.plotSync.caches[channelName] = {}
        end
        AS.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
            for _, packet in ipairs(queue) do _applyDiff(channelName, packet) end
        end)
    end

    local function _semiEnsureSync()
        if AS.syncReady then return true end
        local ok = pcall(function()
            AS.plots = workspace:WaitForChild("Plots", 10)
            local rs = game:GetService("ReplicatedStorage")
            local pkgs = rs:WaitForChild("Packages", 10)
            local datas = rs:WaitForChild("Datas", 10)
            if not (pkgs and datas and AS.plots) then return end
            AS.animalsData = require(datas:WaitForChild("Animals", 10))
            local sync = pkgs:WaitForChild("Synchronizer", 10)
            AS.channelFolder = sync:WaitForChild("Channel", 10)
            AS.routeRemote   = sync:WaitForChild("CommunicationRoute", 10)
            AS.requestData   = sync:FindFirstChild("RequestData")
            for _, child in ipairs(AS.channelFolder:GetChildren()) do
                if child:IsA("RemoteEvent") then _semiAttachChannel(child, AS.plots, AS.requestData) end
            end
            AS.channelFolder.ChildAdded:Connect(function(child)
                if child:IsA("RemoteEvent") then _semiAttachChannel(child, AS.plots, AS.requestData) end
            end)
            AS.routeRemote.OnClientEvent:Connect(function(actions)
                for _, action in ipairs(actions) do
                    local kind, cn = action[1], tostring(action[2])
                    if AS.plots and AS.plots:FindFirstChild(cn) then
                        if kind=="ListenerAdded" then
                            local r = AS.channelFolder and AS.channelFolder:FindFirstChild(cn)
                            if r and r:IsA("RemoteEvent") then _semiAttachChannel(r, AS.plots, AS.requestData) end
                        elseif kind=="ListenerRemoved" then
                            for remote, conn in pairs(AS.plotSync.connections) do
                                if tostring(remote.Name)==cn then
                                    pcall(function() conn:Disconnect() end)
                                    AS.plotSync.connections[remote] = nil
                                    AS.plotSync.caches[cn] = nil
                                    break
                                end
                            end
                        end
                    end
                end
            end)
            AS.syncReady = true
        end)
        return ok and AS.syncReady==true
    end

    local function _semiPlotOwner(plot)
        local sign  = plot and plot:FindFirstChild("PlotSign")
        local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
        local label = frame and frame:FindFirstChild("TextLabel")
        if not label or label.Text=="Empty Base" then return nil end
        return label.Text:gsub("'s [Bb]ase$",""):gsub("%s+$","")
    end
    local function _semiIsMyBase(animalData)
        if not animalData or not animalData.plot or not AS.plots then return false end
        local plot = AS.plots:FindFirstChild(animalData.plot)
        if not plot then return false end
        local owner = _semiPlotOwner(plot)
        return owner==LP.DisplayName or owner==LP.Name
    end
    local function _semiPodiumFor(animalData)
        local plot = AS.plots and AS.plots:FindFirstChild(animalData.plot)
        local pds  = plot and plot:FindFirstChild("AnimalPodiums")
        return pds and pds:FindFirstChild(animalData.slot) or nil
    end
    local function _semiAnimalPos(animalData)
        local pod = _semiPodiumFor(animalData)
        return pod and pod:GetPivot().Position or nil
    end
    local function _semiDistToAnimal(animalData)
        local root = _semiRoot()
        local pos  = _semiAnimalPos(animalData)
        return root and pos and (root.Position-pos).Magnitude or math.huge
    end
    local function _semiFindPrompt(animalData)
        if not animalData then return nil end
        local cached = AS.promptCache[animalData.uid]
        if cached and cached.Parent then return cached end
        local pod    = _semiPodiumFor(animalData)
        local base   = pod and pod:FindFirstChild("Base")
        local spawn  = base and base:FindFirstChild("Spawn")
        local attach = spawn and spawn:FindFirstChild("PromptAttachment")
        if not attach then return nil end
        for _, p in ipairs(attach:GetChildren()) do
            if p:IsA("ProximityPrompt") then AS.promptCache[animalData.uid]=p; return p end
        end
        return nil
    end
    local function _semiBuildCallbacks(prompt)
        if AS.internalCache[prompt] then return end
        local data = {holdCallbacks={}, triggerCallbacks={}, ready=true}
        local okH, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if okH and type(holds)=="table" then
            for _, c in ipairs(holds) do if type(c.Function)=="function" then table.insert(data.holdCallbacks, c.Function) end end
        end
        local okT, triggers = pcall(getconnections, prompt.Triggered)
        if okT and type(triggers)=="table" then
            for _, c in ipairs(triggers) do if type(c.Function)=="function" then table.insert(data.triggerCallbacks, c.Function) end end
        end
        if #data.holdCallbacks>0 or #data.triggerCallbacks>0 then AS.internalCache[prompt]=data end
    end
    local function _semiExecute(prompt, animalData)
        if not prompt or not prompt.Parent or not animalData then return false end
        if AS.state.active then return false end
        if tick()-(AS.state.lastResultTime or 0) < (AS.cooldown or 0.05) then return false end
        _semiBuildCallbacks(prompt)
        local data = AS.internalCache[prompt]
        if not data or not data.ready then return false end
        data.ready=false; AS.state.active=true
        AS.state.startTime=tick(); AS.state.phase="holding"
        AS.state.label = animalData.name or "Animal"
        task.spawn(function()
            local t0 = AS.state.startTime
            for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end
            while AS.enabled and selectedStealMode=="Semi" and tick()-t0 < (AS.holdMin or 1.3) do
                _semiBarSet((tick()-t0)/(AS.holdMax or 2.6), "STEALING")
                task.wait()
            end
            AS.state.phase = "waitingRange"
            local alreadyInRange = _semiDistToAnimal(animalData) <= (tonumber(AS.radius) or 10)
            local fired = false
            while AS.enabled and selectedStealMode=="Semi" and prompt.Parent do
                local elapsed = tick()-t0
                if elapsed > (AS.holdMax or 2.6) then break end
                _semiBarSet(elapsed/(AS.holdMax or 2.6), "STEALING")
                if _semiDistToAnimal(animalData) <= (tonumber(AS.radius) or 10) then
                    if not alreadyInRange then task.wait(AS.entryDelay or 0.3) end
                    if AS.enabled and selectedStealMode=="Semi" then
                        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
                        fired = true
                    end
                    break
                end
                task.wait()
            end
            AS.state.lastResult = fired and ("Stole "..tostring(AS.state.label)) or ("Missed: "..tostring(AS.state.label))
            AS.state.active=false; AS.state.phase="idle"; AS.state.lastResultTime=tick()
            if fired then _semiBarSet(1, "STEALING") end
            task.wait(AS.cooldown or 0.05)
            data.ready=true
            _semiBarReset()
        end)
        return true
    end
    local function _semiScanAllPlots()
        if not _semiEnsureSync() then return 0 end
        local newCache = {}
        for _, plot in ipairs(AS.plots:GetChildren()) do
            local cache = AS.plotSync.caches[plot.Name]
            local animalList = cache and cache.AnimalList
            if typeof(animalList)=="table" then
                for slot, animalData in pairs(animalList) do
                    if type(animalData)=="table" then
                        local animalName = animalData.Index
                        local info = AS.animalsData and AS.animalsData[animalName]
                        if info then
                            table.insert(newCache, {
                                name = info.DisplayName or animalName,
                                plot = plot.Name,
                                slot = tostring(slot),
                                uid  = plot.Name.."_"..tostring(slot),
                            })
                        end
                    end
                end
            end
        end
        AS.animals = newCache
        return #newCache
    end
    local function _semiPickClosest()
        local root = _semiRoot()
        if not root then return nil end
        local best, bestDist = nil, math.huge
        for _, data in ipairs(AS.animals) do
            if not _semiIsMyBase(data) then
                local pos  = _semiAnimalPos(data)
                local dist = pos and (root.Position-pos).Magnitude or math.huge
                if dist <= (AS.primeRange or 80) and dist < bestDist then
                    best, bestDist = data, dist
                end
            end
        end
        return best
    end
    local function _semiEnsureScanThread()
        if AS.scanThread then return end
        AS.scanThread = task.spawn(function()
            while _G.K7SemiSteal do
                if AS.enabled or selectedStealMode=="Semi" then pcall(_semiScanAllPlots) end
                task.wait(5)
            end
        end)
    end

    _G.K7SemiAutoStealStop = function()
        AS.enabled = false
        if AS.conn then AS.conn:Disconnect(); AS.conn=nil end
        AS.state.active=false; AS.state.phase="idle"
        _semiBarReset()
    end

    _G.K7SemiAutoStealStart = function()
        AS.radius  = StealRadii.Semi
        AS.enabled = true
        pcall(_semiEnsureSync)
        _semiEnsureScanThread()
        pcall(_semiScanAllPlots)
        if AS.conn then AS.conn:Disconnect(); AS.conn=nil end
        AS.conn = RunService.Heartbeat:Connect(function()
            if not AS.enabled then return end
            if selectedStealMode~="Semi" then _G.K7SemiAutoStealStop(); return end
            if AS.state.active then return end
            local target = _semiPickClosest()
            if not target then return end
            local prompt = _semiFindPrompt(target)
            if prompt then _semiExecute(prompt, target) end
        end)
    end

    _G.K7SemiAutoStealSync = function()
        if selectedStealMode=="Semi" and Steal.AutoStealEnabled then
            _G.K7SemiAutoStealStart()
        else
            _G.K7SemiAutoStealStop()
        end
    end

    -- ================================================================
    -- MASTER SYNC
    -- ================================================================
    local function autoStealSync()
        if not Steal.AutoStealEnabled then
            if _G.K7NormalAutoStealStop then _G.K7NormalAutoStealStop() end
            if _G.K7SemiAutoStealStop   then _G.K7SemiAutoStealStop()   end
            return
        end
        if selectedStealMode=="Normal" then
            if _G.K7SemiAutoStealStop   then _G.K7SemiAutoStealStop()   end
            if _G.K7NormalAutoStealSync then _G.K7NormalAutoStealSync() end
        elseif selectedStealMode=="Semi" then
            if _G.K7NormalAutoStealStop then _G.K7NormalAutoStealStop() end
            if _G.K7SemiAutoStealSync   then _G.K7SemiAutoStealSync()   end
        end
    end

    -- ================================================================
    -- MODULE RETURN
    -- ================================================================
    createAutoGrabUI()

    -- Start hidden — intro (or finishIntro) will pop it in
    if _barGui then _barGui.Enabled = false end
    if _barFrame then _barFrame.Visible = false end

    -- ================================================================
    -- SOFT STEAL (Auto Switch Carry Speed)
    -- ================================================================
    local softStealAnimals = {}
    local softStealScannerConn = nil
    local softStealScanning = false

    local function softStealScanPlots()
        softStealAnimals = {}
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then
                local podiums = plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, podium in ipairs(podiums:GetChildren()) do
                        if podium:IsA("Model") then
                            local base = podium:FindFirstChild("Base")
                            local spawn = base and base:FindFirstChild("Spawn")
                            if spawn then
                                table.insert(softStealAnimals, {
                                    plot = plot.Name,
                                    slot = podium.Name,
                                    worldPosition = spawn.Position,
                                    uid = plot.Name.."_"..podium.Name,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    local function startSoftStealScanner()
        if softStealScannerConn then return end
        softStealScanning = true
        pcall(softStealScanPlots)
        softStealScannerConn = RunService.Heartbeat:Connect(function()
            if not softStealScanning then return end
            pcall(softStealScanPlots)
        end)
    end

    local function stopSoftStealScanner()
        softStealScanning = false
        if softStealScannerConn then
            softStealScannerConn:Disconnect()
            softStealScannerConn = nil
        end
    end

    local function getNearestSoftStealAnimal(radius)
        local root = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character:FindFirstChild("UpperTorso"))
        if not root then return nil, math.huge end
        local best, bestDist = nil, math.huge
        for _, data in ipairs(softStealAnimals) do
            if data.worldPosition then
                local dist = (root.Position - data.worldPosition).Magnitude
                if dist < bestDist then
                    best = data
                    bestDist = dist
                end
            end
        end
        if radius and bestDist > radius then
            return nil, bestDist
        end
        return best, bestDist
    end

    local module = {
        start = function()
            Steal.AutoStealEnabled = true
            autoStealSync()
        end,
        stop = function()
            Steal.AutoStealEnabled = false
            autoStealSync()
        end,
        setEnabled = function(enabled)
            Steal.AutoStealEnabled = enabled
            autoStealSync()
        end,
        setRadius = function(radius)
            local r = tonumber(radius)
            if r then
                r = math.clamp(r, 1, 200)
                StealRadii[selectedStealMode] = r
                if selectedStealMode=="Normal" then
                    _G.K7NormalSteal.radius = r
                else
                    AS.radius = r
                end
            end
        end,
        setMode = function(mode)
            -- aliases from Zombie Hub naming
            if mode == "v3" or mode == "V3" or mode == "Galaxy" then mode = "Normal" end
            if mode == "v2" or mode == "V2" then mode = "Semi" end
            if mode ~= "Normal" and mode ~= "Semi" then mode = "Normal" end
            selectedStealMode = mode
            if _G._K7StealModeChip then
                _G._K7StealModeChip.Text = (mode == "Semi") and "SEMI" or "NORMAL"
            end
            StealRadii[mode] = StealRadii[mode] or (mode == "Semi" and 10 or 63)
            autoStealSync()
        end,
        getMode = function() return selectedStealMode end,
        getRadii = function() return StealRadii end,
        getScale = function() return _barScale end,
        setScale = function(s)
            s = tonumber(s) or 1
            _barScale = math.clamp(s, 0.6, 1.6)
            if _barUI then _barUI.Scale = _barScale * _barFitScale end
        end,
        setBackground = function(imageId)
            currentBgImage = imageId
            local baseScheme = COLOR_SCHEMES[imageId] or COLOR_SCHEMES["rbxassetid://102557909116203"]
            local scheme = get7UpThemeScheme(baseScheme, _G._K7ThemeMode)
            currentColorScheme = scheme
            if _barBgImg then
                _barBgImg.Image = imageId
                _barBgImg.ImageTransparency = 0.08
                _barBgImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
                _barBgImg.Visible = true
            end
            updateAutoGrabLineColor(scheme)
        end,
        updateColors = function(scheme)
            currentColorScheme = scheme
            updateAutoGrabLineColor(scheme)
        end,
        isEnabled = function() return Steal.AutoStealEnabled end,
        getMode   = function() return selectedStealMode end,
        getSteal  = function() return Steal end,
        updateUI  = function() end,
        updateAutoGrabLineColor = updateAutoGrabLineColor,
        hideUI = function()
            if _barGui then _barGui.Enabled = false end
            if _barFrame then _barFrame.Visible = false end
        end,
        showUI = function(animate)
            if _barGui then _barGui.Enabled = true end
            if not _barFrame then return end
            if animate then
                local finalSize = UDim2.new(0, 580, 0, 70)
                local finalPos  = UDim2.new(0.5, 0, 0.92, 0)
                _barFrame.Size = UDim2.new(0, 0, 0, 0)
                _barFrame.Position = UDim2.new(0.5, 0, 0.92, 21)
                _barFrame.Visible = true
                pcall(function()
                    TweenService:Create(_barFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = finalSize, Position = finalPos
                    }):Play()
                end)
            else
                _barFrame.Visible = true
            end
        end,
        -- Soft Steal exports
        startSoftStealScanner = startSoftStealScanner,
        stopSoftStealScanner  = stopSoftStealScanner,
        getNearestSoftStealAnimal = getNearestSoftStealAnimal,
    }
    return module
end)()

-- ============================================================
-- ESP & SKY GLOBALS
-- ============================================================
local PlayerESP = { enabled = false, conns = {}, playerData = {} }
local BoxedESPOptions = { box = false }
local BoxedESPData   = {}
local BoxedESPConn   = nil
local SKY_PRESETS_LIST = nil
local SKY_PRESETS      = nil
local skyTheme         = "Off"

-- ============================================================
-- STEAL DATA
-- ============================================================
local Steal = {
    StealRadius = 63,  -- V3 ~80% style radius from Zombie
    AutoStealEnabled = true,
}
-- v3 style: aggressive radius default
if State and State.autoStealMode == "v3" then
    Steal.StealRadius = 75
end

if autoGrabModule then
    autoGrabModule.setRadius(Steal.StealRadius)
    autoGrabModule.setEnabled(Steal.AutoStealEnabled)
end

-- ============================================================
-- CONFIG SAVING VARIABLES
-- ============================================================
local CONFIG_VERSION = 5
local CONFIG_FILE = "SevenUpDuels_Green_Config.json"
local CONFIG_BACKUP = "SevenUpDuels_Green_Config.bak"
local CONFIG_EXPORT_FILE = "SevenUpDuels_Export.json"
local CONFIG_IMPORT_FILE = "SevenUpDuels_Import.json"

local function forceLoadConfig()
    local raw = nil
    if _isfile(CONFIG_FILE) then 
        raw = _readfile(CONFIG_FILE) 
    end
    if not raw or raw == "" then
        if _isfile(CONFIG_BACKUP) then
            raw = _readfile(CONFIG_BACKUP)
        end
    end
    if raw and raw ~= "" then
        local ok, dec = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and dec then
            return dec
        end
    end
    return nil
end

local function saveConfigWithRetry(cfg, attempts)
    attempts = attempts or 3
    for i = 1, attempts do
        local success = false
        pcall(function()
            local encoded = HttpService:JSONEncode(cfg)
            _writefile(CONFIG_FILE, encoded)
            local verify = _readfile(CONFIG_FILE)
            if verify == encoded then
                pcall(function() _writefile(CONFIG_BACKUP, encoded) end)
                success = true
            end
        end)
        if success then return true end
        task.wait(0.1)
    end
    return false
end

-- ============================================================
-- INFINITE JUMP (HOLD MODE)
-- ============================================================
UIS.JumpRequest:Connect(function()
    if not State.infJumpEnabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
    end
end)

-- ============================================================
-- STATE
-- ============================================================
local State = {
    normalSpeed=60, carrySpeed=30, laggerSpeed=10.1, laggerCarrySpeed=15,
    speedToggled=false,
    laggerMode=0,
    infJumpEnabled=true, antiRagdollEnabled=false,
    antiRagdollVersion="V1",
    guiVisible=true, uiLocked=false,
    isStealing=false,
    medusaLastUsed=0, medusaDebounce=false, medusaCounterEnabled=false,
    batAimbotToggled=false, autoSwingEnabled=false,
    hittingCooldown=false,
    batCounterEnabled=false, batCounterDebounce=false,
    dropEnabled=false, _tpInProgress=false,
    _dropInProgress=false, _dropSuppressGrabUntil=0, _dropProtectUntil=0,
    lastMoveDir=Vector3.new(0,0,0),
    _prevCarry=30, _prevSpeed=false,
    stackButtonsHidden=false,
    stackButtonsLocked=false,
    mobileButtonShape="Can",
    nukeOpt=false,
    removeAcc=false,
    antiLagEnabled=false,
    saturatedColorsEnabled=false,
    stretchedResEnabled=false,
    tryardAnimEnabled=false,
    introEnabled=true,
    autoTPEnabled=false,
    autoTPHeight=20,
    autoTPConn=nil,
    _autoTPPauseToken=0,

    stretchValue = 0.7,
    stretchFOV = 120,
    autoLeftEnabled = false,
    autoRightEnabled = false,
    autoMoveSpeed = 60,
    espTracer = false,
    espTracerWanted = false,
    batAimbotZombie = false, -- zombie-style bat aimbot
    autoStealMode = "v3", -- Normal | Semi | v3
    aimbotMode = "old", -- old | new (which aimbot the AIMBOT key/stack button drives)

    bgImage = "rbxassetid://102557909116203",
    espEnabled = false,
    skyTheme = "Off",
    antiDieEnabled = false,
    antiFlingShieldEnabled = false,
    headlessEnabled = false,
    korbloxEnabled = false,
    customSkinEnabled = false,
    customSkinVariant = 1,
    uiColorTheme = "Green",
    outfit1Applied = false,
    outfit2Applied = false,
    outfit3Applied = false,
    -- Soft Steal
    softStealEnabled = false,
    softStealRadius = 10,
    softStealSpeed = 30,
    softStealLatched = false,
    _speedEditRevision = 0,
    _initialConfigSettled = false,
}

local function markSpeedEdited()
    State._speedEditRevision = (State._speedEditRevision or 0) + 1
end

local _early7upConfig = forceLoadConfig()
if _early7upConfig then
    if _early7upConfig.uiColorTheme == "Red" then
        State.uiColorTheme = "Red"
        State.bgImage = RED_7UP_BACKGROUND
        currentBgImage = RED_7UP_BACKGROUND
        _G._K7ThemeMode = "Red"
        _G._K7AccentColor = Color3.fromRGB(220, 32, 46)
        currentColorScheme = get7UpThemeScheme(
            COLOR_SCHEMES[State.bgImage] or COLOR_SCHEMES["rbxassetid://102557909116203"],
            "Red"
        )
    end
    local earlyVariant = tonumber(_early7upConfig.customSkinVariant)
    if earlyVariant == 1 or earlyVariant == 2 then State.customSkinVariant = earlyVariant end
    if _early7upConfig.espTracer ~= nil then
        State.espTracer = _early7upConfig.espTracer == true
    elseif _early7upConfig.tracerESP ~= nil then
        State.espTracer = _early7upConfig.tracerESP == true
    end
    State.espTracerWanted = State.espTracer
end

task.spawn(function()
    while task.wait(0.2) do
        if _G._K7SetCarryStatus then
            local textValue, isOn = "CARRY OFF", false
            if State.laggerMode == 2 then
                textValue, isOn = "LAG CARRY", true
            elseif State.speedToggled then
                textValue, isOn = "CARRY ON", true
            elseif State.softStealLatched then
                textValue, isOn = "AUTO CARRY", true
            end
            pcall(_G._K7SetCarryStatus, textValue, isOn)
        end
    end
end)


local Keys = {
    speed=Enum.KeyCode.Q, guiHide=Enum.KeyCode.LeftControl,
    lagger=Enum.KeyCode.R,
    tpDown=Enum.KeyCode.F,
    drop=Enum.KeyCode.X, aimbot=Enum.KeyCode.E,
    autoLeft=Enum.KeyCode.L, autoRight=Enum.KeyCode.R,
    antiDesync=Enum.KeyCode.V,
}

-- ============================================================
-- SAFE MODE (unchanged)
-- ============================================================
local antiKickEnabled = false

function _G.AceSafeModeGetCountdownLabel()
    local ok, label = pcall(function()
        return LP.PlayerGui
            and LP.PlayerGui:FindFirstChild("DuelsMachineTopFrame")
            and LP.PlayerGui.DuelsMachineTopFrame:FindFirstChild("DuelsMachineTopFrame")
            and LP.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame:FindFirstChild("Timer")
            and LP.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer:FindFirstChild("Label")
    end)
    return (ok and label) or nil
end
function _G.AceSafeModeCountdownNumber(text)
    local t = tostring(text or ""):upper():gsub("^%s+",""):gsub("%s+$","")
    if t=="GO" or t=="START" or t=="READY" then return true end
    local n = tonumber(t)
    return n ~= nil and n >= 0 and n <= 10
end
function _G.AceSafeModeInDuelCountdown()
    local label = _G.AceSafeModeGetCountdownLabel()
    return label and _G.AceSafeModeCountdownNumber(label.Text) or false
end
function _G.AceCooldownActive()
    if _G.AceSafeModeInDuelCountdown and _G.AceSafeModeInDuelCountdown() then return true end
    return false
end
_G.AceSafeModeBlockedTools = {
    bat=true,slap=true,sword=true,gun=true,pistol=true,rifle=true,
    medusa=true,hammer=true,axe=true,knife=true,katana=true,blade=true,fist=true,
}
function _G.AceSafeModeIsCarryableTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local name = tool.Name:lower()
    for word in pairs(_G.AceSafeModeBlockedTools) do
        if name:find(word,1,true) then return false end
    end
    return true
end
function _G.AceSafeModeHoldingBrainrot()
    local okA, vA = pcall(function() return LP:GetAttribute("Stealing") end)
    if okA and vA == true then return true end
    local okB, vB = pcall(function() return LP:GetAttribute("AntiKick") end)
    if okB and vB == true then return true end
    local char = LP.Character; if not char then return false end
    local okC, vC = pcall(function() return char:GetAttribute("Stealing") end)
    if okC and vC == true then return true end
    for _, name in ipairs({"Carrying","IsCarrying","Grabbed","Holding","StealHold","HasGrab"}) do
        local v = char:FindFirstChild(name, true)
        if v then
            if v:IsA("BoolValue") and v.Value then return true end
            if v:IsA("ObjectValue") and v.Value then return true end
            if v:IsA("StringValue") and v.Value ~= "" then return true end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart",true) then
            local n = child.Name:lower()
            if n:find("brainrot") or n:find("animal") or n:find("carry") or n:find("grab") or n:find("steal") or n:find("hold") then
                return true
            end
        end
    end
    return false
end
function _G.AceSafeModeIsLocked()
    if not antiKickEnabled then return false end
    if _G.AceSafeModeInDuelCountdown and _G.AceSafeModeInDuelCountdown() then return true end
    if _G.AceCooldownActive and _G.AceCooldownActive() then return true end
    if _G.AceSafeModeHoldingBrainrot and _G.AceSafeModeHoldingBrainrot() then return true end
    if State and State.softStealLatched then return true end
    if State and State.isStealing then return true end
    return false
end
function _G.AceSafeModeForceStop(reason)
    local stopped = false
    if _G.AceNormalAimbotOn and _G.AceStopNormalAimbot then _G.AceStopNormalAimbot(); stopped=true end
    if _G.AceAntiDesyncAimbotOn and _G.AceStopAntiDesyncAimbot then _G.AceStopAntiDesyncAimbot(); stopped=true end
    if State.batAimbotToggled then
        State.batAimbotToggled = false
        if stackBtnRefs and stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end
        stopped = true
    end
    -- Zombie bat aimbot
    if State.batAimbotZombie then
        pcall(function()
            if _G._7upStopZombieBatAimbot then _G._7upStopZombieBatAimbot()
            elseif stopZombieBatAimbot then stopZombieBatAimbot() end
        end)
        stopped = true
    end
    -- Auto Left / Auto Right
    if State.autoLeftEnabled then
        pcall(function()
            if _G._7upStopAutoLeft then _G._7upStopAutoLeft()
            elseif stopAutoLeft then stopAutoLeft() end
        end)
        stopped = true
    end
    if State.autoRightEnabled then
        pcall(function()
            if _G._7upStopAutoRight then _G._7upStopAutoRight()
            elseif stopAutoRight then stopAutoRight() end
        end)
        stopped = true
    end
    if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
    if stopped then
        pcall(function()
            local pg = LP:FindFirstChild("PlayerGui")
            local notifGui = pg and pg:FindFirstChild("SevenUpDuelsV2") and pg.SevenUpDuelsV2:FindFirstChild("Notif")
            if notifGui then
                local lbl = notifGui:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.Text = reason or "SAFE MODE LOCK"; task.delay(1.5, function() if lbl then lbl.Text="" end end) end
            end
        end)
    end
end
function _G.AceSafeModeTryStart()
    if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
        _G.AceSafeModeForceStop("SAFE MODE LOCK")
        return false
    end
    return true
end
_G.AceSafeModeMonitorStarted = _G.AceSafeModeMonitorStarted or false
if not _G.AceSafeModeMonitorStarted then
    _G.AceSafeModeMonitorStarted = true
    RunService.Heartbeat:Connect(function()
        if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            _G.AceSafeModeForceStop("SAFE MODE LOCK")
        end
    end)
end

-- ============================================================
-- INTRO MUSIC SYSTEM (unchanged)
-- ============================================================
local selectedIntroMusic = 1
_introEnabled = true

INTRO_MUSIC_OPTIONS = {
    {name="Blue Bands", url="https://files.catbox.moe/mzvrir.mp3", file="K7IntroSong_1.mp3"},
    {name="Legacy", url="https://files.catbox.moe/siru6c.mp3", file="K7IntroSong_2c.mp3"},
    {name="paznerknacker.wav", url="https://files.catbox.moe/izcvhm.mp3", file="K7IntroSong_3b.mp3"},
    {name="Tesla", url="https://files.catbox.moe/n85fch.mp3", file="K7IntroSong_4b.mp3"},
    {name="King Nasir", url="https://files.catbox.moe/etk99y.mp3", file="K7IntroSong_5b.mp3"},
    {name="Pure Cocaine", url="https://files.catbox.moe/dvjtjk.mp3", file="K7IntroSong_6.mp3"},
    {name="nuts", url="https://files.catbox.moe/iyw1cb.mp3", file="K7IntroSong_7.mp3"},
    {name="Gelato", url="https://files.catbox.moe/zf2z42.mp3", file="K7IntroSong_8.mp3"},
    {name="FREAKED OUT", url="https://files.catbox.moe/dyt2ja.mp3", file="K7IntroSong_9.mp3"},
    {name="Scam Likely", url="https://files.catbox.moe/pr85mz.mp3", file="K7IntroSong_10.mp3"},
    {name="NO INTRO MUSIC", silent=true},
}

local INTRO_SONG_FILE = "K7IntroSongIdx.txt"
local function saveIntroSongIdx()
    pcall(function()
        if _writefile then
            _writefile(INTRO_SONG_FILE, tostring(selectedIntroMusic or 1))
        end
    end)
end
local function loadIntroSongIdx()
    pcall(function()
        if not _isfile or not _readfile then return end
        if not _isfile(INTRO_SONG_FILE) then return end
        local raw = _readfile(INTRO_SONG_FILE)
        local n = tonumber(tostring(raw or ""):match("%d+"))
        if n and n >= 1 and n <= #INTRO_MUSIC_OPTIONS then
            selectedIntroMusic = n
            print("[7UP duels] Restored intro song idx:", n)
        end
    end)
end
loadIntroSongIdx()

introSongCache = introSongCache or {}
introSongDownloading = introSongDownloading or {}
introPlaybackSound = nil
introPlaybackToken = 0

function getIntroSongName()
    local opt = INTRO_MUSIC_OPTIONS[selectedIntroMusic]
    return opt and opt.name or "No Songs"
end

function stopIntroPlayback()
    introPlaybackToken = introPlaybackToken + 1
    if introPlaybackSound then
        pcall(function() introPlaybackSound:Stop() end)
        pcall(function() introPlaybackSound:Destroy() end)
        introPlaybackSound = nil
    end
end

function cacheIntroSong(option, allowDownload)
    if not option or not option.url or option.url == "" then return nil end
    local fileName = option.file or "K7IntroSong.mp3"
    introSongCache = introSongCache or {}
    introSongDownloading = introSongDownloading or {}

    local function loadExisting()
        if introSongCache[fileName] then return introSongCache[fileName] end
        local hasFile = false
        pcall(function()
            if isfile then hasFile = isfile(fileName) end
        end)
        if hasFile and getcustomasset then
            local ok, asset = pcall(function() return getcustomasset(fileName) end)
            if ok and asset then
                introSongCache[fileName] = asset
                return asset
            end
        end
        return nil
    end

    local cached = loadExisting()
    if cached then return cached end
    if allowDownload == false then return nil end
    if introSongDownloading[fileName] then
        local waitStart = tick()
        while introSongDownloading[fileName] and tick() - waitStart < 12 do task.wait(0.05) end
        return loadExisting()
    end

    introSongDownloading[fileName] = true
    local data = nil
    pcall(function()
        if game and game.HttpGet then
            data = game:HttpGet(option.url)
        end
    end)
    if (not data or #data == 0) then
        pcall(function()
            local req = (syn and syn.request) or http_request or request or (getgenv and (getgenv().request or getgenv().http_request)) or (http and http.request)
            if req then
                local res = req({Url = option.url, Method = "GET"})
                if res then data = res.Body or res.body end
            end
        end)
    end
    if data and #data > 0 and writefile then
        pcall(function()
            writefile(fileName, data)
            if getcustomasset then
                introSongCache[fileName] = getcustomasset(fileName)
            end
        end)
    end
    introSongDownloading[fileName] = nil
    local result = loadExisting()
    if not result then
        result = option.url
        introSongCache[fileName] = result
    end
    return result
end

function preloadIntroSongs()
    task.spawn(function()
        pcall(function()
            cacheIntroSong(INTRO_MUSIC_OPTIONS[selectedIntroMusic], true)
            for _, option in ipairs(INTRO_MUSIC_OPTIONS) do
                if option ~= INTRO_MUSIC_OPTIONS[selectedIntroMusic] then
                    cacheIntroSong(option, true)
                    task.wait(0.05)
                end
            end
        end)
    end)
end

function previewIntroSong()
    local option = INTRO_MUSIC_OPTIONS[selectedIntroMusic or 1]
    if not option then return end
    if option.silent then stopIntroPlayback(); return end
    local token = introPlaybackToken + 1
    introPlaybackToken = token
    if introPlaybackSound then
        pcall(function() introPlaybackSound:Stop() end)
        pcall(function() introPlaybackSound:Destroy() end)
        introPlaybackSound = nil
    end
    task.spawn(function()
        local soundId = cacheIntroSong(option, true)
        if token ~= introPlaybackToken then return end
        if not soundId then
            warn("[7UP duels] Preview failed to load:", option.name or "?")
            return
        end
        local sound = Instance.new("Sound")
        sound.Name = "K7IntroPreview"
        sound.Volume = 0.5
        sound.Looped = false
        sound.SoundId = soundId
        sound.Parent = SoundService
        if token ~= introPlaybackToken then
            pcall(function() sound:Destroy() end)
            return
        end
        introPlaybackSound = sound
        sound.TimePosition = 0
        local loadStart = tick()
        while sound and sound.Parent and not sound.IsLoaded and tick() - loadStart < 8 do
            task.wait(0.05)
        end
        if token ~= introPlaybackToken then
            pcall(function() sound:Destroy() end)
            return
        end
        pcall(function() sound:Play() end)
        task.delay(4, function()
            if token == introPlaybackToken then
                pcall(function() sound:Stop() end)
                pcall(function() sound:Destroy() end)
                if introPlaybackSound == sound then introPlaybackSound = nil end
            end
        end)
    end)
end

function playIntroMusic()
    stopIntroPlayback()
    _introEnabled = true
    local option = INTRO_MUSIC_OPTIONS[selectedIntroMusic or 1]
    if not option then
        warn("[7UP duels] No intro song option")
        return
    end
    if option.silent then
        print("[7UP duels] Intro background music disabled")
        return
    end
    local token = introPlaybackToken
    task.spawn(function()
        print("[7UP duels] Loading intro song:", option.name or "?")
        local soundId = cacheIntroSong(option, true)
        if token ~= introPlaybackToken then return end
        if not soundId then
            warn("[7UP duels] Intro song failed to load (need writefile/getcustomasset/HttpGet)")
            return
        end
        local sound = Instance.new("Sound")
        sound.Name = "K7IntroMusic"
        sound.Volume = 0.7
        sound.Looped = false
        sound.SoundId = soundId
        sound.Parent = SoundService
        if token ~= introPlaybackToken then
            pcall(function() sound:Destroy() end)
            return
        end
        introPlaybackSound = sound
        sound.TimePosition = 0
        local loadStart = tick()
        while sound and sound.Parent and not sound.IsLoaded and tick() - loadStart < 12 do
            task.wait(0.05)
        end
        local ok, err = pcall(function() sound:Play() end)
        print("[7UP duels] Intro music play:", ok, err or "ok", "id=", tostring(soundId):sub(1,60))
        task.delay(24, function()
            if token == introPlaybackToken then stopIntroPlayback() end
        end)
    end)
end

-- ============================================================
-- MUSIC PLAYER (full tracks, volume, draggable UI)
-- ============================================================
local MusicPlayer = {
    sound = nil,
    playing = false,
    volume = 1.2,
    songIdx = 1,
    gui = nil,
    looped = true,
    scale = 1,
}

local function mpStop()
    MusicPlayer.playing = false
    if MusicPlayer.sound then
        pcall(function() MusicPlayer.sound:Stop() end)
        pcall(function() MusicPlayer.sound:Destroy() end)
        MusicPlayer.sound = nil
    end
end

local function mpPlay(idx)
    idx = idx or MusicPlayer.songIdx or selectedIntroMusic or 1
    if idx < 1 then idx = #INTRO_MUSIC_OPTIONS end
    if idx > #INTRO_MUSIC_OPTIONS then idx = 1 end
    MusicPlayer.songIdx = idx
    mpStop()
    local option = INTRO_MUSIC_OPTIONS[idx]
    if not option then return end
    if option.silent then MusicPlayer.playing=false; return end
    task.spawn(function()
        local soundId = cacheIntroSong(option, true)
        if not soundId then
            warn("[7UP duels] Music Player failed to load:", option.name)
            return
        end
        -- if user switched song while loading, abort
        if MusicPlayer.songIdx ~= idx then return end
        local sound = Instance.new("Sound")
        sound.Name = "SevenUpMusicPlayer"
        sound.Volume = math.clamp(MusicPlayer.volume, 0, 10)
        sound.Looped = MusicPlayer.looped
        sound.SoundId = soundId
        sound.Parent = SoundService
        MusicPlayer.sound = sound
        local loadStart = tick()
        while sound and sound.Parent and not sound.IsLoaded and tick() - loadStart < 15 do
            task.wait(0.05)
        end
        if MusicPlayer.sound ~= sound then
            pcall(function() sound:Destroy() end)
            return
        end
        MusicPlayer.playing = true
        pcall(function() sound:Play() end)
        sound.Ended:Connect(function()
            if not MusicPlayer.looped then
                MusicPlayer.playing = false
            end
        end)
    end)
end

local function mpSetVolume(v)
    MusicPlayer.volume = math.clamp(v, 0, 5)
    if MusicPlayer.sound then
        MusicPlayer.sound.Volume = MusicPlayer.volume
    end
end

local function mpCloseUI()
    if MusicPlayer.gui then
        pcall(function() MusicPlayer.gui:Destroy() end)
        MusicPlayer.gui = nil
    end
end

local function removeUILineDecorations(root)
    if not root then return end
    for _,obj in ipairs(root:GetDescendants()) do
        if obj:IsA("UIStroke") then
            obj.Enabled = false
            obj.Transparency = 1
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextStrokeTransparency = 1
        elseif obj:IsA("Frame") then
            local hiddenName = obj.Name == "CanRim" or obj.Name == "CanSideRail" or obj.Name == "CanPullTab"
                or obj.Name == "CanEndCap" or obj.Name == "AluminumRim" or obj.Name == "ScanHighlight"
            local sx,sy = obj.Size.X,obj.Size.Y
            local thinX = sx.Scale == 0 and sx.Offset > 0 and sx.Offset <= 3
            local thinY = sy.Scale == 0 and sy.Offset > 0 and sy.Offset <= 3
            if hiddenName or thinX or thinY then obj.Visible = false end
        end
    end
end
_G._K7RemoveUILines = removeUILineDecorations

function openMusicPlayerUI()
    if MusicPlayer.gui and MusicPlayer.gui.Parent then
        MusicPlayer.gui.Enabled = true
        if _G._K7RefreshMusicPlayerTheme then pcall(_G._K7RefreshMusicPlayerTheme) end
        return
    end
    mpCloseUI()
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
    if not pg then return end

    local scheme = currentColorScheme or {}
    local green = scheme.main or Color3.fromRGB(0, 204, 102)
    local greenSoft = scheme.mainLight or Color3.fromRGB(80, 255, 160)
    local bg = scheme.stackBg or scheme.rowBg or Color3.fromRGB(8, 20, 12)

    local gui = Instance.new("ScreenGui")
    gui.Name = "SevenUpMusicPlayer"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 60
    gui.Parent = pg
    MusicPlayer.gui = gui

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 380, 0, 294)
    main.Position = UDim2.new(0.5, -190, 0.22, 0)
    main.BackgroundColor3 = bg
    main.BackgroundTransparency = 0.08
    main.Active = true
    main.Draggable = true
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 34)
    local musicBg=Instance.new("ImageLabel",main)
    musicBg.Name="MusicBackground"
    musicBg.Size=UDim2.new(1,0,1,0); musicBg.Position=UDim2.new(0,0,0,0)
    musicBg.BackgroundTransparency=1; musicBg.BorderSizePixel=0
    musicBg.Image=currentBgImage; musicBg.ImageTransparency=0.08
    musicBg.ImageColor3=Color3.fromRGB(255,255,255)
    musicBg.ScaleType=Enum.ScaleType.Crop; musicBg.ZIndex=0
    Instance.new("UICorner",musicBg).CornerRadius=UDim.new(0,34)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = scheme.border or green
    stroke.Thickness = 2
    local mainGradient=Instance.new("UIGradient",main)
    mainGradient.Color=adaptiveCanColorSequence(scheme,false)
    mainGradient.Rotation=12
    local strokeGradient=Instance.new("UIGradient",stroke)
    strokeGradient.Color=ColorSequence.new(scheme.mainDark or green,scheme.mainLight or greenSoft)
    for _,rimY in ipairs({7,281}) do
        local canRim=Instance.new("Frame",main)
        canRim.Name="CanRim"
        canRim.Size=UDim2.new(1,-42,0,6); canRim.Position=UDim2.new(0,21,0,rimY)
        canRim.BackgroundColor3=Color3.fromRGB(146,160,150); canRim.BackgroundTransparency=0
        canRim.BorderSizePixel=0; canRim.ZIndex=3; Instance.new("UICorner",canRim).CornerRadius=UDim.new(1,0)
        local rimGrad=Instance.new("UIGradient",canRim); rimGrad.Color=ColorSequence.new(Color3.fromRGB(68,84,73),Color3.fromRGB(172,184,175))
        canRim.Visible=false
    end
    for _,sideX in ipairs({7,367}) do
        local rail=Instance.new("Frame",main)
        rail.Size=UDim2.new(0,6,1,-42); rail.Position=UDim2.new(0,sideX,0,21)
        rail.BackgroundColor3=Color3.fromRGB(225,240,230); rail.BackgroundTransparency=0.58
        rail.BorderSizePixel=0; rail.ZIndex=2; Instance.new("UICorner",rail).CornerRadius=UDim.new(1,0)
        rail.Visible=false
    end
    for _,bubbleData in ipairs({{26,46,6},{344,82,9},{30,254,8},{354,238,5}}) do
        local bubble=Instance.new("Frame",main)
        bubble.Size=UDim2.new(0,bubbleData[3],0,bubbleData[3]); bubble.Position=UDim2.new(0,bubbleData[1],0,bubbleData[2])
        bubble.BackgroundColor3=Color3.fromRGB(235,255,242); bubble.BackgroundTransparency=0.45
        bubble.BorderSizePixel=0; bubble.ZIndex=2; Instance.new("UICorner",bubble).CornerRadius=UDim.new(1,0)
    end

    local mainScale=Instance.new("UIScale",main)
    local viewportWidth=(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X) or 800
    local musicUIScale=math.min(1,math.max(0.72,(viewportWidth-20)/380))
    mainScale.Scale=musicUIScale*0.88
    main.BackgroundTransparency=1
    TweenService:Create(mainScale,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=math.clamp(musicUIScale*(MusicPlayer.scale or 1),0.5,1.4)}):Play()
    TweenService:Create(main,TweenInfo.new(0.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0.08}):Play()

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, -180, 0, 34)
    title.Position = UDim2.new(0, 54, 0, 7)
    title.BackgroundTransparency = 1
    title.Text = "7UP // JUKEBOX"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = scheme.mainLight or greenSoft
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = scheme.mainDark or green
    closeBtn.Text = "X"
    closeBtn.TextColor3 = scheme.buttonText or scheme.text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.BorderSizePixel = 0
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseButton1Click:Connect(function()
        mpCloseUI()
    end)

    local shrinkBtn = Instance.new("TextButton", main)
    shrinkBtn.Size = UDim2.new(0, 30, 0, 30)
    shrinkBtn.Position = UDim2.new(1, -108, 0, 8)
    shrinkBtn.BackgroundColor3 = scheme.modeBtnBg or bg
    shrinkBtn.Text = "-"
    shrinkBtn.TextColor3 = scheme.mainLight or greenSoft
    shrinkBtn.Font = Enum.Font.GothamBold
    shrinkBtn.TextSize = 14
    shrinkBtn.BorderSizePixel = 0
    Instance.new("UICorner", shrinkBtn).CornerRadius = UDim.new(1, 0)

    local growBtn = Instance.new("TextButton", main)
    growBtn.Size = UDim2.new(0, 30, 0, 30)
    growBtn.Position = UDim2.new(1, -74, 0, 8)
    growBtn.BackgroundColor3 = scheme.modeBtnBg or bg
    growBtn.Text = "+"
    growBtn.TextColor3 = scheme.mainLight or greenSoft
    growBtn.Font = Enum.Font.GothamBold
    growBtn.TextSize = 14
    growBtn.BorderSizePixel = 0
    Instance.new("UICorner", growBtn).CornerRadius = UDim.new(1, 0)

    local function applyMusicScale(animate)
        local target = math.clamp(musicUIScale * (MusicPlayer.scale or 1), 0.5, 1.4)
        if animate then
            TweenService:Create(mainScale,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=target}):Play()
        else
            mainScale.Scale = target
        end
    end
    shrinkBtn.MouseButton1Click:Connect(function()
        MusicPlayer.scale = math.max(0.5, (MusicPlayer.scale or 1) - 0.1)
        applyMusicScale(true)
        if _G._K7RequestSave then pcall(_G._K7RequestSave) end
    end)
    growBtn.MouseButton1Click:Connect(function()
        MusicPlayer.scale = math.min(1.4, (MusicPlayer.scale or 1) + 0.1)
        applyMusicScale(true)
        if _G._K7RequestSave then pcall(_G._K7RequestSave) end
    end)

    local libraryBtn=Instance.new("TextButton",main)
    libraryBtn.Name="LibraryButton"
    libraryBtn.Size=UDim2.new(0,30,0,30); libraryBtn.Position=UDim2.new(0,12,0,8)
    libraryBtn.BackgroundColor3=scheme.main; libraryBtn.BackgroundTransparency=0.04
    libraryBtn.BorderSizePixel=0; libraryBtn.Text="♫"; libraryBtn.TextColor3=scheme.buttonText or scheme.text; libraryBtn.Font=Enum.Font.GothamBlack; libraryBtn.TextSize=15; libraryBtn.ZIndex=8
    Instance.new("UICorner",libraryBtn).CornerRadius=UDim.new(1,0)
    local libraryStroke=Instance.new("UIStroke",libraryBtn); libraryStroke.Color=green; libraryStroke.Transparency=0.35
    for lineIndex=0,3 do
        local libraryLine=Instance.new("Frame",libraryBtn)
        libraryLine.Size=UDim2.new(0,16-lineIndex%2*3,0,2)
        libraryLine.Position=UDim2.new(0,7,0,6+lineIndex*5)
        libraryLine.BackgroundColor3=scheme.mainLight or greenSoft; libraryLine.BorderSizePixel=0; libraryLine.ZIndex=9
        Instance.new("UICorner",libraryLine).CornerRadius=UDim.new(1,0)
        libraryLine.Visible=false
    end

    local songCard=Instance.new("Frame",main)
    songCard.Size=UDim2.new(1,-32,0,86); songCard.Position=UDim2.new(0,16,0,50)
    songCard.BackgroundColor3=scheme.rowBg; songCard.BackgroundTransparency=0.1; songCard.BorderSizePixel=0
    Instance.new("UICorner",songCard).CornerRadius=UDim.new(0,20)
    local songStroke=Instance.new("UIStroke",songCard); songStroke.Color=scheme.mainLight or greenSoft; songStroke.Transparency=0.22; songStroke.Thickness=1.5
    local songCardGradient=Instance.new("UIGradient",songCard)
    songCardGradient.Color=adaptiveCanColorSequence(scheme,true)
    local visualizer=Instance.new("Frame",songCard)
    visualizer.Size=UDim2.new(1,-16,1,-8); visualizer.Position=UDim2.new(0,8,0,4)
    visualizer.BackgroundTransparency=1; visualizer.BorderSizePixel=0; visualizer.ClipsDescendants=true; visualizer.ZIndex=1
    visualizer.Visible=false
    local visualCenter=Instance.new("Frame",visualizer)
    visualCenter.Size=UDim2.new(1,0,0,1); visualCenter.Position=UDim2.new(0,0,0.5,0)
    visualCenter.BackgroundColor3=scheme.main; visualCenter.BackgroundTransparency=0.72
    visualCenter.BorderSizePixel=0; visualCenter.ZIndex=1
    visualCenter.Visible=false
    local visualBars={}
    local visualLevels={}
    for barIndex=1,20 do
        local bar=Instance.new("Frame",visualizer)
        bar.AnchorPoint=Vector2.new(0.5,0.5); bar.Size=UDim2.new(0,5,0,2)
        bar.Position=UDim2.new((barIndex-0.5)/20,0,0.5,0); bar.BackgroundColor3=scheme.main
        bar.BackgroundTransparency=0.18; bar.BorderSizePixel=0; bar.ZIndex=1; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
        local barGradient=Instance.new("UIGradient",bar)
        barGradient.Color=ColorSequence.new(scheme.main,scheme.mainDark); barGradient.Rotation=90
        visualBars[barIndex]=bar; visualLevels[barIndex]=2
    end
    local songLbl = Instance.new("TextLabel", songCard)
    songLbl.Size = UDim2.new(1, -16, 0, 24)
    songLbl.Position = UDim2.new(0, 8, 0, 12)
    songLbl.BackgroundTransparency = 1
    songLbl.Text = (INTRO_MUSIC_OPTIONS[MusicPlayer.songIdx] and INTRO_MUSIC_OPTIONS[MusicPlayer.songIdx].name) or "Song"
    songLbl.Font = Enum.Font.GothamBold
    songLbl.TextSize = 13
    songLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    songLbl.TextXAlignment = Enum.TextXAlignment.Left
    songLbl.TextStrokeColor3=Color3.fromRGB(0,0,0); songLbl.TextStrokeTransparency=0.15; songLbl.ZIndex=3
    local progressBg=Instance.new("Frame",songCard)
    progressBg.Size=UDim2.new(1,-20,0,12); progressBg.Position=UDim2.new(0,10,1,-20)
    progressBg.BackgroundColor3=scheme.progressBg or scheme.modeBtnBg; progressBg.BackgroundTransparency=0.08; progressBg.BorderSizePixel=0
    progressBg.Visible=false
    Instance.new("UICorner",progressBg).CornerRadius=UDim.new(1,0)
    local progressFill=Instance.new("Frame",progressBg)
    progressFill.Size=UDim2.new(0,0,1,0); progressFill.BackgroundColor3=green; progressFill.BorderSizePixel=0
    Instance.new("UICorner",progressFill).CornerRadius=UDim.new(1,0)
    local musicProgressGradient=Instance.new("UIGradient",progressFill); musicProgressGradient.Color=ColorSequence.new(scheme.main,scheme.mainDark)

    local function refreshSongLbl()
        local opt = INTRO_MUSIC_OPTIONS[MusicPlayer.songIdx]
        songLbl.Text = opt and opt.name or "Song"
    end

    local libraryPanel=Instance.new("Frame",main)
    libraryPanel.Name="MusicLibrary"
    libraryPanel.Size=UDim2.new(0,220,1,0); libraryPanel.Position=UDim2.new(0,-206,0,0)
    libraryPanel.BackgroundColor3=scheme.stackBg or scheme.rowBg; libraryPanel.BackgroundTransparency=0.48
    libraryPanel.BorderSizePixel=0; libraryPanel.ClipsDescendants=true; libraryPanel.Visible=false
    Instance.new("UICorner",libraryPanel).CornerRadius=UDim.new(0,12)
    local libraryPanelStroke=Instance.new("UIStroke",libraryPanel); libraryPanelStroke.Color=scheme.main; libraryPanelStroke.Transparency=0.2
    local libraryPanelGradient=Instance.new("UIGradient",libraryPanel)
    libraryPanelGradient.Color=adaptiveCanColorSequence(scheme,false)

    local libraryTitle=Instance.new("TextLabel",libraryPanel)
    libraryTitle.Size=UDim2.new(1,-24,0,24); libraryTitle.Position=UDim2.new(0,12,0,8)
    libraryTitle.BackgroundTransparency=1; libraryTitle.Text="LIBRARY"; libraryTitle.TextColor3=scheme.mainLight or greenSoft
    libraryTitle.Font=Enum.Font.GothamBlack; libraryTitle.TextSize=12; libraryTitle.TextXAlignment=Enum.TextXAlignment.Left

    local searchBox=Instance.new("TextBox",libraryPanel)
    searchBox.Size=UDim2.new(1,-24,0,32); searchBox.Position=UDim2.new(0,12,0,36)
    searchBox.BackgroundColor3=scheme.inputBg or scheme.modeBtnBg; searchBox.BackgroundTransparency=0.28
    searchBox.BorderSizePixel=0; searchBox.PlaceholderText="Search songs"; searchBox.Text=""
    searchBox.TextColor3=Color3.fromRGB(255,255,255); searchBox.PlaceholderColor3=Color3.fromRGB(145,150,175)
    searchBox.Font=Enum.Font.GothamMedium; searchBox.TextSize=11; searchBox.ClearTextOnFocus=false
    Instance.new("UICorner",searchBox).CornerRadius=UDim.new(0,8)
    local searchStroke=Instance.new("UIStroke",searchBox); searchStroke.Color=green; searchStroke.Transparency=0.52

    local songList=Instance.new("ScrollingFrame",libraryPanel)
    songList.Size=UDim2.new(1,-24,1,-82); songList.Position=UDim2.new(0,12,0,74)
    songList.BackgroundTransparency=1; songList.BorderSizePixel=0; songList.ScrollBarThickness=0
    songList.ScrollBarImageColor3=green; songList.AutomaticCanvasSize=Enum.AutomaticSize.Y; songList.CanvasSize=UDim2.new()
    local songLayout=Instance.new("UIListLayout",songList); songLayout.Padding=UDim.new(0,5); songLayout.SortOrder=Enum.SortOrder.LayoutOrder

    local function rebuildLibrary()
        local query=string.lower(searchBox.Text or "")
        local live=currentColorScheme or scheme
        for _,child in ipairs(songList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for songIndex,option in ipairs(INTRO_MUSIC_OPTIONS) do
            local songName=tostring(option.name or ("Song "..songIndex))
            if query=="" or string.find(string.lower(songName),query,1,true) then
                local row=Instance.new("TextButton",songList)
                row.Size=UDim2.new(1,-4,0,34); row.BackgroundColor3=songIndex==MusicPlayer.songIdx and (live.mainDark or live.main) or (live.modeBtnBg or live.rowBg)
                row.BackgroundTransparency=0.08; row.BorderSizePixel=0; row.Text="  "..songName
                row.TextColor3=live.mainLight or live.text; row.Font=Enum.Font.GothamBold; row.TextSize=11
                row.TextXAlignment=Enum.TextXAlignment.Left; row.LayoutOrder=songIndex; row.AutoButtonColor=false
                Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
                local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=songIndex==MusicPlayer.songIdx and live.main or live.mainDark; rowStroke.Transparency=0.45
                row.MouseEnter:Connect(function()
                    local hoverScheme=currentColorScheme or live
                    TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=hoverScheme.main,BackgroundTransparency=0}):Play()
                end)
                row.MouseLeave:Connect(function()
                    local leaveScheme=currentColorScheme or live
                    TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=songIndex==MusicPlayer.songIdx and (leaveScheme.mainDark or leaveScheme.main) or (leaveScheme.modeBtnBg or leaveScheme.rowBg),BackgroundTransparency=0.08}):Play()
                end)
                row.MouseButton1Click:Connect(function()
                    MusicPlayer.songIdx=songIndex
                    selectedIntroMusic=songIndex
                    refreshSongLbl(); saveIntroSongIdx(); mpPlay(songIndex)
                    rebuildLibrary()
                end)
            end
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(rebuildLibrary)
    local libraryOpen=false
    libraryBtn.MouseButton1Click:Connect(function()
        libraryOpen=not libraryOpen
        libraryPanel.Visible=true
        if libraryOpen then
            libraryPanel.Position=UDim2.new(0,-206,0,0); libraryPanel.BackgroundTransparency=1
            TweenService:Create(libraryPanel,TweenInfo.new(0.36,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,-232,0,0),BackgroundTransparency=0.48}):Play()
            rebuildLibrary(); task.defer(function() searchBox:CaptureFocus() end)
        else
            TweenService:Create(libraryPanel,TweenInfo.new(0.2),{Position=UDim2.new(0,-206,0,0),BackgroundTransparency=1}):Play()
            task.delay(0.22,function() if not libraryOpen and libraryPanel.Parent then libraryPanel.Visible=false end end)
        end
    end)

    -- prev / play / next
    local prevBtn = Instance.new("TextButton", main)
    prevBtn.Size = UDim2.new(0, 48, 0, 32)
    prevBtn.Position = UDim2.new(0.5, -94, 0, 150)
    prevBtn.BackgroundColor3 = scheme.modeBtnBg or bg
    prevBtn.Text = "<<"
    prevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    prevBtn.Font = Enum.Font.GothamBold
    prevBtn.TextSize = 14
    prevBtn.BorderSizePixel = 0
    Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(1, 0)
    local prevStroke = Instance.new("UIStroke", prevBtn)
    prevStroke.Color = green
    prevStroke.Thickness = 1

    local playBtn = Instance.new("TextButton", main)
    playBtn.Size = UDim2.new(0, 72, 0, 36)
    playBtn.Position = UDim2.new(0.5, -36, 0, 148)
    playBtn.BackgroundColor3 = scheme.main
    playBtn.Text = MusicPlayer.playing and "STOP" or "PLAY"
    playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    playBtn.Font = Enum.Font.GothamBlack
    playBtn.TextSize = 13
    playBtn.BorderSizePixel = 0
    Instance.new("UICorner", playBtn).CornerRadius = UDim.new(1, 0)

    local nextBtn = Instance.new("TextButton", main)
    nextBtn.Size = UDim2.new(0, 48, 0, 32)
    nextBtn.Position = UDim2.new(0.5, 46, 0, 150)
    nextBtn.BackgroundColor3 = scheme.modeBtnBg or bg
    nextBtn.Text = ">>"
    nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    nextBtn.Font = Enum.Font.GothamBold
    nextBtn.TextSize = 14
    nextBtn.BorderSizePixel = 0
    Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(1, 0)
    local nextStroke = Instance.new("UIStroke", nextBtn)
    nextStroke.Color = green
    nextStroke.Thickness = 1

    -- volume
    local volLbl = Instance.new("TextLabel", main)
    volLbl.Size = UDim2.new(1, -24, 0, 18)
    volLbl.Position = UDim2.new(0, 12, 0, 193)
    volLbl.BackgroundTransparency = 1
    volLbl.Text = "Volume  " .. string.format("%.1f", MusicPlayer.volume)
    volLbl.Font = Enum.Font.Gotham
    volLbl.TextSize = 12
    volLbl.TextColor3 = greenSoft
    volLbl.TextXAlignment = Enum.TextXAlignment.Center

    local quieter = Instance.new("TextButton", main)
    quieter.Size = UDim2.new(0, 70, 0, 28)
    quieter.Position = UDim2.new(0.5, -110, 0, 222)
    quieter.BackgroundColor3 = scheme.modeBtnBg or bg
    quieter.Text = "- QUIETER"
    quieter.TextColor3 = scheme.mainLight or greenSoft
    quieter.Font = Enum.Font.GothamBold
    quieter.TextSize = 11
    quieter.BorderSizePixel = 0
    Instance.new("UICorner", quieter).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", quieter).Color = green

    local louder = Instance.new("TextButton", main)
    louder.Size = UDim2.new(0, 70, 0, 28)
    louder.Position = UDim2.new(0.5, 40, 0, 222)
    louder.BackgroundColor3 = scheme.modeBtnBg or bg
    louder.Text = "LOUDER +"
    louder.TextColor3 = scheme.mainLight or greenSoft
    louder.Font = Enum.Font.GothamBold
    louder.TextSize = 11
    louder.BorderSizePixel = 0
    Instance.new("UICorner", louder).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", louder).Color = green

    local loopBtn = Instance.new("TextButton", main)
    loopBtn.Size = UDim2.new(0, 70, 0, 28)
    loopBtn.Position = UDim2.new(0.5, -35, 0, 222)
    loopBtn.BackgroundColor3 = MusicPlayer.looped and scheme.main or (scheme.modeBtnBg or bg)
    loopBtn.Text = MusicPlayer.looped and "LOOP ON" or "LOOP OFF"
    loopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loopBtn.Font = Enum.Font.GothamBold
    loopBtn.TextSize = 11
    loopBtn.BorderSizePixel = 0
    Instance.new("UICorner", loopBtn).CornerRadius = UDim.new(1, 0)

    local hint = Instance.new("TextLabel", main)
    hint.Size = UDim2.new(1, -16, 0, 16)
    hint.Position = UDim2.new(0, 8, 1, -20)
    hint.BackgroundTransparency = 1
    hint.Text = "drag to move  ·  full track playback"
    hint.Font = Enum.Font.Gotham
    hint.Visible = false
    hint.TextSize = 10
    hint.TextColor3 = Color3.fromRGB(100, 180, 130)
    hint.TextXAlignment = Enum.TextXAlignment.Center

    local function syncPlayBtn()
        playBtn.Text = MusicPlayer.playing and "STOP" or "PLAY"
        local live=currentColorScheme or scheme
        playBtn.BackgroundColor3 = MusicPlayer.playing and (live.mainDark or live.main) or live.main
    end

    local function polishMusicButton(button)
        local scale=Instance.new("UIScale",button); scale.Scale=1
        button.MouseEnter:Connect(function() TweenService:Create(scale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.07}):Play() end)
        button.MouseLeave:Connect(function() TweenService:Create(scale,TweenInfo.new(0.12),{Scale=1}):Play() end)
        button.MouseButton1Down:Connect(function() TweenService:Create(scale,TweenInfo.new(0.06),{Scale=0.92}):Play() end)
        button.MouseButton1Up:Connect(function() TweenService:Create(scale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.04}):Play() end)
    end
    for _,musicButton in ipairs({closeBtn,libraryBtn,prevBtn,playBtn,nextBtn,quieter,louder,loopBtn,shrinkBtn,growBtn}) do polishMusicButton(musicButton) end

    prevBtn.MouseButton1Click:Connect(function()
        MusicPlayer.songIdx = MusicPlayer.songIdx - 1
        if MusicPlayer.songIdx < 1 then MusicPlayer.songIdx = #INTRO_MUSIC_OPTIONS end
        refreshSongLbl()
        if MusicPlayer.playing then mpPlay(MusicPlayer.songIdx) end
    end)
    nextBtn.MouseButton1Click:Connect(function()
        MusicPlayer.songIdx = MusicPlayer.songIdx + 1
        if MusicPlayer.songIdx > #INTRO_MUSIC_OPTIONS then MusicPlayer.songIdx = 1 end
        refreshSongLbl()
        if MusicPlayer.playing then mpPlay(MusicPlayer.songIdx) end
    end)
    playBtn.MouseButton1Click:Connect(function()
        if MusicPlayer.playing then
            mpStop()
            syncPlayBtn()
        else
            mpPlay(MusicPlayer.songIdx)
            task.delay(0.3, syncPlayBtn)
            task.delay(1.0, syncPlayBtn)
        end
    end)
    quieter.MouseButton1Click:Connect(function()
        mpSetVolume(MusicPlayer.volume - 0.2)
        volLbl.Text = "Volume  " .. string.format("%.1f", MusicPlayer.volume)
    end)
    louder.MouseButton1Click:Connect(function()
        mpSetVolume(MusicPlayer.volume + 0.2)
        volLbl.Text = "Volume  " .. string.format("%.1f", MusicPlayer.volume)
    end)
    loopBtn.MouseButton1Click:Connect(function()
        MusicPlayer.looped = not MusicPlayer.looped
        loopBtn.Text = MusicPlayer.looped and "LOOP ON" or "LOOP OFF"
        local live=currentColorScheme or scheme
        loopBtn.BackgroundColor3 = MusicPlayer.looped and live.main or (live.modeBtnBg or live.rowBg)
        if MusicPlayer.sound then
            MusicPlayer.sound.Looped = MusicPlayer.looped
        end
    end)

    local function refreshMusicPlayerTheme()
        if not gui.Parent then return end
        local live=currentColorScheme or scheme
        main.BackgroundColor3=live.stackBg or live.rowBg
        mainGradient.Color=adaptiveCanColorSequence(live,false)
        stroke.Color=live.border or live.main
        strokeGradient.Color=ColorSequence.new(live.mainDark,live.mainLight)
        musicBg.Image=currentBgImage
        musicBg.ImageColor3=Color3.fromRGB(255,255,255)
        title.TextColor3=live.mainLight

        closeBtn.BackgroundColor3=live.mainDark
        closeBtn.TextColor3=live.buttonText or live.text
        libraryBtn.BackgroundColor3=live.main
        libraryBtn.TextColor3=live.buttonText or live.text
        libraryStroke.Color=live.main
        for _, child in ipairs(libraryBtn:GetChildren()) do
            if child:IsA("Frame") then child.BackgroundColor3=live.mainLight end
        end

        for _, button in ipairs({shrinkBtn,growBtn,prevBtn,nextBtn,quieter,louder}) do
            button.BackgroundColor3=live.modeBtnBg or live.rowBg
            button.TextColor3=live.mainLight
            local buttonStroke=button:FindFirstChildWhichIsA("UIStroke")
            if buttonStroke then buttonStroke.Color=live.main end
        end
        playBtn.TextColor3=live.buttonText or live.text
        syncPlayBtn()
        loopBtn.BackgroundColor3=MusicPlayer.looped and live.main or (live.modeBtnBg or live.rowBg)
        loopBtn.TextColor3=MusicPlayer.looped and (live.buttonText or live.text) or live.mainLight
        volLbl.TextColor3=live.mainLight

        songCard.BackgroundColor3=live.rowBg
        songStroke.Color=live.mainLight
        songCardGradient.Color=adaptiveCanColorSequence(live,true)
        visualCenter.BackgroundColor3=live.main
        progressBg.BackgroundColor3=live.progressBg or live.modeBtnBg
        progressFill.BackgroundColor3=live.main
        musicProgressGradient.Color=ColorSequence.new(live.main,live.mainDark)
        for _, bar in ipairs(visualBars) do
            bar.BackgroundColor3=live.main
            local gradient=bar:FindFirstChildWhichIsA("UIGradient")
            if gradient then gradient.Color=ColorSequence.new(live.main,live.mainDark) end
        end

        libraryPanel.BackgroundColor3=live.stackBg or live.rowBg
        libraryPanelStroke.Color=live.main
        libraryPanelGradient.Color=adaptiveCanColorSequence(live,false)
        libraryTitle.TextColor3=live.mainLight
        searchBox.BackgroundColor3=live.inputBg or live.modeBtnBg
        searchBox.TextColor3=live.inputText or live.text
        searchStroke.Color=live.main
        songList.ScrollBarImageColor3=live.main
        if libraryOpen then rebuildLibrary() end
    end
    _G._K7RefreshMusicPlayerTheme=refreshMusicPlayerTheme
    refreshMusicPlayerTheme()

    -- keep play button in sync
    task.spawn(function()
        while MusicPlayer.gui and MusicPlayer.gui.Parent do
            syncPlayBtn()
            local ratio=0
            pcall(function()
                if MusicPlayer.sound and MusicPlayer.sound.TimeLength>0 then ratio=math.clamp(MusicPlayer.sound.TimePosition/MusicPlayer.sound.TimeLength,0,1) end
            end)
            TweenService:Create(progressFill,TweenInfo.new(0.22,Enum.EasingStyle.Linear),{Size=UDim2.new(ratio,0,1,0)}):Play()
            task.wait(0.5)
        end
    end)
    task.spawn(function()
        while MusicPlayer.gui and MusicPlayer.gui.Parent do
            local amplitude=0
            pcall(function()
                if MusicPlayer.sound and MusicPlayer.playing then amplitude=math.clamp(MusicPlayer.sound.PlaybackLoudness/420,0,1) end
            end)
            local now=tick()
            for barIndex,bar in ipairs(visualBars) do
                local centerWeight=1-(math.abs(barIndex-10.5)/10.5)*0.38
                local movement=0.72+0.28*math.sin(now*7+barIndex*0.82)
                local target=2+amplitude*36*centerWeight*movement
                visualLevels[barIndex]=visualLevels[barIndex]+(target-visualLevels[barIndex])*0.38
                bar.Size=UDim2.new(0,5,0,visualLevels[barIndex])
                bar.BackgroundTransparency=amplitude>0.02 and 0.12 or 0.68
            end
            task.wait(0.045)
        end
    end)

    MusicPlayer.songIdx = MusicPlayer.songIdx or selectedIntroMusic or 1
    refreshSongLbl()
    removeUILineDecorations(gui)
end

_G.SevenUpOpenMusicPlayer = openMusicPlayerUI
_G.SevenUpMusicPlay = mpPlay
_G.SevenUpMusicStop = mpStop

preloadIntroSongs()

-- ============================================================
-- AIMBOT — direct Ace port (green theme)
-- ============================================================
local AIMBOT_SPEED = 50
local LAGGER_AIMBOT_SPEED = 40
_G.AceNormalAimbotOn = false
_G.AceNormalAimbot = {conn=nil, target=nil, swingCooldown=false}

function _G.AceGetNormalAimbotSpeed()
    return State.laggerMode~=0 and (tonumber(LAGGER_AIMBOT_SPEED) or 40) or (tonumber(AIMBOT_SPEED) or 50)
end
function _G.AceRefreshAimbotSpeedBoxes()
    if _G.AceAimbotSpeedBox then _G.AceAimbotSpeedBox.Text=tostring(AIMBOT_SPEED) end
    if _G.AceLaggerAimbotSpeedBox then _G.AceLaggerAimbotSpeedBox.Text=tostring(LAGGER_AIMBOT_SPEED) end
end

-- shared helpers
function _G.AceFindAimbotBat()
    local char=LP.Character; if not char then return nil end
    for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then return t end end
    local bp=LP:FindFirstChild("Backpack")
    if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then return t end end end
    return nil
end
function _G.AceGetClosestAimbotTarget()
    local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not root then return nil end
    local closest,minDist=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character then
            local tRoot=plr.Character:FindFirstChild("HumanoidRootPart")
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health>0 then
                local dist=(tRoot.Position-root.Position).Magnitude
                if dist<minDist then minDist=dist; closest=tRoot end
            end
        end
    end
    return closest
end

-- Normal aimbot
function _G.AceStopNormalAimbot()
    _G.AceNormalAimbotOn=false
    if _G.AceNormalAimbot.conn then _G.AceNormalAimbot.conn:Disconnect(); _G.AceNormalAimbot.conn=nil end
    _G.AceNormalAimbot.target=nil; _G.AceNormalAimbot.swingCooldown=false
    local c=LP.Character; local root=c and c:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
    local hum=c and c:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate=true end
    State.batAimbotToggled = false
    if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
end
function _G.AceStartNormalAimbot()
    if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then return false end
    _G.AceNormalAimbotOn=true
    if _G.AceNormalAimbot.conn then _G.AceNormalAimbot.conn:Disconnect(); _G.AceNormalAimbot.conn=nil end
    local hum0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate=false end
    _G.AceNormalAimbot.conn=RunService.RenderStepped:Connect(function()
        if not _G.AceNormalAimbotOn then return end
        local char=LP.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local bat=char:FindFirstChildOfClass("Tool") or _G.AceFindAimbotBat()
        if bat and bat.Parent~=char then pcall(function() hum:EquipTool(bat) end) end
        local target=_G.AceGetClosestAimbotTarget(); if not target then return end
        _G.AceNormalAimbot.target=target
        local targetVel=target.AssemblyLinearVelocity
        local myPos=root.Position; local targetPos=target.Position
        local predictPos=targetPos+targetVel*0.14+target.CFrame.LookVector*0.3
        local direction=predictPos-myPos
        if direction.Magnitude<0.01 then return end
        local flatDir=Vector3.new(direction.X,0,direction.Z)
        if flatDir.Magnitude<0.01 then return end
        flatDir=flatDir.Unit
        local chaseSpeed=_G.AceGetNormalAimbotSpeed()
        local desiredHeight=targetPos.Y+3.7
        local yVel=(desiredHeight-myPos.Y)*19.5+targetVel.Y*0.8
        if hum.FloorMaterial~=Enum.Material.Air then yVel=math.max(yVel,13) end
        yVel=math.clamp(yVel,-70,110)
        root.AssemblyLinearVelocity=root.AssemblyLinearVelocity:Lerp(Vector3.new(flatDir.X*chaseSpeed,yVel,flatDir.Z*chaseSpeed),0.8)
        local predictTime=math.clamp(targetVel.Magnitude/150,0.05,0.2)
        local predictedPos=targetPos+targetVel*predictTime
        local toPredict=predictedPos-myPos
        if toPredict.Magnitude>0.1 then
            local goalCF=CFrame.lookAt(myPos,predictedPos)
            local diffCF=root.CFrame:Inverse()*goalCF
            local rx,ry,rz=diffCF:ToEulerAnglesXYZ()
            root.AssemblyAngularVelocity=root.CFrame:VectorToWorldSpace(Vector3.new(math.clamp(rx,-2.5,2.5)*42,math.clamp(ry,-2.5,2.5)*42,math.clamp(rz,-2.5,2.5)*42))
        end
        if State.autoSwingEnabled and bat and not _G.AceNormalAimbot.swingCooldown then
            _G.AceNormalAimbot.swingCooldown=true
            pcall(function() bat:Activate() end)
            task.delay(0.08,function() if _G.AceNormalAimbot then _G.AceNormalAimbot.swingCooldown=false end end)
        end
    end)
    if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
    return true
end

function _G.AceRefreshAimbotVisual()
    if _G.AceAimbotSetVisual then _G.AceAimbotSetVisual(_G.AceNormalAimbotOn==true) end
    local on=(_G.AceNormalAimbotOn==true) or (State.batAimbotZombie==true)
    State.batAimbotToggled = _G.AceNormalAimbotOn==true
    if stackBtnRefs and stackBtnRefs.aimbot then
        stackBtnRefs.aimbot.setOn(on)
        if stackBtnRefs.aimbot.setLabel then
            stackBtnRefs.aimbot.setLabel(State.aimbotMode=="new" and "AIMBOT\nNEW" or "AIMBOT\nOLD")
        end
    end
end
function _G.AceToggleSelectedAimbot()
    if State.aimbotMode == "new" then
        if State.batAimbotZombie then
            if _G._7upStopZombieBatAimbot then pcall(_G._7upStopZombieBatAimbot) end
        else
            if _G.AceNormalAimbotOn then _G.AceStopNormalAimbot() end
            if _G._7upStartZombieBatAimbot then pcall(_G._7upStartZombieBatAimbot) end
        end
    else
        if _G.AceNormalAimbotOn then _G.AceStopNormalAimbot()
        else
            if State.batAimbotZombie and _G._7upStopZombieBatAimbot then pcall(_G._7upStopZombieBatAimbot) end
            _G.AceStartNormalAimbot()
        end
    end
end

-- compat stubs
local startBatAimbot=function() _G.AceStartNormalAimbot(); State.batAimbotToggled=true end
local stopBatAimbot=function() _G.AceStopNormalAimbot(); State.batAimbotToggled=false end

-- ============================================================
-- ANTI-DESYNC — Ace port (hardened)
-- ============================================================
_G.AceAntiDesyncAimbotOn = false
_G.AceAntiDesync = _G.AceAntiDesync or {
    conn=nil, hittingCooldown=false, h=nil, hrp=nil,
    lastSafeCFrame=nil, lastPosition=nil, lastSampleTime=0,
    voidRecoverUntil=0, targetSamples={}, targetPlayer=nil,
    safeEngagementCFrame=nil,
}
_G.AceAntiDesync.targetSamples = _G.AceAntiDesync.targetSamples or {}
antiDesyncAutoSwingEnabled = true

_G.AceAntiDesyncSlapList = {
    "Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap",
    "Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap",
}

function _G.AceAntiDesyncGetBat()
    local char = LP.Character
    if not char then return nil end
    for _, name in ipairs(_G.AceAntiDesyncSlapList) do
        local t = char:FindFirstChild(name)
        if t and t:IsA("Tool") then return t end
    end
    for _, ch in ipairs(char:GetChildren()) do
        if ch:IsA("Tool") then
            local n = ch.Name:lower()
            if n:find("bat") or n:find("slap") then return ch end
        end
    end
    local bp = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(_G.AceAntiDesyncSlapList) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(t) end) end
                return t
            end
        end
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") then
                local n = ch.Name:lower()
                if n:find("bat") or n:find("slap") then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(ch) end) end
                    return ch
                end
            end
        end
    end
    return nil
end

function _G.AceAntiDesyncTrySwing()
    if not _G.AceAntiDesync then return end
    if _G.AceAntiDesync.hittingCooldown then return end
    _G.AceAntiDesync.hittingCooldown = true
    pcall(function()
        local char = LP.Character
        if not char then return end
        local bat = _G.AceAntiDesyncGetBat()
        if not bat then return end
        if bat.Parent ~= char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:EquipTool(bat) end) end
        end
        pcall(function() bat:Activate() end)
        local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
        if ev then pcall(function() ev:FireServer() end) end
    end)
    task.delay(0.08, function()
        if _G.AceAntiDesync then _G.AceAntiDesync.hittingCooldown = false end
    end)
end

function _G.AceAntiDesyncGetClosestPlayer()
    local hrp = _G.AceAntiDesync and _G.AceAntiDesync.hrp
    if not hrp or not hrp.Parent then
        local c = LP.Character
        hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then _G.AceAntiDesync.hrp = hrp end
    end
    if not hrp then return nil, math.huge end
    local cp, cd = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and hum and hum.Health > 0 then
                local targetY = tr.Position.Y
                -- Ignore decoy/void targets and immediately select another
                -- living enemy so tracking and swinging never stall.
                if targetY >= -30 and targetY <= 1200 then
                    local d = (hrp.Position - tr.Position).Magnitude
                    if d < cd then cd = d; cp = p end
                end
            end
        end
    end
    return cp, cd
end

function _G.AceAntiDesyncSetupChar(char)
    if not char then return end
    if not _G.AceAntiDesync then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    _G.AceAntiDesync.h = hum
    _G.AceAntiDesync.hrp = root
    if root and root.Position.Y > -30 then
        _G.AceAntiDesync.lastSafeCFrame = root.CFrame
        _G.AceAntiDesync.lastPosition = root.Position
        _G.AceAntiDesync.lastSampleTime = tick()
    end
end

local function _aceFiniteVector3(v)
    return v.X==v.X and v.Y==v.Y and v.Z==v.Z
        and math.abs(v.X)<1e7 and math.abs(v.Y)<1e7 and math.abs(v.Z)<1e7
end
function _G.AceAntiDesyncInspectTarget(player,targetRoot,myRoot)
    if not player or not targetRoot or not targetRoot.Parent then return true,nil end
    local guard=_G.AceAntiDesync; guard.targetSamples=guard.targetSamples or {}
    local sample=guard.targetSamples[player] or {}; guard.targetSamples[player]=sample
    local now=tick(); local pos=targetRoot.Position; local vel=targetRoot.AssemblyLinearVelocity
    local destroyHeight=workspace.FallenPartsDestroyHeight or -500
    local voidFloor=math.max(destroyHeight+90,-50)
    local dt=sample.time and math.max(now-sample.time,1/240) or math.huge
    local delta=sample.position and (pos-sample.position) or Vector3.zero
    local impossibleStep=sample.position~=nil and dt<0.4 and (delta.Magnitude>90 or math.abs(delta.Y)>38)
    local badVelocity=not _aceFiniteVector3(vel) or vel.Magnitude>650 or math.abs(vel.Y)>150
    local badPosition=not _aceFiniteVector3(pos) or pos.Y<=voidFloor or pos.Y>650
        or (myRoot and (pos-myRoot.Position).Magnitude>4000)
    if badPosition or badVelocity or impossibleStep then sample.suspiciousUntil=now+1.35
    elseif now>=(sample.suspiciousUntil or 0) then sample.safePosition=pos; sample.safeCFrame=targetRoot.CFrame end
    sample.position=pos; sample.time=now
    return now<(sample.suspiciousUntil or 0),sample
end

function _G.AceAntiDesyncGuardVoid(root, hum, targetRoot)
    if not root or not hum or not _G.AceAntiDesync then return false end
    local guard = _G.AceAntiDesync
    local now = tick()
    local position = root.Position
    local velocity = root.AssemblyLinearVelocity
    local destroyHeight = workspace.FallenPartsDestroyHeight or -500
    local voidFloor = math.max(destroyHeight + 80, -55)
    local dt = now - (guard.lastSampleTime or now)
    local suddenDrop = guard.lastPosition and dt <= 0.35 and position.Y < guard.lastPosition.Y - 40
    -- Anti TP-bat sky-drag: detect any fast upward pull
    local suddenRise = guard.lastPosition and dt <= 0.35 and position.Y > guard.lastPosition.Y + 25
    local safeRise = guard.lastSafeCFrame and position.Y > guard.lastSafeCFrame.Position.Y + 30
    local forcedLaunch = math.abs(velocity.Y) > 90 or velocity.Magnitude > 450
    local inVoid = position.Y <= voidFloor
    local resetHeight = position.Y > 400
    local recovering = now < (guard.voidRecoverUntil or 0)

    if inVoid or suddenDrop or suddenRise or safeRise or forcedLaunch or resetHeight then
        -- Break PhysicsRepRootPart so their anti can no longer sky-drag us
        if sethiddenproperty then
            pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", root) end)
        end
        -- Prefer snap back onto the target (keep TP bat stuck on them)
        local recoveryCFrame = guard.safeEngagementCFrame or guard.lastSafeCFrame
        if targetRoot and targetRoot.Parent and targetRoot.Position.Y > voidFloor + 10 and targetRoot.Position.Y < 350 then
            local tp = targetRoot.Position
            local recoveryPos = Vector3.new(tp.X, tp.Y + 0.9, tp.Z)
            local facing = Vector3.new(targetRoot.CFrame.LookVector.X, 0, targetRoot.CFrame.LookVector.Z)
            if facing.Magnitude < 0.01 then facing = Vector3.new(0, 0, -1) end
            recoveryCFrame = CFrame.lookAt(recoveryPos, recoveryPos + facing.Unit)
        end
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            pcall(function() root.Velocity = Vector3.zero end)
            pcall(function() root.RotVelocity = Vector3.zero end)
            hum.PlatformStand = false
            hum.Sit = false
            hum.AutoRotate = true
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
            if recoveryCFrame then root.CFrame = recoveryCFrame end
        end)
        guard.voidRecoverUntil = now + 0.55
        guard._physPulseUntil = now + 0.2 -- hold off phys lock briefly after anti-void
        recovering = true
    elseif not recovering and position.Y > voidFloor + 15 and math.abs(velocity.Y) < 85 and position.Y < 250 then
        guard.lastSafeCFrame = root.CFrame
    end

    if recovering then
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            -- Keep re-snapping to target during recovery so anti cannot peel us off
            if targetRoot and targetRoot.Parent and targetRoot.Position.Y > voidFloor + 10 and targetRoot.Position.Y < 350 then
                local tp = targetRoot.Position + Vector3.new(0, 0.9, 0)
                root.CFrame = CFrame.new(tp)
            end
        end)
        if sethiddenproperty then
            pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", root) end)
        end
    end
    guard.lastPosition = root.Position
    guard.lastSampleTime = now
    return recovering
end

function _G.AceStartAntiDesyncAimbot()
    if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then
        warn("[7UP duels] TP Bat blocked by safe mode")
        return false
    end
    pcall(function() if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end end)
    pcall(function() if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end end)
    pcall(function() if stopBatAimbot then stopBatAimbot() end end)
    pcall(function() if stopZombieBatAimbot then stopZombieBatAimbot() end end)
    State.batAimbotToggled = false
    if stackBtnRefs and stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end

    _G.AceAntiDesyncAimbotOn = true
    if _G.AceAntiDesync and _G.AceAntiDesync.conn then
        pcall(function() _G.AceAntiDesync.conn:Disconnect() end)
        _G.AceAntiDesync.conn = nil
    end
    _G.AceAntiDesync = _G.AceAntiDesync or {}
    _G.AceAntiDesync.hittingCooldown = false
    _G.AceAntiDesync.targetSamples = _G.AceAntiDesync.targetSamples or {}

    local function getBat()
        return _G.AceAntiDesyncGetBat and _G.AceAntiDesyncGetBat() or nil
    end
    local function tryHit()
        if _G.AceAntiDesync.hittingCooldown then return end
        _G.AceAntiDesync.hittingCooldown = true
        pcall(function()
            local bat = getBat()
            if not bat then return end
            local char = LP.Character
            if bat.Parent ~= char then
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            pcall(function() bat:Activate() end)
            local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then pcall(function() ev:FireServer() end) end
        end)
        task.delay(0.08, function()
            if _G.AceAntiDesync then _G.AceAntiDesync.hittingCooldown = false end
        end)
    end
    local function closestRoot()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local locked=_G.AceAntiDesync.targetPlayer
        if locked and locked.Parent==Players and locked.Character then
            local lr=locked.Character:FindFirstChild("HumanoidRootPart")
            local lh=locked.Character:FindFirstChildOfClass("Humanoid")
            if lr and lh and lh.Health>0 then return lr,locked end
        end
        local best, bd = nil, math.huge
        local bestPlayer=nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if tr and hum and hum.Health > 0 then
                    local suspicious,sample=_G.AceAntiDesyncInspectTarget(p,tr,hrp)
                    local pos=suspicious and sample and sample.safePosition or tr.Position
                    if pos then local d=(hrp.Position-pos).Magnitude
                        if d<bd then bd=d; best=tr; bestPlayer=p end end
                end
            end
        end
        _G.AceAntiDesync.targetPlayer=bestPlayer
        return best,bestPlayer
    end

    _G.AceAntiDesync.conn = RunService.Heartbeat:Connect(function()
        if not _G.AceAntiDesyncAimbotOn then return end
        if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            _G.AceStopAntiDesyncAimbot()
            return
        end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local tr,targetPlayer = closestRoot()
        if not tr then return end
        local suspicious,sample=_G.AceAntiDesyncInspectTarget(targetPlayer,tr,hrp)
        if _G.AceAntiDesyncGuardVoid(hrp,hum,suspicious and nil or tr) then tryHit(); return end
        if suspicious then
            local recovery=_G.AceAntiDesync.safeEngagementCFrame or _G.AceAntiDesync.lastSafeCFrame
            if sethiddenproperty then pcall(function() sethiddenproperty(hrp,"PhysicsRepRootPart",hrp) end) end
            local safePos=sample and sample.safePosition
            local anchor=recovery and recovery.Position or hrp.Position
            local targetXZ=safePos or anchor
            if _aceFiniteVector3(tr.Position) then
                local reference=safePos or anchor
                local horizontalDelta=Vector3.new(tr.Position.X-reference.X,0,tr.Position.Z-reference.Z).Magnitude
                if horizontalDelta<=180 then targetXZ=tr.Position end
            end
            local sanitizedPos=Vector3.new(targetXZ.X,anchor.Y,targetXZ.Z)
            local facing=Vector3.new(tr.CFrame.LookVector.X,0,tr.CFrame.LookVector.Z)
            if facing.Magnitude<0.01 then facing=Vector3.new(0,0,-1) end
            local sanitizedCFrame=CFrame.lookAt(sanitizedPos,sanitizedPos+facing.Unit)
            pcall(function()
                hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero
                if (hrp.Position-sanitizedPos).Magnitude>5 then hrp.CFrame=sanitizedCFrame end
            end)
            local cam=workspace.CurrentCamera
            if cam then cam.CFrame=CFrame.new(cam.CFrame.Position,sanitizedPos) end
            tryHit(); return
        end
        local guard = _G.AceAntiDesync
        local now = tick()
        -- Live target position every frame (predict slightly with velocity so follow stays on them)
        local tvel = tr.AssemblyLinearVelocity
        local predict = Vector3.new(tvel.X, 0, tvel.Z) * 0.05
        local rawTarget = tr.Position + Vector3.new(0, 0.9, 0) + predict
        -- Use LIVE target Y; do not freeze to old lastSafeCFrame (that caused stuck old pos)
        local targetPos = rawTarget
        if targetPos.Y < -20 then
            targetPos = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
        end
        local facing = Vector3.new(tr.CFrame.LookVector.X, 0, tr.CFrame.LookVector.Z)
        if facing.Magnitude < 0.01 then
            local flat = Vector3.new(tr.Position.X - hrp.Position.X, 0, tr.Position.Z - hrp.Position.Z)
            facing = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
        end
        guard.safeEngagementCFrame = CFrame.lookAt(targetPos, targetPos + facing.Unit)

        -- ALWAYS snap to current target each frame so we never sit on old position
        pcall(function()
            hrp.CFrame = guard.safeEngagementCFrame
            hrp.AssemblyLinearVelocity = Vector3.new(tvel.X, 0, tvel.Z)
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        -- PhysicsRepRootPart for desync stick, but skip during void-recovery window
        if sethiddenproperty and now >= (guard._physPulseUntil or 0) then
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", tr) end)
        end

        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.new(cam.CFrame.Position, tr.Position)
        end
        tryHit()
    end)

    if stackBtnRefs and stackBtnRefs.antiDesync then stackBtnRefs.antiDesync.setOn(true) end
    pcall(function() if requestSave then requestSave() end end)
    print("[7UP duels] TP Bat ON (anti-anti hardened)")
    return true
end

function _G.AceStopAntiDesyncAimbot()
    _G.AceAntiDesyncAimbotOn = false
    if _G.AceAntiDesync and _G.AceAntiDesync.conn then
        pcall(function() _G.AceAntiDesync.conn:Disconnect() end)
        _G.AceAntiDesync.conn = nil
    end

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        if sethiddenproperty then pcall(function() sethiddenproperty(root,"PhysicsRepRootPart",root) end) end
    end

    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (_G.AceAntiDesync.prevAutoRotate == nil) and true or _G.AceAntiDesync.prevAutoRotate
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    end

    if _G.AceAntiDesync then
        _G.AceAntiDesync.hittingCooldown=false
        _G.AceAntiDesync.targetPlayer=nil
        _G.AceAntiDesync.safeEngagementCFrame=nil
    end
    if stackBtnRefs and stackBtnRefs.antiDesync then stackBtnRefs.antiDesync.setOn(false) end
    pcall(function() if requestSave then requestSave() end end)
    print("[7UP duels] TP Bat OFF")
end

function _G.AceToggleAntiDesyncAimbot()
    if _G.AceAntiDesyncAimbotOn then
        _G.AceStopAntiDesyncAimbot()
    else
        _G.AceStartAntiDesyncAimbot()
    end
end

-- Global keybind backup
if not _G._K7AntiDesyncKeyBound then
    _G._K7AntiDesyncKeyBound = true
    UserInputService.InputBegan:Connect(function(inp, gp)
        if UserInputService:GetFocusedTextBox() then return end
        if not Keys or not Keys.antiDesync then return end
        if inp.KeyCode ~= Keys.antiDesync then return end
        if _G.SevenUpDuelsV2_MainExecuted then return end
        print("[7UP duels] AntiDesync global bind:", Keys.antiDesync.Name)
        if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
            return
        end
        pcall(function() _G.AceToggleAntiDesyncAimbot() end)
    end)
end

for _, name in ipairs({"EnvyAutoBatDesyncGUI","MwvaneNewaBatDesyncGUI","PhazeAutoBatDesyncGUI","VisionBatGui","K7AntiDesync"}) do
    pcall(function()
        local o = CoreGui:FindFirstChild(name)
        if o then o:Destroy() end
    end)
    pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        local o = pg and pg:FindFirstChild(name)
        if o then o:Destroy() end
    end)
end

LP.CharacterAdded:Connect(function(char)
    task.defer(function()
        pcall(function() _G.AceAntiDesyncSetupChar(char) end)
    end)
end)
if LP.Character then
    task.spawn(function()
        pcall(function() _G.AceAntiDesyncSetupChar(LP.Character) end)
    end)
end

-- ============================================================
-- DROP TYPES
-- ============================================================
local DROP_TYPES = {
    JUMP = "Jump Drop"
}
local currentDropType = DROP_TYPES.JUMP

-- ============================================================
-- ANTI-RAGDOLL (v1 boost method)
-- ============================================================
do
local antiRagdollConn = nil
local antiRagdollMode = nil
local ragdollConnections = {}
local cachedCharData = {}
local isBoosting = false
local BOOST_SPEED = 400
local AR_DEFAULT_SPEED = 16

local function arV2ResetCharacter(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end

    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum:ChangeState(Enum.HumanoidStateType.Running)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        hum.PlatformStand = false
        hum.Sit = false
        hum.AutoRotate = true
        hum.JumpPower = hum.JumpPower > 0 and hum.JumpPower or 50
        hum.WalkSpeed = hum.WalkSpeed > 0 and hum.WalkSpeed or AR_DEFAULT_SPEED

        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then
                obj.Enabled = true
            elseif obj:IsA("Constraint") or obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then
                obj.Enabled = true
            elseif obj:IsA("BasePart") then
                obj.CanCollide = true
                obj.AssemblyLinearVelocity = Vector3.zero
                obj.AssemblyAngularVelocity = Vector3.zero
            end
        end

        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
        local playerModule = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
        local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
        if controlModule then
            local loaded, module = pcall(require, controlModule)
            if loaded and module and module.Enable then module:Enable() end
        end
    end)
end

local function arCacheCharacterData()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData = { character = char, humanoid = hum, root = root }
    State._ragdollCache = cachedCharData
    return true
end

local function arDisconnectAll()
    for _, conn in ipairs(ragdollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    ragdollConnections = {}
end

local function arIsRagdolled()
    if not cachedCharData.humanoid then return false end
    local state = cachedCharData.humanoid:GetState()
    local ragdollStates = {
        [Enum.HumanoidStateType.Physics] = true,
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragdollStates[state] then return true end
    local endTime = LP:GetAttribute("RagdollEndTime")
    if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function arForceExitRagdoll()
    if not cachedCharData.humanoid or not cachedCharData.root then return end
    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    for _, descendant in ipairs(cachedCharData.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or
           (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            descendant:Destroy()
        end
    end
    if not isBoosting then
        isBoosting = true
        cachedCharData.humanoid.WalkSpeed = BOOST_SPEED
    end
    if cachedCharData.humanoid.Health > 0 then
        cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    cachedCharData.root.Anchored = false
end

local function arHeartbeatLoop()
    while antiRagdollMode == "v1" do
        task.wait()
        local currentlyRagdolled = arIsRagdolled()
        if currentlyRagdolled then
            arForceExitRagdoll()
        elseif isBoosting and not currentlyRagdolled then
            isBoosting = false
            if cachedCharData.humanoid then
                cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED
            end
        end
    end
end

startAntiRagdollNew = function()
    local requestedMode = State.antiRagdollVersion == "V2" and "v2" or "v1"
    if antiRagdollMode == requestedMode then return end

    antiRagdollMode = nil
    if antiRagdollConn then
        antiRagdollConn:Disconnect()
        antiRagdollConn = nil
    end
    if isBoosting and cachedCharData.humanoid then
        cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED
    end
    isBoosting = false
    arDisconnectAll()
    cachedCharData = {}

    if not arCacheCharacterData() then return end
    antiRagdollMode = requestedMode

    if requestedMode == "v2" then
        antiRagdollConn = RunService.Heartbeat:Connect(function()
            if antiRagdollMode ~= "v2" or not State.antiRagdollEnabled then return end
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Physics
                or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.FallingDown
                or state == Enum.HumanoidStateType.Dead
                or hum.PlatformStand == true
                or hum.Sit == true then
                arV2ResetCharacter(char)
            end
        end)
        return
    end

    local camConn = RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if cam and cachedCharData.humanoid then
            cam.CameraSubject = cachedCharData.humanoid
        end
    end)
    table.insert(ragdollConnections, camConn)

    local respawnConn = LP.CharacterAdded:Connect(function()
        isBoosting = false
        task.wait(0.5)
        arCacheCharacterData()
    end)
    table.insert(ragdollConnections, respawnConn)

    task.spawn(arHeartbeatLoop)
end

stopAntiRagdollNew = function()
    antiRagdollMode = nil
    if antiRagdollConn then
        antiRagdollConn:Disconnect()
        antiRagdollConn = nil
    end
    if isBoosting and cachedCharData.humanoid then
        cachedCharData.humanoid.WalkSpeed = AR_DEFAULT_SPEED
    end
    isBoosting = false
    arDisconnectAll()
    cachedCharData = {}
    State._ragdollCache = {}
end
end

-- ============================================================
-- INFINITE JUMP (HOLD MODE)
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not State.infJumpEnabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local jumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum and hum.Jump == true)
    if jumpHeld and root.Velocity.Y < 30 then
        root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
    end
end)

-- ============================================================
-- ANTI-LAG FUNCTION (unchanged)
-- ============================================================
local antiLagDescConn = nil
local antiLagActive = false

local function enableAntiLag()
    if antiLagActive then return end
    antiLagActive = true

    pcall(function() Lighting.GlobalShadows = false end)

    for _, e in ipairs(Lighting:GetDescendants()) do
        pcall(function()
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
               e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or
               e:IsA("Atmosphere") or e:IsA("Clouds") then
                e.Enabled = false
            end
        end)
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
                   obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
                    pcall(function() obj:Destroy() end)
                end
            elseif obj:IsA("SurfaceAppearance") then
                pcall(function() obj:Destroy() end)
            elseif obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("brainrot",1,true) or n:find("animal",1,true) or n:find("carry",1,true) or
                   n:find("grab",1,true) or n:find("steal",1,true) or n:find("hold",1,true) then
                    pcall(function() obj:Destroy() end)
                end
            elseif obj:IsA("Animator") and obj.Parent and obj.Parent.Parent ~= LP.Character then
                pcall(function() obj:Destroy() end)
            end
        end)
    end

    if antiLagDescConn then antiLagDescConn:Disconnect() end
    antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
        if not antiLagActive then return end
        task.defer(function()
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
                       obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
                        pcall(function() obj:Destroy() end)
                    end
                elseif obj:IsA("SurfaceAppearance") then
                    pcall(function() obj:Destroy() end)
                elseif obj:IsA("Model") then
                    local n = obj.Name:lower()
                    if n:find("brainrot",1,true) or n:find("animal",1,true) or n:find("carry",1,true) or
                       n:find("grab",1,true) or n:find("steal",1,true) or n:find("hold",1,true) then
                        pcall(function() obj:Destroy() end)
                    end
                elseif obj:IsA("Animator") and obj.Parent and obj.Parent.Parent ~= LP.Character then
                    pcall(function() obj:Destroy() end)
                elseif obj:IsA("PostEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or
                       obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or
                       obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                    obj.Enabled = false
                end
            end)
        end)
    end)
end

local function disableAntiLag()
    antiLagActive = false
    if antiLagDescConn then antiLagDescConn:Disconnect(); antiLagDescConn = nil end
    pcall(function()
        Lighting.GlobalShadows = true
        for _, e in ipairs(Lighting:GetDescendants()) do
            pcall(function()
                if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or
                   e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or
                   e:IsA("Atmosphere") or e:IsA("Clouds") then
                    e.Enabled = true
                end
            end)
        end
    end)
end

-- ============================================================
-- SATURATED COLORS (vivid post-processing)
-- ============================================================
local SAT_TAG = "SevenUpSaturatedColors"
local satPulseConn = nil
local satColorFx = nil

local function clearSaturatedColors()
    if satPulseConn then
        pcall(function() satPulseConn:Disconnect() end)
        satPulseConn = nil
    end
    satColorFx = nil
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:GetAttribute(SAT_TAG) then
                pcall(function() e:Destroy() end)
            end
        end
    end)
end

local function enableSaturatedColors()
    clearSaturatedColors()
    local lighting = Lighting
    local color = Instance.new("ColorCorrectionEffect")
    color:SetAttribute(SAT_TAG, true)
    color.Name = "SevenUpColorCorrection"
    color.Saturation = 0.6
    color.Contrast = 0.4
    color.Brightness = 0.05
    color.TintColor = Color3.fromRGB(255, 240, 220)
    color.Parent = lighting
    satColorFx = color

    local bloom = Instance.new("BloomEffect")
    bloom:SetAttribute(SAT_TAG, true)
    bloom.Name = "SevenUpBloom"
    bloom.Intensity = 0.8
    bloom.Size = 24
    bloom.Threshold = 1
    bloom.Parent = lighting

    local atmosphere = Instance.new("Atmosphere")
    atmosphere:SetAttribute(SAT_TAG, true)
    atmosphere.Name = "SevenUpAtmosphere"
    atmosphere.Density = 0.3
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(199, 199, 255)
    atmosphere.Decay = Color3.fromRGB(106, 112, 125)
    atmosphere.Glare = 0.2
    atmosphere.Haze = 1
    atmosphere.Parent = lighting

    local sun = Instance.new("SunRaysEffect")
    sun:SetAttribute(SAT_TAG, true)
    sun.Name = "SevenUpSunRays"
    sun.Intensity = 0.2
    sun.Spread = 0.8
    sun.Parent = lighting

    local dof = Instance.new("DepthOfFieldEffect")
    dof:SetAttribute(SAT_TAG, true)
    dof.Name = "SevenUpDOF"
    dof.FocusDistance = 25
    dof.InFocusRadius = 10
    dof.NearIntensity = 0.2
    dof.FarIntensity = 0.4
    dof.Parent = lighting

    satPulseConn = RunService.Heartbeat:Connect(function()
        if not State.saturatedColorsEnabled then return end
        if satColorFx and satColorFx.Parent then
            satColorFx.Contrast = 0.35 + math.sin(tick() * 2) * 0.05
        end
    end)
end

local function disableSaturatedColors()
    State.saturatedColorsEnabled = false
    clearSaturatedColors()
end

-- ============================================================
-- REMOVE ACCESSORIES (FIXED: functions were referenced but never defined)
-- ============================================================
local removeAccConn = nil
local removeAccChildConn = nil
local removeAccActive = false

local function isHatOrHairAccessory(accessory)
    if not accessory or not accessory:IsA("Accessory") then return false end
    local accessoryType = nil
    pcall(function() accessoryType = accessory.AccessoryType end)
    if accessoryType == Enum.AccessoryType.Hat or accessoryType == Enum.AccessoryType.Hair then
        return true
    end
    for _, item in ipairs(accessory:GetDescendants()) do
        if item:IsA("Attachment")
            and (item.Name == "HatAttachment" or item.Name == "HairAttachment") then
            return true
        end
    end
    local lowerName = tostring(accessory.Name):lower()
    return lowerName:find("hair", 1, true) ~= nil or lowerName:find("hat", 1, true) ~= nil
end

local function removeCharAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        pcall(function()
            if child:IsA("Accessory") then
                local sourceId = nil
                pcall(function() sourceId = child.SourceAssetId end)
                local customHatName = tostring(_G._K7CustomSkinHatName or "")
                -- Only hats and hair are removed. Explicit skin-hat checks
                -- cover catalog accessories whose AccessoryType is delayed.
                if isHatOrHairAccessory(child)
                    or child:GetAttribute("SevenUpCustomSkinItem") == true
                    or child.Name == "SevenUpCustomSkinHat"
                    or tostring(sourceId or "") == "127854264346577"
                    or (customHatName ~= "" and child.Name == customHatName) then
                    child:Destroy()
                end
            end
        end)
    end
end

_G._removeAccStart = function()
    removeAccActive = true
    local function bindCharacter(char)
        if removeAccChildConn then removeAccChildConn:Disconnect(); removeAccChildConn = nil end
        removeCharAccessories(char)
        if char then
            removeAccChildConn = char.ChildAdded:Connect(function(child)
                if not removeAccActive or not child:IsA("Accessory") then return end
                task.defer(function()
                    if child.Parent == char then removeCharAccessories(char) end
                end)
            end)
        end
    end
    bindCharacter(LP.Character)
    if removeAccConn then removeAccConn:Disconnect() end
    removeAccConn = LP.CharacterAdded:Connect(function(char)
        task.wait(0.15)
        bindCharacter(char)
    end)
end

_G._removeAccStop = function()
    removeAccActive = false
    if removeAccConn then removeAccConn:Disconnect(); removeAccConn = nil end
    if removeAccChildConn then removeAccChildConn:Disconnect(); removeAccChildConn = nil end
end

-- ============================================================
-- STRETCH REZ (zombie-style matrix + stretch value)
-- ============================================================
-- Stretch Rez from Zombie Hub (matrix only + stretchValue)
local stretchRezConn = nil

local function enableStretchRez()
    State.stretchedResEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    if stretchRezConn then stretchRezConn:Disconnect() end
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not State.stretchedResEnabled then
            if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
            return
        end
        local cam2 = workspace.CurrentCamera
        if not cam2 then return end
        local val = tonumber(State.stretchValue) or 0.7
        pcall(function()
            cam2.CFrame = cam2.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, val, 0, 0, 0, 1)
        end)
    end)
end

local function disableStretchRez()
    State.stretchedResEnabled = false
    if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam and _G._VezyFOV then cam.FieldOfView = _G._VezyFOV end
    end)
end

-- ============================================================
-- TRYARD ANIMATION (unchanged)
-- ============================================================
local TryardAnims = {
    idle1 = "rbxassetid://133806214992291",
    idle2 = "rbxassetid://94970088341563",
    walk  = "rbxassetid://707897309",
    run   = "rbxassetid://707861613",
    jump  = "rbxassetid://116936326516985",
    fall  = "rbxassetid://116936326516985",
    climb = "rbxassetid://116936326516985",
    swim  = "rbxassetid://116936326516985",
    swimidle = "rbxassetid://116936326516985",
}
task.spawn(function()
    pcall(function() ContentProvider:PreloadAsync({
        TryardAnims.idle1, TryardAnims.idle2, TryardAnims.walk, TryardAnims.run,
        TryardAnims.jump, TryardAnims.fall, TryardAnims.climb, TryardAnims.swim, TryardAnims.swimidle,
    }) end)
end)
local tryardHeartbeatConn = nil
local originalTryardAnims = nil
local function isTryardPackAnim(id) for _,v in pairs(TryardAnims) do if v==id then return true end end return false end
local function saveOriginalTryardAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    local ids = {
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        walk  = g(animate.walk and animate.walk.WalkAnim),
        run   = g(animate.run  and animate.run.RunAnim),
        jump  = g(animate.jump and animate.jump.JumpAnim),
        fall  = g(animate.fall and animate.fall.FallAnim),
        climb = g(animate.climb and animate.climb.ClimbAnim),
        swim  = g(animate.swim and animate.swim.Swim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
    }
    if not isTryardPackAnim(ids.walk) then originalTryardAnims = ids end
end
local function applyTryardAnimPack(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function s(obj,id) if obj then obj.AnimationId=id end end
    s(animate.idle and animate.idle.Animation1, TryardAnims.idle1)
    s(animate.idle and animate.idle.Animation2, TryardAnims.idle2)
    s(animate.walk and animate.walk.WalkAnim, TryardAnims.walk)
    s(animate.run  and animate.run.RunAnim,   TryardAnims.run)
    s(animate.jump and animate.jump.JumpAnim, TryardAnims.jump)
    s(animate.fall and animate.fall.FallAnim, TryardAnims.fall)
    s(animate.climb and animate.climb.ClimbAnim, TryardAnims.climb)
    s(animate.swim and animate.swim.Swim, TryardAnims.swim)
    s(animate.swimidle and animate.swimidle.SwimIdle, TryardAnims.swimidle)
end
local function stopTryardAnim()
    if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect(); tryardHeartbeatConn=nil end
    if originalTryardAnims and LP.Character then
        local animate = LP.Character:FindFirstChild("Animate")
        if animate then
            local function s(obj,id) if obj then obj.AnimationId=id end end
            s(animate.idle and animate.idle.Animation1, originalTryardAnims.idle1)
            s(animate.idle and animate.idle.Animation2, originalTryardAnims.idle2)
            s(animate.walk and animate.walk.WalkAnim, originalTryardAnims.walk)
            s(animate.run  and animate.run.RunAnim,   originalTryardAnims.run)
            s(animate.jump and animate.jump.JumpAnim, originalTryardAnims.jump)
            s(animate.fall and animate.fall.FallAnim, originalTryardAnims.fall)
            s(animate.climb and animate.climb.ClimbAnim, originalTryardAnims.climb)
            s(animate.swim and animate.swim.Swim, originalTryardAnims.swim)
            s(animate.swimidle and animate.swimidle.SwimIdle, originalTryardAnims.swimidle)
        end
    end
end
-- ============================================================
-- ANIMATION PACK SYSTEM (ported from Ace, replaces Tryard only toggle)
-- ============================================================
local selectedAnimationPack = "OFF"
_G._K7SelectedAnimationPack = "OFF"
pcall(function()
    local saved = nil
    if isfile and isfile("K7_AnimPack.txt") and readfile then
        saved = tostring(readfile("K7_AnimPack.txt") or ""):gsub("%s+", "")
    end
    if saved and saved ~= "" then
        selectedAnimationPack = saved
        _G._K7SelectedAnimationPack = saved
    end
end)
local AnimationPackList = {"OFF","Unwalk","Hit Harder","Zombie","Ninja","Knight","Elder","Levitate","Astronaut","Pirate","Toy","Vampire","Werewolf","Rthro","Stylish"}
local AnimationPackIndex = 1

local function _K7SaveAnimPackFile(pack)
    pcall(function()
        if writefile then writefile("K7_AnimPack.txt", tostring(pack or "OFF")) end
    end)
end
local function _K7LoadAnimPackFile()
    local p = nil
    pcall(function()
        if isfile and isfile("K7_AnimPack.txt") and readfile then
            p = readfile("K7_AnimPack.txt")
        end
    end)
    if type(p) == "string" then
        p = p:gsub("%s+", "")
        for _, name in ipairs(AnimationPackList) do
            if name == p then return p end
        end
    end
    return nil
end

local AnimationPacks = {
    ["Zombie"]    = {idle={{"rbxassetid://616158929",1},{"rbxassetid://616158929",1}},walk="rbxassetid://616168032",run="rbxassetid://616163682",jump="rbxassetid://616161997",fall="rbxassetid://616157476",climb="rbxassetid://616156119"},
    ["Ninja"]     = {idle={{"rbxassetid://656117400",1},{"rbxassetid://656117400",1}},walk="rbxassetid://656121766",run="rbxassetid://656118852",jump="rbxassetid://656117878",fall="rbxassetid://656115606",climb="rbxassetid://656114359"},
    ["Knight"]    = {idle={{"rbxassetid://657595757",1},{"rbxassetid://657595757",1}},walk="rbxassetid://657552124",run="rbxassetid://657564596",jump="rbxassetid://658409194",fall="rbxassetid://657600338",climb="rbxassetid://658360781"},
    ["Elder"]     = {idle={{"rbxassetid://845397899",1},{"rbxassetid://845397899",1}},walk="rbxassetid://845403856",run="rbxassetid://845386501",jump="rbxassetid://845398858",fall="rbxassetid://845397673",climb="rbxassetid://845392038"},
    ["Levitate"]  = {idle={{"rbxassetid://616006778",1},{"rbxassetid://616006778",1}},walk="rbxassetid://616013216",run="rbxassetid://616013216",jump="rbxassetid://616008936",fall="rbxassetid://616005863",climb="rbxassetid://616003713"},
    ["Astronaut"] = {idle={{"rbxassetid://891621366",1},{"rbxassetid://891621366",1}},walk="rbxassetid://891636393",run="rbxassetid://891636393",jump="rbxassetid://891627522",fall="rbxassetid://891617961",climb="rbxassetid://891609353"},
    ["Pirate"]    = {idle={{"rbxassetid://750781874",1},{"rbxassetid://750781874",1}},walk="rbxassetid://750785693",run="rbxassetid://750783738",jump="rbxassetid://750782230",fall="rbxassetid://750780242",climb="rbxassetid://750779899"},
    ["Toy"]       = {idle={{"rbxassetid://782841498",1},{"rbxassetid://782841498",1}},walk="rbxassetid://782843345",run="rbxassetid://782842708",jump="rbxassetid://782847020",fall="rbxassetid://782846423",climb="rbxassetid://782843869"},
    ["Vampire"]   = {idle={{"rbxassetid://1083445855",1},{"rbxassetid://1083445855",1}},walk="rbxassetid://1083473930",run="rbxassetid://1083462077",jump="rbxassetid://1083455352",fall="rbxassetid://1083443587",climb="rbxassetid://1083439238"},
    ["Werewolf"]  = {idle={{"rbxassetid://1083195517",1},{"rbxassetid://1083195517",1}},walk="rbxassetid://1083178339",run="rbxassetid://1083216690",jump="rbxassetid://1083218792",fall="rbxassetid://1083189019",climb="rbxassetid://1083182000"},
    ["Rthro"]     = {idle={{"rbxassetid://2510196951",1},{"rbxassetid://2510196951",1}},walk="rbxassetid://2510202577",run="rbxassetid://2510198475",jump="rbxassetid://2510197830",fall="rbxassetid://2510195892",climb="rbxassetid://2510192778"},
    ["Stylish"]   = {idle={{"rbxassetid://616136790",1},{"rbxassetid://616136790",1}},walk="rbxassetid://616146177",run="rbxassetid://616140816",jump="rbxassetid://616139451",fall="rbxassetid://616134815",climb="rbxassetid://616133594"},
}
local HIT_HARDER_ANIMS = {
    idle1="rbxassetid://133806214992291", idle2="rbxassetid://94970088341563",
    walk="rbxassetid://707897309", run="rbxassetid://707861613",
    jump="rbxassetid://116936326516985", fall="rbxassetid://116936326516985",
}
local OriginalAnims = {}
local unwalkEnabled = false
local unwalkSavedAnimate = nil
local hitHarderAnimEnabled = false
local enableUnwalk, disableUnwalk, enableHitHarderAnim, disableHitHarderAnim

local function getAnimate(char)
    char = char or LP.Character
    return char and char:FindFirstChild("Animate") or nil
end
local function stopCurrentAnimations(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0) end) end
end
local function backupAnimations(char)
    local animate = getAnimate(char)
    if not animate or next(OriginalAnims) ~= nil then return end
    local function getId(obj) return obj and obj.AnimationId or nil end
    OriginalAnims = {
        idle1 = getId(animate.idle and animate.idle:FindFirstChild("Animation1")),
        idle2 = getId(animate.idle and animate.idle:FindFirstChild("Animation2")),
        walk  = getId(animate.walk and animate.walk:FindFirstChild("WalkAnim")),
        run   = getId(animate.run  and animate.run:FindFirstChild("RunAnim")),
        jump  = getId(animate.jump and animate.jump:FindFirstChild("JumpAnim")),
        fall  = getId(animate.fall and animate.fall:FindFirstChild("FallAnim")),
        climb = getId(animate.climb and animate.climb:FindFirstChild("ClimbAnim")),
    }
end
local function setAnimId(obj, id) if obj and id then pcall(function() obj.AnimationId = id end) end end
local function reloadAnimate(animate)
    if not animate then return end
    pcall(function() animate.Disabled=true; task.wait(); animate.Disabled=false end)
end
local function resetAnimations()
    local char = LP.Character
    local animate = getAnimate(char)
    if not animate or next(OriginalAnims)==nil then return end
    stopCurrentAnimations(char)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), OriginalAnims.idle1)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), OriginalAnims.idle2)
    setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"),   OriginalAnims.walk)
    setAnimId(animate.run  and animate.run:FindFirstChild("RunAnim"),     OriginalAnims.run)
    setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"),   OriginalAnims.jump)
    setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"),   OriginalAnims.fall)
    setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"),OriginalAnims.climb)
    reloadAnimate(animate)
end
local function applyAnimationPack(packName)
    selectedAnimationPack = packName or "OFF"
    _G._K7SelectedAnimationPack = selectedAnimationPack
    pcall(function() if _K7SaveAnimPackFile then _K7SaveAnimPackFile(selectedAnimationPack) end end)
    local char = LP.Character
    if not char then return false end
    local animate = getAnimate(char)
    if not animate then
        animate = char:FindFirstChild("Animate") or char:WaitForChild("Animate", 3)
    end
    if selectedAnimationPack ~= "Unwalk" and unwalkEnabled then disableUnwalk() end
    if selectedAnimationPack ~= "Hit Harder" then
        hitHarderAnimEnabled = false
        pcall(function()
            local ch = LP.Character
            if ch then stopCurrentAnimations(ch) end
        end)
    end
    if selectedAnimationPack == "Unwalk" then
        resetAnimations()
        enableUnwalk()
        return true
    end
    if selectedAnimationPack == "Hit Harder" then
        disableUnwalk()
        enableHitHarderAnim()
        return true
    end
    if selectedAnimationPack == "OFF" then
        resetAnimations()
        return true
    end
    local pack = AnimationPacks[selectedAnimationPack]
    animate = getAnimate(char)
    if not pack or not animate then return false end
    backupAnimations(char)
    stopCurrentAnimations(char)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), pack.idle[1][1])
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), pack.idle[2][1])
    setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"),   pack.walk)
    setAnimId(animate.run  and animate.run:FindFirstChild("RunAnim"),     pack.run)
    setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"),   pack.jump)
    setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"),   pack.fall)
    setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"),pack.climb)
    reloadAnimate(animate)
    return true
end
enableUnwalk = function()
    unwalkEnabled = true
    local char = LP.Character
    local animate = getAnimate(char)
    if animate then
        if not unwalkSavedAnimate then unwalkSavedAnimate = animate:Clone() end
        stopCurrentAnimations(char)
        animate:Destroy()
    end
end
disableUnwalk = function()
    unwalkEnabled = false
    local char = LP.Character
    if char and not char:FindFirstChild("Animate") and unwalkSavedAnimate then
        unwalkSavedAnimate:Clone().Parent = char
    end
end
enableHitHarderAnim = function()
    hitHarderAnimEnabled = true
    local char = LP.Character
    local animate = getAnimate(char)
    if not animate then return end
    backupAnimations(char)
    stopCurrentAnimations(char)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), HIT_HARDER_ANIMS.idle1)
    setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), HIT_HARDER_ANIMS.idle2)
    setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"),   HIT_HARDER_ANIMS.walk)
    setAnimId(animate.run  and animate.run:FindFirstChild("RunAnim"),     HIT_HARDER_ANIMS.run)
    setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"),   HIT_HARDER_ANIMS.jump)
    setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"),   HIT_HARDER_ANIMS.fall)
    reloadAnimate(animate)
end
disableHitHarderAnim = function()
    hitHarderAnimEnabled = false
    resetAnimations()
    if selectedAnimationPack ~= "OFF" then task.wait(); applyAnimationPack(selectedAnimationPack) end
end
local function syncAnimationPackIndex()
    if _G._K7SelectedAnimationPack and type(_G._K7SelectedAnimationPack) == "string" then
        selectedAnimationPack = _G._K7SelectedAnimationPack
    end
    for i, name in ipairs(AnimationPackList) do
        if name == selectedAnimationPack then
            AnimationPackIndex = i
            return
        end
    end
    selectedAnimationPack = "OFF"
    _G._K7SelectedAnimationPack = "OFF"
    AnimationPackIndex = 1
end

local function applySavedAnimationPackToCharacter(char)
    char = char or LP.Character
    if not char then return end
    OriginalAnims = {}
    unwalkSavedAnimate = nil
    unwalkEnabled = false
    hitHarderAnimEnabled = false

    local disk = nil
    pcall(function() if _K7LoadAnimPackFile then disk = _K7LoadAnimPackFile() end end)
    local pack = disk or _G._K7SelectedAnimationPack or selectedAnimationPack or "OFF"
    if pack == "Hit Harder" and disk and disk ~= "Hit Harder" then
        pack = disk
    end
    selectedAnimationPack = pack
    syncAnimationPackIndex()
    if _G._K7AnimPackRefreshRow then pcall(_G._K7AnimPackRefreshRow) end

    if not pack or pack == "OFF" then return end

    task.spawn(function()
        local ok = false
        for attempt = 1, 10 do
            if not LP.Character or LP.Character ~= char then return end
            selectedAnimationPack = pack
            _G._K7SelectedAnimationPack = pack
            local animate = char:FindFirstChild("Animate") or char:WaitForChild("Animate", 1)
            if animate then
                ok = applyAnimationPack(pack)
                selectedAnimationPack = pack
                _G._K7SelectedAnimationPack = pack
                if ok then
                    print("[7UP duels] Anim pack locked/reapplied:", pack, "attempt", attempt)
                    return
                end
            end
            task.wait(0.3)
        end
        if not ok then
            warn("[7UP duels] Anim pack reapply failed (kept selection):", pack)
        end
    end)
end

local function startTryardAnim()
    State.tryardAnimEnabled = true
    local pack = _G._K7SelectedAnimationPack or selectedAnimationPack
    if pack and pack ~= "OFF" then
        pcall(function() applyAnimationPack(pack) end)
    end
end
local function stopTryardAnim()
    State.tryardAnimEnabled = false
end

LP.CharacterAdded:Connect(function(char)
    task.defer(function()
        task.wait(0.2)
        applySavedAnimationPackToCharacter(char)
    end)
end)
if LP.Character then
    task.spawn(function() applySavedAnimationPackToCharacter(LP.Character) end)
end
_G._K7ReapplyAnimPack = function()
    local pack = _G._K7SelectedAnimationPack or selectedAnimationPack or "OFF"
    selectedAnimationPack = pack
    applySavedAnimationPackToCharacter(LP.Character)
end
_G._K7SetAnimationPack = function(packName)
    packName = packName or "OFF"
    selectedAnimationPack = packName
    _G._K7SelectedAnimationPack = packName
    pcall(function() if _K7SaveAnimPackFile then _K7SaveAnimPackFile(packName) end end)
    State.tryardAnimEnabled = packName ~= "OFF"
    pcall(function() applyAnimationPack(packName) end)
    if _G._K7AnimPackRefreshRow then pcall(_G._K7AnimPackRefreshRow) end
end


-- ============================================================
-- STACK BUTTONS (green theme)
-- ============================================================
local BTN_W=68; local BTN_H=96; local BTN_GAP=10; local COLS=2
local stackButtonScale=1
local stackDefs = {
    {key="aimbot",     label="AIMBOT"},
    {key="antiDesync", label="TP\nBAT"},
    {key="lagger",     label="LAGGER\nSPEED"},
    {key="laggerCarry",label="LAGGER\nCARRY"},
    {key="autoLeft", label="AUTO\nLEFT"},
    {key="autoRight", label="AUTO\nRIGHT"},
    {key="drop",       label="DROP"},
    {key="tpDown",     label="TP\nDOWN"},
    {key="carrySpeed", label="CARRY\nMODE"},
    {key="autoCarry",  label="AUTO\nCARRY"},
}
local function getDefaultStackPos(i)
    local col=(i-1)%COLS
    local row2=math.floor((i-1)/COLS)
    return UDim2.new(1,-(COLS*(BTN_W+BTN_GAP)-BTN_GAP+14)+col*(BTN_W+BTN_GAP),
                     0.5,-(math.ceil(#stackDefs/COLS)*(BTN_H+BTN_GAP)-BTN_GAP)/2+row2*(BTN_H+BTN_GAP))
end

stackWrappers = {}
local function styleSingleMobileButton(wrapper, requestedShape)
    if not wrapper then return end
    local shape = tostring(requestedShape or "Can")
    if shape ~= "Circle" and shape ~= "Square" then shape = "Can" end

    local surface = wrapper:FindFirstChild("SodaCanSurface")
    local top = wrapper:FindFirstChild("IndentedCanTop")
    local logo = wrapper:FindFirstChild("FrontSevenDisc")
    local up = wrapper:FindFirstChild("MiniUp")
    local label = wrapper:FindFirstChild("StackFeatureLabel")
    local surfaceCorner = surface and surface:FindFirstChildOfClass("UICorner")

    if top then top.Visible = shape == "Can" end
    if shape == "Circle" then
        if surface then surface.Size=UDim2.fromOffset(BTN_W,BTN_W); surface.Position=UDim2.new(0,0,0,14) end
        if surfaceCorner then surfaceCorner.CornerRadius=UDim.new(1,0) end
        if logo then logo.Size=UDim2.fromOffset(26,26); logo.Position=UDim2.new(0.5,-22,0,19) end
        if up then up.Position=UDim2.new(0.5,3,0,21); up.TextSize=11 end
        if label then label.Size=UDim2.new(1,-10,0,30); label.Position=UDim2.new(0,5,0,49); label.TextSize=9 end
    elseif shape == "Square" then
        if surface then surface.Size=UDim2.new(1,0,1,-12); surface.Position=UDim2.new(0,0,0,6) end
        if surfaceCorner then surfaceCorner.CornerRadius=UDim.new(0,8) end
        if logo then logo.Size=UDim2.fromOffset(28,28); logo.Position=UDim2.new(0.5,-24,0,13) end
        if up then up.Position=UDim2.new(0.5,4,0,16); up.TextSize=12 end
        if label then label.Size=UDim2.new(1,-8,0,40); label.Position=UDim2.new(0,4,0,48); label.TextSize=11 end
    else
        if surface then surface.Size=UDim2.new(1,0,1,-10); surface.Position=UDim2.new(0,0,0,10) end
        if surfaceCorner then surfaceCorner.CornerRadius=UDim.new(0,14) end
        if logo then logo.Size=UDim2.fromOffset(28,28); logo.Position=UDim2.new(0.5,-24,0,9) end
        if up then up.Position=UDim2.new(0.5,4,0,12); up.TextSize=12 end
        if label then label.Size=UDim2.new(1,-8,0,46); label.Position=UDim2.new(0,4,0,44); label.TextSize=11 end
    end
end

local function applyMobileButtonShape(requestedShape)
    local shape = tostring(requestedShape or "Can")
    if shape ~= "Circle" and shape ~= "Square" then shape = "Can" end
    State.mobileButtonShape = shape
    for _,wrapper in pairs(stackWrappers or {}) do
        styleSingleMobileButton(wrapper, shape)
    end
    return shape
end

local function applyStackButtonScale(value)
    stackButtonScale=math.clamp(tonumber(value) or 1,0.6,1.5)
    for _,wrapper in pairs(stackWrappers or {}) do
        if wrapper then
            local scaleObj=wrapper:FindFirstChild("MobileButtonOnlyScale")
            if scaleObj and scaleObj:IsA("UIScale") then scaleObj.Scale=stackButtonScale end
        end
    end
    return stackButtonScale
end
local STACK_POS_FILE = "sevenup_stack_pos.json"

local function saveStackPositionsNow()
    pcall(function()
        local btnPositions = {}
        for key, wrapper in pairs(stackWrappers) do
            if wrapper and wrapper.Parent and wrapper.Position then
                btnPositions[key] = {
                    XS = wrapper.Position.X.Scale,
                    X  = wrapper.Position.X.Offset,
                    YS = wrapper.Position.Y.Scale,
                    Y  = wrapper.Position.Y.Offset,
                }
            end
        end
        if next(btnPositions) then
            local encoded = HttpService:JSONEncode(btnPositions)
            if _writefile then
                _writefile(STACK_POS_FILE, encoded)
            end
        end
    end)
end

local function loadStackPositionsNow()
    local positions = nil
    pcall(function()
        if _isfile and _isfile(STACK_POS_FILE) and _readfile then
            local raw = _readfile(STACK_POS_FILE)
            if raw and #raw > 2 then
                positions = HttpService:JSONDecode(raw)
            end
        end
    end)
    if type(positions) ~= "table" then return false end
    local applied = 0
    for key, posData in pairs(positions) do
        local wrapper = stackWrappers[key]
        if wrapper and type(posData) == "table" and posData.X ~= nil and posData.Y ~= nil then
            local xs = (posData.XS ~= nil) and posData.XS or 0
            local ys = (posData.YS ~= nil) and posData.YS or 0
            wrapper.Position = UDim2.new(xs, posData.X, ys, posData.Y)
            applied = applied + 1
        end
    end
    return applied > 0
end

-- ============================================================
-- PRESETS (unchanged)
-- ============================================================
local Presets = {}
local PRESET_FILE = "GreenDuelsPresets.json"
local LAST_PRESET_FILE = "GreenDuelsLastPreset.json"

local function buildPresetSnapshot() return {
    normalSpeed=State.normalSpeed, carrySpeed=State.carrySpeed,
    laggerSpeed=State.laggerSpeed, laggerCarrySpeed=State.laggerCarrySpeed,
    stealRadius=Steal.StealRadius, stealDuration=Steal.StealDuration,
    infJump=State.infJumpEnabled, antiRagdoll=State.antiRagdollEnabled,
    medusaCounter=State.medusaCounterEnabled, batCounter=State.batCounterEnabled,
    autoSteal=Steal.AutoStealEnabled,
    autoTP=State.autoTPEnabled, autoTPHeight=State.autoTPHeight,
} end
local function savePresetsFile()
    local ok,enc=pcall(function() return HttpService:JSONEncode(Presets) end)
    if ok then pcall(function() _writefile(PRESET_FILE,enc) end) end
end
local function loadPresetsFile()
    if not _isfile(PRESET_FILE) then return end
    local raw; pcall(function() raw=_readfile(PRESET_FILE) end)
    if raw then
        local ok,dec=pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and dec then Presets=dec end
    end
end
local function saveLastPresetName(name)
    local ok,enc=pcall(function() return HttpService:JSONEncode({lastPreset=name}) end)
    if ok then pcall(function() _writefile(LAST_PRESET_FILE,enc) end) end
end
local function loadLastPresetName()
    if not _isfile(LAST_PRESET_FILE) then return nil end
    local raw; pcall(function() raw=_readfile(LAST_PRESET_FILE) end)
    if raw then
        local ok,dec=pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and dec then return dec.lastPreset end
    end
    return nil
end

local MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
    [Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}

local Conns={autoSteal=nil,antiRag=nil,aimbot=nil,anchor={},progress=nil,batCounter=nil, autoTP=nil}
local h,hrp
local setInfJump,setAntiRag
local setMedusaCounter,setAimbot,setAutoSwing
local setLagger,setLaggerCarry,setDropBrainrot,setInstaGrab
local setNukeOpt,setRemoveAcc,setNoCam
local setupMedusaCounter,stopMedusaCounter
local startAutoSteal,stopAutoSteal
local saveConfig,loadConfig,runDrop,stopDrop,runTPDown
local requestSave
local startBatAimbot,stopBatAimbot,startBatCounter,stopBatCounter,setBatCounter
local stackBtnRefs={}; local keybindBtnRefs={}

    local normalBox,carryBox,laggerBox,laggerCarryBox,uiScaleBox,buttonScaleBox,stealRadBox,stealDurBox,autoTPHeightBox,softStealSpeedBox,softStealRadiusBox
local setHideButtonsToggle, setLockButtonsToggle
local presetListFrame=nil; local presetNameBox=nil; local rebuildPresetList
local toggleSetters = {}
local standDropBtn, jumpDropBtn = nil, nil -- stand removed; kept nil for compat

-- ============================================================
-- THEME COLORS (green)
-- ============================================================
local C = {
    winBg=Color3.fromRGB(0,0,0), winBg2=Color3.fromRGB(6,6,6),
    winBorder=Color3.fromRGB(0,200,80),
    sidebarBg=Color3.fromRGB(0,0,0),
    sidebarDiv=Color3.fromRGB(0,80,40),
    topBg=Color3.fromRGB(4,12,7), topTitle=Color3.fromRGB(0,204,102),
    topSub=Color3.fromRGB(0,160,80),
    topBtn=Color3.fromRGB(0,100,50), topBtnHov=Color3.fromRGB(0,180,80),
    topDivider=Color3.fromRGB(0,80,40),
    tabBarBg=Color3.fromRGB(0,0,0), tabBarDiv=Color3.fromRGB(0,80,40),
    tabIdle=Color3.fromRGB(0,160,80), tabIdleHov=Color3.fromRGB(0,204,102),
    tabActive=Color3.fromRGB(80,255,160), tabActiveBg=Color3.fromRGB(8,30,15),
    tabUnderline=Color3.fromRGB(0,204,102),
    sectionTxt=Color3.fromRGB(0,204,102), sectionDiv=Color3.fromRGB(0,80,40),
    rowBg=Color3.fromRGB(0,0,0), rowBorder=Color3.fromRGB(0,80,40),
    rowLabel=Color3.fromRGB(200,255,225), rowSub=Color3.fromRGB(80,200,130),
    rowValue=Color3.fromRGB(0,204,102), rowHov=Color3.fromRGB(10,30,15),
    inputBg=Color3.fromRGB(6,18,10), inputBorder=Color3.fromRGB(0,100,50),
    inputFocus=Color3.fromRGB(0,204,102), inputTxt=Color3.fromRGB(120,255,190),
    pillOff=Color3.fromRGB(10,40,25), pillOn=Color3.fromRGB(0,204,102),
    dotOff=Color3.fromRGB(25,90,55), dotOn=Color3.fromRGB(10,30,15),
    pillBorder=Color3.fromRGB(20,80,45),
    modeBtnBg=Color3.fromRGB(6,18,10), modeBtnBrd=Color3.fromRGB(20,80,45),
    modeBtnTxt=Color3.fromRGB(0,160,80), modeBtnActBg=Color3.fromRGB(0,204,102),
    modeBtnActTx=Color3.fromRGB(10,30,15),
    chipBg=Color3.fromRGB(6,18,10), chipBorder=Color3.fromRGB(20,80,45),
    chipTxt=Color3.fromRGB(0,160,80),
    btnBg=Color3.fromRGB(8,22,15), btnBorder=Color3.fromRGB(20,80,45),
    btnTxt=Color3.fromRGB(200,255,225), btnHov=Color3.fromRGB(18,40,28),
    stackBg=Color3.fromRGB(8,22,15), stackBrd=Color3.fromRGB(0,100,50),
    stackTxt=Color3.fromRGB(200,255,225), stackActBg=Color3.fromRGB(0,150,75),
    stackActBrd=Color3.fromRGB(0,204,102), stackActTxt=Color3.fromRGB(255,255,255),
    stackDot=Color3.fromRGB(25,90,55), stackDotOn=Color3.fromRGB(0,204,102),
    infoBg=Color3.fromRGB(4,14,9), infoBrd=Color3.fromRGB(0,100,50),
    infoTxt=Color3.fromRGB(0,160,80), infoVal=Color3.fromRGB(0,204,102),
    infoFill=Color3.fromRGB(0,204,102), accent=Color3.fromRGB(0,204,102),
    accentDim=Color3.fromRGB(0,100,50), presetBg=Color3.fromRGB(6,18,10),
    presetBrd=Color3.fromRGB(0,100,50), presetLoad=Color3.fromRGB(0,204,102),
    presetDel=Color3.fromRGB(0,100,50), delBrd=Color3.fromRGB(0,150,75),
    lockOn=Color3.fromRGB(0,204,102), divider=Color3.fromRGB(0,80,40),
}

do
    local cleanupNames = {"VyseSlottedGUI","VyseAsireGUI","VyseAsireHubV4","VyseAsireHubV5","VyseAsireHubV5_1","AsireHubV5_1","AsireHubV5_2","LaitoHubV1","GreenDuelsV1"}
    for _,name in ipairs(cleanupNames) do
        pcall(function() local o=game:GetService("CoreGui"):FindFirstChild(name); if o then o:Destroy() end end)
        pcall(function() local o=LP:WaitForChild("PlayerGui"):FindFirstChild(name); if o then o:Destroy() end end)
    end
end

local function mkCorner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 6); return c end
local function mkStroke(p,col,th) local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end

-- ============================================================
-- AUTO TP (unchanged)
-- ============================================================
local function doAutoTPDown(force)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if hrp.Position.Y < State.autoTPHeight then return end
    end
    hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z) * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

local function startAutoTP()
    if State.autoTPConn then task.cancel(State.autoTPConn); State.autoTPConn = nil end
    if not State.autoTPEnabled then return end
    State.autoTPConn = task.spawn(function()
        while State.autoTPEnabled do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
        State.autoTPConn = nil
    end)
end

local function stopAutoTP()
    State.autoTPEnabled = false
    State._autoTPPauseToken = (State._autoTPPauseToken or 0) + 1
    if State.autoTPConn then task.cancel(State.autoTPConn); State.autoTPConn = nil end
end

_G.AceStopAutoTPForAction = function()
    if not State.autoTPEnabled then return end

    -- Combat/drop actions only pause the worker. The user's ON setting stays
    -- untouched, so autosave cannot accidentally remember Auto TP as OFF.
    State._autoTPPauseToken = (State._autoTPPauseToken or 0) + 1
    local pauseToken = State._autoTPPauseToken
    if State.autoTPConn then task.cancel(State.autoTPConn); State.autoTPConn = nil end

    task.spawn(function()
        -- Let the action set its active flag after calling this helper.
        task.wait(0.12)
        while State.autoTPEnabled
            and pauseToken == State._autoTPPauseToken
            and ((_G.AceAntiDesyncAimbotOn == true) or (State._dropInProgress == true)) do
            task.wait(0.1)
        end
        if State.autoTPEnabled
            and pauseToken == State._autoTPPauseToken
            and not State.autoTPConn then
            startAutoTP()
        end
    end)
end

runTPDown = function()
    if stackBtnRefs and stackBtnRefs.tpDown then
        stackBtnRefs.tpDown.setOn(true)
        task.delay(0.22,function()
            if stackBtnRefs and stackBtnRefs.tpDown then stackBtnRefs.tpDown.setOn(false) end
        end)
    end
    pcall(function() doAutoTPDown(true) end)
end

-- ============================================================

-- ============================================================
-- ============================================================
-- CARRY DETECTION (decoupled; used by Soft Steal latch)
-- Detects steal/carry (WalkSpeed < 25 or Stealing attribute)
-- ============================================================
local _acsWasCarrying = false
local _acsCharacter = nil
local _acsSpawnedAt = 0
local _acsSawNormalSpeed = false
local _acsLowSince = 0
local function isCurrentlyCarrying()
    local char = LP.Character
    if not char then
        _acsWasCarrying = false
        return false
    end
    if char ~= _acsCharacter then
        _acsCharacter = char
        _acsSpawnedAt = tick()
        _acsSawNormalSpeed = false
        _acsLowSince = 0
        _acsWasCarrying = false
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local ws = hum and (hum.WalkSpeed or 16) or 16
    local bySpeed = false
    if ws >= 28 then
        _acsSawNormalSpeed = true
        _acsLowSince = 0
    elseif _acsSawNormalSpeed and tick() - _acsSpawnedAt >= 2 then
        if ws < 25 then
            if _acsLowSince == 0 then _acsLowSince = tick() end
            bySpeed = _acsWasCarrying or tick() - _acsLowSince >= 0.3
        else
            _acsLowSince = 0
            bySpeed = _acsWasCarrying and ws < 28
        end
    end
    local byAttr = false
    local ok, v = pcall(function() return LP:GetAttribute("Stealing") end)
    if ok and v == true then byAttr = true end
    local ok2, v2 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok2 and v2 == true then byAttr = true end
    if not byAttr then
        for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do
            local obj = char:FindFirstChild(name)
            if obj then
                if obj:IsA("BoolValue") and obj.Value then byAttr = true; break end
                if obj:IsA("ObjectValue") and obj.Value then byAttr = true; break end
                if obj:IsA("StringValue") and obj.Value ~= "" then byAttr = true; break end
            end
        end
    end
    _acsWasCarrying = bySpeed or byAttr
    return _acsWasCarrying
end

-- ============================================================
-- ANTI DIE (toggleable from Main tab)
-- ============================================================
local AntiDie = {

    enabled = false,
    loop = nil,
    healthConn = nil,
    charConn = nil,
    lastHealTime = 0,
    invincibleUntil = 0,
    config = {
        healthThreshold = 50,
        invincibilityFrames = 0.75,
        fallDamageProtection = false,
        ragdollProtection = true,
        autoRevive = true,
    },
}

local function _adSuperHeal(hum)
    if not hum or not hum.Parent then return end
    local maxHealth = hum.MaxHealth or 100
    if maxHealth <= 0 then maxHealth = 100 end
    pcall(function()
        hum.Health = maxHealth
        if hum.MaxHealth < maxHealth then hum.MaxHealth = maxHealth end
    end)
    AntiDie.invincibleUntil = tick() + AntiDie.config.invincibilityFrames
    AntiDie.lastHealTime = tick()
    pcall(function()
        local char = hum.Parent
        if not char then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("NumberValue") then
                local name = child.Name:lower()
                if name:find("health") or name:find("hp") or name:find("life") then
                    child.Value = maxHealth
                end
            end
            if child:IsA("BoolValue") and child.Name:lower():find("dead") then
                child.Value = false
            end
        end
    end)
end

local function _adPreventDamage(root, hum)
    if not hum then return end
    -- Always keep health up while Anti Die is running
    if hum.Health < (hum.MaxHealth or 100) then
        _adSuperHeal(hum)
    end
    if tick() < AntiDie.invincibleUntil then
        if hum.Health < (hum.MaxHealth or 100) then
            hum.Health = hum.MaxHealth or 100
        end
    end
    if AntiDie.config.ragdollProtection then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown
            or state == Enum.HumanoidStateType.Dead then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
            _adSuperHeal(hum)
            if root then
                pcall(function()
                    root.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
    end
    -- Full death attempt: always try revive first (Anti Die must work)
    if hum.Health <= 0 then
        _adSuperHeal(hum)
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
        if root then
            pcall(function()
                root.CFrame = CFrame.new(root.Position + Vector3.new(0, 2, 0))
                root.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end
end

local function _adAutoRevive()
    if not AntiDie.config.autoRevive then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum then return end
    if hum.Health <= 0 then
        _adSuperHeal(hum)
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
        if root then
            pcall(function()
                root.CFrame = CFrame.new(root.Position + Vector3.new(0, 3, 0))
                root.AssemblyLinearVelocity = Vector3.zero
            end)
        end
    end
end

function startAntiDie()
    AntiDie.enabled = true
    State.antiDieEnabled = true
    if AntiDie.loop then AntiDie.loop:Disconnect() AntiDie.loop = nil end
    if AntiDie.healthConn then AntiDie.healthConn:Disconnect() AntiDie.healthConn = nil end

    AntiDie.loop = RunService.Heartbeat:Connect(function()
        if not AntiDie.enabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum then return end
        -- Hard keep-alive every frame
        if hum.Health <= 0 then
            _adAutoRevive()
        elseif hum.Health <= AntiDie.config.healthThreshold then
            _adSuperHeal(hum)
        elseif hum.Health < (hum.MaxHealth or 100) then
            _adSuperHeal(hum)
        end
        _adPreventDamage(root, hum)
    end)

    local function attachHealth(char)
        if AntiDie.healthConn then AntiDie.healthConn:Disconnect() AntiDie.healthConn = nil end
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then
            hum = char and char:WaitForChild("Humanoid", 3)
        end
        if not hum then return end
        AntiDie.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if not AntiDie.enabled then return end
            if hum.Health < (hum.MaxHealth or 100) then
                _adSuperHeal(hum)
            end
            if hum.Health <= 0 then
                _adAutoRevive()
            end
        end)
        if hum.Health < (hum.MaxHealth or 100) then _adSuperHeal(hum) end
    end

    if LP.Character then attachHealth(LP.Character) end
    if AntiDie.charConn then AntiDie.charConn:Disconnect() end
    AntiDie.charConn = LP.CharacterAdded:Connect(function(char)
        if not AntiDie.enabled then return end
        task.wait(0.05)
        attachHealth(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then _adSuperHeal(hum) end
    end)
end

function stopAntiDie()
    AntiDie.enabled = false
    State.antiDieEnabled = false
    if AntiDie.loop then
        AntiDie.loop:Disconnect()
        AntiDie.loop = nil
    end
    if AntiDie.healthConn then
        AntiDie.healthConn:Disconnect()
        AntiDie.healthConn = nil
    end
end

-- Supplied Anti Die replacement; keeps the existing 7UP toggle interface.
print("leaked by @bu8f on discord")
local SuppliedAntiDie = { enabled=false, healthConn=nil, diedConn=nil, charConn=nil, humanoid=nil }
local function _suppliedAntiDieDisconnectHumanoid()
    if SuppliedAntiDie.healthConn then SuppliedAntiDie.healthConn:Disconnect(); SuppliedAntiDie.healthConn=nil end
    if SuppliedAntiDie.diedConn then SuppliedAntiDie.diedConn:Disconnect(); SuppliedAntiDie.diedConn=nil end
    SuppliedAntiDie.humanoid=nil
end
local function activateSuppliedAntiDie(char)
    if not SuppliedAntiDie.enabled then return end
    char=char or LP.Character or LP.CharacterAdded:Wait()
    local hum=char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid",3)
    if not hum or not SuppliedAntiDie.enabled then return end
    _suppliedAntiDieDisconnectHumanoid(); SuppliedAntiDie.humanoid=hum
    hum.BreakJointsOnDeath=false; hum:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
    SuppliedAntiDie.healthConn=hum:GetPropertyChangedSignal("Health"):Connect(function()
        if SuppliedAntiDie.enabled and hum.Parent and hum.Health<=0 then hum.Health=hum.MaxHealth end
    end)
    SuppliedAntiDie.diedConn=hum.Died:Connect(function()
        if not SuppliedAntiDie.enabled or not char.Parent then return end
        task.wait(); if not SuppliedAntiDie.enabled or not char.Parent then return end
        local newHum=Instance.new("Humanoid"); newHum.Name="ReplacedHumanoid"
        newHum.BreakJointsOnDeath=false; newHum:SetStateEnabled(Enum.HumanoidStateType.Dead,false); newHum.Parent=char
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject=newHum end
        if hum.Parent then hum:Destroy() end
        if SuppliedAntiDie.enabled then activateSuppliedAntiDie(char) end
    end)
end
function startAntiDie()
    AntiDie.enabled=false
    if AntiDie.loop then AntiDie.loop:Disconnect(); AntiDie.loop=nil end
    if AntiDie.healthConn then AntiDie.healthConn:Disconnect(); AntiDie.healthConn=nil end
    if AntiDie.charConn then AntiDie.charConn:Disconnect(); AntiDie.charConn=nil end
    SuppliedAntiDie.enabled=true; State.antiDieEnabled=true
    if SuppliedAntiDie.charConn then SuppliedAntiDie.charConn:Disconnect() end
    SuppliedAntiDie.charConn=LP.CharacterAdded:Connect(function(char)
        if SuppliedAntiDie.enabled then task.defer(function() activateSuppliedAntiDie(char) end) end
    end)
    task.defer(function() activateSuppliedAntiDie(LP.Character) end)
end
function stopAntiDie()
    SuppliedAntiDie.enabled=false; State.antiDieEnabled=false
    if SuppliedAntiDie.charConn then SuppliedAntiDie.charConn:Disconnect(); SuppliedAntiDie.charConn=nil end
    local hum=SuppliedAntiDie.humanoid; _suppliedAntiDieDisconnectHumanoid()
    if hum and hum.Parent then pcall(function()
        hum.BreakJointsOnDeath=true; hum:SetStateEnabled(Enum.HumanoidStateType.Dead,true)
    end) end
end
print("leaked by @bu8f on discord")


-- Anti-Fling Shield from the supplied source. Normal movement is left alone;
-- only launch velocity above the source's threshold is stabilized.
local AntiFlingShield = {
    enabled = false,
    loop = nil,
    velocityThreshold = 80,
}

local function _afsStabilizeRoot(root)
    if not root or not root.Parent then return end
    local velocity
    local ok = pcall(function() velocity = root.AssemblyLinearVelocity end)
    if not ok or typeof(velocity) ~= "Vector3" then
        local legacyOk
        legacyOk, velocity = pcall(function() return root.Velocity end)
        if not legacyOk or typeof(velocity) ~= "Vector3" then return end
    end
    if velocity.Magnitude <= AntiFlingShield.velocityThreshold then return end

    local stabilized = Vector3.new(0, velocity.Y, 0)
    pcall(function() root.AssemblyLinearVelocity = stabilized end)
    pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
    pcall(function() root.Velocity = stabilized end)
    pcall(function() root.RotVelocity = Vector3.zero end)
end

function startAntiFlingShield()
    AntiFlingShield.enabled = true
    State.antiFlingShieldEnabled = true
    if AntiFlingShield.loop then AntiFlingShield.loop:Disconnect() end
    AntiFlingShield.loop = RunService.Heartbeat:Connect(function()
        if not AntiFlingShield.enabled then return end
        local char = LP.Character
        _afsStabilizeRoot(char and char:FindFirstChild("HumanoidRootPart"))
    end)
end

function stopAntiFlingShield()
    AntiFlingShield.enabled = false
    State.antiFlingShieldEnabled = false
    if AntiFlingShield.loop then
        AntiFlingShield.loop:Disconnect()
        AntiFlingShield.loop = nil
    end
end

-- DROP METHODS (original Jump Drop — Stand removed)
-- ============================================================
local _wfConns = {}
local dropActive = false
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150
local _dropConn = nil

local function runJumpDrop()
    if dropActive then return end
    if _G.AceStopAutoTPForAction then pcall(_G.AceStopAutoTPForAction) end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")

    dropActive = true
    State._dropInProgress = true
    State._dropSuppressGrabUntil = tick() + 1.0
    if stackBtnRefs and stackBtnRefs.drop then stackBtnRefs.drop.setOn(true) end

    -- Stop walk mover immediately so walking/carry speed can't cancel the burst
    pcall(function()
        if hum then
            hum:Move(Vector3.zero, false)
            hum.AutoRotate = true
        end
        for _, inst in ipairs(root:GetChildren()) do
            if inst:IsA("LinearVelocity") or inst:IsA("BodyVelocity") or inst:IsA("VectorForce") then
                inst.Enabled = false
            end
        end
    end)

    local t0 = tick()
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
    -- RenderStepped so we win over the walk Heartbeat mover
    _dropConn = RunService.RenderStepped:Connect(function()
        local cchar = LP.Character
        local r = cchar and cchar:FindFirstChild("HumanoidRootPart")
        if not r then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            dropActive = false
            State._dropInProgress = false
            if stackBtnRefs and stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
            return
        end
        if not dropActive then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            State._dropInProgress = false
            if stackBtnRefs and stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
            return
        end

        -- Keep walk boosters off during drop
        pcall(function()
            for _, inst in ipairs(r:GetChildren()) do
                if inst:IsA("LinearVelocity") then
                    inst.Enabled = false
                    if inst.PlaneVelocity ~= nil then
                        inst.PlaneVelocity = Vector2.zero
                    end
                end
            end
        end)

        if tick() - t0 >= DROP_ASCEND_DURATION then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            pcall(function()
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {cchar}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp)
                if rr then
                    local hum2 = cchar:FindFirstChildOfClass("Humanoid")
                    local off = ((hum2 and hum2.HipHeight) or 2) + (r.Size.Y / 2)
                    r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    r.AssemblyLinearVelocity = Vector3.zero
                    r.AssemblyAngularVelocity = Vector3.zero
                    if r.Velocity then r.Velocity = Vector3.zero end
                end
            end)
            dropActive = false
            State._dropInProgress = false
            State._dropSuppressGrabUntil = tick() + 0.6
            if stackBtnRefs and stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
            return
        end

        -- Force upward burst (works while walking / carrying)
        r.AssemblyLinearVelocity = Vector3.new(0, DROP_ASCEND_SPEED, 0)
        r.AssemblyAngularVelocity = Vector3.zero
        if r.Velocity then
            r.Velocity = Vector3.new(0, DROP_ASCEND_SPEED, 0)
        end
    end)
end

local function runSelectedDrop()
    runJumpDrop()
end

runDrop = runSelectedDrop

LP.CharacterRemoving:Connect(function()
    dropActive = false
    State._dropInProgress = false
    for _, c in ipairs(_wfConns) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif type(c) == "thread" then pcall(coroutine.close, c) end
    end
    _wfConns = {}
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
    stopAntiRagdollNew()
end)

stopDrop = function()
    dropActive = false
    State._dropInProgress = false
    State._dropSuppressGrabUntil = tick() + 0.45
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
    for _, c in ipairs(_wfConns) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif type(c) == "thread" then pcall(coroutine.close, c) end
    end
    _wfConns = {}
    if stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
end

-- ============================================================
-- HEADLESS, KORBLOX, OUTFIT CHANGER FUNCTIONS (green theme applied)
-- ============================================================
(function()
local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"
local DARK_GREY_COLOR = Color3.fromRGB(64, 64, 64)

-- Outfit 1 IDs
local OUTFIT1_HEAD_MESH = "rbxassetid://137685008029440"
local OUTFIT1_SHIRT_ID = 6281968058
local OUTFIT1_PANTS_ID = 1073888653
-- Try Hard 1 IDs
local OUTFIT2_HEAD_MESH = "rbxassetid://11711107876"
local OUTFIT2_SHIRT_ID = 14101026303
local OUTFIT2_PANTS_ID = 4620736485
-- Venom Fit IDs
local OUTFIT3_SHIRT_ID = 13950309240
local OUTFIT3_PANTS_ID = 12421776639

-- Headless
local function applyHeadlessToChar(char, enabled)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    if enabled then
        head.Transparency = 1
        head.CanCollide = false
        local face = head:FindFirstChild("face")
        if face then face:Destroy() end

        local mesh = head:FindFirstChild("HeadlessMesh")
        if not mesh then
            mesh = Instance.new("SpecialMesh")
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = HEADLESS_MESH_ID
            mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
            mesh.Name = "HeadlessMesh"
            mesh.Parent = head
        end

        if not head:GetAttribute("HeadlessHooked") then
            head:SetAttribute("HeadlessHooked", true)
            head:GetPropertyChangedSignal("Transparency"):Connect(function()
                if head:GetAttribute("HeadlessHooked") and head.Transparency ~= 1 then
                    head.Transparency = 1
                end
            end)
            head.ChildAdded:Connect(function(child)
                if head:GetAttribute("HeadlessHooked") and child.Name == "face" and child:IsA("Decal") then
                    child:Destroy()
                end
            end)
        end
    else
        head.Transparency = 0
        head.CanCollide = true
        head:SetAttribute("HeadlessHooked", nil)
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") and child.Name == "HeadlessMesh" then
                child:Destroy()
            end
        end
        local face = head:FindFirstChild("face")
        if not face then
            face = Instance.new("Decal")
            face.Name = "face"
            face.Texture = "rbxassetid://2002749760"
            face.Parent = head
        end
    end
end

-- Korblox
local function applyKorbloxToChar(char, enabled)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if enabled then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local rightLeg = char:FindFirstChild("Right Leg")
            if rightLeg then
                for _, child in ipairs(rightLeg:GetChildren()) do
                    if child:IsA("CharacterMesh") then
                        child:Destroy()
                    end
                end
                local mesh = rightLeg:FindFirstChild("KorbloxMesh")
                if not mesh then
                    for _, child in ipairs(rightLeg:GetChildren()) do
                        if child:IsA("SpecialMesh") then
                            child:Destroy()
                        end
                    end
                    mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = KORBLOX_MESH_ID
                    mesh.TextureId = KORBLOX_TEXTURE_ID
                    mesh.Scale = Vector3.new(1, 1, 1)
                    mesh.Name = "KorbloxMesh"
                    mesh.Parent = rightLeg
                end
                rightLeg.Color = DARK_GREY_COLOR
                if not rightLeg:GetAttribute("KorbloxHooked") then
                    rightLeg:SetAttribute("KorbloxHooked", true)
                    rightLeg:GetPropertyChangedSignal("Color"):Connect(function()
                        if rightLeg:GetAttribute("KorbloxHooked") and rightLeg.Color ~= DARK_GREY_COLOR then
                            rightLeg.Color = DARK_GREY_COLOR
                        end
                    end)
                end
            end
        elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
            local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
            if rightUpperLeg then
                rightUpperLeg.Transparency = 1
                local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
                local rightFoot = char:FindFirstChild("RightFoot")
                if rightLowerLeg then rightLowerLeg.Transparency = 1 end
                if rightFoot then rightFoot.Transparency = 1 end

                local korbloxLeg = char:FindFirstChild("KorbloxLeg")
                if not korbloxLeg then
                    korbloxLeg = Instance.new("Part")
                    korbloxLeg.Name = "KorbloxLeg"
                    korbloxLeg.Size = Vector3.new(1, 2, 1)
                    korbloxLeg.Anchored = false
                    korbloxLeg.CanCollide = false
                    korbloxLeg.Color = DARK_GREY_COLOR
                    korbloxLeg.Parent = char

                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = KORBLOX_MESH_ID
                    mesh.TextureId = KORBLOX_TEXTURE_ID
                    mesh.Scale = Vector3.new(1, 1, 1)
                    mesh.Name = "KorbloxMesh"
                    mesh.Parent = korbloxLeg

                    local weld = Instance.new("Weld")
                    weld.Part0 = rightUpperLeg
                    weld.Part1 = korbloxLeg
                    weld.C0 = CFrame.new(0, -0.8, 0)
                    weld.Name = "KorbloxWeld"
                    weld.Parent = korbloxLeg
                end
            end
        end
    else
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local rightLeg = char:FindFirstChild("Right Leg")
            if rightLeg then
                rightLeg:SetAttribute("KorbloxHooked", nil)
                for _, child in ipairs(rightLeg:GetChildren()) do
                    if child:IsA("SpecialMesh") and child.Name == "KorbloxMesh" then
                        child:Destroy()
                    end
                end
                rightLeg.Color = Color3.fromRGB(255, 255, 255)
            end
        elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
            local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
            if rightUpperLeg then
                rightUpperLeg.Transparency = 0
                local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
                local rightFoot = char:FindFirstChild("RightFoot")
                if rightLowerLeg then rightLowerLeg.Transparency = 0 end
                if rightFoot then rightFoot.Transparency = 0 end
                local korbloxLeg = char:FindFirstChild("KorbloxLeg")
                if korbloxLeg then korbloxLeg:Destroy() end
            end
        end
    end
end

-- Outfit 1
local function applyOutfit1ToChar(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") and child.Name ~= "HeadlessMesh" then
                child:Destroy()
            end
        end
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = OUTFIT1_HEAD_MESH
        mesh.Scale = Vector3.new(1, 1, 1)
        mesh.Name = "OutfitHeadMesh"
        mesh.Parent = head
        head.Transparency = 0
        head.CanCollide = true
    end

    local shirt = char:FindFirstChildOfClass("Shirt")
    if not shirt then
        shirt = Instance.new("Shirt")
        shirt.Parent = char
    end
    shirt.ShirtTemplate = "rbxassetid://" .. tostring(OUTFIT1_SHIRT_ID)

    local pants = char:FindFirstChildOfClass("Pants")
    if not pants then
        pants = Instance.new("Pants")
        pants.Parent = char
    end
    pants.PantsTemplate = "rbxassetid://" .. tostring(OUTFIT1_PANTS_ID)

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            child:Destroy()
        end
    end

    local redColor = Color3.fromRGB(255, 0, 0)
    local blackColor = Color3.fromRGB(0, 0, 0)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "Head" or part.Name:find("Torso") or part.Name:find("Arm") then
                part.Color = redColor
            elseif part.Name:find("Leg") then
                part.Color = blackColor
            end
        end
    end
end

-- Try Hard 1 Fit
local function applyOutfit2ToChar(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") and child.Name ~= "HeadlessMesh" then
                child:Destroy()
            end
        end
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = OUTFIT2_HEAD_MESH
        mesh.Scale = Vector3.new(1, 1, 1)
        mesh.Name = "OutfitHeadMesh"
        mesh.Parent = head
        head.Transparency = 0
        head.CanCollide = true
    end

    local shirt = char:FindFirstChildOfClass("Shirt")
    if not shirt then
        shirt = Instance.new("Shirt")
        shirt.Parent = char
    end
    shirt.ShirtTemplate = "rbxassetid://" .. tostring(OUTFIT2_SHIRT_ID)

    local pants = char:FindFirstChildOfClass("Pants")
    if not pants then
        pants = Instance.new("Pants")
        pants.Parent = char
    end
    pants.PantsTemplate = "rbxassetid://" .. tostring(OUTFIT2_PANTS_ID)

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            child:Destroy()
        end
    end
end

-- Venom Fit
local function applyOutfit3ToChar(char)
    if not char then return end
    local shirt = char:FindFirstChildOfClass("Shirt")
    if not shirt then
        shirt = Instance.new("Shirt")
        shirt.Parent = char
    end
    shirt.ShirtTemplate = "rbxassetid://" .. tostring(OUTFIT3_SHIRT_ID)

    local pants = char:FindFirstChildOfClass("Pants")
    if not pants then
        pants = Instance.new("Pants")
        pants.Parent = char
    end
    pants.PantsTemplate = "rbxassetid://" .. tostring(OUTFIT3_PANTS_ID)

    local blackColor = Color3.fromRGB(10, 10, 10)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = blackColor
        end
    end
end

-- Custom Skins variants supplied by the user. Both use the 7UP hat; each
-- variant keeps its own resolved asset cache so switching is immediate.
local CUSTOM_SKIN_VARIANTS = {
    [1] = {
        name = "7UP SKIN",
        hatId = "127854264346577",
        shirtId = 10692517352,
        pantsId = 6294855872,
        headId = 101106043267082,
        bodyColor = Color3.fromRGB(0, 88, 39),
    },
    [2] = {
        name = "BART SKIN",
        hatId = "127854264346577",
        shirtId = 135553740919809,
        pantsId = 5309277694,
        headId = 18913474191,
        bodyColor = Color3.fromRGB(245, 205, 45),
    },
}
local CUSTOM_SKIN_HAT_ID = CUSTOM_SKIN_VARIANTS[1].hatId
local CUSTOM_SKIN_SHIRT_ID = CUSTOM_SKIN_VARIANTS[1].shirtId
local CUSTOM_SKIN_PANTS_ID = CUSTOM_SKIN_VARIANTS[1].pantsId
local CUSTOM_SKIN_HEAD_ID = CUSTOM_SKIN_VARIANTS[1].headId
local CUSTOM_SKIN_TAG = "SevenUpCustomSkinItem"
local CUSTOM_SKIN_SNAPSHOT_ATTR = "SevenUpCustomSkinSnapshot"
local CUSTOM_SKIN_SHIRT_ATTR = "SevenUpOriginalShirt"
local CUSTOM_SKIN_PANTS_ATTR = "SevenUpOriginalPants"

local CustomSkinAssetCache = {
    [1] = {shirtTemplate=nil, pantsTemplate=nil, hatTemplate=nil, lastAttempt=0},
    [2] = {shirtTemplate=nil, pantsTemplate=nil, hatTemplate=nil, lastAttempt=0},
}
local CustomSkinAssets = CustomSkinAssetCache[1]
local CustomSkinSnapshots = setmetatable({}, {__mode = "k"})
_G.SevenUpCustomSkinDescriptions = _G.SevenUpCustomSkinDescriptions or setmetatable({}, {__mode = "k"})
local CustomSkinDescriptions = _G.SevenUpCustomSkinDescriptions
local CUSTOM_SKIN_GREEN = CUSTOM_SKIN_VARIANTS[1].bodyColor

local function syncCustomSkinVariant(variantIndex)
    variantIndex = tonumber(variantIndex) == 2 and 2 or 1
    State.customSkinVariant = variantIndex
    local variant = CUSTOM_SKIN_VARIANTS[variantIndex]
    CUSTOM_SKIN_HAT_ID = variant.hatId
    CUSTOM_SKIN_SHIRT_ID = variant.shirtId
    CUSTOM_SKIN_PANTS_ID = variant.pantsId
    CUSTOM_SKIN_HEAD_ID = variant.headId
    CUSTOM_SKIN_GREEN = variant.bodyColor
    CustomSkinAssets = CustomSkinAssetCache[variantIndex]
    return variant
end

syncCustomSkinVariant(State.customSkinVariant)

local function getCustomSkinAccessoryProperty()
    local property = "HatAccessory"
    pcall(function()
        local info = MarketplaceService:GetProductInfo(tonumber(CUSTOM_SKIN_HAT_ID))
        local propertyByType = {
            [8] = "HatAccessory", [41] = "HairAccessory", [42] = "FaceAccessory",
            [43] = "NeckAccessory", [44] = "ShouldersAccessory", [45] = "FrontAccessory",
            [46] = "BackAccessory", [47] = "WaistAccessory",
        }
        property = propertyByType[tonumber(info.AssetTypeId)] or property
        _G._K7CustomSkinHatName = tostring(info.Name or "")
    end)
    return property
end

local function appendCustomSkinAccessory(description)
    local property = getCustomSkinAccessoryProperty()
    local ok = pcall(function()
        local current = tostring(description[property] or "")
        local found = false
        for id in current:gmatch("[^,]+") do
            if id:gsub("%s+", "") == CUSTOM_SKIN_HAT_ID then found = true; break end
        end
        if not found then
            description[property] = current == "" and CUSTOM_SKIN_HAT_ID
                or (current .. "," .. CUSTOM_SKIN_HAT_ID)
        end
    end)
    if not ok then
        local current = tostring(description.HatAccessory or "")
        if not current:find(CUSTOM_SKIN_HAT_ID, 1, true) then
            description.HatAccessory = current == "" and CUSTOM_SKIN_HAT_ID
                or (current .. "," .. CUSTOM_SKIN_HAT_ID)
        end
    end
end

local CUSTOM_SKIN_ACCESSORY_PROPERTIES = {
    "HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
    "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
}

local function stripCustomSkinAccessory(description)
    if not description then return end
    for _, property in ipairs(CUSTOM_SKIN_ACCESSORY_PROPERTIES) do
        pcall(function()
            if property == "HatAccessory" or property == "HairAccessory" then
                description[property] = ""
                return
            end
            local kept = {}
            for id in tostring(description[property] or ""):gmatch("[^,]+") do
                local clean = id:gsub("%s+", "")
                if clean ~= "" and clean ~= CUSTOM_SKIN_HAT_ID then
                    table.insert(kept, clean)
                end
            end
            description[property] = table.concat(kept, ",")
        end)
    end
end

local function applyCustomSkinGreen(char, enabled)
    if not char then return end
    local bodyColors = char:FindFirstChildOfClass("BodyColors")
    local colorProperties = {"HeadColor3","LeftArmColor3","LeftLegColor3","RightArmColor3","RightLegColor3","TorsoColor3"}
    if bodyColors then
        for _, property in ipairs(colorProperties) do
            local attribute = "SevenUpOriginal" .. property
            if enabled then
                if bodyColors:GetAttribute(attribute) == nil then
                    bodyColors:SetAttribute(attribute, bodyColors[property])
                end
                bodyColors[property] = CUSTOM_SKIN_GREEN
            else
                local original = bodyColors:GetAttribute(attribute)
                if typeof(original) == "Color3" then bodyColors[property] = original end
                bodyColors:SetAttribute(attribute, nil)
            end
        end
    end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local attribute = "SevenUpOriginalBodyColor"
            if enabled then
                if part:GetAttribute(attribute) == nil then part:SetAttribute(attribute, part.Color) end
                part.Color = CUSTOM_SKIN_GREEN
            else
                local original = part:GetAttribute(attribute)
                if typeof(original) == "Color3" then part.Color = original end
                part:SetAttribute(attribute, nil)
            end
        end
    end
end

local function absorbCustomSkinAssets(root)
    if not root then return end
    local shirt = root:IsA("Shirt") and root or root:FindFirstChildWhichIsA("Shirt", true)
    local pants = root:IsA("Pants") and root or root:FindFirstChildWhichIsA("Pants", true)
    local hat = root:IsA("Accessory") and root or root:FindFirstChildWhichIsA("Accessory", true)
    if shirt and shirt.ShirtTemplate ~= "" then
        CustomSkinAssets.shirtTemplate = shirt.ShirtTemplate
    end
    if pants and pants.PantsTemplate ~= "" then
        CustomSkinAssets.pantsTemplate = pants.PantsTemplate
    end
    if hat and not CustomSkinAssets.hatTemplate then
        _G._K7CustomSkinHatName = hat.Name
        CustomSkinAssets.hatTemplate = hat:Clone()
        CustomSkinAssets.hatTemplate.Parent = nil
    end
end

local function loadCustomSkinAssetObject(assetId)
    local objects = nil
    pcall(function()
        objects = game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if type(objects) == "table" then
        for _, object in ipairs(objects) do
            absorbCustomSkinAssets(object)
        end
        for _, object in ipairs(objects) do
            pcall(function() object:Destroy() end)
        end
    end
    if not CustomSkinAssets.hatTemplate and tostring(assetId) == CUSTOM_SKIN_HAT_ID then
        local container = nil
        pcall(function() container = InsertService:LoadAsset(tonumber(assetId)) end)
        if container then
            absorbCustomSkinAssets(container)
            container:Destroy()
        end
    end
end

local function resolveCustomSkinAssets()
    if CustomSkinAssets.shirtTemplate
        and CustomSkinAssets.pantsTemplate
        and CustomSkinAssets.hatTemplate then
        return CustomSkinAssets
    end
    local now = tick()
    if now - (CustomSkinAssets.lastAttempt or 0) < 2 then
        return CustomSkinAssets
    end
    CustomSkinAssets.lastAttempt = now

    -- A HumanoidDescription resolves catalog clothing IDs to their real
    -- templates, which is more reliable than using a catalog ID as a texture.
    local previewModel = nil
    pcall(function()
        local description = Instance.new("HumanoidDescription")
        description.Shirt = CUSTOM_SKIN_SHIRT_ID
        description.Pants = CUSTOM_SKIN_PANTS_ID
        description.Head = CUSTOM_SKIN_HEAD_ID
        appendCustomSkinAccessory(description)
        previewModel = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
        description:Destroy()
    end)
    if previewModel then
        absorbCustomSkinAssets(previewModel)
        previewModel:Destroy()
    end

    if not CustomSkinAssets.shirtTemplate then loadCustomSkinAssetObject(CUSTOM_SKIN_SHIRT_ID) end
    if not CustomSkinAssets.pantsTemplate then loadCustomSkinAssetObject(CUSTOM_SKIN_PANTS_ID) end
    if not CustomSkinAssets.hatTemplate then loadCustomSkinAssetObject(CUSTOM_SKIN_HAT_ID) end

    CustomSkinAssets.shirtTemplate = CustomSkinAssets.shirtTemplate
        or ("rbxassetid://" .. tostring(CUSTOM_SKIN_SHIRT_ID))
    CustomSkinAssets.pantsTemplate = CustomSkinAssets.pantsTemplate
        or ("rbxassetid://" .. tostring(CUSTOM_SKIN_PANTS_ID))
    return CustomSkinAssets
end

local function removeTaggedCustomSkinItems(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:GetAttribute(CUSTOM_SKIN_TAG) == true then
            child:Destroy()
        end
    end
end

local function snapshotCustomSkinClothing(char)
    if CustomSkinSnapshots[char] then return CustomSkinSnapshots[char] end
    local snapshot = {shirts = {}, pants = {}, accessoryNames = {}}
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") and child:GetAttribute(CUSTOM_SKIN_TAG) ~= true then
            local name = tostring(child.Name)
            snapshot.accessoryNames[name] = (snapshot.accessoryNames[name] or 0) + 1
        end
    end
    _G._K7OriginalAccessoryNames = _G._K7OriginalAccessoryNames
        or setmetatable({}, {__mode = "k"})
    _G._K7OriginalAccessoryNames[char] = snapshot.accessoryNames
    if char:GetAttribute(CUSTOM_SKIN_SNAPSHOT_ATTR) == true then
        local oldShirt = char:GetAttribute(CUSTOM_SKIN_SHIRT_ATTR)
        local oldPants = char:GetAttribute(CUSTOM_SKIN_PANTS_ATTR)
        if type(oldShirt) == "string" and oldShirt ~= "" then
            local shirt = Instance.new("Shirt")
            shirt.ShirtTemplate = oldShirt
            table.insert(snapshot.shirts, shirt)
        end
        if type(oldPants) == "string" and oldPants ~= "" then
            local pants = Instance.new("Pants")
            pants.PantsTemplate = oldPants
            table.insert(snapshot.pants, pants)
        end
    else
        local savedShirt, savedPants = "", ""
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Shirt") and child:GetAttribute(CUSTOM_SKIN_TAG) ~= true then
                table.insert(snapshot.shirts, child:Clone())
                if savedShirt == "" then savedShirt = child.ShirtTemplate end
            elseif child:IsA("Pants") and child:GetAttribute(CUSTOM_SKIN_TAG) ~= true then
                table.insert(snapshot.pants, child:Clone())
                if savedPants == "" then savedPants = child.PantsTemplate end
            end
        end
        char:SetAttribute(CUSTOM_SKIN_SNAPSHOT_ATTR, true)
        char:SetAttribute(CUSTOM_SKIN_SHIRT_ATTR, savedShirt)
        char:SetAttribute(CUSTOM_SKIN_PANTS_ATTR, savedPants)
    end
    CustomSkinSnapshots[char] = snapshot
    return snapshot
end

local function clearCharacterClothing(char)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Shirt") or child:IsA("Pants") then
            child:Destroy()
        end
    end
end

local function attachCustomSkinHat(char, assets)
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            if child:GetAttribute(CUSTOM_SKIN_TAG) == true then return end
            local sourceId = nil
            pcall(function() sourceId = child.SourceAssetId end)
            local matchingName = assets.hatTemplate and child.Name == assets.hatTemplate.Name
            if tostring(sourceId or "") == CUSTOM_SKIN_HAT_ID or matchingName then
                child:SetAttribute(CUSTOM_SKIN_TAG, true)
                return
            end
        end
    end
    if not assets.hatTemplate then return end
    local hat = assets.hatTemplate:Clone()
    hat.Name = "SevenUpCustomSkinHat"
    hat:SetAttribute(CUSTOM_SKIN_TAG, true)
    for _, child in ipairs(hat:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") then child:Destroy() end
        if child:IsA("BasePart") then
            child.Anchored = false
            child.CanCollide = false
            child.Massless = true
        end
    end
    local added = pcall(function() humanoid:AddAccessory(hat) end)
    if not added or not hat.Parent then hat.Parent = char end

    -- Some executors parent catalog accessories without creating the weld.
    -- Repair it from matching attachments so the hat is visible on both rigs.
    local handle = hat:FindFirstChild("Handle") or hat:FindFirstChildWhichIsA("BasePart", true)
    if handle and not handle:FindFirstChild("AccessoryWeld") then
        local handleAttachment = handle:FindFirstChildWhichIsA("Attachment")
        local bodyAttachment = nil
        if handleAttachment then
            for _, item in ipairs(char:GetDescendants()) do
                if item:IsA("Attachment") and item.Name == handleAttachment.Name
                    and not item:IsDescendantOf(hat) then
                    bodyAttachment = item
                    break
                end
            end
        end
        if handleAttachment and bodyAttachment and bodyAttachment.Parent:IsA("BasePart") then
            handle.CFrame = bodyAttachment.WorldCFrame * handleAttachment.CFrame:Inverse()
            local weld = Instance.new("WeldConstraint")
            weld.Name = "SevenUpSkinWeld"
            weld.Part0 = handle
            weld.Part1 = bodyAttachment.Parent
            weld.Parent = handle
        end
    end
end

local function applyCustomSkinDescription(char, assets)
    syncCustomSkinVariant(State.customSkinVariant)
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if not CustomSkinDescriptions[char] then
        local original = nil
        pcall(function() original = humanoid:GetAppliedDescription():Clone() end)
        if original then CustomSkinDescriptions[char] = original end
    end
    local original = CustomSkinDescriptions[char]
    if not original then return false end

    local description = original:Clone()
    description.Shirt = CUSTOM_SKIN_SHIRT_ID
    description.Pants = CUSTOM_SKIN_PANTS_ID
    description.Head = CUSTOM_SKIN_HEAD_ID
    description.HeadColor = CUSTOM_SKIN_GREEN
    description.LeftArmColor = CUSTOM_SKIN_GREEN
    description.LeftLegColor = CUSTOM_SKIN_GREEN
    description.RightArmColor = CUSTOM_SKIN_GREEN
    description.RightLegColor = CUSTOM_SKIN_GREEN
    description.TorsoColor = CUSTOM_SKIN_GREEN
    if State.removeAcc then
        stripCustomSkinAccessory(description)
    else
        appendCustomSkinAccessory(description)
    end
    local applied = pcall(function() humanoid:ApplyDescription(description) end)
    description:Destroy()
    if not applied then return false end

    local foundHat = false
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Shirt") or child:IsA("Pants") then
            child:SetAttribute(CUSTOM_SKIN_TAG, true)
        elseif child:IsA("Accessory") then
            local sourceId = nil
            pcall(function() sourceId = child.SourceAssetId end)
            local matchingName = assets.hatTemplate and child.Name == assets.hatTemplate.Name
            if tostring(sourceId or "") == CUSTOM_SKIN_HAT_ID or matchingName then
                child:SetAttribute(CUSTOM_SKIN_TAG, true)
                foundHat = true
            end
        end
    end
    if not State.removeAcc and not foundHat then attachCustomSkinHat(char, assets) end
    if State.removeAcc then removeCharAccessories(char) end
    return true
end

local function restoreCustomSkinDescription(char)
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local original = char and CustomSkinDescriptions[char]
    if not humanoid or not original then return false end
    local restored = pcall(function() humanoid:ApplyDescription(original) end)
    if restored then CustomSkinDescriptions[char] = nil end
    return restored
end

local function applyCustomSkinToChar(char)
    if not char then return end
    syncCustomSkinVariant(State.customSkinVariant)
    local assets = resolveCustomSkinAssets()
    snapshotCustomSkinClothing(char)
    if not applyCustomSkinDescription(char, assets) then
        clearCharacterClothing(char)

        local shirt = Instance.new("Shirt")
        shirt.Name = "SevenUpCustomSkinShirt"
        shirt.ShirtTemplate = assets.shirtTemplate
        shirt:SetAttribute(CUSTOM_SKIN_TAG, true)
        shirt.Parent = char

        local pants = Instance.new("Pants")
        pants.Name = "SevenUpCustomSkinPants"
        pants.PantsTemplate = assets.pantsTemplate
        pants:SetAttribute(CUSTOM_SKIN_TAG, true)
        pants.Parent = char

        if not State.removeAcc then attachCustomSkinHat(char, assets) end
    end
    applyCustomSkinGreen(char, true)
    if State.removeAcc then removeCharAccessories(char) end
end

local function restoreCustomSkinFromChar(char)
    if not char then return end
    local snapshot = CustomSkinSnapshots[char]
    local descriptionRestored = restoreCustomSkinDescription(char)
    removeTaggedCustomSkinItems(char)
    if snapshot and not descriptionRestored then
        clearCharacterClothing(char)
        for _, shirt in ipairs(snapshot.shirts) do shirt:Clone().Parent = char end
        for _, pants in ipairs(snapshot.pants) do pants:Clone().Parent = char end
    end
    CustomSkinSnapshots[char] = nil
    if _G._K7OriginalAccessoryNames then _G._K7OriginalAccessoryNames[char] = nil end
    applyCustomSkinGreen(char, false)
    char:SetAttribute(CUSTOM_SKIN_SNAPSHOT_ATTR, nil)
    char:SetAttribute(CUSTOM_SKIN_SHIRT_ATTR, nil)
    char:SetAttribute(CUSTOM_SKIN_PANTS_ATTR, nil)
    if State.removeAcc then removeCharAccessories(char) end
end

local function renderCustomSkinPreview(viewport, variantIndex)
    if not viewport or not viewport.Parent then return false end
    local variant = syncCustomSkinVariant(variantIndex or State.customSkinVariant)
    viewport:ClearAllChildren()
    local camera = Instance.new("Camera")
    camera.Name = "SkinPreviewCamera"
    camera.FieldOfView = 32
    camera.Parent = viewport
    viewport.CurrentCamera = camera
    local world = Instance.new("WorldModel")
    world.Name = "SkinPreviewWorld"
    world.Parent = viewport

    local source = LP.Character
    local sourceHumanoid = source and source:FindFirstChildOfClass("Humanoid")
    local rigType = sourceHumanoid and sourceHumanoid.RigType or Enum.HumanoidRigType.R15
    local description = nil
    if sourceHumanoid then
        pcall(function()
            local original = CustomSkinDescriptions[source]
            description = original and original:Clone() or sourceHumanoid:GetAppliedDescription():Clone()
        end)
    end
    if not description then
        pcall(function() description = Players:GetHumanoidDescriptionFromUserId(LP.UserId) end)
    end
    if description then
        description.Shirt = variant.shirtId
        description.Pants = variant.pantsId
        description.Head = variant.headId
        description.HeadColor = variant.bodyColor
        description.LeftArmColor = variant.bodyColor
        description.LeftLegColor = variant.bodyColor
        description.RightArmColor = variant.bodyColor
        description.RightLegColor = variant.bodyColor
        description.TorsoColor = variant.bodyColor
        if not State.removeAcc then appendCustomSkinAccessory(description) end
    end

    local preview = nil
    -- When this variant is equipped, cloning the live character is the most
    -- accurate preview because it includes every locally applied skin asset.
    if source and State.customSkinEnabled then
        local wasArchivable = source.Archivable
        source.Archivable = true
        pcall(function() preview = source:Clone() end)
        source.Archivable = wasArchivable
    end
    -- Primary preview path for an unequipped variant.
    if not preview and description then
        pcall(function()
            preview = Players:CreateHumanoidModelFromDescription(description, rigType)
        end)
    end
    -- Roblox occasionally refuses one catalog asset on the first call. Build
    -- a base avatar and apply the description to it as a second path.
    if not preview then
        pcall(function() preview = Players:CreateHumanoidModelFromUserId(LP.UserId) end)
        local fallbackHumanoid = preview and preview:FindFirstChildOfClass("Humanoid")
        if fallbackHumanoid and description then
            pcall(function() fallbackHumanoid:ApplyDescription(description) end)
        end
    end

    if preview and description and not State.customSkinEnabled then
        local previewHumanoid = preview:FindFirstChildOfClass("Humanoid")
        if previewHumanoid then pcall(function() previewHumanoid:ApplyDescription(description) end) end
    end
    if description then description:Destroy() end

    if preview then
        -- Enforce the visible clothing/body tint even if Roblox only applied a
        -- partial HumanoidDescription. This is especially important for large
        -- layered-catalog IDs on some executors.
        local assets = resolveCustomSkinAssets()
        local shirt = preview:FindFirstChildOfClass("Shirt") or Instance.new("Shirt")
        shirt.ShirtTemplate = assets.shirtTemplate or ("rbxassetid://" .. tostring(variant.shirtId))
        shirt.Parent = preview
        local pants = preview:FindFirstChildOfClass("Pants") or Instance.new("Pants")
        pants.PantsTemplate = assets.pantsTemplate or ("rbxassetid://" .. tostring(variant.pantsId))
        pants.Parent = preview
        applyCustomSkinGreen(preview, true)
        if not State.removeAcc then attachCustomSkinHat(preview, assets) end
    end

    if not preview then
        -- Last-resort visual preview: catalog thumbnails still show all three
        -- selected skin pieces instead of leaving an empty black preview.
        camera:Destroy()
        world:Destroy()
        viewport.CurrentCamera = nil
        local ids = {variant.headId, variant.shirtId, variant.pantsId}
        local positions = {
            UDim2.new(0.25,-48,0.5,-48),
            UDim2.new(0.5,-48,0.5,-48),
            UDim2.new(0.75,-48,0.5,-48),
        }
        for index, assetId in ipairs(ids) do
            local tile = Instance.new("ImageLabel", viewport)
            tile.Size = UDim2.new(0,96,0,96)
            tile.Position = positions[index]
            tile.BackgroundColor3 = currentColorScheme.modeBtnBg
            tile.BackgroundTransparency = 0.12
            tile.BorderSizePixel = 0
            tile.Image = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=420&h=420"
            tile.ScaleType = Enum.ScaleType.Fit
            tile.ZIndex = 124
            Instance.new("UICorner", tile).CornerRadius = UDim.new(0,16)
        end
        return true
    end

    preview.Name = "CustomSkinPreview"
    preview.Parent = world
    for _, child in ipairs(preview:GetDescendants()) do
        if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("Tool") then
            child:Destroy()
        elseif child:IsA("BasePart") then
            child.Anchored = true
            child.CanCollide = false
        end
    end
    local previewHumanoid = preview:FindFirstChildOfClass("Humanoid")
    if previewHumanoid then
        previewHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end

    -- Put the avatar at a fixed origin facing the preview camera. This keeps
    -- it visible during dragging and avoids cloning the player's world yaw.
    preview:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
    local boxCFrame, boxSize = preview:GetBoundingBox()
    local target = boxCFrame.Position + Vector3.new(0, boxSize.Y * 0.04, 0)
    local distance = math.max(boxSize.X, boxSize.Y, boxSize.Z) * 1.35
    camera.CFrame = CFrame.new(target + Vector3.new(0, boxSize.Y * 0.01, distance), target)
    return true
end

-- Master apply function
local function applyCharterToChar(char)
    if not char then return end
    -- Apply/restore the full skin description first, then layer the local
    -- Headless and Korblox variants on top so they are not overwritten.
    if State.customSkinEnabled then
        applyCustomSkinToChar(char)
    else
        restoreCustomSkinFromChar(char)
    end
    if State.headlessEnabled then
        applyHeadlessToChar(char, true)
    else
        applyHeadlessToChar(char, false)
    end
    if State.korbloxEnabled then
        applyKorbloxToChar(char, true)
    else
        applyKorbloxToChar(char, false)
    end
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.15)
    applyCharterToChar(char)
end)

-- Repair clothing/accessories if the game refreshes the avatar appearance
-- after CharacterAdded. This stays idle while the variant is disabled.
task.spawn(function()
    while task.wait(1) do
        if State.customSkinEnabled then
            local char = LP.Character
            if char then
                local customShirts, customPants, customHats = 0, 0, 0
                local allShirts, allPants = 0, 0
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("Shirt") then
                        allShirts = allShirts + 1
                        if child:GetAttribute(CUSTOM_SKIN_TAG) == true then customShirts = customShirts + 1 end
                    elseif child:IsA("Pants") then
                        allPants = allPants + 1
                        if child:GetAttribute(CUSTOM_SKIN_TAG) == true then customPants = customPants + 1 end
                    elseif child:IsA("Accessory") and child:GetAttribute(CUSTOM_SKIN_TAG) == true then
                        customHats = customHats + 1
                    end
                end
                local needsRepair = customShirts ~= 1 or customPants ~= 1
                    or allShirts ~= 1 or allPants ~= 1
                    or (not State.removeAcc and CustomSkinAssets.hatTemplate and customHats ~= 1)
                    or (State.removeAcc and customHats ~= 0)
                if needsRepair then pcall(applyCustomSkinToChar, char) end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if char then
        local sig = table.concat({
            State.headlessEnabled and "H" or "h",
            State.korbloxEnabled and "K" or "k",
            State.customSkinEnabled and "C" or "c",
            State.outfit1Applied and "1" or "0",
            State.outfit2Applied and "2" or "0",
            State.outfit3Applied and "3" or "0",
            char.Name,
        }, "")
        if sig ~= _G._lastCharterSig then
            _G._lastCharterSig = sig
            applyCharterToChar(char)
        end
    end
end)

-- ============================================================
-- FUNCTION TO UPDATE ALL COLORS (green)
-- ============================================================
local function updateAllColors(scheme, forcedOld)
    local oldScheme = forcedOld or currentColorScheme
    currentColorScheme = scheme

    local function colorKey(col)
        return math.round(col.R*255)..","..math.round(col.G*255)..","..math.round(col.B*255)
    end

    local bgMap, txtMap, strokeMap = {}, {}, {}
    for prop, oldColor in pairs(oldScheme) do
        local newColor = scheme[prop]
        if newColor and typeof(oldColor) == "Color3" and typeof(newColor) == "Color3" then
            local k = colorKey(oldColor)
            bgMap[k] = newColor
            txtMap[k] = newColor
            strokeMap[k] = newColor
        end
    end

    local gui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("SevenUpDuelsV2")
    if gui then
        for _, obj in ipairs(gui:GetDescendants()) do
            pcall(function()
                if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("ScrollingFrame") then
                    local newBg = bgMap[colorKey(obj.BackgroundColor3)]
                    if newBg then obj.BackgroundColor3 = newBg end
                    if obj:IsA("ScrollingFrame") then
                        local newSb = strokeMap[colorKey(obj.ScrollBarImageColor3)]
                        if newSb then obj.ScrollBarImageColor3 = newSb end
                    end
                end

                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    local name = obj.Name or ""
                    local txt = tostring(obj.Text or "")
                    if name == "SevenUpNavLabel" then
                        local tab = obj.Parent
                        obj.TextColor3 = tab and tab:GetAttribute("Selected")
                            and (scheme.text or Color3.fromRGB(255,255,255))
                            or (scheme.mainLight or scheme.rowLabel)
                    elseif name == "StackFeatureLabel" then
                        obj.TextColor3 = Color3.fromRGB(255,255,255)
                    elseif name == "SevenUpNavTab" then
                        obj.TextColor3 = obj:GetAttribute("Selected")
                            and (scheme.text or Color3.fromRGB(255,255,255))
                            or (scheme.mainLight or scheme.rowLabel)
                    elseif name == "K7Toggle" then
                        obj.TextColor3 = scheme.main
                    elseif txt == "×" then
                        obj.TextColor3 = scheme.closeBtn or scheme.main
                    elseif name == "DiscordSubTitle" or name == "discordLbl" or txt:lower():find("discord") then
                        obj.TextColor3 = scheme.discordText or scheme.subText or scheme.main
                    elseif name == "SpeedBillLbl" or name:lower():find("speed") then
                        obj.TextColor3 = scheme.speedText or scheme.main
                    elseif name:find("StackBtn_") then
                    else
                        local newTxt = txtMap[colorKey(obj.TextColor3)]
                        if newTxt then
                            obj.TextColor3 = newTxt
                        else
                            local rr = math.round(obj.TextColor3.R*255)
                            local gg = math.round(obj.TextColor3.G*255)
                            local bb = math.round(obj.TextColor3.B*255)
                            if rr > 200 and gg > 200 and bb > 200 then
                                obj.TextColor3 = scheme.text or scheme.rowLabel or Color3.fromRGB(255,255,255)
                            elseif math.max(rr,gg,bb) - math.min(rr,gg,bb) < 40 then
                                obj.TextColor3 = scheme.subText or scheme.rowSub or scheme.text
                            else
                                obj.TextColor3 = scheme.rowValue or scheme.main or scheme.text
                            end
                        end
                    end
                end

                if obj:IsA("TextBox") then
                    local newTxt = txtMap[colorKey(obj.TextColor3)]
                    if newTxt then
                        obj.TextColor3 = newTxt
                    else
                        obj.TextColor3 = scheme.inputText or scheme.rowValue or scheme.main or Color3.fromRGB(255,255,255)
                    end
                    local newBg = bgMap[colorKey(obj.BackgroundColor3)]
                    if newBg then obj.BackgroundColor3 = newBg end
                    local parent = obj.Parent
                    if parent and (parent:IsA("Frame") or parent:IsA("TextButton")) then
                        local pBg = bgMap[colorKey(parent.BackgroundColor3)]
                        if pBg then parent.BackgroundColor3 = pBg
                        else parent.BackgroundColor3 = scheme.inputBg or parent.BackgroundColor3 end
                    end
                end

                if obj:IsA("UIStroke") then
                    local newStroke = strokeMap[colorKey(obj.Color)]
                    if newStroke then
                        obj.Color = newStroke
                    else
                        obj.Color = scheme.border or scheme.main or obj.Color
                    end
                end

                if obj:IsA("UIGradient") then
                    local points = {}
                    local changed = false
                    for _, point in ipairs(obj.Color.Keypoints) do
                        local replacement = bgMap[colorKey(point.Value)]
                            or txtMap[colorKey(point.Value)]
                        if replacement then changed = true end
                        table.insert(points, ColorSequenceKeypoint.new(point.Time, replacement or point.Value))
                    end
                    if changed then obj.Color = ColorSequence.new(points) end
                end
            end)
        end
    end

    -- The music player lives in its own ScreenGui, so recolor it alongside
    -- the main window instead of waiting until it is reopened.
    local musicRoot = MusicPlayer and MusicPlayer.gui
    if musicRoot and musicRoot.Parent and musicRoot ~= gui then
        for _, obj in ipairs(musicRoot:GetDescendants()) do
            pcall(function()
                if obj:IsA("GuiObject") then
                    local bg = bgMap[colorKey(obj.BackgroundColor3)]
                    if bg then obj.BackgroundColor3 = bg end
                end
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    local replacement = txtMap[colorKey(obj.TextColor3)]
                    if replacement then obj.TextColor3 = replacement end
                end
                if obj:IsA("UIStroke") then
                    obj.Color = strokeMap[colorKey(obj.Color)] or scheme.border or scheme.main
                elseif obj:IsA("UIGradient") then
                    local points, changed = {}, false
                    for _, point in ipairs(obj.Color.Keypoints) do
                        local replacement = bgMap[colorKey(point.Value)] or txtMap[colorKey(point.Value)]
                        if replacement then changed = true end
                        table.insert(points, ColorSequenceKeypoint.new(point.Time, replacement or point.Value))
                    end
                    if changed then obj.Color = ColorSequence.new(points) end
                end
            end)
        end
    end

    pcall(function()
        local boxes = {normalBox, carryBox, laggerBox, laggerCarryBox, uiScaleBox, buttonScaleBox, stealRadBox, stealDurBox, autoTPHeightBox}
        for _, box in ipairs(boxes) do
            if box and box.Parent then
                box.TextColor3 = scheme.inputText or scheme.rowValue or scheme.main
                local holder = box.Parent
                if holder:IsA("Frame") or holder:IsA("TextButton") then
                    holder.BackgroundColor3 = scheme.inputBg or scheme.modeBtnBg
                    for _, item in ipairs(holder:GetChildren()) do
                        if item:IsA("UIStroke") then item.Color = scheme.inputFocus or scheme.main end
                    end
                end
                local row = holder.Parent
                if row and row:IsA("Frame") then
                    row.BackgroundColor3 = scheme.rowBg
                    for _, item in ipairs(row:GetChildren()) do
                        if item:IsA("TextLabel") then item.TextColor3 = scheme.rowLabel or scheme.text end
                    end
                end
            end
        end
    end)

    -- Gradients and stateful arrows need an explicit semantic refresh instead
    -- of relying only on exact RGB replacement.
    if gui then
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text == "7UP DUELS" then
                obj.TextColor3 = Color3.fromRGB(255,255,255)
                local gradient = obj:FindFirstChildWhichIsA("UIGradient")
                if gradient then
                    gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(0.52, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
                    })
                end
            elseif obj:IsA("TextButton") and obj.Name == "SevenUpDefenseArrow" then
                local expanded = obj:GetAttribute("Expanded") == true
                obj.BackgroundColor3 = expanded and (scheme.modeBtnActBg or scheme.main)
                    or (scheme.modeBtnBg or scheme.rowBg)
                obj.TextColor3 = expanded and (scheme.buttonText or scheme.text)
                    or (scheme.mainLight or scheme.main)
            end
        end
    end

    if _G._K7RefreshMusicPlayerTheme then pcall(_G._K7RefreshMusicPlayerTheme) end
    if _G._K7RefreshAnimPackTheme then pcall(_G._K7RefreshAnimPackTheme) end

    if autoGrabModule then
        pcall(function()
            autoGrabModule.updateColors(scheme)
            autoGrabModule.setBackground(currentBgImage)
        end)
    end

    for key, wrapper in pairs(stackWrappers or {}) do
        if wrapper and wrapper.Parent then
            local isOn = false
            pcall(function()
                if key == "antiDesync" then isOn = _G.AceAntiDesyncAimbotOn == true
                elseif key == "aimbot" then isOn = (_G.AceNormalAimbotOn == true) or (State.batAimbotZombie == true)
                elseif key == "speed" or key == "carrySpeed" then isOn = State.speedToggled == true
                elseif key == "autoCarry" then isOn = State.softStealEnabled == true
                elseif key == "lagger" then isOn = State.laggerMode == 1
                elseif key == "laggerCarry" then isOn = State.laggerMode == 2
                end
            end)
            wrapper.BackgroundColor3 = isOn and (scheme.stackActive or scheme.main) or (scheme.stackBg or scheme.mainDark)
            wrapper.BackgroundTransparency = 1
            wrapper.TextColor3 = isOn and (scheme.stackActiveText or scheme.buttonText or Color3.fromRGB(255,255,255)) or (scheme.stackText or scheme.text)
            local canSurface=wrapper:FindFirstChild("SodaCanSurface")
            local canTop=wrapper:FindFirstChild("IndentedCanTop")
            local canColor=isOn and (scheme.stackActive or scheme.main) or (scheme.stackBg or scheme.mainDark)
            if canSurface then canSurface.BackgroundColor3=canColor end
            if canTop then canTop.BackgroundColor3=canColor end
            wrapper:SetAttribute("Active",isOn)
            local stackLabel=wrapper:FindFirstChild("StackFeatureLabel")
            if stackLabel then
                stackLabel.TextColor3=Color3.fromRGB(255,255,255)
            end
            local miniSeven=wrapper:FindFirstChild("MobileSevenLogo",true)
            if miniSeven and miniSeven:IsA("TextLabel") then
                miniSeven.TextColor3=Color3.fromRGB(255,255,255)
                miniSeven.TextStrokeColor3=scheme.mainDark
            end
            local sharedBlend=adaptiveCanColorSequence(scheme,isOn)
            local bodyBlend=canSurface and canSurface:FindFirstChild("AdaptiveCanBlend")
            local topBlend=canTop and canTop:FindFirstChild("AdaptiveCanBlend")
            if bodyBlend and bodyBlend:IsA("UIGradient") then bodyBlend.Color=sharedBlend end
            if topBlend and topBlend:IsA("UIGradient") then topBlend.Color=sharedBlend end
        end
    end

    for _, btn in pairs(keybindBtnRefs or {}) do
        if btn and btn.Parent then
            btn.BackgroundColor3 = scheme.main
            btn.TextColor3 = scheme.buttonText or scheme.text
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                for _, bbName in ipairs({"SevenUpDuelsBB", "SevenUpDuelsBB_Other"}) do
                    local bb = head:FindFirstChild(bbName)
                    if bb then
                        local speedLbl = bb:FindFirstChild("SpeedBillLbl")
                        if speedLbl then speedLbl.TextColor3 = scheme.speedText or scheme.main end
                        local discordLbl = bb:FindFirstChild("discordLbl")
                        if not discordLbl then
                            for _, child in ipairs(bb:GetChildren()) do
                                if child:IsA("TextLabel") and tostring(child.Text or ""):lower():find("discord") then
                                    discordLbl = child
                                    child.Name = "discordLbl"
                                    break
                                end
                            end
                        end
                        if discordLbl then discordLbl.TextColor3 = scheme.discordText or scheme.subText or scheme.main end
                        local ragTimerLbl = bb:FindFirstChild("RagdollTimerLbl")
                        if ragTimerLbl then ragTimerLbl.TextColor3 = scheme.main end
                    end
                end
            end
        end
    end

    for _, d in pairs(PlayerESP.playerData or {}) do
        pcall(function()
            if d.highlight then
                d.highlight.OutlineColor = scheme.main or Color3.fromRGB(245,245,245)
            end
            if d.billboard then
                for _, item in ipairs(d.billboard:GetDescendants()) do
                    if item:IsA("UIStroke") then item.Color = scheme.main end
                    if item:IsA("TextLabel") then
                        item.TextColor3 = item.Name == "OtherPlayerNameLabel"
                            and (scheme.subText or scheme.mainLight)
                            or scheme.main
                    end
                end
            end
        end)
    end

    if gui then
        local sodaBadge = gui:FindFirstChild("SevenUpSodaBadge", true)
        if sodaBadge and sodaBadge:IsA("Frame") then
            sodaBadge.BackgroundColor3 = scheme.mainDark
            local gradient = sodaBadge:FindFirstChildWhichIsA("UIGradient")
            if gradient then gradient.Color = adaptiveCanColorSequence(scheme,true) end
            local badgeStroke = sodaBadge:FindFirstChildWhichIsA("UIStroke")
            if badgeStroke then badgeStroke.Color = scheme.mainLight end
            for _, item in ipairs(sodaBadge:GetChildren()) do
                if item:IsA("TextLabel") and tostring(item.Text):lower():find("discord",1,true) then
                    item.TextColor3 = scheme.discordText or scheme.mainLight
                end
            end
            local badgeSeven=sodaBadge:FindFirstChild("BadgeSevenLogo",true)
            if badgeSeven and badgeSeven:IsA("TextLabel") then
                badgeSeven.TextStrokeColor3=scheme.mainDark
            end
        end
        local titleMusicButton=gui:FindFirstChild("SevenUpTitleMusicButton",true)
        if titleMusicButton then
            local titleLogo=titleMusicButton:FindFirstChild("TitleSevenLogo",true)
            if titleLogo and titleLogo:IsA("TextLabel") then titleLogo.TextStrokeColor3=scheme.mainDark end
        end
    end
    if _G._K7RefreshMobileButtonShape then pcall(_G._K7RefreshMobileButtonShape) end
end

-- ============================================================
-- BACKGROUND CHANGER FUNCTION (green)
-- ============================================================
local function changeDuelScriptBackground(imageId)
    if State.uiColorTheme == "Red" then imageId = RED_7UP_BACKGROUND end
    if State.uiColorTheme ~= "Red" and imageId == RED_7UP_BACKGROUND then
        imageId = GREEN_7UP_BACKGROUND
    end
    State.bgImage = imageId
    currentBgImage = imageId
    local prevScheme = currentColorScheme
    local baseScheme = COLOR_SCHEMES[imageId] or COLOR_SCHEMES["rbxassetid://102557909116203"]
    local scheme = get7UpThemeScheme(baseScheme, State.uiColorTheme)
    _G._K7ThemeMode = State.uiColorTheme == "Red" and "Red" or "Green"
    _G._K7AccentColor = scheme.main
    
    local gui = LP:FindFirstChild("PlayerGui"):FindFirstChild("SevenUpDuelsV2")
    if gui then
        local mainOuter = gui:FindFirstChild("MainOuter")
        if mainOuter then
            local bg = mainOuter:FindFirstChild("BgImage")
            if bg then
                bg.Image = imageId
                bg.ImageTransparency = 0.04
                bg.ImageColor3 = Color3.fromRGB(255,255,255)
                bg.Visible = true
            end
            local topBg = mainOuter:FindFirstChild("TopBgImage")
            if topBg then
                -- Carry the selected skin through the overlapping can neck.
                topBg.Image = imageId
                topBg.ImageTransparency = 0.04
                topBg.ImageColor3 = Color3.fromRGB(255,255,255)
                topBg.BackgroundColor3 = scheme.mainDark or Color3.fromRGB(0,92,42)
                topBg.Visible = false
                local blend = topBg:FindFirstChild("AdaptiveCanBlend")
                if blend and blend:IsA("UIGradient") then
                    blend.Color = adaptiveCanColorSequence(scheme,false)
                end
            end
            local atmosphere = mainOuter:FindFirstChild("GradientAtmosphere")
            if atmosphere then
                atmosphere.BackgroundColor3 = scheme.main
                atmosphere.BackgroundTransparency = State.uiColorTheme == "Red" and 0.94 or 0.88
            end
        end
    end
    
    if autoGrabModule then
        autoGrabModule.setBackground(imageId)
        autoGrabModule.updateColors(scheme)
    end
    if MusicPlayer and MusicPlayer.gui and MusicPlayer.gui.Parent then
        local musicBg = MusicPlayer.gui:FindFirstChild("MusicBackground", true)
        if musicBg and musicBg:IsA("ImageLabel") then
            musicBg.Image = imageId
            musicBg.ImageTransparency = 0.08
            musicBg.ImageColor3 = Color3.fromRGB(255,255,255)
            musicBg.Visible = true
        end
    end
    
    updateAllColors(scheme, prevScheme)
    if _G._K7RefreshColorThemeButtons then pcall(_G._K7RefreshColorThemeButtons) end
    if _G._K7RefreshCustomSkinTheme then pcall(_G._K7RefreshCustomSkinTheme) end
    if _G._K7RefreshMusicPlayerTheme then pcall(_G._K7RefreshMusicPlayerTheme) end
    if _G._K7RefreshAnimPackTheme then pcall(_G._K7RefreshAnimPackTheme) end
    
    requestSave()
end

local function set7UpColorTheme(mode, skipSave)
    mode = mode == "Red" and "Red" or "Green"
    local previous = currentColorScheme
    State.uiColorTheme = mode
    _G._K7ThemeMode = mode
    local themeBackground = mode == "Red" and RED_7UP_BACKGROUND or GREEN_7UP_BACKGROUND
    State.bgImage = themeBackground
    currentBgImage = themeBackground
    local baseScheme = COLOR_SCHEMES[currentBgImage]
        or COLOR_SCHEMES["rbxassetid://102557909116203"]
    local scheme = get7UpThemeScheme(baseScheme, mode)
    _G._K7AccentColor = scheme.main
    updateAllColors(scheme, previous)

    local playerGui = LP:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("SevenUpDuelsV2")
    if mainGui then
        for _, name in ipairs({"BgImage", "TopBgImage"}) do
            local image = mainGui:FindFirstChild(name, true)
            if image and image:IsA("ImageLabel") then
                image.Image = themeBackground
                image.ImageColor3 = Color3.fromRGB(255,255,255)
            end
        end
        local atmosphere = mainGui:FindFirstChild("GradientAtmosphere", true)
        if atmosphere then
            atmosphere.BackgroundColor3 = scheme.main
            atmosphere.BackgroundTransparency = mode == "Red" and 0.94 or 0.88
        end
    end
    if MusicPlayer and MusicPlayer.gui and MusicPlayer.gui.Parent then
        local musicBg = MusicPlayer.gui:FindFirstChild("MusicBackground", true)
        if musicBg then
            musicBg.Image = themeBackground
            musicBg.ImageColor3 = Color3.fromRGB(255,255,255)
        end
    end
    if _G._K7RefreshColorThemeButtons then pcall(_G._K7RefreshColorThemeButtons) end
    if _G._K7RefreshCustomSkinTheme then pcall(_G._K7RefreshCustomSkinTheme) end
    if _G._K7RefreshMusicPlayerTheme then pcall(_G._K7RefreshMusicPlayerTheme) end
    if _G._K7RefreshAnimPackTheme then pcall(_G._K7RefreshAnimPackTheme) end
    if not skipSave then requestSave() end
end

-- ============================================================
-- SKY THEME SYSTEM (unchanged)
-- ============================================================
SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Tech","Sakura","Pink Night",
    "Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse",
    "Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}
SKY_PRESETS = {
    ["Off"]            = {kind="off"},
    ["Night"]          = {clock=22,  brightness=2,   ambient={110,100,130}, outAmb={120,110,140}, sky={stars=4000,moon=18,sun=0,moonTex=true},      atm={dens=0.45,color={120,60,180}, decay={60,20,100},  glare=0.5,haze=1.2}},
    ["Aurora"]         = {clock=14,  brightness=3,   ambient={150,120,150}, outAmb={160,130,150}, atm={dens=0.55,color={255,80,200}, decay={255,20,150}, glare=2.5,haze=3},   clouds={cover=0.7, dens=0.7, color={255,240,250}}},
    ["Sunset"]         = {clock=17.2,brightness=2.5, ambient={170,120,100}, outAmb={180,130,110}, sky={stars=0,sun=25,moon=0},                       atm={dens=0.5, color={255,130,60}, decay={255,80,30}, glare=2,  haze=2.5}, clouds={cover=0.55,dens=0.55,color={255,200,140}}},
    ["Galaxy"]         = {clock=0,   brightness=1.5, ambient={70,60,100},   outAmb={80,70,110},   sky={stars=10000,moon=30,sun=0},                   atm={dens=0.15,color={40,20,80},  decay={20,10,50},  glare=0.3,haze=0.5}},
    ["Tech"]           = {clock=21,  brightness=2.2, ambient={90,130,170},  outAmb={100,140,180}, sky={stars=2000,moon=12},                          atm={dens=0.4, color={0,200,255}, decay={150,0,255}, glare=2,  haze=2},   clouds={cover=0.4, dens=0.6, color={100,200,255}}},
    ["Sakura"]         = {clock=11,  brightness=3.5, ambient={170,150,160}, outAmb={180,160,170}, sky={sun=8},                                        atm={dens=0.3, color={255,200,220},decay={255,170,200},glare=1, haze=1.5}, clouds={cover=0.6, dens=0.4, color={255,250,252}}},
    ["Pink Night"]     = {clock=23,  brightness=2.2, ambient={120,60,110},  outAmb={140,70,120},  sky={stars=5000,moon=22,sun=0,moonTex=true},       atm={dens=0.5, color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4}, clouds={cover=0.3, dens=0.5, color={180,90,150}}},
    ["Blood Moon"]     = {clock=22.5,brightness=1.6, ambient={130,40,40},   outAmb={150,50,50},   sky={stars=1500,moon=28,sun=0,moonTex=true},       atm={dens=0.6, color={220,30,30}, decay={120,10,10}, glare=1.4,haze=2},   clouds={cover=0.5, dens=0.7, color={120,30,30}}},
    ["Emerald Dawn"]   = {clock=6.5, brightness=2.8, ambient={130,170,140}, outAmb={140,180,150}, sky={sun=18,moon=0,stars=0},                       atm={dens=0.4, color={80,200,140},decay={40,150,90}, glare=1.8,haze=2.2}, clouds={cover=0.5, dens=0.5, color={200,255,220}}},
    ["Volcanic"]       = {clock=19,  brightness=2,   ambient={180,80,40},   outAmb={200,90,50},   sky={stars=200,sun=12,moon=0},                     atm={dens=0.75,color={255,60,0},  decay={180,20,0},  glare=3,  haze=3.5}, clouds={cover=0.8, dens=0.9, color={120,40,20}}},
    ["Arctic"]         = {clock=9,   brightness=3.2, ambient={200,220,235}, outAmb={210,230,245}, sky={sun=10,stars=0,moon=0},                       atm={dens=0.3, color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7, dens=0.6, color={250,253,255}}},
    ["Midnight Ocean"] = {clock=1.5, brightness=1.7, ambient={60,90,130},   outAmb={70,100,140},  sky={stars=6000,moon=24,sun=0,moonTex=true},       atm={dens=0.5, color={20,60,140}, decay={10,30,90},  glare=0.6,haze=1.5}},
    ["Vaporwave"]      = {clock=19.5,brightness=2.4, ambient={180,120,200}, outAmb={190,130,210}, sky={stars=1000,moon=14},                          atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.5, dens=0.55,color={200,150,255}}},
    ["Toxic"]          = {clock=13,  brightness=2.5, ambient={140,180,80},  outAmb={150,190,90},  atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6},  clouds={cover=0.65,dens=0.7, color={180,255,120}}},
    ["Solar Eclipse"]  = {clock=12,  brightness=0.9, ambient={50,40,60},    outAmb={60,50,70},    sky={stars=3500,sun=22,moon=0},                    atm={dens=0.5, color={255,140,40},decay={30,20,40},  glare=2.8,haze=1.8}},
    ["Hellscape"]      = {clock=18,  brightness=1.8, ambient={200,60,30},   outAmb={220,70,40},   sky={stars=100,sun=30,moon=0},                     atm={dens=0.85,color={255,30,0},  decay={120,0,0},   glare=3.5,haze=4},   clouds={cover=0.95,dens=0.95,color={80,20,10}}},
    ["Heaven"]         = {clock=12,  brightness=4,   ambient={240,235,210}, outAmb={250,245,220}, sky={sun=16,moon=0,stars=0},                       atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3, haze=1.5}, clouds={cover=0.85,dens=0.5, color={255,255,255}}},
    ["Storm"]          = {clock=15,  brightness=1.4, ambient={90,90,110},   outAmb={100,100,120}, sky={stars=0,sun=6,moon=0},                        atm={dens=0.65,color={80,90,120}, decay={40,50,80},  glare=0.5,haze=3},   clouds={cover=0.95,dens=0.95,color={60,65,80}}},
    ["Sunrise"]        = {clock=6.2, brightness=2.8, ambient={220,180,130}, outAmb={230,190,140}, sky={sun=22,stars=0,moon=0},                       atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4, dens=0.4, color={255,220,180}}},
    ["Deep Space"]     = {clock=0,   brightness=1,   ambient={30,25,50},    outAmb={40,35,60},    sky={stars=15000,moon=0,sun=0},                    atm={dens=0.08,color={15,5,40},   decay={5,0,20},    glare=0.2,haze=0.3}},
    ["Lavender Dream"] = {clock=18.5,brightness=2.6, ambient={180,160,220}, outAmb={190,170,230}, sky={stars=800,moon=16,sun=0},                     atm={dens=0.4, color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5, color={220,200,255}}},
    ["Inferno"]        = {clock=17.5,brightness=2.2, ambient={220,100,40},  outAmb={235,110,50},  sky={sun=26,moon=0,stars=0},                       atm={dens=0.6, color={255,90,20}, decay={200,40,0},  glare=3,  haze=3.2}, clouds={cover=0.7, dens=0.7, color={200,80,40}}},
    ["Mint Sky"]       = {clock=10,  brightness=3.2, ambient={180,230,210}, outAmb={190,240,220}, sky={sun=10},                                       atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}
local function _vC3(t) return Color3.fromRGB(t[1], t[2], t[3]) end
local function _v4mpClearSky()
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:GetAttribute("_K7Sky") then pcall(function() v:Destroy() end) end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, v in ipairs(terrain:GetChildren()) do
            if v:GetAttribute("_K7Sky") then pcall(function() v:Destroy() end) end
        end
    end
end
local function applyCustomSky(mode)
    _v4mpClearSky()
    local preset = SKY_PRESETS and SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        Lighting.FogEnd=100000; Lighting.FogStart=0
        Lighting.FogColor=Color3.fromRGB(192,192,192)
        Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.GlobalShadows=true
        State.skyTheme="Off"; skyTheme="Off"; return
    end
    Lighting.FogEnd=100000; Lighting.FogStart=0
    Lighting.FogColor=Color3.fromRGB(200,200,200)
    Lighting.GlobalShadows=true
    Lighting.ClockTime = preset.clock or 14
    Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = _vC3(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = _vC3(preset.ambient) end
    if preset.sky then
        local sky = Instance.new("Sky")
        sky:SetAttribute("_K7Sky", true)
        if preset.sky.stars  then sky.StarCount        = preset.sky.stars end
        if preset.sky.moon   then sky.MoonAngularSize  = preset.sky.moon  end
        if preset.sky.sun    then sky.SunAngularSize   = preset.sky.sun   end
        if preset.sky.moonTex then sky.MoonTextureId   = "rbxasset://sky/moon.jpg" end
        sky.Parent = Lighting
    end
    if preset.atm then
        local atm = Instance.new("Atmosphere")
        atm:SetAttribute("_K7Sky", true)
        atm.Density = preset.atm.dens or 0.3
        atm.Color   = _vC3(preset.atm.color)
        atm.Decay   = _vC3(preset.atm.decay)
        atm.Glare   = preset.atm.glare or 1
        atm.Haze    = preset.atm.haze  or 1
        atm.Parent  = Lighting
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if preset.clouds and terrain then
        local clouds = Instance.new("Clouds")
        clouds:SetAttribute("_K7Sky", true)
        clouds.Cover   = preset.clouds.cover or 0.5
        clouds.Density = preset.clouds.dens  or 0.5
        clouds.Color   = _vC3(preset.clouds.color)
        clouds.Parent  = terrain
    end
    State.skyTheme = mode; skyTheme = mode
end

-- ============================================================
-- PLAYER ESP (unchanged)
-- ============================================================
local function startPlayerESP()
    if PlayerESP.enabled then return end
    PlayerESP.enabled = true
    local function cleanupPlayer(plr)
        local d = PlayerESP.playerData[plr]; if not d then return end
        pcall(function() if d.highlight then d.highlight:Destroy() end end)
        pcall(function() if d.billboard then d.billboard:Destroy() end end)
        if d.conns then for _,c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end end
        PlayerESP.playerData[plr] = nil
    end
    local function setupPlayer(plr, char)
        if not PlayerESP.enabled or plr == LP then return end
        cleanupPlayer(plr)
        local hrp  = char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5))
        local head = char and (char:FindFirstChild("Head")             or char:WaitForChild("Head", 5))
        if not hrp or not head then return end
        local hl = Instance.new("Highlight")
        hl.Name = "K7ESP"; hl.Adornee = char
        hl.FillColor = Color3.fromRGB(35, 35, 35); hl.FillTransparency = 0.72
        hl.OutlineColor = _G._K7AccentColor or currentColorScheme.main; hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
        local bb = Instance.new("BillboardGui")
        bb.Name = "K7ESPTag"; bb.Adornee = head
        bb.Size = UDim2.new(0,150,0,104); bb.StudsOffset = Vector3.new(0,3.4,0)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.Parent = head
        local box = Instance.new("Frame", bb)
        box.Size = UDim2.new(1,0,1,0); box.BackgroundTransparency = 1; box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)
        local list = Instance.new("UIListLayout", box)
        list.FillDirection = Enum.FillDirection.Vertical
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.VerticalAlignment = Enum.VerticalAlignment.Center
        list.Padding = UDim.new(0, 2)
        local ava = Instance.new("ImageLabel", box)
        ava.Name = "Avatar"; ava.Size = UDim2.new(0,56,0,56)
        ava.BackgroundColor3 = Color3.fromRGB(8,8,10); ava.BackgroundTransparency = 0
        ava.BorderSizePixel = 0; ava.Image = ""
        Instance.new("UICorner", ava).CornerRadius = UDim.new(1,0)
        local avStroke = Instance.new("UIStroke", ava)
        avStroke.Color = _G._K7AccentColor or currentColorScheme.main; avStroke.Thickness = 2
        local n = Instance.new("TextLabel", box)
        n.Size = UDim2.new(1,-10,0,17)
        n.Name = "OtherPlayerSpeedLabel"
        n.BackgroundTransparency = 1; n.TextColor3 = currentColorScheme.main
        n.Font = Enum.Font.GothamBlack; n.TextSize = 15; n.TextStrokeTransparency = 0.38
        local sub = Instance.new("TextLabel", box)
        sub.Size = UDim2.new(1,-10,0,11)
        sub.Name = "OtherPlayerNameLabel"
        sub.BackgroundTransparency = 1; sub.TextColor3 = currentColorScheme.subText or currentColorScheme.mainLight
        sub.Font = Enum.Font.GothamBold; sub.TextSize = 10; sub.TextStrokeTransparency = 0.58
        task.spawn(function()
            pcall(function()
                local thumb = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                if thumb ~= "" and ava.Parent then ava.Image = thumb end
            end)
        end)
        local conn = RunService.Heartbeat:Connect(function()
            if not PlayerESP.enabled or not hrp.Parent then return end
            local v = hrp.AssemblyLinearVelocity or hrp.Velocity
            n.Text = string.format("%d speed", math.floor(Vector3.new(v.X,0,v.Z).Magnitude + 0.5))
            sub.Text = plr.Name
            n.TextColor3 = currentColorScheme.main
            sub.TextColor3 = currentColorScheme.subText or currentColorScheme.mainLight
        end)
        PlayerESP.playerData[plr] = {highlight = hl, billboard = bb, conns = {conn}}
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            if plr.Character then task.spawn(setupPlayer, plr, plr.Character) end
            table.insert(PlayerESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(setupPlayer, plr, c) end))
        end
    end
    table.insert(PlayerESP.conns, Players.PlayerAdded:Connect(function(plr)
        if plr ~= LP then
            table.insert(PlayerESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(setupPlayer, plr, c) end))
        end
    end))
    table.insert(PlayerESP.conns, Players.PlayerRemoving:Connect(function(plr)
        local d = PlayerESP.playerData[plr]; if not d then return end
        pcall(function() if d.highlight then d.highlight:Destroy() end end)
        pcall(function() if d.billboard then d.billboard:Destroy() end end)
        if d.conns then for _,c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end end
        PlayerESP.playerData[plr] = nil
    end))
end
local function stopPlayerESP()
    PlayerESP.enabled = false
    for _, c in ipairs(PlayerESP.conns or {}) do pcall(function() c:Disconnect() end) end
    PlayerESP.conns = {}
    for _, d in pairs(PlayerESP.playerData or {}) do
        pcall(function() if d.highlight then d.highlight:Destroy() end end)
        pcall(function() if d.billboard then d.billboard:Destroy() end end)
        if d.conns then for _,c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end end
    end
    PlayerESP.playerData = {}
end

-- Boxed ESP (Drawing-based)
local function _safeDrawing(kind, props)
    if not Drawing or not Drawing.new then return nil end
    local ok, obj = pcall(function() return Drawing.new(kind) end)
    if not ok or not obj then return nil end
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    return obj
end
local function _cleanupBoxedESPPlayer(player)
    local data = BoxedESPData[player]; if not data then return end
    for _, obj in pairs(data) do
        pcall(function() obj.Visible = false; if obj.Remove then obj:Remove() end end)
    end
    BoxedESPData[player] = nil
end
local function _cleanupBoxedESP()
    for player, _ in pairs(BoxedESPData) do _cleanupBoxedESPPlayer(player) end
end
local function _updateBoxedESP()
    local cam = workspace.CurrentCamera; if not cam then return end
    local anyOn = BoxedESPOptions.box
    if not anyOn then _cleanupBoxedESP(); return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            if root and head then
                local rootPos, onScreen = cam:WorldToViewportPoint(root.Position)
                local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.55, 0))
                local data = BoxedESPData[player]
                local espColor = _G._K7AccentColor or currentColorScheme.main or Color3.fromRGB(0, 204, 102)
                if not data then
                    data = {
                        box = _safeDrawing("Square", {Thickness=2, Filled=false, Transparency=1, Color=espColor}),
                    }
                    BoxedESPData[player] = data
                end
                local height = math.abs(headPos.Y - rootPos.Y) * 2.15
                if height < 20 or height ~= height then height = 65 end
                local width = height / 2.15
                local view = cam.ViewportSize
                local centerX, centerY = view.X / 2, view.Y / 2
                local targetX, targetY = rootPos.X, rootPos.Y + height / 2
                local targetVisible = onScreen and rootPos.Z > 0
                if not targetVisible then
                    local dx = rootPos.X - centerX; local dy = rootPos.Y - centerY
                    if rootPos.Z <= 0 then dx = -dx; dy = -dy end
                    if math.abs(dx) < 1 and math.abs(dy) < 1 then
                        local rel = cam.CFrame:PointToObjectSpace(root.Position)
                        dx = rel.X; dy = -rel.Y
                        if rootPos.Z <= 0 then dx = -dx; dy = -dy end
                    end
                    local edgePad = 10
                    local scaleX = (dx ~= 0) and ((view.X/2-edgePad)/math.abs(dx)) or math.huge
                    local scaleY = (dy ~= 0) and ((view.Y/2-edgePad)/math.abs(dy)) or math.huge
                    local scale  = math.min(scaleX, scaleY)
                    if scale == math.huge or scale ~= scale then scale = 1 end
                    targetX = math.clamp(centerX + dx*scale, edgePad, view.X-edgePad)
                    targetY = math.clamp(centerY + dy*scale, edgePad, view.Y-edgePad)
                end
                if data.box then
                    data.box.Color = espColor
                    data.box.Size  = Vector2.new(width, height)
                    data.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    data.box.Transparency = BoxedESPOptions.box == true and 0 or 1
                    data.box.Visible  = BoxedESPOptions.box == true and targetVisible
                end
            else
                _cleanupBoxedESPPlayer(player)
            end
        end
    end
end
local function refreshBoxedESP()
    local anyOn = BoxedESPOptions.box
    if anyOn and not BoxedESPConn then
        BoxedESPConn = RunService.RenderStepped:Connect(_updateBoxedESP)
    elseif (not anyOn) and BoxedESPConn then
        BoxedESPConn:Disconnect(); BoxedESPConn = nil; _cleanupBoxedESP()
    end
end
Players.PlayerRemoving:Connect(_cleanupBoxedESPPlayer)


-- ============================================================
-- AUTO LEFT / AUTO RIGHT (from Zombie Hub)
-- ============================================================
local AP_L1 = Vector3.new(-476.48, -6.28, 92.73)
local AP_L2 = Vector3.new(-483.12, -4.95, 94.80)
local AP_R1 = Vector3.new(-476.16, -6.52, 25.62)
local AP_R2 = Vector3.new(-483.06, -5.03, 25.48)
local alConn, arConn = nil, nil
local alPhase, arPhase = 1, 1

local function stopAutoLeft()
    if alConn then alConn:Disconnect(); alConn = nil end
    State.autoLeftEnabled = false
    alPhase = 1
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:Move(Vector3.zero, false) end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
    if stackBtnRefs and stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end
    -- Back to CARRY speed after auto left finishes
    State.speedToggled = true
    if stackBtnRefs and stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(true) end
end

local function stopAutoRight()
    if arConn then arConn:Disconnect(); arConn = nil end
    State.autoRightEnabled = false
    arPhase = 1
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:Move(Vector3.zero, false) end
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
    if stackBtnRefs and stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end
    -- Back to CARRY speed after auto right finishes
    State.speedToggled = true
    if stackBtnRefs and stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(true) end
end

local function startAutoLeft()
    if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
        _G.AceSafeModeForceStop("SAFE MODE LOCK")
        return
    end
    if State.autoRightEnabled then stopAutoRight() end
    if alConn then alConn:Disconnect() end
    alPhase = 1
    State.autoLeftEnabled = true
    -- Show NORMAL SPEED while pathing
    State.speedToggled = false
    if stackBtnRefs and stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
    alConn = RunService.Heartbeat:Connect(function()
        if not State.autoLeftEnabled then return end
        if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            stopAutoLeft()
            return
        end
        -- keep UI/status on normal speed during auto left
        if State.speedToggled then
            State.speedToggled = false
            if stackBtnRefs and stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
        end
        local char = LP.Character
        if not char then return end
        local hrp2 = char:FindFirstChild("HumanoidRootPart")
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if not hrp2 or not hum2 then return end
        local spd = State.normalSpeed or 60
        if alPhase == 1 then
            local tgt = Vector3.new(AP_L1.X, hrp2.Position.Y, AP_L1.Z)
            if (tgt - hrp2.Position).Magnitude < 1.5 then
                alPhase = 2
                return
            end
            local d = AP_L1 - hrp2.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.1 then
                mv = mv.Unit
                hum2:Move(mv, false)
                hrp2.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp2.AssemblyLinearVelocity.Y, mv.Z * spd)
            end
        else
            local tgt = Vector3.new(AP_L2.X, hrp2.Position.Y, AP_L2.Z)
            if (tgt - hrp2.Position).Magnitude < 1.5 then
                stopAutoLeft()
                return
            end
            local d = AP_L2 - hrp2.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.1 then
                mv = mv.Unit
                hum2:Move(mv, false)
                hrp2.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp2.AssemblyLinearVelocity.Y, mv.Z * spd)
            end
        end
    end)
end

local function startAutoRight()
    if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
        _G.AceSafeModeForceStop("SAFE MODE LOCK")
        return
    end
    if State.autoLeftEnabled then stopAutoLeft() end
    if arConn then arConn:Disconnect() end
    arPhase = 1
    State.autoRightEnabled = true
    State.speedToggled = false
    if stackBtnRefs and stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
    arConn = RunService.Heartbeat:Connect(function()
        if not State.autoRightEnabled then return end
        if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            stopAutoRight()
            return
        end
        if State.speedToggled then
            State.speedToggled = false
            if stackBtnRefs and stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
        end
        local char = LP.Character
        if not char then return end
        local hrp2 = char:FindFirstChild("HumanoidRootPart")
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if not hrp2 or not hum2 then return end
        local spd = State.normalSpeed or 60
        if arPhase == 1 then
            local tgt = Vector3.new(AP_R1.X, hrp2.Position.Y, AP_R1.Z)
            if (tgt - hrp2.Position).Magnitude < 1.5 then
                arPhase = 2
                return
            end
            local d = AP_R1 - hrp2.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.1 then
                mv = mv.Unit
                hum2:Move(mv, false)
                hrp2.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp2.AssemblyLinearVelocity.Y, mv.Z * spd)
            end
        else
            local tgt = Vector3.new(AP_R2.X, hrp2.Position.Y, AP_R2.Z)
            if (tgt - hrp2.Position).Magnitude < 1.5 then
                stopAutoRight()
                return
            end
            local d = AP_R2 - hrp2.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.1 then
                mv = mv.Unit
                hum2:Move(mv, false)
                hrp2.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp2.AssemblyLinearVelocity.Y, mv.Z * spd)
            end
        end
    end)
end

-- ============================================================
-- TRACER ESP (green arrows from Zombie Hub style)
-- ============================================================
local TracerESP = { drawings = {}, conn = nil, gui = nil, useDrawing = false }
local tracerGeneration = {}
_G._K7TracerGeneration = tracerGeneration

local function _tracerEnsureGui()
    if TracerESP.gui and TracerESP.gui.Parent then return TracerESP.gui end
    local playerGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
    if not playerGui then return nil end
    local oldGui = playerGui:FindFirstChild("SevenUpTracerReliable")
    if oldGui then oldGui:Destroy() end
    local tracerGui = Instance.new("ScreenGui")
    tracerGui.Name = "SevenUpTracerReliable"
    tracerGui.IgnoreGuiInset = true
    tracerGui.ResetOnSpawn = false
    tracerGui.DisplayOrder = 1000
    tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    tracerGui.Parent = playerGui
    TracerESP.gui = tracerGui
    return tracerGui
end

local function _tracerCleanup(plr)
    local d = TracerESP.drawings[plr]
    if d then
        pcall(function()
            if typeof(d) == "Instance" then d:Destroy()
            elseif d.Remove then d:Remove()
            elseif d.Destroy then d:Destroy() end
        end)
        TracerESP.drawings[plr] = nil
    end
end

local function startTracerESP()
    State.espTracerWanted = true
    State.espTracer = true
    local connectionAlive = TracerESP.conn and TracerESP.conn.Connected
    local guiAlive = TracerESP.gui and TracerESP.gui.Parent
    if connectionAlive and guiAlive then return end
    if TracerESP.conn then
        pcall(function() TracerESP.conn:Disconnect() end)
        TracerESP.conn = nil
    end
    for plr in pairs(TracerESP.drawings) do _tracerCleanup(plr) end
    -- GUI lines work on executors that expose a partial/broken Drawing API,
    -- so use them consistently instead of silently failing on Drawing.new.
    TracerESP.useDrawing = false
    if not _tracerEnsureGui() then return end
    TracerESP.conn = RunService.RenderStepped:Connect(function()
        if _G._K7TracerGeneration ~= tracerGeneration then return end
        if not State.espTracer then
            for plr in pairs(TracerESP.drawings) do _tracerCleanup(plr) end
            return
        end
        local cam = workspace.CurrentCamera
        if not cam then return end
        if not TracerESP.gui or not TracerESP.gui.Parent then return end
        local from = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y - 4)
        local myChar = LP.Character
        local myBody = myChar and (myChar:FindFirstChild("UpperTorso")
            or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("HumanoidRootPart"))
        if myBody then
            local bodyPoint, bodyVisible = cam:WorldToViewportPoint(myBody.Position)
            if bodyVisible and bodyPoint.Z > 0 then
                from = Vector2.new(bodyPoint.X, bodyPoint.Y)
            end
        end
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and root then
                    seen[plr] = true
                    local targetBody = plr.Character:FindFirstChild("UpperTorso")
                        or plr.Character:FindFirstChild("Torso") or root
                    local s = cam:WorldToViewportPoint(targetBody.Position)
                    local line = TracerESP.drawings[plr]
                    if not line then
                        local ok, created = pcall(function()
                            local l = Instance.new("Frame")
                            l.Name = "Tracer_" .. tostring(plr.UserId)
                            l.AnchorPoint = Vector2.new(0.5, 0.5)
                            l.BorderSizePixel = 0
                            l.BackgroundColor3 = currentColorScheme.main
                            l.BackgroundTransparency = 0.04
                            l.ZIndex = 1000
                            Instance.new("UICorner",l).CornerRadius = UDim.new(1,0)
                            local gradient=Instance.new("UIGradient",l)
                            gradient.Name="SevenUpTracerGradient"
                            gradient.Color=ColorSequence.new({
                                ColorSequenceKeypoint.new(0,currentColorScheme.mainDark),
                                ColorSequenceKeypoint.new(0.55,currentColorScheme.mainLight),
                                ColorSequenceKeypoint.new(1,currentColorScheme.main),
                            })
                            l.Parent = TracerESP.gui
                            return l
                        end)
                        if ok and created then
                            line = created
                            TracerESP.drawings[plr] = line
                        end
                    end
                    if line then
                        local to = Vector2.new(s.X, s.Y)
                        if s.Z <= 0 then
                            to = Vector2.new(cam.ViewportSize.X - s.X, cam.ViewportSize.Y - s.Y)
                        end
                        to = Vector2.new(
                            math.clamp(to.X, 3, math.max(3, cam.ViewportSize.X - 3)),
                            math.clamp(to.Y, 3, math.max(3, cam.ViewportSize.Y - 3))
                        )
                        local lineWorked = pcall(function()
                            local accent = currentColorScheme.mainLight or currentColorScheme.main or Color3.fromRGB(0, 204, 102)
                            if typeof(line) == "Instance" then
                                local delta = to - from
                                line.Position = UDim2.fromOffset((from.X + to.X) * 0.5, (from.Y + to.Y) * 0.5)
                                line.Size = UDim2.fromOffset(math.max(1, delta.Magnitude), 3)
                                line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                                line.BackgroundColor3 = accent
                                local gradient=line:FindFirstChild("SevenUpTracerGradient")
                                if gradient and gradient:IsA("UIGradient") then
                                    gradient.Color=ColorSequence.new({
                                        ColorSequenceKeypoint.new(0,currentColorScheme.mainDark),
                                        ColorSequenceKeypoint.new(0.55,currentColorScheme.mainLight),
                                        ColorSequenceKeypoint.new(1,currentColorScheme.main),
                                    })
                                end
                                line.Visible = true
                            else
                                line.From = from
                                line.To = to
                                line.Visible = true
                                line.Color = accent
                            end
                        end)
                        -- A Drawing object can be invalidated by a camera or
                        -- executor reset while the Lua reference stays alive.
                        -- Drop it so the next frame creates a fresh line.
                        if not lineWorked then _tracerCleanup(plr) end
                    end
                end
            end
        end
        for plr in pairs(TracerESP.drawings) do
            if not seen[plr] then _tracerCleanup(plr) end
        end
    end)
end

local function stopTracerESP(keepState)
    if not keepState then
        State.espTracerWanted = false
        State.espTracer = false
    end
    if TracerESP.conn then TracerESP.conn:Disconnect(); TracerESP.conn = nil end
    for plr in pairs(TracerESP.drawings) do _tracerCleanup(plr) end
    if TracerESP.gui then TracerESP.gui:Destroy(); TracerESP.gui = nil end
end
_G._K7StopTracerESP = stopTracerESP

task.spawn(function()
    while task.wait(1) do
        if _G._K7TracerGeneration ~= tracerGeneration then break end
        if State.espTracerWanted then
            State.espTracer = true
        else
            State.espTracer = false
        end
        local connectionAlive = TracerESP.conn and TracerESP.conn.Connected
        local guiAlive = TracerESP.gui and TracerESP.gui.Parent
        if State.espTracerWanted and (not connectionAlive or not guiAlive) then
            if TracerESP.conn then pcall(function() TracerESP.conn:Disconnect() end); TracerESP.conn = nil end
            for plr in pairs(TracerESP.drawings) do _tracerCleanup(plr) end
            if TracerESP.gui then pcall(function() TracerESP.gui:Destroy() end); TracerESP.gui = nil end
            pcall(startTracerESP)
        elseif not State.espTracerWanted and TracerESP.conn then
            pcall(stopTracerESP, true)
        end
    end
end)

-- Rebuild tracer drawings after respawns and camera replacements. The toggle
-- remains ON; only the stale render connection and drawing objects are reset.
local function rebuildTracerESPIfWanted()
    if not State.espTracerWanted then return end
    pcall(stopTracerESP, true)
    State.espTracer = true
    task.defer(function()
        if State.espTracerWanted then pcall(startTracerESP) end
    end)
end
LP.CharacterAdded:Connect(function()
    task.wait(0.15)
    rebuildTracerESPIfWanted()
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(rebuildTracerESPIfWanted)

-- ============================================================
-- ZOMBIE BAT AIMBOT (keeps existing aimbots separate)
-- ============================================================
local ZBat = {
    on = false,
    conn = nil,
    equipped = false,
    Speed = 56,
    VertSpeed = 52,
    Dist = -2.8,
    Height = 4.75,
    VertOffset = 1,
    TurnSpeed = 285,
    MaxTurnRate = 28,
}

local function zFindBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
        end
    end
    return nil
end

local function zGetTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local d = (tRoot.Position - root.Position).Magnitude
                if d < minDist then minDist = d; closest = tRoot end
            end
        end
    end
    return closest
end

local function startZombieBatAimbot()
    if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
        _G.AceSafeModeForceStop("SAFE MODE LOCK")
        return
    end
    pcall(function() if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end end)
    pcall(function() if _G.AceAntiDesyncAimbotOn and _G.AceStopAntiDesyncAimbot then _G.AceStopAntiDesyncAimbot() end end)
    ZBat.on = true
    State.batAimbotZombie = true
    if ZBat.conn then ZBat.conn:Disconnect() end
    if State.autoLeftEnabled then stopAutoLeft() end
    if State.autoRightEnabled then stopAutoRight() end

    ZBat.equipped = false
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate = false end
    ZBat.conn = RunService.Heartbeat:Connect(function()
        if not ZBat.on or not State.batAimbotZombie then return end
        if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            stopZombieBatAimbot()
            return
        end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not hum then return end
        if not ZBat.equipped then
            ZBat.equipped = true
            if not char:FindFirstChildOfClass("Tool") then
                local bat = zFindBat()
                if bat then pcall(function() hum:EquipTool(bat) end) end
            end
        end
        local target = zGetTarget()
        if not target then
            hum.AutoRotate = true
            return
        end
        local targetVel = target.AssemblyLinearVelocity
        local aimPos = target.Position
            + (targetVel * math.clamp(targetVel.Magnitude / 130, 0.05, 0.15))
            + Vector3.new(0, ZBat.VertOffset, 0)
        hum.AutoRotate = false
        local look = aimPos - root.Position
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if look.Magnitude > 0.01 and flatLook.Magnitude > 0.01 then
            local tYaw = math.deg(math.atan2(-flatLook.X, -flatLook.Z))
            local yawD = (tYaw - root.Orientation.Y + 180) % 360 - 180
            local yawR = math.clamp(math.rad(yawD) * ZBat.TurnSpeed, -ZBat.MaxTurnRate, ZBat.MaxTurnRate)
            root.AssemblyAngularVelocity = Vector3.new(0, yawR, 0)
            local dir = flatLook.Unit
            local desired = aimPos + dir * ZBat.Dist + Vector3.new(0, ZBat.Height, 0)
            local to = desired - root.Position
            local hDir = Vector3.new(to.X, 0, to.Z)
            local zSpeed = (_G.AceGetNormalAimbotSpeed and _G.AceGetNormalAimbotSpeed()) or ZBat.Speed
            local hVel = (hDir.Magnitude > 0.2) and (hDir.Unit * zSpeed) or Vector3.zero
            local vVel = Vector3.new(0, math.clamp(to.Y * 2.5, -ZBat.VertSpeed, ZBat.VertSpeed), 0)
            root.AssemblyLinearVelocity = Vector3.new(hVel.X, vVel.Y, hVel.Z)
            if sethiddenproperty then
                pcall(function() sethiddenproperty(root, "PhysicsRepRootPart", target) end)
            end
            if hDir.Magnitude > 0.5 then hum:Move(hDir.Unit, false) end
        end
        if State.autoSwingEnabled then
            local bat = zFindBat()
            if bat and bat.Parent == char then pcall(function() bat:Activate() end) end
        end
    end)
end

local function stopZombieBatAimbot()
    ZBat.on = false
    State.batAimbotZombie = false
    if ZBat.conn then ZBat.conn:Disconnect(); ZBat.conn = nil end
    ZBat.equipped = false
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        pcall(function()
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end)
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end

end

_G._7upStartZombieBatAimbot = startZombieBatAimbot
_G._7upStopZombieBatAimbot = stopZombieBatAimbot
_G._7upStopAutoLeft = stopAutoLeft
_G._7upStopAutoRight = stopAutoRight


-- ============================================================
-- MAIN FUNCTION
-- ============================================================
local function Main()
    if _G.SevenUpDuelsV2_MainExecuted then return end
    _G.SevenUpDuelsV2_MainExecuted = true

    local gui=Instance.new("ScreenGui")
    gui.Name="SevenUpDuelsV2"; gui.ResetOnSpawn=false; gui.DisplayOrder=10
    gui.IgnoreGuiInset=true; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=LP:WaitForChild("PlayerGui")
    -- Main UI scaling is isolated from mobile/stack buttons.
    local uiScaleObj=nil

    local function makeDraggable(frame,handle)
        local src=handle or frame
        local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
        src.InputBegan:Connect(function(inp)
            if State.uiLocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=inp.Position; startPos=frame.Position
                inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
            end
        end)
        src.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dragInput=inp end
        end)
        UIS.InputChanged:Connect(function(inp)
            if inp==dragInput and dragging and not State.uiLocked then
                local dx=inp.Position.X-dragStart.X; local dy=inp.Position.Y-dragStart.Y
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+dx,startPos.Y.Scale,startPos.Y.Offset+dy)
                pcall(function()
                    local pos = frame.Position
                    local posData = {x = pos.X.Offset, y = pos.Y.Offset}
                    _writefile("sevenup_gui_pos.json", HttpService:JSONEncode(posData))
                end)
            end
        end)
    end

    local function makeStackDraggable(frame, onTap)
        local dragStartPos, startPos = nil, nil
        local isDragging = false
        local movedEnough = false
        local wasPressed = false
        local pressTime = 0
        local movementAllowed = not State.stackButtonsLocked
        local saveDebounce = nil
        local activeInput = nil
        local moveConn, endConn = nil, nil

        local lockChangedConn = RunService.Heartbeat:Connect(function()
            movementAllowed = not State.stackButtonsLocked
        end)

        local function savePosNow()
            pcall(saveStackPositionsNow)
            if saveDebounce then task.cancel(saveDebounce) end
            saveDebounce = task.delay(0.2, function()
                pcall(function()
                    if requestSave then requestSave() end
                end)
                saveDebounce = nil
            end)
        end

        local function stopDrag(input)
            if not isDragging then return end
            if activeInput and input and activeInput ~= input then return end
            local wasPressedLocal = wasPressed
            local didMove = movedEnough
            wasPressed = false
            isDragging = false
            activeInput = nil
            if moveConn then moveConn:Disconnect(); moveConn = nil end
            if endConn then endConn:Disconnect(); endConn = nil end

            frame.BackgroundTransparency = 1

            if didMove then
                savePosNow()
            elseif wasPressedLocal and (tick() - pressTime) < 0.35 then
                if onTap then onTap() end
            end
        end

        frame.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if isDragging then return end
            wasPressed = true
            pressTime = tick()
            dragStartPos = input.Position
            startPos = frame.Position
            isDragging = true
            movedEnough = false
            activeInput = input
            frame.BackgroundTransparency = 1

            if moveConn then moveConn:Disconnect() end
            if endConn then endConn:Disconnect() end
            moveConn = UIS.InputChanged:Connect(function(inp)
                if not isDragging or not movementAllowed then return end
                if inp ~= activeInput and inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
                if activeInput and inp.UserInputType == Enum.UserInputType.Touch and inp ~= activeInput then return end
                local pos = inp.Position
                local delta = pos - dragStartPos
                if delta.Magnitude > 6 then movedEnough = true end
                if movedEnough then
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end)
            endConn = UIS.InputEnded:Connect(function(inp)
                if inp == activeInput or (activeInput == nil and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch)) then
                    stopDrag(inp)
                end
            end)
        end)

        frame.AncestryChanged:Connect(function()
            if not frame.Parent then
                lockChangedConn:Disconnect()
                if moveConn then moveConn:Disconnect() end
                if endConn then endConn:Disconnect() end
            end
        end)
    end

    -- ============================================================
    -- UI CREATION - green theme
    -- ============================================================
    local WIN_W = 450
    local WIN_H = 660
    local TITLE_H = 44
    local mainOuter = Instance.new("Frame", gui)
    mainOuter.Name = "MainOuter"
    mainOuter.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    uiScaleObj=Instance.new("UIScale",mainOuter)
    uiScaleObj.Name="MainUIOnlyScale"
    uiScaleObj.Scale=0.9
    
    local savedPos = UDim2.new(0, 10, 0.5, -WIN_H/2 + 40)
    pcall(function()
        if _isfile("sevenup_gui_pos.json") then
            local posData = HttpService:JSONDecode(_readfile("sevenup_gui_pos.json"))
            if posData and posData.x and posData.y then
                savedPos = UDim2.new(0, posData.x, 0, posData.y)
            end
        end
    end)
    mainOuter.Position = savedPos
    mainOuter.BackgroundColor3 = Color3.fromRGB(28,39,32); mainOuter.BackgroundTransparency = 1; mainOuter.BorderSizePixel = 0; mainOuter.ClipsDescendants = false
    mkCorner(mainOuter, 38); makeDraggable(mainOuter)
    local mainOuterStroke = Instance.new("UIStroke", mainOuter)
    mainOuterStroke.Thickness = 2
    mainOuterStroke.Color = Color3.fromRGB(125,142,131)
    mainOuterStroke.Transparency = 0.08
    local mainBorderGradient = Instance.new("UIGradient", mainOuterStroke)
    mainBorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(57,72,63)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(154,166,158)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(57,72,63)),
    })
    local innerBorder = Instance.new("Frame",mainOuter)
    innerBorder.Name = "InnerBorder"
    innerBorder.Size = UDim2.new(1,-10,1,-10); innerBorder.Position = UDim2.new(0,5,0,5)
    innerBorder.BackgroundTransparency = 1; innerBorder.BorderSizePixel = 0; innerBorder.ZIndex = 3
    mkCorner(innerBorder,20)
    local innerStroke = Instance.new("UIStroke",innerBorder)
    innerStroke.Thickness = 1; innerStroke.Transparency = 1; innerStroke.Color = Color3.fromRGB(0, 90, 42)
    local innerGradient = Instance.new("UIGradient",innerStroke)
    innerGradient.Color = ColorSequence.new(Color3.fromRGB(0, 220, 100),Color3.fromRGB(55, 180, 120))
    for _, sideX in ipairs({7, WIN_W-13}) do
        local sideRail=Instance.new("Frame",mainOuter)
        sideRail.Name="CanSideRail"; sideRail.Size=UDim2.new(0,6,1,-38); sideRail.Position=UDim2.new(0,sideX,0,19)
        sideRail.BackgroundColor3=sideX < WIN_W/2 and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,40,19)
        sideRail.BackgroundTransparency=sideX < WIN_W/2 and 0.72 or 0.42
        sideRail.BorderSizePixel=0; sideRail.ZIndex=4; mkCorner(sideRail,3)
        sideRail.Visible=false
        local railGradient=Instance.new("UIGradient",sideRail)
        railGradient.Color=ColorSequence.new(Color3.fromRGB(90,125,105),Color3.fromRGB(255,255,255)); railGradient.Rotation=90
    end
    for _, rimY in ipairs({3, WIN_H-21}) do
        local canRim=Instance.new("Frame",mainOuter)
        local isTop = rimY == 3
        canRim.Name="CanRim"; canRim.Size=isTop and UDim2.new(1,-58,0,18) or UDim2.new(1,-20,0,18)
        canRim.Position=isTop and UDim2.new(0,29,0,rimY) or UDim2.new(0,10,0,rimY)
        canRim.BackgroundColor3=Color3.fromRGB(146,159,150); canRim.BackgroundTransparency=0
        canRim.BorderSizePixel=0; canRim.ZIndex=4; mkCorner(canRim,9)
        canRim.Visible=false
        local rimGradient=Instance.new("UIGradient",canRim)
        rimGradient.Color=ColorSequence.new(Color3.fromRGB(66,82,72),Color3.fromRGB(178,189,181))
    end
    local pullTab=Instance.new("Frame",mainOuter)
    pullTab.Name="CanPullTab"; pullTab.Size=UDim2.new(0,72,0,9); pullTab.Position=UDim2.new(0.5,-36,0,7)
    pullTab.BackgroundColor3=Color3.fromRGB(66,78,70); pullTab.BorderSizePixel=0; pullTab.ZIndex=5; mkCorner(pullTab,5)
    pullTab.Visible=false
    _G._K7MainOuter = mainOuter

    local toggleBtn = Instance.new("TextButton", gui)
    toggleBtn.Name = "K7Toggle"
    toggleBtn.Size = UDim2.new(0, 96, 0, 38)
    toggleBtn.Position = UDim2.new(0, 12, 0, 50)
    toggleBtn.BackgroundColor3 = currentColorScheme.mainDark
    toggleBtn.BackgroundTransparency = 0.08
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "7UP"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.Font = Enum.Font.GothamBlack
    toggleBtn.TextSize = 11
    toggleBtn.ZIndex = 30
    mkCorner(toggleBtn, 14)
    local toggleStroke = Instance.new("UIStroke",toggleBtn)
    toggleStroke.Color = currentColorScheme.main; toggleStroke.Thickness = 1.5; toggleStroke.Transparency = 0.12
    local toggleGradient = Instance.new("UIGradient",toggleBtn)
    toggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,currentColorScheme.mainLight),
        ColorSequenceKeypoint.new(0.6,currentColorScheme.main),
        ColorSequenceKeypoint.new(1,currentColorScheme.mainDark)
    })
    local toggleScale = Instance.new("UIScale",toggleBtn)

    toggleBtn.MouseEnter:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, TextColor3 = currentColorScheme.mainLight}):Play()
        TweenService:Create(toggleScale,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Scale=1.06}):Play()
        TweenService:Create(toggleStroke,TweenInfo.new(0.15),{Thickness=2,Transparency=0}):Play()
    end)
    toggleBtn.MouseLeave:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.25, TextColor3 = currentColorScheme.main}):Play()
        TweenService:Create(toggleScale,TweenInfo.new(0.15),{Scale=1}):Play()
        TweenService:Create(toggleStroke,TweenInfo.new(0.15),{Thickness=1.5,Transparency=0.12}):Play()
    end)
    toggleBtn.MouseButton1Down:Connect(function() TweenService:Create(toggleScale,TweenInfo.new(0.07),{Scale=0.92}):Play() end)
    toggleBtn.MouseButton1Up:Connect(function() TweenService:Create(toggleScale,TweenInfo.new(0.14,Enum.EasingStyle.Back),{Scale=1.04}):Play() end)

    local function toggleMainUI()
        State.guiVisible = not State.guiVisible
        mainOuter.Visible = State.guiVisible
        if _G.GreenDuelsQAHide then pcall(_G.GreenDuelsQAHide, not State.guiVisible) end
        requestSave()
    end
    toggleBtn.MouseButton1Click:Connect(toggleMainUI)

    local bgImg = Instance.new("ImageLabel", mainOuter)
    bgImg.Name = "BgImage"
    -- Full body only — no top neck strip.
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.Position = UDim2.new(0, 0, 0, 0)
    bgImg.Image = State.bgImage or "rbxassetid://102557909116203"
    bgImg.ScaleType = Enum.ScaleType.Crop
    bgImg.BackgroundColor3 = currentColorScheme.mainDark
    bgImg.BackgroundTransparency = 0
    bgImg.ImageTransparency = 0.04
    bgImg.BorderSizePixel = 0
    bgImg.ZIndex = 0
    mkCorner(bgImg, 38)

    local topBgImg = Instance.new("ImageLabel", mainOuter)
    topBgImg.Name = "TopBgImage"
    topBgImg.Size = UDim2.new(1, 0, 0, 1)
    topBgImg.Position = UDim2.new(0, 0, 0, 0)
    topBgImg.Image = ""
    topBgImg.BackgroundTransparency = 1
    topBgImg.ImageTransparency = 1
    topBgImg.BorderSizePixel = 0
    topBgImg.Visible = false
    topBgImg.ZIndex = 0
    local topCanGradient = Instance.new("UIGradient", topBgImg)
    topCanGradient.Name = "AdaptiveCanBlend"
    topCanGradient.Color = adaptiveCanColorSequence(currentColorScheme, false)

    -- Layered cinematic tint: green atmosphere
    local atmosphere = Instance.new("Frame", mainOuter)
    atmosphere.Name = "GradientAtmosphere"
    atmosphere.Size = UDim2.new(1,0,1,-14)
    atmosphere.Position = UDim2.new(0,0,0,14)
    atmosphere.BackgroundColor3 = currentColorScheme.main
    -- A light directional wash preserves readability without hiding the skin.
    atmosphere.BackgroundTransparency = State.uiColorTheme == "Red" and 0.5 or 0.88
    atmosphere.BorderSizePixel = 0
    atmosphere.ZIndex = 1
    mkCorner(atmosphere,38)
    local atmosphereGradient = Instance.new("UIGradient", atmosphere)
    atmosphereGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentColorScheme.main),
        ColorSequenceKeypoint.new(0.22, currentColorScheme.mainDark),
        ColorSequenceKeypoint.new(0.72, currentColorScheme.stackBg),
        ColorSequenceKeypoint.new(1, currentColorScheme.topBg),
    })
    atmosphereGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.82),
        NumberSequenceKeypoint.new(0.52,0.95),
        NumberSequenceKeypoint.new(1,0.76),
    })
    atmosphereGradient.Rotation = 0

    local canArtwork=Instance.new("Frame",mainOuter)
    canArtwork.Size=UDim2.new(1,-16,1,-36); canArtwork.Position=UDim2.new(0,8,0,18)
    canArtwork.BackgroundTransparency=1; canArtwork.BorderSizePixel=0; canArtwork.ClipsDescendants=true; canArtwork.ZIndex=1
    mkCorner(canArtwork,32)
    local flavorSweep=Instance.new("Frame",canArtwork)
    flavorSweep.Size=UDim2.new(0,28,1,90); flavorSweep.Position=UDim2.new(0.56,0,0,-42)
    flavorSweep.Rotation=16; flavorSweep.BackgroundColor3=Color3.fromRGB(224,228,46)
    flavorSweep.BackgroundTransparency=0.63; flavorSweep.BorderSizePixel=0; flavorSweep.ZIndex=1
    mkCorner(flavorSweep,14)
    flavorSweep.Visible=false
    local logoWatermark=Instance.new("TextLabel",canArtwork)
    logoWatermark.Size=UDim2.new(0,320,0,170); logoWatermark.Position=UDim2.new(0,22,0,112)
    logoWatermark.BackgroundTransparency=1; logoWatermark.Text="7UP"; logoWatermark.TextColor3=Color3.fromRGB(255,255,255)
    logoWatermark.TextTransparency=0.84; logoWatermark.TextStrokeColor3=Color3.fromRGB(0,42,20); logoWatermark.TextStrokeTransparency=0.82
    logoWatermark.Font=Enum.Font.GothamBlack; logoWatermark.TextSize=108; logoWatermark.Rotation=-10; logoWatermark.ZIndex=1
    local logoDiscWatermark=Instance.new("Frame",canArtwork)
    logoDiscWatermark.Size=UDim2.new(0,82,0,82); logoDiscWatermark.Position=UDim2.new(0,155,0,165)
    logoDiscWatermark.BackgroundColor3=Color3.fromRGB(220,35,43); logoDiscWatermark.BackgroundTransparency=0.82
    logoDiscWatermark.BorderSizePixel=0; logoDiscWatermark.ZIndex=1; mkCorner(logoDiscWatermark,41)
    for _,bubbleData in ipairs({{252,48,5},{265,64,8},{247,80,4},{278,95,6},{204,318,5},{218,335,8},{230,354,4}}) do
        local bubble=Instance.new("Frame",canArtwork)
        bubble.Size=UDim2.new(0,bubbleData[3],0,bubbleData[3]); bubble.Position=UDim2.new(0,bubbleData[1],0,bubbleData[2])
        bubble.BackgroundColor3=Color3.fromRGB(255,255,255); bubble.BackgroundTransparency=0.76
        bubble.BorderSizePixel=0; bubble.ZIndex=1; mkCorner(bubble,bubbleData[3]/2)
    end

    local mainContent = Instance.new("Frame", mainOuter)
    mainContent.Name = "MainContent"
    mainContent.Size = UDim2.new(1, -16, 1, -36)
    mainContent.Position = UDim2.new(0, 8, 0, 18)
    mainContent.BackgroundTransparency = 1
    mainContent.BorderSizePixel = 0
    mainContent.ZIndex = 2
    mainContent.ClipsDescendants = true
    mkCorner(mainContent, 29)

    local accentBar = Instance.new("Frame", mainContent)
    accentBar.Size = UDim2.new(1, -60, 0, 1); accentBar.Position = UDim2.new(0,30,0,0)
    accentBar.BackgroundColor3 = currentColorScheme.accent; accentBar.BackgroundTransparency = 0.85
    accentBar.BorderSizePixel = 0; accentBar.ZIndex = 5
    accentBar.Visible = false

    local titleBar = Instance.new("Frame", mainContent)
    titleBar.Size = UDim2.new(1,0,0,TITLE_H)
    titleBar.BackgroundColor3 = currentColorScheme.topBg
    titleBar.BackgroundTransparency = 0.78
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 5
    mkCorner(titleBar, 24)
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = adaptiveCanColorSequence(currentColorScheme,false)
    titleGradient.Rotation = 8

    local avatarBg = Instance.new("Frame", titleBar)
    avatarBg.Name = "SevenUpTitleMusicButton"
    avatarBg.Size = UDim2.new(0,28,0,28); avatarBg.Position = UDim2.new(0,12,0,6)
    avatarBg.BackgroundColor3 = Color3.fromRGB(224,38,45); avatarBg.BackgroundTransparency = 0
    avatarBg.BorderSizePixel = 0; avatarBg.ZIndex = 6
    mkCorner(avatarBg,14)
    local avatarStroke = Instance.new("UIStroke",avatarBg)
    avatarStroke.Thickness = 1; avatarStroke.Transparency = 0.35
    local avatarGradient = Instance.new("UIGradient",avatarStroke)
    avatarGradient.Color = ColorSequence.new(Color3.fromRGB(128,18,26),Color3.fromRGB(245,90,90))
    local avatarImg = Instance.new("ImageLabel", avatarBg)
    avatarImg.Size = UDim2.new(1,-4,1,-4); avatarImg.Position = UDim2.new(0,2,0,2)
    avatarImg.BackgroundTransparency = 1; avatarImg.Image = ""; avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.ZIndex = 7; mkCorner(avatarImg,12)
    avatarImg.Visible = false
    local titleLogoSeven=Instance.new("TextLabel",avatarBg)
    titleLogoSeven.Name="TitleSevenLogo"
    titleLogoSeven.Size=UDim2.new(1,0,1,0); titleLogoSeven.BackgroundTransparency=1; titleLogoSeven.Text="7"
    titleLogoSeven.TextColor3=Color3.fromRGB(255,255,255); titleLogoSeven.TextStrokeColor3=currentColorScheme.mainDark
    titleLogoSeven.TextStrokeTransparency=0.25; titleLogoSeven.Font=Enum.Font.GothamBlack; titleLogoSeven.TextSize=20
    titleLogoSeven.Rotation=-8; titleLogoSeven.ZIndex=8
    local titleLogoClick=Instance.new("TextButton",avatarBg)
    titleLogoClick.Size=UDim2.new(1,0,1,0); titleLogoClick.BackgroundTransparency=1; titleLogoClick.BorderSizePixel=0; titleLogoClick.Text=""; titleLogoClick.ZIndex=9
    titleLogoClick.MouseButton1Click:Connect(function() pcall(openMusicPlayerUI) end)

    local userNameLbl = Instance.new("TextLabel", titleBar)
    userNameLbl.Size = UDim2.new(0,90,0,9); userNameLbl.Position = UDim2.new(0,12,0,34)
    userNameLbl.BackgroundTransparency = 1; userNameLbl.ZIndex = 6
    userNameLbl.Text = ""
    userNameLbl.TextColor3 = Color3.fromRGB(200,255,210)
    userNameLbl.Font = Enum.Font.GothamBold; userNameLbl.TextSize = 7
    userNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    userNameLbl.TextWrapped = true
    userNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    userNameLbl.Visible = false


    local titleLbl = Instance.new("TextLabel", titleBar)
    titleLbl.Name = "SevenUpMainTitle"
    titleLbl.Size = UDim2.new(0,220,0,16); titleLbl.Position = UDim2.new(0,50,0,7)
    titleLbl.BackgroundTransparency = 1; titleLbl.Text = "7UP DUELS"
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6
    local mainTitleGradient = Instance.new("UIGradient",titleLbl)
    mainTitleGradient.Name = "SevenUpMainTitleGradient"
    mainTitleGradient.Color = ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(255,255,255))

    local subTitleLbl = Instance.new("TextLabel", titleBar)
    subTitleLbl.Name = "DiscordSubTitle"
    subTitleLbl.Size = UDim2.new(0,220,0,11); subTitleLbl.Position = UDim2.new(0,50,0,24)
    subTitleLbl.BackgroundTransparency = 1; subTitleLbl.Text = "discord.gg/7up"
    subTitleLbl.TextColor3 = currentColorScheme.discordText or currentColorScheme.subtitleText
    subTitleLbl.Font = Enum.Font.GothamMedium; subTitleLbl.TextSize = 10
    subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; subTitleLbl.ZIndex = 6

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0,26,0,26); closeBtn.Position = UDim2.new(1,-36,0.5,-13)
    closeBtn.BackgroundColor3 = currentColorScheme.modeBtnBg; closeBtn.BackgroundTransparency = 0.85
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"; closeBtn.TextColor3 = currentColorScheme.closeBtn; closeBtn.Font = Enum.Font.GothamBlack; closeBtn.TextSize = 18
    closeBtn.ZIndex = 7; mkCorner(closeBtn,6)
    local closeStroke = Instance.new("UIStroke",closeBtn); closeStroke.Color = Color3.fromRGB(0,200,80); closeStroke.Transparency = 0.65
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn,TweenInfo.new(0.12),{TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.2,BackgroundColor3=Color3.fromRGB(0,120,60)}):Play()
        TweenService:Create(closeStroke,TweenInfo.new(0.12),{Transparency=0,Thickness=2}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn,TweenInfo.new(0.12),{TextColor3=currentColorScheme.closeBtn,BackgroundTransparency=0.85,BackgroundColor3=currentColorScheme.modeBtnBg}):Play()
        TweenService:Create(closeStroke,TweenInfo.new(0.12),{Transparency=0.65,Thickness=1}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function()
        State.guiVisible = false; mainOuter.Visible = false
        if _G.GreenDuelsQAHide then pcall(_G.GreenDuelsQAHide, true) end
        requestSave()
    end)

    local titleDiv = Instance.new("Frame", mainContent)
    titleDiv.Size = UDim2.new(1,0,0,1); titleDiv.Position = UDim2.new(0,0,0,TITLE_H)
    titleDiv.BackgroundColor3 = currentColorScheme.divider; titleDiv.BackgroundTransparency = 0.85
    titleDiv.BorderSizePixel = 0; titleDiv.ZIndex = 5
    titleDiv.Visible = false
    local titleDivGradient = Instance.new("UIGradient", titleDiv)
    titleDivGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,220,100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120,255,190)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(55,200,150)),
    })
    titleDivGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(0.18,0.12),
        NumberSequenceKeypoint.new(0.82,0.12), NumberSequenceKeypoint.new(1,1),
    })

    local CONTENT_Y = TITLE_H + 1
    local contentBg = Instance.new("Frame", mainContent)
    contentBg.Size = UDim2.new(1,0,1,-CONTENT_Y); contentBg.Position = UDim2.new(0,0,0,CONTENT_Y)
    contentBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    contentBg.BackgroundTransparency = 0.78
    contentBg.BorderSizePixel = 0; contentBg.ClipsDescendants = true; contentBg.ZIndex = 2
    mkCorner(contentBg, 24)

    do
        local scanLine = Instance.new("Frame", contentBg)
        scanLine.Name = "ScanHighlight"
        scanLine.Size = UDim2.new(1,-20,0,1)
        scanLine.Position = UDim2.new(0,10,0,-2)
        scanLine.BackgroundColor3 = Color3.fromRGB(0,220,100)
        scanLine.BackgroundTransparency = 0.82
        scanLine.BorderSizePixel = 0
        scanLine.ZIndex = 3
        scanLine.Visible = false
        local scanFade = Instance.new("UIGradient", scanLine)
        scanFade.Color = ColorSequence.new(Color3.fromRGB(0,220,100),Color3.fromRGB(55,200,150))
        scanFade.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})
        TweenService:Create(scanLine,TweenInfo.new(5.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=UDim2.new(0,10,1,1)}):Play()

        local function cornerPart(position,size)
            local part=Instance.new("Frame",contentBg)
            part.Position=position; part.Size=size; part.BackgroundColor3=Color3.fromRGB(0,200,80)
            part.BackgroundTransparency=0.35; part.BorderSizePixel=0; part.ZIndex=3
            part.Visible=false
            local fade=Instance.new("UIGradient",part)
            fade.Color=ColorSequence.new(Color3.fromRGB(0,220,100),Color3.fromRGB(55,200,150))
        end
        cornerPart(UDim2.new(0,10,0,10),UDim2.new(0,28,0,1))
        cornerPart(UDim2.new(0,10,0,10),UDim2.new(0,1,0,28))
        cornerPart(UDim2.new(1,-38,1,-11),UDim2.new(0,28,0,1))
        cornerPart(UDim2.new(1,-11,1,-38),UDim2.new(0,1,0,28))
    end

    -- TABS
    local TABS = {"Speed", "Main", "Visual", "Steal", "Config"}
    local TAB_LABELS = {"Movement", "Combat", "Visuals", "Auto Grab", "Settings"}
    local tabPages = {}
    local currentPage = nil
    local lo = 0
    local function LO() lo = lo+1; return lo end

    local TAB_BAR_W = 150
    local tabBar = Instance.new("Frame", contentBg)
    tabBar.Size = UDim2.new(0, TAB_BAR_W, 1, 0)
    tabBar.Position = UDim2.new(1, -TAB_BAR_W, 0, 0)
    tabBar.BackgroundColor3 = currentColorScheme.tabBarBg
    tabBar.BackgroundTransparency = 0.78
    tabBar.BorderSizePixel = 0
    tabBar.ClipsDescendants = true
    tabBar.ZIndex = 4
    mkCorner(tabBar, 12)
    local tabBarGradient = Instance.new("UIGradient", tabBar)
    tabBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentColorScheme.mainDark),
        ColorSequenceKeypoint.new(0.42, currentColorScheme.rowBg),
        ColorSequenceKeypoint.new(1, currentColorScheme.topBg),
    })
    tabBarGradient.Rotation = 90
    local tabBarStroke = Instance.new("UIStroke", tabBar)
    tabBarStroke.Color = currentColorScheme.border
    tabBarStroke.Transparency = 0.72
    tabBarStroke.Thickness = 1
    local tabDivider = Instance.new("Frame", contentBg)
    tabDivider.Size = UDim2.new(0,1,1,-24); tabDivider.Position = UDim2.new(1,-TAB_BAR_W,0,12)
    tabDivider.BackgroundColor3 = Color3.fromRGB(255,255,255); tabDivider.BackgroundTransparency = 0.28
    tabDivider.BorderSizePixel = 0; tabDivider.ZIndex = 6
    tabDivider.Visible = false
    local tabDividerGradient = Instance.new("UIGradient", tabDivider)
    tabDividerGradient.Color = ColorSequence.new(Color3.fromRGB(0,220,100),Color3.fromRGB(55,200,150))
    tabDividerGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.2,0.15),NumberSequenceKeypoint.new(0.8,0.15),NumberSequenceKeypoint.new(1,1)})
    tabDividerGradient.Rotation = 90
    -- Heavy soda-can navigation with bubbles and a 7UP badge.
    local navTitle = Instance.new("TextLabel", tabBar)
    navTitle.Size = UDim2.new(1,-30,0,24)
    navTitle.Position = UDim2.new(0,15,0,12)
    navTitle.BackgroundTransparency = 1
    navTitle.Text = ""
    navTitle.Visible = false
    navTitle.TextColor3 = Color3.fromRGB(0,204,102)
    navTitle.Font = Enum.Font.GothamBlack
    navTitle.TextSize = 9
    navTitle.TextXAlignment = Enum.TextXAlignment.Left
    navTitle.ZIndex = 8

    local TAB_POSITIONS = {
        {y = 18}, {y = 86}, {y = 154}, {y = 222}, {y = 290},
    }

    for _, bubbleData in ipairs({{122,18,7},{18,332,5},{128,354,10},{24,446,8},{116,438,4}}) do
        local bubble = Instance.new("Frame",tabBar)
        bubble.Name = "SodaBubble"
        bubble.Size = UDim2.new(0,bubbleData[3],0,bubbleData[3])
        bubble.Position = UDim2.new(0,bubbleData[1],0,bubbleData[2])
        bubble.BackgroundColor3 = Color3.fromRGB(220,255,232)
        bubble.BackgroundTransparency = 0.45
        bubble.BorderSizePixel = 0
        bubble.ZIndex = 5
        mkCorner(bubble,bubbleData[3]/2)
    end

    local sodaBadge = Instance.new("Frame",tabBar)
    sodaBadge.Name = "SevenUpSodaBadge"
    sodaBadge.Size = UDim2.new(1,-30,0,94)
    sodaBadge.Position = UDim2.new(0,15,1,-112)
    sodaBadge.BackgroundColor3 = currentColorScheme.mainDark
    sodaBadge.BackgroundTransparency = 0.12
    sodaBadge.BorderSizePixel = 0
    sodaBadge.ZIndex = 7
    mkCorner(sodaBadge,18)
    local badgeStroke = Instance.new("UIStroke",sodaBadge)
    badgeStroke.Color = currentColorScheme.mainLight; badgeStroke.Transparency = 0.25; badgeStroke.Thickness = 1.4
    local badgeGradient = Instance.new("UIGradient",sodaBadge)
    badgeGradient.Color = adaptiveCanColorSequence(currentColorScheme,true)
    badgeGradient.Rotation = 35

    local badgeDisc = Instance.new("Frame",sodaBadge)
    badgeDisc.Size = UDim2.new(0,45,0,45); badgeDisc.Position = UDim2.new(0,10,0,11)
    badgeDisc.BackgroundColor3 = Color3.fromRGB(224,38,45); badgeDisc.BorderSizePixel = 0; badgeDisc.ZIndex = 8
    mkCorner(badgeDisc,23)
    local badgeSeven = Instance.new("TextLabel",badgeDisc)
    badgeSeven.Name = "BadgeSevenLogo"
    badgeSeven.Size = UDim2.new(1,0,1,0); badgeSeven.BackgroundTransparency = 1; badgeSeven.Text = "7"
    badgeSeven.TextColor3 = Color3.fromRGB(255,255,255); badgeSeven.TextStrokeColor3 = currentColorScheme.mainDark
    badgeSeven.TextStrokeTransparency = 0.35; badgeSeven.Font = Enum.Font.GothamBlack; badgeSeven.TextSize = 29
    badgeSeven.Rotation = -8; badgeSeven.ZIndex = 9
    local badgeUp = Instance.new("TextLabel",sodaBadge)
    badgeUp.Size = UDim2.new(0,54,0,30); badgeUp.Position = UDim2.new(0,57,0,15)
    badgeUp.BackgroundTransparency = 1; badgeUp.Text = "UP"; badgeUp.TextColor3 = Color3.fromRGB(255,255,255)
    badgeUp.Font = Enum.Font.GothamBlack; badgeUp.TextSize = 22; badgeUp.TextXAlignment = Enum.TextXAlignment.Left; badgeUp.ZIndex = 9
    local badgeSub = Instance.new("TextLabel",sodaBadge)
    badgeSub.Size = UDim2.new(1,-20,0,19); badgeSub.Position = UDim2.new(0,10,1,-25)
    badgeSub.BackgroundTransparency = 1; badgeSub.Text = "discord.gg/7up"; badgeSub.TextColor3 = currentColorScheme.discordText or currentColorScheme.mainLight
    badgeSub.Font = Enum.Font.GothamBlack; badgeSub.TextSize = 7; badgeSub.TextXAlignment = Enum.TextXAlignment.Center; badgeSub.ZIndex = 9
    local badgeClick=Instance.new("TextButton",sodaBadge)
    badgeClick.Size=UDim2.new(1,0,1,0); badgeClick.BackgroundTransparency=1; badgeClick.BorderSizePixel=0; badgeClick.Text=""; badgeClick.ZIndex=10
    local badgeScale=Instance.new("UIScale",sodaBadge); badgeScale.Scale=1
    badgeClick.MouseEnter:Connect(function() TweenService:Create(badgeScale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.04}):Play() end)
    badgeClick.MouseLeave:Connect(function() TweenService:Create(badgeScale,TweenInfo.new(0.12),{Scale=1}):Play() end)
    badgeClick.MouseButton1Click:Connect(function() pcall(openMusicPlayerUI) end)

    local tabButtons = {}
    local selectedTab = nil

    for i, tabName in ipairs(TABS) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Name = "SevenUpNavTab"
        btn.Size = UDim2.new(0, 120, 0, 38)
        btn.Position = UDim2.new(0, 15, 0, TAB_POSITIONS[i].y)
        btn.BackgroundColor3 = currentColorScheme.rowBg
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.ClipsDescendants = true
        btn.Text = ""
        btn.ZIndex = 8
        mkCorner(btn, 14)
        local tabScale = Instance.new("UIScale",btn)
        tabScale.Scale=1
        local tabSurface = Instance.new("Frame", btn)
        tabSurface.Name = "GradientSurface"
        tabSurface.Size = UDim2.new(1,0,1,0)
        tabSurface.BackgroundColor3 = currentColorScheme.mainDark
        tabSurface.BackgroundTransparency = 0.14
        tabSurface.BorderSizePixel = 0
        tabSurface.Active = false
        tabSurface.ZIndex = 7
        mkCorner(tabSurface,14)
        local tabGradient = Instance.new("UIGradient", tabSurface)
        tabGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, currentColorScheme.main),
            ColorSequenceKeypoint.new(0.58, currentColorScheme.mainDark),
            ColorSequenceKeypoint.new(1, currentColorScheme.rowBg),
        })
        tabGradient.Rotation = 7
        for _,isRightCap in ipairs({false,true}) do
            local canCap=Instance.new("Frame",btn)
            canCap.Name="CanEndCap"
            canCap.Size=UDim2.new(0,7,1,-10)
            canCap.Position=isRightCap and UDim2.new(1,-10,0,5) or UDim2.new(0,3,0,5)
            canCap.BackgroundColor3=Color3.fromRGB(126,143,132)
            canCap.BorderSizePixel=0; canCap.ZIndex=8; mkCorner(canCap,4)
        end
        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = currentColorScheme.main
        btnStroke.Transparency = 0.42
        btnStroke.Thickness = 1

        local tabLabel = Instance.new("TextLabel", btn)
        tabLabel.Name = "SevenUpNavLabel"
        tabLabel.Size = UDim2.new(1,-20,1,0)
        tabLabel.Position = UDim2.new(0,12,0,0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = TAB_LABELS[i] or tabName
        tabLabel.TextColor3 = currentColorScheme.main
        tabLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        tabLabel.TextStrokeTransparency = 0.22
        tabLabel.Font = Enum.Font.GothamBlack
        tabLabel.TextSize = 14
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.ZIndex = 10

        local tabNumber=Instance.new("TextLabel",btn)
        tabNumber.Size=UDim2.new(0,25,0,22); tabNumber.Position=UDim2.new(0,8,0.5,-11)
        tabNumber.BackgroundColor3=Color3.fromRGB(0,55,27); tabNumber.BackgroundTransparency=0.08
        tabNumber.BorderSizePixel=0; tabNumber.Text=string.format("%02d",i); tabNumber.TextColor3=Color3.fromRGB(170,255,200)
        tabNumber.Font=Enum.Font.GothamBlack; tabNumber.TextSize=8; tabNumber.ZIndex=10; mkCorner(tabNumber,7)
        tabNumber.Visible=false
        local numberStroke=Instance.new("UIStroke",tabNumber); numberStroke.Color=Color3.fromRGB(150,255,185); numberStroke.Transparency=0.55

        local bar = Instance.new("Frame", btn)
        bar.AnchorPoint = Vector2.new(0, 0.5)
        bar.Size = UDim2.new(0, 4, 0, 22)
        bar.Position = UDim2.new(0, 3, 0.5, 0)
        bar.BackgroundColor3 = Color3.fromRGB(224,38,45)
        bar.BackgroundTransparency = 1
        bar.BorderSizePixel = 0
        bar.ZIndex = 9
        mkCorner(bar, 2)
        bar.Visible = false

        btn.MouseEnter:Connect(function()
            if selectedTab ~= i then
                TweenService:Create(tabLabel, TweenInfo.new(0.14), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
                TweenService:Create(tabSurface, TweenInfo.new(0.14), {BackgroundTransparency = 0}):Play()
                TweenService:Create(tabScale,TweenInfo.new(0.14,Enum.EasingStyle.Back),{Scale=1.035}):Play()
                TweenService:Create(btnStroke, TweenInfo.new(0.14), {Transparency = 0.08}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if selectedTab ~= i then
                TweenService:Create(tabLabel, TweenInfo.new(0.14), {TextColor3 = currentColorScheme.main}):Play()
                TweenService:Create(tabSurface, TweenInfo.new(0.14), {BackgroundTransparency = 0.14}):Play()
                TweenService:Create(tabScale,TweenInfo.new(0.14),{Scale=1}):Play()
                TweenService:Create(btnStroke, TweenInfo.new(0.14), {Transparency = 0.42}):Play()
            end
        end)
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(tabScale,TweenInfo.new(0.08),{Scale=0.96}):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(tabScale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.025}):Play()
        end)

        tabButtons[i] = {btn = btn, label = tabLabel, bar = bar, stroke = btnStroke, surface = tabSurface}
    end

    local tabContainer = Instance.new("Frame", contentBg)
    tabContainer.Size = UDim2.new(1, -TAB_BAR_W, 1, 0)
    tabContainer.Position = UDim2.new(0, 0, 0, 0)
    tabContainer.BackgroundColor3 = Color3.fromRGB(3, 4, 8)
    tabContainer.BackgroundTransparency = 0.58
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 3
    tabContainer.ClipsDescendants = true
    mkCorner(tabContainer, 18)
    local contentPanelStroke = Instance.new("UIStroke", tabContainer)
    contentPanelStroke.Color = Color3.fromRGB(0, 150, 75)
    contentPanelStroke.Transparency = 0.68
    contentPanelStroke.Thickness = 1

    local tabScroll = Instance.new("ScrollingFrame", tabContainer)
    tabScroll.Size = UDim2.new(1,0,1,0)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.ScrollBarImageColor3 = currentColorScheme.main
    tabScroll.ScrollBarImageTransparency = 0.4
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.CanvasSize = UDim2.new(0,0,0,0)
    tabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    tabScroll.ZIndex = 3
    tabScroll.ClipsDescendants = true

    local tabScrollPad = Instance.new("UIPadding", tabScroll)
    tabScrollPad.PaddingLeft = UDim.new(0,8)
    tabScrollPad.PaddingRight = UDim.new(0,8)
    tabScrollPad.PaddingTop = UDim.new(0,6)
    tabScrollPad.PaddingBottom = UDim.new(0,12)

    local function selectTab(index)
        for i, data in ipairs(tabButtons) do
            local btn = data.btn
            if i == index then
                selectedTab = i
                btn:SetAttribute("Selected", true)
                if data.label then TweenService:Create(data.label, TweenInfo.new(0.18), {TextColor3 = currentColorScheme.mainLight}):Play() end
                if data.surface then TweenService:Create(data.surface, TweenInfo.new(0.18), {BackgroundColor3=currentColorScheme.mainDark,BackgroundTransparency=0}):Play() end
                if data.bar then TweenService:Create(data.bar, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play() end
                if data.stroke then TweenService:Create(data.stroke, TweenInfo.new(0.15), {Color = currentColorScheme.main, Transparency = 0}):Play() end
            else
                btn:SetAttribute("Selected", false)
                if data.label then TweenService:Create(data.label, TweenInfo.new(0.18), {TextColor3 = currentColorScheme.main}):Play() end
                if data.surface then TweenService:Create(data.surface, TweenInfo.new(0.18), {BackgroundColor3=currentColorScheme.mainDark,BackgroundTransparency=0.14}):Play() end
                if data.bar then TweenService:Create(data.bar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play() end
                if data.stroke then TweenService:Create(data.stroke, TweenInfo.new(0.15), {Color = currentColorScheme.main, Transparency = 0.42}):Play() end
            end
        end

        for name, page in pairs(tabPages) do
            page.Visible = (name == TABS[index])
            if page.Visible then
                page.Position=UDim2.new(0,-14,0,0)
                TweenService:Create(page,TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
            end
        end
    end

    for i, data in ipairs(tabButtons) do
        data.btn.MouseButton1Click:Connect(function()
            if data.surface then data.surface.BackgroundTransparency=0.62 end
            if data.label then
                data.label.Position=UDim2.new(0,18,0,0)
                TweenService:Create(data.label,TweenInfo.new(0.22,Enum.EasingStyle.Back),{Position=UDim2.new(0,12,0,0)}):Play()
            end
            selectTab(i)
        end)
    end

    local function buildPage(tabName, buildFn)
        local page = Instance.new("Frame", tabScroll)
        page.Name = tabName
        page.Size = UDim2.new(1,0,0,0)
        page.AutomaticSize = Enum.AutomaticSize.Y
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        page.ZIndex = 3

        local ll = Instance.new("UIListLayout", page)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0,4)
        ll.HorizontalAlignment = Enum.HorizontalAlignment.Center

        tabPages[tabName] = page
        currentPage = page
        lo = 0
        buildFn()
        currentPage = nil
        return page
    end

    -- Helper Functions
    local function makeGap(px) local f=Instance.new("Frame",currentPage); f.Size=UDim2.new(1,0,0,px or 6); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=LO() end

    local function makeSectionHeader(label)
        local wrap = Instance.new("Frame", currentPage)
        wrap.Size = UDim2.new(1,0,0,30); wrap.BackgroundTransparency=1; wrap.BorderSizePixel=0; wrap.LayoutOrder=LO()
        local lbl = Instance.new("TextLabel", wrap); lbl.Size = UDim2.new(1,-28,1,0); lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency=1; lbl.Text = label and label:upper() or ""
        lbl.TextColor3 = currentColorScheme.sectionHeader
        lbl.Font = Enum.Font.GothamBlack; lbl.TextSize=12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local line = Instance.new("Frame", wrap); line.Size = UDim2.new(0,34,0,1); line.Position = UDim2.new(1,-44,0.5,0)
        line.BackgroundColor3 = currentColorScheme.main; line.BackgroundTransparency = 0.35; line.BorderSizePixel = 0
        line.Visible = false
        local sectionGradient=Instance.new("UIGradient",line)
        sectionGradient.Color=ColorSequence.new(Color3.fromRGB(0,220,100),Color3.fromRGB(55,200,150))
        sectionGradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
    end

    local function makeInputRow(label, default, onChange)
        local row = Instance.new("Frame", currentPage)
        row.Size = UDim2.new(1,-16,0,42); row.BackgroundColor3 = currentColorScheme.rowBg
        row.BackgroundTransparency = 0.76
        row.BorderSizePixel=0; row.LayoutOrder=LO(); mkCorner(row,12)
        local rowStroke = Instance.new("UIStroke", row); rowStroke.Color = currentColorScheme.mainDark; rowStroke.Transparency = 0.72
        local rowGradient = Instance.new("UIGradient", row); rowGradient.Color = ColorSequence.new(currentColorScheme.rowHover, currentColorScheme.rowBg); rowGradient.Rotation = 8
        row.MouseEnter:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundTransparency=0.56}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.1),{Transparency=0.35}):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundTransparency=0.76}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.1),{Transparency=0.72,Thickness=1}):Play()
        end)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-138,1,0); lbl.Position = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=currentColorScheme.rowLabel
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize=14; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local boxWrap = Instance.new("Frame", row)
        boxWrap.Size = UDim2.new(0,70,0,28); boxWrap.Position = UDim2.new(1,-120,0.5,-14)
        boxWrap.BackgroundColor3 = currentColorScheme.inputBg; boxWrap.BackgroundTransparency = 0.64
        boxWrap.BorderSizePixel=0
        mkCorner(boxWrap,8)
        local inputStroke = Instance.new("UIStroke", boxWrap); inputStroke.Color = currentColorScheme.main; inputStroke.Transparency = 0.58
        local inputGradient = Instance.new("UIGradient", boxWrap)
        inputGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,currentColorScheme.inputFocus),
            ColorSequenceKeypoint.new(0.55,currentColorScheme.inputBg),
            ColorSequenceKeypoint.new(1,currentColorScheme.rowBg),
        })
        inputGradient.Rotation=12
        local box = Instance.new("TextBox", boxWrap)
        box.Size = UDim2.new(1,-8,1,0); box.Position = UDim2.new(0,4,0,0)
        box.BackgroundTransparency=1; box.Text = tostring(default)
        box.TextColor3 = currentColorScheme.inputText; box.Font = Enum.Font.GothamBlack
        box.TextSize=15; box.ClearTextOnFocus=false; box.ZIndex=8; box.TextXAlignment=Enum.TextXAlignment.Center
        box.Focused:Connect(function() 
            TweenService:Create(boxWrap,TweenInfo.new(0.15),{BackgroundColor3=currentColorScheme.inputFocus,BackgroundTransparency=0.1}):Play()
            TweenService:Create(inputStroke,TweenInfo.new(0.15),{Transparency=0,Thickness=2}):Play()
        end)
        local function commitInput()
            if not onChange then return end
            local n = tonumber(box.Text)
            if n then
                onChange(n)
                -- reflect any clamp done by onChange (e.g. speed bounds)
                pcall(requestSave)
            else
                box.Text = tostring(default)
            end
        end
        box.FocusLost:Connect(function()
            TweenService:Create(boxWrap,TweenInfo.new(0.15),{BackgroundColor3=currentColorScheme.inputBg,BackgroundTransparency=0.85}):Play()
            TweenService:Create(inputStroke,TweenInfo.new(0.15),{Transparency=0.58,Thickness=1}):Play()
            commitInput()
        end)
        box.InputEnded:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.Return or inp.KeyCode == Enum.KeyCode.KeypadEnter then
                commitInput()
            end
        end)
        return box,row
    end

    local function makeToggleRow(label, defaultOn, onToggle)
        local row = Instance.new("Frame", currentPage)
        row.Size = UDim2.new(1,-16,0,42); row.BackgroundColor3 = currentColorScheme.rowBg
        row.BackgroundTransparency = defaultOn and 0.62 or 0.76
        row.BorderSizePixel=0; row.LayoutOrder=LO(); mkCorner(row,12)
        row:SetAttribute("ActiveState",defaultOn==true)
        local rowStroke = Instance.new("UIStroke", row); rowStroke.Color = defaultOn and currentColorScheme.main or currentColorScheme.mainDark; rowStroke.Transparency = defaultOn and 0.18 or 0.72; rowStroke.Thickness=defaultOn and 1.5 or 1
        local rowGradient = Instance.new("UIGradient", row); rowGradient.Color = ColorSequence.new(currentColorScheme.rowHover, currentColorScheme.rowBg); rowGradient.Rotation = 8
        row.MouseEnter:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundTransparency=0.56}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.1),{Transparency=0.35}):Play()
        end)
        row.MouseLeave:Connect(function()
            local active=row:GetAttribute("ActiveState")==true
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundTransparency=active and 0.62 or 0.76}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.1),{Transparency=active and 0.18 or 0.72,Thickness=active and 1.5 or 1}):Play()
        end)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-138,1,-4); lbl.Position = UDim2.new(0,10,0,2)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=currentColorScheme.rowLabel
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.TextWrapped=true; lbl.LineHeight=0.9; lbl.TextTruncate=Enum.TextTruncate.AtEnd

        local pillBg = Instance.new("Frame", row)
        pillBg.Name = "SevenUpActivator"
        pillBg.Size = UDim2.new(0,72,0,28); pillBg.Position = UDim2.new(1,-120,0.5,-14)
        pillBg.BackgroundColor3 = Color3.fromRGB(7,9,16)
        pillBg.BackgroundTransparency = 0.04
        pillBg.BorderSizePixel=0; pillBg.ZIndex=7; pillBg.ClipsDescendants=true; mkCorner(pillBg,14)
        local pillStroke = Instance.new("UIStroke", pillBg)
        pillStroke.Color = defaultOn and currentColorScheme.main or currentColorScheme.pillBorder
        pillStroke.Transparency = defaultOn and 0.05 or 0.28
        pillStroke.Thickness=1.5

        local activeFill = Instance.new("Frame", pillBg)
        activeFill.Size = UDim2.new(1,0,1,0)
        activeFill.BackgroundColor3=Color3.fromRGB(255,255,255); activeFill.BackgroundTransparency=defaultOn and 0.04 or 1
        activeFill.BorderSizePixel=0; activeFill.ZIndex=7; mkCorner(activeFill,13)
        local fillGradient=Instance.new("UIGradient",activeFill)
        fillGradient.Color=ColorSequence.new(currentColorScheme.main,currentColorScheme.mainDark); fillGradient.Rotation=8

        local statusLabel=Instance.new("TextLabel",pillBg)
        statusLabel.Size=UDim2.new(1,-26,1,0); statusLabel.Position=UDim2.new(0,24,0,0)
        statusLabel.BackgroundTransparency=1; statusLabel.Text=defaultOn and "ON" or "OFF"
        statusLabel.TextColor3=defaultOn and currentColorScheme.buttonText or currentColorScheme.subText
        statusLabel.TextStrokeColor3=Color3.fromRGB(0,0,0); statusLabel.TextStrokeTransparency=0.45
        statusLabel.Font=Enum.Font.GothamBlack; statusLabel.TextSize=11; statusLabel.ZIndex=9

        local dot = Instance.new("Frame", pillBg)
        dot.Name = "SodaCap"
        dot.Size=UDim2.new(0,16,0,16); dot.Position=UDim2.new(0,6,0.5,-8)
        dot.BackgroundColor3=defaultOn and currentColorScheme.mainLight or currentColorScheme.mainDark; dot.BorderSizePixel=0; dot.ZIndex=10; mkCorner(dot,8)
        local coreStroke=Instance.new("UIStroke",dot); coreStroke.Color=defaultOn and currentColorScheme.mainLight or currentColorScheme.pillBorder; coreStroke.Thickness=1
        local core=Instance.new("Frame",dot)
        core.AnchorPoint=Vector2.new(0.5,0.5); core.Position=UDim2.new(0.5,0,0.5,0); core.Size=UDim2.new(0,5,0,5)
        core.BackgroundColor3=defaultOn and currentColorScheme.buttonText or currentColorScheme.subText; core.BorderSizePixel=0; core.ZIndex=12; mkCorner(core,3)
        local capShine=Instance.new("Frame",dot)
        capShine.Size=UDim2.new(0,7,0,2); capShine.Position=UDim2.new(0,3,0,3)
        capShine.BackgroundColor3=Color3.fromRGB(255,255,255); capShine.BackgroundTransparency=0.28
        capShine.BorderSizePixel=0; capShine.ZIndex=11; mkCorner(capShine,1)
        capShine.Visible=false

        local isOn = defaultOn or false
        local function setV(on)
            isOn = on
            row:SetAttribute("ActiveState",on)
            if on then
                activeFill.Position=UDim2.new(0.5,0,0,0)
                activeFill.Size=UDim2.new(0,0,1,0)
                activeFill.BackgroundTransparency=0.04
                TweenService:Create(activeFill,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,1,0)}):Play()
                fillGradient.Rotation=8
                TweenService:Create(fillGradient,TweenInfo.new(0.35,Enum.EasingStyle.Quart),{Rotation=188}):Play()
            else
                TweenService:Create(activeFill,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{BackgroundTransparency=1}):Play()
            end
            TweenService:Create(row,TweenInfo.new(0.18),{BackgroundTransparency=on and 0.62 or 0.76}):Play()
            fillGradient.Color=ColorSequence.new(currentColorScheme.main,currentColorScheme.mainDark)
            TweenService:Create(rowStroke,TweenInfo.new(0.18),{Color=on and currentColorScheme.main or currentColorScheme.mainDark,Transparency=on and 0.18 or 0.72,Thickness=on and 1.5 or 1}):Play()
            TweenService:Create(dot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{BackgroundColor3=on and currentColorScheme.mainLight or currentColorScheme.mainDark,Rotation=on and 18 or 0}):Play()
            TweenService:Create(core,TweenInfo.new(0.18,Enum.EasingStyle.Back),{BackgroundColor3=on and currentColorScheme.buttonText or currentColorScheme.subText,Size=on and UDim2.new(0,8,0,8) or UDim2.new(0,6,0,6)}):Play()
            TweenService:Create(pillStroke,TweenInfo.new(0.18),{Color=on and currentColorScheme.main or currentColorScheme.pillBorder,Transparency=on and 0.05 or 0.28}):Play()
            TweenService:Create(coreStroke,TweenInfo.new(0.18),{Color=on and currentColorScheme.mainLight or currentColorScheme.pillBorder}):Play()
            statusLabel.Text=on and "ON" or "OFF"
            TweenService:Create(statusLabel,TweenInfo.new(0.18),{TextColor3=on and currentColorScheme.buttonText or currentColorScheme.subText}):Play()
        end
        local function toggle()
            isOn = not isOn; setV(isOn)
            if onToggle then pcall(onToggle, isOn) end
            requestSave()
        end
        local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(1,-122,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=5; clk.BorderSizePixel=0; clk.MouseButton1Click:Connect(toggle)
        local pClk = Instance.new("TextButton", pillBg); pClk.Size = UDim2.new(1,0,1,0); pClk.BackgroundTransparency=1; pClk.Text=""; pClk.ZIndex=11; pClk.BorderSizePixel=0; pClk.MouseButton1Click:Connect(toggle)
        local activatorScale=Instance.new("UIScale",pillBg); activatorScale.Scale=1
        pClk.MouseEnter:Connect(function()
            TweenService:Create(pillStroke,TweenInfo.new(0.12),{Transparency=0,Thickness=2}):Play()
            TweenService:Create(activatorScale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.055}):Play()
        end)
        pClk.MouseLeave:Connect(function()
            TweenService:Create(pillStroke,TweenInfo.new(0.12),{Transparency=isOn and 0.05 or 0.45,Thickness=1.5}):Play()
            TweenService:Create(activatorScale,TweenInfo.new(0.12),{Scale=1}):Play()
        end)
        pClk.MouseButton1Down:Connect(function() TweenService:Create(activatorScale,TweenInfo.new(0.07),{Scale=0.94}):Play() end)
        pClk.MouseButton1Up:Connect(function() TweenService:Create(activatorScale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.04}):Play() end)
        return setV, row, lbl
    end

    local function getKeyDisplayName(kc)
        if not kc or kc == Enum.KeyCode.Unknown then return "None" end
        local n = kc.Name
        local pretty = {
            LeftControl="LCtrl", RightControl="RCtrl", LeftShift="LShift", RightShift="RShift",
            LeftAlt="LAlt", RightAlt="RAlt", LeftSuper="LWin", RightSuper="RWin",
            Return="Enter", Backspace="Bksp", Delete="Del", Escape="Esc",
            Space="Space", Tab="Tab", CapsLock="Caps",
            ButtonA="A", ButtonB="B", ButtonX="X", ButtonY="Y",
            ButtonL1="LB", ButtonL2="LT", ButtonL3="LS",
            ButtonR1="RB", ButtonR2="RT", ButtonR3="RS",
            ButtonSelect="View", ButtonStart="Menu",
            DPadUp="D↑", DPadDown="D↓", DPadLeft="D←", DPadRight="D→",
        }
        if pretty[n] then return pretty[n] end
        -- Keyboard: keep readable name (not truncated like controller labels)
        if n:match("^Button") or n:match("^DPad") or n:match("^Thumbstick") then
            return n:gsub("Button",""):sub(1,5)
        end
        if #n <= 6 then return n end
        return n:sub(1,6)
    end

    local function isGamepadKeyCode(kc)
        if not kc then return false end
        local n = kc.Name
        return n:find("Button") == 1 or n:find("DPad") == 1 or n:find("Thumbstick") == 1
    end

    local function refreshAllKeybindButtons()
        for keyName, btn in pairs(keybindBtnRefs) do
            if btn and Keys[keyName] then
                btn.Text = getKeyDisplayName(Keys[keyName])
            end
        end
    end

    local function makeKeybindRow(label, currentKey, onChanged, keyName)
        local row = Instance.new("Frame", currentPage)
        row.Size = UDim2.new(1,0,0,44); row.BackgroundTransparency=1; row.BorderSizePixel=0; row.LayoutOrder=LO()
        local div = Instance.new("Frame", row); div.Size = UDim2.new(1,-28,0,1); div.Position = UDim2.new(0,14,1,-1)
        div.BackgroundColor3 = currentColorScheme.divider; div.BackgroundTransparency = 0.85
        div.BorderSizePixel=0
        div.Visible=false
        local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(1,-88,1,0); lbl.Position = UDim2.new(0,14,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=currentColorScheme.rowLabel; lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local kbtn = Instance.new("TextButton", row); kbtn.Size = UDim2.new(0,60,0,26); kbtn.Position = UDim2.new(1,-72,0.5,-13)
        kbtn.BackgroundColor3 = currentColorScheme.main; kbtn.BackgroundTransparency = 0.15
        kbtn.BorderSizePixel=0; kbtn.Text = getKeyDisplayName(currentKey)
        kbtn.TextColor3 = currentColorScheme.buttonText; kbtn.Font = Enum.Font.GothamBlack; kbtn.TextSize=11; kbtn.ZIndex=8
        kbtn.AutoButtonColor = true
        kbtn.Selectable = false -- prevent controller UI focus stealing on PC
        mkCorner(kbtn,13)

        local listening = false
        local lconn = nil
        local listenStartedAt = 0

        local function stopL(key)
            listening = false
            if lconn then lconn:Disconnect(); lconn = nil end
            TweenService:Create(kbtn, TweenInfo.new(0.12), {
                BackgroundColor3 = currentColorScheme.main,
                BackgroundTransparency = 0.15
            }):Play()
            kbtn.TextColor3 = currentColorScheme.buttonText
            if key then
                kbtn.Text = getKeyDisplayName(key)
                if onChanged then onChanged(key) end
                if requestSave then
                    requestSave()
                elseif saveConfig then
                    pcall(saveConfig)
                end
            else
                kbtn.Text = getKeyDisplayName(Keys[keyName] or Enum.KeyCode.Unknown)
            end
        end

        kbtn.MouseButton1Click:Connect(function()
            if listening then
                stopL(nil)
                return
            end
            listening = true
            listenStartedAt = tick()
            kbtn.Text = "..."
            kbtn.TextColor3 = currentColorScheme.buttonText
            TweenService:Create(kbtn, TweenInfo.new(0.12), {
                BackgroundColor3 = Color3.fromRGB(0, 160, 80),
                BackgroundTransparency = 0.05
            }):Play()

            if lconn then lconn:Disconnect() end
            lconn = UIS.InputBegan:Connect(function(inp, _gameProcessed)
                if not listening then return end
                -- ignore the click that opened listening + short grace period
                if tick() - listenStartedAt < 0.18 then return end

                local uit = inp.UserInputType
                local kc = inp.KeyCode

                -- Escape cancels
                if uit == Enum.UserInputType.Keyboard and kc == Enum.KeyCode.Escape then
                    stopL(nil)
                    return
                end

                -- Keyboard bind (PC default)
                if uit == Enum.UserInputType.Keyboard then
                    if kc == Enum.KeyCode.Unknown then return end
                    -- ignore pure modifiers alone if you want; allow them as binds
                    stopL(kc)
                    return
                end

                -- Only accept gamepad if a real gamepad is connected AND input is a face/bumper button
                if tostring(uit):find("Gamepad") then
                    local hasPad = false
                    pcall(function()
                        local pads = UIS:GetConnectedGamepads()
                        hasPad = pads and #pads > 0
                    end)
                    if not hasPad then return end -- ghost controller on PC
                    if not isGamepadKeyCode(kc) then return end
                    if kc == Enum.KeyCode.Thumbstick1 or kc == Enum.KeyCode.Thumbstick2 then return end
                    if kc == Enum.KeyCode.Unknown then return end
                    stopL(kc)
                    return
                end
                -- ignore mouse / touch while rebinding
            end)
        end)

        if keyName then keybindBtnRefs[keyName] = kbtn end
        return kbtn
    end

    -- ============================================================
    -- BUILD PAGES
    -- ============================================================
    -- SPEED TAB (unchanged)
    do
        local page = buildPage("Speed", function()
            makeGap(2)
            makeSectionHeader("Speed Values")
            makeGap(2)
            normalBox = makeInputRow("Normal Speed", State.normalSpeed, function(n)
                n = math.clamp(tonumber(n) or State.normalSpeed, 1, 500)
                State.normalSpeed = n
                markSpeedEdited()
                if normalBox then normalBox.Text = tostring(n) end
                if requestSave then requestSave() end
            end)
            carryBox = makeInputRow("Carry Speed", State.carrySpeed, function(n)
                n = math.clamp(tonumber(n) or State.carrySpeed, 1, 500)
                State.carrySpeed = n
                State._prevCarry = n
                markSpeedEdited()
                if carryBox then carryBox.Text = tostring(n) end
                if requestSave then requestSave() end
            end)
            laggerBox = makeInputRow("Lagger Speed", State.laggerSpeed, function(n)
                n = math.clamp(tonumber(n) or State.laggerSpeed, 0.1, 500)
                State.laggerSpeed = n
                if laggerBox then laggerBox.Text = tostring(n) end
                if requestSave then requestSave() end
            end)
            laggerCarryBox = makeInputRow("Lagger Carry Speed", State.laggerCarrySpeed, function(n)
                n = math.clamp(tonumber(n) or State.laggerCarrySpeed, 0.1, 500)
                State.laggerCarrySpeed = n
                if laggerCarryBox then laggerCarryBox.Text = tostring(n) end
                if requestSave then requestSave() end
            end)

            makeGap(8)
            makeSectionHeader("Speed Modes")
            makeGap(2)
            local setCarryMode = makeToggleRow("Carry Mode", State.speedToggled, function(on)
                State.speedToggled = on
                if carryBox then carryBox.Text = tostring(State.carrySpeed) end
                if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(on) end
                requestSave()
            end)
            toggleSetters["carryMode"] = setCarryMode

            local laggerToggle = makeToggleRow("Lagger Mode", State.laggerMode ~= 0, function(on)
                if on then State.laggerMode = 1 else State.laggerMode = 0 end
                if State.laggerMode == 0 then
                    State.carrySpeed = State._prevCarry or 30
                    State.speedToggled = State._prevSpeed or false
                    if carryBox then carryBox.Text = tostring(State.carrySpeed) end
                    if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
                else
                    if State.laggerMode == 1 then
                        if carryBox then carryBox.Text = tostring(State.carrySpeed) end
                    else
                        if carryBox then carryBox.Text = tostring(State.carrySpeed) end
                    end
                end
                updateLaggerButtons()
                requestSave()
            end)
            toggleSetters["laggerMode"] = laggerToggle

            makeGap(8)
            do
                local themeRow = Instance.new("Frame", currentPage)
                themeRow.Name = "SevenUpColorThemeRow"
                themeRow.Size = UDim2.new(1,-16,0,64)
                themeRow.BackgroundColor3 = currentColorScheme.rowBg
                themeRow.BackgroundTransparency = 0.08
                themeRow.BorderSizePixel = 0
                themeRow.LayoutOrder = LO()
                mkCorner(themeRow, 16)

                local themeTitle = Instance.new("TextLabel", themeRow)
                themeTitle.Size = UDim2.new(0.4,-12,1,0)
                themeTitle.Position = UDim2.new(0,14,0,0)
                themeTitle.BackgroundTransparency = 1
                themeTitle.Text = "7UP COLORWAY"
                themeTitle.TextColor3 = currentColorScheme.rowLabel
                themeTitle.Font = Enum.Font.GothamBlack
                themeTitle.TextSize = 11
                themeTitle.TextXAlignment = Enum.TextXAlignment.Left

                local greenButton = Instance.new("TextButton", themeRow)
                greenButton.Size = UDim2.new(0.29,-5,0,38)
                greenButton.Position = UDim2.new(0.4,0,0.5,-19)
                greenButton.BorderSizePixel = 0
                greenButton.Text = "GREEN 7UP"
                greenButton.TextColor3 = Color3.fromRGB(255,255,255)
                greenButton.Font = Enum.Font.GothamBlack
                greenButton.TextSize = 9
                greenButton.AutoButtonColor = false
                mkCorner(greenButton, 12)

                local redButton = Instance.new("TextButton", themeRow)
                redButton.Size = UDim2.new(0.29,-5,0,38)
                redButton.Position = UDim2.new(0.69,3,0.5,-19)
                redButton.BorderSizePixel = 0
                redButton.Text = "RED 7UP"
                redButton.TextColor3 = Color3.fromRGB(255,255,255)
                redButton.Font = Enum.Font.GothamBlack
                redButton.TextSize = 9
                redButton.AutoButtonColor = false
                mkCorner(redButton, 12)

                local function refreshColorThemeButtons()
                    local redSelected = State.uiColorTheme == "Red"
                    greenButton.BackgroundColor3 = redSelected
                        and Color3.fromRGB(6,45,24) or Color3.fromRGB(0,176,76)
                    redButton.BackgroundColor3 = redSelected
                        and Color3.fromRGB(220,32,46) or Color3.fromRGB(68,24,30)
                    greenButton.BackgroundTransparency = redSelected and 0.3 or 0
                    redButton.BackgroundTransparency = redSelected and 0 or 0.3
                    greenButton.TextTransparency = redSelected and 0.28 or 0
                    redButton.TextTransparency = redSelected and 0 or 0.28
                end
                _G._K7RefreshColorThemeButtons = refreshColorThemeButtons
                greenButton.MouseButton1Click:Connect(function() set7UpColorTheme("Green") end)
                redButton.MouseButton1Click:Connect(function() set7UpColorTheme("Red") end)
                refreshColorThemeButtons()
            end

        end)
        page.LayoutOrder = 1
    end

    -- MAIN TAB (unchanged)
    do
        local page = buildPage("Main", function()
            makeGap(2)
            makeSectionHeader("Aimbot")
            makeGap(2)

            setAutoSwing = makeToggleRow("Auto Swing", State.autoSwingEnabled, function(on)
                State.autoSwingEnabled = on
                requestSave()
            end)
            toggleSetters["autoSwing"] = setAutoSwing
            setBatCounter = makeToggleRow("Bat Counter", State.batCounterEnabled, function(on)
                State.batCounterEnabled = on
                if on then startBatCounter() else stopBatCounter() end
                requestSave()
            end)
            toggleSetters["batCounter"] = setBatCounter
            setMedusaCounter = makeToggleRow("Medusa Counter", State.medusaCounterEnabled, function(on)
                State.medusaCounterEnabled = on
                if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end
                requestSave()
            end)
            toggleSetters["medusaCounter"] = setMedusaCounter

            makeGap(6)

            -- Aimbot enable is via stack button / keybind only; OLD/NEW switch below
            _G.AceAimbotSetVisual = function(on)
                if stackBtnRefs and stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(on == true) end
            end

            makeGap(2)
            do
                local modeHolder = Instance.new("Frame", currentPage)
                modeHolder.Size  = UDim2.new(1,-16,0,52)
                modeHolder.BackgroundColor3 = currentColorScheme.rowBg
                modeHolder.BackgroundTransparency = 0.85
                modeHolder.BorderSizePixel = 0
                modeHolder.LayoutOrder = LO()
                mkCorner(modeHolder, 26)

                local slide = Instance.new("Frame", modeHolder)
                slide.Name  = "AimbotModeSlide"
                slide.Size  = UDim2.new(0.5,-4,1,-8)
                slide.Position = UDim2.new(0,4,0,4)
                slide.BackgroundColor3 = currentColorScheme.main
                slide.BackgroundTransparency = 0.15
                slide.BorderSizePixel = 0
                mkCorner(slide, 22)

                local oldTxt = Instance.new("TextLabel", modeHolder)
                oldTxt.Size = UDim2.new(0.5,0,1,0)
                oldTxt.Position = UDim2.new(0,0,0,0)
                oldTxt.BackgroundTransparency = 1
                oldTxt.Text = "OLD"
                oldTxt.TextColor3 = Color3.fromRGB(255,255,255)
                oldTxt.Font = Enum.Font.GothamBlack
                oldTxt.TextSize = 14
                oldTxt.TextXAlignment = Enum.TextXAlignment.Center
                oldTxt.ZIndex = 6

                local newTxt = Instance.new("TextLabel", modeHolder)
                newTxt.Size = UDim2.new(0.5,0,1,0)
                newTxt.Position = UDim2.new(0.5,0,0,0)
                newTxt.BackgroundTransparency = 1
                newTxt.Text = "NEW"
                newTxt.TextColor3 = Color3.fromRGB(255,255,255)
                newTxt.Font = Enum.Font.GothamBlack
                newTxt.TextSize = 14
                newTxt.TextXAlignment = Enum.TextXAlignment.Center
                newTxt.ZIndex = 6

                local oldClick = Instance.new("TextButton", modeHolder)
                oldClick.Size = UDim2.new(0.5,0,1,0)
                oldClick.Position = UDim2.new(0,0,0,0)
                oldClick.BackgroundTransparency = 1
                oldClick.Text = ""; oldClick.AutoButtonColor = false
                oldClick.ZIndex = 8

                local newClick = Instance.new("TextButton", modeHolder)
                newClick.Size = UDim2.new(0.5,0,1,0)
                newClick.Position = UDim2.new(0.5,0,0,0)
                newClick.BackgroundTransparency = 1
                newClick.Text = ""; newClick.AutoButtonColor = false
                newClick.ZIndex = 8

                local function syncModeUI()
                    local onNew = State.aimbotMode == "new"
                    TweenService:Create(slide, TweenInfo.new(0.18), {
                        Position = onNew and UDim2.new(0.5,-1,0,4) or UDim2.new(0,4,0,4)
                    }):Play()
                    TweenService:Create(oldTxt, TweenInfo.new(0.14), {
                        TextTransparency = onNew and 0.25 or 0
                    }):Play()
                    TweenService:Create(newTxt, TweenInfo.new(0.14), {
                        TextTransparency = onNew and 0 or 0.25
                    }):Play()
                    if stackBtnRefs.aimbot and stackBtnRefs.aimbot.setLabel then
                        stackBtnRefs.aimbot.setLabel(onNew and "AIMBOT\nNEW" or "AIMBOT\nOLD")
                    end
                end
                _G._K7SyncAimbotModeBox = syncModeUI

                local function setMode(mode)
                    if mode ~= "new" then mode = "old" end
                    -- Only switch which aimbot the keybind/mobile button will use.
                    -- Do NOT turn aimbot on here.
                    local wasOn = (State.batAimbotToggled == true)
                        or (_G.AceNormalAimbotOn == true)
                        or (State.batAimbotZombie == true)
                    State.aimbotMode = mode
                    -- Stop whatever is running so the next keybind starts the selected mode
                    pcall(function() if stopBatAimbot then stopBatAimbot() end end)
                    pcall(function() if stopZombieBatAimbot then stopZombieBatAimbot() end end)
                    pcall(function() if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end end)
                    State.batAimbotToggled = false
                    State.batAimbotZombie = false
                    if stackBtnRefs and stackBtnRefs.aimbot then
                        stackBtnRefs.aimbot.setOn(false)
                        if stackBtnRefs.aimbot.setLabel then
                            stackBtnRefs.aimbot.setLabel(mode == "new" and "AIMBOT\nNEW" or "AIMBOT\nOLD")
                        end
                    end
                    syncModeUI()
                    requestSave()
                end
                _G._K7SetAimbotMode = setMode

                oldClick.MouseButton1Click:Connect(function() setMode("old") end)
                newClick.MouseButton1Click:Connect(function() setMode("new") end)

                syncModeUI()
            end

            makeGap(4)
            makeSectionHeader("Aimbot Speed")
            makeGap(2)

            do
                local speedRow = Instance.new("Frame", currentPage)
                speedRow.Size = UDim2.new(1,-16,0,52)
                speedRow.BackgroundColor3 = currentColorScheme.rowBg; speedRow.BackgroundTransparency=0.85
                speedRow.BorderSizePixel=0; speedRow.LayoutOrder=LO()
                mkCorner(speedRow, 12)

                local function makeSpeedBox(labelTxt, getValue, setValue, xPos)
                    local lbl = Instance.new("TextLabel", speedRow)
                    lbl.Size=UDim2.new(0,70,0,18); lbl.Position=UDim2.new(0,xPos,0,6)
                    lbl.BackgroundTransparency=1; lbl.Text=labelTxt
                    lbl.TextColor3=currentColorScheme.rowLabel; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9
                    lbl.TextXAlignment=Enum.TextXAlignment.Left

                    local box = Instance.new("TextBox", speedRow)
                    box.Size=UDim2.new(0,58,0,24); box.Position=UDim2.new(0,xPos,0,26)
                    box.BackgroundColor3=currentColorScheme.inputBg; box.BackgroundTransparency=0.15
                    box.BorderSizePixel=0; box.Text=tostring(getValue())
                    box.TextColor3=currentColorScheme.inputText; box.Font=Enum.Font.GothamBold; box.TextSize=11
                    box.TextXAlignment=Enum.TextXAlignment.Center; box.ClearTextOnFocus=false
                    mkCorner(box, 7)
                    box.FocusLost:Connect(function()
                        local v = tonumber(box.Text)
                        if v and v >= 1 and v <= 500 then
                            v = math.clamp(v, 1, 500)
                            setValue(v)
                        else
                            setValue(getValue())
                        end
                        box.Text = tostring(getValue())
                        requestSave()
                    end)
                    return box
                end

                _G.AceAimbotSpeedBox = makeSpeedBox("Normal Speed", function()
                    return tonumber(AIMBOT_SPEED) or 50
                end, function(v)
                    AIMBOT_SPEED=v
                end, 8)

                _G.AceLaggerAimbotSpeedBox = makeSpeedBox("Lagger Speed", function()
                    return tonumber(LAGGER_AIMBOT_SPEED) or 40
                end, function(v)
                    LAGGER_AIMBOT_SPEED=v
                end, 76)
            end


            makeGap(8)
            makeSectionHeader("Safe Mode")
            makeGap(2)
            do
                local smRow = makeToggleRow("Safe Mode", antiKickEnabled, function(on)
                    antiKickEnabled = on
                    if not on then
                    else
                        if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
                            _G.AceSafeModeForceStop("SAFE MODE ACTIVE")
                        end
                    end
                    if _G._K7SafeModeSetVisual then _G._K7SafeModeSetVisual(on) end
                    requestSave()
                end)
                _G._K7SafeModeSetVisual = smRow
                toggleSetters["safeMode"] = smRow

                local infoRow = Instance.new("Frame", currentPage)
                infoRow.Size = UDim2.new(1,-16,0,30)
                infoRow.BackgroundColor3 = currentColorScheme.rowBg
                infoRow.BackgroundTransparency = 0.92
                infoRow.BorderSizePixel = 0
                infoRow.LayoutOrder = LO()
                mkCorner(infoRow, 8)
                local infoLbl = Instance.new("TextLabel", infoRow)
                infoLbl.Size = UDim2.new(1,-16,1,0)
                infoLbl.Position = UDim2.new(0,8,0,0)
                infoLbl.BackgroundTransparency = 1
                infoLbl.Text = "Blocks aimbot during countdown & brainrot carry"
                infoLbl.TextColor3 = currentColorScheme.subText
                infoLbl.Font = Enum.Font.Gotham
                infoLbl.TextSize = 9
                infoLbl.TextXAlignment = Enum.TextXAlignment.Left
                infoLbl.TextWrapped = true
            end

            makeGap(8)
            makeSectionHeader("Infinite Jump & Defense")
            makeGap(2)
            setInfJump = makeToggleRow("Infinite Jump", State.infJumpEnabled, function(on)
                State.infJumpEnabled = on
                requestSave()
            end)
            toggleSetters["infJump"] = setInfJump
            local function attachDefenseArrow(parentRow, parentLabel, subRow)
                if parentLabel then parentLabel.Size = UDim2.new(1,-170,1,-4) end
                local arrow = Instance.new("TextButton", parentRow)
                arrow.Name = "SevenUpDefenseArrow"
                arrow.Size = UDim2.new(0,26,0,26)
                arrow.Position = UDim2.new(1,-152,0.5,-13)
                arrow.BackgroundColor3 = currentColorScheme.modeBtnBg or currentColorScheme.rowBg
                arrow.BackgroundTransparency = 0.14
                arrow.BorderSizePixel = 0
                arrow.Text = ">"
                arrow.TextColor3 = currentColorScheme.mainLight or currentColorScheme.main
                arrow.Font = Enum.Font.GothamBlack
                arrow.TextSize = 16
                arrow.ZIndex = 20
                mkCorner(arrow,13)
                local open = false
                arrow:SetAttribute("Expanded", false)
                arrow.MouseButton1Click:Connect(function()
                    open = not open
                    arrow:SetAttribute("Expanded", open)
                    subRow.Visible = open
                    arrow.Text = open and "v" or ">"
                    local live = currentColorScheme
                    arrow.BackgroundColor3 = open and (live.modeBtnActBg or live.main)
                        or (live.modeBtnBg or live.rowBg)
                    arrow.TextColor3 = open and (live.buttonText or live.text)
                        or (live.mainLight or live.main)
                end)
                return arrow
            end

            local antiRagRow, antiRagLabel
            setAntiRag, antiRagRow, antiRagLabel = makeToggleRow("Anti Ragdoll", State.antiRagdollEnabled, function(on)
                State.antiRagdollEnabled = on
                if on then startAntiRagdollNew() else stopAntiRagdollNew() end
                requestSave()
            end)
            toggleSetters["antiRagdoll"] = setAntiRag

            local antiRagModeRow = Instance.new("Frame", currentPage)
            antiRagModeRow.Name = "AntiRagdollVersionRow"
            antiRagModeRow.Size = UDim2.new(1,-16,0,42)
            antiRagModeRow.BackgroundColor3 = Color3.fromRGB(4,28,15)
            antiRagModeRow.BackgroundTransparency = 0.18
            antiRagModeRow.BorderSizePixel = 0
            antiRagModeRow.LayoutOrder = LO()
            antiRagModeRow.Visible = false
            mkCorner(antiRagModeRow,12)
            local antiRagModeLabel = Instance.new("TextLabel", antiRagModeRow)
            antiRagModeLabel.Size = UDim2.new(1,-150,1,0)
            antiRagModeLabel.Position = UDim2.new(0,10,0,0)
            antiRagModeLabel.BackgroundTransparency = 1
            antiRagModeLabel.Text = "Anti-Ragdoll Mode"
            antiRagModeLabel.TextColor3 = currentColorScheme.rowLabel
            antiRagModeLabel.Font = Enum.Font.GothamSemibold
            antiRagModeLabel.TextSize = 11
            antiRagModeLabel.TextXAlignment = Enum.TextXAlignment.Left

            local function makeRagdollVersionButton(text, xOffset)
                local button = Instance.new("TextButton", antiRagModeRow)
                button.Size = UDim2.new(0,42,0,28)
                button.Position = UDim2.new(1,xOffset,0.5,-14)
                button.BackgroundColor3 = Color3.fromRGB(6,46,23)
                button.BackgroundTransparency = 0.2
                button.BorderSizePixel = 0
                button.Text = text
                button.Font = Enum.Font.GothamBlack
                button.TextSize = 11
                button.ZIndex = 8
                mkCorner(button,10)
                return button
            end
            local ragV1Button = makeRagdollVersionButton("V1",-136)
            local ragV2Button = makeRagdollVersionButton("V2",-90)
            local function refreshRagdollVersionButtons()
                local useV2 = State.antiRagdollVersion == "V2"
                ragV1Button.BackgroundColor3 = useV2 and Color3.fromRGB(6,46,23) or Color3.fromRGB(0,176,76)
                ragV2Button.BackgroundColor3 = useV2 and Color3.fromRGB(0,176,76) or Color3.fromRGB(6,46,23)
                ragV1Button.TextColor3 = useV2 and Color3.fromRGB(105,210,145) or Color3.fromRGB(255,255,255)
                ragV2Button.TextColor3 = useV2 and Color3.fromRGB(255,255,255) or Color3.fromRGB(105,210,145)
            end
            local function selectRagdollVersion(version)
                State.antiRagdollVersion = version
                refreshRagdollVersionButtons()
                if State.antiRagdollEnabled then
                    stopAntiRagdollNew()
                    startAntiRagdollNew()
                end
                requestSave()
            end
            ragV1Button.MouseButton1Click:Connect(function() selectRagdollVersion("V1") end)
            ragV2Button.MouseButton1Click:Connect(function() selectRagdollVersion("V2") end)
            _G._K7RefreshRagdollVersionButtons = refreshRagdollVersionButtons
            refreshRagdollVersionButtons()
            attachDefenseArrow(antiRagRow, antiRagLabel, antiRagModeRow)

            local antiDieToggle, antiDieRow, antiDieLabel = makeToggleRow("Anti Die", State.antiDieEnabled, function(on)
                if on then
                    startAntiDie()
                else
                    stopAntiDie()
                end
                requestSave()
            end)
            toggleSetters["antiDie"] = antiDieToggle

            local antiFlingToggle, antiFlingRow = makeToggleRow("Anti-Fling Shield", State.antiFlingShieldEnabled, function(on)
                if on then startAntiFlingShield() else stopAntiFlingShield() end
                requestSave()
            end)
            antiFlingRow.Name = "AntiFlingShieldRow"
            antiFlingRow.Visible = false
            toggleSetters["antiFlingShield"] = antiFlingToggle
            attachDefenseArrow(antiDieRow, antiDieLabel, antiFlingRow)

            makeGap(8)
            makeSectionHeader("Auto TP")
            makeGap(2)
            local autoTPToggle = makeToggleRow("Auto TP", State.autoTPEnabled, function(on)
                State.autoTPEnabled = on
                if on then startAutoTP() else stopAutoTP() end
                requestSave()
            end)
            toggleSetters["autoTP"] = autoTPToggle
            autoTPHeightBox = makeInputRow("Auto TP Height", State.autoTPHeight, function(n)
                if n and n >= 2 and n <= 500 then State.autoTPHeight = n end
            end)

            makeGap(8)
            makeSectionHeader("Combat")
            makeGap(2)


            makeGap(4)
            local autoLeftSetter = makeToggleRow("Auto Left", State.autoLeftEnabled == true, function(on)
                if on then startAutoLeft() else stopAutoLeft() end
                requestSave()
            end)
            toggleSetters["autoLeft"] = autoLeftSetter

            local autoRightSetter = makeToggleRow("Auto Right", State.autoRightEnabled == true, function(on)
                if on then startAutoRight() else stopAutoRight() end
                requestSave()
            end)
            toggleSetters["autoRight"] = autoRightSetter


            makeGap(8)
        end)
        page.LayoutOrder = 2
    end

    -- VISUAL TAB (updated with Headless, Korblox, Outfit Changer)
    do
        local page = buildPage("Visual", function()
            makeGap(2)
            makeSectionHeader("Soda Can Skins")
            makeGap(2)

            local bgImages = {
                {id = "rbxassetid://102557909116203", label = "CLASSIC"},
                {id = "rbxassetid://85219527046711", label = "FIZZ"},
                {id = "rbxassetid://139630779093907", label = "NIGHT"},
            }

            local previewFrame = Instance.new("Frame", currentPage)
            previewFrame.Size = UDim2.new(1, -16, 0, 104)
            previewFrame.BackgroundColor3 = Color3.fromRGB(0, 82, 38)
            previewFrame.BackgroundTransparency = 0.12
            previewFrame.BorderSizePixel = 0
            previewFrame.LayoutOrder = LO()
            mkCorner(previewFrame, 18)
            local previewStroke=Instance.new("UIStroke",previewFrame); previewStroke.Color=Color3.fromRGB(195,225,202); previewStroke.Transparency=0.28; previewStroke.Thickness=2
            local previewGradient=Instance.new("UIGradient",previewFrame)
            previewGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(210,235,215)),ColorSequenceKeypoint.new(0.08,Color3.fromRGB(0,175,75)),ColorSequenceKeypoint.new(0.75,Color3.fromRGB(0,55,26)),ColorSequenceKeypoint.new(1,Color3.fromRGB(160,185,166))})

            local previewImage = Instance.new("ImageLabel", previewFrame)
            previewImage.Size = UDim2.new(1, -18, 1, -34)
            previewImage.Position = UDim2.new(0, 9, 0, 9)
            previewImage.BackgroundTransparency = 1
            previewImage.Image = State.bgImage or "rbxassetid://102557909116203"
            previewImage.ScaleType = Enum.ScaleType.Crop
            previewImage.ZIndex = 2
            mkCorner(previewImage, 12)

            local previewLabel = Instance.new("TextLabel", previewFrame)
            previewLabel.Size = UDim2.new(1, -20, 0, 18)
            previewLabel.Position = UDim2.new(0, 10, 1, -23)
            previewLabel.BackgroundTransparency = 1
            previewLabel.Text = "ACTIVE CAN SKIN"
            previewLabel.TextColor3 = Color3.fromRGB(255,255,255)
            previewLabel.Font = Enum.Font.GothamBlack
            previewLabel.TextSize = 8
            previewLabel.TextXAlignment = Enum.TextXAlignment.Left
            previewLabel.ZIndex = 3

            local bgGrid = Instance.new("Frame", currentPage)
            bgGrid.Size = UDim2.new(1, -16, 0, 0)
            bgGrid.BackgroundTransparency = 1
            bgGrid.BorderSizePixel = 0
            bgGrid.LayoutOrder = LO()
            bgGrid.AutomaticSize = Enum.AutomaticSize.Y

            local gridLayout = Instance.new("UIListLayout", bgGrid)
            gridLayout.FillDirection = Enum.FillDirection.Horizontal
            gridLayout.Padding = UDim.new(0, 8)
            gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center

            for _, bgData in ipairs(bgImages) do
                local btn = Instance.new("TextButton", bgGrid)
                btn.Size = UDim2.new(0, 72, 0, 62)
                btn.BackgroundColor3 = Color3.fromRGB(0,72,34)
                btn.BackgroundTransparency = 0.08
                btn.BorderSizePixel = 0
                btn.Text = ""
                btn.ZIndex = 2
                mkCorner(btn, 15)
                local btnStroke=Instance.new("UIStroke",btn); btnStroke.Color=State.bgImage==bgData.id and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,190,150); btnStroke.Transparency=State.bgImage==bgData.id and 0.08 or 0.5; btnStroke.Thickness=State.bgImage==bgData.id and 2 or 1
                local btnGradient=Instance.new("UIGradient",btn)
                btnGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(205,228,210)),ColorSequenceKeypoint.new(0.12,Color3.fromRGB(0,175,76)),ColorSequenceKeypoint.new(0.8,Color3.fromRGB(0,55,27)),ColorSequenceKeypoint.new(1,Color3.fromRGB(150,178,157))})
                local btnScale=Instance.new("UIScale",btn); btnScale.Scale=1

                local thumb = Instance.new("ImageLabel", btn)
                thumb.Size = UDim2.new(1, -10, 0, 39)
                thumb.Position = UDim2.new(0, 5, 0, 5)
                thumb.BackgroundTransparency = 1
                thumb.Image = bgData.id
                thumb.ScaleType = Enum.ScaleType.Crop
                thumb.ZIndex = 3
                mkCorner(thumb, 10)

                local label = Instance.new("TextLabel", btn)
                label.Size = UDim2.new(1, -8, 0, 14)
                label.Position = UDim2.new(0, 4, 1, -17)
                label.BackgroundTransparency = 1
                label.Text = bgData.label
                label.TextColor3 = currentColorScheme.subText
                label.Font = Enum.Font.GothamBlack
                label.TextSize = 8
                label.TextXAlignment = Enum.TextXAlignment.Center
                label.ZIndex = 3

                local skinCap=Instance.new("Frame",btn)
                skinCap.Name="SkinCap"; skinCap.Size=UDim2.new(0,10,0,10); skinCap.Position=UDim2.new(1,-14,0,4)
                skinCap.BackgroundColor3=Color3.fromRGB(224,38,45); skinCap.BorderSizePixel=0; skinCap.ZIndex=5
                skinCap.Visible=State.bgImage==bgData.id; mkCorner(skinCap,5)

                if State.bgImage == bgData.id then
                    btn.BackgroundColor3 = currentColorScheme.main
                    btn.BackgroundTransparency = 0.1
                end

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.05}):Play()
                    TweenService:Create(btnScale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.05}):Play()
                    previewImage.Image = bgData.id
                end)

                btn.MouseLeave:Connect(function()
                    if State.bgImage ~= bgData.id then
                        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
                    end
                    TweenService:Create(btnScale,TweenInfo.new(0.12),{Scale=1}):Play()
            previewImage.Image = State.bgImage or "rbxassetid://102557909116203"
                end)

                btn.MouseButton1Click:Connect(function()
                    for _, b in pairs(bgGrid:GetChildren()) do
                        if b:IsA("TextButton") then
                            b.BackgroundColor3 = Color3.fromRGB(0,72,34)
                            b.BackgroundTransparency = 0.2
                            local oldStroke=b:FindFirstChildOfClass("UIStroke"); if oldStroke then oldStroke.Transparency=0.5; oldStroke.Thickness=1 end
                            local oldCap=b:FindFirstChild("SkinCap"); if oldCap then oldCap.Visible=false end
                        end
                    end
                    btn.BackgroundColor3 = currentColorScheme.main
                    btn.BackgroundTransparency = 0.1
                    btnStroke.Transparency=0.08; btnStroke.Thickness=2; skinCap.Visible=true
                    changeDuelScriptBackground(bgData.id)
                    previewImage.Image = bgData.id
                    requestSave()
                end)
            end

            previewImage.Image = State.bgImage or "rbxassetid://102557909116203"

            makeGap(8)
            makeSectionHeader("Visual Settings")
            makeGap(2)
            
            antiLagSetter = makeToggleRow("Anti-Lag", State.antiLagEnabled, function(on)
                State.antiLagEnabled = on
                if on then enableAntiLag() else disableAntiLag() end
                requestSave()
            end)
            toggleSetters["antiLag"] = antiLagSetter

            local satSetter = makeToggleRow("Saturated Colors", State.saturatedColorsEnabled, function(on)
                State.saturatedColorsEnabled = on
                if on then enableSaturatedColors() else disableSaturatedColors() end
                requestSave()
            end)
            toggleSetters["saturatedColors"] = satSetter

            makeGap(4)
            makeSectionHeader("Field of View")
            makeGap(2)
            
            makeInputRow("FOV (Normal)", _G._VezyFOV or 70, function(n)
                if n >= 70 and n <= 180 then
                    _G._VezyFOV = n
                    local cam = workspace.CurrentCamera
                    if cam and not State.stretchedResEnabled then
                        pcall(function() cam.FieldOfView = n end)
                    end
                    requestSave()
                end
            end)

            makeGap(4)
            makeSectionHeader("Wide Stretch")
            makeGap(2)
            
            stretchSetter = makeToggleRow("Stretch Rez", State.stretchedResEnabled, function(on)
                State.stretchedResEnabled = on
                if on then enableStretchRez() else disableStretchRez() end
                requestSave()
            end)
            toggleSetters["stretchedRes"] = stretchSetter

            makeInputRow("Stretch Value", State.stretchValue or 0.7, function(n)
                n = math.clamp(tonumber(n) or 0.7, 0.3, 1.5)
                State.stretchValue = n
                if State.stretchedResEnabled then
                    disableStretchRez()
                    enableStretchRez()
                end
                requestSave()
            end)

            makeGap(4)
            makeSectionHeader("Character Visuals")
            makeGap(2)
            
            removeAccSetter = makeToggleRow("Remove Accessories", State.removeAcc, function(on)
                State.removeAcc = on
                if not on then
                    if _G._removeAccStop then _G._removeAccStop() end
                end
                if State.customSkinEnabled then pcall(applyCustomSkinToChar, LP.Character) end
                if on then
                    if _G._removeAccStart then _G._removeAccStart() end
                    -- ApplyDescription may stream the catalog accessory back
                    -- a few frames later. Keep purging only the skin-added hat
                    -- during that short window.
                    task.spawn(function()
                        for _ = 1, 16 do
                            if not State.removeAcc then break end
                            pcall(removeCharAccessories, LP.Character)
                            task.wait(0.12)
                        end
                    end)
                end
                requestSave()
            end)
            toggleSetters["removeAcc"] = removeAccSetter

            -- ── NEW: Headless Toggle ──────────────────────────────
            local headlessSetter = makeToggleRow("Headless", State.headlessEnabled, function(on)
                State.headlessEnabled = on
                applyCharterToChar(LP.Character)
                requestSave()
            end)
            toggleSetters["headless"] = headlessSetter

            -- ── NEW: Korblox Toggle ──────────────────────────────
            local korbloxSetter = makeToggleRow("Korblox", State.korbloxEnabled, function(on)
                State.korbloxEnabled = on
                applyCharterToChar(LP.Character)
                requestSave()
            end)
            toggleSetters["korblox"] = korbloxSetter

            -- Custom skin preview/apply popup
            do
                local skinRow = Instance.new("Frame", currentPage)
                skinRow.Size = UDim2.new(1,-16,0,58)
                skinRow.BackgroundColor3 = currentColorScheme.rowBg
                skinRow.BackgroundTransparency = 0.08
                skinRow.BorderSizePixel = 0
                skinRow.LayoutOrder = LO()
                mkCorner(skinRow, 15)
                local skinRowGradient = Instance.new("UIGradient", skinRow)
                skinRowGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, currentColorScheme.mainDark),
                    ColorSequenceKeypoint.new(0.55, currentColorScheme.rowBg),
                    ColorSequenceKeypoint.new(1, currentColorScheme.stackBg),
                })
                skinRowGradient.Rotation = 8

                local skinTitle = Instance.new("TextLabel", skinRow)
                skinTitle.Size = UDim2.new(1,-112,0,24)
                skinTitle.Position = UDim2.new(0,14,0,7)
                skinTitle.BackgroundTransparency = 1
                skinTitle.Text = "CUSTOM SKINS"
                skinTitle.TextColor3 = Color3.fromRGB(245,255,247)
                skinTitle.Font = Enum.Font.GothamBlack
                skinTitle.TextSize = 14
                skinTitle.TextXAlignment = Enum.TextXAlignment.Left

                local skinStatus = Instance.new("TextLabel", skinRow)
                skinStatus.Size = UDim2.new(1,-112,0,17)
                skinStatus.Position = UDim2.new(0,14,0,31)
                skinStatus.BackgroundTransparency = 1
                skinStatus.Font = Enum.Font.GothamBold
                skinStatus.TextSize = 10
                skinStatus.TextXAlignment = Enum.TextXAlignment.Left

                local skinOpen = Instance.new("TextButton", skinRow)
                skinOpen.Size = UDim2.new(0,82,0,34)
                skinOpen.Position = UDim2.new(1,-94,0.5,-17)
                skinOpen.BackgroundColor3 = Color3.fromRGB(225,38,45)
                skinOpen.BorderSizePixel = 0
                skinOpen.Text = "PREVIEW"
                skinOpen.TextColor3 = Color3.fromRGB(255,255,255)
                skinOpen.Font = Enum.Font.GothamBlack
                skinOpen.TextSize = 11
                skinOpen.AutoButtonColor = false
                skinOpen.ZIndex = 5
                mkCorner(skinOpen, 12)

                local activeSkinPopup = nil
                local function refreshSkinRow()
                    local on = State.customSkinEnabled == true
                    local selected = tonumber(State.customSkinVariant) == 2 and 2 or 1
                    local skinName = CUSTOM_SKIN_VARIANTS[selected].name
                    skinStatus.Text = on and (skinName .. " EQUIPPED • TAP TO VIEW")
                        or (skinName .. " READY • TAP TO PREVIEW")
                    skinStatus.TextColor3 = on and currentColorScheme.mainLight or currentColorScheme.subText
                    skinOpen.Text = on and "ACTIVE" or "PREVIEW"
                    skinOpen.BackgroundColor3 = on and currentColorScheme.main or currentColorScheme.mainDark
                end
                toggleSetters["customSkin"] = function()
                    refreshSkinRow()
                    if activeSkinPopup and activeSkinPopup.sync then activeSkinPopup.sync() end
                end
                refreshSkinRow()

                local function setCustomSkinEnabled(on)
                    State.customSkinEnabled = on == true
                    syncCustomSkinVariant(State.customSkinVariant)
                    applyCharterToChar(LP.Character)
                    refreshSkinRow()
                    if activeSkinPopup and activeSkinPopup.sync then activeSkinPopup.sync() end
                    if activeSkinPopup and activeSkinPopup.refreshPreview then
                        activeSkinPopup.refreshPreview()
                    end
                    requestSave()
                end

                local function closeSkinPopup()
                    if activeSkinPopup and activeSkinPopup.dragConn then
                        activeSkinPopup.dragConn:Disconnect()
                    end
                    if activeSkinPopup and activeSkinPopup.root then
                        activeSkinPopup.root:Destroy()
                    end
                    activeSkinPopup = nil
                end

                local function openSkinPopup()
                    if activeSkinPopup and activeSkinPopup.root and activeSkinPopup.root.Parent then
                        activeSkinPopup.root.Visible = true
                        if activeSkinPopup.refreshPreview then activeSkinPopup.refreshPreview() end
                        return
                    end

                    local camera = workspace.CurrentCamera
                    local viewSize = camera and camera.ViewportSize or Vector2.new(800,600)
                    local panelWidth = math.clamp(viewSize.X - 28, 300, 390)
                    local panelHeight = math.clamp(viewSize.Y - 30, 430, 500)

                    local dim = Instance.new("TextButton", gui)
                    dim.Name = "CustomSkinPopup"
                    dim.Size = UDim2.new(1,0,1,0)
                    dim.BackgroundColor3 = currentColorScheme.topBg
                    dim.BackgroundTransparency = 0.24
                    dim.BorderSizePixel = 0
                    dim.Text = ""
                    dim.AutoButtonColor = false
                    dim.ZIndex = 120

                    local panel = Instance.new("Frame", dim)
                    panel.AnchorPoint = Vector2.new(0.5,0.5)
                    panel.Position = UDim2.new(0.5,0,0.5,0)
                    panel.Size = UDim2.new(0,panelWidth,0,panelHeight)
                    panel.BackgroundColor3 = currentColorScheme.stackBg
                    panel.BorderSizePixel = 0
                    panel.Active = true
                    panel.ZIndex = 121
                    mkCorner(panel, 22)
                    local panelGradient = Instance.new("UIGradient", panel)
                    panelGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, currentColorScheme.mainDark),
                        ColorSequenceKeypoint.new(0.38, currentColorScheme.rowBg),
                        ColorSequenceKeypoint.new(1, currentColorScheme.topBg),
                    })
                    panelGradient.Rotation = 22

                    local header = Instance.new("Frame", panel)
                    header.Size = UDim2.new(1,0,0,58)
                    header.BackgroundColor3 = currentColorScheme.mainDark
                    header.BackgroundTransparency = 0.2
                    header.BorderSizePixel = 0
                    header.ZIndex = 122
                    mkCorner(header, 22)
                    local headerFade = Instance.new("UIGradient", header)
                    headerFade.Color = ColorSequence.new(currentColorScheme.main, currentColorScheme.mainDark)

                    local logo = Instance.new("TextLabel", header)
                    logo.Size = UDim2.new(0,54,1,0)
                    logo.Position = UDim2.new(0,12,0,0)
                    logo.BackgroundTransparency = 1
                    logo.Text = "7UP"
                    logo.TextColor3 = Color3.fromRGB(255,255,255)
                    logo.TextStrokeColor3 = Color3.fromRGB(0,40,18)
                    logo.TextStrokeTransparency = 0.15
                    logo.Font = Enum.Font.GothamBlack
                    logo.TextSize = 20
                    logo.ZIndex = 123

                    local title = Instance.new("TextLabel", header)
                    title.Size = UDim2.new(1,-118,0,23)
                    title.Position = UDim2.new(0,68,0,8)
                    title.BackgroundTransparency = 1
                    title.Text = "CUSTOM SKINS"
                    title.TextColor3 = Color3.fromRGB(255,255,255)
                    title.Font = Enum.Font.GothamBlack
                    title.TextSize = 15
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    title.ZIndex = 123

                    local subtitle = Instance.new("TextLabel", header)
                    subtitle.Size = UDim2.new(1,-118,0,16)
                    subtitle.Position = UDim2.new(0,68,0,31)
                    subtitle.BackgroundTransparency = 1
                    subtitle.Text = "YOUR CURRENT AVATAR"
                    subtitle.TextColor3 = Color3.fromRGB(174,235,193)
                    subtitle.Font = Enum.Font.GothamBold
                    subtitle.TextSize = 9
                    subtitle.TextXAlignment = Enum.TextXAlignment.Left
                    subtitle.ZIndex = 123

                    local closeBtn = Instance.new("TextButton", header)
                    closeBtn.Size = UDim2.new(0,34,0,34)
                    closeBtn.Position = UDim2.new(1,-44,0,11)
                    closeBtn.BackgroundColor3 = Color3.fromRGB(215,38,45)
                    closeBtn.BorderSizePixel = 0
                    closeBtn.Text = "×"
                    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    closeBtn.Font = Enum.Font.GothamBlack
                    closeBtn.TextSize = 22
                    closeBtn.ZIndex = 125
                    mkCorner(closeBtn, 17)

                    local variantHolder = Instance.new("Frame", panel)
                    variantHolder.Name = "SkinVariantSelector"
                    variantHolder.Size = UDim2.new(1,-28,0,36)
                    variantHolder.Position = UDim2.new(0,14,0,68)
                    variantHolder.BackgroundColor3 = currentColorScheme.modeBtnBg
                    variantHolder.BackgroundTransparency = 0.12
                    variantHolder.BorderSizePixel = 0
                    variantHolder.ZIndex = 123
                    mkCorner(variantHolder, 12)

                    local function makeSkinVariantButton(text, position)
                        local button = Instance.new("TextButton", variantHolder)
                        button.Size = UDim2.new(0.5,-4,1,-6)
                        button.Position = position
                        button.BackgroundColor3 = currentColorScheme.mainDark
                        button.BackgroundTransparency = 0.08
                        button.BorderSizePixel = 0
                        button.Text = text
                        button.TextColor3 = currentColorScheme.buttonText
                        button.Font = Enum.Font.GothamBlack
                        button.TextSize = 10
                        button.AutoButtonColor = false
                        button.ZIndex = 124
                        mkCorner(button, 10)
                        return button
                    end
                    local skinOneButton = makeSkinVariantButton("7UP SKIN", UDim2.new(0,3,0,3))
                    local skinTwoButton = makeSkinVariantButton("BART SKIN", UDim2.new(0.5,1,0,3))

                    local previewCard = Instance.new("Frame", panel)
                    previewCard.Size = UDim2.new(1,-28,1,-182)
                    previewCard.Position = UDim2.new(0,14,0,112)
                    previewCard.BackgroundColor3 = currentColorScheme.rowBg
                    previewCard.BorderSizePixel = 0
                    previewCard.ClipsDescendants = true
                    previewCard.ZIndex = 122
                    mkCorner(previewCard, 17)
                    local previewGradient = Instance.new("UIGradient", previewCard)
                    previewGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, currentColorScheme.topBg),
                        ColorSequenceKeypoint.new(0.52, currentColorScheme.mainDark),
                        ColorSequenceKeypoint.new(1, currentColorScheme.stackBg),
                    })
                    previewGradient.Rotation = 15

                    local viewport = Instance.new("ViewportFrame", previewCard)
                    viewport.Size = UDim2.new(1,0,1,0)
                    viewport.BackgroundTransparency = 1
                    viewport.Ambient = Color3.fromRGB(150,190,160)
                    viewport.LightColor = Color3.fromRGB(240,255,244)
                    viewport.LightDirection = Vector3.new(-1,-0.5,-1)
                    viewport.ZIndex = 123

                    local previewLoading = Instance.new("TextLabel", previewCard)
                    previewLoading.Size = UDim2.new(1,-24,0,28)
                    previewLoading.Position = UDim2.new(0,12,0.5,-14)
                    previewLoading.BackgroundTransparency = 1
                    previewLoading.Text = "LOADING AVATAR..."
                    previewLoading.TextColor3 = Color3.fromRGB(220,246,227)
                    previewLoading.Font = Enum.Font.GothamBlack
                    previewLoading.TextSize = 11
                    previewLoading.ZIndex = 125

                    local statusBadge = Instance.new("TextLabel", previewCard)
                    statusBadge.Size = UDim2.new(0,90,0,26)
                    statusBadge.Position = UDim2.new(1,-100,0,10)
                    statusBadge.BorderSizePixel = 0
                    statusBadge.TextColor3 = Color3.fromRGB(255,255,255)
                    statusBadge.Font = Enum.Font.GothamBlack
                    statusBadge.TextSize = 10
                    statusBadge.ZIndex = 126
                    mkCorner(statusBadge, 13)

                    local applyBtn = Instance.new("TextButton", panel)
                    applyBtn.Size = UDim2.new(0.5,-20,0,42)
                    applyBtn.Position = UDim2.new(0,14,1,-56)
                    applyBtn.BackgroundColor3 = Color3.fromRGB(0,174,73)
                    applyBtn.BorderSizePixel = 0
                    applyBtn.Text = "APPLY SKIN"
                    applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    applyBtn.Font = Enum.Font.GothamBlack
                    applyBtn.TextSize = 11
                    applyBtn.ZIndex = 123
                    mkCorner(applyBtn, 14)

                    local removeBtn = Instance.new("TextButton", panel)
                    removeBtn.Size = UDim2.new(0.5,-20,0,42)
                    removeBtn.Position = UDim2.new(0.5,6,1,-56)
                    removeBtn.BackgroundColor3 = Color3.fromRGB(65,76,69)
                    removeBtn.BorderSizePixel = 0
                    removeBtn.Text = "REMOVE"
                    removeBtn.TextColor3 = Color3.fromRGB(230,238,232)
                    removeBtn.Font = Enum.Font.GothamBlack
                    removeBtn.TextSize = 11
                    removeBtn.ZIndex = 123
                    mkCorner(removeBtn, 14)

                    activeSkinPopup = {root = dim}
                    local function refreshVariantButtons()
                        local selected = tonumber(State.customSkinVariant) == 2 and 2 or 1
                        local activeColor = currentColorScheme.main
                        local idleColor = currentColorScheme.modeBtnBg
                        skinOneButton.BackgroundColor3 = selected == 1 and activeColor or idleColor
                        skinTwoButton.BackgroundColor3 = selected == 2 and activeColor or idleColor
                        skinOneButton.TextTransparency = selected == 1 and 0 or 0.25
                        skinTwoButton.TextTransparency = selected == 2 and 0 or 0.25
                        subtitle.Text = CUSTOM_SKIN_VARIANTS[selected].name .. " • LIVE AVATAR PREVIEW"
                    end
                    local function selectSkinVariant(index)
                        if State.customSkinEnabled and LP.Character then
                            -- Clear the previous variant's body tint before the
                            -- new description is applied (green must never leak
                            -- into Bart Skin's yellow body).
                            applyCustomSkinGreen(LP.Character, false)
                        end
                        State.customSkinVariant = index == 2 and 2 or 1
                        syncCustomSkinVariant(State.customSkinVariant)
                        if State.customSkinEnabled then applyCharterToChar(LP.Character) end
                        refreshVariantButtons()
                        if activeSkinPopup and activeSkinPopup.sync then activeSkinPopup.sync() end
                        if activeSkinPopup and activeSkinPopup.refreshPreview then activeSkinPopup.refreshPreview() end
                        requestSave()
                    end
                    skinOneButton.MouseButton1Click:Connect(function() selectSkinVariant(1) end)
                    skinTwoButton.MouseButton1Click:Connect(function() selectSkinVariant(2) end)
                    refreshVariantButtons()
                    local popupDragging, popupDragInput, popupDragStart, popupStartPos = false, nil, nil, nil
                    header.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            popupDragging = true
                            popupDragStart = input.Position
                            popupStartPos = panel.Position
                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then popupDragging = false end
                            end)
                        end
                    end)
                    header.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement
                            or input.UserInputType == Enum.UserInputType.Touch then
                            popupDragInput = input
                        end
                    end)
                    activeSkinPopup.dragConn = UIS.InputChanged:Connect(function(input)
                        if input == popupDragInput and popupDragging and panel.Parent then
                            local delta = input.Position - popupDragStart
                            panel.Position = UDim2.new(
                                popupStartPos.X.Scale, popupStartPos.X.Offset + delta.X,
                                popupStartPos.Y.Scale, popupStartPos.Y.Offset + delta.Y
                            )
                        end
                    end)
                    local previewRefreshToken = 0
                    activeSkinPopup.refreshPreview = function()
                        previewRefreshToken = previewRefreshToken + 1
                        local token = previewRefreshToken
                        previewLoading.Visible = true
                        previewLoading.Text = "LOADING AVATAR..."
                        task.spawn(function()
                            task.wait()
                            if token ~= previewRefreshToken or not viewport.Parent then return end
                            local ok, rendered = pcall(renderCustomSkinPreview, viewport, State.customSkinVariant)
                            if token == previewRefreshToken and previewLoading.Parent then
                                previewLoading.Visible = not (ok and rendered == true)
                                if previewLoading.Visible then previewLoading.Text = "PREVIEW UNAVAILABLE" end
                            end
                        end)
                    end
                    activeSkinPopup.sync = function()
                        local on = State.customSkinEnabled == true
                        local selected = tonumber(State.customSkinVariant) == 2 and 2 or 1
                        statusBadge.Text = on and "EQUIPPED" or CUSTOM_SKIN_VARIANTS[selected].name
                        statusBadge.BackgroundColor3 = on and currentColorScheme.main or currentColorScheme.mainDark
                        applyBtn.BackgroundColor3 = on and currentColorScheme.mainDark or currentColorScheme.main
                        removeBtn.BackgroundColor3 = on and Color3.fromRGB(205,42,49) or currentColorScheme.modeBtnBg
                        refreshVariantButtons()
                    end
                    _G._K7RefreshCustomSkinTheme = activeSkinPopup.sync
                    activeSkinPopup.sync()

                    closeBtn.MouseButton1Click:Connect(closeSkinPopup)
                    dim.MouseButton1Click:Connect(closeSkinPopup)
                    applyBtn.MouseButton1Click:Connect(function() setCustomSkinEnabled(true) end)
                    removeBtn.MouseButton1Click:Connect(function() setCustomSkinEnabled(false) end)
                    activeSkinPopup.refreshPreview()
                end

                skinOpen.MouseButton1Click:Connect(openSkinPopup)
            end

            State.outfit1Applied = false
            State.outfit2Applied = false
            State.outfit3Applied = false
            if false then -- legacy outfit UI removed

            -- ── NEW: Outfit Changer ──────────────────────────────
            do
                local row = Instance.new("Frame", currentPage)
                row.Size = UDim2.new(1,-16,0,42)
                row.BackgroundColor3 = currentColorScheme.rowBg
                row.BackgroundTransparency = 0.85
                row.BorderSizePixel = 0
                row.LayoutOrder = LO()
                mkCorner(row, 12)

                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(0.5,0,1,0)
                lbl.Position = UDim2.new(0,14,0,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "Legacy Style 1"
                lbl.TextColor3 = currentColorScheme.rowLabel
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local applyBtn = Instance.new("TextButton", row)
                applyBtn.Size = UDim2.new(0, 70, 0, 28)
                applyBtn.Position = UDim2.new(1, -84, 0.5, -14)
                applyBtn.BackgroundColor3 = State.outfit1Applied and currentColorScheme.main or currentColorScheme.inputBg
                applyBtn.BackgroundTransparency = 0.15
                applyBtn.BorderSizePixel = 0
                applyBtn.Text = State.outfit1Applied and "ON" or "OFF"
                applyBtn.TextColor3 = State.outfit1Applied and currentColorScheme.buttonText or currentColorScheme.text
                applyBtn.Font = Enum.Font.GothamBold
                applyBtn.TextSize = 12
                applyBtn.ZIndex = 5
                mkCorner(applyBtn, 6)

                local function updateOutfitBtn()
                    applyBtn.Text = State.outfit1Applied and "ON" or "OFF"
                    applyBtn.BackgroundColor3 = State.outfit1Applied and currentColorScheme.main or currentColorScheme.inputBg
                    applyBtn.TextColor3 = State.outfit1Applied and currentColorScheme.buttonText or currentColorScheme.text
                end
                toggleSetters["outfit1"] = function() updateOutfitBtn() end

                applyBtn.MouseButton1Click:Connect(function()
                    State.outfit1Applied = not State.outfit1Applied
                    if State.outfit1Applied then
                        State.outfit3Applied = false
                    end
                    applyCharterToChar(LP.Character)
                    updateOutfitBtn()
                    if toggleSetters["outfit3"] then pcall(toggleSetters["outfit3"]) end
                    requestSave()
                end)

                local info = Instance.new("Frame", currentPage)
                info.Size = UDim2.new(1,-16,0,24)
                info.BackgroundColor3 = currentColorScheme.rowBg
                info.BackgroundTransparency = 0.92
                info.BorderSizePixel = 0
                info.LayoutOrder = LO()
                mkCorner(info, 8)
                local infoLbl = Instance.new("TextLabel", info)
                infoLbl.Size = UDim2.new(1,-16,1,0)
                infoLbl.Position = UDim2.new(0,8,0,0)
                infoLbl.BackgroundTransparency = 1
                infoLbl.Text = "Head: 137685008029440  •  Shirt: 6281968058  •  Pants: 1073888653"
                infoLbl.TextColor3 = currentColorScheme.subText
                infoLbl.Font = Enum.Font.Gotham
                infoLbl.TextSize = 9
                infoLbl.TextXAlignment = Enum.TextXAlignment.Left
                infoLbl.TextWrapped = true
            end

            -- Try Hard 1 Button
            do
                local row2 = Instance.new("Frame", currentPage)
                row2.Size = UDim2.new(1,-16,0,42)
                row2.BackgroundColor3 = currentColorScheme.rowBg
                row2.BackgroundTransparency = 0.85
                row2.BorderSizePixel = 0
                row2.LayoutOrder = LO()
                mkCorner(row2, 12)

                local lbl2 = Instance.new("TextLabel", row2)
                lbl2.Size = UDim2.new(0.5,0,1,0)
                lbl2.Position = UDim2.new(0,14,0,0)
                lbl2.BackgroundTransparency = 1
                lbl2.Text = "Try Hard 1"
                lbl2.TextColor3 = currentColorScheme.rowLabel
                lbl2.Font = Enum.Font.GothamBold
                lbl2.TextSize = 13
                lbl2.TextXAlignment = Enum.TextXAlignment.Left

                local applyBtn2 = Instance.new("TextButton", row2)
                applyBtn2.Size = UDim2.new(0, 70, 0, 28)
                applyBtn2.Position = UDim2.new(1, -84, 0.5, -14)
                applyBtn2.BackgroundColor3 = State.outfit2Applied and currentColorScheme.main or currentColorScheme.inputBg
                applyBtn2.BackgroundTransparency = 0.15
                applyBtn2.BorderSizePixel = 0
                applyBtn2.Text = State.outfit2Applied and "ON" or "OFF"
                applyBtn2.TextColor3 = State.outfit2Applied and currentColorScheme.buttonText or currentColorScheme.text
                applyBtn2.Font = Enum.Font.GothamBold
                applyBtn2.TextSize = 12
                applyBtn2.ZIndex = 5
                mkCorner(applyBtn2, 6)

                local function updateOutfitBtn2()
                    applyBtn2.Text = State.outfit2Applied and "ON" or "OFF"
                    applyBtn2.BackgroundColor3 = State.outfit2Applied and currentColorScheme.main or currentColorScheme.inputBg
                    applyBtn2.TextColor3 = State.outfit2Applied and currentColorScheme.buttonText or currentColorScheme.text
                end
                toggleSetters["outfit2"] = function() updateOutfitBtn2() end

                applyBtn2.MouseButton1Click:Connect(function()
                    State.outfit2Applied = not State.outfit2Applied
                    if State.outfit2Applied then
                        State.outfit1Applied = false
                        State.outfit3Applied = false
                    end
                    applyCharterToChar(LP.Character)
                    updateOutfitBtn2()
                    if toggleSetters["outfit1"] then pcall(toggleSetters["outfit1"]) end
                    if toggleSetters["outfit3"] then pcall(toggleSetters["outfit3"]) end
                    requestSave()
                end)

                local info2 = Instance.new("Frame", currentPage)
                info2.Size = UDim2.new(1,-16,0,24)
                info2.BackgroundColor3 = currentColorScheme.rowBg
                info2.BackgroundTransparency = 0.92
                info2.BorderSizePixel = 0
                info2.LayoutOrder = LO()
                mkCorner(info2, 8)
                local infoLbl2 = Instance.new("TextLabel", info2)
                infoLbl2.Size = UDim2.new(1,-16,1,0)
                infoLbl2.Position = UDim2.new(0,8,0,0)
                infoLbl2.BackgroundTransparency = 1
                infoLbl2.Text = "Head: 11711107876  •  Shirt: 14101026303  •  Pants: 4620736485"
                infoLbl2.TextColor3 = currentColorScheme.subText
                infoLbl2.Font = Enum.Font.Gotham
                infoLbl2.TextSize = 9
                infoLbl2.TextXAlignment = Enum.TextXAlignment.Left
                infoLbl2.TextWrapped = true
            end

            -- Venom Fit Button
            do
                local row3 = Instance.new("Frame", currentPage)
                row3.Size = UDim2.new(1,-16,0,42)
                row3.BackgroundColor3 = currentColorScheme.rowBg
                row3.BackgroundTransparency = 0.85
                row3.BorderSizePixel = 0
                row3.LayoutOrder = LO()
                mkCorner(row3, 12)

                local lbl3 = Instance.new("TextLabel", row3)
                lbl3.Size = UDim2.new(0.5,0,1,0)
                lbl3.Position = UDim2.new(0,14,0,0)
                lbl3.BackgroundTransparency = 1
                lbl3.Text = "Venom Fit"
                lbl3.TextColor3 = currentColorScheme.rowLabel
                lbl3.Font = Enum.Font.GothamBold
                lbl3.TextSize = 13
                lbl3.TextXAlignment = Enum.TextXAlignment.Left

                local applyBtn3 = Instance.new("TextButton", row3)
                applyBtn3.Size = UDim2.new(0, 70, 0, 28)
                applyBtn3.Position = UDim2.new(1, -84, 0.5, -14)
                applyBtn3.BackgroundColor3 = State.outfit3Applied and currentColorScheme.main or currentColorScheme.inputBg
                applyBtn3.BackgroundTransparency = 0.15
                applyBtn3.BorderSizePixel = 0
                applyBtn3.Text = State.outfit3Applied and "ON" or "OFF"
                applyBtn3.TextColor3 = State.outfit3Applied and currentColorScheme.buttonText or currentColorScheme.text
                applyBtn3.Font = Enum.Font.GothamBold
                applyBtn3.TextSize = 12
                applyBtn3.ZIndex = 5
                mkCorner(applyBtn3, 6)

                local function updateOutfitBtn3()
                    applyBtn3.Text = State.outfit3Applied and "ON" or "OFF"
                    applyBtn3.BackgroundColor3 = State.outfit3Applied and currentColorScheme.main or currentColorScheme.inputBg
                    applyBtn3.TextColor3 = State.outfit3Applied and currentColorScheme.buttonText or currentColorScheme.text
                end
                toggleSetters["outfit3"] = function() updateOutfitBtn3() end

                applyBtn3.MouseButton1Click:Connect(function()
                    State.outfit1Applied = false
                    State.outfit3Applied = not State.outfit3Applied
                    applyCharterToChar(LP.Character)
                    updateOutfitBtn3()
                    if toggleSetters["outfit1"] then pcall(toggleSetters["outfit1"]) end
                    requestSave()
                end)
            end

            -- ── Animation Pack selector ──────────────────────────────
            makeGap(4)
            end -- legacy outfit UI removed
            makeGap(4)
            makeSectionHeader("Animation Pack")
            makeGap(2)

            do
                local packRow = Instance.new("Frame", currentPage)
                packRow.Size = UDim2.new(1,-16,0,58)
                packRow.BackgroundColor3 = currentColorScheme.rowBg; packRow.BackgroundTransparency=0.3
                packRow.BorderSizePixel=0; packRow.LayoutOrder=LO()
                mkCorner(packRow, 17)
                local packRowStroke=Instance.new("UIStroke",packRow); packRowStroke.Color=currentColorScheme.mainLight; packRowStroke.Transparency=0.46; packRowStroke.Thickness=1.4
                local packRowGradient=Instance.new("UIGradient",packRow)
                packRowGradient.Color=adaptiveCanColorSequence(currentColorScheme,false)

                local packLbl = Instance.new("TextLabel",packRow)
                packLbl.Size=UDim2.new(0,48,1,0); packLbl.Position=UDim2.new(0,8,0,0)
                packLbl.BackgroundTransparency=1; packLbl.Text="PACK"
                packLbl.TextColor3=currentColorScheme.rowLabel; packLbl.Font=Enum.Font.GothamBlack; packLbl.TextSize=9
                packLbl.TextXAlignment=Enum.TextXAlignment.Left

                local packHolder = Instance.new("Frame",packRow)
                packHolder.Size=UDim2.new(0,124,0,36); packHolder.Position=UDim2.new(0,96,0.5,-18)
                packHolder.BackgroundColor3=currentColorScheme.modeBtnBg; packHolder.BackgroundTransparency=0.05
                packHolder.BorderSizePixel=0; packHolder.ClipsDescendants=true
                mkCorner(packHolder,12)
                local packHolderStroke=Instance.new("UIStroke",packHolder); packHolderStroke.Color=currentColorScheme.mainLight; packHolderStroke.Transparency=0.34; packHolderStroke.Thickness=1.3
                local packHolderGradient=Instance.new("UIGradient",packHolder); packHolderGradient.Color=ColorSequence.new(currentColorScheme.mainDark,currentColorScheme.stackBg); packHolderGradient.Rotation=15

                local packValLbl = Instance.new("TextLabel",packHolder)
                packValLbl.Size=UDim2.new(1,0,1,0); packValLbl.BackgroundTransparency=1
                packValLbl.Text=selectedAnimationPack; packValLbl.TextColor3=currentColorScheme.text
                packValLbl.Font=Enum.Font.GothamBlack; packValLbl.TextSize=9; packValLbl.TextXAlignment=Enum.TextXAlignment.Center; packValLbl.ZIndex=9
                packValLbl.TextTruncate=Enum.TextTruncate.AtEnd
                _G._K7AnimPackValLbl = packValLbl

                local function setPackIdx(next)
                    if next<1 then next=#AnimationPackList end
                    if next>#AnimationPackList then next=1 end
                    AnimationPackIndex = next
                    local pack = AnimationPackList[next]
                    selectedAnimationPack = pack
                    _G._K7SelectedAnimationPack = pack
                    pcall(function() if _K7SaveAnimPackFile then _K7SaveAnimPackFile(pack) end end)
                    packValLbl.Text = pack
                    State.tryardAnimEnabled = pack ~= "OFF"
                    pcall(function()
                        if _G._K7SetAnimationPack then _G._K7SetAnimationPack(pack)
                        else applyAnimationPack(pack) end
                    end)
                    requestSave()
                end
                _G._K7AnimPackRefreshRow = function()
                    syncAnimationPackIndex()
                    packValLbl.Text = selectedAnimationPack
                end

                local packLeft = Instance.new("TextButton",packRow)
                packLeft.Size=UDim2.new(0,30,0,36); packLeft.Position=UDim2.new(0,60,0.5,-18)
                packLeft.BackgroundColor3=currentColorScheme.main; packLeft.BackgroundTransparency=0.05
                packLeft.BorderSizePixel=0; packLeft.Text="<"; packLeft.TextColor3=currentColorScheme.buttonText
                packLeft.Font=Enum.Font.GothamBlack; packLeft.TextSize=15; packLeft.AutoButtonColor=false
                mkCorner(packLeft,15)
                local packLeftStroke=Instance.new("UIStroke",packLeft); packLeftStroke.Color=currentColorScheme.mainLight; packLeftStroke.Transparency=0.45
                packLeft.MouseButton1Click:Connect(function() setPackIdx(AnimationPackIndex-1) end)
                packLeft.MouseEnter:Connect(function() TweenService:Create(packLeft,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.mainLight,BackgroundTransparency=0}):Play() end)
                packLeft.MouseLeave:Connect(function() TweenService:Create(packLeft,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.main,BackgroundTransparency=0.05}):Play() end)

                local packRight = Instance.new("TextButton",packRow)
                packRight.Size=UDim2.new(0,30,0,36); packRight.Position=UDim2.new(1,-38,0.5,-18)
                packRight.BackgroundColor3=currentColorScheme.main; packRight.BackgroundTransparency=0.05
                packRight.BorderSizePixel=0; packRight.Text=">"; packRight.TextColor3=currentColorScheme.buttonText
                packRight.Font=Enum.Font.GothamBlack; packRight.TextSize=15; packRight.AutoButtonColor=false
                mkCorner(packRight,15)
                local packRightStroke=Instance.new("UIStroke",packRight); packRightStroke.Color=currentColorScheme.mainLight; packRightStroke.Transparency=0.45
                packRight.MouseButton1Click:Connect(function() setPackIdx(AnimationPackIndex+1) end)
                packRight.MouseEnter:Connect(function() TweenService:Create(packRight,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.mainLight,BackgroundTransparency=0}):Play() end)
                packRight.MouseLeave:Connect(function() TweenService:Create(packRight,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.main,BackgroundTransparency=0.05}):Play() end)

                local function refreshAnimPackTheme()
                    local live = currentColorScheme
                    packRow.BackgroundColor3 = live.rowBg
                    packRowStroke.Color = live.mainLight
                    packRowGradient.Color = adaptiveCanColorSequence(live,false)
                    packLbl.TextColor3 = live.rowLabel
                    packHolder.BackgroundColor3 = live.modeBtnBg
                    packHolderStroke.Color = live.mainLight
                    packHolderGradient.Color = ColorSequence.new(live.mainDark,live.stackBg)
                    packValLbl.TextColor3 = live.text
                    for _, button in ipairs({packLeft,packRight}) do
                        button.BackgroundColor3 = live.main
                        button.TextColor3 = live.buttonText
                        local buttonStroke = button:FindFirstChildWhichIsA("UIStroke")
                        if buttonStroke then buttonStroke.Color = live.mainLight end
                    end
                end
                _G._K7RefreshAnimPackTheme = refreshAnimPackTheme
                refreshAnimPackTheme()

                syncAnimationPackIndex(); packValLbl.Text=selectedAnimationPack
            end
            local tryardSetter = nil
            toggleSetters["tryardAnim"] = function(on)
                if on then if selectedAnimationPack=="OFF" then applyAnimationPack("Stylish") end
                else applyAnimationPack("OFF") end
            end

            -- ── Sky Theme ──────────────────────────────────────────
            makeGap(4)
            makeSectionHeader("Sky Theme")
            makeGap(2)

            do
                local skyRow = Instance.new("Frame", currentPage)
                skyRow.Size = UDim2.new(1,-16,0,58)
                skyRow.BackgroundColor3 = Color3.fromRGB(0,72,34)
                skyRow.BackgroundTransparency = 0.3
                skyRow.BorderSizePixel = 0
                skyRow.LayoutOrder = LO()
                mkCorner(skyRow, 17)
                local skyRowStroke=Instance.new("UIStroke",skyRow); skyRowStroke.Color=Color3.fromRGB(175,225,190); skyRowStroke.Transparency=0.46; skyRowStroke.Thickness=1.4
                local skyRowGradient=Instance.new("UIGradient",skyRow)
                skyRowGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(205,230,210)),ColorSequenceKeypoint.new(0.08,Color3.fromRGB(0,155,68)),ColorSequenceKeypoint.new(0.72,Color3.fromRGB(0,55,27)),ColorSequenceKeypoint.new(1,Color3.fromRGB(145,175,153))})

                local skyLbl = Instance.new("TextLabel", skyRow)
                skyLbl.Size = UDim2.new(0,48,1,0)
                skyLbl.Position = UDim2.new(0,8,0,0)
                skyLbl.BackgroundTransparency = 1
                skyLbl.Text = "SKY"
                skyLbl.TextColor3 = Color3.fromRGB(255,255,255)
                skyLbl.Font = Enum.Font.GothamBlack
                skyLbl.TextSize = 9
                skyLbl.TextXAlignment = Enum.TextXAlignment.Left

                local _skyIdx = 1
                for i, name in ipairs(SKY_PRESETS_LIST) do
                    if name == State.skyTheme then _skyIdx = i; break end
                end

                local skyHolder = Instance.new("Frame", skyRow)
                skyHolder.Size = UDim2.new(0,124,0,36)
                skyHolder.Position = UDim2.new(0,96,0.5,-18)
                skyHolder.BackgroundColor3 = Color3.fromRGB(0,18,9)
                skyHolder.BackgroundTransparency = 0.05
                skyHolder.BorderSizePixel = 0
                skyHolder.ClipsDescendants = true
                mkCorner(skyHolder, 12)
                local skyHolderStroke=Instance.new("UIStroke",skyHolder); skyHolderStroke.Color=currentColorScheme.mainLight; skyHolderStroke.Transparency=0.34; skyHolderStroke.Thickness=1.3
                local skyHolderGradient=Instance.new("UIGradient",skyHolder); skyHolderGradient.Color=ColorSequence.new(Color3.fromRGB(0,95,45),Color3.fromRGB(0,25,12)); skyHolderGradient.Rotation=15

                local skyValLbl = Instance.new("TextLabel", skyHolder)
                skyValLbl.Size = UDim2.new(1,0,1,0)
                skyValLbl.BackgroundTransparency = 1
                skyValLbl.Text = SKY_PRESETS_LIST[_skyIdx]
                skyValLbl.TextColor3 = Color3.fromRGB(240,240,240)
                skyValLbl.Font = Enum.Font.GothamBlack
                skyValLbl.TextSize = 9
                skyValLbl.TextXAlignment = Enum.TextXAlignment.Center
                skyValLbl.ZIndex = 9
                skyValLbl.TextTruncate = Enum.TextTruncate.AtEnd

                local function setSkyIdx(next)
                    if next < 1 then next = #SKY_PRESETS_LIST end
                    if next > #SKY_PRESETS_LIST then next = 1 end
                    _skyIdx = next
                    State.skyTheme = SKY_PRESETS_LIST[_skyIdx]
                    skyValLbl.Text = State.skyTheme
                    pcall(applyCustomSky, State.skyTheme)
                    requestSave()
                end

                local skyLeft = Instance.new("TextButton", skyRow)
                skyLeft.Size = UDim2.new(0,30,0,36)
                skyLeft.Position = UDim2.new(0,60,0.5,-18)
                skyLeft.BackgroundColor3 = Color3.fromRGB(184,28,38)
                skyLeft.BackgroundTransparency = 0.05
                skyLeft.BorderSizePixel = 0
                skyLeft.Text = "<"
                skyLeft.TextColor3 = Color3.fromRGB(255,255,255)
                skyLeft.Font = Enum.Font.GothamBlack
                skyLeft.TextSize = 15
                skyLeft.AutoButtonColor = false
                mkCorner(skyLeft, 15)
                local skyLeftStroke=Instance.new("UIStroke",skyLeft); skyLeftStroke.Color=Color3.fromRGB(255,210,210); skyLeftStroke.Transparency=0.45
                skyLeft.MouseButton1Click:Connect(function() setSkyIdx(_skyIdx - 1) end)
                skyLeft.MouseEnter:Connect(function() TweenService:Create(skyLeft,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(235,48,55),BackgroundTransparency=0}):Play() end)
                skyLeft.MouseLeave:Connect(function() TweenService:Create(skyLeft,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(184,28,38),BackgroundTransparency=0.05}):Play() end)

                local skyRight = Instance.new("TextButton", skyRow)
                skyRight.Size = UDim2.new(0,30,0,36)
                skyRight.Position = UDim2.new(1,-38,0.5,-18)
                skyRight.BackgroundColor3 = Color3.fromRGB(184,28,38)
                skyRight.BackgroundTransparency = 0.05
                skyRight.BorderSizePixel = 0
                skyRight.Text = ">"
                skyRight.TextColor3 = Color3.fromRGB(255,255,255)
                skyRight.Font = Enum.Font.GothamBlack
                skyRight.TextSize = 15
                skyRight.AutoButtonColor = false
                mkCorner(skyRight, 15)
                local skyRightStroke=Instance.new("UIStroke",skyRight); skyRightStroke.Color=Color3.fromRGB(255,210,210); skyRightStroke.Transparency=0.45
                skyRight.MouseButton1Click:Connect(function() setSkyIdx(_skyIdx + 1) end)
                skyRight.MouseEnter:Connect(function() TweenService:Create(skyRight,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(235,48,55),BackgroundTransparency=0}):Play() end)
                skyRight.MouseLeave:Connect(function() TweenService:Create(skyRight,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(184,28,38),BackgroundTransparency=0.05}):Play() end)
            end

            -- ── Intro Music ──────────────────────────────────────
            makeGap(4)
            makeSectionHeader("Intro Music")
            makeGap(2)

            do
                local introRow = Instance.new("Frame", currentPage)
                introRow.Size = UDim2.new(1,-16,0,58)
                introRow.BackgroundColor3 = Color3.fromRGB(0,72,34)
                introRow.BackgroundTransparency = 0.3
                introRow.BorderSizePixel = 0
                introRow.LayoutOrder = LO()
                mkCorner(introRow, 17)
                local introRowStroke=Instance.new("UIStroke",introRow); introRowStroke.Color=Color3.fromRGB(175,225,190); introRowStroke.Transparency=0.46; introRowStroke.Thickness=1.4
                local introRowGradient=Instance.new("UIGradient",introRow)
                introRowGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(205,230,210)),ColorSequenceKeypoint.new(0.08,Color3.fromRGB(0,155,68)),ColorSequenceKeypoint.new(0.72,Color3.fromRGB(0,55,27)),ColorSequenceKeypoint.new(1,Color3.fromRGB(145,175,153))})

                local introLbl = Instance.new("TextLabel", introRow)
                introLbl.Size = UDim2.new(0,48,1,0)
                introLbl.Position = UDim2.new(0,8,0,0)
                introLbl.BackgroundTransparency = 1
                introLbl.Text = "INTRO"
                introLbl.TextColor3 = Color3.fromRGB(255,255,255)
                introLbl.Font = Enum.Font.GothamBlack
                introLbl.TextSize = 9
                introLbl.TextXAlignment = Enum.TextXAlignment.Left

                local introHolder = Instance.new("Frame", introRow)
                introHolder.Size = UDim2.new(0,124,0,36)
                introHolder.Position = UDim2.new(0,96,0.5,-18)
                introHolder.BackgroundColor3 = Color3.fromRGB(0,18,9)
                introHolder.BackgroundTransparency = 0.05
                introHolder.BorderSizePixel = 0
                introHolder.ClipsDescendants = true
                mkCorner(introHolder, 12)
                local introHolderStroke=Instance.new("UIStroke",introHolder); introHolderStroke.Color=currentColorScheme.mainLight; introHolderStroke.Transparency=0.34; introHolderStroke.Thickness=1.3
                local introHolderGradient=Instance.new("UIGradient",introHolder); introHolderGradient.Color=ColorSequence.new(Color3.fromRGB(0,95,45),Color3.fromRGB(0,25,12)); introHolderGradient.Rotation=15

                local introValLbl = Instance.new("TextLabel", introHolder)
                introValLbl.Size = UDim2.new(1,0,1,0)
                introValLbl.BackgroundTransparency = 1
                introValLbl.Text = getIntroSongName()
                introValLbl.TextColor3 = Color3.fromRGB(240,240,240)
                introValLbl.Font = Enum.Font.GothamBlack
                introValLbl.TextSize = 9
                introValLbl.TextXAlignment = Enum.TextXAlignment.Center
                introValLbl.ZIndex = 9
                introValLbl.TextTruncate = Enum.TextTruncate.AtEnd
                _G._K7IntroValLbl = introValLbl

                local function setIntroIdx(next)
                    if next < 1 then next = #INTRO_MUSIC_OPTIONS end
                    if next > #INTRO_MUSIC_OPTIONS then next = 1 end
                    selectedIntroMusic = next
                    introValLbl.Text = getIntroSongName()
                    saveIntroSongIdx()
                    preloadIntroSongs()
                    previewIntroSong()
                    requestSave()
                end

                local introLeft = Instance.new("TextButton", introRow)
                introLeft.Size = UDim2.new(0,30,0,36)
                introLeft.Position = UDim2.new(0,60,0.5,-18)
                introLeft.BackgroundColor3 = Color3.fromRGB(184,28,38)
                introLeft.BackgroundTransparency = 0.05
                introLeft.BorderSizePixel = 0
                introLeft.Text = "<"
                introLeft.TextColor3 = Color3.fromRGB(255,255,255)
                introLeft.Font = Enum.Font.GothamBlack
                introLeft.TextSize = 15
                introLeft.AutoButtonColor = false
                mkCorner(introLeft, 15)
                local introLeftStroke=Instance.new("UIStroke",introLeft); introLeftStroke.Color=Color3.fromRGB(255,210,210); introLeftStroke.Transparency=0.45
                introLeft.MouseButton1Click:Connect(function() setIntroIdx(selectedIntroMusic - 1) end)
                introLeft.MouseEnter:Connect(function() TweenService:Create(introLeft,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(235,48,55),BackgroundTransparency=0}):Play() end)
                introLeft.MouseLeave:Connect(function() TweenService:Create(introLeft,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(184,28,38),BackgroundTransparency=0.05}):Play() end)

                local introRight = Instance.new("TextButton", introRow)
                introRight.Size = UDim2.new(0,30,0,36)
                introRight.Position = UDim2.new(1,-38,0.5,-18)
                introRight.BackgroundColor3 = Color3.fromRGB(184,28,38)
                introRight.BackgroundTransparency = 0.05
                introRight.BorderSizePixel = 0
                introRight.Text = ">"
                introRight.TextColor3 = Color3.fromRGB(255,255,255)
                introRight.Font = Enum.Font.GothamBlack
                introRight.TextSize = 15
                introRight.AutoButtonColor = false
                mkCorner(introRight, 15)
                local introRightStroke=Instance.new("UIStroke",introRight); introRightStroke.Color=Color3.fromRGB(255,210,210); introRightStroke.Transparency=0.45
                introRight.MouseButton1Click:Connect(function() setIntroIdx(selectedIntroMusic + 1) end)
                introRight.MouseEnter:Connect(function() TweenService:Create(introRight,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(235,48,55),BackgroundTransparency=0}):Play() end)
                introRight.MouseLeave:Connect(function() TweenService:Create(introRight,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(184,28,38),BackgroundTransparency=0.05}):Play() end)
            end

            -- ── ESP ────────────────────────────────────────────────
            makeGap(4)
            makeSectionHeader("ESP")
            makeGap(2)

            local espSetter = makeToggleRow("Player ESP", State.espEnabled, function(on)
                State.espEnabled = on
                BoxedESPOptions.box = on
                if on then startPlayerESP(); refreshBoxedESP()
                else stopPlayerESP(); refreshBoxedESP() end
                requestSave()
            end)
            toggleSetters["esp"] = espSetter

            local tracerSetter = makeToggleRow("Tracer ESP", State.espTracerWanted == true, function(on)
                State.espTracerWanted = on
                State.espTracer = on
                if on then
                    startTracerESP()
                else
                    stopTracerESP(true)
                    State.espTracer = false
                end
                requestSave()
            end)
            toggleSetters["espTracer"] = tracerSetter

            makeGap(8)
            local fw = Instance.new("Frame", currentPage)
            fw.Size = UDim2.new(1,0,0,22)
            fw.BackgroundTransparency = 1
            fw.BorderSizePixel = 0
            fw.LayoutOrder = LO()
            local fl = Instance.new("TextLabel", fw)
            fl.Size = UDim2.new(1,0,1,0)
            fl.BackgroundTransparency = 1
            fl.Text = "Visual Settings"
            fl.TextColor3 = currentColorScheme.subText
            fl.Font = Enum.Font.Gotham
            fl.TextSize = 10
            fl.TextXAlignment = Enum.TextXAlignment.Center
        end)
        page.LayoutOrder = 3
    end

-- STEAL TAB (updated with Soft Steal)
    do
        local page = buildPage("Steal", function()
            makeGap(2)
            makeSectionHeader("Auto Grab")
            makeGap(2)

            local autoStealToggle = makeToggleRow("Auto Steal", Steal.AutoStealEnabled, function(on)
                Steal.AutoStealEnabled = on
                if autoGrabModule then autoGrabModule.setEnabled(on) end
                requestSave()
            end)
            toggleSetters["autoSteal"] = autoStealToggle

            makeGap(4)
            makeSectionHeader("Steal Mode")
            makeGap(2)

            do
                local modeHolder = Instance.new("Frame", currentPage)
                modeHolder.Size  = UDim2.new(1,-16,0,52)
                modeHolder.BackgroundColor3 = currentColorScheme.rowBg
                modeHolder.BackgroundTransparency = 0.85
                modeHolder.BorderSizePixel = 0
                modeHolder.LayoutOrder = LO()
                mkCorner(modeHolder, 26)

                local slide = Instance.new("Frame", modeHolder)
                slide.Name  = "Slide"
                slide.Size  = UDim2.new(0.5,-4,1,-8)
                slide.Position = UDim2.new(0,4,0,4)
                slide.BackgroundColor3 = currentColorScheme.main
                slide.BackgroundTransparency = 0.15
                slide.BorderSizePixel = 0
                mkCorner(slide, 22)

                local normalTxt = Instance.new("TextLabel", modeHolder)
                normalTxt.Size = UDim2.new(0.5,0,1,0)
                normalTxt.Position = UDim2.new(0,0,0,0)
                normalTxt.BackgroundTransparency = 1
                normalTxt.Text = "NORMAL"
                normalTxt.TextColor3 = Color3.fromRGB(255,255,255)
                normalTxt.Font = Enum.Font.GothamBlack
                normalTxt.TextSize = 14
                normalTxt.TextXAlignment = Enum.TextXAlignment.Center
                normalTxt.ZIndex = 6

                local semiTxt = Instance.new("TextLabel", modeHolder)
                semiTxt.Size = UDim2.new(0.5,0,1,0)
                semiTxt.Position = UDim2.new(0.5,0,0,0)
                semiTxt.BackgroundTransparency = 1
                semiTxt.Text = "SEMI"
                semiTxt.TextColor3 = Color3.fromRGB(255,255,255)
                semiTxt.Font = Enum.Font.GothamBlack
                semiTxt.TextSize = 14
                semiTxt.TextXAlignment = Enum.TextXAlignment.Center
                semiTxt.ZIndex = 6

                local normalClick = Instance.new("TextButton", modeHolder)
                normalClick.Size = UDim2.new(0.5,0,1,0)
                normalClick.Position = UDim2.new(0,0,0,0)
                normalClick.BackgroundTransparency = 1
                normalClick.Text = ""; normalClick.AutoButtonColor = false
                normalClick.ZIndex = 8

                local semiClick = Instance.new("TextButton", modeHolder)
                semiClick.Size = UDim2.new(0.5,0,1,0)
                semiClick.Position = UDim2.new(0.5,0,0,0)
                semiClick.BackgroundTransparency = 1
                semiClick.Text = ""; semiClick.AutoButtonColor = false
                semiClick.ZIndex = 8

                local function setMode(mode)
                    if mode~="Semi" then mode="Normal" end
                    if autoGrabModule then
                        local oldMode = autoGrabModule.getMode()
                        local oldRadii = autoGrabModule.getRadii()
                        oldRadii[oldMode] = Steal.StealRadius
                    end
                    if autoGrabModule then autoGrabModule.setMode(mode) end
                    local radii = autoGrabModule and autoGrabModule.getRadii() or {Normal=60,Semi=10}
                    Steal.StealRadius = radii[mode] or (mode=="Semi" and 10 or 75)
                    if stealRadBox then stealRadBox.Text = tostring(Steal.StealRadius) end
                    local onSemi = mode=="Semi"
                    TweenService:Create(slide, TweenInfo.new(0.18), {
                        Position = onSemi and UDim2.new(0.5,-1,0,4) or UDim2.new(0,4,0,4)
                    }):Play()
                    TweenService:Create(normalTxt, TweenInfo.new(0.14), {
                        TextTransparency = onSemi and 0.25 or 0
                    }):Play()
                    TweenService:Create(semiTxt, TweenInfo.new(0.14), {
                        TextTransparency = onSemi and 0 or 0.25
                    }):Play()
                    requestSave()
                end

                normalClick.MouseButton1Click:Connect(function() setMode("Normal") end)
                semiClick.MouseButton1Click:Connect(function() setMode("Semi") end)

                local initMode = autoGrabModule and autoGrabModule.getMode() or "Normal"
                if initMode=="Semi" then
                    slide.Position = UDim2.new(0.5,-1,0,4)
                    normalTxt.TextTransparency = 0.25
                else
                    slide.Position = UDim2.new(0,4,0,4)
                    semiTxt.TextTransparency = 0.25
                end

                _G._K7StealModeSetUI = setMode
            end

            makeGap(4)
            makeSectionHeader("Grab Config")
            makeGap(2)

            stealRadBox = makeInputRow("Grab Radius", Steal.StealRadius, function(n)
                if n and n >= 1 and n <= 200 then
                    local applied = math.clamp(n,1,200)
                    Steal.StealRadius = applied
                    if stealRadBox then stealRadBox.Text = tostring(applied) end
                    if autoGrabModule then autoGrabModule.setRadius(applied) end
                    requestSave()
                end
            end)

            -- ── NEW: Auto Switch Carry Speed ─────────────────────────────
            makeGap(8)
            makeSectionHeader("Automatic Carry")
            makeGap(2)

            local softStealToggle = makeToggleRow("Auto Carry Switch", State.softStealEnabled or false, function(on)
                State.softStealEnabled = on
                if on then
                    if autoGrabModule and autoGrabModule.startSoftStealScanner then
                        autoGrabModule.startSoftStealScanner()
                    end
                else
                    if autoGrabModule and autoGrabModule.stopSoftStealScanner then
                        autoGrabModule.stopSoftStealScanner()
                    end
                end
                if stackBtnRefs.autoCarry then stackBtnRefs.autoCarry.setOn(on) end
                requestSave()
            end)
            toggleSetters["softSteal"] = softStealToggle

            makeGap(2)
            softStealRadiusBox = makeInputRow("Switch Radius", State.softStealRadius or 10, function(n)
                if n and n >= 1 and n <= 200 then State.softStealRadius = n; requestSave() end
            end)
            makeGap(2)
            softStealSpeedBox = makeInputRow("Switch Speed", State.softStealSpeed or 30, function(n)
                if n and n>0 then State.softStealSpeed = n end
            end)

        end)
        page.LayoutOrder = 4
    end

    -- CONFIG TAB (updated with softSteal added to reset)
    do
        local page = buildPage("Config", function()
            makeGap(2)
            makeSectionHeader("Interface")
            makeGap(2)
            makeKeybindRow("Hide GUI", Keys.guiHide, function(k) Keys.guiHide=k end, "guiHide")
            uiScaleBox = makeInputRow("Main UI Scale", 0.9, function(n)
                if n>=0.5 and n<=1.5 then
                    if uiScaleObj then uiScaleObj.Scale=n end
                    requestSave()
                end
            end)

            local buttonSizeRow=Instance.new("Frame",currentPage)
            buttonSizeRow.Size=UDim2.new(1,-16,0,42)
            buttonSizeRow.BackgroundColor3=currentColorScheme.rowBg
            buttonSizeRow.BackgroundTransparency=0.76
            buttonSizeRow.BorderSizePixel=0
            buttonSizeRow.LayoutOrder=LO()
            mkCorner(buttonSizeRow,21)
            local buttonSizeTitle=Instance.new("TextLabel",buttonSizeRow)
            buttonSizeTitle.Size=UDim2.new(1,-150,1,0); buttonSizeTitle.Position=UDim2.new(0,14,0,0)
            buttonSizeTitle.BackgroundTransparency=1; buttonSizeTitle.Text="Mobile Button Size"
            buttonSizeTitle.TextColor3=currentColorScheme.rowLabel; buttonSizeTitle.Font=Enum.Font.GothamBold
            buttonSizeTitle.TextSize=11; buttonSizeTitle.TextXAlignment=Enum.TextXAlignment.Left
            local sizeMinus=Instance.new("TextButton",buttonSizeRow)
            sizeMinus.Size=UDim2.new(0,34,0,30); sizeMinus.Position=UDim2.new(1,-136,0.5,-15)
            sizeMinus.BackgroundColor3=currentColorScheme.mainDark; sizeMinus.BackgroundTransparency=0.08
            sizeMinus.BorderSizePixel=0; sizeMinus.Text="-"; sizeMinus.TextColor3=Color3.fromRGB(255,255,255)
            sizeMinus.Font=Enum.Font.GothamBlack; sizeMinus.TextSize=17; mkCorner(sizeMinus,15)
            buttonScaleBox=Instance.new("TextLabel",buttonSizeRow)
            buttonScaleBox.Size=UDim2.new(0,54,0,30); buttonScaleBox.Position=UDim2.new(1,-98,0.5,-15)
            buttonScaleBox.BackgroundColor3=currentColorScheme.inputBg; buttonScaleBox.BackgroundTransparency=0.22
            buttonScaleBox.BorderSizePixel=0; buttonScaleBox.Text=string.format("%.1f",stackButtonScale)
            buttonScaleBox.TextColor3=currentColorScheme.rowValue; buttonScaleBox.Font=Enum.Font.GothamBlack
            buttonScaleBox.TextSize=11; mkCorner(buttonScaleBox,15)
            local sizePlus=Instance.new("TextButton",buttonSizeRow)
            sizePlus.Size=UDim2.new(0,34,0,30); sizePlus.Position=UDim2.new(1,-40,0.5,-15)
            sizePlus.BackgroundColor3=currentColorScheme.main; sizePlus.BackgroundTransparency=0.08
            sizePlus.BorderSizePixel=0; sizePlus.Text="+"; sizePlus.TextColor3=Color3.fromRGB(255,255,255)
            sizePlus.Font=Enum.Font.GothamBlack; sizePlus.TextSize=17; mkCorner(sizePlus,15)
            local function changeButtonSize(delta)
                local value=applyStackButtonScale(stackButtonScale+delta)
                buttonScaleBox.Text=string.format("%.1f",value)
                requestSave()
            end
            sizeMinus.MouseButton1Click:Connect(function() changeButtonSize(-0.1) end)
            sizePlus.MouseButton1Click:Connect(function() changeButtonSize(0.1) end)

            local shapeRow=Instance.new("Frame",currentPage)
            shapeRow.Size=UDim2.new(1,-16,0,44)
            shapeRow.BackgroundColor3=currentColorScheme.rowBg
            shapeRow.BackgroundTransparency=0.76
            shapeRow.BorderSizePixel=0
            shapeRow.LayoutOrder=LO()
            mkCorner(shapeRow,14)
            local shapeTitle=Instance.new("TextLabel",shapeRow)
            shapeTitle.Size=UDim2.new(0,72,1,0); shapeTitle.Position=UDim2.new(0,10,0,0)
            shapeTitle.BackgroundTransparency=1; shapeTitle.Text="Shape"
            shapeTitle.TextColor3=currentColorScheme.rowLabel; shapeTitle.Font=Enum.Font.GothamBlack
            shapeTitle.TextSize=12; shapeTitle.TextXAlignment=Enum.TextXAlignment.Left

            local shapeButtons={}
            local function makeShapeButton(label,shape,xOffset)
                local button=Instance.new("TextButton",shapeRow)
                button.Size=UDim2.new(0,52,0,30); button.Position=UDim2.new(1,xOffset,0.5,-15)
                button.BackgroundColor3=currentColorScheme.modeBtnBg; button.BackgroundTransparency=0.16
                button.BorderSizePixel=0; button.Text=label; button.TextColor3=currentColorScheme.mainLight
                button.Font=Enum.Font.GothamBlack; button.TextSize=9; button.AutoButtonColor=false
                mkCorner(button,10)
                shapeButtons[shape]=button
                button.MouseButton1Click:Connect(function()
                    applyMobileButtonShape(shape)
                    if _G._K7RefreshMobileButtonShape then _G._K7RefreshMobileButtonShape() end
                    requestSave()
                end)
            end
            makeShapeButton("7UP CAN","Can",-170)
            makeShapeButton("CIRCLE","Circle",-114)
            makeShapeButton("SQUARE","Square",-58)
            local function refreshMobileButtonShape()
                for shape,button in pairs(shapeButtons) do
                    local selected=State.mobileButtonShape==shape
                    button.BackgroundColor3=selected and currentColorScheme.main or currentColorScheme.modeBtnBg
                    button.TextColor3=selected and (currentColorScheme.buttonText or currentColorScheme.text) or currentColorScheme.mainLight
                    button.BackgroundTransparency=selected and 0.02 or 0.16
                end
            end
            _G._K7RefreshMobileButtonShape=refreshMobileButtonShape
            refreshMobileButtonShape()

            local introEnabledSetter = makeToggleRow("Show Intro on Start", State.introEnabled ~= false, function(on)
                State.introEnabled=on
                _introEnabled=on
                requestSave()
            end)
            toggleSetters["introEnabled"]=introEnabledSetter
            hideButtonsSetter = makeToggleRow("Hide Buttons", State.stackButtonsHidden, function(on) State.stackButtonsHidden=on; for _,wrapper in pairs(stackWrappers) do wrapper.Visible=not on end end)
            toggleSetters["hideButtons"] = hideButtonsSetter
            lockButtonsSetter = makeToggleRow("Lock Buttons", State.stackButtonsLocked, function(on) State.stackButtonsLocked=on end)
            toggleSetters["lockButtons"] = lockButtonsSetter

            makeGap(8)
            makeSectionHeader("Music Player")
            makeGap(2)
            local openMusicBtn = Instance.new("TextButton", currentPage)
            openMusicBtn.Size = UDim2.new(1, -16, 0, 36)
            openMusicBtn.BackgroundColor3 = currentColorScheme.main
            openMusicBtn.BackgroundTransparency = 0.15
            openMusicBtn.BorderSizePixel = 0
            openMusicBtn.Text = "OPEN MUSIC PLAYER"
            openMusicBtn.TextColor3 = currentColorScheme.buttonText
            openMusicBtn.Font = Enum.Font.GothamBold
            openMusicBtn.TextSize = 13
            openMusicBtn.AutoButtonColor = false
            openMusicBtn.LayoutOrder = LO()
            mkCorner(openMusicBtn, 10)
            openMusicBtn.MouseButton1Click:Connect(function()
                if openMusicPlayerUI then
                    openMusicPlayerUI()
                elseif _G.SevenUpOpenMusicPlayer then
                    _G.SevenUpOpenMusicPlayer()
                end
            end)
            makeGap(8)
            makeSectionHeader("Keybinds")
            makeGap(2)
            makeKeybindRow("Speed Toggle", Keys.speed, function(k) Keys.speed=k end, "speed")
            makeKeybindRow("Lagger Toggle", Keys.lagger, function(k) Keys.lagger=k end, "lagger")
            makeKeybindRow("Drop", Keys.drop, function(k) Keys.drop=k end, "drop")
            makeKeybindRow("Auto Left", Keys.autoLeft, function(k) Keys.autoLeft=k end, "autoLeft")
            makeKeybindRow("Auto Right", Keys.autoRight, function(k) Keys.autoRight=k end, "autoRight")
            makeKeybindRow("TP Down", Keys.tpDown, function(k) Keys.tpDown=k end, "tpDown")
            makeKeybindRow("Aimbot", Keys.aimbot, function(k) Keys.aimbot=k end, "aimbot")
            makeKeybindRow("TP Bat", Keys.antiDesync, function(k) Keys.antiDesync=k end, "antiDesync")

            makeGap(8)
            makeSectionHeader("Config Management")
            makeGap(2)
            local saveWrap = Instance.new("Frame", currentPage); saveWrap.Size = UDim2.new(1,0,0,36); saveWrap.BackgroundTransparency=1; saveWrap.BorderSizePixel=0; saveWrap.LayoutOrder=LO()
            local saveBtn = Instance.new("TextButton", saveWrap)
            saveBtn.Size = UDim2.new(1,-28,0,30)
            saveBtn.Position = UDim2.new(0,14,0,3)
            saveBtn.BackgroundColor3 = currentColorScheme.btnBg
            saveBtn.BackgroundTransparency = 0.2
            saveBtn.BorderSizePixel = 0
                        saveBtn.Text = "SAVE CONFIG"
            saveBtn.TextColor3 = currentColorScheme.main
            saveBtn.Font = Enum.Font.GothamBold
            saveBtn.TextSize = 13
            saveBtn.ZIndex = 5
            mkCorner(saveBtn, 16)

            saveBtn.MouseEnter:Connect(function()
                TweenService:Create(saveBtn, TweenInfo.new(0.1), {BackgroundColor3 = currentColorScheme.main, BackgroundTransparency = 0.05, TextColor3 = currentColorScheme.buttonText}):Play()
            end)
            saveBtn.MouseLeave:Connect(function()
                TweenService:Create(saveBtn, TweenInfo.new(0.1), {BackgroundColor3 = currentColorScheme.btnBg, BackgroundTransparency = 0.2, TextColor3 = currentColorScheme.main}):Play()
            end)
            saveBtn.MouseButton1Click:Connect(function()
                local callOk, saveOk = pcall(saveConfig)
                local success = callOk and saveOk == true
                if success then
                    saveBtn.Text = "SAVED!"
                    saveBtn.BackgroundColor3 = currentColorScheme.main
                    saveBtn.BackgroundTransparency = 0.05
                    saveBtn.TextColor3 = currentColorScheme.buttonText
                else
                    saveBtn.Text = "FAILED"
                    saveBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 40)
                    saveBtn.BackgroundTransparency = 0.1
                    saveBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
                end
                task.delay(2.5, function()
                    if saveBtn and saveBtn.Parent then
            saveBtn.Text = "SAVE CONFIG"
                        saveBtn.BackgroundColor3 = currentColorScheme.btnBg
                        saveBtn.BackgroundTransparency = 0.2
                        saveBtn.TextColor3 = currentColorScheme.main
                    end
                end)
            end)

            local transferHint = Instance.new("TextLabel", currentPage)
            transferHint.Size = UDim2.new(1,-28,0,28)
            transferHint.BackgroundTransparency = 1
            transferHint.Text = "Paste a shared 7UP config below, or leave it empty to import from your clipboard / " .. CONFIG_IMPORT_FILE
            transferHint.TextColor3 = currentColorScheme.rowSub
            transferHint.Font = Enum.Font.Gotham
            transferHint.TextSize = 9
            transferHint.TextWrapped = true
            transferHint.TextXAlignment = Enum.TextXAlignment.Left
            transferHint.LayoutOrder = LO()

            local importBox = Instance.new("TextBox", currentPage)
            importBox.Size = UDim2.new(1,-28,0,72)
            importBox.BackgroundColor3 = currentColorScheme.inputBg
            importBox.BackgroundTransparency = 0.15
            importBox.BorderSizePixel = 0
            importBox.ClearTextOnFocus = false
            importBox.MultiLine = true
            importBox.PlaceholderText = "Paste exported config JSON here..."
            importBox.PlaceholderColor3 = currentColorScheme.rowSub
            importBox.Text = ""
            importBox.TextColor3 = currentColorScheme.inputText
            importBox.TextSize = 9
            importBox.Font = Enum.Font.Code
            importBox.TextWrapped = true
            importBox.TextXAlignment = Enum.TextXAlignment.Left
            importBox.TextYAlignment = Enum.TextYAlignment.Top
            importBox.LayoutOrder = LO()
            mkCorner(importBox, 10)
            local importPadding = Instance.new("UIPadding", importBox)
            importPadding.PaddingLeft = UDim.new(0,10); importPadding.PaddingRight = UDim.new(0,10)
            importPadding.PaddingTop = UDim.new(0,8); importPadding.PaddingBottom = UDim.new(0,8)

            local transferWrap = Instance.new("Frame", currentPage)
            transferWrap.Size = UDim2.new(1,0,0,40)
            transferWrap.BackgroundTransparency = 1
            transferWrap.BorderSizePixel = 0
            transferWrap.LayoutOrder = LO()
            local exportBtn = Instance.new("TextButton", transferWrap)
            exportBtn.Size = UDim2.new(0.5,-17,0,30); exportBtn.Position = UDim2.new(0,14,0,5)
            exportBtn.BackgroundColor3 = currentColorScheme.btnBg; exportBtn.BackgroundTransparency = 0.15
            exportBtn.BorderSizePixel = 0; exportBtn.Text = "EXPORT CONFIG"
            exportBtn.TextColor3 = currentColorScheme.main; exportBtn.Font = Enum.Font.GothamBold; exportBtn.TextSize = 11
            mkCorner(exportBtn, 15)
            local importBtn = Instance.new("TextButton", transferWrap)
            importBtn.Size = UDim2.new(0.5,-17,0,30); importBtn.Position = UDim2.new(0.5,3,0,5)
            importBtn.BackgroundColor3 = currentColorScheme.main; importBtn.BackgroundTransparency = 0.08
            importBtn.BorderSizePixel = 0; importBtn.Text = "IMPORT CONFIG"
            importBtn.TextColor3 = currentColorScheme.buttonText; importBtn.Font = Enum.Font.GothamBold; importBtn.TextSize = 11
            mkCorner(importBtn, 15)

            local function resetTransferButton(button, text, bg, textColor)
                task.delay(2.5, function()
                    if button and button.Parent then
                        button.Text = text
                        button.BackgroundColor3 = bg
                        button.TextColor3 = textColor
                    end
                end)
            end

            exportBtn.MouseButton1Click:Connect(function()
                local saveCallOk, saved = false, false
                if saveConfig then saveCallOk, saved = pcall(saveConfig) end
                saved = saveCallOk and saved == true
                local raw = nil
                if saved and _isfile(CONFIG_FILE) then
                    pcall(function() raw = _readfile(CONFIG_FILE) end)
                end
                if not raw or raw == "" then
                    exportBtn.Text = "EXPORT FAILED"
                    exportBtn.BackgroundColor3 = Color3.fromRGB(180,60,40)
                    exportBtn.TextColor3 = Color3.fromRGB(255,220,220)
                else
                    pcall(function() _writefile(CONFIG_EXPORT_FILE, raw) end)
                    local copied = false
                    if _setclipboard then copied = pcall(_setclipboard, raw) end
                    exportBtn.Text = copied and "COPIED + EXPORTED!" or "EXPORTED TO FILE!"
                    exportBtn.BackgroundColor3 = currentColorScheme.main
                    exportBtn.TextColor3 = currentColorScheme.buttonText
                end
                resetTransferButton(exportBtn, "EXPORT CONFIG", currentColorScheme.btnBg, currentColorScheme.main)
            end)

            importBtn.MouseButton1Click:Connect(function()
                local raw = tostring(importBox.Text or ""):match("^%s*(.-)%s*$")
                if raw == "" and _getclipboard then
                    local clipOk, clip = pcall(_getclipboard)
                    if clipOk and type(clip) == "string" then raw = clip:match("^%s*(.-)%s*$") end
                end
                if raw == "" and _isfile(CONFIG_IMPORT_FILE) then
                    pcall(function() raw = tostring(_readfile(CONFIG_IMPORT_FILE) or ""):match("^%s*(.-)%s*$") end)
                end

                local valid, decoded = false, nil
                if raw ~= "" and #raw <= 2000000 then
                    valid, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
                    valid = valid and type(decoded) == "table"
                        and decoded.version == CONFIG_VERSION
                        and decoded.theme == "sevenup_green"
                end

                if not valid then
                    importBtn.Text = "INVALID CONFIG"
                    importBtn.BackgroundColor3 = Color3.fromRGB(180,60,40)
                    importBtn.TextColor3 = Color3.fromRGB(255,220,220)
                else
                    local encodedOk, normalized = pcall(HttpService.JSONEncode, HttpService, decoded)
                    if encodedOk then
                        pcall(function()
                            _writefile(CONFIG_FILE, normalized)
                            _writefile(CONFIG_BACKUP, normalized)
                        end)
                    end
                    local applied = false
                    if encodedOk and loadConfig then
                        local loadOk, loadResult = pcall(loadConfig, normalized)
                        applied = loadOk and loadResult == true
                    end
                    if applied then
                        importBox.Text = ""
                        importBtn.Text = "IMPORTED!"
                        importBtn.BackgroundColor3 = currentColorScheme.main
                        importBtn.TextColor3 = currentColorScheme.buttonText
                    else
                        importBtn.Text = "IMPORT FAILED"
                        importBtn.BackgroundColor3 = Color3.fromRGB(180,60,40)
                        importBtn.TextColor3 = Color3.fromRGB(255,220,220)
                    end
                end
                resetTransferButton(importBtn, "IMPORT CONFIG", currentColorScheme.main, currentColorScheme.buttonText)
            end)

            local resetWrap = Instance.new("Frame", currentPage); resetWrap.Size = UDim2.new(1,0,0,36); resetWrap.BackgroundTransparency=1; resetWrap.BorderSizePixel=0; resetWrap.LayoutOrder=LO()
            local resetAllBtn = Instance.new("TextButton", resetWrap); resetAllBtn.Size = UDim2.new(1,-28,0,26); resetAllBtn.Position = UDim2.new(0,14,0,5); resetAllBtn.BackgroundColor3=currentColorScheme.mainDark; resetAllBtn.BackgroundTransparency=0.2; resetAllBtn.BorderSizePixel=0; resetAllBtn.Text="Reset All Settings"; resetAllBtn.TextColor3=currentColorScheme.buttonText; resetAllBtn.Font=Enum.Font.GothamBold; resetAllBtn.TextSize=11; resetAllBtn.ZIndex=5; mkCorner(resetAllBtn,16)
            resetAllBtn.MouseEnter:Connect(function() TweenService:Create(resetAllBtn,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.main,BackgroundTransparency=0.05}):Play() end)
            resetAllBtn.MouseLeave:Connect(function() TweenService:Create(resetAllBtn,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.mainDark,BackgroundTransparency=0.2}):Play() end)
            local _resetConfirmStage=0; local _resetConfirmTimer=nil
            resetAllBtn.MouseButton1Click:Connect(function()
                if _resetConfirmStage==0 then
                    _resetConfirmStage=1; resetAllBtn.Text="Click again to confirm!"; resetAllBtn.BackgroundColor3=currentColorScheme.main; resetAllBtn.BackgroundTransparency=0.05
                    if _resetConfirmTimer then task.cancel(_resetConfirmTimer) end
                    _resetConfirmTimer = task.delay(3,function() if resetAllBtn and resetAllBtn.Parent then _resetConfirmStage=0; resetAllBtn.Text="Reset All Settings"; resetAllBtn.BackgroundColor3=currentColorScheme.mainDark; resetAllBtn.BackgroundTransparency=0.2 end end)
                    return
                end
                _resetConfirmStage=0; if _resetConfirmTimer then task.cancel(_resetConfirmTimer); _resetConfirmTimer=nil end
                pcall(function() if State.batAimbotToggled then stopBatAimbot() end end)
                pcall(function() if State.batCounterEnabled then stopBatCounter() end end)
                pcall(function() if State.medusaCounterEnabled then stopMedusaCounter() end end)
                pcall(function() if State.antiRagdollEnabled then stopAntiRagdollNew() end end)
                pcall(function() if State.antiLagEnabled then disableAntiLag() end end)
                pcall(function() if State.stretchedResEnabled then disableStretchRez() end end)
                pcall(function() if State.autoTPEnabled then stopAutoTP() end end)

                pcall(function() if State.antiDieEnabled then stopAntiDie() end end)
                pcall(function() if State.antiFlingShieldEnabled then stopAntiFlingShield() end end)

                State.normalSpeed=60; State.carrySpeed=30; State.laggerSpeed=10.1; State.laggerCarrySpeed=15
                State.speedToggled=false; State.laggerMode=0; State.infJumpEnabled=true; State.antiRagdollEnabled=false; State.antiRagdollVersion="V1"
                State.antiLagEnabled=false; State.saturatedColorsEnabled=false; State.stretchedResEnabled=false
                State.medusaCounterEnabled=false; State.batCounterEnabled=false
                State.batAimbotToggled=false; State.autoSwingEnabled=true
                State.stackButtonsHidden=false; State.stackButtonsLocked=false; State.mobileButtonShape="Can"; State.introEnabled=false; _introEnabled=false
                State.autoTPEnabled=false; State.autoTPHeight=20; State.removeAcc=false; State.tryardAnimEnabled=false
                if _G._removeAccStop then pcall(_G._removeAccStop) end
                AIMBOT_SPEED=50; LAGGER_AIMBOT_SPEED=40
                if _G.AceRefreshAimbotSpeedBoxes then pcall(_G.AceRefreshAimbotSpeedBoxes) end

                State.espEnabled = false; State.espTracer = false; State.espTracerWanted = false; State.skyTheme = "Off"
                State.antiDieEnabled=false; State.antiFlingShieldEnabled=false
                BoxedESPOptions.box = false
                stopPlayerESP(); stopTracerESP(true); refreshBoxedESP(); pcall(applyCustomSky, "Off")
                if toggleSetters["esp"]    then pcall(toggleSetters["esp"],    false) end
                if toggleSetters["espTracer"] then pcall(toggleSetters["espTracer"], false) end
                State.headlessEnabled = false
                State.korbloxEnabled = false
                State.customSkinEnabled = false
                State.customSkinVariant = 1
                syncCustomSkinVariant(1)
                set7UpColorTheme("Green", true)
                State.outfit1Applied = false
                State.outfit3Applied = false
                State.outfit2Applied = false
                pcall(applyCharterToChar, LP.Character)
                if toggleSetters["headless"] then pcall(toggleSetters["headless"], false) end
                if toggleSetters["korblox"] then pcall(toggleSetters["korblox"], false) end
                if toggleSetters["customSkin"] then pcall(toggleSetters["customSkin"], false) end
                if toggleSetters["outfit1"] then pcall(toggleSetters["outfit1"], false) end
                if toggleSetters["outfit2"] then pcall(toggleSetters["outfit2"], false) end
                if toggleSetters["outfit3"] then pcall(toggleSetters["outfit3"], false) end
                Steal.StealRadius=75
                Steal.AutoStealEnabled=true
                if autoGrabModule then
                    local resetRadii = autoGrabModule.getRadii()
                    if resetRadii then resetRadii.Normal=75; resetRadii.Semi=10 end
                    autoGrabModule.setMode("Normal")
                    autoGrabModule.setRadius(75)
                    autoGrabModule.setEnabled(true)
                end
                -- Reset Soft Steal
                State.softStealEnabled = false
                State.softStealLatched = false
                State.softStealRadius = 10
                State.softStealSpeed = 30
                if softStealRadiusBox then softStealRadiusBox.Text = "10" end
                if softStealSpeedBox then softStealSpeedBox.Text = "30" end
                if autoGrabModule and autoGrabModule.stopSoftStealScanner then
                    autoGrabModule.stopSoftStealScanner()
                end
                if toggleSetters["softSteal"] then pcall(toggleSetters["softSteal"], false) end

                Keys.speed=Enum.KeyCode.Q; Keys.guiHide=Enum.KeyCode.LeftControl
                Keys.lagger=Enum.KeyCode.Unknown; Keys.tpDown=Enum.KeyCode.Unknown; Keys.drop=Enum.KeyCode.H; Keys.aimbot=Enum.KeyCode.Unknown
                Keys.autoLeft=Enum.KeyCode.L; Keys.autoRight=Enum.KeyCode.R
                Keys.antiDesync=Enum.KeyCode.V
                currentDropType = DROP_TYPES.JUMP
                if normalBox then normalBox.Text=tostring(State.normalSpeed) end; if carryBox then carryBox.Text=tostring(State.carrySpeed) end
                if laggerBox then laggerBox.Text=tostring(State.laggerSpeed) end; if laggerCarryBox then laggerCarryBox.Text=tostring(State.laggerCarrySpeed) end
                if stealRadBox then stealRadBox.Text=tostring(Steal.StealRadius) end
                if uiScaleObj then uiScaleObj.Scale=0.9 end; if uiScaleBox then uiScaleBox.Text="0.9" end
                applyStackButtonScale(1); if buttonScaleBox then buttonScaleBox.Text="1.0" end
                applyMobileButtonShape("Can"); if _G._K7RefreshMobileButtonShape then pcall(_G._K7RefreshMobileButtonShape) end
                if setInfJump then pcall(setInfJump,true) end; if setAntiRag then pcall(setAntiRag,false) end
                if setMedusaCounter then pcall(setMedusaCounter,false) end; if setBatCounter then pcall(setBatCounter,false) end; if setAutoSwing then pcall(setAutoSwing,true) end
                if hideButtonsSetter then pcall(hideButtonsSetter,false) end; if lockButtonsSetter then pcall(lockButtonsSetter,false) end
                if toggleSetters["autoSteal"] then pcall(toggleSetters["autoSteal"], true) end
                if toggleSetters["antiLag"] then pcall(toggleSetters["antiLag"], false) end
                if toggleSetters["stretchedRes"] then pcall(toggleSetters["stretchedRes"], false) end
                if toggleSetters["removeAcc"] then pcall(toggleSetters["removeAcc"], false) end
                if toggleSetters["tryardAnim"] then pcall(toggleSetters["tryardAnim"], false) end

                if toggleSetters["antiDie"] then pcall(toggleSetters["antiDie"], false) end
                if toggleSetters["antiFlingShield"] then pcall(toggleSetters["antiFlingShield"], false) end
                if _G._K7RefreshRagdollVersionButtons then pcall(_G._K7RefreshRagdollVersionButtons) end
                if stackBtnRefs then for key,ref in pairs(stackBtnRefs) do if ref and ref.setOn then pcall(ref.setOn,false) end end end
                if keybindBtnRefs then refreshAllKeybindButtons() end
                for i,def in ipairs(stackDefs) do local wrapper=stackWrappers[def.key]; if wrapper then TweenService:Create(wrapper,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=getDefaultStackPos(i)}):Play() end end
                resetAllBtn.Text="All Settings Reset!"; resetAllBtn.BackgroundColor3=currentColorScheme.main; resetAllBtn.BackgroundTransparency=0.05
                task.delay(2,function() if resetAllBtn and resetAllBtn.Parent then resetAllBtn.Text="Reset All Settings"; resetAllBtn.BackgroundColor3=currentColorScheme.mainDark; resetAllBtn.BackgroundTransparency=0.2 end end)
            end)

            makeGap(8)
            makeSectionHeader("Layout")
            makeGap(2)
            local rWrap = Instance.new("Frame", currentPage); rWrap.Size = UDim2.new(1,0,0,36); rWrap.BackgroundTransparency=1; rWrap.BorderSizePixel=0; rWrap.LayoutOrder=LO()
            local resetBtn = Instance.new("TextButton", rWrap); resetBtn.Size = UDim2.new(1,-28,0,26); resetBtn.Position = UDim2.new(0,14,0,5); resetBtn.BackgroundColor3=currentColorScheme.btnBg; resetBtn.BackgroundTransparency=0.3; resetBtn.BorderSizePixel=0; resetBtn.Text="Reset Button Positions"; resetBtn.TextColor3=currentColorScheme.btnTxt; resetBtn.Font=Enum.Font.GothamBold; resetBtn.TextSize=11; resetBtn.ZIndex=5; mkCorner(resetBtn,16)
            resetBtn.MouseEnter:Connect(function() TweenService:Create(resetBtn,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.btnHov,BackgroundTransparency=0.1}):Play() end)
            resetBtn.MouseLeave:Connect(function() TweenService:Create(resetBtn,TweenInfo.new(0.1),{BackgroundColor3=currentColorScheme.btnBg,BackgroundTransparency=0.3}):Play() end)
            resetBtn.MouseButton1Click:Connect(function()
                for i,def in ipairs(stackDefs) do local wrapper=stackWrappers[def.key]; if wrapper then TweenService:Create(wrapper,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=getDefaultStackPos(i)}):Play() end end
                resetBtn.Text="Positions Reset!"; task.delay(1.8,function() if resetBtn and resetBtn.Parent then resetBtn.Text="Reset Button Positions" end end)
            end)

            makeGap(10)
            local fw = Instance.new("Frame", currentPage); fw.Size = UDim2.new(1,0,0,22); fw.BackgroundTransparency=1; fw.BorderSizePixel=0; fw.LayoutOrder=LO()
            local fl = Instance.new("TextLabel", fw); fl.Size = UDim2.new(1,0,1,0); fl.BackgroundTransparency=1; fl.Text="discord.gg/7up"; fl.TextColor3=Color3.fromRGB(0,204,102); fl.Font=Enum.Font.GothamBlack; fl.TextSize=10; fl.TextXAlignment=Enum.TextXAlignment.Center
            _G._VezySaveStatusLbl = fl
            _G._VezyFlashSave = function(success)
                if not _G._VezySaveStatusLbl or not _G._VezySaveStatusLbl.Parent then return end
                local lbl = _G._VezySaveStatusLbl
                if success then lbl.Text="Auto-saved"; lbl.TextColor3=currentColorScheme.main
                else lbl.Text="Save failed"; lbl.TextColor3=currentColorScheme.mainLight end
                task.delay(1.5,function() if lbl and lbl.Parent then lbl.Text="discord.gg/7up"; lbl.TextColor3=Color3.fromRGB(0,204,102) end end)
            end
        end)
        page.LayoutOrder = 5
    end

    -- ============================================================
    -- SELECT FIRST TAB
    -- ============================================================
    selectTab(1)

    -- ============================================================
    -- STACK BUTTONS (green theme)
    -- ============================================================
    local function updateLaggerButtons()
        if stackBtnRefs.lagger then stackBtnRefs.lagger.setOn(State.laggerMode==1) end
        if stackBtnRefs.laggerCarry then stackBtnRefs.laggerCarry.setOn(State.laggerMode==2) end
    end

    local function setLaggerMode(mode, forceCarry)
        if mode == State.laggerMode and not forceCarry then return end
        local oldMode = State.laggerMode
        if mode == 0 then
            State.carrySpeed = State._prevCarry or 30
            State.speedToggled = State._prevSpeed or false
            if forceCarry then
                State.speedToggled = true
                State._prevSpeed = true
            end
            if carryBox then carryBox.Text = tostring(State.carrySpeed) end
            if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
        elseif mode == 1 then
            if oldMode == 0 then State._prevCarry = State.carrySpeed; State._prevSpeed = State.speedToggled end
            State.speedToggled = false
            if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
            if carryBox then carryBox.Text = tostring(State.carrySpeed) end
        elseif mode == 2 then
            if oldMode == 0 then State._prevCarry = State.carrySpeed; State._prevSpeed = State.speedToggled end
            State.speedToggled = false
            if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(false) end
            if carryBox then carryBox.Text = tostring(State.carrySpeed) end
        end
        State.laggerMode = mode
        updateLaggerButtons()
        if toggleSetters["laggerMode"] then
            pcall(toggleSetters["laggerMode"], State.laggerMode ~= 0)
        end
        if toggleSetters["carryMode"] then
            pcall(toggleSetters["carryMode"], State.speedToggled == true)
        end
        requestSave()
    end

    local function toggleLaggerMode()
        if State.laggerMode == 0 then setLaggerMode(1)
        elseif State.laggerMode == 1 then setLaggerMode(2)
        else setLaggerMode(1) end
    end

    local function toggleSpeed()
        -- Carry has priority: one press leaves either Lagger mode and goes
        -- directly to Carry instead of requiring an extra press.
        if State.laggerMode ~= 0 then setLaggerMode(0, true); return end
        State.speedToggled = not State.speedToggled
        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
        if toggleSetters["carryMode"] then
            pcall(toggleSetters["carryMode"], State.speedToggled == true)
        end
        if carryBox then carryBox.Text = tostring(State.carrySpeed) end
        requestSave()
    end

    for i,def in ipairs(stackDefs) do
        local btnFrame = Instance.new("TextButton", gui)
        btnFrame.Name = "StackBtn_"..def.key
        btnFrame.Size = UDim2.new(0,BTN_W,0,BTN_H)
        btnFrame.Position = getDefaultStackPos(i)
        btnFrame.BackgroundColor3 = currentColorScheme.stackBg
        btnFrame.BackgroundTransparency = 1
        btnFrame.BorderSizePixel=0
        btnFrame.AutoButtonColor = false
        btnFrame.Text = ""
        btnFrame.TextColor3 = Color3.fromRGB(255,255,255)
        btnFrame.TextScaled = false
        btnFrame.TextSize = 16
        btnFrame.Font = Enum.Font.GothamBold
        btnFrame.TextWrapped = true
        btnFrame.LineHeight = 1.2
        btnFrame.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        btnFrame.TextStrokeTransparency = 1
        btnFrame.ZIndex=15
        btnFrame.Visible = false
        mkCorner(btnFrame,12)
        local mobileScale=Instance.new("UIScale",btnFrame)
        mobileScale.Name="MobileButtonOnlyScale"
        mobileScale.Scale=stackButtonScale

        local stackSurface = Instance.new("Frame",btnFrame)
        stackSurface.Name="SodaCanSurface"
        stackSurface.Size=UDim2.new(1,0,1,-10)
        stackSurface.Position=UDim2.new(0,0,0,10)
        stackSurface.BackgroundColor3=currentColorScheme.stackBg
        stackSurface.BackgroundTransparency=0.08
        stackSurface.BorderSizePixel=0
        stackSurface.ClipsDescendants=true
        stackSurface.Active=false
        stackSurface.ZIndex=14
        mkCorner(stackSurface,14)
        local stackGradient=Instance.new("UIGradient",stackSurface)
        stackGradient.Name="AdaptiveCanBlend"
        stackGradient.Color=adaptiveCanColorSequence(currentColorScheme,false)
        stackGradient.Rotation=8
        local topNeck=Instance.new("Frame",btnFrame)
        topNeck.Name="IndentedCanTop"
        -- Wide, shallow indented cap: it overlaps the body as one can instead
        -- of reading as a separate circle.
        topNeck.Size=UDim2.new(1,-8,0,26); topNeck.Position=UDim2.new(0,4,0,0)
        topNeck.BackgroundColor3=currentColorScheme.stackBg; topNeck.BackgroundTransparency=0
        topNeck.BorderSizePixel=0; topNeck.ClipsDescendants=true; topNeck.Active=false; topNeck.ZIndex=17
        mkCorner(topNeck,9)
        local topNeckGradient=Instance.new("UIGradient",topNeck)
        topNeckGradient.Name="AdaptiveCanBlend"
        topNeckGradient.Color=adaptiveCanColorSequence(currentColorScheme,false)
        topNeckGradient.Transparency=NumberSequence.new(0)
        topNeckGradient.Rotation=8
        local stackOutline=Instance.new("UIStroke",btnFrame)
        stackOutline.Color=Color3.fromRGB(0,200,80)
        stackOutline.Transparency=0.18
        stackOutline.Thickness=2
        stackOutline.Enabled=false

        -- Aluminum rims and vertical shine make each mobile control read as a soda can.
        for _,rimY in ipairs({4,77}) do
            local rim=Instance.new("Frame",stackSurface)
            rim.Size=UDim2.new(1,-14,0,5); rim.Position=UDim2.new(0,7,0,rimY)
            rim.BackgroundColor3=Color3.fromRGB(142,158,148); rim.BackgroundTransparency=0
            rim.BorderSizePixel=0; rim.ZIndex=15; mkCorner(rim,3)
            rim.Visible=false
        end
        local canShine=Instance.new("Frame",stackSurface)
        canShine.Size=UDim2.new(0,3,1,-22); canShine.Position=UDim2.new(0,9,0,11)
        canShine.BackgroundColor3=Color3.fromRGB(255,255,255); canShine.BackgroundTransparency=0.58
        canShine.BorderSizePixel=0; canShine.ZIndex=15; mkCorner(canShine,2)
        canShine.Visible=false
        -- Logo lives on the button root at a higher layer so the indented top can never cover it.
        local logoDisc=Instance.new("Frame",btnFrame)
        logoDisc.Name="FrontSevenDisc"
        logoDisc.Size=UDim2.new(0,28,0,28); logoDisc.Position=UDim2.new(0.5,-24,0,9)
        logoDisc.BackgroundColor3=Color3.fromRGB(224,38,45); logoDisc.BorderSizePixel=0; logoDisc.ZIndex=24; mkCorner(logoDisc,15)
        local miniSeven=Instance.new("TextLabel",logoDisc)
        miniSeven.Name="MobileSevenLogo"
        miniSeven.Size=UDim2.new(1,0,1,0); miniSeven.BackgroundTransparency=1; miniSeven.Text="7"
        miniSeven.TextColor3=Color3.fromRGB(255,255,255); miniSeven.TextStrokeColor3=currentColorScheme.mainDark
        miniSeven.TextStrokeTransparency=0.35; miniSeven.Font=Enum.Font.GothamBlack; miniSeven.TextSize=20
        miniSeven.Rotation=-8; miniSeven.ZIndex=25
        local miniUp=Instance.new("TextLabel",btnFrame)
        miniUp.Name="MiniUp"
        miniUp.Size=UDim2.new(0,30,0,22); miniUp.Position=UDim2.new(0.5,4,0,12)
        miniUp.BackgroundTransparency=1; miniUp.Text="UP"; miniUp.TextColor3=Color3.fromRGB(255,255,255)
        miniUp.Font=Enum.Font.GothamBlack; miniUp.TextSize=12; miniUp.TextXAlignment=Enum.TextXAlignment.Left
        miniUp.Rotation=-5; miniUp.ZIndex=25
        local stackLabel=Instance.new("TextLabel",btnFrame)
        stackLabel.Name="StackFeatureLabel"
        stackLabel.Size=UDim2.new(1,-8,0,46); stackLabel.Position=UDim2.new(0,4,0,44)
        stackLabel.BackgroundColor3=Color3.fromRGB(0,70,32); stackLabel.BackgroundTransparency=1
        stackLabel.BorderSizePixel=0; stackLabel.Text=def.label; stackLabel.TextColor3=Color3.fromRGB(255,255,255)
        stackLabel.TextStrokeColor3=Color3.fromRGB(0,0,0); stackLabel.TextStrokeTransparency=1
        stackLabel.TextSize=11; stackLabel.Font=Enum.Font.GothamBlack; stackLabel.TextWrapped=true; stackLabel.LineHeight=0.96
        stackLabel.ZIndex=18; mkCorner(stackLabel,11)
        local labelStroke=Instance.new("UIStroke",stackLabel)
        labelStroke.Color=Color3.fromRGB(0,200,80); labelStroke.Transparency=1; labelStroke.Thickness=1
        labelStroke.Enabled=false
        local stateDot=Instance.new("Frame",btnFrame)
        stateDot.Size=UDim2.new(0,8,0,8); stateDot.Position=UDim2.new(1,-14,0,8)
        stateDot.BackgroundColor3=Color3.fromRGB(105,135,110); stateDot.BorderSizePixel=0; stateDot.ZIndex=19; mkCorner(stateDot,4)
        stateDot.Visible=false
        local stateDotStroke=Instance.new("UIStroke",stateDot); stateDotStroke.Color=Color3.fromRGB(200,255,210); stateDotStroke.Transparency=0.45
        stateDotStroke.Enabled=false
        local btnState = false
        btnFrame.MouseEnter:Connect(function()
            TweenService:Create(mobileScale,TweenInfo.new(0.13,Enum.EasingStyle.Back),{Scale=stackButtonScale*1.07}):Play()
            TweenService:Create(stackOutline,TweenInfo.new(0.13),{Transparency=0,Thickness=2.5}):Play()
        end)
        btnFrame.MouseLeave:Connect(function()
            TweenService:Create(mobileScale,TweenInfo.new(0.13),{Scale=stackButtonScale}):Play()
            TweenService:Create(stackOutline,TweenInfo.new(0.13),{Transparency=btnState and 0 or 0.18,Thickness=btnState and 3 or 2}):Play()
        end)
        btnFrame.MouseButton1Down:Connect(function()
            TweenService:Create(mobileScale,TweenInfo.new(0.07),{Scale=stackButtonScale*0.92}):Play()
        end)
        btnFrame.MouseButton1Up:Connect(function()
            TweenService:Create(mobileScale,TweenInfo.new(0.13,Enum.EasingStyle.Back),{Scale=stackButtonScale*1.04}):Play()
        end)
        stackWrappers[def.key] = btnFrame
        styleSingleMobileButton(btnFrame, State.mobileButtonShape)

        local function setOn(on)
            btnState = on
            btnFrame:SetAttribute("Active",on)
            local live=currentColorScheme
            local sharedBlend=adaptiveCanColorSequence(live,on)
            stackGradient.Color=sharedBlend
            topNeckGradient.Color=sharedBlend
            TweenService:Create(btnFrame,TweenInfo.new(0.15),{
                TextColor3=on and (live.stackActiveText or live.buttonText) or (live.mainLight or live.stackText)
            }):Play()
            TweenService:Create(stackSurface,TweenInfo.new(0.15),{BackgroundColor3=on and live.stackActive or live.stackBg,BackgroundTransparency=on and 0 or 0.08}):Play()
            TweenService:Create(topNeck,TweenInfo.new(0.15),{BackgroundColor3=on and live.stackActive or live.stackBg,BackgroundTransparency=0}):Play()
            TweenService:Create(stackOutline,TweenInfo.new(0.15),{Color=on and (live.stackActiveBorder or live.main) or (live.stackBorder or live.mainDark),Transparency=on and 0 or 0.18,Thickness=on and 3 or 2}):Play()
            TweenService:Create(stateDot,TweenInfo.new(0.15),{BackgroundColor3=on and (live.dotOn or live.main) or (live.dotOff or live.mainDark),Size=on and UDim2.new(0,10,0,10) or UDim2.new(0,8,0,8),Position=on and UDim2.new(1,-15,0,7) or UDim2.new(1,-14,0,8)}):Play()
            TweenService:Create(stackLabel,TweenInfo.new(0.15),{BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,255,255),TextStrokeTransparency=on and 0 or 0.14}):Play()
            TweenService:Create(labelStroke,TweenInfo.new(0.15),{Transparency=1}):Play()
        end
        stackBtnRefs[def.key] = {setOn = setOn, setLabel = function(txt) stackLabel.Text = txt end}
        if def.key == "aimbot" then
            stackLabel.Text = State.aimbotMode=="new" and "AIMBOT\nNEW" or "AIMBOT\nOLD"
        end

        local function onTap()
            if def.key == "tpDown" then
                task.spawn(function() if runTPDown then pcall(runTPDown) end; setOn(true); task.wait(0.12); setOn(false) end)
                return
            end
            if def.key == "drop" then
                task.spawn(function() pcall(runDrop) end)
                return
            end
            if def.key == "autoLeft" then
                if State.autoLeftEnabled then stopAutoLeft() else startAutoLeft() end
                setOn(State.autoLeftEnabled == true)
                requestSave()
                return
            end
            if def.key == "autoRight" then
                if State.autoRightEnabled then stopAutoRight() else startAutoRight() end
                setOn(State.autoRightEnabled == true)
                requestSave()
                return
            end
            if def.key == "carrySpeed" then
                toggleSpeed()
                return
            end
            if def.key == "autoCarry" then
                State.softStealEnabled = not State.softStealEnabled
                setOn(State.softStealEnabled)
                if toggleSetters.softSteal then toggleSetters.softSteal(State.softStealEnabled) end
                if State.softStealEnabled then
                    if autoGrabModule and autoGrabModule.startSoftStealScanner then autoGrabModule.startSoftStealScanner() end
                else
                    if autoGrabModule and autoGrabModule.stopSoftStealScanner then autoGrabModule.stopSoftStealScanner() end
                end
                requestSave()
                return
            end
            if def.key == "lagger" then
                if State.laggerMode==1 then setLaggerMode(0) else setLaggerMode(1) end
                return
            end
            if def.key == "laggerCarry" then
                if State.laggerMode==2 then setLaggerMode(0) else setLaggerMode(2) end
                return
            end
            if def.key == "antiDesync" then
                if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
                    if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
                    return
                end
                if _G.AceToggleAntiDesyncAimbot then _G.AceToggleAntiDesyncAimbot() end
                setOn(_G.AceAntiDesyncAimbotOn == true)
                requestSave()
                return
            end
            if def.key == "aimbot" then
                if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
                    if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
                    return
                end
                if _G.AceToggleSelectedAimbot then pcall(_G.AceToggleSelectedAimbot) end
                local on = (_G.AceNormalAimbotOn == true) or (State.batAimbotZombie == true)
                State.batAimbotToggled = (_G.AceNormalAimbotOn == true)
                setOn(on)
                if stackBtnRefs.aimbot then
                    stackBtnRefs.aimbot.setOn(on)
                    if stackBtnRefs.aimbot.setLabel then
                        stackBtnRefs.aimbot.setLabel(State.aimbotMode=="new" and "AIMBOT\nNEW" or "AIMBOT\nOLD")
                    end
                end
                requestSave()
                return
            end
            local ns = not btnState; setOn(ns)
            requestSave()
        end

        makeStackDraggable(btnFrame, onTap)
    end

    task.spawn(function()
        local lastAimbot=nil
        local lastAntiDesync=nil
        while gui and gui.Parent do
            local aimbotOn=(_G.AceNormalAimbotOn==true) or (State.batAimbotZombie==true)
            local antiDesyncOn=_G.AceAntiDesyncAimbotOn==true
            if aimbotOn~=lastAimbot then
                lastAimbot=aimbotOn
                if stackBtnRefs.aimbot then
                    stackBtnRefs.aimbot.setOn(aimbotOn)
                    if stackBtnRefs.aimbot.setLabel then
                        stackBtnRefs.aimbot.setLabel(State.aimbotMode=="new" and "AIMBOT\nNEW" or "AIMBOT\nOLD")
                    end
                end
            end
            if antiDesyncOn~=lastAntiDesync then
                lastAntiDesync=antiDesyncOn
                if stackBtnRefs.antiDesync then stackBtnRefs.antiDesync.setOn(antiDesyncOn) end
            end
            task.wait(0.1)
        end
    end)
    pcall(loadStackPositionsNow)
    if stackBtnRefs.autoCarry then stackBtnRefs.autoCarry.setOn(State.softStealEnabled == true) end

    -- ============================================================
    -- SAVE/LOAD CONFIG (updated with softSteal)
    -- ============================================================
    saveConfig = function()
        local success = false
        pcall(function()
            local btnPositions = {}
            for key, wrapper in pairs(stackWrappers) do
                if wrapper and wrapper.Position then
                    btnPositions[key] = { XS = wrapper.Position.X.Scale, X = wrapper.Position.X.Offset, YS = wrapper.Position.Y.Scale, Y = wrapper.Position.Y.Offset }
                end
            end
            pcall(saveStackPositionsNow)
            local cfg = {
                version = CONFIG_VERSION,
                theme = "sevenup_green",
                normalSpeed = State.normalSpeed,
                carrySpeed = State.carrySpeed,
                laggerSpeed = State.laggerSpeed,
                laggerCarrySpeed = State.laggerCarrySpeed,
                speedToggled = State.speedToggled,
                laggerMode = State.laggerMode,
                stealRadius = Steal.StealRadius,
                autoStealEnabled = Steal.AutoStealEnabled,
                selectedStealMode = autoGrabModule and autoGrabModule.getMode() or "Normal",
                stealRadii = (function()
                    if autoGrabModule then
                        local radii = autoGrabModule.getRadii()
                        if type(radii) == "table" then
                            local mode = autoGrabModule.getMode() or "Normal"
                            radii[mode] = tonumber(Steal.StealRadius) or radii[mode]
                            return {
                                Normal = tonumber(radii.Normal) or 60,
                                Semi   = tonumber(radii.Semi) or 10
                            }
                        end
                    end
                    return { Normal = 60, Semi = 10 }
                end)(),
                uiScale = uiScaleObj and uiScaleObj.Scale or 0.9,
                buttonScale = stackButtonScale,
                mobileButtonShape = State.mobileButtonShape,
                autoGrabScale = autoGrabModule and autoGrabModule.getScale() or 1,
                stackButtonsHidden = State.stackButtonsHidden,
                stackButtonsLocked = State.stackButtonsLocked,
                speedKey = Keys.speed and Keys.speed.Name or "Q",
                guiHideKey = Keys.guiHide and Keys.guiHide.Name or "LeftControl",
                dropKey = Keys.drop and Keys.drop.Name or "H",
                laggerKey = Keys.lagger and Keys.lagger.Name or "Unknown",
                tpDownKey = Keys.tpDown and Keys.tpDown.Name or "Unknown",
                aimbotKey = Keys.aimbot and Keys.aimbot.Name or "Unknown",
                autoLeftKey = Keys.autoLeft and Keys.autoLeft.Name or "L",
                autoRightKey = Keys.autoRight and Keys.autoRight.Name or "R",
                antiDesyncKey = Keys.antiDesync and Keys.antiDesync.Name or "V",
                safeMode = antiKickEnabled,
                normalAimbotSpeed = AIMBOT_SPEED,
                laggerAimbotSpeed = LAGGER_AIMBOT_SPEED,
                selectedAnimationPack = selectedAnimationPack,
                infJump = State.infJumpEnabled,
                antiRagdoll = State.antiRagdollEnabled,
                antiRagdollVersion = State.antiRagdollVersion,
                medusaCounter = State.medusaCounterEnabled,
                batCounter = State.batCounterEnabled,
                autoSwing = State.autoSwingEnabled,
                batAimbot = State.batAimbotToggled,
                antiLagEnabled = State.antiLagEnabled,
                saturatedColorsEnabled = State.saturatedColorsEnabled,
                stretchedResEnabled = State.stretchedResEnabled,
                normalFOV = _G._VezyFOV or 70,
                removeAccessories = State.removeAcc,
                tryardAnimEnabled = State.tryardAnimEnabled,
                introEnabled = State.introEnabled,
                guiVisible = State.guiVisible,
                buttonPositions = btnPositions,
                autoTPEnabled = State.autoTPEnabled,
                autoTPHeight = State.autoTPHeight,
                dropType = currentDropType,

                stretchValue = State.stretchValue,
                stretchFOV = State.stretchFOV,
                espTracer = State.espTracerWanted == true,
                tracerESP = State.espTracerWanted == true,
                batAimbotZombie = State.batAimbotZombie,
                autoMoveSpeed = State.autoMoveSpeed,
                autoStealMode = State.autoStealMode,
                aimbotMode = State.aimbotMode,
                bgImage = State.bgImage,
                espEnabled = State.espEnabled,
                skyTheme = State.skyTheme,
                selectedIntroMusic = selectedIntroMusic,
                musicPlayerScale = MusicPlayer.scale,
                antiDesyncAimbotEnabled = _G.AceAntiDesyncAimbotOn == true,
                antiDieEnabled = State.antiDieEnabled,
                antiFlingShieldEnabled = State.antiFlingShieldEnabled,
                headlessEnabled = State.headlessEnabled,
                korbloxEnabled = State.korbloxEnabled,
                customSkinEnabled = State.customSkinEnabled,
                customSkinVariant = State.customSkinVariant,
                uiColorTheme = State.uiColorTheme,
                -- Soft Steal
                softStealEnabled = State.softStealEnabled,
                softStealRadius = State.softStealRadius,
                softStealSpeed = State.softStealSpeed,
            }
            pcall(saveIntroSongIdx)
            success = saveConfigWithRetry(cfg)
        end)
        if success then
            pcall(_G._VezyFlashSave, true)
        else
            pcall(_G._VezyFlashSave, false)
            warn("[7UP duels] Config save FAILED!")
        end
        return success
    end

    loadConfig = function(importedRaw)
        local raw = importedRaw
        local usedBackup = false
        if not raw and _isfile(CONFIG_FILE) then raw = _readfile(CONFIG_FILE) end
        if not raw or raw == "" then
            if _isfile(CONFIG_BACKUP) then
                raw = _readfile(CONFIG_BACKUP)
                usedBackup = true
                if raw and raw ~= "" then print("[7UP duels] Loaded config from backup") end
            end
        end
        if not raw or raw == "" then
            print("[7UP duels] No valid config file found, using defaults")
            return false
        end
        local ok, decErr = pcall(HttpService.JSONDecode, HttpService, raw)
        if (not ok or not decErr) and not usedBackup and not importedRaw then
            warn("[7UP duels] Main config corrupt, trying backup...")
            local backupRaw = nil
            if _isfile(CONFIG_BACKUP) then backupRaw = _readfile(CONFIG_BACKUP) end
            if backupRaw and backupRaw ~= "" then
                ok, decErr = pcall(HttpService.JSONDecode, HttpService, backupRaw)
                if ok and decErr then
                    print("[7UP duels] Recovered from backup successfully")
                    pcall(function() _delfile(CONFIG_FILE) end)
                end
            end
        end
        if not ok or not decErr then
            if not usedBackup and not importedRaw then pcall(function() _delfile(CONFIG_FILE) end) end
            warn("[7UP duels] Config unrecoverable, using defaults")
            return false
        end
        if decErr.version ~= CONFIG_VERSION or decErr.theme ~= "sevenup_green" then
            warn("[7UP duels] Ignored legacy config")
            return false
        end

        local function applyNumber(key, targetVar, uiBox)
            if decErr[key] then
                targetVar = decErr[key]
                if uiBox and uiBox.Text then uiBox.Text = tostring(decErr[key]) end
            end
            return targetVar
        end

        local keepLiveSpeedValues = not importedRaw
            and not State._initialConfigSettled
            and (State._speedEditRevision or 0) > 0
        if not keepLiveSpeedValues then
            State.normalSpeed = applyNumber("normalSpeed", State.normalSpeed, normalBox)
            State.carrySpeed = applyNumber("carrySpeed", State.carrySpeed, carryBox)
            State.laggerSpeed = applyNumber("laggerSpeed", State.laggerSpeed, laggerBox)
            State.laggerCarrySpeed = applyNumber("laggerCarrySpeed", State.laggerCarrySpeed, laggerCarryBox)
            State._prevCarry = State.carrySpeed
        end
        Steal.StealRadius = applyNumber("stealRadius", Steal.StealRadius, stealRadBox)
        if decErr.autoStealEnabled ~= nil then
            Steal.AutoStealEnabled = decErr.autoStealEnabled
            if autoGrabModule then autoGrabModule.setEnabled(Steal.AutoStealEnabled) end
            if toggleSetters["autoSteal"] then pcall(toggleSetters["autoSteal"], Steal.AutoStealEnabled) end
        end
        if decErr.stealRadii and type(decErr.stealRadii) == "table" and autoGrabModule then
            local radii = autoGrabModule.getRadii()
            if radii then
                if decErr.stealRadii.Normal ~= nil then
                    radii.Normal = tonumber(decErr.stealRadii.Normal) or radii.Normal or 60
                end
                if decErr.stealRadii.Semi ~= nil then
                    radii.Semi = tonumber(decErr.stealRadii.Semi) or radii.Semi or 10
                end
            end
        end
        if decErr.selectedStealMode then
            local mode = decErr.selectedStealMode
            if mode~="Normal" and mode~="Semi" then mode="Normal" end
            if autoGrabModule then autoGrabModule.setMode(mode) end
            local radii = autoGrabModule and autoGrabModule.getRadii() or {Normal=60, Semi=10}
            Steal.StealRadius = radii[mode] or Steal.StealRadius
            if autoGrabModule then autoGrabModule.setRadius(Steal.StealRadius) end
            if stealRadBox then stealRadBox.Text = tostring(Steal.StealRadius) end
            if _G._K7StealModeSetUI then pcall(_G._K7StealModeSetUI, mode) end
        end
        if decErr.uiScale and uiScaleObj then
            uiScaleObj.Scale = math.clamp(decErr.uiScale,0.5,1.5)
            if uiScaleBox then uiScaleBox.Text = tostring(uiScaleObj.Scale) end
        end
        if decErr.buttonScale ~= nil then
            local loadedButtonScale=applyStackButtonScale(decErr.buttonScale)
            if buttonScaleBox then buttonScaleBox.Text=string.format("%.1f",loadedButtonScale) end
        end
        if decErr.mobileButtonShape == "Can" or decErr.mobileButtonShape == "Circle" or decErr.mobileButtonShape == "Square" then
            applyMobileButtonShape(decErr.mobileButtonShape)
            if _G._K7RefreshMobileButtonShape then pcall(_G._K7RefreshMobileButtonShape) end
        end
        if decErr.autoGrabScale ~= nil and autoGrabModule then
            autoGrabModule.setScale(decErr.autoGrabScale)
        end
        if decErr.normalFOV then
            _G._VezyFOV = decErr.normalFOV
            pcall(function() workspace.CurrentCamera.FieldOfView = _G._VezyFOV end)
        end
        if decErr.autoTPEnabled ~= nil then State.autoTPEnabled = decErr.autoTPEnabled end
            if decErr.autoTPHeight then
                State.autoTPHeight = decErr.autoTPHeight
                if autoTPHeightBox then autoTPHeightBox.Text = tostring(State.autoTPHeight) end
            end

        if decErr.dropType then
            currentDropType = DROP_TYPES.JUMP
            currentDropType = DROP_TYPES.JUMP
        end

        if decErr.uiColorTheme == "Red" or decErr.uiColorTheme == "Green" then
            State.uiColorTheme = decErr.uiColorTheme
            _G._K7ThemeMode = State.uiColorTheme
        end
        local loadedSkinVariant = tonumber(decErr.customSkinVariant)
        if loadedSkinVariant == 1 or loadedSkinVariant == 2 then
            State.customSkinVariant = loadedSkinVariant
            syncCustomSkinVariant(loadedSkinVariant)
        end
        if decErr.bgImage and decErr.version == CONFIG_VERSION then
            State.bgImage = decErr.bgImage
            changeDuelScriptBackground(State.bgImage)
        else
            print("[7UP duels] Config version mismatch — using default background")
        end

        local bools = {
            stackButtonsHidden="stackButtonsHidden", stackButtonsLocked="stackButtonsLocked",
            infJump="infJumpEnabled", antiRagdoll="antiRagdollEnabled",
            medusaCounter="medusaCounterEnabled", batCounter="batCounterEnabled",
            autoSwing="autoSwingEnabled",
            batAimbot="batAimbotToggled", antiLagEnabled="antiLagEnabled",
            saturatedColorsEnabled="saturatedColorsEnabled",
            stretchedResEnabled="stretchedResEnabled",
            removeAccessories="removeAcc", tryardAnimEnabled="tryardAnimEnabled",
            introEnabled="introEnabled", guiVisible="guiVisible",
            speedToggled="speedToggled", autoTPEnabled="autoTPEnabled",

            espTracer="espTracer",
            batAimbotZombie="batAimbotZombie",
            headlessEnabled="headlessEnabled",
            korbloxEnabled="korbloxEnabled",
            customSkinEnabled="customSkinEnabled",
            -- Soft Steal
            softStealEnabled="softStealEnabled",
        }
        for cfgKey, stateKey in pairs(bools) do
            if decErr[cfgKey] ~= nil then State[stateKey] = decErr[cfgKey] end
        end
        if decErr.espTracer ~= nil then
            State.espTracer = decErr.espTracer == true
        elseif decErr.tracerESP ~= nil then
            State.espTracer = decErr.tracerESP == true
        end
        State.espTracerWanted = State.espTracer
        if decErr.antiRagdollVersion == "V1" or decErr.antiRagdollVersion == "V2" then
            State.antiRagdollVersion = decErr.antiRagdollVersion
            if _G._K7RefreshRagdollVersionButtons then pcall(_G._K7RefreshRagdollVersionButtons) end
        end

        if decErr.stretchValue then State.stretchValue = decErr.stretchValue end
        if decErr.stretchFOV then State.stretchFOV = decErr.stretchFOV end
        if decErr.autoMoveSpeed then State.autoMoveSpeed = decErr.autoMoveSpeed end
        if decErr.autoStealMode then State.autoStealMode = decErr.autoStealMode end
        if decErr.aimbotMode == "old" or decErr.aimbotMode == "new" then State.aimbotMode = decErr.aimbotMode end
        if decErr.laggerMode ~= nil then State.laggerMode = decErr.laggerMode end
        local keyMap = {
            speedKey="speed",
            guiHideKey="guiHide", dropKey="drop", laggerKey="lagger",
            tpDownKey="tpDown", aimbotKey="aimbot",
            autoLeftKey="autoLeft", autoRightKey="autoRight",
            antiDesyncKey="antiDesync",
        }
        for cfgKey, stateKey in pairs(keyMap) do
            if decErr[cfgKey] then
                local kc = Enum.KeyCode[decErr[cfgKey]]
                if kc then
                    Keys[stateKey] = kc
                    if keybindBtnRefs[stateKey] then keybindBtnRefs[stateKey].Text = getKeyDisplayName(kc) end
                end
            end
        end

        mainOuter.Visible = State.guiVisible
        if _G.GreenDuelsQAHide then pcall(_G.GreenDuelsQAHide, not State.guiVisible) end
        if not _G._K7IntroHidingUI then
            for _, wrapper in pairs(stackWrappers) do wrapper.Visible = not State.stackButtonsHidden end
        end
        if hideButtonsSetter then hideButtonsSetter(State.stackButtonsHidden) end
        if lockButtonsSetter then lockButtonsSetter(State.stackButtonsLocked) end

        if State.laggerMode == 0 then
            if carryBox then carryBox.Text = tostring(State.carrySpeed) end
        elseif State.laggerMode == 1 then
            if carryBox then carryBox.Text = tostring(State.carrySpeed) end
        elseif State.laggerMode == 2 then
            if carryBox then carryBox.Text = tostring(State.carrySpeed) end
        end
        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
        if stackBtnRefs.lagger then stackBtnRefs.lagger.setOn(State.laggerMode == 1) end
        if stackBtnRefs.laggerCarry then stackBtnRefs.laggerCarry.setOn(State.laggerMode == 2) end
        if stackBtnRefs.aimbot then
            stackBtnRefs.aimbot.setOn(State.batAimbotToggled or State.batAimbotZombie)
            if stackBtnRefs.aimbot.setLabel then
                stackBtnRefs.aimbot.setLabel(State.aimbotMode=="new" and "AIMBOT\nNEW" or "AIMBOT\nOLD")
            end
        end
        if stackBtnRefs.autoCarry then stackBtnRefs.autoCarry.setOn(State.softStealEnabled == true) end

        if decErr.espEnabled ~= nil then
            State.espEnabled = decErr.espEnabled
            BoxedESPOptions.box = State.espEnabled
            if State.espEnabled then startPlayerESP() else stopPlayerESP() end
            refreshBoxedESP()
            if toggleSetters["esp"] then pcall(toggleSetters["esp"], State.espEnabled) end
        end
        if decErr.skyTheme and decErr.skyTheme ~= "" then
            State.skyTheme = decErr.skyTheme; skyTheme = State.skyTheme
            pcall(applyCustomSky, State.skyTheme)
        end
        if decErr.antiDieEnabled ~= nil then
            State.antiDieEnabled = decErr.antiDieEnabled
            if State.antiDieEnabled then
                task.delay(1.0, function() pcall(startAntiDie) end)
            end
            if toggleSetters["antiDie"] then pcall(toggleSetters["antiDie"], State.antiDieEnabled) end
        end
        if decErr.antiFlingShieldEnabled ~= nil then
            State.antiFlingShieldEnabled = decErr.antiFlingShieldEnabled == true
            if State.antiFlingShieldEnabled then
                task.delay(1.0, function() pcall(startAntiFlingShield) end)
            else
                pcall(stopAntiFlingShield)
            end
            if toggleSetters["antiFlingShield"] then pcall(toggleSetters["antiFlingShield"], State.antiFlingShieldEnabled) end
        end
        if decErr.safeMode ~= nil then
            antiKickEnabled = decErr.safeMode == true
            if toggleSetters["safeMode"] then pcall(toggleSetters["safeMode"], antiKickEnabled) end
        end
        if decErr.normalAimbotSpeed then AIMBOT_SPEED = decErr.normalAimbotSpeed end
        if decErr.laggerAimbotSpeed then LAGGER_AIMBOT_SPEED = decErr.laggerAimbotSpeed end
        if _G.AceRefreshAimbotSpeedBoxes then pcall(_G.AceRefreshAimbotSpeedBoxes) end
        if decErr.selectedAnimationPack and type(decErr.selectedAnimationPack) == "string" then
            selectedAnimationPack = decErr.selectedAnimationPack
            _G._K7SelectedAnimationPack = selectedAnimationPack
            State.tryardAnimEnabled = selectedAnimationPack ~= "OFF"
            if _G._K7AnimPackRefreshRow then pcall(_G._K7AnimPackRefreshRow) end
            if selectedAnimationPack ~= "OFF" then
                task.delay(1, function()
                    local pack = _G._K7SelectedAnimationPack or selectedAnimationPack
                    pcall(function() applyAnimationPack(pack) end)
                end)
            end
        end
        if decErr.selectedIntroMusic and type(decErr.selectedIntroMusic) == "number" then
            if decErr.selectedIntroMusic >= 1 and decErr.selectedIntroMusic <= #INTRO_MUSIC_OPTIONS then
                local fromFile = false
                pcall(function()
                    if _isfile and _isfile(INTRO_SONG_FILE) then
                        local raw = _readfile(INTRO_SONG_FILE)
                        local n = tonumber(tostring(raw or ""):match("%d+"))
                        if n and n >= 1 and n <= #INTRO_MUSIC_OPTIONS then
                            selectedIntroMusic = n
                            fromFile = true
                        end
                    end
                end)
                if not fromFile then
                    selectedIntroMusic = decErr.selectedIntroMusic
                    saveIntroSongIdx()
                end
            end
        end
        if decErr.musicPlayerScale and type(decErr.musicPlayerScale) == "number" then
            MusicPlayer.scale = math.clamp(decErr.musicPlayerScale, 0.5, 1.4)
        end
        if _G._K7IntroValLbl and _G._K7IntroValLbl.Parent then
            pcall(function() _G._K7IntroValLbl.Text = getIntroSongName() end)
        end
        if decErr.introEnabled ~= nil then
            State.introEnabled = decErr.introEnabled == true
        end
        _introEnabled = State.introEnabled ~= false
        if toggleSetters["introEnabled"] then pcall(toggleSetters["introEnabled"], State.introEnabled ~= false) end
        if decErr.antiDesyncAimbotEnabled == true then
            task.delay(1.5, function() pcall(function() _G.AceStartAntiDesyncAimbot() end) end)
        end

        -- Soft Steal config loading
        if decErr.softStealEnabled ~= nil then
            State.softStealEnabled = decErr.softStealEnabled
            if State.softStealEnabled and autoGrabModule and autoGrabModule.startSoftStealScanner then
                autoGrabModule.startSoftStealScanner()
            elseif not State.softStealEnabled and autoGrabModule and autoGrabModule.stopSoftStealScanner then
                autoGrabModule.stopSoftStealScanner()
            end
            if toggleSetters["softSteal"] then pcall(toggleSetters["softSteal"], State.softStealEnabled) end
        end
        if decErr.softStealSpeed ~= nil and type(decErr.softStealSpeed)=="number" then
            State.softStealSpeed = decErr.softStealSpeed
            if softStealSpeedBox then softStealSpeedBox.Text = tostring(State.softStealSpeed) end
        end
        if decErr.softStealRadius ~= nil and type(decErr.softStealRadius)=="number" then
            State.softStealRadius = math.clamp(decErr.softStealRadius, 1, 200)
            if softStealRadiusBox then softStealRadiusBox.Text = tostring(State.softStealRadius) end
        end

        if State.antiLagEnabled then enableAntiLag() else disableAntiLag() end
        if State.stretchedResEnabled then enableStretchRez() else disableStretchRez() end
        if State.removeAcc then if _G._removeAccStart then _G._removeAccStart() end else if _G._removeAccStop then _G._removeAccStop() end end
        if State.tryardAnimEnabled then startTryardAnim() end
        if State.aimbotMode=="new" then
            if State.batAimbotToggled then State.batAimbotToggled=false end
        elseif State.batAimbotZombie then
            State.batAimbotZombie = false
        end
        if State.batAimbotToggled then startBatAimbot() else stopBatAimbot() end
        if _G._K7SyncAimbotModeBox then pcall(_G._K7SyncAimbotModeBox) end
        task.spawn(function()
            task.wait(0.35)
            if State.batCounterEnabled then
                pcall(stopBatCounter)
                pcall(startBatCounter)
            else
                pcall(stopBatCounter)
            end
            if State.medusaCounterEnabled then
                pcall(stopMedusaCounter)
                pcall(function() setupMedusaCounter(LP.Character) end)
            else
                pcall(stopMedusaCounter)
            end
            if State.antiRagdollEnabled then
                pcall(stopAntiRagdollNew)
                pcall(startAntiRagdollNew)
            else
                pcall(stopAntiRagdollNew)
            end
            if State.antiLagEnabled then
                pcall(disableAntiLag)
                pcall(enableAntiLag)
            else
                pcall(disableAntiLag)
            end
            if State.espTracerWanted then pcall(startTracerESP) end

            if State.batAimbotZombie and State.aimbotMode=="new" then pcall(startZombieBatAimbot) end
            if State.stretchedResEnabled then pcall(enableStretchRez) end
            if State.saturatedColorsEnabled then
                pcall(enableSaturatedColors)
            else
                pcall(clearSaturatedColors)
            end
            if toggleSetters["autoSwing"] then pcall(toggleSetters["autoSwing"], State.autoSwingEnabled == true) end
            if toggleSetters["batCounter"] then pcall(toggleSetters["batCounter"], State.batCounterEnabled == true) end
            if toggleSetters["medusaCounter"] then pcall(toggleSetters["medusaCounter"], State.medusaCounterEnabled == true) end
            if toggleSetters["antiRagdoll"] then pcall(toggleSetters["antiRagdoll"], State.antiRagdollEnabled == true) end
            if toggleSetters["safeMode"] then pcall(toggleSetters["safeMode"], antiKickEnabled == true) end
            if toggleSetters["infJump"] then pcall(toggleSetters["infJump"], State.infJumpEnabled == true) end
            if toggleSetters["antiLag"] then pcall(toggleSetters["antiLag"], State.antiLagEnabled == true) end
            if toggleSetters["saturatedColors"] then pcall(toggleSetters["saturatedColors"], State.saturatedColorsEnabled == true) end
            if State.headlessEnabled or State.korbloxEnabled or State.customSkinEnabled
                or CustomSkinSnapshots[LP.Character] then
                pcall(applyCharterToChar, LP.Character)
            end
            if toggleSetters["headless"] then pcall(toggleSetters["headless"], State.headlessEnabled) end
            if toggleSetters["korblox"] then pcall(toggleSetters["korblox"], State.korbloxEnabled) end
            if toggleSetters["customSkin"] then pcall(toggleSetters["customSkin"], State.customSkinEnabled) end
        end)
        if State.antiRagdollEnabled then startAntiRagdollNew() else stopAntiRagdollNew() end
        if State.autoTPEnabled then startAutoTP() else stopAutoTP() end
        if autoGrabModule then
            autoGrabModule.setRadius(Steal.StealRadius)
            autoGrabModule.setEnabled(Steal.AutoStealEnabled)
        end

        for key, setter in pairs(toggleSetters) do
            local stateValue = nil
            if key=="infJump" then stateValue=State.infJumpEnabled
            elseif key=="antiRagdoll" then stateValue=State.antiRagdollEnabled
            elseif key=="medusaCounter" then stateValue=State.medusaCounterEnabled
            elseif key=="batCounter" then stateValue=State.batCounterEnabled
            elseif key=="autoSwing" then stateValue=State.autoSwingEnabled
            elseif key=="antiLag" then stateValue=State.antiLagEnabled
            elseif key=="stretchedRes" then stateValue=State.stretchedResEnabled
            elseif key=="removeAcc" then stateValue=State.removeAcc
            elseif key=="tryardAnim" then stateValue=State.tryardAnimEnabled
            elseif key=="hideButtons" then stateValue=State.stackButtonsHidden
            elseif key=="lockButtons" then stateValue=State.stackButtonsLocked
            elseif key=="autoTP" then stateValue=State.autoTPEnabled
            elseif key=="carryMode" then stateValue=State.speedToggled
            elseif key=="espTracer" then stateValue=State.espTracerWanted == true
            elseif key=="laggerMode" then stateValue=State.laggerMode~=0
            elseif key=="autoSteal" then stateValue=Steal.AutoStealEnabled

            elseif key=="antiDesync" then stateValue=_G.AceAntiDesyncAimbotOn == true
            elseif key=="safeMode" then stateValue=antiKickEnabled == true
            elseif key=="headless" then stateValue=State.headlessEnabled
            elseif key=="korblox" then stateValue=State.korbloxEnabled
            elseif key=="customSkin" then stateValue=State.customSkinEnabled
            elseif key=="softSteal" then stateValue=State.softStealEnabled
            elseif key=="antiDie" then stateValue=State.antiDieEnabled
            elseif key=="antiFlingShield" then stateValue=State.antiFlingShieldEnabled
            end
            if stateValue ~= nil then pcall(setter, stateValue) end
        end
        if toggleSetters["espTracer"] then
            pcall(toggleSetters["espTracer"], State.espTracerWanted == true)
            task.defer(function()
                if toggleSetters["espTracer"] then
                    pcall(toggleSetters["espTracer"], State.espTracerWanted == true)
                end
            end)
        end

        refreshAllKeybindButtons()

        local function applyPositions(positions)
            if type(positions) ~= "table" then return end
            for key, posData in pairs(positions) do
                local wrapper = stackWrappers[key]
                if wrapper and type(posData) == "table" and posData.X ~= nil and posData.Y ~= nil then
                    local xs = (posData.XS ~= nil) and posData.XS or 0
                    local ys = (posData.YS ~= nil) and posData.YS or 0
                    wrapper.Position = UDim2.new(xs, posData.X, ys, posData.Y)
                end
            end
        end
        if decErr.buttonPositions and type(decErr.buttonPositions) == "table" then
            applyPositions(decErr.buttonPositions)
            task.delay(1.5, function() applyPositions(decErr.buttonPositions) end)
            task.delay(3.0, function() applyPositions(decErr.buttonPositions) end)
        end
        pcall(loadStackPositionsNow)
        task.delay(1.5, function() pcall(loadStackPositionsNow) end)
        task.delay(3.5, function() pcall(loadStackPositionsNow) end)


        print("[7UP duels] Config loaded successfully")
        return true
    end

    local _saveToken = 0
    requestSave = function()
        _saveToken = _saveToken + 1
        local myToken = _saveToken
        task.spawn(function()
            -- short debounce so rapid edits coalesce to latest values
            task.wait(0.12)
            if myToken ~= _saveToken then return end
            -- snapshot current speeds right before write (latest wins)
            local ok = saveConfig()
            if not ok then
                task.wait(0.15)
                if myToken == _saveToken then
                    ok = saveConfig()
                end
            end
            if ok then if _G._VezyFlashSave then _G._VezyFlashSave(true) end
            else if _G._VezyFlashSave then _G._VezyFlashSave(false) end end
        end)
    end
    _G._K7RequestSave = requestSave

    -- bounded force instead of math.huge: accelerates smoothly so the
    -- server sees a ramp, not an instant snap (kills the lagback)
    local LV_MAX_FORCE = 2200
    local LV_FREE_FORCE = 500

    -- ============================================================
    -- HELPER FUNCTIONS (unchanged)
    -- ============================================================
    local _aimbotTarget=nil
    local function findBat()
        local char=LP.Character; if not char then return nil end
        for _,tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end
        local bp=LP:FindFirstChild("Backpack"); if bp then for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end end
        return nil
    end
    local function getClosestTarget()
        local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not root then return nil end
        local closest,minDist=nil,math.huge
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                local tRoot=plr.Character:FindFirstChild("HumanoidRootPart"); local hum=plr.Character:FindFirstChildOfClass("Humanoid")
                if tRoot and hum and hum.Health>0 then
                    local dist=(tRoot.Position-root.Position).Magnitude
                    if dist<minDist then minDist=dist; closest=tRoot end
                end
            end
        end
        return closest
    end
    startBatAimbot = function()
        if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
            _G.AceSafeModeForceStop("SAFE MODE LOCK")
            return
        end
        if Conns.aimbot then Conns.aimbot:Disconnect() end
        local hum0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum0 then hum0.AutoRotate=false end
        Conns.aimbot = RunService.RenderStepped:Connect(function()
            if not State.batAimbotToggled then return end
            local char=LP.Character; if not char then return end
            local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
            local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            if not char:FindFirstChildOfClass("Tool") then local bat=findBat(); if bat then pcall(function() hum:EquipTool(bat) end) end end
            local target=getClosestTarget(); if not target then return end
            _aimbotTarget=target
            local targetVel=target.AssemblyLinearVelocity
            local myPos=root.Position; local targetPos=target.Position
            local predictPos=targetPos+targetVel*0.14; predictPos=predictPos+target.CFrame.LookVector*0.3
            local direction=predictPos-myPos; local flatDir=Vector3.new(direction.X,0,direction.Z).Unit
            local chaseSpeed = _G.AceGetNormalAimbotSpeed and _G.AceGetNormalAimbotSpeed() or 50; local desiredHeight=targetPos.Y+3.7
            local yVel=(desiredHeight-myPos.Y)*19.5+targetVel.Y*0.8
            if hum.FloorMaterial~=Enum.Material.Air then yVel=math.max(yVel,13) end
            yVel=math.clamp(yVel,-70,110)
            local desiredVel=Vector3.new(flatDir.X*chaseSpeed,yVel,flatDir.Z*chaseSpeed)
            root.AssemblyLinearVelocity=root.AssemblyLinearVelocity:Lerp(desiredVel,0.8)
            local speed3=targetVel.Magnitude
            local predictTime=math.clamp(speed3/150,0.05,0.2)
            local predictedPos=targetPos+targetVel*predictTime
            local toPredict=predictedPos-myPos
            if toPredict.Magnitude>0.1 then
                local goalCF=CFrame.lookAt(myPos,predictedPos)
                local diffCF=root.CFrame:Inverse()*goalCF
                local rx,ry,rz=diffCF:ToEulerAnglesXYZ()
                rx=math.clamp(rx,-2.5,2.5); ry=math.clamp(ry,-2.5,2.5); rz=math.clamp(rz,-2.5,2.5)
                root.AssemblyAngularVelocity=root.CFrame:VectorToWorldSpace(Vector3.new(rx*42,ry*42,rz*42))
            end
        end)
    end
    stopBatAimbot = function()
        if Conns.aimbot then Conns.aimbot:Disconnect(); Conns.aimbot=nil end
        _aimbotTarget=nil
        local c=LP.Character; local root=c and c:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
        local hum2=c and c:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2.AutoRotate=true end
        State.hittingCooldown=false
    end

    local BAT_COUNTER_SLAP_LIST={"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
    local function findBatForCounter()
        local c=LP.Character; if not c then return nil end
        local bp=LP:FindFirstChildOfClass("Backpack")
        for _,name in ipairs(BAT_COUNTER_SLAP_LIST) do
            local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
            if t then return t end
        end
        for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
        if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
        return nil
    end
    local function swingBatForCounter(bat,char)
        local hum2=char:FindFirstChildOfClass("Humanoid")
        if bat.Parent~=char then if hum2 then pcall(function() hum2:EquipTool(bat) end) end; task.wait(0.05) end
        local remote=bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer() end); task.wait(0.15); pcall(function() remote:FireServer() end)
        else pcall(function() bat:Activate() end); task.wait(0.15); pcall(function() bat:Activate() end) end
    end
    startBatCounter = function()
        if Conns.batCounter then return end
        Conns.batCounter = RunService.Heartbeat:Connect(function()
            if not State.batCounterEnabled or State.batCounterDebounce then return end
            local char=LP.Character; if not char then return end
            local hum2=char:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
            local st=hum2:GetState()
            local isRagdolled = st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown
            if isRagdolled then
                State.batCounterDebounce=true
                task.spawn(function()
                    local bat=findBatForCounter()
                    if bat then swingBatForCounter(bat,char) end
                    task.wait(0.5); State.batCounterDebounce=false
                end)
            end
        end)
    end
    stopBatCounter = function()
        if Conns.batCounter then Conns.batCounter:Disconnect(); Conns.batCounter=nil end
        State.batCounterDebounce=false
    end

    local MEDUSA_COOLDOWN=0.5
    local function findMedusa()
        local c=LP.Character; if not c then return nil end
        for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end
        local bp=LP:FindFirstChildOfClass("Backpack")
        if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end
        return nil
    end
    local function useMedusaCounter()
        if State.medusaDebounce then return end; if tick()-State.medusaLastUsed<MEDUSA_COOLDOWN then return end
        local c=LP.Character; if not c then return end; State.medusaDebounce=true
        local med=findMedusa(); if not med then State.medusaDebounce=false; return end
        if med.Parent~=c then local hum2=c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:EquipTool(med) end end
        pcall(function() med:Activate() end); State.medusaLastUsed=tick(); State.medusaDebounce=false
    end
    local function onAnchorChanged(part) return part:GetPropertyChangedSignal("Anchored"):Connect(function() if part.Anchored and part.Transparency==1 then useMedusaCounter() end end) end
    setupMedusaCounter = function(char)
        stopMedusaCounter(); if not char then return end
        for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end
        table.insert(Conns.anchor,char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end))
    end
    stopMedusaCounter = function() for _,c2 in pairs(Conns.anchor) do pcall(function() c2:Disconnect() end) end; Conns.anchor={} end

    -- ============================================================
    -- ANTI-RAGDOLL CONNECTIONS (unchanged)
    -- ============================================================
    local _rtTimerActive = false
    local function getRagTimerLbl()
        local char = LP.Character; if not char then return nil end
        local head = char:FindFirstChild("Head"); if not head then return nil end
        local bb = head:FindFirstChild("SevenUpDuelsBB"); if not bb then return nil end
        return bb:FindFirstChild("RagdollTimerLbl")
    end
    local function startRagTimerGui()
        if _rtTimerActive then return end
        _rtTimerActive = true
        task.spawn(function()
            local t = 3.0
            while t >= 0.0 do
                local lbl = getRagTimerLbl()
                if lbl then
                    lbl.Text = string.format("%.1f", t)
                    lbl.TextColor3 = currentColorScheme.main
                end
                task.wait(0.1)
                t = math.round((t - 0.1) * 10) / 10
            end
            local lbl = getRagTimerLbl()
            if lbl then 
                lbl.Text = "STEAL!" 
                lbl.TextColor3 = currentColorScheme.mainLight
            end
            repeat task.wait(0.1) until (function()
                local c = LP.Character
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if not hum then return true end
                local st = hum:GetState()
                return st ~= Enum.HumanoidStateType.Physics and st ~= Enum.HumanoidStateType.Ragdoll and st ~= Enum.HumanoidStateType.FallingDown
            end)()
            local lbl2 = getRagTimerLbl()
            if lbl2 then lbl2.Text = "" end
            _rtTimerActive = false
        end)
    end
    local function startRagTimerDetection(char)
        RunService.Heartbeat:Connect(function()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                startRagTimerGui()
            end
        end)
    end

    -- ============================================================
    -- CHARACTER SETUP (unchanged, but now includes charter)
    -- ============================================================
    local function setupChar(char)
        task.wait(0.1)
        h=char:WaitForChild("Humanoid",5)
        hrp=char:WaitForChild("HumanoidRootPart",5)
        if not h or not hrp then return end

        local head=char:FindFirstChild("Head")
        if head then
            local oldSpeedBadge=head:FindFirstChild("SevenUpSpeedBadge"); if oldSpeedBadge then oldSpeedBadge:Destroy() end
            local oldBB=head:FindFirstChild("SevenUpDuelsBB"); if oldBB then oldBB:Destroy() end
            local bb=Instance.new("BillboardGui", head); bb.Name="SevenUpDuelsBB"; bb.Size=UDim2.new(0,180,0,100); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
            local list=Instance.new("UIListLayout",bb); list.FillDirection=Enum.FillDirection.Vertical; list.SortOrder=Enum.SortOrder.LayoutOrder; list.VerticalAlignment=Enum.VerticalAlignment.Center; list.Padding=UDim.new(0,2)
            local speedBillLbl=Instance.new("TextLabel",bb); speedBillLbl.Name="SpeedBillLbl"; speedBillLbl.Size=UDim2.new(1,0,0,24); speedBillLbl.BackgroundTransparency=1; speedBillLbl.Text="0.0"; speedBillLbl.TextColor3=currentColorScheme.speedText or currentColorScheme.main; speedBillLbl.Font=Enum.Font.GothamBlack; speedBillLbl.TextScaled=true; speedBillLbl.TextStrokeTransparency=0.1; speedBillLbl.TextStrokeColor3=Color3.new(0,0,0); speedBillLbl.LayoutOrder=1
            local discordLbl=Instance.new("TextLabel",bb); discordLbl.Name="discordLbl"; discordLbl.Size=UDim2.new(1,0,0,22); discordLbl.BackgroundTransparency=1; discordLbl.Text="discord.gg/7up"; discordLbl.TextColor3=currentColorScheme.discordText or currentColorScheme.subText; discordLbl.Font=Enum.Font.GothamBlack; discordLbl.TextScaled=true; discordLbl.TextStrokeTransparency=0.1; discordLbl.TextStrokeColor3=Color3.new(0,0,0); discordLbl.LayoutOrder=2
            local ragTimerLbl=Instance.new("TextLabel",bb); ragTimerLbl.Name="RagdollTimerLbl"; ragTimerLbl.Size=UDim2.new(1,0,0,30); ragTimerLbl.BackgroundTransparency=1; ragTimerLbl.Text=""; ragTimerLbl.TextColor3=currentColorScheme.main; ragTimerLbl.Font=Enum.Font.GothamBlack; ragTimerLbl.TextScaled=true; ragTimerLbl.TextStrokeTransparency=0.1; ragTimerLbl.TextStrokeColor3=Color3.new(0,0,0); ragTimerLbl.LayoutOrder=3
        end
        stopAntiRagdollNew()
        _rtTimerActive = false
        local _rtLbl = getRagTimerLbl and getRagTimerLbl()
        if _rtLbl then _rtLbl.Text = "" end
        task.spawn(function() startRagTimerDetection(char) end)
        if State.antiRagdollEnabled then task.wait(0.5); startAntiRagdollNew() end
        if State.medusaCounterEnabled then setupMedusaCounter(char) end
        if State.batAimbotToggled then stopBatAimbot(); task.wait(0.2); pcall(startBatAimbot) end
        if State.batCounterEnabled then task.wait(0.3); startBatCounter() end
        task.defer(function()
            task.wait(0.25)
            local pack = _G._K7SelectedAnimationPack or selectedAnimationPack or "OFF"
            pcall(function()
                if _K7LoadAnimPackFile then
                    local d = _K7LoadAnimPackFile()
                    if d and d ~= "" then pack = d end
                end
            end)
            if pack and pack ~= "OFF" then
                selectedAnimationPack = pack
                _G._K7SelectedAnimationPack = pack
                if _G._K7SetAnimationPack then
                    pcall(function() _G._K7SetAnimationPack(pack) end)
                elseif applyAnimationPack then
                    pcall(function() applyAnimationPack(pack) end)
                end
            elseif pack == "OFF" then
                selectedAnimationPack = "OFF"
                _G._K7SelectedAnimationPack = "OFF"
            end
            -- Apply charter
            pcall(applyCharterToChar, char)
        end)
    end
    LP.CharacterAdded:Connect(setupChar)
    if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

    -- ============================================================
    -- RUNTIME LOOPS (updated with Soft Steal integration)
    -- ============================================================
    RunService.Stepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end end
    end)

    local function getActiveMoveSpeed()
        if State.autoLeftEnabled or State.autoRightEnabled then
            return State.normalSpeed or 60
        end
        -- Soft Steal: approach slow, then keep soft steal speed while carrying until the animal is dropped/thrown
        if State.softStealEnabled and autoGrabModule and autoGrabModule.getNearestSoftStealAnimal then
            local _, dist = autoGrabModule.getNearestSoftStealAnimal(State.softStealRadius or 10)
            local inRange = dist and dist <= (State.softStealRadius or 10)
            if inRange then
                State.softStealLatched = true
                return State.softStealSpeed or 30
            end
            if State.softStealLatched then
                if isCurrentlyCarrying() then
                    return State.softStealSpeed or 30
                else
                    State.softStealLatched = false
                end
            end
        end

        -- existing speed logic
        if State.laggerMode == 1 then return State.laggerSpeed or 10.1 end
        if State.laggerMode == 2 then return State.laggerCarrySpeed or 15 end
        if State.speedToggled then return State.carrySpeed or 30 end
        return State.normalSpeed or 60
    end

    local function activeSpeedStatus()
        if State.autoLeftEnabled or State.autoRightEnabled then
            return "NORMAL SPEED", State.normalSpeed or 60
        end
        if State.softStealEnabled and autoGrabModule and autoGrabModule.getNearestSoftStealAnimal then
            local _, dist = autoGrabModule.getNearestSoftStealAnimal(State.softStealRadius or 10)
            local inRange = dist and dist <= (State.softStealRadius or 10)
            if inRange or (State.softStealLatched and isCurrentlyCarrying()) then
                return "AUTO SWITCH CARRY", State.softStealSpeed or 30
            end
        end
        if State.laggerMode == 1 then
            return "LAGGER SPEED", State.laggerSpeed or 10.1
        end
        if State.laggerMode == 2 then
            return "LAGGER CARRY SPEED", State.laggerCarrySpeed or 15
        end
        if State.speedToggled then
            return "CARRY SPEED", State.carrySpeed or 30
        end
        return "NORMAL SPEED", State.normalSpeed or 60
    end

    local _lvBoost, _lvAtt = nil, nil
    local _lvOwnedTick = 0
    local _blockedTime = 0

    local function _lvDestroy()
        if _lvBoost and _lvBoost.Parent then pcall(function() _lvBoost:Destroy() end) end
        if _lvAtt and _lvAtt.Parent then pcall(function() _lvAtt:Destroy() end) end
        _lvBoost = nil
        _lvAtt = nil
    end

    local function noCollideCarried()
        local char = LP.Character
        if not char then return end
        for _, model in ipairs(char:GetChildren()) do
            if model:IsA("Model") then
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
        for _, name in ipairs({"Carrying","IsCarrying","Grabbed","Holding","StealHold","HasGrab"}) do
            local v = char:FindFirstChild(name)
            if v and v:IsA("ObjectValue") and v.Value and v.Value:IsA("Model") then
                for _, part in ipairs(v.Value:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end

    local function _lvSetup(hrp)
        if _lvBoost and _lvBoost.Parent == hrp then return end
        _lvDestroy()
        local att = Instance.new("Attachment")
        att.Parent = hrp
        local lv = Instance.new("LinearVelocity")
        lv.Name = "MuzanBoostLV"
        lv.Attachment0 = att
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
        lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
        lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)
        lv.MaxForce = LV_MAX_FORCE
        lv.PlaneVelocity = Vector2.zero
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.Parent = hrp
        _lvAtt = att
        _lvBoost = lv
        pcall(function() hrp:SetNetworkOwner(LP) end)
    end

    RunService.Heartbeat:Connect(function(dt)
        if not h or not hrp then return end

        local speed = getActiveMoveSpeed()
        activeSpeedValue = speed

        local moveDir = h.MoveDirection
        local moving = moveDir.Magnitude > 0.1
        local hVel = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        local wallNormalFlat = nil
        if moving then
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local filter = { LP.Character }
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then filter[#filter+1] = p.Character end
            end
            rayParams.FilterDescendantsInstances = filter
            local hit = workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), flatDir * 2.5, rayParams)
            if hit and hit.Instance and hit.Instance.CanCollide then
                local nf = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
                if nf.Magnitude > 0.7 then
                    wallNormalFlat = nf.Unit
                end
            end
        end
        local blocked = wallNormalFlat ~= nil or (moving and hVel.Magnitude < 2)

        if blocked then pcall(noCollideCarried) end

        local st = h:GetState()
        local ragdolled = st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
        local moverBlocked = ragdolled or dropActive or State._tpInProgress or State.batAimbotToggled or _G.AceAntiDesyncAimbotOn or _G.AceNormalAimbotOn
        if not moverBlocked then
            if not _lvBoost or _lvBoost.Parent ~= hrp then
                _lvSetup(hrp)
            end
            if _lvBoost then
                if not _lvBoost.Enabled then _lvBoost.Enabled = true end
                _lvOwnedTick = _lvOwnedTick + 1
                if _lvOwnedTick % 300 == 0 then
                    pcall(function() hrp:SetNetworkOwner(LP) end)
                end
                if moveDir.Magnitude > 0.1 then
                    local flat = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
                    if wallNormalFlat then
                        local wanted = flat * speed
                        local along = wanted - wallNormalFlat * wanted:Dot(wallNormalFlat)
                        if along.Magnitude < 0.5 then
                            _lvBoost.PlaneVelocity = Vector2.zero
                        else
                            _lvBoost.PlaneVelocity = Vector2.new(along.X, along.Z)
                        end
                    else
                        _lvBoost.PlaneVelocity = Vector2.new(flat.X * speed, flat.Z * speed)
                    end
                else
                    _lvBoost.PlaneVelocity = Vector2.zero
                end
                if blocked then
                    _blockedTime = _blockedTime + (dt or 0.016)
                else
                    _blockedTime = 0
                end
                if _blockedTime > 0.35 then
                    if _lvBoost.MaxForce ~= LV_FREE_FORCE then _lvBoost.MaxForce = LV_FREE_FORCE end
                elseif _lvBoost.MaxForce ~= LV_MAX_FORCE then
                    _lvBoost.MaxForce = LV_MAX_FORCE
                end
            end
        elseif _lvBoost then
            _lvBoost.PlaneVelocity = Vector2.zero
            if _lvBoost.Enabled then _lvBoost.Enabled = false end
        end

        pcall(function()
            local head2 = LP.Character and LP.Character:FindFirstChild("Head")
            if head2 then
                local bb2 = head2:FindFirstChild("SevenUpDuelsBB")
                local sl = bb2 and bb2:FindFirstChild("SpeedBillLbl")
                if sl then
                    local mode,value=activeSpeedStatus()
                    sl.Text=string.format("%s  %g",mode,value)
                    -- This runs every heartbeat, so it must use the live
                    -- palette or it will overwrite Red 7UP back to green.
                    sl.TextColor3=currentColorScheme.speedText or currentColorScheme.main
                end
            end
        end)

        -- Never cancel upward velocity during Jump Drop
        if not dropActive and not State._dropInProgress then
            if blocked and hrp.AssemblyLinearVelocity.Y > 2 and h.FloorMaterial ~= Enum.Material.Air then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)

    UIS.InputBegan:Connect(function(inp, gp)
        if UIS:GetFocusedTextBox() then return end
        local isKb = inp.UserInputType == Enum.UserInputType.Keyboard
        local isGp = tostring(inp.UserInputType):find("Gamepad") ~= nil
        if not isKb and not isGp then return end
        local kc = inp.KeyCode
        if kc == Enum.KeyCode.Unknown then return end

        if kc == Keys.aimbot then
            if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
                if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
                return
            end
            if _G.AceToggleSelectedAimbot then
                _G.AceToggleSelectedAimbot()
            elseif _G.AceStartNormalAimbot and _G.AceStopNormalAimbot then
                if _G.AceNormalAimbotOn then _G.AceStopNormalAimbot() else _G.AceStartNormalAimbot() end
            end
            if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
            requestSave()
            return
        end

        if Keys.antiDesync and kc == Keys.antiDesync then
            if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
                if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
                return
            end
            print("[7UP duels] AntiDesync key pressed:", Keys.antiDesync.Name, "on=", _G.AceAntiDesyncAimbotOn)
            if _G.AceToggleAntiDesyncAimbot then
                _G.AceToggleAntiDesyncAimbot()
            elseif _G.AceStartAntiDesyncAimbot and _G.AceStopAntiDesyncAimbot then
                if _G.AceAntiDesyncAimbotOn then _G.AceStopAntiDesyncAimbot() else _G.AceStartAntiDesyncAimbot() end
            else
                warn("[7UP duels] AntiDesync functions missing")
            end
            return
        end

        -- Keyboard + Controller both fire action keybinds
        if kc == Keys.speed then toggleSpeed()
        elseif Keys.autoLeft and kc == Keys.autoLeft then
            if State.autoLeftEnabled then stopAutoLeft() else startAutoLeft() end
        elseif Keys.autoRight and kc == Keys.autoRight then
            if State.autoRightEnabled then stopAutoRight() else startAutoRight() end
        elseif kc == Keys.drop then if not dropActive then pcall(runDrop) end
        elseif kc == Keys.lagger then toggleLaggerMode()
        elseif kc == Keys.tpDown then if runTPDown then task.spawn(runTPDown) end
        elseif kc == Keys.guiHide then
            -- allow both keyboard and controller for hide
            State.guiVisible = not State.guiVisible
            mainOuter.Visible = State.guiVisible
            if _G.GreenDuelsQAHide then pcall(_G.GreenDuelsQAHide, not State.guiVisible) end
            requestSave()
        end
    end)

    -- FOV Lock (unchanged)
    _G._VezyFOV = _G._VezyFOV or 70
    _G._VezyFOVPropConn = nil
    local function _attachFOVLock(cam)
        if not cam then return end
        if _G._VezyFOVPropConn then pcall(function() _G._VezyFOVPropConn:Disconnect() end) end
        local function fovTarget()
            return _G._VezyFOV or 70
        end
        pcall(function() cam.FieldOfView = fovTarget() end)
        _G._VezyFOVPropConn = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            local target = fovTarget()
            if cam.FieldOfView ~= target then pcall(function() cam.FieldOfView = target end) end
        end)
    end
    _attachFOVLock(workspace.CurrentCamera)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() task.wait(); _attachFOVLock(workspace.CurrentCamera) end)
    LP.CharacterAdded:Connect(function() task.wait(0.3); _attachFOVLock(workspace.CurrentCamera) end)
    RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local target = _G._VezyFOV or 70
        if cam.FieldOfView ~= target then pcall(function() cam.FieldOfView = target end) end
    end)

    -- ============================================================
    -- INIT: CONFIG LOAD
    -- ============================================================
    loadPresetsFile()
    local _lastPresetName = loadLastPresetName()
    if _lastPresetName and _lastPresetName~="" then
        for _,preset in ipairs(Presets) do
            if preset.name==_lastPresetName then
                pcall(function()
                    local d=preset.data or {}
                    if (State._speedEditRevision or 0) == 0 then
                        if d.normalSpeed then State.normalSpeed=d.normalSpeed; if normalBox then normalBox.Text=tostring(d.normalSpeed) end end
                        if d.carrySpeed then State.carrySpeed=d.carrySpeed; State._prevCarry=d.carrySpeed; if carryBox then carryBox.Text=tostring(d.carrySpeed) end end
                        if d.laggerSpeed then State.laggerSpeed=d.laggerSpeed; if laggerBox then laggerBox.Text=tostring(d.laggerSpeed) end end
                        if d.laggerCarrySpeed then State.laggerCarrySpeed=d.laggerCarrySpeed; if laggerCarryBox then laggerCarryBox.Text=tostring(d.laggerCarrySpeed) end end
                    end
                    if d.stealRadius then 
                        Steal.StealRadius=d.stealRadius
                        if autoGrabModule then autoGrabModule.setRadius(d.stealRadius) end
                        if stealRadBox then stealRadBox.Text=tostring(d.stealRadius) end
                    end
                    if d.autoSteal ~= nil then
                        Steal.AutoStealEnabled=d.autoSteal
                        if autoGrabModule then autoGrabModule.setEnabled(d.autoSteal) end
                        if toggleSetters["autoSteal"] then pcall(toggleSetters["autoSteal"], d.autoSteal) end
                    end
                    if d.autoTP ~= nil then State.autoTPEnabled=d.autoTP; if toggleSetters["autoTP"] then toggleSetters["autoTP"](d.autoTP) end end
                    if d.autoTPHeight then State.autoTPHeight=d.autoTPHeight; if autoTPHeightBox then autoTPHeightBox.Text=tostring(d.autoTPHeight) end end
                end)
                break
            end
        end
    end
    
    local configLoaded = false
    for i = 1, 3 do
        if loadConfig() then
            configLoaded = true
            break
        end
        task.wait(0.2)
    end
    State._initialConfigSettled = true
    
    if not configLoaded then
        print("[7UP duels] Warning: Could not load config, using defaults")
        pcall(saveConfig)
    end
    
print("[7UP HUB] Ready. Categories: Movement | Combat | Visuals | Auto Grab | Settings")
print("[7UP HUB] Target HUD loaded with 7UP branding.")

print("[7UP HUB] Visuals include Headless, Korblox, and the custom skin preview.")
print("[7UP HUB] Auto Carry Switch: switches to carry speed near an animal.")

    task.spawn(function()
        while task.wait(5) do
            pcall(requestSave)
        end
    end)
end

-- ============================================================
-- K7 INTRO VISUAL (green theme)
-- ============================================================
_G.K7RunIntro = function()
    local TS = TweenService
    if State and State.introEnabled == false then
        _introEnabled=false
        _G._K7IntroHidingUI=false
        local skippedFrame=_G._K7MainOuter
        if skippedFrame then skippedFrame.Visible=State.guiVisible~=false end
        pcall(function()
            for _,wrapper in pairs(stackWrappers or {}) do wrapper.Visible=not State.stackButtonsHidden end
            if autoGrabModule and autoGrabModule.showUI then autoGrabModule.showUI(false) end
        end)
        return
    end
    _introEnabled = true
    _G._K7IntroHidingUI = true
    local frame = _G._K7MainOuter
    if not frame then
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
        local gui = pg and (pg:FindFirstChild("SevenUpDuelsV2") or pg:WaitForChild("SevenUpDuelsV2", 3))
        if gui then frame = gui:FindFirstChild("MainOuter"); if frame then _G._K7MainOuter = frame end end
    end
    local introGuiParent = (LP and (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5))) or CoreGui
    if not introGuiParent then introGuiParent = CoreGui end
    if not introGuiParent then return end
    local origSize = (frame and frame.Size) or UDim2.new(0, 420, 0, 520)
    if frame then
        frame.Visible = false
        frame.Size = UDim2.new(0, 0, 0, 0)
    end
    pcall(function()
        if autoGrabModule and autoGrabModule.hideUI then
            autoGrabModule.hideUI()
        else
            local ag = _G._K7AutoGrabGui or (LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("AutoGrab"))
            if ag then ag.Enabled = false end
            if _G._K7AutoGrabFrame then _G._K7AutoGrabFrame.Visible = false end
        end
    end)
    pcall(function()
        for _, wrapper in pairs(stackWrappers or {}) do
            if wrapper then wrapper.Visible = false end
        end
    end)
    pcall(playIntroMusic)

    task.spawn(function()
        local introGui = Instance.new("ScreenGui")
        introGui.Name = "K7Intro"
        introGui.IgnoreGuiInset = true
        introGui.DisplayOrder = 100
        introGui.ResetOnSpawn = false
        introGui.Enabled = true
        introGui.Parent = introGuiParent

        local introActive = true
        local function finishIntro()
            if not introActive then return end
            introActive = false
            stopIntroPlayback()
            _G._K7IntroHidingUI = false
            if frame then
                frame.Visible = true
                pcall(function()
                    TS:Create(frame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = origSize}):Play()
                end)
            end
            task.spawn(function()
                task.wait(0.12)
                local showStacks = not (State and State.stackButtonsHidden)
                if showStacks then
                    local keys = {}
                    for key, wrapper in pairs(stackWrappers or {}) do
                        if wrapper then table.insert(keys, {key = key, w = wrapper}) end
                    end
                    table.sort(keys, function(a, b) return tostring(a.key) < tostring(b.key) end)
                    for i, item in ipairs(keys) do
                        local w = item.w
                        if w and w.Parent then
                            local targetSize = w.Size
                            local targetPos  = w.Position
                            w.Size = UDim2.new(0, 0, 0, 0)
                            w.Visible = true
                            pcall(function()
                                TS:Create(w, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    Size = targetSize
                                }):Play()
                            end)
                            task.wait(0.04)
                        end
                    end
                end
                pcall(loadStackPositionsNow)
                task.wait(0.08)
                pcall(function()
                    if autoGrabModule and autoGrabModule.showUI then
                        autoGrabModule.showUI(true)
                    else
                        local bar = _G._K7AutoGrabFrame
                        local ag  = _G._K7AutoGrabGui
                        if ag then ag.Enabled = true end
                        if bar then
                            local finalSize = UDim2.new(0, 580, 0, 70)
                            local finalPos  = UDim2.new(0.5, 0, 0.92, 0)
                            bar.Size = UDim2.new(0, 0, 0, 0)
                            bar.Position = UDim2.new(0.5, 0, 0.92, 21)
                            bar.Visible = true
                            TS:Create(bar, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                Size = finalSize, Position = finalPos
                            }):Play()
                        end
                    end
                end)
            end)
            task.delay(0.9, function() pcall(function() introGui:Destroy() end) end)
        end

        -- ── 7UP theme palette (green) ─────────────────────────────
        local GREEN      = Color3.fromRGB(0, 200, 80)
        local GREEN_DARK = Color3.fromRGB(0, 130, 60)
        local GREEN_SOFT = Color3.fromRGB(80, 255, 160)
        local NAVY     = Color3.fromRGB(15, 24, 66)
        local NAVY_DK  = Color3.fromRGB(7, 11, 34)
        local WHITE    = Color3.fromRGB(245, 245, 250)
        local SODA_IMG = "rbxassetid://102557909116203"  -- default reference artwork

        local darkBg = Instance.new("Frame", introGui)
        darkBg.Size = UDim2.new(1, 0, 1, 0)
        darkBg.BackgroundColor3 = NAVY_DK
        darkBg.BackgroundTransparency = 1
        darkBg.BorderSizePixel = 0
        darkBg.ZIndex = 1
        local bgGrad = Instance.new("UIGradient", darkBg)
        bgGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(36, 66, 48)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 40, 20)),
            ColorSequenceKeypoint.new(1, NAVY_DK)
        })
        bgGrad.Rotation = 90

        local wash = Instance.new("Frame", introGui)
        wash.Size = UDim2.new(1, 0, 1, 0)
        wash.BackgroundColor3 = GREEN
        wash.BackgroundTransparency = 1
        wash.BorderSizePixel = 0
        wash.ZIndex = 2

        local skipBtn = Instance.new("TextButton", introGui)
        skipBtn.Name = "SkipIntro"
        skipBtn.AnchorPoint = Vector2.new(1, 0)
        skipBtn.Position = UDim2.new(1, -22, 0, 22)
        skipBtn.Size = UDim2.new(0, 104, 0, 34)
        skipBtn.BackgroundColor3 = GREEN
        skipBtn.BackgroundTransparency = 0.1
        skipBtn.BorderSizePixel = 0
        skipBtn.Text = "SKIP INTRO"
        skipBtn.TextColor3 = WHITE
        skipBtn.TextSize = 11
        skipBtn.Font = Enum.Font.GothamBlack
        skipBtn.AutoButtonColor = false
        skipBtn.ZIndex = 80
        Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 10)
        local skipStroke = Instance.new("UIStroke", skipBtn)
        skipStroke.Color = GREEN_SOFT
        skipStroke.Thickness = 1.2
        skipStroke.Transparency = 0.15
        local skipScale=Instance.new("UIScale",skipBtn); skipScale.Scale=1
        skipBtn.MouseEnter:Connect(function()
            TS:Create(skipScale,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Scale=1.06}):Play()
            TS:Create(skipStroke,TweenInfo.new(0.12),{Transparency=0,Thickness=2}):Play()
            TS:Create(skipBtn,TweenInfo.new(0.12),{BackgroundTransparency=0}):Play()
        end)
        skipBtn.MouseLeave:Connect(function()
            TS:Create(skipScale,TweenInfo.new(0.12),{Scale=1}):Play()
            TS:Create(skipStroke,TweenInfo.new(0.12),{Transparency=0.15,Thickness=1.2}):Play()
            TS:Create(skipBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.1}):Play()
        end)
        skipBtn.MouseButton1Down:Connect(function() TS:Create(skipScale,TweenInfo.new(0.06),{Scale=0.94}):Play() end)
        skipBtn.MouseButton1Click:Connect(finishIntro)

        -- ── Centerpiece ────────────────────────────────────
        local sodaPic = Instance.new("ImageLabel", introGui)
        sodaPic.Name = "SevenUpSodaPic"
        sodaPic.AnchorPoint = Vector2.new(0.5, 0.5)
        sodaPic.Position = UDim2.new(0.5, 0, 0.36, 0)
        sodaPic.Size = UDim2.new(0, 0, 0, 0)
        sodaPic.Image = SODA_IMG
        sodaPic.ScaleType = Enum.ScaleType.Fit
        sodaPic.BackgroundColor3 = GREEN_DARK
        sodaPic.BackgroundTransparency = 0.25
        sodaPic.BorderSizePixel = 0
        sodaPic.ImageTransparency = 1
        sodaPic.Rotation = -16
        sodaPic.ZIndex = 22
        Instance.new("UICorner", sodaPic).CornerRadius = UDim.new(0, 22)
        local picStroke = Instance.new("UIStroke", sodaPic)
        picStroke.Color = GREEN
        picStroke.Thickness = 3
        picStroke.Transparency = 1

        local center = Instance.new("Frame", introGui)
        center.AnchorPoint = Vector2.new(0.5, 0.5)
        center.Position = UDim2.new(0.5, 0, 0.68, 0)
        center.Size = UDim2.new(0, 700, 0, 200)
        center.BackgroundTransparency = 1
        center.ZIndex = 40

        local lineTop = Instance.new("Frame", center)
        lineTop.AnchorPoint = Vector2.new(0.5, 0)
        lineTop.Position = UDim2.new(0.5, 0, 0, 0)
        lineTop.Size = UDim2.new(0, 0, 0, 2)
        lineTop.BackgroundColor3 = GREEN
        lineTop.BorderSizePixel = 0
        lineTop.ZIndex = 41
        lineTop.Visible = false

        local lineBot = Instance.new("Frame", center)
        lineBot.AnchorPoint = Vector2.new(0.5, 0)
        lineBot.Position = UDim2.new(0.5, 0, 0, 150)
        lineBot.Size = UDim2.new(0, 0, 0, 2)
        lineBot.BackgroundColor3 = GREEN
        lineBot.BorderSizePixel = 0
        lineBot.ZIndex = 41
        lineBot.Visible = false

        local titleShadow = Instance.new("TextLabel", center)
        titleShadow.Size = UDim2.new(1, 0, 0, 80)
        titleShadow.Position = UDim2.new(0, 4, 0, 26)
        titleShadow.BackgroundTransparency = 1
        titleShadow.Text = "7UP DUELS"
        titleShadow.TextColor3 = NAVY_DK
        titleShadow.Font = Enum.Font.GothamBlack
        titleShadow.TextSize = 72
        titleShadow.TextTransparency = 1
        titleShadow.ZIndex = 42

        local titleGreen = titleShadow:Clone()
        titleGreen.Name = "TitleGreenEcho"
        titleGreen.Position = UDim2.new(0,-7,0,22)
        titleGreen.TextColor3 = currentColorScheme.main
        titleGreen.ZIndex = 41
        titleGreen.Parent = center
        local titleBlue = titleShadow:Clone()
        titleBlue.Name = "TitleBlueEcho"
        titleBlue.Position = UDim2.new(0,7,0,22)
        titleBlue.TextColor3 = currentColorScheme.mainDark
        titleBlue.ZIndex = 41
        titleBlue.Parent = center

        local title = Instance.new("TextLabel", center)
        title.Size = UDim2.new(1, 0, 0, 80)
        title.Position = UDim2.new(0, 0, 0, 22)
        title.BackgroundTransparency = 1
        title.Text = "7UP DUELS"
        title.TextColor3 = WHITE
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 72
        title.TextTransparency = 1
        title.TextStrokeTransparency = 0.65
        title.TextStrokeColor3 = currentColorScheme.main
        title.ZIndex = 43
        local titleGradient=Instance.new("UIGradient",title)
        titleGradient.Color=ColorSequence.new(Color3.fromRGB(255,255,255),Color3.fromRGB(255,255,255))
        TweenService:Create(titleGradient,TweenInfo.new(2.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Offset=Vector2.new(1,0)}):Play()

        -- Cinematic web field
        local introWeb = Instance.new("Frame",introGui)
        introWeb.Size=UDim2.new(1,0,1,0); introWeb.BackgroundTransparency=1; introWeb.BorderSizePixel=0; introWeb.ZIndex=8
        introWeb.Visible=false
        local introStrands={}
        for strandIndex=0,5 do
            local strand=Instance.new("Frame",introWeb)
            strand.AnchorPoint=Vector2.new(0.5,0.5); strand.Position=UDim2.new(0.5,0,0.36,0)
            strand.Size=UDim2.new(0.92,0,0,1); strand.Rotation=strandIndex*30
            strand.BackgroundColor3=strandIndex%2==0 and GREEN_SOFT or Color3.fromRGB(55,200,150)
            strand.BackgroundTransparency=1; strand.BorderSizePixel=0; strand.ZIndex=8
            local strandFade=Instance.new("UIGradient",strand)
            strandFade.Transparency=NumberSequence.new({
                NumberSequenceKeypoint.new(0,1),
                NumberSequenceKeypoint.new(0.18,0.55),
                NumberSequenceKeypoint.new(0.48,0.15),
                NumberSequenceKeypoint.new(0.52,0.15),
                NumberSequenceKeypoint.new(0.82,0.55),
                NumberSequenceKeypoint.new(1,1)
            })
            introStrands[#introStrands+1]=strand
        end

        local webRingLayer=Instance.new("Frame",introGui)
        webRingLayer.AnchorPoint=Vector2.new(0.5,0.5); webRingLayer.Position=UDim2.new(0.5,0,0.36,0)
        webRingLayer.Size=UDim2.new(0,440,0,440); webRingLayer.BackgroundTransparency=1
        webRingLayer.BorderSizePixel=0; webRingLayer.ZIndex=10
        webRingLayer.Visible=false
        local webRingScale=Instance.new("UIScale",webRingLayer); webRingScale.Scale=0.68
        local introRingSegments={}
        local function introRingLine(x1,y1,x2,y2,color)
            local dx,dy=x2-x1,y2-y1
            local segment=Instance.new("Frame",webRingLayer)
            segment.AnchorPoint=Vector2.new(0.5,0.5); segment.Position=UDim2.new(0.5,(x1+x2)/2,0.5,(y1+y2)/2)
            segment.Size=UDim2.new(0,math.sqrt(dx*dx+dy*dy),0,1)
            segment.Rotation=math.deg(math.atan2(dy,dx)); segment.BackgroundColor3=color
            segment.BackgroundTransparency=1; segment.BorderSizePixel=0; segment.ZIndex=10
            local fade=Instance.new("UIGradient",segment)
            fade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.8),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,0.8)})
            introRingSegments[#introRingSegments+1]=segment
        end
        for _,radius in ipairs({160,205}) do
            for pointIndex=0,17 do
                local a1=math.rad(pointIndex*20); local a2=math.rad((pointIndex+1)*20)
                introRingLine(math.cos(a1)*radius,math.sin(a1)*radius,math.cos(a2)*radius,math.sin(a2)*radius,pointIndex%2==0 and GREEN_SOFT or Color3.fromRGB(55,200,150))
            end
        end
        for spokeIndex=0,5 do
            local spokeAngle=math.rad(spokeIndex*60)
            introRingLine(math.cos(spokeAngle)*160,math.sin(spokeAngle)*160,math.cos(spokeAngle)*205,math.sin(spokeAngle)*205,WHITE)
        end
        local webCore=Instance.new("Frame",webRingLayer)
        webCore.AnchorPoint=Vector2.new(0.5,0.5); webCore.Position=UDim2.new(0.5,0,0.5,0)
        webCore.Size=UDim2.new(0,18,0,18); webCore.BackgroundColor3=GREEN; webCore.BackgroundTransparency=0.3
        webCore.BorderSizePixel=0; webCore.ZIndex=11; Instance.new("UICorner",webCore).CornerRadius=UDim.new(1,0)
        local webCoreStroke=Instance.new("UIStroke",webCore); webCoreStroke.Color=WHITE; webCoreStroke.Transparency=0.32; webCoreStroke.Thickness=1.5

        local orbit=Instance.new("Frame",introGui)
        orbit.AnchorPoint=Vector2.new(0.5,0.5); orbit.Position=UDim2.new(0.5,0,0.36,0); orbit.Size=UDim2.new(0,270,0,270)
        orbit.BackgroundTransparency=1; orbit.BorderSizePixel=0; orbit.ZIndex=20; Instance.new("UICorner",orbit).CornerRadius=UDim.new(1,0)
        orbit.Visible=false
        local orbitStroke=Instance.new("UIStroke",orbit)
        orbitStroke.Thickness=3; orbitStroke.Transparency=1; orbitStroke.Color=WHITE
        local orbitGradient=Instance.new("UIGradient",orbitStroke)
        orbitGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,GREEN),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(55,200,150)),ColorSequenceKeypoint.new(1,GREEN)})
        for nodeIndex=0,5 do
            local angle=math.rad(nodeIndex*60)
            local node=Instance.new("Frame",orbit)
            node.AnchorPoint=Vector2.new(0.5,0.5)
            node.Size=UDim2.new(0,8,0,8)
            node.Position=UDim2.new(0.5,math.cos(angle)*135,0.5,math.sin(angle)*135)
            node.BackgroundColor3=nodeIndex%2==0 and GREEN_SOFT or Color3.fromRGB(55,200,150)
            node.BackgroundTransparency=1; node.BorderSizePixel=0; node.ZIndex=24
            Instance.new("UICorner",node).CornerRadius=UDim.new(1,0)
            local nodeStroke=Instance.new("UIStroke",node)
            nodeStroke.Color=WHITE; nodeStroke.Transparency=0.5; nodeStroke.Thickness=1
        end
        local innerOrbit=Instance.new("Frame",introGui)
        innerOrbit.AnchorPoint=Vector2.new(0.5,0.5); innerOrbit.Position=UDim2.new(0.5,0,0.36,0); innerOrbit.Size=UDim2.new(0,232,0,232)
        innerOrbit.BackgroundTransparency=1; innerOrbit.BorderSizePixel=0; innerOrbit.ZIndex=21; Instance.new("UICorner",innerOrbit).CornerRadius=UDim.new(1,0)
        innerOrbit.Visible=false
        local innerOrbitStroke=Instance.new("UIStroke",innerOrbit); innerOrbitStroke.Thickness=1.5; innerOrbitStroke.Transparency=1
        local innerOrbitGradient=Instance.new("UIGradient",innerOrbitStroke)
        innerOrbitGradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(55,200,150)),ColorSequenceKeypoint.new(0.5,GREEN_SOFT),ColorSequenceKeypoint.new(1,Color3.fromRGB(55,200,150))})

        local progressTrack=Instance.new("Frame",introGui)
        progressTrack.AnchorPoint=Vector2.new(0.5,0.5); progressTrack.Position=UDim2.new(0.5,0,0.86,0); progressTrack.Size=UDim2.new(0,280,0,4)
        progressTrack.BackgroundColor3=Color3.fromRGB(52,82,62); progressTrack.BackgroundTransparency=0.25; progressTrack.BorderSizePixel=0; progressTrack.ZIndex=45
        progressTrack.Visible=false
        Instance.new("UICorner",progressTrack).CornerRadius=UDim.new(1,0)
        local progressFill=Instance.new("Frame",progressTrack)
        progressFill.Size=UDim2.new(0,0,1,0); progressFill.BackgroundColor3=WHITE; progressFill.BorderSizePixel=0; progressFill.ZIndex=46
        Instance.new("UICorner",progressFill).CornerRadius=UDim.new(1,0)
        local progressGradient=Instance.new("UIGradient",progressFill)
        progressGradient.Color=ColorSequence.new(GREEN,Color3.fromRGB(55,200,150))

        local pulse = Instance.new("Frame", introGui)
        pulse.AnchorPoint = Vector2.new(0.5, 0.5)
        pulse.Position = UDim2.new(0.5, 0, 0.36, 0)
        pulse.Size = UDim2.new(0, 200, 0, 200)
        pulse.BackgroundTransparency = 1
        pulse.BorderSizePixel = 0
        pulse.ZIndex = 9
        pulse.Visible = false
        Instance.new("UICorner", pulse).CornerRadius = UDim.new(1, 0)
        local pulseStroke = Instance.new("UIStroke", pulse)
        pulseStroke.Color = GREEN_SOFT
        pulseStroke.Thickness = 2.5
        pulseStroke.Transparency = 1

        if _G._K7RemoveUILines then pcall(_G._K7RemoveUILines,introGui) end

        TS:Create(darkBg, TweenInfo.new(0.9), {BackgroundTransparency = 0.1}):Play()
        TS:Create(wash, TweenInfo.new(1.2), {BackgroundTransparency = 0.93}):Play()
        task.wait(0.55)
        if not introActive then return end

        task.wait(0.35)
        if not introActive then return end

        TS:Create(sodaPic, TweenInfo.new(1.0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 170, 0, 280), ImageTransparency = 0, Rotation = 0
        }):Play()
        TS:Create(picStroke, TweenInfo.new(0.8), {Transparency = 0}):Play()
        TS:Create(orbitStroke,TweenInfo.new(0.6),{Transparency=0.12}):Play()
        TS:Create(innerOrbitStroke,TweenInfo.new(0.6),{Transparency=0.28}):Play()
        TS:Create(orbitGradient,TweenInfo.new(4.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=360}):Play()
        TS:Create(innerOrbitGradient,TweenInfo.new(3.1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=-360}):Play()
        TS:Create(orbit,TweenInfo.new(9,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=360}):Play()
        TS:Create(innerOrbit,TweenInfo.new(7,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=-360}):Play()
        for _,node in ipairs(orbit:GetChildren()) do
            if node:IsA("Frame") then TS:Create(node,TweenInfo.new(0.45),{BackgroundTransparency=0.04}):Play() end
        end
        TS:Create(progressFill,TweenInfo.new(4.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0)}):Play()
        for strandIndex,strand in ipairs(introStrands) do
            TS:Create(strand,TweenInfo.new(0.45+strandIndex*0.025),{BackgroundTransparency=0.66}):Play()
        end
        TS:Create(webRingScale,TweenInfo.new(0.9,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
        for segmentIndex,segment in ipairs(introRingSegments) do
            TS:Create(segment,TweenInfo.new(0.35+(segmentIndex%8)*0.025),{BackgroundTransparency=0.7}):Play()
        end
        TS:Create(webRingLayer,TweenInfo.new(13,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1),{Rotation=360}):Play()

        task.spawn(function()
            while introActive do
                pulse.Size = UDim2.new(0, 200, 0, 200)
                pulseStroke.Transparency = 0.35
                TS:Create(pulse, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 340, 0, 340)
                }):Play()
                TS:Create(pulseStroke, TweenInfo.new(0.9), {Transparency = 1}):Play()
                task.wait(0.95)
            end
        end)

        task.wait(0.5)
        if not introActive then return end

        TS:Create(lineTop, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 2)
        }):Play()
        TS:Create(lineBot, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 2)
        }):Play()
        task.wait(0.25)
        if not introActive then return end

        TS:Create(titleShadow, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = 0.55
        }):Play()
        TS:Create(titleGreen,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextTransparency=0.3}):Play()
        TS:Create(titleBlue,TweenInfo.new(0.45,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{TextTransparency=0.3}):Play()
        TS:Create(title, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        task.spawn(function()
            while introActive and title.Parent do
                titleGreen.Position=UDim2.new(0,-math.random(3,8),0,22+math.random(-2,2))
                titleBlue.Position=UDim2.new(0,math.random(3,8),0,22+math.random(-2,2))
                task.wait(0.09)
            end
        end)
        task.wait(4.4)
        if not introActive then return end

        TS:Create(darkBg, TweenInfo.new(1.0), {BackgroundTransparency = 1}):Play()
        TS:Create(wash, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
        TS:Create(sodaPic, TweenInfo.new(0.8), {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1}):Play()
        TS:Create(picStroke, TweenInfo.new(0.7), {Transparency = 1}):Play()
        TS:Create(title, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        TS:Create(titleShadow, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        TS:Create(titleGreen,TweenInfo.new(0.45),{TextTransparency=1}):Play()
        TS:Create(titleBlue,TweenInfo.new(0.45),{TextTransparency=1}):Play()
        TS:Create(orbitStroke,TweenInfo.new(0.6),{Transparency=1}):Play()
        TS:Create(innerOrbitStroke,TweenInfo.new(0.6),{Transparency=1}):Play()
        TS:Create(progressTrack,TweenInfo.new(0.6),{BackgroundTransparency=1}):Play()
        TS:Create(progressFill,TweenInfo.new(0.6),{BackgroundTransparency=1}):Play()
        for _,strand in ipairs(introStrands) do TS:Create(strand,TweenInfo.new(0.55),{BackgroundTransparency=1}):Play() end
        for _,segment in ipairs(introRingSegments) do TS:Create(segment,TweenInfo.new(0.45),{BackgroundTransparency=1}):Play() end
        TS:Create(lineTop, TweenInfo.new(0.65), {BackgroundTransparency = 1}):Play()
        TS:Create(lineBot, TweenInfo.new(0.65), {BackgroundTransparency = 1}):Play()
        TS:Create(pulseStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()

        task.wait(1.0)
        finishIntro()
    end)
end

-- ============================================================
-- 7UP SODA-OPENING INTRO (replaces the legacy web intro above)
-- ============================================================
_G.K7RunIntro = function()
    local TS = TweenService
    local introEnabled = not (State and State.introEnabled == false)
    local frame = _G._K7MainOuter
    if not frame then
        local pg = LP and (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui",5))
        local duelGui = pg and pg:FindFirstChild("SevenUpDuelsV2")
        frame = duelGui and duelGui:FindFirstChild("MainOuter")
        if frame then _G._K7MainOuter = frame end
    end

    local function restoreOwnedUI(animate)
        _G._K7IntroHidingUI = false
        if frame then
            local targetSize = UDim2.new(0,450,0,660)
            frame.Visible = not (State and State.guiVisible == false)
            if frame.Visible then
                if animate then
                    frame.Size = UDim2.new(0,0,0,0)
                    TS:Create(frame,TweenInfo.new(0.72,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=targetSize}):Play()
                else
                    frame.Size = targetSize
                end
            end
        end
        pcall(function()
            local showButtons = not (State and State.stackButtonsHidden)
            for _,wrapper in pairs(stackWrappers or {}) do
                if wrapper then wrapper.Visible = showButtons end
            end
            loadStackPositionsNow()
        end)
        pcall(function()
            if autoGrabModule and autoGrabModule.showUI then
                autoGrabModule.showUI(animate == true)
            end
        end)
    end

    if not introEnabled then
        _introEnabled = false
        restoreOwnedUI(false)
        return
    end

    _introEnabled = true
    _G._K7IntroHidingUI = true
    if frame then frame.Visible=false end
    pcall(function()
        if autoGrabModule and autoGrabModule.hideUI then autoGrabModule.hideUI() end
        for _,wrapper in pairs(stackWrappers or {}) do if wrapper then wrapper.Visible=false end end
    end)
    pcall(playIntroMusic)

    local introParent = LP and (LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui",5)) or CoreGui
    if not introParent then restoreOwnedUI(false); return end
    local stale = introParent:FindFirstChild("K7SodaOpeningIntro")
    if stale then stale:Destroy() end

    local introGui=Instance.new("ScreenGui")
    introGui.Name="K7SodaOpeningIntro"
    introGui.IgnoreGuiInset=true
    introGui.ResetOnSpawn=false
    introGui.DisplayOrder=120
    introGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    introGui.Parent=introParent

    local openSfx=Instance.new("Sound")
    openSfx.Name="SevenUpCanOpenSFX"
    openSfx.SoundId="rbxassetid://6811412838"
    openSfx.Volume=7
    openSfx.PlaybackSpeed=1
    openSfx.Looped=false
    openSfx.Parent=SoundService
    task.spawn(function()
        pcall(function() ContentProvider:PreloadAsync({openSfx}) end)
    end)

    local active=true
    local finished=false
    local function corner(obj,r)
        local c=Instance.new("UICorner",obj); c.CornerRadius=UDim.new(0,r); return c
    end
    local function tween(obj,time,style,direction,props)
        if not obj or not obj.Parent then return nil end
        local tw=TS:Create(obj,TweenInfo.new(time,style or Enum.EasingStyle.Quad,direction or Enum.EasingDirection.Out),props)
        tw:Play(); return tw
    end
    local function aliveWait(seconds)
        local elapsed=0
        while active and elapsed < seconds do elapsed = elapsed + task.wait(math.min(0.05,seconds-elapsed)) end
        return active
    end

    local root=Instance.new("Frame",introGui)
    root.Size=UDim2.fromScale(1,1)
    root.BackgroundColor3=Color3.fromRGB(1,18,9)
    root.BackgroundTransparency=1
    root.BorderSizePixel=0
    root.ZIndex=1
    root.Active=true
    local rootGradient=Instance.new("UIGradient",root)
    rootGradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,20,10)),
        ColorSequenceKeypoint.new(0.45,Color3.fromRGB(0,62,29)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,12,7))
    })
    rootGradient.Rotation=32

    local glow=Instance.new("Frame",root)
    glow.AnchorPoint=Vector2.new(0.5,0.5)
    glow.Position=UDim2.new(0.5,0,0.46,0)
    glow.Size=UDim2.new(0,640,0,640)
    glow.BackgroundColor3=Color3.fromRGB(0,220,96)
    glow.BackgroundTransparency=0.9
    glow.BorderSizePixel=0
    glow.ZIndex=2
    corner(glow,320)
    local glowGradient=Instance.new("UIGradient",glow)
    glowGradient.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.45),NumberSequenceKeypoint.new(0.58,0.8),NumberSequenceKeypoint.new(1,1)
    })

    local topCopy=Instance.new("TextLabel",root)
    topCopy.AnchorPoint=Vector2.new(0.5,0)
    topCopy.Position=UDim2.new(0.5,0,0.07,0)
    topCopy.Size=UDim2.new(0,520,0,28)
    topCopy.BackgroundTransparency=1
    topCopy.Text="CHILLED  •  CARBONATED  •  READY"
    topCopy.TextColor3=Color3.fromRGB(115,255,172)
    topCopy.TextTransparency=1
    topCopy.Font=Enum.Font.GothamBlack
    topCopy.TextSize=11
    topCopy.ZIndex=15

    local skipBtn=Instance.new("TextButton",root)
    skipBtn.AnchorPoint=Vector2.new(1,0)
    skipBtn.Position=UDim2.new(1,-20,0,20)
    skipBtn.Size=UDim2.new(0,142,0,34)
    skipBtn.BackgroundColor3=Color3.fromRGB(0,108,48)
    skipBtn.BackgroundTransparency=0.12
    skipBtn.BorderSizePixel=0
    skipBtn.Text="2× CLICK TO SKIP"
    skipBtn.TextColor3=Color3.fromRGB(255,255,255)
    skipBtn.Font=Enum.Font.GothamBlack
    skipBtn.TextSize=10
    skipBtn.AutoButtonColor=false
    skipBtn.ZIndex=80
    corner(skipBtn,17)

    local skipHint=Instance.new("TextLabel",root)
    skipHint.AnchorPoint=Vector2.new(0.5,1)
    skipHint.Position=UDim2.new(0.5,0,1,-24)
    skipHint.Size=UDim2.new(0,420,0,24)
    skipHint.BackgroundTransparency=1
    skipHint.Text="DOUBLE CLICK / DOUBLE TAP ANYWHERE TO SKIP"
    skipHint.TextColor3=Color3.fromRGB(255,255,255)
    skipHint.TextTransparency=0.08
    skipHint.TextStrokeColor3=Color3.fromRGB(0,0,0)
    skipHint.TextStrokeTransparency=0.35
    skipHint.Font=Enum.Font.GothamBlack
    skipHint.TextSize=11
    skipHint.ZIndex=81

    local canAssembly=Instance.new("Frame",root)
    canAssembly.Name="OpeningCan"
    canAssembly.AnchorPoint=Vector2.new(0.5,0.5)
    canAssembly.Position=UDim2.new(0.5,0,0.46,220)
    canAssembly.Size=UDim2.new(0,220,0,420)
    canAssembly.BackgroundTransparency=1
    canAssembly.BorderSizePixel=0
    canAssembly.Rotation=10
    canAssembly.ZIndex=10
    local canScale=Instance.new("UIScale",canAssembly)
    local viewport=(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(900,700)
    local fit=math.clamp(math.min(viewport.X/650,viewport.Y/760),0.64,1)
    canScale.Scale=fit*0.58

    local canShadow=Instance.new("Frame",canAssembly)
    canShadow.Size=UDim2.new(0,188,0,326)
    canShadow.Position=UDim2.new(0,22,0,73)
    canShadow.BackgroundColor3=Color3.fromRGB(0,0,0)
    canShadow.BackgroundTransparency=0.55
    canShadow.BorderSizePixel=0
    canShadow.ZIndex=2
    corner(canShadow,46)

    local canBody=Instance.new("Frame",canAssembly)
    canBody.Name="CanBody"
    canBody.Size=UDim2.new(0,180,0,324)
    canBody.Position=UDim2.new(0,20,0,62)
    canBody.BackgroundColor3=Color3.fromRGB(0,118,51)
    canBody.BorderSizePixel=0
    canBody.ClipsDescendants=true
    canBody.ZIndex=5
    corner(canBody,42)
    local bodyGradient=Instance.new("UIGradient",canBody)
    bodyGradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,54,26)),
        ColorSequenceKeypoint.new(0.2,Color3.fromRGB(0,204,86)),
        ColorSequenceKeypoint.new(0.52,Color3.fromRGB(0,120,50)),
        ColorSequenceKeypoint.new(0.84,Color3.fromRGB(0,65,31)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,28,15))
    })
    bodyGradient.Rotation=6

    local redDisc=Instance.new("Frame",canBody)
    redDisc.Size=UDim2.new(0,76,0,76)
    redDisc.Position=UDim2.new(0,23,0,122)
    redDisc.BackgroundColor3=Color3.fromRGB(224,38,45)
    redDisc.BorderSizePixel=0
    redDisc.ZIndex=9
    corner(redDisc,38)
    local seven=Instance.new("TextLabel",redDisc)
    seven.Size=UDim2.fromScale(1,1)
    seven.BackgroundTransparency=1
    seven.Text="7"
    seven.TextColor3=Color3.fromRGB(255,255,255)
    seven.Font=Enum.Font.GothamBlack
    seven.TextSize=57
    seven.Rotation=-9
    seven.ZIndex=10
    local up=Instance.new("TextLabel",canBody)
    up.Size=UDim2.new(0,82,0,64)
    up.Position=UDim2.new(0,91,0,132)
    up.BackgroundTransparency=1
    up.Text="UP"
    up.TextColor3=Color3.fromRGB(255,255,255)
    up.Font=Enum.Font.GothamBlack
    up.TextSize=39
    up.TextXAlignment=Enum.TextXAlignment.Left
    up.Rotation=-5
    up.ZIndex=10
    local canCaption=Instance.new("TextLabel",canBody)
    canCaption.Size=UDim2.new(1,-24,0,40)
    canCaption.Position=UDim2.new(0,12,1,-66)
    canCaption.BackgroundTransparency=1
    canCaption.Text="7UP HUB\nDUELS EDITION"
    canCaption.TextColor3=Color3.fromRGB(220,255,230)
    canCaption.Font=Enum.Font.GothamBlack
    canCaption.TextSize=11
    canCaption.ZIndex=10

    local neck=Instance.new("Frame",canAssembly)
    neck.Size=UDim2.new(0,158,0,48)
    neck.Position=UDim2.new(0,31,0,43)
    neck.BackgroundColor3=Color3.fromRGB(0,90,41)
    neck.BorderSizePixel=0
    neck.ZIndex=7
    corner(neck,24)

    local lid=Instance.new("Frame",canAssembly)
    lid.Name="OpeningLid"
    lid.Size=UDim2.new(0,168,0,44)
    lid.Position=UDim2.new(0,26,0,31)
    lid.BackgroundColor3=Color3.fromRGB(157,173,163)
    lid.BorderSizePixel=0
    lid.ZIndex=12
    corner(lid,22)
    local lidGradient=Instance.new("UIGradient",lid)
    lidGradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(70,86,76)),
        ColorSequenceKeypoint.new(0.35,Color3.fromRGB(224,232,226)),
        ColorSequenceKeypoint.new(0.7,Color3.fromRGB(132,149,138)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(52,68,59))
    })

    local lidInset=Instance.new("Frame",lid)
    lidInset.Size=UDim2.new(1,-28,1,-14)
    lidInset.Position=UDim2.new(0,14,0,7)
    lidInset.BackgroundColor3=Color3.fromRGB(74,91,80)
    lidInset.BackgroundTransparency=0.12
    lidInset.BorderSizePixel=0
    lidInset.ZIndex=13
    corner(lidInset,15)

    local pullTab=Instance.new("Frame",lid)
    pullTab.Name="PullTab"
    pullTab.AnchorPoint=Vector2.new(0.5,0.5)
    pullTab.Position=UDim2.new(0.5,4,0.5,0)
    pullTab.Size=UDim2.new(0,67,0,18)
    pullTab.BackgroundColor3=Color3.fromRGB(214,223,217)
    pullTab.BorderSizePixel=0
    pullTab.ZIndex=15
    corner(pullTab,9)
    local tabHole=Instance.new("Frame",pullTab)
    tabHole.Size=UDim2.new(0,25,0,8)
    tabHole.Position=UDim2.new(0,8,0,5)
    tabHole.BackgroundColor3=Color3.fromRGB(82,98,88)
    tabHole.BorderSizePixel=0
    tabHole.ZIndex=16
    corner(tabHole,4)

    local openingCore=Instance.new("Frame",canAssembly)
    openingCore.AnchorPoint=Vector2.new(0.5,0.5)
    openingCore.Position=UDim2.new(0.5,0,0,49)
    openingCore.Size=UDim2.new(0,0,0,0)
    openingCore.BackgroundColor3=Color3.fromRGB(240,255,245)
    openingCore.BackgroundTransparency=0.1
    openingCore.BorderSizePixel=0
    openingCore.ZIndex=11
    corner(openingCore,45)

    local fizzText=Instance.new("TextLabel",root)
    fizzText.AnchorPoint=Vector2.new(0.5,0.5)
    fizzText.Position=UDim2.new(0.5,0,0.22,22)
    fizzText.Size=UDim2.new(0,420,0,72)
    fizzText.BackgroundTransparency=1
    fizzText.Text="PSSSHH!"
    fizzText.TextColor3=Color3.fromRGB(220,255,232)
    fizzText.TextTransparency=1
    fizzText.Font=Enum.Font.GothamBlack
    fizzText.TextSize=46
    fizzText.Rotation=-4
    fizzText.ZIndex=35

    local fizzLayer=Instance.new("Frame",root)
    fizzLayer.Size=UDim2.fromScale(1,1)
    fizzLayer.BackgroundTransparency=1
    fizzLayer.BorderSizePixel=0
    fizzLayer.ZIndex=30
    local bubbles={}
    local bubbleLayout={
        {-18,0,-160,-210,13},{15,2,130,-225,9},{-42,8,-210,-180,8},{48,9,220,-170,14},
        {-7,4,-80,-265,7},{28,5,80,-250,11},{-61,16,-270,-130,10},{67,14,285,-110,7},
        {-28,18,-145,-155,16},{38,20,175,-145,8},{0,0,0,-295,12},{-78,22,-315,-90,6},
        {82,20,330,-65,10},{-10,13,-35,-205,6},{11,14,42,-190,5},{-51,24,-225,-105,12}
    }
    for i,data in ipairs(bubbleLayout) do
        local bubble=Instance.new("Frame",fizzLayer)
        local size=data[5]
        bubble.AnchorPoint=Vector2.new(0.5,0.5)
        bubble.Position=UDim2.new(0.5,data[1],0.46,data[2])
        bubble.Size=UDim2.new(0,0,0,0)
        bubble.BackgroundColor3=i%3==0 and Color3.fromRGB(110,255,170) or Color3.fromRGB(240,255,245)
        bubble.BackgroundTransparency=0.08
        bubble.BorderSizePixel=0
        bubble.ZIndex=31
        corner(bubble,size)
        bubbles[#bubbles+1]={obj=bubble,size=size,endX=data[3],endY=data[4],delay=(i-1)*0.025}
    end

    local title=Instance.new("TextLabel",root)
    title.AnchorPoint=Vector2.new(0.5,0.5)
    title.Position=UDim2.new(0.5,0,0.79,28)
    title.Size=UDim2.new(0,620,0,74)
    title.BackgroundTransparency=1
    title.Text="7UP DUELS"
    title.TextColor3=Color3.fromRGB(255,255,255)
    title.TextTransparency=1
    title.Font=Enum.Font.GothamBlack
    title.TextScaled=true
    title.ZIndex=40
    local titleLimit=Instance.new("UITextSizeConstraint",title)
    titleLimit.MinTextSize=26; titleLimit.MaxTextSize=58
    local titleGradient=Instance.new("UIGradient",title)
    titleGradient.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.46,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
    })

    local subtitle=Instance.new("TextLabel",root)
    subtitle.AnchorPoint=Vector2.new(0.5,0.5)
    subtitle.Position=UDim2.new(0.5,0,0.86,18)
    subtitle.Size=UDim2.new(0,500,0,25)
    subtitle.BackgroundTransparency=1
    subtitle.Text="discord.gg/7up  •  FRESHLY OPENED"
    subtitle.TextColor3=Color3.fromRGB(90,255,160)
    subtitle.TextTransparency=1
    subtitle.Font=Enum.Font.GothamBlack
    subtitle.TextSize=11
    subtitle.ZIndex=40

    local wipe=Instance.new("Frame",root)
    wipe.AnchorPoint=Vector2.new(0.5,0.5)
    wipe.Position=UDim2.new(0.5,0,0.5,0)
    wipe.Size=UDim2.new(0,0,0,0)
    wipe.BackgroundColor3=Color3.fromRGB(0,210,88)
    wipe.BackgroundTransparency=0
    wipe.BorderSizePixel=0
    wipe.ZIndex=70
    corner(wipe,1200)

    local skipInputConn=nil
    local function finishIntro()
        if finished then return end
        finished=true
        active=false
        if skipInputConn then skipInputConn:Disconnect(); skipInputConn=nil end
        pcall(stopIntroPlayback)
        pcall(function() openSfx:Stop(); openSfx:Destroy() end)
        restoreOwnedUI(true)
        task.delay(0.55,function()
            pcall(function() if introGui then introGui:Destroy() end end)
        end)
    end
    local lastSkipPress=0
    skipInputConn=UIS.InputBegan:Connect(function(input)
        if not active then return end
        local inputType=input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1
            and inputType ~= Enum.UserInputType.Touch then return end
        local now=tick()
        if now-lastSkipPress <= 0.36 then
            lastSkipPress=0
            finishIntro()
        else
            lastSkipPress=now
            skipHint.Text="ONE MORE CLICK TO SKIP"
            skipHint.TextTransparency=0
            task.delay(0.42,function()
                if active and now==lastSkipPress and skipHint.Parent then
                    skipHint.Text="DOUBLE CLICK / DOUBLE TAP ANYWHERE TO SKIP"
                    skipHint.TextTransparency=0.08
                end
            end)
        end
    end)
    skipBtn.MouseEnter:Connect(function() tween(skipBtn,0.12,nil,nil,{BackgroundTransparency=0}) end)
    skipBtn.MouseLeave:Connect(function() tween(skipBtn,0.12,nil,nil,{BackgroundTransparency=0.12}) end)

    task.spawn(function()
        tween(root,0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{BackgroundTransparency=0.02})
        tween(topCopy,0.6,nil,nil,{TextTransparency=0})
        tween(canAssembly,0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Position=UDim2.new(0.5,0,0.46,0),Rotation=0})
        tween(canScale,0.8,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Scale=fit})
        if not aliveWait(1.35) then return end

        -- Pressure builds: the whole can gives a short, weighty shake.
        tween(canAssembly,0.11,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{Rotation=-4})
        if not aliveWait(0.13) then return end
        tween(canAssembly,0.11,nil,nil,{Rotation=4})
        if not aliveWait(0.13) then return end
        tween(canAssembly,0.11,nil,nil,{Rotation=-2})
        if not aliveWait(0.13) then return end
        tween(canAssembly,0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Rotation=0})
        if not aliveWait(0.62) then return end

        -- Pull-tab snap and opening pressure bloom.
        pcall(function()
            if introPlaybackSound and introPlaybackSound.Parent then
                tween(introPlaybackSound,0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{Volume=0.18})
            end
            openSfx.TimePosition=0
            openSfx:Play()
        end)
        task.delay(1.4,function()
            if active and introPlaybackSound and introPlaybackSound.Parent then
                tween(introPlaybackSound,0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{Volume=0.7})
            end
        end)
        tween(pullTab,0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Rotation=-48,Position=UDim2.new(0.5,1,0.5,-8)})
        tween(lid,0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Position=UDim2.new(0,26,0,24),Rotation=2})
        tween(openingCore,0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,{Size=UDim2.new(0,118,0,42),BackgroundTransparency=0.3})
        tween(glow,0.32,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,{Size=UDim2.new(0,820,0,820),BackgroundTransparency=0.8})
        tween(fizzText,0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{TextTransparency=0,Position=UDim2.new(0.5,0,0.22,-10),Rotation=2})
        for _,data in ipairs(bubbles) do
            task.delay(data.delay,function()
                if not active or not data.obj.Parent then return end
                data.obj.Size=UDim2.new(0,data.size,0,data.size)
                tween(data.obj,0.8+data.delay,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,{
                    Position=UDim2.new(0.5,data.endX,0.46,data.endY),
                    Size=UDim2.new(0,data.size*1.55,0,data.size*1.55),
                    BackgroundTransparency=1
                })
            end)
        end
        if not aliveWait(0.78) then return end
        tween(fizzText,0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{TextTransparency=1,Position=UDim2.new(0.5,0,0.18,-30)})
        tween(openingCore,0.5,nil,nil,{Size=UDim2.new(0,180,0,66),BackgroundTransparency=1})
        tween(canScale,0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Scale=fit*1.035})
        if not aliveWait(0.5) then return end
        tween(canScale,0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{Scale=fit})
        tween(title,0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out,{TextTransparency=0,Position=UDim2.new(0.5,0,0.79,0)})
        tween(subtitle,0.7,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,{TextTransparency=0,Position=UDim2.new(0.5,0,0.86,0)})
        if not aliveWait(4.1) then return end

        -- One carbonation bubble fills the screen and reveals the actual hub.
        tween(wipe,0.62,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,{Size=UDim2.new(0,2200,0,2200)})
        tween(title,0.35,nil,nil,{TextTransparency=1})
        tween(subtitle,0.35,nil,nil,{TextTransparency=1})
        if not aliveWait(0.78) then return end
        finishIntro()
    end)
end

-- ============================================================
-- BOOT: run Main GUI + force Ace-style intro
-- ============================================================
if not _G.SevenUpDuelsV2_MainExecuted then
    _G._K7IntroHidingUI = true
    local function boot()
        local ok, err = pcall(function()
            if not LP then LP = Players.LocalPlayer or Players:WaitForChild("LocalPlayer") end
            LP:WaitForChild("PlayerGui", 10)
            Main()
            local pg = LP:FindFirstChild("PlayerGui")
            if _G._K7RemoveUILines and pg then
                for _,guiName in ipairs({"SevenUpDuelsV2","AutoGrab"}) do
                    local ownedGui=pg:FindFirstChild(guiName)
                    if ownedGui then pcall(_G._K7RemoveUILines,ownedGui) end
                end
            end
        end)
        if not ok then
            warn("[7UP duels] Main() error:", err)
        else
            print("[7UP duels] Main GUI loaded")
        end
    end
    boot()

    task.spawn(function()
        task.wait(0.4)
        local tries = 0
        while tries < 50 do
            tries = tries + 1
            local pg = LP and LP:FindFirstChild("PlayerGui")
            local gui = pg and pg:FindFirstChild("SevenUpDuelsV2")
            local mo = gui and gui:FindFirstChild("MainOuter")
            if mo then
                _G._K7MainOuter = mo
                break
            end
            task.wait(0.1)
        end
        _introEnabled = not (State and State.introEnabled == false)
        if not _introEnabled then
            _G._K7IntroHidingUI=false
            local skippedFrame=_G._K7MainOuter
            if skippedFrame then skippedFrame.Visible=not (State and State.guiVisible==false) end
            for _,wrapper in pairs(stackWrappers or {}) do
                if wrapper then wrapper.Visible=not (State and State.stackButtonsHidden) end
            end
            if autoGrabModule and autoGrabModule.showUI then pcall(autoGrabModule.showUI,false) end
            print("[7UP duels] Intro disabled in Config")
            return
        end
        print("[7UP duels] Running intro...")
        local ok, err = pcall(function()
            if _G.K7RunIntro then
                _G.K7RunIntro()
            else
                warn("[7UP duels] K7RunIntro missing")
            end
        end)
        if not ok then
            warn("[7UP duels] Intro error:", err)
            _G._K7IntroHidingUI = false
            pcall(function()
                if autoGrabModule and autoGrabModule.showUI then autoGrabModule.showUI(false) end
                for _, wrapper in pairs(stackWrappers or {}) do
                    if wrapper then wrapper.Visible = not (State and State.stackButtonsHidden) end
                end
                local frame = _G._K7MainOuter
                if frame then frame.Visible = true; frame.Size = UDim2.new(0, 450, 0, 660) end
            end)
        end
    end)
end
end)()
