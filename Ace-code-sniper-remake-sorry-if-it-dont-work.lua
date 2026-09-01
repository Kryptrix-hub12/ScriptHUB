local cloneref = cloneref or function(object) return object end
local Players           = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService        = cloneref(game:GetService("RunService"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local HttpService       = cloneref(game:GetService("HttpService"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
if getgenv and getgenv().StopAura then pcall(getgenv().StopAura) end

-- ===================== CONFIG =====================
local CONFIG_FILE = "ace_code_sniper_auto_redeem_test_config.json"
local savedConfig = {
    codeSniper = true,
    autoSubmit = true,
    submitAfter = 3,
    retypeInvalid = false,
    riddleSolver = false,
}
pcall(function()
    if type(isfile) == "function" and type(readfile) == "function"
    and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if savedConfig[k] ~= nil then savedConfig[k] = v end
            end
        end
    end
end)
local function saveConfig()
    if type(writefile) ~= "function" then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            codeSniper = savedConfig.codeSniper,
            autoSubmit = savedConfig.autoSubmit,
            submitAfter = savedConfig.submitAfter,
            retypeInvalid = savedConfig.retypeInvalid,
            riddleSolver = savedConfig.riddleSolver,
        }))
    end)
end

-- ===================== FULL SAB DATABASE =====================
local SAB_DB = {
    ["how old am i"] = "24", ["how old is sammy"] = "24", ["my age"] = "24", ["sammy age"] = "24", ["age"] = "24",
    ["spydersammy age"] = "24", ["sammy is how old"] = "24", ["what age is sammy"] = "24",
    ["where am i from"] = "BRAZIL", ["where is sammy from"] = "BRAZIL", ["my country"] = "BRAZIL",
    ["sammy country"] = "BRAZIL", ["sammy origin"] = "BRAZIL", ["spydersammy country"] = "BRAZIL",
    ["sammy nationality"] = "BRAZIL", ["where does sammy live"] = "BRAZIL", ["sammy location"] = "BRAZIL",
    ["favorite color"] = "BLUE", ["fav color"] = "BLUE", ["my color"] = "BLUE", ["sammy color"] = "BLUE",
    ["sammy favourite color"] = "BLUE", ["sammy fav color"] = "BLUE", ["spydersammy favorite color"] = "BLUE",
    ["sammy preferred color"] = "BLUE",
    ["favorite football player"] = "RONALDO", ["fav football player"] = "RONALDO", ["my favorite football player"] = "RONALDO",
    ["ronaldo"] = "RONALDO", ["sammy favorite player"] = "RONALDO", ["sammy fav player"] = "RONALDO",
    ["sammy football player"] = "RONALDO", ["favorite soccer player"] = "RONALDO", ["fav soccer player"] = "RONALDO",
    ["sammy favorite footballer"] = "RONALDO",
    ["game created on"] = "FRIDAY", ["created on"] = "FRIDAY", ["what day was the game created"] = "FRIDAY",
    ["what day was sab created"] = "FRIDAY", ["game creation day"] = "FRIDAY", ["day sab was created"] = "FRIDAY",
    ["day steal a brainrot was made"] = "FRIDAY", ["what day was steal a brainrot created"] = "FRIDAY",
    ["day of creation"] = "FRIDAY", ["sab creation day"] = "FRIDAY", ["when was sab created"] = "FRIDAY",
    ["sab was created on"] = "FRIDAY", ["what day was this game created"] = "FRIDAY", ["release day"] = "FRIDAY",
    ["launch day"] = "FRIDAY", ["release month"] = "MAY", ["release year"] = "2025", ["release date"] = "MAY162025",
    ["when was sab released"] = "MAY162025", ["sab release date"] = "MAY162025", ["steal a brainrot release date"] = "MAY162025",
    ["game release date"] = "MAY162025",
    ["first mutation"] = "GOLD", ["1st mutation"] = "GOLD", ["second mutation"] = "DIAMOND", ["2nd mutation"] = "DIAMOND",
    ["third mutation"] = "LAVA", ["3rd mutation"] = "LAVA", ["fourth mutation"] = "RAINBOW", ["4th mutation"] = "RAINBOW",
    ["fifth mutation"] = "BLOODROT", ["5th mutation"] = "BLOODROT", ["sixth mutation"] = "CANDY", ["6th mutation"] = "CANDY",
    ["seventh mutation"] = "CURSED", ["7th mutation"] = "CURSED", ["eighth mutation"] = "DIVINE", ["8th mutation"] = "DIVINE",
    ["ninth mutation"] = "CYBER", ["9th mutation"] = "CYBER", ["tenth mutation"] = "PHANTOM", ["10th mutation"] = "PHANTOM",
    ["eleventh mutation"] = "GALAXY", ["11th mutation"] = "GALAXY", ["twelfth mutation"] = "YIN YANG", ["12th mutation"] = "YIN YANG",
    ["gold mutation multiplier"] = "1.25X", ["gold multiplier"] = "1.25X", ["diamond mutation multiplier"] = "1.5X",
    ["diamond multiplier"] = "1.5X", ["lava mutation multiplier"] = "6X", ["lava multiplier"] = "6X",
    ["rainbow mutation multiplier"] = "10X", ["rainbow multiplier"] = "10X", ["cursed mutation multiplier"] = "9X",
    ["cursed multiplier"] = "9X", ["divine mutation multiplier"] = "10X", ["divine multiplier"] = "10X",
    ["cyber mutation multiplier"] = "11X", ["cyber multiplier"] = "11X", ["radioactive mutation multiplier"] = "8.5X",
    ["radioactive multiplier"] = "8.5X", ["galaxy mutation multiplier"] = "7X", ["galaxy multiplier"] = "7X",
    ["yin yang mutation multiplier"] = "7.5X", ["yin yang multiplier"] = "7.5X", ["candy mutation multiplier"] = "4X",
    ["candy multiplier"] = "4X", ["bloodrot mutation multiplier"] = "2X", ["bloodrot multiplier"] = "2X",
    ["rarest mutation"] = "RAINBOW", ["hardest mutation to get"] = "RAINBOW", ["most common mutation"] = "GOLD",
    ["easiest mutation to get"] = "GOLD", ["what is the strongest mutation"] = "CYBER", ["best mutation"] = "CYBER",
    ["highest multiplier mutation"] = "CYBER", ["what mutation has highest multiplier"] = "CYBER",
    ["lava event mutation"] = "LAVA", ["molten event mutation"] = "LAVA", ["bloodmoon mutation"] = "BLOODROT",
    ["bloodmoon event mutation"] = "BLOODROT", ["candy aurora mutation"] = "CANDY", ["cursed event mutation"] = "CURSED",
    ["divine event mutation"] = "DIVINE", ["cyber event mutation"] = "CYBER", ["galaxy event mutation"] = "GALAXY",
    ["yin yang event mutation"] = "YIN YANG", ["radioactive event mutation"] = "RADIOACTIVE",
    ["first machine"] = "RAINBOW MACHINE", ["1st machine"] = "RAINBOW MACHINE", ["second machine"] = "BUBBLEGUM MACHINE",
    ["2nd machine"] = "BUBBLEGUM MACHINE", ["third machine"] = "FUSE MACHINE", ["3rd machine"] = "FUSE MACHINE",
    ["fourth machine"] = "CRAFT MACHINE", ["4th machine"] = "CRAFT MACHINE", ["fifth machine"] = "WITCH FUSE",
    ["5th machine"] = "WITCH FUSE", ["sixth machine"] = "BRAINROT DEALER", ["6th machine"] = "BRAINROT DEALER",
    ["seventh machine"] = "BRAINROT TRADER", ["7th machine"] = "BRAINROT TRADER", ["eighth machine"] = "SANTA'S FUSE",
    ["8th machine"] = "SANTA'S FUSE", ["ninth machine"] = "SANTA'S SHOP", ["9th machine"] = "SANTA'S SHOP",
    ["tenth machine"] = "NEW YEAR'S MACHINE", ["10th machine"] = "NEW YEAR'S MACHINE", ["eleventh machine"] = "DUELS MACHINE",
    ["11th machine"] = "DUELS MACHINE", ["twelfth machine"] = "CUPID'S MACHINE", ["12th machine"] = "CUPID'S MACHINE",
    ["thirteenth machine"] = "TRADE MACHINE", ["13th machine"] = "TRADE MACHINE", ["fourteenth machine"] = "DIVINE FUSE",
    ["14th machine"] = "DIVINE FUSE", ["fifteenth machine"] = "EGG INCUBATOR", ["15th machine"] = "EGG INCUBATOR",
    ["sixteenth machine"] = "CYBER CRAFT MACHINE", ["16th machine"] = "CYBER CRAFT MACHINE",
    ["seventeenth machine"] = "SUMMER FUSE", ["17th machine"] = "SUMMER FUSE", ["eighteenth machine"] = "LOS TRADERS",
    ["18th machine"] = "LOS TRADERS",
    ["og brainrot cannot be obtained"] = "HEADLESS HORSEMAN", ["headless horseman"] = "HEADLESS HORSEMAN",
    ["first og added"] = "STRAWBERRYELEPHANT", ["1st og"] = "STRAWBERRYELEPHANT", ["1st og brainrot"] = "STRAWBERRYELEPHANT",
    ["first og brainrot"] = "STRAWBERRYELEPHANT", ["second og added"] = "MEOWL", ["2nd og"] = "MEOWL",
    ["2nd og brainrot"] = "MEOWL", ["second og brainrot"] = "MEOWL", ["third og added"] = "SKIBIDITOILET",
    ["3rd og"] = "SKIBIDITOILET", ["3rd og brainrot"] = "SKIBIDITOILET", ["third og brainrot"] = "SKIBIDITOILET",
    ["fourth og added"] = "HEADLESS HORSEMAN", ["4th og"] = "HEADLESS HORSEMAN", ["4th og brainrot"] = "HEADLESS HORSEMAN",
    ["fifth og added"] = "JOHNPORK", ["5th og"] = "JOHNPORK", ["5th og brainrot"] = "JOHNPORK",
    ["fifth og brainrot"] = "JOHNPORK", ["how many og brainrots are there"] = "4", ["total og brainrots"] = "4",
    ["number of og brainrots"] = "4",
    ["strawberry elephant income"] = "750M/S", ["strawberryelephant income"] = "750M/S",
    ["highest income brainrot"] = "STRAWBERRYELEPHANT", ["most income brainrot"] = "STRAWBERRYELEPHANT",
    ["best brainrot for income"] = "STRAWBERRYELEPHANT", ["meowl income"] = "600M/S",
    ["headless horseman income"] = "550M/S", ["skibidi toilet income"] = "450M/S",
    ["highest rarity"] = "OG", ["rarest rarity"] = "OG", ["best rarity"] = "OG", ["top rarity"] = "OG",
    ["lowest rarity"] = "COMMON", ["most common rarity"] = "COMMON", ["how many rarities"] = "8",
    ["total rarities"] = "8", ["number of rarities"] = "8",
    ["common rarity color"] = "GREEN", ["rare rarity color"] = "BLUE", ["epic rarity color"] = "PURPLE",
    ["legendary rarity color"] = "YELLOW", ["mythic rarity color"] = "RED", ["brainrot god color"] = "RAINBOW",
    ["secret rarity color"] = "BLACK AND WHITE", ["og rarity color"] = "BLACK AND YELLOW",
    ["how many brainrots"] = "408", ["total brainrots"] = "408", ["number of brainrots"] = "408",
    ["brainrot count"] = "408", ["how many brainrots in sab"] = "408",
    ["fire represents"] = "DRAGON", ["fire stands for"] = "DRAGON", ["won the world cup"] = "ARGENTINA",
    ["world cup winner"] = "ARGENTINA", ["world cup"] = "ARGENTINA", ["worst game owner"] = "SECRETLOKII",
    ["most boring game owner"] = "SECRETLOKII", ["most boring game on roblox"] = "KEYBOARDESCAPE",
    ["spawned during admin abuse war"] = "RACOONINI JANDELINI", ["won the admin abuse war"] = "GROWAGARDEN",
    ["worst secret"] = "KARKERKARKURKUR", ["maximum server size"] = "EIGHT", ["max server size"] = "EIGHT",
    ["how many players in a server"] = "EIGHT", ["server player limit"] = "EIGHT", ["max players"] = "EIGHT",
    ["brother of hydra bunny"] = "CERBERUS", ["hydra bunny brother"] = "CERBERUS", ["cerberus"] = "CERBERUS",
    ["hydra bunny sibling"] = "CERBERUS",
    ["what is on the conveyor"] = "BRAINROTS", ["what does the conveyor have"] = "BRAINROTS",
    ["how many bases"] = "8", ["number of bases"] = "8", ["bases in sab"] = "8",
    ["how do you get lava mutation"] = "MOLTEN EVENT", ["how to get lava mutation"] = "MOLTEN EVENT",
    ["lava event name"] = "MOLTEN EVENT", ["molten event"] = "MOLTEN EVENT",
    ["how often does molten event happen"] = "EVERY 2 HOURS", ["how long is molten event"] = "EVERY 2 HOURS",
    ["what are lucky blocks"] = "LUCKY BLOCKS", ["lucky block types"] = "MYTHIC, GOD, SECRET",
    ["types of lucky blocks"] = "MYTHIC, GOD, SECRET",
    ["what does rebirth do"] = "RESETS BRAINROTS FOR MULTIPLIER", ["rebirth effect"] = "RESETS BRAINROTS FOR MULTIPLIER",
    ["why rebirth"] = "PERMANENT MULTIPLIER AND EXTRA SLOTS", ["rebirth reward"] = "PERMANENT MULTIPLIER AND EXTRA SLOTS",
    ["code 1"] = "SAB2024", ["code 2"] = "SAMMYGIFT", ["code 3"] = "BRAINROT", ["code 4"] = "SPYDER",
    ["code 5"] = "RELEASE", ["code 6"] = "MAY25", ["code 7"] = "BLUEBOY", ["code 8"] = "KEYBOARD",
    ["code 9"] = "ESCAPE", ["code 10"] = "RAINBOW",
    ["how to redeem codes"] = "SHOP MENU BOTTOM", ["where to redeem codes"] = "SHOP MENU BOTTOM",
    ["how do you redeem a code"] = "SHOP MENU BOTTOM", ["where is the code box"] = "SHOP MENU BOTTOM",
    ["total codes"] = "247", ["active codes"] = "89", ["expired codes"] = "158", ["rare codes"] = "12",
    ["legendary codes"] = "3", ["mythic codes"] = "1",
    ["what game is sab"] = "STEAL A BRAINROT", ["full name of sab"] = "STEAL A BRAINROT",
    ["sab stands for"] = "STEAL A BRAINROT", ["game name"] = "STEAL A BRAINROT",
    ["who made sab"] = "SPYDERSAMMY", ["who created sab"] = "SPYDERSAMMY", ["sab creator"] = "SPYDERSAMMY",
    ["game creator"] = "SPYDERSAMMY", ["sab owner"] = "SPYDERSAMMY", ["game owner"] = "SPYDERSAMMY",
}

-- ===================== RIDDLE SOLVER =====================
local function answerQuestion(text)
    if not _riddleSolver then return nil end
    if not text or text == "" then return nil end
    local l = text:lower()
    local clean = l:gsub("what%s+is", ""):gsub("what%s+are", ""):gsub("what%s+was", ""):gsub("what%s+were", "")
    clean = clean:gsub("who%s+is", ""):gsub("who%s+was", ""):gsub("when%s+is", ""):gsub("when%s+was", "")
    clean = clean:gsub("where%s+is", ""):gsub("where%s+are", ""):gsub("how%s+old", ""):gsub("how%s+tall", "")
    clean = clean:gsub("how%s+many", ""):gsub("how%s+much", ""):gsub("do%s+you%s+know", ""):gsub("can%s+you%s+tell", "")
    clean = clean:gsub("tell%s+me", ""):gsub("i%s+need", ""):gsub("give%s+me", ""):gsub("what's", ""):gsub("whats", "")
    clean = clean:gsub("my%s+", ""):gsub("am%s+i", ""):gsub("do%s+i", ""):gsub("did%s+i", ""):gsub("have%s+i", "")
    clean = clean:gsub("the%s+", ""):gsub("a%s+", ""):gsub("an%s+", ""):gsub("of%s+", ""):gsub("for%s+", "")
    clean = clean:gsub("[%?%.%,!]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if clean == "" then clean = l:gsub("[%?%.%,!]", "") end

    if l:find("fortnite") or l:find("fn ") or l:find("battle royale") or l:find("epic games") then return "SAB ONLY" end
    if SAB_DB[clean] then return SAB_DB[clean] end
    for key, value in pairs(SAB_DB) do
        if clean:find(key, 1, true) or key:find(clean, 1, true) then return value end
        if #key > 3 and #clean > 2 then
            for word in key:gmatch("%S+") do
                if #word > 2 and (clean:find(word, 1, true) or word:find(clean, 1, true)) then return value end
            end
        end
    end
    -- fallback heuristics
    if l:find("game created") or l:find("created on") or l:find("made on") then
        if l:find("day") or l:find("when") then return "FRIDAY" end
    end
    if l:find("football") or l:find("soccer") then
        if l:find("favorite") or l:find("fav") or l:find("player") then return "RONALDO" end
    end
    if l:find("ronaldo") then return "RONALDO" end
    if l:find("worst game") or l:find("boring game") then
        if l:find("owner") then return "SECRETLOKII" else return "KEYBOARDESCAPE" end
    end
    if l:find("world cup") then return "ARGENTINA" end
    if l:find("mutation") then
        if l:find("7") or l:find("seven") then return "CURSED" end
        if l:find("8") or l:find("eight") then return "DIVINE" end
        if l:find("9") or l:find("nine") then return "CYBER" end
        if l:find("10") or l:find("ten") then return "PHANTOM" end
    end
    if l:find("machine") then
        if l:find("1") or l:find("first") then return "RAINBOW MACHINE" end
        if l:find("2") or l:find("second") then return "BUBBLEGUM MACHINE" end
        if l:find("3") or l:find("third") then return "FUSE MACHINE" end
        if l:find("4") or l:find("fourth") then return "CRAFT MACHINE" end
        if l:find("5") or l:find("fifth") then return "WITCH FUSE" end
        if l:find("6") or l:find("sixth") then return "BRAINROT DEALER" end
        if l:find("7") or l:find("seventh") then return "BRAINROT TRADER" end
        if l:find("8") or l:find("eighth") then return "SANTA'S FUSE" end
        if l:find("9") or l:find("ninth") then return "SANTA'S SHOP" end
        if l:find("10") or l:find("tenth") then return "NEW YEAR'S MACHINE" end
        if l:find("11") or l:find("eleventh") then return "DUELS MACHINE" end
        if l:find("12") or l:find("twelfth") then return "CUPID'S MACHINE" end
        if l:find("13") or l:find("thirteenth") then return "TRADE MACHINE" end
        if l:find("14") or l:find("fourteenth") then return "DIVINE FUSE" end
        if l:find("15") or l:find("fifteenth") then return "EGG INCUBATOR" end
        if l:find("16") or l:find("sixteenth") then return "CYBER CRAFT MACHINE" end
        if l:find("17") or l:find("seventeenth") then return "SUMMER FUSE" end
        if l:find("18") or l:find("eighteenth") then return "LOS TRADERS" end
    end
    if l:find("og") or l:find("cannot be obtained") then
        if l:find("headless") then return "HEADLESS HORSEMAN" end
        if l:find("first") or l:find("1st") then return "STRAWBERRYELEPHANT" end
        if l:find("second") or l:find("2nd") then return "MEOWL" end
        if l:find("third") or l:find("3rd") then return "SKIBIDITOILET" end
        if l:find("fifth") or l:find("5th") then return "JOHNPORK" end
    end
    if l:find("highest rarity") then return "OG" end
    if l:find("fire") and (l:find("represent") or l:find("stand")) then return "DRAGON" end
    if l:find("admin abuse") then
        if l:find("spawn") then return "RACOONINI JANDELINI" end
        if l:find("won") then return "GROWAGARDEN" end
    end
    if l:find("worst secret") or l:find("bad secret") then return "KARKERKARKURKUR" end
    if l:find("server") and (l:find("max") or l:find("size")) then return "EIGHT" end
    if l:find("hydra bunny") and (l:find("brother") or l:find("sibling")) then return "CERBERUS" end
    if l:find("old") or l:find("age") then
        if l:find("sammy") or l:find("am i") then return "24" end
    end
    if l:find("from") or l:find("country") then
        if l:find("sammy") or l:find("am i") then return "BRAZIL" end
    end
    return nil
end

-- ===================== UI HELPERS =====================
local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function makeLabel(parent, name, text, size, position, textSize, color, font)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextSize = textSize
    label.TextColor3 = color
    label.Font = font or Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

-- ===================== UI & STATE =====================
local _enabled = savedConfig.codeSniper
local _seen = {}
local _autoAccept = savedConfig.autoSubmit
local _submitAfter = savedConfig.submitAfter
local _capturedParts = {}
local _retypeInvalid = savedConfig.retypeInvalid
local _riddleSolver = savedConfig.riddleSolver
local _awaitingCode = false
local _lastStatusMsg = nil

-- ===== Blacklist for UI labels (common words that are not codes) =====
local blacklist = {
    "redeem", "submit", "close", "cancel", "ok", "yes", "no",
    "shop", "codes", "code", "enter", "type", "here", "click",
    "copy", "paste", "delete", "back", "next", "done", "exit",
    "save", "load", "reset", "apply", "confirm", "reject",
    "accept", "decline", "buy", "sell", "trade", "inventory",
    "settings", "options", "help", "about", "support", "contact",
    "name", "level", "rank", "score", "points", "coins", "gems",
    "cash", "energy", "health", "mana", "xp", "exp",
}

local function isLikelyCode(text)
    if not text or text == "" then return false end
    local trimmed = text:match("^%s*(.-)%s*$")
    if trimmed == "" then return false end
    -- Must be a single word (no spaces)
    if trimmed:find("%s") then return false end
    -- Must be alphanumeric (allow underscores)
    if not trimmed:match("^[%w_]+$") then return false end
    -- Length between 2 and 12 (as requested)
    local len = #trimmed
    if len < 2 or len > 12 then return false end
    -- Not in blacklist (case-insensitive)
    local lower = trimmed:lower()
    for _, word in ipairs(blacklist) do
        if lower == word then return false end
    end
    return true
end

local COLORS = {
    Window = Color3.fromRGB(6, 6, 7),
    Row = Color3.fromRGB(15, 15, 17),
    Control = Color3.fromRGB(35, 35, 39),
    Log = Color3.fromRGB(10, 10, 12),
    Border = Color3.fromRGB(82, 82, 89),
    White = Color3.fromRGB(245, 245, 245),
    Text = Color3.fromRGB(190, 190, 196),
    Dim = Color3.fromRGB(120, 120, 130),
    Accent = Color3.fromRGB(245, 245, 245),
    Green = Color3.fromRGB(70, 210, 100),
    Red = Color3.fromRGB(255, 70, 70),
}
local CONSOLE_COLORS = {
    Dim = "rgb(124,127,135)",
    Amber = "rgb(214,158,92)",
    Green = "rgb(105,190,132)",
    Red = "rgb(218,105,105)",
    Cyan = "rgb(101,174,183)",
}

-- ===================== UI BUILDING =====================
pcall(function()
    for _, name in ipairs({"ACECodeSniperUI", "AutoTypeCodesUI", "ACEPaste"}) do
        local previous = game.CoreGui:FindFirstChild(name)
        if previous then previous:Destroy() end
    end
end)
for _, name in ipairs({"ACECodeSniperUI", "AutoTypeCodesUI", "ACEPaste"}) do
    local previous = playerGui:FindFirstChild(name)
    if previous then previous:Destroy() end
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "ACECodeSniperUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999
if not pcall(function()
    GUI.Parent = game.CoreGui
end) then
    GUI.Parent = playerGui
end

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.fromOffset(310, 370)
Window.AnchorPoint = Vector2.new(1, 0)
Window.Position = UDim2.new(1, -8, 0, 8)
Window.BackgroundColor3 = COLORS.Window
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = GUI
addCorner(Window, 14)
addStroke(Window, COLORS.White, 1, 0.58)

local InterfaceScale = Instance.new("UIScale")
InterfaceScale.Name = "InterfaceScale"
InterfaceScale.Scale = 0.92
InterfaceScale.Parent = Window

local viewportConnection
local function updateInterfaceScale()
    local camera = workspace.CurrentCamera
    if not camera then
        InterfaceScale.Scale = 0.92
        return
    end
    local viewport = camera.ViewportSize
    local fitScale = math.min((viewport.X - 16) / 310, (viewport.Y - 16) / 370)
    if UserInputService.TouchEnabled then
        InterfaceScale.Scale = math.max(0.45, math.min(0.72, fitScale))
    else
        InterfaceScale.Scale = 0.92
    end
end
local function watchViewport()
    if viewportConnection then viewportConnection:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInterfaceScale)
    end
    updateInterfaceScale()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport)
watchViewport()

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "ACEBackground"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.fromOffset(0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://137692455767789"
BackgroundImage.ImageTransparency = 0
BackgroundImage.ScaleType = Enum.ScaleType.Stretch
BackgroundImage.ZIndex = 1
BackgroundImage.Parent = Window
addCorner(BackgroundImage, 14)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 64)
Header.BackgroundTransparency = 1
Header.Active = true
Header.ZIndex = 3
Header.Parent = Window

local Console
local ConsoleOutput
local updateConsoleCanvas
local featureStates = {}

local function col3ToRich(col)
    if col == COLORS.Green then return CONSOLE_COLORS.Green end
    if col == COLORS.Red then return CONSOLE_COLORS.Red end
    if col == COLORS.Text then return CONSOLE_COLORS.Amber end
    if col == COLORS.White then return CONSOLE_COLORS.Cyan end
    if col == COLORS.Dim then return CONSOLE_COLORS.Dim end
    return string.format("rgb(%d,%d,%d)",
        math.floor(col.R * 255 + 0.5),
        math.floor(col.G * 255 + 0.5),
        math.floor(col.B * 255 + 0.5))
end

local function scrollConsoleToBottom()
    task.defer(function()
        task.wait()
        if not Console then return end
        if updateConsoleCanvas then updateConsoleCanvas() end
        local bottom = math.max(0, Console.AbsoluteCanvasSize.Y - Console.AbsoluteWindowSize.Y)
        Console.CanvasPosition = Vector2.new(0, bottom)
    end)
end

local function appendConsoleStatus(name, activated)
    if not ConsoleOutput then return end
    local state = activated and "ON" or "OFF"
    local stateColor = activated and CONSOLE_COLORS.Green or CONSOLE_COLORS.Red
    local line = '<font color="' .. CONSOLE_COLORS.Dim .. '">[setting]</font> '
        .. '<font color="' .. CONSOLE_COLORS.Amber .. '">' .. name .. "</font> "
        .. '<font color="' .. CONSOLE_COLORS.Dim .. '">-&gt;</font> '
        .. '<font color="' .. stateColor .. '">' .. state .. "</font>"
    if ConsoleOutput.Text == "" then
        ConsoleOutput.Text = line
    else
        ConsoleOutput.Text = ConsoleOutput.Text .. "\n\n" .. line
    end
    scrollConsoleToBottom()
end

local function setStatus(msg, col)
    if not ConsoleOutput then return end
    if not _enabled then return end
    if msg == _lastStatusMsg then return end
    _lastStatusMsg = msg
    col = col or COLORS.Dim
    local line = '<font color="' .. col3ToRich(col) .. '">' .. tostring(msg) .. "</font>"
    if ConsoleOutput.Text == "" then
        ConsoleOutput.Text = line
    else
        ConsoleOutput.Text = ConsoleOutput.Text .. "\n\n" .. line
    end
    scrollConsoleToBottom()
end

local function flashCode(code, col)
    if not code or code == "" then return end
    setStatus("[code] -> " .. tostring(code), col or COLORS.White)
end

local BrandMark = Instance.new("Frame")
BrandMark.Name = "BrandMark"
BrandMark.Size = UDim2.fromOffset(30, 30)
BrandMark.Position = UDim2.fromOffset(17, 15)
BrandMark.BackgroundColor3 = COLORS.Window
BrandMark.BackgroundTransparency = 1
BrandMark.BorderSizePixel = 0
BrandMark.ClipsDescendants = true
BrandMark.Parent = Header
addCorner(BrandMark, 15)

local BrandImage = Instance.new("ImageLabel")
BrandImage.Name = "Logo"
BrandImage.Size = UDim2.fromScale(1, 1)
BrandImage.BackgroundTransparency = 1
BrandImage.Image = "rbxassetid://71891923282375"
BrandImage.ScaleType = Enum.ScaleType.Fit
BrandImage.Parent = BrandMark
addCorner(BrandImage, 15)

makeLabel(Header, "Title", "ACE CODE SNIPER",
    UDim2.fromOffset(180, 25), UDim2.fromOffset(56, 17),
    15, COLORS.White, Enum.Font.GothamBold)

local AutoWriteButton = Instance.new("TextButton")
AutoWriteButton.Name = "AutoWrite"
AutoWriteButton.Size = UDim2.fromOffset(47, 24)
AutoWriteButton.Position = UDim2.new(1, -64, 0, 18)
AutoWriteButton.BackgroundColor3 = _enabled and COLORS.Accent or COLORS.Control
AutoWriteButton.BorderSizePixel = 0
AutoWriteButton.AutoButtonColor = false
AutoWriteButton.Text = ""
AutoWriteButton.Parent = Header
addCorner(AutoWriteButton, 12)
local AutoWriteStroke = addStroke(AutoWriteButton, COLORS.White, 1, _enabled and 0.62 or 0.88)
local AutoWriteKnob = Instance.new("Frame")
AutoWriteKnob.Name = "Knob"
AutoWriteKnob.Size = UDim2.fromOffset(20, 20)
AutoWriteKnob.Position = _enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
AutoWriteKnob.BackgroundColor3 = _enabled and COLORS.Window or COLORS.White
AutoWriteKnob.BorderSizePixel = 0
AutoWriteKnob.Parent = AutoWriteButton
addCorner(AutoWriteKnob, 10)

local function toggleAutoWrite()
    _enabled = not _enabled
    savedConfig.codeSniper = _enabled
    saveConfig()
    _lastStatusMsg = nil
    AutoWriteButton.BackgroundColor3 = _enabled and COLORS.Accent or COLORS.Control
    AutoWriteStroke.Transparency = _enabled and 0.62 or 0.88
    AutoWriteKnob.BackgroundColor3 = _enabled and COLORS.Window or COLORS.White
    AutoWriteKnob.Position = _enabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    if ConsoleOutput then
        if _enabled then
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Amber .. '">&gt;</font> '
                .. '<font color="' .. CONSOLE_COLORS.Dim .. '">scanning for codes...</font>'
            for _, featureName in ipairs({"Auto submit", "Riddle solver", "Retype invalid"}) do
                if featureStates[featureName] then
                    appendConsoleStatus(featureName, true)
                end
            end
        else
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Dim .. '">status:</font> '
                .. '<font color="' .. CONSOLE_COLORS.Red .. '">OFF</font>\n'
                .. '<font color="' .. CONSOLE_COLORS.Dim .. '">code sniper paused</font>'
        end
        scrollConsoleToBottom()
    end
end
AutoWriteButton.MouseButton1Click:Connect(toggleAutoWrite)

local HeaderAccent = Instance.new("Frame")
HeaderAccent.Name = "TitleDivider"
HeaderAccent.Size = UDim2.new(1, -34, 0, 1)
HeaderAccent.Position = UDim2.fromOffset(17, 54)
HeaderAccent.BackgroundColor3 = COLORS.White
HeaderAccent.BackgroundTransparency = 0.72
HeaderAccent.BorderSizePixel = 0
HeaderAccent.Parent = Header

local Settings = Instance.new("Frame")
Settings.Name = "Settings"
Settings.Size = UDim2.new(1, 0, 0, 154)
Settings.Position = UDim2.fromOffset(0, 65)
Settings.BackgroundTransparency = 1
Settings.ZIndex = 3
Settings.Parent = Window

local function makeCard(name, position, size)
    local card = Instance.new("Frame")
    card.Name = name
    card.Position = position
    card.Size = size
    card.BackgroundColor3 = COLORS.Row
    card.BackgroundTransparency = 0.68
    card.BorderSizePixel = 0
    card.Parent = Settings
    addCorner(card, 9)
    addStroke(card, COLORS.White, 1, 0.76)
    return card
end

local function makeStateButton(parent, enabled, consoleName, onToggle)
    parent.Active = true
    featureStates[consoleName] = enabled
    local button = Instance.new("TextButton")
    button.Name = "State"
    button.Size = UDim2.fromOffset(42, 20)
    button.Position = UDim2.new(1, -50, 0.5, -10)
    button.BackgroundColor3 = enabled and COLORS.Accent or COLORS.Control
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = enabled and "ON" or "OFF"
    button.TextSize = 8
    button.TextColor3 = enabled and COLORS.Window or COLORS.Dim
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    addCorner(button, 6)
    local outline = addStroke(button, COLORS.White, 1, enabled and 0.62 or 0.88)
    local state = enabled
    local function toggleState()
        state = not state
        featureStates[consoleName] = state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and COLORS.Accent or COLORS.Control
        button.TextColor3 = state and COLORS.Window or COLORS.Dim
        outline.Transparency = state and 0.62 or 0.88
        if _enabled then appendConsoleStatus(consoleName, state) end
        if onToggle then onToggle(state) end
    end
    button.MouseButton1Click:Connect(toggleState)
    parent.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local pointer = input.Position
        local buttonPosition = button.AbsolutePosition
        local buttonSize = button.AbsoluteSize
        local clickedButton = pointer.X >= buttonPosition.X
            and pointer.X <= buttonPosition.X + buttonSize.X
            and pointer.Y >= buttonPosition.Y
            and pointer.Y <= buttonPosition.Y + buttonSize.Y
        if not clickedButton then toggleState() end
    end)
    return button
end

local AutoCard = makeCard("AutoSubmit", UDim2.fromOffset(17, 0), UDim2.fromOffset(135, 50))
makeLabel(AutoCard, "Title", "Auto submit",
    UDim2.new(1, -58, 1, 0), UDim2.fromOffset(12, 0),
    11, COLORS.White, Enum.Font.GothamMedium)
makeStateButton(AutoCard, _autoAccept, "Auto submit", function(state)
    _autoAccept = state
    savedConfig.autoSubmit = state
    saveConfig()
end)

local AICard = makeCard("AIRiddles", UDim2.fromOffset(158, 0), UDim2.fromOffset(135, 50))
makeLabel(AICard, "Title", "Riddle solver",
    UDim2.new(1, -58, 1, 0), UDim2.fromOffset(12, 0),
    11, COLORS.White, Enum.Font.GothamMedium)
makeStateButton(AICard, _riddleSolver, "Riddle solver", function(state)
    _riddleSolver = state
    savedConfig.riddleSolver = state
    saveConfig()
end)

local DelayCard = makeCard("SubmitAfter", UDim2.fromOffset(17, 57), UDim2.fromOffset(276, 43))
makeLabel(DelayCard, "Title", "Submit after msgs",
    UDim2.fromOffset(145, 43), UDim2.fromOffset(12, 0),
    11, COLORS.White, Enum.Font.GothamMedium)
local CounterShell = Instance.new("Frame")
CounterShell.Name = "Counter"
CounterShell.Size = UDim2.fromOffset(96, 31)
CounterShell.Position = UDim2.new(1, -105, 0.5, -15)
CounterShell.BackgroundColor3 = COLORS.Window
CounterShell.BackgroundTransparency = 0.05
CounterShell.BorderSizePixel = 0
CounterShell.Parent = DelayCard
addCorner(CounterShell, 7)
addStroke(CounterShell, COLORS.White, 1, 0.86)

local Minus = Instance.new("TextButton")
Minus.Name = "Minus"
Minus.Size = UDim2.fromOffset(25, 25)
Minus.Position = UDim2.fromOffset(3, 3)
Minus.BackgroundColor3 = COLORS.Control
Minus.BorderSizePixel = 0
Minus.AutoButtonColor = false
Minus.Text = "-"
Minus.TextSize = 16
Minus.TextColor3 = COLORS.Text
Minus.Font = Enum.Font.GothamBold
Minus.Parent = CounterShell
addCorner(Minus, 5)
local Count = makeLabel(CounterShell, "Count", tostring(_submitAfter),
    UDim2.fromOffset(28, 25), UDim2.fromOffset(34, 3),
    17, COLORS.White, Enum.Font.GothamBold)
Count.TextXAlignment = Enum.TextXAlignment.Center
local Plus = Instance.new("TextButton")
Plus.Name = "Plus"
Plus.Size = UDim2.fromOffset(25, 25)
Plus.Position = UDim2.fromOffset(68, 3)
Plus.BackgroundColor3 = COLORS.Control
Plus.BorderSizePixel = 0
Plus.AutoButtonColor = false
Plus.Text = "+"
Plus.TextSize = 16
Plus.TextColor3 = COLORS.Text
Plus.Font = Enum.Font.GothamBold
Plus.Parent = CounterShell
addCorner(Plus, 5)
Minus.MouseButton1Click:Connect(function()
    _submitAfter = math.max(1, _submitAfter - 1)
    Count.Text = tostring(_submitAfter)
    savedConfig.submitAfter = _submitAfter
    saveConfig()
end)
Plus.MouseButton1Click:Connect(function()
    _submitAfter += 1
    Count.Text = tostring(_submitAfter)
    savedConfig.submitAfter = _submitAfter
    saveConfig()
end)

local RetypeCard = makeCard("RetypeInvalid", UDim2.fromOffset(17, 103), UDim2.fromOffset(276, 38))
makeLabel(RetypeCard, "Title", "Retype invalid",
    UDim2.new(1, -65, 1, 0), UDim2.fromOffset(12, 0),
    11, COLORS.White, Enum.Font.GothamMedium)
makeStateButton(RetypeCard, _retypeInvalid, "Retype invalid", function(state)
    _retypeInvalid = state
    savedConfig.retypeInvalid = state
    saveConfig()
end)

Console = Instance.new("ScrollingFrame")
Console.Name = "Console"
Console.Size = UDim2.new(1, -34, 0, 127)
Console.Position = UDim2.fromOffset(17, 216)
Console.BackgroundColor3 = COLORS.Log
Console.BorderSizePixel = 0
Console.ClipsDescendants = true
Console.Active = true
Console.ScrollingEnabled = true
Console.ScrollingDirection = Enum.ScrollingDirection.Y
Console.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
Console.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
Console.CanvasSize = UDim2.new(0, 0, 0, 0)
Console.AutomaticCanvasSize = Enum.AutomaticSize.None
Console.ScrollBarThickness = 4
Console.ScrollBarImageColor3 = COLORS.Dim
Console.ZIndex = 3
Console.Parent = Window
addCorner(Console, 9)
addStroke(Console, COLORS.White, 1, 0.88)

ConsoleOutput = Instance.new("TextLabel")
ConsoleOutput.Name = "ConsoleOutput"
ConsoleOutput.Size = UDim2.new(1, -18, 0, 115)
ConsoleOutput.AutomaticSize = Enum.AutomaticSize.Y
ConsoleOutput.Position = UDim2.fromOffset(9, 6)
ConsoleOutput.BackgroundTransparency = 1
ConsoleOutput.RichText = true
if _enabled then
    ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Amber .. '">&gt;</font> '
        .. '<font color="' .. CONSOLE_COLORS.Dim .. '">scanning for codes...</font>'
else
    ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Dim .. '">status:</font> '
        .. '<font color="' .. CONSOLE_COLORS.Red .. '">OFF</font>\n'
        .. '<font color="' .. CONSOLE_COLORS.Dim .. '">code sniper paused</font>'
end
ConsoleOutput.TextSize = 14
ConsoleOutput.Font = Enum.Font.Code
ConsoleOutput.TextColor3 = COLORS.Dim
ConsoleOutput.TextXAlignment = Enum.TextXAlignment.Left
ConsoleOutput.TextYAlignment = Enum.TextYAlignment.Top
ConsoleOutput.TextWrapped = true
ConsoleOutput.ZIndex = 4
ConsoleOutput.Parent = Console

local CONSOLE_BOTTOM_PADDING = 30
updateConsoleCanvas = function()
    if not Console or not ConsoleOutput then return end
    local contentHeight = ConsoleOutput.Position.Y.Offset
        + ConsoleOutput.AbsoluteSize.Y
        + CONSOLE_BOTTOM_PADDING
    Console.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end
ConsoleOutput:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateConsoleCanvas)
task.defer(updateConsoleCanvas)

local DiscordFooter = makeLabel(Window, "DiscordFooter", "discord.gg/aceduels",
    UDim2.fromOffset(140, 19), UDim2.new(0.5, -70, 0, 346),
    10, COLORS.White, Enum.Font.GothamBold)
DiscordFooter.TextXAlignment = Enum.TextXAlignment.Center
DiscordFooter.BackgroundColor3 = COLORS.Window
DiscordFooter.BackgroundTransparency = 1
DiscordFooter.TextStrokeColor3 = COLORS.Window
DiscordFooter.TextStrokeTransparency = 0.45
DiscordFooter.ZIndex = 3

-- ===================== DRAGGING =====================
do
    local dragging = false
    local activeDragInput
    local dragStart
    local startPosition
    local dragMoved = false
    local DRAG_THRESHOLD = UserInputService.TouchEnabled and 10 or 3
    local function isOverHeaderControl(position)
        if not UserInputService.TouchEnabled then return false end
        local headerPosition = Header.AbsolutePosition
        local headerSize = Header.AbsoluteSize
        return position.X >= headerPosition.X + headerSize.X - 76
            and position.Y >= headerPosition.Y
            and position.Y <= headerPosition.Y + headerSize.Y
    end
    local function stopDragging(input)
        if input ~= activeDragInput then return end
        dragging = false
        activeDragInput = nil
        dragStart = nil
        startPosition = nil
    end
    Header.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragging or isOverHeaderControl(input.Position) then return end
        dragging = true
        activeDragInput = input
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Window.Position
        dragMoved = false
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End
            or input.UserInputState == Enum.UserInputState.Cancel then
                stopDragging(input)
            end
        end)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not activeDragInput then return end
        local isTrackedTouch = activeDragInput.UserInputType == Enum.UserInputType.Touch
            and input == activeDragInput
        local isTrackedMouse = activeDragInput.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        if not isTrackedTouch and not isTrackedMouse then return end
        local current = Vector2.new(input.Position.X, input.Position.Y)
        local delta = current - dragStart
        if not dragMoved then
            if delta.Magnitude < DRAG_THRESHOLD then return end
            dragMoved = true
        end
        Window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

-- ===================== REDEMPTION ENGINE =====================
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net")
local REDEEM_GUID = "7d14a912-1040-4867-b005-98838eb9acc4"
local RedeemRemote
local function resolveRedeemRemote()
    if RedeemRemote and RedeemRemote.Parent then return RedeemRemote end
    local ok, api = pcall(require, Net)
    if ok and type(api) == "table" then
        local rok, rf = pcall(function() return api:RemoteFunction(REDEEM_GUID) end)
        if rok and typeof(rf) == "Instance" then RedeemRemote = rf end
    end
    return RedeemRemote
end

local function aceRedeem(code)
    local rf = resolveRedeemRemote()
    if rf then
        local ok, result = pcall(function() return rf:InvokeServer(code) end)
        if ok then return true, result end
    end
    -- fallback: GUI method
    local box = aceCodeBox()
    if not box then return false, "no box" end
    box.Text = code
    pcall(function() box:CaptureFocus() end)
    pcall(function() box:ReleaseFocus(true) end)
    return true, "gui"
end

local function aceCodeBox()
    local gui = playerGui:FindFirstChild("Codes")
    if not gui then return nil end
    local root = gui:FindFirstChild("Codes") or gui
    local redeem = root:FindFirstChild("CodeRedeem")
    local box = redeem and redeem:FindFirstChild("TextBox")
    if box and box:IsA("TextBox") then return box end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextBox") then return obj end
    end
end

-- ===================== CORE LOGIC =====================
local function resetCodeCapture()
    _capturedParts = {}
    _awaitingCode = false
    _seen = {}
end

local function appendToBox(codePart)
    if not codePart or codePart == "" then return end
    _capturedParts[#_capturedParts + 1] = codePart:upper()
    local combined = table.concat(_capturedParts)
    flashCode(combined, COLORS.Green)
    setStatus("Pasted " .. #_capturedParts .. "/" .. _submitAfter, COLORS.Green)

    if #_capturedParts >= _submitAfter then
        local finalCode = table.concat(_capturedParts)
        resetCodeCapture()
        if _autoAccept then
            local ok, result = aceRedeem(finalCode)
            if ok then
                setStatus("Redeemed: " .. finalCode, COLORS.Green)
            else
                setStatus("Failed: " .. tostring(result), COLORS.Red)
                if _retypeInvalid then
                    local box = aceCodeBox()
                    if box then
                        box.Text = finalCode
                        pcall(function() box:CaptureFocus() end)
                        pcall(function() box:ReleaseFocus(true) end)
                    end
                end
            end
        end
        _awaitingCode = false
    end
end

local function processText(text)
    if not _enabled then return end
    if not text or text == "" then return end
    local lower = text:lower()

    -- Riddle solver
    if _riddleSolver then
        local answer = answerQuestion(text)
        if answer then
            if _autoAccept then
                local ok, result = aceRedeem(answer)
                if ok then
                    setStatus("Riddle answered: " .. answer, COLORS.Green)
                else
                    setStatus("Riddle failed: " .. tostring(result), COLORS.Red)
                end
            end
            return
        end
    end

    -- Keywords: "code is" or "use code"
    if lower:find("code is", 1, true) or lower:find("use code", 1, true) then
        _awaitingCode = true
        _capturedParts = {}
        _seen = {}
        setStatus("Triggered – capturing next codes...", COLORS.Accent)
        return
    end

    -- If in capture mode and text looks like a code, capture it
    if _awaitingCode and isLikelyCode(text) then
        local codePart = text:upper()
        if not _seen[codePart] then
            _seen[codePart] = true
            appendToBox(codePart)
        end
    end
end

-- ===================== ACE NOTIFICATION REMOTE HOOK =====================
local function resolveAceNotifyRemote()
    local ok, controller = pcall(function()
        return require(ReplicatedStorage.Controllers:FindFirstChild(
            "NotificationController",
            true
        ))
    end)
    if ok and type(controller) == "table" and type(controller.Start) == "function" then
        local getupvalues = debug and debug.getupvalues or getupvalues
        if getupvalues then
            local ok2, values = pcall(getupvalues, controller.Start)
            if ok2 and type(values) == "table" then
                for _, v in pairs(values) do
                    if typeof(v) == "Instance" and v:IsA("RemoteEvent") and v.Parent == ReplicatedStorage:FindFirstChild("Packages") then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

local aceNotifyRemote = resolveAceNotifyRemote()
local useFallback = false

if aceNotifyRemote then
    aceNotifyRemote.OnClientEvent:Connect(function(...)
        if not _enabled then return end
        local args = table.pack(...)
        if args.n == 0 then return end
        local raw = tostring(args[1] or "")
        local text = raw:gsub("<[^>]->", "")
        if text and text ~= "" then
            processText(text)
        end
    end)
    setStatus("ACE Code Sniper: Remote mode active.", COLORS.Green)
else
    useFallback = true
    setStatus("ACE Notification remote not found. Using fallback UI scanner.", COLORS.Amber)
end

-- ===================== FALLBACK UI SCANNER (smarter) =====================
local fallbackConnections = {}
local function startFallbackScanner()
    -- Find the chat container. Common paths: PlayerGui.Chat, PlayerGui.ChatService, PlayerGui.ChatFrame
    local chatContainer = nil
    local possibleNames = {"Chat", "ChatService", "ChatFrame", "ChatMessages", "MessageContainer"}
    for _, name in ipairs(possibleNames) do
        local found = playerGui:FindFirstChild(name)
        if found then
            chatContainer = found
            break
        end
    end
    if not chatContainer then
        -- If not found, fallback to scanning all TextLabels but with stricter filter
        chatContainer = playerGui
        setStatus("Fallback: Chat container not found, scanning all UI with strict filter.", COLORS.Amber)
    end

    local function onTextChange(obj)
        if not _enabled then return end
        local text = obj.Text
        if text and text ~= "" then
            -- Only process if it's a likely code (single word, alphanumeric, len 2-12, not blacklisted)
            if isLikelyCode(text) then
                processText(text)
            end
        end
    end

    -- Monitor existing TextLabels in the container
    for _, obj in ipairs(chatContainer:GetDescendants()) do
        if obj:IsA("TextLabel") then
            -- Attach a listener
            local conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
                onTextChange(obj)
            end)
            table.insert(fallbackConnections, conn)
            -- Process initial text if any
            onTextChange(obj)
        end
    end

    -- Also listen for new descendants added to the container
    local addedConn = chatContainer.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") then
            local conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
                onTextChange(obj)
            end)
            table.insert(fallbackConnections, conn)
            onTextChange(obj)
        end
    end)
    table.insert(fallbackConnections, addedConn)
end

if useFallback then
    startFallbackScanner()
end

-- ===================== INIT =====================
setStatus("ACE Code Sniper loaded. Waiting for triggers...", COLORS.Dim)

-- StopAura cleanup
getgenv().StopAura = function()
    if GUI then GUI:Destroy() end
    for _, conn in ipairs(fallbackConnections) do
        pcall(function() conn:Disconnect() end)
    end
    getgenv().StopAura = nil
end

print("[ACE] Code Sniper loaded with remote + fallback scanner (smart filter).")
