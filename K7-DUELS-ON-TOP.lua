-- K7 Duels | Mobile + PC (UNC / Synapse / Fluxus / Solara / Delta / Wave / etc.)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local player = Players.LocalPlayer
-- Prevent double-inject (stacked Heartbeats caused random physics deaths / respawns)
if getgenv then
    if getgenv()._K7DuelsRunning then
        return
    end
    getgenv()._K7DuelsRunning = true
end

-- Load persisted intro preference from session (disk load happens later in loadConfigKeys)
pcall(function()
    if getgenv and type(getgenv()._K7DuelsCfg)=="table" and getgenv()._K7DuelsCfg.introEnabled ~= nil then
        -- will be applied again after disk load; session hint only
    end
end)

-- ============================
-- EXECUTOR COMPAT (PC + Mobile)
-- ============================
local function _resolve(name)
    local g = rawget(_G, name) or (getgenv and getgenv()[name])
    if typeof(g)=="function" then return g end
    if syn and typeof(syn[name])=="function" then return syn[name] end
    if fluxus and typeof(fluxus[name])=="function" then return fluxus[name] end
    return nil
end

local _gethui = _resolve("gethui") or (typeof(gethui)=="function" and gethui) or nil
local _getcustomasset = _resolve("getcustomasset") or (typeof(getcustomasset)=="function" and getcustomasset) or nil
local _request = _resolve("request")
    or _resolve("http_request")
    or (syn and syn.request)
    or (http and (http.request or http.Request))
    or (fluxus and fluxus.request)
    or (typeof(request)=="function" and request)
    or (typeof(http_request)=="function" and http_request)
    or nil

local function protectGui(gui)
    if not gui then return end
    pcall(function()
        if typeof(protect_gui)=="function" then protect_gui(gui)
        elseif syn and syn.protect_gui then syn.protect_gui(gui)
        elseif typeof(hide_in_gcoregui)=="function" then hide_in_gcoregui(gui)
        end
    end)
end

local function parentGui(gui)
    if not gui then return end
    protectGui(gui)
    local ok = false
    if _gethui then
        ok = pcall(function() gui.Parent = _gethui() end)
    end
    if not ok or not gui.Parent then
        ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
    end
    if not gui.Parent then
        pcall(function()
            local plr = Players.LocalPlayer
            if plr then gui.Parent = plr:WaitForChild("PlayerGui") end
        end)
    end
end

-- File API polyfills (Synapse / Fluxus / Delta / UNC / Solara / Wave)
local _isfile = (typeof(isfile)=="function" and isfile)
    or (syn and syn.isfile)
    or (fluxus and fluxus.isfile)
    or (getgenv and getgenv().isfile)
    or function(p)
        local ok, data = pcall(function() return readfile(p) end)
        return ok and data ~= nil
    end
local _readfile = (typeof(readfile)=="function" and readfile)
    or (syn and syn.readfile)
    or (fluxus and fluxus.readfile)
    or (getgenv and getgenv().readfile)
    or function() return nil end
local _writefile = (typeof(writefile)=="function" and writefile)
    or (syn and syn.writefile)
    or (fluxus and fluxus.writefile)
    or (getgenv and getgenv().writefile)
    or function() end
isfile, readfile, writefile = _isfile, _readfile, _writefile

-- Unified HTTP get (binary-safe when request exists)
local function k7HttpGet(url)
    if _request then
        local ok, res = pcall(function()
            return _request({
                Url = url,
                Method = "GET",
                Headers = { ["User-Agent"] = "Mozilla/5.0" },
            })
        end)
        if ok and type(res)=="table" then
            return res.Body or res.body or res.Data or res.data
        elseif ok and type(res)=="string" then
            return res
        end
    end
    local ok2, body = pcall(function() return game:HttpGet(url) end)
    if ok2 then return body end
    return nil
end

local function k7GetCustomAsset(path)
    if not path then return nil end
    local asset = nil
    pcall(function()
        if _getcustomasset then asset = _getcustomasset(path) end
    end)
    if asset and asset ~= "" then return asset end
    pcall(function()
        if syn and syn.getcustomasset then asset = syn.getcustomasset(path) end
    end)
    if asset and asset ~= "" then return asset end
    pcall(function()
        if getcustomasset then asset = getcustomasset(path, true) end
    end)
    if asset and asset ~= "" then return asset end
    return nil
end

-- getconnections polyfill
getconnections = getconnections or get_signal_cons or getconnects
    or (syn and syn.get_signal_cons) or (getgenv and getgenv().getconnections)


-- ============================================================
-- K7 HUB LOGO (rbxassetid only â€” no embedded image)
-- ============================================================
local K7_LOGO_RBX = "rbxassetid://135382218880707"
local _k7LogoAsset = K7_LOGO_RBX
local function getK7LogoAsset()
    return K7_LOGO_RBX
end



local function destroyOldGui(name)
    if not name then return end
    pcall(function()
        if _gethui then
            local h = _gethui(); local o = h and h:FindFirstChild(name); if o then o:Destroy() end
        end
    end)
    pcall(function()
        local cg = game:GetService("CoreGui"); local o = cg:FindFirstChild(name); if o then o:Destroy() end
    end)
    pcall(function()
        local plr = Players.LocalPlayer
        if plr then
            local pg = plr:FindFirstChild("PlayerGui")
            if pg then local o = pg:FindFirstChild(name); if o then o:Destroy() end end
        end
    end)
end




-- ============================================================
-- SKY THEME SYSTEM
-- ============================================================
local K7_SKY_TAG = "K7SkyTheme"
local currentSkyTheme = "Night"
local K7_SKY_PRESETS = {
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
local function k7SkyColor(rgb) return Color3.fromRGB(rgb[1],rgb[2],rgb[3]) end
local function K7ApplyCustomSky(mode)
    for _,child in ipairs(Lighting:GetChildren()) do if child:GetAttribute(K7_SKY_TAG) then pcall(function() child:Destroy() end) end end
    local terrain=workspace:FindFirstChildOfClass("Terrain")
    if terrain then for _,child in ipairs(terrain:GetChildren()) do if child:GetAttribute(K7_SKY_TAG) then pcall(function() child:Destroy() end) end end end
    local preset=K7_SKY_PRESETS[mode]
    if not preset or preset.kind=="off" then Lighting.ClockTime=14;Lighting.Brightness=2;Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127);Lighting.Ambient=Color3.fromRGB(127,127,127);Lighting.FogEnd=100000;Lighting.GlobalShadows=true;return end
    Lighting.FogStart=0;Lighting.FogEnd=100000;Lighting.FogColor=Color3.fromRGB(200,200,200);Lighting.ColorShift_Top=Color3.fromRGB(0,0,0);Lighting.ColorShift_Bottom=Color3.fromRGB(0,0,0);Lighting.GlobalShadows=true
    Lighting.ClockTime=preset.clock or 14;Lighting.Brightness=preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient=k7SkyColor(preset.outAmb) end
    if preset.ambient then Lighting.Ambient=k7SkyColor(preset.ambient) end
    if preset.sky then
        local skyInst=Instance.new("Sky");skyInst:SetAttribute(K7_SKY_TAG,true)
        if preset.sky.stars then skyInst.StarCount=preset.sky.stars end
        if preset.sky.moon then skyInst.MoonAngularSize=preset.sky.moon end
        if preset.sky.sun then skyInst.SunAngularSize=preset.sky.sun end
        if preset.sky.moonTex then skyInst.MoonTextureId="rbxasset://sky/moon.jpg" end
        skyInst.Parent=Lighting
    end
    if preset.atm then
        local atm=Instance.new("Atmosphere");atm:SetAttribute(K7_SKY_TAG,true)
        atm.Density=preset.atm.dens or 0.3;atm.Color=k7SkyColor(preset.atm.color);atm.Decay=k7SkyColor(preset.atm.decay);atm.Glare=preset.atm.glare or 1;atm.Haze=preset.atm.haze or 1;atm.Parent=Lighting
    end
    if preset.clouds and terrain then
        local clouds=Instance.new("Clouds");clouds:SetAttribute(K7_SKY_TAG,true)
        clouds.Cover=preset.clouds.cover or 0.5;clouds.Density=preset.clouds.dens or 0.5;clouds.Color=k7SkyColor(preset.clouds.color);clouds.Parent=terrain
    end
end

-- ============================================================
-- GUI THEME SYSTEM (refined / clean)
-- ============================================================
currentGuiTheme = "Obsidian"
GUI_THEME_ORDER = {"Obsidian","Snow","Azure","Jade","Crimson","Violet","Amber","Slate"}
GUI_THEMES = {
    ["Obsidian"] = {
        BG=Color3.fromRGB(8,8,10), BG2=Color3.fromRGB(14,14,16), ROW_BG=Color3.fromRGB(16,16,18),
        ROW_BORDER=Color3.fromRGB(32,32,36), WHITE=Color3.fromRGB(235,235,240), GRAY=Color3.fromRGB(120,120,130),
        INP=Color3.fromRGB(12,12,14), ACCENT=Color3.fromRGB(255,255,255), ACCENT2=Color3.fromRGB(200,200,210),
        ACCENT3=Color3.fromRGB(36,36,40), OFF=Color3.fromRGB(24,24,28), SECT=Color3.fromRGB(100,100,110),
        MOB_ON=Color3.fromRGB(255,255,255), MOB_OFF=Color3.fromRGB(16,16,18), MOB_BORDER_OFF=Color3.fromRGB(40,40,44),
        MOB_TEXT_OFF=Color3.fromRGB(160,160,170), MOB_TEXT_ON=Color3.fromRGB(10,10,12),
        STEAL_BG=Color3.fromRGB(10,10,12), STEAL_FILL=Color3.fromRGB(235,235,240), STEAL_ACCENT=Color3.fromRGB(255,255,255),
        PARTICLE=Color3.fromRGB(200,200,210),
    },
    ["Snow"] = {
        BG=Color3.fromRGB(18,18,20), BG2=Color3.fromRGB(24,24,28), ROW_BG=Color3.fromRGB(28,28,32),
        ROW_BORDER=Color3.fromRGB(48,48,54), WHITE=Color3.fromRGB(245,245,250), GRAY=Color3.fromRGB(140,140,150),
        INP=Color3.fromRGB(20,20,24), ACCENT=Color3.fromRGB(230,230,240), ACCENT2=Color3.fromRGB(190,190,200),
        ACCENT3=Color3.fromRGB(44,44,50), OFF=Color3.fromRGB(34,34,38), SECT=Color3.fromRGB(130,130,140),
        MOB_ON=Color3.fromRGB(230,230,240), MOB_OFF=Color3.fromRGB(28,28,32), MOB_BORDER_OFF=Color3.fromRGB(50,50,56),
        MOB_TEXT_OFF=Color3.fromRGB(170,170,180), MOB_TEXT_ON=Color3.fromRGB(16,16,18),
        STEAL_BG=Color3.fromRGB(20,20,22), STEAL_FILL=Color3.fromRGB(220,220,230), STEAL_ACCENT=Color3.fromRGB(230,230,240),
        PARTICLE=Color3.fromRGB(210,210,220),
    },
    ["Azure"] = {
        BG=Color3.fromRGB(8,10,14), BG2=Color3.fromRGB(12,16,22), ROW_BG=Color3.fromRGB(14,18,26),
        ROW_BORDER=Color3.fromRGB(28,40,58), WHITE=Color3.fromRGB(220,230,245), GRAY=Color3.fromRGB(110,130,155),
        INP=Color3.fromRGB(10,14,20), ACCENT=Color3.fromRGB(90,160,220), ACCENT2=Color3.fromRGB(70,130,180),
        ACCENT3=Color3.fromRGB(24,40,60), OFF=Color3.fromRGB(18,24,34), SECT=Color3.fromRGB(100,140,180),
        MOB_ON=Color3.fromRGB(90,160,220), MOB_OFF=Color3.fromRGB(14,18,26), MOB_BORDER_OFF=Color3.fromRGB(30,44,64),
        MOB_TEXT_OFF=Color3.fromRGB(140,170,200), MOB_TEXT_ON=Color3.fromRGB(6,14,22),
        STEAL_BG=Color3.fromRGB(10,14,20), STEAL_FILL=Color3.fromRGB(80,150,210), STEAL_ACCENT=Color3.fromRGB(90,160,220),
        PARTICLE=Color3.fromRGB(90,150,210),
    },
    ["Jade"] = {
        BG=Color3.fromRGB(8,12,10), BG2=Color3.fromRGB(12,18,14), ROW_BG=Color3.fromRGB(14,22,18),
        ROW_BORDER=Color3.fromRGB(28,48,36), WHITE=Color3.fromRGB(220,240,230), GRAY=Color3.fromRGB(110,145,125),
        INP=Color3.fromRGB(10,16,12), ACCENT=Color3.fromRGB(80,190,140), ACCENT2=Color3.fromRGB(60,150,110),
        ACCENT3=Color3.fromRGB(24,48,34), OFF=Color3.fromRGB(18,28,22), SECT=Color3.fromRGB(100,160,130),
        MOB_ON=Color3.fromRGB(80,190,140), MOB_OFF=Color3.fromRGB(14,22,18), MOB_BORDER_OFF=Color3.fromRGB(32,52,40),
        MOB_TEXT_OFF=Color3.fromRGB(140,180,155), MOB_TEXT_ON=Color3.fromRGB(6,18,12),
        STEAL_BG=Color3.fromRGB(10,16,12), STEAL_FILL=Color3.fromRGB(70,180,130), STEAL_ACCENT=Color3.fromRGB(80,190,140),
        PARTICLE=Color3.fromRGB(90,180,140),
    },
    ["Crimson"] = {
        BG=Color3.fromRGB(12,8,8), BG2=Color3.fromRGB(18,12,12), ROW_BG=Color3.fromRGB(22,14,14),
        ROW_BORDER=Color3.fromRGB(48,28,28), WHITE=Color3.fromRGB(245,230,230), GRAY=Color3.fromRGB(150,120,120),
        INP=Color3.fromRGB(16,10,10), ACCENT=Color3.fromRGB(220,70,70), ACCENT2=Color3.fromRGB(180,55,55),
        ACCENT3=Color3.fromRGB(48,24,24), OFF=Color3.fromRGB(28,18,18), SECT=Color3.fromRGB(170,110,110),
        MOB_ON=Color3.fromRGB(220,70,70), MOB_OFF=Color3.fromRGB(22,14,14), MOB_BORDER_OFF=Color3.fromRGB(52,30,30),
        MOB_TEXT_OFF=Color3.fromRGB(185,140,140), MOB_TEXT_ON=Color3.fromRGB(20,6,6),
        STEAL_BG=Color3.fromRGB(14,10,10), STEAL_FILL=Color3.fromRGB(200,60,60), STEAL_ACCENT=Color3.fromRGB(220,70,70),
        PARTICLE=Color3.fromRGB(210,80,80),
    },
    ["Violet"] = {
        BG=Color3.fromRGB(10,8,14), BG2=Color3.fromRGB(16,12,22), ROW_BG=Color3.fromRGB(20,16,28),
        ROW_BORDER=Color3.fromRGB(42,34,58), WHITE=Color3.fromRGB(235,230,245), GRAY=Color3.fromRGB(135,125,160),
        INP=Color3.fromRGB(14,10,18), ACCENT=Color3.fromRGB(150,110,220), ACCENT2=Color3.fromRGB(120,85,180),
        ACCENT3=Color3.fromRGB(36,28,52), OFF=Color3.fromRGB(24,20,34), SECT=Color3.fromRGB(140,120,180),
        MOB_ON=Color3.fromRGB(150,110,220), MOB_OFF=Color3.fromRGB(20,16,28), MOB_BORDER_OFF=Color3.fromRGB(46,36,62),
        MOB_TEXT_OFF=Color3.fromRGB(165,150,190), MOB_TEXT_ON=Color3.fromRGB(14,8,22),
        STEAL_BG=Color3.fromRGB(12,10,16), STEAL_FILL=Color3.fromRGB(140,100,210), STEAL_ACCENT=Color3.fromRGB(150,110,220),
        PARTICLE=Color3.fromRGB(150,115,210),
    },
    ["Amber"] = {
        BG=Color3.fromRGB(12,10,8), BG2=Color3.fromRGB(18,16,12), ROW_BG=Color3.fromRGB(24,20,14),
        ROW_BORDER=Color3.fromRGB(52,44,28), WHITE=Color3.fromRGB(245,240,225), GRAY=Color3.fromRGB(155,140,110),
        INP=Color3.fromRGB(16,14,10), ACCENT=Color3.fromRGB(230,180,70), ACCENT2=Color3.fromRGB(190,145,50),
        ACCENT3=Color3.fromRGB(48,40,22), OFF=Color3.fromRGB(28,24,16), SECT=Color3.fromRGB(170,150,100),
        MOB_ON=Color3.fromRGB(230,180,70), MOB_OFF=Color3.fromRGB(24,20,14), MOB_BORDER_OFF=Color3.fromRGB(54,46,30),
        MOB_TEXT_OFF=Color3.fromRGB(185,170,130), MOB_TEXT_ON=Color3.fromRGB(18,14,4),
        STEAL_BG=Color3.fromRGB(14,12,8), STEAL_FILL=Color3.fromRGB(210,165,60), STEAL_ACCENT=Color3.fromRGB(230,180,70),
        PARTICLE=Color3.fromRGB(220,175,80),
    },
    ["Slate"] = {
        BG=Color3.fromRGB(10,11,13), BG2=Color3.fromRGB(16,17,20), ROW_BG=Color3.fromRGB(20,22,26),
        ROW_BORDER=Color3.fromRGB(38,42,48), WHITE=Color3.fromRGB(225,230,235), GRAY=Color3.fromRGB(125,135,145),
        INP=Color3.fromRGB(14,15,18), ACCENT=Color3.fromRGB(140,155,175), ACCENT2=Color3.fromRGB(110,125,145),
        ACCENT3=Color3.fromRGB(32,36,42), OFF=Color3.fromRGB(24,26,30), SECT=Color3.fromRGB(130,140,155),
        MOB_ON=Color3.fromRGB(140,155,175), MOB_OFF=Color3.fromRGB(20,22,26), MOB_BORDER_OFF=Color3.fromRGB(42,46,54),
        MOB_TEXT_OFF=Color3.fromRGB(155,165,180), MOB_TEXT_ON=Color3.fromRGB(10,12,14),
        STEAL_BG=Color3.fromRGB(12,13,15), STEAL_FILL=Color3.fromRGB(130,145,165), STEAL_ACCENT=Color3.fromRGB(140,155,175),
        PARTICLE=Color3.fromRGB(145,160,180),
    },
}
function getTheme()
    return GUI_THEMES[currentGuiTheme] or GUI_THEMES["Obsidian"]
end

-- ============================================================
-- STATE
-- ============================================================
TS=TweenService
LP=Players.LocalPlayer

-- ===== ANIMATION PACKS + CHARTER (Headless / Korblox) =====
PACKS = {
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

animPack = "Adidas Sports"
animPackEnabled = true
headlessEnabled = false
korbloxEnabled = false

local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"
local DARK_GREY_COLOR = Color3.fromRGB(64, 64, 64)

local function removeFace(head)
    local face = head:FindFirstChild("face")
    if face then face:Destroy() end
end

function applyHeadlessToChar(char, enabled)
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
            if head.Transparency ~= 1 then head.Transparency = 1 end
        end)
        head.ChildAdded:Connect(function(child)
            if child.Name == "face" and child:IsA("Decal") then child:Destroy() end
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

function applyKorbloxToChar(char, enabled)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if enabled then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            local rightLeg = char:FindFirstChild("Right Leg")
            if rightLeg then
                for _, child in ipairs(rightLeg:GetChildren()) do
                    if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then child:Destroy() end
                end
                rightLeg.Color = DARK_GREY_COLOR
                rightLeg:GetPropertyChangedSignal("Color"):Connect(function()
                    if rightLeg.Color ~= DARK_GREY_COLOR then rightLeg.Color = DARK_GREY_COLOR end
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
                    if child:IsA("SpecialMesh") and child.Name == "KorbloxMesh" then child:Destroy() end
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

function applyCharterToChar(char)
    if not char then return end
    applyHeadlessToChar(char, headlessEnabled)
    applyKorbloxToChar(char, korbloxEnabled)
end
function waitForAnimate(char)
    for _ = 1, 40 do
        local a = char:FindFirstChild("Animate")
        if a and a:FindFirstChild("idle") and a:FindFirstChild("run") and a:FindFirstChild("walk") then
            return a
        end
        task.wait(0.1)
    end
    return nil
end

function setAnim(animObj, id)
    if animObj and id then
        animObj.AnimationId = "rbxassetid://" .. tostring(id)
    end
end

function stopAllTracks(hum)
    if not hum then return end
    for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() t:Stop(0) end)
    end
end

function ensureAnim(folder, name)
    if not folder then return nil end
    local a = folder:FindFirstChild(name)
    if not a then
        a = Instance.new("Animation")
        a.Name = name
        a.Parent = folder
    end
    return a
end

function ensureIdleSlots(idleFolder, n)
    if not idleFolder then return end
    n = n or 2
    for i=1,n do
        ensureAnim(idleFolder, "Animation" .. i)
    end
end

function pickAnim(pack, ...)
    for i = 1, select("#", ...) do
        local k = select(i, ...)
        local v = pack[k]
        if v ~= nil then return v end
    end
    return nil
end

local applyingAnim = false
function applyAnimPack(packName)
    if applyingAnim then return false end
    applyingAnim = true

    local pack = PACKS[packName]
    if not pack then
        applyingAnim = false
        return false
    end

    local char = LP.Character or LP.CharacterAdded:Wait()
    local animate = waitForAnimate(char)
    if not animate then
        applyingAnim = false
        return false
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    stopAllTracks(hum)

    local runObj   = ensureAnim(animate:FindFirstChild("run"),   "RunAnim")
    local walkObj  = ensureAnim(animate:FindFirstChild("walk"),  "WalkAnim")
    local jumpObj  = ensureAnim(animate:FindFirstChild("jump"),  "JumpAnim")
    local fallObj  = ensureAnim(animate:FindFirstChild("fall"),  "FallAnim")
    local climbObj = ensureAnim(animate:FindFirstChild("climb"), "ClimbAnim")
    local swimObj  = ensureAnim(animate:FindFirstChild("swim"),     "Swim")
    local swimIdleObj = ensureAnim(animate:FindFirstChild("swimidle"), "SwimIdle")
    local idleFolder = animate:FindFirstChild("idle")

    setAnim(walkObj,  pickAnim(pack, "WalkAnim", "Walk"))
    setAnim(runObj,   pickAnim(pack, "RunAnim", "Run"))
    setAnim(jumpObj,  pickAnim(pack, "JumpAnim", "Jump"))
    setAnim(fallObj,  pickAnim(pack, "FallAnim", "Fall"))
    setAnim(climbObj, pickAnim(pack, "ClimbAnim", "Climb"))
    setAnim(swimObj,      pickAnim(pack, "Swim"))
    setAnim(swimIdleObj,  pickAnim(pack, "SwimIdle") or pickAnim(pack, "Swim"))

    if idleFolder then
        local a1 = pickAnim(pack, "Animation1")
        local a2 = pickAnim(pack, "Animation2")
        if a1 or a2 then
            ensureIdleSlots(idleFolder, 2)
            local id1 = a1 or a2
            local id2 = a2 or a1 or id1
            setAnim(idleFolder:FindFirstChild("Animation1"), id1)
            setAnim(idleFolder:FindFirstChild("Animation2"), id2)
        elseif pack.Idle and #pack.Idle > 0 then
            ensureIdleSlots(idleFolder, math.max(2, #pack.Idle))
            setAnim(idleFolder:FindFirstChild("Animation1"), pack.Idle[1])
            setAnim(idleFolder:FindFirstChild("Animation2"), pack.Idle[2] or pack.Idle[1])
            for i = 3, #pack.Idle do
                local a = idleFolder:FindFirstChild("Animation" .. i)
                if a then setAnim(a, pack.Idle[i]) end
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

    animPack = packName
    applyingAnim = false
    return true
end


-- ===== END ANIMATION / CHARTER =====
NS,CS=60,30
LAGGER_SPEED=15
LAGGER_CARRY_SPEED=24.5
carrySpeedActive = false
laggerModeEnabled = false
laggerCarryActive = false

antiRagdollEnabled,infJumpEnabled=false,false
playerEspEnabled,playerTracersEnabled=false,false
medusaCounterEnabled,batCounterEnabled,unwalkEnabled=false,false,false
medusaDebounce,medusaLastUsed,dropActive=false,0,false
autoLeftEnabled,autoRightEnabled=false,false
autoLeftSetVisual,autoRightSetVisual=nil,nil
autoTPLeftEnabled,autoTPRightEnabled=true,false
autoTPLeftSetVisual,autoTPRightSetVisual=nil,nil
autoTPLeftConn,autoTPRightConn=nil,nil
autoTPLeftRecovered,autoTPRightRecovered=true,true
autoTPLeftBusy,autoTPRightBusy=false,false
ragdollSyncAutoStealEnabled=false
RAGDOLL_STEAL_LEAD=0.015
ragdollStealScheduleToken=0
antiDropEnabled=false
antiDropHooksInstalled=false
antiBatEnabled=false
antiBatConnection=nil
spoofedVelocity=Vector3.zero
speedValue=59
speedLabel=nil
autoBatEnabled=false
batAimbotEnabled=false
antiBatBypassLockEnabled=false
antiDesyncAimbotEnabled=false
AIMBOT_SPEED=58
LAGGER_AIMBOT_SPEED=40
tpBatEnabled=false
aimbotV2Enabled=false
aimbotMode="normal"  -- "normal" | "bypass"
autoSwingEnabled=true
autoMoveSwingEnabled=false
autoMoveSwingInterval=0.3
_alSwingDebounce=false
_arSwingDebounce=false
autoBatSetVisual=nil
resetAutoBatMotion=nil
setBatCounterVisual=nil
startBatCounter,stopBatCounter=nil,nil
antiLagEnabled,removeAccessoriesEnabled,antiLagDescConn=false,false,nil
unwalkSavedAnimate,_anyKeyListening=nil,false
autoTPEnabled,autoTPHeight,autoTPConn,setAutoTPVisual=false,30,nil,nil
mirrorTPDownEnabled,mirrorTPPreviousY,mirrorTPLastTeleport=false,{},0
MIRROR_TP_DROP_THRESHOLD,MIRROR_TP_DOWN_Y=3,-7.00
setMirrorTPVisual=nil
guiTransparencyEnabled,mobileButtonsEnabled,mobileButtonsLocked=false,true,false
mobileButtonsSize=80
stealBarPos = nil -- {sx,ox,sy,oy} persisted
circleButtonsEnabled=false
stealBarFrame=nil
progressFill=nil
setStealStatusText=nil
mobBtnRefs={}
mobGuiRef=nil
mobViewportConn=nil
fovValue=80
fovOptions={80,120,180}
fovIndex=1
laggerModePillRef=nil
carryModePillRef=nil
autoSwitchSpeedEnabled=false -- unused
mobBtnTransparencyEnabled=false
perButtonDragEnabled=true -- each mobile button drags independently
antiKickEnabled=false
safeModeEnabled=false
setSafeModeVisual=nil
antiKickSetVisual=nil
brainrotDetected=false
activeBatBillboard=nil
activeMedusaBillboard=nil
ragdollGuiEnabled=false  -- removed from GUI

introEnabled=true
selectedIntroMusic=1 -- 1..4 only
persistentRagdollGui=nil -- reference to a persistent "always on" display
uiLocked=false
infJumpMode="manual"
holdInfJumpConn=nil
DROP_ASCEND_DURATION=0.2
DROP_ASCEND_SPEED=150

MOB_POS_FILE="k7duels_btnpos.json"
forceDefaultBtnPos=false
activeMobDrag=nil -- only one mobile button can drag at a time
local function loadBtnPositions()
    local data={}
    -- primary file (don't require isfile - many executors only have readfile)
    pcall(function()
        local raw=readfile(MOB_POS_FILE)
        if raw and #raw>2 then
            local decoded=HS:JSONDecode(raw)
            if type(decoded)=="table" then data=decoded end
        end
    end)
    -- fallback: positions embedded in main config
    if not data or next(data)==nil then
        pcall(function()
            local raw=readfile("k7duels.json")
            if raw then
                local cfg=HS:JSONDecode(raw)
                if type(cfg)=="table" and type(cfg.btnPositions)=="table" and next(cfg.btnPositions)~=nil then
                    data=cfg.btnPositions
                end
            end
        end)
    end
    return data or {}
end
local function saveBtnPositions()
    if not mobGuiRef then return end
    local out={}
    for _,child in ipairs(mobGuiRef:GetDescendants()) do
        if child:IsA("Frame") and child:GetAttribute("BtnKey") then
            local key=child:GetAttribute("BtnKey")
            out[key]={xs=0,xo=child.Position.X.Offset,ys=0,yo=child.Position.Y.Offset}
        end
    end
    -- also keep any keys already saved that might not be in tree yet
    if next(out)==nil then return end
    if writefile then
        pcall(function() writefile(MOB_POS_FILE,HS:JSONEncode(out)) end)
    end
    -- mirror into main config so it survives executor file quirks
    if writefile and isfile and isfile("k7duels.json") then
        pcall(function()
            local cfg=HS:JSONDecode(readfile("k7duels.json"))
            if type(cfg)=="table" then
                cfg.btnPositions=out
                writefile("k7duels.json",HS:JSONEncode(cfg))
            end
        end)
    end
end
-- autosave every 2s while buttons exist
task.spawn(function()
    while true do
        task.wait(2)
        pcall(saveBtnPositions)
    end
end)

refreshSpeedModeLabel,saveConfig=nil,nil
startUnwalk,stopUnwalk,setupMedusa,stopMedusaCounter=nil,nil,nil,nil
startAntiRagdoll,stopAntiRagdoll,startAutoLeft,stopAutoLeft,startAutoRight,stopAutoRight=nil,nil,nil,nil,nil,nil
startAutoTPLeft,stopAutoTPLeft,startAutoTPRight,stopAutoTPRight=nil,nil,nil,nil
setAutoTPLeftVisual,setAutoTPRightVisual,setRagdollSyncVisual,setAntiBatVisual=nil,nil,nil,nil
enableAntiDrop,disableAntiDrop=nil,nil
startAntiBat,stopAntiBat=nil,nil
startAutoTP,stopAutoTP,enableAntiLag,disableAntiLag=nil,nil,nil,nil
startBatAimbot,stopBatAimbot,queueAutoBatStart,runDrop,runTPFloor,startTPBat,stopTPBat=nil,nil,nil,nil,nil,nil,nil
startAutoSteal,stopAutoSteal,enableAntiKick,disableAntiKick,toggleCarryMode,toggleLaggerMode,toggleLaggerCarryMode=nil,nil,nil,nil,nil,nil,nil

local function addShimmerToLabel(lbl,color1,color2)
    local gr=Instance.new("UIGradient",lbl)
    gr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,color1 or Color3.fromRGB(160,80,255)),ColorSequenceKeypoint.new(0.5,color2 or Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,color1 or Color3.fromRGB(160,80,255))})
    gr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3,0),NumberSequenceKeypoint.new(0.5,0,0),NumberSequenceKeypoint.new(1,0.3,0)})
    return gr
end
fovConn=nil
local function applyFOV()
    if fovConn then fovConn:Disconnect() end
    fovConn=RunService.RenderStepped:Connect(function() local cam=workspace.CurrentCamera;if cam then cam.FieldOfView=fovValue end end)
end
applyFOV()

-- ============================================================
-- 2.5 SECOND RAGDOLL TIMER (themed)
-- ============================================================
do
    local timerBillboard = nil
    local timerLabel = nil
    local timerActive = false
    local timerConn = nil
    local ragdollCheckConn = nil
    local lastRagdollState = false

    local function getRagdollTheme()
        local th = (type(getTheme)=="function" and getTheme()) or nil
        if type(th)~="table" then
            th = (GUI_THEMES and GUI_THEMES[currentGuiTheme]) or nil
        end
        if type(th)~="table" then
            return {
                BG = Color3.fromRGB(8,8,10),
                ACCENT = Color3.fromRGB(255,255,255),
                ACCENT2 = Color3.fromRGB(200,200,210),
                WHITE = Color3.fromRGB(235,235,240),
                ROW_BORDER = Color3.fromRGB(32,32,36),
            }
        end
        return th
    end

    local function createTimerBillboard()
        if timerBillboard then timerBillboard:Destroy() end
        
        local char = LP.Character
        if not char then return end
        
        local head = char:FindFirstChild("Head")
        if not head then return end

        local th = getRagdollTheme()
        local accent = th.ACCENT or Color3.fromRGB(255,255,255)
        local bgCol = th.BG or Color3.fromRGB(8,8,10)
        local border = th.ROW_BORDER or Color3.fromRGB(32,32,36)
        
        timerBillboard = Instance.new("BillboardGui")
        timerBillboard.Name = "K7RagdollTimer"
        timerBillboard.Size = UDim2.new(0, 140, 0, 56)
        timerBillboard.StudsOffset = Vector3.new(0, 5.6, 0)
        timerBillboard.AlwaysOnTop = true
        timerBillboard.MaxDistance = 120
        timerBillboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        timerBillboard.Parent = head
        
        local bgFrame = Instance.new("Frame")
        bgFrame.Name = "Bg"
        bgFrame.Size = UDim2.new(1, 0, 1, 0)
        bgFrame.BackgroundColor3 = bgCol
        bgFrame.BackgroundTransparency = 0.18
        bgFrame.BorderSizePixel = 0
        bgFrame.Parent = timerBillboard
        Instance.new("UICorner", bgFrame).CornerRadius = UDim.new(0, 12)
        
        local stroke = Instance.new("UIStroke", bgFrame)
        stroke.Name = "ThemeStroke"
        stroke.Color = accent
        stroke.Thickness = 1.8
        stroke.Transparency = 0.25

        -- thin top accent bar
        local topBar = Instance.new("Frame")
        topBar.Name = "TopAccent"
        topBar.Size = UDim2.new(1, 0, 0, 2)
        topBar.Position = UDim2.new(0, 0, 0, 0)
        topBar.BackgroundColor3 = accent
        topBar.BackgroundTransparency = 0.1
        topBar.BorderSizePixel = 0
        topBar.ZIndex = 3
        topBar.Parent = bgFrame
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

        timerLabel = Instance.new("TextLabel")
        timerLabel.Name = "TimerText"
        timerLabel.Size = UDim2.new(1, -8, 1, -6)
        timerLabel.Position = UDim2.new(0, 4, 0, 4)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = "2.50"
        timerLabel.TextColor3 = accent
        timerLabel.Font = Enum.Font.GothamBlack
        timerLabel.TextSize = 26
        timerLabel.TextScaled = true
        timerLabel.ZIndex = 4
        timerLabel.Parent = bgFrame
        local tConstraint = Instance.new("UITextSizeConstraint")
        tConstraint.MinTextSize = 14
        tConstraint.MaxTextSize = 28
        tConstraint.Parent = timerLabel
        
        timerBillboard.Enabled = false
    end

    local function updateTimerDisplay(time, isReady)
        if not timerLabel or not timerBillboard then return end
        local th = getRagdollTheme()
        local accent = th.ACCENT or Color3.fromRGB(255,255,255)
        local accent2 = th.ACCENT2 or accent
        local bgCol = th.BG or Color3.fromRGB(8,8,10)
        local white = th.WHITE or Color3.fromRGB(235,235,240)
        
        if isReady then
            timerLabel.Text = "READY"
            timerLabel.TextColor3 = accent
            timerLabel.TextScaled = true
            local bg = timerLabel.Parent
            if bg then
                local stroke = bg:FindFirstChild("ThemeStroke") or bg:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = accent
                    stroke.Thickness = 2.4
                    stroke.Transparency = 0.05
                end
                bg.BackgroundTransparency = 0.08
                bg.BackgroundColor3 = bgCol
                local top = bg:FindFirstChild("TopAccent")
                if top then
                    top.BackgroundColor3 = accent
                    top.BackgroundTransparency = 0
                end
            end
        else
            timerLabel.Text = string.format("%.2f", time)
            -- blend accent as time counts down (warmer near end)
            local t = math.clamp(time / 2.5, 0, 1)
            timerLabel.TextColor3 = accent:Lerp(white, (1 - t) * 0.25)
            timerLabel.TextScaled = true
            local bg = timerLabel.Parent
            if bg then
                local stroke = bg:FindFirstChild("ThemeStroke") or bg:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Color = accent
                    stroke.Thickness = 1.6 + (1 - t) * 0.8
                    stroke.Transparency = 0.15 + t * 0.15
                end
                bg.BackgroundTransparency = 0.18
                bg.BackgroundColor3 = bgCol
                local top = bg:FindFirstChild("TopAccent")
                if top then
                    top.BackgroundColor3 = accent
                    top.BackgroundTransparency = 0.15
                end
            end
        end
    end

    local function startRagdollTimer()
        if timerActive then return end
        
        if not timerBillboard or not timerBillboard.Parent then
            createTimerBillboard()
            if not timerBillboard then return end
        end
        
        timerActive = true
        timerBillboard.Enabled = true
        local startTime = tick()
        local duration = 2.5
        
        if timerConn then timerConn:Disconnect() end
        timerConn = RunService.Heartbeat:Connect(function()
            if not timerActive then 
                timerConn:Disconnect()
                timerConn = nil
                return 
            end
            
            local char = LP.Character
            if not char then
                timerActive = false
                if timerBillboard then timerBillboard.Enabled = false end
                if timerConn then timerConn:Disconnect(); timerConn = nil end
                return
            end
            
            local elapsed = tick() - startTime
            local remaining = math.max(duration - elapsed, 0)
            
            if remaining <= 0 then
                timerActive = false
                updateTimerDisplay(0, true)
                
                if timerConn then timerConn:Disconnect(); timerConn = nil end
                
                task.delay(1.5, function()
                    if timerBillboard then timerBillboard.Enabled = false end
                    timerActive = false
                end)
                return
            end
            
            updateTimerDisplay(remaining, false)
        end)
    end

    local function checkRagdoll()
        if ragdollCheckConn then return end
        
        ragdollCheckConn = RunService.Heartbeat:Connect(function()
            local char = LP.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local state = hum:GetState()
            
            local isRagdolled = state == Enum.HumanoidStateType.Physics or 
                               state == Enum.HumanoidStateType.Ragdoll or 
                               state == Enum.HumanoidStateType.FallingDown
            
            if isRagdolled and not lastRagdollState then
                handleRagdollTPState(true)
                scheduleRagdollSyncedSteal()
                if not timerActive then
                    if not timerBillboard or not timerBillboard.Parent then createTimerBillboard() end
                    startRagdollTimer()
                end
            elseif not isRagdolled and lastRagdollState then
                handleRagdollTPState(false)
                ragdollStealScheduleToken+=1
            end
            lastRagdollState = isRagdolled
        end)
    end
    
    task.spawn(checkRagdoll)
    
    -- ============================================================
    -- MOGGED INTRO (4 panels) + selected song after mog sounds
    -- ============================================================
    playIntroAnimation = function()
        if introEnabled == false then return end

        local ASSETS = {
            IrishHub = "rbxassetid://131513419838182",
            GreenDuels = "rbxassetid://79052318194557",
            VampHub = "rbxassetid://108632168923336",
            AceDuels = "rbxassetid://86968392795085",
            K7Duels = "rbxassetid://135382218880707",
        }

        local MOGGED_SOUND_ID = "rbxassetid://132182797103598"
        local BACKGROUND_MUSIC_VOLUME = 0.55
        local MOGGED_SOUND_VOLUME = 0.95

        local PANEL_POP_TIME = 0.42
        local PANEL_POP_HOLD = 0.42
        local MOGGED_BAR_TIME = 0.34
        local MOGGED_HOLD = 0.82
        local BETWEEN_PANELS = 0.20
        local FINAL_REVEAL_HOLD = 1.55
        -- Loading always runs full 0->100% at 12%/sec (~8.33s); song plays from 4th mog until then
        local POST_MOG_TOTAL = 10.0
        local LOADING_TIME = 8.333
        local TAP_TO_SKIP = true

        local RED = Color3.fromRGB(229, 22, 34)
        local RED_BRIGHT = Color3.fromRGB(255, 65, 76)
        local BLACK = Color3.fromRGB(5, 5, 7)
        local BLACK_2 = Color3.fromRGB(13, 13, 16)
        local WHITE = Color3.fromRGB(242, 242, 245)

        local Players2 = game:GetService("Players")
        local TweenService2 = game:GetService("TweenService")
        local RunService2 = game:GetService("RunService")
        local ContentProvider = game:GetService("ContentProvider")
        local SoundService2 = game:GetService("SoundService")
        local LP2 = Players2.LocalPlayer
        local playerGui = LP2:WaitForChild("PlayerGui")

        pcall(function()
            local old = playerGui:FindFirstChild("K7DuelsMogIntro")
            if old then old:Destroy() end
            local gh = (typeof(gethui)=="function" and gethui) or _gethui
            if gh then
                local h = gh()
                local o = h and h:FindFirstChild("K7DuelsMogIntro")
                if o then o:Destroy() end
            end
            local cg = game:GetService("CoreGui"):FindFirstChild("K7DuelsMogIntro")
            if cg then cg:Destroy() end
        end)

        local gui = Instance.new("ScreenGui")
        gui.Name = "K7DuelsMogIntro"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local parented = false
        pcall(function()
            if parentGui then parentGui(gui); parented = gui.Parent ~= nil end
        end)
        if not parented then
            pcall(function()
                local gh = (typeof(gethui)=="function" and gethui) or _gethui
                if gh then gui.Parent = gh(); parented = true end
            end)
        end
        if not parented then
            parented = pcall(function() gui.Parent = game:GetService("CoreGui") end)
        end
        if not parented then
            gui.Parent = playerGui
        end

        local introSong = Instance.new("Sound")
        introSong.Name = "K7MogIntroSong"
        introSong.Volume = BACKGROUND_MUSIC_VOLUME
        introSong.Looped = false
        introSong.Parent = SoundService2

        local moggedSound = Instance.new("Sound")
        moggedSound.Name = "MoggedImpactSound"
        moggedSound.SoundId = MOGGED_SOUND_ID
        moggedSound.Volume = MOGGED_SOUND_VOLUME
        moggedSound.Looped = false
        moggedSound.Parent = SoundService2
        local moggedEqualizer = Instance.new("EqualizerSoundEffect")
        moggedEqualizer.LowGain = 4
        moggedEqualizer.MidGain = 2
        moggedEqualizer.HighGain = -1
        moggedEqualizer.Parent = moggedSound
        local moggedBoost = Instance.new("DistortionSoundEffect")
        moggedBoost.Level = 0.08
        moggedBoost.Parent = moggedSound

        local songStarted = false
        local running = true
        local loadingConnection
        local viewportConnection

        local function playMoggedSound()
            pcall(function()
                moggedSound:Stop()
                moggedSound.TimePosition = 0
                moggedSound:Play()
            end)
        end

        -- Load selected intro song (catbox) in background; play only AFTER 4 mog sounds
        local intros = {
            "https://files.catbox.moe/8ch5qz.mp3",
            "https://files.catbox.moe/8oogdu.mp3",
            "https://files.catbox.moe/gm26vl.mp3",
            "https://files.catbox.moe/m5kxm3.mp3",
        }
        local selectedMusic = math.clamp(tonumber(selectedIntroMusic) or 1, 1, 4)
        local songUrl = intros[selectedMusic]
        local cacheName = "K7HubIntro_" .. tostring(selectedMusic) .. ".mp3"
        local songAssetReady = nil

        local function tryGetCustomAsset(path)
            local asset = nil
            pcall(function()
                if k7GetCustomAsset then asset = k7GetCustomAsset(path) end
            end)
            if asset and asset ~= "" then return asset end
            pcall(function() if getcustomasset then asset = getcustomasset(path) end end)
            if asset and asset ~= "" then return asset end
            pcall(function() if syn and syn.getcustomasset then asset = syn.getcustomasset(path) end end)
            if asset and asset ~= "" then return asset end
            return nil
        end

        task.spawn(function()
            -- try cache first
            local cached = tryGetCustomAsset(cacheName)
            if cached then
                songAssetReady = cached
                return
            end
            local body = nil
            pcall(function()
                if k7HttpGet then body = k7HttpGet(songUrl) end
            end)
            if not body or #body < 1000 then
                pcall(function() body = game:HttpGet(songUrl) end)
            end
            if body and #body > 1000 then
                pcall(function()
                    if writefile then writefile(cacheName, body) end
                end)
                task.wait(0.05)
                songAssetReady = tryGetCustomAsset(cacheName)
            end
        end)

        local function startSelectedSong()
            if songStarted or not running then return end
            songStarted = true
            task.spawn(function()
                local waitStart = tick()
                while running and not songAssetReady and tick() - waitStart < 8 do
                    task.wait(0.05)
                end
                if not running then return end
                if songAssetReady then
                    pcall(function()
                        introSong.SoundId = songAssetReady
                        introSong.TimePosition = 0
                        introSong.Volume = BACKGROUND_MUSIC_VOLUME
                        introSong:Play()
                    end)
                end
            end)
        end

        local function tween(object, duration, goal, style, direction)
            local animation = TweenService2:Create(
                object,
                TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
                goal
            )
            animation:Play()
            return animation
        end

        local function round(object, radius)
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, radius)
            corner.Parent = object
            return corner
        end

        local function stroke(object, color, thickness, transparency)
            local line = Instance.new("UIStroke")
            line.Color = color
            line.Thickness = thickness or 1
            line.Transparency = transparency or 0
            line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            line.Parent = object
            return line
        end

        local background = Instance.new("Frame")
        background.Size = UDim2.fromScale(1, 1)
        background.BackgroundColor3 = BLACK
        background.BorderSizePixel = 0
        background.Parent = gui

        local backgroundGradient = Instance.new("UIGradient")
        backgroundGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 3, 5)),
            ColorSequenceKeypoint.new(0.48, Color3.fromRGB(25, 5, 8)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 3, 5)),
        })
        backgroundGradient.Rotation = 90
        backgroundGradient.Parent = background

        local backgroundGlow = Instance.new("Frame")
        backgroundGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        backgroundGlow.Position = UDim2.fromScale(0.5, 0.5)
        backgroundGlow.Size = UDim2.fromScale(0.62, 0.62)
        backgroundGlow.BackgroundColor3 = RED
        backgroundGlow.BackgroundTransparency = 0.93
        backgroundGlow.BorderSizePixel = 0
        backgroundGlow.Parent = background
        round(backgroundGlow, 999)

        local boardGroup = Instance.new("CanvasGroup")
        boardGroup.AnchorPoint = Vector2.new(0.5, 0.5)
        boardGroup.Position = UDim2.fromScale(0.5, 0.5)
        boardGroup.BackgroundTransparency = 1
        boardGroup.GroupTransparency = 0
        boardGroup.Parent = gui

        local boardScale = Instance.new("UIScale")
        boardScale.Scale = 1
        boardScale.Parent = boardGroup

        local board = Instance.new("Frame")
        board.Size = UDim2.fromScale(1, 1)
        board.BackgroundColor3 = BLACK
        board.BorderSizePixel = 0
        board.ClipsDescendants = true
        board.Parent = boardGroup
        round(board, 16)
        stroke(board, RED, 2, 0.22)

        local boardInner = Instance.new("Frame")
        boardInner.Position = UDim2.fromOffset(5, 5)
        boardInner.Size = UDim2.new(1, -10, 1, -10)
        boardInner.BackgroundColor3 = BLACK_2
        boardInner.BorderSizePixel = 0
        boardInner.ClipsDescendants = true
        boardInner.Parent = board
        round(boardInner, 12)

        local verticalDivider = Instance.new("Frame")
        verticalDivider.AnchorPoint = Vector2.new(0.5, 0.5)
        verticalDivider.Position = UDim2.fromScale(0.5, 0.5)
        verticalDivider.Size = UDim2.new(0, 3, 1, 0)
        verticalDivider.BackgroundColor3 = RED
        verticalDivider.BackgroundTransparency = 0.35
        verticalDivider.BorderSizePixel = 0
        verticalDivider.ZIndex = 30
        verticalDivider.Parent = boardInner

        local horizontalDivider = Instance.new("Frame")
        horizontalDivider.AnchorPoint = Vector2.new(0.5, 0.5)
        horizontalDivider.Position = UDim2.fromScale(0.5, 0.5)
        horizontalDivider.Size = UDim2.new(1, 0, 0, 3)
        horizontalDivider.BackgroundColor3 = RED
        horizontalDivider.BackgroundTransparency = 0.35
        horizontalDivider.BorderSizePixel = 0
        horizontalDivider.ZIndex = 30
        horizontalDivider.Parent = boardInner

        local panelData = {
            { name = "IRISH HUB", image = ASSETS.IrishHub, position = UDim2.fromScale(0, 0) },
            { name = "GREEN DUELS", image = ASSETS.GreenDuels, position = UDim2.fromScale(0.5, 0) },
            { name = "VAMP HUB", image = ASSETS.VampHub, position = UDim2.fromScale(0, 0.5) },
            { name = "ACE DUELS", image = ASSETS.AceDuels, position = UDim2.fromScale(0.5, 0.5) },
        }

        local panels = {}

        local function createMogPanel(info, order)
            local panel = Instance.new("CanvasGroup")
            panel.Name = info.name
            panel.Position = info.position
            panel.Size = UDim2.fromScale(0.5, 0.5)
            panel.BackgroundColor3 = BLACK_2
            panel.BorderSizePixel = 0
            panel.ClipsDescendants = true
            panel.GroupTransparency = 1
            panel.ZIndex = 10
            panel.Parent = boardInner

            local panelScale = Instance.new("UIScale")
            panelScale.Scale = 1.18
            panelScale.Parent = panel

            local image = Instance.new("ImageLabel")
            image.Size = UDim2.fromScale(1, 1)
            image.BackgroundColor3 = BLACK_2
            image.BorderSizePixel = 0
            image.Image = info.image
            image.ScaleType = Enum.ScaleType.Crop
            image.ImageTransparency = 0
            image.ZIndex = 11
            image.Parent = panel

            local darken = Instance.new("Frame")
            darken.Size = UDim2.fromScale(1, 1)
            darken.BackgroundColor3 = BLACK
            darken.BackgroundTransparency = 0.28
            darken.BorderSizePixel = 0
            darken.ZIndex = 12
            darken.Parent = panel

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Position = UDim2.fromOffset(12, 9)
            nameLabel.Size = UDim2.new(1, -24, 0, 22)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = info.name
            nameLabel.TextColor3 = WHITE
            nameLabel.TextTransparency = 0.15
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 14
            nameLabel.Parent = panel

            local nameStroke = Instance.new("UIStroke")
            nameStroke.Color = BLACK
            nameStroke.Thickness = 1.5
            nameStroke.Transparency = 0.1
            nameStroke.Parent = nameLabel

            local bar = Instance.new("Frame")
            bar.AnchorPoint = Vector2.new(0.5, 0.5)
            bar.Position = UDim2.fromScale(-0.55, 0.56)
            bar.Size = UDim2.new(0.9, 0, 0.24, 0)
            bar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bar.BorderSizePixel = 0
            bar.ZIndex = 20
            bar.Parent = panel
            stroke(bar, Color3.fromRGB(30, 30, 34), 1, 0.28)

            local barGradient = Instance.new("UIGradient")
            barGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 12)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
            })
            barGradient.Parent = bar

            local mogged = Instance.new("TextLabel")
            mogged.Size = UDim2.fromScale(1, 1)
            mogged.BackgroundTransparency = 1
            mogged.Text = "MOGGED"
            mogged.TextColor3 = RED_BRIGHT
            mogged.TextTransparency = 0
            mogged.Font = Enum.Font.GothamBlack
            mogged.TextScaled = true
            mogged.ZIndex = 21
            mogged.Parent = bar

            local textConstraint = Instance.new("UITextSizeConstraint")
            textConstraint.MinTextSize = 18
            textConstraint.MaxTextSize = 42
            textConstraint.Parent = mogged

            local mogStroke = Instance.new("UIStroke")
            mogStroke.Color = Color3.fromRGB(70, 0, 4)
            mogStroke.Thickness = 1.3
            mogStroke.Transparency = 0.12
            mogStroke.Parent = mogged

            local flash = Instance.new("Frame")
            flash.Size = UDim2.fromScale(1, 1)
            flash.BackgroundColor3 = RED_BRIGHT
            flash.BackgroundTransparency = 1
            flash.BorderSizePixel = 0
            flash.ZIndex = 25
            flash.Parent = panel

            panels[order] = {
                group = panel,
                scale = panelScale,
                image = image,
                bar = bar,
                flash = flash,
            }
        end

        for index, info in ipairs(panelData) do
            createMogPanel(info, index)
        end

        local fullReveal = Instance.new("CanvasGroup")
        fullReveal.Size = UDim2.fromScale(1, 1)
        fullReveal.BackgroundColor3 = BLACK
        fullReveal.BorderSizePixel = 0
        fullReveal.GroupTransparency = 1
        fullReveal.Visible = false
        fullReveal.ZIndex = 60
        fullReveal.Parent = boardInner

        local k7Ghost = Instance.new("ImageLabel")
        k7Ghost.AnchorPoint = Vector2.new(0.5, 0.5)
        k7Ghost.Position = UDim2.new(0.5, 7, 0.5, 0)
        k7Ghost.Size = UDim2.fromScale(1.16, 1.16)
        k7Ghost.BackgroundTransparency = 1
        k7Ghost.Image = (getK7LogoAsset() or ASSETS.K7Duels or "")
        k7Ghost.ImageColor3 = RED
        k7Ghost.ImageTransparency = 0.5
        k7Ghost.ScaleType = Enum.ScaleType.Crop
        k7Ghost.ZIndex = 61
        k7Ghost.Parent = fullReveal

        local k7Image = Instance.new("ImageLabel")
        k7Image.AnchorPoint = Vector2.new(0.5, 0.5)
        k7Image.Position = UDim2.fromScale(0.5, 0.5)
        k7Image.Size = UDim2.fromScale(1.22, 1.22)
        k7Image.BackgroundColor3 = BLACK
        k7Image.BorderSizePixel = 0
        k7Image.Image = (getK7LogoAsset() or ASSETS.K7Duels or "")
        k7Image.ScaleType = Enum.ScaleType.Crop
        k7Image.ZIndex = 62
        k7Image.Parent = fullReveal

        local k7Darken = Instance.new("Frame")
        k7Darken.Size = UDim2.fromScale(1, 1)
        k7Darken.BackgroundColor3 = BLACK
        k7Darken.BackgroundTransparency = 0.56
        k7Darken.BorderSizePixel = 0
        k7Darken.ZIndex = 63
        k7Darken.Parent = fullReveal

        local k7Title = Instance.new("TextLabel")
        k7Title.AnchorPoint = Vector2.new(0.5, 0.5)
        k7Title.Position = UDim2.fromScale(0.5, 0.82)
        k7Title.Size = UDim2.new(0.92, 0, 0.15, 0)
        k7Title.BackgroundTransparency = 1
        k7Title.Text = "K7 DUELS"
        k7Title.TextColor3 = RED_BRIGHT
        k7Title.TextTransparency = 1
        k7Title.Font = Enum.Font.GothamBlack
        k7Title.TextScaled = true
        k7Title.ZIndex = 68
        k7Title.Parent = fullReveal

        local k7TitleConstraint = Instance.new("UITextSizeConstraint")
        k7TitleConstraint.MinTextSize = 26
        k7TitleConstraint.MaxTextSize = 62
        k7TitleConstraint.Parent = k7Title

        local k7TitleStroke = Instance.new("UIStroke")
        k7TitleStroke.Color = BLACK
        k7TitleStroke.Thickness = 2.2
        k7TitleStroke.Transparency = 0.05
        k7TitleStroke.Parent = k7Title

        local k7Line = Instance.new("Frame")
        k7Line.AnchorPoint = Vector2.new(0.5, 0.5)
        k7Line.Position = UDim2.fromScale(0.5, 0.9)
        k7Line.Size = UDim2.new(0, 0, 0, 5)
        k7Line.BackgroundColor3 = RED_BRIGHT
        k7Line.BorderSizePixel = 0
        k7Line.ZIndex = 68
        k7Line.Parent = fullReveal
        round(k7Line, 4)

        local revealFlash = Instance.new("Frame")
        revealFlash.Size = UDim2.fromScale(1, 1)
        revealFlash.BackgroundColor3 = RED_BRIGHT
        revealFlash.BackgroundTransparency = 1
        revealFlash.BorderSizePixel = 0
        revealFlash.ZIndex = 80
        revealFlash.Parent = fullReveal

        local scanLine = Instance.new("Frame")
        scanLine.Position = UDim2.fromScale(0, -0.08)
        scanLine.Size = UDim2.new(1, 0, 0.08, 0)
        scanLine.BackgroundColor3 = RED_BRIGHT
        scanLine.BackgroundTransparency = 0.48
        scanLine.BorderSizePixel = 0
        scanLine.ZIndex = 70
        scanLine.Parent = fullReveal

        local loading = Instance.new("CanvasGroup")
        loading.Size = UDim2.fromScale(1, 1)
        loading.BackgroundColor3 = BLACK
        loading.BorderSizePixel = 0
        loading.GroupTransparency = 1
        loading.Visible = false
        loading.ZIndex = 100
        loading.Parent = boardInner

        local loadingImage = Instance.new("ImageLabel")
        loadingImage.AnchorPoint = Vector2.new(0.5, 0.5)
        loadingImage.Position = UDim2.fromScale(0.5, 0.39)
        loadingImage.Size = UDim2.fromScale(0.34, 0.34)
        loadingImage.BackgroundTransparency = 1
        loadingImage.Image = (getK7LogoAsset() or ASSETS.K7Duels or "")
        loadingImage.ScaleType = Enum.ScaleType.Crop
        loadingImage.ImageTransparency = 0.08
        loadingImage.ZIndex = 101
        loadingImage.Parent = loading
        round(loadingImage, 18)
        stroke(loadingImage, RED, 2, 0.2)

        local loadingTitle = Instance.new("TextLabel")
        loadingTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        loadingTitle.Position = UDim2.fromScale(0.5, 0.62)
        loadingTitle.Size = UDim2.new(0.9, 0, 0.11, 0)
        loadingTitle.BackgroundTransparency = 1
        loadingTitle.Text = "K7 DUELS"
        loadingTitle.TextColor3 = RED_BRIGHT
        loadingTitle.Font = Enum.Font.GothamBlack
        loadingTitle.TextScaled = true
        loadingTitle.ZIndex = 102
        loadingTitle.Parent = loading

        local loadingTitleConstraint = Instance.new("UITextSizeConstraint")
        loadingTitleConstraint.MinTextSize = 24
        loadingTitleConstraint.MaxTextSize = 52
        loadingTitleConstraint.Parent = loadingTitle

        local loadingText = Instance.new("TextLabel")
        loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
        loadingText.Position = UDim2.fromScale(0.5, 0.70)
        loadingText.Size = UDim2.new(0.8, 0, 0.055, 0)
        loadingText.BackgroundTransparency = 1
        loadingText.Text = "LOADING"
        loadingText.TextColor3 = WHITE
        loadingText.TextTransparency = 0.16
        loadingText.Font = Enum.Font.GothamMedium
        loadingText.TextScaled = true
        loadingText.ZIndex = 102
        loadingText.Parent = loading

        local loadingTextConstraint = Instance.new("UITextSizeConstraint")
        loadingTextConstraint.MinTextSize = 14
        loadingTextConstraint.MaxTextSize = 24
        loadingTextConstraint.Parent = loadingText

        local progressBack = Instance.new("Frame")
        progressBack.AnchorPoint = Vector2.new(0.5, 0.5)
        progressBack.Position = UDim2.fromScale(0.5, 0.875)
        progressBack.Size = UDim2.new(0.48, 0, 0.022, 0)
        progressBack.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        progressBack.BorderSizePixel = 0
        progressBack.ZIndex = 102
        progressBack.Parent = loading
        round(progressBack, 999)

        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.fromScale(0, 1)
        progressFill.BackgroundColor3 = RED_BRIGHT
        progressFill.BorderSizePixel = 0
        progressFill.ZIndex = 103
        progressFill.Parent = progressBack
        round(progressFill, 999)

        local introDiscord = Instance.new("TextLabel")
        introDiscord.Name = "IntroDiscord"
        introDiscord.AnchorPoint = Vector2.new(0.5, 0.5)
        introDiscord.Position = UDim2.fromScale(0.5, 0.935)
        introDiscord.Size = UDim2.new(0.9, 0, 0.04, 0)
        introDiscord.BackgroundTransparency = 1
        introDiscord.Text = "discord.gg/k7hub"
        introDiscord.TextColor3 = Color3.fromRGB(180, 180, 190)
        introDiscord.TextTransparency = 0.2
        introDiscord.Font = Enum.Font.GothamBold
        introDiscord.TextScaled = true
        introDiscord.ZIndex = 102
        introDiscord.Parent = loading
        local introDiscordConstraint = Instance.new("UITextSizeConstraint")
        introDiscordConstraint.MinTextSize = 10
        introDiscordConstraint.MaxTextSize = 16
        introDiscordConstraint.Parent = introDiscord

        local skipButton = Instance.new("TextButton")
        skipButton.Size = UDim2.fromScale(1, 1)
        skipButton.BackgroundTransparency = 1
        skipButton.Text = ""
        skipButton.AutoButtonColor = false
        skipButton.ZIndex = 500
        skipButton.Parent = gui

        local skipText = Instance.new("TextLabel")
        skipText.AnchorPoint = Vector2.new(0.5, 1)
        skipText.Position = UDim2.new(0.5, 0, 1, -18)
        skipText.Size = UDim2.fromOffset(180, 22)
        skipText.BackgroundTransparency = 1
        skipText.Text = TAP_TO_SKIP and "tap to skip" or ""
        skipText.TextColor3 = Color3.fromRGB(145, 145, 150)
        skipText.TextTransparency = 0.28
        skipText.Font = Enum.Font.GothamMedium
        skipText.TextSize = 11
        skipText.ZIndex = 501
        skipText.Parent = gui

        local screenFlash = Instance.new("Frame")
        screenFlash.Size = UDim2.fromScale(1, 1)
        screenFlash.BackgroundColor3 = RED_BRIGHT
        screenFlash.BackgroundTransparency = 1
        screenFlash.BorderSizePixel = 0
        screenFlash.ZIndex = 450
        screenFlash.Parent = gui

        local camera = workspace.CurrentCamera
        while not camera do
            RunService2.RenderStepped:Wait()
            camera = workspace.CurrentCamera
        end

        local function updateBoardSize()
            local viewportSize = camera.ViewportSize
            local side = math.floor(math.min(viewportSize.X, viewportSize.Y) * 0.78)
            side = math.clamp(side, 320, 760)
            boardGroup.Size = UDim2.fromOffset(side, side)
        end
        updateBoardSize()
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateBoardSize)

        local function shakeBoard(strength, duration)
            local startPosition = boardGroup.Position
            local startedAt = os.clock()
            while running and os.clock() - startedAt < duration do
                local fade = 1 - ((os.clock() - startedAt) / duration)
                local x = (math.random() - 0.5) * strength * fade
                local y = (math.random() - 0.5) * strength * fade
                boardGroup.Position = UDim2.new(0.5, x, 0.5, y)
                RunService2.RenderStepped:Wait()
            end
            boardGroup.Position = startPosition
        end

        local function redImpact()
            screenFlash.BackgroundTransparency = 0.22
            tween(screenFlash, 0.24, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            task.spawn(shakeBoard, 11, 0.17)
        end

        local function closeIntro()
            if not running then return end
            running = false
            if introSong.IsPlaying then
                tween(introSong, 0.28, {Volume = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
            pcall(function() moggedSound:Stop() end)
            if loadingConnection then loadingConnection:Disconnect(); loadingConnection = nil end
            if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
            tween(boardGroup, 0.28, {GroupTransparency = 1}, Enum.EasingStyle.Quad)
            tween(background, 0.38, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            tween(skipText, 0.2, {TextTransparency = 1}, Enum.EasingStyle.Quad)
            task.delay(0.42, function()
                pcall(function() introSong:Destroy() end)
                pcall(function() moggedSound:Destroy() end)
                if gui then pcall(function() gui:Destroy() end) end
            end)
        end

        if TAP_TO_SKIP then
            skipButton.Activated:Connect(closeIntro)
        else
            skipButton.Active = false
        end

        pcall(function()
            ContentProvider:PreloadAsync({
                panels[1].image, panels[2].image, panels[3].image, panels[4].image,
                k7Image, loadingImage, moggedSound,
            })
        end)

        local mogCount = 0
        local postMogStartTime = nil
        local function revealPanel(panel)
            if not running then return end
            panel.group.GroupTransparency = 1
            panel.scale.Scale = 1.22
            panel.bar.Position = UDim2.fromScale(-0.55, 0.56)

            tween(panel.group, PANEL_POP_TIME * 0.72, {GroupTransparency = 0}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            tween(panel.scale, PANEL_POP_TIME, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.spawn(shakeBoard, 4, 0.09)
            task.wait(PANEL_POP_HOLD)

            playMoggedSound()
            mogCount = mogCount + 1
            -- After the 4th mog sound, start the selected intro song for ~8s remainder
            if mogCount >= 4 then
                postMogStartTime = os.clock()
                startSelectedSong()
            end

            tween(panel.bar, MOGGED_BAR_TIME, {Position = UDim2.fromScale(0.5, 0.56)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            panel.flash.BackgroundTransparency = 0.45
            tween(panel.flash, 0.28, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.spawn(shakeBoard, 6, 0.12)
            task.wait(MOGGED_HOLD)
        end

        local function transitionToK7()
            if not running then return end
            startSelectedSong()

            -- heavy impact flash + board slam
            redImpact()
            screenFlash.BackgroundColor3 = RED_BRIGHT
            screenFlash.BackgroundTransparency = 0.05
            tween(screenFlash, 0.45, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            tween(boardScale, 0.18, {Scale = 1.14}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            task.spawn(shakeBoard, 18, 0.22)
            task.wait(0.12)

            -- collapse the 4 mog panels with a spin-out
            for i, panel in ipairs(panels) do
                local ang = (i % 2 == 0) and 12 or -12
                tween(panel.group, 0.28, {GroupTransparency = 1}, Enum.EasingStyle.Quad)
                if panel.scale then
                    tween(panel.scale, 0.28, {Scale = 0.72}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                end
            end
            tween(verticalDivider, 0.2, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            tween(horizontalDivider, 0.2, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            task.wait(0.18)
            verticalDivider.Visible = false
            horizontalDivider.Visible = false

            -- setup k7 reveal
            fullReveal.Visible = true
            fullReveal.GroupTransparency = 1
            k7Image.Size = UDim2.fromScale(1.55, 1.55)
            k7Image.Rotation = 0
            k7Image.ImageTransparency = 0.15
            k7Ghost.Position = UDim2.new(0.5, 28, 0.5, 0)
            k7Ghost.ImageTransparency = 0.55
            k7Ghost.Size = UDim2.fromScale(1.4, 1.4)
            k7Title.TextTransparency = 1
            k7Title.Size = UDim2.new(0.35, 0, 0.10, 0)
            k7Title.TextColor3 = RED_BRIGHT
            if k7Line then
                k7Line.Size = UDim2.new(0, 0, 0, 5)
                k7Line.BackgroundTransparency = 0
            end
            if revealFlash then
                revealFlash.BackgroundTransparency = 0.0
            end

            -- zoom slam into frame
            tween(boardScale, 0.42, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(fullReveal, 0.22, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
            tween(k7Image, 0.85, {
                Size = UDim2.fromScale(1.05, 1.05),
                Rotation = 0,
                ImageTransparency = 0,
            }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            tween(k7Ghost, 0.7, {
                Position = UDim2.new(0.5, -10, 0.5, 0),
                ImageTransparency = 0.42,
                Size = UDim2.fromScale(1.12, 1.12),
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if scanLine then
                scanLine.Position = UDim2.fromScale(0, -0.1)
                tween(scanLine, 0.9, {Position = UDim2.fromScale(0, 1.08)}, Enum.EasingStyle.Linear)
            end
            if revealFlash then
                tween(revealFlash, 0.55, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            end

            -- burst particles from center
            local burst = {}
            for i = 1, 16 do
                local p = Instance.new("Frame")
                p.AnchorPoint = Vector2.new(0.5, 0.5)
                p.Position = UDim2.fromScale(0.5, 0.5)
                p.Size = UDim2.fromOffset(5 + (i % 4), 5 + (i % 4))
                p.BackgroundColor3 = (i % 3 == 0) and WHITE or RED_BRIGHT
                p.BackgroundTransparency = 0.1
                p.BorderSizePixel = 0
                p.ZIndex = 80
                p.Parent = fullReveal
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(1, 0)
                c.Parent = p
                local ang = (i / 16) * math.pi * 2
                local dist = 40 + (i % 5) * 18
                burst[i] = {gui = p, ang = ang, dist = dist}
                tween(p, 0.55, {
                    Position = UDim2.new(0.5, math.cos(ang) * dist, 0.5, math.sin(ang) * dist),
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(2, 2),
                }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
            task.delay(0.7, function()
                for _, b in ipairs(burst) do
                    pcall(function() b.gui:Destroy() end)
                end
            end)

            task.wait(0.35)
            -- title slam in
            tween(k7Title, 0.45, {
                TextTransparency = 0,
                Size = UDim2.new(0.92, 0, 0.15, 0),
            }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            if k7Line then
                tween(k7Line, 0.5, {Size = UDim2.new(0.55, 0, 0, 5)}, Enum.EasingStyle.Quint)
            end
            task.spawn(shakeBoard, 12, 0.2)

            -- expanding energy ring (no logo spin)
            local energyRing = Instance.new("Frame")
            energyRing.AnchorPoint = Vector2.new(0.5, 0.5)
            energyRing.Position = UDim2.fromScale(0.5, 0.5)
            energyRing.Size = UDim2.fromOffset(40, 40)
            energyRing.BackgroundTransparency = 1
            energyRing.ZIndex = 78
            energyRing.Parent = fullReveal
            local erStroke = Instance.new("UIStroke")
            erStroke.Color = RED_BRIGHT
            erStroke.Thickness = 3
            erStroke.Transparency = 0.15
            erStroke.Parent = energyRing
            Instance.new("UICorner", energyRing).CornerRadius = UDim.new(1, 0)
            tween(energyRing, 0.7, {Size = UDim2.fromOffset(320, 320)}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            tween(erStroke, 0.7, {Transparency = 1, Thickness = 0.5}, Enum.EasingStyle.Quad)
            task.delay(0.75, function() pcall(function() energyRing:Destroy() end) end)

            -- corner light streaks
            for i = 1, 4 do
                local streak = Instance.new("Frame")
                streak.AnchorPoint = Vector2.new(0.5, 0.5)
                streak.Size = UDim2.new(0, 0, 0, 2)
                streak.BackgroundColor3 = RED_BRIGHT
                streak.BackgroundTransparency = 0.15
                streak.BorderSizePixel = 0
                streak.ZIndex = 77
                streak.Rotation = (i - 1) * 90 + 45
                streak.Position = UDim2.fromScale(0.5, 0.5)
                streak.Parent = fullReveal
                tween(streak, 0.55, {
                    Size = UDim2.new(0, 220, 0, 2),
                    BackgroundTransparency = 1,
                }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                task.delay(0.6, function() pcall(function() streak:Destroy() end) end)
            end

            -- energetic post-reveal loop (glitch / pulse / chromatic ghost)
            local effectStart = os.clock()
            local glitchT = 0
            while running and os.clock() - effectStart < FINAL_REVEAL_HOLD do
                local elapsed = os.clock() - effectStart
                local pulse = math.sin(elapsed * 10)
                local pulse2 = math.cos(elapsed * 7.5)
                k7Ghost.Position = UDim2.new(0.5, pulse * 9 + math.sin(elapsed * 3) * 2, 0.5, pulse2 * 4)
                k7Ghost.ImageTransparency = 0.35 + pulse * 0.1
                -- subtle RGB-ish title flicker
                k7Title.TextColor3 = Color3.fromRGB(
                    255,
                    math.clamp(40 + pulse * 55, 25, 140),
                    math.clamp(50 + pulse2 * 45, 30, 130)
                )
                if k7Line then
                    k7Line.BackgroundTransparency = 0.02 + math.abs(pulse) * 0.3
                    k7Line.BackgroundColor3 = Color3.fromRGB(
                        255,
                        math.clamp(40 + math.abs(pulse2) * 60, 30, 120),
                        math.clamp(50 + math.abs(pulse) * 40, 30, 110)
                    )
                end
                backgroundGlow.BackgroundTransparency = 0.86 + pulse * 0.04
                boardScale.Scale = 1 + pulse * 0.015

                -- occasional micro-glitch on title
                glitchT = glitchT + 1
                if glitchT % 14 == 0 then
                    k7Title.Position = UDim2.new(0.5, (math.random() - 0.5) * 10, k7Title.Position.Y.Scale, k7Title.Position.Y.Offset)
                    task.delay(0.04, function()
                        if k7Title and k7Title.Parent then
                            k7Title.Position = UDim2.new(0.5, 0, k7Title.Position.Y.Scale, k7Title.Position.Y.Offset)
                        end
                    end)
                end
                RunService2.RenderStepped:Wait()
            end
            k7Image.Rotation = 0
            k7Title.TextColor3 = RED_BRIGHT
            if k7Title then
                k7Title.Position = UDim2.new(0.5, 0, k7Title.Position.Y.Scale, k7Title.Position.Y.Offset)
            end
        end

        local function showLoading()
            if not running then return end
            startSelectedSong()
            screenFlash.BackgroundColor3 = BLACK
            screenFlash.BackgroundTransparency = 1
            tween(screenFlash, 0.18, {BackgroundTransparency = 0.15}, Enum.EasingStyle.Quad)
            task.wait(0.12)

            -- Keep k7 logo visible behind loading for continuity
            if fullReveal then
                fullReveal.Visible = true
                tween(fullReveal, 0.45, {GroupTransparency = 0.55}, Enum.EasingStyle.Quad)
            end

            loading.Visible = true
            loading.GroupTransparency = 1
            tween(loading, 0.35, {GroupTransparency = 0}, Enum.EasingStyle.Quad)
            tween(screenFlash, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)

            -- Orbit rings around loading logo
            local ring1 = Instance.new("Frame")
            ring1.Name = "OrbitRing1"
            ring1.AnchorPoint = Vector2.new(0.5, 0.5)
            ring1.Position = UDim2.fromScale(0.5, 0.42)
            ring1.Size = UDim2.fromOffset(150, 150)
            ring1.BackgroundTransparency = 1
            ring1.ZIndex = 70
            ring1.Parent = loading
            local ring1Stroke = Instance.new("UIStroke")
            ring1Stroke.Color = RED_BRIGHT
            ring1Stroke.Thickness = 2
            ring1Stroke.Transparency = 0.35
            ring1Stroke.Parent = ring1
            local ring1Corner = Instance.new("UICorner")
            ring1Corner.CornerRadius = UDim.new(1, 0)
            ring1Corner.Parent = ring1

            local ring2 = Instance.new("Frame")
            ring2.Name = "OrbitRing2"
            ring2.AnchorPoint = Vector2.new(0.5, 0.5)
            ring2.Position = UDim2.fromScale(0.5, 0.42)
            ring2.Size = UDim2.fromOffset(190, 190)
            ring2.BackgroundTransparency = 1
            ring2.ZIndex = 69
            ring2.Parent = loading
            local ring2Stroke = Instance.new("UIStroke")
            ring2Stroke.Color = Color3.fromRGB(255, 120, 130)
            ring2Stroke.Thickness = 1.5
            ring2Stroke.Transparency = 0.55
            ring2Stroke.Parent = ring2
            local ring2Corner = Instance.new("UICorner")
            ring2Corner.CornerRadius = UDim.new(1, 0)
            ring2Corner.Parent = ring2

            -- floating spark dots
            local sparks = {}
            for i = 1, 10 do
                local s = Instance.new("Frame")
                s.AnchorPoint = Vector2.new(0.5, 0.5)
                s.Size = UDim2.fromOffset(4 + (i % 3), 4 + (i % 3))
                s.BackgroundColor3 = (i % 2 == 0) and RED_BRIGHT or WHITE
                s.BackgroundTransparency = 0.2
                s.BorderSizePixel = 0
                s.ZIndex = 72
                s.Parent = loading
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(1, 0)
                c.Parent = s
                sparks[i] = {gui = s, angle = (i / 10) * math.pi * 2, speed = 0.7 + (i % 4) * 0.25, radius = 70 + (i % 5) * 12}
            end

            -- status tag under percent (bar is below this so they never collide)
            local statusTag = Instance.new("TextLabel")
            statusTag.AnchorPoint = Vector2.new(0.5, 0.5)
            statusTag.Position = UDim2.fromScale(0.5, 0.79)
            statusTag.Size = UDim2.new(0.8, 0, 0.045, 0)
            statusTag.BackgroundTransparency = 1
            statusTag.Text = "INITIALIZING"
            statusTag.TextColor3 = WHITE
            statusTag.TextTransparency = 0.25
            statusTag.Font = Enum.Font.GothamBold
            statusTag.TextScaled = true
            statusTag.ZIndex = 75
            statusTag.Parent = loading
            local statusConstraint = Instance.new("UITextSizeConstraint")
            statusConstraint.MinTextSize = 10
            statusConstraint.MaxTextSize = 18
            statusConstraint.Parent = statusTag

            local statusMessages = {
                "INITIALIZING",
                "LOADING MODULES",
                "SYNCING",
                "CALIBRATING",
                "ALMOST READY",
                "READY"
            }

            local PCT_PER_SEC = 12
            local loadDuration = 100 / PCT_PER_SEC

            local startedAt = os.clock()
            local lastShown = -1
            loadingText.Text = "0%"
            progressFill.Size = UDim2.fromScale(0, 1)

            -- progress bar soft glow
            local barGlow = Instance.new("UIStroke")
            barGlow.Color = RED_BRIGHT
            barGlow.Thickness = 1.5
            barGlow.Transparency = 0.4
            if progressFill and progressFill.Parent then
                barGlow.Parent = progressFill.Parent
            end

            loadingConnection = RunService2.RenderStepped:Connect(function()
                if not running then return end
                local elapsed = os.clock() - startedAt
                local pct = math.clamp(elapsed * PCT_PER_SEC, 0, 100)
                local shown = math.floor(pct)
                if shown ~= lastShown then
                    lastShown = shown
                    loadingText.Text = tostring(shown) .. "%"
                    local msgIdx = math.clamp(math.floor(pct / 20) + 1, 1, #statusMessages)
                    statusTag.Text = statusMessages[msgIdx]
                end
                progressFill.Size = UDim2.fromScale(pct / 100, 1)

                local pulse = 1 + math.sin(elapsed * 5.5) * 0.04
                local pulse2 = math.sin(elapsed * 3.2)
                -- logo: soft scale pulse only (no rotation)
                loadingImage.Size = UDim2.fromScale(0.34 * pulse, 0.34 * pulse)
                loadingImage.Rotation = 0
                loadingText.TextTransparency = 0.05 + math.abs(pulse2) * 0.08
                statusTag.TextTransparency = 0.2 + math.abs(math.sin(elapsed * 4)) * 0.25
                if loadingTitle then
                    loadingTitle.TextTransparency = 0.02 + math.abs(math.sin(elapsed * 2.8)) * 0.08
                end
                if introDiscord then
                    introDiscord.TextTransparency = 0.12 + math.abs(math.sin(elapsed * 2.2)) * 0.22
                end

                -- orbit rings
                ring1.Rotation = elapsed * 55
                ring2.Rotation = -elapsed * 35
                local ringPulse = 1 + math.sin(elapsed * 4) * 0.06
                ring1.Size = UDim2.fromOffset(150 * ringPulse, 150 * ringPulse)
                ring2.Size = UDim2.fromOffset(190 * ringPulse, 190 * ringPulse)
                ring1Stroke.Transparency = 0.3 + math.abs(math.sin(elapsed * 3)) * 0.35
                ring2Stroke.Transparency = 0.45 + math.abs(math.cos(elapsed * 2.5)) * 0.3

                if barGlow then
                    barGlow.Transparency = 0.25 + math.abs(math.sin(elapsed * 6)) * 0.45
                    barGlow.Thickness = 1.2 + math.abs(math.sin(elapsed * 5)) * 1.5
                end
                -- progress track subtle height breathe
                if progressBack then
                    local h = 0.022 + math.abs(math.sin(elapsed * 3.5)) * 0.004
                    progressBack.Size = UDim2.new(0.48, 0, h, 0)
                end

                -- sparks orbit
                for _, sp in ipairs(sparks) do
                    local a = sp.angle + elapsed * sp.speed
                    local r = sp.radius * (1 + math.sin(elapsed * 2 + sp.angle) * 0.08)
                    local x = math.cos(a) * r
                    local y = math.sin(a) * r
                    sp.gui.Position = UDim2.new(0.5, x, 0.42, y)
                    sp.gui.BackgroundTransparency = 0.15 + (math.sin(elapsed * 5 + sp.angle) * 0.35 + 0.35)
                end

                -- subtle board / bg energy while song plays
                if backgroundGlow then
                    backgroundGlow.BackgroundTransparency = 0.9 + math.sin(elapsed * 2.5) * 0.04
                end
                if boardScale then
                    boardScale.Scale = 1 + math.sin(elapsed * 2.2) * 0.01
                end

                -- occasional soft red flash
                if math.floor(elapsed * 2) % 7 == 0 and (elapsed * 2) % 1 < 0.05 then
                    screenFlash.BackgroundColor3 = RED
                    screenFlash.BackgroundTransparency = 0.82
                    tween(screenFlash, 0.25, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
                end
            end)

            task.wait(loadDuration)
            if loadingConnection then
                loadingConnection:Disconnect()
                loadingConnection = nil
            end
            loadingText.Text = "100%"
            statusTag.Text = "READY"
            progressFill.Size = UDim2.fromScale(1, 1)
            -- final pop
            tween(loadingImage, 0.2, {Size = UDim2.fromScale(0.42, 0.42)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(0.28)
            closeIntro()
        end

        task.spawn(function()
            for _, panel in ipairs(panels) do
                if not running then return end
                revealPanel(panel)
                task.wait(BETWEEN_PANELS)
            end
            if not running then return end
            task.wait(0.25)
            transitionToK7()
            if not running then return end
            showLoading()
        end)
    end


    LP.CharacterAdded:Connect(function(char)
        if ragdollCheckConn then 
            ragdollCheckConn:Disconnect()
            ragdollCheckConn = nil
        end
        timerActive = false
        lastRagdollState = false
        if timerConn then timerConn:Disconnect(); timerConn = nil end
        if timerBillboard then timerBillboard:Destroy(); timerBillboard = nil end
        
        task.wait(0.5)
        createTimerBillboard()
        checkRagdoll()
        -- intro intentionally NOT played on reset/respawn
    end)
    
    task.spawn(function()
        task.wait(0.5)
        createTimerBillboard()
    end)
end

local function createRagdollBillboard(duration,labelText,color)
    if not ragdollGuiEnabled then return nil end
    local PINK  = color or Color3.fromRGB(160,80,255)
    local BG    = Color3.fromRGB(6,4,14)
    local WHITE = Color3.fromRGB(255,255,255)
    local W,H   = 210,80
    local guiName="K7RagdollTimer_"..labelText
    pcall(function()
        local cg=game:GetService("CoreGui");local old=cg:FindFirstChild(guiName);if old then old:Destroy() end
        local pg=LP:FindFirstChild("PlayerGui");if pg then local o=pg:FindFirstChild(guiName);if o then o:Destroy() end end
    end)
    local sg=Instance.new("ScreenGui")
    sg.Name=guiName;sg.ResetOnSpawn=false;sg.IgnoreGuiInset=true;sg.DisplayOrder=25
    parentGui(sg)
    -- Outer card - dark, thick pink border, matches photo
    local card=Instance.new("Frame",sg)
    card.Size=UDim2.new(0,W,0,H);card.Position=UDim2.new(0.5,-W/2,0,58)
    card.BackgroundColor3=BG;card.BackgroundTransparency=0.05
    card.BorderSizePixel=0;card.ZIndex=30;card.Active=true
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,14)
    -- Static border (no glow pulse)
    local stroke=Instance.new("UIStroke",card)
    stroke.Color=PINK;stroke.Thickness=1;stroke.Transparency=0.6
    -- Title (white bold, centered, photo style - no colored bar)
    local titleLbl=Instance.new("TextLabel",card)
    titleLbl.Size=UDim2.new(1,-16,0,28);titleLbl.Position=UDim2.new(0,8,0,6)
    titleLbl.BackgroundTransparency=1
    titleLbl.Text=(labelText=="RAGDOLL" and "RAGDOLL TIMER" or (labelText=="STONE" and "STONE TIMER" or labelText.." TIMER"))
    titleLbl.TextColor3=WHITE;titleLbl.Font=Enum.Font.GothamBlack;titleLbl.TextSize=13
    titleLbl.TextXAlignment=Enum.TextXAlignment.Center;titleLbl.ZIndex=32
    -- Thin pink divider under title
    local divider=Instance.new("Frame",card)
    divider.Size=UDim2.new(1,-20,0,1);divider.Position=UDim2.new(0,10,0,34)
    divider.BackgroundColor3=PINK;divider.BackgroundTransparency=0.5;divider.BorderSizePixel=0;divider.ZIndex=31
    -- Countdown label (big, pink, shimmer)
    local timerLbl=Instance.new("TextLabel",card)
    timerLbl.Size=UDim2.new(1,0,0,H-38);timerLbl.Position=UDim2.new(0,0,0,36)
    timerLbl.BackgroundTransparency=1;timerLbl.Text=string.format("%.1f",duration).."s"
    timerLbl.TextColor3=PINK;timerLbl.Font=Enum.Font.GothamBlack;timerLbl.TextSize=24
    timerLbl.TextXAlignment=Enum.TextXAlignment.Center;timerLbl.ZIndex=32
    local shimmer=addShimmerToLabel(timerLbl,PINK,WHITE)
    task.spawn(function() local t=0;while timerLbl and timerLbl.Parent do t=t+0.04;shimmer.Offset=Vector2.new(math.sin(t)*0.5,0);task.wait(0.04) end end)
    -- Drag support
    local dragStart,dragStartPos,dragging=nil,nil,false
    card.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true;dragStart=inp.Position;dragStartPos=card.Position
            inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then
                        dragging=false
                        -- persist steal/info bar position
                        pcall(function()
                            local pos = frame.Position
                            stealBarPos = {sx=pos.X.Scale, ox=pos.X.Offset, sy=pos.Y.Scale, oy=pos.Y.Offset}
                            if type(saveConfig)=="function" then saveConfig() end
                        end)
                    end
                end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local d=inp.Position-dragStart
            card.Position=UDim2.new(dragStartPos.X.Scale,dragStartPos.X.Offset+d.X,dragStartPos.Y.Scale,dragStartPos.Y.Offset+d.Y)
        end
    end)
    -- Auto-countdown and destroy
    local startTime=tick();local conn
    conn=RunService.Heartbeat:Connect(function()
        local remaining=math.max(0,duration-(tick()-startTime))
        if remaining<=0 then conn:Disconnect();pcall(function() sg:Destroy() end)
        elseif timerLbl and timerLbl.Parent then timerLbl.Text=string.format("%.1f",remaining).."s" end
    end)
    return sg
end
local function onHumanoidStateChanged(old,new)
    local char=LP.Character;if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid");if not hum then return end
    local isRag=(new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll or new==Enum.HumanoidStateType.FallingDown)
    if isRag and not hum.PlatformStand and not activeBatBillboard then
        activeBatBillboard=createRagdollBillboard(2.5,"RAGDOLL",Color3.fromRGB(160,80,255))
        task.delay(2.6,function() if activeBatBillboard then pcall(function() activeBatBillboard:Destroy() end);activeBatBillboard=nil end end)
    end
end
local function onMedusaStateChanged()
    local char=LP.Character;if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum and hum.PlatformStand and not activeMedusaBillboard then
        activeMedusaBillboard=createRagdollBillboard(4.5,"STONE",Color3.fromRGB(255,255,255))
        task.delay(4.5,function() if activeMedusaBillboard then pcall(function() activeMedusaBillboard:Destroy() end);activeMedusaBillboard=nil end end)
    end
end
local function setupRagdollTriggers()
    local char=LP.Character;if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then hum.StateChanged:Connect(onHumanoidStateChanged);hum:GetPropertyChangedSignal("PlatformStand"):Connect(onMedusaStateChanged) end
end
local function getSpeedThemeColors()
    local th=getTheme()
    local accent=th and th.ACCENT or Color3.fromRGB(255,255,255)
    local accent2=th and th.ACCENT2 or Color3.fromRGB(220,220,220)
    local gray=th and th.GRAY or Color3.fromRGB(200,200,210)
    return accent,accent2,gray
end
local function applySpeedIndicatorTheme()
    local char=LP.Character;if not char then return end
    local head=char:FindFirstChild("Head");if not head then return end
    local bb=head:FindFirstChild("K7SpeedBB");if not bb then return end
    local accent,accent2,gray=getSpeedThemeColors()
    for _,lbl in ipairs(bb:GetChildren()) do
        if lbl:IsA("TextLabel") then
            if lbl.Name=="DiscordLbl" then
                lbl.TextColor3=gray
                local gr=lbl:FindFirstChildOfClass("UIGradient")
                if gr then gr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,gray),ColorSequenceKeypoint.new(0.5,accent),ColorSequenceKeypoint.new(1,gray)}) end
            else
                lbl.TextColor3=accent
                local gr=lbl:FindFirstChildOfClass("UIGradient")
                if gr then gr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,accent2),ColorSequenceKeypoint.new(0.5,accent),ColorSequenceKeypoint.new(1,accent2)}) end
            end
        end
    end
end
local function setupSpeedIndicator(char)
    local head=char:WaitForChild("Head",5);if not head then return end
    pcall(function()
        local old=head:FindFirstChild("K7SpeedBB")
        if old then old:Destroy() end
    end)
    speedLabel=nil
    local accent,accent2,gray=getSpeedThemeColors()
    local bb=Instance.new("BillboardGui")
    bb.Name="K7SpeedBB";bb.Size=UDim2.new(0,130,0,48);bb.StudsOffset=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=true;bb.MaxDistance=80;bb.Parent=head
    local discordLabel=Instance.new("TextLabel",bb)
    discordLabel.Name="DiscordLbl";discordLabel.Size=UDim2.new(1,0,0.38,0)
    discordLabel.BackgroundTransparency=1;discordLabel.Text="discord.gg/k7hub"
    discordLabel.TextColor3=gray;discordLabel.Font=Enum.Font.GothamBold
    discordLabel.TextScaled=true;discordLabel.TextStrokeTransparency=0.4
    speedLabel=Instance.new("TextLabel",bb)
    speedLabel.Name="SpeedLbl";speedLabel.Size=UDim2.new(1,0,0.55,0)
    speedLabel.Position=UDim2.new(0,0,0.38,0);speedLabel.BackgroundTransparency=1
    speedLabel.Text="0.0";speedLabel.TextColor3=accent
    speedLabel.Font=Enum.Font.GothamBold;speedLabel.TextScaled=true
    speedLabel.TextStrokeTransparency=0.35
    local gr1=addShimmerToLabel(speedLabel,accent2,accent)
    local gr2=addShimmerToLabel(discordLabel,gray,accent)
    task.spawn(function()
        local t=0
        while bb and bb.Parent do
            t=t+0.03
            pcall(function()
                gr1.Offset=Vector2.new(math.sin(t)*0.4,0)
                gr2.Offset=Vector2.new(math.sin(t)*0.4,0)
            end)
            task.wait(0.05)
        end
    end)
end
local function getActiveMoveSpeed()
    if laggerCarryActive then return LAGGER_CARRY_SPEED
    elseif laggerModeEnabled then return LAGGER_SPEED
    elseif carrySpeedActive then return CS
    else return NS end
end
local function getAutoPathSpeed()
    if laggerModeEnabled then return LAGGER_SPEED
    else return NS end
end


-- ============================================================
-- Movement: mass ApplyImpulse + CFrame displacement to HIT the set speed
-- (impulse alone under-delivers; CFrame makes studs/sec match the number)
-- ============================================================
local _moveDt = 1/60
local _speedActive = false
local _lastHorizSpeed = 0
local _actualSpeed = 0
local _lastPos = nil
local _lastPosT = 0

local function destroySpeedConstraint()
    _speedActive = false
end

local function clearSpeedConstraint()
    _speedActive = false
    _lastHorizSpeed = 0
end

-- Impulse to reach a target world velocity: impulse = (target - current) * mass
local function applyImpulseVel(part, targetVel)
    if not part or not part.Parent then return end
    pcall(function()
        local mass = part.AssemblyMass
        if not mass or mass ~= mass or mass <= 0 then mass = 1 end
        local current = part.AssemblyLinearVelocity
        local delta = targetVel - current
        part:ApplyImpulse(delta * mass)
    end)
end

local function applyVel(part, targetVel)
    applyImpulseVel(part, targetVel)
end

local function applyAngVel(part, targetAng)
    if not part or not part.Parent then return end
    pcall(function()
        local mass = part.AssemblyMass
        if not mass or mass <= 0 then mass = 1 end
        local current = part.AssemblyAngularVelocity
        local target = targetAng or Vector3.zero
        part:ApplyAngularImpulse((target - current) * mass * 0.35)
    end)
end

-- Drive horizontal speed with CFrame only (exact studs/sec = set number)
-- Impulse is NOT added here - stacking it made the counter read ~6 high.
-- Speed drive + active brake (kills residual XZ so you don't skate on uneven ground)
local _lastGroundNormalY = 1
local function sampleGround(hrp)
    -- pcall only returns ONE value from the fn; pack results in a table
    local ok, res = pcall(function()
        local origin = hrp.Position + Vector3.new(0, 2, 0)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local char = hrp.Parent
        if char then params.FilterDescendantsInstances = {char} end
        params.IgnoreWater = true
        local hit = workspace:Raycast(origin, Vector3.new(0, -8, 0), params)
        if hit and hit.Normal then
            return {ny = hit.Normal.Y, grounded = (hit.Distance < 4.2)}
        end
        return {ny = 1, grounded = false}
    end)
    if ok and type(res) == "table" and type(res.ny) == "number" then
        _lastGroundNormalY = res.ny
        return res.ny, res.grounded == true
    end
    return _lastGroundNormalY, false
end

local function setSpeedConstraint(hrp, horizVel)
    if not hrp or not hrp.Parent then return end
    local hx, hz = horizVel.X, horizVel.Z
    local mag = math.sqrt(hx * hx + hz * hz)
    _lastHorizSpeed = mag
    _speedActive = mag > 0.05
    if mag < 0.05 then return end

    pcall(function()
        local ny, grounded = sampleGround(hrp)
        local v = hrp.AssemblyLinearVelocity
        local mass = hrp.AssemblyMass
        if not mass or mass ~= mass or mass <= 0 then mass = 1 end

        local gain = 0.85
        if grounded then
            if ny < 0.55 then
                gain = 0.45
            elseif ny < 0.78 then
                gain = 0.62
            else
                gain = 0.9
            end
        else
            gain = 0.7
        end

        local target = Vector3.new(hx, v.Y, hz)
        hrp:ApplyImpulse((target - v) * mass * gain)
    end)
end

-- Hard-stop residual horizontal velocity when grounded & not intending to move
local function brakeHorizontal(hrp)
    if not hrp or not hrp.Parent then return end
    pcall(function()
        local ny, grounded = sampleGround(hrp)
        if not grounded then return end
        local v = hrp.AssemblyLinearVelocity
        local hx, hz = v.X, v.Z
        local hMag = math.sqrt(hx * hx + hz * hz)
        if hMag < 0.8 then
            if hMag > 0.05 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
            end
            return
        end
        local mass = hrp.AssemblyMass
        if not mass or mass ~= mass or mass <= 0 then mass = 1 end
        local target = Vector3.new(0, v.Y, 0)
        hrp:ApplyImpulse((target - v) * mass * 0.92)
    end)
end

local function applyCFrameMove(part, dirUnit, spd, dt)
    if not part or not part.Parent then return end
    if not dirUnit or dirUnit.Magnitude < 0.01 then return end
    _moveDt = dt or _moveDt
    setSpeedConstraint(part, Vector3.new(dirUnit.X, 0, dirUnit.Z).Unit * spd)
end

local function manualJumpBoost(boost)
    if not infJumpEnabled or infJumpMode~="manual" then return end
    local char=LP.Character;if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart");if root then applyVel(root, Vector3.new(root.AssemblyLinearVelocity.X,boost,root.AssemblyLinearVelocity.Z)) end
end
local function startHoldInfJump()
    if holdInfJumpConn then holdInfJumpConn:Disconnect() end
    holdInfJumpConn=RunService.Heartbeat:Connect(function()
        if not infJumpEnabled or infJumpMode~="hold" then return end
        local char=LP.Character;if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not root or not hum then return end
        local isJumpHeld=UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump==true)
        local cv=root.AssemblyLinearVelocity
        if isJumpHeld and cv.Y<35 then applyVel(root, Vector3.new(cv.X,55,cv.Z)) end
        cv=root.AssemblyLinearVelocity
        if cv.Y<-120 then applyVel(root, Vector3.new(cv.X,-120,cv.Z)) end
    end)
end
local function stopHoldInfJump() if holdInfJumpConn then holdInfJumpConn:Disconnect();holdInfJumpConn=nil end end
UIS.JumpRequest:Connect(function() manualJumpBoost(50) end)
UIS.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.Space and not UIS:GetFocusedTextBox() then
        task.delay(0.12,function() if UIS:IsKeyDown(Enum.KeyCode.Space) then manualJumpBoost(50) end end)
    end
end)
RunService.Heartbeat:Connect(function() if UIS:IsKeyDown(Enum.KeyCode.Space) then manualJumpBoost(50) end end)
-- blacklist/kick/insta-reset removed

_antiKickConns={}
enableAntiKick=function()
    antiKickEnabled=true
    task.spawn(function()
        while antiKickEnabled do
            task.wait(0.5)
            local char=LP.Character
            local found=false
            if char then
                for _,tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        local n=tool.Name:lower()
                        if n:find("brainrot") or n:find("skibidi") or n:find("toilet") then
                            found=true
                            break
                        end
                    end
                end
            end
            brainrotDetected=found
            if found then
                if autoBatEnabled then
                    autoBatEnabled=false
                    if stopBatAimbot then pcall(stopBatAimbot) end
                    if resetAutoBatMotion then pcall(resetAutoBatMotion) end
                    if autoBatSetVisual then autoBatSetVisual(false) end
                    if mobBtnRefs and mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
                end
                if autoLeftEnabled then
                    autoLeftEnabled=false
                    if stopAutoLeft then pcall(stopAutoLeft) end
                    if autoLeftSetVisual then autoLeftSetVisual(false) end
                    if mobBtnRefs and mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
                end
                if autoRightEnabled then
                    autoRightEnabled=false
                    if stopAutoRight then pcall(stopAutoRight) end
                    if autoRightSetVisual then autoRightSetVisual(false) end
                    if mobBtnRefs and mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
                end
            end
        end
    end)
end
disableAntiKick=function()
    antiKickEnabled=false;brainrotDetected=false
    for _,c in ipairs(_antiKickConns) do pcall(function() c:Disconnect() end) end;_antiKickConns={}
end


-- ============================================================
-- SAFE MODE (VYNX-style: lock combat during duel countdown / holding brainrot)
-- ============================================================
local function safeModeGetCountdownLabel()
    local ok, label = pcall(function()
        local pg = LP:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local top = pg:FindFirstChild("DuelsMachineTopFrame")
        if not top then return nil end
        local inner = top:FindFirstChild("DuelsMachineTopFrame") or top
        local timer = inner:FindFirstChild("Timer", true)
        if not timer then return nil end
        return timer:FindFirstChild("Label") or timer:FindFirstChildWhichIsA("TextLabel")
    end)
    return (ok and label) or nil
end
local function safeModeCountdownNumber(text)
    local t = tostring(text or ""):upper():gsub("^%s+", ""):gsub("%s+$", "")
    if t == "GO" or t == "START" or t == "READY" then return true end
    local n = tonumber(t)
    return n ~= nil and n >= 0 and n <= 10
end
local function safeModeInDuelCountdown()
    local label = safeModeGetCountdownLabel()
    return label and safeModeCountdownNumber(label.Text) or false
end
local function safeModeHoldingBrainrot()
    local ok, val = pcall(function() return LP:GetAttribute("Stealing") end)
    if ok and val == true then return true end
    local ok2, val2 = pcall(function() return LP:GetAttribute("AntiKick") end)
    if ok2 and val2 == true then return true end
    if brainrotDetected then return true end
    local char = LP.Character
    if not char then return false end
    local ok3, val3 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok3 and val3 == true then return true end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("brainrot") or n:find("skibidi") or n:find("toilet") then return true end
        end
    end
    return false
end
local function safeModeIsLocked()
    if not safeModeEnabled then return false end
    return safeModeInDuelCountdown() or safeModeHoldingBrainrot()
end
local function safeModeForceStop(reason)
    if autoBatEnabled then
        autoBatEnabled=false
        if stopBatAimbot then pcall(stopBatAimbot) end
        if autoBatSetVisual then autoBatSetVisual(false) end
        if mobBtnRefs and mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
    end
    if autoLeftEnabled then
        autoLeftEnabled=false
        if stopAutoLeft then pcall(stopAutoLeft) end
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobBtnRefs and mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
    end
    if autoRightEnabled then
        autoRightEnabled=false
        if stopAutoRight then pcall(stopAutoRight) end
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobBtnRefs and mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
    end
    if tpBatEnabled then
        tpBatEnabled=false
        if stopTPBat then pcall(stopTPBat) end
    end
end
local function safeModeTryStart()
    if safeModeIsLocked() then
        safeModeForceStop("SAFE MODE LOCK")
        return false
    end
    return true
end
local function enableSafeMode()
    safeModeEnabled = true
end
local function disableSafeMode()
    safeModeEnabled = false
end
if not _G._SafeModeMonitorStarted_K7 then
    _G._SafeModeMonitorStarted_K7 = true
    task.spawn(function()
        while true do
            task.wait(0.2)
            if safeModeEnabled and safeModeIsLocked() then
                safeModeForceStop("SAFE MODE LOCK")
            end
        end
    end)
end



KB={DropBrainrot={kb=nil,gp=nil},AutoLeft={kb=nil,gp=nil},AutoRight={kb=nil,gp=nil},AutoBat={kb=nil,gp=nil},TPBat={kb=nil,gp=nil},TPFloor={kb=nil,gp=nil},GuiHide={kb=nil,gp=nil},SpeedToggle={kb=nil,gp=nil},LaggerToggle={kb=nil,gp=nil},LaggerCarry={kb=nil,gp=nil},AntiDesync={kb=nil,gp=nil},LaggerPanel={kb=nil,gp=nil}}
AP_L1,AP_L2=Vector3.new(-476.47,-6.28,92.73),Vector3.new(-483.12,-4.95,94.81)
AP_R1,AP_R2=Vector3.new(-476.16,-6.52,25.62),Vector3.new(-483.06,-5.03,25.48)

local RAG_TP_CHECKPOINT_A=Vector3.new(-472.60,-7.00,57.52)
local RAG_TP_LEFT_B=Vector3.new(-472.65,-7.00,95.69)
local RAG_TP_LEFT_FINAL=Vector3.new(-483.59,-5.04,104.24)
local RAG_TP_RIGHT_B=Vector3.new(-471.76,-7.00,26.22)
local RAG_TP_RIGHT_FINAL=Vector3.new(-483.51,-5.10,18.89)
local RAG_TP_STEP_DELAY=0.12
local function ragdollTeleportTo(pos)
    local char=LP.Character;if not char or not char.Parent then return false end
    local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return false end
    local ok=pcall(function() char:PivotTo(CFrame.new(pos)) end)
    if not ok then ok=pcall(function() hrp.CFrame=CFrame.new(pos) end) end
    return ok
end
local function runRagdollTPSequence(side)
    local isLeft=side=="left"
    if isLeft then
        if not autoTPLeftEnabled or autoTPLeftBusy or not autoTPLeftRecovered then return end
        autoTPLeftBusy=true;autoTPLeftRecovered=false
    else
        if not autoTPRightEnabled or autoTPRightBusy or not autoTPRightRecovered then return end
        autoTPRightBusy=true;autoTPRightRecovered=false
    end
    task.spawn(function()
        local function enabled() return isLeft and autoTPLeftEnabled or (not isLeft and autoTPRightEnabled) end
        if enabled() then ragdollTeleportTo(RAG_TP_CHECKPOINT_A) end
        task.wait(RAG_TP_STEP_DELAY)
        if enabled() then ragdollTeleportTo(isLeft and RAG_TP_LEFT_B or RAG_TP_RIGHT_B) end
        task.wait(RAG_TP_STEP_DELAY)
        if enabled() then ragdollTeleportTo(isLeft and RAG_TP_LEFT_FINAL or RAG_TP_RIGHT_FINAL) end
        if isLeft then autoTPLeftBusy=false else autoTPRightBusy=false end
    end)
end
handleRagdollTPState=function(isRagdolled)
    if isRagdolled then
        if autoTPLeftEnabled then runRagdollTPSequence("left") end
        if autoTPRightEnabled then runRagdollTPSequence("right") end
    else
        autoTPLeftRecovered=true;autoTPRightRecovered=true
    end
end
Steal={AutoStealEnabled=false,StealRadius=69.8,StealDuration=1.3,StealMode="normal",StealRange=10,EntryDelay=0.3,HoldMax=2.6,Data={},plotCache={},plotCacheTime={},cachedPrompts={},promptCacheTime=0}
lastStealTick=0
isStealing,stealStartTime=false,nil
Conns={autoSteal=nil,antiRag=nil,batCounter=nil,anchor={}}
MEDUSA_COOLDOWN=25;batCounterDebounce=false
modeValLbl=nil;lastMoveDir=Vector3.new(0,0,0)
_lastRagExitTime=0  -- only re-apply lastMoveDir for a short window after ragdoll exit
MOVE_KEYS={[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true}
local function isRagdollState(hum)
    if not hum then return true end
    local st=hum:GetState()
    return hum.PlatformStand or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll
end

local function installAntiDropHooks()
    if antiDropHooksInstalled or typeof(hookmetamethod)~="function" then return end
    antiDropHooksInstalled=true

    local oldIndex
    oldIndex=hookmetamethod(game,"__index",newcclosure(function(self,key)
        if antiDropEnabled and (not checkcaller or not checkcaller()) and (key=="AssemblyLinearVelocity" or key=="Velocity") then
            local char=LP.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if typeof(self)=="Instance" and self:IsA("BasePart") and self.Name=="HumanoidRootPart" and hrp and self==hrp and self:IsDescendantOf(char) then
                return spoofedVelocity
            end
        end
        return oldIndex(self,key)
    end))

    local oldNewIndex
    oldNewIndex=hookmetamethod(game,"__newindex",newcclosure(function(self,key,value)
        if antiDropEnabled and (not checkcaller or not checkcaller()) and (key=="AssemblyLinearVelocity" or key=="Velocity") and typeof(value)=="Vector3" then
            local char=LP.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if typeof(self)=="Instance" and self:IsA("BasePart") and self.Name=="HumanoidRootPart" and hrp and self==hrp and self:IsDescendantOf(char) then
                spoofedVelocity=value
                return
            end
        end
        return oldNewIndex(self,key,value)
    end))
end

local function applyVelocitySpeed(speed)
    if not antiDropEnabled then return end
    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local root=char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root or hum.Health<=0 then return end

    local dir=hum.MoveDirection
    if dir.Magnitude>0.05 then
        pcall(function()
            if root.SetNetworkOwner then root:SetNetworkOwner(LP) end
        end)
        local unit=dir.Unit
        local y=root.AssemblyLinearVelocity.Y
        spoofedVelocity=Vector3.new(unit.X*16,y,unit.Z*16)
        pcall(function()
            root.AssemblyLinearVelocity=Vector3.new(unit.X*speed,y,unit.Z*speed)
        end)
    else
        spoofedVelocity=Vector3.new(0,root.AssemblyLinearVelocity.Y,0)
    end
end

local antiDropSimulationConn=RunService.PreSimulation:Connect(function()
    applyVelocitySpeed(speedValue)
end)

local function setupAntiDie(char)
    local humanoid=char:WaitForChild("Humanoid",5)
    if not humanoid then return end
    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if antiDropEnabled and humanoid.Health>0 and humanoid.Health<humanoid.MaxHealth then
            humanoid.Health=humanoid.MaxHealth
        end
    end)
    humanoid.Died:Connect(function()
        if antiDropEnabled then
            task.wait()
            pcall(function() humanoid.Health=humanoid.MaxHealth end)
        end
    end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("ResetButtonCallback",not antiDropEnabled and true or false)
    end)
end

if LP.Character then task.spawn(setupAntiDie,LP.Character) end
LP.CharacterAdded:Connect(function(char)
    task.spawn(setupAntiDie,char)
    task.wait(0.2)
    if antiDropEnabled then
        pcall(function() game:GetService("StarterGui"):SetCore("ResetButtonCallback",false) end)
    end
end)

enableAntiDrop=function()
    antiDropEnabled=true
    installAntiDropHooks()
    pcall(function() game:GetService("StarterGui"):SetCore("ResetButtonCallback",false) end)
end

disableAntiDrop=function()
    antiDropEnabled=false
    pcall(function() game:GetService("StarterGui"):SetCore("ResetButtonCallback",true) end)
end

startAntiBat=function()
    if antiBatConnection then antiBatConnection:Disconnect() end
    antiBatConnection=RunService.Heartbeat:Connect(function()
        if not antiBatEnabled then return end
        local character=LP.Character
        local rootPart=character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local originalVelocity=rootPart.Velocity
        rootPart.Velocity=Vector3.new(1000,rootPart.Velocity.Y,1000)
        task.spawn(function()
            RunService.RenderStepped:Wait()
            if antiBatEnabled and rootPart and rootPart.Parent then
                rootPart.Velocity=originalVelocity
            end
        end)
    end)
end

stopAntiBat=function()
    if antiBatConnection then
        antiBatConnection:Disconnect()
        antiBatConnection=nil
    end
end

local function isMyPlotByName(plotName)
    local ct=tick()
    if Steal.plotCache[plotName] ~= nil and (ct-(Steal.plotCacheTime[plotName] or 0)) < 2 then
        return Steal.plotCache[plotName]
    end
    local plots=workspace:FindFirstChild("Plots"); if not plots then Steal.plotCache[plotName]=false; Steal.plotCacheTime[plotName]=ct; return false end
    local plot=plots:FindFirstChild(plotName); if not plot then Steal.plotCache[plotName]=false; Steal.plotCacheTime[plotName]=ct; return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then
        local yb=sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            local r = yb.Enabled==true
            Steal.plotCache[plotName]=r; Steal.plotCacheTime[plotName]=ct
            return r
        end
        -- fallback: owner name on sign matches local display name
        local sg = sign:FindFirstChild("SurfaceGui")
        local frame = sg and sg:FindFirstChild("Frame")
        local lbl = frame and frame:FindFirstChild("TextLabel")
        if lbl and lbl.Text and lbl.Text ~= "Empty Base" then
            local owner = lbl.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
            local r = (owner == LP.DisplayName) or (owner == LP.Name)
            Steal.plotCache[plotName]=r; Steal.plotCacheTime[plotName]=ct
            return r
        end
    end
    Steal.plotCache[plotName]=false; Steal.plotCacheTime[plotName]=ct
    return false
end

local function collectPromptFromSpawn(sp)
    if not sp then return nil end
    local att = sp:FindFirstChild("PromptAttachment")
    if att then
        for _,child in ipairs(att:GetChildren()) do
            if child:IsA("ProximityPrompt") then return child end
        end
    end
    for _,child in ipairs(sp:GetDescendants()) do
        if child:IsA("ProximityPrompt") then return child end
    end
    return nil
end

local function grabConnectionFns(signal)
    local out = {}
    if not signal then return out end
    local list = nil
    pcall(function()
        if getconnections then
            list = getconnections(signal)
        elseif get_signal_cons then
            list = get_signal_cons(signal)
        end
    end)
    if type(list) ~= "table" then return out end
    for _,c in ipairs(list) do
        local fn = nil
        pcall(function() fn = c.Function or c.func or c.Fn end)
        if type(fn) == "function" then
            table.insert(out, fn)
        end
    end
    return out
end

-- Find nearest enemy podium prompt within StealRadius (prime range)
local function findNearestPromptTarget()
    local char = LP.Character
    if not char then return nil, nil, math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil, math.huge end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil, nil, math.huge end
    local nearest, nearestSp, dist = nil, nil, math.huge
    local radius = ((Steal.StealMode or "normal") == "semi") and (Steal.StealRange or 10) or (Steal.StealRadius or 60)
    for _, plot in ipairs(plots:GetChildren()) do
        if not isMyPlotByName(plot.Name) then
            local pods = plot:FindFirstChild("AnimalPodiums")
            if pods then
                for _, pod in ipairs(pods:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    local sp = base and base:FindFirstChild("Spawn")
                    if sp then
                        local d = (sp.Position - root.Position).Magnitude
                        if d <= radius and d < dist then
                            local prompt = collectPromptFromSpawn(sp)
                            if prompt then
                                nearest = prompt
                                nearestSp = sp
                                dist = d
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest, nearestSp, dist
end

local function distToSpawn(sp)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not sp then return math.huge end
    return (hrp.Position - sp.Position).Magnitude
end

local function buildStealCallbacks(prompt)
    if not prompt then return nil end
    if Steal.Data[prompt] then return Steal.Data[prompt] end
    local data = { hold = {}, trigger = {}, ready = true, useFallback = false }
    data.hold = grabConnectionFns(prompt.PromptButtonHoldBegan)
    data.trigger = grabConnectionFns(prompt.Triggered)
    if #data.hold == 0 and #data.trigger == 0 then
        data.useFallback = true
    end
    Steal.Data[prompt] = data
    return data
end

-- ============================================================
-- NEW AUTO STEAL LOGIC (logic only; no extra standalone GUI)
-- ============================================================
local STEAL_RADIUS = 69.8
local STEAL_DURATION = 1.3
local StealData = {}

local function getStealHRP()
    local c = LP.Character
    if c then
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    end
    return nil
end

local function isMyPlotByNameNew(pn)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(pn)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPromptNew()
    local hrp = getStealHRP()
    if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearest, dist = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByNameNew(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            local base = pod:FindFirstChild("Base")
            if not base then continue end
            local spawn = base:FindFirstChild("Spawn")
            if not spawn then continue end
            local d = (spawn.Position - hrp.Position).Magnitude
            if d <= STEAL_RADIUS and d < dist then
                local att = spawn:FindFirstChild("PromptAttachment")
                if att then
                    for _, prompt in ipairs(att:GetChildren()) do
                        if prompt:IsA("ProximityPrompt") and prompt.ActionText and prompt.ActionText:find("Steal") then
                            nearest, dist = prompt, d
                        end
                    end
                end
            end
        end
    end
    return nearest
end

local function updateNewStealProgress(p)
    if progressFill then
        progressFill.Size = UDim2.new(math.clamp(p, 0, 1), 0, 1, 0)
    end
    if setStealStatusText then
        setStealStatusText("STEALING", math.clamp(p, 0, 1))
    end
end

local function executeStealNew(prompt,forcedDuration,forcedEndTime)
    if isStealing or not prompt then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        if getconnections then
            pcall(function()
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end)
        end
    end

    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    stealStartTime = tick()

    task.spawn(function()
        local startTime = tick()
        local duration = tonumber(forcedDuration) or STEAL_DURATION
        local endAt = tonumber(forcedEndTime)
        for _, f in ipairs(data.hold) do pcall(f) end

        while true do
            local elapsed=tick()-startTime
            local remainingByClock=duration-elapsed
            local remainingByRagdoll=endAt and (endAt-workspace:GetServerTimeNow()) or remainingByClock
            local remaining=math.min(remainingByClock,remainingByRagdoll)
            if remaining<=0 then break end
            local progress=1-(remaining/duration)
            updateNewStealProgress(progress)
            task.wait()
        end

        updateNewStealProgress(1)
        for _, f in ipairs(data.trigger) do pcall(f) end
        task.wait(0.05)

        data.ready = true
        isStealing = false
        stealStartTime = nil
        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
        if Steal.AutoStealEnabled and setStealStatusText then setStealStatusText("SEARCHING") end
    end)
end

startAutoSteal=function()
    Steal.AutoStealEnabled = true
    if Conns.autoSteal then
        pcall(function() Conns.autoSteal:Disconnect() end)
        Conns.autoSteal = nil
    end
    Conns.autoSteal = RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        if ragdollSyncAutoStealEnabled then
            local c=LP.Character;local h=c and c:FindFirstChildOfClass("Humanoid")
            if h and isRagdollState(h) then return end
        end
        local success, prompt = pcall(findNearestPromptNew)
        if success and prompt then
            pcall(executeStealNew, prompt)
        end
    end)
end

scheduleRagdollSyncedSteal=function()
    if not ragdollSyncAutoStealEnabled or not Steal.AutoStealEnabled then return end
    ragdollStealScheduleToken+=1
    local token=ragdollStealScheduleToken
    task.spawn(function()
        local targetDuration=1.3
        local now=workspace:GetServerTimeNow()
        local endTime=LP:GetAttribute("RagdollEndTime")
        if type(endTime)~="number" or endTime<=now then
            endTime=now+(lastRagdollDuration or 2.5)
        end
        local targetStart=endTime-targetDuration
        while token==ragdollStealScheduleToken and ragdollSyncAutoStealEnabled and Steal.AutoStealEnabled and not isStealing do
            local char=LP.Character
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if not hum or not isRagdollState(hum) then return end
            local left=targetStart-workspace:GetServerTimeNow()
            if left<=0 then break end
            task.wait(math.min(left,0.005))
        end
        if token~=ragdollStealScheduleToken or not ragdollSyncAutoStealEnabled or not Steal.AutoStealEnabled or isStealing then return end
        local ok,prompt=pcall(findNearestPromptNew)
        if ok and prompt then
            local oldDuration=STEAL_DURATION
            STEAL_DURATION=targetDuration
            pcall(executeStealNew,prompt)
            STEAL_DURATION=oldDuration
        end
    end)
end
stopAutoSteal=function()
    Steal.AutoStealEnabled = false
    if Conns.autoSteal then
        pcall(function() Conns.autoSteal:Disconnect() end)
        Conns.autoSteal = nil
    end
    isStealing = false
    stealStartTime = nil
    updateNewStealProgress(0)
    if setStealStatusText then setStealStatusText("SEARCHING") end
end

-- ============================================================
-- INSTA RESET (logic only; mobile button is added below)
-- ============================================================
local AdaptResetCooldown = false
local AdaptResetThread = nil
local AdaptResetCharacter = nil
local AdaptResetSuccessful = false
local AdaptStopResetSequence = false
local AdaptCameraLocked = false
local AdaptLockedCameraCFrame = nil
local AdaptResetMaxDuration = 0.05

local function AdaptInstantReset()
    if AdaptResetCooldown then return end
    AdaptResetCooldown = true
    AdaptResetSuccessful = false
    AdaptStopResetSequence = false
    AdaptCameraLocked = false

    local character = LP.Character
    if not character then
        AdaptResetCooldown = false
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        AdaptResetCooldown = false
        return
    end

    local camera = workspace.CurrentCamera
    if camera then
        AdaptLockedCameraCFrame = camera.CFrame
        AdaptCameraLocked = true
        camera.CFrame = AdaptLockedCameraCFrame
    end

    AdaptResetCharacter = character
    local isRespawning = false

    AdaptResetThread = task.spawn(function()
        local attempts = 0
        local maxAttempts = 40
        local originalHipHeight = humanoid.HipHeight

        while character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning and not AdaptStopResetSequence do
            if LP.Character ~= character then
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

            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 or LP.Character ~= character then
                AdaptResetSuccessful = true
                break
            end

            attempts += 1
            if attempts >= maxAttempts then break end
            task.wait(AdaptResetMaxDuration)
        end

        if not AdaptResetSuccessful and character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning then
            pcall(function() humanoid.Health = 0 end)
            task.wait(0.1)
            if not character.Parent or humanoid.Health <= 0 then
                AdaptResetSuccessful = true
            end
        end

        if not AdaptResetSuccessful and character and character.Parent and humanoid then
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

        AdaptCameraLocked = false
        AdaptResetCooldown = false
        AdaptResetThread = nil
        AdaptResetCharacter = nil
        AdaptStopResetSequence = false
    end)
end

local function AdaptStopInstantReset()
    AdaptStopResetSequence = true
    if AdaptResetThread then
        pcall(task.cancel, AdaptResetThread)
        AdaptResetThread = nil
    end
    AdaptResetCooldown = false
    AdaptResetCharacter = nil
    AdaptCameraLocked = false
end

LP.CharacterAdded:Connect(function()
    AdaptStopInstantReset()
    AdaptResetSuccessful = false
    AdaptStopResetSequence = false
    AdaptCameraLocked = false
end)

RunService.RenderStepped:Connect(function()
    if AdaptCameraLocked and AdaptLockedCameraCFrame and workspace.CurrentCamera then
        workspace.CurrentCamera.CFrame = AdaptLockedCameraCFrame
    end
end)

_G.AdaptInstantReset = AdaptInstantReset
_G.AdaptStopInstantReset = AdaptStopInstantReset

-- Stepped full-descendant CanCollide strip REMOVED (caused physics instability / random deaths)
-- No-player-collision is handled once in applyNoPlayerCollision()

-- Impulse speed loop (mass-scaled ApplyImpulse every frame)
RunService.Heartbeat:Connect(function(dt)
    _moveDt = dt
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if isRagdollState(hum) then
        lastMoveDir = Vector3.new(0, 0, 0)
        _speedActive = false
        _lastHorizSpeed = 0
        brakeHorizontal(hrp)
        if speedLabel then speedLabel.Text = "0.0" end
        return
    end
    local spd = getActiveMoveSpeed()
    local moving = false
    local controlled = not autoBatEnabled and not tpBatEnabled and not autoLeftEnabled and not autoRightEnabled

    pcall(function()
        if hum.CameraOffset.Magnitude > 0.05 then
            hum.CameraOffset = Vector3.new(0, 0, 0)
        end
        -- Do NOT force Sit/WalkSpeed every frame (server anti-cheat + desync deaths)
    end)

    if controlled then
        local md = hum.MoveDirection
        if md.Magnitude > 0.05 then
            lastMoveDir = Vector3.new(md.X, 0, md.Z).Unit
            moving = true
            setSpeedConstraint(hrp, lastMoveDir * spd)
        else
            _speedActive = false
            _lastHorizSpeed = 0
            brakeHorizontal(hrp)
        end
    else
        brakeHorizontal(hrp)
    end

    if speedLabel then
        if moving or _speedActive then
            speedLabel.Text = string.format("%.1f", spd)
        else
            speedLabel.Text = "0.0"
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5);setupSpeedIndicator(char);setupRagdollTriggers()
    if medusaCounterEnabled then setupMedusa(char) end
    if batCounterEnabled then startBatCounter() end
    if unwalkEnabled then task.wait(0.5);startUnwalk() end
    -- old LinearVelocity dies with character; nothing to clean
end)
if LP.Character then setupSpeedIndicator(LP.Character);setupRagdollTriggers() end
alConn,arConn=nil,nil;alPhase,arPhase=1,1
stopAutoLeft=function()
    if alConn then alConn:Disconnect();alConn=nil end;alPhase=1
    local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
end
stopAutoRight=function()
    if arConn then arConn:Disconnect();arConn=nil end;arPhase=1
    local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
end
startAutoLeft=function()
    if alConn then alConn:Disconnect() end;alPhase=1
    alConn=RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char=LP.Character;if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero,false);return end
        local spd=getAutoPathSpeed()
        if alPhase==1 then
            local tgt=Vector3.new(AP_L1.X,hrp.Position.Y,AP_L1.Z)
            if (tgt-hrp.Position).Magnitude<1 then alPhase=2;local d=AP_L2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit;hum:Move(mv,false);setSpeedConstraint(hrp, Vector3.new(mv.X*spd, 0, mv.Z*spd));return end
            local d=AP_L1-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit;hum:Move(mv,false);setSpeedConstraint(hrp, Vector3.new(mv.X*spd, 0, mv.Z*spd))
        elseif alPhase==2 then
            local tgt=Vector3.new(AP_L2.X,hrp.Position.Y,AP_L2.Z)
            if (tgt-hrp.Position).Magnitude<1 then hum:Move(Vector3.zero,false);clearSpeedConstraint();autoLeftEnabled=false;if alConn then alConn:Disconnect();alConn=nil end;alPhase=1;if autoLeftSetVisual then autoLeftSetVisual(false) end;if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end;return end
            local d=AP_L2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit;hum:Move(mv,false);setSpeedConstraint(hrp, Vector3.new(mv.X*spd, 0, mv.Z*spd))
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
    arConn=RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char=LP.Character;if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart");local hum=char:FindFirstChildOfClass("Humanoid");if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero,false);return end
        local spd=getAutoPathSpeed()
        if arPhase==1 then
            local tgt=Vector3.new(AP_R1.X,hrp.Position.Y,AP_R1.Z)
            if (tgt-hrp.Position).Magnitude<1 then arPhase=2;local d=AP_R2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit;hum:Move(mv,false);setSpeedConstraint(hrp, Vector3.new(mv.X*spd, 0, mv.Z*spd));return end
            local d=AP_R1-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit;hum:Move(mv,false);setSpeedConstraint(hrp, Vector3.new(mv.X*spd, 0, mv.Z*spd))
        elseif arPhase==2 then
            local tgt=Vector3.new(AP_R2.X,hrp.Position.Y,AP_R2.Z)
            if (tgt-hrp.Position).Magnitude<1 then hum:Move(Vector3.zero,false);clearSpeedConstraint();autoRightEnabled=false;if arConn then arConn:Disconnect();arConn=nil end;arPhase=1;if autoRightSetVisual then autoRightSetVisual(false) end;if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end;return end
            local d=AP_R2-hrp.Position;local mv=Vector3.new(d.X,0,d.Z).Unit;hum:Move(mv,false);setSpeedConstraint(hrp, Vector3.new(mv.X*spd, 0, mv.Z*spd))
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

startAutoTPLeft=function()
    if autoTPLeftConn then autoTPLeftConn:Disconnect() end
    autoTPLeftConn=RunService.Heartbeat:Connect(function()
        if not autoTPLeftEnabled then return end
        local c=LP.Character;local h=c and c:FindFirstChildOfClass("Humanoid");if not h then return end
        handleRagdollTPState(isRagdollState(h))
    end)
end
stopAutoTPLeft=function() if autoTPLeftConn then autoTPLeftConn:Disconnect();autoTPLeftConn=nil end;autoTPLeftBusy=false;autoTPLeftRecovered=true end
startAutoTPRight=function()
    if autoTPRightConn then autoTPRightConn:Disconnect() end
    autoTPRightConn=RunService.Heartbeat:Connect(function()
        if not autoTPRightEnabled then return end
        local c=LP.Character;local h=c and c:FindFirstChildOfClass("Humanoid");if not h then return end
        handleRagdollTPState(isRagdollState(h))
    end)
end
stopAutoTPRight=function() if autoTPRightConn then autoTPRightConn:Disconnect();autoTPRightConn=nil end;autoTPRightBusy=false;autoTPRightRecovered=true end

-- Aimbot anti-fling (defined early so V1/TP bat can call it; strengthened later)
local ANTI_FLING_AIMBOT_LIN = 95
local ANTI_FLING_AIMBOT_ANG = 20
local function applyAimbotAntiFling(root)
    if not root or not root.Parent then return end
    pcall(function()
        local v = root.AssemblyLinearVelocity
        if v.Magnitude > ANTI_FLING_AIMBOT_LIN then
            root.AssemblyLinearVelocity = v.Unit * ANTI_FLING_AIMBOT_LIN
        end
        if root.AssemblyAngularVelocity.Magnitude > ANTI_FLING_AIMBOT_ANG then
            root.AssemblyAngularVelocity = Vector3.zero
        end
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") and p ~= root then
                    local pv = p.AssemblyLinearVelocity
                    if pv.Magnitude > ANTI_FLING_AIMBOT_LIN * 1.15 then
                        p.AssemblyLinearVelocity = pv.Unit * ANTI_FLING_AIMBOT_LIN
                    end
                    if p.AssemblyAngularVelocity.Magnitude > ANTI_FLING_AIMBOT_ANG then
                        p.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end
    end)
end

-- Drop is HARD-LOCKED: only armDrop()+runDrop from keybind/mobile button can fire it
local _dropToken = 0
local function armDrop()
    _dropToken = (_dropToken % 1000000) + 1
    return _dropToken
end
runDrop=function(expectedToken)
    -- require matching token from the same intentional press
    if expectedToken == nil or expectedToken ~= _dropToken then
        return
    end
    _dropToken = 0 -- consume so it cannot chain
    if dropActive then return end
    local char=LP.Character;if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart");if not root then return end
    dropActive=true;local t0=tick();local dc
    dc=RunService.Heartbeat:Connect(function()
        local r=char and char:FindFirstChild("HumanoidRootPart")
        if not r then dc:Disconnect();dropActive=false;return end
        if tick()-t0>=DROP_ASCEND_DURATION then
            dc:Disconnect()
            local rp=RaycastParams.new();rp.FilterDescendantsInstances={char};rp.FilterType=Enum.RaycastFilterType.Exclude
            local rr=workspace:Raycast(r.Position,Vector3.new(0,-2000,0),rp)
            if rr then local hum2=char:FindFirstChildOfClass("Humanoid");local off=(hum2 and hum2.HipHeight or 2);r.CFrame=CFrame.new(r.Position.X,rr.Position.Y+off,r.Position.Z);applyVel(r, Vector3.zero) end
            dropActive=false;return end
        applyVel(r, Vector3.new(r.AssemblyLinearVelocity.X,DROP_ASCEND_SPEED,r.AssemblyLinearVelocity.Z))
    end)
end
local autoTPPaused = false  -- true while bat aimbot / tp bat is active
local function doAutoTPDown(force)
    local char=LP.Character;if not char then return end;local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
    local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end
    if not force then if hum2.FloorMaterial~=Enum.Material.Air then return end;if not(hrp.Position.Y>=autoTPHeight) then return end end
    -- VYNX-style hard floor snap (Y = -7)
    local yaw=select(2,hrp.CFrame:ToEulerAnglesYXZ())
    hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)*CFrame.Angles(0,yaw,0)
    pcall(function() applyVel(hrp, Vector3.zero) end)
    pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)
    pcall(function() hrp.Velocity=Vector3.zero end)
end
local function pauseAutoTP()
    autoTPPaused = true
end
local function resumeAutoTP()
    autoTPPaused = false
end
startAutoTP=function()
    if autoTPConn then task.cancel(autoTPConn);autoTPConn=nil end
    autoTPConn=task.spawn(function()
        while autoTPEnabled do
            task.wait(0.1)
            if not autoTPPaused then
                pcall(function() doAutoTPDown(false) end)
            end
        end
    end)
end
stopAutoTP=function() autoTPEnabled=false;autoTPPaused=false;if autoTPConn then task.cancel(autoTPConn);autoTPConn=nil end end
runTPFloor=function() pcall(function() doAutoTPDown(true) end) end

-- ============================================================
-- MIRROR TP DOWN (teleport down when opponent drops while aimbot is on)
-- ============================================================
local function mirrorTPAimbotActive()
    return autoBatEnabled == true or tpBatEnabled == true or batAimbotEnabled == true
end

local function mirrorTPTeleportDown()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local now = tick()
    if now - (mirrorTPLastTeleport or 0) < 0.08 then return end
    mirrorTPLastTeleport = now
    local _, yaw = root.CFrame:ToEulerAnglesYXZ()
    local y = (MIRROR_TP_DOWN_Y or -7) + (math.random() * 0.6 - 0.3)
    root.CFrame = CFrame.new(root.Position.X, y, root.Position.Z) * CFrame.Angles(0, yaw, 0)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new((math.random()-0.5)*0.4, 0, (math.random()-0.5)*0.4)
    end)
    pcall(function() applyVel(root, Vector3.new((math.random()-0.5)*0.4, 0, (math.random()-0.5)*0.4)) end)
end

do
    local flagName = "_K7MirrorTPStarted"
    if not _G[flagName] then
        _G[flagName] = true
        RunService.Heartbeat:Connect(function()
            if not mirrorTPDownEnabled or not mirrorTPAimbotActive() then
                if next(mirrorTPPreviousY) then
                    table.clear(mirrorTPPreviousY)
                end
                return
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local currentY = root.Position.Y
                        local previousY = mirrorTPPreviousY[plr.UserId]
                        if previousY and previousY - currentY >= (MIRROR_TP_DROP_THRESHOLD or 3) then
                            pcall(mirrorTPTeleportDown)
                            table.clear(mirrorTPPreviousY)
                            return
                        end
                        mirrorTPPreviousY[plr.UserId] = currentY
                    end
                end
            end
        end)
    end
end

local function setMirrorTPDown(enabled)
    mirrorTPDownEnabled = enabled == true
    if not mirrorTPDownEnabled then
        table.clear(mirrorTPPreviousY)
    end
    if setMirrorTPVisual then setMirrorTPVisual(mirrorTPDownEnabled) end
end
defLightBrightness,defLightClock,defLightAmbient=nil,nil,nil
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
                if part.Anchored and part.Transparency == 1 then
            if medusaCounterEnabled then
                useMedusaCounter()
            end
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
BAT_COUNTER_SLAP_LIST={"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
local function findBatForCounter()
    local c=LP.Character;if not c then return nil end;local bp=LP:FindFirstChildOfClass("Backpack")
    for _,name in ipairs(BAT_COUNTER_SLAP_LIST) do local t=c:FindFirstChild(name) or (bp and bp:FindFirstChild(name));if t then return t end end
    for _,ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _,ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end
local function swingBatForCounter(bat,char)
    local hum2=char:FindFirstChildOfClass("Humanoid")
    if bat.Parent~=char then if hum2 then pcall(function() hum2:EquipTool(bat) end) end;task.wait(0.05) end
    local remote=bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then pcall(function() remote:FireServer() end);task.wait(0.15);pcall(function() remote:FireServer() end)
    else pcall(function() bat:Activate() end);task.wait(0.15);pcall(function() bat:Activate() end) end
end
startBatCounter=function()
    if Conns.batCounter then return end
    Conns.batCounter=RunService.Heartbeat:Connect(function()
        if not batCounterEnabled or batCounterDebounce then return end
        local char=LP.Character;if not char then return end;local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end
        local st=hum2:GetState()
        if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll then
            batCounterDebounce=true;task.spawn(function() local bat=findBatForCounter();if bat then swingBatForCounter(bat,char) end;task.wait(0.5);batCounterDebounce=false end)
        end
    end)
end
stopBatCounter=function() if Conns.batCounter then Conns.batCounter:Disconnect();Conns.batCounter=nil end;batCounterDebounce=false end
aimbotConn=nil
tpBatConn=nil
aimbotV2Conn=nil

-- ============================================================
-- VISION HUB BAT AIMBOT (ported into K7 as Auto Bat / normal)
-- ============================================================
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

local aimbotSpeed = 58
_aimbotTarget = nil
_aimbotTargetPlr = nil

local function getClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil, math.huge end
    local closest, closestPlr, minDist = nil, nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                    closestPlr = plr
                end
            end
        end
    end
    return closest, closestPlr, minDist
end

local function getStickyTarget(currentRoot)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local newClosest, newPlr, newDist = getClosestTarget()
    if not newClosest then return nil, nil end
    if currentRoot and currentRoot.Parent then
        local currentPlr = Players:GetPlayerFromCharacter(currentRoot.Parent)
        local hum = currentRoot.Parent:FindFirstChildOfClass("Humanoid")
        if currentPlr and hum and hum.Health > 0 then
            local currentDist = (currentRoot.Position - root.Position).Magnitude
            if currentPlr == newPlr or newDist > currentDist * 0.7 then
                return currentRoot, currentPlr
            end
        end
    end
    return newClosest, newPlr
end

local function swingCurrentBat(char)
    if not autoSwingEnabled then return end
    char = char or LP.Character
    if not char then return end
    local bat = findBat()
    if bat and bat.Parent == char and bat:IsA("Tool") then
        pcall(function() bat:Activate() end)
    end
end

-- Vision Hub style LOCKED target HUD
do
    task.spawn(function()
        task.wait(1.5)
        local sg = Instance.new("ScreenGui")
        sg.Name = "K7VisionAimbotTarget"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 40
        sg.IgnoreGuiInset = true
        pcall(function()
            if parentGui then parentGui(sg) else
                local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
                if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
            end
        end)
        local th = (type(getTheme) == "function" and getTheme()) or {}
        local bg = th.BG or Color3.fromRGB(8, 8, 10)
        local accent = th.ACCENT or Color3.fromRGB(190, 120, 255)
        local accent2 = th.ACCENT2 or Color3.fromRGB(218, 155, 255)
        local white = th.WHITE or Color3.fromRGB(235, 235, 240)

        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0, 200, 0, 36)
        f.Position = UDim2.new(0.5, -100, 0, 80)
        f.BackgroundColor3 = bg
        f.BackgroundTransparency = 0.12
        f.BorderSizePixel = 0
        f.Visible = false
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
        local st = Instance.new("UIStroke", f)
        st.Color = accent
        st.Thickness = 1
        st.Transparency = 0.2
        local stGrad = Instance.new("UIGradient", st)
        stGrad.Color = ColorSequence.new(accent, accent2)
        stGrad.Rotation = 0
        local lockTxt = Instance.new("TextLabel", f)
        lockTxt.Size = UDim2.new(0, 60, 1, 0)
        lockTxt.Position = UDim2.new(0, 10, 0, 0)
        lockTxt.BackgroundTransparency = 1
        lockTxt.Text = "LOCKED"
        lockTxt.TextColor3 = accent
        lockTxt.Font = Enum.Font.GothamBlack
        lockTxt.TextSize = 11
        lockTxt.TextXAlignment = Enum.TextXAlignment.Left
        local targetLabel = Instance.new("TextLabel", f)
        targetLabel.Size = UDim2.new(1, -76, 1, 0)
        targetLabel.Position = UDim2.new(0, 70, 0, 0)
        targetLabel.BackgroundTransparency = 1
        targetLabel.Text = ""
        targetLabel.TextColor3 = white
        targetLabel.Font = Enum.Font.GothamBlack
        targetLabel.TextSize = 12
        targetLabel.TextXAlignment = Enum.TextXAlignment.Left
        targetLabel.TextTruncate = Enum.TextTruncate.AtEnd
        local labelGrad = Instance.new("UIGradient", targetLabel)
        labelGrad.Color = ColorSequence.new(accent, accent2)
        labelGrad.Rotation = 0
        local rot = 0
        RunService.Heartbeat:Connect(function(dt)
            rot = (rot + (dt or 0.016) * 35) % 360
            stGrad.Rotation = rot
            -- refresh theme colors lightly
            local th2 = (type(getTheme) == "function" and getTheme()) or th
            local a = th2.ACCENT or accent
            lockTxt.TextColor3 = a
            st.Color = a
            if autoBatEnabled and _aimbotTargetPlr and _aimbotTargetPlr.Parent then
                local name = _aimbotTargetPlr.DisplayName or _aimbotTargetPlr.Name or "?"
                if targetLabel.Text ~= name then targetLabel.Text = name end
                if not f.Visible then f.Visible = true end
            else
                if f.Visible then f.Visible = false end
            end
        end)
    end)
end


-- Shared bat auto-equip for Normal / Bypass / TP Bat
local BAT_TOOL_NAMES = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
function ensureBatEquipped()
    local char = LP.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local function isBatTool(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local n = tostring(tool.Name):lower()
        if n:find("bat", 1, true) or n:find("slap", 1, true) or n:find("glove", 1, true) then return true end
        for _, name in ipairs(BAT_TOOL_NAMES) do
            if tool.Name == name then return true end
        end
        return false
    end
    -- already equipped?
    for _, ch in ipairs(char:GetChildren()) do
        if isBatTool(ch) then return ch end
    end
    -- backpack: exact names first
    local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    if bp and hum then
        for _, name in ipairs(BAT_TOOL_NAMES) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                pcall(function() hum:EquipTool(t) end)
                return t
            end
        end
        for _, t in ipairs(bp:GetChildren()) do
            if isBatTool(t) then
                pcall(function() hum:EquipTool(t) end)
                return t
            end
        end
    end
    return nil
end

-- ========== ACE AIMBOT SYSTEMS ==========
local AceAntiBypassAimbot = {conn = nil, swingCooldown = false, prevAutoRotate = nil}
local AceNormalAimbot = {conn = nil, target = nil, swingCooldown = false}

batAimbotEnabled = false
antiBatBypassLockEnabled = false
antiDesyncAimbotEnabled = false

AIMBOT_SPEED = 58
LAGGER_AIMBOT_SPEED = 40
local AceAntiBypassAimbotSpeed = 58
local AceAntiBypassLaggerAimbotSpeed = 40
ANTI_DESYNC_AIMBOT_SPEED = 58

local AceAntiBypassSlapList = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}

setBatAimbotVisual = setBatAimbotVisual
setAntiBatBypassLockVisual = setAntiBatBypassLockVisual
-- autoBatSetVisual is shared with GUI (do not localize/shadow)

function GetCurrentSpeedMode()
    if laggerCarryActive or laggerModeEnabled then return "Lagger"
    elseif carrySpeedActive then return "Carry"
    else return "Normal" end
end

function GetBatAimbotSpeed()
    local mode = GetCurrentSpeedMode()
    if mode == "Lagger" then return tonumber(LAGGER_AIMBOT_SPEED) or 40
    else return tonumber(AIMBOT_SPEED) or 58 end
end

function GetAntiBypassAimbotSpeed()
    local mode = GetCurrentSpeedMode()
    if mode == "Lagger" then return tonumber(AceAntiBypassLaggerAimbotSpeed) or 40
    else return tonumber(AceAntiBypassAimbotSpeed) or 58 end
end

function FindAimbotBat()
    return ensureBatEquipped()
end

function GetClosestAimbotTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then minDist = dist; closest = tRoot end
            end
        end
    end
    return closest
end

function AntiBypassGetClosest()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then minDist = dist; closest = tRoot end
            end
        end
    end
    return closest, minDist
end

function AntiBypassFindBat()
    return ensureBatEquipped()
end

function AntiBypassTrySwing()
    if AceAntiBypassAimbot.swingCooldown then return end
    AceAntiBypassAimbot.swingCooldown = true
    pcall(function()
        local char = LP.Character
        if not char then return end
        local bat = AntiBypassFindBat()
        if bat then
            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            pcall(function() bat:Activate() end)
        end
    end)
    task.delay(0.03, function()
        AceAntiBypassAimbot.swingCooldown = false
    end)
end

-- ========== BAT AIMBOT ==========
function StartBatAimbot()
    if AceNormalAimbot.conn then AceNormalAimbot.conn:Disconnect(); AceNormalAimbot.conn = nil end
    batAimbotEnabled = true
    autoBatEnabled = true
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate = false end

    AceNormalAimbot.conn = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        local c = LP.Character
        if not c then return end
        local root = c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if not c:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target = getClosestTarget()
        if not target then
            local bat = findBat()
            if bat then
                if bat.Parent ~= c then pcall(function() hum:EquipTool(bat) end) end
                pcall(function() bat:Activate() end)
            end
            return
        end
        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * 0.14 + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude < 0.05 then
            flatDir = root.CFrame.LookVector
        else
            flatDir = flatDir.Unit
        end
        local chaseSpeed = 58
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = math.clamp(yVel, -70, 110)
        local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)

        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local curCF = root.CFrame
            local diffCF = curCF:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            local tiltSpeed = 42
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(
                Vector3.new(rx * tiltSpeed, ry * tiltSpeed, rz * tiltSpeed)
            )
        end
        local bat = findBat()
        if bat then
            if bat.Parent ~= c then pcall(function() hum:EquipTool(bat) end) end
            pcall(function() bat:Activate() end)
        end
    end)
end

function StopBatAimbot()
    if AceNormalAimbot and AceNormalAimbot.conn then
        AceNormalAimbot.conn:Disconnect()
        AceNormalAimbot.conn = nil
    end
    batAimbotEnabled = false
    autoBatEnabled = false
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    if setBatAimbotVisual then setBatAimbotVisual(false) end
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobBtnRefs and mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
end

-- ========== ANTI BAT BYPASS LOCK ==========
function StartAntiBatBypassLock()
    if batAimbotEnabled then StopBatAimbot() end
    if antiBatBypassLockEnabled then
        if AceAntiBypassAimbot.conn then AceAntiBypassAimbot.conn:Disconnect(); AceAntiBypassAimbot.conn = nil end
    end
    antiBatBypassLockEnabled = true
    autoBatEnabled = true
    if AceAntiBypassAimbot.conn then AceAntiBypassAimbot.conn:Disconnect(); AceAntiBypassAimbot.conn = nil end
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        AceAntiBypassAimbot.prevAutoRotate = hum0.AutoRotate
        hum0.AutoRotate = false
    end
    pcall(function() if pauseAutoTP then pauseAutoTP() end end)
    pcall(ensureBatEquipped)

    local bypassTick = 0
    AceAntiBypassAimbot.conn = RunService.Heartbeat:Connect(function()
        if not antiBatBypassLockEnabled then return end
        bypassTick = bypassTick + 1
        if bypassTick % 8 == 0 then return end

        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local bat = ensureBatEquipped() or AntiBypassFindBat()
        if bat and bat.Parent ~= char then pcall(function() hum:EquipTool(bat) end) end
        local target, targetDist = AntiBypassGetClosest()
        if not target then return end
        local myPos = root.Position
        local targetPos = target.Position
        local direction = targetPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = Vector3.zero end
        local chaseSpeed = GetAntiBypassAimbotSpeed()
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = math.clamp(yVel, -70, 110)
        local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        local toTarget = targetPos - myPos
        if toTarget.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, targetPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5); ry = math.clamp(ry, -2.5, 2.5); rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42))
        end
        if autoSwingEnabled and targetDist <= 8 then AntiBypassTrySwing() end
    end)
    if setAntiBatBypassLockVisual then setAntiBatBypassLockVisual(true) end
    if autoBatSetVisual then autoBatSetVisual(true) end
    if mobBtnRefs and mobBtnRefs.autoBat then mobBtnRefs.autoBat(true) end
end

function StopAntiBatBypassLock()
    antiBatBypassLockEnabled = false
    autoBatEnabled = false
    if AceAntiBypassAimbot and AceAntiBypassAimbot.conn then
        AceAntiBypassAimbot.conn:Disconnect(); AceAntiBypassAimbot.conn = nil
    end
    if AceAntiBypassAimbot then AceAntiBypassAimbot.swingCooldown = false end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = (AceAntiBypassAimbot.prevAutoRotate == nil) and true or AceAntiBypassAimbot.prevAutoRotate end
    AceAntiBypassAimbot.prevAutoRotate = nil
    pcall(function() if not tpBatEnabled and resumeAutoTP then resumeAutoTP() end end)
    if setAntiBatBypassLockVisual then setAntiBatBypassLockVisual(false) end
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobBtnRefs and mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
end

-- ========== ANTI-DESYNC AIMBOT ==========
-- Backward compatibility with mobile / existing callers
startBatAimbot = StartBatAimbot
stopBatAimbot = function()
    StopBatAimbot()
    StopAntiBatBypassLock()
end
queueAutoBatStart = function()
    if antiKickEnabled and brainrotDetected then return end
    if autoLeftEnabled then autoLeftEnabled=false; if autoLeftSetVisual then autoLeftSetVisual(false) end; stopAutoLeft() end
    if autoRightEnabled then autoRightEnabled=false; if autoRightSetVisual then autoRightSetVisual(false) end; stopAutoRight() end
    -- aimbotMode: "normal" or "bypass"
    if aimbotMode == "bypass" then
        if batAimbotEnabled then StopBatAimbot() end
        StartAntiBatBypassLock()
    else
        if antiBatBypassLockEnabled then StopAntiBatBypassLock() end
        StartBatAimbot()
    end
end

resetAutoBatMotion=function()
    local char=LP.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hrp then applyVel(hrp, hrp.AssemblyLinearVelocity*0.3);applyAngVel(hrp, Vector3.zero) end
    if hum then hum.AutoRotate=true end
end

-- Prediction marker (used by TP Bat)
_predBall = nil
local function cleanupPredBall()
    if _predBall then
        pcall(function() _predBall:Destroy() end)
        _predBall = nil
    end
end
local function ensurePredBall(pos)
    pcall(function()
        if not _predBall or not _predBall.Parent then
            _predBall = Instance.new("Part")
            _predBall.Name = "K7PredBall"
            _predBall.Size = Vector3.new(0.6, 0.6, 0.6)
            _predBall.Shape = Enum.PartType.Ball
            _predBall.Material = Enum.Material.Neon
            _predBall.CanCollide = false
            _predBall.Anchored = true
            _predBall.CastShadow = false
            _predBall.Parent = workspace
        end
        local accent = (getTheme and getTheme() and getTheme().ACCENT) or Color3.fromRGB(190, 120, 255)
        _predBall.Color = accent
        _predBall.CFrame = CFrame.new(pos)
        _predBall.Transparency = 0.15
    end)
end

-- ============================================================
-- TP BAT (with built-in anti-die / god) - toggleable, isolated
-- ============================================================
local _tpGodConns = {}
local function _tpGodDisable()
    for _, c in ipairs(_tpGodConns) do
        pcall(function() c:Disconnect() end)
    end
    for i = #_tpGodConns, 1, -1 do _tpGodConns[i] = nil end
    pcall(function()
        local char = LP.Character
        if char then
            local ff = char:FindFirstChild("K7TPBatFF")
            if ff then ff:Destroy() end
            -- restore normal death behaviour (leaving these disabled caused random respawn loops)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.BreakJointsOnDeath = true
                hum.RequiresNeck = true
                pcall(function()
                    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                end)
            end
        end
    end)
end
local function _tpGodBindCharacter(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
    if not hum then return end
    local root = char:FindFirstChild("HumanoidRootPart")

    pcall(function()
        local oldFF = char:FindFirstChild("K7TPBatFF")
        if oldFF then oldFF:Destroy() end
        local ff = Instance.new("ForceField")
        ff.Name = "K7TPBatFF"
        ff.Visible = false
        ff.Parent = char
    end)

    pcall(function()
        hum.BreakJointsOnDeath = false
        hum.RequiresNeck = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum.Health = math.max(hum.Health, hum.MaxHealth)
        hum.MaxHealth = math.max(hum.MaxHealth, 100)
    end)

    local function forceAlive()
        if not tpBatEnabled then return end
        if not hum or not hum.Parent then return end
        pcall(function()
            hum.MaxHealth = math.max(hum.MaxHealth, 100)
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
            hum.BreakJointsOnDeath = false
            hum.RequiresNeck = false
            hum.PlatformStand = false
            hum.Sit = false
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
            end)
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Dead
                or st == Enum.HumanoidStateType.Physics
                or st == Enum.HumanoidStateType.Ragdoll
                or st == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            if root and root.Parent then
                local v = root.AssemblyLinearVelocity
                if v.Magnitude > 120 then
                    root.AssemblyLinearVelocity = v.Unit * 120
                end
                if root.AssemblyAngularVelocity.Magnitude > 20 then
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end
            if char and char.Parent and not char:FindFirstChild("K7TPBatFF") then
                local ff = Instance.new("ForceField")
                ff.Name = "K7TPBatFF"
                ff.Visible = false
                ff.Parent = char
            end
        end)
    end

    table.insert(_tpGodConns, hum.HealthChanged:Connect(forceAlive))
    table.insert(_tpGodConns, hum:GetPropertyChangedSignal("Health"):Connect(forceAlive))
    table.insert(_tpGodConns, hum.Died:Connect(function()
        if not tpBatEnabled then return end
        pcall(function()
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.PlatformStand = false
            if char and char.Parent and not char:FindFirstChild("K7TPBatFF") then
                local ff = Instance.new("ForceField")
                ff.Name = "K7TPBatFF"
                ff.Visible = false
                ff.Parent = char
            end
        end)
    end))
    table.insert(_tpGodConns, hum.StateChanged:Connect(function(_, new)
        if not tpBatEnabled then return end
        if new == Enum.HumanoidStateType.Dead
            or new == Enum.HumanoidStateType.Physics
            or new == Enum.HumanoidStateType.Ragdoll
            or new == Enum.HumanoidStateType.FallingDown then
            pcall(function()
                hum.Health = hum.MaxHealth
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end))
    table.insert(_tpGodConns, RunService.RenderStepped:Connect(forceAlive))
    table.insert(_tpGodConns, RunService.Stepped:Connect(forceAlive))
    table.insert(_tpGodConns, RunService.Heartbeat:Connect(forceAlive))
end
local function _tpGodEnable()
    _tpGodDisable()
    _tpGodBindCharacter(LP.Character)
    table.insert(_tpGodConns, LP.CharacterAdded:Connect(function(c)
        if not tpBatEnabled then return end
        task.wait(0.05)
        _tpGodBindCharacter(c)
    end))
end


local function getChar() return LP.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end


startTPBat=function()
    if tpBatConn then tpBatConn:Disconnect() end
    tpBatEnabled = true
    local hittingCooldown = false

    local function getBatTool()
        local char = LP.Character
        if not char then return nil end
        local tool = char:FindFirstChild("Bat")
        if tool then return tool end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then
                return t
            end
        end
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            tool = bp:FindFirstChild("Bat")
            if tool then tool.Parent = char; return tool end
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") and (t.Name:lower():find("bat") or t.Name:lower():find("slap")) then
                    t.Parent = char
                    return t
                end
            end
        end
        return nil
    end

    local function executeBatHit()
        if hittingCooldown then return end
        hittingCooldown = true
        pcall(function()
            local bat = getBatTool()
            if bat then
                bat:Activate()
                local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
                if remote then remote:FireServer() end
            end
        end)
        task.delay(0.08, function() hittingCooldown = false end)
    end

    tpBatConn = RunService.Heartbeat:Connect(function()
        if not tpBatEnabled then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end
        local target = getClosestTarget()
        if not target then return end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(hrp, "PhysicsRepRootPart", target)
            end
        end)
        local targetPosition = target.Position + Vector3.new(0, 0.9, 0)
        if (hrp.Position - targetPosition).Magnitude > 8 then
            hrp.CFrame = CFrame.new(targetPosition)
        end
        local camera = workspace.CurrentCamera
        if camera then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
        executeBatHit()
    end)
end

stopTPBat=function()
    tpBatEnabled = false
    if tpBatConn then
        tpBatConn:Disconnect()
        tpBatConn = nil
    end
end

-- compat aliases (old names)


resetAutoBatMotion=function()
    local char=LP.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hrp then applyVel(hrp, hrp.AssemblyLinearVelocity*0.3);applyAngVel(hrp, Vector3.zero) end
    if hum then hum.AutoRotate=true end
end
saveConfig=function()
    local ok, err = pcall(function()
        local function ks(e)
            if type(e)~="table" then return {kb=nil,gp=nil} end
            local ok, res = pcall(function()
                if e.kb then return {kb=e.kb.Name,gp=e.gp and e.gp.Name}
                elseif e.gp then return {gp=e.gp.Name}
                else return {kb=nil,gp=nil} end
            end)
            if ok and type(res)=="table" then return res end
            return {kb=nil,gp=nil}
        end
        local btnPos = {}
        pcall(function() btnPos = loadBtnPositions() or {} end)
        local cfg = {
            normalSpeed=NS, carrySpeed=CS,
            dropBrainrotKey=ks(KB.DropBrainrot), autoLeftKey=ks(KB.AutoLeft), autoRightKey=ks(KB.AutoRight),
            autoBatKey=ks(KB.AutoBat), tpBatKey=ks(KB.TPBat), laggerToggleKey=ks(KB.LaggerToggle),
            laggerCarryKey=ks(KB.LaggerCarry), tpFloorKey=ks(KB.TPFloor), 
            guiHideKey=ks(KB.GuiHide), speedToggleKey=ks(KB.SpeedToggle), antiDesyncKey=ks(KB.AntiDesync),
            grabRadius=Steal.StealRadius, stealDuration=Steal.StealDuration, stealMode=Steal.StealMode or "normal",
            antiRagdoll=antiRagdollEnabled==true,
            antiFling=true,
            playerEsp=playerEspEnabled==true,
            playerTracers=playerTracersEnabled==true,
            autoStealEnabled=Steal.AutoStealEnabled==true,
            infiniteJump=infJumpEnabled==true, infJumpMode=infJumpMode,
            medusaCounter=medusaCounterEnabled==true, batCounter=batCounterEnabled==true,
            carrySpeedActive=carrySpeedActive==true, laggerModeEnabled=laggerModeEnabled==true,
            laggerCarryActive=laggerCarryActive==true,
            laggerSpeed=LAGGER_SPEED, laggerCarrySpeed=LAGGER_CARRY_SPEED,
            autoBat=autoBatEnabled==true, tpBat=tpBatEnabled==true, aimbotMode=aimbotMode,

        animPack=animPack,
        stealBarPos=stealBarPos,
        animPackEnabled=animPackEnabled==true,
        headlessEnabled=headlessEnabled==true,
        korbloxEnabled=korbloxEnabled==true,
            autoSwing=autoSwingEnabled==true, unwalkEnabled=unwalkEnabled==true,
            antiLag=antiLagEnabled==true, autoTPEnabled=autoTPEnabled==true, autoTPHeight=autoTPHeight, mirrorTPDown=mirrorTPDownEnabled==true, autoTPLeftEnabled=autoTPLeftEnabled==true, autoTPRightEnabled=autoTPRightEnabled==true, ragdollSyncAutoSteal=ragdollSyncAutoStealEnabled==true, antiDrop=antiDropEnabled==true, antiBat=antiBatEnabled==true,
            guiTransparencyEnabled=guiTransparencyEnabled==true,
            mobileButtonsEnabled=mobileButtonsEnabled==true, mobileButtonsLocked=mobileButtonsLocked==true,
            uiLocked=uiLocked==true,
            mobileButtonsSize=mobileButtonsSize, circleButtonsEnabled=circleButtonsEnabled==true,
            antiKick=antiKickEnabled==true, safeMode=safeModeEnabled==true, fovValue=fovValue, perButtonDrag=true,
            skyTheme=currentSkyTheme, guiTheme=currentGuiTheme,
            autoMoveSwing=autoMoveSwingEnabled==true, autoMoveSwingInterval=autoMoveSwingInterval,
            ragdollGui=ragdollGuiEnabled==true, introEnabled=introEnabled==true,
            selectedIntroMusic=selectedIntroMusic, btnPositions=btnPos,
        }
        local encoded = HS:JSONEncode(cfg)
        local wrote = false
        pcall(function()
            writefile("k7duels.json", encoded)
            wrote = true
        end)
        pcall(function() writefile("K7DuelsConfig.json", encoded) end)
        -- session backup so re-execute in same game remembers even if FS flakes
        pcall(function()
            if getgenv then
                getgenv()._K7DuelsCfg = cfg
                getgenv()._K7IntroEnabled = cfg.introEnabled
            end
        end)
        if not wrote then
        end
    end)
    if not ok then
    end
end
task.spawn(function() while task.wait(5) do saveConfig() end end)
local function resetAllSettings()
    NS=60;CS=30;LAGGER_SPEED=15;LAGGER_CARRY_SPEED=24.5;carrySpeedActive=false;laggerModeEnabled=false;laggerCarryActive=false
    antiRagdollEnabled=false;infJumpEnabled=false;infJumpMode="manual"
    medusaCounterEnabled=false;batCounterEnabled=false;unwalkEnabled=false
    autoLeftEnabled=false;autoRightEnabled=false;autoBatEnabled=false;autoSwingEnabled=true;autoMoveSwingEnabled=false;ragdollStealScheduleToken+=1
    autoTPEnabled=false;autoTPHeight=30;mirrorTPDownEnabled=false;antiLagEnabled=false
    autoTPLeftEnabled=true;autoTPRightEnabled=false;ragdollSyncAutoStealEnabled=false;antiDropEnabled=false;antiBatEnabled=false;    Steal.AutoStealEnabled=false;Steal.StealRadius=69.8;Steal.StealDuration=1.3;Steal.StealRange=10
    guiTransparencyEnabled=false;mobileButtonsEnabled=true;mobileButtonsSize=80
    circleButtonsEnabled=false;antiKickEnabled=false;uiLocked=false;fovValue=80;fovIndex=1
    KB.DropBrainrot={kb=nil,gp=nil};KB.AutoLeft={kb=nil,gp=nil};KB.AutoRight={kb=nil,gp=nil}
    KB.AutoBat={kb=nil,gp=nil};KB.TPBat={kb=nil,gp=nil};KB.TPFloor={kb=nil,gp=nil}
    KB.GuiHide={kb=nil,gp=nil};KB.SpeedToggle={kb=nil,gp=nil};KB.LaggerToggle={kb=nil,gp=nil}
    KB.LaggerCarry={kb=nil,gp=nil};KB.AntiDesync={kb=nil,gp=nil};KB.LaggerPanel={kb=nil,gp=nil}
    if refreshSpeedModeLabel then refreshSpeedModeLabel() end
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end
    if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end
    if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end
    if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end
    stopBatAimbot();stopAutoSteal();stopAutoLeft();stopAutoRight();stopAutoTPLeft();stopAutoTPRight();stopAntiRagdoll();stopAutoTP();stopHoldInfJump();disableAntiDrop();stopAntiBat()
    if antiLagEnabled then disableAntiLag() end;saveConfig()
end
setInstaGrab,setInfJumpVisual,setAntiRagVisual,setMedusaVisual,setUnwalkVisual,setAntiLagVisual,setAutoSwingVisual=nil,nil,nil,nil,nil,nil,nil
setTranspVisual,setLockVisual,setMobVisual,setCircleBtnsVisual=nil,nil,nil,nil
normalBox,carryBox,laggerBox,laggerCarryBox,radInput,autoTPHeightBox,durationBox=nil,nil,nil,nil,nil,nil,nil
mainFrame=nil
mainGuiRef=nil
_persistentConns={}
local function trackConn(conn) table.insert(_persistentConns,conn);return conn end
local function clearPersistentConns() for _,c in ipairs(_persistentConns) do pcall(function() c:Disconnect() end) end;_persistentConns={} end

refreshSpeedModeLabel=function()
    if modeValLbl then
        if laggerCarryActive then modeValLbl.Text="Lagger Carry"
        elseif laggerModeEnabled then modeValLbl.Text="Lagger"
        elseif carrySpeedActive then modeValLbl.Text="Carry"
        else modeValLbl.Text="Normal" end
    end
    if laggerModePillRef and laggerModePillRef.pill and laggerModePillRef.dot then
        local pill=laggerModePillRef.pill;local dot=laggerModePillRef.dot;local on=laggerModeEnabled
        local PINK2=Color3.fromRGB(130,60,220);local OFF=Color3.fromRGB(20,14,38);local WHITE=Color3.fromRGB(255,255,255);local GRAY=Color3.fromRGB(180,150,165)
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and PINK2 or OFF}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=on and Color3.fromRGB(12,12,14) or GRAY}):Play()
    end
    if carryModePillRef and carryModePillRef.pill and carryModePillRef.dot then
        local pill=carryModePillRef.pill;local dot=carryModePillRef.dot;local on=carrySpeedActive
        local PINK2=Color3.fromRGB(130,60,220);local OFF=Color3.fromRGB(20,14,38);local WHITE=Color3.fromRGB(255,255,255);local GRAY=Color3.fromRGB(180,150,165)
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and PINK2 or OFF}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),BackgroundColor3=on and Color3.fromRGB(12,12,14) or GRAY}):Play()
    end
end
toggleCarryMode=function()
    carrySpeedActive = not carrySpeedActive
    if carrySpeedActive then
        laggerModeEnabled = false
        laggerCarryActive = false
    end
    refreshSpeedModeLabel()
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end
end
toggleLaggerMode=function()
    laggerModeEnabled = not laggerModeEnabled
    if laggerModeEnabled then
        carrySpeedActive = false
        laggerCarryActive = false
    end
    refreshSpeedModeLabel()
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end
end
toggleLaggerCarryMode=function()
    laggerCarryActive = not laggerCarryActive
    if laggerCarryActive then
        carrySpeedActive = false
        laggerModeEnabled = false
    end
    refreshSpeedModeLabel()
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end
end

-- ============================================================
-- RESPAWN SAFETY: reset humanoid death flags on every spawn
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.defer(function()
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if not hum then return end
        if tpBatEnabled then return end -- TP bat anti-die owns state while active
        pcall(function()
            hum.BreakJointsOnDeath = true
            hum.RequiresNeck = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
            -- clear any leftover physics ownership desync
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and sethiddenproperty then
                pcall(function() sethiddenproperty(root, "NetworkIsSleeping", false) end)
            end
        end)
    end)
end)

-- ============================================================
-- IMPROVED ANTI RAGDOLL (from new file)
-- ============================================================
antiRagdollCached = {}

local function cacheCharacterAntiRag()
    local char = LP.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum or not root then return false end

    antiRagdollCached = {
        character = char,
        humanoid = hum,
        root = root
    }

    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraSubject = hum
    end

    return true
end

local function isRagdolledAntiRag()
    local hum = antiRagdollCached.humanoid
    if not hum then return false end

    local state = hum:GetState()

    if state == Enum.HumanoidStateType.Physics
    or state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.FallingDown then
        return true
    end

    local endTime = LP:GetAttribute("RagdollEndTime")
    if endTime then
        local now = workspace:GetServerTimeNow()
        if (endTime - now) > 0 then
            return true
        end
    end

    return false
end

local function removeRagdollConstraints()
    for _, v in ipairs(antiRagdollCached.character:GetDescendants()) do
        if v:IsA("BallSocketConstraint") or 
           (v:IsA("Attachment") and v.Name:find("RagdollAttachment")) then
            pcall(function()
                v:Destroy()
            end)
        end
    end
end

local function forceExitRagdoll()
    local hum = antiRagdollCached.humanoid
    local root = antiRagdollCached.root

    if not hum or not root then return end
    if hum.Health <= 0 then return end   -- don't touch camera on dead humanoid

    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)

    hum:ChangeState(Enum.HumanoidStateType.Running)

    root.Anchored = false
    applyVel(root, Vector3.zero)
    applyAngVel(root, Vector3.zero)

    root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)

    local camera = workspace.CurrentCamera
    if camera and hum.Health > 0 and camera.CameraSubject ~= hum then
        camera.CameraSubject = hum
    end
end

startAntiRagdoll = function()
    if Conns.antiRag then return end
    local _arLastReset = 0
    Conns.antiRag = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local state = hum:GetState()
        -- Only real ragdoll physics - never treat Sit / Dead as ragdoll (caused self-move / fight)
        -- FallingDown is a NORMAL state (jumps/falls) - fighting it caused random respawns
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or hum.PlatformStand == true then
            local now = tick()
            if now - _arLastReset >= 0.03 then
                _arLastReset = now
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root or hum.Health <= 0 then return end
                pcall(function()
                    _lastRagExitTime = tick()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    applyVel(root, Vector3.zero)
                    root.AssemblyAngularVelocity = Vector3.zero
                    hum.PlatformStand = false
                    hum.Sit = false
                    hum.AutoRotate = true
                    if hum.JumpPower and hum.JumpPower <= 0 then hum.JumpPower = 50 end
                    if hum.WalkSpeed and hum.WalkSpeed <= 0 then hum.WalkSpeed = 16 end
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("Motor6D") then
                            obj.Enabled = true
                        elseif obj:IsA("Constraint") or obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint") then
                            obj.Enabled = true
                        elseif obj:IsA("BasePart") then
                            -- do not force CanCollide true (player no-collide system owns this)
                            pcall(function() applyVel(obj, Vector3.zero) end)
                            pcall(function() obj.AssemblyAngularVelocity = Vector3.zero end)
                        end
                    end
                    local cam = workspace.CurrentCamera
                    if cam then cam.CameraSubject = hum end
                    local PM = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
                    if PM then
                        local CM = PM:FindFirstChild("ControlModule")
                        if CM then
                            local okm, module = pcall(require, CM)
                            if okm and module and module.Enable then pcall(function() module:Enable() end) end
                        end
                    end
                end)
            else
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    hum.PlatformStand = false
                    hum.Sit = false
                end)
            end
        end
    end)
end

stopAntiRagdoll = function()
    if Conns.antiRag then
        Conns.antiRag:Disconnect()
        Conns.antiRag = nil
    end
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and workspace.CurrentCamera then
        workspace.CurrentCamera.CameraSubject = hum
    end
    if antiRagdollEnabled then
        stopAntiRagdoll()
        startAntiRagdoll()
    end
end)
startUnwalk=function()
    local c=LP.Character;if not c then return end;local hum=c:FindFirstChildOfClass("Humanoid")
    if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim=c:FindFirstChild("Animate");if anim then unwalkSavedAnimate=anim:Clone();anim:Destroy() end
end
stopUnwalk=function() local c=LP.Character;if c and unwalkSavedAnimate then unwalkSavedAnimate:Clone().Parent=c;unwalkSavedAnimate=nil end end

-- ============================================================
-- STEAL BAR
-- ============================================================



-- ============================================================
-- ANTI FLING / WALKFLING (always on - no toggle)
-- Global clamp + stronger protection while any aimbot is active
-- ============================================================
-- Raised thresholds so normal bumps/slopes are not clipped into slide/desync deaths
local ANTI_FLING_MAX_LIN = 160
local ANTI_FLING_MAX_ANG = 45
-- ANTI_FLING_AIMBOT_* already set earlier
local _antiFlingConn = nil

local function _antiFlingApply(root, char, maxLin, maxAng)
    if not root or not root.Parent then return end
    pcall(function()
        local v = root.AssemblyLinearVelocity
        local horiz = Vector3.new(v.X, 0, v.Z)
        local hMag = horiz.Magnitude
        -- Prefer clamping horizontal only so vertical (jumps / slopes) is preserved
        if hMag > maxLin then
            local scale = maxLin / hMag
            root.AssemblyLinearVelocity = Vector3.new(v.X * scale, v.Y, v.Z * scale)
        elseif v.Magnitude > maxLin * 1.35 then
            -- extreme full-vector only (true fling)
            root.AssemblyLinearVelocity = v.Unit * maxLin
        end
        local av = root.AssemblyAngularVelocity
        if av.Magnitude > maxAng then
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if char then
            for _, p in ipairs(char:GetChildren()) do
                if p:IsA("BasePart") and p ~= root then
                    local pv = p.AssemblyLinearVelocity
                    local ph = Vector3.new(pv.X, 0, pv.Z)
                    if ph.Magnitude > maxLin * 1.2 then
                        local scale = (maxLin * 1.05) / ph.Magnitude
                        p.AssemblyLinearVelocity = Vector3.new(pv.X * scale, pv.Y, pv.Z * scale)
                    end
                    if p.AssemblyAngularVelocity.Magnitude > maxAng then
                        p.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end
    end)
end

-- applyAimbotAntiFling defined earlier (near runDrop); global clamp uses _antiFlingApply below

local function startAntiFling()
    if _antiFlingConn then return end
    _antiFlingConn = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local aimOn = autoBatEnabled or tpBatEnabled
        local maxLin = aimOn and ANTI_FLING_AIMBOT_LIN or ANTI_FLING_MAX_LIN
        local maxAng = aimOn and ANTI_FLING_AIMBOT_ANG or ANTI_FLING_MAX_ANG
        _antiFlingApply(root, char, maxLin, maxAng)
    end)
end

-- always-on (no stop / no toggle)
task.spawn(function()
    task.wait(0.35)
    startAntiFling()
end)
LP.CharacterAdded:Connect(function()
    task.defer(startAntiFling)
end)

-- ============================================================
-- NO PLAYER COLLISION (local character ignores other players)
-- ============================================================
local _noPlayerColConn = nil
local _noPlayerColHB = nil
local function applyNoPlayerCollision()
    -- NEVER change local character CollisionGroup â€” that can break floor collision.
    -- Only disable collision on OTHER players' parts locally.
    pcall(function()
        local function stripOther(char)
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then stripOther(plr.Character) end
        end
        if not _noPlayerColConn then
            _noPlayerColConn = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.wait(0.15)
                    stripOther(char)
                end)
                if plr.Character then stripOther(plr.Character) end
            end)
        end
        if not _noPlayerColHB then
            _noPlayerColHB = RunService.Heartbeat:Connect(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        for _, part in ipairs(plr.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end)
end
task.spawn(function()
    task.wait(1)
    applyNoPlayerCollision()
end)

-- ============================================================
-- PLAYER ESP + TRACERS (theme color) + K7 user marker
-- ============================================================
local K7_MARKER = "K7DuelsMarker"
playerEspEnabled = playerEspEnabled or false
playerTracersEnabled = playerTracersEnabled or false
local _espFolder = nil
local _espConn = nil
local _espObjects = {} -- [player] = { highlight, billboard, tracer, beamAtt0, beamAtt1 }

local function getEspThemeColor()
    local th = (type(getTheme)=="function" and getTheme()) or nil
    return (th and th.ACCENT) or Color3.fromRGB(255, 255, 255)
end

local function getTracerBrightColor()
    local c = getEspThemeColor()
    -- push toward white so tracers pop more
    local r = math.min(1, c.R * 1.35 + 0.2)
    local g = math.min(1, c.G * 1.35 + 0.2)
    local b = math.min(1, c.B * 1.35 + 0.2)
    return Color3.new(r, g, b)
end

local function ensureEspFolder()
    if _espFolder and _espFolder.Parent then return _espFolder end
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("K7PlayerESP")
        if old then old:Destroy() end
    end)
    local f = Instance.new("Folder")
    f.Name = "K7PlayerESP"
    pcall(function()
        if _gethui then f.Parent = _gethui()
        else f.Parent = game:GetService("CoreGui") end
    end)
    if not f.Parent then
        pcall(function() f.Parent = LP:FindFirstChild("PlayerGui") end)
    end
    _espFolder = f
    return f
end

-- Silent K7 detection (NO chat).
-- Multi-property Player fingerprint (camera zoom + name display distance).
-- These Player properties replicate so other K7 clients can read them.
local _k7Users = {} -- [userId] = true
local K7_ZOOM_MAX = 127.89134
local K7_ZOOM_MIN = 0.41278
local K7_NAME_DIST = 101.337

local function markK7UserId(uid)
    if type(uid) == "number" and uid ~= LP.UserId then
        _k7Users[uid] = true
    end
end

-- ============================================================
-- K7 PRESENCE BACKEND (shared HTTP)
-- All K7 clients heartbeat into the same JSON blob so other
-- users running this source show "USING K7" above their head.
-- ============================================================
local K7_PRESENCE_URL = "https://jsonblob.com/api/jsonBlob/019fd958-1bb9-79ea-ac53-d695c6d450e6"
local K7_PRESENCE_TTL = 25 -- seconds; stale entries ignored
local _presenceLastPush = 0
local _presenceBusy = false

local function _presenceRequest(method, body)
    local resBody = nil
    if _request then
        local ok, res = pcall(function()
            local opts = {
                Url = K7_PRESENCE_URL,
                Method = method,
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Accept"] = "application/json",
                },
            }
            if body then opts.Body = body end
            return _request(opts)
        end)
        if ok and type(res) == "table" then
            resBody = res.Body or res.body or res.Data or res.data
        elseif ok and type(res) == "string" then
            resBody = res
        end
    end
    if not resBody and method == "GET" then
        pcall(function()
            resBody = game:HttpGet(K7_PRESENCE_URL)
        end)
    end
    return resBody
end

local function _presenceDecode(raw)
    if type(raw) ~= "string" or #raw < 2 then return nil end
    local ok, data = pcall(function() return HS:JSONDecode(raw) end)
    if ok and type(data) == "table" then return data end
    return nil
end

local function presencePush()
    do return end -- disabled: external HTTP presence can flag PC clients
    if _presenceBusy then return end
    _presenceBusy = true
    pcall(function()
        local jobId = tostring(game.JobId or "unknown")
        local uid = tostring(LP.UserId)
        local now = os.time()

        local data = _presenceDecode(_presenceRequest("GET")) or { v = 1, servers = {} }
        if type(data.servers) ~= "table" then data.servers = {} end
        if type(data.servers[jobId]) ~= "table" then data.servers[jobId] = {} end

        -- write self
        data.servers[jobId][uid] = now

        -- prune stale entries across all servers (keep map small)
        for jid, users in pairs(data.servers) do
            if type(users) == "table" then
                for u, ts in pairs(users) do
                    if type(ts) ~= "number" or (now - ts) > (K7_PRESENCE_TTL * 3) then
                        users[u] = nil
                    end
                end
                if next(users) == nil then
                    data.servers[jid] = nil
                end
            end
        end

        local encoded = HS:JSONEncode(data)
        _presenceRequest("PUT", encoded)
        _presenceLastPush = tick()
    end)
    _presenceBusy = false
end

local function presencePull()
    do return end -- disabled: external HTTP presence can flag PC clients
    pcall(function()
        local jobId = tostring(game.JobId or "unknown")
        local now = os.time()
        local data = _presenceDecode(_presenceRequest("GET"))
        if not data or type(data.servers) ~= "table" then return end
        local users = data.servers[jobId]
        if type(users) ~= "table" then return end
        for u, ts in pairs(users) do
            local uid = tonumber(u)
            if uid and uid ~= LP.UserId and type(ts) == "number" and (now - ts) <= K7_PRESENCE_TTL then
                markK7UserId(uid)
            end
        end
    end)
end

-- heartbeat loop (push + pull)
task.spawn(function()
    task.wait(1.2)
    while true do
        pcall(presencePush)
        pcall(presencePull)
        task.wait(4)
    end
end)

-- faster local tag refresh after pull
task.spawn(function()
    while true do
        task.wait(2)
        pcall(presencePull)
        pcall(function()
            if updateK7Tags then updateK7Tags() end
        end)
    end
end)

local function applyK7Fingerprint()
    -- Local-only fingerprint (no character StringValues/Billboards â€” those replicate and can trigger PC anti-cheat)
    pcall(function()
        LP.CameraMaxZoomDistance = K7_ZOOM_MAX
        LP.CameraMinZoomDistance = K7_ZOOM_MIN
        LP.NameDisplayDistance = K7_NAME_DIST
    end)
    pcall(function()
        if getgenv then
            getgenv()._K7DuelsFP = "v2"
            getgenv()._K7DuelsRunning = true
        end
    end)
end

local function placeK7Marker(char)
    applyK7Fingerprint()
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    placeK7Marker(char)
end)


local function _matchesK7FP(plr)
    if not plr then return false end
    -- Primary: character marker (replicates via character network ownership)
    local char = plr.Character
    if char then
        local marker = char:FindFirstChild(K7_MARKER, true)
        if marker then return true end
        local tag = char:FindFirstChild("K7DuelsTag", true)
        if tag then return true end
        local cAttrOk, cAttr = pcall(function() return char:GetAttribute("K7Duels") end)
        if cAttrOk and cAttr == true then return true end
    end
    local hits = 0
    local ok1, zmax = pcall(function() return plr.CameraMaxZoomDistance end)
    if ok1 and typeof(zmax) == "number" and math.abs(zmax - K7_ZOOM_MAX) < 0.002 then
        hits = hits + 1
    end
    local ok2, zmin = pcall(function() return plr.CameraMinZoomDistance end)
    if ok2 and typeof(zmin) == "number" and math.abs(zmin - K7_ZOOM_MIN) < 0.002 then
        hits = hits + 1
    end
    local ok3, nd = pcall(function() return plr.NameDisplayDistance end)
    if ok3 and typeof(nd) == "number" and math.abs(nd - K7_NAME_DIST) < 0.05 then
        hits = hits + 1
    end
    if hits >= 2 then return true end
    if hits >= 1 and ok1 and typeof(zmax) == "number" and math.abs(zmax - K7_ZOOM_MAX) < 0.0005 then
        return true
    end
    local attrOk, attr = pcall(function() return plr:GetAttribute("K7Duels") end)
    if attrOk and attr == true then return true end
    local fpOk, fp = pcall(function() return plr:GetAttribute("K7FP") end)
    if fpOk and fp == "v2" then return true end
    return false
end

local function isK7User(plr)
    if not plr or plr == LP then return false end
    if _k7Users[plr.UserId] then return true end
    if _matchesK7FP(plr) then
        markK7UserId(plr.UserId)
        return true
    end
    return false
end


-- Always-on "USING K7" tags (works even if Player ESP toggle is off)
local _k7TagFolder = nil
local function ensureK7TagFolder()
    if _k7TagFolder and _k7TagFolder.Parent then return _k7TagFolder end
    local f = Instance.new("Folder")
    f.Name = "K7UserTags"
    local parented = false
    pcall(function()
        if parentGui then parentGui(f); parented = f.Parent ~= nil end
    end)
    if not parented then
        pcall(function() f.Parent = game:GetService("CoreGui") end)
    end
    if not f.Parent then
        pcall(function() f.Parent = LP:WaitForChild("PlayerGui") end)
    end
    _k7TagFolder = f
    return f
end
local _k7Billboards = {}
local function updateK7Tags()
    local folder = ensureK7TagFolder()
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isK7User(plr) then
            seen[plr] = true
            local char = plr.Character
            local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
            if head then
                local o = _k7Billboards[plr]
                if not o or not o.Parent then
                    pcall(function() if o then o:Destroy() end end)
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "UsingK7_" .. tostring(plr.UserId)
                    bb.Size = UDim2.new(0, 220, 0, 36)
                    bb.StudsOffset = Vector3.new(0, 3.2, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 600
                    bb.Adornee = head
                    bb.Parent = folder
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "USING K7"
                    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    lbl.Font = Enum.Font.GothamBlack
                    lbl.TextSize = 18
                    lbl.TextStrokeTransparency = 0.15
                    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
                    _k7Billboards[plr] = bb
                else
                    o.Adornee = head
                    o.Enabled = true
                end
            end
        end
    end
    for plr, bb in pairs(_k7Billboards) do
        if not seen[plr] then
            pcall(function() bb:Destroy() end)
            _k7Billboards[plr] = nil
        end
    end
end
task.spawn(function()
    while true do
        task.wait(0.75)
        pcall(updateK7Tags)
    end
end)

-- Keep fingerprint applied every frame (games often reset zoom) + scan others often
task.spawn(function()
    applyK7Fingerprint()
    local acc = 0
    while true do
        RunService.Heartbeat:Wait()
        pcall(applyK7Fingerprint)
        acc = acc + 1
        if acc >= 30 then -- ~0.5s at 60fps
            acc = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP then
                    pcall(function()
                        if _matchesK7FP(plr) then
                            markK7UserId(plr.UserId)
                        end
                    end)
                end
            end
        end
    end
end)

local function clearEspFor(plr)
    local o = _espObjects[plr]
    if not o then return end
    if o.drawLine then
        pcall(function() o.drawLine.Visible = false; o.drawLine:Remove() end)
        o.drawLine = nil
    end
    for k, v in pairs(o) do
        pcall(function()
            if typeof(v)=="Instance" then v:Destroy() end
        end)
    end
    _espObjects[plr] = nil
end

local function clearAllEsp()
    for plr in pairs(_espObjects) do clearEspFor(plr) end
    _espObjects = {}
end

local function updatePlayerEsp(plr)
    if not plr or plr == LP then return end
    local char = plr.Character
    if not char then clearEspFor(plr); return end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    local head = char:FindFirstChild("Head")
    if not hrp then clearEspFor(plr); return end

    local color = getEspThemeColor()
    local folder = ensureEspFolder()
    local o = _espObjects[plr]
    if not o then o = {}; _espObjects[plr] = o end

    -- Highlight
    if playerEspEnabled then
        if not o.highlight or not o.highlight.Parent then
            pcall(function() if o.highlight then o.highlight:Destroy() end end)
            local hl = Instance.new("Highlight")
            hl.Name = "K7HL"
            hl.FillColor = color
            hl.OutlineColor = color
            hl.FillTransparency = 0.35
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = folder
            o.highlight = hl
        else
            o.highlight.FillColor = color
            o.highlight.OutlineColor = color
            o.highlight.FillTransparency = 0.35
            o.highlight.OutlineTransparency = 0
            o.highlight.Adornee = char
        end

        -- Name / USING K7 billboard (higher + larger)
        local usingK7 = isK7User(plr)
        local labelText = usingK7 and "USING K7" or (plr.DisplayName or plr.Name)
        local nameColor = usingK7 and Color3.fromRGB(255, 255, 255) or color
        if usingK7 then
            -- pure white + theme stroke so it reads clearly
            nameColor = Color3.new(
                math.min(1, color.R * 0.35 + 0.75),
                math.min(1, color.G * 0.35 + 0.75),
                math.min(1, color.B * 0.35 + 0.75)
            )
        end
        if not o.billboard or not o.billboard.Parent then
            pcall(function() if o.billboard then o.billboard:Destroy() end end)
            local bb = Instance.new("BillboardGui")
            bb.Name = "K7Name"
            bb.Size = UDim2.new(0, 240, 0, 42)
            bb.StudsOffset = Vector3.new(0, 4.8, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 500
            bb.Adornee = head or hrp
            bb.Parent = folder
            local lbl = Instance.new("TextLabel", bb)
            lbl.Name = "Lbl"
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = nameColor
            lbl.Font = Enum.Font.GothamBlack
            lbl.TextSize = usingK7 and 20 or 18
            lbl.TextStrokeTransparency = 0.2
            lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            o.billboard = bb
        else
            o.billboard.Adornee = head or hrp
            local lbl = o.billboard:FindFirstChild("Lbl")
            if lbl then
                lbl.Text = labelText
                lbl.TextColor3 = nameColor
                lbl.TextSize = usingK7 and 20 or 18
            end
        end
    else
        if o.highlight then pcall(function() o.highlight:Destroy() end); o.highlight = nil end
        if o.billboard then pcall(function() o.billboard:Destroy() end); o.billboard = nil end
    end

    -- Tracers: Drawing line (preferred) + workspace Beam fallback
    if playerTracersEnabled then
        local myChar = LP.Character
        local myHrp = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("UpperTorso"))
        if myHrp then
            local cam = workspace.CurrentCamera
            local tColor = getTracerBrightColor()
            local useDrawing = false
            pcall(function()
                if Drawing and Drawing.new then useDrawing = true end
            end)
            if useDrawing then
                if not o.drawLine then
                    local ok, line = pcall(function() return Drawing.new("Line") end)
                    if ok and line then
                        line.Thickness = 2
                        line.Transparency = 0.15
                        line.Visible = true
                        o.drawLine = line
                    end
                end
                if o.drawLine then
                    local ok1, p1, v1 = pcall(function()
                        local p, on = cam:WorldToViewportPoint(myHrp.Position)
                        return p, on
                    end)
                    local ok2, p2, v2 = pcall(function()
                        local p, on = cam:WorldToViewportPoint(hrp.Position)
                        return p, on
                    end)
                    if ok1 and ok2 and p1 and p2 then
                        local visible = (v1 ~= false) and (v2 ~= false) and p1.Z > 0 and p2.Z > 0
                        o.drawLine.From = Vector2.new(p1.X, p1.Y)
                        o.drawLine.To = Vector2.new(p2.X, p2.Y)
                        o.drawLine.Color = tColor
                        o.drawLine.Visible = visible
                    else
                        o.drawLine.Visible = false
                    end
                end
                -- cleanup beam path if switching
                if o.beam then pcall(function() o.beam:Destroy() end); o.beam = nil end
                if o.att0 then pcall(function() o.att0:Destroy() end); o.att0 = nil end
                if o.att1 then pcall(function() o.att1:Destroy() end); o.att1 = nil end
            else
                -- Beam must live in Workspace to render
                local wsFolder = workspace:FindFirstChild("K7TracersWS")
                if not wsFolder then
                    wsFolder = Instance.new("Folder")
                    wsFolder.Name = "K7TracersWS"
                    wsFolder.Parent = workspace
                end
                if not o.att0 or not o.att0.Parent then
                    pcall(function() if o.att0 then o.att0:Destroy() end end)
                    local a0 = Instance.new("Attachment")
                    a0.Name = "K7Trace0"
                    a0.Parent = myHrp
                    o.att0 = a0
                elseif o.att0.Parent ~= myHrp then
                    pcall(function() o.att0:Destroy() end)
                    local a0 = Instance.new("Attachment")
                    a0.Name = "K7Trace0"
                    a0.Parent = myHrp
                    o.att0 = a0
                end
                if not o.att1 or not o.att1.Parent then
                    pcall(function() if o.att1 then o.att1:Destroy() end end)
                    local a1 = Instance.new("Attachment")
                    a1.Name = "K7Trace1"
                    a1.Parent = hrp
                    o.att1 = a1
                elseif o.att1.Parent ~= hrp then
                    pcall(function() o.att1:Destroy() end)
                    local a1 = Instance.new("Attachment")
                    a1.Name = "K7Trace1"
                    a1.Parent = hrp
                    o.att1 = a1
                end
                if not o.beam or not o.beam.Parent then
                    pcall(function() if o.beam then o.beam:Destroy() end end)
                    local beam = Instance.new("Beam")
                    beam.Name = "K7Tracer"
                    beam.Attachment0 = o.att0
                    beam.Attachment1 = o.att1
                    beam.Color = ColorSequence.new(tColor)
                    beam.Width0 = 0.25
                    beam.Width1 = 0.18
                    beam.FaceCamera = true
                    beam.LightEmission = 1
                    beam.LightInfluence = 0
                    beam.Transparency = NumberSequence.new(0)
                    beam.Parent = wsFolder
                    o.beam = beam
                else
                    o.beam.Attachment0 = o.att0
                    o.beam.Attachment1 = o.att1
                    o.beam.Color = ColorSequence.new(tColor)
                end
            end
        end
    else
        if o.drawLine then
            pcall(function() o.drawLine.Visible = false; o.drawLine:Remove() end)
            o.drawLine = nil
        end
        if o.beam then pcall(function() o.beam:Destroy() end); o.beam = nil end
        if o.att0 then pcall(function() o.att0:Destroy() end); o.att0 = nil end
        if o.att1 then pcall(function() o.att1:Destroy() end); o.att1 = nil end
    end
end

local function refreshAllEsp()
    if not playerEspEnabled and not playerTracersEnabled then
        clearAllEsp()
        return
    end
    ensureEspFolder()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            pcall(updatePlayerEsp, plr)
        end
    end
    -- cleanup left players
    for plr in pairs(_espObjects) do
        if not plr.Parent or plr == LP then
            clearEspFor(plr)
        end
    end
end

startPlayerEsp = function()
    playerEspEnabled = true
    refreshAllEsp()
    if not _espConn then
        _espConn = RunService.Heartbeat:Connect(function()
            if not playerEspEnabled and not playerTracersEnabled then return end
            -- throttle lightly
            refreshAllEsp()
        end)
    end
end

stopPlayerEsp = function()
    playerEspEnabled = false
    if not playerTracersEnabled then
        if _espConn then _espConn:Disconnect(); _espConn = nil end
        clearAllEsp()
    else
        refreshAllEsp()
    end
end

startPlayerTracers = function()
    playerTracersEnabled = true
    refreshAllEsp()
    if not _espConn then
        _espConn = RunService.Heartbeat:Connect(function()
            if not playerEspEnabled and not playerTracersEnabled then return end
            refreshAllEsp()
        end)
    end
end

stopPlayerTracers = function()
    playerTracersEnabled = false
    if not playerEspEnabled then
        if _espConn then _espConn:Disconnect(); _espConn = nil end
        clearAllEsp()
    else
        refreshAllEsp()
    end
end

-- keep fingerprint/marker on our character
task.spawn(function()
    local function onChar(char)
        task.wait(0.25)
        placeK7Marker(char)
    end
    if LP.Character then onChar(LP.Character) end
    LP.CharacterAdded:Connect(onChar)
end)
Players.PlayerRemoving:Connect(function(plr)
    clearEspFor(plr)
    if plr then _k7Users[plr.UserId] = nil end
end)


local function createStealBar()
    -- destroy old
    pcall(function()
        if destroyOldGui then destroyOldGui("K7InfoBar") end
        if destroyOldGui then destroyOldGui("K7StealBar") end
        local cg=game:GetService("CoreGui")
        for _,n in ipairs({"K7InfoBar","K7StealBar"}) do
            local o=cg:FindFirstChild(n); if o then o:Destroy() end
        end
        local pg=LP:FindFirstChild("PlayerGui")
        if pg then
            for _,n in ipairs({"K7InfoBar","K7StealBar"}) do
                local o=pg:FindFirstChild(n); if o then o:Destroy() end
            end
        end
    end)

    -- theme colors into C-like table for the info bar
    local th = (type(getTheme)=="function" and getTheme()) or {}
    C = C or {}
    C.infoBg = th.STEAL_BG or th.BG or Color3.fromRGB(2,12,2)
    C.infoBrd = th.STEAL_ACCENT or th.ACCENT or Color3.fromRGB(0,255,100)
    C.infoVal = th.WHITE or Color3.fromRGB(0,255,100)
    C.infoTxt = th.GRAY or Color3.fromRGB(0,130,50)
    C.accent = th.STEAL_FILL or th.ACCENT or Color3.fromRGB(0,255,100)
    C.pillOff = th.BG2 or Color3.fromRGB(0,25,10)
    C.winBg = th.BG or C.infoBg
    C.winBorder = C.infoBrd
    C.topTitle = C.infoVal

    local function mkCorner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 6); return c end
    local function mkStroke(p,col,thk)
        local s=Instance.new("UIStroke",p); s.Color=col; s.Thickness=thk or 1
        s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s
    end
    local function makeDraggable(frame,handle)
        local src=handle or frame
        local dragging,dragStart,startPos=false,nil,nil
        src.InputBegan:Connect(function(inp)
            if uiLocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=inp.Position; startPos=frame.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then
                        dragging=false
                        -- persist steal/info bar position
                        pcall(function()
                            local pos = frame.Position
                            stealBarPos = {sx=pos.X.Scale, ox=pos.X.Offset, sy=pos.Y.Scale, oy=pos.Y.Offset}
                            if type(saveConfig)=="function" then saveConfig() end
                        end)
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if uiLocked then dragging=false; return end
            if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                local dx=inp.Position.X-dragStart.X; local dy=inp.Position.Y-dragStart.Y
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+dx,startPos.Y.Scale,startPos.Y.Offset+dy)
            end
        end)
    end

-- INFO BAR
-- ============================================================
-- Steal / info bar (from K7 Impulse script)
local infoBarGui = Instance.new("ScreenGui")
infoBarGui.Name = "K7InfoBar"
infoBarGui.ResetOnSpawn = false
infoBarGui.IgnoreGuiInset = true
infoBarGui.DisplayOrder = 12
if parentGui then parentGui(infoBarGui) else infoBarGui.Parent = LP:FindFirstChild("PlayerGui") or game:GetService("CoreGui") end
local infoBar = Instance.new("Frame", infoBarGui)
infoBar.Size = UDim2.new(0, 360, 0, 54)
do
        local p = stealBarPos
        if type(p)=="table" and p.sx ~= nil then
            infoBar.Position = UDim2.new(p.sx, p.ox, p.sy, p.oy)
        else
            infoBar.Position = UDim2.new(0.5, -180, 1, -68)
        end
    end
infoBar.BackgroundColor3 = C.infoBg
infoBar.BackgroundTransparency = 0.08; infoBar.BorderSizePixel = 0; infoBar.Active = true
mkCorner(infoBar, 10); mkStroke(infoBar, C.infoBrd, 1)
makeDraggable(infoBar)

-- Profile avatar (circle, far left)
do
    local avRing = Instance.new("Frame", infoBar)
    avRing.Name = "AvatarRing"
    avRing.Size = UDim2.new(0, 36, 0, 36)
    avRing.Position = UDim2.new(0, 8, 0.5, -18)
    avRing.BackgroundColor3 = C.infoBrd
    avRing.BorderSizePixel = 0
    avRing.ZIndex = 3
    mkCorner(avRing, 18)
    local av = Instance.new("ImageLabel", avRing)
    av.Name = "Avatar"
    av.Size = UDim2.new(1, -2, 1, -2)
    av.Position = UDim2.new(0, 1, 0, 1)
    av.BackgroundColor3 = C.infoBg
    av.BorderSizePixel = 0
    av.ScaleType = Enum.ScaleType.Crop
    av.ZIndex = 4
    mkCorner(av, 17)
    pcall(function()
        av.Image = Players:GetUserThumbnailAsync(
            LP.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
end

do
    local ibAcc = Instance.new("Frame", infoBar)
    ibAcc.Size = UDim2.new(0, 2, 0.55, 0); ibAcc.Position = UDim2.new(0, 0, 0.225, 0)
    ibAcc.BackgroundColor3 = C.accent; ibAcc.BorderSizePixel = 0; ibAcc.BackgroundTransparency = 0.2
    mkCorner(ibAcc, 2)
end

local stealLbl = Instance.new("TextLabel", infoBar)
stealLbl.Size = UDim2.new(1, -120, 0, 16); stealLbl.Position = UDim2.new(0, 50, 0, 8)
stealLbl.BackgroundTransparency = 1; stealLbl.Text = formatRadDurPing and formatRadDurPing() or ("RAD: "..tostring(Steal.StealRadius).."  DUR: "..tostring(Steal.StealDuration).."s")
stealLbl.TextColor3 = C.infoVal; stealLbl.Font = Enum.Font.GothamMedium; stealLbl.TextSize = 10
stealLbl.TextXAlignment = Enum.TextXAlignment.Left
stealLbl.TextTruncate = Enum.TextTruncate.AtEnd

local stealPctLbl = Instance.new("TextLabel", infoBar)
stealPctLbl.Size = UDim2.new(0, 78, 0, 16); stealPctLbl.Position = UDim2.new(1, -86, 0, 8)
stealPctLbl.BackgroundTransparency = 1; stealPctLbl.Text = "SEARCHING"; stealPctLbl.TextColor3 = C.infoVal
stealPctLbl.Font = Enum.Font.GothamBold; stealPctLbl.TextSize = 11
stealPctLbl.TextXAlignment = Enum.TextXAlignment.Right

function getPingMs()
    local ms = 0
    pcall(function()
        local Stats = game:GetService("Stats")
        local item = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            or Stats.Network.ServerStatsItem["Data Ping"]
        if item then
            local v = item:GetValue()
            if type(v) == "number" then
                ms = math.floor(v + 0.5)
            elseif type(v) == "string" then
                ms = math.floor(tonumber((v:match("[%d%.]+")) or 0) + 0.5)
            end
        end
    end)
    if ms <= 0 then
        pcall(function()
            ms = math.floor(((LP:GetNetworkPing() or 0) * 1000) + 0.5)
        end)
    end
    return math.max(0, ms)
end

function formatStealPct(prog)
    local pct = math.floor((prog or 0) * 100)
    return pct .. "%"
end

function getUniverseClock()
    local t = os.date("*t")
    local h = t.hour
    local m = t.min
    local ampm = "AM"
    if h >= 12 then
        ampm = "PM"
        if h > 12 then h = h - 12 end
    end
    if h == 0 then h = 12 end
    return string.format("%d:%02d %s", h, m, ampm)
end

function getExecutorName()
    local name = nil
    pcall(function()
        if identifyexecutor then
            local a, b = identifyexecutor()
            name = a or b
        end
    end)
    if not name or name == "" then
        pcall(function()
            if getexecutorname then name = getexecutorname() end
        end)
    end
    if not name or name == "" then
        pcall(function()
            if syn then name = "Synapse" end
            if fluxus then name = "Fluxus" end
            if is_sirhurt_closure then name = "Sirhurt" end
            if secure_load then name = "Sentinel" end
            if KRNL_LOADED then name = "Krnl" end
            if getgenv and getgenv().IS_VORB_LOADED then name = "Vorb" end
        end)
    end
    if type(name) ~= "string" or name == "" then name = "Unknown" end
    -- short display
    name = tostring(name):gsub("^%s+", ""):gsub("%s+$", "")
    if #name > 12 then name = name:sub(1, 12) end
    return name
end

_executorNameCache = nil
function formatRadDurPing()
    if not _executorNameCache then
        pcall(function() _executorNameCache = getExecutorName() end)
        _executorNameCache = _executorNameCache or "Unknown"
    end
    return "RAD: "..tostring(Steal.StealRadius).."  DUR: "..tostring(Steal.StealDuration).."s  |  "..tostring(getPingMs()).."ms  |  "..getUniverseClock().."  |  ".._executorNameCache
end

function setStealStatusText(status, extra)
    if status == "SEARCHING" then
        stealPctLbl.Text = "SEARCHING"
    elseif status == "STEALING" then
        stealPctLbl.Text = formatStealPct(extra or 0)
    elseif status == "STOLE" then
        stealPctLbl.Text = "STOLE!"
    else
        stealPctLbl.Text = tostring(status)
    end
end

progressFill = progressFill
do
    local pTrack = Instance.new("Frame", infoBar)
    pTrack.Size = UDim2.new(1, -58, 0, 16); pTrack.Position = UDim2.new(0, 50, 0, 30)
    pTrack.BackgroundColor3 = C.pillOff; pTrack.BorderSizePixel = 0; mkCorner(pTrack, 4)
    progressFill = Instance.new("Frame", pTrack)
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = C.accent; progressFill.BorderSizePixel = 0; mkCorner(progressFill, 5)
end

radTB = Instance.new("TextBox", infoBar)
radTB.Size = UDim2.new(0, 0, 0, 0); radTB.Position = UDim2.new(0, 0, 0, 0)
radTB.BackgroundTransparency = 1; radTB.TextTransparency = 1; radTB.Text = tostring(Steal.StealRadius)
radTB.ClearTextOnFocus = false; radTB.ZIndex = -1; radTB.Active = false
radTB.FocusLost:Connect(function()
    local n = tonumber(radTB.Text)
    if n and n >= 5 and n <= 300 then Steal.StealRadius = math.floor(n); Steal.cachedPrompts = {}; Steal.promptCacheTime = 0 end
    radTB.Text = tostring(Steal.StealRadius)
    if stealRadBox and not stealRadBox:IsFocused() then stealRadBox.Text = tostring(Steal.StealRadius) end
    stealLbl.Text = formatRadDurPing()
end)

do
    task.spawn(function()
        while task.wait(0.25) do
            pcall(function()
                if stealRadBox and not stealRadBox:IsFocused() then stealRadBox.Text = tostring(Steal.StealRadius) end
                stealLbl.Text = formatRadDurPing()
                if not isStealing then
                    if Steal.AutoStealEnabled then
                        setStealStatusText("SEARCHING")
                    else
                        stealPctLbl.Text = formatStealPct(0)
                    end
                end
            end)
        end
    end)
end

-- ============================================================
-- HELPERS
-- ============================================================
function resetProgressBar()
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    if Steal.AutoStealEnabled then
        setStealStatusText("SEARCHING")
    else
        stealPctLbl.Text = formatStealPct(0)
    end
end


    stealBarFrame = infoBar -- compat alias for any code that references steal bar frame
end

local function destroyMobileButtons()
    pcall(saveBtnPositions) -- persist before destroy
    if mobViewportConn then pcall(function() mobViewportConn:Disconnect() end);mobViewportConn=nil end
    if mobGuiRef then pcall(function() mobGuiRef:Destroy() end);mobGuiRef=nil end
    for _,n in ipairs({"K7MobileButtons"}) do
        local old=game:GetService("CoreGui"):FindFirstChild(n);if old then old:Destroy() end
        local pgui=LP:FindFirstChild("PlayerGui");if pgui then local o=pgui:FindFirstChild(n);if o then o:Destroy() end end
    end
    mobBtnRefs={}
end
local function buildMobileButtons()
    destroyMobileButtons();if not mobileButtonsEnabled then return end
    perButtonDragEnabled=true -- always drag each button independently
    local savedPositions=loadBtnPositions()

    -- OLD size formula restored (mobileButtonsSize default=80 -> BTN_SIZE=44)
    local BTN_SIZE=math.floor(mobileButtonsSize*0.55)
    local BTN_GAP=12
    local CORNER_R=circleButtonsEnabled and BTN_SIZE or math.max(8,math.floor(BTN_SIZE*0.22))
    local fontSize=math.max(7,math.floor(mobileButtonsSize*0.10))

    -- Mobile buttons (2 cols).
    -- Row1: DROP BR      | AUTO LEFT
    -- Row2: BAT AIMBOT   | AUTO RIGHT
    -- Row3: TP DOWN      | CARRY SPD
    -- Row4: LAGGER MODE  | LAGGER CARRY
    -- Row5: TP BAT
    -- Row6: INSTA RESET      | AUTO TP LEFT
    -- Row7: AUTO TP RIGHT
    local buttons={
        {key="drop",        label="DROP\nBR",       toggle=false, exclusive=false},
        {key="autoLeft",    label="AUTO\nLEFT",     toggle=true,  exclusive=true},
        {key="autoBat",     label="BAT\nAIMBOT",    toggle=true,  exclusive=true},
        {key="autoRight",   label="AUTO\nRIGHT",    toggle=true,  exclusive=true},
        {key="tpDown",      label="TP\nDOWN",       toggle=false, exclusive=false},
        {key="carrySpeed",  label="CARRY\nSPD",     toggle=true,  exclusive=false},
        {key="lagger",      label="LAGGER\nMODE",   toggle=true,  exclusive=false},
        {key="laggerCarry", label="LAGGER\nCARRY",  toggle=true,  exclusive=false},
        {key="tpBat",       label="TP\nBAT",        toggle=true,  exclusive=false},
        {key="instaReset",  label="INSTA RESET",     toggle=false, exclusive=false},
        {key="autoTPLeft",  label="AUTO TP\nLEFT",    toggle=true,  exclusive=true},
        {key="autoTPRight", label="AUTO TP\nRIGHT",   toggle=true,  exclusive=true},
    }

    local COLS=2
    local totalW=(COLS*(BTN_SIZE+BTN_GAP))-BTN_GAP
    local totalH=(math.ceil(#buttons/COLS)*(BTN_SIZE+BTN_GAP))-BTN_GAP

    -- Panel padding for background card
    local PAD=10

    local vp=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
    local savedPanel=savedPositions["_panel"]
    local defPanelX=vp.X-totalW-PAD*2-18
    local defPanelY=math.max(10,vp.Y/2-(totalH+PAD*2)/2)
    local panelXO=savedPanel and savedPanel.xo or defPanelX
    local panelYO=savedPanel and savedPanel.yo or defPanelY

    local mobGui=Instance.new("ScreenGui")
    mobGui.Name="K7MobileButtons";mobGui.ResetOnSpawn=false;mobGui.DisplayOrder=9999;mobGui.IgnoreGuiInset=true;mobGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    parentGui(mobGui)
    mobGuiRef=mobGui

    -- Colors from active GUI theme
    local th = getTheme()
    local PINK_ON      = th.MOB_ON
    local BTN_BG_OFF   = th.MOB_OFF
    local PANEL_BG     = th.BG
    local BORDER_OFF   = th.MOB_BORDER_OFF
    local BORDER_ON    = th.MOB_ON
    local TEXT_OFF     = th.MOB_TEXT_OFF
    local TEXT_ON      = th.MOB_TEXT_ON
    local STROKE_W     = 1

    -- Outer panel only created when NOT using per-button drag
    local panel
    if not perButtonDragEnabled then
        panel=Instance.new("Frame",mobGui)
        panel.Name="MobPanel"
        panel.Size=UDim2.new(0,totalW+PAD*2,0,totalH+PAD*2)
        panel.Position=UDim2.new(0,panelXO,0,panelYO)
        panel.BackgroundColor3=PANEL_BG
        panel.BackgroundTransparency=1
        panel.BorderSizePixel=0;panel.Active=true;panel.ZIndex=99
        local panelStroke=Instance.new("UIStroke",panel)
        panelStroke.Color=Color3.fromRGB(80,80,80);panelStroke.Thickness=1;panelStroke.Transparency=0.7

        -- Drag handle on panel
        local gDragStart,gDragStartPos,gDragDown=nil,nil,false
        panel.InputBegan:Connect(function(input)
            if uiLocked then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                gDragDown=true;gDragStart=input.Position;gDragStartPos=panel.Position
                input.Changed:Connect(function()
                    if input.UserInputState==Enum.UserInputState.End then
                        gDragDown=false
                        if writefile then
                            local posData=loadBtnPositions()
                            posData["_panel"]={xo=panel.Position.X.Offset,yo=panel.Position.Y.Offset}
                            pcall(function() writefile(MOB_POS_FILE,HS:JSONEncode(posData)) end)
                        end
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if gDragDown and not uiLocked and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
                local delta=input.Position-gDragStart
                panel.Position=UDim2.new(0,gDragStartPos.X.Offset+delta.X,0,gDragStartPos.Y.Offset+delta.Y)
            end
        end)
    end

    for i,def in ipairs(buttons) do
        local col=(i-1)%COLS
        local rowN=math.floor((i-1)/COLS)
        local localX=PAD+col*(BTN_SIZE+BTN_GAP)
        local localY=PAD+rowN*(BTN_SIZE+BTN_GAP)

        -- Position: saved absolute pixels, OR default grid pinned to RIGHT edge.
        -- Every button is clamped to the actual viewport so it can NEVER spawn off-screen.
        local frameParent=perButtonDragEnabled and mobGui or panel
        local frame=Instance.new("Frame",frameParent)
        frame.Name="MobBtn_"..def.key
        frame.Size=UDim2.new(0,BTN_SIZE,0,BTN_SIZE)
        local cam = workspace.CurrentCamera
        local vpX = (cam and cam.ViewportSize.X) or 800
        local vpY = (cam and cam.ViewportSize.Y) or 600
        local MIN_EDGE=6
        local maxX=math.max(MIN_EDGE,vpX-BTN_SIZE-MIN_EDGE)
        local maxY=math.max(MIN_EDGE,vpY-BTN_SIZE-MIN_EDGE)
        local function clampXY(x,y)
            x=math.clamp(tonumber(x) or MIN_EDGE,MIN_EDGE,maxX)
            y=math.clamp(tonumber(y) or MIN_EDGE,MIN_EDGE,maxY)
            return x,y
        end
        local sp = (not forceDefaultBtnPos) and savedPositions[def.key] or nil
        local xo,yo
        if sp and tonumber(sp.xo)~=nil and tonumber(sp.yo)~=nil then
            xo,yo=clampXY(sp.xo,sp.yo)
        else
            -- Neat grid on the RIGHT using pure offsets.
            xo,yo=clampXY(vpX-(totalW+PAD+18)+localX,math.max(10,vpY/2-(totalH+PAD*2)/2)+localY)
        end
        frame.Position=UDim2.new(0,xo,0,yo)
        frame.BackgroundColor3=BTN_BG_OFF
        frame.BackgroundTransparency=0.05
        frame.BorderSizePixel=0;frame.Active=true;frame.ZIndex=102
        frame:SetAttribute("BtnKey",def.key)

        local uic=Instance.new("UICorner",frame)
        uic.CornerRadius=circleButtonsEnabled and UDim.new(1,0) or UDim.new(0,math.max(8,CORNER_R))

        local fstroke=Instance.new("UIStroke",frame)
        fstroke.Color=BORDER_OFF;fstroke.Thickness=1;fstroke.Transparency=0.35

        local btn=Instance.new("TextButton",frame)
        btn.Size=UDim2.new(1,0,1,0);btn.BackgroundTransparency=1
        btn.Text=def.label
        btn.TextColor3=TEXT_OFF
        btn.Font=Enum.Font.GothamBold
        btn.TextSize=fontSize
        btn.LineHeight=1.05
        btn.TextWrapped=true;btn.AutoButtonColor=false;btn.ZIndex=105
        btn.TextStrokeTransparency=1

        local isOn=false

        local function setOn(v)
            isOn=v
            if v then
                frame:SetAttribute("BtnIsOn",true)
                TweenService:Create(frame,TweenInfo.new(0.12,Enum.EasingStyle.Quad),{BackgroundColor3=PINK_ON}):Play()
                TweenService:Create(fstroke,TweenInfo.new(0.12),{Color=BORDER_ON,Thickness=STROKE_W+1}):Play()
                TweenService:Create(btn,TweenInfo.new(0.12),{TextColor3=TEXT_ON}):Play()
            else
                frame:SetAttribute("BtnIsOn",false)
                TweenService:Create(frame,TweenInfo.new(0.12,Enum.EasingStyle.Quad),{BackgroundColor3=BTN_BG_OFF}):Play()
                TweenService:Create(fstroke,TweenInfo.new(0.12),{Color=BORDER_OFF,Thickness=STROKE_W}):Play()
                TweenService:Create(btn,TweenInfo.new(0.12),{TextColor3=TEXT_OFF}):Play()
            end
        end

        mobBtnRefs[def.key]=setOn

        local function flash()
            TweenService:Create(frame,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(240,240,240)}):Play()
            task.delay(0.18,function()
                TweenService:Create(frame,TweenInfo.new(0.1),{BackgroundColor3=BTN_BG_OFF}):Play()
            end)
        end

        -- Per-button independent drag (one at a time, pure offset = no jump)
        local dragStart2,dragStartPos2,dragMoved,dragDown=nil,nil,false,false
        btn.InputBegan:Connect(function(input)
            if uiLocked then return end
            if activeMobDrag and activeMobDrag~=frame then return end -- another button is already dragging
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragMoved=false
                dragDown=true
                activeMobDrag=frame
                dragStart2=input.Position
                -- use current Position offsets (buttons always pure offset now)
                dragStartPos2=Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragDown or uiLocked or activeMobDrag~=frame then return end
            if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
                local delta=input.Position-dragStart2
                if delta.Magnitude>18 then dragMoved=true end
                if dragMoved then
                    frame.Position=UDim2.new(0,dragStartPos2.X+delta.X,0,dragStartPos2.Y+delta.Y)
                end
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if not dragDown or activeMobDrag~=frame then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                local wasDrag=dragMoved
                dragDown=false
                activeMobDrag=nil
                if wasDrag then pcall(saveBtnPositions) end
                task.delay(0.08,function() dragMoved=false end)
            end
        end)

        btn.Activated:Connect(function()
            if dragMoved then return end

            if def.key=="tpDown" then runTPFloor();flash();return end
            if def.key=="drop" then local d=armDrop();runDrop(d);flash();return end

            if def.exclusive then
                local alreadyOn=(def.key=="autoLeft" and autoLeftEnabled) or (def.key=="autoRight" and autoRightEnabled) or (def.key=="autoBat" and autoBatEnabled) or (def.key=="autoTPLeft" and autoTPLeftEnabled) or (def.key=="autoTPRight" and autoTPRightEnabled) 
                if alreadyOn then
                    if def.key=="autoLeft" then autoLeftEnabled=false;stopAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(false) end;setOn(false)
                    elseif def.key=="autoRight" then autoRightEnabled=false;stopAutoRight();if autoRightSetVisual then autoRightSetVisual(false) end;setOn(false)
                    elseif def.key=="autoBat" then stopBatAimbot();if autoBatSetVisual then autoBatSetVisual(false) end;setOn(false)
                    elseif def.key=="autoTPLeft" then autoTPLeftEnabled=false;stopAutoTPLeft();if autoTPLeftSetVisual then autoTPLeftSetVisual(false) end;setOn(false)
                    elseif def.key=="autoTPRight" then autoTPRightEnabled=false;stopAutoTPRight();if autoTPRightSetVisual then autoTPRightSetVisual(false) end;setOn(false)
                                        end
                    return
                end
                if def.key~="autoLeft" and def.key~="autoRight" and def.key~="autoTPLeft" and def.key~="autoTPRight" and autoLeftEnabled then autoLeftEnabled=false;stopAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(false) end;if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end end
                if def.key~="autoLeft" and def.key~="autoRight" and def.key~="autoTPLeft" and def.key~="autoTPRight" and autoRightEnabled then autoRightEnabled=false;stopAutoRight();if autoRightSetVisual then autoRightSetVisual(false) end;if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end end
                if autoBatEnabled and def.key~="autoBat" and def.key~="autoTPLeft" and def.key~="autoTPRight" then stopBatAimbot();if autoBatSetVisual then autoBatSetVisual(false) end;if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end end
                                if def.key=="autoLeft" then autoLeftEnabled=true;if safeModeTryStart and not safeModeTryStart() then return end;startAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(true) end;setOn(true)
                elseif def.key=="autoRight" then autoRightEnabled=true;if safeModeTryStart and not safeModeTryStart() then return end;startAutoRight();if autoRightSetVisual then autoRightSetVisual(true) end;setOn(true)
                elseif def.key=="autoBat" then queueAutoBatStart();if autoBatSetVisual then autoBatSetVisual(true) end;setOn(true)
                elseif def.key=="autoTPLeft" then
                    if autoTPRightEnabled then autoTPRightEnabled=false;stopAutoTPRight();if autoTPRightSetVisual then autoTPRightSetVisual(false) end;if mobBtnRefs.autoTPRight then mobBtnRefs.autoTPRight(false) end end
                    autoTPLeftEnabled=true;startAutoTPLeft();if autoTPLeftSetVisual then autoTPLeftSetVisual(true) end;setOn(true)
                elseif def.key=="autoTPRight" then
                    if autoTPLeftEnabled then autoTPLeftEnabled=false;stopAutoTPLeft();if autoTPLeftSetVisual then autoTPLeftSetVisual(false) end;if mobBtnRefs.autoTPLeft then mobBtnRefs.autoTPLeft(false) end end
                    autoTPRightEnabled=true;startAutoTPRight();if autoTPRightSetVisual then autoTPRightSetVisual(true) end;setOn(true)
                                end
                return
            end
            if def.key=="instaReset" then
                AdaptInstantReset()
                flash()
                return
            end
            if def.key=="tpBat" then
                -- TP Bat only
                if tpBatEnabled then
                    stopTPBat()
                    setOn(false)
                    pcall(cleanupPredBall)
                else
                    startTPBat()
                    setOn(true)
                end
                -- force visual to match actual state
                setOn(tpBatEnabled == true)
                saveConfig(); return
            end
            if def.key=="carrySpeed" then toggleCarryMode();setOn(carrySpeedActive);if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end;saveConfig();return end
            if def.key=="lagger" then toggleLaggerMode();setOn(laggerModeEnabled);if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end;if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end;saveConfig();return end
            if def.key=="laggerCarry" then toggleLaggerCarryMode();setOn(laggerCarryActive);if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end;saveConfig();return end
        end)
    end

    -- Re-clamp/rebuild on device rotation or viewport changes so the mobile buttons
    -- (including AUTO TP RIGHT) never disappear beyond the screen edges.
    local camera=workspace.CurrentCamera
    if camera then
        mobViewportConn=camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if mobileButtonsEnabled and mobGuiRef==mobGui then
                task.defer(function()
                    if mobileButtonsEnabled and mobGuiRef==mobGui then buildMobileButtons() end
                end)
            end
        end)
    end

    -- Sync initial states
    if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(autoLeftEnabled) end
    if mobBtnRefs.autoRight then mobBtnRefs.autoRight(autoRightEnabled) end
    if mobBtnRefs.autoBat then mobBtnRefs.autoBat(autoBatEnabled) end
    if mobBtnRefs.autoTPLeft then mobBtnRefs.autoTPLeft(autoTPLeftEnabled) end
    if mobBtnRefs.autoTPRight then mobBtnRefs.autoTPRight(autoTPRightEnabled) end
    if mobBtnRefs.tpBat then mobBtnRefs.tpBat(tpBatEnabled) end
    if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end
end

-- ============================================================
-- MAIN GUI - clean minimal style
-- ============================================================
local function buildGui()
    clearPersistentConns()
    pcall(createStealBar)

    -- Color palette from active GUI theme
    local th = getTheme() or GUI_THEMES["Obsidian"]
    local BG, BG2, ROW_BG, ROW_BORDER = th.BG, th.BG2, th.ROW_BG, th.ROW_BORDER
    local WHITE, GRAY, INP = th.WHITE, th.GRAY, th.INP
    local PINK, PINK2, PINK3 = th.ACCENT, th.ACCENT2, th.ACCENT3
    local OFF, TAB_ACTIVE, TAB_INACT, SECT_LBL = th.OFF, th.ACCENT, th.GRAY, th.SECT

    -- Destroy previous GUI completely (gethui / CoreGui / PlayerGui)
    pcall(function()
        if mainGuiRef then mainGuiRef:Destroy() end
    end)
    mainGuiRef = nil
    pcall(function() destroyOldGui("K7Duels") end)
    pcall(function()
        local cg=game:GetService("CoreGui")
        local o=cg:FindFirstChild("K7Duels"); if o then o:Destroy() end
        local pg=LP:FindFirstChild("PlayerGui")
        if pg then local o2=pg:FindFirstChild("K7Duels"); if o2 then o2:Destroy() end end
    end)

    local gui=Instance.new("ScreenGui");gui.Name="K7Duels";gui.ResetOnSpawn=false;gui.DisplayOrder=10;gui.IgnoreGuiInset=true
    parentGui(gui)
    mainGuiRef = gui

    -- Slimmer window: 330 wide
    local W, H = 300, 360
    mainFrame=Instance.new("Frame",gui);mainFrame.Name="Main"
    mainFrame.Size=UDim2.new(0,W,0,H);mainFrame.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
    mainFrame.BackgroundColor3=BG;mainFrame.BackgroundTransparency=guiTransparencyEnabled and 0.55 or 0.15
    mainFrame.BorderSizePixel=0;mainFrame.ClipsDescendants=true;mainFrame.ZIndex=5
    Instance.new("UICorner",mainFrame).CornerRadius=UDim.new(0,14)

    local bgImage=Instance.new("ImageLabel",mainFrame)
    bgImage.Name="K7BG"
    bgImage.Size=UDim2.new(1,0,1,0)
    bgImage.Position=UDim2.new(0,0,0,0)
    bgImage.BackgroundTransparency=1
    bgImage.Image="rbxassetid://135382218880707"
    bgImage.ScaleType=Enum.ScaleType.Crop
    bgImage.ZIndex=5
    bgImage.ImageTransparency=0.35
    Instance.new("UICorner",bgImage).CornerRadius=UDim.new(0,14)

    local mfStroke=Instance.new("UIStroke",mainFrame)
    mfStroke.Color=ROW_BORDER;mfStroke.Thickness=1;mfStroke.Transparency=0.35

    -- subtle top accent line (clean, not neon spam)
    local topAccent=Instance.new("Frame",mainFrame)
    topAccent.Size=UDim2.new(1,0,0,2);topAccent.Position=UDim2.new(0,0,0,0)
    topAccent.BackgroundColor3=PINK;topAccent.BorderSizePixel=0;topAccent.ZIndex=12
    topAccent.BackgroundTransparency=0.15

    -- no busy background image
    local bgImage=Instance.new("Frame",mainFrame)
    bgImage.Size=UDim2.new(1,0,1,0);bgImage.BackgroundTransparency=1
    bgImage.BorderSizePixel=0;bgImage.ZIndex=1;bgImage.Visible=false;bgImage.Active=false
    _G._K7Duels_bgImage=bgImage


    local _transpOriginals=nil
    local function applyTransparencyToGui(transparent)
        if not transparent then
            mainFrame.BackgroundTransparency=0
            if _transpOriginals then for frame,val in pairs(_transpOriginals) do if frame and frame.Parent then frame.BackgroundTransparency=val end end end
            return
        end
        if not _transpOriginals then
            _transpOriginals={}
            local function snapshot(parent)
                for _,child in ipairs(parent:GetChildren()) do
                    if (child:IsA("Frame") or child:IsA("ScrollingFrame")) and child~=bgImage then _transpOriginals[child]=child.BackgroundTransparency end
                    snapshot(child)
                end
            end
            snapshot(mainFrame)
        end
        mainFrame.BackgroundTransparency=0.75
        for frame,_ in pairs(_transpOriginals) do if frame and frame.Parent then frame.BackgroundTransparency=0.7 end end
    end

    -- Drag handler (only on header)
    local function dragHandle(handle)
        local dn,ds,sp,di=false
        handle.InputBegan:Connect(function(i)
            if uiLocked then return end
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dn=true;ds=i.Position;sp=mainFrame.Position
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dn=false end end)
            end
        end)
        handle.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then di=i end end)
        trackConn(UIS.InputChanged:Connect(function(i)
            if i==di and dn and not uiLocked then
                mainFrame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+(i.Position.X-ds.X),sp.Y.Scale,sp.Y.Offset+(i.Position.Y-ds.Y))
            end
        end))
    end

    -- ===== HEADER =====
    local headerH = 48
    local header=Instance.new("Frame",mainFrame)
    header.Size=UDim2.new(1,0,0,headerH)
    header.BackgroundColor3=BG2;header.BorderSizePixel=0;header.ZIndex=6
    -- square bottom so it meets content cleanly
    local headerFix=Instance.new("Frame",mainFrame)
    headerFix.Size=UDim2.new(1,0,0,14);headerFix.Position=UDim2.new(0,0,0,headerH-12)
    headerFix.BackgroundColor3=BG2;headerFix.BorderSizePixel=0;headerFix.ZIndex=5
    local hDivider=Instance.new("Frame",mainFrame)
    hDivider.Size=UDim2.new(1,-24,0,1);hDivider.Position=UDim2.new(0,12,0,headerH)
    hDivider.BackgroundColor3=ROW_BORDER;hDivider.BackgroundTransparency=0.25;hDivider.BorderSizePixel=0;hDivider.ZIndex=7

    dragHandle(header)

    local titleLbl=Instance.new("TextLabel",header)
    titleLbl.Size=UDim2.new(1,-100,0,18);titleLbl.Position=UDim2.new(0,14,0,8)
    titleLbl.BackgroundTransparency=1;titleLbl.Text="K7 DUELS"
    titleLbl.TextColor3=WHITE;titleLbl.Font=Enum.Font.GothamBold
    titleLbl.TextSize=15;titleLbl.TextXAlignment=Enum.TextXAlignment.Left;titleLbl.ZIndex=8

    local discSmall=Instance.new("TextLabel",header)
    discSmall.Size=UDim2.new(0,140,0,12);discSmall.Position=UDim2.new(0,14,0,28)
    discSmall.BackgroundTransparency=1;discSmall.Text="discord.gg/k7hub"
    discSmall.TextColor3=GRAY;discSmall.Font=Enum.Font.Gotham
    discSmall.TextSize=9;discSmall.TextXAlignment=Enum.TextXAlignment.Left;discSmall.ZIndex=8

    local pingFpsLbl=Instance.new("TextLabel",header)
    pingFpsLbl.Size=UDim2.new(0,90,0,14);pingFpsLbl.Position=UDim2.new(1,-128,0,10)
    pingFpsLbl.BackgroundTransparency=1;pingFpsLbl.Text="--ms  --fps"
    pingFpsLbl.TextColor3=GRAY;pingFpsLbl.Font=Enum.Font.GothamMedium
    pingFpsLbl.TextSize=9;pingFpsLbl.TextXAlignment=Enum.TextXAlignment.Right;pingFpsLbl.ZIndex=8
    task.spawn(function()
        local frames=0;local t0=tick()
        while pingFpsLbl and pingFpsLbl.Parent do
            frames=frames+1;local now=tick()
            if now-t0>=0.5 then
                local fps=math.floor(frames/(now-t0)+0.5)
                local ok,ms=pcall(function() return LP:GetNetworkPing()*1000 end)
                pingFpsLbl.Text=(ok and math.floor(ms+0.5) or "--").."ms - "..fps.."fps"
                frames=0;t0=now
            end
            task.wait()
        end
    end)

    local closeBtn=Instance.new("TextButton",header)
    closeBtn.Size=UDim2.new(0,28,0,28);closeBtn.Position=UDim2.new(1,-40,0.5,-14)
    closeBtn.BackgroundColor3=PINK3;closeBtn.BorderSizePixel=0
    closeBtn.Text="-";closeBtn.TextColor3=WHITE
    closeBtn.Font=Enum.Font.GothamBold;closeBtn.TextSize=16;closeBtn.ZIndex=10
    Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,8)

    local miniBtn=Instance.new("TextButton",gui)
    miniBtn.Size=UDim2.new(0,96,0,34)
    miniBtn.Position=UDim2.new(0,16,0.5,-17)
    miniBtn.BackgroundColor3=BG2;miniBtn.BorderSizePixel=0
    miniBtn.Text="K7";miniBtn.TextColor3=WHITE
    miniBtn.Font=Enum.Font.GothamBold;miniBtn.TextSize=12;miniBtn.ZIndex=20;miniBtn.Visible=false
    Instance.new("UICorner",miniBtn).CornerRadius=UDim.new(1,0)
    local miniStroke=Instance.new("UIStroke",miniBtn)
    miniStroke.Color=ROW_BORDER;miniStroke.Thickness=1;miniStroke.Transparency=0.25
    -- Mini button has its own independent drag so it stays at its original spot
    do
        local mdn,mds,msp=false,nil,nil
        miniBtn.InputBegan:Connect(function(i)
            if uiLocked then return end
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                mdn=true;mds=i.Position;msp=miniBtn.Position
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then mdn=false end end)
            end
        end)
        trackConn(UIS.InputChanged:Connect(function(i)
            if mdn and not uiLocked and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                miniBtn.Position=UDim2.new(msp.X.Scale,msp.X.Offset+(i.Position.X-mds.X),msp.Y.Scale,msp.Y.Offset+(i.Position.Y-mds.Y))
            end
        end))
    end
    closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible=false;miniBtn.Visible=true end)
    miniBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible=true;miniBtn.Visible=false
        TweenService:Create(mainFrame,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,W,0,H)}):Play()
    end)

    -- ===== SINGLE SCROLLABLE CONTENT FRAME (NO TABS) =====
    local contentFrameY = headerH + 1
    local contentH = H - contentFrameY
    
    local contentFrame = Instance.new("ScrollingFrame", mainFrame)
    contentFrame.Size = UDim2.new(1, 0, 0, contentH)
    contentFrame.Position = UDim2.new(0, 0, 0, contentFrameY)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 2
    contentFrame.ScrollBarImageColor3 = PINK3
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.Visible = true
    contentFrame.ZIndex = 8
    contentFrame.Active = true
    
    local ll = Instance.new("UIListLayout", contentFrame)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 0)
    
    local pd = Instance.new("UIPadding", contentFrame)
    pd.PaddingLeft = UDim.new(0, 10)
    pd.PaddingRight = UDim.new(0, 10)
    pd.PaddingTop = UDim.new(0, 8)
    pd.PaddingBottom = UDim.new(0, 8)

    -- All tabs point to the same single frame
    local tabPages = {}
    tabPages["Main"] = contentFrame
    tabPages["Auto"] = contentFrame
    tabPages["Visuals"] = contentFrame
    tabPages["Settings"] = contentFrame
    tabPages["Speed"] = contentFrame
    tabPages["Combat"] = contentFrame
    tabPages["Steal"] = contentFrame
    tabPages["Visual"] = contentFrame

    local contentFrame = tabPages["Main"]
    

    -- ===== PROFILE CARD =====
    do
        local profileCard = Instance.new("Frame", contentFrame)
        profileCard.Name = "ProfileCard"
        profileCard.Size = UDim2.new(1, 0, 0, 88)
        profileCard.BackgroundColor3 = ROW_BG
        profileCard.BackgroundTransparency = 0.15
        profileCard.BorderSizePixel = 0
        profileCard.LayoutOrder = 0
        profileCard.ZIndex = 8
        Instance.new("UICorner", profileCard).CornerRadius = UDim.new(0, 10)
        local pStroke = Instance.new("UIStroke", profileCard)
        pStroke.Color = ROW_BORDER
        pStroke.Thickness = 1
        pStroke.Transparency = 0.35

        local avatar = Instance.new("ImageLabel", profileCard)
        avatar.Name = "Avatar"
        avatar.Size = UDim2.new(0, 48, 0, 48)
        avatar.Position = UDim2.new(0, 12, 0.5, -24)
        avatar.BackgroundColor3 = BG2
        avatar.BorderSizePixel = 0
        avatar.ScaleType = Enum.ScaleType.Crop
        avatar.ZIndex = 9
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
        local aStroke = Instance.new("UIStroke", avatar)
        aStroke.Color = ROW_BORDER
        aStroke.Thickness = 1
        aStroke.Transparency = 0.3
        pcall(function()
            avatar.Image = Players:GetUserThumbnailAsync(
                LP.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)

        local displayName = Instance.new("TextLabel", profileCard)
        displayName.Name = "DisplayName"
        displayName.Size = UDim2.new(1, -78, 0, 20)
        displayName.Position = UDim2.new(0, 70, 0, 16)
        displayName.BackgroundTransparency = 1
        displayName.Text = LP.DisplayName or LP.Name
        displayName.TextColor3 = WHITE
        displayName.Font = Enum.Font.GothamBold
        displayName.TextSize = 14
        displayName.TextXAlignment = Enum.TextXAlignment.Left
        displayName.TextTruncate = Enum.TextTruncate.AtEnd
        displayName.ZIndex = 9

        local username = Instance.new("TextLabel", profileCard)
        username.Name = "Username"
        username.Size = UDim2.new(1, -78, 0, 14)
        username.Position = UDim2.new(0, 70, 0, 34)
        username.BackgroundTransparency = 1
        username.Text = "@" .. tostring(LP.Name)
        username.TextColor3 = GRAY
        username.Font = Enum.Font.Gotham
        username.TextSize = 11
        username.TextXAlignment = Enum.TextXAlignment.Left
        username.TextTruncate = Enum.TextTruncate.AtEnd
        username.ZIndex = 9

        local buyerBadge = Instance.new("TextLabel", profileCard)
        buyerBadge.Name = "BuyerBadge"
        buyerBadge.Size = UDim2.new(0, 108, 0, 18)
        buyerBadge.Position = UDim2.new(0, 70, 0, 52)
        buyerBadge.BackgroundColor3 = PINK3
        buyerBadge.BorderSizePixel = 0
        buyerBadge.Text = "K7 BUYER"
        buyerBadge.TextColor3 = WHITE
        buyerBadge.Font = Enum.Font.GothamBold
        buyerBadge.TextSize = 9
        buyerBadge.ZIndex = 9
        Instance.new("UICorner", buyerBadge).CornerRadius = UDim.new(0, 5)
        local bStroke = Instance.new("UIStroke", buyerBadge)
        bStroke.Color = ROW_BORDER
        bStroke.Thickness = 1
        bStroke.Transparency = 0.4
    end


    -- ===== ROW HELPERS - clean style =====
    -- Each row: full-width bordered box, label left, control right

    local function mkSectionLbl(parent, txt)
        local spacer=Instance.new("Frame",parent)
        spacer.Size=UDim2.new(1,0,0,8);spacer.BackgroundTransparency=1;spacer.LayoutOrder=#parent:GetChildren()

        local row=Instance.new("Frame",parent)
        row.Size=UDim2.new(1,0,0,16);row.BackgroundTransparency=1;row.LayoutOrder=#parent:GetChildren()
        local l=Instance.new("TextLabel",row)
        l.Size=UDim2.new(1,0,1,0);l.BackgroundTransparency=1
        l.Text=txt:upper();l.TextColor3=SECT_LBL
        l.Font=Enum.Font.GothamBold;l.TextSize=10
        l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=9

        local sp2=Instance.new("Frame",parent)
        sp2.Size=UDim2.new(1,0,0,4);sp2.BackgroundTransparency=1;sp2.LayoutOrder=#parent:GetChildren()
    end

    local function mkRow(parent, h)
        local f=Instance.new("Frame",parent)
        f.Size=UDim2.new(1,0,0,h or 36)
        f.BackgroundColor3=ROW_BG;f.BorderSizePixel=0;f.ZIndex=8
        f.LayoutOrder=#parent:GetChildren()
        local stroke=Instance.new("UIStroke",f)
        stroke.Color=ROW_BORDER;stroke.Thickness=1;stroke.Transparency=0.45
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
        local spacer=Instance.new("Frame",parent)
        spacer.Size=UDim2.new(1,0,0,4);spacer.BackgroundTransparency=1
        spacer.LayoutOrder=#parent:GetChildren()+1
        return f
    end

    local function mkLabel(row, txt)
        local l=Instance.new("TextLabel",row)
        l.Size=UDim2.new(0.58,0,1,0);l.Position=UDim2.new(0,12,0,0)
        l.BackgroundTransparency=1;l.Text=txt
        l.TextColor3=WHITE;l.Font=Enum.Font.GothamMedium
        l.TextSize=12;l.TextXAlignment=Enum.TextXAlignment.Left;l.ZIndex=9
        return l
    end

    local function mkPill(row)
        local pill=Instance.new("Frame",row)
        pill.Size=UDim2.new(0,40,0,20);pill.Position=UDim2.new(1,-50,0.5,-10)
        pill.BackgroundColor3=OFF;pill.BorderSizePixel=0;pill.ZIndex=9
        Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
        local pStroke=Instance.new("UIStroke",pill)
        pStroke.Name="PillStroke";pStroke.Color=ROW_BORDER;pStroke.Thickness=1;pStroke.Transparency=0.45
        local dot=Instance.new("Frame",pill)
        dot.Size=UDim2.new(0,14,0,14);dot.Position=UDim2.new(0,3,0.5,-7)
        dot.BackgroundColor3=GRAY;dot.BorderSizePixel=0;dot.ZIndex=10
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        return pill,dot
    end

    local function animPill(pill, dot, on)
        TweenService:Create(pill,TweenInfo.new(0.16,Enum.EasingStyle.Quad),{BackgroundColor3=on and PINK or OFF}):Play()
        TweenService:Create(dot,TweenInfo.new(0.16,Enum.EasingStyle.Back),{
            Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=on and Color3.fromRGB(12,12,14) or GRAY
        }):Play()
        local ps=pill:FindFirstChild("PillStroke")
        if ps then
            TweenService:Create(ps,TweenInfo.new(0.16),{Transparency=on and 0.15 or 0.45, Color=on and PINK or ROW_BORDER}):Play()
        end
    end

    local function mkToggle(parent, txt, cb)
        local row=mkRow(parent,34);mkLabel(row,txt)
        local pill,dot=mkPill(row)
        local on=false
        local function sv(state) on=state; animPill(pill,dot,state) end
        local clk=Instance.new("TextButton",pill)
        clk.Size=UDim2.new(1,0,1,0)
        clk.BackgroundTransparency=1
        clk.Text=""
        clk.ZIndex=11
        clk.Activated:Connect(function()
            on = not on
            sv(on)
            if cb then
                local ok, err = pcall(cb, on)
            end
        end)
        return sv
    end

    -- Value box (dark rounded box on right side, clean style)
    local function mkBoxRow(parent, txt, default, cb)
        local row=mkRow(parent,34);mkLabel(row,txt)
        local tb=Instance.new("TextBox",row)
        tb.Size=UDim2.new(0,58,0,22);tb.Position=UDim2.new(1,-66,0.5,-11)
        tb.BackgroundColor3=INP;tb.BorderSizePixel=0
        tb.Text=tostring(default);tb.TextColor3=WHITE
        tb.Font=Enum.Font.GothamMedium;tb.TextSize=12
        tb.ClearTextOnFocus=false;tb.ZIndex=9
        Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
        local tbs=Instance.new("UIStroke",tb);tbs.Color=ROW_BORDER;tbs.Thickness=1;tbs.Transparency=0.4
        tb.FocusLost:Connect(function()
            if cb then local n=tonumber(tb.Text);if n then cb(n) else tb.Text=tostring(default) end end
        end)
        return tb
    end

    -- Keybind display button (pink text label, right side)
    local GAMEPAD_KEYS={[Enum.KeyCode.ButtonA]=true,[Enum.KeyCode.ButtonB]=true,[Enum.KeyCode.ButtonX]=true,[Enum.KeyCode.ButtonY]=true,[Enum.KeyCode.ButtonL1]=true,[Enum.KeyCode.ButtonR1]=true,[Enum.KeyCode.ButtonL2]=true,[Enum.KeyCode.ButtonR2]=true,[Enum.KeyCode.ButtonL3]=true,[Enum.KeyCode.ButtonR3]=true,[Enum.KeyCode.ButtonStart]=true,[Enum.KeyCode.ButtonSelect]=true,[Enum.KeyCode.DPadUp]=true,[Enum.KeyCode.DPadDown]=true,[Enum.KeyCode.DPadLeft]=true,[Enum.KeyCode.DPadRight]=true}
    local function isGamepadInput(inp) return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad")~=nil end
    local function isBindableInput(inp)
        if not inp or inp.KeyCode==Enum.KeyCode.Unknown then return false end
        if inp.UserInputType==Enum.UserInputType.Keyboard then return true end
        return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode]==true
    end
    local function kbMatch(entry,kc)
        if not kc or kc == Enum.KeyCode.Unknown then return false end
        if not entry or type(entry)~="table" then return false end
        if entry.kb == nil and entry.gp == nil then return false end
        local ok, hit = pcall(function()
            if entry.kb ~= nil and kc == entry.kb then return true end
            if entry.gp ~= nil and kc == entry.gp then return true end
            return false
        end)
        return ok and hit == true
    end

    local function formatKeybindText(entry)
        if not entry then return "..." end
        local parts = {}
        if entry.kb then table.insert(parts, entry.kb.Name) end
        if entry.gp then table.insert(parts, entry.gp.Name) end
        if #parts == 0 then return "..." end
        return table.concat(parts, " / ")
    end

    local function mkKBButton(row, kbEntry, cb)
        -- Dual-bind PC + gamepad (VYNX-style): keep both, show "Key / Button"
        local function getLabel()
            return formatKeybindText(kbEntry)
        end
        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.new(0,90,0,22);btn.Position=UDim2.new(1,-98,0.5,-11)
        btn.BackgroundColor3=INP;btn.BorderSizePixel=0
        btn.Text=getLabel();btn.TextColor3=WHITE
        btn.Font=Enum.Font.GothamMedium;btn.TextSize=10
        btn.TextTruncate=Enum.TextTruncate.AtEnd
        btn.AutoButtonColor=false;btn.ZIndex=9
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
        local kbs=Instance.new("UIStroke",btn);kbs.Color=ROW_BORDER;kbs.Thickness=1;kbs.Transparency=0.4
        local li=false;local lc;local pv=btn.Text;local ls=0
        btn.Activated:Connect(function()
            if li then
                li=false;_anyKeyListening=false
                if lc then lc:Disconnect();lc=nil end
                btn.Text=getLabel();btn.TextColor3=PINK
                return
            end
            pv=btn.Text;li=true;_anyKeyListening=true;ls=tick()
            btn.Text="Press key...";btn.TextColor3=WHITE
            lc=UIS.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode==Enum.KeyCode.Escape then
                    li=false;_anyKeyListening=false
                    if lc then lc:Disconnect();lc=nil end
                    btn.Text=getLabel();btn.TextColor3=PINK
                    return
                end
                local isGp=isGamepadInput(inp)
                if isGp and not(tick()-ls>=0.15) then return end
                if not isBindableInput(inp) then return end
                -- Keep both PC keyboard and gamepad binds (mobile + PC support)
                if isGp then
                    kbEntry.gp=inp.KeyCode
                else
                    kbEntry.kb=inp.KeyCode
                end
                li=false;_anyKeyListening=false
                if lc then lc:Disconnect();lc=nil end
                btn.Text=getLabel();btn.TextColor3=PINK
                if cb then cb(inp.KeyCode,isGp) end
                pcall(saveConfig)
            end)
        end)
        return btn
    end

    -- Toggle row with a keybind button on the right (pill at far right, kb just left of it)
    local function mkToggleKB(parent, txt, kbEntry, onToggle, onKB)
        local row=mkRow(parent,34);mkLabel(row,txt)
        mkKBButton(row,kbEntry,function(k,isGp) if onKB then onKB(k,isGp) end end)
        local pill=Instance.new("Frame",row);pill.Size=UDim2.new(0,30,0,16);pill.Position=UDim2.new(1,-40,0.5,-8)
        -- shift pill left of KB button - place pill at right edge, kb just inside
        -- Actually for this layout: label left, [kb btn] [pill] right
        pill:Destroy() -- rebuild properly below
        -- Rebuilt: kb at right-78 to right-8, pill at right-44 to right-10 -> let's offset
        local pill2=Instance.new("Frame",row);pill2.Size=UDim2.new(0,40,0,20);pill2.Position=UDim2.new(1,-50,0.5,-10)
        pill2.BackgroundColor3=OFF;pill2.BorderSizePixel=0;pill2.ZIndex=9
        Instance.new("UICorner",pill2).CornerRadius=UDim.new(1,0)
        local pStroke2=Instance.new("UIStroke",pill2);pStroke2.Name="PillStroke";pStroke2.Color=ROW_BORDER;pStroke2.Thickness=1;pStroke2.Transparency=0.45
        local dot2=Instance.new("Frame",pill2);dot2.Size=UDim2.new(0,14,0,14);dot2.Position=UDim2.new(0,3,0.5,-7)
        dot2.BackgroundColor3=GRAY;dot2.BorderSizePixel=0;dot2.ZIndex=10
        Instance.new("UICorner",dot2).CornerRadius=UDim.new(1,0)
        -- reposition kb button to fit next to pill
        local kbb=row:FindFirstChildOfClass("TextButton")
        if kbb then kbb.Position=UDim2.new(1,-148,0.5,-11);kbb.Size=UDim2.new(0,90,0,22) end
        local on=false
        local function sv(s) on=s;animPill(pill2,dot2,s) end
        local clk=Instance.new("TextButton",pill2);clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=11
        clk.Activated:Connect(function() if _anyKeyListening then return end;on=not on;sv(on);if onToggle then onToggle(on) end end)
        return sv
    end

    local function mkKBRow(parent, txt, kbEntry, onKB)
        local row=mkRow(parent,34);mkLabel(row,txt)
        mkKBButton(row,kbEntry,function(k,isGp) if onKB then onKB(k,isGp) end end)
        return row
    end

    local function mkActionRow(parent, txt, onActivate)
        local row=mkRow(parent,34);mkLabel(row,txt)
        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.new(0,50,0,18);btn.Position=UDim2.new(1,-58,0.5,-9)
        btn.BackgroundColor3=PINK3;btn.BorderSizePixel=0
        btn.Text=">";btn.TextColor3=WHITE;btn.Font=Enum.Font.GothamBlack;btn.TextSize=11
        btn.AutoButtonColor=false;btn.ZIndex=9
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
        btn.Activated:Connect(function()
            TweenService:Create(btn,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(200,60,120)}):Play()
            task.delay(0.12,function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=PINK3}):Play() end)
            if onActivate then onActivate() end
        end)
        return row,btn
    end

    -- ===== SPEED =====
    local pg=tabPages["Speed"]
    mkSectionLbl(pg,"Speed Configuration")
    mkSectionLbl(pg,"Normal Mode")
    normalBox=mkBoxRow(pg,"Normal Speed",NS,function(v) if v>0 and v<=500 then NS=v end;saveConfig() end)
    carryBox=mkBoxRow(pg,"Carry Speed",CS,function(v) if v>0 and v<=500 then CS=v end;saveConfig() end)
    mkSectionLbl(pg,"Lagger Mode")
    laggerBox=mkBoxRow(pg,"Lagger Speed",LAGGER_SPEED,function(v) if v>0 and v<=500 then LAGGER_SPEED=v end;saveConfig() end)
    laggerCarryBox=mkBoxRow(pg,"Lagger Carry Speed",LAGGER_CARRY_SPEED,function(v) if v>0 and v<=500 then LAGGER_CARRY_SPEED=v end;saveConfig() end)

    mkSectionLbl(pg,"Combat")

    do
        local row=mkRow(pg,34);mkLabel(row,"Aimbot Mode")
        local modeBtn=Instance.new("TextButton",row)
        modeBtn.Size=UDim2.new(0,70,0,22);modeBtn.Position=UDim2.new(1,-78,0.5,-11)
        modeBtn.BackgroundColor3=PINK3;modeBtn.BorderSizePixel=0
        modeBtn.Text=(aimbotMode=="bypass") and "Bypass" or "Normal"
        modeBtn.TextColor3=WHITE;modeBtn.Font=Enum.Font.GothamBold;modeBtn.TextSize=10
        modeBtn.AutoButtonColor=false;modeBtn.ZIndex=12
        Instance.new("UICorner",modeBtn).CornerRadius=UDim.new(0,5)
        modeBtn.Activated:Connect(function()
            if _anyKeyListening then return end
            aimbotMode=(aimbotMode=="normal") and "bypass" or "normal"
            modeBtn.Text=(aimbotMode=="bypass") and "Bypass" or "Normal"
            -- if aimbot is running, restart in new mode
            if autoBatEnabled then
                stopBatAimbot()
                startBatAimbot()
            end
            saveConfig()
        end)
    end
    setAntiRagVisual=mkToggle(pg,"Anti Ragdoll",function(on) antiRagdollEnabled=on;if on then startAntiRagdoll() else stopAntiRagdoll() end;saveConfig() end)
    local setAntiDropVisual=mkToggle(pg,"Anti Drop",function(on) antiDropEnabled=on==true;if on then enableAntiDrop() else disableAntiDrop() end;saveConfig() end)
    if setAntiDropVisual then setAntiDropVisual(antiDropEnabled==true) end
    setAntiBatVisual=mkToggle(pg,"Anti Bat",function(on) antiBatEnabled=on==true;if antiBatEnabled then startAntiBat() else stopAntiBat() end;saveConfig() end)
    if setAntiBatVisual then setAntiBatVisual(antiBatEnabled==true) end
    -- Anti Fling is always-on (built into aimbot + global clamp); no toggle
    setBatCounterVisual=mkToggle(pg,"Bat Counter",function(on) batCounterEnabled=on;if on then startBatCounter() else stopBatCounter() end;saveConfig() end)
    setMedusaVisual=mkToggle(pg,"Medusa Counter",function(on) medusaCounterEnabled=on;if on then setupMedusa(LP.Character) else stopMedusaCounter() end;saveConfig() end)

    setUnwalkVisual=mkToggle(pg,"Unwalk",function(on) unwalkEnabled=on;if on then startUnwalk() else stopUnwalk() end;saveConfig() end)

    do
        local row=mkRow(pg,30);mkLabel(row,"Anti Kick")
        local pill=Instance.new("Frame",row);pill.Size=UDim2.new(0,40,0,20);pill.Position=UDim2.new(1,-50,0.5,-10)
        pill.BackgroundColor3=OFF;pill.BorderSizePixel=0;pill.ZIndex=9
        Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
        local pStroke=Instance.new("UIStroke",pill);pStroke.Name="PillStroke";pStroke.Color=ROW_BORDER;pStroke.Thickness=1;pStroke.Transparency=0.45
        local dot=Instance.new("Frame",pill);dot.Size=UDim2.new(0,14,0,14);dot.Position=UDim2.new(0,3,0.5,-7)
        dot.BackgroundColor3=GRAY;dot.BorderSizePixel=0;dot.ZIndex=10
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local on=false
        local function sv(s) on=s;animPill(pill,dot,s) end;antiKickSetVisual=sv
        local clk=Instance.new("TextButton",pill);clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=11
        clk.Activated:Connect(function() on=not on;sv(on);antiKickEnabled=on;if on then enableAntiKick() else disableAntiKick() end;saveConfig() end)
    end
    setInfJumpVisual=mkToggle(pg,"Infinite Jump",function(on) infJumpEnabled=on;if infJumpEnabled then if infJumpMode=="hold" then startHoldInfJump() end else stopHoldInfJump() end;saveConfig() end)
    do
        local row=mkRow(pg,30);mkLabel(row,"Jump Mode")
        local manualBtn=Instance.new("TextButton",row)
        manualBtn.Size=UDim2.new(0,50,0,22);manualBtn.Position=UDim2.new(1,-110,0.5,-11)
        manualBtn.BackgroundColor3=(infJumpMode=="manual") and PINK2 or Color3.fromRGB(50,30,40)
        manualBtn.BorderSizePixel=0;manualBtn.Text="Manual"
        manualBtn.TextColor3=WHITE;manualBtn.Font=Enum.Font.GothamBold;manualBtn.TextSize=9
        manualBtn.AutoButtonColor=false;manualBtn.ZIndex=12
        Instance.new("UICorner",manualBtn).CornerRadius=UDim.new(0,5)
        local holdBtn=Instance.new("TextButton",row)
        holdBtn.Size=UDim2.new(0,46,0,22);holdBtn.Position=UDim2.new(1,-57,0.5,-11)
        holdBtn.BackgroundColor3=(infJumpMode=="hold") and PINK2 or Color3.fromRGB(50,30,40)
        holdBtn.BorderSizePixel=0;holdBtn.Text="Hold"
        holdBtn.TextColor3=WHITE;holdBtn.Font=Enum.Font.GothamBold;holdBtn.TextSize=9
        holdBtn.AutoButtonColor=false;holdBtn.ZIndex=12
        Instance.new("UICorner",holdBtn).CornerRadius=UDim.new(0,5)
        manualBtn.Activated:Connect(function() infJumpMode="manual";manualBtn.BackgroundColor3=PINK2;holdBtn.BackgroundColor3=Color3.fromRGB(50,30,40);stopHoldInfJump();saveConfig() end)
        holdBtn.Activated:Connect(function() infJumpMode="hold";holdBtn.BackgroundColor3=PINK2;manualBtn.BackgroundColor3=Color3.fromRGB(50,30,40);if infJumpEnabled then startHoldInfJump() end;saveConfig() end)
    end

    -- ===== AUTO =====
    pg=tabPages["Auto"]
    mkSectionLbl(pg,"Auto")
    setAutoSwingVisual=mkToggle(pg,"Auto Swing",function(on) autoSwingEnabled=on;saveConfig() end)
    if setAutoSwingVisual then setAutoSwingVisual(autoSwingEnabled) end
    setAutoTPVisual=mkToggle(pg,"Auto TP",function(on) autoTPEnabled=on;if on then startAutoTP() else stopAutoTP() end;saveConfig() end)
    setSafeModeVisual=mkToggle(pg,"Safe Mode",function(on)
        safeModeEnabled=on==true
        if on then enableSafeMode() else disableSafeMode() end
        saveConfig()
    end)
    if setSafeModeVisual then setSafeModeVisual(safeModeEnabled==true) end
    setMirrorTPVisual=mkToggle(pg,"Mirror TP Down",function(on) setMirrorTPDown(on);saveConfig() end)
    if setMirrorTPVisual then setMirrorTPVisual(mirrorTPDownEnabled==true) end
    autoTPHeightBox=mkBoxRow(pg,"TP Height",autoTPHeight,function(v) if v>=0 and v<=500 then autoTPHeight=v end;saveConfig() end)
    radInput=mkBoxRow(pg,"Steal Radius",Steal.StealRadius,function(v) if v>=0.5 and v<=300 then Steal.StealRadius=v end;saveConfig() end)
    durationBox=mkBoxRow(pg,"Steal Duration",Steal.StealDuration,function(v) if v>=0.1 and v<=10 then Steal.StealDuration=v else durationBox.Text=tostring(Steal.StealDuration) end;saveConfig() end)
    do
        local row=mkRow(pg,34);mkLabel(row,"Steal Mode")
        local modeBtn=Instance.new("TextButton",row)
        modeBtn.Size=UDim2.new(0,70,0,22);modeBtn.Position=UDim2.new(1,-78,0.5,-11)
        modeBtn.BackgroundColor3=PINK3;modeBtn.BorderSizePixel=0
        modeBtn.Text=((Steal.StealMode or "normal")=="semi") and "Semi" or "Normal"
        modeBtn.TextColor3=WHITE;modeBtn.Font=Enum.Font.GothamBold;modeBtn.TextSize=10
        modeBtn.AutoButtonColor=false;modeBtn.ZIndex=12
        Instance.new("UICorner",modeBtn).CornerRadius=UDim.new(0,5)
        modeBtn.Activated:Connect(function()
            if _anyKeyListening then return end
            Steal.StealMode = ((Steal.StealMode or "normal")=="normal") and "semi" or "normal"
            modeBtn.Text = (Steal.StealMode=="semi") and "Semi" or "Normal"
            if Steal.StealMode == "semi" then
                Steal.StealRange = Steal.StealRange or 10
            else
                if not Steal.StealRadius or Steal.StealRadius < 20 then Steal.StealRadius = 70.3 end
            end
            Steal.StealDuration = Steal.StealDuration or 1.3
            saveConfig()
        end)
    end
    do
        local row=mkRow(pg,30);mkLabel(row,"Auto Steal")
        local pill=Instance.new("Frame",row);pill.Size=UDim2.new(0,40,0,20);pill.Position=UDim2.new(1,-50,0.5,-10)
        pill.BackgroundColor3=OFF;pill.BorderSizePixel=0;pill.ZIndex=9
        Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
        local pStroke=Instance.new("UIStroke",pill);pStroke.Name="PillStroke";pStroke.Color=ROW_BORDER;pStroke.Thickness=1;pStroke.Transparency=0.45
        local dot=Instance.new("Frame",pill);dot.Size=UDim2.new(0,14,0,14);dot.Position=UDim2.new(0,3,0.5,-7)
        dot.BackgroundColor3=GRAY;dot.BorderSizePixel=0;dot.ZIndex=10
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local on=false
        local function sv(s) on=s;animPill(pill,dot,s) end
        setInstaGrab=sv
        local function toggleSteal()
            on = not on
            sv(on)
            Steal.AutoStealEnabled = on
            if on then
                if Conns.autoSteal then pcall(function() Conns.autoSteal:Disconnect() end); Conns.autoSteal=nil end
                startAutoSteal()
            else
                stopAutoSteal()
                Steal.AutoStealEnabled = false
            end
            saveConfig()
        end
        local clk=Instance.new("TextButton",pill)
        clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=11
        clk.Activated:Connect(toggleSteal)
    end

    do
        local row=mkRow(pg,30);mkLabel(row,"Ragdoll Sync")
        local pill=Instance.new("Frame",row);pill.Size=UDim2.new(0,40,0,20);pill.Position=UDim2.new(1,-50,0.5,-10);pill.BackgroundColor3=OFF;pill.BorderSizePixel=0;pill.ZIndex=9;Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
        local ps=Instance.new("UIStroke",pill);ps.Color=ROW_BORDER;ps.Thickness=1;ps.Transparency=0.45
        local dot=Instance.new("Frame",pill);dot.Size=UDim2.new(0,14,0,14);dot.Position=UDim2.new(0,3,0.5,-7);dot.BackgroundColor3=GRAY;dot.BorderSizePixel=0;dot.ZIndex=10;Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local on=ragdollSyncAutoStealEnabled
        local function sv(v) on=v;animPill(pill,dot,v) end
        setRagdollSyncVisual=sv;sv(on)
        local clk=Instance.new("TextButton",pill);clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=11
        clk.Activated:Connect(function() on=not on;sv(on);ragdollSyncAutoStealEnabled=on;saveConfig() end)
    end

    -- ===== VISUAL =====
    pg=tabPages["Visual"]
    mkSectionLbl(pg,"Visual")

    setAntiLagVisual=mkToggle(pg,"Anti Lag",function(on) if on then enableAntiLag() else disableAntiLag() end;saveConfig() end)
    setPlayerEspVisual=mkToggle(pg,"Player ESP",function(on)
        if on then startPlayerEsp() else stopPlayerEsp() end
        saveConfig()
    end)
    setPlayerTracersVisual=mkToggle(pg,"Player Tracers",function(on)
        if on then startPlayerTracers() else stopPlayerTracers() end
        saveConfig()
    end)

    do
        local row=mkRow(pg,30);mkLabel(row,"GUI Theme")
        local guiThemeIndex=1
        for i,theme in ipairs(GUI_THEME_ORDER) do if theme==currentGuiTheme then guiThemeIndex=i;break end end
        local guiThemeVal=Instance.new("TextLabel",row)
        guiThemeVal.Size=UDim2.new(0,70,0,22);guiThemeVal.Position=UDim2.new(1,-120,0.5,-11)
        guiThemeVal.BackgroundTransparency=1;guiThemeVal.Text=currentGuiTheme
        guiThemeVal.TextColor3=PINK;guiThemeVal.Font=Enum.Font.GothamBold;guiThemeVal.TextSize=9
        guiThemeVal.TextXAlignment=Enum.TextXAlignment.Right;guiThemeVal.ZIndex=9
        local guiThemeBtn=Instance.new("TextButton",row)
        guiThemeBtn.Size=UDim2.new(0,40,0,22);guiThemeBtn.Position=UDim2.new(1,-48,0.5,-11)
        guiThemeBtn.BackgroundColor3=PINK3;guiThemeBtn.BorderSizePixel=0
        guiThemeBtn.Text="Next";guiThemeBtn.TextColor3=WHITE
        guiThemeBtn.Font=Enum.Font.GothamBold;guiThemeBtn.TextSize=9
        guiThemeBtn.AutoButtonColor=false;guiThemeBtn.ZIndex=10
        Instance.new("UICorner",guiThemeBtn).CornerRadius=UDim.new(0,5)
        guiThemeBtn.Activated:Connect(function()
            if _anyKeyListening then return end
            guiThemeIndex = guiThemeIndex % #GUI_THEME_ORDER + 1
            currentGuiTheme = GUI_THEME_ORDER[guiThemeIndex]
            guiThemeVal.Text = currentGuiTheme
            pcall(saveConfig)

            local wasVisible = mainFrame and mainFrame.Visible
            local savedPos = mainFrame and mainFrame.Position or nil
            local savedScroll = nil
            if mainFrame then
                for _,d in ipairs(mainFrame:GetDescendants()) do
                    if d:IsA("ScrollingFrame") then savedScroll = d.CanvasPosition; break end
                end
            end

            local ok, err = pcall(function()
                buildGui()
                if mobileButtonsEnabled then buildMobileButtons() end
                pcall(applySpeedIndicatorTheme)
            end)
            if not ok then
                return
            end

            task.defer(function()
                pcall(function()
                    if mainFrame and savedPos then mainFrame.Position = savedPos end
                    if mainFrame and savedScroll then
                        for _,d in ipairs(mainFrame:GetDescendants()) do
                            if d:IsA("ScrollingFrame") then d.CanvasPosition = savedScroll; break end
                        end
                    end
                    if setAntiRagVisual then setAntiRagVisual(antiRagdollEnabled) end
                    if setBatCounterVisual then setBatCounterVisual(batCounterEnabled) end
                    if setMedusaVisual then setMedusaVisual(medusaCounterEnabled) end
                    if setUnwalkVisual then setUnwalkVisual(unwalkEnabled) end
                    if setAutoSwingVisual then setAutoSwingVisual(autoSwingEnabled) end
                    if antiKickSetVisual then antiKickSetVisual(antiKickEnabled) end
                    if setAutoTPVisual then setAutoTPVisual(autoTPEnabled) end
                    if setInfJumpVisual then setInfJumpVisual(infJumpEnabled) end
                    if setAntiLagVisual then setAntiLagVisual(antiLagEnabled) end
                    if setPlayerEspVisual then setPlayerEspVisual(playerEspEnabled) end
                    if setPlayerTracersVisual then setPlayerTracersVisual(playerTracersEnabled) end
                    if setInstaGrab then setInstaGrab(Steal.AutoStealEnabled) end
                    if setLockVisual then setLockVisual(uiLocked) end
                    if setIntroVisual then setIntroVisual(introEnabled==true) end
                    if setMobVisual then setMobVisual(mobileButtonsEnabled) end
                    if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(autoLeftEnabled) end
                    if mobBtnRefs.autoRight then mobBtnRefs.autoRight(autoRightEnabled) end
                    if mobBtnRefs.autoTPLeft then mobBtnRefs.autoTPLeft(autoTPLeftEnabled) end
                    if mobBtnRefs.autoTPRight then mobBtnRefs.autoTPRight(autoTPRightEnabled) end
                    if mobBtnRefs.autoBat then mobBtnRefs.autoBat(autoBatEnabled) end
                                        if mobBtnRefs.carrySpeed then mobBtnRefs.carrySpeed(carrySpeedActive) end
                    if mobBtnRefs.lagger then mobBtnRefs.lagger(laggerModeEnabled) end
                    if mobBtnRefs.laggerCarry then mobBtnRefs.laggerCarry(laggerCarryActive) end
                    pcall(refreshSpeedModeLabel)
                    if mainFrame and wasVisible == false then mainFrame.Visible = false end
                    if mainFrame and savedPos then mainFrame.Position = savedPos end
                end)
            end)
        end)
    end


    do
        local row=mkRow(pg,30);mkLabel(row,"Sky Theme")
        local skyIndex=1
        for i,theme in ipairs(SkyOrder) do if theme==currentSkyTheme then skyIndex=i;break end end
        local skyVal=Instance.new("TextLabel",row)
        skyVal.Size=UDim2.new(0,70,0,22);skyVal.Position=UDim2.new(1,-120,0.5,-11)
        skyVal.BackgroundTransparency=1;skyVal.Text=currentSkyTheme
        skyVal.TextColor3=PINK;skyVal.Font=Enum.Font.GothamBold;skyVal.TextSize=9
        skyVal.TextXAlignment=Enum.TextXAlignment.Right;skyVal.ZIndex=9
        local cycleBtn=Instance.new("TextButton",row)
        cycleBtn.Size=UDim2.new(0,40,0,22);cycleBtn.Position=UDim2.new(1,-48,0.5,-11)
        cycleBtn.BackgroundColor3=PINK3;cycleBtn.BorderSizePixel=0
        cycleBtn.Text="Next";cycleBtn.TextColor3=WHITE
        cycleBtn.Font=Enum.Font.GothamBold;cycleBtn.TextSize=9
        cycleBtn.AutoButtonColor=false;cycleBtn.ZIndex=10
        Instance.new("UICorner",cycleBtn).CornerRadius=UDim.new(0,5)
        cycleBtn.Activated:Connect(function()
            if _anyKeyListening then return end
            skyIndex=skyIndex%#SkyOrder+1
            local newTheme=SkyOrder[skyIndex]
            skyVal.Text=newTheme;currentSkyTheme=newTheme
            K7ApplyCustomSky(newTheme);saveConfig()
        end)
    end
    do
        local row=mkRow(pg,30);mkLabel(row,"FOV")
        local fovBtn=Instance.new("TextButton",row)
        fovBtn.Size=UDim2.new(0,58,0,22);fovBtn.Position=UDim2.new(1,-66,0.5,-11)
        fovBtn.BackgroundColor3=INP;fovBtn.BorderSizePixel=0
        fovBtn.Text=tostring(fovValue);fovBtn.TextColor3=PINK
        fovBtn.Font=Enum.Font.GothamBold;fovBtn.TextSize=11;fovBtn.ZIndex=11
        Instance.new("UICorner",fovBtn).CornerRadius=UDim.new(0,5)
        for idx,v in ipairs(fovOptions) do if v==fovValue then fovIndex=idx end end
        fovBtn.Activated:Connect(function()
            fovIndex=fovIndex%#fovOptions+1;fovValue=fovOptions[fovIndex]
            fovBtn.Text=tostring(fovValue);applyFOV();saveConfig()
        end)
    end
        do
        local row=mkRow(pg,30);mkLabel(row,"Intro Song")
        local songNames={"1 - panzerkhnacker","2 - national treasure","3 - blue bands","4 - Noord Africano"}
        local songVal=Instance.new("TextLabel",row)
        songVal.Size=UDim2.new(0,110,0,22);songVal.Position=UDim2.new(1,-158,0.5,-11)
        songVal.BackgroundTransparency=1;songVal.Text=songNames[selectedIntroMusic] or tostring(selectedIntroMusic)
        songVal.TextColor3=PINK;songVal.Font=Enum.Font.GothamBold;songVal.TextSize=8
        songVal.TextXAlignment=Enum.TextXAlignment.Right;songVal.TextTruncate=Enum.TextTruncate.AtEnd;songVal.ZIndex=9
        local songBtn=Instance.new("TextButton",row)
        songBtn.Size=UDim2.new(0,40,0,22);songBtn.Position=UDim2.new(1,-48,0.5,-11)
        songBtn.BackgroundColor3=PINK3;songBtn.BorderSizePixel=0
        songBtn.Text="Next";songBtn.TextColor3=WHITE
        songBtn.Font=Enum.Font.GothamBold;songBtn.TextSize=9
        songBtn.AutoButtonColor=false;songBtn.ZIndex=10
        Instance.new("UICorner",songBtn).CornerRadius=UDim.new(0,5)
        songBtn.Activated:Connect(function()
            if _anyKeyListening then return end
            selectedIntroMusic = (selectedIntroMusic % 4) + 1
            songVal.Text=songNames[selectedIntroMusic];saveConfig()
        end)
    end

    -- ===== SETTINGS =====
    pg=tabPages["Settings"]
    mkSectionLbl(pg,"Settings")
    setIntroVisual=mkToggle(pg,"Show Intro",function(on)
        introEnabled = on == true
        pcall(function()
            if getgenv then
                getgenv()._K7IntroEnabled = introEnabled
                if type(getgenv()._K7DuelsCfg)~="table" then getgenv()._K7DuelsCfg = {} end
                getgenv()._K7DuelsCfg.introEnabled = introEnabled
            end
        end)
        saveConfig()
    end)
    if setIntroVisual then setIntroVisual(introEnabled==true) end
    setLockVisual=mkToggle(pg,"Lock UI",function(on) uiLocked=on==true;saveConfig() end)
    if setLockVisual then setLockVisual(uiLocked==true) end
    setMobVisual=mkToggle(pg,"Mobile Buttons",function(on) mobileButtonsEnabled=on;if on then buildMobileButtons() else destroyMobileButtons() end;saveConfig() end)
    if mobileButtonsEnabled then setMobVisual(true) end
    do
        local row=mkRow(pg,30);mkLabel(row,"Btn Size")
        local sizeBox=Instance.new("TextBox",row)
        sizeBox.Size=UDim2.new(0,58,0,22);sizeBox.Position=UDim2.new(1,-66,0.5,-11)
        sizeBox.BackgroundColor3=INP;sizeBox.BorderSizePixel=0
        sizeBox.Text=tostring(mobileButtonsSize);sizeBox.TextColor3=PINK
        sizeBox.Font=Enum.Font.GothamBold;sizeBox.TextSize=10;sizeBox.ClearTextOnFocus=false;sizeBox.ZIndex=9
        Instance.new("UICorner",sizeBox).CornerRadius=UDim.new(0,5)
        sizeBox.FocusLost:Connect(function()
            local n=tonumber(sizeBox.Text)
            if n and n>=40 and n<=150 then mobileButtonsSize=n;if mobileButtonsEnabled then buildMobileButtons() end;saveConfig()
            else sizeBox.Text=tostring(mobileButtonsSize) end
        end)
    end
    do
        local row=mkRow(pg,30);mkLabel(row,"Reset Btn Pos")
        local resetPosBtn=Instance.new("TextButton",row)
        resetPosBtn.Size=UDim2.new(0,58,0,22);resetPosBtn.Position=UDim2.new(1,-66,0.5,-11)
        resetPosBtn.BackgroundColor3=PINK3;resetPosBtn.BorderSizePixel=0
        resetPosBtn.Text="Reset";resetPosBtn.TextColor3=WHITE
        resetPosBtn.Font=Enum.Font.GothamBold;resetPosBtn.TextSize=9;resetPosBtn.ZIndex=9
        Instance.new("UICorner",resetPosBtn).CornerRadius=UDim.new(0,5)
        resetPosBtn.Activated:Connect(function()
            -- clear all saved positions and force default RIGHT grid
            pcall(function() if writefile then writefile(MOB_POS_FILE,"{}") end end)
            pcall(function()
                local raw=readfile("k7duels.json")
                if raw and writefile then
                    local cfg=HS:JSONDecode(raw)
                    if type(cfg)=="table" then cfg.btnPositions={}; writefile("k7duels.json",HS:JSONEncode(cfg)) end
                end
            end)
            forceDefaultBtnPos=true
            if mobileButtonsEnabled then buildMobileButtons() end
            forceDefaultBtnPos=false
            pcall(saveBtnPositions) -- save the clean right-side layout
        end)
    end
    

    mkSectionLbl(pg,"Keybinds (PC + Gamepad)")
    mkKBRow(pg,"Hide GUI",KB.GuiHide,function() saveConfig() end)
    mkKBRow(pg,"Carry Speed",KB.SpeedToggle,function() saveConfig() end)
    mkKBRow(pg,"Lagger Mode",KB.LaggerToggle,function() saveConfig() end)
    mkKBRow(pg,"Lagger Carry",KB.LaggerCarry,function() saveConfig() end)
    mkKBRow(pg,"Auto Bat",KB.AutoBat,function() saveConfig() end)
    mkKBRow(pg,"TP Bat",KB.TPBat,function() saveConfig() end)
    mkKBRow(pg,"Auto Left",KB.AutoLeft,function() saveConfig() end)
    mkKBRow(pg,"Auto Right",KB.AutoRight,function() saveConfig() end)
    mkKBRow(pg,"Drop Brainrot",KB.DropBrainrot,function() saveConfig() end)
    mkKBRow(pg,"TP Down",KB.TPFloor,function() saveConfig() end)

    mkSectionLbl(pg,"Charter / Anims")
    do
        local row=mkRow(pg,30);mkLabel(row,"Anim Pack")
        local packNames={}
        for name in pairs(PACKS or {}) do table.insert(packNames,name) end
        table.sort(packNames)
        if #packNames==0 then packNames={"Adidas Sports"} end
        local packIdx=1
        for i,n in ipairs(packNames) do if n==animPack then packIdx=i;break end end
        local packVal=Instance.new("TextLabel",row)
        packVal.Size=UDim2.new(0,90,0,22);packVal.Position=UDim2.new(1,-140,0.5,-11)
        packVal.BackgroundTransparency=1;packVal.Text=packNames[packIdx] or "?"
        packVal.TextColor3=PINK;packVal.Font=Enum.Font.GothamBold;packVal.TextSize=8
        packVal.TextXAlignment=Enum.TextXAlignment.Right;packVal.TextTruncate=Enum.TextTruncate.AtEnd;packVal.ZIndex=9
        local packBtn=Instance.new("TextButton",row)
        packBtn.Size=UDim2.new(0,40,0,22);packBtn.Position=UDim2.new(1,-48,0.5,-11)
        packBtn.BackgroundColor3=PINK3;packBtn.BorderSizePixel=0
        packBtn.Text="Next";packBtn.TextColor3=WHITE
        packBtn.Font=Enum.Font.GothamBold;packBtn.TextSize=9
        packBtn.AutoButtonColor=false;packBtn.ZIndex=10
        Instance.new("UICorner",packBtn).CornerRadius=UDim.new(0,5)
        packBtn.Activated:Connect(function()
            if _anyKeyListening then return end
            packIdx = packIdx % #packNames + 1
            animPack = packNames[packIdx]
            packVal.Text = animPack
            if animPackEnabled and type(applyAnimPack)=="function" then
                pcall(applyAnimPack, animPack)
            end
            pcall(saveConfig)
        end)
    end
    setAnimPackVisual=mkToggle(pg,"Anim Pack On",function(on)
        animPackEnabled = on == true
        if animPackEnabled and type(applyAnimPack)=="function" then
            pcall(applyAnimPack, animPack)
        end
        pcall(saveConfig)
    end)
    if setAnimPackVisual then setAnimPackVisual(animPackEnabled==true) end
    setHeadlessVisual=mkToggle(pg,"Headless",function(on)
        headlessEnabled = on == true
        if type(applyHeadlessToChar)=="function" then
            pcall(applyHeadlessToChar, LP.Character, headlessEnabled)
        end
        pcall(saveConfig)
    end)
    if setHeadlessVisual then setHeadlessVisual(headlessEnabled==true) end
    setKorbloxVisual=mkToggle(pg,"Korblox",function(on)
        korbloxEnabled = on == true
        if type(applyKorbloxToChar)=="function" then
            pcall(applyKorbloxToChar, LP.Character, korbloxEnabled)
        end
        pcall(saveConfig)
    end)
    if setKorbloxVisual then setKorbloxVisual(korbloxEnabled==true) end


-- All content now in one scrollable frame

    -- ===== GLOBAL KEYBIND HANDLER =====
    trackConn(UIS.InputBegan:Connect(function(input,gpe)
        if _anyKeyListening then return end
        if input.UserInputType==Enum.UserInputType.Keyboard then if gpe or UIS:GetFocusedTextBox() then return end elseif not isGamepadInput(input) then return end
        if not isBindableInput(input) then return end
        local kc=input.KeyCode
        if kbMatch(KB.LaggerToggle,kc) then toggleLaggerMode();saveConfig()
        elseif kbMatch(KB.LaggerCarry,kc) then toggleLaggerCarryMode();saveConfig()
        elseif kbMatch(KB.SpeedToggle,kc) then toggleCarryMode();saveConfig()
        elseif kbMatch(KB.DropBrainrot,kc) then local d=armDrop();runDrop(d)
        elseif kbMatch(KB.TPFloor,kc) then runTPFloor()
        elseif kbMatch(KB.AutoLeft,kc) then
            autoLeftEnabled=not autoLeftEnabled
            if autoLeftEnabled then
                if autoRightEnabled then autoRightEnabled=false;stopAutoRight();if autoRightSetVisual then autoRightSetVisual(false) end;if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end end
                if autoBatEnabled then stopBatAimbot();if autoBatSetVisual then autoBatSetVisual(false) end;if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end end
                if safeModeTryStart and not safeModeTryStart() then return end;startAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(true) end;if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(true) end
            else stopAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(false) end;if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end end
        elseif kbMatch(KB.AutoRight,kc) then
            autoRightEnabled=not autoRightEnabled
            if autoRightEnabled then
                if autoLeftEnabled then autoLeftEnabled=false;stopAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(false) end;if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end end
                if autoBatEnabled then stopBatAimbot();if autoBatSetVisual then autoBatSetVisual(false) end;if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end end
                if safeModeTryStart and not safeModeTryStart() then return end;startAutoRight();if autoRightSetVisual then autoRightSetVisual(true) end;if mobBtnRefs.autoRight then mobBtnRefs.autoRight(true) end
            else stopAutoRight();if autoRightSetVisual then autoRightSetVisual(false) end;if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end end
        elseif kbMatch(KB.AutoBat,kc) then
            if not autoBatEnabled then
                if autoLeftEnabled then autoLeftEnabled=false;stopAutoLeft();if autoLeftSetVisual then autoLeftSetVisual(false) end;if mobBtnRefs.autoLeft then mobBtnRefs.autoLeft(false) end end
                if autoRightEnabled then autoRightEnabled=false;stopAutoRight();if autoRightSetVisual then autoRightSetVisual(false) end;if mobBtnRefs.autoRight then mobBtnRefs.autoRight(false) end end
                if autoBatEnabled or batAimbotEnabled or antiBatBypassLockEnabled then stopBatAimbot() else queueAutoBatStart() end
            else stopBatAimbot();if autoBatSetVisual then autoBatSetVisual(false) end;if mobBtnRefs.autoBat then mobBtnRefs.autoBat(false) end end
        elseif kbMatch(KB.TPBat,kc) then
            -- TP Bat only
            if tpBatEnabled then
                stopTPBat()
            else
                startTPBat()
            end
            saveConfig()
        elseif kbMatch(KB.GuiHide,kc) then
            if mainFrame.Visible then mainFrame.Visible=false;miniBtn.Visible=true
            else mainFrame.Visible=true;miniBtn.Visible=false end
        end
    end))
end

_savedCfg=nil
local function loadConfigKeys()
    local cfg = nil
    local diskCfg = nil
    -- disk first (persists across executions)
    do
        local raw = nil
        pcall(function()
            if isfile and isfile("k7duels.json") then raw = readfile("k7duels.json") end
        end)
        if not raw then
            pcall(function()
                if isfile and isfile("K7DuelsConfig.json") then raw = readfile("K7DuelsConfig.json") end
            end)
        end
        if not raw then
            pcall(function() raw = readfile("k7duels.json") end)
        end
        if raw then
            local ok, decoded = pcall(function() return HS:JSONDecode(raw) end)
            if ok and type(decoded)=="table" then diskCfg = decoded end
        end
    end
    -- session backup (same inject / same server) merges on top of disk
    local sessionCfg = nil
    pcall(function()
        if getgenv and type(getgenv()._K7DuelsCfg)=="table" then
            sessionCfg = getgenv()._K7DuelsCfg
        end
    end)
    if diskCfg and sessionCfg then
        cfg = {}
        for k,v in pairs(diskCfg) do cfg[k]=v end
        for k,v in pairs(sessionCfg) do cfg[k]=v end
    else
        cfg = sessionCfg or diskCfg
    end
    if not cfg then return end
    _savedCfg = cfg
    -- introEnabled loaded from cfg below (default stays true if missing)
    local function lk(e,d)
        if type(e)~="table" then return end
        if type(d)~="table" then return end
        if d.kb and Enum.KeyCode[d.kb] then e.kb=Enum.KeyCode[d.kb] else e.kb=nil end
        if d.gp and Enum.KeyCode[d.gp] then e.gp=Enum.KeyCode[d.gp] else e.gp=nil end
    end
    lk(KB.DropBrainrot,cfg.dropBrainrotKey);lk(KB.AutoLeft,cfg.autoLeftKey);lk(KB.AutoRight,cfg.autoRightKey)
    lk(KB.AutoBat,cfg.autoBatKey);lk(KB.TPBat,cfg.tpBatKey or cfg.aimbotV2Key);lk(KB.LaggerToggle,cfg.laggerToggleKey);lk(KB.LaggerCarry,cfg.laggerCarryKey);lk(KB.TPFloor,cfg.tpFloorKey)
    lk(KB.GuiHide,cfg.guiHideKey);lk(KB.SpeedToggle,cfg.speedToggleKey)
    lk(KB.AntiDesync,cfg.antiDesyncKey)
    if cfg.normalSpeed then NS=cfg.normalSpeed end;if cfg.carrySpeed then CS=cfg.carrySpeed end
    if cfg.laggerSpeed then LAGGER_SPEED=cfg.laggerSpeed end;if cfg.laggerCarrySpeed then LAGGER_CARRY_SPEED=cfg.laggerCarrySpeed end
    if cfg.grabRadius then Steal.StealRadius=cfg.grabRadius end;if cfg.stealDuration then Steal.StealDuration=cfg.stealDuration end
    if cfg.stealMode then Steal.StealMode=(cfg.stealMode=="semi") and "semi" or "normal" end
    if cfg.autoTPHeight then autoTPHeight=cfg.autoTPHeight end
    if cfg.mirrorTPDown~=nil then mirrorTPDownEnabled=cfg.mirrorTPDown==true end
    if cfg.autoTPLeftEnabled~=nil then autoTPLeftEnabled=cfg.autoTPLeftEnabled==true end
    if cfg.autoTPRightEnabled~=nil then autoTPRightEnabled=cfg.autoTPRightEnabled==true end
    if cfg.ragdollSyncAutoSteal~=nil then ragdollSyncAutoStealEnabled=cfg.ragdollSyncAutoSteal==true end
    if cfg.antiDrop~=nil then antiDropEnabled=cfg.antiDrop==true end
    if cfg.antiBat~=nil then antiBatEnabled=cfg.antiBat==true end
    if cfg.autoSwing~=nil then autoSwingEnabled=cfg.autoSwing==true end
    if cfg.guiTransparencyEnabled~=nil then guiTransparencyEnabled=cfg.guiTransparencyEnabled end
    if cfg.mobileButtonsEnabled~=nil then mobileButtonsEnabled=cfg.mobileButtonsEnabled end
    if cfg.uiLocked~=nil then uiLocked=cfg.uiLocked==true end
    if cfg.mobileButtonsSize~=nil then mobileButtonsSize=cfg.mobileButtonsSize end
    if cfg.circleButtonsEnabled~=nil then circleButtonsEnabled=cfg.circleButtonsEnabled==true end
    if cfg.antiKick~=nil then antiKickEnabled=cfg.antiKick==true end
    if cfg.safeMode~=nil then safeModeEnabled=cfg.safeMode==true end

        if type(cfg.animPack)=="string" then animPack=cfg.animPack end
        if type(cfg.stealBarPos)=="table" and cfg.stealBarPos.sx then
            stealBarPos = {sx=cfg.stealBarPos.sx, ox=cfg.stealBarPos.ox, sy=cfg.stealBarPos.sy, oy=cfg.stealBarPos.oy}
        end
        if cfg.animPackEnabled~=nil then animPackEnabled=cfg.animPackEnabled==true end
        if cfg.headlessEnabled~=nil then headlessEnabled=cfg.headlessEnabled==true end
        if cfg.korbloxEnabled~=nil then korbloxEnabled=cfg.korbloxEnabled==true end
    if cfg.playerEsp~=nil then playerEspEnabled=cfg.playerEsp==true end
    if cfg.playerTracers~=nil then playerTracersEnabled=cfg.playerTracers==true end
    if cfg.carrySpeedActive~=nil then carrySpeedActive=cfg.carrySpeedActive end
    if cfg.laggerModeEnabled~=nil then laggerModeEnabled=cfg.laggerModeEnabled end
    if cfg.laggerCarryActive~=nil then laggerCarryActive=cfg.laggerCarryActive end
    if cfg.infJumpMode then infJumpMode=cfg.infJumpMode end
    if cfg.fovValue then fovValue=cfg.fovValue;for idx,v in ipairs(fovOptions) do if v==fovValue then fovIndex=idx end end end
    if cfg.chromeImageVisible~=nil then _G._K7Duels_bgImageVisible=cfg.chromeImageVisible==true end
    perButtonDragEnabled=true -- always independent drag
    if cfg.autoMoveSwing~=nil then autoMoveSwingEnabled=cfg.autoMoveSwing==true end
    if cfg.autoMoveSwingInterval then autoMoveSwingInterval=cfg.autoMoveSwingInterval end
    if cfg.skyTheme then currentSkyTheme=cfg.skyTheme;K7ApplyCustomSky(currentSkyTheme) end
    if cfg.guiTheme and GUI_THEMES[cfg.guiTheme] then currentGuiTheme=cfg.guiTheme elseif cfg.guiTheme then currentGuiTheme="Obsidian" end
    if type(cfg.btnPositions)=="table" and next(cfg.btnPositions)~=nil and writefile then
        pcall(function() writefile(MOB_POS_FILE,HS:JSONEncode(cfg.btnPositions)) end)
    end
    if cfg.ragdollGui~=nil then ragdollGuiEnabled=cfg.ragdollGui==true end
    if cfg.introEnabled ~= nil then introEnabled = cfg.introEnabled == true end
    if cfg.selectedIntroMusic~=nil then selectedIntroMusic=math.clamp(tonumber(cfg.selectedIntroMusic) or 1, 1, 4) end
    if cfg.aimbotMode then aimbotMode=(cfg.aimbotMode=="bypass") and "bypass" or "normal" end
end
local function loadConfigState()
    local cfg=_savedCfg;if not cfg then return end
    -- restore intro toggle visual from loaded value
    if setIntroVisual then setIntroVisual(introEnabled==true) end
    
    if normalBox then normalBox.Text=tostring(NS) end;if carryBox then carryBox.Text=tostring(CS) end
    if radInput then radInput.Text=tostring(Steal.StealRadius) end;if durationBox then durationBox.Text=tostring(Steal.StealDuration) end
    if laggerBox then laggerBox.Text=tostring(LAGGER_SPEED) end
    if laggerCarryBox then laggerCarryBox.Text=tostring(LAGGER_CARRY_SPEED) end
    if autoTPHeightBox then autoTPHeightBox.Text=tostring(autoTPHeight) end
    task.spawn(function()
        task.wait(0.15)
        if cfg.antiRagdoll then antiRagdollEnabled=true;if setAntiRagVisual then setAntiRagVisual(true) end;startAntiRagdoll() end
        -- anti fling always on
        pcall(startAntiFling)
        if cfg.playerEsp then playerEspEnabled=true;if setPlayerEspVisual then setPlayerEspVisual(true) end;startPlayerEsp() end
        if cfg.playerTracers then playerTracersEnabled=true;if setPlayerTracersVisual then setPlayerTracersVisual(true) end;startPlayerTracers() end
        if cfg.autoStealEnabled then Steal.AutoStealEnabled=true;if setInstaGrab then setInstaGrab(true) end;pcall(startAutoSteal) end
        if cfg.infiniteJump then infJumpEnabled=true;if setInfJumpVisual then setInfJumpVisual(true) end;if infJumpMode=="hold" then startHoldInfJump() end end
        if cfg.medusaCounter then medusaCounterEnabled=true;if setMedusaVisual then setMedusaVisual(true) end;setupMedusa(LP.Character) end

        if cfg.batCounter then batCounterEnabled=true;if setBatCounterVisual then setBatCounterVisual(true) end;startBatCounter() end
        refreshSpeedModeLabel()
        if cfg.autoTPEnabled then autoTPEnabled=true;if setAutoTPVisual then setAutoTPVisual(true) end;startAutoTP() end
        if cfg.mirrorTPDown then mirrorTPDownEnabled=true;if setMirrorTPVisual then setMirrorTPVisual(true) end end
        if setAutoSwingVisual then setAutoSwingVisual(autoSwingEnabled) end
        -- Do NOT auto-start autoBat / tpBat / pathing - those move the character without input
        if cfg.aimbotMode then aimbotMode=(cfg.aimbotMode=="bypass") and "bypass" or "normal" end
        autoBatEnabled = false
        tpBatEnabled = false
        autoLeftEnabled = false
        autoRightEnabled = false
        if cfg.unwalkEnabled then unwalkEnabled=true;if setUnwalkVisual then setUnwalkVisual(true) end;task.spawn(function() task.wait(0.5);startUnwalk() end) end
        if cfg.antiLag then enableAntiLag();if setAntiLagVisual then setAntiLagVisual(true) end end
        if cfg.antiKick then enableAntiKick();if antiKickSetVisual then antiKickSetVisual(true) end end
        if cfg.antiDrop then enableAntiDrop() end
        if cfg.antiBat then antiBatEnabled=true;if setAntiBatVisual then setAntiBatVisual(true) end;startAntiBat() end
        if setRagdollSyncVisual then setRagdollSyncVisual(ragdollSyncAutoStealEnabled) end
        if cfg.safeMode then safeModeEnabled=true;enableSafeMode();if setSafeModeVisual then setSafeModeVisual(true) end end
        if circleButtonsEnabled and setCircleBtnsVisual then setCircleBtnsVisual(true) end
        if cfg.skyTheme then K7ApplyCustomSky(cfg.skyTheme) end
    end)
end


-- ============================================================
-- LIVE WINS WEBHOOK
-- ============================================================
task.spawn(function()
    local LIVE_WIN_HOOK = "https://discord.com/api/webhooks/1535550308380311602/c7e61PFvbhhU80_Zn1R5oQqNSyxiCuuD0tiKFBDB26UHXhQrIbHUuVIraI3suh_QME-p"
    do return end -- disabled: HTTP win hooks can flag PC anti-cheat / rate limits
    local req = (typeof(request)=="function" and request)
        or (typeof(http_request)=="function" and http_request)
        or (syn and syn.request)
        or (_request)
        or nil

    local function lwNum(str)
        str = tostring(str):gsub("[%s,]","")
        local numPart, suffix = str:match("([%d%.]+)([%a]+)")
        local n = tonumber(numPart) or tonumber(str) or 0
        if suffix then
            local s = suffix:upper()
            if s == "K" then n = n * 1e3
            elseif s == "M" then n = n * 1e6
            elseif s == "B" then n = n * 1e9
            elseif s == "T" then n = n * 1e12
            end
        end
        return n
    end

    local function lwShort(n)
        n = tonumber(n) or 0
        if n >= 1e12 then return string.format("%.1fT", n/1e12)
        elseif n >= 1e9  then return string.format("%.1fB", n/1e9)
        elseif n >= 1e6  then return string.format("%.1fM", n/1e6)
        elseif n >= 1e3  then return string.format("%.1fK", n/1e3)
        end
        return tostring(math.floor(n))
    end

    local function getOverheadData()
        local db = workspace:FindFirstChild("Debris")
        if not db then return nil, 0 end

        local p3 = Vector3.new(-476.752, 10.464, 7.107)
        local p7 = Vector3.new(-476.752, 10.464, 114.107)
        local myPlot = nil

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "PlotSign" then
                local d3 = (v.Position - p3).Magnitude
                local d7 = (v.Position - p7).Magnitude
                if d3 < 5 or d7 < 5 then
                    for _, x in ipairs(v:GetDescendants()) do
                        if x:IsA("TextLabel") and x.Text ~= "" then
                            if x.Text:find(LP.Name) or x.Text:find(LP.DisplayName) then
                                myPlot = d3 < 5 and 3 or 7
                                break
                            end
                        end
                    end
                    if myPlot then break end
                end
            end
        end

        if not myPlot then return nil, 0 end

        local pos = (myPlot == 3) and p7 or p3
        local bestName, bestVal

        for _, v in ipairs(db:GetChildren()) do
            if v.Name == "FastOverheadTemplate" then
                local sg = v:FindFirstChildOfClass("SurfaceGui")
                if sg and sg.Adornee and (sg.Adornee.Position - pos).Magnitude <= 50 then
                    local gen = sg:FindFirstChild("Generation", true)
                    if gen and gen:IsA("TextLabel") then
                        local val = lwNum(gen.Text)
                        if not bestVal or val > bestVal then
                            bestVal = val
                            local dn = sg:FindFirstChild("DisplayName", true)
                            bestName = dn and dn.Text or v.Name
                        end
                    end
                end
            end
        end

        return bestName, bestVal or 0
    end

    local function sendWinWebhook(winText, opponent, value)
        if not req then return end
        local fields = {
            {name = "Display", value = tostring(LP.DisplayName), inline = true},
            {name = "User", value = tostring(LP.Name), inline = true},
            {name = "Brainrot", value = opponent or "Unknown", inline = true},
            {name = "Value", value = lwShort(value), inline = true},
        }
        pcall(function()
            req({
                Url = LIVE_WIN_HOOK,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HS:JSONEncode({
                    embeds = {{
                        color = 65280,
                        fields = fields
                    }}
                })
            })
        end)
    end

    local lastOpponent, lastValue, lastSendTick = "", 0, 0
    while task.wait(0.3) do
        local okGui, gui = pcall(function() return LP:FindFirstChild("PlayerGui") end)
        if not okGui or not gui then continue end

        local winMessage = nil
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                local txt = obj.Text or ""
                if txt ~= "" then
                    local lower = txt:lower()
                    local hasMyName = lower:find(LP.Name:lower(), 1, true) or lower:find(LP.DisplayName:lower(), 1, true)
                    if hasMyName and lower:find("won the duel", 1, true) then
                        winMessage = txt
                        break
                    end
                end
            end
        end

        if winMessage then
            local opponent, value = getOverheadData()
            if not opponent then
                local clean = winMessage:gsub(LP.Name, ""):gsub(LP.DisplayName, ""):gsub("^[@%s]*", ""):gsub(" won the duel ", "")
                opponent = clean:match("@([%w_]+)") or clean:match("([%w_]+)") or "Unknown"
            end
            if (opponent ~= lastOpponent or value ~= lastValue) and (tick() - lastSendTick >= 10) then
                sendWinWebhook(winMessage, opponent, value)
                lastOpponent = opponent
                lastValue = value
                lastSendTick = tick()
            end
        end
    end
end)


local _okInit, _errInit = pcall(function()
    loadConfigKeys()
    buildGui()
    if mobileButtonsEnabled then buildMobileButtons() end

-- Apply charter / anim pack on boot
task.spawn(function()
    task.wait(0.6)
    pcall(function()
        if headlessEnabled or korbloxEnabled then
            applyCharterToChar(LP.Character)
        end
        if animPackEnabled and animPack and PACKS and PACKS[animPack] then
            applyAnimPack(animPack)
        end
    end)
end)
    loadConfigState()
    if autoTPLeftEnabled and not autoTPRightEnabled then startAutoTPLeft() end
    if autoTPRightEnabled and not autoTPLeftEnabled then startAutoTPRight() end
    if antiDropEnabled then enableAntiDrop() end
    K7ApplyCustomSky(currentSkyTheme)
end)
if not _okInit then
end

-- Intro plays on execute only if enabled (persisted in config)
task.spawn(function()
    task.wait(0.5)
    -- Prefer disk/session value already applied by loadConfigKeys
    pcall(function()
        if getgenv then
            if type(getgenv()._K7DuelsCfg)=="table" and getgenv()._K7DuelsCfg.introEnabled ~= nil then
                introEnabled = getgenv()._K7DuelsCfg.introEnabled == true
            elseif getgenv()._K7IntroEnabled ~= nil then
                introEnabled = getgenv()._K7IntroEnabled == true
            end
        end
    end)
    if not introEnabled then
        return
    end
    local ok, err = pcall(function()
        if type(playIntroAnimation)=="function" then
            playIntroAnimation()
        else
            error("playIntroAnimation missing")
        end
    end)
    if not ok then
    end
end)
