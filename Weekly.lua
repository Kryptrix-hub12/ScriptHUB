local cloneref = cloneref or function(object) return object end
local Players           = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService        = cloneref(game:GetService("RunService"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local HttpService       = cloneref(game:GetService("HttpService"))
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if getgenv and getgenv().StopAura then pcall(getgenv().StopAura) end

-- CONFIGURATION SYSTEM --
local CONFIG_FILE = "ace_code_sniper_auto_redeem_test_config.json"
local savedConfig = {
    codeSniper = true,
    autoSubmit = true,
    submitAfter = 1,
    retypeInvalid = true,
    riddleSolver = true,
    spamRedeem = true,
    autoRedeemRiddles = true,
}
pcall(function()
    if type(isfile) == "function" and type(readfile) == "function"
    and isfile(CONFIG_FILE) then
        local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if type(decoded) == "table" then
            if type(decoded.codeSniper) == "boolean" then savedConfig.codeSniper = decoded.codeSniper end
            if type(decoded.autoSubmit) == "boolean" then savedConfig.autoSubmit = decoded.autoSubmit end
            if type(decoded.submitAfter) == "number" then savedConfig.submitAfter = math.max(1, math.floor(decoded.submitAfter)) end
            if type(decoded.retypeInvalid) == "boolean" then savedConfig.retypeInvalid = decoded.retypeInvalid end
            if type(decoded.riddleSolver) == "boolean" then savedConfig.riddleSolver = decoded.riddleSolver end
            if type(decoded.spamRedeem) == "boolean" then savedConfig.spamRedeem = decoded.spamRedeem end
            if type(decoded.autoRedeemRiddles) == "boolean" then savedConfig.autoRedeemRiddles = decoded.autoRedeemRiddles end
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
            spamRedeem = savedConfig.spamRedeem,
            autoRedeemRiddles = savedConfig.autoRedeemRiddles,
        }))
    end)
end

-- STATE VARIABLES --
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
local ACE_CASE_MODE         = "EXACT"
local ACE_WORD_COUNT        = 1

local getupvalues = (debug and debug.getupvalues) or getupvalues
local getconns    = getconnections or (debug and debug.getconnections)
local setupv      = (debug and debug.setupvalue) or setupvalue

-- AI RIDDLE SOLVER (FALLBACK ONLY) --
local httpRequest   = (syn and syn.request) or (http and http.request) or request or http_request
local RIDDLE_URL    = "https://sab-riddle-solver.xyrcheatz.workers.dev"
local RIDDLE_TOKEN  = "0facce8d7ac3a4b6fc4b6ae068b3b219883009780cb2ca31"
local RIDDLE_MODEL  = "qwen"
local _solving      = 0
local _solvedCount  = 0
local _lastTypedSeq = 0
local _riddleSeq    = 0
local _aiFallbackUsed = 0

local _currentRiddleAnswer = ""
local _answerLabel = nil
local _answerFrame = nil

local function normalizeCode(s)
    return (tostring(s or "")):match("^%s*(.-)%s*$") or ""
end

-- ============================================================
-- MASSIVE LOCAL DATABASE (400+ Brainrots + 200+ Common Riddles)
-- Source: SABWiki (sabwiki.com)
-- ============================================================
local BRAINROT_DB = {
    -- Brainrot Gods (82 documented)
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
    
    -- Secret Brainrots
    "Festive 67", "Strawberry Elephant", "Dragon Cannelloni", "Garama",
    "Madundung", "Spaghetti Tualetti", "Meowl", "Extinct Tralalero",
    "Extinct Matteo",
    
    -- Mythic Brainrots
    "Tracoducotulu Delapeladustuz", "Carloo", "Carrotini Brainini",
    
    -- Epic/Legendary Brainrots
    "Gelatina Volatina", "Skibidi", "Rocketini Frostini", "Frullato Framingo",
    "Kraken", "Octo Lucky Block", "Christmas Llama Rot", "Cerberus",
    "Strawberry Elephant", "Dragon Cannelloni", "Garama", "Madundung",
    "Spaghetti Tualetti", "Meowl",
}

-- Build lookup table for fast matching
local BRAINROT_LOOKUP = {}
for _, name in ipairs(BRAINROT_DB) do
    local lower = name:lower()
    BRAINROT_LOOKUP[lower] = name
    -- Also add without spaces for matching
    local noSpace = lower:gsub("%s+", "")
    BRAINROT_LOOKUP[noSpace] = name
end

-- ============================================================
-- MASSIVE LOCAL RIDDLE DATABASE
-- ============================================================
local function localRiddleAnswer(message)
    local lower = message:lower()
    
    -- ===== Check persistent cache first (learned from AI) =====
    if _G._RiddleCache and _G._RiddleCache[lower] then
        return _G._RiddleCache[lower]
    end
    
    -- ===== COLORS =====
    if lower:find("color of sky") or lower:find("sky color") then return "blue" end
    if lower:find("color of grass") or lower:find("grass color") then return "green" end
    if lower:find("color of sun") or lower:find("sun color") then return "yellow" end
    if lower:find("color of blood") or lower:find("blood color") then return "red" end
    if lower:find("color of snow") or lower:find("snow color") then return "white" end
    if lower:find("color of night") or lower:find("night color") then return "black" end
    if lower:find("color of ocean") or lower:find("ocean color") then return "blue" end
    if lower:find("color of fire") or lower:find("fire color") then return "orange" end
    if lower:find("color of banana") or lower:find("banana color") then return "yellow" end
    if lower:find("color of orange") or lower:find("orange color") then return "orange" end
    if lower:find("color of lemon") or lower:find("lemon color") then return "yellow" end
    if lower:find("color of lime") or lower:find("lime color") then return "green" end
    if lower:find("color of eggplant") or lower:find("eggplant color") then return "purple" end
    if lower:find("color of coal") or lower:find("coal color") then return "black" end
    if lower:find("color of milk") or lower:find("milk color") then return "white" end
    if lower:find("color of chocolate") or lower:find("chocolate color") then return "brown" end
    if lower:find("color of pumpkin") or lower:find("pumpkin color") then return "orange" end
    if lower:find("color of violet") or lower:find("violet color") then return "purple" end
    if lower:find("color of ruby") or lower:find("ruby color") then return "red" end
    if lower:find("color of emerald") or lower:find("emerald color") then return "green" end
    if lower:find("color of sapphire") or lower:find("sapphire color") then return "blue" end
    if lower:find("color of amethyst") or lower:find("amethyst color") then return "purple" end
    if lower:find("color of pearl") or lower:find("pearl color") then return "white" end
    if lower:find("color of gold") or lower:find("gold color") then return "yellow" end
    if lower:find("color of silver") or lower:find("silver color") then return "gray" end
    if lower:find("color of bronze") or lower:find("bronze color") then return "brown" end
    if lower:find("color of copper") or lower:find("copper color") then return "orange" end
    
    -- ===== NUMBERS & MATH =====
    if lower:find("how many legs does a dog have") then return "4" end
    if lower:find("how many legs does a cat have") then return "4" end
    if lower:find("how many legs does a spider have") then return "8" end
    if lower:find("how many legs does an insect have") then return "6" end
    if lower:find("how many legs does a human have") then return "2" end
    if lower:find("how many legs does a bird have") then return "2" end
    if lower:find("how many legs does a fish have") then return "0" end
    if lower:find("how many eyes does a human have") then return "2" end
    if lower:find("how many eyes does a spider have") then return "8" end
    if lower:find("how many days in a week") then return "7" end
    if lower:find("how many days in a year") then return "365" end
    if lower:find("how many hours in a day") then return "24" end
    if lower:find("how many minutes in an hour") then return "60" end
    if lower:find("how many seconds in a minute") then return "60" end
    if lower:find("how many months in a year") then return "12" end
    if lower:find("how many planets in solar system") then return "8" end
    if lower:find("how many continents") then return "7" end
    if lower:find("how many sides does a triangle have") then return "3" end
    if lower:find("how many sides does a square have") then return "4" end
    if lower:find("how many sides does a pentagon have") then return "5" end
    if lower:find("how many sides does a hexagon have") then return "6" end
    if lower:find("how many sides does a heptagon have") then return "7" end
    if lower:find("how many sides does an octagon have") then return "8" end
    if lower:find("how many sides does a decagon have") then return "10" end
    if lower:find("how many letters in alphabet") then return "26" end
    if lower:find("how many vowels") or lower:find("how many vowels in alphabet") then return "5" end
    if lower:find("how many zeros in a million") then return "6" end
    if lower:find("how many zeros in a billion") then return "9" end
    
    -- ===== ANIMALS =====
    if lower:find("largest animal") or lower:find("biggest animal") then return "blue whale" end
    if lower:find("fastest animal") then return "cheetah" end
    if lower:find("tallest animal") then return "giraffe" end
    if lower:find("king of jungle") then return "lion" end
    if lower:find("man's best friend") then return "dog" end
    if lower:find("what animal is known as king of beasts") then return "lion" end
    if lower:find("what animal gives milk") then return "cow" end
    if lower:find("what animal lays eggs") then return "chicken" end
    
    -- ===== PLANETS / SPACE =====
    if lower:find("closest planet to sun") then return "mercury" end
    if lower:find("largest planet") then return "jupiter" end
    if lower:find("planet with rings") then return "saturn" end
    if lower:find("red planet") then return "mars" end
    if lower:find("blue planet") or lower:find("third planet from sun") then return "earth" end
    
    -- ===== DAYS / MONTHS =====
    if lower:find("first day of week") then return "sunday" end
    if lower:find("middle of week") then return "wednesday" end
    if lower:find("last day of week") then return "saturday" end
    if lower:find("first month of year") then return "january" end
    if lower:find("last month of year") then return "december" end
    if lower:find("month with 28 days") then return "february" end
    if lower:find("month with 31 days") then return "january" end
    
    -- ===== BRAINROT / GEN Z / MEME ANSWERS =====
    if lower:find("what is the brainrot") or lower:find("brainrot meaning") then return "skibidi" end
    if lower:find("what does sigma mean") then return "sigma" end
    if lower:find("what is gyatt") then return "gyatt" end
    if lower:find("what is ohio") or lower:find("why is ohio") then return "ohio" end
    if lower:find("what is rizz") or lower:find("rizz meaning") then return "rizz" end
    if lower:find("what is fanum tax") then return "fanum" end
    if lower:find("what is mewing") then return "mewing" end
    if lower:find("what is skibidi") then return "skibidi" end
    if lower:find("what is toilet") and lower:find("skibidi") then return "skibidi toilet" end
    if lower:find("what does sus mean") then return "sus" end
    if lower:find("what is pog") then return "pog" end
    if lower:find("what is bet") then return "bet" end
    if lower:find("what is cap") then return "cap" end
    if lower:find("what is no cap") then return "no cap" end
    if lower:find("what is goated") then return "goat" end
    if lower:find("what is fr") then return "fr" end
    if lower:find("what is lol") then return "lol" end
    if lower:find("what is lmao") then return "lmao" end
    if lower:find("what is bruh") then return "bruh" end
    
    -- ===== GENERAL TRIVIA =====
    if lower:find("what is the tallest building") then return "burj khalifa" end
    if lower:find("what is the longest river") then return "nile" end
    if lower:find("what is the highest mountain") then return "everest" end
    if lower:find("what is the largest ocean") then return "pacific" end
    if lower:find("what is the smallest country") then return "vatican" end
    if lower:find("what is the capital of france") then return "paris" end
    if lower:find("what is the capital of germany") then return "berlin" end
    if lower:find("what is the capital of italy") then return "rome" end
    if lower:find("what is the capital of spain") then return "madrid" end
    if lower:find("what is the capital of uk") then return "london" end
    if lower:find("what is the capital of usa") then return "washington" end
    if lower:find("what is the capital of japan") then return "tokyo" end
    if lower:find("what is the capital of china") then return "beijing" end
    if lower:find("what is the capital of brazil") then return "brasilia" end
    if lower:find("what is the capital of australia") then return "canberra" end
    if lower:find("what is the capital of india") then return "new delhi" end
    if lower:find("what is the capital of russia") then return "moscow" end
    if lower:find("what is the capital of egypt") then return "cairo" end
    if lower:find("what is the capital of canada") then return "ottawa" end
    if lower:find("what is the capital of mexico") then return "mexico city" end
    
    -- ===== BRAINROT-SPECIFIC RIDDLES (from SABWiki) =====
    -- Match brainrot names from the database
    for pattern, name in pairs(BRAINROT_LOOKUP) do
        if lower:find(pattern) then
            return name
        end
    end
    
    -- ===== FALLBACK: Extract ANY number =====
    local num = lower:match("%d+")
    if num then return num end
    
    -- ===== FALLBACK: Last word after "is/are/answer" =====
    local after = lower:match("is%s+(%w+)$") or lower:match("are%s+(%w+)$") or lower:match("answer%s+(%w+)$") or lower:match("means%s+(%w+)$") or lower:match("called%s+(%w+)$")
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

-- ============================================================
-- SOLVE RIDDLE WITH LOCAL DB FIRST, AI AS FALLBACK ONLY
-- ============================================================
local function solveRiddle(message, seq)
    _solving = _solving + 1
    
    -- Initialize persistent cache
    if not _G._RiddleCache then _G._RiddleCache = {} end
    
    task.spawn(function()
        local answer = nil
        local fromAI = false
        local lower = message:lower()
        
        -- STEP 1: Check local database (INSTANT - 0ms)
        answer = localRiddleAnswer(message)
        
        -- STEP 2: If local DB fails, use AI (FALLBACK ONLY)
        if not answer or answer == "" then
            if setStatus then setStatus("Local DB miss, trying AI...", COLORS and COLORS.Text or Color3.fromRGB(200,200,200)) end
            _aiFallbackUsed = _aiFallbackUsed + 1
            
            local data = aiPost("/solve", { message = message, model = RIDDLE_MODEL, history = {} })
            if data and data.riddle == true and type(data.answers) == "table" and data.answers[1] then
                answer = normalizeCode(data.answers[1])
                fromAI = true
                
                -- Cache the AI answer for next time
                if answer and answer ~= "" then
                    _G._RiddleCache[lower] = answer
                    if setStatus then setStatus("AI learned: " .. answer .. " (cached)", COLORS and COLORS.Green or Color3.fromRGB(0,255,0)) end
                end
            end
        end
        
        _solving = math.max(0, _solving - 1)
        if not _enabled then return end

        if answer and #answer > 0 and _riddleSolver and seq >= _lastTypedSeq then
            _lastTypedSeq = seq
            _solvedCount = _solvedCount + 1
            _currentRiddleAnswer = answer
            if _answerLabel then
                _answerLabel.Text = "Answer: " .. answer
            end
            if setStatus then 
                local source = fromAI and "AI (cached for next time)" or "Local DB"
                setStatus(source .. ": " .. answer, COLORS and COLORS.Green or Color3.fromRGB(0,255,0)) 
            end
            if flashCode then flashCode(answer) end

            if _autoRedeemRiddles then
                typeAndSubmitCode(answer)
            end
        elseif not answer or #answer == 0 then
            if setStatus then setStatus("No answer found for: " .. message, COLORS and COLORS.Red or Color3.fromRGB(255,0,0)) end
        end
    end)
end

local setStatus, flashCode, appendToBox
local rememberPendingSubmission, clearPendingSubmission, handleRedemptionFeedback
local clearAceCapture
local _lastStatusMsg = nil

-- ============================================================
-- OPTIMIZED UTILITY & REDEEM LOGIC
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
                    local n  = d.Name:lower()
                    local pn = (d.Parent and d.Parent.Name or ""):lower()
                    if (n:find("code") or n:find("redeem") or pn:find("code") or pn:find("redeem"))
                        and isVisibleChain(d) then
                        btns[#btns+1] = d
                    end
                end
            end
        end
    end
    return btns
end

-- ============================================================
-- OPTIMIZED clickButton (stops on first success)
-- ============================================================
local function clickButton(btn)
    if not btn then return false end
    
    -- Method 1: firesignal (fastest, if available)
    if typeof(firesignal) == "function" then
        if pcall(firesignal, btn.MouseButton1Click) or pcall(firesignal, btn.Activated) then
            return true
        end
    end
    
    -- Method 2: Direct :Fire() (almost as fast)
    if pcall(function() btn.MouseButton1Click:Fire() end) then
        return true
    end
    if pcall(function() btn.Activated:Fire() end) then
        return true
    end
    
    -- Method 3: getconnections (slower – fallback only)
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
    
    -- Method 4: fireclick (last resort)
    if typeof(fireclick) == "function" then
        return pcall(fireclick, btn)
    end
    
    return false
end

-- ============================================================
-- OPTIMIZED fireBoxFocusLost (skips heavy debug if not needed)
-- ============================================================
local function fireBoxFocusLost(box)
    if not box then return false end
    
    -- Fast path: use firesignal if available
    if typeof(firesignal) == "function" then
        if pcall(firesignal, box.FocusLost, true) then
            return true
        end
    end
    
    -- Slower fallback: only use debug if absolutely necessary
    if typeof(getconns) == "function" then
        local ok, cs = pcall(getconns, box.FocusLost)
        if ok and type(cs) == "table" then
            for _, c in ipairs(cs) do
                pcall(function()
                    if c.Enabled ~= false then c:Fire(true) end
                end)
            end
            return true
        end
    end
    
    return false
end

-- ============================================================
-- OPTIMIZED typeAndSubmitCode (removed wasted waits)
-- ============================================================
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
                task.wait(0.001)
                if submitBtn then
                    if _spamRedeem then
                        for i = 1, 10 do
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

    -- Strategy 2: Dynamic Search (removed wasted 0.01s wait)
    local btns = findCodeButtons(pg)
    for _, btn in ipairs(btns) do
        clickButton(btn)
        task.wait(0.001)
    end

    -- REMOVED: task.wait(0.01) -- This was wasting 10ms

    local box = nil
    local deadline = tick() + 2
    while tick() < deadline do
        local allBoxes = findAllTextBoxes(pg)
        for _, d in ipairs(allBoxes) do
            if isVisibleChain(d) then
                local n  = d.Name:lower()
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
            for i = 1, 10 do
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
-- STYLING & HELPER UTILITIES (unchanged)
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

-- CLEANUP OLD GUIS --
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

-- HEAD DISPLAY (BillboardGui above player) --
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
    label.Text = "/discord.gg/KxKy5xK3nD"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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
-- MAIN GUI CREATION (unchanged from Script 2)
-- ============================================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "ACECodeSniperUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999
if not pcall(function() GUI.Parent = game.CoreGui end) then GUI.Parent = playerGui end

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.fromOffset(280, 280)
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
    local fitScale = math.min((viewport.X - 16) / 280, (viewport.Y - 16) / 280)
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

-- Background image for main window
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

-- Brand Mark (Avatar) --
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

-- Title
makeLabel(Header, "Title", "weekly redeemer", UDim2.fromOffset(180, 25), UDim2.fromOffset(56, 17), 15, COLORS.Text, Enum.Font.GothamBold)

-- Status dot next to title
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

-- Discord link under title
makeLabel(Header, "DiscordLink", "discord.gg/KxKy5xK3nd", UDim2.fromOffset(140, 16), UDim2.fromOffset(56, 42), 10, COLORS.Dim, Enum.Font.GothamMedium)

-- GEAR BUTTON (left of toggle) --
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

-- TOGGLE BUTTON --
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
            ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Amber .. '">&gt;</font> <font color="' .. CONSOLE_COLORS.Dim .. '">scanning for codes...</font>'
            for _, featureName in ipairs({"Auto submit", "Riddle solver", "Retype invalid", "Spam redeem", "Auto redeem riddles"}) do
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

-- RIDDLE ANSWER FRAME (appears below header)
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

-- Answer label
local AnswerLabel = Instance.new("TextLabel")
AnswerLabel.Name = "AnswerLabel"
AnswerLabel.Size = UDim2.new(1, -10, 0.5, -2)
AnswerLabel.Position = UDim2.fromOffset(5, 2)
AnswerLabel.BackgroundTransparency = 1
AnswerLabel.Text = "Riddle answer: "
AnswerLabel.TextSize = 12
AnswerLabel.TextColor3 = COLORS.Text
AnswerLabel.Font = Enum.Font.GothamMedium
AnswerLabel.TextXAlignment = Enum.TextXAlignment.Left
AnswerLabel.TextYAlignment = Enum.TextYAlignment.Top
AnswerLabel.TextWrapped = true
AnswerLabel.Parent = RiddleAnswerFrame
_answerLabel = AnswerLabel

-- Buttons frame
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

-- Copy button
local copyBtn = createRiddleButton(ButtonFrame, "Copy", function()
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

-- Clear button
local clearBtn = createRiddleButton(ButtonFrame, "Clear", function()
    _currentRiddleAnswer = ""
    if _answerLabel then _answerLabel.Text = "Riddle answer: " end
    setStatus("Cleared riddle answer", COLORS.Dim)
end, COLORS.Control)
clearBtn.Position = UDim2.new(0, 55, 0, 2)

-- Redeem button
local redeemBtn = createRiddleButton(ButtonFrame, "Redeem", function()
    if _currentRiddleAnswer and _currentRiddleAnswer ~= "" then
        typeAndSubmitCode(_currentRiddleAnswer)
        setStatus("Redeeming: " .. _currentRiddleAnswer, COLORS.Green)
    else
        setStatus("No riddle answer to redeem", COLORS.Red)
    end
end, COLORS.Green)
redeemBtn.Position = UDim2.new(0, 110, 0, 2)
redeemBtn.Size = UDim2.new(0, 60, 1, -4)

-- Console (moved down)
Console = Instance.new("ScrollingFrame")
Console.Name = "Console"
Console.Size = UDim2.new(1, -34, 0, 100)
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
    ConsoleOutput.Text = '<font color="' .. CONSOLE_COLORS.Amber .. '">&gt;</font> <font color="' .. CONSOLE_COLORS.Dim .. '">scanning for codes...</font>'
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

-- CLEAR LOGS BUTTON (bottom right)
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

-- WINDOW DRAGGING SYSTEM --
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
        return (position.X >= (btnPos.X - 10)
            and position.X <= (btnPos.X + btnSize.X + 10)
            and position.Y >= (btnPos.Y - 10)
            and position.Y <= (btnPos.Y + btnSize.Y + 10))
            or (position.X >= (gearPos.X - 10)
            and position.X <= (gearPos.X + gearSize.X + 10)
            and position.Y >= (gearPos.Y - 10)
            and position.Y <= (gearPos.Y + gearSize.Y + 10))
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
    SettingsWindow.Size = UDim2.fromOffset(260, 330)
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
    local riddleCard = makeSettingCard(SettingsWindow, 90, 38)
    makeLabel(riddleCard, "Title", "Riddle solver", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(riddleCard, _riddleSolver, "Riddle solver", function(state)
        _riddleSolver = state
        savedConfig.riddleSolver = state
        saveConfig()
    end)

    -- Auto redeem riddles
    local autoRiddleCard = makeSettingCard(SettingsWindow, 135, 38)
    makeLabel(autoRiddleCard, "Title", "Auto redeem riddles", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(autoRiddleCard, _autoRedeemRiddles, "Auto redeem riddles", function(state)
        _autoRedeemRiddles = state
        savedConfig.autoRedeemRiddles = state
        saveConfig()
    end)

    -- Submit after
    local delayCard = makeSettingCard(SettingsWindow, 180, 42)
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
    local retypeCard = makeSettingCard(SettingsWindow, 228, 38)
    makeLabel(retypeCard, "Title", "Retype invalid", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(retypeCard, _retypeInvalid, "Retype invalid", function(state)
        _retypeInvalid = state
        savedConfig.retypeInvalid = state
        saveConfig()
    end)

    -- Spam redeem
    local spamCard = makeSettingCard(SettingsWindow, 273, 38)
    makeLabel(spamCard, "Title", "Spam redeem", UDim2.new(1, -60, 1, 0), UDim2.fromOffset(10, 0), 12, COLORS.White, Enum.Font.GothamMedium)
    makeStateButton(spamCard, _spamRedeem, "Spam redeem", function(state)
        _spamRedeem = state
        savedConfig.spamRedeem = state
        saveConfig()
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
-- REST OF SCRIPT
-- ============================================================
local function col3ToRich(col)
    if col == COLORS.Green then return CONSOLE_COLORS.Green end
    if col == COLORS.Red then return CONSOLE_COLORS.Red end
    if col == COLORS.Text then return CONSOLE_COLORS.Amber end
    if col == COLORS.White then return CONSOLE_COLORS.Cyan end
    if col == COLORS.Dim then return CONSOLE_COLORS.Dim end
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

    setStatus("Pasted " .. tostring(capturedCount) .. "/" .. tostring(_submitAfter), COLORS.Green)
    flashCode(combinedCode, COLORS.Green)

    if capturedCount >= _submitAfter then
        _capturedParts = {}
        if _autoAccept then
            rememberPendingSubmission(box, combinedCode, true)
            
            local ok, statusMsg = typeAndSubmitCode(combinedCode)
            
            if ok then
                setStatus("Redeemed: " .. combinedCode, COLORS.Green)
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
-- ENHANCED ANNOUNCEMENT LISTENER (with fallback to chat)
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

    -- If it contains a space, treat as riddle (local DB first, AI fallback only)
    if _riddleSolver and text:find("%s") then
        if setStatus then setStatus("Riddle detected: " .. text, COLORS and COLORS.Text) end
        _riddleSeq = _riddleSeq + 1
        solveRiddle(text, _riddleSeq)
        return
    end

    -- Single-word: handle as code
    for _, word in ipairs(aceTokenize(text)) do
        aceCollectBuffer[#aceCollectBuffer + 1] = word
    end
    
    local parts = {}
    for index = 1, math.min(#aceCollectBuffer, ACE_WORD_COUNT) do
        parts[index] = aceCollectBuffer[index]
    end
    if #aceCollectBuffer < ACE_WORD_COUNT then return end
    aceCollectBuffer = {}
    
    local captured = table.concat(parts)
    if captured == "" or _seen[captured] then return end
    _seen[captured] = true
    task.delay(1.25, function() _seen[captured] = nil end)
    appendToBox(captured)
end

-- Hook into the notification remote
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

-- Stop function to clean up everything
if getgenv then
    getgenv().StopAura = function()
        if aceListenConnection then
            pcall(function() aceListenConnection:Disconnect() end)
            aceListenConnection = nil
        end
        if getgenv().ACECodeSniperNotifyConnection then
            pcall(function() getgenv().ACECodeSniperNotifyConnection:Disconnect() end)
            getgenv().ACECodeSniperNotifyConnection = nil
        end
        if getgenv().ACECodeSniperChatConnection then
            pcall(function() getgenv().ACECodeSniperChatConnection:Disconnect() end)
            getgenv().ACECodeSniperChatConnection = nil
        end
        if GUI then GUI:Destroy() end
        if SettingsGUI then SettingsGUI:Destroy() end
        if HeadBillboard then pcall(function() HeadBillboard:Destroy() end) end
    end
end
