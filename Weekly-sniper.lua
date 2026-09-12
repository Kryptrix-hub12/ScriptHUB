-- ============================================================
-- ULTIMATE KEYWORD-TRIGGERED CODE SNIPER v3.0
-- With Massive Database, AI Fallback & Performance Optimizations
-- ============================================================

local cloneref = cloneref or function(object) return object end
local Players           = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService        = cloneref(game:GetService("RunService"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local HttpService       = cloneref(game:GetService("HttpService"))
local Lighting          = cloneref(game:GetService("Lighting"))
local Workspace         = cloneref(game:GetService("Workspace"))
local TweenService      = cloneref(game:GetService("TweenService"))
local Stats             = cloneref(game:GetService("Stats"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if getgenv and getgenv().StopAura then pcall(getgenv().StopAura) end

-- ============================================================
-- CONFIGURATION SYSTEM
-- ============================================================
local CONFIG_FILE = "ace_code_sniper_auto_redeem_test_config.json"
local savedConfig = {
    codeSniper = true,
    autoSubmit = true,
    submitAfter = 1,
    retypeInvalid = true,
    riddleSolver = true,
    spamRedeem = true,
    autoRedeemRiddles = true,
    ultraFast = true,
    performanceMode = true,
    triggers = {"code is", "use code", "riddle is"},
}
pcall(function()
    if type(isfile) == "function" and type(readfile) == "function" and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if savedConfig[k] ~= nil then
                    if type(v) == type(savedConfig[k]) then savedConfig[k] = v end
                end
            end
        end
    end
end)

local function saveConfig()
    if type(writefile) ~= "function" then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(savedConfig))
    end)
end

-- ============================================================
-- STATE VARIABLES
-- ============================================================
local _enabled              = savedConfig.codeSniper
local _seen                 = {}
local _focused              = nil
local _lastBox              = nil
local _autoAccept           = savedConfig.autoSubmit
local _submitAfter          = savedConfig.submitAfter
local _capturedParts        = {}
local _lastWatchedBox       = nil
local _boxTextConn          = nil
local _boxAncestryConn      = nil
local _boxVisibilityConns   = {}
local _retypeInvalid        = savedConfig.retypeInvalid
local _riddleSolver         = savedConfig.riddleSolver
local _spamRedeem           = savedConfig.spamRedeem
local _autoRedeemRiddles    = savedConfig.autoRedeemRiddles
local _lastNonBlankBoxText  = ""
local _pendingRejectedText  = nil
local _pendingRejectedBox   = nil
local _pendingRejectedUntil = 0
local _pendingRejectedToken = 0
local _triggers             = savedConfig.triggers or {"code is", "use code", "riddle is"}
local _isActive             = false
local _triggerUsed          = ""
local _ultraFast            = savedConfig.ultraFast
local _waitTime             = _ultraFast and 0.001 or 0.05

local getupvalues = (debug and debug.getupvalues) or getupvalues
local getconns    = getconnections or (debug and debug.getconnections)
local setupv      = (debug and debug.setupvalue) or setupvalue

-- ============================================================
-- PERFORMANCE / NETWORK OPTIMIZATIONS
-- ============================================================

-- Cache frequently used services for speed
local _settings = settings()
local _rendering = _settings.Rendering
local _lighting = Lighting
local _workspace = Workspace

local function applyPerformanceSettings()
    if not savedConfig.performanceMode then return end
    
    -- Graphics Quality
    pcall(function()
        _rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    -- Disable shadows globally
    _lighting.GlobalShadows = false
    _lighting.Technology = Enum.Technology.Legacy
    _lighting.Brightness = 1
    _lighting.EnvironmentDiffuseScale = 0
    _lighting.EnvironmentSpecularScale = 0
    
    -- Disable post-processing effects
    for _, effect in pairs(_lighting:GetChildren()) do
        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or 
           effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or 
           effect:IsA("DepthOfFieldEffect") then
            effect.Enabled = false
        end
    end
    
    -- Disable particles and effects in workspace
    for _, v in ipairs(_workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or 
           v:IsA("Fire") or v:IsA("Smoke") then
            v.Enabled = false
        end
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end
    
    -- Streaming optimization
    _workspace.StreamingEnabled = true
    _workspace.StreamingRadius = 50
    _workspace.StreamingTargetRadius = 80
    
    -- Mobile-specific optimizations
    if UserInputService.TouchEnabled then
        pcall(function()
            _rendering.ResolutionScale = 0.7
        end)
    end
    
    -- Reduce physics load if possible
    pcall(function()
        _workspace.Gravity = _workspace.Gravity -- keep same
        _workspace.FallenPartsDestroyHeight = -500
    end)
    
    setStatus("⚡ Performance mode ON", COLORS.Green)
end

local function revertPerformanceSettings()
    pcall(function()
        _rendering.QualityLevel = Enum.QualityLevel.Level06
        _lighting.GlobalShadows = true
        _lighting.Technology = Enum.Technology.Future
        _workspace.StreamingEnabled = false
        _rendering.ResolutionScale = 1
    end)
    setStatus("Performance mode OFF (revert may require restart)", COLORS.Red)
end

-- ============================================================
-- MASSIVE OPTIMIZED DATABASE
-- ============================================================

-- Brainrot database organized by category for efficiency
local BRAINROT_DB = {
    -- Brainrot Gods (82 documented)
    Gods = {
        "Dumborino Miracello", "Eggdin Egg Egg Dun", "Clovkur Kurkur", "Karkerheart Luvkur",
        "Pop Pop Sahur", "Dolphini Jetskini", "Pandanini Frostini", "Ginger Cisterna",
        "Tentacolo Tecnico", "Cocoa Assassino", "Belula Beluga", "Skull Skull Skull",
        "Krupuk Pagi Pagi", "Patteo", "Bunny Tralala", "Cappuccino Clownino",
        "Brasilini Berimbini", "Luv Luv Luv", "Astrolero Cervalero", "Noo La Polizia",
        "Anpali Babel", "Chrismasmamat", "Mastodontico Telepiedone", "Bambu Bambu Sahur",
        "Los Gattitos", "Boba Panda", "Piccionetta Machina", "Squalanana",
        "Frio Ninja", "Los Tipi Tacos", "Tootini Shrimpini", "Granchiello Spiritell",
        "Yeti Claus", "Ginger Globo", "Snailenzo", "Mummy Ambalabu",
        "Corn Corn Corn Sahur", "Tartaruga Cisterna", "Aquanaut", "Orcalita Orcala",
        "Cacasito Satalito", "Los Orcalitos", "Crabbo Limonetta", "Tractoro Dinosauro",
        "Bombardini Tortinii", "Piccione Macchina", "Pakrahmatmatina", "Brr es Teh Patipum",
        "Los Bombinitos", "Pakrahmatmamat", "Ballerina Peppermintina", "Los Tungtungtungcitos",
        "Bulbito Bandito Traktorito", "Ballerino Lololo", "Las Capuchinas", "Trippi Troppi Troppa Trippa",
        "Gattito Tacoto", "Los Chihuaninis", "Divino Platypio", "Capi Taco",
        "Trenostruzzo Turbo 3000", "Urubini Flamenguini", "Jacko Jack Jack", "Extinct Ballerina",
        "Vampira Cappucina", "Orcalero Orcala", "Tukanno Bananno", "Tralalita Tralala",
        "Alessio", "Tipi Topi Taco", "Matteo", "Tralalero Tralala",
        "Cocofanto Elefanto", "Girafa Celestre", "Tartaruga Cisterna",
    },
    -- Secret Brainrots
    Secrets = {
        "Festive 67", "Strawberry Elephant", "Dragon Cannelloni", "Garama",
        "Madundung", "Spaghetti Tualetti", "Meowl", "Extinct Tralalero",
        "Extinct Matteo",
    },
    -- Mythic Brainrots
    Mythic = {
        "Tracoducotulu Delapeladustuz", "Carloo", "Carrotini Brainini",
    },
    -- Epic/Legendary Brainrots
    Epic = {
        "Gelatina Volatina", "Skibidi", "Rocketini Frostini", "Frullato Framingo",
        "Kraken", "Octo Lucky Block", "Christmas Llama Rot", "Cerberus",
        "Strawberry Elephant", "Dragon Cannelloni", "Garama", "Madundung",
    },
    -- Rare/Common Brainrots
    Rare = {
        "Spaghetti Tualetti", "Meowl", "Extinct Tralalero", "Extinct Matteo",
    }
}

-- Build efficient lookup tables
local BRAINROT_LOOKUP = {}
local BRAINROT_PATTERNS = {}

-- Add all brainrots to lookup with multiple variations
for category, names in pairs(BRAINROT_DB) do
    for _, name in ipairs(names) do
        local lower = name:lower()
        -- Exact match
        BRAINROT_LOOKUP[lower] = name
        -- Remove spaces
        local noSpace = lower:gsub("%s+", "")
        BRAINROT_LOOKUP[noSpace] = name
        -- Remove common suffixes
        local clean = lower:gsub("%s+", ""):gsub("s$", ""):gsub("e$", "")
        if clean ~= noSpace then
            BRAINROT_LOOKUP[clean] = name
        end
        -- Store pattern for partial matching
        if #lower > 5 then
            local firstWord = lower:match("^(%S+)")
            if firstWord then
                BRAINROT_PATTERNS[firstWord] = name
            end
        end
    end
end

-- ============================================================
-- RIDDLE DATABASE (Optimized)
-- ============================================================

-- Organized by category for faster lookups
local RIDDLE_DB = {
    Colors = {
        {pattern = "color of sky|sky color", answer = "blue"},
        {pattern = "color of grass|grass color", answer = "green"},
        {pattern = "color of sun|sun color", answer = "yellow"},
        {pattern = "color of blood|blood color", answer = "red"},
        {pattern = "color of snow|snow color", answer = "white"},
        {pattern = "color of night|night color", answer = "black"},
        {pattern = "color of ocean|ocean color", answer = "blue"},
        {pattern = "color of fire|fire color", answer = "orange"},
        {pattern = "color of banana|banana color", answer = "yellow"},
        {pattern = "color of orange|orange color", answer = "orange"},
        {pattern = "color of lemon|lemon color", answer = "yellow"},
        {pattern = "color of lime|lime color", answer = "green"},
        {pattern = "color of eggplant|eggplant color", answer = "purple"},
        {pattern = "color of coal|coal color", answer = "black"},
        {pattern = "color of milk|milk color", answer = "white"},
        {pattern = "color of chocolate|chocolate color", answer = "brown"},
        {pattern = "color of pumpkin|pumpkin color", answer = "orange"},
        {pattern = "color of ruby|ruby color", answer = "red"},
        {pattern = "color of emerald|emerald color", answer = "green"},
        {pattern = "color of sapphire|sapphire color", answer = "blue"},
        {pattern = "color of gold|gold color", answer = "yellow"},
        {pattern = "color of silver|silver color", answer = "gray"},
    },
    Numbers = {
        {pattern = "how many legs does a dog", answer = "4"},
        {pattern = "how many legs does a cat", answer = "4"},
        {pattern = "how many legs does a spider", answer = "8"},
        {pattern = "how many legs does an insect", answer = "6"},
        {pattern = "how many legs does a human", answer = "2"},
        {pattern = "how many legs does a bird", answer = "2"},
        {pattern = "how many eyes does a human", answer = "2"},
        {pattern = "how many eyes does a spider", answer = "8"},
        {pattern = "how many days in a week", answer = "7"},
        {pattern = "how many days in a year", answer = "365"},
        {pattern = "how many hours in a day", answer = "24"},
        {pattern = "how many minutes in an hour", answer = "60"},
        {pattern = "how many seconds in a minute", answer = "60"},
        {pattern = "how many months in a year", answer = "12"},
        {pattern = "how many planets in solar system", answer = "8"},
        {pattern = "how many continents", answer = "7"},
        {pattern = "how many sides does a triangle", answer = "3"},
        {pattern = "how many sides does a square", answer = "4"},
        {pattern = "how many sides does a pentagon", answer = "5"},
        {pattern = "how many sides does a hexagon", answer = "6"},
        {pattern = "how many sides does an octagon", answer = "8"},
        {pattern = "how many letters in alphabet", answer = "26"},
        {pattern = "how many vowels", answer = "5"},
        {pattern = "how many zeros in a million", answer = "6"},
        {pattern = "how many zeros in a billion", answer = "9"},
    },
    Animals = {
        {pattern = "largest animal|biggest animal", answer = "blue whale"},
        {pattern = "fastest animal", answer = "cheetah"},
        {pattern = "tallest animal", answer = "giraffe"},
        {pattern = "king of jungle", answer = "lion"},
        {pattern = "man's best friend", answer = "dog"},
        {pattern = "king of beasts", answer = "lion"},
        {pattern = "animal gives milk", answer = "cow"},
        {pattern = "animal lays eggs", answer = "chicken"},
    },
    Planets = {
        {pattern = "closest planet to sun", answer = "mercury"},
        {pattern = "largest planet", answer = "jupiter"},
        {pattern = "planet with rings", answer = "saturn"},
        {pattern = "red planet", answer = "mars"},
        {pattern = "blue planet|third planet", answer = "earth"},
    },
    DaysMonths = {
        {pattern = "first day of week", answer = "sunday"},
        {pattern = "middle of week", answer = "wednesday"},
        {pattern = "last day of week", answer = "saturday"},
        {pattern = "first month of year", answer = "january"},
        {pattern = "last month of year", answer = "december"},
        {pattern = "month with 28 days", answer = "february"},
        {pattern = "month with 31 days", answer = "january"},
    },
    Memes = {
        {pattern = "brainrot meaning|what is brainrot", answer = "skibidi"},
        {pattern = "what does sigma", answer = "sigma"},
        {pattern = "what is gyatt", answer = "gyatt"},
        {pattern = "what is ohio|why is ohio", answer = "ohio"},
        {pattern = "what is rizz|rizz meaning", answer = "rizz"},
        {pattern = "what is fanum tax", answer = "fanum"},
        {pattern = "what is mewing", answer = "mewing"},
        {pattern = "what is skibidi", answer = "skibidi"},
        {pattern = "what does sus", answer = "sus"},
        {pattern = "what is pog", answer = "pog"},
        {pattern = "what is bet", answer = "bet"},
        {pattern = "what is cap", answer = "cap"},
        {pattern = "what is no cap", answer = "no cap"},
        {pattern = "what is goated", answer = "goat"},
    },
    Capitals = {
        {pattern = "capital of france", answer = "paris"},
        {pattern = "capital of germany", answer = "berlin"},
        {pattern = "capital of italy", answer = "rome"},
        {pattern = "capital of spain", answer = "madrid"},
        {pattern = "capital of uk", answer = "london"},
        {pattern = "capital of usa", answer = "washington"},
        {pattern = "capital of japan", answer = "tokyo"},
        {pattern = "capital of china", answer = "beijing"},
        {pattern = "capital of brazil", answer = "brasilia"},
        {pattern = "capital of australia", answer = "canberra"},
        {pattern = "capital of india", answer = "new delhi"},
        {pattern = "capital of russia", answer = "moscow"},
        {pattern = "capital of egypt", answer = "cairo"},
        {pattern = "capital of canada", answer = "ottawa"},
        {pattern = "capital of mexico", answer = "mexico city"},
    },
    Trivia = {
        {pattern = "tallest building", answer = "burj khalifa"},
        {pattern = "longest river", answer = "nile"},
        {pattern = "highest mountain", answer = "everest"},
        {pattern = "largest ocean", answer = "pacific"},
        {pattern = "smallest country", answer = "vatican"},
    },
}

-- Build efficient riddle lookup
local RIDDLE_LOOKUP = {}
for category, riddles in pairs(RIDDLE_DB) do
    for _, entry in ipairs(riddles) do
        local patterns = entry.pattern:split("|")
        for _, pattern in ipairs(patterns) do
            RIDDLE_LOOKUP[pattern] = entry.answer
        end
    end
end

-- ============================================================
-- FAST RIDDLE SOLVER
-- ============================================================

local function normalizeCode(s)
    return (tostring(s or "")):match("^%s*(.-)%s*$") or ""
end

-- AI Fallback
local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request
local RIDDLE_URL = "https://sab-riddle-solver.xyrcheatz.workers.dev"
local RIDDLE_TOKEN = "0facce8d7ac3a4b6fc4b6ae068b3b219883009780cb2ca31"
local RIDDLE_MODEL = "qwen"

local _currentRiddleAnswer = ""
local _answerLabel = nil
local _G = getgenv() or _G
if not _G._RiddleCache then _G._RiddleCache = {} end

local function fastRiddleLookup(message)
    local lower = message:lower()
    
    -- Check AI cache first (fastest)
    if _G._RiddleCache[lower] then
        return _G._RiddleCache[lower]
    end
    
    -- Check exact pattern matches
    for pattern, answer in pairs(RIDDLE_LOOKUP) do
        if lower:find(pattern) then
            return answer
        end
    end
    
    -- Check brainrot names
    for pattern, name in pairs(BRAINROT_LOOKUP) do
        if lower:find(pattern) then
            return name
        end
    end
    
    -- Check brainrot first words
    for word, name in pairs(BRAINROT_PATTERNS) do
        if lower:find(word) then
            return name
        end
    end
    
    -- Extract any number
    local num = lower:match("%d+")
    if num then return num end
    
    -- Extract last word after common phrases
    local after = lower:match("is%s+(%w+)$") or 
                  lower:match("are%s+(%w+)$") or 
                  lower:match("answer%s+(%w+)$") or 
                  lower:match("means%s+(%w+)$") or 
                  lower:match("called%s+(%w+)$")
    if after then return after end
    
    return nil
end

local function aiPost(path, body)
    if not httpRequest then return nil end
    local ok, res = pcall(httpRequest, {
        Url = RIDDLE_URL .. path,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. RIDDLE_TOKEN,
        },
        Body = HttpService:JSONEncode(body),
    })
    if not ok or type(res) ~= "table" then return nil end
    local raw = res.Body or res.body
    if type(raw) ~= "string" then return nil end
    local okd, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if okd and type(data) == "table" then return data end
    return nil
end

local function solveRiddle(message, seq)
    if not _riddleSolver then return end
    if setStatus then setStatus("Solving riddle...", COLORS and COLORS.Text or Color3.fromRGB(200,200,200)) end
    
    task.spawn(function()
        -- Try local DB first (instant)
        local answer = fastRiddleLookup(message)
        local fromAI = false
        
        -- If not found, use AI (fallback only)
        if not answer or answer == "" then
            if setStatus then setStatus("Local DB miss, trying AI...", COLORS and COLORS.Text or Color3.fromRGB(200,200,200)) end
            local data = aiPost("/solve", { message = message, model = RIDDLE_MODEL, history = {} })
            if data and data.riddle == true and type(data.answers) == "table" and data.answers[1] then
                answer = normalizeCode(data.answers[1])
                fromAI = true
                if answer and answer ~= "" then
                    _G._RiddleCache[message:lower()] = answer
                    if setStatus then setStatus("AI learned: " .. answer, COLORS and COLORS.Green or Color3.fromRGB(0,255,0)) end
                end
            end
        end
        
        if answer and #answer > 0 then
            _currentRiddleAnswer = answer
            if _answerLabel then
                _answerLabel.Text = "Answer: " .. answer
            end
            if setStatus then 
                local source = fromAI and "AI (cached)" or "Local DB"
                setStatus(source .. ": " .. answer, COLORS and COLORS.Green or Color3.fromRGB(0,255,0))
            end
            if flashCode then flashCode(answer) end
            if _autoRedeemRiddles then
                typeAndSubmitCode(answer)
            end
        else
            if setStatus then setStatus("No answer found for: " .. message, COLORS and COLORS.Red or Color3.fromRGB(255,0,0)) end
        end
    end)
end

-- ============================================================
-- UTILITY & REDEEM LOGIC (Ultra-Fast)
-- ============================================================

local function isOurGui(instance)
    local p = instance
    for _ = 1, 10 do
        if not p then break end
        if p.Name == "ACECodeSniperUI" or p.Name == "SourcesHubRedeemerGui" or p.Name == "ACESettingsUI" then return true end
        p = p.Parent
    end
    return false
end

local function isVisibleChain(inst)
    local current = inst
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("ScreenGui") then return current.Enabled end
        current = current.Parent
    end
    return true
end

local function findAllTextBoxes(pg)
    local boxes = {}
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextBox") and not isOurGui(d) then
                    boxes[#boxes+1] = d
                end
            end
        end
    end
    return boxes
end

local function findCodeButtons(pg)
    local btns = {}
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled and not isOurGui(gui) then
            for _, d in ipairs(gui:GetDescendants()) do
                if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                    local n = d.Name:lower()
                    local pn = (d.Parent and d.Parent.Name or ""):lower()
                    if (n:find("code") or n:find("redeem") or pn:find("code") or pn:find("redeem")) and isVisibleChain(d) then
                        btns[#btns+1] = d
                    end
                end
            end
        end
    end
    return btns
end

-- Ultra-fast clickButton
local function clickButton(btn)
    if not btn then return false end
    if typeof(firesignal) == "function" then
        if pcall(firesignal, btn.MouseButton1Click) or pcall(firesignal, btn.Activated) then return true end
    end
    if pcall(function() btn.MouseButton1Click:Fire() end) then return true end
    if pcall(function() btn.Activated:Fire() end) then return true end
    if typeof(getconns) == "function" then
        local ok, cs = pcall(getconns, btn.MouseButton1Click)
        if ok and type(cs) == "table" then
            for _, c in ipairs(cs) do
                if pcall(function() c:Fire() end) then return true end
            end
        end
        local ok2, cs2 = pcall(getconns, btn.Activated)
        if ok2 and type(cs2) == "table" then
            for _, c in ipairs(cs2) do
                if pcall(function() c:Fire() end) then return true end
            end
        end
    end
    if typeof(fireclick) == "function" then
        return pcall(fireclick, btn)
    end
    return false
end

-- Ultra-fast fireBoxFocusLost
local function fireBoxFocusLost(box)
    if not box then return false end
    if typeof(firesignal) == "function" then
        if pcall(firesignal, box.FocusLost, true) then return true end
    end
    if typeof(getconns) == "function" then
        local ok, cs = pcall(getconns, box.FocusLost)
        if ok and type(cs) == "table" then
            for _, c in ipairs(cs) do
                pcall(function() if c.Enabled ~= false then c:Fire(true) end end)
            end
            return true
        end
    end
    return false
end

-- Ultra-fast typeAndSubmitCode
local function typeAndSubmitCode(code)
    local pg = playerGui or player:FindFirstChildOfClass("PlayerGui")
    if not pg then return false, "no PlayerGui" end
    
    -- Strategy 1: Known UI path
    local codesGui = pg:FindFirstChild("Codes")
    if codesGui then
        if codesGui:IsA("ScreenGui") then codesGui.Enabled = true end
        local codesFrame = codesGui:FindFirstChild("Codes") or codesGui
        if codesFrame then
            if codesFrame:IsA("GuiObject") then codesFrame.Visible = true end
            local cur = codesFrame
            while cur and cur ~= codesGui do
                if cur:IsA("GuiObject") then cur.Visible = true end
                cur = cur.Parent
            end
            
            local box = nil
            for _, d in ipairs(codesFrame:GetDescendants()) do
                if d:IsA("TextBox") and not isOurGui(d) then
                    box = d
                    break
                end
            end
            
            local submitBtn = nil
            for _, d in ipairs(codesFrame:GetDescendants()) do
                if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                    local n = d.Name:lower()
                    local txt = ""
                    pcall(function() txt = d.Text:lower() end)
                    if n:find("submit") or txt:find("submit") or n:find("redeem") or txt:find("redeem") or n:find("claim") or txt:find("confirm") or n:find("enter") then
                        submitBtn = d
                        break
                    end
                end
            end
            if not submitBtn then
                for _, d in ipairs(codesFrame:GetDescendants()) do
                    if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) then
                        local n = d.Name:lower()
                        if not n:find("close") and not n:find("x") and not n:find("toggle") then
                            submitBtn = d
                            break
                        end
                    end
                end
            end
            
            if box then
                pcall(function() box.Text = code end)
                if _ultraFast then task.wait(0.001) else task.wait(0.05) end
                if submitBtn then
                    if _spamRedeem then
                        local clicks = _ultraFast and 5 or 10
                        for i = 1, clicks do
                            clickButton(submitBtn)
                            task.wait(0.001)
                        end
                    else
                        clickButton(submitBtn)
                    end
                end
                fireBoxFocusLost(box)
                return true, "submitted via PlayerGui.Codes"
            end
        end
    end
    
    -- Strategy 2: Dynamic Search (ultra-fast)
    local btns = findCodeButtons(pg)
    for _, btn in ipairs(btns) do
        clickButton(btn)
        task.wait(0.001)
    end
    
    local box = nil
    local deadline = tick() + (_ultraFast and 0.3 or 2)
    while tick() < deadline do
        local allBoxes = findAllTextBoxes(pg)
        for _, d in ipairs(allBoxes) do
            if isVisibleChain(d) then
                local n = d.Name:lower()
                local pn = (d.Parent and d.Parent.Name or ""):lower()
                if n:find("code") or pn:find("code") or n:find("redeem") or pn:find("redeem") or n:find("input") or pn:find("textbox") or n:find("enter") then
                    box = d
                    break
                end
            end
        end
        if not box then
            for _, d in ipairs(allBoxes) do
                if isVisibleChain(d) then box = d; break end
            end
        end
        if box then break end
        task.wait(0.001)
    end
    
    if not box then return false, "no codebox visible" end
    
    pcall(function() box.Text = code end)
    task.wait(0.001)
    
    local redeemBtn = nil
    local searchNames = {"submit","redeem","claim","confirm","enter","send","apply","ok","use","go","check"}
    local p = box.Parent
    for _ = 1, 8 do
        if not p then break end
        for _, d in ipairs(p:GetDescendants()) do
            if (d:IsA("TextButton") or d:IsA("ImageButton")) and not isOurGui(d) and d ~= box then
                local n = d.Name:lower()
                local txt = ""
                pcall(function() txt = d.Text:lower() end)
                for _, sn in ipairs(searchNames) do
                    if n:find(sn) or txt:find(sn) then
                        if isVisibleChain(d) then
                            redeemBtn = d
                            break
                        end
                    end
                end
                if redeemBtn then break end
            end
        end
        if redeemBtn then break end
        p = p.Parent
    end
    
    if redeemBtn then
        if _spamRedeem then
            local clicks = _ultraFast and 5 or 10
            for i = 1, clicks do
                clickButton(redeemBtn)
                task.wait(0.001)
            end
        else
            clickButton(redeemBtn)
        end
    end
    fireBoxFocusLost(box)
    
    return true, "submitted via dynamic search"
end

local function aceCodeBox()
    local pg = playerGui
    local allBoxes = findAllTextBoxes(pg)
    for _, box in ipairs(allBoxes) do
        if isVisibleChain(box) then return box end
    end
    return nil
end

-- ============================================================
-- STYLING & HELPER UTILITIES
-- ============================================================
local COLORS = {
    Window = Color3.fromRGB(0, 0, 0),
    Row = Color3.fromRGB(10, 10, 12),
    Control = Color3.fromRGB(25, 25, 30),
    Log = Color3.fromRGB(5, 5, 8),
    Border = Color3.fromRGB(128, 0, 255),
    White = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(200, 200, 210),
    Dim = Color3.fromRGB(120, 120, 140),
    Accent = Color3.fromRGB(128, 0, 255),
    Green = Color3.fromRGB(70, 210, 100),
    Red = Color3.fromRGB(255, 70, 70),
    Gold = Color3.fromRGB(255, 215, 0),
}

local function addCorner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius)
    value.Parent = parent
    return value
end

local function addStroke(parent, color, thickness, transparency)
    local value = Instance.new("UIStroke")
    value.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    value.Color = color
    value.Thickness = thickness or 1
    value.Transparency = transparency or 0
    value.Parent = parent
    return value
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

-- CLEANUP OLD GUIS
pcall(function()
    for _, name in ipairs({"ACECodeSniperUI", "ACESettingsUI", "AutoTypeCodesUI", "ACEPaste"}) do
        local previous = game.CoreGui:FindFirstChild(name)
        if previous then previous:Destroy() end
    end
end)
for _, name in ipairs({"ACECodeSniperUI", "ACESettingsUI", "AutoTypeCodesUI", "ACEPaste"}) do
    local previous = playerGui:FindFirstChild(name)
    if previous then previous:Destroy() end
end

-- HEAD DISPLAY
local HeadBillboard = nil
local function createHeadDisplay()
    if HeadBillboard then
        pcall(function() HeadBillboard:Destroy() end)
        HeadBillboard = nil
    end
    
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local bill = Instance.new("BillboardGui")
    bill.Name = "ACECodeSniperHeadDisplay"
    bill.Adornee = head
    bill.Size = UDim2.new(0, 200, 0, 40)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.MaxDistance = 100
    bill.AlwaysOnTop = true
    bill.Parent = head
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    bg.Parent = bill
    addCorner(bg, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚡ CODE SNIPER ACTIVE"
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = bg
    
    HeadBillboard = bill
end

local function updateHeadDisplay()
    if HeadBillboard then
        pcall(function() HeadBillboard:Destroy() end)
        HeadBillboard = nil
    end
    createHeadDisplay()
end

player.CharacterAdded:Connect(updateHeadDisplay)
updateHeadDisplay()

-- ============================================================
-- MAIN GUI CREATION
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "ACECodeSniperUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999
if not pcall(function() GUI.Parent = game.CoreGui end) then GUI.Parent = playerGui end

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.fromOffset(300, 320)
Window.AnchorPoint = Vector2.new(1, 0)
Window.Position = UDim2.new(1, -8, 0, 8)
Window.BackgroundColor3 = COLORS.Window
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = GUI
addCorner(Window, 14)
addStroke(Window, COLORS.Border, 1, 0.3)

local InterfaceScale = Instance.new("UIScale")
InterfaceScale.Name = "InterfaceScale"
InterfaceScale.Scale = 0.92
InterfaceScale.Parent = Window

local viewportConnection
local function updateInterfaceScale()
    local camera = workspace.CurrentCamera
    if not camera then InterfaceScale.Scale = 0.92; return end
    local viewport = camera.ViewportSize
    local fitScale = math.min((viewport.X - 16) / 300, (viewport.Y - 16) / 320)
    if UserInputService.TouchEnabled then
        local mobileTarget = 0.72
        InterfaceScale.Scale = math.max(0.45, math.min(mobileTarget, fitScale))
    else
        InterfaceScale.Scale = 0.92
    end
end

local function watchViewport()
    if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
    local camera = workspace.CurrentCamera
    if camera then viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInterfaceScale) end
    updateInterfaceScale()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchViewport)
watchViewport()

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "ACEBackground"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.fromOffset(0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://94538552851680"
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

local Console, ConsoleOutput, updateConsoleCanvas
local featureStates = {}
local CONSOLE_COLORS = {
    Dim = "rgb(124,127,135)",
    Amber = "rgb(214,158,92)",
    Green = "rgb(105,190,132)",
    Red = "rgb(218,105,105)",
    Cyan = "rgb(101,174,183)",
    Gold = "rgb(255,215,0)",
}

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
    if ConsoleOutput.Text == "" then ConsoleOutput.Text = line
    else ConsoleOutput.Text = ConsoleOutput.Text .. "\n\n" .. line end
    scrollConsoleToBottom()
end

-- Brand Mark
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
local avatarId = player.UserId
BrandImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. avatarId .. "&w=150&h=150"
BrandImage.ScaleType = Enum.ScaleType.Fit
BrandImage.Parent = BrandMark
addCorner(BrandImage, 15)

makeLabel(Header, "Title", "⚡ CODE SNIPER", UDim2.fromOffset(180, 25), UDim2.fromOffset(56, 17), 15, COLORS.White, Enum.Font.GothamBold)

-- Status Dot
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.fromOffset(10, 10)
StatusDot.Position = UDim2.fromOffset(240, 26)
StatusDot.BackgroundColor3 = _enabled and COLORS.Green or COLORS.Red
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 4
StatusDot.Parent = Header
addCorner(StatusDot, 5)

local function updateStatusDot()
    StatusDot.BackgroundColor3 = _enabled and COLORS.Green or COLORS.Red
end

makeLabel(Header, "DiscordLink", "discord.gg/KxKy5xK3nd", UDim2.fromOffset(140, 16), UDim2.fromOffset(56, 42), 10, COLORS.Dim, Enum.Font.GothamMedium)

-- GEAR BUTTON
local GearButton = Instance.new("TextButton")
GearButton.Name = "GearButton"
GearButton.Size = UDim2.fromOffset(30, 30)
GearButton.Position = UDim2.new(1, -100, 0, 15)
GearButton.BackgroundTransparency = 1
GearButton.Text = "⚙️"
GearButton.TextSize = 22
GearButton.TextColor3 = COLORS.Text
GearButton.Font = Enum.Font.GothamBold
GearButton.ZIndex = 5
GearButton.Parent = Header

-- TOGGLE BUTTON
local AutoWriteButton = Instance.new("TextButton")
AutoWriteButton.Name = "AutoWrite"
AutoWriteButton.Size = UDim2.fromOffset(47, 24)
AutoWriteButton.Position = UDim2.new(1, -64, 0, 18)
AutoWriteButton.BackgroundColor3 = COLORS.Accent
AutoWriteButton.BorderSizePixel = 0
AutoWriteButton.AutoButtonColor = false
AutoWriteButton.Active = true
AutoWriteButton.Text = ""
AutoWriteButton.ZIndex = 5
AutoWriteButton.Parent = Header
addCorner(AutoWriteButton, 12)

local AutoWriteStroke = addStroke(AutoWriteButton, COLORS.White, 1, 0.62)
local AutoWriteKnob = Instance.new("Frame")
AutoWriteKnob.Name = "Knob"
AutoWriteKnob.Size = UDim2.fromOffset(20, 20)
AutoWriteKnob.Position = UDim2.new(1, -22, 0.5, -10)
AutoWriteKnob.BackgroundColor3 = COLORS.Window
AutoWriteKnob.BorderSizePixel = 0
AutoWriteKnob.ZIndex = 6
AutoWriteKnob.Parent = AutoWriteButton
addCorner(AutoWriteKnob, 10)

local autoWriteEnabled = _enabled
_enabled = autoWriteEnabled
AutoWriteButton.BackgroundColor3 = autoWriteEnabled and COLORS.Accent or COLORS.Control
AutoWriteStroke.Transparency = autoWriteEnabled and 0.62 or 0.88
AutoWriteKnob.BackgroundColor3 = autoWriteEnabled and COLORS.Window or COLORS.White
AutoWriteKnob.Position = autoWriteEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)

local lastToggleTime = 0
local function toggleAutoWrite()
    if tick() - lastToggleTime < 0.15 then return end
    lastToggleTime = tick()
    
    autoWriteEnabled = not autoWriteEnabled
    _enabled = autoWriteEnabled
    if not autoWriteEnabled and clearAceCapture then clearAceCapture() end
    savedConfig.codeSniper = autoWriteEnabled
    saveConfig()
    _lastStatusMsg = nil
    updateStatusDot()
    AutoWriteButton.BackgroundColor3 = autoWriteEnabled and COLORS.Accent or COLORS.Control
    AutoWriteStroke.Transparency = autoWriteEnabled and 0.62 or 0.88
    AutoWriteKnob.BackgroundColor3 = autoWriteEnabled and COLORS.Window or COLORS.White
    AutoWriteKnob.Position = autoWriteEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    
    if ConsoleOutput then
        if autoWriteEnabled then
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Amber .. '">&gt;</font> <font color="' .. CONSOLE_COLORS.Dim .. '">waiting for trigger...</font>'
            for _, featureName in ipairs({"Auto submit", "Riddle solver", "Retype invalid", "Spam redeem", "Auto redeem riddles", "Performance Mode"}) do
                if featureStates[featureName] then appendConsoleStatus(featureName, true) end
            end
        else
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Dim .. '">status:</font> <font color="' .. CONSOLE_COLORS.Red .. '">OFF</font>\n<font color="' .. CONSOLE_COLORS.Dim .. '">code sniper paused</font>'
        end
        scrollConsoleToBottom()
    end
end

AutoWriteButton.Activated:Connect(toggleAutoWrite)
AutoWriteButton.MouseButton1Click:Connect(toggleAutoWrite)
AutoWriteButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleAutoWrite()
    end
end)

local HeaderAccent = Instance.new("Frame")
HeaderAccent.Name = "TitleDivider"
HeaderAccent.Size = UDim2.new(1, -34, 0, 1)
HeaderAccent.Position = UDim2.fromOffset(17, 54)
HeaderAccent.BackgroundColor3 = COLORS.Border
HeaderAccent.BackgroundTransparency = 0.5
HeaderAccent.BorderSizePixel = 0
HeaderAccent.Parent = Header

-- RIDDLE ANSWER FRAME
local RiddleAnswerFrame = Instance.new("Frame")
RiddleAnswerFrame.Name = "RiddleAnswerFrame"
RiddleAnswerFrame.Size = UDim2.new(1, -34, 0, 55)
RiddleAnswerFrame.Position = UDim2.fromOffset(17, 70)
RiddleAnswerFrame.BackgroundColor3 = COLORS.Log
RiddleAnswerFrame.BorderSizePixel = 0
RiddleAnswerFrame.ClipsDescendants = true
RiddleAnswerFrame.Parent = Window
addCorner(RiddleAnswerFrame, 9)
addStroke(RiddleAnswerFrame, COLORS.Border, 1, 0.3)

local AnswerLabel = Instance.new("TextLabel")
AnswerLabel.Name = "AnswerLabel"
AnswerLabel.Size = UDim2.new(1, -10, 0.5, -2)
AnswerLabel.Position = UDim2.fromOffset(5, 2)
AnswerLabel.BackgroundTransparency = 1
AnswerLabel.Text = "🎯 Answer: "
AnswerLabel.TextSize = 12
AnswerLabel.TextColor3 = COLORS.Text
AnswerLabel.Font = Enum.Font.GothamMedium
AnswerLabel.TextXAlignment = Enum.TextXAlignment.Left
AnswerLabel.TextYAlignment = Enum.TextYAlignment.Top
AnswerLabel.TextWrapped = true
AnswerLabel.Parent = RiddleAnswerFrame
_answerLabel = AnswerLabel

local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "ButtonFrame"
ButtonFrame.Size = UDim2.new(1, -10, 0.5, -2)
ButtonFrame.Position = UDim2.new(0, 5, 0.5, 2)
ButtonFrame.BackgroundTransparency = 1
ButtonFrame.Parent = RiddleAnswerFrame

local function createRiddleButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 1, -4)
    btn.Position = UDim2.new(0, 0, 0, 2)
    btn.BackgroundColor3 = color or COLORS.Control
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text
    btn.TextSize = 11
    btn.TextColor3 = COLORS.White
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    addCorner(btn, 6)
    addStroke(btn, COLORS.Border, 1, 0.5)
    btn.Activated:Connect(callback)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local copyBtn = createRiddleButton(ButtonFrame, "📋 Copy", function()
    if _currentRiddleAnswer and _currentRiddleAnswer ~= "" then
        if toclipboard then
            toclipboard(_currentRiddleAnswer)
            setStatus("Copied: " .. _currentRiddleAnswer, COLORS.Green)
        else
            setStatus("Clipboard not available", COLORS.Red)
        end
    else
        setStatus("No riddle answer to copy", COLORS.Red)
    end
end, COLORS.Accent)
copyBtn.Position = UDim2.new(0, 0, 0, 2)

local clearBtn = createRiddleButton(ButtonFrame, "🗑️ Clear", function()
    _currentRiddleAnswer = ""
    if _answerLabel then _answerLabel.Text = "🎯 Answer: " end
    setStatus("Cleared riddle answer", COLORS.Dim)
end, COLORS.Control)
clearBtn.Position = UDim2.new(0, 55, 0, 2)

local redeemBtn = createRiddleButton(ButtonFrame, "✅ Redeem", function()
    if _currentRiddleAnswer and _currentRiddleAnswer ~= "" then
        typeAndSubmitCode(_currentRiddleAnswer)
        setStatus("Redeeming: " .. _currentRiddleAnswer, COLORS.Green)
    else
        setStatus("No riddle answer to redeem", COLORS.Red)
    end
end, COLORS.Green)
redeemBtn.Position = UDim2.new(0, 110, 0, 2)
redeemBtn.Size = UDim2.new(0, 60, 1, -4)

-- Console
Console = Instance.new("ScrollingFrame")
Console.Name = "Console"
Console.Size = UDim2.new(1, -34, 0, 85)
Console.Position = UDim2.fromOffset(17, 130)
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
addStroke(Console, COLORS.Border, 1, 0.3)

ConsoleOutput = Instance.new("TextLabel")
ConsoleOutput.Name = "ConsoleOutput"
ConsoleOutput.Size = UDim2.new(1, -18, 0, 90)
ConsoleOutput.AutomaticSize = Enum.AutomaticSize.Y
ConsoleOutput.Position = UDim2.fromOffset(9, 6)
ConsoleOutput.BackgroundTransparency = 1
ConsoleOutput.RichText = true
if autoWriteEnabled then
    ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Amber .. '">&gt;</font> <font color="' .. CONSOLE_COLORS.Dim .. '">waiting for trigger...</font>\n' .. '<font color="' .. CONSOLE_COLORS.Dim .. '">Triggers: ' .. table.concat(_triggers, ", ") .. '</font>'
else
    ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Dim .. '">status:</font> <font color="' .. CONSOLE_COLORS.Red .. '">OFF</font>\n<font color="' .. CONSOLE_COLORS.Dim .. '">code sniper paused</font>'
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
    local contentHeight = ConsoleOutput.Position.Y.Offset + ConsoleOutput.AbsoluteSize.Y + CONSOLE_BOTTOM_PADDING
    Console.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end
ConsoleOutput:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateConsoleCanvas)
task.defer(updateConsoleCanvas)

-- Clear Logs Button
local ClearLogsBtn = Instance.new("TextButton")
ClearLogsBtn.Name = "ClearLogsBtn"
ClearLogsBtn.Size = UDim2.fromOffset(60, 22)
ClearLogsBtn.Position = UDim2.new(1, -76, 1, -28)
ClearLogsBtn.BackgroundColor3 = COLORS.Control
ClearLogsBtn.BorderSizePixel = 0
ClearLogsBtn.AutoButtonColor = false
ClearLogsBtn.Text = "Clear"
ClearLogsBtn.TextSize = 10
ClearLogsBtn.TextColor3 = COLORS.Text
ClearLogsBtn.Font = Enum.Font.GothamBold
ClearLogsBtn.ZIndex = 5
ClearLogsBtn.Parent = Window
addCorner(ClearLogsBtn, 6)
addStroke(ClearLogsBtn, COLORS.Border, 1, 0.5)
ClearLogsBtn.Activated:Connect(function()
    if ConsoleOutput then ConsoleOutput.Text = "" end
end)

-- WINDOW DRAGGING
do
    local dragging = false
    local activeDragInput
    local dragStart
    local startPosition
    local dragMoved = false
    local DRAG_THRESHOLD = UserInputService.TouchEnabled and 10 or 3
    
    local function isOverHeaderControl(position)
        local btnPos = AutoWriteButton.AbsolutePosition
        local btnSize = AutoWriteButton.AbsoluteSize
        local gearPos = GearButton.AbsolutePosition
        local gearSize = GearButton.AbsoluteSize
        return (position.X >= (btnPos.X - 10) and position.X <= (btnPos.X + btnSize.X + 10) and position.Y >= (btnPos.Y - 10) and position.Y <= (btnPos.Y + btnSize.Y + 10))
            or (position.X >= (gearPos.X - 10) and position.X <= (gearPos.X + gearSize.X + 10) and position.Y >= (gearPos.Y - 10) and position.Y <= (gearPos.Y + gearSize.Y + 10))
    end
    
    local function stopDragging(input)
        if input ~= activeDragInput then return end
        dragging = false
        activeDragInput = nil
        dragStart = nil
        startPosition = nil
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if dragging or isOverHeaderControl(input.Position) then return end
        
        dragging = true
        activeDragInput = input
        dragStart = Vector2.new(input.Position.X, input.Position.Y)
        startPosition = Window.Position
        dragMoved = false
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                stopDragging(input)
            end
        end)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not activeDragInput then return end
        local isTrackedTouch = activeDragInput.UserInputType == Enum.UserInputType.Touch and input == activeDragInput
        local isTrackedMouse = activeDragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement
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

-- ============================================================
-- SETTINGS UI (GEAR POPUP)
-- ============================================================
local SettingsGUI = nil
local function createSettingsUI()
    if SettingsGUI and SettingsGUI.Parent then
        SettingsGUI:Destroy()
        SettingsGUI = nil
        return
    end
    
    SettingsGUI = Instance.new("ScreenGui")
    SettingsGUI.Name = "ACESettingsUI"
    SettingsGUI.ResetOnSpawn = false
    SettingsGUI.IgnoreGuiInset = true
    SettingsGUI.DisplayOrder = 998
    if not pcall(function() SettingsGUI.Parent = game.CoreGui end) then SettingsGUI.Parent = playerGui end
    
    local SettingsWindow = Instance.new("Frame")
    SettingsWindow.Name = "SettingsWindow"
    SettingsWindow.Size = UDim2.fromOffset(270, 360)
    SettingsWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    SettingsWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    SettingsWindow.BackgroundTransparency = 1
    SettingsWindow.BorderSizePixel = 0
    SettingsWindow.ClipsDescendants = true
    SettingsWindow.Parent = SettingsGUI
    addCorner(SettingsWindow, 14)
    addStroke(SettingsWindow, COLORS.Border, 1, 0.3)
    
    local SettingsBg = Instance.new("ImageLabel")
    SettingsBg.Name = "SettingsBackground"
    SettingsBg.Size = UDim2.new(1, 0, 1, 0)
    SettingsBg.Position = UDim2.fromOffset(0, 0)
    SettingsBg.BackgroundTransparency = 1
    SettingsBg.Image = "rbxassetid://94538552851680"
    SettingsBg.ImageTransparency = 0
    SettingsBg.ScaleType = Enum.ScaleType.Stretch
    SettingsBg.ZIndex = 1
    SettingsBg.Parent = SettingsWindow
    addCorner(SettingsBg, 14)
    
    local SettingsTitle = makeLabel(SettingsWindow, "Title", "⚙️ Settings", UDim2.new(1, -20, 0, 40), UDim2.fromOffset(10, 10), 18, COLORS.Text, Enum.Font.GothamBold)
    SettingsTitle.TextXAlignment = Enum.TextXAlignment.Center
    SettingsTitle.ZIndex = 2
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextSize = 18
    closeBtn.TextColor3 = COLORS.Dim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 2
    closeBtn.Parent = SettingsWindow
    closeBtn.Activated:Connect(function() if SettingsGUI then SettingsGUI:Destroy(); SettingsGUI = nil end end)
    
    local function makeSettingCard(parent, yOffset, height)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -20, 0, height)
        card.Position = UDim2.new(0, 10, 0, yOffset)
        card.BackgroundColor3 = COLORS.Row
        card.BackgroundTransparency = 0.4
        card.BorderSizePixel = 0
        card.Parent = parent
        card.ZIndex = 2
        addCorner(card, 8)
        addStroke(card, COLORS.Border, 1, 0.5)
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
        button.Active = true
        button.Text = enabled and "ON" or "OFF"
        button.TextSize = 8
        button.TextColor3 = enabled and COLORS.Window or COLORS.Dim
        button.Font = Enum.Font.GothamBold
        button.ZIndex = 5
        button.Parent = parent
        addCorner(button, 6)
        local outline = addStroke(button, COLORS.White, 1, enabled and 0.62 or 0.88)
        local state = enabled
        local lastSubToggle = 0
        
        local function toggleState()
            if tick() - lastSubToggle < 0.15 then return end
            lastSubToggle = tick()
            state = not state
            featureStates[consoleName] = state
            button.Text = state and "ON" or "OFF"
            button.BackgroundColor3 = state and COLORS.Accent or COLORS.Control
            button.TextColor3 = state and COLORS.Window or COLORS.Dim
            outline.Transparency = state and 0.62 or 0.88
            if autoWriteEnabled then appendConsoleStatus(consoleName, state) end
            if onToggle then onToggle(state) end
        end
        
        button.Activated:Connect(toggleState)
        button.MouseButton1Click:Connect(toggleState)
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleState()
            end
        end)
        return button
    end
    
    -- Auto submit
    local autoCard = makeSettingCard(SettingsWindow, 45, 38)
    makeLabel(autoCard, "Title", "Auto submit", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(autoCard, _autoAccept, "Auto submit", function(state)
        _autoAccept = state
        savedConfig.autoSubmit = state
        saveConfig()
    end)
    
    -- Riddle solver
    local riddleCard = makeSettingCard(SettingsWindow, 88, 38)
    makeLabel(riddleCard, "Title", "Riddle solver", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(riddleCard, _riddleSolver, "Riddle solver", function(state)
        _riddleSolver = state
        savedConfig.riddleSolver = state
        saveConfig()
    end)
    
    -- Auto redeem riddles
    local autoRiddleCard = makeSettingCard(SettingsWindow, 131, 38)
    makeLabel(autoRiddleCard, "Title", "Auto redeem riddles", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(autoRiddleCard, _autoRedeemRiddles, "Auto redeem riddles", function(state)
        _autoRedeemRiddles = state
        savedConfig.autoRedeemRiddles = state
        saveConfig()
    end)
    
    -- Submit after
    local delayCard = makeSettingCard(SettingsWindow, 174, 42)
    makeLabel(delayCard, "Title", "Submit after", UDim2.fromOffset(130, 42), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    local CounterShell = Instance.new("Frame")
    CounterShell.Name = "Counter"
    CounterShell.Size = UDim2.fromOffset(90, 28)
    CounterShell.Position = UDim2.new(1, -100, 0.5, -14)
    CounterShell.BackgroundColor3 = COLORS.Window
    CounterShell.BackgroundTransparency = 0.05
    CounterShell.BorderSizePixel = 0
    CounterShell.Parent = delayCard
    CounterShell.ZIndex = 2
    addCorner(CounterShell, 7)
    addStroke(CounterShell, COLORS.Border, 1, 0.5)
    
    local Minus = Instance.new("TextButton")
    Minus.Name = "Minus"
    Minus.Size = UDim2.fromOffset(22, 22)
    Minus.Position = UDim2.fromOffset(3, 3)
    Minus.BackgroundColor3 = COLORS.Control
    Minus.BorderSizePixel = 0
    Minus.AutoButtonColor = false
    Minus.Active = true
    Minus.Text = "-"
    Minus.TextSize = 14
    Minus.TextColor3 = COLORS.Text
    Minus.Font = Enum.Font.GothamBold
    Minus.Parent = CounterShell
    Minus.ZIndex = 3
    addCorner(Minus, 5)
    
    local Count = makeLabel(CounterShell, "Count", tostring(_submitAfter), UDim2.fromOffset(24, 22), UDim2.fromOffset(33, 3), 15, COLORS.White, Enum.Font.GothamBold)
    Count.TextXAlignment = Enum.TextXAlignment.Center
    Count.ZIndex = 3
    
    local Plus = Instance.new("TextButton")
    Plus.Name = "Plus"
    Plus.Size = UDim2.fromOffset(22, 22)
    Plus.Position = UDim2.fromOffset(65, 3)
    Plus.BackgroundColor3 = COLORS.Control
    Plus.BorderSizePixel = 0
    Plus.AutoButtonColor = false
    Plus.Active = true
    Plus.Text = "+"
    Plus.TextSize = 14
    Plus.TextColor3 = COLORS.Text
    Plus.Font = Enum.Font.GothamBold
    Plus.Parent = CounterShell
    Plus.ZIndex = 3
    addCorner(Plus, 5)
    
    local function decr()
        _submitAfter = math.max(1, _submitAfter - 1)
        Count.Text = tostring(_submitAfter)
        savedConfig.submitAfter = _submitAfter
        clearAceCapture()
        saveConfig()
    end
    local function incr()
        _submitAfter += 1
        Count.Text = tostring(_submitAfter)
        savedConfig.submitAfter = _submitAfter
        clearAceCapture()
        saveConfig()
    end
    Minus.Activated:Connect(decr)
    Minus.MouseButton1Click:Connect(decr)
    Plus.Activated:Connect(incr)
    Plus.MouseButton1Click:Connect(incr)
    
    -- Retype invalid
    local retypeCard = makeSettingCard(SettingsWindow, 221, 38)
    makeLabel(retypeCard, "Title", "Retype invalid", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(retypeCard, _retypeInvalid, "Retype invalid", function(state)
        _retypeInvalid = state
        savedConfig.retypeInvalid = state
        saveConfig()
    end)
    
    -- Spam redeem
    local spamCard = makeSettingCard(SettingsWindow, 264, 38)
    makeLabel(spamCard, "Title", "Spam redeem", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(spamCard, _spamRedeem, "Spam redeem", function(state)
        _spamRedeem = state
        savedConfig.spamRedeem = state
        saveConfig()
    end)
    
    -- Performance Mode
    local perfCard = makeSettingCard(SettingsWindow, 307, 38)
    makeLabel(perfCard, "Title", "⚡ Performance Mode", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.Gold, Enum.Font.GothamMedium)
    makeStateButton(perfCard, savedConfig.performanceMode, "Performance Mode", function(state)
        savedConfig.performanceMode = state
        saveConfig()
        if state then
            applyPerformanceSettings()
            setStatus("⚡ Performance mode ON", COLORS.Green)
        else
            revertPerformanceSettings()
            setStatus("Performance mode OFF", COLORS.Red)
        end
    end)
    
    -- Dragging for settings window
    do
        local drag, input, start, pos
        SettingsWindow.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true
                input = i
                start = Vector2.new(i.Position.X, i.Position.Y)
                pos = SettingsWindow.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End or i.UserInputState == Enum.UserInputState.Cancel then
                        drag = false
                        input = nil
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and input then
                if (input.UserInputType == Enum.UserInputType.MouseButton1 and i.UserInputType == Enum.UserInputType.MouseMovement) or
                   (input.UserInputType == Enum.UserInputType.Touch and i == input) then
                    local delta = Vector2.new(i.Position.X, i.Position.Y) - start
                    SettingsWindow.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
                end
            end
        end)
    end
end

GearButton.Activated:Connect(createSettingsUI)
GearButton.MouseButton1Click:Connect(createSettingsUI)
GearButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        createSettingsUI()
    end
end)

-- ============================================================
-- CONSOLE FUNCTIONS
-- ============================================================
local function col3ToRich(col)
    if col == COLORS.Green then return CONSOLE_COLORS.Green end
    if col == COLORS.Red then return CONSOLE_COLORS.Red end
    if col == COLORS.Text then return CONSOLE_COLORS.Amber end
    if col == COLORS.White then return CONSOLE_COLORS.Cyan end
    if col == COLORS.Dim then return CONSOLE_COLORS.Dim end
    if col == COLORS.Gold then return CONSOLE_COLORS.Gold end
    return string.format("rgb(%d,%d,%d)", math.floor(col.R * 255 + 0.5), math.floor(col.G * 255 + 0.5), math.floor(col.B * 255 + 0.5))
end

function setStatus(msg, col)
    if not ConsoleOutput or not _enabled then return end
    if msg == _lastStatusMsg then return end
    _lastStatusMsg = msg
    col = col or COLORS.Dim
    local line = '<font color="' .. col3ToRich(col) .. '">' .. tostring(msg) .. "</font>"
    if ConsoleOutput.Text == "" then ConsoleOutput.Text = line
    else ConsoleOutput.Text = ConsoleOutput.Text .. "\n\n" .. line end
    scrollConsoleToBottom()
end

function flashCode(code, col)
    if not code or code == "" or code == "—" then return end
    setStatus("[code] -> " .. tostring(code), col or COLORS.White)
end

local function resetPasteCounter() _capturedParts = {} end
clearAceCapture = function() _capturedParts = {} end

local function clearBoxWatchers()
    if _boxTextConn then pcall(function() _boxTextConn:Disconnect() end) end
    if _boxAncestryConn then pcall(function() _boxAncestryConn:Disconnect() end) end
    for _, connection in ipairs(_boxVisibilityConns) do pcall(function() connection:Disconnect() end) end
    _boxTextConn = nil
    _boxAncestryConn = nil
    _boxVisibilityConns = {}
    _lastWatchedBox = nil
end

local function watchBoxForBlankReset(box)
    if not box or _lastWatchedBox == box then return end
    clearBoxWatchers()
    _lastWatchedBox = box
    if box.Text ~= "" then _lastNonBlankBoxText = box.Text end
    _boxTextConn = box:GetPropertyChangedSignal("Text"):Connect(function()
        if box.Text == "" then resetPasteCounter()
        else _lastNonBlankBoxText = box.Text end
    end)
    _boxAncestryConn = box.AncestryChanged:Connect(function(_, parent)
        if not parent then resetPasteCounter(); clearBoxWatchers() end
    end)
end

UserInputService.TextBoxFocused:Connect(function(box)
    if box:IsDescendantOf(GUI) or (SettingsGUI and box:IsDescendantOf(SettingsGUI)) then return end
    if box ~= aceCodeBox() then return end
    _focused = box
    _lastBox = box
    watchBoxForBlankReset(box)
    if _enabled then setStatus("Ready", COLORS.Green) end
end)

UserInputService.TextBoxFocusReleased:Connect(function(box)
    if box:IsDescendantOf(GUI) or (SettingsGUI and box:IsDescendantOf(SettingsGUI)) then return end
    local codeBox = aceCodeBox()
    if box ~= codeBox and box ~= _lastBox then return end
    if _retypeInvalid and rememberPendingSubmission and (box == codeBox or box == _lastBox) then
        local submittedText = box.Text ~= "" and box.Text or _lastNonBlankBoxText
        rememberPendingSubmission(box, submittedText, false)
    end
    if _focused == box then
        _focused = nil
        if _enabled then
            setStatus((_lastBox and _lastBox.Parent) and "Ready" or "Click code box first", (_lastBox and _lastBox.Parent) and COLORS.Green or COLORS.Dim)
        end
    end
end)

clearPendingSubmission = function()
    _pendingRejectedToken += 1
    _pendingRejectedText = nil
    _pendingRejectedBox = nil
    _pendingRejectedUntil = 0
end

rememberPendingSubmission = function(box, text, replaceExisting)
    if not _retypeInvalid or not text or text == "" then return end
    if not replaceExisting and _pendingRejectedText and os.clock() <= _pendingRejectedUntil then return end
    _pendingRejectedToken += 1
    local token = _pendingRejectedToken
    _pendingRejectedText = text
    _pendingRejectedBox = box
    _pendingRejectedUntil = os.clock() + 8
    task.delay(8, function()
        if token == _pendingRejectedToken then clearPendingSubmission() end
    end)
end

local function restoreRejectedText(box, previousText)
    if not _retypeInvalid or not previousText or previousText == "" then return false end
    RunService.Heartbeat:Wait()
    local repasteBox = aceCodeBox() or box
    if not repasteBox or not isVisibleChain(repasteBox) then return false end
    local restored = pcall(function() repasteBox.Text = previousText end)
    if restored then
        _lastBox = repasteBox
        watchBoxForBlankReset(repasteBox)
    end
    return restored
end

handleRedemptionFeedback = function(text, feedbackObject)
    if not _retypeInvalid or not _pendingRejectedText then return end
    if os.clock() > _pendingRejectedUntil then clearPendingSubmission(); return end
    if feedbackObject and feedbackObject:IsDescendantOf(GUI) or (SettingsGUI and feedbackObject:IsDescendantOf(SettingsGUI)) then return end
    local lower = tostring(text or ""):lower()
    local rejected = lower:find("invalid code", 1, true)
        or lower:find("code is invalid", 1, true)
        or lower:find("expired", 1, true)
        or lower:find("already redeemed", 1, true)
        or lower:find("already used", 1, true)
        or lower:find("doesn't exist", 1, true)
        or lower:find("does not exist", 1, true)
        or lower:find("not found", 1, true)
        or lower:find("rejected", 1, true)
    if not rejected then return end
    local previousText = _pendingRejectedText
    local previousBox = _pendingRejectedBox
    local restored = restoreRejectedText(previousBox, previousText)
    clearPendingSubmission()
    if restored then
        setStatus("Invalid - repasted: " .. previousText, COLORS.Text)
        flashCode(previousText, COLORS.Red)
    end
end

function appendToBox(text)
    if not text or text == "" then return end
    
    if not _isActive then return end
    
    if _lastWatchedBox and not isVisibleChain(_lastWatchedBox) then
        resetPasteCounter()
        clearBoxWatchers()
    end
    local box = aceCodeBox()
    _capturedParts[#_capturedParts + 1] = text
    local combinedCode = table.concat(_capturedParts)
    local capturedCount = #_capturedParts
    
    if box then
        _lastBox = box
        watchBoxForBlankReset(box)
        local boxWasFocused = UserInputService:GetFocusedTextBox() == box
        box.Text = combinedCode
        if boxWasFocused then
            pcall(function()
                local caretEnd = #combinedCode + 1
                box.CursorPosition = caretEnd
                box.SelectionStart = caretEnd
            end)
        end
    else
        setStatus("Captured; opening & searching UI...", COLORS.Text)
    end
    
    setStatus("Pasted " .. tostring(capturedCount) .. "/" .. tostring(_submitAfter) .. " (trigger: " .. _triggerUsed .. ")", COLORS.Green)
    flashCode(combinedCode, COLORS.Green)
    
    if capturedCount >= _submitAfter then
        _capturedParts = {}
        if _autoAccept then
            rememberPendingSubmission(box, combinedCode, true)
            
            local ok, statusMsg = typeAndSubmitCode(combinedCode)
            
            if ok then
                setStatus("✅ Redeemed: " .. combinedCode, COLORS.Green)
            else
                local restored = restoreRejectedText(box, combinedCode)
                clearPendingSubmission()
                if restored then
                    setStatus("Invalid - repasted: " .. combinedCode, COLORS.Text)
                    flashCode(combinedCode, COLORS.Red)
                else
                    setStatus("Failed: " .. tostring(statusMsg), COLORS.Red)
                end
            end
            
            _isActive = false
            _triggerUsed = ""
            setStatus("⏳ Waiting for trigger... (" .. table.concat(_triggers, ", ") .. ")", COLORS.Dim)
        end
    end
end

local function watchRedemptionFeedbackObject(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
    handleRedemptionFeedback(obj.Text or "", obj)
    obj:GetPropertyChangedSignal("Text"):Connect(function()
        handleRedemptionFeedback(obj.Text or "", obj)
    end)
end

for _, obj in ipairs(playerGui:GetDescendants()) do watchRedemptionFeedbackObject(obj) end
playerGui.DescendantAdded:Connect(function(obj)
    task.wait(0.04)
    watchRedemptionFeedbackObject(obj)
end)

-- ============================================================
-- ANNOUNCEMENT LISTENER WITH TRIGGER SYSTEM
-- ============================================================
local function resolveNotifyRemote()
    if _G.PhiNotifyRemote then return _G.PhiNotifyRemote end
    local Net = ReplicatedStorage:FindFirstChild("Packages")
    if Net then
        local getinfo = debug and (debug.getinfo or debug.info)
        if getgc and getinfo and getconnections then
            for _, d in ipairs(Net:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    local ok, cs = pcall(getconnections, d.OnClientEvent)
                    if ok then
                        for _, c in ipairs(cs) do
                            local f, fn = pcall(function() return c.Function end)
                            if f and type(fn) == "function" then
                                local i, info = pcall(getinfo, fn)
                                if i and tostring(info.short_src or info.source or ""):find("NotificationController", 1, true) then
                                    return d
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    for _, service in ipairs({ReplicatedStorage, game}) do
        for _, obj in ipairs(service:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local ok, cs = pcall(getconnections, obj.OnClientEvent)
                if ok and type(cs) == "table" and #cs > 0 then
                    return obj
                end
            end
        end
    end
    return nil
end

local function aceStripRich(text)
    if type(text) ~= "string" then return tostring(text) end
    return (text:gsub("<[^>]->", ""))
end

local function aceTokenize(text)
    local words = {}
    for word in text:gmatch("[%w_]+") do
        words[#words + 1] = word
    end
    return words
end

local aceCollectBuffer = {}
local function onAceAnnouncement(...)
    local text = aceStripRich(tostring((...) or ""))
    text = text:match("^%s*(.-)%s*$") or ""
    if text == "" then return end
    
    local lower = text:lower()
    
    -- Trigger detection
    local triggerFound = false
    local matchedTrigger = ""
    for _, trigger in ipairs(_triggers) do
        if lower:find(trigger:lower()) then
            triggerFound = true
            matchedTrigger = trigger
            break
        end
    end
    
    if triggerFound then
        _isActive = true
        _triggerUsed = matchedTrigger
        _capturedParts = {}
        setStatus("🔴 TRIGGERED: " .. matchedTrigger .. " — Waiting for code parts...", COLORS.Gold)
        return
    end
    
    if not _isActive then
        return
    end
    
    -- Riddle detection (multi-word)
    if _riddleSolver and text:find("%s") then
        if setStatus then setStatus("Riddle detected: " .. text, COLORS and COLORS.Text) end
        _riddleSeq = _riddleSeq + 1
        solveRiddle(text, _riddleSeq)
        return
    end
    
    -- Single-word code capture
    for _, word in ipairs(aceTokenize(text)) do
        aceCollectBuffer[#aceCollectBuffer + 1] = word
    end
    
    local parts = {}
    for index = 1, math.min(#aceCollectBuffer, 1) do
        parts[index] = aceCollectBuffer[index]
    end
    if #aceCollectBuffer < 1 then return end
    aceCollectBuffer = {}
    
    local captured = table.concat(parts)
    if captured == "" or _seen[captured] then return end
    _seen[captured] = true
    task.delay(1.25, function() _seen[captured] = nil end)
    
    if _isActive then
        appendToBox(captured)
    end
end

-- Hook remote
local aceNotifyRemote = resolveNotifyRemote()
local aceListenConnection
if aceNotifyRemote then
    if getgenv then
        local previous = getgenv().ACECodeSniperNotifyConnection
        if previous then pcall(function() previous:Disconnect() end) end
    end
    aceListenConnection = aceNotifyRemote.OnClientEvent:Connect(function(...)
        if not _enabled then return end
        pcall(onAceAnnouncement, ...)
    end)
    if getgenv then getgenv().ACECodeSniperNotifyConnection = aceListenConnection end
else
    if player.Chatted then
        if getgenv then
            local previous = getgenv().ACECodeSniperChatConnection
            if previous then pcall(function() previous:Disconnect() end) end
        end
        aceListenConnection = player.Chatted:Connect(function(msg)
            if not _enabled then return end
            pcall(onAceAnnouncement, msg)
        end)
        if getgenv then getgenv().ACECodeSniperChatConnection = aceListenConnection end
        setStatus("No notification remote found – listening to chat instead", COLORS.Text)
    else
        setStatus("No riddle listener available – remote and chat not found", COLORS.Red)
    end
end

-- Initial status
setStatus("⏳ Waiting for trigger... (" .. table.concat(_triggers, ", ") .. ")", COLORS.Dim)

-- Apply performance settings on startup
if savedConfig.performanceMode then
    task.spawn(applyPerformanceSettings)
end

-- Stop function
if getgenv then
    getgenv().StopAura = function()
        if aceListenConnection then pcall(function() aceListenConnection:Disconnect() end) end
        if getgenv().ACECodeSniperNotifyConnection then pcall(function() getgenv().ACECodeSniperNotifyConnection:Disconnect() end) end
        if getgenv().ACECodeSniperChatConnection then pcall(function() getgenv().ACECodeSniperChatConnection:Disconnect() end) end
        if GUI then GUI:Destroy() end
        if SettingsGUI then SettingsGUI:Destroy() end
        if HeadBillboard then pcall(function() HeadBillboard:Destroy() end) end
    end
end
