-- RITUAL HUB UPDATED BACKEND
-- New TP Bat + Bat Aimbot + Speed Constraint + Anti Die + Anti Fling
-- V3 SPEED FIX: authoritative mode state + live GUI speed values; no stale Carry latch.
-- cridts to anas 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ============================================================
-- EARLY STARTUP GUARD
-- The original script builds the main GUI very late in the file.
-- If anything fails before that point, the executor can look like
-- nothing happened. This tiny GUI appears immediately and reports
-- a runtime failure instead of silently disappearing.
-- ============================================================
local __RITUAL_BOOT_GUI
local __RITUAL_BOOT_STATUS
pcall(function()
    local pg = player and player:WaitForChild("PlayerGui", 10)
    if not pg then return end
    local old = pg:FindFirstChild("RitualHubStartup")
    if old then old:Destroy() end

    __RITUAL_BOOT_GUI = Instance.new("ScreenGui")
    __RITUAL_BOOT_GUI.Name = "RitualHubStartup"
    __RITUAL_BOOT_GUI.ResetOnSpawn = false
    __RITUAL_BOOT_GUI.IgnoreGuiInset = true
    __RITUAL_BOOT_GUI.DisplayOrder = 10000
    __RITUAL_BOOT_GUI.Parent = pg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(270, 72)
    frame.Position = UDim2.fromOffset(18, 70)
    frame.BackgroundColor3 = Color3.fromRGB(7, 15, 24)
    frame.BorderSizePixel = 0
    frame.Parent = __RITUAL_BOOT_GUI
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.fromOffset(10, 7)
    title.BackgroundTransparency = 1
    title.Text = "RITUAL HUB"
    title.TextColor3 = Color3.fromRGB(120, 190, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    __RITUAL_BOOT_STATUS = Instance.new("TextLabel")
    __RITUAL_BOOT_STATUS.Size = UDim2.new(1, -20, 0, 28)
    __RITUAL_BOOT_STATUS.Position = UDim2.fromOffset(10, 34)
    __RITUAL_BOOT_STATUS.BackgroundTransparency = 1
    __RITUAL_BOOT_STATUS.Text = "Starting..."
    __RITUAL_BOOT_STATUS.TextColor3 = Color3.fromRGB(220, 225, 235)
    __RITUAL_BOOT_STATUS.Font = Enum.Font.GothamMedium
    __RITUAL_BOOT_STATUS.TextSize = 11
    __RITUAL_BOOT_STATUS.TextXAlignment = Enum.TextXAlignment.Left
    __RITUAL_BOOT_STATUS.Parent = frame
end)

local function __RitualBootFail(err)
    warn("[RitualHub] startup/runtime error:\n" .. tostring(err))
    pcall(function()
        if __RITUAL_BOOT_STATUS then
            __RITUAL_BOOT_STATUS.Text = "Startup error — check executor console"
            __RITUAL_BOOT_STATUS.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
    end)
end

local function __RitualBootClear()
    pcall(function()
        if __RITUAL_BOOT_GUI then __RITUAL_BOOT_GUI:Destroy() end
    end)
end


local _GACC = {}

local introSoundEnabled = true
-- Read the Ritual config, but fall back to an existing Rainy one so the
-- rename does not wipe saved settings. Writes always go to the new file.
_GACC.CFG_FILE = "RitualHub_PC.json"
if isfile and not isfile(_GACC.CFG_FILE) and isfile("RainyHub_PC.json") then
    _GACC.CFG_FILE = "RainyHub_PC.json"
end
if isfile and isfile(_GACC.CFG_FILE) then
    local ok, data = pcall(function() return HS:JSONDecode(readfile(_GACC.CFG_FILE)) end)
    if ok and type(data) == "table" and data.introSoundEnabled ~= nil then
        introSoundEnabled = data.introSoundEnabled
    end
end

local animEnabled = false
local backgroundEnabled = false
local backgroundIndex = 1
local currentColorTheme = "RAIN"

local THEME_DEFS = {
    RAIN = {accent=Color3.fromRGB(82,170,255), accentDark=Color3.fromRGB(35,94,165), accentBg=Color3.fromRGB(7,25,48), accentHover=Color3.fromRGB(18,67,116), accentRowHover=Color3.fromRGB(7,25,43), bgAsset="rbxassetid://100853278968274"},
}

_GACC.playerHighlightEnabled=false
_GACC.backgroundImages={
    "rbxassetid://129085053275432",
    "rbxassetid://126638309339233",
    "rbxassetid://90211231416942",
    "rbxassetid://138472956105442",
    "rbxassetid://106519139240666",
    "rbxassetid://114535932585883",
    "rbxassetid://133353928145895",
    "rbxassetid://95372928362733",
    "rbxassetid://82986133916631",
    "rbxassetid://71086942427922",
}
do local _t0=THEME_DEFS[currentColorTheme] or THEME_DEFS.RAIN
    _GACC.accent=_t0.accent; _GACC.accentDark=_t0.accentDark
    _GACC.accentBg=_t0.accentBg; _GACC.accentHover=_t0.accentHover
    _GACC.accentRowHover=_t0.accentRowHover
end

local _themeExtRefs = {}
local _themeStealPills = {}

local function _gAccentGrad(t)
    local a=_GACC.accent; local d=_GACC.accentDark
    local pulse=math.sin(t*0.7)*0.14
    local aR=math.clamp(math.floor(a.R*255*(1+pulse)),0,255)
    local aG=math.clamp(math.floor(a.G*255*(1+pulse)),0,255)
    local aB=math.clamp(math.floor(a.B*255*(1+pulse)),0,255)
    local dR=math.clamp(math.floor(d.R*255*(0.75+pulse*0.25)),0,255)
    local dG=math.clamp(math.floor(d.G*255*(0.75+pulse*0.25)),0,255)
    local dB=math.clamp(math.floor(d.B*255*(0.75+pulse*0.25)),0,255)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(dR,dG,dB)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(aR,aG,aB)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.82,Color3.fromRGB(aR,aG,aB)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(dR,dG,dB))
    })
end

if isfile and isfile(_GACC.CFG_FILE) then
    local ok2, d2 = pcall(function() return HS:JSONDecode(readfile(_GACC.CFG_FILE)) end)
    if ok2 and type(d2)=="table" then
        if type(d2.animEnabled)=="boolean" then animEnabled=d2.animEnabled end
        if type(d2.backgroundEnabled)=="boolean" then backgroundEnabled=d2.backgroundEnabled end
        if type(d2.backgroundIndex)=="number" then backgroundIndex=d2.backgroundIndex end
        if type(d2.colorThemeName)=="string" and THEME_DEFS[d2.colorThemeName] then currentColorTheme=d2.colorThemeName end
    end
end

-- ========== NEW SCALE VARIABLES ==========
local menuScale = 0.85
local mobileBtnScale = 0.9
local stealBarScale = 1.0
-- ========================================

local introSoundInstance = nil
if introSoundEnabled then
    task.spawn(function()
        local urlIntro = "https://files.catbox.moe/66xaq4.mp3"
        local numeFisier = "ritualhub_intro.mp3"
        if not (isfile and isfile(numeFisier)) then
            local ok, data = pcall(function() return game:HttpGet(urlIntro) end)
            if ok and data then pcall(function() writefile(numeFisier, data) end) end
        end
        introSoundInstance = Instance.new("Sound")
        pcall(function()
            introSoundInstance.SoundId = getcustomasset(numeFisier)
            introSoundInstance.Volume = 3
            introSoundInstance.Looped = false
            introSoundInstance.Parent = game:GetService("CoreGui")
            introSoundInstance:Play()
        end)
    end)
end

if false then
    task.spawn(function()
        task.wait(1.7)
        local shaking = true
        local shakeConn = RunService.RenderStepped:Connect(function()
            if not shaking then return end
            local cam = workspace.CurrentCamera
            if cam then
                local ox = (math.random() * 2 - 1) * 1.8
                local oy = (math.random() * 2 - 1) * 1.8
                cam.CFrame = cam.CFrame * CFrame.new(ox, oy, 0)
            end
        end)
        task.wait(1.6)
        shaking = false
        shakeConn:Disconnect()
        local introGui = Instance.new("ScreenGui")
        introGui.Name = "RitualHubIntroTitle"
        introGui.ResetOnSpawn = false
        introGui.IgnoreGuiInset = true
        introGui.DisplayOrder = 9999
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(introGui) end end)
        if not pcall(function() introGui.Parent = game:GetService("CoreGui") end) then
            introGui.Parent = player:WaitForChild("PlayerGui")
        end
        local pokerLbl = Instance.new("TextLabel")
        pokerLbl.Size = UDim2.new(0.8, 0, 0, 130)
        pokerLbl.AnchorPoint = Vector2.new(0.5, 0.5)
        pokerLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
        pokerLbl.BackgroundTransparency = 1
        pokerLbl.RichText = true
        pokerLbl.Text = 'RITUAL <font color="rgb(120,190,255)">HUB</font>'
        pokerLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        pokerLbl.TextScaled = true
        pokerLbl.Font = Enum.Font.GothamBlack
        pokerLbl.TextTransparency = 1
        pokerLbl.TextStrokeTransparency = 1
        pokerLbl.ZIndex = 10
        pokerLbl.Parent = introGui
        for i = 1, 25 do
            pokerLbl.TextTransparency = 1 - (i / 25)
            pokerLbl.TextStrokeTransparency = 1 - (i / 25)
            task.wait(0.016)
        end
        pokerLbl.TextTransparency = 0
        pokerLbl.TextStrokeTransparency = 0
        task.wait(2.5)
        for i = 1, 30 do
            local a = i / 30
            pokerLbl.TextTransparency = a
            pokerLbl.TextStrokeTransparency = a
            task.wait(0.03)
        end
        pokerLbl.TextTransparency = 1
        task.wait(0.05)
        pcall(function() introGui:Destroy() end)
        pcall(function() introGui.Parent = nil end)
    end)
end

repeat task.wait() until game:IsLoaded()

local CANDY_SKY_TAG = "MoveeSkyTheme"
local currentSkyTheme = "Night"
local CANDY_SKY_PRESETS = {
    ["Off"]={kind="off"},
    ["Night"]={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}},
    ["Aurora"]={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
    ["Sunset"]={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}},
    ["Galaxy"]={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
    ["Cyber"]={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}},
    ["Sakura"]={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
    ["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4},clouds={cover=0.3,dens=0.5,color={180,90,150}}},
    ["Blood Moon"]={clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2},clouds={cover=0.5,dens=0.7,color={120,30,30}}},
    ["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18,moon=0,stars=0},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2},clouds={cover=0.5,dens=0.5,color={200,255,220}}},
    ["Volcanic"]={clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50},sky={stars=200,sun=12,moon=0},atm={dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5},clouds={cover=0.8,dens=0.9,color={120,40,20}}},
    ["Arctic"]={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10,stars=0,moon=0},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7,dens=0.6,color={250,253,255}}},
    ["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
    ["Vaporwave"]={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.5,dens=0.55,color={200,150,255}}},
    ["Toxic"]={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6},clouds={cover=0.65,dens=0.7,color={180,255,120}}},
    ["Solar Eclipse"]={clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70},sky={stars=3500,sun=22,moon=0},atm={dens=0.5,color={255,140,40},decay={30,20,40},glare=2.8,haze=1.8}},
    ["Hellscape"]={clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40},sky={stars=100,sun=30,moon=0},atm={dens=0.85,color={255,30,0},decay={120,0,0},glare=3.5,haze=4},clouds={cover=0.95,dens=0.95,color={80,20,10}}},
    ["Heaven"]={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16,moon=0,stars=0},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5},clouds={cover=0.85,dens=0.5,color={255,255,255}}},
    ["Storm"]={clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120},sky={stars=0,sun=6,moon=0},atm={dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3},clouds={cover=0.95,dens=0.95,color={60,65,80}}},
    ["Sunrise"]={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22,stars=0,moon=0},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4,dens=0.4,color={255,220,180}}},
    ["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}},
    ["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16,sun=0},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5,color={220,200,255}}},
    ["Inferno"]={clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50},sky={sun=26,moon=0,stars=0},atm={dens=0.6,color={255,90,20},decay={200,40,0},glare=3,haze=3.2},clouds={cover=0.7,dens=0.7,color={200,80,40}}},
    ["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}
local SkyOrder={"Off","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}
local function candyColor(rgb) return Color3.fromRGB(rgb[1],rgb[2],rgb[3]) end
local function CandyApplyCustomSky(mode)
    for _,child in ipairs(Lighting:GetChildren()) do if child:GetAttribute(CANDY_SKY_TAG) then pcall(function() child:Destroy() end) end end
    local terrain=workspace:FindFirstChildOfClass("Terrain")
    if terrain then for _,child in ipairs(terrain:GetChildren()) do if child:GetAttribute(CANDY_SKY_TAG) then pcall(function() child:Destroy() end) end end end
    local preset=CANDY_SKY_PRESETS[mode]
    if not preset or preset.kind=="off" then Lighting.ClockTime=14;Lighting.Brightness=2;Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127);Lighting.Ambient=Color3.fromRGB(127,127,127);Lighting.FogEnd=100000;Lighting.GlobalShadows=true;return end
    Lighting.FogStart=0;Lighting.FogEnd=100000;Lighting.FogColor=Color3.fromRGB(200,200,200);Lighting.ColorShift_Top=Color3.fromRGB(0,0,0);Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0);Lighting.GlobalShadows=true
    Lighting.ClockTime=preset.clock or 14;Lighting.Brightness=preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient=candyColor(preset.outAmb) end
    if preset.ambient then Lighting.Ambient=candyColor(preset.ambient) end
    if preset.sky then
        local skyInst=Instance.new("Sky");skyInst:SetAttribute(CANDY_SKY_TAG,true)
        if preset.sky.stars then skyInst.StarCount=preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize=preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize=preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId="rbxasset://sky/moon.jpg" end
        skyInst.Parent=Lighting
    end
    if preset.atm then
        local atm=Instance.new("Atmosphere");atm:SetAttribute(CANDY_SKY_TAG,true)
        atm.Density=preset.atm.dens or 0.3;atm.Color=candyColor(preset.atm.color);atm.Decay=candyColor(preset.atm.decay);atm.Glare=preset.atm.glare or 1;atm.Haze=preset.atm.haze or 1;atm.Parent=Lighting
    end
    if preset.clouds and terrain then
        local clouds=Instance.new("Clouds");clouds:SetAttribute(CANDY_SKY_TAG,true)
        clouds.Cover=preset.clouds.cover or 0.5;clouds.Density=preset.clouds.dens or 0.5;clouds.Color=candyColor(preset.clouds.color);clouds.Parent=terrain
    end
end

local TS=TweenService
local LP=Players.LocalPlayer
local playerGui = LP:WaitForChild("PlayerGui")

local NS,CS=59,29
local LAGGER_SPEED=30
local LAGGER_CARRY_SPEED=15
local carrySpeedActive = false
local laggerModeEnabled = false

local antiRagdollEnabled,infJumpEnabled=false,false
local medusaCounterEnabled,unwalkEnabled=false,false
local medusaDebounce,medusaLastUsed,dropActive=false,0,false
local autoLeftEnabled,autoRightEnabled=false,false
local autoLeftSetVisual,autoRightSetVisual=nil,nil
local speedLabel=nil
local speedModeLabel=nil
local autoBatEnabled=false
local batDesyncTpEnabled=false
local batDesyncTpSetVisual=nil
local autoSwingEnabled=true
local autoMoveSwingEnabled=false
local autoMoveSwingInterval=0.3
local _alSwingDebounce=false
local _arSwingDebounce=false
local autoBatSetVisual=nil
local resetAutoBatMotion=nil
local antiLagEnabled,removeAccessoriesEnabled,antiLagDescConn=false,false,nil
local stretchRezEnabled,stretchRezConn,setStretchRezVisual=false,nil,nil
local unwalkSavedAnimate,_anyKeyListening=nil,false
local autoTPEnabled,autoTPHeight,autoTPConn,setAutoTPVisual=false,20,nil,nil
local guiTransparencyEnabled,mobileButtonsEnabled,mobileButtonsLocked=false,true,false
local mobileButtonsSize=56
local circleButtonsEnabled=false
local stealBarFrame
local mobBtnRefs={}
local mobGuiRef=nil
local fovValue=80
-- Roblox hard-caps Camera.FieldOfView at 120; anything above is ignored.
local fovOptions={70,80,90,100,110,120}
local fovIndex=1
local laggerModePillRef=nil
local carryModePillRef=nil
local autoSwitchSpeedEnabled=false
local mobBtnTransparencyEnabled=false
local perButtonDragEnabled=false
_GACC.autoCarrySpeedEnabled=false
local espEnabled=false
local espObjects={}
local espConnections={}
local ragdollGuiEnabled=true
local persistentRagdollGui=nil
local uiLocked=false
local infJumpMode="manual"
local holdInfJumpConn=nil
-- Green Duels jump-drop tuning
local DROP_ASCEND_DURATION=0.22
local DROP_ASCEND_SPEED=160
local _GuiKeys = nil
local pingNotification = nil
local _perfFps,_perfPing=0,0

-- ========== ANTI DIE ==========
local antiDieEnabled = false
local antiDieConnections = {}  -- store all event connections
local antiDieHeartbeat = nil
-- ================================

local bgImageRef = nil
local bgImageContainer = nil 
local bgImageCorner = nil
local bgGradientRef = nil
local rainLayerRef = nil
local innerPanelRef = nil
local function applyBackgroundImage()
    if not bgImageRef then return end
    local theme=THEME_DEFS[currentColorTheme] or THEME_DEFS.RAIN
    backgroundIndex=math.clamp(math.floor(tonumber(backgroundIndex) or 1),1,#_GACC.backgroundImages)
    local asset=backgroundEnabled and (_GACC.backgroundImages[backgroundIndex] or theme.bgAsset or "") or ""
    if asset~="" and not string.find(asset,"rbxassetid://",1,true) then asset="rbxassetid://"..asset end
    local hasImage=asset~=""
    bgImageRef.Image=asset; bgImageRef.ImageTransparency=hasImage and .18 or 1; bgImageRef.Visible=hasImage; bgImageRef.Size=UDim2.new(1,0,1,0); bgImageRef.ScaleType=Enum.ScaleType.Crop
    if innerPanelRef then innerPanelRef.BackgroundTransparency=.74 end
    if bgGradientRef then bgGradientRef.BackgroundTransparency=1 end
    if rainLayerRef then rainLayerRef.Visible=false end
end

local RembembiAnims = {
    WalkAnim  = 73718308412641,
    RunAnim   = 135515454877967,
    JumpAnim  = 78508480717326,
    FallAnim  = 78147885297412,
    SwimIdle  = 129183123083281,
    Swim      = 110657013921774,
    ClimbAnim = 129447497744818,
    Animation1 = 92849173543269,
    Animation2 = 132238900951109,
}

local startAnimToggle, stopAnimToggle
local AnimRefs = {
        heartbeat=nil,
        savedAnimate=nil,
        originalAnims=nil,
        originalCharacter=nil,
        generation=0,
    }

do
    local LP_anim = Players.LocalPlayer
    local function isRembembiAnim(id)
        if not id then return false end
        for _,v in pairs(RembembiAnims) do if v == id then return true end end
        return false
    end
    local function saveOriginalAnims(char)
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function g(obj) return obj and obj.AnimationId or nil end
        local ids = {
            walk=g(animate.walk and animate.walk.WalkAnim),
            run=g(animate.run and animate.run.RunAnim),
            jump=g(animate.jump and animate.jump.JumpAnim),
            fall=g(animate.fall and animate.fall.FallAnim),
            climb=g(animate.climb and animate.climb.ClimbAnim),
            swim=g(animate.swim and animate.swim.Swim),
            swimidle=g(animate.swimidle and animate.swimidle.SwimIdle),
            idle1=g(animate.idle and animate.idle.Animation1),
            idle2=g(animate.idle and animate.idle.Animation2),
        }
        if AnimRefs.originalCharacter ~= char or not AnimRefs.originalAnims then
            AnimRefs.originalAnims = ids
            AnimRefs.originalCharacter = char
        end
    end
    local function applyRembembiAnims(char)
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj, id) if obj then obj.AnimationId = "rbxassetid://" .. id end end
        s(animate.walk and animate.walk.WalkAnim, RembembiAnims.WalkAnim)
        s(animate.run and animate.run.RunAnim, RembembiAnims.RunAnim)
        s(animate.jump and animate.jump.JumpAnim, RembembiAnims.JumpAnim)
        s(animate.fall and animate.fall.FallAnim, RembembiAnims.FallAnim)
        s(animate.climb and animate.climb.ClimbAnim, RembembiAnims.ClimbAnim)
        s(animate.swim and animate.swim.Swim, RembembiAnims.Swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, RembembiAnims.SwimIdle)
        s(animate.idle and animate.idle.Animation1, RembembiAnims.Animation1)
        s(animate.idle and animate.idle.Animation2, RembembiAnims.Animation2)
    end
    local function restoreOriginalAnims(char)
        local orig = AnimRefs.originalAnims
        if not orig then return end
        local animate = char:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj, id) if obj and id then obj.AnimationId = id end end
        s(animate.walk and animate.walk.WalkAnim, orig.walk)
        s(animate.run and animate.run.RunAnim, orig.run)
        s(animate.jump and animate.jump.JumpAnim, orig.jump)
        s(animate.fall and animate.fall.FallAnim, orig.fall)
        s(animate.climb and animate.climb.ClimbAnim, orig.climb)
        s(animate.swim and animate.swim.Swim, orig.swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, orig.swimidle)
        s(animate.idle and animate.idle.Animation1, orig.idle1)
        s(animate.idle and animate.idle.Animation2, orig.idle2)
    end
    function startAnimToggle()
        if AnimRefs.heartbeat then AnimRefs.heartbeat:Disconnect(); AnimRefs.heartbeat = nil end
        local char = LP_anim.Character
        if char then saveOriginalAnims(char); applyRembembiAnims(char) end
        AnimRefs.heartbeat = RunService.Heartbeat:Connect(function()
            if not animEnabled then return end
            local c = LP_anim.Character
            if c then applyRembembiAnims(c) end
        end)
    end
    function stopAnimToggle()
        if AnimRefs.heartbeat then AnimRefs.heartbeat:Disconnect(); AnimRefs.heartbeat = nil end
        local char = LP_anim.Character
        if char then restoreOriginalAnims(char) end
    end
end

_GACC.extras={}
do
local ANIMATION_PACKS={
    ["Adidas Sports"]={WalkAnim=18537392113,RunAnim=18537384940,JumpAnim=18537380791,FallAnim=18537367238,SwimIdle=18537387180,Swim=18537389531,Animation1=18537376492,Animation2=18537371272,ClimbAnim=18537363391},
    ["Adidas Community"]={WalkAnim=122150855457006,RunAnim=82598234841035,JumpAnim=75290611992385,FallAnim=98600215928904,SwimIdle=109346520324160,Swim=133308483266208,Animation1=122257458498464,Animation2=102357151005774,ClimbAnim=88763136693023},
    ["Adidas Aura"]={WalkAnim=83842218823011,RunAnim=118320322718866,JumpAnim=109996626521204,FallAnim=95603166884636,SwimIdle=94922130551805,Swim=134530128383903,Animation1=110211186840347,Animation2=114191137265065,ClimbAnim=97824616490448},
    ["Wicked Popular"]={WalkAnim=92072849924640,RunAnim=72301599441680,JumpAnim=104325245285198,FallAnim=121152442762481,Animation1=118832222982049,ClimbAnim=131326830509784,SwimIdle=113199415118199,Swim=99384245425157,Animation2=76049494037641},
    Elder={WalkAnim=10921111375,RunAnim=10921104374,JumpAnim=10921107367,FallAnim=10921105765,SwimIdle=10921110146,Swim=10921108971,ClimbAnim=10921100400,Animation1=10921101664,Animation2=10921102574},
    Zombie={WalkAnim=10921355261,RunAnim=616163682,JumpAnim=10921351278,FallAnim=10921350320,SwimIdle=10921353442,Swim=10921352344,Animation1=10921344533,Animation2=10921345304,ClimbAnim=10921343576},
    Mage={WalkAnim=10921152678,RunAnim=10921148209,JumpAnim=10921149743,FallAnim=10921148939,SwimIdle=10921151661,Swim=10921150788,ClimbAnim=10921143404,Animation1=10921144709,Animation2=10921145797},
    ["Catwalk Glam"]={WalkAnim=109168724482748,RunAnim=81024476153754,JumpAnim=116936326516985,FallAnim=92294537340807,SwimIdle=98854111361360,Swim=134591743181628,ClimbAnim=119377220967554,Animation1=133806214992291,Animation2=94970088341563},
    Astronaut={WalkAnim=10921046031,RunAnim=10921039308,JumpAnim=10921042494,FallAnim=10921040576,SwimIdle=10921045006,Swim=10921044000,ClimbAnim=10921032124,Animation1=10921034824,Animation2=10921036806},
    ['Wicked "Dancing Through Life"']={WalkAnim=73718308412641,RunAnim=135515454877967,JumpAnim=78508480717326,FallAnim=78147885297412,SwimIdle=129183123083281,Swim=110657013921774,ClimbAnim=129447497744818,Animation1=92849173543269,Animation2=132238900951109},
    Werewolf={WalkAnim=10921342074,RunAnim=10921336997,FallAnim=10921337907,SwimIdle=10921341319,Swim=10921340419,ClimbAnim=10921329322,Animation1=10921330408,Animation2=10921333667},
    Superhero={WalkAnim=10921298616,RunAnim=10921291831,JumpAnim=10921294559,FallAnim=10921293373,SwimIdle=10921297391,Swim=10921295495,ClimbAnim=10921286911,Animation1=10921288909,Animation2=10921290167},
    Toy={WalkAnim=10921312010,RunAnim=10921306285,JumpAnim=10921308158,FallAnim=10921307241,SwimIdle=10921310341,Swim=10921309319,ClimbAnim=10921300839,Animation1=10921301576},
    ["No Boundaries"]={WalkAnim=18747074203,RunAnim=18747070484,JumpAnim=18747069148,FallAnim=18747062535,SwimIdle=18747071682,Swim=18747073181,ClimbAnim=18747060903,Animation1=18747067405,Animation2=18747063918},
    NFL={WalkAnim=110358958299415,RunAnim=117333533048078,JumpAnim=119846112151352,FallAnim=129773241321032,SwimIdle=79090109939093,Swim=132697394189921,ClimbAnim=134630013742019,Animation1=92080889861410,Animation2=74451233229259},
    ["Amazon Unboxed"]={WalkAnim=90478085024465,RunAnim=134824450619865,JumpAnim=121454505477205,FallAnim=94788218468396,SwimIdle=129126268464847,Swim=105962919001086,ClimbAnim=121145883950231,Animation1=98281136301627},
    Vampire={WalkAnim=10921326949,RunAnim=10921320299,JumpAnim=10921322186,FallAnim=10921321317,SwimIdle=10921325443,Swim=10921324408,ClimbAnim=10921314188,Animation1=10921315373},
    Ninja={Run=656118852,Walk=656121766,Jump=656117878,Fall=656115606,Swim=656119721,SwimIdle=656121397,Climb=656114359,Idle={656117400,656118341,886742569}},
    Robot={Run=616091570,Walk=616095330,Jump=616090535,Fall=616087089,Swim=616092998,SwimIdle=616094091,Climb=616086039,Idle={616088211,616089559,885531463}},
    Levitation={Run=616010382,Walk=616013216,Jump=616008936,Fall=616005863,Swim=616011509,SwimIdle=616012453,Climb=616003713,Idle={616006778,616008087,886862142}},
    Stylish={Run=616140816,Walk=616146177,Jump=616139451,Fall=616134815,Swim=616143378,SwimIdle=616144772,Climb=616133594,Idle={616136790,616138447,886888594}},
    Bubbly={Run=910025107,Walk=910034870,Jump=910016857,Fall=910001910,Swim=910028158,SwimIdle=910030921,Climb=909997997,Idle={910004836,910009958,1018536639}},
    Cartoon={Run=742638842,Walk=742640026,Jump=742637942,Fall=742637151,Swim=742639220,SwimIdle=742639812,Climb=742636889,Idle={742637544,742638445,885477856}},
}
local selectedAnimPack="Adidas Sports"
local headlessEnabled=false
local korbloxEnabled=false
local HEADLESS_MESH_ID="rbxassetid://1095708"
local KORBLOX_MESH_ID="rbxassetid://101851696"
local KORBLOX_TEXTURE_ID="rbxassetid://101851254"
local cosmeticState=setmetatable({},{__mode="k"})

local function animPick(pack,...)
    for i=1,select("#",...) do local v=pack[select(i,...)]; if v~=nil then return v end end
end
local function ensureAnimation(folder,name)
    if not folder then return nil end
    local obj=folder:FindFirstChild(name)
    if not obj then obj=Instance.new("Animation"); obj.Name=name; obj.Parent=folder end
    return obj
end
    local applyingAnimPack=false
    local function capturePackOriginals(char)
        if AnimRefs.originalCharacter==char and AnimRefs.originalAnims then return end
        local animate=char and char:FindFirstChild("Animate")
        if not animate then return end
        local function id(folder,name)
            local f=animate:FindFirstChild(folder); local obj=f and f:FindFirstChild(name)
            return obj and obj.AnimationId or nil
        end
        AnimRefs.originalAnims={
            walk=id("walk","WalkAnim"), run=id("run","RunAnim"), jump=id("jump","JumpAnim"),
            fall=id("fall","FallAnim"), climb=id("climb","ClimbAnim"), swim=id("swim","Swim"),
            swimidle=id("swimidle","SwimIdle"), idle1=id("idle","Animation1"), idle2=id("idle","Animation2"),
        }
        AnimRefs.originalCharacter=char
    end
    local function restorePackOriginals(char)
        local animate=char and char:FindFirstChild("Animate")
        if not animate then return false end
        local orig=AnimRefs.originalAnims
        -- If no snapshot is available, fall back to Roblox's standard R15 set.
        local defaults={
            walk=orig and orig.walk or "rbxassetid://913402848",
            run=orig and orig.run or "rbxassetid://913376220",
            jump=orig and orig.jump or "rbxassetid://125750702",
            fall=orig and orig.fall or "rbxassetid://913389285",
            climb=orig and orig.climb or "rbxassetid://913386991",
            swim=orig and orig.swim or "rbxassetid://913412306",
            swimidle=orig and orig.swimidle or "rbxassetid://913415072",
            idle1=orig and orig.idle1 or "rbxassetid://913402848",
            idle2=orig and orig.idle2 or "rbxassetid://913402848",
        }
        local function set(folder,name,value)
            local f=animate:FindFirstChild(folder); local obj=f and f:FindFirstChild(name)
            if obj and value then obj.AnimationId=value end
        end
        set("walk","WalkAnim",defaults.walk); set("run","RunAnim",defaults.run); set("jump","JumpAnim",defaults.jump)
        set("fall","FallAnim",defaults.fall); set("climb","ClimbAnim",defaults.climb); set("swim","Swim",defaults.swim)
        set("swimidle","SwimIdle",defaults.swimidle); set("idle","Animation1",defaults.idle1); set("idle","Animation2",defaults.idle2)
        return true
    end
    local function stopTracks(hum)
        if not hum then return end
        for _,track in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0) end) end
    end
    local function restartAnimate(animate,hum)
        if animate then
            pcall(function()
                animate.Disabled=true
                task.wait(.15)
                animate.Disabled=false
            end)
        end
        if hum then
            stopTracks(hum)
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Landed)
                task.wait(.05)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end
    local function applyAnimationPack(packName,char)
        if applyingAnimPack then return false end
        char=char or LP.Character
        if not char then return false end
        local animate=char:FindFirstChild("Animate")
        if not animate then return false end
        local hum=char:FindFirstChildOfClass("Humanoid")
        applyingAnimPack=true
        AnimRefs.generation=AnimRefs.generation+1
        local myGeneration=AnimRefs.generation
        capturePackOriginals(char)
        stopTracks(hum)
        if packName=="Off" or packName==nil or packName=="" then
            animEnabled=false
            restorePackOriginals(char)
            selectedAnimPack="Off"
            restartAnimate(animate,hum)
            applyingAnimPack=false
            return true
        end
        local pack=ANIMATION_PACKS[packName]
        if not pack then applyingAnimPack=false; return false end
        local ready=false
        for _=1,40 do
            animate=char:FindFirstChild("Animate")
            if animate and animate:FindFirstChild("idle") and animate:FindFirstChild("run") and animate:FindFirstChild("walk") then ready=true; break end
            task.wait(.1)
            if AnimRefs.generation~=myGeneration then applyingAnimPack=false; return false end
        end
        if not ready then applyingAnimPack=false; return false end
        local function set(folder,name,id)
            local f=animate:FindFirstChild(folder); local obj=f and f:FindFirstChild(name)
            if not obj then obj=ensureAnimation(f,name) end
            if obj and id then obj.AnimationId="rbxassetid://"..tostring(id) end
        end
        set("walk","WalkAnim",animPick(pack,"WalkAnim","Walk")); set("run","RunAnim",animPick(pack,"RunAnim","Run"))
        set("jump","JumpAnim",animPick(pack,"JumpAnim","Jump")); set("fall","FallAnim",animPick(pack,"FallAnim","Fall"))
        set("climb","ClimbAnim",animPick(pack,"ClimbAnim","Climb")); set("swim","Swim",animPick(pack,"Swim"))
        set("swimidle","SwimIdle",animPick(pack,"SwimIdle") or animPick(pack,"Swim"))
        local idle=animate:FindFirstChild("idle")
        if idle then
            local ids=pack.Idle or {animPick(pack,"Animation1"),animPick(pack,"Animation2")}
            if ids[1] or ids[2] then
                local a1=ensureAnimation(idle,"Animation1"); local a2=ensureAnimation(idle,"Animation2")
                if a1 then a1.AnimationId="rbxassetid://"..tostring(ids[1] or ids[2]) end
                if a2 then a2.AnimationId="rbxassetid://"..tostring(ids[2] or ids[1]) end
                for i=3,#ids do local a=ensureAnimation(idle,"Animation"..i); if a then a.AnimationId="rbxassetid://"..tostring(ids[i]) end end
            end
        end
        restartAnimate(animate,hum)
        selectedAnimPack=packName; applyingAnimPack=false; return true
    end

local function applyHeadless(char,enabled)
    local head=char and char:FindFirstChild("Head"); if not head then return end
    local state=cosmeticState[char] or {}; cosmeticState[char]=state
    if enabled then
        if state.headTransparency==nil then state.headTransparency=head.Transparency; state.headCanCollide=head.CanCollide; local face=head:FindFirstChild("face"); state.face=face and face:Clone() or nil end
        head.Transparency=1; head.CanCollide=false
        local face=head:FindFirstChild("face"); if face then face:Destroy() end
        local old=head:FindFirstChild("RitualHeadlessMesh"); if old then old:Destroy() end
        local mesh=Instance.new("SpecialMesh",head); mesh.Name="RitualHeadlessMesh"; mesh.MeshType=Enum.MeshType.FileMesh; mesh.MeshId=HEADLESS_MESH_ID; mesh.Scale=Vector3.new(.001,.001,.001)
    else
        local mesh=head:FindFirstChild("RitualHeadlessMesh"); if mesh then mesh:Destroy() end
        if state.headTransparency~=nil then
            head.Transparency=state.headTransparency; head.CanCollide=state.headCanCollide
            if state.face and not head:FindFirstChild("face") then state.face:Clone().Parent=head end
            state.headTransparency=nil; state.headCanCollide=nil; state.face=nil
        end
    end
end

local function applyKorblox(char,enabled)
    local hum=char and char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local state=cosmeticState[char] or {}; cosmeticState[char]=state
    if hum.RigType==Enum.HumanoidRigType.R6 then
        local leg=char:FindFirstChild("Right Leg"); if not leg then return end
        if enabled then
            if not state.r6LegColor then state.r6LegColor=leg.Color; state.r6Meshes={}; for _,v in ipairs(leg:GetChildren()) do if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then table.insert(state.r6Meshes,v:Clone()); v:Destroy() end end end
            leg.Color=Color3.fromRGB(64,64,64); local old=leg:FindFirstChild("RitualKorbloxMesh"); if old then old:Destroy() end
            local mesh=Instance.new("SpecialMesh",leg); mesh.Name="RitualKorbloxMesh"; mesh.MeshType=Enum.MeshType.FileMesh; mesh.MeshId=KORBLOX_MESH_ID; mesh.TextureId=KORBLOX_TEXTURE_ID
        else
            local mesh=leg:FindFirstChild("RitualKorbloxMesh"); if mesh then mesh:Destroy() end
            if state.r6LegColor then leg.Color=state.r6LegColor end
            if state.r6Meshes then for _,v in ipairs(state.r6Meshes) do v:Clone().Parent=leg end end
            state.r6LegColor=nil; state.r6Meshes=nil
        end
    else
        local upper=char:FindFirstChild("RightUpperLeg"); local lower=char:FindFirstChild("RightLowerLeg"); local foot=char:FindFirstChild("RightFoot")
        if not upper then return end
        if enabled then
            if not state.r15Transparency then state.r15Transparency={upper.Transparency,lower and lower.Transparency or 0,foot and foot.Transparency or 0} end
            upper.Transparency=1; if lower then lower.Transparency=1 end; if foot then foot.Transparency=1 end
            local old=char:FindFirstChild("RitualKorbloxLeg"); if old then old:Destroy() end
            local leg=Instance.new("Part",char); leg.Name="RitualKorbloxLeg"; leg.Size=Vector3.new(1,2,1); leg.Anchored=false; leg.CanCollide=false; leg.Massless=true; leg.Color=Color3.fromRGB(64,64,64)
            local mesh=Instance.new("SpecialMesh",leg); mesh.MeshType=Enum.MeshType.FileMesh; mesh.MeshId=KORBLOX_MESH_ID; mesh.TextureId=KORBLOX_TEXTURE_ID
            local weld=Instance.new("Weld",leg); weld.Name="RitualKorbloxWeld"; weld.Part0=upper; weld.Part1=leg; weld.C0=CFrame.new(0,-.8,0)
        else
            local vals=state.r15Transparency
            if vals then upper.Transparency=vals[1]; if lower then lower.Transparency=vals[2] end; if foot then foot.Transparency=vals[3] end end
            local leg=char:FindFirstChild("RitualKorbloxLeg"); if leg then leg:Destroy() end; state.r15Transparency=nil
        end
    end
end

_GACC.extras.packs=ANIMATION_PACKS
_GACC.extras.getPack=function() return selectedAnimPack end
_GACC.extras.setPack=function(name,applyNow,char)
    if name~="Off" and not ANIMATION_PACKS[name] then return false end
    if applyNow then
        local ok=applyAnimationPack(name,char)
        if ok then selectedAnimPack=name end
        return ok
    end
    selectedAnimPack=name
    return true
end
_GACC.extras.applyPack=applyAnimationPack
_GACC.extras.getHeadless=function() return headlessEnabled end
_GACC.extras.setHeadless=function(on,char) headlessEnabled=on==true; if char then applyHeadless(char,headlessEnabled) end end
_GACC.extras.getKorblox=function() return korbloxEnabled end
_GACC.extras.setKorblox=function(on,char) korbloxEnabled=on==true; if char then applyKorblox(char,korbloxEnabled) end end
_GACC.extras.onCharacter=function(char)
    AnimRefs.originalCharacter=nil
    AnimRefs.originalAnims=nil
    applyHeadless(char,headlessEnabled); applyKorblox(char,korbloxEnabled)
    if selectedAnimPack and ANIMATION_PACKS[selectedAnimPack] then task.spawn(function() task.wait(.2); applyAnimationPack(selectedAnimPack,char) end) end
end
_GACC.extras.reset=function(char)
    selectedAnimPack="Adidas Sports"; headlessEnabled=false; korbloxEnabled=false
    if char then applyHeadless(char,false); applyKorblox(char,false) end
    task.spawn(function() applyAnimationPack(selectedAnimPack) end)
end
end

local refreshSpeedModeLabel,saveConfig
local startUnwalk,stopUnwalk,setupMedusa,stopMedusaCounter
local startAntiRagdoll,stopAntiRagdoll,startAutoLeft,stopAutoLeft,startAutoRight,stopAutoRight
local startAutoTP,stopAutoTP,enableAntiLag,disableAntiLag,enableStretchRez,disableStretchRez
local runDrop,runTPFloor
local startBatDesyncTp,stopBatDesyncTp
local startAutoSteal,stopAutoSteal,toggleCarryMode,toggleLaggerMode

-- ==================== INSTANT RESET ====================
-- Bugra logic, unchanged.
local resetting = false
local instantReset

do
local tpPos = CFrame.new(2000.5, 9911.9, 4000.2)

function instantReset()
    if resetting then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    resetting = true

    local cam = workspace.CurrentCamera
    local lockedCamCFrame = cam.CFrame

    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = lockedCamCFrame

    local prevAntiDie = antiDieEnabled
    antiDieEnabled = false

    RunService:BindToRenderStep("RitualCamLock", Enum.RenderPriority.Camera.Value + 1, function()
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = lockedCamCFrame

        local activeChar = LP.Character
        local activeHrp = activeChar and activeChar:FindFirstChild("HumanoidRootPart")
        if activeHrp then
            activeHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            activeHrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            activeHrp.CFrame = tpPos
        end
    end)

    local respawnConn
    respawnConn = LP.CharacterAdded:Connect(function(newChar)
        if respawnConn then respawnConn:Disconnect() end

        pcall(function()
            RunService:UnbindFromRenderStep("RitualCamLock")
        end)

        local newHum = newChar:WaitForChild("Humanoid", 5)
        task.wait(0.05)

        pcall(function()
            cam.CameraSubject = newHum
            cam.CameraType = Enum.CameraType.Custom
        end)

        antiDieEnabled = prevAntiDie
        resetting = false
    end)
end
end

-- ==================== MEDUSA INSTANT RESET ====================
-- Medusa petrifies you by anchoring your parts. Watching Anchored flip on
-- any body part catches it a frame after it lands, and we reset out of it.
_GACC.medusaResetEnabled = _GACC.medusaResetEnabled or false
_GACC.medusaAnchorConns = {}

local function _medusaOnAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if _GACC.medusaResetEnabled and part.Anchored and not resetting then
            instantReset()
        end
    end)
end

_GACC.stopMedusaReset = function()
    for _, c in pairs(_GACC.medusaAnchorConns) do pcall(function() c:Disconnect() end) end
    _GACC.medusaAnchorConns = {}
end

_GACC.startMedusaReset = function(char)
    _GACC.stopMedusaReset()
    char = char or LP.Character
    if not char or not _GACC.medusaResetEnabled then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(_GACC.medusaAnchorConns, _medusaOnAnchorChanged(part))
        end
    end
    table.insert(_GACC.medusaAnchorConns, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            table.insert(_GACC.medusaAnchorConns, _medusaOnAnchorChanged(part))
        end
    end))
end

-- Auto Reset on Death removed: Medusa Instant Reset replaces it.

-- ==================== ANTI SUMMER BASE ====================
local AntiSummer = {
    antiSummerBaseEnabled = false,
    _antiSummerCleaned = {},
    antiSummerBaseConn = nil,
}

function AntiSummer.isSummerBaseName(name)
    if not name then return false end
    local n = tostring(name):lower()
    return n == "summerbase"
        or n == "summer_base"
        or n:find("summerbase", 1, true) ~= nil
        or n:find("summer_base", 1, true) ~= nil
end

function AntiSummer.isAnchorName(name)
    if not name then return false end
    local n = tostring(name):lower()
    return n == "anchor" or n == "anchors"
end

function AntiSummer.stripBlockingAnchor(obj)
    if not obj or not obj.Parent then return end
    local key = tostring(obj:GetFullName())
    if AntiSummer._antiSummerCleaned[key] then return end
    AntiSummer._antiSummerCleaned[key] = true
    pcall(function()
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.CanCollide = false
            obj.CanQuery = false
            obj.CanTouch = false
            obj.Transparency = 1
        end
        obj:Destroy()
    end)
end

function AntiSummer.cleanSummerBaseAnchors()
    if not AntiSummer.antiSummerBaseEnabled then return end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, plot in ipairs(plots:GetChildren()) do
        local isSummer = AntiSummer.isSummerBaseName(plot.Name)
        if not isSummer then
            for _, d in ipairs(plot:GetDescendants()) do
                if AntiSummer.isSummerBaseName(d.Name) then
                    isSummer = true
                    break
                end
            end
        end
        if not isSummer then continue end
        for _, d in ipairs(plot:GetDescendants()) do
            if AntiSummer.isAnchorName(d.Name) then
                AntiSummer.stripBlockingAnchor(d)
            end
        end
    end
end

function AntiSummer.enable()
    AntiSummer.antiSummerBaseEnabled = true
    AntiSummer._antiSummerCleaned = {}
    AntiSummer.cleanSummerBaseAnchors()
    if AntiSummer.antiSummerBaseConn then
        pcall(function() AntiSummer.antiSummerBaseConn:Disconnect() end)
        AntiSummer.antiSummerBaseConn = nil
    end
    AntiSummer.antiSummerBaseConn = workspace.DescendantAdded:Connect(function(obj)
        if not AntiSummer.antiSummerBaseEnabled then return end
        if not AntiSummer.isAnchorName(obj.Name) then return end
        task.defer(function()
            if not AntiSummer.antiSummerBaseEnabled or not obj.Parent then return end
            local p = obj
            local underPlots, nearSummer = false, false
            while p and p ~= workspace do
                if p.Name == "Plots" or (p.Parent and p.Parent.Name == "Plots") then underPlots = true end
                if AntiSummer.isSummerBaseName(p.Name) then nearSummer = true end
                p = p.Parent
            end
            if underPlots and nearSummer then
                AntiSummer.stripBlockingAnchor(obj)
            end
        end)
    end)
    task.spawn(function()
        while AntiSummer.antiSummerBaseEnabled do
            AntiSummer.cleanSummerBaseAnchors()
            task.wait(5)
        end
    end)
end

function AntiSummer.disable()
    AntiSummer.antiSummerBaseEnabled = false
    if AntiSummer.antiSummerBaseConn then
        pcall(function() AntiSummer.antiSummerBaseConn:Disconnect() end)
        AntiSummer.antiSummerBaseConn = nil
    end
end
-- =====================================================

local function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
            return tool
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
                return tool
            end
        end
    end
    return nil
end

local function resolveBatTool()
    local char = LP.Character
    local function scan(container)
        if not container then return nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("bat", 1, true) or n:find("slap", 1, true) then return tool end
            end
        end
        return nil
    end
    return scan(char) or scan(LP:FindFirstChild("Backpack"))
end

-- Dice Bat engine adapter for Ritual Hub.
_GACC.equipPreferredBatTool = function()
    local char = LP.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bat = resolveBatTool()
    if bat and hum and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
    return bat
end

;(function()
--  AUTO BAT / BAT AIMBOT BACKEND
-- ============================================================
local aimbotSpeed=58
local CONFIG = {
    FollowSpeed = 55, MaxSpeed = 59, ActivateDistance = 13, MinFollowDistance = 1,
    PredictionTime = 0.18, PredictAhead = 1.75, JumpSpeedBoost = 1.5, ActivationDelay = 0.2,
    ServerTickrate = 1/60, PingSampleSize = 10, MinPingComp = 0.03, MaxPingComp = 0.25,
    VelocityHistorySize = 8, AccelHistorySize = 4, AerialHistorySize = 6, VerticalHistorySize = 5,
    VelocitySmoothing = 0.2, AerialSmoothing = 0.15, MaxVelocityChange = 150, MaxHorizontalVel = 80,
    AccelerationWeight = 0.3, Gravity = 196.2, AirControlFactor = 0.8, AerialVelocityDecay = 0.95,
    AerialDirectionWeight = 0.6, MinAirborneTime = 0.08,
}
local State = {
    TargetPlayer=nil, LastTargetPos=nil, TargetVelocity=Vector3.zero, SmoothedVelocity=Vector3.zero,
    VelocityHistory={}, AirborneTime=0, LastActivationTime=0, HighYVelocityTime=0,
    AccelerationHistory={}, LastDirectionChangeTime=0, PreviousDirection=nil,
    WasAirborne=false, AerialVelocityHistory={}, AerialSmoothVelocity=Vector3.zero,
    LastGroundedPosition=nil, LastYVelocity=0, PeakHeight=0, GroundHeight=0,
    IsMultiJumping=false, VerticalVelocityHistory={},
}
local _aimbotTarget = nil
local _aimbotTargetPlr = nil
local aimbotConn = nil

resetAutoBatMotion=function()
	local char=LP.Character
	local hrp=char and char:FindFirstChild("HumanoidRootPart")
	local hum=char and char:FindFirstChildOfClass("Humanoid")
	if hrp then
		hrp.Velocity=hrp.Velocity*0.3
		hrp.AssemblyAngularVelocity=Vector3.zero
	end
	if hum then hum.AutoRotate=true end
end

local function findBat()
	local char=LP.Character
	if not char then return nil end
	for _,tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
	end
	local bp=LP:FindFirstChild("Backpack")
	if bp then
		for _,tool in ipairs(bp:GetChildren()) do
			if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
		end
	end
	return nil
end

local function getClosestTarget()
	local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil,nil end
	local closest,closestPlr,minDist=nil,nil,math.huge
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=LP and plr.Character then
			local tRoot=plr.Character:FindFirstChild("HumanoidRootPart")
			local hum=plr.Character:FindFirstChildOfClass("Humanoid")
			if tRoot and hum and hum.Health>0 then
				local dist=(tRoot.Position-root.Position).Magnitude
				if dist<minDist then minDist=dist;closest=tRoot;closestPlr=plr end
			end
		end
	end
	return closest,closestPlr,minDist
end

-- Get target with stickiness: prefer existing target unless new one is 30% closer
local function getStickyTarget(currentRoot)
	local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil,nil end
	local newClosest,newPlr,newDist=getClosestTarget()
	if not newClosest then return nil,nil end
	if currentRoot and currentRoot.Parent then
		local currentPlr=Players:GetPlayerFromCharacter(currentRoot.Parent)
		local hum=currentRoot.Parent:FindFirstChildOfClass("Humanoid")
		if currentPlr and hum and hum.Health>0 then
			local currentDist=(currentRoot.Position-root.Position).Magnitude
			-- Keep current if new isn't significantly closer (30%) or new is same player
			if currentPlr==newPlr or newDist>currentDist*0.7 then
				return currentRoot,currentPlr
			end
		end
	end
	return newClosest,newPlr
end

local function swingCurrentBat(char)
	if not autoSwingEnabled then return end
	local bat=findBat()
	if bat and bat.Parent==char and bat:IsA("Tool") then
		pcall(function() bat:Activate() end)
	end
end

startBatAimbot=function()
    if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end
    if autoLeftEnabled then
        autoLeftEnabled=false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled=false
        if autoRightSetVisual then autoRightSetVisual(false) end
        stopAutoRight()
    end

    autoBatEnabled=true
    State.AutoBat=true
    State.BatAimbot=true
    if refreshBatMotionAntiDieGuard then refreshBatMotionAntiDieGuard() end

    local hum0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate=false end

    -- Cursed Hub-style AUTO BAT backend.
    local AUTO_BAT_SPEED=58
    local AUTO_BAT_VERT_SPEED=52
    local AUTO_BAT_DIST=-2.8
    local AUTO_BAT_HEIGHT=4.75
    local AUTO_BAT_V_OFF=1
    local AUTO_BAT_TURN_SPEED=285
    local AUTO_BAT_MAX_TURN_RATE=28
    local AUTO_SWING_ENABLED=true

    aimbotConn=RunService.Heartbeat:Connect(function()
        if not autoBatEnabled then return end

        local char=LP.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root then return end

        local bat=findBat()
        if bat and bat.Parent~=char then
            pcall(function() hum:EquipTool(bat) end)
        end

        local target,targetPlr=getStickyTarget(_aimbotTarget)
        if not target then
            _aimbotTarget=nil
            _aimbotTargetPlr=nil
            hum.AutoRotate=true
            root.AssemblyAngularVelocity=Vector3.zero
            root.AssemblyLinearVelocity=Vector3.zero
            return
        end

        _aimbotTarget=target
        _aimbotTargetPlr=targetPlr

        local targetVel=target.AssemblyLinearVelocity
        local aimTargetPos=target.Position
            + (targetVel * math.clamp(targetVel.Magnitude/130,0.05,0.15))
            + Vector3.new(0,AUTO_BAT_V_OFF,0)

        hum.AutoRotate=false

        local look=aimTargetPos-root.Position
        local flatLook=Vector3.new(look.X,0,look.Z)

        if look.Magnitude>0.01 and flatLook.Magnitude>0.01 then
            local targetYaw=math.deg(math.atan2(-flatLook.X,-flatLook.Z))
            local yawDelta=(targetYaw-root.Orientation.Y+180)%360-180
            local targetPitch=math.deg(math.atan2(look.Y,flatLook.Magnitude))
            local pitchDelta=(targetPitch-root.Orientation.X+180)%360-180

            local yawRate=math.clamp(
                math.rad(yawDelta)*AUTO_BAT_TURN_SPEED,
                -AUTO_BAT_MAX_TURN_RATE,
                AUTO_BAT_MAX_TURN_RATE
            )
            local pitchRate=math.clamp(
                math.rad(pitchDelta)*AUTO_BAT_TURN_SPEED,
                -AUTO_BAT_MAX_TURN_RATE,
                AUTO_BAT_MAX_TURN_RATE
            )

            local yawRad=math.rad(root.Orientation.Y)
            local rightAxis=Vector3.new(math.cos(yawRad),0,-math.sin(yawRad))
            root.AssemblyAngularVelocity=Vector3.new(0,yawRate,0)+(rightAxis*pitchRate)
        else
            root.AssemblyAngularVelocity=Vector3.zero
        end

        local dir=look.Magnitude>0.01 and look.Unit or Vector3.zero
        local standPos=aimTargetPos-(dir*AUTO_BAT_DIST)+Vector3.new(0,AUTO_BAT_HEIGHT,0)
        local moveDir=standPos-root.Position
        local hDir=Vector3.new(moveDir.X,0,moveDir.Z)

        local hVel=hDir.Magnitude>0.1 and hDir.Unit*AUTO_BAT_SPEED or Vector3.zero
        local vVel=math.abs(moveDir.Y)>0.1
            and Vector3.new(0,math.sign(moveDir.Y)*AUTO_BAT_VERT_SPEED,0)
            or Vector3.new(0,-2,0)

        root.AssemblyLinearVelocity=hVel+vVel

        if hDir.Magnitude>0.5 then
            hum:Move(hDir.Unit,false)
        end

        if AUTO_SWING_ENABLED and (root.Position-target.Position).Magnitude<6 then
            local swingBat=findBat()
            if swingBat and swingBat:IsA("Tool") then
                pcall(function() swingBat:Activate() end)
            end
        end
    end)
end

stopBatAimbot=function()
    if aimbotConn then aimbotConn:Disconnect();aimbotConn=nil end
    _aimbotTarget=nil
    _aimbotTargetPlr=nil
    autoBatEnabled=false
    State.AutoBat=false
    State.BatAimbot=false

    local char=LP.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity=Vector3.zero
        root.AssemblyAngularVelocity=Vector3.zero
    end

    local hum2=char and char:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate=true end

    State.hittingCooldown=false
    if resetAutoBatMotion then resetAutoBatMotion() end
    if refreshBatMotionAntiDieGuard then refreshBatMotionAntiDieGuard() end
end

local function queueAutoLeftStart()
    autoLeftEnabled=true
    if autoRightEnabled then
        autoRightEnabled=false
        if autoRightSetVisual then autoRightSetVisual(false) end
        stopAutoRight()
    end
    if autoBatEnabled then
        stopBatAimbot()
        if autoBatSetVisual then autoBatSetVisual(false) end
    end
    startAutoLeft()
end

local function queueAutoRightStart()
    autoRightEnabled=true
    if autoLeftEnabled then
        autoLeftEnabled=false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if autoBatEnabled then
        stopBatAimbot()
        if autoBatSetVisual then autoBatSetVisual(false) end
    end
    startAutoRight()
end

local batDesyncTpConn=nil
local hittingCooldownDesync=false

local function getBatDesync()
    local char=LP.Character
    if not char then return nil end

    local tool=char:FindFirstChild("Bat")
    if tool then return tool end

    local bp=LP:FindFirstChild("Backpack")
    if bp then
        tool=bp:FindFirstChild("Bat")
        if tool then
            tool.Parent=char
            return tool
        end
    end

    return nil
end

local function tryHitBatDesync()
    if hittingCooldownDesync then return end
    hittingCooldownDesync=true

    pcall(function()
        local bat=getBatDesync()
        if bat then
            bat:Activate()
            local ev=bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
        end
    end)

    task.delay(0.05,function()
        hittingCooldownDesync=false
    end)
end

local function getClosestPlayerDesync()
    local char=LP.Character
    if not char then return nil,math.huge end

    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil,math.huge end

    local closest,closestDist=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if tr and hum and hum.Health>0 then
                local d=(hrp.Position-tr.Position).Magnitude
                if d<closestDist then
                    closestDist=d
                    closest=p
                end
            end
        end
    end

    return closest,closestDist
end

local function batDesyncTpUpdate()
    if not batDesyncTpEnabled then return end

    local char=LP.Character
    if not char then return end

    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local target,dist=getClosestPlayerDesync()
    if not target or not target.Character then return end

    local tr=target.Character:FindFirstChild("HumanoidRootPart")
    local th=target.Character:FindFirstChildOfClass("Humanoid")
    if not tr or not th or th.Health<=0 then return end

    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(hrp,"PhysicsRepRootPart",tr)
        end)
        pcall(function()
            sethiddenproperty(hrp,"NetworkOwnership",9999)
        end)
    end

    -- Stay within 8 studs, matching the requested TP-Bat behavior.
    local targetPos=tr.Position+Vector3.new(0,0.9,0)
    if dist>8 then
        hrp.CFrame=CFrame.new(targetPos)
    end

    local cam=workspace.CurrentCamera
    if cam then
        cam.CFrame=CFrame.new(cam.CFrame.Position,tr.Position+Vector3.new(0,0.5,0))
    end

    tryHitBatDesync()
end

function startBatDesyncTp()
    if _GACC.safeBlocked and _GACC.safeBlocked() then
        batDesyncTpEnabled=false
        if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
        return
    end

    if batDesyncTpConn then return end

    batDesyncTpEnabled=true
    batDesyncTpConn=RunService.Heartbeat:Connect(batDesyncTpUpdate)
end

function stopBatDesyncTp()
    if batDesyncTpConn then
        batDesyncTpConn:Disconnect()
        batDesyncTpConn=nil
    end
    batDesyncTpEnabled=false
    hittingCooldownDesync=false

    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(hrp,"PhysicsRepRootPart",nil)
            end
        end)
    end
end

function queueAutoBatStart()
    startBatAimbot()
end

function resetAutoBatMotion()
    local char=LP.Character
    if char then
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if root then
            root.AssemblyLinearVelocity=root.AssemblyLinearVelocity*0.3
            root.AssemblyAngularVelocity=Vector3.zero
        end
        if hum then hum.AutoRotate=true end
    end
end

startAutoSwingLoop=function() end
stopAutoSwingLoop=function() end
swingCurrentBat=function() end

LP.CharacterAdded:Connect(function(char)
    if autoBatEnabled then
        task.wait(0.5)
        startBatAimbot()
    end
end)
end)()


local isNearPodiumWithPrompt

local function addShimmerToLabel(lbl,color1,color2)
    local gr=Instance.new("UIGradient",lbl)
    gr.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,  color1 or Color3.fromRGB(150,150,150)),
        ColorSequenceKeypoint.new(0.3,Color3.fromRGB(230,230,230)),
        ColorSequenceKeypoint.new(0.6,color2 or Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,  color1 or Color3.fromRGB(150,150,150))
    })
    gr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3,0),NumberSequenceKeypoint.new(0.5,0,0),NumberSequenceKeypoint.new(1,0.3,0)})
    return gr
end

local fovConn=nil
local function applyFOV()
    if fovConn then fovConn:Disconnect() end
    fovConn=RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        if cam then cam.FieldOfView=math.clamp(fovValue,1,120) end
    end)
end
applyFOV()

function createPingNotificationLegacy()
    if pingNotification then
        pcall(function() pingNotification:Destroy() end)
        pingNotification = nil
    end
    local sg=Instance.new("ScreenGui")
    sg.Name="PingNotification"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true; sg.DisplayOrder=999
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    if not pcall(function() sg.Parent=game:GetService("CoreGui") end) then
        sg.Parent=LP:WaitForChild("PlayerGui")
    end
    local shadow=Instance.new("Frame",sg); shadow.Size=UDim2.fromOffset(316,92); shadow.Position=UDim2.new(1,28,0,29)
    shadow.BackgroundColor3=Color3.fromRGB(0,0,0); shadow.BackgroundTransparency=.52; shadow.BorderSizePixel=0; shadow.ZIndex=8; Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,16)
    local card=Instance.new("CanvasGroup",sg); card.Size=UDim2.fromOffset(316,92); card.Position=UDim2.new(1,24,0,22)
    card.BackgroundColor3=Color3.fromRGB(10,10,15); card.BackgroundTransparency=.04; card.BorderSizePixel=0; card.ZIndex=10; card.ClipsDescendants=true; card.GroupTransparency=.08
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,16)
    local cStroke=Instance.new("UIStroke",card); cStroke.Color=Color3.fromRGB(255,112,90); cStroke.Thickness=1; cStroke.Transparency=.38
    local cardGrad=Instance.new("UIGradient",card); cardGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(24,17,22)),ColorSequenceKeypoint.new(.55,Color3.fromRGB(11,11,17)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,13,20))}); cardGrad.Rotation=12
    local rail=Instance.new("Frame",card); rail.Size=UDim2.new(0,4,1,-18); rail.Position=UDim2.fromOffset(0,9); rail.BackgroundColor3=Color3.fromRGB(255,96,78); rail.BorderSizePixel=0; rail.ZIndex=12; Instance.new("UICorner",rail).CornerRadius=UDim.new(1,0)
    local badge=Instance.new("Frame",card); badge.Size=UDim2.fromOffset(58,58); badge.Position=UDim2.fromOffset(15,17); badge.BackgroundColor3=Color3.fromRGB(232,230,224); badge.BorderSizePixel=0; badge.ZIndex=12; badge.Rotation=-7; Instance.new("UICorner",badge).CornerRadius=UDim.new(0,14)
    local badgeDepth=Instance.new("UIStroke",badge); badgeDepth.Color=Color3.fromRGB(255,108,82); badgeDepth.Thickness=2; badgeDepth.Transparency=.08
    local badgeGrad=Instance.new("UIGradient",badge); badgeGrad.Color=ColorSequence.new(Color3.fromRGB(255,252,244),Color3.fromRGB(150,145,145)); badgeGrad.Rotation=45
    for _,pt in ipairs({{.24,.24},{.76,.24},{.24,.76},{.76,.76}}) do
        local pip=Instance.new("Frame",badge); pip.AnchorPoint=Vector2.new(.5,.5); pip.Position=UDim2.fromScale(pt[1],pt[2]); pip.Size=UDim2.fromOffset(7,7); pip.BackgroundColor3=Color3.fromRGB(34,27,31); pip.BorderSizePixel=0; pip.ZIndex=13; Instance.new("UICorner",pip).CornerRadius=UDim.new(1,0)
    end
    local bang=Instance.new("TextLabel",badge); bang.AnchorPoint=Vector2.new(.5,.5); bang.Position=UDim2.fromScale(.5,.5); bang.Size=UDim2.fromOffset(22,28); bang.BackgroundTransparency=1; bang.Text="!"; bang.TextColor3=Color3.fromRGB(226,65,54); bang.Font=Enum.Font.GothamBlack; bang.TextSize=25; bang.ZIndex=14
    local warnLbl=Instance.new("TextLabel",card); warnLbl.Size=UDim2.fromOffset(112,18); warnLbl.Position=UDim2.fromOffset(87,11); warnLbl.BackgroundTransparency=1; warnLbl.Text="HIGH PING"; warnLbl.TextColor3=Color3.fromRGB(255,238,233); warnLbl.Font=Enum.Font.GothamBlack; warnLbl.TextSize=13; warnLbl.TextXAlignment=Enum.TextXAlignment.Left; warnLbl.ZIndex=12
    local pingLbl=Instance.new("TextLabel",card); pingLbl.Size=UDim2.fromOffset(125,35); pingLbl.Position=UDim2.fromOffset(85,28); pingLbl.BackgroundTransparency=1; pingLbl.Text="-- ms"; pingLbl.TextColor3=Color3.fromRGB(255,112,90); pingLbl.Font=Enum.Font.GothamBlack; pingLbl.TextSize=24; pingLbl.TextXAlignment=Enum.TextXAlignment.Left; pingLbl.ZIndex=12
    local duelPill=Instance.new("Frame",card); duelPill.Size=UDim2.fromOffset(104,24); duelPill.Position=UDim2.fromOffset(85,61); duelPill.BackgroundColor3=Color3.fromRGB(57,39,21); duelPill.BackgroundTransparency=.12; duelPill.BorderSizePixel=0; duelPill.ZIndex=12; Instance.new("UICorner",duelPill).CornerRadius=UDim.new(1,0)
    local duelStroke=Instance.new("UIStroke",duelPill); duelStroke.Color=Color3.fromRGB(255,183,77); duelStroke.Transparency=.45; duelStroke.Thickness=1
    local duelDot=Instance.new("Frame",duelPill); duelDot.AnchorPoint=Vector2.new(.5,.5); duelDot.Position=UDim2.new(0,12,.5,0); duelDot.Size=UDim2.fromOffset(6,6); duelDot.BackgroundColor3=Color3.fromRGB(255,183,77); duelDot.BorderSizePixel=0; duelDot.ZIndex=13; Instance.new("UICorner",duelDot).CornerRadius=UDim.new(1,0)
    local duelLbl=Instance.new("TextLabel",duelPill); duelLbl.Size=UDim2.new(1,-24,1,0); duelLbl.Position=UDim2.fromOffset(22,0); duelLbl.BackgroundTransparency=1; duelLbl.Text="AVOID DUELS"; duelLbl.TextColor3=Color3.fromRGB(255,207,130); duelLbl.Font=Enum.Font.GothamBlack; duelLbl.TextSize=9; duelLbl.TextXAlignment=Enum.TextXAlignment.Left; duelLbl.ZIndex=13
    local meter=Instance.new("Frame",card); meter.Size=UDim2.fromOffset(72,38); meter.Position=UDim2.fromOffset(213,34); meter.BackgroundTransparency=1; meter.ZIndex=12
    local bars={}
    for i=1,5 do
        local bar=Instance.new("Frame",meter); bar.AnchorPoint=Vector2.new(0,1); bar.Position=UDim2.fromOffset((i-1)*14,38); bar.Size=UDim2.fromOffset(8,8+i*5); bar.BackgroundColor3=Color3.fromRGB(255,104,84); bar.BackgroundTransparency=.72; bar.BorderSizePixel=0; bar.ZIndex=13; Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); bars[i]=bar
    end
    local closeBtn=Instance.new("TextButton",card); closeBtn.Size=UDim2.fromOffset(22,22); closeBtn.Position=UDim2.new(1,-28,0,7); closeBtn.BackgroundColor3=Color3.fromRGB(31,25,30); closeBtn.BorderSizePixel=0; closeBtn.ZIndex=15; Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(1,0); closeBtn.Text="×"; closeBtn.TextColor3=Color3.fromRGB(173,157,163); closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=15
    closeBtn.MouseButton1Click:Connect(function()
        if pingNotification then pcall(function() pingNotification:Destroy() end); pingNotification=nil end
    end)
    TweenService:Create(card,TweenInfo.new(.58,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(1,-336,0,22),GroupTransparency=0}):Play()
    TweenService:Create(shadow,TweenInfo.new(.58,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(1,-332,0,29)}):Play()
    TweenService:Create(badge,TweenInfo.new(.72,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=0}):Play()
    task.spawn(function()
        local t=0
        while card and card.Parent do
            t=t+0.04
            pcall(function()
                local ping=math.floor(Players.LocalPlayer:GetNetworkPing()*1000)
                pingLbl.Text=tostring(ping).." ms"
                local severity=math.clamp((ping-80)/120,0,1)
                local hot=Color3.fromRGB(255,math.floor(166-82*severity),math.floor(91-28*severity)); pingLbl.TextColor3=hot; rail.BackgroundColor3=hot; badgeDepth.Color=hot
                local active=math.clamp(math.ceil(ping/45),1,5)
                for i,bar in ipairs(bars) do bar.BackgroundColor3=hot; bar.BackgroundTransparency=i<=active and .08 or .76 end
            end)
            local pulse=math.abs(math.sin(t*3.2)); cStroke.Transparency=.3+pulse*.32; duelDot.BackgroundTransparency=.05+pulse*.45; badge.Rotation=math.sin(t*2.4)*2
            task.wait(0.08)
        end
    end)
    task.delay(7,function()
        if card and card.Parent then
            TweenService:Create(card,TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(1,24,0,22),GroupTransparency=1}):Play()
            TweenService:Create(shadow,TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(1,28,0,29),BackgroundTransparency=1}):Play()
            task.delay(0.4,function()
                if sg then pcall(function() sg:Destroy() end) end
                pingNotification=nil
            end)
        end
    end)
    pingNotification=sg
    return sg
end

local function createPingNotification()
    if pingNotification then pcall(function() pingNotification:Destroy() end);pingNotification=nil end
    local sg=Instance.new("ScreenGui");sg.Name="PingNotification";sg.ResetOnSpawn=false;sg.IgnoreGuiInset=true;sg.DisplayOrder=999
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
    if not pcall(function() sg.Parent=game:GetService("CoreGui") end) then sg.Parent=LP:WaitForChild("PlayerGui") end
    local shadow=Instance.new("Frame",sg);shadow.Size=UDim2.fromOffset(232,58);shadow.Position=UDim2.new(1,20,0,19);shadow.BackgroundColor3=Color3.fromRGB(0,0,0);shadow.BackgroundTransparency=.62;shadow.BorderSizePixel=0;shadow.ZIndex=8;Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,9)
    local card=Instance.new("Frame",sg);card.Size=UDim2.fromOffset(232,58);card.Position=UDim2.new(1,16,0,14);card.BackgroundColor3=Color3.fromRGB(10,10,13);card.BackgroundTransparency=.06;card.BorderSizePixel=0;card.ZIndex=10;card.ClipsDescendants=true;Instance.new("UICorner",card).CornerRadius=UDim.new(0,9)
    local stroke=Instance.new("UIStroke",card);stroke.Color=Color3.fromRGB(66,67,75);stroke.Thickness=1;stroke.Transparency=.25
    local rail=Instance.new("Frame",card);rail.Size=UDim2.new(0,3,1,0);rail.BackgroundColor3=Color3.fromRGB(225,86,78);rail.BorderSizePixel=0;rail.ZIndex=12
    local dot=Instance.new("Frame",card);dot.Size=UDim2.fromOffset(7,7);dot.Position=UDim2.fromOffset(14,13);dot.BackgroundColor3=Color3.fromRGB(225,86,78);dot.BorderSizePixel=0;dot.ZIndex=12;Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local warn=Instance.new("TextLabel",card);warn.Size=UDim2.fromOffset(98,18);warn.Position=UDim2.fromOffset(28,7);warn.BackgroundTransparency=1;warn.Text="HIGH PING";warn.TextColor3=Color3.fromRGB(232,233,238);warn.Font=Enum.Font.GothamBold;warn.TextSize=11;warn.TextXAlignment=Enum.TextXAlignment.Left;warn.ZIndex=12
    local duel=Instance.new("TextLabel",card);duel.Size=UDim2.fromOffset(120,17);duel.Position=UDim2.fromOffset(14,31);duel.BackgroundTransparency=1;duel.Text="Avoid duels";duel.TextColor3=Color3.fromRGB(155,157,167);duel.Font=Enum.Font.GothamMedium;duel.TextSize=10;duel.TextXAlignment=Enum.TextXAlignment.Left;duel.ZIndex=12
    local pingLbl=Instance.new("TextLabel",card);pingLbl.Size=UDim2.fromOffset(72,24);pingLbl.Position=UDim2.new(1,-98,0,17);pingLbl.BackgroundTransparency=1;pingLbl.Text="-- ms";pingLbl.TextColor3=Color3.fromRGB(224,226,232);pingLbl.Font=Enum.Font.GothamBold;pingLbl.TextSize=15;pingLbl.TextXAlignment=Enum.TextXAlignment.Right;pingLbl.ZIndex=12
    local close=Instance.new("TextButton",card);close.Size=UDim2.fromOffset(20,20);close.Position=UDim2.new(1,-24,0,5);close.BackgroundTransparency=1;close.BorderSizePixel=0;close.ZIndex=15;close.Text="X";close.TextColor3=Color3.fromRGB(115,117,126);close.Font=Enum.Font.GothamBold;close.TextSize=10
    close.MouseButton1Click:Connect(function() if pingNotification then pcall(function() pingNotification:Destroy() end);pingNotification=nil end end)
    TweenService:Create(card,TweenInfo.new(.42,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(1,-248,0,14)}):Play()
    TweenService:Create(shadow,TweenInfo.new(.42,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(1,-244,0,19)}):Play()
    task.spawn(function()
        while card and card.Parent do
            pcall(function() local ping=math.floor(Players.LocalPlayer:GetNetworkPing()*1000);pingLbl.Text=tostring(ping).." ms";pingLbl.TextColor3=ping>=180 and Color3.fromRGB(238,103,92) or Color3.fromRGB(224,226,232) end)
            task.wait(.2)
        end
    end)
    task.delay(7,function()
        if card and card.Parent then
            TweenService:Create(card,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(1,16,0,14)}):Play()
            TweenService:Create(shadow,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(1,20,0,19),BackgroundTransparency=1}):Play()
            task.delay(.34,function() if sg then pcall(function() sg:Destroy() end) end;pingNotification=nil end)
        end
    end)
    pingNotification=sg
    return sg
end

task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            local ping = math.floor(Players.LocalPlayer:GetNetworkPing()*1000)
            if ping > 100 then
                if not pingNotification then
                    createPingNotification()
                end
            else
                if pingNotification then
                    pcall(function() pingNotification:Destroy() end)
                    pingNotification = nil
                end
            end
        end)
    end
end)

-- ==================== OVERHEAD GUI (Ragdoll Timer, Discord, Speed) ====================
local Overhead = {}

Overhead.headIndicator = nil
Overhead.overheadSpeedLabel = nil
Overhead.ragdollTimerThread = nil
Overhead.ragdollTimerRemaining = 0
Overhead.isRagdollActive = false

function Overhead.setupHeadIndicator(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local old = head:FindFirstChild("MoveeHeadIndicator")
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "MoveeHeadIndicator"
    bb.Size = UDim2.new(0, 240, 0, 76)
    bb.StudsOffset = Vector3.new(0, 3.35, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Parent = head

    -- Ragdoll Timer (bigger, thick font)
    local ragdollLbl = Instance.new("TextLabel")
    ragdollLbl.Name = "RagdollTimer"
    ragdollLbl.Size = UDim2.new(1, 0, 0, 20)
    ragdollLbl.Position = UDim2.new(0, 0, 0, 0)
    ragdollLbl.BackgroundTransparency = 1
    ragdollLbl.Text = ""
    ragdollLbl.TextColor3 = Color3.fromRGB(0, 110, 200)
    ragdollLbl.Font = Enum.Font.GothamBlack
    ragdollLbl.TextSize = 16
    ragdollLbl.TextStrokeColor3 = Color3.fromRGB(0, 25, 50)
    ragdollLbl.TextStrokeTransparency = 0.35
    ragdollLbl.ZIndex = 11
    ragdollLbl.Parent = bb

    -- Discord
    local discordLbl = Instance.new("TextLabel")
    discordLbl.Name = "Discord"
    discordLbl.Size = UDim2.new(1, 0, 0, 18)
    discordLbl.Position = UDim2.new(0, 0, 0, 20)
    discordLbl.BackgroundTransparency = 1
    discordLbl.Text = "discord.gg/ritualhub"
    discordLbl.TextColor3 = Color3.fromRGB(0, 110, 200)
    discordLbl.Font = Enum.Font.GothamBlack
    discordLbl.TextSize = 14
    discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 25, 50)
    discordLbl.TextStrokeTransparency = 0.35
    discordLbl.ZIndex = 10
    discordLbl.Parent = bb

    -- Separator line
    local line = Instance.new("Frame")
    line.Name = "Separator"
    line.Size = UDim2.new(0.60, 0, 0, 1)
    line.Position = UDim2.new(0.20, 0, 0, 42)
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.1
    line.BorderSizePixel = 0
    line.ZIndex = 9
    line.Parent = bb

    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(1, 0)
    lineCorner.Parent = line

    -- Speed label
    local speedLbl = Instance.new("TextLabel")
    speedLbl.Name = "Speed"
    speedLbl.Size = UDim2.new(1, 0, 0, 22)
    speedLbl.Position = UDim2.new(0, 0, 0, 46)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "Speed: 0"
    speedLbl.TextColor3 = Color3.fromRGB(0, 110, 200)
    speedLbl.Font = Enum.Font.GothamBlack
    speedLbl.TextSize = 16
    speedLbl.TextStrokeColor3 = Color3.fromRGB(0, 25, 50)
    speedLbl.TextStrokeTransparency = 0.35
    speedLbl.ZIndex = 10
    speedLbl.Parent = bb

    Overhead.headIndicator = {
        bb = bb,
        ragdollTimer = ragdollLbl,
        discord = discordLbl,
        speed = speedLbl,
        line = line
    }
    Overhead.overheadSpeedLabel = speedLbl
end

function Overhead.updateOverheadSpeed(speed)
    if not Overhead.overheadSpeedLabel then return end
    local rounded = math.floor(speed * 10 + 0.5) / 10
    if math.abs(rounded - math.floor(rounded)) < 0.05 then
        Overhead.overheadSpeedLabel.Text = string.format("Speed: %d", math.floor(rounded + 0.5))
    else
        Overhead.overheadSpeedLabel.Text = string.format("Speed: %.1f", rounded)
    end
end

function Overhead.updateRagdollTimer(duration)
    if Overhead.ragdollTimerThread then
        task.cancel(Overhead.ragdollTimerThread)
        Overhead.ragdollTimerThread = nil
    end

    if duration <= 0 or not ragdollGuiEnabled then
        Overhead.isRagdollActive = false
        if Overhead.headIndicator and Overhead.headIndicator.ragdollTimer then
            Overhead.headIndicator.ragdollTimer.Text = ""
        end
        return
    end

    Overhead.isRagdollActive = true
    local startTime = tick()
    Overhead.ragdollTimerRemaining = duration

    Overhead.ragdollTimerThread = task.spawn(function()
        while Overhead.isRagdollActive and Overhead.ragdollTimerRemaining > 0 do
            local remaining = math.max(0, duration - (tick() - startTime))
            Overhead.ragdollTimerRemaining = remaining

            if Overhead.headIndicator and Overhead.headIndicator.ragdollTimer then
                Overhead.headIndicator.ragdollTimer.Text = string.format("%.1fs", remaining)
            end

            if remaining <= 0 then
                Overhead.isRagdollActive = false
                if Overhead.headIndicator and Overhead.headIndicator.ragdollTimer then
                    Overhead.headIndicator.ragdollTimer.Text = ""
                end
                break
            end
            task.wait(0.05)
        end
        Overhead.ragdollTimerThread = nil
    end)
end

function Overhead.onHumanoidStateChanged(_, new)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if (new == Enum.HumanoidStateType.Physics
        or new == Enum.HumanoidStateType.Ragdoll
        or new == Enum.HumanoidStateType.FallingDown)
        and not hum.PlatformStand then
        Overhead.updateRagdollTimer(2.6)
    end
end

function Overhead.onMedusaStateChanged()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.PlatformStand then
        Overhead.updateRagdollTimer(4.5)
    end
end

function Overhead.setupRagdollTriggers()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.StateChanged:Connect(Overhead.onHumanoidStateChanged)
        hum:GetPropertyChangedSignal("PlatformStand"):Connect(Overhead.onMedusaStateChanged)
    end
end
-- =====================================================

-- Setup overhead on initial character and on respawn
if player.Character then
    Overhead.setupHeadIndicator(player.Character)
    Overhead.setupRagdollTriggers()
end
player.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    Overhead.setupHeadIndicator(char)
    Overhead.setupRagdollTriggers()
end)

-- Speed update loop for local player
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and Overhead.overheadSpeedLabel then
            local v = hrp.AssemblyLinearVelocity or hrp.Velocity
            local speed = Vector3.new(v.X, 0, v.Z).Magnitude
            Overhead.updateOverheadSpeed(speed)
        end
    end
end)

-- ==================== DICE ESP ====================
do
local function removePlayerHighlight(targetPlayer)
    local obj=espObjects[targetPlayer]
    if obj then
        if obj.marker then pcall(function() obj.marker:Destroy() end)
        elseif obj.highlight then pcall(function() obj.highlight:Destroy() end) end
    end
    espObjects[targetPlayer]=nil
end

local function attachPlayerHighlight(targetPlayer,character)
    if not espEnabled or targetPlayer==LP or not character then return end
    local root=character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart",5)
    if not root or not espEnabled or character~=targetPlayer.Character then return end
    removePlayerHighlight(targetPlayer)
    local marker=Instance.new("Part")
    marker.Name="DicePlayerLocation"; marker.Size=Vector3.new(2.6,5.2,2.1); marker.CFrame=root.CFrame
    marker.Transparency=.99; marker.CanCollide=false; marker.CanTouch=false; marker.CanQuery=false
    marker.CastShadow=false; marker.Massless=true; marker.Parent=character
    local weld=Instance.new("WeldConstraint",marker); weld.Part0=root; weld.Part1=marker
    local highlight=Instance.new("Highlight")
    highlight.Name="DicePlayerHighlight"; highlight.Adornee=marker
    highlight.FillColor=Color3.fromRGB(0,110,255); highlight.OutlineColor=Color3.fromRGB(70,170,255)
    highlight.FillTransparency=.78; highlight.OutlineTransparency=0.02
    highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; highlight.Parent=marker
    espObjects[targetPlayer]={highlight=highlight,marker=marker}
end

local function setupPlayerHighlight(targetPlayer)
    if targetPlayer==LP then return end
    if targetPlayer.Character then task.spawn(attachPlayerHighlight,targetPlayer,targetPlayer.Character) end
    table.insert(espConnections,targetPlayer.CharacterAdded:Connect(function(character)
        if espEnabled then task.spawn(attachPlayerHighlight,targetPlayer,character) end
    end))
end

_GACC.startESP=function()
    if espEnabled then return end
    _GACC.playerHighlightEnabled=true; espEnabled=true
    for _,targetPlayer in ipairs(Players:GetPlayers()) do setupPlayerHighlight(targetPlayer) end
    table.insert(espConnections,Players.PlayerAdded:Connect(function(targetPlayer)
        if espEnabled then setupPlayerHighlight(targetPlayer) end
    end))
    table.insert(espConnections,Players.PlayerRemoving:Connect(removePlayerHighlight))
end

_GACC.stopESP=function()
    _GACC.playerHighlightEnabled=false; espEnabled=false
    for _,connection in ipairs(espConnections) do pcall(function() connection:Disconnect() end) end
    espConnections={}
    for _,obj in pairs(espObjects) do
        if obj.marker then pcall(function() obj.marker:Destroy() end)
        elseif obj.highlight then pcall(function() obj.highlight:Destroy() end) end
    end
    espObjects={}
end
end

local function setupSpeedIndicator(char)
    -- This function is replaced by Overhead system; we keep it empty to avoid conflicts.
    -- The speed label is handled by Overhead.
end

-- ==================== SPEED MODE STATE ====================
-- speedMode is the single source of truth. The legacy booleans are mirrors only.
-- GUI edits always change the live numeric variables used by movement.
local speedMode = "Normal"
local manualSpeedOverride = false
local applyActiveHumanoidSpeed

local function setSpeedMode(mode)
    if mode ~= "Normal" and mode ~= "Carry" and mode ~= "Lagger" and mode ~= "Lagger Carry" then
        mode = "Normal"
    end

    -- IMPORTANT: changing the mode must also remove any movement constraint
    -- left behind by a previous mode.  Otherwise an old LinearVelocity can
    -- keep forcing the old Carry/Lagger speed even after the toggle is off.
    speedMode = mode
    carrySpeedActive = (mode == "Carry" or mode == "Lagger Carry")
    laggerModeEnabled = (mode == "Lagger" or mode == "Lagger Carry")

    -- Also apply the selected speed directly to the Humanoid. The previous
    -- fix only cleared movement constraints; if the game resets/holds
    -- Humanoid.WalkSpeed at its default (often 16), the selected mode could
    -- still appear stuck at 16.
    if applyActiveHumanoidSpeed then pcall(applyActiveHumanoidSpeed) end

    pcall(function()
        local char = LP and LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local oldLV = hrp:FindFirstChild("_RHSpeedLV")
            if oldLV then oldLV:Destroy() end
            local v = hrp.AssemblyLinearVelocity
            -- Preserve vertical velocity, but discard horizontal velocity from
            -- the previous mode so the next frame starts from the new speed.
            hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        end
    end)

    if refreshSpeedModeLabel then refreshSpeedModeLabel() end
    if _GACC.safeCarryVisual then pcall(_GACC.safeCarryVisual, carrySpeedActive) end
    if _GACC.safeLaggerVisual then pcall(_GACC.safeLaggerVisual, laggerModeEnabled) end
end

local function syncSpeedMode()
    -- Never let stale legacy booleans overwrite the authoritative mode.
    -- They are kept synchronized by setSpeedMode().
    if speedMode ~= "Normal" and speedMode ~= "Carry" and speedMode ~= "Lagger" and speedMode ~= "Lagger Carry" then
        speedMode = "Normal"
    end
    local wantCarry = (speedMode == "Carry" or speedMode == "Lagger Carry")
    local wantLagger = (speedMode == "Lagger" or speedMode == "Lagger Carry")
    if carrySpeedActive ~= wantCarry or laggerModeEnabled ~= wantLagger then
        carrySpeedActive = wantCarry
        laggerModeEnabled = wantLagger
    end
    return speedMode
end

local function getActiveMoveSpeed()
    local mode = syncSpeedMode()
    if mode == "Lagger Carry" then
        return math.max(0, tonumber(LAGGER_CARRY_SPEED) or 0)
    elseif mode == "Lagger" then
        return math.max(0, tonumber(LAGGER_SPEED) or 0)
    elseif mode == "Carry" then
        return math.max(0, tonumber(CS) or 0)
    else
        return math.max(0, tonumber(NS) or 0)
    end
end

local function _validateSpeedState()
    return syncSpeedMode()
end

applyActiveHumanoidSpeed = function()
    local char = LP and LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local mode = syncSpeedMode()
    local speed
    if mode == "Lagger Carry" then
        speed = tonumber(LAGGER_CARRY_SPEED) or 15
    elseif mode == "Lagger" then
        speed = tonumber(LAGGER_SPEED) or 30
    elseif mode == "Carry" then
        speed = tonumber(CS) or 29
    else
        speed = tonumber(NS) or 59
    end
    if speed >= 0 then hum.WalkSpeed = speed end
end

local function getAutoPathSpeed()
    local mode = syncSpeedMode()
    if mode == "Lagger Carry" then
        return math.max(0, tonumber(LAGGER_CARRY_SPEED) or 0)
    elseif mode == "Lagger" then
        return math.max(0, tonumber(LAGGER_SPEED) or 0)
    else
        return math.max(0, tonumber(NS) or 0)
    end
end
do
local _autoSwitchWasSteal=false
local _autoSwitchSavedMode=nil

local function updateAutoSwitchSpeed()
    if manualSpeedOverride then return end
    if not autoSwitchSpeedEnabled then
        if _autoSwitchWasSteal then
            setSpeedMode(_autoSwitchSavedMode or "Normal")
        end
        _autoSwitchWasSteal=false
        _autoSwitchSavedMode=nil
        return
    end

    local char=LP.Character
    if not char then return end
    local h=char:FindFirstChildOfClass("Humanoid")
    if not h then return end

    local isStealSpeed=h.WalkSpeed<25
    if isStealSpeed==_autoSwitchWasSteal then return end
    _autoSwitchWasSteal=isStealSpeed

    if isStealSpeed then
        if not _autoSwitchSavedMode then _autoSwitchSavedMode=speedMode end
        setSpeedMode("Carry")
    else
        setSpeedMode(_autoSwitchSavedMode or "Normal")
        _autoSwitchSavedMode=nil
    end

    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
end

task.spawn(function()
    while true do
        task.wait(0.1)
        updateAutoSwitchSpeed()
    end
end)
end

local function startHoldInfJump()
    if holdInfJumpConn then holdInfJumpConn:Disconnect() end
    holdInfJumpConn=RunService.Heartbeat:Connect(function()
        if not infJumpEnabled then return end
        local char=LP.Character;if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
        local isJumpHeld=UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump==true)
        if isJumpHeld and root.Velocity.Y<35 then root.Velocity=Vector3.new(root.Velocity.X,55,root.Velocity.Z) end
        if root.Velocity.Y<-120 then root.Velocity=Vector3.new(root.Velocity.X,-120,root.Velocity.Z) end
    end)
end

local function stopHoldInfJump() if holdInfJumpConn then holdInfJumpConn:Disconnect();holdInfJumpConn=nil end end


local KB={DropBrainrot={kb=nil,gp=nil},AutoLeft={kb=nil,gp=nil},AutoRight={kb=nil,gp=nil},AutoBat={kb=nil,gp=nil},TPFloor={kb=nil,gp=nil},GuiHide={kb=nil,gp=nil},SpeedToggle={kb=nil,gp=nil},LaggerToggle={kb=nil,gp=nil},InstantReset={kb=nil,gp=nil},TpBat={kb=nil,gp=nil}}
-- Auto path waypoints (Ritual Hub coords)
local AP_L1,AP_L2=Vector3.new(-476.48,-6.28,92.73),Vector3.new(-483.12,-4.95,94.80)
local AP_R1,AP_R2=Vector3.new(-476.16,-6.52,25.62),Vector3.new(-483.06,-5.03,25.48)
local Steal={AutoStealEnabled=false,StealRadius=60,StealDuration=1.4,Data={}}
local stealMode="normal" 
local SemiSteal={State={active=false,startTime=0,duration=1.4,progress=0,inRange=false,paused=false,phase="idle",label="",lastResult="",lastResultTime=0,totalSteals=0,failedSteals=0},CONFIG={HOLD_MIN=1.3,HOLD_MAX=2.6,ENTRY_DELAY=0.3,COOLDOWN=.05,STEAL_RANGE=9,PRIME_RANGE=80,RADIUS=60,DURATION=1.4,DELAY_RADIUS=8,STOP_TIME=1.29,STOP_TIME_ENABLED=false}}
local startSemiAutoSteal,stopSemiAutoSteal

-- Ritual Hub steal presets. Fixed on purpose - V modes expose no settings.
_GACC.V_PCT      = { v1=0.74, v2=0.80, v3=0.85, v4=0.45 }
_GACC.safeModeEnabled = _GACC.safeModeEnabled or false

-- ==================== SAFE MODE ====================
-- Locks only while you are carrying a brainrot. Countdown detection was
-- removed on purpose: nobody runs the auto paths during a 5-4-3-2-1, and
-- holding the lock through "GO" cost a head start every round.
_GACC.safeHoldingBrainrot=function()
    local ok,val=pcall(function() return LP:GetAttribute("Stealing") end)
    if ok and val==true then return true end
    local ok2,val2=pcall(function() return LP:GetAttribute("AntiKick") end)
    if ok2 and val2==true then return true end
    local char=LP.Character
    if char then
        local ok3,val3=pcall(function() return char:GetAttribute("Stealing") end)
        if ok3 and val3==true then return true end
    end
    if _GACC.autoCarryDetect then
        local okCarry,carrying=pcall(_GACC.autoCarryDetect)
        if okCarry and carrying then return true end
    end
    return false
end

_GACC.safeIsLocked=function()
    if not _GACC.safeModeEnabled then return false end
    return _GACC.safeHoldingBrainrot()
end
_GACC.V_RADIUS   = 61
_GACC.V_DURATION = 1.3
_GACC.V_DELAYRAD = 9
_GACC.isVersionMode = function(m) return _GACC.V_PCT[m or ""] ~= nil end
local isStealing,stealStartTime=false,nil
local Conns={autoSteal=nil,antiRag=nil,anchor={},batCounter=nil}

-- ==================== BAT COUNTER ====================
-- Watches for you being knocked into a ragdoll state and swings back
-- automatically. Ported as-is from the reference: fire the tool's RemoteEvent
-- twice 0.15s apart when there is one, otherwise Activate() twice.
_GACC.batCounterEnabled = _GACC.batCounterEnabled or false
_GACC.batCounterDebounce = false
_GACC.BAT_COUNTER_LIST = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap",
    "Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}

_GACC.findBatForCounter = function()
    local c = LP.Character; if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(_GACC.BAT_COUNTER_LIST) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    return nil
end

_GACC.swingBatForCounter = function(bat, char)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char then
        if hum2 then pcall(function() hum2:EquipTool(bat) end) end
        task.wait(0.05)
    end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end)
        task.wait(0.15)
        pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end)
        task.wait(0.15)
        pcall(function() bat:Activate() end)
    end
end

_GACC.startBatCounter = function()
    if Conns.batCounter then return end
    Conns.batCounter = RunService.Heartbeat:Connect(function()
        if not _GACC.batCounterEnabled then return end
        if _GACC.batCounterDebounce then return end
        local char = LP.Character; if not char then return end
        local hum2 = char:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
        local st = hum2:GetState()
        if st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown then
            _GACC.batCounterDebounce = true
            task.spawn(function()
                local bat = _GACC.findBatForCounter()
                if bat then pcall(_GACC.swingBatForCounter, bat, char) end
                task.wait(0.5)
                _GACC.batCounterDebounce = false
            end)
        end
    end)
end

_GACC.stopBatCounter = function()
    if Conns.batCounter then Conns.batCounter:Disconnect(); Conns.batCounter = nil end
    _GACC.batCounterDebounce = false
end
local MEDUSA_COOLDOWN=25
local modeValLbl;local lastMoveDir=Vector3.new(0,0,0)
local MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}

local function isRagdollState(hum)
    if not hum then return true end;local st=hum:GetState()
    return hum.PlatformStand or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown
end

do 
local function isMyPlotByName(plotName)
    local plots=workspace:FindFirstChild("Plots");if not plots then return false end
    local plot=plots:FindFirstChild(plotName);if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase");if yb and yb:IsA("BillboardGui") then return yb.Enabled==true end end
    return false
end

isNearPodiumWithPrompt = function()
    local char=LP.Character;local hrpL=char and char:FindFirstChild("HumanoidRootPart");if not hrpL then return false end
    local plots=workspace:FindFirstChild("Plots");if not plots then return false end
    for _,plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums=plot:FindFirstChild("AnimalPodiums");if not podiums then continue end
        for _,podium in ipairs(podiums:GetChildren()) do
            local base=podium:FindFirstChild("Base");if not base then continue end
            local sp=base:FindFirstChild("Spawn");if not sp then continue end
            local d=(hrpL.Position-sp.Position).Magnitude;if d>Steal.StealRadius then continue end
            local att=sp:FindFirstChild("PromptAttachment");if not att then continue end
            for _,obj in ipairs(att:GetChildren()) do if obj:IsA("ProximityPrompt") and obj.Enabled then return true,d end end
        end
    end
    return false,math.huge
end

local function findNearestPrompt()
    local char=LP.Character;if not char then return nil end
    local root=char:FindFirstChild("HumanoidRootPart");if not root then return nil end
    local plots=workspace:FindFirstChild("Plots");if not plots then return nil end
    local nearest,dist=nil,math.huge
    for _,plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods=plot:FindFirstChild("AnimalPodiums");if not pods then continue end
        for _,pod in ipairs(pods:GetChildren()) do
            local base=pod:FindFirstChild("Base");local sp=base and base:FindFirstChild("Spawn")
            if sp then
                local d=(sp.Position-root.Position).Magnitude
                if d<=Steal.StealRadius and dist>d then
                    local att=sp:FindFirstChild("PromptAttachment")
                    if att then for _,prompt in ipairs(att:GetChildren()) do if prompt:IsA("ProximityPrompt") and prompt.ActionText:find("Steal") then nearest,dist=prompt,d end end end
                end
            end
        end
    end
    return nearest
end

local function executeSteal(prompt)
    if isStealing then return end
    if not Steal.Data[prompt] then
        Steal.Data[prompt]={hold={},trigger={},ready=true}
        if getconnections then
            for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do if c.Function then table.insert(Steal.Data[prompt].hold,c.Function) end end
            for _,c in ipairs(getconnections(prompt.Triggered)) do if c.Function then table.insert(Steal.Data[prompt].trigger,c.Function) end end
        end
    end
    local data=Steal.Data[prompt];if not data.ready then return end
    data.ready=false;isStealing=true;stealStartTime=tick()
    task.spawn(function()
        for _,fn in ipairs(data.hold) do task.spawn(fn) end
        task.wait(Steal.StealDuration)
        for _,fn in ipairs(data.trigger) do task.spawn(fn) end
        if _GACC.autoCarryWatch then _GACC.autoCarryWatch(1.25) end
        task.wait(.06)
        data.ready=true;isStealing=false;stealStartTime=nil
    end)
end

-- Cuts anything that flings you while Safe Mode is locked.
_GACC.safeForceStop=function()
    if not _GACC.safeModeEnabled then return end
    if autoBatEnabled then
        autoBatEnabled=false
        pcall(stopBatAimbot)
        if autoBatSetVisual then autoBatSetVisual(false) end
        if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
    end
    if batDesyncTpEnabled then
        batDesyncTpEnabled=false
        if _GACC.stopBatDesyncTp then pcall(_GACC.stopBatDesyncTp) end
        if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
    end
    if autoLeftEnabled then
        autoLeftEnabled=false
        if stopAutoLeft then pcall(stopAutoLeft) end
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
    end
    if autoRightEnabled then
        autoRightEnabled=false
        if stopAutoRight then pcall(stopAutoRight) end
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
    end
end

-- Returns false when Safe Mode is blocking a start request.
_GACC.safeTryStart=function()
    if _GACC.safeIsLocked() then
        _GACC.safeForceStop()
        return false
    end
    return true
end

RunService.Heartbeat:Connect(function()
    if _GACC.safeModeEnabled and _GACC.safeIsLocked() then
        pcall(_GACC.safeForceStop)
    end
end)

startAutoSteal=function()
    if stealMode=="semi" or _GACC.isVersionMode(stealMode) then
        if startSemiAutoSteal then startSemiAutoSteal() end
        return
    end
    if Conns.autoSteal then return end
    Conns.autoSteal=RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        local p=findNearestPrompt();if p then executeSteal(p) end
    end)
end

stopAutoSteal=function()
    if stopSemiAutoSteal then stopSemiAutoSteal() end
    if Conns.autoSteal then Conns.autoSteal:Disconnect();Conns.autoSteal=nil end
    isStealing=false;stealStartTime=nil
end
end 

do
local function _initSemiStealEngine()
local RS = game:GetService("ReplicatedStorage")
local SEMI_CONFIG = SemiSteal.CONFIG 

local syncRemotes = nil
local plots = nil
pcall(function()
    plots = workspace:WaitForChild("Plots", 8)
    local folder = RS:WaitForChild("Packages", 8):WaitForChild("Synchronizer", 8)
    syncRemotes = {
        channelFolder = folder:WaitForChild("Channel", 8),
        routeRemote   = folder:WaitForChild("CommunicationRoute", 8),
        requestData   = folder:FindFirstChild("RequestData"),
    }
end)

local AnimalsData = nil
pcall(function()
    AnimalsData = require(RS:WaitForChild("Datas", 8):WaitForChild("Animals", 8))
end)

local plotAnimalSync = { caches = {}, connections = {} }
local allAnimalsCache = {}
local SemiPromptCache = {}
local SemiCallbackCache = {}

local function splitSyncPath(path)
    if type(path)=="table" then return path end
    local out={}
    for part in string.gmatch(tostring(path),"[^%.]+") do
        table.insert(out, tonumber(part) or part)
    end
    return out
end

local function resolveSyncPath(path, root)
    local current,parent,key=root,nil,nil
    for _,part in ipairs(splitSyncPath(path)) do
        parent=current; key=part
        current=current and current[part] or nil
    end
    return current,parent,key
end

local function applyPlotSyncDiff(channelName, packet)
    local cache=plotAnimalSync.caches[channelName]
    if type(cache)~="table" then return end
    local path,action,a,b=packet[1],packet[2],packet[3],packet[4]
    local current,parent,key=resolveSyncPath(path,cache)
    if action=="Changed" then if parent then parent[key]=a end
    elseif action=="ArrayInsert" then if current then table.insert(current,b,a) end
    elseif action=="ArrayRemoved" then if current then table.remove(current,b) end
    elseif action=="DictionaryInsert" then if current then current[b]=a end
    elseif action=="DictionaryRemoved" then if current then current[b]=nil end
    end
end

local function attachPlotChannel(remote)
    if not plots or not syncRemotes then return end
    if plotAnimalSync.connections[remote] then return end
    local channelName=tostring(remote.Name)
    if not plots:FindFirstChild(channelName) then return end
    if syncRemotes.requestData and plotAnimalSync.caches[channelName]==nil then
        local ok,data=pcall(function() return syncRemotes.requestData:InvokeServer(channelName) end)
        plotAnimalSync.caches[channelName]=(ok and type(data)=="table") and data or {}
    elseif plotAnimalSync.caches[channelName]==nil then
        plotAnimalSync.caches[channelName]={}
    end
    plotAnimalSync.connections[remote]=remote.OnClientEvent:Connect(function(queue)
        for _,packet in ipairs(queue) do applyPlotSyncDiff(channelName,packet) end
    end)
end

local function detachPlotChannel(channelName)
    for remote,conn in pairs(plotAnimalSync.connections) do
        if tostring(remote.Name)==tostring(channelName) then
            conn:Disconnect()
            plotAnimalSync.connections[remote]=nil
            plotAnimalSync.caches[tostring(channelName)]=nil
            break
        end
    end
end

pcall(function()
    if not syncRemotes then return end
    for _,child in ipairs(syncRemotes.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then attachPlotChannel(child) end
    end
    syncRemotes.channelFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then attachPlotChannel(child) end
    end)
    syncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
        for _,action in ipairs(actions) do
            local kind,channelName=action[1],tostring(action[2])
            if not plots:FindFirstChild(channelName) then continue end
            if kind=="ListenerAdded" then
                local r=syncRemotes.channelFolder:FindFirstChild(channelName)
                if r and r:IsA("RemoteEvent") then attachPlotChannel(r) end
            elseif kind=="ListenerRemoved" then detachPlotChannel(channelName) end
        end
    end)
end)

local function getPlotOwner(plot)
    local sign=plot:FindFirstChild("PlotSign")
    local frame=sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
    local label=frame and frame:FindFirstChild("TextLabel")
    if not label or label.Text=="Empty Base" then return nil end
    return label.Text:gsub("'s [Bb]ase$",""):gsub("%s+$","")
end

local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot then return false end
    local plot=plots and plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    
    local sign=plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled==true end end
    
    return getPlotOwner(plot)==LP.DisplayName
end

local function scanAllPlots()
    if not plots then return end
    local newCache={}
    for _,plot in ipairs(plots:GetChildren()) do
        local cache=plotAnimalSync.caches[plot.Name]
        if not cache then continue end
        local animalList=cache.AnimalList
        if type(animalList)~="table" then continue end
        for slot,animalData in pairs(animalList) do
            if type(animalData)=="table" then
                local animalName=animalData.Index
                local displayName=animalName
                if AnimalsData then
                    local info=AnimalsData[animalName]
                    if info then displayName=info.DisplayName or animalName end
                end
                table.insert(newCache,{
                    name=displayName, plot=plot.Name,
                    slot=tostring(slot), uid=plot.Name.."_"..tostring(slot),
                })
            end
        end
    end
    allAnimalsCache=newCache
end

task.spawn(function() while true do task.wait(5); pcall(scanAllPlots) end end)
pcall(scanAllPlots)

local function getAnimalPosition(animalData)
    if not plots then return nil end
    local plot=plots:FindFirstChild(animalData.plot); if not plot then return nil end
    local podiums=plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium=podiums:FindFirstChild(animalData.slot); if not podium then return nil end
    return podium:GetPivot().Position
end

local function distToAnimal(animalData)
    local char=LP.Character; if not char then return math.huge end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return math.huge end
    local pos=getAnimalPosition(animalData); if not pos then return math.huge end
    return (hrp.Position-pos).Magnitude
end

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached=SemiPromptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    if not plots then return nil end
    local plot=plots:FindFirstChild(animalData.plot); if not plot then return nil end
    local podiums=plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
    local podium=podiums:FindFirstChild(animalData.slot); if not podium then return nil end
    local base=podium:FindFirstChild("Base"); if not base then return nil end
    local spawn=base:FindFirstChild("Spawn"); if not spawn then return nil end
    local attach=spawn:FindFirstChild("PromptAttachment"); if not attach then return nil end
    for _,p in ipairs(attach:GetChildren()) do
        if p:IsA("ProximityPrompt") then SemiPromptCache[animalData.uid]=p; return p end
    end
    return nil
end

local function pickClosest()
    local char=LP.Character; if not char then return nil end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best,bestDist=nil,math.huge
    for _,animalData in ipairs(allAnimalsCache) do
        if isMyBaseAnimal(animalData) then continue end
        local pos=getAnimalPosition(animalData); if not pos then continue end
        local dist=(hrp.Position-pos).Magnitude
        if dist>SEMI_CONFIG.PRIME_RANGE then continue end
        if dist<bestDist then bestDist=dist; best=animalData end
    end
    return best
end

local function buildSemiCallbacks(prompt)
    if SemiCallbackCache[prompt] then return end
    local data={holdCallbacks={},triggerCallbacks={},ready=true}
    local ok1,conns1=pcall(getconnections,prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1)=="table" then
        for _,conn in ipairs(conns1) do if type(conn.Function)=="function" then table.insert(data.holdCallbacks,conn.Function) end end
    end
    local ok2,conns2=pcall(getconnections,prompt.Triggered)
    if ok2 and type(conns2)=="table" then
        for _,conn in ipairs(conns2) do if type(conn.Function)=="function" then table.insert(data.triggerCallbacks,conn.Function) end end
    end
    if #data.holdCallbacks>0 or #data.triggerCallbacks>0 then SemiCallbackCache[prompt]=data end
end

local function executeSemiStealAsync(prompt, animalData)
    local data=SemiCallbackCache[prompt]
    if not data or not data.ready then return false end
    data.ready=false
    SemiSteal.State.active=true
    SemiSteal.State.startTime=tick()
    SemiSteal.State.inRange=false
    SemiSteal.State.phase="holding"
    SemiSteal.State.label=animalData.name or "Animal"
    isStealing=true
    SemiSteal.State.progress=0
    SemiSteal.State.duration=SEMI_CONFIG.HOLD_MAX
    task.spawn(function()
        for _,fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        -- hold phase: fill against HOLD_MAX so the bar keeps climbing
        -- through the wait-for-range phase instead of jumping
        local holdEnd=SemiSteal.State.startTime+SEMI_CONFIG.HOLD_MIN
        while tick()<holdEnd do
            SemiSteal.State.progress=math.clamp((tick()-SemiSteal.State.startTime)/SEMI_CONFIG.HOLD_MAX,0,1)
            task.wait()
        end
        SemiSteal.State.phase="waitingRange"
        local alreadyInRange=distToAnimal(animalData)<=(tonumber(Steal.StealRadius) or SEMI_CONFIG.STEAL_RANGE)
        local fired=false
        while true do
            local elapsed=tick()-SemiSteal.State.startTime
            SemiSteal.State.progress=math.clamp(elapsed/SEMI_CONFIG.HOLD_MAX,0,1)
            if elapsed>SEMI_CONFIG.HOLD_MAX then break end
            if not prompt.Parent then break end
            if distToAnimal(animalData)<=(tonumber(Steal.StealRadius) or SEMI_CONFIG.STEAL_RANGE) then
                SemiSteal.State.inRange=true
                if not alreadyInRange then task.wait(SEMI_CONFIG.ENTRY_DELAY) end
                for _,fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
                if _GACC.autoCarryWatch then _GACC.autoCarryWatch(1.25) end
                fired=true
                break
            end
            task.wait()
        end
        if fired then
            SemiSteal.State.progress=1
            SemiSteal.State.totalSteals=SemiSteal.State.totalSteals+1
            SemiSteal.State.lastResult="Stole "..SemiSteal.State.label
        else
            SemiSteal.State.failedSteals=SemiSteal.State.failedSteals+1
            SemiSteal.State.lastResult="Missed window: "..SemiSteal.State.label
        end
        SemiSteal.State.lastResultTime=tick()
        task.wait(SEMI_CONFIG.COOLDOWN)
        SemiSteal.State.active=false
        SemiSteal.State.inRange=false
        SemiSteal.State.phase="idle"
        SemiSteal.State.progress=0
        isStealing=false
        data.ready=true
    end)
    return true
end

local function attemptSemiSteal(prompt, animalData)
    if not prompt or not prompt.Parent then return false end
    buildSemiCallbacks(prompt)
    if not SemiCallbackCache[prompt] then return false end
    return executeSemiStealAsync(prompt, animalData)
end

local semiConn=nil

_GACC.startRitualSemi=function()
    if semiConn then return end
    pcall(scanAllPlots)
    semiConn=RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or stealMode~="semi" or isStealing then return end
        if SemiSteal.State.active then return end
        local target=pickClosest(); if not target then return end
        local prompt=SemiPromptCache[target.uid]
        if not prompt or not prompt.Parent then prompt=findProximityPromptForAnimal(target) end
        if prompt then attemptSemiSteal(prompt,target) end
    end)
end

_GACC.stopRitualSemi=function()
    if semiConn then semiConn:Disconnect(); semiConn=nil end
    SemiSteal.State.active=false
    SemiSteal.State.inRange=false
    SemiSteal.State.phase="idle"
    isStealing=false
end

end
-- Runs the semi engine setup. Spawned because it does WaitForChild on
-- Plots / Packages / Datas and would otherwise stall the load by ~16s.
task.spawn(function() pcall(_initSemiStealEngine) end)
end

do
local opConnection=nil
local opPromptData={}

local function opIsMyPlot(plot)
    local sign=plot and plot:FindFirstChild("PlotSign")
    local yourBase=sign and sign:FindFirstChild("YourBase")
    return yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled==true
end

local function opPromptPosition(prompt)
    local attachment=prompt and prompt.Parent
    local spawn=attachment and attachment.Parent
    return spawn and spawn:IsA("BasePart") and spawn.Position or nil
end

local function findNearestOPPrompt()
    local character=LP.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local plotsFolder=workspace:FindFirstChild("Plots")
    if not root or not plotsFolder then return nil end
    local nearest,minDistance=nil,math.huge
    for _,plot in ipairs(plotsFolder:GetChildren()) do
        if not opIsMyPlot(plot) then
            local podiums=plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _,podium in ipairs(podiums:GetChildren()) do
                    local base=podium:FindFirstChild("Base")
                    local spawn=base and base:FindFirstChild("Spawn")
                    local attachment=spawn and spawn:FindFirstChild("PromptAttachment")
                    if spawn and attachment then
                        local distance=(spawn.Position-root.Position).Magnitude
                        if distance<=_GACC.V_RADIUS and distance<minDistance then
                            for _,child in ipairs(attachment:GetChildren()) do
                                if child:IsA("ProximityPrompt") and child.Enabled and child.ActionText:find("Steal") then
                                    nearest,minDistance=child,distance
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function finishOPSteal(data,fired)
    if fired then
        SemiSteal.State.totalSteals=SemiSteal.State.totalSteals+1
        SemiSteal.State.lastResult="OP steal completed"
        if _GACC.autoCarryWatch then _GACC.autoCarryWatch(1.25) end
    else
        SemiSteal.State.failedSteals=SemiSteal.State.failedSteals+1
        SemiSteal.State.lastResult="OP steal cancelled"
    end
    SemiSteal.State.lastResultTime=tick()
    SemiSteal.State.active=false;SemiSteal.State.progress=0;SemiSteal.State.inRange=false;SemiSteal.State.paused=false;SemiSteal.State.phase="idle"
    isStealing=false;stealStartTime=nil
    data.ready=true
end

local function executeOPSteal(prompt)
    if isStealing or not prompt or not prompt.Parent then return end
    if not opPromptData[prompt] then
        local data={hold={},trigger={},ready=true}
        if getconnections then
            local okHold,holdConnections=pcall(getconnections,prompt.PromptButtonHoldBegan)
            if okHold then for _,connection in ipairs(holdConnections) do if connection.Function then table.insert(data.hold,connection.Function) end end end
            local okTrigger,triggerConnections=pcall(getconnections,prompt.Triggered)
            if okTrigger then for _,connection in ipairs(triggerConnections) do if connection.Function then table.insert(data.trigger,connection.Function) end end end
        end
        opPromptData[prompt]=data
    end
    local data=opPromptData[prompt]
    if not data.ready then return end
    data.ready=false;isStealing=true;stealStartTime=tick()
    local duration=_GACC.V_DURATION
    local vPct=_GACC.V_PCT[stealMode] or 0.74
    SemiSteal.State.active=true;SemiSteal.State.startTime=stealStartTime;SemiSteal.State.duration=duration;SemiSteal.State.progress=0;SemiSteal.State.paused=false;SemiSteal.State.phase="holding";SemiSteal.State.inRange=false
    task.spawn(function()
        for _,callback in ipairs(data.hold) do task.spawn(callback) end
        local fired=false
        local cancelled=false
        local function distanceFromPrompt()
            local position=opPromptPosition(prompt)
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not position or not root then return nil end
            return (root.Position-position).Magnitude
        end
        local function stillRunning()
            return isStealing and Steal.AutoStealEnabled and _GACC.isVersionMode(stealMode) and prompt.Parent~=nil
        end
        if true then
            local stopAt=math.clamp(duration*vPct,.05,duration)
            local started=tick()
            while stillRunning() do
                local elapsed=tick()-started
                local distance=distanceFromPrompt()
                if not distance or distance>_GACC.V_RADIUS then cancelled=true;break end
                SemiSteal.State.inRange=true
                SemiSteal.State.progress=math.clamp(elapsed/duration,0,1)
                if elapsed>=stopAt then break end
                task.wait()
            end
            if not stillRunning() then cancelled=true end
            if not cancelled then
                local stopProgress=math.clamp(stopAt/duration,0,1)
                SemiSteal.State.progress=stopProgress;SemiSteal.State.paused=true;SemiSteal.State.phase="waiting"
                local delayTime=math.max(2.99-stopAt-math.max(duration-stopAt,0),.05)
                local delayStarted=tick()
                local enteredDelayRadius=false
                while stillRunning() and tick()-delayStarted<delayTime do
                    local distance=distanceFromPrompt()
                    if not distance or distance>_GACC.V_RADIUS then cancelled=true;break end
                    SemiSteal.State.inRange=distance<=_GACC.V_DELAYRAD
                    if SemiSteal.State.inRange then enteredDelayRadius=true;break end
                    task.wait()
                end
                if not stillRunning() then cancelled=true end
                if enteredDelayRadius and not cancelled then
                    SemiSteal.State.paused=false;SemiSteal.State.phase="finishing"
                    local finishStarted=tick()
                    local remaining=math.max(duration-stopAt,.05)
                    while stillRunning() do
                        local finishProgress=math.clamp((tick()-finishStarted)/remaining,0,1)
                        SemiSteal.State.progress=stopProgress+finishProgress*(1-stopProgress)
                        if finishProgress>=1 then break end
                        task.wait()
                    end
                    if stillRunning() then
                        for _,callback in ipairs(data.trigger) do task.spawn(callback) end
                        fired=true;SemiSteal.State.progress=1
                    end
                end
            end
        else
            local started=tick()
            while stillRunning() do
                local elapsed=tick()-started
                local distance=distanceFromPrompt()
                if not distance or distance>_GACC.V_RADIUS then cancelled=true;break end
                SemiSteal.State.inRange=true;SemiSteal.State.progress=math.clamp(elapsed/duration,0,1)
                if elapsed>=duration then
                    for _,callback in ipairs(data.trigger) do task.spawn(callback) end
                    fired=true;SemiSteal.State.progress=1
                    break
                end
                task.wait()
            end
        end
        task.wait(.05)
        finishOPSteal(data,fired)
    end)
end

startSemiAutoSteal=function()
    if stealMode=="semi" then
        if _GACC.startRitualSemi then
            _GACC.startRitualSemi()
        else
            -- engine still spinning up (WaitForChild); retry until it lands
            task.spawn(function()
                for _=1,40 do
                    task.wait(0.5)
                    if not Steal.AutoStealEnabled or stealMode~="semi" then return end
                    if _GACC.startRitualSemi then _GACC.startRitualSemi(); return end
                end
            end)
        end
        return
    end
    if not _GACC.isVersionMode(stealMode) then return end
    if opConnection then return end
    opConnection=RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or not _GACC.isVersionMode(stealMode) or isStealing or SemiSteal.State.active then return end
        local prompt=findNearestOPPrompt()
        if prompt then executeOPSteal(prompt) end
    end)
end

stopSemiAutoSteal=function()
    if _GACC.stopRitualSemi then _GACC.stopRitualSemi() end
    if opConnection then opConnection:Disconnect();opConnection=nil end
    for _,data in pairs(opPromptData) do data.ready=true end
    SemiSteal.State.active=false;SemiSteal.State.progress=0;SemiSteal.State.inRange=false;SemiSteal.State.paused=false;SemiSteal.State.phase="idle"
    isStealing=false;stealStartTime=nil
end
end

do
    local function showRoundResultMessage(text)
        local guiName="MoveeRoundResult"
        pcall(function() local old=game:GetService("CoreGui"):FindFirstChild(guiName); if old then old:Destroy() end end)
        pcall(function() local pgui=LP:FindFirstChild("PlayerGui"); local old=pgui and pgui:FindFirstChild(guiName); if old then old:Destroy() end end)
        local sg=Instance.new("ScreenGui"); sg.Name=guiName; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true; sg.DisplayOrder=90
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(sg) end end)
        if not pcall(function() sg.Parent=game:GetService("CoreGui") end) then sg.Parent=LP:WaitForChild("PlayerGui") end
        local lbl=Instance.new("TextLabel",sg)
        lbl.AnchorPoint=Vector2.new(0.5,0.5); lbl.Position=UDim2.new(0.5,0,0.38,0); lbl.Size=UDim2.new(0,500,0,70)
        lbl.BackgroundTransparency=1; lbl.Text=text; lbl.Font=Enum.Font.GothamBlack; lbl.TextSize=44
        lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextStrokeTransparency=0.15; lbl.TextTransparency=1
        local grad=Instance.new("UIGradient",lbl)
        grad.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(230,230,230)),
            ColorSequenceKeypoint.new(0.35,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.65,Color3.fromRGB(150,150,150)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,10,10))
        })
        task.spawn(function()
            local t=0
            while grad and grad.Parent do t=t+0.05; grad.Rotation=math.sin(t*0.6)*25; task.wait(0.04) end
        end)
        TweenService:Create(lbl,TweenInfo.new(0.25),{TextTransparency=0}):Play()
        task.delay(1.6,function()
            if lbl and lbl.Parent then
                TweenService:Create(lbl,TweenInfo.new(0.4),{TextTransparency=1,Position=UDim2.new(0.5,0,0.34,0)}):Play()
            end
        end)
        task.delay(2.2,function() pcall(function() sg:Destroy() end) end)
    end

    local lastRoundText,lastRoundTime="",0
    local function handleRoundText(txt)
        if type(txt)~="string" or txt=="" then return end
        local trimmed=txt:gsub("^%s+",""):gsub("%s+$","")
        local name=trimmed:match("^@?([%w_]+)%s+[Ww][Oo][Nn]%s+[Tt][Hh][Ii][Ss]%s+[Rr][Oo][Uu][Nn][Dd]!?$")
        if not name then return end
        local now=tick()
        if trimmed==lastRoundText and (now-lastRoundTime)<3 then return end
        lastRoundText=trimmed; lastRoundTime=now
        if string.lower(name)==string.lower(LP.Name) then
            showRoundResultMessage("Good job!")
        else
            showRoundResultMessage("Lock In")
        end
    end

    local function isOwnGui(inst)
        local cur=inst
        while cur do
            local n=cur.Name
            if type(n)=="string" and n:sub(1,5)=="Movee" then return true end
            cur=cur.Parent
        end
        return false
    end

    local function watchInstance(inst)
        if not (inst:IsA("TextLabel") or inst:IsA("TextButton")) then return end
        if isOwnGui(inst) then return end
        handleRoundText(inst.Text)
        inst:GetPropertyChangedSignal("Text"):Connect(function() handleRoundText(inst.Text) end)
    end

    local function watchGuiRoot(root)
        if not root then return end
        for _,d in ipairs(root:GetDescendants()) do pcall(watchInstance,d) end
        root.DescendantAdded:Connect(function(d) pcall(watchInstance,d) end)
    end

    task.spawn(function()
        watchGuiRoot(LP:WaitForChild("PlayerGui"))
        pcall(function() watchGuiRoot(game:GetService("CoreGui")) end)
    end)
end

RunService.Stepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end end
end)

local function _getOrMakeLV(hrp)
    local lv=hrp:FindFirstChild("_RHSpeedLV")
    local att=hrp:FindFirstChild("RootAttachment")

    if not att then
        att=Instance.new("Attachment")
        att.Name="RootAttachment"
        att.Parent=hrp
    end

    if not lv then
        lv=Instance.new("LinearVelocity")
        lv.Name="_RHSpeedLV"
        lv.Parent=hrp
    end

    lv.Attachment0=att
    lv.RelativeTo=Enum.ActuatorRelativeTo.World
    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
    lv.PrimaryTangentAxis=Vector3.new(1,0,0)
    lv.SecondaryTangentAxis=Vector3.new(0,0,1)
    lv.PlaneVelocity=Vector2.new(0,0)
    lv.MaxForce=math.huge

    return lv
end

local function _speedLVSet(hrp,x,z)
    local lv=_getOrMakeLV(hrp)
    lv.PlaneVelocity=Vector2.new(x,z)
end

local function _speedLVClear(hrp)
    local lv=hrp:FindFirstChild("_RHSpeedLV")
    if lv then lv:Destroy() end
end

-- ==================== NEW SPEED CONSTRAINT ====================
local function sampleGround(hrp)
    if not hrp then return Vector3.new(0,1,0),false end

    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude

    local char=LP.Character
    params.FilterDescendantsInstances=char and {char} or {}

    local result=workspace:Raycast(
        hrp.Position,
        Vector3.new(0,-6,0),
        params
    )

    if result then
        return result.Normal,true
    end

    return Vector3.new(0,1,0),false
end

local function setSpeedConstraint(hrp,horizVel)
    if not hrp or not horizVel then return end

    local hx,hz=horizVel.X,horizVel.Z
    local mag=math.sqrt(hx*hx+hz*hz)
    if mag<0.05 then return end

    local ny,grounded=sampleGround(hrp)
    local v=hrp.AssemblyLinearVelocity
    local mass=hrp.AssemblyMass

    local gain=0.85
    if grounded then
        if ny<0.55 then
            gain=0.45
        elseif ny<0.78 then
            gain=0.62
        else
            gain=0.9
        end
    else
        gain=0.7
    end

    local target=Vector3.new(hx,v.Y,hz)
    hrp:ApplyImpulse((target-v)*mass*gain)
end

local function applyCFrameMove(part,dirUnit,spd,dt)
    if not part or not dirUnit or dirUnit.Magnitude<0.01 then return end

    local flat=Vector3.new(dirUnit.X,0,dirUnit.Z)
    if flat.Magnitude<0.01 then return end

    setSpeedConstraint(
        part,
        flat.Unit*spd
    )
end

-- Keep the selected speed applied. This is deliberately small and only
-- writes WalkSpeed; it does not alter the selected mode or toggle state.
RunService.Heartbeat:Connect(function()
    pcall(function() applyActiveHumanoidSpeed() end)
end)

-- ==================== ANTI-FLING ====================
-- Normal movement remains untouched. Only unusually large horizontal/
-- vertical velocities are clamped, while ragdoll/intentional root-driving
-- modes are allowed to operate normally.
RunService.Heartbeat:Connect(function()
    if _GACC.antiFlingEnabled==false then return end
    if autoBatEnabled or autoLeftEnabled or autoRightEnabled or batDesyncTpEnabled then
        return
    end

    local char=LP.Character
    if not char then return end

    local hum=char:FindFirstChildOfClass("Humanoid")
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if isRagdollState(hum) then return end

    local cap=getActiveMoveSpeed()
    local v=hrp.AssemblyLinearVelocity
    local flat=Vector3.new(v.X,0,v.Z)
    local m=flat.Magnitude

    local newY=v.Y
    if newY>95 then
        newY=95
    elseif newY<-150 then
        newY=-150
    end

    if m>math.max(cap*1.6,90) and m>0.01 then
        local u=flat/m
        hrp.AssemblyLinearVelocity=Vector3.new(
            u.X*cap,
            newY,
            u.Z*cap
        )
    elseif newY~=v.Y then
        hrp.AssemblyLinearVelocity=Vector3.new(v.X,newY,v.Z)
    end
end)

RunService.RenderStepped:Connect(function()
    local char=LP.Character
    if not char then return end

    local hum=char:FindFirstChildOfClass("Humanoid")
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if isRagdollState(hum) then
        lastMoveDir=Vector3.zero
        _speedLVClear(hrp)
        return
    end

    if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then
        local md=hum.MoveDirection
        local _mode=_validateSpeedState()
        local spd=getActiveMoveSpeed()

        if md.Magnitude>0 then
            lastMoveDir=md
            -- The main movement path uses impulse-based speed control.  Never
            -- leave an old LinearVelocity from Carry/Lagger/auto-path movement
            -- alive while this path is active.
            _speedLVClear(hrp)
            applyCFrameMove(hrp,md,spd,1/60)
        elseif antiRagdollEnabled and lastMoveDir.Magnitude>0 then
            _speedLVClear(hrp)
            local anyHeld=false
            for key in pairs(MOVE_KEYS) do
                if UIS:IsKeyDown(key) then
                    anyHeld=true
                    break
                end
            end

            if anyHeld then
                applyCFrameMove(hrp,lastMoveDir,spd,1/60)
            else
                _speedLVClear(hrp)
            end
        else
            _speedLVClear(hrp)
        end
    end
end)

do 
local alConn,arConn=nil,nil;local alPhase,arPhase=1,1

-- Returns true once the waypoint is reached.
local function _apStep(hrp,hum,target,spd,dt)
    local tgt=Vector3.new(target.X,hrp.Position.Y,target.Z)
    local delta=tgt-hrp.Position
    local dist=delta.Magnitude
    if dist<1 then return true end
    local mv=Vector3.new(delta.X,0,delta.Z).Unit
    -- full speed until the last stride, then only what is left, so the
    -- <1 stud arrival window cannot be stepped over at speed
    local step=math.min(spd,dist/math.max(dt,1/240))
    hum:Move(mv,false)
    _speedLVSet(hrp,mv.X*step,mv.Z*step)
    return false
end

local function _apHalt(hrp,hum)
    hum:Move(Vector3.zero,false)
    _speedLVClear(hrp)
    hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0)
end

stopAutoLeft=function()
    if alConn then alConn:Disconnect();alConn=nil end;alPhase=1
    local char=LP.Character
    if char then
        local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end
        local r=char:FindFirstChild("HumanoidRootPart")
        if r then _speedLVClear(r);r.AssemblyLinearVelocity=Vector3.new(0,r.AssemblyLinearVelocity.Y,0) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
end

stopAutoRight=function()
    if arConn then arConn:Disconnect();arConn=nil end;arPhase=1
    local char=LP.Character
    if char then
        local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end
        local r=char:FindFirstChild("HumanoidRootPart")
        if r then _speedLVClear(r);r.AssemblyLinearVelocity=Vector3.new(0,r.AssemblyLinearVelocity.Y,0) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
end

startAutoLeft=function()
    if alConn then alConn:Disconnect() end;alPhase=1
    do local c=LP.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if h then _speedLVClear(h) end end
    alConn=RunService.Heartbeat:Connect(function(dt)
        if not autoLeftEnabled then return end
        local char=LP.Character;if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero,false);return end
        local spd=getAutoPathSpeed()
        if alPhase==1 then
            if _apStep(hrp,hum,AP_L1,spd,dt) then alPhase=2 end
        elseif alPhase==2 then
            if _apStep(hrp,hum,AP_L2,spd,dt) then
                _apHalt(hrp,hum)
                autoLeftEnabled=false
                if alConn then alConn:Disconnect();alConn=nil end
                alPhase=1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
                return
            end
        end
        if autoMoveSwingEnabled and not _alSwingDebounce then
            _alSwingDebounce=true
            local bat=findBat()
            if bat then
                if bat.Parent~=char then pcall(function() hum:EquipTool(bat) end) end
                pcall(function() bat:Activate() end)
            end
            task.delay(autoMoveSwingInterval,function() _alSwingDebounce=false end)
        end
    end)
end

startAutoRight=function()
    if arConn then arConn:Disconnect() end;arPhase=1
    do local c=LP.Character;local h=c and c:FindFirstChild("HumanoidRootPart");if h then _speedLVClear(h) end end
    arConn=RunService.Heartbeat:Connect(function(dt)
        if not autoRightEnabled then return end
        local char=LP.Character;if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero,false);return end
        local spd=getAutoPathSpeed()
        if arPhase==1 then
            if _apStep(hrp,hum,AP_R1,spd,dt) then arPhase=2 end
        elseif arPhase==2 then
            if _apStep(hrp,hum,AP_R2,spd,dt) then
                _apHalt(hrp,hum)
                autoRightEnabled=false
                if arConn then arConn:Disconnect();arConn=nil end
                arPhase=1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
                return
            end
        end
        if autoMoveSwingEnabled and not _arSwingDebounce then
            _arSwingDebounce=true
            local bat=findBat()
            if bat then
                if bat.Parent~=char then pcall(function() hum:EquipTool(bat) end) end
                pcall(function() bat:Activate() end)
            end
            task.delay(autoMoveSwingInterval,function() _arSwingDebounce=false end)
        end
    end)
end
end 

do  -- scoped: file is at Luau's 200-local cap on the main chunk
-- ============================================================
-- DROP METHODS (Green Duels, verbatim)
-- ============================================================
_GACC.dropType = _GACC.dropType or "Jump"
_GACC.DROP_TYPES = {"Stand","Jump"}

_GACC.wfConns = {}

local function disableOtherCollisions()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            for _, part in ipairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- 1. STAND DROP (Brainrot fling - original Cursed Hub)
local function runStandDrop()
    if dropActive then return end
    dropActive = true
    local colConn = RunService.Stepped:Connect(function()
        if not dropActive then return end
        disableOtherCollisions()
    end)
    table.insert(_GACC.wfConns, colConn)
    local flingThread = coroutine.create(function()
        while dropActive do
            RunService.Heartbeat:Wait()
            local c = LP.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            if not root then break end
            local vel = root.Velocity
            root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            if root and root.Parent then root.Velocity = vel end
            RunService.Stepped:Wait()
            if root and root.Parent then root.Velocity = vel + Vector3.new(0, 0.1, 0) end
        end
    end)
    table.insert(_GACC.wfConns, flingThread)
    coroutine.resume(flingThread)
    task.delay(0.1, function()
        dropActive = false
        for _, c in ipairs(_GACC.wfConns) do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            elseif type(c) == "thread" then
                pcall(coroutine.close, c)
            end
        end
        _GACC.wfConns = {}
        if _GACC.runAfterDrop then pcall(_GACC.runAfterDrop) end
    end)
end

-- 2. JUMP DROP (ascend then teleport)
local DROP_ASCEND_DURATION = 0.22
local DROP_ASCEND_SPEED = 160
local _dropConn = nil

local function runJumpDrop()
    if dropActive then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    dropActive = true
    local t0 = tick()
    if _dropConn then _dropConn:Disconnect() end
    _dropConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            dropActive = false
            return
        end
        if not dropActive then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            return
        end
        if tick() - t0 >= DROP_ASCEND_DURATION then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            pcall(function()
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {c}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
                if rr then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    local off = ((hum and hum.HipHeight) or 2) + (r.Size.Y / 2)
                    r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    r.AssemblyLinearVelocity = Vector3.zero
                end
            end)
            dropActive = false
            if _GACC.runAfterDrop then pcall(_GACC.runAfterDrop) end
            return
        end
        local lv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = Vector3.new(lv.X, DROP_ASCEND_SPEED, lv.Z)
    end)
end

-- Main drop dispatcher
local function runSelectedDrop()
    if _GACC.dropType == "Stand" then
        runStandDrop()
    else
        runJumpDrop()
    end
end

runDrop = runSelectedDrop

-- Cleanup on character remove
LP.CharacterRemoving:Connect(function()
    dropActive = false
    for _, c in ipairs(_GACC.wfConns) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif type(c) == "thread" then pcall(coroutine.close, c) end
    end
    _GACC.wfConns = {}
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
end)

end

do 
local function doAutoTPDown(force)
    local char=LP.Character;if not char then return end;local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
    local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end
    if not force then if hum2.FloorMaterial~=Enum.Material.Air then return end;if not(hrp.Position.Y>=autoTPHeight) then return end end
    hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)*CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0);hrp.Velocity=Vector3.zero
end

startAutoTP=function()
    if autoTPConn then task.cancel(autoTPConn);autoTPConn=nil end
    autoTPConn=task.spawn(function() while autoTPEnabled do task.wait(0.1);pcall(function() doAutoTPDown(false) end) end end)
end

stopAutoTP=function() autoTPEnabled=false;if autoTPConn then task.cancel(autoTPConn);autoTPConn=nil end end
runTPFloor=function() pcall(function() doAutoTPDown(true) end) end
end 

do 
local STRETCH_NAME="Movee_Stretch"
enableStretchRez=function()
    stretchRezEnabled=true;if stretchRezConn then stretchRezConn:Disconnect() end
    pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end)
    pcall(function() RunService:BindToRenderStep(STRETCH_NAME,Enum.RenderPriority.Last.Value-1,function() local cam=workspace.CurrentCamera;if cam then cam.CFrame=cam.CFrame*CFrame.new(0,0,0,1,0,0,0,0.8,0,0,0,1) end end) end)
end

disableStretchRez=function() stretchRezEnabled=false;pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end) end

local defLightBrightness,defLightClock,defLightAmbient
local function applyAntiLagDerender(obj)
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy()
        elseif obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic;obj.Reflectance=0;obj.CastShadow=false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled=false end
    end)
end

enableAntiLag=function()
    removeAccessoriesEnabled=true;antiLagEnabled=true
    defLightBrightness=defLightBrightness or Lighting.Brightness;defLightClock=defLightClock or Lighting.ClockTime;defLightAmbient=defLightAmbient or Lighting.OutdoorAmbient
    Lighting.GlobalShadows=false;Lighting.FogEnd=1e10;Lighting.Brightness=1;Lighting.EnvironmentDiffuseScale=0;Lighting.EnvironmentSpecularScale=0
    for _,e in pairs(Lighting:GetChildren()) do pcall(function() if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end end) end
    for _,obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end
    if antiLagDescConn then antiLagDescConn:Disconnect() end
    antiLagDescConn=workspace.DescendantAdded:Connect(function(obj) if removeAccessoriesEnabled then applyAntiLagDerender(obj) end end)
end

disableAntiLag=function()
    removeAccessoriesEnabled=false;antiLagEnabled=false;if antiLagDescConn then antiLagDescConn:Disconnect();antiLagDescConn=nil end
    pcall(function() if defLightBrightness then Lighting.Brightness=defLightBrightness end;if defLightClock then Lighting.ClockTime=defLightClock end;if defLightAmbient then Lighting.OutdoorAmbient=defLightAmbient end;Lighting.ExposureCompensation=0 end)
end
end 

do 
local function findMedusa()
    local c=LP.Character;if not c then return nil end
    for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower();if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end
    local bp=LP:FindFirstChild("Backpack");if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower();if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end
    return nil
end

local function useMedusaCounter()
    if medusaDebounce then return end;if MEDUSA_COOLDOWN>(tick()-medusaLastUsed) then return end
    local c=LP.Character;if not c then return end;medusaDebounce=true
    local med=findMedusa();if not med then medusaDebounce=false;return end
    if med.Parent~=c then local hum2=c:FindFirstChildOfClass("Humanoid");if hum2 then hum2:EquipTool(med) end end
    pcall(function() med:Activate() end);medusaLastUsed=tick();medusaDebounce=false
end

local function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if part.Anchored and part.Transparency==1 then
            if medusaCounterEnabled then useMedusaCounter() end
        end
    end)
end

setupMedusa=function(char)
    for _,c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end;Conns.anchor={}
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end
    table.insert(Conns.anchor,char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end end))
end

stopMedusaCounter=function() for _,c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end;Conns.anchor={} end
end 

-- Dice Bat/TP Bat engine is the sole active implementation.

-- ==================== ROOT-CONTROL EXCLUSIVITY ====================
-- Turns off every root-driving feature except `keep`, and syncs both the
-- menu toggle and the mobile button for each one. Call this from anywhere
-- that switches one of them on.
-- ==================== AFTER DROP ====================
-- "Off" | "Bat Aimbot" | "Bat TP" - what to switch on once a Drop Brainrot
-- finishes landing.
_GACC.afterDrop = _GACC.afterDrop or "Off"
_GACC.AFTER_DROP_OPTIONS = {"Off","Bat Aimbot","Bat TP"}

_GACC.runAfterDrop = function()
    local mode = _GACC.afterDrop
    if mode ~= "Bat Aimbot" and mode ~= "Bat TP" then return end
    -- let the landing settle before taking the root back
    task.delay(0.12, function()
        if dropActive then return end                                  -- another drop started
        if _GACC.safeIsLocked and _GACC.safeIsLocked() then return end -- safe mode says no
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if mode == "Bat Aimbot" then
            _GACC.exclusiveStop("batAimbot")
            autoBatEnabled = true
            pcall(startBatAimbot)
            if autoBatSetVisual then autoBatSetVisual(true) end
            if mobBtnRefs.autoBat then mobBtnRefs.autoBat(true) end
        else
            _GACC.exclusiveStop("batTp")
            batDesyncTpEnabled = true
            pcall(startBatDesyncTp)
            if batDesyncTpSetVisual then batDesyncTpSetVisual(true) end
            if mobBtnRefs.tpBat then mobBtnRefs.tpBat(true) end
        end
    end)
end

_GACC.exclusiveStop = function(keep)
    if keep ~= "batAimbot" and autoBatEnabled then
        autoBatEnabled = false
        pcall(stopBatAimbot)
        if autoBatSetVisual then autoBatSetVisual(false) end
        if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
    end
    if keep ~= "batTp" and batDesyncTpEnabled then
        batDesyncTpEnabled = false
        pcall(stopBatDesyncTp)
        if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
        if mobBtnRefs.tpBat then mobBtnRefs.tpBat(false) end
    end
    if keep ~= "autoLeft" and autoLeftEnabled then
        autoLeftEnabled = false
        pcall(stopAutoLeft)
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
    end
    if keep ~= "autoRight" and autoRightEnabled then
        autoRightEnabled = false
        pcall(stopAutoRight)
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
    end
end

;(function()
    local state={applied=false,waiting=false,watchUntil=0,graceUntil=0,savedMode=nil,stealWasActive=false}

    local function modeName()
        return speedMode
    end

    local function setModes(lagger,carry)
        if lagger then
            setSpeedMode(carry and "Lagger Carry" or "Lagger")
        else
            setSpeedMode(carry and "Carry" or "Normal")
        end
        if _GACC.safeLaggerVisual then _GACC.safeLaggerVisual(laggerModeEnabled) end
        if _GACC.safeCarryVisual then _GACC.safeCarryVisual(carrySpeedActive) end
        if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
        if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    end

    local function isIgnoredTool(name)
        local lower=tostring(name or ""):lower()
        return lower:find("bat",1,true) or lower:find("slap",1,true) or lower:find("medusa",1,true) or lower:find("head",1,true) or lower:find("stone",1,true)
    end

    _GACC.autoCarryDetect=function()
        local char=LP.Character;if not char then return false end
        for _,name in ipairs({"Carrying","IsCarrying","Grabbed","Holding","StealHold","HasGrab"}) do
            local value=char:FindFirstChild(name,true)
            if value and ((value:IsA("BoolValue") and value.Value) or (value:IsA("ObjectValue") and value.Value) or (value:IsA("StringValue") and value.Value~="")) then return true end
        end
        for _,child in ipairs(char:GetChildren()) do
            local lower=child.Name:lower()
            if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart",true) then
                if (child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart")) or lower:find("brainrot") or lower:find("animal") or lower:find("carry") or lower:find("grab") or lower:find("steal") or lower:find("hold") then return true end
            elseif child:IsA("Tool") and not isIgnoredTool(child.Name) then return true end
        end
        return false
    end

    local function enableCarry()
        state.waiting=false;state.watchUntil=0
        if not state.applied then state.savedMode=modeName() end
        state.applied=true;state.graceUntil=tick()+.75
        local wasLagger=state.savedMode=="Lagger" or state.savedMode=="Lagger Carry"
        if wasLagger then setModes(true,true) else setModes(false,true) end
    end

    local function disableCarry()
        local wasApplied=state.applied
        local saved=state.savedMode
        state.applied=false
        state.waiting=false
        state.watchUntil=0
        state.graceUntil=0
        state.savedMode=nil

        if wasApplied then
            if saved=="Lagger" or saved=="Lagger Carry" then
                setModes(true,false)
            elseif saved=="Carry" then
                setModes(false,true)
            else
                setModes(false,false)
            end
        elseif not _GACC.autoCarrySpeedEnabled then
            -- If the feature was disabled while another callback was changing
            -- state, force the authoritative mode back to its current mirror.
            syncSpeedMode()
        end
    end

    _GACC.autoCarryWatch=function(seconds)
        if not _GACC.autoCarrySpeedEnabled then return end
        state.waiting=true;state.watchUntil=tick()+(seconds or 1.25)
    end
    _GACC.disableAutoCarry=disableCarry

    RunService.RenderStepped:Connect(function()
        if manualSpeedOverride then
            if state.applied then disableCarry() end
            return
        end
        if not _GACC.autoCarrySpeedEnabled then disableCarry();return end
        local char=LP.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root then disableCarry();state.stealWasActive=false;return end
        local humanoidState=hum:GetState()
        local gotHit=humanoidState==Enum.HumanoidStateType.Physics or humanoidState==Enum.HumanoidStateType.Ragdoll or humanoidState==Enum.HumanoidStateType.FallingDown
        local stealing=LP:GetAttribute("Stealing")==true or char:GetAttribute("Stealing")==true
        local carrying=_GACC.autoCarryDetect()
        if stealing and not state.stealWasActive then state.stealWasActive=true;enableCarry()
        elseif not stealing then state.stealWasActive=false end
        if state.waiting then
            if gotHit or tick()>state.watchUntil then state.waiting=false;state.watchUntil=0
            elseif carrying then enableCarry() end
        end
        if carrying and not state.applied then enableCarry() end
        if state.applied and (gotHit or (tick()>state.graceUntil and not carrying and not stealing)) then disableCarry() end
    end)
end)()

saveConfig=function()
    local function ks(e)
        if e.kb then return {kb=e.kb.Name,gp=e.gp and e.gp.Name}
        elseif e.gp then return {gp=e.gp.Name}
        else return {kb=nil,gp=nil} end
    end
    local cfg={speedMode=speedMode,normalSpeed=NS,carrySpeed=CS,dropBrainrotKey=ks(KB.DropBrainrot),autoLeftKey=ks(KB.AutoLeft),autoRightKey=ks(KB.AutoRight),autoBatKey=ks(KB.AutoBat),laggerToggleKey=ks(KB.LaggerToggle),tpFloorKey=ks(KB.TPFloor),guiHideKey=ks(KB.GuiHide),speedToggleKey=ks(KB.SpeedToggle),grabRadius=Steal.StealRadius,stealDuration=Steal.StealDuration,stealMode=stealMode,antiRagdoll=antiRagdollEnabled,autoStealEnabled=Steal.AutoStealEnabled,infiniteJump=infJumpEnabled,infJumpMode=infJumpMode,medusaCounter=medusaCounterEnabled,carrySpeedActive=carrySpeedActive,laggerModeEnabled=laggerModeEnabled,laggerSpeed=LAGGER_SPEED,laggerCarrySpeed=LAGGER_CARRY_SPEED,autoBat=autoBatEnabled,autoSwing=autoSwingEnabled,unwalkEnabled=unwalkEnabled,antiLag=antiLagEnabled,stretchRez=stretchRezEnabled,autoTPEnabled=autoTPEnabled,autoTPHeight=autoTPHeight,guiTransparencyEnabled=guiTransparencyEnabled,mobileButtonsEnabled=mobileButtonsEnabled,mobileButtonsLocked=mobileButtonsLocked,mobileButtonsSize=mobileButtonsSize,circleButtonsEnabled=circleButtonsEnabled,autoSwitchSpeed=autoSwitchSpeedEnabled,fovValue=fovValue,perButtonDrag=perButtonDragEnabled,skyTheme=currentSkyTheme,medusaReset=medusaResetEnabled,autoMoveSwing=autoMoveSwingEnabled,autoMoveSwingInterval=autoMoveSwingInterval,ragdollGui=ragdollGuiEnabled,introSoundEnabled=introSoundEnabled,animEnabled=false,animationPack=_GACC.extras.getPack(),headlessEnabled=_GACC.extras.getHeadless(),korbloxEnabled=_GACC.extras.getKorblox(),backgroundEnabled=backgroundEnabled,backgroundIndex=backgroundIndex,colorThemeName=currentColorTheme,keys=(function() if not _GuiKeys then return {} end;local t={};for k,v in pairs(_GuiKeys) do t[k]=v.Name end;return t end)()}
    cfg.playerHighlightEnabled=_GACC.playerHighlightEnabled
    cfg.autoCarrySpeedEnabled=_GACC.autoCarrySpeedEnabled
    cfg.opRadius=SemiSteal.CONFIG.RADIUS
    cfg.opDuration=SemiSteal.CONFIG.DURATION
    cfg.opDelayRadius=SemiSteal.CONFIG.DELAY_RADIUS
    cfg.opStopTime=SemiSteal.CONFIG.STOP_TIME
    cfg.opStopTimeEnabled=SemiSteal.CONFIG.STOP_TIME_ENABLED
    cfg.medusaResetEnabled=_GACC.medusaResetEnabled
    cfg.antiSummerBaseEnabled=AntiSummer.antiSummerBaseEnabled
    cfg.antiDieEnabled = antiDieEnabled  -- NEW
    -- NEW SCALES
    cfg.menuScale = menuScale
    cfg.mobileBtnScale = mobileBtnScale
    cfg.stealBarScale = stealBarScale
    if _GACC.mobileButtonPositions then cfg.mobileButtonPositions = _GACC.mobileButtonPositions end
    cfg.uiLocked = uiLocked
    cfg.afterDrop = _GACC.afterDrop
    cfg.batDesyncTpEnabled = batDesyncTpEnabled
    cfg.batCounter = _GACC.batCounterEnabled
    cfg.dropType = _GACC.dropType
    cfg.safeModeEnabled = _GACC.safeModeEnabled
    if _GACC.uiPositions then cfg.uiPositions = _GACC.uiPositions end
    if writefile then pcall(function() writefile("RitualHub_PC.json",HS:JSONEncode(cfg)) end) end
end

task.spawn(function() while task.wait(5) do saveConfig() end end)

local function resetAllSettings()
    NS=59;CS=29;LAGGER_SPEED=30;LAGGER_CARRY_SPEED=15
    autoSwitchSpeedEnabled=false
    manualSpeedOverride=false
    _GACC.autoCarrySpeedEnabled=false
    if _GACC.disableAutoCarry then pcall(_GACC.disableAutoCarry) end
    setSpeedMode("Normal")
    antiRagdollEnabled=false;infJumpEnabled=false;infJumpMode="manual"
    medusaCounterEnabled=false;unwalkEnabled=false
    autoLeftEnabled=false;autoRightEnabled=false;autoBatEnabled=false;autoSwingEnabled=true;autoMoveSwingEnabled=false
    autoTPEnabled=false;autoTPHeight=20;antiLagEnabled=false;stretchRezEnabled=false
    Steal.AutoStealEnabled=false;Steal.StealRadius=61;Steal.StealDuration=1.3;stealMode="normal"
    guiTransparencyEnabled=false;mobileButtonsEnabled=true;mobileButtonsSize=80
    circleButtonsEnabled=false;uiLocked=false;fovValue=80;fovIndex=1
    introSoundEnabled=true
    _GACC.medusaResetEnabled=false
    if _GACC.stopMedusaReset then _GACC.stopMedusaReset() end
    AntiSummer.disable()
    _GACC.autoCarrySpeedEnabled=false;if _GACC.disableAutoCarry then _GACC.disableAutoCarry() end
    _GACC.extras.reset(LP.Character)
    KB.DropBrainrot={kb=nil,gp=nil};KB.AutoLeft={kb=nil,gp=nil};KB.AutoRight={kb=nil,gp=nil}
    KB.AutoBat={kb=nil,gp=nil};KB.TPFloor={kb=nil,gp=nil}
    KB.GuiHide={kb=nil,gp=nil};KB.SpeedToggle={kb=nil,gp=nil};KB.LaggerToggle={kb=nil,gp=nil}
    if refreshSpeedModeLabel then refreshSpeedModeLabel() end
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
    if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
    if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
    if _GACC.autoCarryVisual then _GACC.autoCarryVisual(false) end
    stopBatAimbot();stopAutoSteal();stopAutoLeft();stopAutoRight();stopAntiRagdoll();stopAutoTP();stopHoldInfJump()
    if stretchRezEnabled then disableStretchRez() end;if antiLagEnabled then disableAntiLag() end
    -- Anti Die reset
    if antiDieEnabled then stopAntiDie() end
    saveConfig()
end

local setInfJumpVisual,setAntiRagVisual,setMedusaVisual,setUnwalkVisual

refreshSpeedModeLabel=function()
    if modeValLbl then
        if laggerModeEnabled then 
            modeValLbl.Text = carrySpeedActive and "Lagger Carry" or "Lagger Mode"
        elseif carrySpeedActive then modeValLbl.Text="Carry"
        else modeValLbl.Text="Normal" end
    end
    if laggerModePillRef and laggerModePillRef.pill and laggerModePillRef.dot then
        local pill=laggerModePillRef.pill;local dot=laggerModePillRef.dot;local on=laggerModeEnabled
        local WHITE=Color3.fromRGB(255,255,255);local OFF=Color3.fromRGB(46,24,38);local GRAY=Color3.fromRGB(180,150,165)
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and WHITE or OFF}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5),BackgroundColor3=on and Color3.fromRGB(30,30,30) or GRAY}):Play()
    end
    if carryModePillRef and carryModePillRef.pill and carryModePillRef.dot then
        local pill=carryModePillRef.pill;local dot=carryModePillRef.dot;local on=carrySpeedActive
        local WHITE=Color3.fromRGB(255,255,255);local OFF=Color3.fromRGB(46,24,38);local GRAY=Color3.fromRGB(180,150,165)
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and WHITE or OFF}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,3,0.5,-5),BackgroundColor3=on and Color3.fromRGB(30,30,30) or GRAY}):Play()
    end
end

toggleCarryMode=function()
    -- Manual toggle always wins over automatic carry/speed switching.
    manualSpeedOverride = true
    local mode = syncSpeedMode()
    if mode == "Carry" then
        setSpeedMode("Normal")
    else
        setSpeedMode("Carry")
    end
    local char=LP.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
        pcall(function()
            local lv=root:FindFirstChild("_RHSpeedLV")
            if lv then lv:Destroy() end
            local v=root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity=Vector3.new(0,v.Y,0)
        end)
    end
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
end

toggleLaggerMode=function()
    -- Manual toggle always wins over automatic carry/speed switching.
    manualSpeedOverride = true
    local mode = syncSpeedMode()
    if mode == "Lagger" then
        setSpeedMode("Normal")
    else
        setSpeedMode("Lagger")
    end
    local char=LP.Character
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if root then
        pcall(function()
            local lv=root:FindFirstChild("_RHSpeedLV")
            if lv then lv:Destroy() end
            local v=root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity=Vector3.new(0,v.Y,0)
        end)
    end
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
end

;(function()
    local resetCooldown=0

    local function forceReset()
        local char=LP.Character
        if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local root=char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health<=0 then return end

        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            root.Velocity=Vector3.zero
            root.RotVelocity=Vector3.zero
            root.AssemblyLinearVelocity=Vector3.zero
            root.AssemblyAngularVelocity=Vector3.zero

            for _,obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") then obj.Enabled=true end
                if obj:IsA("Constraint") then obj.Enabled=true end
            end

            if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject=hum end

            local playerModule=LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
            local controlModule=playerModule and playerModule:FindFirstChild("ControlModule")
            if controlModule then
                local controls=require(controlModule)
                if controls then controls:Enable() end
            end

            hum.AutoRotate=true
            hum.PlatformStand=false
            hum.Sit=false
        end)
    end
    startAntiRagdoll=function()
        if Conns.antiRag then return end
        antiRagdollEnabled=true
        Conns.antiRag=RunService.Heartbeat:Connect(function()
            if not antiRagdollEnabled then return end
            local char=LP.Character
            if not char then return end
            local hum=char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health<=0 then return end

            local state=hum:GetState()
            local ragdolled=(state==Enum.HumanoidStateType.Physics or state==Enum.HumanoidStateType.Ragdoll or state==Enum.HumanoidStateType.FallingDown)
            if ragdolled then
                local now=tick()
                if now-resetCooldown>.15 then
                    resetCooldown=now
                    forceReset()
                end
            end
        end)
    end

    stopAntiRagdoll=function()
        antiRagdollEnabled=false
        if Conns.antiRag then
            Conns.antiRag:Disconnect()
            Conns.antiRag=nil
        end
    end
end)()

startUnwalk=function()
    local c=LP.Character;if not c then return end;local hum=c:FindFirstChildOfClass("Humanoid")
    if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim=c:FindFirstChild("Animate");if anim then unwalkSavedAnimate=anim:Clone();anim:Destroy() end
end

stopUnwalk=function() local c=LP.Character;if c and unwalkSavedAnimate then unwalkSavedAnimate:Clone().Parent=c;unwalkSavedAnimate=nil end end

-- ========== ANTI DIE ==========
-- Local protection backend. It restores health while enabled and temporarily
-- yields during Instant Reset so the reset system can still function.
local function protectChar(char)
    if not char then return end

    local hum=char:FindFirstChildOfClass("Humanoid")
        or char:WaitForChild("Humanoid",5)
    if not hum then return end

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
    end)

    local sc=hum.StateChanged:Connect(function(_,new)
        if not antiDieEnabled or resetting then return end

        if new==Enum.HumanoidStateType.Dead then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
                hum.Health=hum.MaxHealth
            end)
        end
    end)
    table.insert(antiDieConnections,sc)

    local hc=hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not antiDieEnabled or resetting then return end

        if hum.Health<hum.MaxHealth then
            pcall(function()
                hum.Health=hum.MaxHealth
            end)
        end
    end)
    table.insert(antiDieConnections,hc)

    if antiDieHeartbeat then
        antiDieHeartbeat:Disconnect()
    end

    antiDieHeartbeat=RunService.Heartbeat:Connect(function()
        if not antiDieEnabled or resetting then return end

        if hum and hum.Parent and hum.Health<hum.MaxHealth then
            pcall(function()
                hum.Health=hum.MaxHealth
            end)
        end
    end)
end

_GACC.applyAntiDie=protectChar

local function startAntiDie()
    if antiDieEnabled then return end

    antiDieEnabled=true

    for _,c in ipairs(antiDieConnections) do
        pcall(function() c:Disconnect() end)
    end
    antiDieConnections={}

    if antiDieHeartbeat then
        antiDieHeartbeat:Disconnect()
        antiDieHeartbeat=nil
    end

    protectChar(LP.Character)

    -- One persistent respawn watcher, rather than creating duplicate
    -- CharacterAdded connections every time the toggle is pressed.
    if not _GACC.antiDieCharacterConn then
        _GACC.antiDieCharacterConn=LP.CharacterAdded:Connect(function(c)
            if not antiDieEnabled then return end
            task.wait(0.1)

            for _,c2 in ipairs(antiDieConnections) do
                pcall(function() c2:Disconnect() end)
            end
            antiDieConnections={}

            protectChar(c)
        end)
    end

    pcall(function()
        StarterGui:SetCore("ResetButtonCallback",false)
    end)
end

local function stopAntiDie()
    antiDieEnabled=false

    for _,c in ipairs(antiDieConnections) do
        pcall(function() c:Disconnect() end)
    end
    antiDieConnections={}

    if antiDieHeartbeat then
        antiDieHeartbeat:Disconnect()
        antiDieHeartbeat=nil
    end

    local char=LP.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead,true)
            end)
        end
    end

    pcall(function()
        StarterGui:SetCore("ResetButtonCallback",true)
    end)
end

-- ==================== ANTI-FLING ====================
-- The speed backend above already contains the main fling clamp. This helper
-- keeps the protection available independently for any future root-driving
-- feature without creating another competing movement controller.
_GACC.antiFlingEnabled=true
_GACC.setAntiFlingEnabled=function(on)
    _GACC.antiFlingEnabled=(on==true)
end

local function createStealBar()
    for _,n in ipairs({"MoveeStealBar"}) do
        local old=game:GetService("CoreGui"):FindFirstChild(n);if old then old:Destroy() end
        local pgui=LP:FindFirstChild("PlayerGui");if pgui then local o=pgui:FindFirstChild(n);if o then o:Destroy() end end
    end
    local SB_W,SB_H=220,46
    local stealGui=Instance.new("ScreenGui");stealGui.Name="MoveeStealBar";stealGui.ResetOnSpawn=false;stealGui.IgnoreGuiInset=true;stealGui.DisplayOrder=8
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(stealGui) end end)
    if not pcall(function() stealGui.Parent=game:GetService("CoreGui") end) then stealGui.Parent=LP:WaitForChild("PlayerGui") end

    stealBarFrame=Instance.new("Frame",stealGui)
    stealBarFrame.Size=UDim2.new(0,SB_W,0,SB_H)
    stealBarFrame.Position=UDim2.new(0.5,-SB_W/2,0.88,0)
    do local sp=_GACC.getUiPos and _GACC.getUiPos("stealBar"); if sp then stealBarFrame.Position=sp end end
    stealBarFrame.BackgroundColor3=Color3.fromRGB(4,28,52)
    stealBarFrame.BackgroundTransparency=0.46
    stealBarFrame.BorderSizePixel=0; stealBarFrame.ZIndex=20; stealBarFrame.ClipsDescendants=true
    Instance.new("UICorner",stealBarFrame).CornerRadius=UDim.new(0,10)
    local sbStroke=Instance.new("UIStroke",stealBarFrame)
    sbStroke.Color=_GACC.accent; sbStroke.Thickness=1.15; sbStroke.Transparency=0.46
    local sbBgGrad=Instance.new("UIGradient",stealBarFrame)
    sbBgGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(24,93,145)),ColorSequenceKeypoint.new(0.55,Color3.fromRGB(7,43,78)),ColorSequenceKeypoint.new(1,Color3.fromRGB(2,22,43))})
    sbBgGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(.55,.22),NumberSequenceKeypoint.new(1,.34)})
    sbBgGrad.Rotation=18
    local sideAccent=Instance.new("Frame",stealBarFrame)
    sideAccent.Size=UDim2.new(0,2,0,24); sideAccent.Position=UDim2.new(0,0,0.5,-12)
    sideAccent.BackgroundColor3=_GACC.accent; sideAccent.BackgroundTransparency=.18; sideAccent.BorderSizePixel=0; sideAccent.ZIndex=22
    Instance.new("UICorner",sideAccent).CornerRadius=UDim.new(0,2)

    local dot=Instance.new("Frame",stealBarFrame)
    dot.Size=UDim2.new(0,6,0,6); dot.Position=UDim2.new(0,12,0,11)
    dot.BackgroundColor3=_GACC.accentDark; dot.BackgroundTransparency=.12; dot.BorderSizePixel=0; dot.ZIndex=22
    Instance.new("UICorner",dot).CornerRadius=UDim.new(0,4)

    local stealLbl=Instance.new("TextLabel",stealBarFrame)
    stealLbl.Size=UDim2.new(0,105,0,16); stealLbl.Position=UDim2.new(0,24,0,5)
    stealLbl.BackgroundTransparency=1; stealLbl.Text="AUTO STEAL"
    stealLbl.TextColor3=Color3.fromRGB(215,240,255); stealLbl.Font=Enum.Font.GothamBold; stealLbl.TextSize=10
    stealLbl.TextXAlignment=Enum.TextXAlignment.Left; stealLbl.ZIndex=22
    local stealLblGrad=Instance.new("UIGradient",stealLbl); stealLblGrad.Color=_gAccentGrad(0)

    local stateLbl=Instance.new("TextLabel",stealBarFrame)
    stateLbl.Size=UDim2.new(0,70,0,12); stateLbl.Position=UDim2.new(0,12,0,22)
    stateLbl.BackgroundTransparency=1; stateLbl.Text="OFF"
    stateLbl.TextColor3=Color3.fromRGB(102,158,205); stateLbl.TextSize=8; stateLbl.Font=Enum.Font.GothamBold
    stateLbl.TextXAlignment=Enum.TextXAlignment.Left; stateLbl.ZIndex=22

    local perfLbl=Instance.new("TextLabel",stealBarFrame)
    perfLbl.Size=UDim2.new(0,92,0,12); perfLbl.Position=UDim2.new(0,66,0,22)
    perfLbl.BackgroundTransparency=1; perfLbl.Text="FPS --  /  --ms"
    perfLbl.TextColor3=Color3.fromRGB(130,181,220); perfLbl.TextSize=8; perfLbl.Font=Enum.Font.GothamMedium
    perfLbl.TextXAlignment=Enum.TextXAlignment.Center; perfLbl.ZIndex=22

    local pctLbl=Instance.new("TextLabel",stealBarFrame)
    pctLbl.Size=UDim2.new(0,42,0,14); pctLbl.Position=UDim2.new(1,-50,0,21)
    pctLbl.BackgroundTransparency=1; pctLbl.Text="0%"
    pctLbl.TextColor3=_GACC.accent; pctLbl.Font=Enum.Font.GothamBlack; pctLbl.TextSize=10
    pctLbl.TextXAlignment=Enum.TextXAlignment.Right; pctLbl.ZIndex=22
    table.insert(_themeExtRefs,{callback=function(thm) pcall(function() pctLbl.TextColor3=thm.accent end) end})

    local track=Instance.new("Frame",stealBarFrame)
    track.Size=UDim2.new(1,-24,0,4); track.Position=UDim2.new(0,12,1,-8)
    track.BackgroundColor3=Color3.fromRGB(16,73,111); track.BackgroundTransparency=.48; track.BorderSizePixel=0; track.ZIndex=21
    Instance.new("UICorner",track).CornerRadius=UDim.new(0,3)

    local fillLine=Instance.new("Frame",track)
    fillLine.Size=UDim2.new(0,0,1,0); fillLine.Position=UDim2.new(0,0,0,0)
    fillLine.BackgroundColor3=_GACC.accent; fillLine.BackgroundTransparency=.1; fillLine.BorderSizePixel=0; fillLine.ZIndex=22
    Instance.new("UICorner",fillLine).CornerRadius=UDim.new(0,3)
    local fillGrad=Instance.new("UIGradient",fillLine)
    fillGrad.Color=_gAccentGrad(0)
    table.insert(_themeExtRefs,{callback=function(thm)
        pcall(function() stealBarFrame.BackgroundColor3=Color3.fromRGB(4,28,52) end)
        pcall(function() fillLine.BackgroundColor3=thm.accent end)
        pcall(function() fillGrad.Color=_gAccentGrad(0) end)
        pcall(function() stealLblGrad.Color=_gAccentGrad(0) end)
        pcall(function() sideAccent.BackgroundColor3=thm.accent end)
    end})

    -- Add UIScale for steal bar
    local stealScaleObj = Instance.new("UIScale")
    stealScaleObj.Name = "StealBarScale"
    stealScaleObj.Scale = stealBarScale
    stealScaleObj.Parent = stealBarFrame
    _GACC.stealBarScaleObj = stealScaleObj

    task.spawn(function()
        local lastPct=0
        while fillLine and fillLine.Parent do
            local now=tick()
            local pct=0
            local ready=false
            if Steal.AutoStealEnabled then
                if (stealMode~="normal") and SemiSteal.State.active then
                    pct=math.clamp(tonumber(SemiSteal.State.progress) or 0,0,1); ready=true
                elseif stealMode=="normal" and isStealing and stealStartTime then
                    pct=math.clamp((now-stealStartTime)/Steal.StealDuration,0,1); ready=true
                end
            end
            lastPct=lastPct+(pct-lastPct)*0.82
            if math.abs(lastPct-pct)<0.002 then lastPct=pct end
            fillLine.Size=UDim2.new(lastPct,0,1,0)
            fillGrad.Color=_gAccentGrad(now)
            pctLbl.Text=math.floor(lastPct*100+.5).."%"
            if not Steal.AutoStealEnabled then
                stateLbl.Text="OFF"
            elseif ready then
                if _GACC.isVersionMode(stealMode) then stateLbl.Text=SemiSteal.State.paused and "WAIT RANGE" or (stealMode:upper().." HOLD")
                elseif stealMode=="semi" then stateLbl.Text=SemiSteal.State.phase=="waitingRange" and "WAIT RANGE" or "SEMI HOLD"
                else stateLbl.Text="STEALING" end
            else
                stateLbl.Text="SEARCHING"
            end
            stateLbl.TextColor3=ready and Color3.fromRGB(160,218,255) or Color3.fromRGB(102,158,205)
            perfLbl.Text="FPS "..tostring(_perfFps).."  /  "..tostring(_perfPing).."ms"
            
            if ready then
                dot.BackgroundColor3=_GACC.accent
            else
                dot.BackgroundColor3=_GACC.accentDark
            end
            
            sbStroke.Color=ready and _GACC.accent or _GACC.accentDark
            RunService.RenderStepped:Wait()
        end
    end)

    local dragStart2,dragStartPos2,dragging2=nil,nil,false
    stealBarFrame.InputBegan:Connect(function(input)
        if uiLocked then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging2=true;dragStart2=input.Position;dragStartPos2=stealBarFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then
                    if dragging2 then dragging2=false; if _GACC.saveUiPos then _GACC.saveUiPos("stealBar",stealBarFrame) end end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if uiLocked then dragging2=false;return end
        if dragging2 and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-dragStart2
            stealBarFrame.Position=UDim2.new(dragStartPos2.X.Scale,dragStartPos2.X.Offset+delta.X,dragStartPos2.Y.Scale,dragStartPos2.Y.Offset+delta.Y)
        end
    end)
end
_GACC.uiPositions = _GACC.uiPositions or {}
pcall(function()
    if not(isfile and isfile(_GACC.CFG_FILE)) then return end
    local ok,d=pcall(function() return HS:JSONDecode(readfile(_GACC.CFG_FILE)) end)
    if not(ok and type(d)=="table") then return end
    if type(d.uiPositions)=="table" then _GACC.uiPositions=d.uiPositions end
    if type(d.uiLocked)=="boolean" then uiLocked=d.uiLocked end
    if d.afterDrop=="Off" or d.afterDrop=="Bat Aimbot" or d.afterDrop=="Bat TP" then _GACC.afterDrop=d.afterDrop end
    if type(d.batDesyncTpEnabled)=="boolean" then batDesyncTpEnabled=d.batDesyncTpEnabled end
    if type(d.batCounter)=="boolean" then _GACC.batCounterEnabled=d.batCounter end
    if d.dropType=="Stand" or d.dropType=="Jump" then _GACC.dropType=d.dropType end
    if type(d.mobileButtonsLocked)=="boolean" then mobileButtonsLocked=d.mobileButtonsLocked end
end)

-- Store/restore a frame position as scale+offset so it survives resolution changes.
_GACC.saveUiPos = function(key, frame)
    if not (key and frame) then return end
    _GACC.uiPositions = _GACC.uiPositions or {}
    local pos = frame.Position
    _GACC.uiPositions[key] = { xs=pos.X.Scale, xo=pos.X.Offset, ys=pos.Y.Scale, yo=pos.Y.Offset }
    if saveConfig then pcall(saveConfig) end
end
_GACC.getUiPos = function(key)
    local t = _GACC.uiPositions and _GACC.uiPositions[key]
    if type(t)~="table" then return nil end
    if type(t.xs)~="number" or type(t.xo)~="number" or type(t.ys)~="number" or type(t.yo)~="number" then return nil end
    return UDim2.new(t.xs,t.xo,t.ys,t.yo)
end

createStealBar()

-- ==================== MOBILE BUTTONS ====================
local mobileButtonStates = {}
local mobileButtonRefs = {}
_GACC.mobileButtonPositions = _GACC.mobileButtonPositions or {}

local function setupMobileButtons()
    if playerGui:FindFirstChild("BrainrotMenu") then
        playerGui.BrainrotMenu:Destroy()
    end

    -- Ritual Hub mobile button styling
    local EDGE_MARGIN = 20
    local BTN_W = 62
    local BTN_H = 62
    local GAP_X = 8
    local GAP_Y = 8
    local CORNER = 16
    local TXT = 12
    local DARK = Color3.fromRGB(8, 8, 10)
    local ACTIVE_BLUE = Color3.fromRGB(40, 110, 255)
    local B_TOP = Color3.fromRGB(153, 229, 255)
    local B_BOT = Color3.fromRGB(77, 210, 255)
    local WHITE = Color3.fromRGB(255, 255, 255)

    local DATA = {
        { "DropBrainrot", "DROP\nBRAINROT", false },
        { "AutoLeft",     "AUTO\nLEFT",     false },
        { "BatAimbot",    "BAT\nAIMBOT",    false },
        { "AutoRight",    "AUTO\nRIGHT",    false },
        { "TpDown",       "TP\nDOWN",       false },
        { "CarrySpeed",   "CARRY\nSPD",     true  },
        { "LaggerNormal", "LAGGER\nMODE",   false },
        { "LaggerCarry",  "LAGGER\nCARRY",  false },
        { "InstantReset", "INSTANT\nRESET", false },
        { "TpBat",        "TP\nBAT",        false },
    }

    -- Fire-once buttons: flash blue on tap rather than staying lit.
    local MOMENTARY = { DropBrainrot = true, TpDown = true, InstantReset = true }

    local COLS = 2
    local ROWS = math.ceil(#DATA / COLS)
    local TOTAL_W = BTN_W * COLS + GAP_X * (COLS - 1)
    local TOTAL_H = BTN_H * ROWS + GAP_Y * (ROWS - 1)

    local gui = Instance.new("ScreenGui")
    gui.Name = "BrainrotMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.BackgroundTransparency = 1
    main.Active = false
    main.AnchorPoint = Vector2.new(1, 0.5)
    main.Size = UDim2.fromOffset(TOTAL_W, TOTAL_H)
    main.Position = UDim2.new(1, -EDGE_MARGIN, 0.5, 0)
    main.Parent = gui

    -- Add UIScale for mobile buttons
    local mobileScaleObj = Instance.new("UIScale")
    mobileScaleObj.Name = "MobileScale"
    mobileScaleObj.Scale = mobileBtnScale
    mobileScaleObj.Parent = main
    _GACC.mobileScaleObj = mobileScaleObj

    local Actions = {
        DropBrainrot = function(on)
            if on then runDrop() end
        end,
        AutoLeft = function(on)
            if on then _GACC.exclusiveStop("autoLeft") end
            autoLeftEnabled = on
            if on then startAutoLeft() else stopAutoLeft() end
            if autoLeftSetVisual then autoLeftSetVisual(on) end
            if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(on) end
        end,
        BatAimbot = function(on)
            if on then _GACC.exclusiveStop("batAimbot") end
            autoBatEnabled = on
            if on then startBatAimbot() else stopBatAimbot() end
            if autoBatSetVisual then autoBatSetVisual(on) end
            if mobBtnRefs.autoBat then mobBtnRefs.autoBat(on) end
        end,
        AutoRight = function(on)
            if on then _GACC.exclusiveStop("autoRight") end
            autoRightEnabled = on
            if on then startAutoRight() else stopAutoRight() end
            if autoRightSetVisual then autoRightSetVisual(on) end
            if mobBtnRefs.autoRight then mobBtnRefs.autoRight(on) end
        end,
        TpDown = function(on)
            if on then runTPFloor() end
        end,
        CarrySpeed = function(on)
            manualSpeedOverride=true
            setSpeedMode(on and "Carry" or "Normal")
            if _GACC.safeCarryVisual then _GACC.safeCarryVisual(carrySpeedActive) end
            if _GACC.safeLaggerVisual then _GACC.safeLaggerVisual(laggerModeEnabled) end
            if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
            if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
        end,
        LaggerNormal = function(on)
            manualSpeedOverride=true
            setSpeedMode(on and "Lagger" or "Normal")
            if _GACC.safeLaggerVisual then _GACC.safeLaggerVisual(laggerModeEnabled) end
            if _GACC.safeCarryVisual then _GACC.safeCarryVisual(carrySpeedActive) end
            if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
            if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
        end,
        LaggerCarry = function(on)
            manualSpeedOverride=true
            setSpeedMode(on and "Lagger Carry" or "Normal")
            if _GACC.safeLaggerVisual then _GACC.safeLaggerVisual(laggerModeEnabled) end
            if _GACC.safeCarryVisual then _GACC.safeCarryVisual(carrySpeedActive) end
            if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
            if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
        end,
        InstantReset = function(on)
            if on then instantReset() end
        end,
        TpBat = function(on)
            if on then _GACC.exclusiveStop("batTp") end
            batDesyncTpEnabled = on
            if on then startBatDesyncTp() else stopBatDesyncTp() end
            if batDesyncTpSetVisual then batDesyncTpSetVisual(on) end
        end,
    }

    local DRAG_THRESHOLD = 6

    local function makeButton(name, text, defaultActive, order)
        local index = order - 1
        local col = index % COLS
        local row = math.floor(index / COLS)
        local px = col * (BTN_W + GAP_X)
        local py = row * (BTN_H + GAP_Y)

        local holder = Instance.new("Frame")
        holder.Name = name
        holder.LayoutOrder = order
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.fromOffset(BTN_W, BTN_H)
        holder.Position = UDim2.fromOffset(px, py)
        holder.Parent = main

        local scale = Instance.new("UIScale")
        scale.Parent = holder

        local bg = Instance.new("Frame")
        bg.Name = "BG"
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = DARK
        bg.BorderSizePixel = 0
        bg.ZIndex = 1
        bg.Parent = holder

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, CORNER)
        c.Parent = bg

        local grad = Instance.new("UIGradient")
        grad.Rotation = 90
        grad.Color = ColorSequence.new(B_TOP, B_BOT)
        grad.Enabled = false
        grad.Parent = bg

        local b = Instance.new("TextButton")
        b.Name = "Btn"
        b.Size = UDim2.fromScale(1, 1)
        b.BackgroundTransparency = 1
        b.AutoButtonColor = false
        b.BorderSizePixel = 0
        b.ZIndex = 2
        b.Text = text
        b.TextColor3 = WHITE
        b.TextTransparency = 0
        b.TextSize = TXT
        b.Font = Enum.Font.GothamBlack
        b.TextWrapped = true
        b.LineHeight = 1.15
        b.Parent = holder

        local state = defaultActive

        -- Ritual Hub press feel: squash to 0.88, spring back with Back easing.
        local function punch()
            scale.Scale = 0.88
            TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        end

        local function paint(animate)
            TweenService:Create(bg, TweenInfo.new(0.15), { BackgroundColor3 = state and ACTIVE_BLUE or DARK }):Play()
            b.TextColor3 = WHITE
            if animate then punch() end
        end

        local function flash()
            punch()
            TweenService:Create(bg, TweenInfo.new(0.07), { BackgroundColor3 = ACTIVE_BLUE }):Play()
            task.delay(0.25, function()
                TweenService:Create(bg, TweenInfo.new(0.2), { BackgroundColor3 = DARK }):Play()
            end)
        end

        bg.BackgroundColor3 = state and ACTIVE_BLUE or DARK
        b.TextColor3 = WHITE

        local savedPos = _GACC.mobileButtonPositions[name]
        if savedPos then
            holder.Position = UDim2.new(0, savedPos.X or px, 0, savedPos.Y or py)
        end

        local dragging, dragMoved, dragStart, startPos, heldInput = false, false, nil, nil, nil

        local function release()
            TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
        end

        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragMoved = false
                heldInput = input
                dragStart = input.Position
                startPos = holder.Position
                holder.ZIndex = 10
                TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if mobileButtonsLocked then return end  -- taps still register, dragging does not
            if not dragging or not heldInput then return end
            local ok = input == heldInput or (input.UserInputType == Enum.UserInputType.MouseMovement and heldInput.UserInputType == Enum.UserInputType.MouseButton1)
            if not ok then return end

            local delta = input.Position - dragStart
            if not dragMoved and delta.Magnitude > DRAG_THRESHOLD then
                dragMoved = true
            end
            if dragMoved then
                holder.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    heldInput = nil
                    release()
                    if not dragMoved then
                        local fn = Actions[name]
                        if MOMENTARY[name] then
                            flash()
                            if fn then task.spawn(fn, true) end
                        else
                            state = not state
                            paint(true)
                            if fn then task.spawn(fn, state) end
                        end
                        _GACC.mobileButtonPositions[name] = { X = holder.Position.X.Offset, Y = holder.Position.Y.Offset }
                        saveConfig()
                    else
                        _GACC.mobileButtonPositions[name] = { X = holder.Position.X.Offset, Y = holder.Position.Y.Offset }
                        saveConfig()
                    end
                end
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if dragging and (input == heldInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
                dragging = false
                heldInput = nil
                release()
            end
        end)

        b.MouseLeave:Connect(release)

        mobileButtonRefs[name] = {
            holder = holder,
            setState = function(on)
                if state == on then return end
                state = on
                paint()
            end,
            getState = function() return state end
        }
        mobileButtonStates[name] = state
        return holder
    end

    for i, info in ipairs(DATA) do
        makeButton(info[1], info[2], info[3], i)
    end

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)
end

pcall(function()
    if not(isfile and isfile(_GACC.CFG_FILE)) then return end
    local ok,d=pcall(function() return HS:JSONDecode(readfile(_GACC.CFG_FILE)) end)
    if ok and type(d)=="table" and type(d.mobileButtonPositions)=="table" then
        _GACC.mobileButtonPositions = d.mobileButtonPositions
    end
end)

setupMobileButtons()

local function updateMobileButtonState(name, state)
    if mobileButtonRefs[name] then
        mobileButtonRefs[name].setState(state)
    end
end

local origToggleCarry = toggleCarryMode
toggleCarryMode = function()
    origToggleCarry()
    updateMobileButtonState("CarrySpeed", speedMode == "Carry")
    updateMobileButtonState("LaggerNormal", speedMode == "Lagger")
    updateMobileButtonState("LaggerCarry", speedMode == "Lagger Carry")
end

local origToggleLagger = toggleLaggerMode
toggleLaggerMode = function()
    origToggleLagger()
    updateMobileButtonState("CarrySpeed", speedMode == "Carry")
    updateMobileButtonState("LaggerNormal", speedMode == "Lagger")
    updateMobileButtonState("LaggerCarry", speedMode == "Lagger Carry")
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if mobileButtonRefs.DropBrainrot then
            updateMobileButtonState("DropBrainrot", false)
            updateMobileButtonState("AutoLeft", autoLeftEnabled)
            updateMobileButtonState("BatAimbot", autoBatEnabled)
            updateMobileButtonState("AutoRight", autoRightEnabled)
            updateMobileButtonState("TpDown", false)
            updateMobileButtonState("CarrySpeed", speedMode == "Carry")
            updateMobileButtonState("LaggerNormal", speedMode == "Lagger")
            updateMobileButtonState("LaggerCarry", speedMode == "Lagger Carry")
            updateMobileButtonState("InstantReset", false)
            updateMobileButtonState("TpBat", batDesyncTpEnabled)
        end
    end
end)

pcall(function()
    if not(isfile and isfile(_GACC.CFG_FILE)) then return end
    local ok,d=pcall(function() return HS:JSONDecode(readfile(_GACC.CFG_FILE)) end)
    if not(ok and type(d)=="table") then return end
    if type(d.normalSpeed)=="number" and d.normalSpeed>0 then NS=d.normalSpeed end
    if type(d.carrySpeed)=="number" and d.carrySpeed>0 then CS=d.carrySpeed end
    if type(d.laggerSpeed)=="number" and d.laggerSpeed>0 then LAGGER_SPEED=d.laggerSpeed end
    if type(d.laggerCarrySpeed)=="number" and d.laggerCarrySpeed>0 then LAGGER_CARRY_SPEED=d.laggerCarrySpeed end
    if type(d.speedMode)=="string" then
        setSpeedMode(d.speedMode)
    elseif type(d.laggerModeEnabled)=="boolean" or type(d.carrySpeedActive)=="boolean" then
        local savedLagger = d.laggerModeEnabled == true
        local savedCarry = d.carrySpeedActive == true
        if savedLagger and savedCarry then
            setSpeedMode("Lagger Carry")
        elseif savedLagger then
            setSpeedMode("Lagger")
        elseif savedCarry then
            setSpeedMode("Carry")
        else
            setSpeedMode("Normal")
        end
    else
        setSpeedMode("Normal")
    end
    if type(d.antiRagdoll)=="boolean" then antiRagdollEnabled=d.antiRagdoll end
    if type(d.infiniteJump)=="boolean" then infJumpEnabled=d.infiniteJump end
    if type(d.infJumpMode)=="string" then infJumpMode=d.infJumpMode end
    if type(d.medusaCounter)=="boolean" then medusaCounterEnabled=d.medusaCounter end
    if type(d.autoStealEnabled)=="boolean" then Steal.AutoStealEnabled=d.autoStealEnabled end
    if d.stealMode=="op" then stealMode="v1"  -- OP retired; V1 is its closest preset
    elseif type(d.stealMode)=="string" and (d.stealMode=="normal" or d.stealMode=="semi" or _GACC.isVersionMode(d.stealMode)) then stealMode=d.stealMode end
    if type(d.grabRadius)=="number" then Steal.StealRadius=d.grabRadius end
    if type(d.stealDuration)=="number" then Steal.StealDuration=d.stealDuration end
    local savedOPRadius=d.opRadius or d.opPrimeRange or d.semiPrimeRange
    if type(savedOPRadius)=="number" then SemiSteal.CONFIG.RADIUS=math.clamp(savedOPRadius,1,500) end
    if type(d.opDuration)=="number" then SemiSteal.CONFIG.DURATION=math.clamp(d.opDuration,.05,10) end
    local savedOPDelayRadius=d.opDelayRadius or d.delayRadius
    if type(savedOPDelayRadius)=="number" then SemiSteal.CONFIG.DELAY_RADIUS=math.clamp(savedOPDelayRadius,1,500) end
    if type(d.opStopTime)=="number" then SemiSteal.CONFIG.STOP_TIME=math.clamp(d.opStopTime,.05,10) end
    if type(d.opStopTimeEnabled)=="boolean" then SemiSteal.CONFIG.STOP_TIME_ENABLED=d.opStopTimeEnabled end
    if type(d.autoSwing)=="boolean" then autoSwingEnabled=d.autoSwing end
    if type(d.unwalkEnabled)=="boolean" then unwalkEnabled=d.unwalkEnabled end
    if type(d.antiLag)=="boolean" then antiLagEnabled=d.antiLag end
    if type(d.stretchRez)=="boolean" then stretchRezEnabled=d.stretchRez end
    if type(d.autoTPEnabled)=="boolean" then autoTPEnabled=d.autoTPEnabled end
    if type(d.autoTPHeight)=="number" then autoTPHeight=d.autoTPHeight end
    if type(d.fovValue)=="number" then fovValue=d.fovValue end
    if type(d.fovIndex)=="number" then fovIndex=d.fovIndex end
    if type(d.skyTheme)=="string" then currentSkyTheme=d.skyTheme end
    if type(d.autoMoveSwing)=="boolean" then autoMoveSwingEnabled=d.autoMoveSwing end
    if type(d.autoMoveSwingInterval)=="number" then autoMoveSwingInterval=d.autoMoveSwingInterval end
    if type(d.ragdollGui)=="boolean" then ragdollGuiEnabled=d.ragdollGui end
    if type(d.mobileButtonsEnabled)=="boolean" then mobileButtonsEnabled=d.mobileButtonsEnabled end
    if type(d.mobileButtonsSize)=="number" then mobileButtonsSize=d.mobileButtonsSize end
    if type(d.circleButtonsEnabled)=="boolean" then circleButtonsEnabled=d.circleButtonsEnabled end
    if type(d.introSoundEnabled)=="boolean" then introSoundEnabled=d.introSoundEnabled end
    if type(d.medusaResetEnabled)=="boolean" then _GACC.medusaResetEnabled=d.medusaResetEnabled end
    if type(d.antiSummerBaseEnabled)=="boolean" then
        if d.antiSummerBaseEnabled then AntiSummer.enable() else AntiSummer.disable() end
    end
    if type(d.antiDieEnabled)=="boolean" then antiDieEnabled=d.antiDieEnabled end  -- NEW
    animEnabled=false
    local savedPack=type(d.animationPack)=="string" and d.animationPack or d.animPack
    if type(savedPack)=="string" then _GACC.extras.setPack(savedPack,false) end
    if type(d.headlessEnabled)=="boolean" then _GACC.extras.setHeadless(d.headlessEnabled) end
    if type(d.korbloxEnabled)=="boolean" then _GACC.extras.setKorblox(d.korbloxEnabled) end
    if type(d.backgroundEnabled)=="boolean" then backgroundEnabled=d.backgroundEnabled end
    if type(d.backgroundIndex)=="number" then backgroundIndex=d.backgroundIndex end
    if type(d.playerHighlightEnabled)=="boolean" then _GACC.playerHighlightEnabled=d.playerHighlightEnabled end
    if type(d.colorThemeName)=="string" and THEME_DEFS[d.colorThemeName] then currentColorTheme=d.colorThemeName end
    if type(d.autoSwitchSpeed)=="boolean" then autoSwitchSpeedEnabled=d.autoSwitchSpeed end
    if type(d.autoCarrySpeedEnabled)=="boolean" then _GACC.autoCarrySpeedEnabled=d.autoCarrySpeedEnabled end
    if type(d.mobileButtonPositions)=="table" then _GACC.mobileButtonPositions = d.mobileButtonPositions end
    -- NEW SCALES
    if type(d.menuScale)=="number" and d.menuScale>0 then menuScale=d.menuScale end
    if type(d.mobileBtnScale)=="number" and d.mobileBtnScale>0 then mobileBtnScale=d.mobileBtnScale end
    if type(d.stealBarScale)=="number" and d.stealBarScale>0 then stealBarScale=d.stealBarScale end
    if type(d.uiLocked)=="boolean" then uiLocked=d.uiLocked end
    if d.afterDrop=="Off" or d.afterDrop=="Bat Aimbot" or d.afterDrop=="Bat TP" then _GACC.afterDrop=d.afterDrop end
    if type(d.batDesyncTpEnabled)=="boolean" then batDesyncTpEnabled=d.batDesyncTpEnabled end
    if type(d.batCounter)=="boolean" then _GACC.batCounterEnabled=d.batCounter end
    if d.dropType=="Stand" or d.dropType=="Jump" then _GACC.dropType=d.dropType end
    if type(d.mobileButtonsLocked)=="boolean" then mobileButtonsLocked=d.mobileButtonsLocked end
    if type(d.safeModeEnabled)=="boolean" then _GACC.safeModeEnabled=d.safeModeEnabled end
    if type(d.uiPositions)=="table" then _GACC.uiPositions=d.uiPositions end
end)

pcall(function()
    task.spawn(function() task.wait(.5); _GACC.extras.applyPack(_GACC.extras.getPack()) end)
    if _GACC.extras.getHeadless() or _GACC.extras.getKorblox() then task.spawn(function() task.wait(.3); local char=LP.Character; if char then _GACC.extras.onCharacter(char) end end) end
    if antiLagEnabled then task.spawn(function() task.wait(1); if enableAntiLag then enableAntiLag() end end) end
    if stretchRezEnabled then task.spawn(function() task.wait(0.5); if enableStretchRez then enableStretchRez() end end) end
    if antiRagdollEnabled then task.spawn(function() task.wait(0.5); if startAntiRagdoll then startAntiRagdoll() end end) end
    if infJumpEnabled then task.spawn(function() task.wait(0.5); if setInfJumpInternal then setInfJumpInternal(true) end end) end
    if Steal.AutoStealEnabled then task.spawn(function() task.wait(1); if startAutoSteal then startAutoSteal() end end) end
    if medusaCounterEnabled then task.spawn(function() task.wait(1); local char=LP.Character; if char and setupMedusa then setupMedusa(char) end end) end
    if autoTPEnabled then task.spawn(function() task.wait(0.5); if startAutoTP then startAutoTP() end end) end
    if currentSkyTheme and currentSkyTheme ~= "" then task.spawn(function() task.wait(1); if CandyApplyCustomSky then CandyApplyCustomSky(currentSkyTheme) end end) end
    if _GACC.medusaResetEnabled then
        task.spawn(function()
            task.wait(1)
            _GACC.startMedusaReset(LP.Character)
        end)
    end
    if AntiSummer.antiSummerBaseEnabled then
        task.spawn(function() AntiSummer.enable() end)
    end
    if antiDieEnabled then  -- NEW: start Anti Die on load
        task.spawn(function()
            task.wait(1)
            startAntiDie()
        end)
    end
end)

_GACC.GuiToggleSetters = {}

-- ==================== MAIN GUI ====================
;(function()

    local GuiRefs = {}
    
    local _thm0 = THEME_DEFS[currentColorTheme] or THEME_DEFS.RAIN
    local _ACC = {accent=_thm0.accent,accentDark=_thm0.accentDark,accentBg=_thm0.accentBg,accentHover=_thm0.accentHover,accentRowHover=_thm0.accentRowHover}
    
    local _themeSeps,_themeScrollbars,_themeSectRefs,_themeTabBtns={},{},{},{}
    local _themeTabInds,_themeActBtns,_themeKbLabels,_themeSwatchStrokes={},{},{},{}
    local _themeToggleRefs={}  
    local applyColorTheme 
    local C={
        bg=Color3.fromRGB(2,7,13), bgDark=Color3.fromRGB(0,3,8), row=Color3.fromRGB(7,15,24),
        input=Color3.fromRGB(5,16,29), blue=_ACC.accent, blueDim=Color3.fromRGB(73,105,135),
        blueDark=Color3.fromRGB(7,22,38), text=Color3.fromRGB(240,247,255), textDim=Color3.fromRGB(155,177,199),
        textMuted=Color3.fromRGB(96,117,138), white=Color3.fromRGB(255,255,255), divider=Color3.fromRGB(25,53,78),
        green=Color3.fromRGB(80,220,120),
        yellow=Color3.fromRGB(255,220,0), yellowDim=Color3.fromRGB(160,130,0),
        accent=_ACC.accent, accentDark=_ACC.accentDark, accentBg=_ACC.accentBg,
        accentHover=_ACC.accentHover, accentRowHover=_ACC.accentRowHover,
    }

    local function guiCorner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=p;return c end
    local function guiStroke(p,col,t) local s=Instance.new("UIStroke");s.Color=col or Color3.fromRGB(60,60,70);s.Thickness=t or 1;s.Parent=p;return s end
    local function tw(obj,props,ti) TweenService:Create(obj,ti or TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props):Play() end
    
    local function _accentGrad(t)
        local a=_ACC.accent; local d=_ACC.accentDark
        local pulse=math.sin(t*0.7)*0.14
        local aR=math.clamp(math.floor(a.R*255*(1+pulse)),0,255)
        local aG=math.clamp(math.floor(a.G*255*(1+pulse)),0,255)
        local aB=math.clamp(math.floor(a.B*255*(1+pulse)),0,255)
        local dR=math.clamp(math.floor(d.R*255*(0.75+pulse*0.25)),0,255)
        local dG=math.clamp(math.floor(d.G*255*(0.75+pulse*0.25)),0,255)
        local dB=math.clamp(math.floor(d.B*255*(0.75+pulse*0.25)),0,255)
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(dR,dG,dB)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(aR,aG,aB)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.82,Color3.fromRGB(aR,aG,aB)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(dR,dG,dB)),
        })
    end

    local function makeDraggable_cyber(dragTarget, moveTarget, saveKey)
        moveTarget = moveTarget or dragTarget
        local dragging, dragInput, dragStart, startPos = false
        dragTarget.InputBegan:Connect(function(input)
            if uiLocked then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=input.Position; startPos=moveTarget.Position
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then
                        if dragging then
                            dragging=false
                            if saveKey and _GACC.saveUiPos then _GACC.saveUiPos(saveKey,moveTarget) end
                        end
                    end
                end)
            end
        end)
        dragTarget.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end
        end)
        UIS.InputChanged:Connect(function(input)
            if uiLocked then dragging=false; return end
            if input==dragInput and dragging then
                local delta=input.Position-dragStart
                moveTarget.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            end
        end)
    end

    local Keys={
        circle=Enum.KeyCode.E, speed=Enum.KeyCode.Q, carryMode=Enum.KeyCode.C,
        laggerToggle=Enum.KeyCode.K, guiHide=Enum.KeyCode.RightControl,
        dropBrainrot=Enum.KeyCode.H, tpDown=Enum.KeyCode.T,
        autoLeft=Enum.KeyCode.J, autoRight=Enum.KeyCode.L,
        batDesyncTp=Enum.KeyCode.X,
        instantReset=Enum.KeyCode.R
    }

    pcall(function()
        if not(isfile and isfile(_GACC.CFG_FILE)) then return end
        local ok,d=pcall(function() return HS:JSONDecode(readfile(_GACC.CFG_FILE)) end)
        if ok and type(d)=="table" and type(d.keys)=="table" then
            for k,v in pairs(d.keys) do
                local ok2,kc=pcall(function() return Enum.KeyCode[v] end)
                if ok2 and kc and kc~=Enum.KeyCode.Unknown then Keys[k]=kc end
            end
        end
    end)
    _GuiKeys = Keys

    local PlayerGui = LP:WaitForChild("PlayerGui")

    local GuiHub=Instance.new("ScreenGui")
    GuiHub.Name="RitualHub"; GuiHub.ResetOnSpawn=false
    GuiHub.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    GuiHub.Parent=PlayerGui
    GuiRefs.hub=GuiHub

    local Outer=Instance.new("Frame")
    Outer.Name="Outer"; Outer.Size=UDim2.new(0,310,0,410); Outer.Position=UDim2.new(0,-330,0,80)
    Outer.BackgroundTransparency=1; Outer.BorderSizePixel=0; Outer.ClipsDescendants=false; Outer.Parent=GuiHub
    Outer:GetPropertyChangedSignal("Size"):Connect(function() if Outer.Size~=UDim2.fromOffset(310,410) then Outer.Size=UDim2.fromOffset(310,410) end end)
    GuiRefs.outer=Outer

    -- Add Menu Scale UIScale
    local menuScaleObj = Instance.new("UIScale")
    menuScaleObj.Name = "MenuScale"
    menuScaleObj.Scale = menuScale
    menuScaleObj.Parent = Outer
    _GACC.menuScaleObj = menuScaleObj  -- store in global table

    local Inner=Instance.new("Frame")
    Inner.Name="Inner"; Inner.ClipsDescendants=false; Inner.Size=UDim2.new(1,0,1,0)
    Inner.BackgroundColor3=C.bg; Inner.BackgroundTransparency=.70; Inner.BorderSizePixel=0; Inner.Parent=Outer
    innerPanelRef=Inner
    guiCorner(Inner,14)
    local _innerStroke=guiStroke(Inner,_ACC.accentDark,1.5); GuiRefs.inner=Inner
    _innerStroke.Color=_ACC.accentDark
    _innerStroke.Thickness=1.2
    local openScale=Instance.new("UIScale",Inner); openScale.Scale=0.94
    TweenService:Create(openScale,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    task.delay(.45,function()
        if not openScale.Parent then return end
        openScale.Scale=1
        openScale:GetPropertyChangedSignal("Scale"):Connect(function() if openScale.Scale~=1 then openScale.Scale=1 end end)
    end)
    local cornerL=Instance.new("Frame",Inner)
    cornerL.Size=UDim2.new(0,18,0,2); cornerL.Position=UDim2.new(0,8,1,-9)
    cornerL.BackgroundColor3=_GACC.accentDark; cornerL.BackgroundTransparency=0.25; cornerL.BorderSizePixel=0; cornerL.ZIndex=10; cornerL.Visible=false
    local cornerLV=Instance.new("Frame",Inner)
    cornerLV.Size=UDim2.new(0,2,0,8); cornerLV.Position=UDim2.new(0,8,1,-15)
    cornerLV.BackgroundColor3=_GACC.accentDark; cornerLV.BackgroundTransparency=0.25; cornerLV.BorderSizePixel=0; cornerLV.ZIndex=10; cornerLV.Visible=false
    local cornerR=Instance.new("Frame",Inner)
    cornerR.Size=UDim2.new(0,18,0,2); cornerR.Position=UDim2.new(1,-26,1,-9)
    cornerR.BackgroundColor3=_GACC.accentDark; cornerR.BackgroundTransparency=0.25; cornerR.BorderSizePixel=0; cornerR.ZIndex=10; cornerR.Visible=false
    local cornerRV=Instance.new("Frame",Inner)
    cornerRV.Size=UDim2.new(0,2,0,8); cornerRV.Position=UDim2.new(1,-10,1,-15)
    cornerRV.BackgroundColor3=_GACC.accentDark; cornerRV.BackgroundTransparency=0.25; cornerRV.BorderSizePixel=0; cornerRV.ZIndex=10; cornerRV.Visible=false
    table.insert(_themeExtRefs,{callback=function(thm)
        pcall(function()
            cornerL.BackgroundColor3=thm.accentDark; cornerLV.BackgroundColor3=thm.accentDark
            cornerR.BackgroundColor3=thm.accentDark; cornerRV.BackgroundColor3=thm.accentDark
        end)
    end})
    task.spawn(function()
        local bright=false
        while Inner and Inner.Parent do
            bright=not bright
            TweenService:Create(_innerStroke,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{
                Transparency=bright and .34 or .68,
                Color=bright and _GACC.accent or _GACC.accentDark
            }):Play()
            task.wait(1.4)
        end
    end)
    Outer.Position=UDim2.new(0,20,0,80)
    do
        local mp=_GACC.getUiPos and _GACC.getUiPos("menu")
        if mp then
            local bad = mp.X.Scale < -0.5 or mp.X.Scale > 1.5
                or mp.Y.Scale < -0.5 or mp.Y.Scale > 1.5
                or mp.X.Offset < -500 or mp.X.Offset > 3000
                or mp.Y.Offset < -500 or mp.Y.Offset > 3000
            if not bad then Outer.Position=mp end
        end
    end
    Outer.Visible=true

    do 
    local BgCont=Instance.new("Frame")
    BgCont.Name="BackgroundContainer"; BgCont.Size=UDim2.new(1,0,1,0)
    BgCont.BackgroundTransparency=1; BgCont.ZIndex=0; BgCont.Parent=Inner

    local BgGrad=Instance.new("Frame")
    BgGrad.Name="BgGrad"; BgGrad.Size=UDim2.new(1,0,1,0); BgGrad.BackgroundColor3=C.bgDark
    BgGrad.BackgroundTransparency=1; BgGrad.BorderSizePixel=0; BgGrad.ZIndex=0; BgGrad.Parent=BgCont; guiCorner(BgGrad,12)
    bgGradientRef=BgGrad
    local grad=Instance.new("UIGradient")
    grad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,5,12)),
        ColorSequenceKeypoint.new(0.35,Color3.fromRGB(4,18,32)),
        ColorSequenceKeypoint.new(0.65,Color3.fromRGB(6,25,44)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(1,8,17)),
    })
    grad.Rotation=135; grad.Parent=BgGrad; GuiRefs.bgGrad=BgGrad
    task.spawn(function()
        local t=0
        while grad and grad.Parent do
            t=t+0.012
            grad.Offset=Vector2.new(math.sin(t)*0.12,math.cos(t*0.7)*0.08)
            grad.Rotation=135+math.sin(t*0.5)*8
            task.wait(0.04)
        end
    end)

    local RainLayer=Instance.new("Frame",BgCont)
    RainLayer.Name="RainEffect"
    RainLayer.Size=UDim2.fromScale(1,1)
    RainLayer.BackgroundTransparency=1
    RainLayer.BorderSizePixel=0
    RainLayer.ClipsDescendants=true
    RainLayer.Active=false
    RainLayer.ZIndex=1
    RainLayer.Visible=false
    rainLayerRef=RainLayer
    guiCorner(RainLayer,12)
    local rainHaze=Instance.new("Frame",RainLayer)
    rainHaze.Size=UDim2.new(1,0,.42,0); rainHaze.BackgroundColor3=_ACC.accentBg; rainHaze.BackgroundTransparency=.72; rainHaze.BorderSizePixel=0; rainHaze.ZIndex=0
    local hazeGrad=Instance.new("UIGradient",rainHaze); hazeGrad.Rotation=90; hazeGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.18),NumberSequenceKeypoint.new(1,1)})
    for index=1,28 do
        local glow=Instance.new("Frame",RainLayer)
        glow.Name="RainGlow"..index; glow.AnchorPoint=Vector2.new(.5,.5); glow.Size=UDim2.fromOffset(index%6==0 and 4 or 2,20+(index%7)*4)
        glow.BackgroundColor3=_ACC.accent; glow.BackgroundTransparency=.94; glow.BorderSizePixel=0; glow.Rotation=13; glow.ZIndex=0; guiCorner(glow,4)
        local drop=Instance.new("Frame",RainLayer)
        drop.Name="Drop"..index
        drop.AnchorPoint=Vector2.new(0.5,0.5)
        drop.Size=UDim2.fromOffset(index%7==0 and 2 or 1,14+(index%8)*3)
        drop.BackgroundColor3=index%5==0 and Color3.fromRGB(235,247,255) or _ACC.accent
        drop.BackgroundTransparency=0.34+(index%5)*0.08
        drop.BorderSizePixel=0
        drop.Rotation=13
        drop.ZIndex=1
        guiCorner(drop,2)
        local dropGrad=Instance.new("UIGradient",drop); dropGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(245,252,255)),ColorSequenceKeypoint.new(1,_ACC.accent)}); dropGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.62),NumberSequenceKeypoint.new(.35,0),NumberSequenceKeypoint.new(1,.28)}); dropGrad.Rotation=90
        local splash=Instance.new("Frame",RainLayer); splash.AnchorPoint=Vector2.new(.5,.5); splash.Size=UDim2.fromOffset(2,1); splash.BackgroundColor3=_ACC.accent; splash.BackgroundTransparency=1; splash.BorderSizePixel=0; splash.ZIndex=1; guiCorner(splash,2)
        task.spawn(function()
            task.wait((index%14)*0.065)
            while drop and drop.Parent do
                local x=math.random(3,102)/100
                local duration=0.5+(index%11)*0.068
                drop.Position=UDim2.new(x,0,0,-24)
                glow.Position=UDim2.new(x,0,0,-24)
                drop.BackgroundColor3=index%5==0 and Color3.fromRGB(235,247,255) or _GACC.accent
                glow.BackgroundColor3=_GACC.accent
                local fall=TweenService:Create(drop,TweenInfo.new(duration,Enum.EasingStyle.Linear),{
                    Position=UDim2.new(x-0.13,0,1,34)
                })
                TweenService:Create(glow,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Position=UDim2.new(x-0.13,0,1,34)}):Play()
                fall:Play()
                fall.Completed:Wait()
                splash.Position=UDim2.new(x-0.13,0,1,-4); splash.Size=UDim2.fromOffset(2,1); splash.BackgroundColor3=_GACC.accent; splash.BackgroundTransparency=index%3==0 and .48 or 1
                TweenService:Create(splash,TweenInfo.new(.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(10,1),BackgroundTransparency=1}):Play()
                task.wait(0.025+(index%4)*0.025)
            end
        end)
    end

    local BgImg=Instance.new("ImageLabel")
    BgImg.Name="BackgroundImage"; BgImg.Size=UDim2.new(1,0,1,0); BgImg.BackgroundTransparency=1
    BgImg.Image=""; BgImg.ScaleType=Enum.ScaleType.Stretch; BgImg.ZIndex=0; BgImg.Visible=false
    BgImg.Parent=BgCont; local BgImgCorner=guiCorner(BgImg,12); GuiRefs.backgroundImage=BgImg; bgImageRef=BgImg
    bgImageContainer=BgCont; bgImageCorner=BgImgCorner
    applyBackgroundImage()

    local HF=Instance.new("Frame")
    HF.Name="HeaderFrame"; HF.Size=UDim2.new(1,0,0,74); HF.BackgroundTransparency=1
    HF.BorderSizePixel=0; HF.Parent=Inner; HF.ZIndex=2
    makeDraggable_cyber(HF, Outer, "menu")

    do
        local headerPlate=Instance.new("Frame",HF)
        headerPlate.Name="PrivateHeaderPlate"; headerPlate.Position=UDim2.new(0,6,0,5); headerPlate.Size=UDim2.new(1,-12,0,61)
        headerPlate.BackgroundColor3=Color3.fromRGB(5,20,36); headerPlate.BackgroundTransparency=.72; headerPlate.BorderSizePixel=0; headerPlate.ZIndex=2
        guiCorner(headerPlate,10)
        local plateStroke=guiStroke(headerPlate,_ACC.accentDark,1); plateStroke.Transparency=.20
        local plateGrad=Instance.new("UIGradient",headerPlate)
        plateGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(8,42,76)),ColorSequenceKeypoint.new(.48,Color3.fromRGB(4,22,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(1,9,18))})
        plateGrad.Rotation=12
        local topLine=Instance.new("Frame",HF)
        topLine.Position=UDim2.new(0,28,0,6); topLine.Size=UDim2.new(0,116,0,2); topLine.BackgroundColor3=_ACC.accent; topLine.BorderSizePixel=0; topLine.ZIndex=3
        guiCorner(topLine,2)
        local lineFade=Instance.new("UIGradient",topLine)
        lineFade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.72,.48),NumberSequenceKeypoint.new(1,1)})
    end

    local TL=Instance.new("TextLabel")
    TL.Position=UDim2.new(0,28,0,13); TL.Size=UDim2.new(0,68,0,27); TL.BackgroundTransparency=1
    TL.Text="RITUAL"; TL.TextColor3=C.text; TL.TextSize=18; TL.Font=Enum.Font.GothamBold
    TL.TextXAlignment=Enum.TextXAlignment.Left; TL.Parent=HF; TL.ZIndex=3
    local PrivateTL=Instance.new("TextLabel")
    PrivateTL.Position=UDim2.new(0,94,0,13); PrivateTL.Size=UDim2.new(0,48,0,27); PrivateTL.BackgroundTransparency=1
    PrivateTL.Text="HUB"; PrivateTL.TextColor3=Color3.fromRGB(188,222,255); PrivateTL.TextSize=18; PrivateTL.Font=Enum.Font.GothamBold
    PrivateTL.TextXAlignment=Enum.TextXAlignment.Left; PrivateTL.TextStrokeColor3=Color3.fromRGB(91,95,106); PrivateTL.TextStrokeTransparency=.58; PrivateTL.Parent=HF; PrivateTL.ZIndex=3
    local privateGrad=Instance.new("UIGradient",PrivateTL)
    privateGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(35,94,165)),ColorSequenceKeypoint.new(.42,Color3.fromRGB(105,186,255)),ColorSequenceKeypoint.new(.58,Color3.fromRGB(245,250,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(74,139,204))})
    privateGrad.Offset=Vector2.new(-1,0)
    task.spawn(function()
        while PrivateTL and PrivateTL.Parent do
            privateGrad.Offset=Vector2.new(-1,0)
            TweenService:Create(privateGrad,TweenInfo.new(1.15,Enum.EasingStyle.Quint,Enum.EasingDirection.InOut),{Offset=Vector2.new(1,0)}):Play()
            task.wait(2.35)
        end
    end)

    local ML=Instance.new("TextLabel")
    ML.Position=UDim2.new(0,28,0,42); ML.Size=UDim2.new(0,126,0,14); ML.BackgroundTransparency=1
    ML.Text="discord.gg/ritualhub"; ML.TextColor3=C.textDim; ML.TextSize=9; ML.Font=Enum.Font.GothamMedium
    ML.TextXAlignment=Enum.TextXAlignment.Left; ML.Parent=HF; ML.ZIndex=3

    local lavaGradML = Instance.new("UIGradient", ML)
    lavaGradML.Color=_accentGrad(0)
    lavaGradML.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.1,0),NumberSequenceKeypoint.new(0.5,0,0),NumberSequenceKeypoint.new(1,0.1,0)})
    lavaGradML.Rotation=0

    task.spawn(function()
        local t=0
        while ML and ML.Parent do
            t=t+0.03
            lavaGradML.Offset=Vector2.new(math.sin(t*0.8)*0.3 + math.cos(t*0.5)*0.2, math.sin(t*0.6)*0.1)
            lavaGradML.Rotation=math.sin(t*0.4)*15
            lavaGradML.Color=_accentGrad(t)
            task.wait(0.03)
        end
    end)

    local hFpsLbl=Instance.new("TextLabel")
    hFpsLbl.Size=UDim2.new(0,175,0,13); hFpsLbl.Position=UDim2.new(0,14,0,48)
    hFpsLbl.BackgroundTransparency=1; hFpsLbl.Text=""; hFpsLbl.Visible=false
    hFpsLbl.TextColor3=Color3.fromRGB(160,160,160); hFpsLbl.Font=Enum.Font.GothamBold
    hFpsLbl.TextSize=9; hFpsLbl.TextXAlignment=Enum.TextXAlignment.Left
    hFpsLbl.ZIndex=3; hFpsLbl.Parent=HF
    do
        local RING_SZ=20; local ring={}; for i=1,RING_SZ do ring[i]=1/60 end
        local ridx=1; local rsum=RING_SZ/60; local cpng=0
        task.spawn(function()
            while hFpsLbl and hFpsLbl.Parent do
                pcall(function() cpng=math.floor(Players.LocalPlayer:GetNetworkPing()*1000) end)
                task.wait(0.5)
            end
        end)
        RunService.RenderStepped:Connect(function(dt)
            rsum=rsum-ring[ridx]+dt; ring[ridx]=dt; ridx=ridx%RING_SZ+1
            local fps=math.floor(1/math.max(rsum/RING_SZ,0.001))
            _perfFps=fps; _perfPing=cpng
            local fc; if fps>=55 then fc=Color3.fromRGB(140,200,80) elseif fps>=30 then fc=Color3.fromRGB(220,200,50) else fc=Color3.fromRGB(210,90,60) end
            local pc; if cpng<80 then pc=Color3.fromRGB(140,200,80) elseif cpng<150 then pc=Color3.fromRGB(220,200,50) else pc=Color3.fromRGB(210,90,60) end
            if hFpsLbl and hFpsLbl.Parent then
                hFpsLbl.Text="FPS: "..tostring(fps).." | PING: "..tostring(cpng).."ms"
                local worstR=math.min(fc.R,pc.R); local worstG=math.min(fc.G,pc.G); local worstB=math.min(fc.B,pc.B)
                hFpsLbl.TextColor3=Color3.fromRGB(math.max(worstR*255,0),math.max(worstG*255,0),math.max(worstB*255,0))
            end
        end)
    end

    local CloseBtn=Instance.new("TextButton")
    CloseBtn.Size=UDim2.new(0,32,0,32); CloseBtn.Position=UDim2.new(1,-44,0,6)
    CloseBtn.BackgroundColor3=C.bgDark; CloseBtn.BackgroundTransparency=1; CloseBtn.BorderSizePixel=0
    CloseBtn.Text="—"; CloseBtn.TextColor3=C.textMuted; CloseBtn.Font=Enum.Font.GothamBlack; CloseBtn.TextSize=18
    CloseBtn.ZIndex=5; CloseBtn.Parent=HF
    guiCorner(CloseBtn,7); local closeBtnStroke=guiStroke(CloseBtn,Color3.fromRGB(90,94,110),1);closeBtnStroke.Transparency=.72
    CloseBtn.MouseEnter:Connect(function()
        tw(CloseBtn,{TextColor3=Color3.fromRGB(255,110,120),BackgroundTransparency=1})
        tw(closeBtnStroke,{Transparency=.38})
    end)
    CloseBtn.MouseLeave:Connect(function()
        tw(CloseBtn,{TextColor3=C.textMuted,BackgroundTransparency=1})
        tw(closeBtnStroke,{Transparency=.72})
    end)

    local MiniBtn=Instance.new("TextButton")
    MiniBtn.Size=UDim2.new(0,120,0,30); MiniBtn.Position=UDim2.new(0,20,0,100)
    MiniBtn.BackgroundColor3=C.bgDark; MiniBtn.BackgroundTransparency=1; MiniBtn.BorderSizePixel=0
    MiniBtn.RichText=true; MiniBtn.Text='RITUAL <font color="rgb(120,190,255)">HUB</font>'; MiniBtn.TextColor3=C.text; MiniBtn.Font=Enum.Font.GothamBold; MiniBtn.TextSize=11
    MiniBtn.ZIndex=20; MiniBtn.Visible=false; MiniBtn.Parent=GuiRefs.hub
    guiCorner(MiniBtn,8); local miniBtnStroke=guiStroke(MiniBtn,Color3.fromRGB(90,94,110),1.2);miniBtnStroke.Transparency=.72
    do local mp=_GACC.getUiPos and _GACC.getUiPos("mini"); if mp then MiniBtn.Position=mp end end
    makeDraggable_cyber(MiniBtn, MiniBtn, "mini")
    MiniBtn.MouseEnter:Connect(function() 
        tw(MiniBtn,{BackgroundTransparency=1})
        tw(miniBtnStroke,{Transparency=.38})
    end)
    MiniBtn.MouseLeave:Connect(function() 
        tw(MiniBtn,{BackgroundTransparency=1})
        tw(miniBtnStroke,{Transparency=.72})
    end)
    local function showGui()
        local home=(_GACC.getUiPos and _GACC.getUiPos("menu")) or UDim2.new(0,20,0,80)
        MiniBtn.Visible=false; Outer.Visible=true
        Outer.Position=UDim2.new(home.X.Scale,home.X.Offset-50,home.Y.Scale,home.Y.Offset)
        TweenService:Create(Outer,TweenInfo.new(0.38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=home}):Play()
    end
    local function hideGui()
        local home=Outer.Position
        if _GACC.saveUiPos then _GACC.saveUiPos("menu",Outer) end
        TweenService:Create(Outer,TweenInfo.new(0.28,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position=UDim2.new(0,-350,home.Y.Scale,home.Y.Offset)}):Play()
        task.delay(0.3,function() Outer.Visible=false; MiniBtn.Visible=true end)
    end
    CloseBtn.MouseButton1Click:Connect(hideGui)
    MiniBtn.MouseButton1Click:Connect(showGui)

    end 

    do local HSep=Instance.new("Frame")
    HSep.Position=UDim2.new(0,0,0,74); HSep.Size=UDim2.new(1,0,0,1); HSep.BorderSizePixel=0
    HSep.BackgroundColor3=Color3.fromRGB(70,76,94); HSep.BackgroundTransparency=.78
    HSep.Parent=Inner; HSep.ZIndex=4
    local hSepGrad=Instance.new("UIGradient",HSep)
    hSepGrad.Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1,0),
        NumberSequenceKeypoint.new(0.10,0,0),
        NumberSequenceKeypoint.new(0.90,0,0),
        NumberSequenceKeypoint.new(1,   1,0),
    })
    end 

    local CF=Instance.new("ScrollingFrame")
    CF.Name="ContentFrame"; CF.Size=UDim2.new(1,-20,1,-131); CF.Position=UDim2.new(0,10,0,122)
    CF.BackgroundTransparency=1; CF.BorderSizePixel=0; CF.ScrollBarThickness=0; CF.ScrollBarImageColor3=C.blue
    table.insert(_themeScrollbars,CF)
    CF.CanvasSize=UDim2.new(0,0,0,0); CF.AutomaticCanvasSize=Enum.AutomaticSize.Y
    CF.ScrollingDirection=Enum.ScrollingDirection.Y; CF.ScrollingEnabled=true; CF.Active=true
    CF.ElasticBehavior=Enum.ElasticBehavior.Never; CF.Active=true; CF.Parent=Inner; GuiRefs.contentFrame=CF
    local tabTransitionOverlay=Instance.new("Frame",Inner)
    tabTransitionOverlay.Name="TabTransitionOverlay"
    tabTransitionOverlay.Position=CF.Position; tabTransitionOverlay.Size=CF.Size
    tabTransitionOverlay.BackgroundColor3=_ACC.accent; tabTransitionOverlay.BackgroundTransparency=1
    tabTransitionOverlay.BorderSizePixel=0; tabTransitionOverlay.ZIndex=50
    tabTransitionOverlay.Visible=false; tabTransitionOverlay.Active=false
    GuiRefs.tabTransitionOverlay=tabTransitionOverlay
    local tabTransitionScale=Instance.new("UIScale",tabTransitionOverlay)
    tabTransitionScale.Scale=1
    GuiRefs.tabTransitionScale=tabTransitionScale
    local scrollTrack=Instance.new("Frame",Inner)
    scrollTrack.Size=UDim2.new(0,2,1,-139); scrollTrack.Position=UDim2.new(1,-5,0,126)
    scrollTrack.BackgroundColor3=Color3.fromRGB(28,29,38); scrollTrack.BackgroundTransparency=.74
    scrollTrack.BorderSizePixel=0; scrollTrack.ZIndex=8; guiCorner(scrollTrack,2)
    local scrollFill=Instance.new("Frame",scrollTrack)
    scrollFill.Size=UDim2.new(1,0,0.15,0); scrollFill.BackgroundColor3=_ACC.accent
    scrollFill.BackgroundTransparency=0.1; scrollFill.BorderSizePixel=0; scrollFill.ZIndex=9; guiCorner(scrollFill,2)
    local function updateScrollRail()
        local total=CF.AbsoluteCanvasSize.Y
        local visible=CF.AbsoluteWindowSize.Y
        local ratio=math.clamp(visible/math.max(total,1),0.08,1)
        local progress=math.clamp(CF.CanvasPosition.Y/math.max(total-visible,1),0,1)
        scrollFill.Size=UDim2.new(1,0,ratio,0)
        scrollFill.Position=UDim2.new(0,0,progress*(1-ratio),0)
        scrollTrack.Visible=total>visible+2
    end
    CF:GetPropertyChangedSignal("CanvasPosition"):Connect(updateScrollRail)
    CF:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateScrollRail)
    CF:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateScrollRail)
    table.insert(_themeExtRefs,{callback=function(thm) pcall(function() scrollFill.BackgroundColor3=thm.accent end) end})
    task.defer(updateScrollRail)
    do
    local CLay=Instance.new("UIListLayout"); CLay.SortOrder=Enum.SortOrder.LayoutOrder; CLay.Padding=UDim.new(0,6); CLay.Parent=CF
    local CPad=Instance.new("UIPadding"); CPad.PaddingLeft=UDim.new(0,0); CPad.PaddingRight=UDim.new(0,0)
    CPad.PaddingTop=UDim.new(0,10); CPad.PaddingBottom=UDim.new(0,34); CPad.Parent=CF
    end 

    do
        local vDiv=Instance.new("Frame",Inner)
        vDiv.Name="SidebarDiv"
        vDiv.Size=UDim2.new(0,1,1,-89); vDiv.Position=UDim2.new(0,119,0,89)
        vDiv.BackgroundColor3=Color3.fromRGB(65,69,86); vDiv.BackgroundTransparency=.80
        vDiv.BorderSizePixel=0; vDiv.ZIndex=3; vDiv.Visible=false
    end
    local TabRail=Instance.new("Frame",Inner)
    TabRail.Name="TabRail"
    TabRail.Size=UDim2.new(0,119,1,-89); TabRail.Position=UDim2.new(0,0,0,89)
    TabRail.BackgroundColor3=Color3.fromRGB(4,4,8); TabRail.BackgroundTransparency=.72
    TabRail.BorderSizePixel=0; TabRail.ZIndex=3; TabRail.ClipsDescendants=true; TabRail.Visible=false
    do local railG=Instance.new("UIGradient",TabRail)
    railG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(12,12,18)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,3,6))})
    railG.Rotation=90 end
    do
        local rLay=Instance.new("UIListLayout",TabRail)
        rLay.FillDirection=Enum.FillDirection.Vertical
        rLay.SortOrder=Enum.SortOrder.LayoutOrder
        rLay.HorizontalAlignment=Enum.HorizontalAlignment.Center
        rLay.Padding=UDim.new(0,4)
        rLay.VerticalAlignment=Enum.VerticalAlignment.Top
        rLay.Padding=UDim.new(0,4)
    end

    local KeyListen={cb=nil,label=nil,active=false}
    local KEY_ALIASES={
        ButtonA="A",ButtonB="B",ButtonX="X",ButtonY="Y",ButtonR1="RB",ButtonR2="RT",ButtonL1="LB",ButtonL2="LT",
        DPadUp="D↑",DPadDown="D↓",DPadLeft="D←",DPadRight="D→",ButtonStart="▶",ButtonSelect="◀",
        LeftShift="LShift",RightShift="RShift",LeftControl="LCtrl",RightControl="RCtrl",LeftAlt="LAlt",RightAlt="RAlt",
        LeftSuper="LSuper",RightSuper="RSuper",Return="Enter",BackSpace="Backspace",Tab="Tab",CapsLock="CapsLock",
        Escape="Esc",Space="Space",PageUp="PgUp",PageDown="PgDn",End="End",Home="Home",Insert="Ins",Delete="Del",
        Up="↑",Down="↓",Left="←",Right="→",F1="F1",F2="F2",F3="F3",F4="F4",F5="F5",F6="F6",F7="F7",F8="F8",
        F9="F9",F10="F10",F11="F11",F12="F12",Print="PrtScn",ScrollLock="ScrLk",Pause="Pause",
        Minus="-",Equals="=",LeftBracket="[",RightBracket="]",BackSlash="\\",Semicolon=";",Quote="'",
        Comma=",",Period=".",Slash="/",Backquote="`"
    }
    local function prettyKey(kc) return KEY_ALIASES[kc.Name] or kc.Name end
    local function cancelKL()
        if KeyListen.label then KeyListen.label.BackgroundColor3=C.blue; KeyListen.label.BackgroundTransparency=0.5 end
        KeyListen.cb=nil; KeyListen.label=nil; KeyListen.active=false
    end
    local function startKL(lbl,onSet)
        cancelKL(); KeyListen.cb=onSet; KeyListen.label=lbl; KeyListen.active=true
        lbl.Text="..."; lbl.BackgroundColor3=Color3.fromRGB(80,220,120); lbl.BackgroundTransparency=0.3
        local cap=lbl; task.delay(8,function() if KeyListen.label==cap and KeyListen.active then cancelKL(); if lbl and lbl.Parent then lbl.Text=prettyKey(Keys.guiHide); lbl.BackgroundColor3=C.blue; lbl.BackgroundTransparency=0.5 end end end)
    end
    UIS.InputBegan:Connect(function(inp,gp)
        if not KeyListen.active then return end; if gp then return end
        local ut=inp.UserInputType
        if ut~=Enum.UserInputType.Keyboard and ut~=Enum.UserInputType.Gamepad1 then return end
        local k=inp.KeyCode
        if k==Enum.KeyCode.Unknown then return end
        if k==Enum.KeyCode.Escape then cancelKL(); return end
        local cb=KeyListen.cb; local lb=KeyListen.label; cancelKL()
        if lb and lb.Parent then lb.Text=prettyKey(k); lb.BackgroundColor3=C.blue; lb.BackgroundTransparency=0.5 end
        if cb then task.spawn(cb,k) end
    end)

    local function addSectLbl(parent,text,order)
        local w=Instance.new("Frame",parent); w.Size=UDim2.new(1,0,0,26); w.BackgroundTransparency=1; w.LayoutOrder=order
        local L=Instance.new("TextLabel",w); L.Size=UDim2.new(1,0,0,22); L.BackgroundTransparency=1
        L.Text=text; L.TextColor3=C.textDim; L.TextSize=12; L.Font=Enum.Font.GothamBlack; L.TextXAlignment=Enum.TextXAlignment.Left
        return L
    end

    local function mkSection(parent,title,order)
        local outer=Instance.new("Frame",parent); outer.LayoutOrder=order; outer.Size=UDim2.new(1,0,0,0); outer.AutomaticSize=Enum.AutomaticSize.Y; outer.BackgroundTransparency=1; outer.BorderSizePixel=0
        local outerLay=Instance.new("UIListLayout",outer); outerLay.SortOrder=Enum.SortOrder.LayoutOrder; outerLay.Padding=UDim.new(0,3)
        
        local hdr=Instance.new("Frame",outer); hdr.LayoutOrder=0; hdr.Size=UDim2.new(1,0,0,24); hdr.BackgroundTransparency=1; hdr.BorderSizePixel=0
        local accentBar=Instance.new("Frame",hdr); accentBar.Size=UDim2.new(0,2,0,14); accentBar.Position=UDim2.new(0,2,0.5,-7)
        accentBar.BackgroundColor3=_ACC.accent; accentBar.BorderSizePixel=0; guiCorner(accentBar,1)
        table.insert(_themeTabInds,accentBar)
        local lbl=Instance.new("TextLabel",hdr); lbl.Size=UDim2.new(1,-12,1,0); lbl.Position=UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=title; lbl.TextColor3=Color3.fromRGB(130,138,160)
        lbl.TextSize=10; lbl.Font=Enum.Font.GothamBold; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local mark=Instance.new("TextLabel",hdr)
        mark.Size=UDim2.new(0,22,1,0); mark.Position=UDim2.new(1,-24,0,0)
        mark.BackgroundTransparency=1; mark.Text=""; mark.TextColor3=_ACC.accentDark; mark.Visible=false
        mark.TextSize=9; mark.Font=Enum.Font.GothamBlack; mark.TextXAlignment=Enum.TextXAlignment.Right
        table.insert(_themeSectRefs,{lbl=lbl,arrow=mark})
        local rainTrack=Instance.new("Frame",hdr)
        rainTrack.Size=UDim2.fromOffset(25,19); rainTrack.Position=UDim2.new(1,-27,.5,-10)
        rainTrack.BackgroundTransparency=1; rainTrack.BorderSizePixel=0; rainTrack.ClipsDescendants=true
        local miniShadow=Instance.new("Frame",rainTrack); miniShadow.Position=UDim2.fromOffset(3,6); miniShadow.Size=UDim2.fromOffset(19,7); miniShadow.BackgroundColor3=Color3.fromRGB(24,43,59); miniShadow.BackgroundTransparency=.2; miniShadow.BorderSizePixel=0; miniShadow.ZIndex=1; guiCorner(miniShadow,6)
        for _,spec in ipairs({{4,4,8,8},{9,1,11,11},{15,4,7,7}}) do
            local cloudPuff=Instance.new("Frame",rainTrack); cloudPuff.Position=UDim2.fromOffset(spec[1],spec[2]); cloudPuff.Size=UDim2.fromOffset(spec[3],spec[3]); cloudPuff.BackgroundColor3=Color3.fromRGB(94,127,151); cloudPuff.BackgroundTransparency=.1; cloudPuff.BorderSizePixel=0; cloudPuff.ZIndex=2; guiCorner(cloudPuff,8)
            local puffGrad=Instance.new("UIGradient",cloudPuff); puffGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(154,184,207)),ColorSequenceKeypoint.new(1,Color3.fromRGB(51,78,100))}); puffGrad.Rotation=112
        end
        local miniCloud=Instance.new("Frame",rainTrack); miniCloud.Position=UDim2.fromOffset(3,6); miniCloud.Size=UDim2.fromOffset(20,7); miniCloud.BackgroundColor3=Color3.fromRGB(86,118,142); miniCloud.BackgroundTransparency=.08; miniCloud.BorderSizePixel=0; miniCloud.ZIndex=3; guiCorner(miniCloud,6)
        local miniGrad=Instance.new("UIGradient",miniCloud); miniGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(139,171,195)),ColorSequenceKeypoint.new(1,Color3.fromRGB(45,70,91))}); miniGrad.Rotation=90
        local miniShade=Instance.new("Frame",miniCloud); miniShade.Position=UDim2.new(0,3,1,-3); miniShade.Size=UDim2.new(1,-6,0,2); miniShade.BackgroundColor3=Color3.fromRGB(24,43,60); miniShade.BackgroundTransparency=.3; miniShade.BorderSizePixel=0; miniShade.ZIndex=4; guiCorner(miniShade,2)
        local rainDrop=Instance.new("Frame",rainTrack)
        rainDrop.Size=UDim2.fromOffset(2,7); rainDrop.Position=UDim2.fromOffset(8,9)
        rainDrop.BackgroundColor3=_ACC.accent; rainDrop.BorderSizePixel=0; rainDrop.Rotation=12; guiCorner(rainDrop,3)
        local rainDrop2=Instance.new("Frame",rainTrack)
        rainDrop2.Size=UDim2.fromOffset(2,6); rainDrop2.Position=UDim2.fromOffset(16,11)
        rainDrop2.BackgroundColor3=_ACC.accentDark; rainDrop2.BorderSizePixel=0; rainDrop2.Rotation=12; guiCorner(rainDrop2,3)
        local rainSpark=Instance.new("Frame",rainTrack)
        rainSpark.AnchorPoint=Vector2.new(.5,.5); rainSpark.Position=UDim2.fromOffset(12,18); rainSpark.Size=UDim2.fromOffset(7,1)
        rainSpark.BackgroundColor3=_ACC.accent; rainSpark.BackgroundTransparency=1; rainSpark.BorderSizePixel=0; guiCorner(rainSpark,2)
        task.spawn(function()
            task.wait(((order or 0)%6)*.08)
            while rainTrack and rainTrack.Parent do
                rainDrop.Position=UDim2.fromOffset(8,9); rainDrop2.Position=UDim2.fromOffset(16,7); rainDrop.BackgroundTransparency=.04; rainDrop2.BackgroundTransparency=.18
                TweenService:Create(rainDrop,TweenInfo.new(.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromOffset(6,19),BackgroundTransparency=.5}):Play()
                TweenService:Create(rainDrop2,TweenInfo.new(.62,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.fromOffset(14,19),BackgroundTransparency=.55}):Play()
                task.wait(.48)
                rainSpark.Size=UDim2.fromOffset(2,2); rainSpark.BackgroundTransparency=.08
                TweenService:Create(rainSpark,TweenInfo.new(.25,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(13,1),BackgroundTransparency=1}):Play()
                task.wait(.72)
            end
        end)
        table.insert(_themeExtRefs,{callback=function(thm)
            pcall(function() rainDrop.BackgroundColor3=thm.accent; rainDrop2.BackgroundColor3=thm.accentDark; rainSpark.BackgroundColor3=thm.accent end)
        end})
        
        local body=Instance.new("Frame",outer); body.Name="SectBody"; body.LayoutOrder=1
        body.Size=UDim2.new(1,0,0,0); body.AutomaticSize=Enum.AutomaticSize.Y; body.BackgroundTransparency=1; body.BorderSizePixel=0
        local bodyLay=Instance.new("UIListLayout",body); bodyLay.SortOrder=Enum.SortOrder.LayoutOrder; bodyLay.Padding=UDim.new(0,4)
        
        return body
    end

    local function addInputRow(parent,label,value,order,cb)
        local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,42); Row.BackgroundColor3=Color3.fromRGB(11,11,17)
        Row.BackgroundTransparency=0.25; Row.BorderSizePixel=0; Row.LayoutOrder=order; guiCorner(Row,6)
        local aBar=Instance.new("Frame",Row); aBar.Size=UDim2.new(0,3,0,22); aBar.AnchorPoint=Vector2.new(0,0.5)
        aBar.Position=UDim2.new(0,0,0.5,0); aBar.BackgroundColor3=_ACC.accent; aBar.BackgroundTransparency=1
        aBar.BorderSizePixel=0; guiCorner(aBar,2)
        local Lb=Instance.new("TextLabel",Row); Lb.Size=UDim2.new(0.58,0,0,18); Lb.Position=UDim2.new(0,14,0,12)
        Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=Color3.fromRGB(210,210,225); Lb.TextSize=12; Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left
        local BC=Instance.new("Frame",Row); BC.ZIndex=6; BC.Position=UDim2.new(1,-62,0.5,-12); BC.Size=UDim2.new(0,52,0,24)
        BC.BackgroundColor3=C.input; BC.BackgroundTransparency=0.45; BC.BorderSizePixel=0; guiCorner(BC,8); guiStroke(BC,Color3.fromRGB(55,55,65),1)
        local Box=Instance.new("TextBox",BC); Box.ZIndex=7; Box.Size=UDim2.new(1,0,1,0); Box.BackgroundTransparency=1
        Box.Text=tostring(value); Box.TextColor3=C.text; Box.TextSize=11; Box.Font=Enum.Font.GothamBold; Box.ClearTextOnFocus=false
        Box.FocusLost:Connect(function() local n=tonumber(Box.Text); if n and n>0 then cb(n) else Box.Text=tostring(value) end end)
        Box.Focused:Connect(function() tw(BC,{BackgroundTransparency=0.2}) end)
        Box.FocusLost:Connect(function() tw(BC,{BackgroundTransparency=0.45}) end)
        local hov=Instance.new("TextButton",Row); hov.Size=UDim2.new(1,0,1,0); hov.BackgroundTransparency=1; hov.Text=""; hov.ZIndex=0
        hov.MouseEnter:Connect(function()
            tw(Row,{BackgroundTransparency=0.18,BackgroundColor3=_ACC.accentRowHover})
            tw(aBar,{BackgroundTransparency=0.15})
        end)
        hov.MouseLeave:Connect(function()
            tw(Row,{BackgroundTransparency=0.55,BackgroundColor3=Color3.fromRGB(11,11,17)})
            tw(aBar,{BackgroundTransparency=1})
        end)
        return Row,Box
    end

    local function playFeatureEffect(row)
        if not row or not row.Parent then return end
        local flash=Instance.new("Frame",row)
        flash.AnchorPoint=Vector2.new(0.5,0.5); flash.Position=UDim2.new(0.5,0,0.5,0)
        flash.Size=UDim2.new(0,4,0,4); flash.BackgroundColor3=_ACC.accent
        flash.BackgroundTransparency=0.68; flash.BorderSizePixel=0; flash.ZIndex=4
        guiCorner(flash,8)
        local flashStroke=guiStroke(flash,_ACC.accent,1); flashStroke.Transparency=0.18
        TweenService:Create(flash,TweenInfo.new(0.34,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
            Size=UDim2.new(1,-4,1,-4),BackgroundTransparency=1
        }):Play()
        TweenService:Create(flashStroke,TweenInfo.new(0.34),{Transparency=1}):Play()
        for i=1,4 do
            local particle=Instance.new("Frame",row)
            particle.AnchorPoint=Vector2.new(0.5,0.5); particle.Position=UDim2.new(1,-30,0.5,0)
            particle.Size=UDim2.new(0,3,0,3); particle.BackgroundColor3=_ACC.accent
            particle.BackgroundTransparency=0.05; particle.BorderSizePixel=0; particle.ZIndex=8
            particle.Rotation=45; guiCorner(particle,1)
            local angle=((i-1)/4)*math.pi*2
            local dx=math.cos(angle)*(12+i*2); local dy=math.sin(angle)*(9+i)
            TweenService:Create(particle,TweenInfo.new(0.38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{
                Position=UDim2.new(1,-30+dx,0.5,dy),BackgroundTransparency=1,Rotation=135,Size=UDim2.new(0,1,0,1)
            }):Play()
            task.delay(0.4,function() pcall(function() particle:Destroy() end) end)
        end
        task.delay(0.4,function() pcall(function() flash:Destroy() end) end)
    end

    local function addToggleRow(parent,label,enabled,order,kbKey,onToggle)
        local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,42); Row.BackgroundColor3=Color3.fromRGB(11,11,17)
        Row.BackgroundTransparency=0.25; Row.BorderSizePixel=0; Row.LayoutOrder=order; guiCorner(Row,6)
        
        local aBar=Instance.new("Frame",Row); aBar.Size=UDim2.new(0,3,0,22); aBar.AnchorPoint=Vector2.new(0,0.5)
        aBar.Position=UDim2.new(0,0,0.5,0); aBar.BackgroundColor3=_ACC.accent; aBar.BackgroundTransparency=1
        aBar.BorderSizePixel=0; guiCorner(aBar,2)
        local Lb=Instance.new("TextLabel",Row); Lb.Size=UDim2.new(0.62,0,0,18); Lb.Position=UDim2.new(0,14,0,12)
        Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=Color3.fromRGB(210,210,225); Lb.TextSize=12; Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left
        local OFF_TRACK=Color3.fromRGB(28,28,35); local OFF_TRACK_STROKE=Color3.fromRGB(58,58,70); local OFF_KNOB=Color3.fromRGB(72,72,86)
        -- ── Ritual Hub style circle toggle ──────────────────────────────
        local TI_POP=TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        local Track=Instance.new("Frame",Row); Track.ZIndex=3
        Track.Position=UDim2.new(1,-48,0.5,-12); Track.Size=UDim2.new(0,36,0,24)
        Track.BackgroundTransparency=1; Track.BorderSizePixel=0
        Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
        local Shadow=Instance.new("Frame",Track); Shadow.ZIndex=3; Shadow.AnchorPoint=Vector2.new(0.5,0.5)
        Shadow.Position=UDim2.new(0.5,0,0.5,1); Shadow.Size=UDim2.new(0,16,0,16)
        Shadow.BackgroundColor3=Color3.fromRGB(0,0,0); Shadow.BackgroundTransparency=0.5; Shadow.BorderSizePixel=0
        Instance.new("UICorner",Shadow).CornerRadius=UDim.new(1,0)
        local Knob=Instance.new("Frame",Track); Knob.ZIndex=4; Knob.AnchorPoint=Vector2.new(0.5,0.5)
        Knob.Position=UDim2.new(0.5,0,0.5,0); Knob.Size=UDim2.new(0,13,0,13)
        Knob.BackgroundColor3=OFF_KNOB; Knob.BorderSizePixel=0
        Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
        local KnobGrad=Instance.new("UIGradient",Knob); KnobGrad.Rotation=90
        local Gloss=Instance.new("Frame",Knob); Gloss.ZIndex=5
        Gloss.Position=UDim2.new(0.22,0,0.11,0); Gloss.Size=UDim2.new(0.46,0,0.24,0)
        Gloss.BackgroundColor3=Color3.fromRGB(255,255,255); Gloss.BackgroundTransparency=0.62; Gloss.BorderSizePixel=0
        Instance.new("UICorner",Gloss).CornerRadius=UDim.new(1,0)
        local GlossGrad=Instance.new("UIGradient",Gloss); GlossGrad.Rotation=90
        GlossGrad.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.35),NumberSequenceKeypoint.new(0.6,0.78),NumberSequenceKeypoint.new(1,1)
        })
        local TrkStroke=nil
        local st=enabled
        local function circleVisual(on)
            if on then
                Knob.BackgroundColor3=_ACC.accent
                KnobGrad.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,Color3.fromRGB(200,230,255)),
                    ColorSequenceKeypoint.new(0.46,_ACC.accent),
                    ColorSequenceKeypoint.new(1,_ACC.accentDark),
                })
                Gloss.BackgroundTransparency=0.5
            else
                Knob.BackgroundColor3=OFF_KNOB
                KnobGrad.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,Color3.fromRGB(235,232,248)),
                    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(128,124,150)),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(48,48,58)),
                })
                Gloss.BackgroundTransparency=0.62
            end
        end
        circleVisual(st)
        table.insert(_themeToggleRefs,{track=Track,trkStroke=TrkStroke,knob=Knob,offTrack=OFF_TRACK,offKnob=OFF_KNOB,offStroke=OFF_TRACK_STROKE,getSt=function() return st end})
        table.insert(_themeExtRefs,{callback=function() pcall(function() circleVisual(st) end) end})
        local function setV(on)
            st=on
            if on then playFeatureEffect(Row) end
            circleVisual(on)
            Knob.Size=UDim2.new(0,10,0,10)
            tw(Knob,{Size=UDim2.new(0,13,0,13)},TI_POP)
        end
        local Btn=Instance.new("TextButton",Row); Btn.Size=UDim2.new(0,36,0,24); Btn.Position=UDim2.new(1,-48,0.5,-12); Btn.BackgroundTransparency=1; Btn.Text=""; Btn.ZIndex=5
        Btn.MouseButton1Click:Connect(function() st=not st; setV(st); if onToggle then onToggle(st) end end)
        local hov=Instance.new("TextButton",Row); hov.Size=UDim2.new(1,0,1,0); hov.BackgroundTransparency=1; hov.Text=""; hov.ZIndex=0
        hov.MouseEnter:Connect(function()
            tw(Row,{BackgroundTransparency=0.25,BackgroundColor3=_ACC.accentRowHover})
            tw(aBar,{BackgroundTransparency=0.15})
        end)
        hov.MouseLeave:Connect(function()
            tw(Row,{BackgroundTransparency=0.55,BackgroundColor3=Color3.fromRGB(11,11,17)})
            tw(aBar,{BackgroundTransparency=1})
        end)
        if kbKey then _GACC.GuiToggleSetters[kbKey]=setV end
        return Row,setV
    end

    local function addActionRow(parent,label,kbKey,onAction,order)
        local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,42); Row.BackgroundColor3=Color3.fromRGB(11,11,17)
        Row.BackgroundTransparency=0.25; Row.BorderSizePixel=0; Row.LayoutOrder=order; guiCorner(Row,6)
        local aBar=Instance.new("Frame",Row); aBar.Size=UDim2.new(0,3,0,22); aBar.AnchorPoint=Vector2.new(0,0.5)
        aBar.Position=UDim2.new(0,0,0.5,0); aBar.BackgroundColor3=_ACC.accent; aBar.BackgroundTransparency=1
        aBar.BorderSizePixel=0; guiCorner(aBar,2)
        local Lb=Instance.new("TextLabel",Row); Lb.Size=UDim2.new(0.7,0,0,18); Lb.Position=UDim2.new(0,14,0,12)
        Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=Color3.fromRGB(210,210,225); Lb.TextSize=12; Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left
        local AB=Instance.new("TextButton",Row); AB.Size=UDim2.new(1,0,1,0); AB.BackgroundTransparency=1; AB.Text=""
        AB.MouseButton1Click:Connect(function() playFeatureEffect(Row); onAction() end)
        local hov=Instance.new("TextButton",Row); hov.Size=UDim2.new(1,0,1,0); hov.BackgroundTransparency=1; hov.Text=""; hov.ZIndex=0
        hov.MouseEnter:Connect(function()
            tw(Row,{BackgroundTransparency=0.25,BackgroundColor3=_ACC.accentRowHover})
            tw(aBar,{BackgroundTransparency=0.15})
        end)
        hov.MouseLeave:Connect(function()
            tw(Row,{BackgroundTransparency=0.55,BackgroundColor3=Color3.fromRGB(11,11,17)})
            tw(aBar,{BackgroundTransparency=1})
        end)
        return Row
    end

    _GACC.extras.addDropdownRow=function(parent,label,options,current,order,onSelect)
        local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,42); Row.LayoutOrder=order
        Row.BackgroundColor3=Color3.fromRGB(11,11,17); Row.BackgroundTransparency=.25; Row.BorderSizePixel=0; Row.ClipsDescendants=true; guiCorner(Row,6)
        local accent=Instance.new("Frame",Row); accent.Size=UDim2.new(0,3,0,22); accent.Position=UDim2.new(0,0,0,10)
        accent.BackgroundColor3=_ACC.accent; accent.BackgroundTransparency=.25; accent.BorderSizePixel=0; guiCorner(accent,2)
        local Lb=Instance.new("TextLabel",Row); Lb.Size=UDim2.new(0,88,0,42); Lb.Position=UDim2.new(0,14,0,0)
        Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=Color3.fromRGB(210,210,225); Lb.TextSize=11
        Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left
        local valueBtn=Instance.new("TextButton",Row); valueBtn.Size=UDim2.new(1,-116,0,26); valueBtn.Position=UDim2.new(0,104,0,8)
        valueBtn.BackgroundColor3=_ACC.accentBg; valueBtn.BackgroundTransparency=.18; valueBtn.BorderSizePixel=0
        valueBtn.Text=tostring(current).."  v"; valueBtn.TextColor3=_ACC.accent; valueBtn.TextSize=9; valueBtn.Font=Enum.Font.GothamBold
        valueBtn.TextTruncate=Enum.TextTruncate.AtEnd; valueBtn.ZIndex=8; guiCorner(valueBtn,7); guiStroke(valueBtn,_ACC.accentDark,1)
        local drop=Instance.new("ScrollingFrame",Row); drop.Position=UDim2.new(0,8,0,44); drop.Size=UDim2.new(1,-16,0,0)
        drop.BackgroundColor3=Color3.fromRGB(7,7,12); drop.BackgroundTransparency=.02; drop.BorderSizePixel=0
        drop.ScrollBarThickness=2; drop.ScrollBarImageColor3=_ACC.accent; drop.CanvasSize=UDim2.new(0,0,0,#options*28+4)
        drop.Visible=false; drop.ZIndex=9; guiCorner(drop,7); guiStroke(drop,Color3.fromRGB(48,50,64),1)
        local list=Instance.new("UIListLayout",drop); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Padding=UDim.new(0,2)
        local pad=Instance.new("UIPadding",drop); pad.PaddingTop=UDim.new(0,3); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
        local built=false; local open=false
        local function setOpen(on)
            open=on
            if on and not built then
                built=true
                for i,name in ipairs(options) do
                    local choice=Instance.new("TextButton",drop); choice.Size=UDim2.new(1,0,0,26); choice.LayoutOrder=i
                    choice.BackgroundColor3=Color3.fromRGB(17,18,25); choice.BackgroundTransparency=.12; choice.BorderSizePixel=0
                    choice.Text=name; choice.TextColor3=Color3.fromRGB(205,208,224); choice.TextSize=9; choice.Font=Enum.Font.GothamBold
                    choice.ZIndex=10; guiCorner(choice,5)
                    choice.MouseEnter:Connect(function() tw(choice,{BackgroundColor3=_ACC.accentHover}) end)
                    choice.MouseLeave:Connect(function() tw(choice,{BackgroundColor3=Color3.fromRGB(17,18,25)}) end)
                    choice.MouseButton1Click:Connect(function()
                        current=name; valueBtn.Text=name.."  v"; if onSelect then onSelect(name) end; setOpen(false)
                    end)
                end
            end
            if on then drop.Visible=true end
            -- size to the actual option count, capped so long lists scroll
            local wanted=math.min(#options*28+6,140)
            tw(Row,{Size=UDim2.new(1,0,0,on and (wanted+52) or 42)},TweenInfo.new(.24,Enum.EasingStyle.Quint,Enum.EasingDirection.Out))
            tw(drop,{Size=UDim2.new(1,-16,0,on and wanted or 0)},TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out))
            valueBtn.Text=tostring(current)..(on and "  ^" or "  v")
            if not on then task.delay(.23,function() if not open and drop then drop.Visible=false end end) end
        end
        valueBtn.MouseButton1Click:Connect(function() setOpen(not open) end)
        table.insert(_themeActBtns,valueBtn); table.insert(_themeScrollbars,drop)
        return Row,function(v) current=v; valueBtn.Text=tostring(v)..(open and "  ^" or "  v") end
    end

    local function addKeybindRow(parent,label,kbKey,order)
        local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,42); Row.LayoutOrder=order
        Row.BackgroundColor3=Color3.fromRGB(11,11,17); Row.BackgroundTransparency=.25; Row.BorderSizePixel=0; guiCorner(Row,6)
        local accent=Instance.new("Frame",Row); accent.Size=UDim2.new(0,3,0,22); accent.Position=UDim2.new(0,0,.5,-11)
        accent.BackgroundColor3=_ACC.accent; accent.BackgroundTransparency=1; accent.BorderSizePixel=0; guiCorner(accent,2)
        local Lb=Instance.new("TextLabel",Row); Lb.Size=UDim2.new(.58,0,1,0); Lb.Position=UDim2.new(0,14,0,0)
        Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=Color3.fromRGB(210,210,225)
        Lb.TextSize=12; Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left
        local keyBtn=Instance.new("TextButton",Row); keyBtn.AnchorPoint=Vector2.new(1,.5)
        keyBtn.Size=UDim2.new(0,44,0,24); keyBtn.Position=UDim2.new(1,-12,.5,0); keyBtn.AutomaticSize=Enum.AutomaticSize.X
        keyBtn.BackgroundColor3=_ACC.accentBg; keyBtn.BackgroundTransparency=.3; keyBtn.BorderSizePixel=0
        keyBtn.Text=prettyKey(Keys[kbKey]); keyBtn.TextColor3=_ACC.accent; keyBtn.TextSize=10; keyBtn.Font=Enum.Font.GothamBold
        guiCorner(keyBtn,6); local keyPad=Instance.new("UIPadding",keyBtn); keyPad.PaddingLeft=UDim.new(0,10); keyPad.PaddingRight=UDim.new(0,10)
        table.insert(_themeKbLabels,keyBtn)
        keyBtn.MouseButton1Click:Connect(function() startKL(keyBtn,function(nk) Keys[kbKey]=nk; keyBtn.Text=prettyKey(nk); saveConfig() end) end)
        keyBtn.MouseEnter:Connect(function()
            tw(keyBtn,{BackgroundTransparency=.05,BackgroundColor3=_ACC.accentHover}); tw(Row,{BackgroundTransparency=.15,BackgroundColor3=_ACC.accentRowHover}); tw(accent,{BackgroundTransparency=.1})
        end)
        keyBtn.MouseLeave:Connect(function()
            tw(keyBtn,{BackgroundTransparency=.3,BackgroundColor3=_ACC.accentBg}); tw(Row,{BackgroundTransparency=.25,BackgroundColor3=Color3.fromRGB(11,11,17)}); tw(accent,{BackgroundTransparency=1})
        end)
        return Row,keyBtn
    end

    -- NEW: Add Scale Row with + and - buttons
    local function addScaleRow(parent, label, getter, setter, order)
        local Row=Instance.new("Frame",parent); Row.Size=UDim2.new(1,0,0,42); Row.BackgroundColor3=Color3.fromRGB(11,11,17)
        Row.BackgroundTransparency=0.25; Row.BorderSizePixel=0; Row.LayoutOrder=order; guiCorner(Row,6)
        local aBar=Instance.new("Frame",Row); aBar.Size=UDim2.new(0,3,0,22); aBar.AnchorPoint=Vector2.new(0,0.5)
        aBar.Position=UDim2.new(0,0,0.5,0); aBar.BackgroundColor3=_ACC.accent; aBar.BackgroundTransparency=1
        aBar.BorderSizePixel=0; guiCorner(aBar,2)
        local Lb=Instance.new("TextLabel",Row); Lb.Size=UDim2.new(0.5,0,0,18); Lb.Position=UDim2.new(0,14,0,12)
        Lb.BackgroundTransparency=1; Lb.Text=label; Lb.TextColor3=Color3.fromRGB(210,210,225); Lb.TextSize=12; Lb.Font=Enum.Font.GothamBold; Lb.TextXAlignment=Enum.TextXAlignment.Left
        -- Container for buttons and value
        local controlFrame=Instance.new("Frame",Row)
        controlFrame.Size=UDim2.new(0,120,0,28); controlFrame.Position=UDim2.new(1,-132,0.5,-14)
        controlFrame.BackgroundTransparency=1; controlFrame.ZIndex=6

        local minus=Instance.new("TextButton",controlFrame)
        minus.Size=UDim2.new(0,28,1,0); minus.Position=UDim2.new(0,0,0,0)
        minus.BackgroundColor3=Color3.fromRGB(28,30,38); minus.BackgroundTransparency=0.2; minus.BorderSizePixel=0
        minus.Text="−"; minus.TextColor3=Color3.fromRGB(220,220,230); minus.Font=Enum.Font.GothamBold; minus.TextSize=14
        guiCorner(minus,6); guiStroke(minus,Color3.fromRGB(60,62,74),1)

        local valLbl=Instance.new("TextLabel",controlFrame)
        valLbl.Size=UDim2.new(0,50,1,0); valLbl.Position=UDim2.new(0,32,0,0)
        valLbl.BackgroundTransparency=1; valLbl.Text=string.format("%.1f", getter())
        valLbl.TextColor3=Color3.fromRGB(230,235,245); valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=13
        valLbl.TextXAlignment=Enum.TextXAlignment.Center

        local plus=Instance.new("TextButton",controlFrame)
        plus.Size=UDim2.new(0,28,1,0); plus.Position=UDim2.new(1,-28,0,0)
        plus.BackgroundColor3=Color3.fromRGB(28,30,38); plus.BackgroundTransparency=0.2; plus.BorderSizePixel=0
        plus.Text="+"; plus.TextColor3=Color3.fromRGB(220,220,230); plus.Font=Enum.Font.GothamBold; plus.TextSize=14
        guiCorner(plus,6); guiStroke(plus,Color3.fromRGB(60,62,74),1)

        local function updateVal()
            local v = getter()
            valLbl.Text = string.format("%.1f", v)
        end

        minus.MouseButton1Click:Connect(function()
            local newVal = math.max(0.1, getter() - 0.1)
            setter(newVal)
            updateVal()
            saveConfig()
        end)
        plus.MouseButton1Click:Connect(function()
            local newVal = math.min(2.0, getter() + 0.1)
            setter(newVal)
            updateVal()
            saveConfig()
        end)

        minus.MouseEnter:Connect(function()
            tw(minus,{BackgroundColor3=Color3.fromRGB(60,40,40),BackgroundTransparency=0})
        end)
        minus.MouseLeave:Connect(function()
            tw(minus,{BackgroundColor3=Color3.fromRGB(28,30,38),BackgroundTransparency=0.2})
        end)
        plus.MouseEnter:Connect(function()
            tw(plus,{BackgroundColor3=Color3.fromRGB(40,60,40),BackgroundTransparency=0})
        end)
        plus.MouseLeave:Connect(function()
            tw(plus,{BackgroundColor3=Color3.fromRGB(28,30,38),BackgroundTransparency=0.2})
        end)

        local hov=Instance.new("TextButton",Row); hov.Size=UDim2.new(1,0,1,0); hov.BackgroundTransparency=1; hov.Text=""; hov.ZIndex=0
        hov.MouseEnter:Connect(function()
            tw(Row,{BackgroundTransparency=0.18,BackgroundColor3=_ACC.accentRowHover})
            tw(aBar,{BackgroundTransparency=0.15})
        end)
        hov.MouseLeave:Connect(function()
            tw(Row,{BackgroundTransparency=0.55,BackgroundColor3=Color3.fromRGB(11,11,17)})
            tw(aBar,{BackgroundTransparency=1})
        end)
        return Row
    end

    local Categories={"Speed","Combat","Movement","Visual","Settings","Keybinds"}
    local CategoryMeta={
        Speed={icon="SP",sub="velocity"}, Combat={icon="CB",sub="targeting"},
        Movement={icon="MV",sub="routing"}, Visual={icon="FX",sub="display"}, Settings={icon="ST",sub="safety"}, Keybinds={icon="KB",sub="controls"},
    }
    local CategoryRefs={contents={},btns={},strokes={},active="Speed"}

    for pageIndex,name in ipairs(Categories) do
        local page=Instance.new("Frame")
        page.Size=UDim2.new(1,0,0,0); page.AutomaticSize=Enum.AutomaticSize.Y; page.BackgroundTransparency=1
        page.Visible=(name==CategoryRefs.active); page.LayoutOrder=pageIndex; page.Parent=CF; CategoryRefs.contents[name]=page
        local lay=Instance.new("UIListLayout"); lay.SortOrder=Enum.SortOrder.LayoutOrder; lay.Padding=UDim.new(0,5); lay.Parent=page
        local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
        pad.PaddingTop=UDim.new(0,6); pad.PaddingBottom=UDim.new(0,6); pad.Parent=page
    end

    -- ==================== TOP CATEGORY BAR ====================
    -- Horizontal pills under the header. Scrolls sideways so all six fit
    -- at a readable size instead of being squeezed to fit the width.
    local TabBar=Instance.new("ScrollingFrame",Inner)
    TabBar.Name="TabBar"
    TabBar.Position=UDim2.new(0,10,0,80)
    TabBar.Size=UDim2.new(1,-20,0,34)
    TabBar.BackgroundTransparency=1
    TabBar.BorderSizePixel=0
    TabBar.ScrollBarThickness=0
    TabBar.ScrollingDirection=Enum.ScrollingDirection.X
    TabBar.AutomaticCanvasSize=Enum.AutomaticSize.X
    TabBar.CanvasSize=UDim2.new(0,0,0,0)
    TabBar.ElasticBehavior=Enum.ElasticBehavior.Never
    TabBar.ClipsDescendants=true
    TabBar.Active=true
    TabBar.ZIndex=6
    do
        local tbLay=Instance.new("UIListLayout",TabBar)
        tbLay.FillDirection=Enum.FillDirection.Horizontal
        tbLay.SortOrder=Enum.SortOrder.LayoutOrder
        tbLay.Padding=UDim.new(0,7)
        tbLay.VerticalAlignment=Enum.VerticalAlignment.Center
        local tbPad=Instance.new("UIPadding",TabBar)
        tbPad.PaddingRight=UDim.new(0,10)
    end
    CategoryRefs.topTabs={}

    local function styleTopTab(name,activeNow)
        local t=CategoryRefs.topTabs[name]
        if not t then return end
        local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        tw(t.frame,{BackgroundColor3=activeNow and _ACC.accentBg or Color3.fromRGB(13,13,19),
                    BackgroundTransparency=activeNow and 0.12 or 0.45},ti)
        tw(t.label,{TextColor3=activeNow and Color3.fromRGB(242,242,255) or Color3.fromRGB(126,128,146)},ti)
        t.stroke.Color=activeNow and _ACC.accent or Color3.fromRGB(34,35,46)
        tw(t.stroke,{Transparency=activeNow and 0.15 or 0.55},ti)
    end

    -- single place that changes page, with a short fade-and-slide transition
    local function selectCategory(name)
        local nextPage = CategoryRefs.contents[name]
        if not nextPage or CategoryRefs.active == name then return end
        local previousPage = CategoryRefs.contents[CategoryRefs.active]
        CategoryRefs.active=name
        local token = (CategoryRefs.transitionToken or 0) + 1
        CategoryRefs.transitionToken = token
        local tiOut = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tiIn = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local overlay=GuiRefs.tabTransitionOverlay
        if overlay then overlay.Visible=false end
        if previousPage and previousPage ~= nextPage then
            previousPage.Visible=true
            previousPage.Position=UDim2.new(-0.09,0,0,0)
            tw(previousPage,{Position=UDim2.new(0.09,0,0,0)},tiOut)
            task.delay(0.14,function()
                if CategoryRefs.transitionToken==token then previousPage.Visible=false end
            end)
        end
        nextPage.Visible=true
        nextPage.Position=UDim2.new(0.09,0,0,0)
        tw(nextPage,{Position=UDim2.new(0,0,0,0)},tiIn)
        -- No overlay or color flash is used during tab switching.
        CF.CanvasPosition=Vector2.new(0,0)
        for n in pairs(CategoryRefs.topTabs) do styleTopTab(n,n==name) end
    end
    CategoryRefs.select=selectCategory

    for i,name in ipairs(Categories) do
        local wide=math.max(62,#name*8+26)
        local holder=Instance.new("TextButton",TabBar)
        holder.Name="TopTab_"..name
        holder.Size=UDim2.new(0,wide,0,30)
        holder.BackgroundColor3=Color3.fromRGB(13,13,19)
        holder.BackgroundTransparency=0.45
        holder.BorderSizePixel=0
        holder.AutoButtonColor=false
        holder.Text=""
        holder.LayoutOrder=i
        holder.ZIndex=7
        guiCorner(holder,9)
        local hs=guiStroke(holder,Color3.fromRGB(34,35,46),1)

        local lbl=Instance.new("TextLabel",holder)
        lbl.Size=UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency=1
        lbl.Text=string.upper(name)
        lbl.TextColor3=Color3.fromRGB(126,128,146)
        lbl.TextSize=10
        lbl.Font=Enum.Font.GothamBold
        lbl.ZIndex=8

        CategoryRefs.topTabs[name]={frame=holder,label=lbl,stroke=hs}
        holder.MouseButton1Click:Connect(function() selectCategory(name) end)
    end
    for n in pairs(CategoryRefs.topTabs) do styleTopTab(n,n==CategoryRefs.active) end
    -- repaint the bar when the colour theme changes
    table.insert(_themeExtRefs,{callback=function()
        pcall(function()
            for n in pairs(CategoryRefs.topTabs) do styleTopTab(n,n==CategoryRefs.active) end
        end)
    end})

    local _CAT_COUNT=#Categories
    for i,name in ipairs(Categories) do
        local isActive=(name=="Speed")

        local meta=CategoryMeta[name]
        local row=Instance.new("Frame",TabRail)
        row.Name="Tab_"..name
        row.Size=UDim2.new(1,-12,0,48)
        row.BackgroundColor3=isActive and Color3.fromRGB(24,24,31) or Color3.fromRGB(10,10,15)
        row.BackgroundTransparency=isActive and 0.08 or 0.42
        row.BorderSizePixel=0; row.LayoutOrder=i*2; row.ClipsDescendants=false
        guiCorner(row,9)
        local rowStroke=guiStroke(row,isActive and _ACC.accentDark or Color3.fromRGB(35,36,48),1)
        CategoryRefs.strokes[name]=rowStroke

        local ind=Instance.new("Frame",row); ind.Name="indicator"
        ind.AnchorPoint=Vector2.new(0,0.5); ind.Position=UDim2.new(0,0,0.5,0)
        ind.BackgroundColor3=_ACC.accent
        ind.BackgroundTransparency=isActive and 0 or 1
        ind.Size=isActive and UDim2.new(0,3,0,28) or UDim2.new(0,3,0,14)
        ind.BorderSizePixel=0; guiCorner(ind,2)
        table.insert(_themeTabInds,ind)

        local badge=Instance.new("Frame",row)
        badge.Name="Badge"
        badge.Size=UDim2.new(0,28,0,28); badge.Position=UDim2.new(0,10,0.5,-14)
        badge.BackgroundColor3=isActive and _ACC.accentBg or Color3.fromRGB(19,19,26)
        badge.BackgroundTransparency=0.08; badge.BorderSizePixel=0; guiCorner(badge,7)
        local badgeStroke=guiStroke(badge,isActive and _ACC.accentDark or Color3.fromRGB(48,49,62),1)
        local badgeText=Instance.new("TextLabel",badge)
        badgeText.Size=UDim2.new(1,0,1,0); badgeText.BackgroundTransparency=1
        badgeText.Text=meta.icon; badgeText.Font=Enum.Font.GothamBlack; badgeText.TextSize=9
        badgeText.TextColor3=isActive and _ACC.accent or Color3.fromRGB(112,114,132)

        local sub=Instance.new("TextLabel",row)
        sub.Size=UDim2.new(1,-48,0,12); sub.Position=UDim2.new(0,45,0,25)
        sub.BackgroundTransparency=1; sub.Text=meta.sub; sub.Font=Enum.Font.Gotham
        sub.TextSize=8; sub.TextColor3=Color3.fromRGB(82,84,102); sub.TextXAlignment=Enum.TextXAlignment.Left

        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.new(1,-45,0,22); btn.Position=UDim2.new(0,45,0,6)
        btn.BackgroundTransparency=1
        btn.Text=name
        btn.TextColor3=isActive and Color3.fromRGB(240,240,255) or Color3.fromRGB(138,140,158)
        btn.Font=Enum.Font.GothamBold; btn.TextSize=10; btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.AutoButtonColor=false; btn.BorderSizePixel=0
        btn.TextWrapped=true; btn.TextTruncate=Enum.TextTruncate.AtEnd
        table.insert(_themeTabBtns,{btn=btn,name=name})
        CategoryRefs.btns[name]=btn

        btn.MouseEnter:Connect(function()
            if CategoryRefs.active~=name then
                local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
                tw(btn,{TextColor3=Color3.fromRGB(225,228,240)},ti)
                tw(row,{BackgroundTransparency=0.18,BackgroundColor3=Color3.fromRGB(18,18,25)},ti)
                tw(badgeText,{TextColor3=Color3.fromRGB(190,192,210)},ti)
            end
        end)
        btn.MouseLeave:Connect(function()
            if CategoryRefs.active~=name then
                local ti=TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
                tw(btn,{TextColor3=Color3.fromRGB(138,140,158)},ti)
                tw(row,{BackgroundTransparency=0.42,BackgroundColor3=Color3.fromRGB(10,10,15)},ti)
                tw(badgeText,{TextColor3=Color3.fromRGB(112,114,132)},ti)
            end
        end)

        btn.MouseButton1Click:Connect(function()
            if CategoryRefs.active == name then return end
            if CategoryRefs.select then CategoryRefs.select(name) end
            local ti_btn = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            local ti_ind = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            for n,b in pairs(CategoryRefs.btns) do
                local ac=(n==name)
                tw(b, {TextColor3=ac and Color3.fromRGB(240,240,255) or Color3.fromRGB(138,140,158)}, ti_btn)
                local r2=b.Parent
                tw(r2, {BackgroundTransparency=ac and 0.08 or 0.42,BackgroundColor3=ac and Color3.fromRGB(24,24,31) or Color3.fromRGB(10,10,15)}, ti_btn)
                local ind2=r2:FindFirstChild("indicator")
                if ind2 then tw(ind2, {BackgroundTransparency=ac and 0 or 1, Size=ac and UDim2.new(0,3,0,28) or UDim2.new(0,3,0,14)}, ti_ind) end
                local badge2=r2:FindFirstChild("Badge")
                if badge2 then
                    local bt=badge2:FindFirstChildOfClass("TextLabel")
                    tw(badge2,{BackgroundColor3=ac and _ACC.accentBg or Color3.fromRGB(19,19,26)},ti_btn)
                    if bt then tw(bt,{TextColor3=ac and _ACC.accent or Color3.fromRGB(112,114,132)},ti_btn) end
                end
                local stroke2=CategoryRefs.strokes[n]
                if stroke2 then stroke2.Color=ac and _ACC.accentDark or Color3.fromRGB(35,36,48) end
            end
        end)
    end

    do
        local spBtn=CategoryRefs.btns["Speed"]
        if spBtn then
            spBtn.TextColor3=_ACC.accent
            local r2=spBtn.Parent
            r2.BackgroundTransparency=0.08
            local ind2=r2:FindFirstChild("indicator")
            if ind2 then ind2.BackgroundTransparency=0; ind2.Size=UDim2.new(0,3,0,28) end
        end
    end

    do
        local userF=Instance.new("Frame",Inner)
        userF.Name="UserInfo"; userF.ZIndex=4
        userF.Size=UDim2.new(0,108,0,54); userF.Position=UDim2.new(1,-156,0,7)
        userF.BackgroundColor3=Color3.fromRGB(13,13,20); userF.BackgroundTransparency=1; userF.BorderSizePixel=0
        guiCorner(userF,10)
        local userStroke=guiStroke(userF,Color3.fromRGB(48,50,64),1);userStroke.Transparency=.72
        local userGrad=Instance.new("UIGradient",userF)
        userGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(22,22,31)),ColorSequenceKeypoint.new(0.55,Color3.fromRGB(13,13,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(7,7,12))})
        userGrad.Rotation=16
        local cardGlint=Instance.new("Frame",userF)
        cardGlint.Size=UDim2.new(1,-20,0,1); cardGlint.Position=UDim2.new(0,10,0,3)
        cardGlint.BackgroundColor3=Color3.fromRGB(235,238,255); cardGlint.BackgroundTransparency=1
        cardGlint.BorderSizePixel=0; cardGlint.ZIndex=6; guiCorner(cardGlint,1)
        local cardGlintGrad=Instance.new("UIGradient",cardGlint)
        cardGlintGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.45,.05),NumberSequenceKeypoint.new(1,1)})
        local profileAccent=Instance.new("Frame",userF)
        profileAccent.Size=UDim2.new(0,2,0,28); profileAccent.Position=UDim2.new(0,0,0.5,-14)
        profileAccent.BackgroundColor3=_ACC.accentDark; profileAccent.BackgroundTransparency=.62
        profileAccent.BorderSizePixel=0; profileAccent.ZIndex=6; guiCorner(profileAccent,2)
        local logoCircle=Instance.new("Frame",userF)
        logoCircle.Size=UDim2.new(0,40,0,40); logoCircle.Position=UDim2.new(0,7,0,7)
        logoCircle.BackgroundColor3=_ACC.accentBg; logoCircle.BackgroundTransparency=.72; logoCircle.BorderSizePixel=0
        guiCorner(logoCircle,20)
        local avatarStroke=guiStroke(logoCircle,_ACC.accentDark,1.7)
        local logoImg=Instance.new("ImageLabel",logoCircle)
        logoImg.Size=UDim2.new(1,-4,1,-4); logoImg.Position=UDim2.new(0,2,0,2)
        logoImg.BackgroundTransparency=1; logoImg.BorderSizePixel=0
        logoImg.Image=""; logoImg.ScaleType=Enum.ScaleType.Crop
        guiCorner(logoImg,18)
        task.spawn(function()
            local ok,thumb=pcall(function()
                return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
            end)
            if ok and logoImg and logoImg.Parent then logoImg.Image=thumb end
        end)
        local onlineDot=Instance.new("Frame",logoCircle)
        onlineDot.Size=UDim2.new(0,8,0,8); onlineDot.Position=UDim2.new(1,-8,1,-8)
        onlineDot.BackgroundColor3=Color3.fromRGB(110,225,145); onlineDot.BorderSizePixel=0
        onlineDot.ZIndex=8; guiCorner(onlineDot,4)
        local onlineStroke=guiStroke(onlineDot,Color3.fromRGB(8,8,13),1.5); onlineStroke.Transparency=0
        local onlineScale=Instance.new("UIScale",onlineDot)
        task.spawn(function()
            while onlineDot and onlineDot.Parent do
                TweenService:Create(onlineScale,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1.28}):Play(); task.wait(.7)
                TweenService:Create(onlineScale,TweenInfo.new(.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1}):Play(); task.wait(.7)
            end
        end)
        local profileName=Instance.new("TextLabel",userF)
        profileName.Size=UDim2.new(1,-60,0,16); profileName.Position=UDim2.new(0,53,0,8)
        profileName.BackgroundTransparency=1; profileName.Text=LP.DisplayName
        profileName.TextColor3=Color3.fromRGB(239,241,250); profileName.TextSize=9
        profileName.Font=Enum.Font.GothamBlack; profileName.TextXAlignment=Enum.TextXAlignment.Left
        profileName.TextStrokeColor3=Color3.fromRGB(8,8,13); profileName.TextStrokeTransparency=.7
        profileName.TextTruncate=Enum.TextTruncate.AtEnd
local profileHandle=Instance.new("TextLabel",userF)
profileHandle.Size=UDim2.new(1,-60,0,14); profileHandle.Position=UDim2.new(0,53,0,25)
profileHandle.BackgroundTransparency=1; profileHandle.Text="@"..LP.Name
profileHandle.TextColor3=Color3.fromRGB(194,198,214); profileHandle.TextSize=8
profileHandle.Font=Enum.Font.GothamMedium; profileHandle.TextXAlignment=Enum.TextXAlignment.Left
profileHandle.TextTruncate=Enum.TextTruncate.AtEnd
profileHandle.TextStrokeColor3=_ACC.accentDark; profileHandle.TextStrokeTransparency=.58
local handleGrad=Instance.new("UIGradient",profileHandle)
handleGrad.Color=_accentGrad(0)
handleGrad.Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.2),
    NumberSequenceKeypoint.new(.5,0),
    NumberSequenceKeypoint.new(1,.2)
})
task.spawn(function()
    local t=0
    while profileHandle and profileHandle.Parent do
        t=t+.035
        handleGrad.Offset=Vector2.new(math.sin(t*.8)*.35,0)
        handleGrad.Color=_accentGrad(t)
        task.wait(.04)
    end
end)
local profileLine=Instance.new("Frame",userF)
        profileLine.Size=UDim2.new(0,52,0,1); profileLine.Position=UDim2.new(0,53,1,-8)
        profileLine.BackgroundColor3=_ACC.accentDark; profileLine.BackgroundTransparency=.78
        profileLine.BorderSizePixel=0
        local lineGrad=Instance.new("UIGradient",profileLine)
        lineGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
        local profileScale=Instance.new("UIScale",userF)
        userF.MouseEnter:Connect(function()
            TweenService:Create(profileScale,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.035}):Play()
            tw(userF,{BackgroundColor3=_ACC.accentBg,BackgroundTransparency=1},TweenInfo.new(0.18))
            tw(profileAccent,{BackgroundTransparency=.38},TweenInfo.new(0.18))
            tw(userStroke,{Transparency=.42},TweenInfo.new(0.18))
        end)
        userF.MouseLeave:Connect(function()
            TweenService:Create(profileScale,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1}):Play()
            tw(userF,{BackgroundColor3=Color3.fromRGB(13,13,20),BackgroundTransparency=1},TweenInfo.new(0.2))
            tw(profileAccent,{BackgroundTransparency=.62},TweenInfo.new(0.2))
            tw(userStroke,{Transparency=.72},TweenInfo.new(0.2))
        end)
        table.insert(_themeExtRefs,{callback=function(thm)
            pcall(function()
                logoCircle.BackgroundColor3=thm.accentBg; avatarStroke.Color=thm.accentDark
                userStroke.Color=thm.accentDark; profileAccent.BackgroundColor3=thm.accentDark
                profileLine.BackgroundColor3=thm.accentDark; profileHandle.TextStrokeColor3=thm.accentDark
            end)
        end})
    end

    do
    local sp=CategoryRefs.contents["Speed"]
    local b=mkSection(sp,"SPEED CONFIGURATION",0)
    addInputRow(b,"Normal Speed",NS,1,function(v)
        local n=tonumber(v)
        if n and n>=0 then NS=n end
        pcall(applyActiveHumanoidSpeed)
        saveConfig()
    end)
    addInputRow(b,"Carry Speed",CS,2,function(v)
        local n=tonumber(v)
        if n and n>=0 then CS=n end
        pcall(applyActiveHumanoidSpeed)
        saveConfig()
    end)
    addInputRow(b,"Lagger Normal",LAGGER_SPEED,3,function(v)
        local n=tonumber(v)
        if n and n>=0 then LAGGER_SPEED=n end
        saveConfig()
    end)
    addInputRow(b,"Lagger Carry",LAGGER_CARRY_SPEED,4,function(v)
        local n=tonumber(v)
        if n and n>=0 then LAGGER_CARRY_SPEED=n end
        saveConfig()
    end)

    local _,carryVisual=addToggleRow(b,"Carry Mode",speedMode=="Carry",5,nil,function(on)
        manualSpeedOverride=true
        if on then
            setSpeedMode("Carry")
        elseif speedMode=="Carry" then
            setSpeedMode("Normal")
        end
        if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(speedMode=="Carry") end
        if mobBtnRefs.lagger then mobBtnRefs.lagger(speedMode=="Lagger") end
        saveConfig()
    end)
    _GACC.safeCarryVisual=carryVisual

    local _,laggerVisual=addToggleRow(b,"Lagger Mode",speedMode=="Lagger",6,nil,function(on)
        manualSpeedOverride=true
        if on then
            setSpeedMode("Lagger")
        elseif speedMode=="Lagger" then
            setSpeedMode("Normal")
        end
        if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(speedMode=="Carry") end
        if mobBtnRefs.lagger then mobBtnRefs.lagger(speedMode=="Lagger") end
        saveConfig()
    end)
    _GACC.safeLaggerVisual=laggerVisual

    local _,autoCarryVisual=addToggleRow(b,"Auto Carry Speed",_GACC.autoCarrySpeedEnabled,7,nil,function(on)
        _GACC.autoCarrySpeedEnabled=on
        if on then manualSpeedOverride=false end
        if not on and _GACC.disableAutoCarry then _GACC.disableAutoCarry() end
        saveConfig()
    end)
    _GACC.autoCarryVisual=autoCarryVisual
    end 

    task.spawn(function()

    do
    local cp=CategoryRefs.contents["Combat"]
    do local b=mkSection(cp,"BAT CONTROLS",0)
    local _,svAutoBat=addToggleRow(b,"Bat Aimbot",autoBatEnabled,1,"circle",function(on)
        if on and _GACC.safeTryStart and not _GACC.safeTryStart() then
            if svAutoBat then svAutoBat(false) end
            return
        end
        if on then
            _GACC.exclusiveStop("batAimbot")
            queueAutoBatStart();if mobBtnRefs.autoBat then mobBtnRefs.autoBat(true) end
        else stopBatAimbot();if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end end
        saveConfig()
    end)
    autoBatSetVisual=svAutoBat
    local _,svBatDesyncTp=addToggleRow(b,"Bat Desync TP",batDesyncTpEnabled,2,"batDesyncTp",function(on)
        if on and _GACC.safeTryStart and not _GACC.safeTryStart() then
            if svBatDesyncTp then svBatDesyncTp(false) end
            return
        end
        if on then
            _GACC.exclusiveStop("batTp")
            batDesyncTpEnabled=true
            startBatDesyncTp()
        else
            stopBatDesyncTp()
        end
        saveConfig()
    end)
    batDesyncTpSetVisual=svBatDesyncTp
    addToggleRow(b,"Auto Swing",autoSwingEnabled,3,nil,function(on) autoSwingEnabled=on;saveConfig(); end)
    _GACC.extras.addDropdownRow(b,"Drop Type",_GACC.DROP_TYPES,_GACC.dropType,4,function(name)
        _GACC.dropType=name; saveConfig()
    end)
    _GACC.extras.addDropdownRow(b,"After Drop",_GACC.AFTER_DROP_OPTIONS,_GACC.afterDrop,5,function(name)
        _GACC.afterDrop=name; saveConfig()
    end)
    end

    do local b=mkSection(cp,"RAGDOLL",1)
    addToggleRow(b,"Bat Counter",_GACC.batCounterEnabled,0,nil,function(on)
        _GACC.batCounterEnabled=on
        if on then _GACC.startBatCounter() else _GACC.stopBatCounter() end
        saveConfig()
    end)
    local _,svRagdoll=addToggleRow(b,"Anti Ragdoll",antiRagdollEnabled,1,nil,function(on) antiRagdollEnabled=on;if on then startAntiRagdoll() else stopAntiRagdoll() end;saveConfig() end)
    setAntiRagVisual=svRagdoll
    if antiRagdollEnabled then svRagdoll(true) end
    local _,svMedusa=addToggleRow(b,"Medusa Counter",medusaCounterEnabled,2,nil,function(on) medusaCounterEnabled=on;if on then setupMedusa(LP.Character) else stopMedusaCounter() end;saveConfig() end)
    setMedusaVisual=svMedusa
    local _,svUnwalk=addToggleRow(b,"Unwalk",unwalkEnabled,3,nil,function(on) unwalkEnabled=on;if on then startUnwalk() else stopUnwalk() end;saveConfig() end)
    setUnwalkVisual=svUnwalk
    end

    -- ========== NEW ANTI DIE SECTION ==========
    do local b=mkSection(cp,"SAFE MODE",1.5)
    addToggleRow(b,"Safe Mode",_GACC.safeModeEnabled,1,nil,function(on)
        _GACC.safeModeEnabled=on
        if on and _GACC.safeForceStop then _GACC.safeForceStop() end
        saveConfig()
    end)
    end

    do local b=mkSection(cp,"ANTI DIE",2)
    local _,svAntiDie=addToggleRow(b,"Anti Die",antiDieEnabled,1,nil,function(on)
        if on then
            startAntiDie()
        else
            stopAntiDie()
        end
        saveConfig()
    end)
    end
    -- ==========================================

    do local b=mkSection(cp,"STEAL",3)
    local radiusRow
    local function syncStealSettingRows(animate)
        -- Steal Radius applies to NORMAL and SEMI. V1-V4 are fixed presets.
        local show=(stealMode=="normal" or stealMode=="semi")
        if not radiusRow then return end
        if show then
            radiusRow.Visible=true
            if animate then
                radiusRow.Size=UDim2.new(1,0,0,0)
                tw(radiusRow,{Size=UDim2.new(1,0,0,42)},TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out))
            else
                radiusRow.Size=UDim2.new(1,0,0,42)
            end
        elseif animate then
            tw(radiusRow,{Size=UDim2.new(1,0,0,0)},TweenInfo.new(0.16,Enum.EasingStyle.Quint,Enum.EasingDirection.In))
            task.delay(0.17,function()
                if radiusRow and not (stealMode=="normal" or stealMode=="semi") then radiusRow.Visible=false end
            end)
        else
            radiusRow.Visible=false
        end
    end

    do
        local Row=Instance.new("Frame",b)
        Row.Size=UDim2.new(1,0,0,42); Row.BackgroundColor3=Color3.fromRGB(11,11,17)
        Row.BackgroundTransparency=0.25; Row.BorderSizePixel=0; Row.LayoutOrder=1
        guiCorner(Row,6); local autoStealStroke=guiStroke(Row,Color3.fromRGB(38,40,52),1)
        local topGlow=Instance.new("Frame",Row)
        topGlow.Size=UDim2.new(1,-24,0,1); topGlow.Position=UDim2.new(0,12,0,0)
        topGlow.BackgroundColor3=_ACC.accent; topGlow.BackgroundTransparency=1; topGlow.BorderSizePixel=0; topGlow.Visible=false
        local topGlowGrad=Instance.new("UIGradient",topGlow)
        topGlowGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})
        task.spawn(function()
            local x=-1
            while topGlow and topGlow.Parent do
                x=x+0.025; if x>1 then x=-1 end
                topGlowGrad.Offset=Vector2.new(x,0)
                task.wait(0.025)
            end
        end)

        local Lb=Instance.new("TextLabel",Row)
        Lb.Size=UDim2.new(0,90,0,18); Lb.Position=UDim2.new(0,14,0,12)
        Lb.BackgroundTransparency=1; Lb.Text="Auto Steal"
        Lb.TextColor3=Color3.fromRGB(190,226,255); Lb.TextSize=12; Lb.Font=Enum.Font.GothamBold
        Lb.TextXAlignment=Enum.TextXAlignment.Left
        local stealDesc=Instance.new("TextLabel",Row)
        stealDesc.Size=UDim2.new(1,-112,0,13); stealDesc.Position=UDim2.new(0,55,0,28)
        stealDesc.BackgroundTransparency=1; stealDesc.Text=""; stealDesc.Visible=false
        stealDesc.TextColor3=Color3.fromRGB(102,105,124); stealDesc.TextSize=8; stealDesc.Font=Enum.Font.Gotham
        stealDesc.TextXAlignment=Enum.TextXAlignment.Left

        local modeBtn=Instance.new("TextButton",Row)
        modeBtn.Size=UDim2.new(0,58,0,20); modeBtn.Position=UDim2.new(0,102,0,11)
        modeBtn.BackgroundColor3=_ACC.accentBg; modeBtn.BackgroundTransparency=0.16
        modeBtn.BorderSizePixel=0; modeBtn.ZIndex=6
        modeBtn.Font=Enum.Font.GothamBold; modeBtn.TextSize=8
        modeBtn.TextColor3=Color3.fromRGB(118,188,240)
        guiCorner(modeBtn,7)
        local modeBtnStroke=guiStroke(modeBtn,_ACC.accentDark,1)

        local function updateModeBtn()
            if stealMode~="normal" then
                modeBtn.Text=stealMode:upper()
                tw(modeBtn,{BackgroundColor3=_ACC.accentBg,BackgroundTransparency=0.05})
                modeBtn.TextColor3=_ACC.accent
                if modeBtnStroke then modeBtnStroke.Color=_ACC.accentDark end
            else
                modeBtn.Text="NORMAL"
                tw(modeBtn,{BackgroundColor3=_ACC.accentBg,BackgroundTransparency=0.16})
                modeBtn.TextColor3=Color3.fromRGB(118,188,240)
                if modeBtnStroke then modeBtnStroke.Color=_ACC.accentDark end
            end
        end
        updateModeBtn()

        modeBtn.MouseEnter:Connect(function() tw(modeBtn,{BackgroundTransparency=0}) end)
        modeBtn.MouseLeave:Connect(function() updateModeBtn() end)

        local arrowBtn=Instance.new("TextButton",Row)
        arrowBtn.Size=UDim2.new(0,22,0,20); arrowBtn.Position=UDim2.new(0,166,0,11)
        arrowBtn.BackgroundColor3=_ACC.accentBg; arrowBtn.BackgroundTransparency=0.14
        arrowBtn.BorderSizePixel=0; arrowBtn.Text="v"; arrowBtn.TextColor3=_ACC.accent
        arrowBtn.Font=Enum.Font.GothamBold; arrowBtn.TextSize=10; arrowBtn.ZIndex=8
        guiCorner(arrowBtn,7); local arrowStroke=guiStroke(arrowBtn,_ACC.accentDark,1)

        local modeDrop=Instance.new("Frame",Row)
        modeDrop.Size=UDim2.new(0,176,0,0); modeDrop.Position=UDim2.new(0,12,0,44)
        modeDrop.BackgroundColor3=Color3.fromRGB(2,16,32); modeDrop.BackgroundTransparency=0.02
        modeDrop.BorderSizePixel=0; modeDrop.ClipsDescendants=true; modeDrop.ZIndex=7
        guiCorner(modeDrop,8); guiStroke(modeDrop,_ACC.accentDark,1)
        local stealChoices={}
        do
            local defs={{"normal","NORMAL"},{"semi","SEMI"},{"v1","V1"},{"v2","V2"},{"v3","V3"},{"v4","V4"}}
            for idx,def in ipairs(defs) do
                local col=(idx-1)%3; local row=math.floor((idx-1)/3)
                local btn=Instance.new("TextButton",modeDrop)
                btn.Size=UDim2.new(0.333,-4,0,21)
                btn.Position=UDim2.new(0.333*col, col==0 and 3 or 1, 0, 3+row*24)
                btn.BackgroundColor3=Color3.fromRGB(7,22,40); btn.BackgroundTransparency=0.12
                btn.BorderSizePixel=0; btn.Text=def[2]; btn.TextColor3=Color3.fromRGB(105,170,220)
                btn.Font=Enum.Font.GothamBold; btn.TextSize=8; btn.ZIndex=9; guiCorner(btn,6)
                stealChoices[idx]={mode=def[1],btn=btn}
            end
        end
        local dropOpen=false
        local function setDropOpen(on)
            dropOpen=on; arrowBtn.Text=on and "^" or "v"
            tw(Row,{Size=UDim2.new(1,0,0,on and 98 or 42)},TweenInfo.new(0.24,Enum.EasingStyle.Quint,Enum.EasingDirection.Out))
            tw(modeDrop,{Size=UDim2.new(0,176,0,on and 51 or 0)},TweenInfo.new(0.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out))
            tw(arrowBtn,{BackgroundColor3=on and _ACC.accentHover or _ACC.accentBg},TweenInfo.new(0.18))
        end
        local function chooseStealMode(nextMode)
            if stealMode~=nextMode then
                local wasOn=Steal.AutoStealEnabled
                if wasOn then stopAutoSteal() end
                stealMode=nextMode; updateModeBtn(); syncStealSettingRows(true); saveConfig()
                if wasOn then startAutoSteal() end
            end
            for _,c in ipairs(stealChoices) do
                local sel=(stealMode==c.mode)
                c.btn.BackgroundColor3=sel and _ACC.accentBg or Color3.fromRGB(7,22,40)
                c.btn.TextColor3=sel and _ACC.accent or Color3.fromRGB(105,170,220)
            end
            setDropOpen(false)
        end
        for _,c in ipairs(stealChoices) do
            c.btn.MouseButton1Click:Connect(function() chooseStealMode(c.mode) end)
            c.btn.MouseEnter:Connect(function() tw(c.btn,{BackgroundColor3=_ACC.accentHover},TweenInfo.new(0.14)) end)
            c.btn.MouseLeave:Connect(function()
                tw(c.btn,{BackgroundColor3=(stealMode==c.mode) and _ACC.accentBg or Color3.fromRGB(7,22,40)},TweenInfo.new(0.16))
            end)
        end
        arrowBtn.MouseButton1Click:Connect(function() setDropOpen(not dropOpen) end)
        modeBtn.MouseButton1Click:Connect(function() setDropOpen(not dropOpen) end)
        local arrowScale=Instance.new("UIScale",arrowBtn)
        arrowBtn.MouseEnter:Connect(function()
            TweenService:Create(arrowScale,TweenInfo.new(0.16,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.1}):Play()
            tw(arrowBtn,{BackgroundColor3=_ACC.accentHover},TweenInfo.new(0.16))
        end)
        arrowBtn.MouseLeave:Connect(function()
            TweenService:Create(arrowScale,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1}):Play()
            tw(arrowBtn,{BackgroundColor3=dropOpen and _ACC.accentHover or _ACC.accentBg},TweenInfo.new(0.18))
        end)
        chooseStealMode(stealMode)

        table.insert(_themeExtRefs,{callback=function(thm)
            pcall(function()
                if stealMode~="normal" then
                    tw(modeBtn,{BackgroundColor3=thm.accentBg})
                    modeBtn.TextColor3=thm.accent
                    if modeBtnStroke then modeBtnStroke.Color=thm.accentDark end
                end
            end)
        end})

        local OFF_TRACK=Color3.fromRGB(5,24,43); local OFF_KNOB=Color3.fromRGB(70,126,174)
        -- ── Ritual Hub style circle toggle ──────────────────────────────
        local Track=Instance.new("Frame",Row); Track.ZIndex=3
        Track.Size=UDim2.new(0,36,0,24); Track.Position=UDim2.new(1,-48,0,9)
        Track.BackgroundTransparency=1; Track.BorderSizePixel=0
        Instance.new("UICorner",Track).CornerRadius=UDim.new(1,0)
        local TrkStroke=nil
        local Shadow=Instance.new("Frame",Track); Shadow.ZIndex=3; Shadow.AnchorPoint=Vector2.new(0.5,0.5)
        Shadow.Position=UDim2.new(0.5,0,0.5,1); Shadow.Size=UDim2.new(0,16,0,16)
        Shadow.BackgroundColor3=Color3.fromRGB(0,0,0); Shadow.BackgroundTransparency=0.5; Shadow.BorderSizePixel=0
        Instance.new("UICorner",Shadow).CornerRadius=UDim.new(1,0)
        local Knob=Instance.new("Frame",Track); Knob.ZIndex=4; Knob.AnchorPoint=Vector2.new(0.5,0.5)
        Knob.Position=UDim2.new(0.5,0,0.5,0); Knob.Size=UDim2.new(0,13,0,13)
        Knob.BackgroundColor3=OFF_KNOB; Knob.BorderSizePixel=0
        Instance.new("UICorner",Knob).CornerRadius=UDim.new(1,0)
        local KnobGrad=Instance.new("UIGradient",Knob); KnobGrad.Rotation=90
        local Gloss=Instance.new("Frame",Knob); Gloss.ZIndex=5
        Gloss.Position=UDim2.new(0.22,0,0.11,0); Gloss.Size=UDim2.new(0.46,0,0.24,0)
        Gloss.BackgroundColor3=Color3.fromRGB(255,255,255); Gloss.BackgroundTransparency=0.62; Gloss.BorderSizePixel=0
        Instance.new("UICorner",Gloss).CornerRadius=UDim.new(1,0)
        local GlossGrad=Instance.new("UIGradient",Gloss); GlossGrad.Rotation=90
        GlossGrad.Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.35),NumberSequenceKeypoint.new(0.6,0.78),NumberSequenceKeypoint.new(1,1)
        })
        local function stealCircleVisual(on)
            if on then
                Knob.BackgroundColor3=_ACC.accent
                KnobGrad.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,Color3.fromRGB(200,230,255)),
                    ColorSequenceKeypoint.new(0.46,_ACC.accent),
                    ColorSequenceKeypoint.new(1,_ACC.accentDark),
                })
                Gloss.BackgroundTransparency=0.5
            else
                Knob.BackgroundColor3=OFF_KNOB
                KnobGrad.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0,Color3.fromRGB(235,232,248)),
                    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(128,124,150)),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(48,48,58)),
                })
                Gloss.BackgroundTransparency=0.62
            end
        end

        local statusDot=Instance.new("Frame",Row)
        statusDot.Size=UDim2.new(0,6,0,6); statusDot.Position=UDim2.new(0,0,0,0)
        statusDot.BorderSizePixel=0; statusDot.Visible=false; guiCorner(statusDot,3)
        local statusLbl=Instance.new("TextLabel",Row)
        statusLbl.Size=UDim2.new(0,0,0,0); statusLbl.Position=UDim2.new(0,0,0,0)
        statusLbl.BackgroundTransparency=1; statusLbl.TextSize=8; statusLbl.Font=Enum.Font.GothamBold; statusLbl.Visible=false
        statusLbl.TextXAlignment=Enum.TextXAlignment.Left

        local stealToggleSt=Steal.AutoStealEnabled
        local function setStealV(on)
            stealToggleSt=on
            if on then playFeatureEffect(Row) end
            stealCircleVisual(on)
            Knob.Size=UDim2.new(0,10,0,10)
            tw(Knob,{Size=UDim2.new(0,13,0,13)},TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out))
            statusDot.BackgroundColor3=on and _ACC.accent or _ACC.accentDark
            statusLbl.Text=on and "ON" or "OFF"
            statusLbl.TextColor3=on and Color3.fromRGB(170,222,255) or Color3.fromRGB(100,157,205)
            if TrkStroke then TrkStroke.Color=_ACC.accentDark end
        end
        table.insert(_themeToggleRefs,{track=Track,trkStroke=TrkStroke,knob=Knob,
            offTrack=OFF_TRACK,offKnob=OFF_KNOB,offStroke=_ACC.accentDark,
            getSt=function() return stealToggleSt end})

        setStealV(stealToggleSt)
        table.insert(_themeExtRefs,{callback=function(thm)
            pcall(function()
                topGlow.BackgroundColor3=thm.accent; arrowBtn.TextColor3=thm.accent; arrowStroke.Color=thm.accentDark
            end)
        end})

        local ToggleBtn=Instance.new("TextButton",Row)
        ToggleBtn.Size=UDim2.new(0,36,0,24); ToggleBtn.Position=UDim2.new(1,-48,0,9)
        ToggleBtn.BackgroundTransparency=1; ToggleBtn.Text=""; ToggleBtn.ZIndex=8
        ToggleBtn.MouseButton1Click:Connect(function()
            stealToggleSt=not stealToggleSt; setStealV(stealToggleSt)
            Steal.AutoStealEnabled=stealToggleSt
            if stealToggleSt then startAutoSteal() else stopAutoSteal() end
            saveConfig()
        end)

        local hov=Instance.new("TextButton",Row)
        hov.Size=UDim2.new(1,0,1,0); hov.BackgroundTransparency=1; hov.Text=""; hov.ZIndex=0
        hov.MouseEnter:Connect(function() tw(Row,{BackgroundTransparency=0.18,BackgroundColor3=_ACC.accentRowHover}); autoStealStroke.Color=_ACC.accentDark end)
        hov.MouseLeave:Connect(function() tw(Row,{BackgroundTransparency=0.25,BackgroundColor3=Color3.fromRGB(11,11,17)}); autoStealStroke.Color=Color3.fromRGB(38,40,52) end)
    end

    radiusRow=addInputRow(b,"Steal Radius",Steal.StealRadius,2,function(v) Steal.StealRadius=math.clamp(tonumber(v) or 61,1,500); saveConfig() end)
    syncStealSettingRows(false)
    end

    do local b=mkSection(cp,"ACTIONS",4)
    -- Drop Brainrot / TP Down removed: mobile buttons + keybinds cover these.
    addToggleRow(b,"Medusa Instant Reset",_GACC.medusaResetEnabled,4,nil,function(on)
        _GACC.medusaResetEnabled = on
        if on then _GACC.startMedusaReset(LP.Character) else _GACC.stopMedusaReset() end
        saveConfig()
    end)
    local _,svAntiSummer = addToggleRow(b,"Anti Summer Base",AntiSummer.antiSummerBaseEnabled,5,nil,function(on)
        if on then
            AntiSummer.enable()
        else
            AntiSummer.disable()
        end
        saveConfig()
    end)
    end

    do local b=mkSection(cp,"HIGHLIGHT",5)
    addToggleRow(b,"Player Highlight",_GACC.playerHighlightEnabled,1,nil,function(on)
        _GACC.playerHighlightEnabled=on
        if on then _GACC.startESP() else _GACC.stopESP() end
        saveConfig()
    end)
    end

    end 

    do
    local mv=CategoryRefs.contents["Movement"]
    -- AUTO PATHS section removed: use the mobile buttons or keybinds instead.

    do local b=mkSection(mv,"SETTINGS",1)
    local _,svAutoTP=addToggleRow(b,"Auto TP",autoTPEnabled,1,nil,function(on) autoTPEnabled=on;if on then startAutoTP() else stopAutoTP() end;saveConfig() end)
    setAutoTPVisual=svAutoTP
    addInputRow(b,"TP Height",autoTPHeight,2,function(v) if v>=0 and v<=500 then autoTPHeight=v end;saveConfig() end)
    local _,svInfJump=addToggleRow(b,"Infinite Jump",infJumpEnabled,3,nil,function(on)
        infJumpEnabled=on; if on then startHoldInfJump() else stopHoldInfJump() end; saveConfig()
    end)
    setInfJumpVisual=svInfJump
    end

    end 

    applyColorTheme = function(name)
        local thm = THEME_DEFS[name]; if not thm then return end
        currentColorTheme = name
        
        _ACC.accent=thm.accent; _ACC.accentDark=thm.accentDark
        _ACC.accentBg=thm.accentBg; _ACC.accentHover=thm.accentHover
        _ACC.accentRowHover=thm.accentRowHover
        
        _GACC.accent=thm.accent; _GACC.accentDark=thm.accentDark
        _GACC.accentBg=thm.accentBg; _GACC.accentHover=thm.accentHover
        _GACC.accentRowHover=thm.accentRowHover
        
        for _,_r in ipairs(_themeExtRefs) do pcall(_r.callback,thm) end
        
        C.blue=thm.accent; C.accent=thm.accent; C.accentDark=thm.accentDark
        C.accentBg=thm.accentBg; C.accentHover=thm.accentHover; C.accentRowHover=thm.accentRowHover
        
        for _,f in ipairs(_themeSeps)       do pcall(function() f.BackgroundColor3=thm.accent end) end
        for _,f in ipairs(_themeScrollbars) do pcall(function() f.ScrollBarImageColor3=thm.accent end) end
        for _,r in ipairs(_themeSectRefs)   do
            pcall(function() r.arrow.TextColor3=thm.accent end)
            pcall(function() r.lbl.TextColor3=thm.accentDark end)
        end
        for _,tb in ipairs(_themeTabBtns) do
            pcall(function()
                local ac=(CategoryRefs.active==tb.name)
                tb.btn.TextColor3 = ac and thm.accent or Color3.fromRGB(68,68,82)
            end)
        end
        for _,ind in ipairs(_themeTabInds) do pcall(function() ind.BackgroundColor3=thm.accent end) end
        
        for _,tgl in ipairs(_themeToggleRefs) do pcall(function()
            if tgl.getSt() then
                tgl.track.BackgroundColor3=thm.accentBg
                tgl.knob.BackgroundColor3=thm.accent
                if tgl.trkStroke then tgl.trkStroke.Color=thm.accentDark end
            end
        end) end
        for _,ab in ipairs(_themeActBtns)  do
            pcall(function() ab.BackgroundColor3=thm.accentBg end)
            pcall(function() ab.TextColor3=thm.accent end)
        end
        for _,kb in ipairs(_themeKbLabels) do
            pcall(function() kb.BackgroundColor3=thm.accentBg end)
            pcall(function() kb.TextColor3=thm.accent end)
        end
        
        for _,s in ipairs(_themeSwatchStrokes) do
            local ac=(s.name==name)
            TweenService:Create(s.stroke,TweenInfo.new(0.15),{
                Color=ac and Color3.fromRGB(255,255,255) or Color3.fromRGB(60,60,70),
                Transparency=ac and 0.05 or 0.5, Thickness=ac and 2.5 or 1
            }):Play()
        end
        
        applyBackgroundImage()
        
        saveConfig()
    end

    do
    local vi=CategoryRefs.contents["Visual"]

    do local b=mkSection(vi,"AVATAR",0)
    local packNames={"Off"}
    do
        local tmp={}; for name in pairs(_GACC.extras.packs) do table.insert(tmp,name) end; table.sort(tmp)
        for _,n in ipairs(tmp) do table.insert(packNames,n) end
    end
    _GACC.extras.addDropdownRow(b,"Anim Pack",packNames,_GACC.extras.getPack(),1,function(name)
        local ok=_GACC.extras.setPack(name,true,LP.Character)
        if ok then saveConfig() end
    end)
    addToggleRow(b,"Headless",_GACC.extras.getHeadless(),2,nil,function(on) _GACC.extras.setHeadless(on,LP.Character); saveConfig() end)
    addToggleRow(b,"Korblox",_GACC.extras.getKorblox(),3,nil,function(on) _GACC.extras.setKorblox(on,LP.Character); saveConfig() end)
    end

    do local b=mkSection(vi,"VISUAL",1)
    addToggleRow(b,"Intro Song",introSoundEnabled,1,nil,function(on)
        introSoundEnabled=on
        if not on and introSoundInstance and introSoundInstance.IsPlaying then pcall(function() introSoundInstance:Stop() end) end
        saveConfig()
    end)
    addToggleRow(b,"Anti Lag",antiLagEnabled,2,nil,function(on) if on then enableAntiLag() else disableAntiLag() end;saveConfig() end)
    addToggleRow(b,"Stretch Rez",stretchRezEnabled,3,nil,function(on) if on then enableStretchRez() else disableStretchRez() end;saveConfig() end)
    addToggleRow(b,"Ragdoll GUI",ragdollGuiEnabled,4,nil,function(on) ragdollGuiEnabled=on;saveConfig() end)
    end

    local viFovBody=mkSection(vi,"FOV",3)
    do 
    local fovRow=Instance.new("Frame"); fovRow.Size=UDim2.new(1,0,0,38); fovRow.BackgroundColor3=C.row
    fovRow.BackgroundTransparency=0.5; fovRow.BorderSizePixel=0; fovRow.LayoutOrder=1; fovRow.Parent=viFovBody
    guiCorner(fovRow,10); guiStroke(fovRow,C.divider,1)
    local fovLbl=Instance.new("TextLabel",fovRow); fovLbl.Size=UDim2.new(0.5,0,0,16); fovLbl.Position=UDim2.new(0,12,0,6)
    fovLbl.BackgroundTransparency=1; fovLbl.Text="FOV"; fovLbl.TextColor3=C.text; fovLbl.TextSize=11; fovLbl.Font=Enum.Font.GothamBold; fovLbl.TextXAlignment=Enum.TextXAlignment.Left
    local fovBtn=Instance.new("TextButton",fovRow); fovBtn.Size=UDim2.new(0,52,0,22)
    fovBtn.AnchorPoint=Vector2.new(1,0.5); fovBtn.Position=UDim2.new(1,-12,0.5,0); fovBtn.AutomaticSize=Enum.AutomaticSize.X
    fovBtn.BackgroundColor3=_ACC.accentBg; fovBtn.BackgroundTransparency=0.3; fovBtn.BorderSizePixel=0
    fovBtn.Text=tostring(fovValue); fovBtn.TextColor3=_ACC.accent
    table.insert(_themeActBtns,fovBtn); fovBtn.TextSize=11; fovBtn.Font=Enum.Font.GothamBold; guiCorner(fovBtn,5)
    do local fovBtnPad=Instance.new("UIPadding",fovBtn); fovBtnPad.PaddingLeft=UDim.new(0,10); fovBtnPad.PaddingRight=UDim.new(0,10) end
    fovBtn.MouseButton1Click:Connect(function()
        fovIndex=fovIndex%#fovOptions+1; fovValue=fovOptions[fovIndex]; fovBtn.Text=tostring(fovValue); applyFOV(); saveConfig()
    end)
    fovBtn.MouseEnter:Connect(function() tw(fovBtn,{BackgroundTransparency=0.05}); tw(fovBtn,{BackgroundColor3=_ACC.accentHover}) end)
    fovBtn.MouseLeave:Connect(function() tw(fovBtn,{BackgroundTransparency=0.3}); tw(fovBtn,{BackgroundColor3=_ACC.accentBg}) end)
    local hov3=Instance.new("TextButton",fovRow); hov3.Size=UDim2.new(1,0,1,0); hov3.BackgroundTransparency=1; hov3.Text=""; hov3.ZIndex=0
    hov3.MouseEnter:Connect(function() tw(fovRow,{BackgroundTransparency=0.2}); tw(fovRow,{BackgroundColor3=_ACC.accentRowHover}) end)
    hov3.MouseLeave:Connect(function() tw(fovRow,{BackgroundTransparency=0.5}); tw(fovRow,{BackgroundColor3=C.row}) end)
    end 
    end

    ;(function(settingsPage)
    -- lives on the Visual page now; the argument name is left alone so the
    -- rest of this closure does not need touching
    local backgroundBody=mkSection(settingsPage,"BACKGROUNDS",4)
    addActionRow(backgroundBody,"Background Images",nil,function()
        if PlayerGui:FindFirstChild("RitualBackgroundGalleryLayer") then return end

        local selectedIndex=backgroundIndex
        local closing=false
        local cardRefs={}
        local responsiveConn=nil
        local modalGui=Instance.new("ScreenGui")
        modalGui.Name="RitualBackgroundGalleryLayer"; modalGui.ResetOnSpawn=false; modalGui.IgnoreGuiInset=true
        modalGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; modalGui.DisplayOrder=999; modalGui.Parent=PlayerGui
        local blur=Instance.new("BlurEffect")
        blur.Name="RitualBackgroundGalleryBlur"; blur.Size=0; blur.Parent=Lighting

        local overlay=Instance.new("TextButton",modalGui)
        overlay.Name="BackgroundGalleryOverlay"; overlay.Size=UDim2.fromScale(1,1)
        overlay.BackgroundColor3=Color3.fromRGB(2,3,8); overlay.BackgroundTransparency=1
        overlay.BorderSizePixel=0; overlay.Text=""; overlay.AutoButtonColor=false; overlay.ZIndex=100

        local popup=Instance.new("CanvasGroup",overlay)
        popup.Name="BackgroundGallery"; popup.AnchorPoint=Vector2.new(.5,.5); popup.Position=UDim2.new(.5,-165,.5,0)
        popup.Size=UDim2.fromOffset(720,470); popup.BackgroundColor3=Color3.fromRGB(7,8,14)
        popup.BackgroundTransparency=.34; popup.BorderSizePixel=0; popup.ClipsDescendants=true
        popup.GroupTransparency=1; popup.Rotation=-3; popup.ZIndex=101; guiCorner(popup,20)
        local popupStroke=guiStroke(popup,Color3.fromRGB(104,112,138),1.4); popupStroke.Transparency=.34
        local popupScale=Instance.new("UIScale",popup)
        local showcaseScale=nil

        local function getTargetScale()
            local camera=workspace.CurrentCamera
            local viewport=camera and camera.ViewportSize or Vector2.new(1280,720)
            return math.clamp(math.min((viewport.X-28)/1050,(viewport.Y-28)/470),.42,1)
        end
        local targetScale=getTargetScale()
        popupScale.Scale=targetScale*.78
        responsiveConn=workspace.CurrentCamera and workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            targetScale=getTargetScale()
            TweenService:Create(popupScale,TweenInfo.new(.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=targetScale}):Play()
            if showcaseScale then TweenService:Create(showcaseScale,TweenInfo.new(.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=targetScale}):Play() end
        end)

        local showcasePanel=Instance.new("CanvasGroup",overlay)
        showcasePanel.Name="FullMainGuiShowcase";showcasePanel.AnchorPoint=Vector2.new(.5,.5)
        showcasePanel.Position=UDim2.new(.5,365,.5,0);showcasePanel.Size=UDim2.fromOffset(310,410)
        showcasePanel.BackgroundTransparency=1;showcasePanel.BorderSizePixel=0
        showcasePanel.GroupTransparency=1;showcasePanel.ZIndex=102;showcasePanel.Active=true
        showcaseScale=Instance.new("UIScale",showcasePanel);showcaseScale.Scale=targetScale*.78
        local showcaseClone=Inner:Clone()
        showcaseClone.Name="LiveMainGuiPreview";showcaseClone.Size=UDim2.fromScale(1,1)
        showcaseClone.Position=UDim2.fromOffset(0,0);showcaseClone.AnchorPoint=Vector2.zero
        showcaseClone.BackgroundTransparency=.74;showcaseClone.ZIndex=203;showcaseClone.Parent=showcasePanel
        for _,object in ipairs(showcaseClone:GetDescendants()) do
            if object:IsA("GuiObject") then object.ZIndex=math.min(999,object.ZIndex+203) end
        end
        local externalShowcaseBg=showcaseClone:FindFirstChild("BackgroundImage",true)
        if externalShowcaseBg and externalShowcaseBg:IsA("ImageLabel") then
            externalShowcaseBg.Image=_GACC.backgroundImages[selectedIndex]
            externalShowcaseBg.ImageTransparency=.18
            externalShowcaseBg.Visible=true
        end
        local clonedGrad=showcaseClone:FindFirstChild("BgGrad",true)
        if clonedGrad and clonedGrad:IsA("GuiObject") then clonedGrad.BackgroundTransparency=1 end
        local clonedRain=showcaseClone:FindFirstChild("RainEffect",true)
        if clonedRain and clonedRain:IsA("GuiObject") then clonedRain.Visible=false end

        local topGlow=Instance.new("Frame",popup)
        topGlow.Size=UDim2.new(1,0,0,105); topGlow.BackgroundColor3=_ACC.accentBg
        topGlow.BackgroundTransparency=.58; topGlow.BorderSizePixel=0; topGlow.ZIndex=101
        local topGlowGrad=Instance.new("UIGradient",topGlow)
        topGlowGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,_ACC.accentDark),ColorSequenceKeypoint.new(.48,_ACC.accent),ColorSequenceKeypoint.new(1,_ACC.accentDark)})
        topGlowGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.76),NumberSequenceKeypoint.new(.48,.91),NumberSequenceKeypoint.new(1,1)})
        topGlowGrad.Rotation=8

        local accentLine=Instance.new("Frame",popup)
        accentLine.Position=UDim2.fromOffset(24,0); accentLine.Size=UDim2.new(1,-48,0,2)
        accentLine.BackgroundColor3=_ACC.accent; accentLine.BorderSizePixel=0; accentLine.ZIndex=109
        local accentFade=Instance.new("UIGradient",accentLine)
        accentFade.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.2,.08),NumberSequenceKeypoint.new(.8,.08),NumberSequenceKeypoint.new(1,1)})

        local title=Instance.new("TextLabel",popup)
        title.Position=UDim2.fromOffset(94,24); title.Size=UDim2.new(1,-170,0,25); title.BackgroundTransparency=1
        title.RichText=true; title.Text='RITUAL <font color="rgb(120,190,255)">BACKGROUNDS</font>'; title.TextColor3=Color3.fromRGB(247,248,255); title.Font=Enum.Font.GothamBold
        title.TextSize=19; title.TextXAlignment=Enum.TextXAlignment.Left; title.ZIndex=104

        local closeBtn=Instance.new("TextButton",popup)
        closeBtn.AnchorPoint=Vector2.new(1,0); closeBtn.Position=UDim2.new(1,-20,0,19); closeBtn.Size=UDim2.fromOffset(38,38)
        closeBtn.BackgroundColor3=Color3.fromRGB(24,26,38); closeBtn.BackgroundTransparency=.62; closeBtn.BorderSizePixel=0
        closeBtn.Text="X"; closeBtn.TextColor3=Color3.fromRGB(211,215,231); closeBtn.Font=Enum.Font.GothamBold
        closeBtn.TextSize=12; closeBtn.ZIndex=110; guiCorner(closeBtn,11); local closeStroke=guiStroke(closeBtn,Color3.fromRGB(63,67,86),1)

        local headerDivider=Instance.new("Frame",popup)
        headerDivider.Position=UDim2.fromOffset(20,76); headerDivider.Size=UDim2.new(1,-40,0,1)
        headerDivider.BackgroundColor3=Color3.fromRGB(49,52,67); headerDivider.BackgroundTransparency=.28
        headerDivider.BorderSizePixel=0; headerDivider.ZIndex=103

        local previewPanel=Instance.new("Frame",popup)
        previewPanel.Position=UDim2.fromOffset(20,92); previewPanel.Size=UDim2.fromOffset(420,356)
        previewPanel.BackgroundColor3=Color3.fromRGB(11,12,19); previewPanel.BackgroundTransparency=.32
        previewPanel.BorderSizePixel=0; previewPanel.ZIndex=103; guiCorner(previewPanel,16)
        local previewStroke=guiStroke(previewPanel,Color3.fromRGB(52,55,72),1); previewStroke.Transparency=.2

        local hero=Instance.new("ImageLabel",previewPanel)
        hero.Position=UDim2.fromOffset(7,7); hero.Size=UDim2.new(1,-14,1,-80); hero.BackgroundColor3=Color3.fromRGB(5,6,10)
        hero.BackgroundTransparency=0; hero.BorderSizePixel=0; hero.Image=_GACC.backgroundImages[selectedIndex]
        hero.ScaleType=Enum.ScaleType.Fit; hero.ZIndex=104; guiCorner(hero,12)
        local heroStroke=guiStroke(hero,Color3.fromRGB(65,69,88),1); heroStroke.Transparency=.32
        local heroShade=Instance.new("Frame",hero)
        heroShade.Size=UDim2.new(1,0,0,90); heroShade.Position=UDim2.new(0,0,1,-90)
        heroShade.BackgroundColor3=Color3.fromRGB(4,5,9); heroShade.BackgroundTransparency=.18
        heroShade.BorderSizePixel=0; heroShade.ZIndex=105
        local heroShadeGrad=Instance.new("UIGradient",heroShade)
        heroShadeGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.55,.38),NumberSequenceKeypoint.new(1,0)})
        heroShadeGrad.Rotation=90

        local selectedTitle=Instance.new("TextLabel",previewPanel)
        selectedTitle.Position=UDim2.fromOffset(18,290); selectedTitle.Size=UDim2.fromOffset(170,20)
        selectedTitle.BackgroundTransparency=1; selectedTitle.TextColor3=Color3.fromRGB(241,243,252)
        selectedTitle.Font=Enum.Font.GothamBlack; selectedTitle.TextSize=12; selectedTitle.TextXAlignment=Enum.TextXAlignment.Left; selectedTitle.ZIndex=108
        local applyBtn=Instance.new("TextButton",previewPanel)
        applyBtn.AnchorPoint=Vector2.new(1,1); applyBtn.Position=UDim2.new(1,-12,1,-12); applyBtn.Size=UDim2.fromOffset(166,46)
        applyBtn.BackgroundColor3=_ACC.accentBg; applyBtn.BackgroundTransparency=.04; applyBtn.BorderSizePixel=0
        applyBtn.Text="APPLY BACKGROUND"; applyBtn.TextColor3=_ACC.accent; applyBtn.Font=Enum.Font.GothamBlack
        applyBtn.TextSize=10; applyBtn.AutoButtonColor=false; applyBtn.ZIndex=109; guiCorner(applyBtn,12)
        local applyStroke=guiStroke(applyBtn,_ACC.accentDark,1.2); applyStroke.Transparency=.08
        local applyScale=Instance.new("UIScale",applyBtn)

        local libraryPanel=Instance.new("Frame",popup)
        libraryPanel.Position=UDim2.fromOffset(454,92); libraryPanel.Size=UDim2.new(1,-474,1,-114)
        libraryPanel.BackgroundColor3=Color3.fromRGB(10,11,18); libraryPanel.BackgroundTransparency=.38
        libraryPanel.BorderSizePixel=0; libraryPanel.ZIndex=103; guiCorner(libraryPanel,16)
        local libraryStroke=guiStroke(libraryPanel,Color3.fromRGB(47,50,66),1); libraryStroke.Transparency=.28
        local libraryTitle=Instance.new("TextLabel",libraryPanel)
        libraryTitle.Position=UDim2.fromOffset(14,11); libraryTitle.Size=UDim2.new(1,-28,0,20)
        libraryTitle.BackgroundTransparency=1; libraryTitle.Text="IMAGE LIBRARY"; libraryTitle.TextColor3=Color3.fromRGB(220,223,237)
        libraryTitle.Font=Enum.Font.GothamBlack; libraryTitle.TextSize=10; libraryTitle.TextXAlignment=Enum.TextXAlignment.Left; libraryTitle.ZIndex=105
        local countBadge=Instance.new("TextLabel",libraryPanel)
        countBadge.AnchorPoint=Vector2.new(1,0); countBadge.Position=UDim2.new(1,-12,0,9); countBadge.Size=UDim2.fromOffset(28,22)
        countBadge.BackgroundColor3=_ACC.accentBg; countBadge.BackgroundTransparency=.12; countBadge.BorderSizePixel=0
        countBadge.Text=tostring(#_GACC.backgroundImages); countBadge.TextColor3=_ACC.accent; countBadge.Font=Enum.Font.GothamBlack
        countBadge.TextSize=9; countBadge.ZIndex=106; guiCorner(countBadge,7)

        local showcase=Instance.new("Frame",libraryPanel)
        showcase.Name="LiveShowcase";showcase.Position=UDim2.fromOffset(10,40);showcase.Size=UDim2.new(1,-20,0,146)
        showcase.BackgroundColor3=Color3.fromRGB(5,6,10);showcase.BackgroundTransparency=.34
        showcase.BorderSizePixel=0;showcase.ClipsDescendants=true;showcase.ZIndex=105;showcase.Visible=false;guiCorner(showcase,12)
        local showcaseStroke=guiStroke(showcase,Color3.fromRGB(76,82,104),1);showcaseStroke.Transparency=.38
        local showcaseBg=Instance.new("ImageLabel",showcase)
        showcaseBg.Size=UDim2.fromScale(1,1);showcaseBg.BackgroundTransparency=1
        showcaseBg.Image=_GACC.backgroundImages[selectedIndex];showcaseBg.ImageTransparency=.16
        showcaseBg.ScaleType=Enum.ScaleType.Crop;showcaseBg.ZIndex=105;guiCorner(showcaseBg,12)
        local glassShade=Instance.new("Frame",showcase)
        glassShade.Size=UDim2.fromScale(1,1);glassShade.BackgroundColor3=Color3.fromRGB(5,8,14)
        glassShade.BackgroundTransparency=.72;glassShade.BorderSizePixel=0;glassShade.ZIndex=106;guiCorner(glassShade,12)

        local mockGui=Instance.new("Frame",showcase)
        mockGui.AnchorPoint=Vector2.new(.5,.5);mockGui.Position=UDim2.fromScale(.5,.5);mockGui.Size=UDim2.new(1,-28,1,-20)
        mockGui.BackgroundColor3=Color3.fromRGB(8,10,17);mockGui.BackgroundTransparency=.42
        mockGui.BorderSizePixel=0;mockGui.ZIndex=107;guiCorner(mockGui,9)
        local mockStroke=guiStroke(mockGui,_ACC.accentDark,1);mockStroke.Transparency=.25
        local mockHeader=Instance.new("Frame",mockGui)
        mockHeader.Size=UDim2.new(1,0,0,27);mockHeader.BackgroundColor3=_ACC.accentBg
        mockHeader.BackgroundTransparency=.52;mockHeader.BorderSizePixel=0;mockHeader.ZIndex=108;guiCorner(mockHeader,9)
        local mockHeaderCover=Instance.new("Frame",mockHeader)
        mockHeaderCover.Position=UDim2.new(0,0,1,-8);mockHeaderCover.Size=UDim2.new(1,0,0,8)
        mockHeaderCover.BackgroundColor3=mockHeader.BackgroundColor3;mockHeaderCover.BackgroundTransparency=mockHeader.BackgroundTransparency
        mockHeaderCover.BorderSizePixel=0;mockHeaderCover.ZIndex=108
        local mockTitle=Instance.new("TextLabel",mockHeader)
        mockTitle.Position=UDim2.fromOffset(8,2);mockTitle.Size=UDim2.new(1,-38,0,20);mockTitle.BackgroundTransparency=1
        mockTitle.RichText=true;mockTitle.Text='RITUAL <font color="rgb(120,190,255)">HUB</font>'
        mockTitle.TextColor3=Color3.fromRGB(241,244,252);mockTitle.Font=Enum.Font.GothamBold
        mockTitle.TextSize=9;mockTitle.TextXAlignment=Enum.TextXAlignment.Left;mockTitle.ZIndex=109
        local mockAvatar=Instance.new("ImageLabel",mockHeader)
        mockAvatar.AnchorPoint=Vector2.new(1,.5);mockAvatar.Position=UDim2.new(1,-7,.5,0);mockAvatar.Size=UDim2.fromOffset(18,18)
        mockAvatar.BackgroundColor3=_ACC.accentBg;mockAvatar.BackgroundTransparency=.38;mockAvatar.BorderSizePixel=0
        mockAvatar.Image="";mockAvatar.ZIndex=109;guiCorner(mockAvatar,9)
        task.spawn(function()
            local ok,thumb=pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end)
            if ok and mockAvatar.Parent then mockAvatar.Image=thumb end
        end)
        local mockRail=Instance.new("Frame",mockGui)
        mockRail.Position=UDim2.fromOffset(6,33);mockRail.Size=UDim2.fromOffset(48,82)
        mockRail.BackgroundColor3=Color3.fromRGB(6,7,12);mockRail.BackgroundTransparency=.52
        mockRail.BorderSizePixel=0;mockRail.ZIndex=108;guiCorner(mockRail,7)
        for i,name in ipairs({"SPEED","COMBAT","MOVE","VISUAL"}) do
            local nav=Instance.new("TextLabel",mockRail)
            nav.Position=UDim2.fromOffset(4,4+(i-1)*19);nav.Size=UDim2.new(1,-8,0,15)
            nav.BackgroundColor3=i==1 and _ACC.accentBg or Color3.fromRGB(15,17,25)
            nav.BackgroundTransparency=i==1 and .28 or .62;nav.BorderSizePixel=0
            nav.Text=name;nav.TextColor3=i==1 and _ACC.accent or Color3.fromRGB(145,150,170)
            nav.Font=Enum.Font.GothamBold;nav.TextSize=5;nav.ZIndex=109;guiCorner(nav,4)
        end
        local mockContent=Instance.new("ScrollingFrame",mockGui)
        mockContent.Position=UDim2.fromOffset(60,33);mockContent.Size=UDim2.new(1,-66,1,-39)
        mockContent.BackgroundTransparency=1;mockContent.BorderSizePixel=0;mockContent.ScrollBarThickness=1
        mockContent.ScrollBarImageColor3=_ACC.accent;mockContent.CanvasSize=UDim2.fromOffset(0,145)
        mockContent.ScrollingEnabled=true;mockContent.Active=true;mockContent.ZIndex=108
        local mockLayout=Instance.new("UIListLayout",mockContent);mockLayout.Padding=UDim.new(0,4)
        for i,name in ipairs({"NORMAL SPEED","CARRY SPEED","LAGGER NORMAL","LAGGER CARRY","AUTO SWITCH","MOVEMENT MODE"}) do
            local row=Instance.new("Frame",mockContent)
            row.Size=UDim2.new(1,-3,0,19);row.BackgroundColor3=Color3.fromRGB(16,18,27)
            row.BackgroundTransparency=.48;row.BorderSizePixel=0;row.LayoutOrder=i;row.ZIndex=109;guiCorner(row,5)
            local rowText=Instance.new("TextLabel",row)
            rowText.Position=UDim2.fromOffset(6,0);rowText.Size=UDim2.new(1,-35,1,0);rowText.BackgroundTransparency=1
            rowText.Text=name;rowText.TextColor3=Color3.fromRGB(215,219,232);rowText.Font=Enum.Font.GothamMedium
            rowText.TextSize=5;rowText.TextXAlignment=Enum.TextXAlignment.Left;rowText.ZIndex=110
            local pill=Instance.new("Frame",row)
            pill.AnchorPoint=Vector2.new(1,.5);pill.Position=UDim2.new(1,-5,.5,0);pill.Size=UDim2.fromOffset(20,9)
            pill.BackgroundColor3=i%2==0 and _ACC.accentBg or Color3.fromRGB(38,41,53)
            pill.BackgroundTransparency=.24;pill.BorderSizePixel=0;pill.ZIndex=110;guiCorner(pill,5)
        end

        local browseLabel=Instance.new("TextLabel",libraryPanel)
        browseLabel.Position=UDim2.fromOffset(12,38);browseLabel.Size=UDim2.new(1,-24,0,16)
        browseLabel.BackgroundTransparency=1;browseLabel.Text="SCROLL TO PREVIEW STYLES"
        browseLabel.TextColor3=Color3.fromRGB(150,156,178);browseLabel.Font=Enum.Font.GothamBold
        browseLabel.TextSize=7;browseLabel.TextXAlignment=Enum.TextXAlignment.Left;browseLabel.ZIndex=106

        local gallery=Instance.new("ScrollingFrame",libraryPanel)
        gallery.Position=UDim2.fromOffset(10,58); gallery.Size=UDim2.new(1,-20,1,-68)
        gallery.BackgroundTransparency=1; gallery.BorderSizePixel=0; gallery.ScrollBarThickness=2
        gallery.ScrollBarImageColor3=_ACC.accent; gallery.CanvasSize=UDim2.fromOffset(0,0)
        gallery.AutomaticCanvasSize=Enum.AutomaticSize.Y; gallery.ZIndex=104
        local grid=Instance.new("UIGridLayout",gallery)
        grid.CellSize=UDim2.fromOffset(100,72); grid.CellPadding=UDim2.fromOffset(8,8)
        grid.HorizontalAlignment=Enum.HorizontalAlignment.Center; grid.SortOrder=Enum.SortOrder.LayoutOrder
        local galleryPad=Instance.new("UIPadding",gallery)
        galleryPad.PaddingTop=UDim.new(0,2); galleryPad.PaddingBottom=UDim.new(0,8)

        local function refreshSelection()
            selectedIndex=math.clamp(selectedIndex,1,#_GACC.backgroundImages)
            hero.Image=_GACC.backgroundImages[selectedIndex]
            showcaseBg.Image=_GACC.backgroundImages[selectedIndex]
            if externalShowcaseBg then externalShowcaseBg.Image=_GACC.backgroundImages[selectedIndex] end
            selectedTitle.Text=string.format("IMAGE %02d",selectedIndex)
            local active=selectedIndex==backgroundIndex
            applyBtn.Text=active and "CURRENTLY ACTIVE" or "APPLY BACKGROUND"
            applyBtn.BackgroundColor3=active and Color3.fromRGB(22,30,27) or _ACC.accentBg
            applyBtn.TextColor3=active and Color3.fromRGB(132,230,168) or _ACC.accent
            applyStroke.Color=active and Color3.fromRGB(72,155,101) or _ACC.accentDark
            for index,ref in ipairs(cardRefs) do
                local selected=index==selectedIndex
                local current=index==backgroundIndex
                ref.stroke.Color=selected and _ACC.accent or (current and Color3.fromRGB(84,180,116) or Color3.fromRGB(48,51,66))
                ref.stroke.Thickness=selected and 2.2 or 1
                ref.stroke.Transparency=selected and .02 or .25
                ref.badge.Text=current and "ON" or string.format("%02d",index)
                ref.badge.BackgroundColor3=current and Color3.fromRGB(32,72,47) or Color3.fromRGB(10,11,17)
                ref.badge.TextColor3=current and Color3.fromRGB(151,235,178) or Color3.fromRGB(197,201,218)
            end
        end

        local function closeGallery()
            if closing then return end
            closing=true
            if responsiveConn then responsiveConn:Disconnect(); responsiveConn=nil end
            TweenService:Create(blur,TweenInfo.new(.22),{Size=0}):Play()
            TweenService:Create(overlay,TweenInfo.new(.24),{BackgroundTransparency=1}):Play()
            TweenService:Create(popup,TweenInfo.new(.26,Enum.EasingStyle.Back,Enum.EasingDirection.In),{GroupTransparency=1,Rotation=3}):Play()
            TweenService:Create(popupScale,TweenInfo.new(.26,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Scale=targetScale*.8}):Play()
            TweenService:Create(showcasePanel,TweenInfo.new(.24,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{GroupTransparency=1}):Play()
            TweenService:Create(showcaseScale,TweenInfo.new(.26,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Scale=targetScale*.8}):Play()
            task.delay(.28,function()
                if blur then blur:Destroy() end
                if modalGui then modalGui:Destroy() end
            end)
        end

        for index,asset in ipairs(_GACC.backgroundImages) do
            local card=Instance.new("ImageButton",gallery)
            card.Name="Background"..index; card.LayoutOrder=index; card.BackgroundColor3=Color3.fromRGB(12,13,20)
            card.BackgroundTransparency=1; card.BorderSizePixel=0; card.Image=asset; card.ImageTransparency=1
            card.ScaleType=Enum.ScaleType.Fit; card.AutoButtonColor=false; card.ZIndex=105; guiCorner(card,11)
            local cardStroke=guiStroke(card,Color3.fromRGB(48,51,66),1); cardStroke.Transparency=1
            local cardScale=Instance.new("UIScale",card); cardScale.Scale=.82
            local cardShade=Instance.new("Frame",card)
            cardShade.Size=UDim2.new(1,0,0,28); cardShade.Position=UDim2.new(0,0,1,-28)
            cardShade.BackgroundColor3=Color3.fromRGB(5,6,10); cardShade.BackgroundTransparency=.12
            cardShade.BorderSizePixel=0; cardShade.ZIndex=106; guiCorner(cardShade,10)
            local cover=Instance.new("Frame",cardShade)
            cover.Size=UDim2.new(1,0,0,10); cover.BackgroundColor3=cardShade.BackgroundColor3
            cover.BackgroundTransparency=cardShade.BackgroundTransparency; cover.BorderSizePixel=0; cover.ZIndex=106
            local badge=Instance.new("TextLabel",cardShade)
            badge.AnchorPoint=Vector2.new(1,.5); badge.Position=UDim2.new(1,-6,.5,0); badge.Size=UDim2.fromOffset(34,18)
            badge.BackgroundColor3=Color3.fromRGB(10,11,17); badge.BorderSizePixel=0; badge.Text=string.format("%02d",index)
            badge.TextColor3=Color3.fromRGB(197,201,218); badge.Font=Enum.Font.GothamBlack; badge.TextSize=8; badge.ZIndex=108; guiCorner(badge,6)
            local miniTitle=Instance.new("TextLabel",cardShade)
            miniTitle.Position=UDim2.fromOffset(7,5); miniTitle.Size=UDim2.new(1,-48,0,18); miniTitle.BackgroundTransparency=1
            miniTitle.Text="STYLE"; miniTitle.TextColor3=Color3.fromRGB(225,228,240); miniTitle.Font=Enum.Font.GothamBold
            miniTitle.TextSize=8; miniTitle.TextXAlignment=Enum.TextXAlignment.Left; miniTitle.ZIndex=108
            cardRefs[index]={stroke=cardStroke,badge=badge,scale=cardScale,card=card}
            card.MouseEnter:Connect(function()
                TweenService:Create(cardScale,TweenInfo.new(.16,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1.035}):Play()
                cardStroke.Color=_ACC.accentDark; cardStroke.Transparency=.02
            end)
            card.MouseLeave:Connect(function()
                TweenService:Create(cardScale,TweenInfo.new(.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1}):Play()
                refreshSelection()
            end)
            card.MouseButton1Click:Connect(function()
                selectedIndex=index; refreshSelection()
                hero.ImageTransparency=.3
                TweenService:Create(hero,TweenInfo.new(.22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{ImageTransparency=0}):Play()
                showcaseBg.ImageTransparency=.48
                TweenService:Create(showcaseBg,TweenInfo.new(.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{ImageTransparency=.16}):Play()
                if externalShowcaseBg then
                    externalShowcaseBg.ImageTransparency=.48
                    TweenService:Create(externalShowcaseBg,TweenInfo.new(.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{ImageTransparency=.18}):Play()
                end
                showcaseClone.Size=UDim2.new(.96,0,.96,0);showcaseClone.Position=UDim2.new(.02,0,.02,0)
                TweenService:Create(showcaseClone,TweenInfo.new(.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromScale(1,1),Position=UDim2.fromOffset(0,0)}):Play()
            end)
            task.delay(.16+index*.045,function()
                if not card.Parent then return end
                TweenService:Create(card,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{BackgroundTransparency=.03,ImageTransparency=0}):Play()
                TweenService:Create(cardStroke,TweenInfo.new(.3),{Transparency=index==selectedIndex and .02 or .25}):Play()
                TweenService:Create(cardScale,TweenInfo.new(.34,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
            end)
        end

        applyBtn.MouseEnter:Connect(function()
            TweenService:Create(applyScale,TweenInfo.new(.15,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1.025}):Play()
            TweenService:Create(applyBtn,TweenInfo.new(.15),{BackgroundTransparency=0}):Play()
        end)
        applyBtn.MouseLeave:Connect(function()
            TweenService:Create(applyScale,TweenInfo.new(.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1}):Play()
            TweenService:Create(applyBtn,TweenInfo.new(.18),{BackgroundTransparency=.04}):Play()
        end)
        applyBtn.MouseButton1Click:Connect(function()
            if selectedIndex==backgroundIndex then return end
            backgroundIndex=selectedIndex; backgroundEnabled=true; applyBackgroundImage(); saveConfig(); refreshSelection()
            applyScale.Scale=.94
            TweenService:Create(applyScale,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
            previewStroke.Color=Color3.fromRGB(98,205,133); previewStroke.Transparency=0
            TweenService:Create(previewStroke,TweenInfo.new(.55),{Color=Color3.fromRGB(52,55,72),Transparency=.2}):Play()
        end)

        closeBtn.MouseEnter:Connect(function()
            TweenService:Create(closeBtn,TweenInfo.new(.15),{BackgroundColor3=Color3.fromRGB(53,31,39),TextColor3=Color3.fromRGB(255,190,204)}):Play()
            closeStroke.Color=Color3.fromRGB(135,69,83)
        end)
        closeBtn.MouseLeave:Connect(function()
            TweenService:Create(closeBtn,TweenInfo.new(.18),{BackgroundColor3=Color3.fromRGB(24,26,38),TextColor3=Color3.fromRGB(211,215,231)}):Play()
            closeStroke.Color=Color3.fromRGB(63,67,86)
        end)
        closeBtn.MouseButton1Click:Connect(closeGallery)
        overlay.MouseButton1Click:Connect(closeGallery)
        popup.InputBegan:Connect(function() end)

        refreshSelection()
        TweenService:Create(blur,TweenInfo.new(.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=14}):Play()
        TweenService:Create(overlay,TweenInfo.new(.28),{BackgroundTransparency=.32}):Play()
        TweenService:Create(popup,TweenInfo.new(.44,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{GroupTransparency=0,Rotation=0}):Play()
        TweenService:Create(popupScale,TweenInfo.new(.44,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=targetScale}):Play()
        TweenService:Create(showcasePanel,TweenInfo.new(.46,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{GroupTransparency=0}):Play()
        TweenService:Create(showcaseScale,TweenInfo.new(.44,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=targetScale}):Play()
        task.spawn(function()
            local rotation=8
            while popup and popup.Parent do
                rotation=(rotation+.7)%360; topGlowGrad.Rotation=rotation; task.wait(.04)
            end
        end)
    end,1)
    end)(CategoryRefs.contents["Visual"])

    -- Add Scale rows in Settings
    local settingsPage = CategoryRefs.contents["Settings"]
    local scaleSection = mkSection(settingsPage, "UI SCALING", 2)
    addScaleRow(scaleSection, "Menu Scale", function() return menuScale end, function(v) menuScale=v; if _GACC.menuScaleObj then _GACC.menuScaleObj.Scale=v end end, 1)
    addScaleRow(scaleSection, "Mobile Btn Scale", function() return mobileBtnScale end, function(v) mobileBtnScale=v; if _GACC.mobileScaleObj then _GACC.mobileScaleObj.Scale=v end end, 2)
    addScaleRow(scaleSection, "Steal Bar Scale", function() return stealBarScale end, function(v) stealBarScale=v; if _GACC.stealBarScaleObj then _GACC.stealBarScaleObj.Scale=v end end, 3)

    do local b=mkSection(settingsPage, "LOCK", 3)
    addToggleRow(b,"Lock Mobile Buttons",mobileButtonsLocked,1,nil,function(on)
        mobileButtonsLocked=on
        saveConfig()
    end)
    addToggleRow(b,"Lock UI",uiLocked,2,nil,function(on)
        uiLocked=on
        saveConfig()
    end)
    end

    do
    local kbPage=CategoryRefs.contents["Keybinds"]
    local kbBody=mkSection(kbPage,"BINDS",0)
    addKeybindRow(kbBody,"Hide GUI",             "guiHide",     1)
    addKeybindRow(kbBody,"Speed Toggle",         "speed",       2)
    addKeybindRow(kbBody,"Carry Mode",           "carryMode",   3)
    addKeybindRow(kbBody,"Lagger Mode",          "laggerToggle",4)
    addKeybindRow(kbBody,"Bat Aimbot",           "circle",      5)
    addKeybindRow(kbBody,"Bat Desync TP",        "batDesyncTp", 6)
    addKeybindRow(kbBody,"Auto Left",            "autoLeft",    7)
    addKeybindRow(kbBody,"Auto Right",           "autoRight",   8)
    addKeybindRow(kbBody,"Drop Brainrot",        "dropBrainrot",9)
    addKeybindRow(kbBody,"TP Down",              "tpDown",      10)
    addKeybindRow(kbBody,"Instant Reset",        "instantReset",11)
    end

    UIS.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if UIS:GetFocusedTextBox() then return end
        if inp.KeyCode==Keys.guiHide then if GuiRefs.outer then GuiRefs.outer.Visible=not GuiRefs.outer.Visible end
        elseif inp.KeyCode==Keys.speed then toggleCarryMode(); saveConfig()
        elseif inp.KeyCode==Keys.carryMode then toggleCarryMode(); saveConfig()
        elseif inp.KeyCode==Keys.laggerToggle then toggleLaggerMode(); saveConfig()
        elseif inp.KeyCode==Keys.circle then
            autoBatEnabled=not autoBatEnabled
            if autoBatEnabled then
                _GACC.exclusiveStop("batAimbot")
                autoBatEnabled=true
                startBatAimbot()
            else stopBatAimbot() end
            if autoBatSetVisual then autoBatSetVisual(autoBatEnabled) end
            if mobBtnRefs.autoBat then mobBtnRefs.autoBat(autoBatEnabled) end
            saveConfig()
        elseif inp.KeyCode==Keys.batDesyncTp then
            batDesyncTpEnabled=not batDesyncTpEnabled
            if batDesyncTpEnabled then
                _GACC.exclusiveStop("batTp")
                batDesyncTpEnabled=true
                startBatDesyncTp()
            else stopBatDesyncTp() end
            if batDesyncTpSetVisual then batDesyncTpSetVisual(batDesyncTpEnabled) end
            saveConfig()
        elseif inp.KeyCode==Keys.dropBrainrot then runDrop()
        elseif inp.KeyCode==Keys.tpDown then runTPFloor()
        elseif inp.KeyCode==Keys.instantReset then instantReset()
        elseif inp.KeyCode==Keys.autoLeft then
            if autoLeftEnabled then
                autoLeftEnabled=false; stopAutoLeft()
            else
                _GACC.exclusiveStop("autoLeft")
                autoLeftEnabled=true; startAutoLeft()
            end
            if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
            if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(autoLeftEnabled) end
        elseif inp.KeyCode==Keys.autoRight then
            if autoRightEnabled then
                autoRightEnabled=false; stopAutoRight()
            else
                _GACC.exclusiveStop("autoRight")
                autoRightEnabled=true; startAutoRight()
            end
            if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
            if mobBtnRefs.autoRight then mobBtnRefs.autoRight(autoRightEnabled) end
        end
    end)
    end) 

    for _,object in ipairs(GuiHub:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
            object.Font=object.TextSize>=16 and Enum.Font.GothamBold or Enum.Font.GothamMedium
        end
    end
    task.defer(function() if applyColorTheme then applyColorTheme(currentColorTheme) end end)
    
end)()

local function onCharacterAdded(char)
    task.wait(0.5)
    if medusaCounterEnabled then setupMedusa(char) end
    if unwalkEnabled then task.wait(0.5); startUnwalk() end
    if refreshSpeedModeLabel then refreshSpeedModeLabel() end
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    _GACC.extras.onCharacter(char)
    if _GACC.medusaResetEnabled then _GACC.startMedusaReset(char) end
    -- Anti Die is handled by its own CharacterAdded connection inside startAntiDie
end

LP.CharacterAdded:Connect(onCharacterAdded)
if LP.Character then onCharacterAdded(LP.Character) end

if infJumpEnabled then startHoldInfJump() end
if antiRagdollEnabled then startAntiRagdoll() end
if _GACC.batCounterEnabled then _GACC.startBatCounter() end
if medusaCounterEnabled then setupMedusa(LP.Character) end
pcall(applyBackgroundImage)
if _GACC.playerHighlightEnabled then pcall(_GACC.startESP) end
pcall(function() CandyApplyCustomSky(currentSkyTheme) end)
__RitualBootClear()

-- Apply initial scales
if _GACC.menuScaleObj then _GACC.menuScaleObj.Scale = menuScale end
if _GACC.mobileScaleObj then _GACC.mobileScaleObj.Scale = mobileBtnScale end
if _GACC.stealBarScaleObj then _GACC.stealBarScaleObj.Scale = stealBarScale end

-- Start Anti Die if enabled (already handled in pcall above, but ensure it's on)
if antiDieEnabled then
    task.spawn(function()
        task.wait(1.5)  -- wait a bit for character to load
        startAntiDie()
    end)
end

-- Final GUI recovery: if an executor/game event hid the menu during startup,
-- restore it without touching any feature state.

-- Final speed-state watchdog: remove stale movement constraints whenever the
-- authoritative mode changes, including after manual Carry/Lagger toggles.
do
    local lastObservedSpeedMode = speedMode
    RunService.Heartbeat:Connect(function()
        local mode = syncSpeedMode()
        if mode ~= lastObservedSpeedMode then
            lastObservedSpeedMode = mode
            local char=LP.Character
            local root=char and char:FindFirstChild("HumanoidRootPart")
            if root then
                pcall(function()
                    local lv=root:FindFirstChild("_RHSpeedLV")
                    if lv then lv:Destroy() end
                    local v=root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity=Vector3.new(0,v.Y,0)
                end)
            end
        end
    end)
end

task.defer(function()
    pcall(function()
        local pg = LP and LP:FindFirstChild("PlayerGui")
        local gui = pg and pg:FindFirstChild("RitualHub")
        if not gui then gui = game:GetService("CoreGui"):FindFirstChild("RitualHub") end
        if gui then
            gui.Enabled = true
            local outer = gui:FindFirstChild("Outer", true)
            if outer and outer:IsA("GuiObject") then
                outer.Visible = true
                local pos = outer.Position
                if pos.X.Offset < -500 or pos.X.Offset > 3000 or pos.Y.Offset < -500 or pos.Y.Offset > 3000 then
                    outer.Position = UDim2.new(0,20,0,80)
                end
            end
        end
    end)
end)
