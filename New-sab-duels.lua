-- ============================================================
-- FLUID.VS - COMPLETE
-- Jump drop only (no crasher)
-- TP Bat (TOGGLE - stays on until clicked again)
-- Blossom Reset (player reset)
-- 3-column layout matching image
-- ============================================================

local Players            = game:GetService("Players")
local HttpService        = game:GetService("HttpService")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")

local request = http_request or request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
if not request then return end

local LP = Players.LocalPlayer
if not LP then LP = Players.PlayerAdded:Wait() end

if _G.FluidVS_Running then
    -- already running from an earlier execute: kill the old GUI and reset flags
    pcall(function()
        for _, name in ipairs({"FluidVS", "FluidVSIntro", "FluidVSToasts"}) do
            local a = game:GetService("CoreGui"):FindFirstChild(name); if a then a:Destroy() end
            local b = LP:WaitForChild("PlayerGui"):FindFirstChild(name); if b then b:Destroy() end
        end
    end)
    _G.FluidVS_Running = false
    _G.FluidVS_MainExecuted = false
    task.wait(0.1)
end
_G.FluidVS_Running = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer or Players:WaitForChild("LocalPlayer")

-- ============================================================
-- FIX: Missing variables
-- ============================================================
local DROP_TYPES = {
    JUMP = "jump",
}
local currentDropType = DROP_TYPES.JUMP

-- Create a dummy presetListFrame to avoid nil errors
presetListFrame = Instance.new("Frame")
presetListFrame.Name = "PresetList"
presetListFrame.Size = UDim2.new(0, 0, 0, 0)
presetListFrame.BackgroundTransparency = 1
presetListFrame.Parent = game:GetService("CoreGui")
presetListFrame.Visible = false

-- ============================================================

local _isfile = isfile or (syn and syn.isfile) or (getgenv and getgenv().isfile) or function() return false end
local _readfile = readfile or (syn and syn.readfile) or (getgenv and getgenv().readfile) or function() return nil end
local _writefile = writefile or (syn and syn.writefile) or (getgenv and getgenv().writefile) or function() end
local _delfile = delfile or (syn and syn.delfile) or (getgenv and getgenv().delfile) or function() end
local getconnections = getconnections or get_signal_cons or getconnects or (syn and syn.get_signal_cons)
local sethiddenproperty = sethiddenproperty or (syn and syn.sethiddenproperty) or (getgenv and getgenv().sethiddenproperty) or function() end

-- HTTP request function for webhook
-- Carry settings over from earlier builds (void.cc / Green Duels).
local function _migrateLegacyFile(oldName, newName)
    pcall(function()
        if _isfile(newName) then return end
        if not _isfile(oldName) then return end
        local raw = _readfile(oldName)
        if raw and raw ~= "" then _writefile(newName, raw) end
    end)
end

local _request = request or http_request or (syn and syn.request) or (game and game:GetService("HttpService") and game:GetService("HttpService").RequestAsync) or nil

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
-- BLOSSOM RESET FEATURE
-- ============================================================
local resetRemote = nil
local RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local originalFireServer = nil

local function findResetRemote()
    if resetRemote then return resetRemote end
    for _, descendant in pairs(game:GetDescendants()) do
        if descendant:IsA("RemoteEvent") and descendant.Name:sub(1, 3) == "RE/" then
            resetRemote = descendant
            print("[fluid.vs] Found reset remote:", descendant:GetFullName())
            break
        end
    end
    return resetRemote
end

local o; o = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
    if not resetRemote and self.Name:sub(1, 3) == "RE/" then
        resetRemote = self
        originalFireServer = o
        print("[fluid.vs] Found reset remote via hook:", self:GetFullName())
    end
    return o(self, ...)
end))

local function instaReset()
    findResetRemote()
    if not resetRemote then
        task.wait(0.5)
        findResetRemote()
        if not resetRemote then
            warn("[fluid.vs] Reset remote not found!")
            return
        end
    end
    
    local character = LP.Character
    if not character then 
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        return 
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        return
    end
    
    if humanoid.Health <= 0 then
        pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
        return
    end
    
    local resetDetected = false
    local connections = {}
    table.insert(connections, humanoid.Died:Connect(function() resetDetected = true end))
    table.insert(connections, character.AncestryChanged:Connect(function(_, parent) if not parent then resetDetected = true end end))
    table.insert(connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function() if humanoid.Health <= 0 then resetDetected = true end end))
    
    task.spawn(function()
        local attempts = 0
        while not resetDetected and attempts < 50 do
            attempts = attempts + 1
            pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
            task.wait()
        end
        for _, conn in pairs(connections) do conn:Disconnect() end
        if resetDetected then print("[fluid.vs] Reset successful after", attempts, "attempts")
        else warn("[fluid.vs] No reset detected") end
    end)
end

-- ============================================================
-- BAT MODE  (Cocoa logic - TOGGLE, stays ON until clicked again)
-- Single Heartbeat loop: TP to nearest player, face them, swing.
-- ============================================================
local tpBatToggled = false
local tpBatHittingCooldown = false
local tpBatHRP = nil
local tpBatH = nil
local tpBatConn = nil

local BAT_TP_RANGE = 8      -- studs: only reposition if further than this
local BAT_Y_OFFSET = 0.9    -- sit slightly above the target root
local BAT_COOLDOWN = 0.08   -- seconds between swing attempts

local function getBat()
    local char = LP.Character
    if not char then return nil end
    local tool = char:FindFirstChild("Bat")
    if tool then return tool end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        tool = bp:FindFirstChild("Bat")
        if tool then
            tool.Parent = char
            return tool
        end
    end
    return nil
end

local function tryHitBat()
    if tpBatHittingCooldown then return end
    tpBatHittingCooldown = true
    pcall(function()
        local bat = getBat()
        if bat then
            bat:Activate()
            local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
        end
    end)
    task.delay(BAT_COOLDOWN, function() tpBatHittingCooldown = false end)
end

local function getClosestPlayerForTP()
    if not tpBatHRP then return nil, math.huge end
    local closest, closestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (tpBatHRP.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = p
                end
            end
        end
    end
    return closest, closestDist
end

local function startTPBat()
    if tpBatConn then tpBatConn:Disconnect(); tpBatConn = nil end

    tpBatConn = RunService.Heartbeat:Connect(function()
        if not tpBatToggled then return end

        -- re-acquire the character if it was swapped out
        if not tpBatH or not tpBatHRP then
            local char = LP.Character
            if char then
                tpBatH = char:FindFirstChildOfClass("Humanoid")
                tpBatHRP = char:FindFirstChild("HumanoidRootPart")
            end
            if not tpBatH or not tpBatHRP then return end
        end

        local target = getClosestPlayerForTP()
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                if sethiddenproperty then
                    pcall(function() sethiddenproperty(tpBatHRP, "PhysicsRepRootPart", targetRoot) end)
                end
                local targetPos = targetRoot.Position + Vector3.new(0, BAT_Y_OFFSET, 0)
                if (tpBatHRP.Position - targetPos).Magnitude > BAT_TP_RANGE then
                    tpBatHRP.CFrame = CFrame.new(targetPos)
                end
                local cam = workspace.CurrentCamera
                if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, targetRoot.Position) end
                tryHitBat()
            end
        end
    end)
    print("[fluid.vs] Bat Mode STARTED (toggle ON)")
end

local function stopTPBat()
    if tpBatConn then tpBatConn:Disconnect(); tpBatConn = nil end
    print("[fluid.vs] Bat Mode STOPPED (toggle OFF)")
end

local function toggleTPBat()
    tpBatToggled = not tpBatToggled

    if tpBatToggled then
        local char = LP.Character
        if char then
            tpBatHRP = char:FindFirstChild("HumanoidRootPart")
            tpBatH = char:FindFirstChildOfClass("Humanoid")
        end
        startTPBat()
        if stackBtnRefs and stackBtnRefs.tpBat then
            stackBtnRefs.tpBat.setOn(true)
        end
    else
        stopTPBat()
        if stackBtnRefs and stackBtnRefs.tpBat then
            stackBtnRefs.tpBat.setOn(false)
        end
    end
    requestSave()
end

local function setupTPBatCharacter(char)
    task.wait(0.2)
    tpBatH = char:FindFirstChildOfClass("Humanoid")
    tpBatHRP = char:FindFirstChild("HumanoidRootPart")
    if tpBatToggled then startTPBat() end
end

LP.CharacterAdded:Connect(setupTPBatCharacter)
if LP.Character then task.spawn(function() setupTPBatCharacter(LP.Character) end) end

-- ============================================================
-- CONFIG VERSION & EARLY LOAD
-- ============================================================
local CONFIG_VERSION = 2
local CONFIG_FILE = "fluidvs_v3_config.json"
local CONFIG_BACKUP = "fluidvs_v3_config.bak"
_migrateLegacyFile("voidcc_config.json", CONFIG_FILE)
_migrateLegacyFile("voidcc_config.bak", CONFIG_BACKUP)
_migrateLegacyFile("fluidvs_config.json", CONFIG_FILE)
_migrateLegacyFile("fluidvs_config.bak", CONFIG_BACKUP)

local earlyConfig = nil
local function loadEarlyConfig()
    if not _isfile(CONFIG_FILE) then return nil end
    local raw = _readfile(CONFIG_FILE)
    if not raw then return nil end
    local ok, cfg = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok and cfg and cfg.version == CONFIG_VERSION then return cfg end
    return nil
end
earlyConfig = loadEarlyConfig()
local introShouldPlay = (earlyConfig == nil or earlyConfig.introEnabled ~= false)

-- Intro (skip if disabled) -- classic fluid ring intro, bigger title, new gradient
if introShouldPlay then
    local _TS = TweenService
    local _PG = LP:WaitForChild("PlayerGui")
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "FluidVSIntro"
    introGui.ResetOnSpawn = false
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 999
    introGui.Parent = _PG

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(8,10,15)
    bg.BackgroundTransparency = 0
    bg.BorderSizePixel = 0
    bg.Parent = introGui
    local bgG = Instance.new("UIGradient", bg)
    bgG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12,22,38)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8,10,15)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(4,5,8)),
    })
    bgG.Rotation = 90

    local blur = Instance.new("BlurEffect")
    blur.Size = 14
    blur.Parent = game:GetService("Lighting")

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0,420,0,320)
    container.Position = UDim2.new(0.5,-210,0.5,-160)
    container.BackgroundTransparency = 1
    container.Parent = bg

    local LOGO_ID = "rbxassetid://16478039709"
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({LOGO_ID, "rbxassetid://102729289645203"}) end) end)

    local ring = Instance.new("Frame", container)
    ring.Size = UDim2.new(0,132,0,132)
    ring.Position = UDim2.new(0.5,-66,0,10)
    ring.BackgroundColor3 = Color3.fromRGB(84,196,255)
    ring.BackgroundTransparency = 0.92
    ring.BorderSizePixel = 0
    local rc = Instance.new("UICorner", ring); rc.CornerRadius = UDim.new(0,66)
    local rs = Instance.new("UIStroke", ring); rs.Thickness = 2; rs.Color = Color3.fromRGB(84,196,255); rs.Transparency = 0.3
    local rg = Instance.new("UIGradient", rs)
    rg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120,215,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(58,140,255)),
    })
    task.spawn(function()
        while ring.Parent do
            rg.Rotation = (rg.Rotation + 2.4) % 360
            RunService.RenderStepped:Wait()
        end
    end)

    -- Logo badge: the fluid logo image inside the spinning ring
    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(1,-14,1,-14)
    logo.Position = UDim2.new(0,7,0,7)
    logo.BackgroundTransparency = 1
    logo.Image = LOGO_ID
    logo.ImageColor3 = Color3.fromRGB(255,255,255)
    logo.ImageTransparency = 1
    logo.ScaleType = Enum.ScaleType.Fit
    logo.ZIndex = 2
    logo.Parent = ring
    local lgc = Instance.new("UICorner", logo); lgc.CornerRadius = UDim.new(0,59)

    -- BIG title: taller slot so TextScaled renders way larger than before,
    -- magenta -> violet -> cyan gradient synced with the GUI title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,76)
    title.Position = UDim2.new(0,0,0,158)
    title.BackgroundTransparency = 1
    title.Text = "fluid.vs"
    title.TextColor3 = Color3.fromRGB(245,250,255)
    title.TextTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeTransparency = 1
    title.Parent = container
    local titleGrad = Instance.new("UIGradient", title)
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,105,240)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170,130,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60,205,255)),
    })
    titleGrad.Rotation = 15
    task.spawn(function()
        while title.Parent do
            titleGrad.Offset = Vector2.new(math.sin(tick() * 1.4) * 0.25, 0)
            RunService.RenderStepped:Wait()
        end
    end)

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(0.8,0,0,24)
    sub.Position = UDim2.new(0.1,0,0,242)
    sub.BackgroundTransparency = 1
    sub.Text = "DUELS EDITION"
    sub.TextColor3 = Color3.fromRGB(96,190,235)
    sub.TextTransparency = 1
    sub.TextScaled = true
    sub.Font = Enum.Font.GothamBold
    sub.Parent = container

    local loadingBg = Instance.new("Frame")
    loadingBg.Size = UDim2.new(0.6,0,0,5)
    loadingBg.Position = UDim2.new(0.2,0,0,284)
    loadingBg.BackgroundColor3 = Color3.fromRGB(22,30,44)
    loadingBg.BorderSizePixel = 0
    loadingBg.Parent = container
    Instance.new("UICorner", loadingBg).CornerRadius = UDim.new(1,0)

    local loadingBar = Instance.new("Frame")
    loadingBar.Size = UDim2.new(0,0,1,0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingBg
    Instance.new("UICorner", loadingBar).CornerRadius = UDim.new(1,0)
    local lbGrad = Instance.new("UIGradient", loadingBar)
    lbGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,105,240)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170,130,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60,205,255)),
    })

    _TS:Create(logo, TweenInfo.new(0.9, Enum.EasingStyle.Back), {ImageTransparency = 0}):Play()
    _TS:Create(title, TweenInfo.new(0.9), {TextTransparency = 0}):Play()
    _TS:Create(sub, TweenInfo.new(0.9), {TextTransparency = 0.25}):Play()
    _TS:Create(loadingBar, TweenInfo.new(2, Enum.EasingStyle.Linear), {Size = UDim2.new(1,0,1,0)}):Play()
    task.wait(2.6)
    _TS:Create(bg, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
    _TS:Create(ring, TweenInfo.new(0.9), {BackgroundTransparency = 1, Size = UDim2.new(0,240,0,240), Position = UDim2.new(0.5,-120,0,-30)}):Play()
    pcall(function() _TS:Create(rs, TweenInfo.new(0.9), {Transparency = 1}):Play() end)
    _TS:Create(logo, TweenInfo.new(0.9), {ImageTransparency = 1}):Play()
    _TS:Create(title, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
    _TS:Create(sub, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
    _TS:Create(loadingBg, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
    _TS:Create(loadingBar, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
    task.wait(1.1)
    introGui:Destroy()
    blur:Destroy()
end

-- ============================================================
-- INFINITE JUMP (platform-based version)
-- ============================================================
local InfJumpPlatform = nil

local function CreateIJP()
    if InfJumpPlatform then return end
    InfJumpPlatform = Instance.new("Part")
    InfJumpPlatform.Name = "InfJumpPlatform"
    InfJumpPlatform.Size = Vector3.new(8, 0.5, 8)
    InfJumpPlatform.Anchored = true
    InfJumpPlatform.CanCollide = true
    InfJumpPlatform.Transparency = 1
    InfJumpPlatform.Material = Enum.Material.ForceField
    InfJumpPlatform.Parent = workspace
end

CreateIJP()

-- ============================================================
-- STATE
-- ============================================================
local State = {
    normalSpeed=60, carrySpeed=30, laggerSpeed=10.1, laggerCarrySpeed=15,
    speedToggled=false,
    laggerMode=0,
    infJumpEnabled=true, antiRagdollEnabled=false,
    guiVisible=true, uiLocked=false,
    isStealing=false, stealStartTime=nil, lastStealTick=0,
    autoLeftEnabled=false, autoRightEnabled=false,
    autoLeftPhase=1, autoRightPhase=1,
    medusaLastUsed=0, medusaDebounce=false, medusaCounterEnabled=false,
    batAimbotToggled=false, autoSwingEnabled=false,
    hittingCooldown=false,
    batCounterEnabled=false, batCounterDebounce=false,
    dropEnabled=false, _tpInProgress=false,
    lastMoveDir=Vector3.new(0,0,0),
    _prevCarry=30, _prevSpeed=false,
    stackButtonsHidden=false,
    countdownActive=false,
    stackButtonsLocked=false,
    nukeOpt=false,
    removeAcc=false,
    antiLagEnabled=false,
    stretchedResEnabled=false,
    stretchFOV=120,
    activeSky=nil,
    activeAnimPack=nil,
    tryardAnimEnabled=false,
    introEnabled=true,
    chromaEnabled=false,
    korbloxLeftEnabled=false, korbloxRightEnabled=false,
    autoTPEnabled=false,
    autoTPHeight=20,
    autoTPConn=nil,
    autoCarryEnabled=false,
    _autoCarryFromSteal=false, _autoCarryGraceUntil=0,
    _waitingForCarryPickup=false, _carryPickupWatchUntil=0,
    _autoCarryReturnMode=nil,
}

if earlyConfig and earlyConfig.introEnabled ~= nil then
    State.introEnabled = earlyConfig.introEnabled
end

local Keys = {
    speed=Enum.KeyCode.Q, guiHide=Enum.KeyCode.LeftControl,
    autoLeft=Enum.KeyCode.L, autoRight=Enum.KeyCode.R,
    lagger=Enum.KeyCode.Unknown,
    tpDown=Enum.KeyCode.T,
    drop=Enum.KeyCode.H, aimbot=Enum.KeyCode.Unknown,
    tpBat=Enum.KeyCode.X, reset=Enum.KeyCode.R,
    autoCarry=Enum.KeyCode.C,
}

-- ============================================================
-- INFINITE JUMP PLATFORM LOGIC
-- ============================================================
RunService.Heartbeat:Connect(function()
    if not State.infJumpEnabled then 
        if InfJumpPlatform then
            InfJumpPlatform.Position = Vector3.new(0, -1000, 0)
        end
        return 
    end
    
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and root and hum) then 
        if InfJumpPlatform then
            InfJumpPlatform.Position = Vector3.new(0, -1000, 0)
        end
        return 
    end

    local isJumping = UIS:IsKeyDown(Enum.KeyCode.Space)
        or hum:GetState() == Enum.HumanoidStateType.Jumping
        or hum.Jump

    if isJumping then
        if not InfJumpPlatform then CreateIJP() end
        InfJumpPlatform.Position = root.Position - Vector3.new(0, 3.5, 0)
        if root.Velocity.Y < 50 then
            root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
        end
    else
        if InfJumpPlatform then
            InfJumpPlatform.Position = Vector3.new(0, -1000, 0)
        end
    end
end)

-- ============================================================
-- TRYARD ANIMATION PACK
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
local function startTryardAnim()
    if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect() end
    local char = LP.Character
    if char then
        saveOriginalTryardAnims(char)
        applyTryardAnimPack(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
    tryardHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not State.tryardAnimEnabled then return end
        local c = LP.Character
        if c then applyTryardAnimPack(c) end
    end)
end
LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if State.tryardAnimEnabled and tryardHeartbeatConn then
        saveOriginalTryardAnims(char)
        applyTryardAnimPack(char)
    end
end)

-- ============================================================
-- DEFAULT STACK BUTTON POSITIONS (3 Columns)
-- ============================================================
local BTN_W = 58
local BTN_H = 58
local BTN_GAP = 8
local COLS = 3

local stackDefs = {
    {key="drop",        label="DROP"},
    {key="tpBat",       label="BAT\nMODE"},
    {key="autoLeft",    label="AUTO\nLEFT"},
    {key="autoRight",   label="AUTO\nRIGHT"},
    {key="aimbot",      label="AIMBOT"},
    {key="tpDown",      label="TP\nDOWN"},
    {key="carrySpeed",  label="CARRY\nSPD"},
    {key="reset",       label="RESET"},
    {key="lagger",      label="LAGGER"},
    {key="laggerCarry", label="LAGGER\nCARRY"},
}

local function getDefaultStackPos(i)
    local col = (i-1) % COLS
    local row = math.floor((i-1) / COLS)
    local totalRows = math.ceil(#stackDefs / COLS)
    return UDim2.new(
        1, -(COLS * (BTN_W + BTN_GAP) - BTN_GAP + 14) + col * (BTN_W + BTN_GAP),
        0.5, -(totalRows * (BTN_H + BTN_GAP) - BTN_GAP) / 2 + row * (BTN_H + BTN_GAP)
    )
end

local Steal = { AutoStealEnabled=true, StealRadius=55, StealDuration=0.25, Data={} }

-- ============================================================
-- PRESETS
-- ============================================================
local Presets = {}
local PRESET_FILE = "fluidvs_v3_presets.json"
local LAST_PRESET_FILE = "fluidvs_v3_lastpreset.json"
_migrateLegacyFile("voidcc_presets.json", PRESET_FILE)
_migrateLegacyFile("voidcc_lastpreset.json", LAST_PRESET_FILE)
_migrateLegacyFile("fluidvs_presets.json", PRESET_FILE)
_migrateLegacyFile("fluidvs_lastpreset.json", LAST_PRESET_FILE)

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

-- Auto Left/Right positions
local AP_L1     = Vector3.new(-476.48, -6.28, 92.73)
local AP_L2     = Vector3.new(-483.12, -4.95, 94.80)
local AP_L_FACE = Vector3.new(-482.25, -4.96, 92.09)
local AP_R1     = Vector3.new(-476.16, -6.52, 25.62)
local AP_R2     = Vector3.new(-483.06, -5.03, 25.48)
local AP_R_FACE = Vector3.new(-482.06, -6.93, 35.47)

local alConn, arConn = nil, nil
local alPhase, arPhase = 1, 1

local Conns={autoSteal=nil,antiRag=nil,autoLeft=nil,autoRight=nil,aimbot=nil,anchor={},progress=nil,batCounter=nil, autoTP=nil}
local h,hrp
local setAutoLeft,setAutoRight,setInfJump,setAntiRag
local setMedusaCounter,setAimbot,setAutoSwing
local setLagger,setLaggerCarry,setDropBrainrot,setInstaGrab
local setNukeOpt,setRemoveAcc,setNoCam
local setupMedusaCounter,stopMedusaCounter,startAntiRagdoll,stopAntiRagdoll
local startAutoSteal,stopAutoSteal
local startAutoLeft,stopAutoLeft,startAutoRight,stopAutoRight
local saveConfig,loadConfig,runDrop,stopDrop,runTPDown
local requestSave
local startBatAimbot,stopBatAimbot,startBatCounter,stopBatCounter,setBatCounter
local stackBtnRefs={}; local stackWrappers={}; local keybindBtnRefs={}
local normalBox,carryBox,laggerBox,laggerCarryBox,uiScaleBox,stealRadBox,stealDurBox,autoTPHeightBox
local setHideButtonsToggle, setLockButtonsToggle
local presetListFrame=nil; local presetNameBox=nil; local rebuildPresetList
local animTabBtns={}
local refreshAnimButtons=nil
local toggleSetters = {}

-- ============================================================
-- COLORS (azure-glass theme)
-- ============================================================
local C = {
    accent      = Color3.fromRGB(84,196,255),
    accentDim   = Color3.fromRGB(58,120,170),
    strokeHi    = Color3.fromRGB(150,215,255),

    rowBg       = Color3.fromRGB(16,21,29),
    rowHov      = Color3.fromRGB(21,28,38),
    rowBorder   = Color3.fromRGB(40,58,80),
    rowLabel    = Color3.fromRGB(235,244,255),

    sectionTxt  = Color3.fromRGB(120,215,255),
    sectionDiv  = Color3.fromRGB(45,70,100),

    inputBg     = Color3.fromRGB(12,17,24),
    inputBorder = Color3.fromRGB(45,65,90),
    inputFocus  = Color3.fromRGB(84,196,255),
    inputTxt    = Color3.fromRGB(245,250,255),

    chipBg      = Color3.fromRGB(14,19,27),
    chipBorder  = Color3.fromRGB(45,65,90),
    chipTxt     = Color3.fromRGB(235,244,255),

    btnBg       = Color3.fromRGB(22,29,40),
    btnHov      = Color3.fromRGB(30,40,56),
    btnBorder   = Color3.fromRGB(45,65,90),
    btnTxt      = Color3.fromRGB(235,244,255),

    modeBtnBg   = Color3.fromRGB(18,24,33),
    modeBtnBrd  = Color3.fromRGB(45,65,90),
    modeBtnTxt  = Color3.fromRGB(200,220,240),
    modeBtnActBg= Color3.fromRGB(84,196,255),
    modeBtnActTx= Color3.fromRGB(8,14,20),

    stackTxt    = Color3.fromRGB(245,250,255),
    stackBrd    = Color3.fromRGB(45,65,90),
    stackDot    = Color3.fromRGB(84,196,255),
    stackActTxt = Color3.fromRGB(10,16,22),
    stackActBrd = Color3.fromRGB(120,215,255),

    dotOn       = Color3.fromRGB(84,196,255),
    dotOff      = Color3.fromRGB(60,70,85),

    infoBg      = Color3.fromRGB(12,17,24),
    infoBrd     = Color3.fromRGB(45,65,90),
    infoTxt     = Color3.fromRGB(160,190,220),
    infoVal     = Color3.fromRGB(245,250,255),
    infoFill    = Color3.fromRGB(84,196,255),

    presetBg    = Color3.fromRGB(18,24,33),
    presetBrd   = Color3.fromRGB(45,65,90),
    presetDel   = Color3.fromRGB(255,120,120),
    presetLoad  = Color3.fromRGB(84,196,255),

    tabBarBg    = Color3.fromRGB(12,16,23),
    tabBarDiv   = Color3.fromRGB(35,50,70),
    tabIdle     = Color3.fromRGB(110,135,160),
    tabIdleHov  = Color3.fromRGB(170,200,230),
    tabActive   = Color3.fromRGB(245,250,255),
    tabActiveBg = Color3.fromRGB(26,34,46),
    tabUnderline= Color3.fromRGB(84,196,255),

    topTitle    = Color3.fromRGB(245,250,255),
    topSub      = Color3.fromRGB(96,180,255),
    topDivider  = Color3.fromRGB(40,58,80),
    topBtn      = Color3.fromRGB(22,29,40),
}

-- ============================================================
-- UI HELPERS
-- ============================================================
local function mkCorner(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 6); return c end
local function mkStroke(p,col,th) local st=Instance.new("UIStroke",p); st.Color=col; st.Thickness=th or 1; st.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return st end

-- UIGradient multiplies the parent's BackgroundColor3, so the parent must be
-- near-white for the ramp to be visible; the gradient itself carries the tone.
local function mkGrad(p, top, bottom, rot)
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, top),
        ColorSequenceKeypoint.new(1, bottom),
    })
    g.Rotation = rot or 90
    return g
end

-- Subtle vertical sheen: pure white at the top fading down, multiplied over
-- whatever BackgroundColor3 the control already has (tweens keep working),
-- so any flat button or toggle row instantly gets a gradient-glass look.
local function mkSheen(p, lo)
    lo = lo or 0.8
    local g = Instance.new("UIGradient", p)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(lo,lo,lo)),
    })
    g.Rotation = 90
    return g
end

-- Shared backdrop artwork for the floating controls.
local UI_ASSET      = "rbxassetid://102729289645203"
local UI_ART_IDLE   = 0.80   -- ImageTransparency when the control is dark
local UI_ART_ACTIVE = 0.88   -- fainter when the control turns active

-- Adds the artwork as a child ImageLabel. Caller gives the caption a higher
-- ZIndex so it still sits on top (siblings sort by ZIndex).
local function mkBackdrop(parent, radius, zindex)
    local img = Instance.new("ImageLabel", parent)
    img.Name = "Backdrop"
    img.Size = UDim2.new(1,0,1,0)
    img.BackgroundTransparency = 1
    img.BorderSizePixel = 0
    img.Image = UI_ASSET
    img.ImageTransparency = UI_ART_IDLE
    img.ScaleType = Enum.ScaleType.Crop
    img.ZIndex = zindex or 1
    local c = Instance.new("UICorner", img)
    c.CornerRadius = UDim.new(0, radius or 12)
    return img
end

-- Fake blur-shadow: n dark rounded frames as SIBLINGS of the target, so
-- they live in the exact same coordinate space (no inset/scale mismatch).
-- Center-anchored expansion = perfectly even halo on every side, and the
-- layers copy Rotation so the drag wobble lines up too.
local function mkShadow(gui, frame, radius, n)
    n = n or 3
    local parent = frame.Parent or gui
    local layers = {}
    for i = 1, n do
        local sh = Instance.new("Frame", parent)
        sh.AnchorPoint = Vector2.new(0.5, 0.5)
        sh.BackgroundColor3 = Color3.fromRGB(0,0,0)
        sh.BackgroundTransparency = math.clamp(0.82 + i * 0.04, 0, 1)
        sh.BorderSizePixel = 0
        sh.ZIndex = (frame.ZIndex or 1) - 1
        sh.Visible = frame.Visible
        mkCorner(sh, (radius or 10) + i)
        table.insert(layers, sh)
    end
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not frame or not frame.Parent then
            if conn then conn:Disconnect() end
            for _, sh in ipairs(layers) do pcall(function() sh:Destroy() end) end
            return
        end
        local fp, fs, ap = frame.Position, frame.Size, frame.AnchorPoint
        local cx = UDim.new(fp.X.Scale + fs.X.Scale * (0.5 - ap.X), fp.X.Offset + fs.X.Offset * (0.5 - ap.X))
        local cy = UDim.new(fp.Y.Scale + fs.Y.Scale * (0.5 - ap.Y), fp.Y.Offset + fs.Y.Offset * (0.5 - ap.Y))
        local vis, rot = frame.Visible, frame.Rotation
        for i, sh in ipairs(layers) do
            sh.Visible = vis
            sh.Rotation = rot
            sh.Position = UDim2.new(cx, cy)
            sh.Size = UDim2.new(fs.X.Scale, fs.X.Offset + i * 2, fs.Y.Scale, fs.Y.Offset + i * 2)
        end
    end)
    return layers
end

-- Click ripple: a quick expanding flash circle inside the pressed control.
local function mkRipple(btn, size)
    local d = size or 26
    local r = Instance.new("Frame", btn)
    r.AnchorPoint = Vector2.new(0.5, 0.5)
    r.Position = UDim2.new(0.5, 0, 0.5, 0)
    r.Size = UDim2.new(0, 0, 0, 0)
    r.BackgroundColor3 = Color3.fromRGB(140,220,255)
    r.BackgroundTransparency = 0.55
    r.BorderSizePixel = 0
    r.ZIndex = btn.ZIndex or 1
    mkCorner(r, math.floor(d / 2))
    TweenService:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, d, 0, d),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.5, function() pcall(function() r:Destroy() end) end)
end

-- Gradient ramps (kept together so the look is easy to retune)
local GRAD = {
    idleTop  = Color3.fromRGB(44,56,74),   idleBot  = Color3.fromRGB(22,28,40),
    hovTop   = Color3.fromRGB(60,78,104),  hovBot   = Color3.fromRGB(30,40,56),
    onTop    = Color3.fromRGB(120,215,255), onBot  = Color3.fromRGB(58,140,255),
}

-- ============================================================
-- CHROMA MODE (animated RGB accents)
-- ============================================================
local chromaGrads = {}
local chromaColorItems = {}
local chromaStrokeItems = {}
local chromaConn = nil

local function registerChromaGrad(g)
    if not g then return end
    for _, x in ipairs(chromaGrads) do if x == g then return end end
    table.insert(chromaGrads, g)
end
local function unregisterChromaGrad(g)
    for i, x in ipairs(chromaGrads) do
        if x == g then table.remove(chromaGrads, i) break end
    end
end
local function registerChromaColor(obj, prop, base, alt)
    for _, it in ipairs(chromaColorItems) do if it.obj == obj then return end end
    table.insert(chromaColorItems, {obj = obj, prop = prop, base = base, alt = alt})
end
local function unregisterChromaColor(obj)
    for i, it in ipairs(chromaColorItems) do
        if it.obj == obj then table.remove(chromaColorItems, i) break end
    end
end
local function registerChromaStroke(st, onT, offT, onTh, offTh)
    if not st then return end
    table.insert(chromaStrokeItems, {s = st, onT = onT, offT = offT, onTh = onTh, offTh = offTh})
end

local function startChromaLoop()
    if chromaConn then chromaConn:Disconnect(); chromaConn = nil end
    for _, it in ipairs(chromaStrokeItems) do
        pcall(function()
            if it.onT then it.s.Transparency = it.onT end
            if it.onTh then it.s.Thickness = it.onTh end
        end)
    end
    chromaConn = RunService.RenderStepped:Connect(function()
        if not State.chromaEnabled then return end
        local t = tick() * 0.10
        local c1 = Color3.fromHSV(t % 1, 0.55, 1)
        local c2 = Color3.fromHSV((t + 0.14) % 1, 0.65, 1)
        local seq = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        })
        for _, g in ipairs(chromaGrads) do
            pcall(function() g.Color = seq end)
        end
        for _, it in ipairs(chromaColorItems) do
            pcall(function() it.obj[it.prop] = it.alt and c2 or c1 end)
        end
    end)
end

local function stopChromaLoop()
    if chromaConn then chromaConn:Disconnect(); chromaConn = nil end
    local def = ColorSequence.new({
        ColorSequenceKeypoint.new(0, GRAD.onTop),
        ColorSequenceKeypoint.new(1, GRAD.onBot),
    })
    for _, g in ipairs(chromaGrads) do pcall(function() g.Color = def end) end
    for _, it in ipairs(chromaColorItems) do pcall(function() it.obj[it.prop] = it.base end) end
    for _, it in ipairs(chromaStrokeItems) do
        pcall(function()
            if it.offT then it.s.Transparency = it.offT end
            if it.offTh then it.s.Thickness = it.offTh end
        end)
    end
end


-- ============================================================
-- AUTO TP
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
    return true
end

local function startAutoTP()
    if State.autoTPConn then task.cancel(State.autoTPConn); State.autoTPConn = nil end
    State.autoTPConn = task.spawn(function()
        local firedOnce = false
        while State.autoTPEnabled do
            task.wait(0.1)
            local tp = false
            pcall(function() tp = doAutoTPDown(false) end)
            if tp and not firedOnce then
                firedOnce = true
            elseif not tp then
                firedOnce = false
            end
        end
    end)
end

local function stopAutoTP()
    State.autoTPEnabled = false
    if State.autoTPConn then task.cancel(State.autoTPConn); State.autoTPConn = nil end
end

runTPDown = function()
    local tp = false
    pcall(function() tp = doAutoTPDown(true) end)
end

-- ============================================================
-- JUMP DROP ONLY (Safe - No Crasher)
-- ============================================================
local DROP_ASCEND_DURATION = 0.22
local DROP_ASCEND_SPEED = 160
local _dropConn = nil
local dropActive = false

local function runJumpDrop()
    if dropActive then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    dropActive = true
    if stackBtnRefs.drop then stackBtnRefs.drop.setOn(true) end
    local t0 = tick()
    if _dropConn then _dropConn:Disconnect() end
    _dropConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            dropActive = false
            if stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
            return
        end
        if not dropActive then
            if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
            if stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
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
            if stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
            return
        end
        local lv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = Vector3.new(lv.X, DROP_ASCEND_SPEED, lv.Z)
    end)
end

runDrop = runJumpDrop

LP.CharacterRemoving:Connect(function()
    dropActive = false
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
end)

stopDrop = function()
    dropActive = false
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
    if stackBtnRefs.drop then stackBtnRefs.drop.setOn(false) end
end

-- ============================================================
-- ANTI RAGDOLL (Ace logic: Heartbeat + Motor6D re-enable)
-- ============================================================
local antiRagdollConn = nil

startAntiRagdoll = function()
    if antiRagdollConn then return end
    antiRagdollConn = RunService.Heartbeat:Connect(function()
        if not State.antiRagdollEnabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local ragdolled = (
            s == Enum.HumanoidStateType.Physics
            or s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown
        )
        local endTime = LP:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
            ragdolled = true
        end
        if ragdolled then
            pcall(function()
                LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
            end)
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                    pcall(function() d:Destroy() end)
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

stopAntiRagdoll = function()
    if antiRagdollConn then
        antiRagdollConn:Disconnect()
        antiRagdollConn = nil
    end
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if State.antiRagdollEnabled then
        if not antiRagdollConn then
            startAntiRagdoll()
        end
    end
end)

-- ============================================================
-- KORBLOX LEGS (client-side appearance)
-- ============================================================
local KORBLOX_LEFT_LEG_ID = 139607673
local KORBLOX_RIGHT_LEG_ID = 139607718

-- per-side swap tracking so legs can be cleanly restored
local korbloxSwapData = { Left = {}, Right = {} }

local function disableKorbloxLeg(side)
    for _, swap in ipairs(korbloxSwapData[side]) do
        if swap.clonedPart then pcall(function() swap.clonedPart:Destroy() end) end
        if swap.motor then pcall(function() swap.motor.Enabled = true end) end
        if swap.oldPart then pcall(function() swap.oldPart.Transparency = 0; swap.oldPart.CanCollide = true end) end
    end
    korbloxSwapData[side] = {}
end

local function enableKorbloxLeg(side)
    local character = LP.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then return end
    local assetId = (side == "Left") and KORBLOX_LEFT_LEG_ID or KORBLOX_RIGHT_LEG_ID
    local success, result = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if not success or not result or #result == 0 then return end
    local rootModel = result[1]
    -- the asset holds MeshParts (e.g. RightUpperLeg/LowerLeg/Foot); clone each
    -- in, rebuild its Motor6D onto the rig, hide the original limb part
    local partNames = { side .. "UpperLeg", side .. "LowerLeg", side .. "Foot" }
    local replaced, swaps = {}, {}
    for _, partName in ipairs(partNames) do
        local newPart = nil
        if rootModel:IsA("BasePart") and rootModel.Name == partName then
            newPart = rootModel
        else
            newPart = rootModel:FindFirstChild(partName, true)
        end
        local oldPart = (newPart and newPart:IsA("BasePart")) and character:FindFirstChild(partName) or nil
        if oldPart and oldPart:IsA("BasePart") then
            local motor = nil
            for _, child in ipairs(oldPart:GetChildren()) do
                if child:IsA("Motor6D") and child.Part1 == oldPart then motor = child break end
            end
            if motor then
                local clonedPart = newPart:Clone()
                clonedPart.CFrame = oldPart.CFrame
                clonedPart.Parent = character
                -- if the parent limb above was already swapped this pass,
                -- weld to the new one instead of the hidden original
                local part0 = motor.Part0
                if part0 and replaced[part0.Name] then part0 = replaced[part0.Name] end
                local newMotor = Instance.new("Motor6D")
                newMotor.Name = motor.Name
                newMotor.Part0 = part0
                newMotor.Part1 = clonedPart
                newMotor.C0 = motor.C0
                newMotor.C1 = motor.C1
                newMotor.Parent = clonedPart
                motor.Enabled = false
                oldPart.Transparency = 1
                oldPart.CanCollide = false
                replaced[partName] = clonedPart
                table.insert(swaps, { oldPart = oldPart, motor = motor, clonedPart = clonedPart })
            end
        end
    end
    korbloxSwapData[side] = swaps
end

-- respawn wipes transparency + swapped parts, so re-apply whatever was on
LP.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    korbloxSwapData = { Left = {}, Right = {} }
    if State.korbloxLeftEnabled then pcall(function() enableKorbloxLeg("Left") end) end
    if State.korbloxRightEnabled then pcall(function() enableKorbloxLeg("Right") end) end
end)

-- ============================================================
-- ANIMATION PACKS (client-side, ids cleaned: zero-id placeholders removed)
-- ============================================================
local ANIM_PACKS = {
    {name="Anthro (Default)", idle1="2510196951", idle2="2510197257", walk="2510202577", run="2510198475", jump="2510197830", climb="2510192778", fall="2510195892"},
    {name="Astronaut", idle1="891621366", idle2="891633237", walk="891667138", run="891636393", jump="891627522", climb="891609353", fall="891617961"},
    {name="Bubbly", idle1="910004836", idle2="910009958", walk="910034870", run="910025107", jump="910016857", fall="910001910", swimIdle="910030921", swim="910028158"},
    {name="Cartoony", idle1="742637544", idle2="742638445", walk="742640026", run="742638842", jump="742637942", climb="742636889", fall="742637151"},
    {name="Confident", idle1="1069977950", idle2="1069987858", walk="1070017263", run="1070001516", jump="1069984524", climb="1069946257", fall="1069973677"},
    {name="Cowboy", idle1="1014390418", idle2="1014398616", walk="1014421541", run="1014401683", jump="1014394726", climb="1014380606", fall="1014384571"},
    {name="Elder", idle1="845397899", idle2="845400520", walk="845403856", run="845386501", jump="845398858", climb="845392038", fall="845396048"},
    {name="Ghost", idle1="616006778", idle2="616008087", walk="616013216", run="616013216", jump="616008936", fall="616005863", swimIdle="616012453", swim="616011509"},
    {name="Knight", idle1="657595757", idle2="657568135", walk="657552124", run="657564596", jump="658409194", climb="658360781", fall="657600338"},
    {name="Levitation", idle1="616006778", idle2="616008087", walk="616013216", run="616010382", jump="616008936", climb="616003713", fall="616005863"},
    {name="Mage", idle1="707742142", idle2="707855907", walk="707897309", run="707861613", jump="707853694", climb="707826056", fall="707829716"},
    {name="Ninja", idle1="656117400", idle2="656118341", walk="656121766", run="656118852", jump="656117878", climb="656114359", fall="656115606"},
    {name="Patrol", idle1="1149612882", idle2="1150842221", walk="1151231493", run="1150967949", jump="1148811837", climb="1148811837", fall="1148863382"},
    {name="Pirate", idle1="750781874", idle2="750782770", walk="750785693", run="750783738", jump="750782230", climb="750779899", fall="750780242"},
    {name="Popstar", idle1="1212900985", idle2="1150842221", walk="1212980338", run="1212980348", jump="1212954642", climb="1213044953", fall="1212900995"},
    {name="Princess", idle1="941003647", idle2="941013098", walk="941028902", run="941015281", jump="941008832", climb="940996062", fall="941000007"},
    {name="Robot", idle1="616088211", idle2="616089559", walk="616095330", run="616091570", jump="616090535", climb="616086039", fall="616087089"},
    {name="Sneaky", idle1="1132473842", idle2="1132477671", walk="1132510133", run="1132494274", jump="1132489853", climb="1132461372", fall="1132469004"},
    {name="Stylish", idle1="616136790", idle2="616138447", walk="616146177", run="616140816", jump="616139451", climb="616133594", fall="616134815"},
    {name="SuperHero", idle1="616111295", idle2="616113536", walk="616122287", run="616117076", jump="616115533", climb="616104706", fall="616108001"},
    {name="Toy", idle1="782841498", idle2="782845736", walk="782843345", run="782842708", jump="782847020", climb="782843869", fall="782846423"},
    {name="unwalk", blank=true, idle1="0", idle2="0", walk="0", run="0", jump="0", climb="0", fall="0", swimIdle="0", swim="0"},
    {name="Vampire", idle1="1083445855", idle2="1083450166", walk="1083473930", run="1083462077", jump="1083455352", climb="1083439238", fall="1083443587"},
    {name="Werewolf", idle1="1083195517", idle2="1083214717", walk="1083178339", run="1083216690", jump="1083218792", climb="1083182000", fall="1083189019"},
    {name="Zombie", idle1="616158929", idle2="616160636", walk="616168032", run="616163682", jump="616161997", climb="616156119", fall="616157476"},
}

local function findAnimPack(name)
    for _, pack in ipairs(ANIM_PACKS) do
        if pack.name == name then return pack end
    end
    return nil
end

-- capture the default animation ids once per character life so the
-- "Restore Default Animations" button can genuinely put them back
local originalAnimIds = nil
local _animSlots = {
    {"idle","Animation1"},{"idle","Animation2"},
    {"walk","WalkAnim"},{"run","RunAnim"},{"jump","JumpAnim"},
    {"climb","ClimbAnim"},{"fall","FallAnim"},
    {"swimidle","SwimIdle"},{"swim","Swim"},
}
local function captureOriginalAnims(char)
    local animate = char and char:FindFirstChild("Animate")
    if not animate then return nil end
    local orig = {}
    for _, s in ipairs(_animSlots) do
        local c = animate:FindFirstChild(s[1])
        local a = c and c:FindFirstChild(s[2])
        if a then orig[s[1].."/"..s[2]] = a.AnimationId end
    end
    return orig
end

local function applyAnimPack(pack)
    local char = LP.Character
    if not char then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    if not originalAnimIds then originalAnimIds = captureOriginalAnims(char) end
    task.spawn(function()
        local function setSlot(container, name, id)
            local c = animate:FindFirstChild(container)
            local a = c and c:FindFirstChild(name)
            if a and id and (id ~= "0" or pack.blank) then
                a.AnimationId = "http://www.roblox.com/asset/?id=" .. id
            end
        end
        setSlot("idle", "Animation1", pack.idle1)
        setSlot("idle", "Animation2", pack.idle2)
        setSlot("walk", "WalkAnim", pack.walk)
        setSlot("run", "RunAnim", pack.run)
        setSlot("jump", "JumpAnim", pack.jump)
        setSlot("climb", "ClimbAnim", pack.climb)
        setSlot("fall", "FallAnim", pack.fall)
        if pack.swimIdle then setSlot("swimidle", "SwimIdle", pack.swimIdle) end
        if pack.swim then setSlot("swim", "Swim", pack.swim) end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = true
            task.wait(0.05)
            humanoid.Jump = false
        end
    end)
end

local function restoreOriginalAnims()
    local char = LP.Character
    if not (char and originalAnimIds) then return end
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    task.spawn(function()
        for key, id in pairs(originalAnimIds) do
            local slot, name = key:match("^(.-)/(.+)$")
            local c = slot and animate:FindFirstChild(slot)
            local a = c and c:FindFirstChild(name)
            if a then a.AnimationId = id end
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = true
            task.wait(0.05)
            humanoid.Jump = false
        end
    end)
end

LP.CharacterAdded:Connect(function(char)
    originalAnimIds = nil
    task.wait(0.8)
    if State.activeAnimPack then
        local pk = findAnimPack(State.activeAnimPack)
        if pk then pcall(function() applyAnimPack(pk) end) end
    end
end)

-- ============================================================
-- MAIN FUNCTION (UI and everything else)
-- ============================================================

local function Main()
    if _G.FluidVS_MainExecuted then return end
    _G.FluidVS_MainExecuted = true

    local gui=Instance.new("ScreenGui")
    gui.Name="FluidVS"; gui.ResetOnSpawn=false; gui.DisplayOrder=10
    gui.IgnoreGuiInset=true; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.Parent=LP:WaitForChild("PlayerGui")
    local uiScaleObj=Instance.new("UIScale",gui); uiScaleObj.Scale=1.0

    local function makeDraggable(frame,handle)
        local src=handle or frame
        local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
        src.InputBegan:Connect(function(inp)
            if State.uiLocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=inp.Position; startPos=frame.Position
                TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = (math.random() > 0.5 and 1.4 or -1.4)}):Play()
                inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then
                        dragging=false
                        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                    end
                end)
            end
        end)
        src.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dragInput=inp end
        end)
        UIS.InputChanged:Connect(function(inp)
            if inp==dragInput and dragging and not State.uiLocked then
                local dx=inp.Position.X-dragStart.X; local dy=inp.Position.Y-dragStart.Y
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+dx,startPos.Y.Scale,startPos.Y.Offset+dy)
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

        local lockChangedConn = RunService.Heartbeat:Connect(function()
            movementAllowed = not State.stackButtonsLocked
        end)

        frame.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            wasPressed = true
            pressTime = tick()
            dragStartPos = input.Position
            startPos = frame.Position
            isDragging = true
            movedEnough = false
        end)

        frame.InputChanged:Connect(function(input)
            if not isDragging or not movementAllowed then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStartPos
                if delta.Magnitude > 8 then movedEnough = true end
                if movedEnough then
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)

        frame.InputEnded:Connect(function(input)
            local wasPressedLocal = wasPressed
            wasPressed = false
            if not isDragging then return end
            isDragging = false

            if movedEnough then
                if saveDebounce then task.cancel(saveDebounce) end
                saveDebounce = task.delay(0.2, function()
                    pcall(requestSave)
                    saveDebounce = nil
                end)
            end

            if wasPressedLocal and not movedEnough and (tick() - pressTime) < 0.3 then
                if onTap then onTap() end
            end
        end)

        frame.AncestryChanged:Connect(function()
            if not frame.Parent then lockChangedConn:Disconnect() end
        end)
    end

    local WIN_W = 520
    local WIN_H = 520
    local TITLE_H = 44
    -- Panel backdrop. Swap this id to change the art.
    local BG_ASSET = "rbxassetid://102729289645203"
    local BG_DIM   = 0.62   -- 0 = raw art, 1 = invisible
    task.spawn(function() pcall(function() ContentProvider:PreloadAsync({BG_ASSET}) end) end)
    local mainOuter = Instance.new("Frame", gui)
    mainOuter.Name = "MainOuter"
    mainOuter.Size = UDim2.new(0, WIN_W, 0, WIN_H)
    mainOuter.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
    mainOuter.BackgroundTransparency = 1; mainOuter.BorderSizePixel = 0; mainOuter.ClipsDescendants = true
    mkCorner(mainOuter, 24); makeDraggable(mainOuter)
    mkShadow(gui, mainOuter, 24, 4)
    local winScale = Instance.new("UIScale", mainOuter)
    local _visSeq = 0
    local function showWindow()
        _visSeq = _visSeq + 1
        mainOuter.Visible = true
        winScale.Scale = 0.88
        TweenService:Create(winScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end
    local function hideWindow()
        _visSeq = _visSeq + 1
        local my = _visSeq
        TweenService:Create(winScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {Scale = 0.88}):Play()
        task.delay(0.16, function()
            if my == _visSeq then mainOuter.Visible = false end
            winScale.Scale = 1
        end)
    end
    winScale.Scale = 0.88
    TweenService:Create(winScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    local bgImg = Instance.new("ImageLabel", mainOuter)
    bgImg.Name = "BgFill"; bgImg.Size = UDim2.new(1,0,1,0)
    bgImg.BackgroundColor3 = Color3.fromRGB(0,0,0); bgImg.BackgroundTransparency = 0
    bgImg.BorderSizePixel = 0; bgImg.ZIndex = 0
    bgImg.Image = BG_ASSET
    bgImg.ImageColor3 = Color3.fromRGB(150,185,225)
    bgImg.ImageTransparency = BG_DIM
    bgImg.ScaleType = Enum.ScaleType.Crop      -- fill the panel, keep aspect
    mkCorner(bgImg, 24)
    -- Multiplies the artwork only (black bg stays black): bright at the top,
    -- dimmer at the bottom so long option lists stay legible.
    local mainGrad = Instance.new("UIGradient", bgImg)
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(185,215,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120,150,190))
    })
    mainGrad.Rotation = 90
    local mainStroke = Instance.new("UIStroke", mainOuter)
    mainStroke.Thickness = 1.4; mainStroke.Color = Color3.fromRGB(58,90,130); mainStroke.Transparency = 0.15
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local mainStrokeGrad = Instance.new("UIGradient", mainStroke)
    mainStrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70,120,160)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150,215,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70,120,160))
    })
    task.spawn(function() while mainOuter.Parent do mainStrokeGrad.Rotation = (mainStrokeGrad.Rotation+0.4)%360; RunService.RenderStepped:Wait() end end)

    local accentBar = Instance.new("Frame", mainOuter)
    accentBar.Size = UDim2.new(1, -60, 0, 2); accentBar.Position = UDim2.new(0,30,0,0)
    accentBar.BackgroundColor3 = C.accent; accentBar.BackgroundTransparency = 0.1
    accentBar.BorderSizePixel = 0; accentBar.ZIndex = 6
    mkCorner(accentBar, 2)
    local abGrad = mkGrad(accentBar, GRAD.onTop, GRAD.onBot, 0)
    task.spawn(function()
        while accentBar.Parent do
            abGrad.Offset = Vector2.new((tick() * 0.25) % 1, 0)
            RunService.RenderStepped:Wait()
        end
    end)
    registerChromaGrad(abGrad)
    registerChromaGrad(mainStrokeGrad)

    -- Dedicated chroma edge: while Chroma RGB Mode is on this stroke glows
    -- thick and animated; when it is off it falls back to the normal GUI
    -- theme colors (azure gradient, subtle transparency).
    local chromaEdge = Instance.new("UIStroke", mainOuter)
    chromaEdge.Name = "ChromaEdge"
    chromaEdge.Thickness = 2.2
    chromaEdge.Color = GRAD.onTop
    chromaEdge.Transparency = 0.55
    chromaEdge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local chromaEdgeGrad = Instance.new("UIGradient", chromaEdge)
    chromaEdgeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, GRAD.onTop),
        ColorSequenceKeypoint.new(1, GRAD.onBot),
    })
    task.spawn(function() while mainOuter.Parent do chromaEdgeGrad.Rotation = (chromaEdgeGrad.Rotation+1.6)%360; RunService.RenderStepped:Wait() end end)
    registerChromaGrad(chromaEdgeGrad)
    registerChromaStroke(chromaEdge, 0, 0.55, 2.6, 2.2)

    local titleBar = Instance.new("Frame", mainOuter)
    titleBar.Size = UDim2.new(1,0,0,TITLE_H); titleBar.BackgroundColor3 = Color3.fromRGB(12,16,23)
    -- Light scrim: without it a white contour line can pass behind the grey
    -- subtitle and drop it to ~1.2:1 contrast (unreadable).
    titleBar.BackgroundTransparency = 0.1; titleBar.BorderSizePixel = 0; titleBar.ZIndex = 5

    local avatarBg = Instance.new("Frame", titleBar)
    avatarBg.Size = UDim2.new(0,32,0,32); avatarBg.Position = UDim2.new(0,12,0.5,-16)
    avatarBg.BackgroundColor3 = Color3.fromRGB(13,18,26); avatarBg.BorderSizePixel = 0; avatarBg.ZIndex = 6
    mkCorner(avatarBg,16); mkStroke(avatarBg, Color3.fromRGB(58,120,170), 1.5).Transparency = 0.2
    local avatarImg = Instance.new("ImageLabel", avatarBg)
    avatarImg.Size = UDim2.new(1,-4,1,-4); avatarImg.Position = UDim2.new(0,2,0,2)
    avatarImg.BackgroundTransparency = 1; avatarImg.Image = ""; avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.ZIndex = 7; mkCorner(avatarImg,14)
    task.spawn(function()
        local ok,thumb = pcall(function() return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
        if ok and thumb then avatarImg.Image = thumb end
    end)
    LP.CharacterAdded:Connect(function()
        task.spawn(function()
            local ok,thumb = pcall(function() return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
            if ok and thumb then avatarImg.Image = thumb end
        end)
    end)

    local titleLbl = Instance.new("TextLabel", titleBar)
    titleLbl.Size = UDim2.new(1,-96,0,16); titleLbl.Position = UDim2.new(0,50,0,7)
    titleLbl.BackgroundTransparency = 1; titleLbl.Text = "fluid.vs"
    titleLbl.TextColor3 = C.topTitle; titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 15
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 6
    do
        local tlg = mkGrad(titleLbl, Color3.fromRGB(255,105,240), Color3.fromRGB(70,200,255), 0)
        registerChromaGrad(tlg)
        task.spawn(function()
            while titleLbl and titleLbl.Parent do
                tlg.Offset = Vector2.new(math.sin(tick() * 1.2) * 0.2, 0)
                RunService.RenderStepped:Wait()
            end
        end)
    end

    local subTitleLbl = Instance.new("TextLabel", titleBar)
    subTitleLbl.Size = UDim2.new(1,-96,0,11); subTitleLbl.Position = UDim2.new(0,50,0,24)
    subTitleLbl.BackgroundTransparency = 1; subTitleLbl.Text = "powered by fluid"
    subTitleLbl.TextColor3 = C.topSub; subTitleLbl.Font = Enum.Font.GothamMedium; subTitleLbl.TextSize = 10
    subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; subTitleLbl.ZIndex = 6
    task.spawn(function()
        local phrases = {"powered by fluid", "status: ready", "nuke optimizer online", "bat mode armed", "low latency mode"}
        local idx = 1
        while subTitleLbl and subTitleLbl.Parent do
            task.wait(4)
            if not (subTitleLbl and subTitleLbl.Parent) then break end
            idx = idx % #phrases + 1
            TweenService:Create(subTitleLbl, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            task.wait(0.28)
            if subTitleLbl and subTitleLbl.Parent then
                subTitleLbl.Text = phrases[idx]
                TweenService:Create(subTitleLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            end
        end
    end)

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0,26,0,26); closeBtn.Position = UDim2.new(1,-36,0.5,-13)
    closeBtn.BackgroundColor3 = C.modeBtnBg; closeBtn.BorderSizePixel = 0
    closeBtn.Text = "x"; closeBtn.TextColor3 = C.topBtn; closeBtn.Font = Enum.Font.GothamBlack; closeBtn.TextSize = 18
    closeBtn.ZIndex = 7; mkCorner(closeBtn,13); mkStroke(closeBtn, C.chipBorder,1); mkSheen(closeBtn)
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.1), {TextColor3=Color3.fromRGB(255,110,110), BackgroundColor3=Color3.fromRGB(60,26,32)}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.1), {TextColor3=C.topBtn, BackgroundColor3=C.modeBtnBg}):Play() end)
    closeBtn.MouseButton1Click:Connect(function()
        State.guiVisible = false; hideWindow()
        local _qa = _G.FluidVSQAHide or _G.VoidCCQAHide or _G.GreenDuelsQAHide; if _qa then pcall(_qa, true) end
        requestSave()
    end)

    local miniBtn = Instance.new("TextButton", titleBar)
    miniBtn.Size = UDim2.new(0,26,0,26); miniBtn.Position = UDim2.new(1,-68,0.5,-13)
    miniBtn.BackgroundColor3 = C.modeBtnBg; miniBtn.BorderSizePixel = 0
    miniBtn.Text = "-"; miniBtn.TextColor3 = C.topBtn; miniBtn.Font = Enum.Font.GothamBlack; miniBtn.TextSize = 16
    miniBtn.ZIndex = 7; mkCorner(miniBtn,13); mkStroke(miniBtn, C.chipBorder,1); mkSheen(miniBtn)
    miniBtn.MouseEnter:Connect(function() TweenService:Create(miniBtn, TweenInfo.new(0.1), {TextColor3=C.topTitle}):Play() end)
    miniBtn.MouseLeave:Connect(function() TweenService:Create(miniBtn, TweenInfo.new(0.1), {TextColor3=C.topBtn}):Play() end)
    local _minimized = false
    miniBtn.MouseButton1Click:Connect(function()
        _minimized = not _minimized
        miniBtn.Text = _minimized and "+" or "-"
        TweenService:Create(mainOuter, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, WIN_W, 0, _minimized and (TITLE_H + 1) or WIN_H)
        }):Play()
    end)

    local titleDiv = Instance.new("Frame", mainOuter)
    titleDiv.Size = UDim2.new(1,0,0,1); titleDiv.Position = UDim2.new(0,0,0,TITLE_H)
    titleDiv.BackgroundColor3 = C.topDivider; titleDiv.BorderSizePixel = 0; titleDiv.ZIndex = 5

    local CONTENT_Y = TITLE_H + 42
    local contentBg = Instance.new("Frame", mainOuter)
    contentBg.Size = UDim2.new(1,0,1,-CONTENT_Y); contentBg.Position = UDim2.new(0,0,0,CONTENT_Y)
    contentBg.BackgroundColor3 = Color3.fromRGB(10,13,19); contentBg.BackgroundTransparency = 0.25
    contentBg.BorderSizePixel = 0; contentBg.ClipsDescendants = true; contentBg.ZIndex = 2

    local mainScroll = Instance.new("ScrollingFrame", contentBg)
    mainScroll.Name = "MainScroll"; mainScroll.Size = UDim2.new(1,0,1,0)
    mainScroll.BackgroundTransparency = 1; mainScroll.BorderSizePixel = 0
    mainScroll.ScrollBarThickness = 3; mainScroll.ScrollBarImageColor3 = C.accent
    mainScroll.ScrollBarImageTransparency = 0.4; mainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    mainScroll.CanvasSize = UDim2.new(0,0,0,0); mainScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    mainScroll.ZIndex = 3

    local mainLL = Instance.new("UIListLayout", mainScroll)
    mainLL.SortOrder = Enum.SortOrder.LayoutOrder; mainLL.Padding = UDim.new(0,4)
    mainLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local mainPad = Instance.new("UIPadding", mainScroll)
    mainPad.PaddingLeft = UDim.new(0,8); mainPad.PaddingRight = UDim.new(0,8)
    mainPad.PaddingTop = UDim.new(0,6); mainPad.PaddingBottom = UDim.new(0,12)

    local TABS = {"Speed", "Combat", "Auto Steal", "Movement", "Visual", "Animation", "Settings"}
    local tabPages = {}
    local currentPage = nil
    local lo = 0
    local function LO() lo = lo+1; return lo end

    local function makeGap(px) local f=Instance.new("Frame",currentPage); f.Size=UDim2.new(1,0,0,px or 6); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=LO() end
    local function makeSectionHeader(label)
        local wrap = Instance.new("Frame", currentPage)
        wrap.Size = UDim2.new(1,0,0,28); wrap.BackgroundTransparency=1; wrap.BorderSizePixel=0; wrap.LayoutOrder=LO()
        local dotRing = Instance.new("Frame", wrap); dotRing.Size = UDim2.new(0,12,0,12); dotRing.Position = UDim2.new(0,11,0.5,-6)
        dotRing.BackgroundTransparency = 1; dotRing.BorderSizePixel = 0; mkCorner(dotRing,6)
        local drs = mkStroke(dotRing, C.accent, 1); drs.Transparency = 0.45
        local dot = Instance.new("Frame", wrap); dot.Size = UDim2.new(0,6,0,6); dot.Position = UDim2.new(0,14,0.5,-3)
        dot.BackgroundColor3 = C.accent; dot.BorderSizePixel=0; mkCorner(dot,3)
        local lbl = Instance.new("TextLabel", wrap); lbl.Size = UDim2.new(1,-190,1,0); lbl.Position = UDim2.new(0,30,0,0)
        lbl.BackgroundTransparency=1; lbl.Text = label and label:upper() or ""
        lbl.TextColor3 = C.sectionTxt; lbl.Font = Enum.Font.GothamBlack; lbl.TextSize=10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local line = Instance.new("Frame", wrap)
        line.Size = UDim2.new(1, -226, 0, 1)
        line.Position = UDim2.new(0, 212, 0.5, 0)
        line.BackgroundColor3 = C.sectionDiv
        line.BorderSizePixel = 0
        local lg = Instance.new("UIGradient", line)
        lg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35),
            NumberSequenceKeypoint.new(1, 1),
        })
    end

    local function makeInputRow(label, default, onChange)
        local row = Instance.new("Frame", currentPage)
        row.Size = UDim2.new(1,-16,0,44); row.BackgroundColor3 = C.rowBg; row.BackgroundTransparency = 0.1
        row.BorderSizePixel=0; row.LayoutOrder=LO(); mkCorner(row,12); mkSheen(row)
        local rowStroke = mkStroke(row, C.rowBorder,1); rowStroke.Transparency = 0.5
        row.MouseEnter:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.rowHov}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.12),{Color=C.strokeHi,Transparency=0.15}):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.rowBg}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.12),{Color=C.rowBorder,Transparency=0.5}):Play()
        end)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-110,1,0); lbl.Position = UDim2.new(0,14,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.rowLabel
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local boxWrap = Instance.new("Frame", row)
        boxWrap.Size = UDim2.new(0,72,0,30); boxWrap.Position = UDim2.new(1,-86,0.5,-15)
        boxWrap.BackgroundColor3 = C.inputBg; boxWrap.BorderSizePixel=0
        mkCorner(boxWrap,9); local bs = mkStroke(boxWrap, C.inputBorder,1); bs.Transparency=0.35
        local box = Instance.new("TextBox", boxWrap)
        box.Size = UDim2.new(1,-8,1,0); box.Position = UDim2.new(0,4,0,0)
        box.BackgroundTransparency=1; box.Text = tostring(default)
        box.TextColor3 = C.inputTxt; box.Font = Enum.Font.GothamBlack
        box.TextSize=13; box.ClearTextOnFocus=false; box.ZIndex=8; box.TextXAlignment=Enum.TextXAlignment.Center
        box.Focused:Connect(function()
            TweenService:Create(bs,TweenInfo.new(0.15),{Color=C.inputFocus,Transparency=0}):Play()
            TweenService:Create(boxWrap,TweenInfo.new(0.15),{BackgroundColor3=C.rowHov}):Play()
        end)
        box.FocusLost:Connect(function()
            TweenService:Create(bs,TweenInfo.new(0.15),{Color=C.inputBorder,Transparency=0.35}):Play()
            TweenService:Create(boxWrap,TweenInfo.new(0.15),{BackgroundColor3=C.inputBg}):Play()
            if onChange then
                local n = tonumber(box.Text)
                if n then onChange(n); requestSave()
                else box.Text = tostring(default) end
            end
        end)
        return box,row
    end

    local function makeToggleRow(label, defaultOn, onToggle)
        local row = Instance.new("Frame", currentPage)
        row.Size = UDim2.new(1,-16,0,44); row.BackgroundColor3 = C.rowBg; row.BackgroundTransparency = 0.1
        row.BorderSizePixel=0; row.LayoutOrder=LO(); mkCorner(row,12); mkSheen(row)
        local rowStroke = mkStroke(row, C.rowBorder,1); rowStroke.Transparency = 0.5
        row.MouseEnter:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.rowHov}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.12),{Color=C.strokeHi,Transparency=0.15}):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.rowBg}):Play()
            TweenService:Create(rowStroke,TweenInfo.new(0.12),{Color=C.rowBorder,Transparency=0.5}):Play()
        end)
        local sDot = Instance.new("Frame", row)
        sDot.Size = UDim2.new(0,5,0,5); sDot.Position = UDim2.new(0,14,0.5,-2.5)
        sDot.BackgroundColor3 = defaultOn and C.accent or C.stackDot
        sDot.BorderSizePixel = 0; mkCorner(sDot,3)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-84,1,0); lbl.Position = UDim2.new(0,27,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.rowLabel
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local pillGlow = Instance.new("Frame", row)
        pillGlow.Size = UDim2.new(0,58,0,36); pillGlow.Position = UDim2.new(1,-68,0.5,-18)
        pillGlow.BackgroundColor3 = C.accent
        pillGlow.BackgroundTransparency = defaultOn and 0.92 or 1
        pillGlow.BorderSizePixel = 0; pillGlow.ZIndex = 6; mkCorner(pillGlow,18)
        local pillBg = Instance.new("Frame", row)
        pillBg.Size = UDim2.new(0,46,0,24); pillBg.Position = UDim2.new(1,-62,0.5,-12)
        pillBg.BackgroundColor3 = Color3.fromRGB(255,255,255)
        pillBg.BorderSizePixel=0; pillBg.ZIndex=7; mkCorner(pillBg,12)
        local pillGrad = mkGrad(pillBg,
            defaultOn and GRAD.onTop or GRAD.idleTop,
            defaultOn and GRAD.onBot or GRAD.idleBot)
        local function setPillGrad(on)
            pillGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, on and GRAD.onTop or GRAD.idleTop),
                ColorSequenceKeypoint.new(1, on and GRAD.onBot or GRAD.idleBot),
            })
        end
        local dot = Instance.new("Frame", pillBg)
        dot.Size = UDim2.new(0,18,0,18); dot.Position = defaultOn and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        dot.BackgroundColor3 = defaultOn and C.dotOn or C.dotOff; dot.BorderSizePixel=0; dot.ZIndex=8; mkCorner(dot,9); mkSheen(dot, 0.88)
        local isOn = defaultOn or false
        if isOn then
            registerChromaGrad(pillGrad)
            registerChromaColor(sDot, "BackgroundColor3", C.accent, false)
        end
        local function setV(on)
            isOn = on
            setPillGrad(on)
            if on then
                registerChromaGrad(pillGrad)
                registerChromaColor(sDot, "BackgroundColor3", C.accent, false)
            else
                unregisterChromaGrad(pillGrad)
                unregisterChromaColor(sDot)
            end
            TweenService:Create(dot, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3 = on and C.dotOn or C.dotOff
            }):Play()
            TweenService:Create(pillGlow, TweenInfo.new(0.25), {BackgroundTransparency = on and 0.92 or 1}):Play()
            TweenService:Create(sDot, TweenInfo.new(0.2), {BackgroundColor3 = on and C.accent or C.stackDot}):Play()
        end
        local function toggle()
            isOn = not isOn; setV(isOn)
            mkRipple(row, 26)
            if onToggle then pcall(onToggle, isOn) end
            requestSave()
        end
        local clk = Instance.new("TextButton", row); clk.Size = UDim2.new(1,-74,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=5; clk.BorderSizePixel=0; clk.MouseButton1Click:Connect(toggle)
        local pClk = Instance.new("TextButton", pillBg); pClk.Size = UDim2.new(1,0,1,0); pClk.BackgroundTransparency=1; pClk.Text=""; pClk.ZIndex=9; pClk.BorderSizePixel=0; pClk.MouseButton1Click:Connect(toggle)
        return setV
    end

    local function getKeyDisplayName(kc)
        if kc == Enum.KeyCode.Unknown then return "None" end
        local n = kc.Name
        local gpNames = {ButtonA="A",ButtonB="B",ButtonX="X",ButtonY="Y",ButtonL1="LB",ButtonL2="LT",ButtonL3="LS",
            ButtonR1="RB",ButtonR2="RT",ButtonR3="RS",ButtonSelect="SEL",ButtonStart="STA",
            DPadUp="DU",DPadDown="DD",DPadLeft="DL",DPadRight="DR",Thumbstick1="LS",Thumbstick2="RS"}
        return gpNames[n] or n:sub(1,5)
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
        row.Size = UDim2.new(1,-16,0,42); row.BackgroundColor3 = C.rowBg; row.BackgroundTransparency = 0.1
        row.BorderSizePixel = 0; row.LayoutOrder = LO(); mkCorner(row, 12); mkSheen(row)
        local rowStroke = mkStroke(row, C.rowBorder, 1); rowStroke.Transparency = 0.5
        row.MouseEnter:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.rowHov}):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=C.rowBg}):Play()
        end)
        local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(1,-90,1,0); lbl.Position = UDim2.new(0,14,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.rowLabel; lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local kbtn = Instance.new("TextButton", row); kbtn.Size = UDim2.new(0,56,0,26); kbtn.Position = UDim2.new(1,-70,0.5,-13)
        kbtn.BackgroundColor3 = C.chipBg; kbtn.BorderSizePixel=0; kbtn.Text = getKeyDisplayName(currentKey)
        kbtn.TextColor3 = C.chipTxt; kbtn.Font = Enum.Font.GothamBlack; kbtn.TextSize=11; kbtn.ZIndex=8
        mkCorner(kbtn,13); local ks = mkStroke(kbtn, C.chipBorder,1); mkSheen(kbtn)
        local listening = false; local lconnKeyboard,lconnGamepad
        local function stopL(key)
            listening = false
            if lconnKeyboard then lconnKeyboard:Disconnect(); lconnKeyboard=nil end
            if lconnGamepad then lconnGamepad:Disconnect(); lconnGamepad=nil end
            TweenService:Create(ks,TweenInfo.new(0.12),{Color=C.chipBorder}):Play()
            TweenService:Create(kbtn,TweenInfo.new(0.12),{BackgroundColor3=C.chipBg}):Play()
            kbtn.TextColor3 = C.chipTxt
            if key then
                kbtn.Text = getKeyDisplayName(key)
                if onChanged then onChanged(key) end
                pcall(requestSave)
            else
                kbtn.Text = getKeyDisplayName(Keys[keyName] or Enum.KeyCode.Unknown)
            end
        end
        kbtn.MouseButton1Click:Connect(function()
            if listening then stopL(nil); return end
            listening = true; kbtn.Text = "..."
            TweenService:Create(ks,TweenInfo.new(0.12),{Color=C.accent}):Play()
            task.spawn(function()
                local flip = false
                while listening do
                    flip = not flip
                    TweenService:Create(kbtn,TweenInfo.new(0.28),{BackgroundColor3 = flip and C.accentDim or C.chipBg}):Play()
                    task.wait(0.3)
                end
            end)
            lconnKeyboard = UIS.InputBegan:Connect(function(inp)
                if not listening then return end
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if inp.KeyCode == Enum.KeyCode.Escape then stopL(nil); return end
                stopL(inp.KeyCode)
            end)
            lconnGamepad = UIS.InputBegan:Connect(function(inp)
                if not listening then return end
                if inp.UserInputType ~= Enum.UserInputType.Gamepad1 and inp.UserInputType ~= Enum.UserInputType.Gamepad2 and inp.UserInputType ~= Enum.UserInputType.Gamepad3 and inp.UserInputType ~= Enum.UserInputType.Gamepad4 then return end
                local kc = inp.KeyCode; if kc == Enum.KeyCode.Unknown then return end
                stopL(kc)
            end)
        end)
        if keyName then keybindBtnRefs[keyName] = kbtn end
        return kbtn
    end

    -- ============================================================
    -- PERFORMANCE
    -- ============================================================
    local antiLagDescConn = nil
    local antiLagActive = false
    local antiLagDefBrightness, antiLagDefFog, antiLagDefDiffuse, antiLagDefSpecular

    local function _applyAntiLagObj(obj)
        pcall(function()
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic; obj.Reflectance = 0; obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
            or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
                for _,t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
            end
        end)
    end

    local function enableAntiLag()
        antiLagActive = true
        antiLagDefBrightness = antiLagDefBrightness or Lighting.Brightness
        antiLagDefFog        = antiLagDefFog        or Lighting.FogEnd
        antiLagDefDiffuse    = antiLagDefDiffuse    or Lighting.EnvironmentDiffuseScale
        antiLagDefSpecular   = antiLagDefSpecular   or Lighting.EnvironmentSpecularScale
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _,e in pairs(Lighting:GetChildren()) do
            pcall(function()
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
            end)
        end
        for _,obj in ipairs(workspace:GetDescendants()) do _applyAntiLagObj(obj) end
        if antiLagDescConn then antiLagDescConn:Disconnect() end
        antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
            if antiLagActive then _applyAntiLagObj(obj) end
        end)
    end

    local function disableAntiLag()
        antiLagActive = false
        if antiLagDescConn then antiLagDescConn:Disconnect(); antiLagDescConn = nil end
        pcall(function()
            Lighting.GlobalShadows = true
            if antiLagDefBrightness then Lighting.Brightness = antiLagDefBrightness end
            if antiLagDefFog        then Lighting.FogEnd = antiLagDefFog end
            if antiLagDefDiffuse    then Lighting.EnvironmentDiffuseScale = antiLagDefDiffuse end
            if antiLagDefSpecular   then Lighting.EnvironmentSpecularScale = antiLagDefSpecular end
            for _,e in pairs(Lighting:GetChildren()) do
                pcall(function()
                    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                    or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = true end
                end)
            end
        end)
    end

    local stretchRezEnabled=false
    local stretchRezConn,stretchFovConn=nil,nil
    local function applyStretchFOV(val) local cam=Workspace.CurrentCamera; if cam then pcall(function() cam.FieldOfView=val end) end end
    local function enableStretchRez()
        stretchRezEnabled=true; local cam=Workspace.CurrentCamera; if not cam then return end
        if stretchRezConn then stretchRezConn:Disconnect() end
        if stretchFovConn then stretchFovConn:Disconnect() end
        stretchFovConn = RunService.RenderStepped:Connect(function() if stretchRezEnabled then applyStretchFOV(State.stretchFOV) end end)
        stretchRezConn = RunService.RenderStepped:Connect(function()
            if not stretchRezEnabled then stretchRezConn:Disconnect(); stretchRezConn=nil; return end
            if cam then cam.CFrame = cam.CFrame * CFrame.new(0,0,0,1,0,0,0,0.7,0,0,0,1) end
        end)
    end
    local function disableStretchRez()
        stretchRezEnabled=false
        if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn=nil end
        if stretchFovConn then stretchFovConn:Disconnect(); stretchFovConn=nil end
        pcall(function() Workspace.CurrentCamera.FieldOfView = 70 end)
    end
    local function cleanParticlesAndLights()
        local removed=0
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                pcall(function() obj:Destroy() end); removed=removed+1
            end
        end
        if _G._VezyFlashSave then _G._VezyFlashSave(true); task.delay(1.2,function() if _G._VezyFlashSave then _G._VezyFlashSave(false) end end) end
        print("[fluid.vs] Cleaned "..removed.." effects/lights")
    end
    local origLighting = {
        Ambient = Lighting.Ambient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
    local activeColorCorr = nil
    local function clearColorCorr() if activeColorCorr then pcall(function() activeColorCorr:Destroy() end); activeColorCorr=nil end end
    local function restoreLighting()
        clearColorCorr()
        pcall(function()
            Lighting.Ambient = origLighting.Ambient; Lighting.Brightness = origLighting.Brightness
            Lighting.ClockTime = origLighting.ClockTime; Lighting.FogColor = origLighting.FogColor
            Lighting.FogEnd = origLighting.FogEnd; Lighting.GlobalShadows = origLighting.GlobalShadows
            Lighting.EnvironmentDiffuseScale = origLighting.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale = origLighting.EnvironmentSpecularScale
        end)
    end

    local function applySky(kind)
        if kind==nil or kind=="none" then restoreLighting(); return end
        clearColorCorr(); local cc=Instance.new("ColorCorrectionEffect"); cc.Parent=Lighting; activeColorCorr=cc
        if kind=="blue" then
            Lighting.Ambient=Color3.fromRGB(30,60,120); Lighting.FogColor=Color3.fromRGB(40,80,160)
            cc.TintColor=Color3.fromRGB(140,180,255); cc.Saturation=0.4; cc.Contrast=0.1
        elseif kind=="green" then
            Lighting.Ambient=Color3.fromRGB(40,100,60); Lighting.FogColor=Color3.fromRGB(50,140,80)
            cc.TintColor=Color3.fromRGB(160,255,180); cc.Saturation=0.5; cc.Contrast=0.1
        elseif kind=="night" then
            Lighting.ClockTime=0; Lighting.Brightness=0.2; Lighting.Ambient=Color3.fromRGB(20,20,35)
            cc.TintColor=Color3.fromRGB(180,180,220); cc.Saturation=-0.2; cc.Contrast=0.1
        elseif kind=="day" then
            Lighting.ClockTime=14; Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(140,140,140)
            cc.TintColor=Color3.fromRGB(255,255,255); cc.Saturation=0.1; cc.Contrast=0
        end
    end

    -- ============================================================
    -- BUILD PAGES
    -- ============================================================
    local function buildPage(tabName, buildFn)
        local page = Instance.new("Frame", mainScroll)
        page.Name = tabName; page.Size = UDim2.new(1,0,0,0); page.AutomaticSize = Enum.AutomaticSize.Y
        page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.LayoutOrder = 0
        local ll = Instance.new("UIListLayout", page); ll.SortOrder = Enum.SortOrder.LayoutOrder
        ll.Padding = UDim.new(0,4); ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabPages[tabName] = page
        currentPage = page; lo = 0; buildFn(); currentPage = nil
        return page
    end

    -- Speed Page
    do
        local page = buildPage("Speed", function()
            makeGap(2); makeSectionHeader("Speed Values"); makeGap(2)
            normalBox = makeInputRow("Normal Speed", State.normalSpeed, function(n) if n>0 and n<=500 then State.normalSpeed=n end end)
            carryBox = makeInputRow("Carry Speed", State.carrySpeed, function(n) if n>0 and n<=500 then State.carrySpeed=n end end)
            laggerBox = makeInputRow("Lagger Speed", State.laggerSpeed, function(n) if n>0 and n<=500 then State.laggerSpeed=n end end)
            laggerCarryBox = makeInputRow("Lagger Carry Speed", State.laggerCarrySpeed, function(n) if n>0 and n<=500 then State.laggerCarrySpeed=n end end)
            makeGap(8); makeSectionHeader("Auto Carry"); makeGap(2)
            setAutoCarry = makeToggleRow("Auto Carry Speed", State.autoCarryEnabled, function(on) State.autoCarryEnabled=on end)
            toggleSetters["autoCarry"] = setAutoCarry
            makeGap(8); makeSectionHeader("Speed Keybinds"); makeGap(2)
            makeKeybindRow("Speed Key (toggles)", Keys.speed, function(k) Keys.speed=k end, "speed")
            makeKeybindRow("Lagger Key (toggles)", Keys.lagger, function(k) Keys.lagger=k end, "lagger")
            makeKeybindRow("Auto Carry Key", Keys.autoCarry, function(k) Keys.autoCarry=k end, "autoCarry")
        end)
        page.LayoutOrder = 1
    end

    -- Combat Page
    do
        local page = buildPage("Combat", function()
            makeGap(2); makeSectionHeader("Bat Aimbot"); makeGap(2)
            setAutoSwing = makeToggleRow("Auto Swing", false, function(on) State.autoSwingEnabled=on end)
            toggleSetters["autoSwing"] = setAutoSwing
            setBatCounter = makeToggleRow("Bat Counter", false, function(on) State.batCounterEnabled=on; if on then startBatCounter() else stopBatCounter() end end)
            toggleSetters["batCounter"] = setBatCounter
            setMedusaCounter = makeToggleRow("Medusa Counter", false, function(on) State.medusaCounterEnabled=on; if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end end)
            toggleSetters["medusaCounter"] = setMedusaCounter
            makeKeybindRow("Aimbot Key", Keys.aimbot, function(k) Keys.aimbot=k end, "aimbot")
            makeKeybindRow("TP Bat Key", Keys.tpBat, function(k) Keys.tpBat=k end, "tpBat")
        end)
        page.LayoutOrder = 2
    end

    -- Auto Steal Page
    do
        local page = buildPage("Auto Steal", function()
            makeGap(2); makeSectionHeader("Insta Grab"); makeGap(2)
            setInstaGrab = makeToggleRow("Auto Steal", true, function(on) Steal.AutoStealEnabled=on; if on then startAutoSteal() else stopAutoSteal() end end)
            toggleSetters["autoSteal"] = setInstaGrab
            makeGap(6); makeSectionHeader("Steal Config"); makeGap(2)
            stealRadBox = makeInputRow("Steal Radius", Steal.StealRadius, function(n) if n then n=math.floor(n); if n>=1 and n<=500 then Steal.StealRadius=n end end end)
            local durBox,_ = makeInputRow("Steal Duration", Steal.StealDuration, function(n) if n then n=math.min(n,10); if n>=0.05 then Steal.StealDuration=n end end end)
            stealDurBox = durBox
        end)
        page.LayoutOrder = 3
    end

    -- Movement Page
    do
        local page = buildPage("Movement", function()
            makeGap(2); makeSectionHeader("Infinite Jump"); makeGap(2)
            setInfJump = makeToggleRow("Infinite Jump", true, function(on) State.infJumpEnabled=on end)
            toggleSetters["infJump"] = setInfJump
            makeGap(8); makeSectionHeader("Defense"); makeGap(2)
            setAntiRag = makeToggleRow("Anti Ragdoll", false, function(on) State.antiRagdollEnabled=on; if on then startAntiRagdoll() else stopAntiRagdoll() end end)
            toggleSetters["antiRagdoll"] = setAntiRag
            makeGap(8); makeSectionHeader("Auto Movement"); makeGap(2)
            makeKeybindRow("Auto Left", Keys.autoLeft, function(k) Keys.autoLeft=k end, "autoLeft")
            makeKeybindRow("Auto Right", Keys.autoRight, function(k) Keys.autoRight=k end, "autoRight")
            makeKeybindRow("Drop Key", Keys.drop, function(k) Keys.drop=k end, "drop")
            makeKeybindRow("TP Down", Keys.tpDown, function(k) Keys.tpDown=k end, "tpDown")
            makeKeybindRow("Reset Player", Keys.reset, function(k) Keys.reset=k end, "reset")

            -- DROP TYPE SELECTOR (Only Jump Drop)
            local dropTypeRow = Instance.new("Frame", currentPage)
            dropTypeRow.Size = UDim2.new(1,-16,0,42)
            dropTypeRow.BackgroundColor3 = C.rowBg; dropTypeRow.BackgroundTransparency = 0.1
            dropTypeRow.BorderSizePixel = 0
            dropTypeRow.LayoutOrder = LO()
            mkCorner(dropTypeRow, 12)
            local dropTypeStroke = mkStroke(dropTypeRow, C.rowBorder, 1)
            dropTypeStroke.Transparency = 0.5

            local dropTypeLbl = Instance.new("TextLabel", dropTypeRow)
            dropTypeLbl.Size = UDim2.new(0.4, 0, 1, 0)
            dropTypeLbl.Position = UDim2.new(0, 14, 0, 0)
            dropTypeLbl.BackgroundTransparency = 1
            dropTypeLbl.Text = "Drop Type"
            dropTypeLbl.TextColor3 = C.rowLabel
            dropTypeLbl.Font = Enum.Font.GothamBold
            dropTypeLbl.TextSize = 13
            dropTypeLbl.TextXAlignment = Enum.TextXAlignment.Left

            jumpDropBtn = Instance.new("TextButton", dropTypeRow)
            jumpDropBtn.Size = UDim2.new(0, 120, 0, 30)
            jumpDropBtn.Position = UDim2.new(0.6, 0, 0.5, -15)
            jumpDropBtn.BackgroundColor3 = C.accent
            jumpDropBtn.BorderSizePixel = 0
            jumpDropBtn.Text = "Jump Drop"
            jumpDropBtn.TextColor3 = Color3.fromRGB(10,10,10)
            jumpDropBtn.Font = Enum.Font.GothamBold
            jumpDropBtn.TextSize = 12
            jumpDropBtn.ZIndex = 20
            mkCorner(jumpDropBtn, 6)
            mkStroke(jumpDropBtn, C.inputBorder, 1); mkSheen(jumpDropBtn, 0.82)
            
            jumpDropBtn.MouseButton1Click:Connect(function()
                print("[fluid.vs] Drop type: Jump Drop (safe - ascends then teleports)")
            end)

            -- Auto TP
            makeGap(8); makeSectionHeader("Auto TP"); makeGap(2)
            local autoTPToggle = makeToggleRow("Auto TP", State.autoTPEnabled, function(on)
                State.autoTPEnabled = on
                if on then startAutoTP() else stopAutoTP() end
                requestSave()
            end)
            toggleSetters["autoTP"] = autoTPToggle
            autoTPHeightBox = makeInputRow("Auto TP Height", State.autoTPHeight, function(n)
                if n and n >= 2 and n <= 500 then State.autoTPHeight = n end
            end)
        end)
        page.LayoutOrder = 4
    end

    -- Visual Page
    local antiLagSetter, stretchSetter
    local nukeSetter, removeAccSetter, tryardSetter, chromaSetter
    do
        local page = buildPage("Visual", function()
            makeGap(2); makeSectionHeader("Performance"); makeGap(2)
            antiLagSetter = makeToggleRow("Anti-Lag (recommended)", State.antiLagEnabled, function(on) State.antiLagEnabled=on; if on then enableAntiLag() else disableAntiLag() end end)
            toggleSetters["antiLag"] = antiLagSetter
            stretchSetter = makeToggleRow("Stretch Rez", State.stretchedResEnabled, function(on) State.stretchedResEnabled=on; if on then enableStretchRez() else disableStretchRez() end end)
            toggleSetters["stretchedRes"] = stretchSetter
            do
                local fovRow = Instance.new("Frame", currentPage); fovRow.Size = UDim2.new(1,-16,0,42); fovRow.BackgroundColor3=C.rowBg; fovRow.BackgroundTransparency=0.1; fovRow.BorderSizePixel=0; fovRow.LayoutOrder=LO(); mkCorner(fovRow,12)
                local fovStroke = mkStroke(fovRow, C.rowBorder,1); fovStroke.Transparency=0.5
                local fovLabel = Instance.new("TextLabel", fovRow); fovLabel.Size = UDim2.new(0.4,0,1,0); fovLabel.Position = UDim2.new(0,14,0,0); fovLabel.BackgroundTransparency=1; fovLabel.Text="Stretch FOV"; fovLabel.TextColor3=C.rowLabel; fovLabel.Font=Enum.Font.GothamBold; fovLabel.TextSize=13; fovLabel.TextXAlignment=Enum.TextXAlignment.Left
                local btnFrame = Instance.new("Frame", fovRow); btnFrame.Size = UDim2.new(0,150,0,28); btnFrame.Position = UDim2.new(1,-162,0.5,-14); btnFrame.BackgroundTransparency=1
                local function makeFOVBtn(val,x)
                    local btn = Instance.new("TextButton", btnFrame); btn.Size = UDim2.new(0,44,0,28); btn.Position = UDim2.new(0,x,0,0); btn.BackgroundColor3=C.modeBtnBg; btn.BorderSizePixel=0; btn.Text=tostring(val); btn.TextColor3=C.modeBtnTxt; btn.Font=Enum.Font.GothamBold; btn.TextSize=12; mkCorner(btn,6); mkStroke(btn, C.modeBtnBrd,1); mkSheen(btn)
                    if val == State.stretchFOV then btn.BackgroundColor3=C.modeBtnActBg; btn.TextColor3=C.modeBtnActTx end
                    btn.MouseButton1Click:Connect(function()
                        State.stretchFOV=val; if State.stretchedResEnabled then applyStretchFOV(val) end
                        for _,b in pairs(btnFrame:GetChildren()) do if b:IsA("TextButton") then local v=tonumber(b.Text); if v==val then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.modeBtnActBg,TextColor3=C.modeBtnActTx}):Play() else TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.modeBtnBg,TextColor3=C.modeBtnTxt}):Play() end end end
                        requestSave()
                    end)
                    return btn
                end
                makeFOVBtn(90,0); makeFOVBtn(120,53); makeFOVBtn(180,106)
            end
            local cleanBtnWrap = Instance.new("Frame", currentPage); cleanBtnWrap.Size = UDim2.new(1,-16,0,46); cleanBtnWrap.BackgroundTransparency=1; cleanBtnWrap.LayoutOrder=LO()
            local cleanBtn = Instance.new("TextButton", cleanBtnWrap); cleanBtn.Size = UDim2.new(1,0,0,32); cleanBtn.Position = UDim2.new(0,0,0,7); cleanBtn.BackgroundColor3=C.btnBg; cleanBtn.BorderSizePixel=0; cleanBtn.Text="Clean Particles & Lights"; cleanBtn.TextColor3=C.btnTxt; cleanBtn.Font=Enum.Font.GothamBold; cleanBtn.TextSize=12; mkCorner(cleanBtn,6); mkStroke(cleanBtn, C.btnBorder,1); mkSheen(cleanBtn)
            cleanBtn.MouseEnter:Connect(function() TweenService:Create(cleanBtn,TweenInfo.new(0.1),{BackgroundColor3=C.btnHov}):Play() end)
            cleanBtn.MouseLeave:Connect(function() TweenService:Create(cleanBtn,TweenInfo.new(0.1),{BackgroundColor3=C.btnBg}):Play() end)
            cleanBtn.MouseButton1Click:Connect(cleanParticlesAndLights)

            makeGap(8); makeSectionHeader("Sky Colors"); makeGap(2)
            local function makeSkyBtn(label,kind)
                local btn = Instance.new("TextButton", currentPage); btn.Size = UDim2.new(1,-16,0,32); btn.BackgroundColor3=C.modeBtnBg; btn.BorderSizePixel=0; btn.Text=label; btn.TextColor3=C.modeBtnTxt; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.LayoutOrder=LO(); mkCorner(btn,6); mkStroke(btn, C.modeBtnBrd,1); mkSheen(btn)
                if State.activeSky == kind then btn.BackgroundColor3=C.modeBtnActBg; btn.TextColor3=C.modeBtnActTx end
                btn.MouseButton1Click:Connect(function()
                    if State.activeSky == kind then applySky(nil); State.activeSky=nil; for _,b in pairs(currentPage:GetChildren()) do if b:IsA("TextButton") and b~=cleanBtn and b~=cleanBtnWrap then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.modeBtnBg,TextColor3=C.modeBtnTxt}):Play() end end
                    else applySky(kind); State.activeSky=kind; for _,b in pairs(currentPage:GetChildren()) do if b:IsA("TextButton") and b~=cleanBtn and b~=cleanBtnWrap then local isActive=(b.Text==label); TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=isActive and C.modeBtnActBg or C.modeBtnBg,TextColor3=isActive and C.modeBtnActTx or C.modeBtnTxt}):Play() end end end
                    requestSave()
                end)
                return btn
            end
            makeSkyBtn("Blue Sky","blue"); makeSkyBtn("Green Sky","green"); makeSkyBtn("Night Mode","night"); makeSkyBtn("Day Mode","day")
            makeGap(4)
            local resetSkyBtn = Instance.new("TextButton", currentPage); resetSkyBtn.Size = UDim2.new(1,-16,0,32); resetSkyBtn.BackgroundColor3=Color3.fromRGB(52,32,40); resetSkyBtn.BorderSizePixel=0; resetSkyBtn.Text="Restore Default Lighting"; resetSkyBtn.TextColor3=Color3.fromRGB(235,235,235); resetSkyBtn.Font=Enum.Font.GothamBold; resetSkyBtn.TextSize=11; resetSkyBtn.LayoutOrder=LO(); mkCorner(resetSkyBtn,6); mkStroke(resetSkyBtn, Color3.fromRGB(110,60,80),1); mkSheen(resetSkyBtn)
            resetSkyBtn.MouseEnter:Connect(function() TweenService:Create(resetSkyBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(66,40,48)}):Play() end)
            resetSkyBtn.MouseLeave:Connect(function() TweenService:Create(resetSkyBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(52,32,40)}):Play() end)
            resetSkyBtn.MouseButton1Click:Connect(function()
                applySky(nil); State.activeSky=nil
                for _,b in pairs(currentPage:GetChildren()) do if b:IsA("TextButton") and b~=cleanBtn and b~=cleanBtnWrap and b~=resetSkyBtn then TweenService:Create(b,TweenInfo.new(0.15),{BackgroundColor3=C.modeBtnBg,TextColor3=C.modeBtnTxt}):Play() end end
                requestSave()
            end)

            makeGap(8); makeSectionHeader("Other Visuals"); makeGap(2)
            setKorbloxLeft = makeToggleRow("Korblox Left Leg", State.korbloxLeftEnabled, function(on)
                State.korbloxLeftEnabled=on
                pcall(function() if on then enableKorbloxLeg("Left") else disableKorbloxLeg("Left") end end)
            end)
            toggleSetters["korbloxLeft"] = setKorbloxLeft
            setKorbloxRight = makeToggleRow("Korblox Right Leg", State.korbloxRightEnabled, function(on)
                State.korbloxRightEnabled=on
                pcall(function() if on then enableKorbloxLeg("Right") else disableKorbloxLeg("Right") end end)
            end)
            toggleSetters["korbloxRight"] = setKorbloxRight
            chromaSetter = makeToggleRow("Chroma RGB Mode", State.chromaEnabled, function(on) State.chromaEnabled=on; if on then startChromaLoop() else stopChromaLoop() end end)
            toggleSetters["chroma"] = chromaSetter
            nukeSetter = makeToggleRow("Nuke Optimizer", false, function(on) State.nukeOpt=on; if on then _G._nukeStart() else _G._nukeStop() end end)
            toggleSetters["nukeOpt"] = nukeSetter
            removeAccSetter = makeToggleRow("Remove Accessories", false, function(on) State.removeAcc=on; if on then _G._removeAccStart() else _G._removeAccStop() end end)
            toggleSetters["removeAcc"] = removeAccSetter
            tryardSetter = makeToggleRow("Tryard Animation Pack", State.tryardAnimEnabled, function(on) State.tryardAnimEnabled=on; if on then startTryardAnim() else stopTryardAnim() end end)
            toggleSetters["tryardAnim"] = tryardSetter
            _G._VezyFOV = _G._VezyFOV or 70
            makeInputRow("FOV (normal)", _G._VezyFOV, function(n) if n>=70 and n<=180 then _G._VezyFOV=n; local cam=workspace.CurrentCamera; if cam and not State.stretchedResEnabled then pcall(function() cam.FieldOfView=n end) end end end)
        end)
        page.LayoutOrder = 5
    end

    -- Animation Page
    do
        local page = buildPage("Animation", function()
            makeGap(2); makeSectionHeader("Animation Packs"); makeGap(2)
            refreshAnimButtons = function()
                for name, b in pairs(animTabBtns) do
                    if b and b.Parent then
                        local isActive = (State.activeAnimPack == name)
                        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = isActive and C.modeBtnActBg or C.modeBtnBg, TextColor3 = isActive and C.modeBtnActTx or C.modeBtnTxt}):Play()
                    end
                end
            end
            local function makeAnimBtn(pack)
                local btn = Instance.new("TextButton", currentPage); btn.Size = UDim2.new(1,-16,0,32); btn.BackgroundColor3=C.modeBtnBg; btn.BorderSizePixel=0; btn.Text=pack.name; btn.TextColor3=C.modeBtnTxt; btn.Font=Enum.Font.GothamBold; btn.TextSize=11; btn.LayoutOrder=LO(); mkCorner(btn,6); mkStroke(btn, C.modeBtnBrd,1); mkSheen(btn)
                btn.MouseEnter:Connect(function() if State.activeAnimPack ~= pack.name then TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.btnHov}):Play() end end)
                btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=(State.activeAnimPack==pack.name) and C.modeBtnActBg or C.modeBtnBg}):Play() end)
                btn.MouseButton1Click:Connect(function()
                    pcall(function() applyAnimPack(pack) end)
                    State.activeAnimPack = pack.name
                    refreshAnimButtons()
                    requestSave()
                end)
                animTabBtns[pack.name] = btn
            end
            for _, pack in ipairs(ANIM_PACKS) do makeAnimBtn(pack) end
            task.defer(function() if refreshAnimButtons then pcall(refreshAnimButtons) end end)
            makeGap(4)
            local restoreAnimBtn = Instance.new("TextButton", currentPage); restoreAnimBtn.Size = UDim2.new(1,-16,0,32); restoreAnimBtn.BackgroundColor3=Color3.fromRGB(52,32,40); restoreAnimBtn.BorderSizePixel=0; restoreAnimBtn.Text="Restore Default Animations"; restoreAnimBtn.TextColor3=Color3.fromRGB(235,235,235); restoreAnimBtn.Font=Enum.Font.GothamBold; restoreAnimBtn.TextSize=11; restoreAnimBtn.LayoutOrder=LO(); mkCorner(restoreAnimBtn,6); mkStroke(restoreAnimBtn, Color3.fromRGB(110,60,80),1); mkSheen(restoreAnimBtn)
            restoreAnimBtn.MouseEnter:Connect(function() TweenService:Create(restoreAnimBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(66,40,48)}):Play() end)
            restoreAnimBtn.MouseLeave:Connect(function() TweenService:Create(restoreAnimBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(52,32,40)}):Play() end)
            restoreAnimBtn.MouseButton1Click:Connect(function()
                pcall(restoreOriginalAnims); State.activeAnimPack=nil; refreshAnimButtons(); requestSave()
            end)
        end)
        page.LayoutOrder = 6
    end

    -- Settings Page
    local introSetter, hideButtonsSetter, lockButtonsSetter
    do
        local page = buildPage("Settings", function()
            makeGap(2); makeSectionHeader("Interface"); makeGap(2)
            makeKeybindRow("Hide GUI", Keys.guiHide, function(k) Keys.guiHide=k end, "guiHide")
            uiScaleBox = makeInputRow("UI Scale", 1.0, function(n) if n>=0.5 and n<=2.0 then if uiScaleObj then uiScaleObj.Scale=n end end end)
            hideButtonsSetter = makeToggleRow("Hide Buttons", false, function(on) State.stackButtonsHidden=on; for _,wrapper in pairs(stackWrappers) do wrapper.Visible=not on end end)
            toggleSetters["hideButtons"] = hideButtonsSetter
            lockButtonsSetter = makeToggleRow("Lock Buttons", false, function(on) State.stackButtonsLocked=on end)
            toggleSetters["lockButtons"] = lockButtonsSetter
            introSetter = makeToggleRow("Show Intro Animation", State.introEnabled, function(on) State.introEnabled=on; requestSave() end)
            toggleSetters["introEnabled"] = introSetter

            makeGap(8); makeSectionHeader("Config"); makeGap(2)
            local saveWrap = Instance.new("Frame", currentPage); saveWrap.Size = UDim2.new(1,0,0,46); saveWrap.BackgroundTransparency=1; saveWrap.BorderSizePixel=0; saveWrap.LayoutOrder=LO()
            local saveBtn = Instance.new("TextButton", saveWrap); saveBtn.Size = UDim2.new(1,-28,0,32); saveBtn.Position = UDim2.new(0,14,0,7); saveBtn.BackgroundColor3=C.accent; saveBtn.BorderSizePixel=0; saveBtn.Text="Save Config Now"; saveBtn.TextColor3=Color3.fromRGB(10,10,10); saveBtn.Font=Enum.Font.GothamBold; saveBtn.TextSize=12; saveBtn.ZIndex=5; mkCorner(saveBtn,6); mkStroke(saveBtn, C.accent,1); mkSheen(saveBtn, 0.82)
            saveBtn.MouseEnter:Connect(function() TweenService:Create(saveBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(140,215,255)}):Play() end)
            saveBtn.MouseLeave:Connect(function() TweenService:Create(saveBtn,TweenInfo.new(0.1),{BackgroundColor3=C.accent}):Play() end)
            saveBtn.MouseButton1Click:Connect(function()
                local success = pcall(saveConfig)
                if _G.FluidToast then _G.FluidToast(success and "Config saved" or "Save failed", success) end
                if success then saveBtn.Text="Saved!"; saveBtn.BackgroundColor3=Color3.fromRGB(120,215,255) else saveBtn.Text="Save Failed"; saveBtn.BackgroundColor3=Color3.fromRGB(255,120,120) end
                task.delay(2.5,function() if saveBtn and saveBtn.Parent then saveBtn.Text="Save Config Now"; saveBtn.BackgroundColor3=C.accent end end)
            end)
            local resetWrap = Instance.new("Frame", currentPage); resetWrap.Size = UDim2.new(1,0,0,46); resetWrap.BackgroundTransparency=1; resetWrap.BorderSizePixel=0; resetWrap.LayoutOrder=LO()
            local resetAllBtn = Instance.new("TextButton", resetWrap); resetAllBtn.Size = UDim2.new(1,-28,0,32); resetAllBtn.Position = UDim2.new(0,14,0,7); resetAllBtn.BackgroundColor3=Color3.fromRGB(52,32,40); resetAllBtn.BorderSizePixel=0; resetAllBtn.Text="Reset All Settings"; resetAllBtn.TextColor3=Color3.fromRGB(235,235,235); resetAllBtn.Font=Enum.Font.GothamBold; resetAllBtn.TextSize=12; resetAllBtn.ZIndex=5; mkCorner(resetAllBtn,6); mkStroke(resetAllBtn, Color3.fromRGB(110,60,80),1); mkSheen(resetAllBtn)
            resetAllBtn.MouseEnter:Connect(function() TweenService:Create(resetAllBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(66,40,48)}):Play() end)
            resetAllBtn.MouseLeave:Connect(function() TweenService:Create(resetAllBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(52,32,40)}):Play() end)
            local _resetConfirmStage=0; local _resetConfirmTimer=nil
            resetAllBtn.MouseButton1Click:Connect(function()
                if _resetConfirmStage==0 then
                    _resetConfirmStage=1; resetAllBtn.Text="Click again to confirm!"; resetAllBtn.BackgroundColor3=Color3.fromRGB(94,54,64)
                    if _resetConfirmTimer then task.cancel(_resetConfirmTimer) end
                    _resetConfirmTimer = task.delay(3,function() if resetAllBtn and resetAllBtn.Parent then _resetConfirmStage=0; resetAllBtn.Text="Reset All Settings"; resetAllBtn.BackgroundColor3=Color3.fromRGB(52,32,40) end end)
                    return
                end
                _resetConfirmStage=0; if _resetConfirmTimer then task.cancel(_resetConfirmTimer); _resetConfirmTimer=nil end
                pcall(function() if State.batAimbotToggled then stopBatAimbot() end end)
                pcall(function() if State.batCounterEnabled then stopBatCounter() end end)
                pcall(function() if State.medusaCounterEnabled then stopMedusaCounter() end end)
                pcall(function() if State.antiRagdollEnabled then stopAntiRagdoll() end end)
                pcall(function() if Steal.AutoStealEnabled then stopAutoSteal() end end)
                pcall(function() if State.autoLeftEnabled then stopAutoLeft() end end)
                pcall(function() if State.autoRightEnabled then stopAutoRight() end end)
                pcall(function() if State.antiLagEnabled then disableAntiLag() end end)
                pcall(function() if State.stretchedResEnabled then disableStretchRez() end end)
                pcall(function() if State.chromaEnabled then stopChromaLoop() end end)
                pcall(restoreOriginalAnims)
                pcall(function() if State.autoTPEnabled then stopAutoTP() end end)
                pcall(function() disableKorbloxLeg("Left") end); pcall(function() disableKorbloxLeg("Right") end)
                pcall(function() if tpBatToggled then stopTPBat(); tpBatToggled = false end end)
                pcall(function() if _G._NukeOn and _G._nukeStop then _G._nukeStop() end end)
                pcall(function() if _G._RemoveAccOn and _G._removeAccStop then _G._removeAccStop() end end)
                applySky(nil)
                State.normalSpeed=60; State.carrySpeed=30; State.laggerSpeed=10.1; State.laggerCarrySpeed=15
                State.speedToggled=false; State.laggerMode=0; State.infJumpEnabled=true; State.antiRagdollEnabled=false
                State.antiLagEnabled=false; State.stretchedResEnabled=false
                State.chromaEnabled=false
                State.korbloxLeftEnabled=false; State.korbloxRightEnabled=false
                State.stretchFOV=120; State.activeSky=nil; State.activeAnimPack=nil; State.medusaCounterEnabled=false; State.batCounterEnabled=false
                State.batAimbotToggled=false; State.autoSwingEnabled=false; State.autoLeftEnabled=false; State.autoRightEnabled=false
                State.stackButtonsHidden=false; State.stackButtonsLocked=false; State.introEnabled=true
                State.autoTPEnabled=false; State.autoTPHeight=20; tpBatToggled=false
                State.autoCarryEnabled=false
                Steal.StealRadius=55; Steal.StealDuration=0.25; Steal.AutoStealEnabled=true
                Keys.speed=Enum.KeyCode.Q; Keys.guiHide=Enum.KeyCode.LeftControl; Keys.autoLeft=Enum.KeyCode.L; Keys.autoRight=Enum.KeyCode.R
                Keys.lagger=Enum.KeyCode.Unknown; Keys.tpDown=Enum.KeyCode.T; Keys.drop=Enum.KeyCode.H; Keys.aimbot=Enum.KeyCode.Unknown
                Keys.tpBat=Enum.KeyCode.X; Keys.reset=Enum.KeyCode.R; Keys.autoCarry=Enum.KeyCode.C
                currentDropType = DROP_TYPES.JUMP
                if jumpDropBtn then
                    jumpDropBtn.BackgroundColor3 = C.accent
                    jumpDropBtn.TextColor3 = Color3.fromRGB(10,10,10)
                end
                if normalBox then normalBox.Text=tostring(State.normalSpeed) end; if carryBox then carryBox.Text=tostring(State.carrySpeed) end
                if laggerBox then laggerBox.Text=tostring(State.laggerSpeed) end; if laggerCarryBox then laggerCarryBox.Text=tostring(State.laggerCarrySpeed) end
                if stealRadBox then stealRadBox.Text=tostring(Steal.StealRadius) end; if stealDurBox then stealDurBox.Text=tostring(Steal.StealDuration) end
                if uiScaleObj then uiScaleObj.Scale=1.0 end; if uiScaleBox then uiScaleBox.Text="1" end
                if setInstaGrab then pcall(setInstaGrab,true) end; if setInfJump then pcall(setInfJump,true) end; if setAntiRag then pcall(setAntiRag,false) end
                if setMedusaCounter then pcall(setMedusaCounter,false) end; if setBatCounter then pcall(setBatCounter,false) end; if setAutoSwing then pcall(setAutoSwing,false) end
                if setAutoCarry then pcall(setAutoCarry,false) end
                if hideButtonsSetter then pcall(hideButtonsSetter,false) end; if lockButtonsSetter then pcall(lockButtonsSetter,false) end
                if introSetter then pcall(introSetter,true) end
                if chromaSetter then pcall(chromaSetter,false) end
                if setKorbloxLeft then pcall(setKorbloxLeft,false) end; if setKorbloxRight then pcall(setKorbloxRight,false) end
                if stackBtnRefs then for key,ref in pairs(stackBtnRefs) do if ref and ref.setOn then pcall(ref.setOn,false) end end end
                if keybindBtnRefs then refreshAllKeybindButtons() end
                if refreshAnimButtons then pcall(refreshAnimButtons) end
                for i,def in ipairs(stackDefs) do local wrapper=stackWrappers[def.key]; if wrapper then TweenService:Create(wrapper,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=getDefaultStackPos(i)}):Play() end end
                resetAllBtn.Text="All Settings Reset!"; resetAllBtn.BackgroundColor3=Color3.fromRGB(46,120,92); if _G.FluidToast then _G.FluidToast("All settings reset", true) end
                task.delay(2,function() if resetAllBtn and resetAllBtn.Parent then resetAllBtn.Text="Reset All Settings"; resetAllBtn.BackgroundColor3=Color3.fromRGB(52,32,40) end end)
            end)
            makeGap(8); makeSectionHeader("Layout"); makeGap(2)
            local rWrap = Instance.new("Frame", currentPage); rWrap.Size = UDim2.new(1,0,0,46); rWrap.BackgroundTransparency=1; rWrap.BorderSizePixel=0; rWrap.LayoutOrder=LO()
            local resetBtn = Instance.new("TextButton", rWrap); resetBtn.Size = UDim2.new(1,-28,0,32); resetBtn.Position = UDim2.new(0,14,0,7); resetBtn.BackgroundColor3=C.btnBg; resetBtn.BorderSizePixel=0; resetBtn.Text="Reset Button Positions"; resetBtn.TextColor3=C.btnTxt; resetBtn.Font=Enum.Font.GothamBold; resetBtn.TextSize=12; resetBtn.ZIndex=5; mkCorner(resetBtn,6); mkStroke(resetBtn, C.btnBorder,1); mkSheen(resetBtn)
            resetBtn.MouseEnter:Connect(function() TweenService:Create(resetBtn,TweenInfo.new(0.1),{BackgroundColor3=C.btnHov}):Play() end)
            resetBtn.MouseLeave:Connect(function() TweenService:Create(resetBtn,TweenInfo.new(0.1),{BackgroundColor3=C.btnBg}):Play() end)
            resetBtn.MouseButton1Click:Connect(function()
                for i,def in ipairs(stackDefs) do local wrapper=stackWrappers[def.key]; if wrapper then TweenService:Create(wrapper,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=getDefaultStackPos(i)}):Play() end end
                resetBtn.Text="Positions Reset!"; task.delay(1.8,function() if resetBtn and resetBtn.Parent then resetBtn.Text="Reset Button Positions" end end)
            end)
            makeGap(10)
            local fw = Instance.new("Frame", currentPage); fw.Size = UDim2.new(1,0,0,22); fw.BackgroundTransparency=1; fw.BorderSizePixel=0; fw.LayoutOrder=LO()
            local fl = Instance.new("TextLabel", fw); fl.Size = UDim2.new(1,0,1,0); fl.BackgroundTransparency=1; fl.Text="fluid.vs  |  powered by fluid"; fl.TextColor3=Color3.fromRGB(110,110,110); fl.Font=Enum.Font.Gotham; fl.TextSize=10; fl.TextXAlignment=Enum.TextXAlignment.Center
            _G._VezySaveStatusLbl = fl
            _G._VezyFlashSave = function(success)
                if not _G._VezySaveStatusLbl or not _G._VezySaveStatusLbl.Parent then return end
                local lbl = _G._VezySaveStatusLbl
                if success then lbl.Text="Auto-saved"; lbl.TextColor3=Color3.fromRGB(200,200,200)
                else lbl.Text="Save failed"; lbl.TextColor3=Color3.fromRGB(250,250,250) end
                task.delay(1.5,function() if lbl and lbl.Parent then lbl.Text="fluid.vs  |  powered by fluid"; lbl.TextColor3=Color3.fromRGB(110,110,110) end end)
            end
        end)
        page.LayoutOrder = 6
    end

    -- ============================================================
    -- TAB BAR (animated underline + glow)
    -- ============================================================
    local tabBar = Instance.new("Frame", mainOuter)
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.Position = UDim2.new(0, 0, 0, TITLE_H + 1)
    tabBar.BackgroundColor3 = C.tabBarBg
    tabBar.BackgroundTransparency = 0.3
    tabBar.BorderSizePixel = 0
    tabBar.ZIndex = 5

    local tabDiv2 = Instance.new("Frame", mainOuter)
    tabDiv2.Size = UDim2.new(1, 0, 0, 1)
    tabDiv2.Position = UDim2.new(0, 0, 0, TITLE_H + 41)
    tabDiv2.BackgroundColor3 = C.tabBarDiv
    tabDiv2.BorderSizePixel = 0
    tabDiv2.ZIndex = 5

    local underline = Instance.new("Frame", tabBar)
    underline.Size = UDim2.new(0, 54, 0, 3)
    underline.Position = UDim2.new(0, 20, 1, -3)
    underline.BackgroundColor3 = C.tabUnderline
    underline.BorderSizePixel = 0
    underline.ZIndex = 8
    mkCorner(underline, 2)
    local ulGlow = Instance.new("Frame", tabBar)
    ulGlow.Size = UDim2.new(0, 54, 0, 10)
    ulGlow.Position = UDim2.new(0, 20, 1, -10)
    ulGlow.BackgroundColor3 = C.tabUnderline
    ulGlow.BackgroundTransparency = 0.88
    ulGlow.BorderSizePixel = 0
    ulGlow.ZIndex = 7
    mkCorner(ulGlow, 4)
    local ulGrad = mkGrad(underline, GRAD.onTop, GRAD.onBot, 0)
    registerChromaGrad(ulGrad)
    registerChromaColor(ulGlow, "BackgroundColor3", C.tabUnderline, true)

    local tabBtns = {}
    local activeTab = nil

    local function switchTab(name)
        if activeTab == name then return end
        activeTab = name
        for tName, page in pairs(tabPages) do
            page.Visible = (tName == name)
        end
        mainScroll.CanvasPosition = Vector2.new(0, 0)
        local btn = tabBtns[name]
        if btn then
            local xc = btn.Position.X.Offset + (btn.AbsoluteSize.X - 54) / 2
            TweenService:Create(underline, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, xc, 1, -3)}):Play()
            TweenService:Create(ulGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, xc, 1, -10)}):Play()
        end
        for tName, b in pairs(tabBtns) do
            local on = (tName == name)
            TweenService:Create(b, TweenInfo.new(0.18), {TextColor3 = on and C.tabActive or C.tabIdle}):Play()
            TweenService:Create(b, TweenInfo.new(0.18), {BackgroundTransparency = on and 0.92 or 1}):Play()
        end
    end

    do
        local pad = 8
        local innerW = WIN_W - pad * 2
        local bw = math.floor(innerW / #TABS)
        for i, tName in ipairs(TABS) do
            local b = Instance.new("TextButton", tabBar)
            b.Size = UDim2.new(0, bw, 0, 30)
            b.Position = UDim2.new(0, pad + (i - 1) * bw, 0.5, -15)
            b.BackgroundColor3 = C.tabActiveBg
            b.BackgroundTransparency = 1
            b.BorderSizePixel = 0
            b.Text = tName
            b.TextColor3 = C.tabIdle
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            b.ZIndex = 8
            b.AutoButtonColor = false
            mkCorner(b, 8); mkSheen(b)
            b.MouseEnter:Connect(function()
                if activeTab ~= tName then
                    TweenService:Create(b, TweenInfo.new(0.12), {TextColor3 = C.tabIdleHov}):Play()
                end
            end)
            b.MouseLeave:Connect(function()
                if activeTab ~= tName then
                    TweenService:Create(b, TweenInfo.new(0.12), {TextColor3 = C.tabIdle}):Play()
                end
            end)
            b.MouseButton1Click:Connect(function() switchTab(tName) end)
            tabBtns[tName] = b
        end
    end
    switchTab("Speed")

        rebuildPresetList = function()
        if not presetListFrame then return end
        for _,child in ipairs(presetListFrame:GetChildren()) do if child.Name~="EmptyLabel" and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end end
        local emptyLbl = presetListFrame:FindFirstChild("EmptyLabel")
        if emptyLbl then emptyLbl.Visible = (#Presets == 0) end
        for i,preset in ipairs(Presets) do
            local row = Instance.new("Frame", presetListFrame); row.Name="Preset_"..i; row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=C.presetBg; row.BorderSizePixel=0; row.LayoutOrder=i+1; mkCorner(row,6); mkStroke(row, C.presetBrd,1)
            local nameLbl = Instance.new("TextLabel", row); nameLbl.Size=UDim2.new(1,-94,1,0); nameLbl.Position=UDim2.new(0,10,0,0); nameLbl.BackgroundTransparency=1; nameLbl.Text=preset.name; nameLbl.TextColor3=C.rowLabel; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=12; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd
            local loadBtn = Instance.new("TextButton", row); loadBtn.Size=UDim2.new(0,44,0,26); loadBtn.Position=UDim2.new(1,-96,0.5,-13); loadBtn.BackgroundColor3=C.presetLoad; loadBtn.BorderSizePixel=0; loadBtn.Text="Load"; loadBtn.TextColor3=Color3.fromRGB(10,10,10); loadBtn.Font=Enum.Font.GothamBold; loadBtn.TextSize=11; loadBtn.ZIndex=9; mkCorner(loadBtn,5); mkSheen(loadBtn, 0.82)
            loadBtn.MouseEnter:Connect(function() TweenService:Create(loadBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(140,215,255)}):Play() end)
            loadBtn.MouseLeave:Connect(function() TweenService:Create(loadBtn,TweenInfo.new(0.1),{BackgroundColor3=C.presetLoad}):Play() end)
            loadBtn.MouseButton1Click:Connect(function()
                saveLastPresetName(preset.name); loadBtn.Text="OK"; task.delay(1.2,function() if loadBtn and loadBtn.Parent then loadBtn.Text="Load" end end)
            end)
            local delBtn = Instance.new("TextButton", row); delBtn.Size=UDim2.new(0,34,0,26); delBtn.Position=UDim2.new(1,-48,0.5,-13); delBtn.BackgroundColor3=C.presetDel; delBtn.BorderSizePixel=0; delBtn.Text="X"; delBtn.TextColor3=Color3.fromRGB(235,235,235); delBtn.Font=Enum.Font.GothamBold; delBtn.TextSize=11; delBtn.ZIndex=9; mkCorner(delBtn,5); mkSheen(delBtn)
            delBtn.MouseEnter:Connect(function() TweenService:Create(delBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(58,58,58)}):Play() end)
            delBtn.MouseLeave:Connect(function() TweenService:Create(delBtn,TweenInfo.new(0.1),{BackgroundColor3=C.presetDel}):Play() end)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(Presets,i); savePresetsFile(); rebuildPresetList()
            end)
        end
    end

    -- ============================================================
    -- INFO BAR
    -- ============================================================
    local infoBar = Instance.new("Frame", gui)
    infoBar.Size = UDim2.new(0,360,0,40); infoBar.Position = UDim2.new(0.5,-180,0.88,-22)
    infoBar.BackgroundColor3 = C.infoBg; infoBar.BorderSizePixel=0; infoBar.Active=true
    infoBar.BackgroundTransparency = 0.05
    mkCorner(infoBar,20)
    local ibStroke = mkStroke(infoBar, C.infoBrd, 1.5); ibStroke.Transparency = 0.3
    local ibsg = mkGrad(ibStroke, GRAD.onTop, GRAD.onBot, 0)
    registerChromaGrad(ibsg)
    registerChromaStroke(ibStroke, 0.05, 0.3, 2.2, 1.5)
    mkGrad(infoBar, Color3.fromRGB(255,255,255), Color3.fromRGB(190,215,255))
    mkShadow(gui, infoBar, 20, 3)
    local ibShine = Instance.new("Frame", infoBar)
    ibShine.Size = UDim2.new(1,-28,0,1); ibShine.Position = UDim2.new(0,14,0,1)
    ibShine.BackgroundColor3 = Color3.fromRGB(255,255,255); ibShine.BackgroundTransparency = 0.92; ibShine.BorderSizePixel = 0
    ibShine.ZIndex = 6

    local progressBg = Instance.new("Frame", infoBar)
    progressBg.Size = UDim2.new(0,152,1,-10); progressBg.Position = UDim2.new(0,5,0,5)
    progressBg.BackgroundColor3 = Color3.fromRGB(9,12,18); progressBg.BorderSizePixel=0; progressBg.ClipsDescendants=true
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(1,0)
    local pbStroke = mkStroke(progressBg, C.rowBorder, 1); pbStroke.Transparency = 0.6

    local progressFill = Instance.new("Frame", progressBg)
    progressFill.Size = UDim2.new(0,0,1,0); progressFill.BackgroundColor3 = C.infoFill
    progressFill.BorderSizePixel=0; Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1,0)
    local pfGrad = mkGrad(progressFill, GRAD.onTop, GRAD.onBot, 90)
    registerChromaGrad(pfGrad)

    local stealTextLbl = Instance.new("TextLabel", progressBg)
    stealTextLbl.Size = UDim2.new(0,60,1,0); stealTextLbl.Position = UDim2.new(0,12,0,0)
    stealTextLbl.BackgroundTransparency=1; stealTextLbl.Text="STEAL"; stealTextLbl.TextColor3=C.infoTxt
    stealTextLbl.Font = Enum.Font.GothamBlack; stealTextLbl.TextSize=12; stealTextLbl.TextXAlignment=Enum.TextXAlignment.Left
    stealTextLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    stealTextLbl.TextStrokeTransparency = 0.6
    stealTextLbl.ZIndex = 5

    local stealPctLbl = Instance.new("TextLabel", progressBg)
    stealPctLbl.Size = UDim2.new(0,50,1,0); stealPctLbl.Position = UDim2.new(1,-58,0,0)
    stealPctLbl.BackgroundTransparency=1; stealPctLbl.Text="0%"; stealPctLbl.TextColor3=C.infoFill
    stealPctLbl.Font = Enum.Font.GothamBlack; stealPctLbl.TextSize=13; stealPctLbl.TextXAlignment=Enum.TextXAlignment.Right
    stealPctLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    stealPctLbl.TextStrokeTransparency = 0.6
    stealPctLbl.ZIndex = 5

    local fpsIcon = Instance.new("TextLabel", infoBar)
    fpsIcon.Size = UDim2.new(0,26,0,18); fpsIcon.Position = UDim2.new(0,164,0.5,-9)
    fpsIcon.BackgroundTransparency=1; fpsIcon.Text="FPS"; fpsIcon.TextColor3=C.infoTxt
    fpsIcon.Font = Enum.Font.GothamBold; fpsIcon.TextSize=10; fpsIcon.TextXAlignment=Enum.TextXAlignment.Center

    local fpsVal = Instance.new("TextLabel", infoBar)
    fpsVal.Size = UDim2.new(0,40,0,18); fpsVal.Position = UDim2.new(0,190,0.5,-9)
    fpsVal.BackgroundTransparency=1; fpsVal.Text="0"; fpsVal.TextColor3=C.infoVal
    fpsVal.Font = Enum.Font.GothamBlack; fpsVal.TextSize=13; fpsVal.TextXAlignment=Enum.TextXAlignment.Left

    local pingIcon = Instance.new("TextLabel", infoBar)
    pingIcon.Size = UDim2.new(0,18,0,18); pingIcon.Position = UDim2.new(0,238,0.5,-9)
    pingIcon.BackgroundTransparency=1; pingIcon.Text="PING"; pingIcon.TextColor3=C.infoTxt
    pingIcon.Font = Enum.Font.GothamBold; pingIcon.TextSize=13; pingIcon.TextXAlignment=Enum.TextXAlignment.Center

    local pingVal = Instance.new("TextLabel", infoBar)
    pingVal.Size = UDim2.new(0,54,0,18); pingVal.Position = UDim2.new(0,258,0.5,-9)
    pingVal.BackgroundTransparency=1; pingVal.Text="0ms"; pingVal.TextColor3=C.infoVal
    pingVal.Font = Enum.Font.GothamBold; pingVal.TextSize=11; pingVal.TextXAlignment=Enum.TextXAlignment.Left

    local statusDotBg = Instance.new("Frame", infoBar)
    statusDotBg.Size = UDim2.new(0,24,0,24); statusDotBg.Position = UDim2.new(1,-34,0.5,-12)
    statusDotBg.BackgroundColor3 = Color3.fromRGB(16,22,32); statusDotBg.BorderSizePixel=0
    mkCorner(statusDotBg,12)
    local sdStroke = mkStroke(statusDotBg, C.infoBrd,1); sdStroke.Transparency = 0.4

    local statusDot = Instance.new("Frame", statusDotBg)
    statusDot.Size = UDim2.new(0,10,0,10); statusDot.Position = UDim2.new(0.5,-5,0.5,-5)
    statusDot.BackgroundColor3 = C.infoFill; statusDot.BorderSizePixel=0; mkCorner(statusDot,5)

    task.spawn(function()
        while statusDot and statusDot.Parent do
            TweenService:Create(statusDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.55}):Play()
            task.wait(0.9)
            if not (statusDot and statusDot.Parent) then break end
            TweenService:Create(statusDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
            task.wait(0.9)
        end
    end)

    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount+1
        local now = tick()
        if now-lastTime >= 1 then
            local fps = math.floor(frameCount/(now-lastTime))
            fpsVal.Text = tostring(fps)
            fpsVal.TextColor3 = fps >= 90 and Color3.fromRGB(120,225,255) or (fps >= 45 and Color3.fromRGB(235,244,255) or Color3.fromRGB(255,140,140))
            frameCount = 0; lastTime = now
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local ping = 0
                pcall(function()
                    local netStats = Stats:FindFirstChild("Network")
                    if netStats then
                        local sci = netStats:FindFirstChild("ServerStatsItem")
                        if sci then
                            local dp = sci:FindFirstChild("Data Ping")
                            if dp then ping = math.floor(dp:GetValue() or 0) end
                        end
                    end
                end)
                if pingVal then
                pingVal.Text = ping.."ms"
                pingVal.TextColor3 = ping < 90 and Color3.fromRGB(120,225,255) or (ping < 170 and Color3.fromRGB(255,200,120) or Color3.fromRGB(255,140,140))
            end
                if statusDot then statusDot.BackgroundColor3 = State.isStealing and Color3.fromRGB(120,225,255) or Color3.fromRGB(84,196,255) end
            end)
        end
    end)

    -- ============================================================
    -- STACK BUTTONS
    -- ============================================================
    local function updateLaggerButtons()
        if stackBtnRefs.lagger then stackBtnRefs.lagger.setOn(State.laggerMode==1) end
        if stackBtnRefs.laggerCarry then stackBtnRefs.laggerCarry.setOn(State.laggerMode==2) end
    end
    
    local function setLaggerMode(mode)
        if mode == State.laggerMode then return end
        local oldMode = State.laggerMode

        if mode == 0 then
            State.carrySpeed = State._prevCarry or 30
            State.speedToggled = State._prevSpeed or false
            if carryBox then
                carryBox.Text = tostring(State.speedToggled and State.carrySpeed or State.normalSpeed)
            end
            if stackBtnRefs.carrySpeed then
                stackBtnRefs.carrySpeed.setOn(State.speedToggled)
            end
        elseif mode == 1 then
            if oldMode == 0 then
                State._prevCarry = State.carrySpeed
                State._prevSpeed = State.speedToggled
            end
            State.speedToggled = false
            if stackBtnRefs.carrySpeed then
                stackBtnRefs.carrySpeed.setOn(false)
            end
            if carryBox then
                carryBox.Text = tostring(State.laggerSpeed)
            end
        elseif mode == 2 then
            if oldMode == 0 then
                State._prevCarry = State.carrySpeed
                State._prevSpeed = State.speedToggled
            end
            State.speedToggled = false
            if stackBtnRefs.carrySpeed then
                stackBtnRefs.carrySpeed.setOn(false)
            end
            if carryBox then
                carryBox.Text = tostring(State.laggerCarrySpeed)
            end
        end

        State.laggerMode = mode
        updateLaggerButtons()
        requestSave()
    end

    local function toggleLaggerMode()
        if State.laggerMode == 0 then
            setLaggerMode(1)
        elseif State.laggerMode == 1 then
            setLaggerMode(2)
        else
            setLaggerMode(1)
        end
    end

    local function toggleSpeed()
        if State.laggerMode ~= 0 then
            setLaggerMode(0)
            return
        end
        State.speedToggled = not State.speedToggled
        if stackBtnRefs.carrySpeed then
            stackBtnRefs.carrySpeed.setOn(State.speedToggled)
        end
        if carryBox then
            carryBox.Text = tostring(State.speedToggled and State.carrySpeed or State.normalSpeed)
        end
        requestSave()
    end

    -- ============================================================
    -- AUTO CARRY (Ace logic: force carry-speed while stealing / holding)
    -- ============================================================
    local function isCarryName(name)
        local n = tostring(name or ""):lower()
        return n:find("brainrot") or n:find("animal") or n:find("carry")
            or n:find("grab") or n:find("steal") or n:find("hold")
    end
    local function isIgnoredCarryTool(name)
        local n = tostring(name or ""):lower()
        return n:find("bat") or n:find("slap") or n:find("medusa")
            or n:find("head") or n:find("stone")
    end
    local function isCarryingBrainrot(char)
        if not char then return false end
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
                if child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
                    return true
                end
                if isCarryName(child.Name) then
                    return true
                end
            elseif child:IsA("Tool") and not isIgnoredCarryTool(child.Name) then
                return true
            end
        end
        return false
    end

    local function getCurrentSpeedModeName()
        if State.laggerMode == 1 then return "Lagger" end
        if State.laggerMode == 2 then return "Lagger Carry" end
        if State.speedToggled then return "Carry" end
        return "Normal"
    end
    local function fluidSetCarryMode(on)
        if State.laggerMode ~= 0 then setLaggerMode(0) end
        if State.speedToggled ~= on then
            State.speedToggled = on
            if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(on) end
            if carryBox then carryBox.Text = tostring(on and State.carrySpeed or State.normalSpeed) end
        end
    end

    local function enableCarrySpeedForSteal()
        State._waitingForCarryPickup = false
        State._carryPickupWatchUntil = 0
        if not State._autoCarryFromSteal then
            State._autoCarryReturnMode = getCurrentSpeedModeName()
        end
        State._autoCarryFromSteal = true
        State._autoCarryGraceUntil = tick() + 0.75
        local rm = State._autoCarryReturnMode
        local cur = getCurrentSpeedModeName()
        local wasLagger = (rm == "Lagger" or rm == "Lagger Carry" or cur == "Lagger" or cur == "Lagger Carry")
        if wasLagger then
            setLaggerMode(2)
        else
            fluidSetCarryMode(true)
        end
        pcall(requestSave)
    end

    local function disableAutoCarrySpeed()
        if not State._autoCarryFromSteal and not State._waitingForCarryPickup then return end
        local wasAutoApplied = State._autoCarryFromSteal == true
        local returnMode = State._autoCarryReturnMode
        State._autoCarryFromSteal = false
        State._waitingForCarryPickup = false
        State._autoCarryGraceUntil = 0
        State._carryPickupWatchUntil = 0
        State._autoCarryReturnMode = nil
        if not wasAutoApplied then return end
        if returnMode == "Lagger" then
            setLaggerMode(1)
        elseif returnMode == "Lagger Carry" then
            setLaggerMode(2)
        elseif returnMode == "Carry" then
            fluidSetCarryMode(true)
        else
            fluidSetCarryMode(false)
        end
        pcall(requestSave)
    end

    local function startAutoCarryPickupWatch(seconds)
        if State.autoCarryEnabled ~= true then return end
        State._waitingForCarryPickup = true
        State._carryPickupWatchUntil = tick() + (seconds or 1.25)
    end

    local _aceStealAttrWasActive = false
    RunService.RenderStepped:Connect(function()
        if State.autoCarryEnabled ~= true then
            disableAutoCarrySpeed()
            return
        end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root then
            disableAutoCarrySpeed()
            _aceStealAttrWasActive = false
            return
        end
        local st = hum:GetState()
        local gotHit = st == Enum.HumanoidStateType.Physics
            or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown
        local stealingAttr = LP:GetAttribute("Stealing") == true
        local carryingBrainrot = isCarryingBrainrot(char)
        if stealingAttr and not _aceStealAttrWasActive then
            _aceStealAttrWasActive = true
            enableCarrySpeedForSteal()
        elseif not stealingAttr then
            _aceStealAttrWasActive = false
        end
        if State._waitingForCarryPickup then
            if gotHit or tick() > (State._carryPickupWatchUntil or 0) then
                State._waitingForCarryPickup = false
                State._carryPickupWatchUntil = 0
            elseif carryingBrainrot then
                enableCarrySpeedForSteal()
            end
        end
        if carryingBrainrot and not State._autoCarryFromSteal then
            enableCarrySpeedForSteal()
        end
        if State._autoCarryFromSteal then
            local graceDone = tick() > (State._autoCarryGraceUntil or 0)
            if gotHit or (graceDone and not carryingBrainrot and not stealingAttr) then
                disableAutoCarrySpeed()
            end
        end
    end)

    _G.AutoCarrySpeed = {
        IsCarryingBrainrot = isCarryingBrainrot,
        Enable = enableCarrySpeedForSteal,
        Disable = disableAutoCarrySpeed,
        WatchPickup = startAutoCarryPickupWatch,
    }

    -- STACK BUTTONS LOOP
    for i,def in ipairs(stackDefs) do
        local btnFrame = Instance.new("TextButton", gui)
        btnFrame.Name = "StackBtn_"..def.key
        btnFrame.Size = UDim2.new(0,BTN_W,0,BTN_H)
        btnFrame.Position = getDefaultStackPos(i)
        -- White base so the UIGradient (which multiplies) is visible.
        btnFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btnFrame.BorderSizePixel=0
        btnFrame.AutoButtonColor = false
        btnFrame.Text = ""            -- caption lives on the child label below
        btnFrame.ZIndex=15
        btnFrame.ClipsDescendants = true
        mkCorner(btnFrame,12)
        local bStroke = mkStroke(btnFrame, C.stackBrd, 1)
        bStroke.Transparency = 0.25
        local stackGrad = mkGrad(btnFrame, GRAD.idleTop, GRAD.idleBot)
        local stackArt = mkBackdrop(btnFrame, 12, btnFrame.ZIndex)
        mkShadow(gui, btnFrame, 12, 3)
        -- Caption as a child: renders above the gradient, and UIGradient does
        -- not cascade to descendants, so the text keeps its own colour.
        local stackLbl = Instance.new("TextLabel", btnFrame)
        stackLbl.Name = "Label"
        stackLbl.Size = UDim2.new(1,0,1,0)
        stackLbl.BackgroundTransparency = 1
        stackLbl.Text = def.label
        stackLbl.TextColor3 = C.stackTxt
        stackLbl.TextScaled = false; stackLbl.TextSize = 11
        stackLbl.Font = Enum.Font.GothamBold
        stackLbl.TextWrapped = true; stackLbl.LineHeight = 1.2
        stackLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        stackLbl.TextStrokeTransparency = 0.55   -- keeps text off the contour lines
        stackLbl.ZIndex = btnFrame.ZIndex + 1
        stackWrappers[def.key] = btnFrame

        local btnState = false
        local function setOn(on)
            btnState = on
            if on then
                registerChromaGrad(stackGrad)
                TweenService:Create(btnFrame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {Size = UDim2.new(0, BTN_W+4, 0, BTN_H+4)}):Play()
                task.delay(0.12, function()
                    TweenService:Create(btnFrame, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, BTN_W, 0, BTN_H)}):Play()
                end)
            else
                unregisterChromaGrad(stackGrad)
            end
            stackGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, on and GRAD.onTop or GRAD.idleTop),
                ColorSequenceKeypoint.new(1, on and GRAD.onBot or GRAD.idleBot),
            })
            -- fade the art back on the white active state so the dark
            -- caption keeps its contrast
            TweenService:Create(stackArt,TweenInfo.new(0.15),{
                ImageTransparency = on and UI_ART_ACTIVE or UI_ART_IDLE
            }):Play()
            TweenService:Create(stackLbl,TweenInfo.new(0.15),{
                TextColor3 = on and C.stackActTxt or C.stackTxt
            }):Play()
            TweenService:Create(bStroke,TweenInfo.new(0.15),{
                Color = on and C.stackActBrd or C.stackBrd
            }):Play()
        end
        stackBtnRefs[def.key] = {setOn = setOn, _btnFrame = btnFrame}
        btnFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                mkRipple(btnFrame, BTN_W)
                TweenService:Create(btnFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, BTN_W-5, 0, BTN_H-5)}):Play()
            end
        end)
        local function releaseStackBtn()
            TweenService:Create(btnFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, BTN_W, 0, BTN_H)}):Play()
        end
        btnFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then releaseStackBtn() end
        end)
        btnFrame.MouseLeave:Connect(releaseStackBtn)

        local function onTap()
            if def.key == "tpDown" then
                task.spawn(function() if runTPDown then pcall(runTPDown) end; setOn(true); task.wait(0.12); setOn(false) end)
                return
            end
            if def.key == "drop" then
                task.spawn(function() pcall(runDrop) end)
                return
            end
            if def.key == "tpBat" then
                task.spawn(function()
                    toggleTPBat()  -- Toggle ON/OFF
                end)
                return
            end
            if def.key == "reset" then
                task.spawn(function() 
                    pcall(instaReset)
                    setOn(true)
                    task.wait(0.3)
                    setOn(false)
                end)
                return
            end
            if def.key == "carrySpeed" then
                if State.laggerMode~=0 then return end
                State.speedToggled = not State.speedToggled
                setOn(State.speedToggled)
                if carryBox then carryBox.Text = tostring(State.speedToggled and State.carrySpeed or State.normalSpeed) end
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
            local ns = not btnState; setOn(ns)
            if def.key == "autoLeft" then
                State.autoLeftEnabled = ns
                if ns and State.batAimbotToggled then State.batAimbotToggled=false; stopBatAimbot(); if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end end
                if ns then startAutoLeft() else stopAutoLeft() end
            elseif def.key == "autoRight" then
                State.autoRightEnabled = ns
                if ns and State.batAimbotToggled then State.batAimbotToggled=false; stopBatAimbot(); if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end end
                if ns then startAutoRight() else stopAutoRight() end
            elseif def.key == "aimbot" then
                State.batAimbotToggled = ns
                if ns then
                    if State.autoLeftEnabled then State.autoLeftEnabled=false; stopAutoLeft(); if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
                    if State.autoRightEnabled then State.autoRightEnabled=false; stopAutoRight(); if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end
                    pcall(startBatAimbot)
                else stopBatAimbot() end
            end
            requestSave()
        end

        makeStackDraggable(btnFrame, onTap)
    end

    -- ============================================================
    -- CHARACTER SETUP
    -- ============================================================
    local function setupChar(char)
        task.wait(0.1)
        h=char:WaitForChild("Humanoid",5)
        hrp=char:WaitForChild("HumanoidRootPart",5)
        if not h or not hrp then return end
        local head=char:FindFirstChild("Head")
        if head then
            for _,_bbn in ipairs({"FluidVSBB","FluidVSBB","GreenDuelsBB"}) do
                local _old=head:FindFirstChild(_bbn); if _old then _old:Destroy() end
            end
            local bb=Instance.new("BillboardGui", head); bb.Name="FluidVSBB"; bb.Size=UDim2.new(0,180,0,100); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
            local list=Instance.new("UIListLayout",bb); list.FillDirection=Enum.FillDirection.Vertical; list.SortOrder=Enum.SortOrder.LayoutOrder; list.VerticalAlignment=Enum.VerticalAlignment.Center; list.Padding=UDim.new(0,2)
            local speedBillLbl=Instance.new("TextLabel",bb); speedBillLbl.Name="SpeedBillLbl"; speedBillLbl.Size=UDim2.new(1,0,0,24); speedBillLbl.BackgroundTransparency=1; speedBillLbl.Text="0.0"; speedBillLbl.TextColor3=Color3.fromRGB(255,255,255); speedBillLbl.Font=Enum.Font.GothamBlack; speedBillLbl.TextScaled=true; speedBillLbl.TextStrokeTransparency=0.1; speedBillLbl.TextStrokeColor3=Color3.new(0,0,0); speedBillLbl.LayoutOrder=1
            local discordLbl=Instance.new("TextLabel",bb); discordLbl.Size=UDim2.new(1,0,0,22); discordLbl.BackgroundTransparency=1; discordLbl.Text="fluid.vs"; discordLbl.TextColor3=Color3.fromRGB(200,200,200); discordLbl.Font=Enum.Font.GothamBold; discordLbl.TextScaled=true; discordLbl.TextStrokeTransparency=0.1; discordLbl.TextStrokeColor3=Color3.new(0,0,0); discordLbl.LayoutOrder=2
            local ragTimerLbl=Instance.new("TextLabel",bb); ragTimerLbl.Name="RagdollTimerLbl"; ragTimerLbl.Size=UDim2.new(1,0,0,30); ragTimerLbl.BackgroundTransparency=1; ragTimerLbl.Text=""; ragTimerLbl.TextColor3=Color3.fromRGB(245,245,245); ragTimerLbl.Font=Enum.Font.GothamBlack; ragTimerLbl.TextScaled=true; ragTimerLbl.TextStrokeTransparency=0.1; ragTimerLbl.TextStrokeColor3=Color3.new(0,0,0); ragTimerLbl.LayoutOrder=3
        end
        stopAntiRagdoll()
        Steal.Data={}
        _rtTimerActive = false
        local _rtLbl = getRagTimerLbl and getRagTimerLbl()
        if _rtLbl then _rtLbl.Text = "" end
        task.spawn(function() startRagTimerDetection(char) end)
        if State.antiRagdollEnabled then task.wait(0.5); startAntiRagdoll() end
        if State.medusaCounterEnabled then setupMedusaCounter(char) end
        if State.batAimbotToggled then stopBatAimbot(); task.wait(0.2); pcall(startBatAimbot) end
        if State.batCounterEnabled then task.wait(0.3); startBatCounter() end
        if State.tryardAnimEnabled then saveOriginalTryardAnims(char); applyTryardAnimPack(char) end
        -- TP Bat setup
        tpBatH = char:FindFirstChildOfClass("Humanoid")
        tpBatHRP = char:FindFirstChild("HumanoidRootPart")
        if tpBatToggled then startTPBat() end
    end
    LP.CharacterAdded:Connect(setupChar)
    if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

    -- ============================================================
    -- AUTO LEFT / RIGHT
    -- ============================================================
    stopAutoLeft = function()
        if alConn then alConn:Disconnect(); alConn = nil end; alPhase = 1
        local char = LP.Character; if char then local hum2 = char:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero, false) end end
        if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end
    end
    stopAutoRight = function()
        if arConn then arConn:Disconnect(); arConn = nil end; arPhase = 1
        local char = LP.Character; if char then local hum2 = char:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero, false) end end
        if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end
    end

    startAutoLeft = function()
        if alConn then alConn:Disconnect() end; alPhase = 1
        alConn = RunService.Heartbeat:Connect(function()
            if not State.autoLeftEnabled then return end
            local char = LP.Character; if not char then return end
            local hrp2 = char:FindFirstChild("HumanoidRootPart")
            local hum2 = char:FindFirstChildOfClass("Humanoid")
            if not hrp2 or not hum2 then return end
            local spd = State.normalSpeed
            if alPhase == 1 then
                local tgt = Vector3.new(AP_L1.X, hrp2.Position.Y, AP_L1.Z)
                if (tgt - hrp2.Position).Magnitude < 1 then
                    alPhase = 2
                    local d = AP_L2 - hrp2.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                    hum2:Move(mv, false); hrp2.AssemblyLinearVelocity = Vector3.new(mv.X*spd, hrp2.AssemblyLinearVelocity.Y, mv.Z*spd); return
                end
                local d = AP_L1 - hrp2.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum2:Move(mv, false); hrp2.AssemblyLinearVelocity = Vector3.new(mv.X*spd, hrp2.AssemblyLinearVelocity.Y, mv.Z*spd)
            elseif alPhase == 2 then
                local tgt = Vector3.new(AP_L2.X, hrp2.Position.Y, AP_L2.Z)
                if (tgt - hrp2.Position).Magnitude < 1 then
                    hum2:Move(Vector3.zero, false); hrp2.AssemblyLinearVelocity = Vector3.zero
                    State.autoLeftEnabled = false; if alConn then alConn:Disconnect(); alConn = nil end
                    alPhase = 1; if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end
                    if (AP_L_FACE - hrp2.Position).Magnitude > 0.01 then
                        hrp2.CFrame = CFrame.new(hrp2.Position, Vector3.new(AP_L_FACE.X, hrp2.Position.Y, AP_L_FACE.Z))
                    end
                    return
                end
                local d = AP_L2 - hrp2.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum2:Move(mv, false); hrp2.AssemblyLinearVelocity = Vector3.new(mv.X*spd, hrp2.AssemblyLinearVelocity.Y, mv.Z*spd)
            end
        end)
    end

    startAutoRight = function()
        if arConn then arConn:Disconnect() end; arPhase = 1
        arConn = RunService.Heartbeat:Connect(function()
            if not State.autoRightEnabled then return end
            local char = LP.Character; if not char then return end
            local hrp2 = char:FindFirstChild("HumanoidRootPart")
            local hum2 = char:FindFirstChildOfClass("Humanoid")
            if not hrp2 or not hum2 then return end
            local spd = State.normalSpeed
            if arPhase == 1 then
                local tgt = Vector3.new(AP_R1.X, hrp2.Position.Y, AP_R1.Z)
                if (tgt - hrp2.Position).Magnitude < 1 then
                    arPhase = 2
                    local d = AP_R2 - hrp2.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                    hum2:Move(mv, false); hrp2.AssemblyLinearVelocity = Vector3.new(mv.X*spd, hrp2.AssemblyLinearVelocity.Y, mv.Z*spd); return
                end
                local d = AP_R1 - hrp2.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum2:Move(mv, false); hrp2.AssemblyLinearVelocity = Vector3.new(mv.X*spd, hrp2.AssemblyLinearVelocity.Y, mv.Z*spd)
            elseif arPhase == 2 then
                local tgt = Vector3.new(AP_R2.X, hrp2.Position.Y, AP_R2.Z)
                if (tgt - hrp2.Position).Magnitude < 1 then
                    hum2:Move(Vector3.zero, false); hrp2.AssemblyLinearVelocity = Vector3.zero
                    State.autoRightEnabled = false; if arConn then arConn:Disconnect(); arConn = nil end
                    arPhase = 1; if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end
                    if (AP_R_FACE - hrp2.Position).Magnitude > 0.01 then
                        hrp2.CFrame = CFrame.new(hrp2.Position, Vector3.new(AP_R_FACE.X, hrp2.Position.Y, AP_R_FACE.Z))
                    end
                    return
                end
                local d = AP_R2 - hrp2.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum2:Move(mv, false); hrp2.AssemblyLinearVelocity = Vector3.new(mv.X*spd, hrp2.AssemblyLinearVelocity.Y, mv.Z*spd)
            end
        end)
    end

    -- ============================================================
    -- HELPER FUNCTIONS
    -- ============================================================
    local function resetProgressBar() stealPctLbl.Text="0%"; progressFill.Size=UDim2.new(0,0,1,0) end

    local _aimbotTarget=nil
    local function findBat()
        local char=LP.Character; if not char then return nil end
        for _,tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end
        local bp=LP:FindFirstChild("Backpack"); if bp then for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end end end
        return nil
    end
    -- (old getClosestTarget removed: the new aimbot uses getAimbotEnemy,
    --  which also returns the character, head and dynamic hitbox part)
    -- ============================================================
    -- BAT AIMBOT  (ported "fears" logic)
    -- Dynamic hitbox + facing prediction + behind-target approach,
    -- and unlike the previous engine it actually swings the bat.
    -- ============================================================
    local AIMBOT_SPEED            = 56.5
    local HIT_DISTANCE            = 5
    local SWING_COOLDOWN          = 0.08
    local BEHIND_DISTANCE         = -3
    local BASE_PREDICTION         = 0.15
    local FACING_PREDICTION       = 1.5
    local PREDICTION_RADIUS_LIMIT = 10
    local Y_TRACK_GAIN            = 20
    local Y_PRED_CLAMP            = 8

    -- Pick head / chest / legs depending on where the enemy is vertically.
    local function getAimbotTargetPart(targetChar, myPos)
        local tHead  = targetChar:FindFirstChild("Head")
        local tHRP   = targetChar:FindFirstChild("HumanoidRootPart")
        local tUpper = targetChar:FindFirstChild("UpperTorso")
        local tLower = targetChar:FindFirstChild("LowerTorso")
        if not tHead or not tHRP then return tHRP end
        local headY, myY = tHead.Position.Y, myPos.Y
        if headY > myY + 3 then
            return tHead                     -- enemy above  -> head
        elseif myY > headY + 3 then
            return tLower or tHRP            -- enemy below  -> legs
        else
            return tUpper or tHRP            -- same level   -> chest
        end
    end

    local function getAimbotEnemy()
        local char = LP.Character
        if not char then return nil end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local myPos = myHRP.Position
        local bestDist = math.huge
        local bChar, bHRP, bHead, bPart = nil, nil, nil, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local tChar = plr.Character
                local tHRP  = tChar:FindFirstChild("HumanoidRootPart")
                local tHum  = tChar:FindFirstChildOfClass("Humanoid")
                if tHRP and tHum and tHum.Health > 0 then
                    local d = (myPos - tHRP.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bChar, bHRP = tChar, tHRP
                        bHead = tChar:FindFirstChild("Head")
                        bPart = getAimbotTargetPart(tChar, myPos)
                    end
                end
            end
        end
        return bChar, bestDist, bHRP, bHead, bPart
    end

    local function swingAimbotBat(targetChar)
        if State.hittingCooldown then return end
        State.hittingCooldown = true
        pcall(function()
            local bat = findBat()
            if bat then
                -- equip first: firetouchinterest needs the handle in-world
                if bat.Parent ~= LP.Character then
                    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(bat) end) end
                end
                local handle = bat:FindFirstChild("Handle")
                if handle and targetChar then
                    local tHead = targetChar:FindFirstChild("Head")
                    if tHead and firetouchinterest then
                        pcall(function()
                            firetouchinterest(handle, tHead, 0)
                            firetouchinterest(handle, tHead, 1)
                        end)
                    end
                end
                local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
                if remote then pcall(function() remote:FireServer() end)
                else pcall(function() bat:Activate() end) end
            end
        end)
        task.delay(SWING_COOLDOWN, function() State.hittingCooldown = false end)
    end

    startBatAimbot = function()
        if Conns.aimbot then Conns.aimbot:Disconnect() end
        if State.autoLeftEnabled then State.autoLeftEnabled=false; if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end; stopAutoLeft() end
        if State.autoRightEnabled then State.autoRightEnabled=false; if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end; stopAutoRight() end
        local hum0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum0 then hum0.AutoRotate=false end

        Conns.aimbot = RunService.Heartbeat:Connect(function()
            if not State.batAimbotToggled then return end
            local char = LP.Character; if not char then return end
            local myHRP = char:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            if not char:FindFirstChildOfClass("Tool") then
                local bat = findBat()
                if bat then pcall(function() hum:EquipTool(bat) end) end
            end

            local targetChar, dist, targetHRP, targetHead, targetPart = getAimbotEnemy()
            if targetChar and targetHRP and targetPart then
                _aimbotTarget = targetHRP
                local myPos     = myHRP.Position
                local currentVel = targetHRP.AssemblyLinearVelocity
                local targetPos  = targetPart.Position
                local headPos    = targetHead and targetHead.Position or targetPos

                -- facing prediction + velocity lead
                local facingOffset = targetHRP.CFrame.LookVector * FACING_PREDICTION
                local predictedPos = targetPos + facingOffset + (currentVel * BASE_PREDICTION)

                -- clamp how far the prediction may stray
                local predOffset = predictedPos - targetPos
                if predOffset.Magnitude > PREDICTION_RADIUS_LIMIT then
                    predictedPos = targetPos + predOffset.Unit * PREDICTION_RADIUS_LIMIT
                end

                -- horizontal approach, stopping behind the target
                local flatDir = Vector3.new(predictedPos.X - myPos.X, 0, predictedPos.Z - myPos.Z)
                if flatDir.Magnitude < 0.01 then flatDir = Vector3.new(0, 0, 0.01) end
                local standPos = predictedPos - (flatDir.Unit * BEHIND_DISTANCE)

                -- vertical tracking
                local headY = headPos.Y
                local predictedY = headY + (currentVel.Y * BASE_PREDICTION)
                local dY = predictedY - headY
                if math.abs(dY) > Y_PRED_CLAMP then
                    predictedY = headY + (dY / math.abs(dY)) * Y_PRED_CLAMP
                end
                local yVel = math.clamp((headY - myPos.Y) * Y_TRACK_GAIN, -120, 120)

                local finalAimPoint = Vector3.new(standPos.X, predictedY, standPos.Z)
                local moveDir  = finalAimPoint - myPos
                local finalDir = moveDir.Magnitude > 0.5 and moveDir.Unit or flatDir.Unit

                myHRP.AssemblyLinearVelocity = Vector3.new(
                    finalDir.X * AIMBOT_SPEED,
                    yVel,
                    finalDir.Z * AIMBOT_SPEED
                )

                -- face the target (kept from the old engine: AutoRotate is off)
                local lookAt = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
                if (lookAt - myPos).Magnitude > 0.01 then
                    myHRP.CFrame = CFrame.new(myPos, lookAt)
                end

                -- Swing whenever in range, matching the source logic.
                -- (Not gated behind the "Auto Swing" toggle: that toggle
                --  defaults to false, which would disable this entirely.)
                local headDist = (headPos - myPos).Magnitude
                if headDist <= HIT_DISTANCE then
                    swingAimbotBat(targetChar)
                end
            else
                _aimbotTarget = nil
                myHRP.AssemblyLinearVelocity = Vector3.zero
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

    local _rtTimerActive = false
    local function getRagTimerLbl()
        local char = LP.Character; if not char then return nil end
        local head = char:FindFirstChild("Head"); if not head then return nil end
        local bb = head:FindFirstChild("FluidVSBB"); if not bb then return nil end
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
                    lbl.TextColor3 = Color3.fromRGB(235,235,235)
                end
                task.wait(0.1)
                t = math.round((t - 0.1) * 10) / 10
            end
            local lbl = getRagTimerLbl()
            if lbl then lbl.Text = "STEAL!"; lbl.TextColor3 = Color3.fromRGB(255,255,255) end
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
    -- AUTO-STEAL
    -- ============================================================
    local isStealing=false
    local stealProgressConn=nil
    local function updateProgressBar(progress) if progressFill and stealPctLbl then progressFill.Size=UDim2.new(progress,0,1,0); stealPctLbl.Text=math.floor(progress*100).."%" end end
    local function resetProgressBar() updateProgressBar(0) end
    local function getHRP() local char=LP.Character; if char then return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end; return nil end
    local function isMyPlot(plotName)
        local plots=workspace:FindFirstChild("Plots"); if not plots then return false end
        local plot=plots:FindFirstChild(plotName); if not plot then return false end
        local sign=plot:FindFirstChild("PlotSign"); if sign then local yb=sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled==true end end
        return false
    end
    local function findNearestPrompt()
        local hrp=getHRP(); if not hrp then return nil end
        local plots=workspace:FindFirstChild("Plots"); if not plots then return nil end
        local bestPrompt,bestDist=nil,math.huge
        local radius=Steal.StealRadius
        for _,plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") and not isMyPlot(plot.Name) then
                local pods=plot:FindFirstChild("AnimalPodiums")
                if pods then
                    for _,pod in ipairs(pods:GetChildren()) do
                        local base=pod:FindFirstChild("Base"); if base then
                            local spawn=base:FindFirstChild("Spawn"); if spawn then
                                local dist=(spawn.Position-hrp.Position).Magnitude
                                if dist<=radius and dist<bestDist then
                                    local att=spawn:FindFirstChild("PromptAttachment")
                                    if att then
                                        for _,prompt in ipairs(att:GetChildren()) do
                                            if prompt:IsA("ProximityPrompt") and prompt.ActionText and prompt.ActionText:find("Steal") then bestPrompt,bestDist=prompt,dist end
                                        end
                                    end
                                    if not bestPrompt then
                                        for _,prompt in ipairs(spawn:GetDescendants()) do
                                            if prompt:IsA("ProximityPrompt") and prompt.ActionText and prompt.ActionText:find("Steal") then bestPrompt,bestDist=prompt,dist end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return bestPrompt
    end
    local stealDataCache={}
    local function executeSteal(prompt)
        if isStealing then return end
        if not stealDataCache[prompt] then
            local data={hold={},trigger={},ready=true}
            if getconnections then
                local holds=getconnections(prompt.PromptButtonHoldBegan)
                for _,conn in ipairs(holds) do if conn.Function then table.insert(data.hold,conn.Function) end end
                local triggers=getconnections(prompt.Triggered)
                for _,conn in ipairs(triggers) do if conn.Function then table.insert(data.trigger,conn.Function) end end
            end
            stealDataCache[prompt]=data
        end
        local data=stealDataCache[prompt]
        if not data.ready then return end
        data.ready=false
        isStealing=true; State.isStealing=true
        local startTime=tick(); local duration=Steal.StealDuration
        if stealProgressConn then stealProgressConn:Disconnect() end
        stealProgressConn=RunService.Heartbeat:Connect(function()
            if not isStealing then if stealProgressConn then stealProgressConn:Disconnect(); stealProgressConn=nil end; return end
            local elapsed=tick()-startTime; local prog=math.clamp(elapsed/duration,0,1); updateProgressBar(prog)
        end)
        task.spawn(function()
            for _,fn in ipairs(data.hold) do task.spawn(fn) end
            local elapsed=0
            while elapsed<duration do elapsed=elapsed+task.wait() end
            for _,fn in ipairs(data.trigger) do task.spawn(fn) end
            task.wait(0.05)
            if stealProgressConn then stealProgressConn:Disconnect(); stealProgressConn=nil end
            resetProgressBar(); data.ready=true; isStealing=false; State.isStealing=false
        end)
    end
    local autoStealConn=nil
    startAutoSteal = function()
        if autoStealConn then return end
        autoStealConn = RunService.Heartbeat:Connect(function()
            if not Steal.AutoStealEnabled or isStealing then return end
            local success,prompt=pcall(findNearestPrompt)
            if success and prompt then pcall(executeSteal,prompt) end
        end)
    end
    stopAutoSteal = function()
        if autoStealConn then autoStealConn:Disconnect(); autoStealConn=nil end
        if stealProgressConn then stealProgressConn:Disconnect(); stealProgressConn=nil end
        isStealing=false; State.isStealing=false; resetProgressBar(); stealDataCache={}
    end

    -- ============================================================
    -- WEBHOOK MONITOR (DUEL WINS - ALWAYS ON, NO UI)
    -- ============================================================
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1515585744570286149/yN5O_-tZ3TJM7pwZ_2nxKm2vK7rpWl5Gg-bfh9XDAI11jSV2Gzh_qz2N6SnBuMFOPvQT"

    if _request then
        task.spawn(function()
            local function num(v)
                v = tostring(v):gsub("%s","")
                local n,s = v:match("([%d%.]+)(%a?)")
                n = tonumber(n) or 0
                if s == "K" or s == "k" then
                    n = n * 1e3
                elseif s == "M" or s == "m" then
                    n = n * 1e6
                elseif s == "B" or s == "b" then
                    n = n * 1e9
                elseif s == "T" or s == "t" then
                    n = n * 1e12
                end
                return n
            end
            
            local function short(n)
                if n >= 1e12 then
                    return string.format("%.1fT", n/1e12)
                elseif n >= 1e9 then
                    return string.format("%.1fB", n/1e9)
                elseif n >= 1e6 then
                    return string.format("%.1fM", n/1e6)
                elseif n >= 1e3 then
                    return string.format("%.1fK", n/1e3)
                end
                return tostring(math.floor(n))
            end
            
            local p3 = Vector3.new(-476.752, 10.464, 7.107)
            local p7 = Vector3.new(-476.752, 10.464, 114.107)
            
            local function myPlot()
                for _,v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "PlotSign" then
                        local d3 = (v.Position - p3).Magnitude
                        local d7 = (v.Position - p7).Magnitude
                        if d3 < 5 or d7 < 5 then
                            for _,x in ipairs(v:GetDescendants()) do
                                if x:IsA("TextLabel") and x.Text ~= "" then
                                    if x.Text:find(LP.Name) or x.Text:find(LP.DisplayName) then
                                        return d3 < 5 and 3 or 7
                                    end
                                end
                            end
                        end
                    end
                end
                return nil
            end
            
            local lastSend = ""
            local lastSendTime = 0
            
            while task.wait(1) do
                local mine = myPlot()
                if not mine then continue end
                local pos = mine == 3 and p7 or p3
                local best, bestVal = nil, nil
                
                local db = workspace:FindFirstChild("Debris")
                if not db then continue end
                
                for _,v in ipairs(db:GetChildren()) do
                    if v.Name ~= "FastOverheadTemplate" then continue end
                    local sg = v:FindFirstChildOfClass("SurfaceGui")
                    if not sg or not sg.Adornee then continue end
                    if (sg.Adornee.Position - pos).Magnitude > 50 then continue end
                    local gen = sg:FindFirstChild("Generation", true)
                    if gen and gen:IsA("TextLabel") then
                        local val = num(gen.Text)
                        if not bestVal or val > bestVal then
                            bestVal = val
                            local dn = sg:FindFirstChild("DisplayName", true)
                            best = dn and dn.Text or v.Name
                        end
                    end
                end
                
                if best and bestVal then
                    local identifier = best .. "_" .. tostring(bestVal)
                    if identifier ~= lastSend and tick() - lastSendTime > 10 then
                        lastSend = identifier
                        lastSendTime = tick()
                        pcall(function()
                            _request({
                                Url = WEBHOOK_URL,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({
                                    embeds = {{
                                        title = "DUEL WON",
                                        color = 65280,
                                        fields = {
                                            {name="Display", value=LP.DisplayName, inline=true},
                                            {name="User", value=LP.Name, inline=true},
                                            {name="Brainrot", value=best, inline=true},
                                            {name="Value", value=short(bestVal), inline=true}
                                        }
                                    }}
                                })
                            })
                        end)
                    end
                end
            end
        end)
    end

    -- ============================================================
    -- MODULES
    -- ============================================================
    _G._NukeOn=false; _G._NukeConns={}; _G._NukeThreads={}
    _G._nukeStart = function()
        if _G._NukeOn then return end; _G._NukeOn=true
        local Lighting=game:GetService("Lighting"); local MaterialService=game:GetService("MaterialService")
        local XMin,XMax=-560,-240
        local ClothingClasses={"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
        local BASE_NAMES={"baseplate","spawnlocation","spawn location","spawn"}
        local function SafeDestroy(obj) if obj.Name=="Overhead" then return end pcall(function() obj:Destroy() end) end
        local function IsClothing(obj) for _,c in ipairs(ClothingClasses) do if obj:IsA(c) then return true end end return false end
        local function IsCharacterPart(obj) for _,plr in ipairs(Players:GetPlayers()) do if plr.Character and obj:IsDescendantOf(plr.Character) then return true end end return false end
        local function IsOutOfRange(obj) if obj:IsA("BasePart") then local x=obj.Position.X; return x<XMin or x>XMax end return false end
        local function IsBase(obj) if not obj:IsA("BasePart") then return false end local nl=obj.Name:lower(); for _,n in ipairs(BASE_NAMES) do if nl:find(n,1,true) then return true end end return false end
        local function IsInBase(obj) local p=obj.Parent; while p and p~=workspace do if IsBase(p) then return true end p=p.Parent end return false end
        local function MakeTransparent(obj) pcall(function() if IsBase(obj) and not IsCharacterPart(obj) then obj.Transparency=1; obj.CastShadow=false end end) end
        local function StripObject(obj) pcall(function() if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then SafeDestroy(obj) elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then pcall(function() obj.Enabled=false end); SafeDestroy(obj) elseif obj:IsA("SurfaceAppearance") then SafeDestroy(obj) elseif obj:IsA("BasePart") then obj.CastShadow=false; obj.Material=Enum.Material.Plastic; obj.MaterialVariant=""; obj.Reflectance=0 end end) end
        local function CleanObject(obj) pcall(function() if obj:IsA("SurfaceAppearance") then SafeDestroy(obj) elseif obj:IsA("Decal") or obj:IsA("Texture") then if not (obj.Name=="face" and obj.Parent and obj.Parent.Name=="Head") then SafeDestroy(obj) end elseif obj:IsA("SpecialMesh") then obj.TextureId="" elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then SafeDestroy(obj) elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then SafeDestroy(obj) elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then SafeDestroy(obj) elseif obj:IsA("Animation") or obj:IsA("AnimationController") then if not IsCharacterPart(obj) then SafeDestroy(obj) end elseif obj:IsA("BasePart") then obj.CastShadow=false; obj.Material=Enum.Material.Plastic; obj.MaterialVariant=""; obj.Reflectance=0 end end) end
        local function ApplyGreySky() pcall(function() for _,obj in ipairs(Lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end; local sky=Instance.new("Sky"); sky.SkyboxBk=""; sky.SkyboxDn=""; sky.SkyboxFt=""; sky.SkyboxLf=""; sky.SkyboxRt=""; sky.SkyboxUp=""; sky.CelestialBodiesShown=false; sky.Name="_VezyNukeSky"; sky.Parent=Lighting end) end
        local function OptimizeLighting() Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.FogStart=9e9; Lighting.EnvironmentDiffuseScale=0; Lighting.EnvironmentSpecularScale=0; Lighting.Brightness=1.5; Lighting.Ambient=Color3.fromRGB(60,60,60); for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v:Destroy() end end; ApplyGreySky() end
        local function ApplyTerrain() pcall(function() local T=workspace.Terrain; T.Decoration=false; T.WaterWaveSize=0; T.WaterWaveSpeed=0; T.WaterReflectance=0; T.WaterTransparency=1 end) end
        local function OptimizeCharacter(char) if not char then return end task.spawn(function() task.wait(0.3); if not _G._NukeOn then return end; for _,obj in ipairs(char:GetDescendants()) do if IsClothing(obj) then SafeDestroy(obj) else CleanObject(obj) end end end) end
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01; settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01 end)
        pcall(function() if setfpscap then setfpscap(999) end end)
        table.insert(_G._NukeThreads,task.spawn(function() if not game:IsLoaded() then game.Loaded:Wait() end; OptimizeLighting(); ApplyTerrain(); for _,obj in ipairs(workspace:GetDescendants()) do if not _G._NukeOn then return end; if IsBase(obj) then MakeTransparent(obj) elseif IsClothing(obj) then SafeDestroy(obj) elseif IsInBase(obj) then elseif IsCharacterPart(obj) then elseif IsOutOfRange(obj) then SafeDestroy(obj) else CleanObject(obj); StripObject(obj) end end; for _,obj in ipairs(workspace:GetDescendants()) do MakeTransparent(obj) end end))
        table.insert(_G._NukeConns,workspace.DescendantAdded:Connect(function(obj) if not _G._NukeOn then return end; task.defer(function() if not _G._NukeOn then return end; if IsBase(obj) then MakeTransparent(obj); return end; if IsClothing(obj) then SafeDestroy(obj) elseif IsInBase(obj) then elseif IsCharacterPart(obj) then elseif IsOutOfRange(obj) then SafeDestroy(obj) else CleanObject(obj); StripObject(obj) end end) end))
        table.insert(_G._NukeConns,Lighting.DescendantAdded:Connect(function(obj) if not _G._NukeOn then return end; if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then SafeDestroy(obj) end end))
        table.insert(_G._NukeConns,MaterialService.DescendantAdded:Connect(function(obj) if not _G._NukeOn then return end; SafeDestroy(obj) end))
        for _,plr in ipairs(Players:GetPlayers()) do OptimizeCharacter(plr.Character); table.insert(_G._NukeConns,plr.CharacterAdded:Connect(OptimizeCharacter)) end
        table.insert(_G._NukeConns,Players.PlayerAdded:Connect(function(plr) table.insert(_G._NukeConns,plr.CharacterAdded:Connect(OptimizeCharacter)) end))
        table.insert(_G._NukeThreads,task.spawn(function() while _G._NukeOn do task.wait(15); pcall(function() collectgarbage("collect") end) end end))
    end
    _G._nukeStop = function() _G._NukeOn=false; for _,c in ipairs(_G._NukeConns) do pcall(function() c:Disconnect() end) end; _G._NukeConns={}; _G._NukeThreads={} end

    -- ============================================================
    -- GAME GRAB / STEAL BAR ART
    -- Puts the fluid artwork image behind the game's own steal bar
    -- (PlayerGui.StealBarGui.StealBar) whenever it shows up. Watcher
    -- is re-exec safe and re-decorates if the game rebuilds the bar.
    -- ============================================================
    task.spawn(function()
        local pg = LP:WaitForChild("PlayerGui", 15)
        if not pg then return end
        local function decorateGrabBar()
            local sg = pg:FindFirstChild("StealBarGui")
            local bar = sg and sg:FindFirstChild("StealBar")
            if not bar then return false end
            if bar:FindFirstChild("FluidArtBg") then return true end
            local lowest = 1
            for _, ch in ipairs(bar:GetChildren()) do
                if ch:IsA("GuiObject") and ch.ZIndex < lowest then lowest = ch.ZIndex end
            end
            local img = Instance.new("ImageLabel")
            img.Name = "FluidArtBg"
            img.BackgroundTransparency = 1
            img.BorderSizePixel = 0
            img.Size = UDim2.new(1, 0, 1, 0)
            img.Image = UI_ASSET
            img.ImageColor3 = Color3.fromRGB(150, 185, 225)
            img.ImageTransparency = 0.55
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = lowest - 1
            local barCorner = bar:FindFirstChildOfClass("UICorner")
            if barCorner then barCorner:Clone().Parent = img end
            img.Parent = bar
            return true
        end
        pcall(decorateGrabBar)
        if not _G._fluidGrabArtWatcher then
            _G._fluidGrabArtWatcher = true
            pg.DescendantAdded:Connect(function(obj)
                if obj.Name == "StealBar" or obj.Name == "StealBarGui" then
                    task.defer(function() pcall(decorateGrabBar) end)
                end
            end)
            task.spawn(function()
                while true do
                    task.wait(2)
                    pcall(decorateGrabBar)
                end
            end)
        end
    end)

    _G._NoCamOn=false; _G._NoCamConn=nil; _G._NoCamParts={}
    _G._noCamStart = function() if _G._NoCamOn then return end; _G._NoCamOn=true; local function apply(obj) if obj:IsA("BasePart") and not obj:IsDescendantOf(LP.Character) then if _G._NoCamParts[obj]==nil then _G._NoCamParts[obj]=obj.CanCollide end end end; for _,obj in ipairs(workspace:GetDescendants()) do apply(obj) end; _G._NoCamConn = RunService.RenderStepped:Connect(function() if not _G._NoCamOn then return end; local cam=workspace.CurrentCamera; if not cam then return end; for p,_ in pairs(_G._NoCamParts) do if p and p.Parent then pcall(function() local dist=(cam.CFrame.Position-p.Position).Magnitude; if dist<8 then p.LocalTransparencyModifier=1 else p.LocalTransparencyModifier=0 end end) end end end) end
    _G._noCamStop = function() _G._NoCamOn=false; if _G._NoCamConn then _G._NoCamConn:Disconnect(); _G._NoCamConn=nil end; for p,_ in pairs(_G._NoCamParts) do pcall(function() if p and p.Parent then p.LocalTransparencyModifier=0 end end) end; _G._NoCamParts={} end

    _G._VezyFontMyfont=nil; _G._VezyFontBadfont=nil; _G._VezyFontConn=nil; _G._VezyFontEnabled=false; _G._VezyFontOriginals={}
    _G._fontDontTouch = function(this) if this:IsA("TextLabel") or this:IsA("TextButton") or this:IsA("TextBox") then if this.TextStrokeTransparency~=1 then return false end; local cur=tostring(this.FontFace); return cur==_G._VezyFontBadfont or string.find(cur,"BuilderIcons") end; return true end
    _G._fontChangeIt = function(txt) if (txt:IsA("TextLabel") or txt:IsA("TextButton") or txt:IsA("TextBox")) and not _G._fontDontTouch(txt) then if not _G._VezyFontOriginals[txt] then _G._VezyFontOriginals[txt]=txt.FontFace end; pcall(function() txt.FontFace=_G._VezyFontMyfont end) end end
    _G._fontSetup = function() if _G._VezyFontMyfont then return true end; local ok=pcall(function() local httpsvc=game:GetService("HttpService"); if isfile and writefile and getcustomasset then if not isfile("starborn.ttf") then writefile("starborn.ttf",game:HttpGet("https://granny.anondrop.net/uploads/6c2505542959f371/Starborn.ttf")) end; writefile("starborn.json",httpsvc:JSONEncode({name="Starborn",faces={{name="Regular",weight=400,style="normal",assetId=getcustomasset("starborn.ttf")}}})); _G._VezyFontMyfont=Font.new(getcustomasset("starborn.json")); _G._VezyFontBadfont=tostring(Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json")) end end); return ok and _G._VezyFontMyfont~=nil end
    _G._customFontStart = function() if _G._VezyFontEnabled then return end; if not _G._fontSetup() then return end; _G._VezyFontEnabled=true; for _,v in pairs(game:GetDescendants()) do _G._fontChangeIt(v) end; _G._VezyFontConn=game.DescendantAdded:Connect(function(obj) if _G._VezyFontEnabled then _G._fontChangeIt(obj) end end) end
    _G._customFontStop = function() _G._VezyFontEnabled=false; if _G._VezyFontConn then _G._VezyFontConn:Disconnect(); _G._VezyFontConn=nil end; for obj,origFont in pairs(_G._VezyFontOriginals) do pcall(function() if obj and obj.Parent then obj.FontFace=origFont end end) end; _G._VezyFontOriginals={} end

    _G._RemoveAccOn=false; _G._RemoveAccConn=nil; _G._removedAccessories={}
    _G._removeAccDo = function() if not _G._RemoveAccOn then return end; local char=LP.Character; if not char then return end; for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Accessory") or obj:IsA("Hat") then if not _G._removedAccessories[obj] then _G._removedAccessories[obj]=true; pcall(function() obj:Destroy() end) end end end end
    _G._removeAccStart = function() if _G._RemoveAccOn then return end; _G._RemoveAccOn=true; _G._removeAccDo(); _G._RemoveAccConn=LP.CharacterAdded:Connect(function() task.wait(0.5); if _G._RemoveAccOn then _G._removeAccDo() end end) end
    _G._removeAccStop = function() _G._RemoveAccOn=false; if _G._RemoveAccConn then _G._RemoveAccConn:Disconnect(); _G._RemoveAccConn=nil end; _G._removedAccessories={} end

    -- ============================================================
    -- RUNTIME LOOPS
    -- ============================================================
    RunService.Stepped:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end end
    end)

    RunService.RenderStepped:Connect(function()
        if not (h and hrp) then return end; if State._tpInProgress then return end
        if not State.batAimbotToggled and not State.autoLeftEnabled and not State.autoRightEnabled then
            local md=h.MoveDirection
            local spd
            if State.laggerMode==1 then spd=State.laggerSpeed
            elseif State.laggerMode==2 then spd=State.laggerCarrySpeed
            else spd=State.speedToggled and State.carrySpeed or State.normalSpeed end
            if md.Magnitude>0 then
                State.lastMoveDir=md
                hrp.Velocity=Vector3.new(md.X*spd,hrp.Velocity.Y,md.Z*spd)
            elseif State.antiRagdollEnabled and State.lastMoveDir.Magnitude>0 then
                local anyHeld=false
                for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld=true; break end end
                if anyHeld then hrp.Velocity=Vector3.new(State.lastMoveDir.X*spd,hrp.Velocity.Y,State.lastMoveDir.Z*spd) end
            end
        end
        pcall(function()
            local head2=LP.Character and LP.Character:FindFirstChild("Head")
            if head2 then
                local bb2=head2:FindFirstChild("FluidVSBB")
                local sl=bb2 and bb2:FindFirstChild("SpeedBillLbl")
                if sl then sl.Text=string.format("%.1f",Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude) end
            end
        end)
    end)

    UIS.InputBegan:Connect(function(inp,gp)
        if gp then return end
        local isKb=inp.UserInputType==Enum.UserInputType.Keyboard
        local isGp=inp.UserInputType==Enum.UserInputType.Gamepad1 or inp.UserInputType==Enum.UserInputType.Gamepad2 or inp.UserInputType==Enum.UserInputType.Gamepad3 or inp.UserInputType==Enum.UserInputType.Gamepad4
        if not isKb and not isGp then return end
        local kc=inp.KeyCode; if kc==Enum.KeyCode.Unknown then return end
        if kc==Keys.speed then toggleSpeed()
        elseif kc==Keys.autoLeft then
            State.autoLeftEnabled=not State.autoLeftEnabled
            if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(State.autoLeftEnabled) end
            if State.autoLeftEnabled and State.batAimbotToggled then State.batAimbotToggled=false; stopBatAimbot(); if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end end
            if State.autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
            requestSave()
        elseif kc==Keys.autoRight then
            State.autoRightEnabled=not State.autoRightEnabled
            if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(State.autoRightEnabled) end
            if State.autoRightEnabled and State.batAimbotToggled then State.batAimbotToggled=false; stopBatAimbot(); if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(false) end end
            if State.autoRightEnabled then startAutoRight() else stopAutoRight() end
            requestSave()
        elseif kc==Keys.drop then if not dropActive then pcall(runDrop) end
        elseif kc==Keys.autoCarry then
            State.autoCarryEnabled=not State.autoCarryEnabled
            if toggleSetters["autoCarry"] then pcall(toggleSetters["autoCarry"], State.autoCarryEnabled) end
            requestSave()
        elseif kc==Keys.lagger then toggleLaggerMode()
        elseif kc==Keys.tpDown then if runTPDown then task.spawn(runTPDown) end
        elseif kc==Keys.tpBat then
            toggleTPBat()  -- Toggle ON/OFF
        elseif kc==Keys.reset then 
            task.spawn(instaReset)
            if stackBtnRefs.reset then
                stackBtnRefs.reset.setOn(true)
                task.wait(0.3)
                stackBtnRefs.reset.setOn(false)
            end
        elseif kc==Keys.aimbot then
            State.batAimbotToggled=not State.batAimbotToggled
            if State.batAimbotToggled then
                if State.autoLeftEnabled then State.autoLeftEnabled=false; stopAutoLeft(); if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(false) end end
                if State.autoRightEnabled then State.autoRightEnabled=false; stopAutoRight(); if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(false) end end
                pcall(startBatAimbot)
            else stopBatAimbot() end
            if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(State.batAimbotToggled) end
            requestSave()
        elseif kc==Keys.guiHide then
            if isKb then
                State.guiVisible=not State.guiVisible
                if State.guiVisible then showWindow() else hideWindow() end
                local _qa = _G.FluidVSQAHide or _G.VoidCCQAHide or _G.GreenDuelsQAHide; if _qa then pcall(_qa, not State.guiVisible) end
                requestSave()
            end
        end
    end)

    _G._VezyFOV = _G._VezyFOV or 70
    _G._VezyFOVPropConn = nil
    local function _attachFOVLock(cam)
        if not cam then return end
        if _G._VezyFOVPropConn then pcall(function() _G._VezyFOVPropConn:Disconnect() end) end
        pcall(function() cam.FieldOfView = _G._VezyFOV or 70 end)
        _G._VezyFOVPropConn = cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            local target = _G._VezyFOV or 70
            if not State.stretchedResEnabled and cam.FieldOfView ~= target then pcall(function() cam.FieldOfView = target end) end
        end)
    end
    _attachFOVLock(workspace.CurrentCamera)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() task.wait(); _attachFOVLock(workspace.CurrentCamera) end)
    LP.CharacterAdded:Connect(function() task.wait(0.3); _attachFOVLock(workspace.CurrentCamera) end)
    RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local target = _G._VezyFOV or 70
        if not State.stretchedResEnabled and cam.FieldOfView ~= target then pcall(function() cam.FieldOfView = target end) end
    end)

    -- ============================================================
    -- MINI TOGGLE CHIP
    -- ============================================================
    local toggleBtn = Instance.new("TextButton", gui)
    toggleBtn.Name = "FluidVSToggle"
    toggleBtn.Size = UDim2.new(0,148,0,40)
    toggleBtn.Position = UDim2.new(0,20,0,200)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.AutoButtonColor = false
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 25
    toggleBtn.Visible = true
    mkCorner(toggleBtn,14)
    local tbStroke = mkStroke(toggleBtn, C.stackBrd, 1.5)
    tbStroke.Transparency = 0.25
    local toggleGrad = mkGrad(toggleBtn, GRAD.idleTop, GRAD.idleBot)
    local toggleArt = mkBackdrop(toggleBtn, 14, toggleBtn.ZIndex)
    mkShadow(gui, toggleBtn, 14, 3)
    local chipDot = Instance.new("Frame", toggleBtn)
    chipDot.Size = UDim2.new(0,7,0,7); chipDot.Position = UDim2.new(0,13,0.5,-3.5)
    chipDot.BackgroundColor3 = C.accent; chipDot.BorderSizePixel = 0
    chipDot.ZIndex = toggleBtn.ZIndex + 2; mkCorner(chipDot,4)
    registerChromaColor(chipDot, "BackgroundColor3", C.accent, false)
    local toggleLbl = Instance.new("TextLabel", toggleBtn)
    toggleLbl.Name = "Label"
    toggleLbl.Size = UDim2.new(1,-32,1,0); toggleLbl.Position = UDim2.new(0,26,0,0)
    toggleLbl.BackgroundTransparency = 1
    toggleLbl.Text = "fluid.vs"
    toggleLbl.TextColor3 = Color3.fromRGB(245,250,255)
    toggleLbl.Font = Enum.Font.GothamBlack
    toggleLbl.TextSize = 14
    toggleLbl.TextXAlignment = Enum.TextXAlignment.Left
    toggleLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    toggleLbl.TextStrokeTransparency = 0.7
    toggleLbl.ZIndex = toggleBtn.ZIndex + 2
    mkGrad(toggleLbl, Color3.fromRGB(255,255,255), Color3.fromRGB(140,210,255), 0)

    do
        local dragStart,startPos,dragging = nil,nil,false
        local saveDebounce = nil
        toggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = toggleBtn.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
                mkRipple(toggleBtn, 30)
            end
        end)
        toggleBtn.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        toggleBtn.InputEnded:Connect(function()
            if dragging then
                dragging = false
                if saveDebounce then task.cancel(saveDebounce) end
                saveDebounce = task.delay(0.2, function()
                    pcall(requestSave)
                    saveDebounce = nil
                end)
            end
        end)
    end

    toggleBtn.MouseButton1Click:Connect(function()
        State.guiVisible = not State.guiVisible
        if State.guiVisible then showWindow() else hideWindow() end
        local _qa = _G.FluidVSQAHide or _G.VoidCCQAHide or _G.GreenDuelsQAHide; if _qa then pcall(_qa, not State.guiVisible) end
        requestSave()
    end)

    toggleBtn.MouseEnter:Connect(function()
        toggleGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, GRAD.hovTop), ColorSequenceKeypoint.new(1, GRAD.hovBot)})
        TweenService:Create(tbStroke, TweenInfo.new(0.15), {Color = C.strokeHi, Transparency = 0}):Play()
    end)
    toggleBtn.MouseLeave:Connect(function()
        toggleGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, GRAD.idleTop), ColorSequenceKeypoint.new(1, GRAD.idleBot)})
        TweenService:Create(tbStroke, TweenInfo.new(0.15), {Color = C.stackBrd, Transparency = 0.25}):Play()
    end)

    -- ============================================================
    -- TOAST NOTIFICATIONS
    -- ============================================================
    do
        local TextService = game:GetService("TextService")
        local toastHolder = Instance.new("Frame", gui)
        toastHolder.Name = "Toasts"
        toastHolder.Size = UDim2.new(0, 300, 0, 220)
        toastHolder.Position = UDim2.new(0.5, -150, 1, -250)
        toastHolder.BackgroundTransparency = 1
        toastHolder.ZIndex = 40
        local tl = Instance.new("UIListLayout", toastHolder)
        tl.SortOrder = Enum.SortOrder.LayoutOrder
        tl.Padding = UDim.new(0, 6)
        tl.VerticalAlignment = Enum.VerticalAlignment.Bottom
        tl.HorizontalAlignment = Enum.HorizontalAlignment.Center

        _G.FluidToast = function(msg, good)
            local t = Instance.new("Frame", toastHolder)
            t.Size = UDim2.new(0, 140, 0, 30)
            t.BackgroundColor3 = C.infoBg
            t.BorderSizePixel = 0
            t.ZIndex = 41
            t.BackgroundTransparency = 1
            mkCorner(t, 15)
            local ts = mkStroke(t, good and Color3.fromRGB(64,200,150) or (good == false and Color3.fromRGB(255,110,110) or C.infoBrd), 1.2)
            ts.Transparency = 1
            local tdot = Instance.new("Frame", t)
            tdot.Size = UDim2.new(0,7,0,7); tdot.Position = UDim2.new(0,12,0.5,-3.5)
            tdot.BackgroundColor3 = good == false and Color3.fromRGB(255,110,110) or (good and Color3.fromRGB(64,200,150) or C.accent)
            tdot.BorderSizePixel = 0; tdot.ZIndex = 42; mkCorner(tdot, 4)
            local tlbl = Instance.new("TextLabel", t)
            tlbl.Size = UDim2.new(1,-32,1,0); tlbl.Position = UDim2.new(0,26,0,0)
            tlbl.BackgroundTransparency = 1; tlbl.Text = tostring(msg)
            tlbl.TextColor3 = Color3.fromRGB(235,242,252); tlbl.Font = Enum.Font.GothamBold; tlbl.TextSize = 12
            tlbl.TextXAlignment = Enum.TextXAlignment.Left; tlbl.ZIndex = 42; tlbl.TextTransparency = 1
            local w = 160
            pcall(function()
                w = math.clamp(TextService:GetTextSize(tostring(msg), 12, Enum.Font.GothamBold, Vector2.new(400, 30)).X + 44, 110, 280)
            end)
            t.Size = UDim2.new(0, w, 0, 30)
            TweenService:Create(t, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.06}):Play()
            TweenService:Create(ts, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
            TweenService:Create(tlbl, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
            task.delay(2.2, function()
                if t and t.Parent then
                    TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, w, 0, 0)}):Play()
                    TweenService:Create(ts, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    TweenService:Create(tlbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                    task.delay(0.35, function() pcall(function() t:Destroy() end) end)
                end
            end)
        end
    end

    -- ============================================================
    -- SAVE / LOAD (ROBUST VERSION)
    -- ============================================================
    saveConfig = function()
        local success = false
        pcall(function()
            if _isfile(CONFIG_FILE) then
                local oldRaw = _readfile(CONFIG_FILE)
                if oldRaw and oldRaw ~= "" then
                    pcall(function() _writefile(CONFIG_BACKUP, oldRaw) end)
                end
            end
            
            local btnPositions = {}
            for key, wrapper in pairs(stackWrappers) do
                if wrapper and wrapper.Position then
                    btnPositions[key] = { X = wrapper.Position.X.Offset, Y = wrapper.Position.Y.Offset }
                end
            end
            local togglePos = toggleBtn and toggleBtn.Position and { X = toggleBtn.Position.X.Offset, Y = toggleBtn.Position.Y.Offset } or nil
            local cfg = {
                version = CONFIG_VERSION,
                normalSpeed = State.normalSpeed,
                carrySpeed = State.carrySpeed,
                laggerSpeed = State.laggerSpeed,
                laggerCarrySpeed = State.laggerCarrySpeed,
                speedToggled = State.speedToggled,
                laggerMode = State.laggerMode,
                stealRadius = Steal.StealRadius,
                stealDuration = Steal.StealDuration,
                uiScale = uiScaleObj and uiScaleObj.Scale or 1.0,
                stackButtonsHidden = State.stackButtonsHidden,
                stackButtonsLocked = State.stackButtonsLocked,
                speedKey = Keys.speed and Keys.speed.Name or "Q",
                autoLeftKey = Keys.autoLeft and Keys.autoLeft.Name or "L",
                autoRightKey = Keys.autoRight and Keys.autoRight.Name or "R",
                guiHideKey = Keys.guiHide and Keys.guiHide.Name or "LeftControl",
                dropKey = Keys.drop and Keys.drop.Name or "H",
                laggerKey = Keys.lagger and Keys.lagger.Name or "Unknown",
                tpDownKey = Keys.tpDown and Keys.tpDown.Name or "Unknown",
                tpBatKey = Keys.tpBat and Keys.tpBat.Name or "X",
                resetKey = Keys.reset and Keys.reset.Name or "R",
                aimbotKey = Keys.aimbot and Keys.aimbot.Name or "Unknown",
                autoCarryKey = Keys.autoCarry and Keys.autoCarry.Name or "C",
                infJump = State.infJumpEnabled,
                antiRagdoll = State.antiRagdollEnabled,
                medusaCounter = State.medusaCounterEnabled,
                batCounter = State.batCounterEnabled,
                autoStealEnabled = Steal.AutoStealEnabled,
                autoSwing = State.autoSwingEnabled,
                batAimbot = State.batAimbotToggled,
                antiLagEnabled = State.antiLagEnabled,
                stretchedResEnabled = State.stretchedResEnabled,
                stretchFOV = State.stretchFOV,
                normalFOV = _G._VezyFOV or 70,
                activeSky = State.activeSky,
                activeAnimPack = State.activeAnimPack,
                chromaEnabled = State.chromaEnabled,
                korbloxLeftEnabled = State.korbloxLeftEnabled,
                korbloxRightEnabled = State.korbloxRightEnabled,
                autoCarryEnabled = State.autoCarryEnabled,
                nukeOptimizer = State.nukeOpt,
                removeAccessories = State.removeAcc,
                tryardAnimEnabled = State.tryardAnimEnabled,
                introEnabled = State.introEnabled,
                guiVisible = State.guiVisible,
                buttonPositions = btnPositions,
                togglePosition = togglePos,
                autoTPEnabled = State.autoTPEnabled,
                autoTPHeight = State.autoTPHeight,
                dropType = currentDropType,
                tpBatToggled = tpBatToggled,
            }
            local encoded = HttpService:JSONEncode(cfg)
            _writefile(CONFIG_FILE, encoded)
            local verify = _readfile(CONFIG_FILE)
            if verify == encoded then success = true end
        end)
        if not success then
            pcall(_G._VezyFlashSave, false)
            warn("[fluid.vs] Config save FAILED!")
        else
            pcall(_G._VezyFlashSave, true)
        end
        return success
    end

    loadConfig = function()
        local raw = nil
        if _isfile(CONFIG_FILE) then
            raw = _readfile(CONFIG_FILE)
        end
        if not raw or raw == "" then
            if _isfile(CONFIG_BACKUP) then
                raw = _readfile(CONFIG_BACKUP)
                if raw and raw ~= "" then
                    print("[fluid.vs] Loaded config from backup")
                end
            end
        end
        if not raw or raw == "" then
            print("[fluid.vs] No valid config file found, using defaults")
            return false
        end
        
        local ok, decErr = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or not decErr then
            pcall(function() _delfile(CONFIG_FILE) end)
            pcall(function() _delfile(CONFIG_BACKUP) end)
            warn("[fluid.vs] Corrupt config deleted, using defaults")
            return false
        end

        local function applyNumber(key, targetVar, uiBox)
            if decErr[key] then
                targetVar = decErr[key]
                if uiBox and uiBox.Text then uiBox.Text = tostring(decErr[key]) end
            end
            return targetVar
        end

        State.normalSpeed = applyNumber("normalSpeed", State.normalSpeed, normalBox)
        State.carrySpeed = applyNumber("carrySpeed", State.carrySpeed, carryBox)
        State.laggerSpeed = applyNumber("laggerSpeed", State.laggerSpeed, laggerBox)
        State.laggerCarrySpeed = applyNumber("laggerCarrySpeed", State.laggerCarrySpeed, laggerCarryBox)
        Steal.StealRadius = applyNumber("stealRadius", Steal.StealRadius, stealRadBox)
        Steal.StealDuration = applyNumber("stealDuration", Steal.StealDuration, stealDurBox)
        if decErr.uiScale and uiScaleObj then
            uiScaleObj.Scale = decErr.uiScale
            if uiScaleBox then uiScaleBox.Text = tostring(decErr.uiScale) end
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
        if decErr.tpBatToggled ~= nil then
            tpBatToggled = decErr.tpBatToggled
            if tpBatToggled then
                local char = LP.Character
                if char then
                    tpBatHRP = char:FindFirstChild("HumanoidRootPart")
                    tpBatH = char:FindFirstChildOfClass("Humanoid")
                end
                startTPBat()
            end
            if stackBtnRefs.tpBat then stackBtnRefs.tpBat.setOn(tpBatToggled) end
        end

        if decErr.dropType and (decErr.dropType == DROP_TYPES.JUMP) then
            currentDropType = decErr.dropType
            if jumpDropBtn then
                jumpDropBtn.BackgroundColor3 = C.accent
                jumpDropBtn.TextColor3 = Color3.fromRGB(10,10,10)
            end
        end

        local bools = {
            stackButtonsHidden="stackButtonsHidden", stackButtonsLocked="stackButtonsLocked",
            infJump="infJumpEnabled", antiRagdoll="antiRagdollEnabled",
            medusaCounter="medusaCounterEnabled", batCounter="batCounterEnabled",
            autoStealEnabled="autoStealEnabled", autoSwing="autoSwingEnabled",
            batAimbot="batAimbotToggled", antiLagEnabled="antiLagEnabled",
            stretchedResEnabled="stretchedResEnabled", nukeOptimizer="nukeOpt",
            removeAccessories="removeAcc", tryardAnimEnabled="tryardAnimEnabled",
            chromaEnabled="chromaEnabled",
            korbloxLeftEnabled="korbloxLeftEnabled", korbloxRightEnabled="korbloxRightEnabled",
            autoCarryEnabled="autoCarryEnabled",
            introEnabled="introEnabled", guiVisible="guiVisible",
            speedToggled="speedToggled", autoTPEnabled="autoTPEnabled",
        }
        for cfgKey, stateKey in pairs(bools) do
            if decErr[cfgKey] ~= nil then State[stateKey] = decErr[cfgKey] end
        end
        if decErr.laggerMode ~= nil then State.laggerMode = decErr.laggerMode end
        if decErr.stretchFOV then State.stretchFOV = decErr.stretchFOV end
        if decErr.activeSky then State.activeSky = decErr.activeSky end
        if decErr.activeAnimPack then State.activeAnimPack = decErr.activeAnimPack end

        local keyMap = {
            speedKey="speed", autoLeftKey="autoLeft", autoRightKey="autoRight",
            guiHideKey="guiHide", dropKey="drop", laggerKey="lagger",
            tpDownKey="tpDown", tpBatKey="tpBat", resetKey="reset", aimbotKey="aimbot",
            autoCarryKey="autoCarry"
        }
        for cfgKey, stateKey in pairs(keyMap) do
            if decErr[cfgKey] then
                local kc = Enum.KeyCode[decErr[cfgKey]]
                if kc and kc ~= Enum.KeyCode.Unknown then
                    Keys[stateKey] = kc
                    if keybindBtnRefs[stateKey] then keybindBtnRefs[stateKey].Text = getKeyDisplayName(kc) end
                end
            end
        end

        mainOuter.Visible = State.guiVisible
        local _qa = _G.FluidVSQAHide or _G.VoidCCQAHide or _G.GreenDuelsQAHide; if _qa then pcall(_qa, not State.guiVisible) end
        for _, wrapper in pairs(stackWrappers) do wrapper.Visible = not State.stackButtonsHidden end
        if hideButtonsSetter then hideButtonsSetter(State.stackButtonsHidden) end
        if lockButtonsSetter then lockButtonsSetter(State.stackButtonsLocked) end

        if State.laggerMode == 0 then
            if carryBox then carryBox.Text = tostring(State.speedToggled and State.carrySpeed or State.normalSpeed) end
        elseif State.laggerMode == 1 then
            if carryBox then carryBox.Text = tostring(State.laggerSpeed) end
        elseif State.laggerMode == 2 then
            if carryBox then carryBox.Text = tostring(State.laggerCarrySpeed) end
        end
        if stackBtnRefs.carrySpeed then stackBtnRefs.carrySpeed.setOn(State.speedToggled) end
        if stackBtnRefs.lagger then stackBtnRefs.lagger.setOn(State.laggerMode == 1) end
        if stackBtnRefs.laggerCarry then stackBtnRefs.laggerCarry.setOn(State.laggerMode == 2) end
        if stackBtnRefs.aimbot then stackBtnRefs.aimbot.setOn(State.batAimbotToggled) end
        if stackBtnRefs.autoLeft then stackBtnRefs.autoLeft.setOn(State.autoLeftEnabled) end
        if stackBtnRefs.autoRight then stackBtnRefs.autoRight.setOn(State.autoRightEnabled) end
        if stackBtnRefs.tpBat then stackBtnRefs.tpBat.setOn(tpBatToggled) end

        if State.antiLagEnabled then enableAntiLag() else disableAntiLag() end
        if State.stretchedResEnabled then enableStretchRez() else disableStretchRez() end
        if State.activeSky then applySky(State.activeSky) else applySky(nil) end
        if State.activeAnimPack then local pk = findAnimPack(State.activeAnimPack); if pk then pcall(function() applyAnimPack(pk) end) end end
        if refreshAnimButtons then pcall(refreshAnimButtons) end
        if State.chromaEnabled then startChromaLoop() else stopChromaLoop() end
        if State.korbloxLeftEnabled then pcall(function() enableKorbloxLeg("Left") end) end
        if State.korbloxRightEnabled then pcall(function() enableKorbloxLeg("Right") end) end
        if State.nukeOpt then _G._nukeStart() else _G._nukeStop() end
        if State.removeAcc then _G._removeAccStart() else _G._removeAccStop() end
        if State.tryardAnimEnabled then startTryardAnim() else stopTryardAnim() end
        if State.batAimbotToggled then startBatAimbot() else stopBatAimbot() end
        if State.batCounterEnabled then startBatCounter() else stopBatCounter() end
        if State.medusaCounterEnabled then setupMedusaCounter(LP.Character) else stopMedusaCounter() end
        if State.antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end
        if Steal.AutoStealEnabled then startAutoSteal() else stopAutoSteal() end
        if State.autoTPEnabled then startAutoTP() else stopAutoTP() end

        for key, setter in pairs(toggleSetters) do
            local stateValue = nil
            if key=="autoSteal" then stateValue=Steal.AutoStealEnabled
            elseif key=="infJump" then stateValue=State.infJumpEnabled
            elseif key=="antiRagdoll" then stateValue=State.antiRagdollEnabled
            elseif key=="medusaCounter" then stateValue=State.medusaCounterEnabled
            elseif key=="batCounter" then stateValue=State.batCounterEnabled
            elseif key=="autoSwing" then stateValue=State.autoSwingEnabled
            elseif key=="antiLag" then stateValue=State.antiLagEnabled
            elseif key=="stretchedRes" then stateValue=State.stretchedResEnabled
            elseif key=="nukeOpt" then stateValue=State.nukeOpt
            elseif key=="removeAcc" then stateValue=State.removeAcc
            elseif key=="tryardAnim" then stateValue=State.tryardAnimEnabled
            elseif key=="chroma" then stateValue=State.chromaEnabled
            elseif key=="korbloxLeft" then stateValue=State.korbloxLeftEnabled
            elseif key=="korbloxRight" then stateValue=State.korbloxRightEnabled
            elseif key=="introEnabled" then stateValue=State.introEnabled
            elseif key=="hideButtons" then stateValue=State.stackButtonsHidden
            elseif key=="lockButtons" then stateValue=State.stackButtonsLocked
            elseif key=="autoTP" then stateValue=State.autoTPEnabled
            elseif key=="autoCarry" then stateValue=State.autoCarryEnabled
            end
            if stateValue ~= nil then pcall(setter, stateValue) end
        end

        refreshAllKeybindButtons()

        if decErr.buttonPositions then
            for key, posData in pairs(decErr.buttonPositions) do
                local wrapper = stackWrappers[key]
                if wrapper and posData.X and posData.Y then
                    wrapper.Position = UDim2.new(wrapper.Position.X.Scale, posData.X, wrapper.Position.Y.Scale, posData.Y)
                end
            end
        end
        if decErr.togglePosition and toggleBtn then
            toggleBtn.Position = UDim2.new(0, decErr.togglePosition.X, 0, decErr.togglePosition.Y)
        end

        print("[fluid.vs] Config loaded successfully")
        return true
    end

    requestSave = function()
        local ok = saveConfig()
        if ok then
            if _G._VezyFlashSave then _G._VezyFlashSave(true) end
        else
            if _G._VezyFlashSave then _G._VezyFlashSave(false) end
        end
    end

    -- ============================================================
    -- INIT
    -- ============================================================
    loadPresetsFile()
    rebuildPresetList()
    local _lastPresetName = loadLastPresetName()
    if _lastPresetName and _lastPresetName~="" then
        for _,preset in ipairs(Presets) do
            if preset.name==_lastPresetName then
                pcall(function()
                    local d=preset.data or {}
                    if d.normalSpeed then State.normalSpeed=d.normalSpeed; if normalBox then normalBox.Text=tostring(d.normalSpeed) end end
                    if d.carrySpeed then State.carrySpeed=d.carrySpeed; if carryBox then carryBox.Text=tostring(d.carrySpeed) end end
                    if d.laggerSpeed then State.laggerSpeed=d.laggerSpeed; if laggerBox then laggerBox.Text=tostring(d.laggerSpeed) end end
                    if d.laggerCarrySpeed then State.laggerCarrySpeed=d.laggerCarrySpeed; if laggerCarryBox then laggerCarryBox.Text=tostring(d.laggerCarrySpeed) end end
                    if d.stealRadius then Steal.StealRadius=d.stealRadius; if stealRadBox and not stealRadBox:IsFocused() then stealRadBox.Text=tostring(Steal.StealRadius) end end
                    if d.stealDuration then Steal.StealDuration=d.stealDuration; if stealDurBox then stealDurBox.Text=tostring(Steal.StealDuration) end end
                    if d.autoTP ~= nil then State.autoTPEnabled=d.autoTP; if toggleSetters["autoTP"] then toggleSetters["autoTP"](d.autoTP) end end
                    if d.autoTPHeight then State.autoTPHeight=d.autoTPHeight; if autoTPHeightBox then autoTPHeightBox.Text=tostring(d.autoTPHeight) end end
                end)
                break
            end
        end
    end
    loadConfig()
    startAutoSteal()
    print("[fluid.vs] Ready! Jump Drop only (safe). BAT MODE (TOGGLE - stays ON until clicked again) & Blossom Reset added.")
end

-- ============================================================
-- SAFE MAIN EXECUTION - FIXED
-- ============================================================
if not _G.FluidVS_MainExecuted then
    task.wait(0.5)  -- Wait for player to fully load
    if LP and LP:FindFirstChild("PlayerGui") then
        Main()
    else
        LP = LP or Players:WaitForChild("LocalPlayer")
        local success, err = pcall(function()
            LP:WaitForChild("PlayerGui")
            Main()
        end)
        if not success then
            warn("[fluid.vs] Failed to execute Main:", err)
        end
    end
end

-- ============================================================
-- OTHER PLAYERS SPEED DISPLAY
-- ============================================================
;(function()
local function setupOtherPlayerSpeed(player)
    if player == LP then return end
    local function onCharacterAdded(char)
        task.wait(0.2)
        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then return end
        for _,_bbn in ipairs({"FluidVSBB_Other","FluidVSBB_Other","GreenDuelsBB_Other"}) do
            local _old = head:FindFirstChild(_bbn); if _old then _old:Destroy() end
        end
        local bb = Instance.new("BillboardGui", head)
        bb.Name = "FluidVSBB_Other"
        bb.Size = UDim2.new(0, 160, 0, 24)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local speedLbl = Instance.new("TextLabel", bb)
        speedLbl.Name = "SpeedBillLbl"
        speedLbl.Size = UDim2.new(1, 0, 1, 0)
        speedLbl.Position = UDim2.new(0, 0, 0, 0)
        speedLbl.BackgroundTransparency = 1
        speedLbl.Text = "0.0"
        speedLbl.TextColor3 = Color3.fromRGB(255,255,255)
        speedLbl.Font = Enum.Font.GothamBlack
        speedLbl.TextScaled = true
        speedLbl.TextStrokeTransparency = 0
        speedLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        task.spawn(function()
            while char and char.Parent and hrp and hrp.Parent and speedLbl and speedLbl.Parent do
                pcall(function()
                    local hspd = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
                    speedLbl.Text = string.format("%.1f", hspd)
                end)
                task.wait(0.1)
            end
        end)
    end
    if player.Character then task.spawn(function() onCharacterAdded(player.Character) end) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LP then task.spawn(function() setupOtherPlayerSpeed(player) end) end
end
Players.PlayerAdded:Connect(function(player)
    task.spawn(function() setupOtherPlayerSpeed(player) end)
end)
end)()
