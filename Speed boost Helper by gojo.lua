-- =====================================================
--  SEMI TP HELPER ( GOJO )
--  Speed 23-30 · BOOST / TOGGLE · Auto FOV 120 + Stretch + Unwalk
-- =====================================================

if _G._GojoTP and _G._GojoTP.destroy then
    pcall(_G._GojoTP.destroy)
end

local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local TS      = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

local state = {
    enabled      = true,     -- toggle ON by default
    speed        = 28,
    conn         = nil,
    alive        = true,
    savedAnimate = nil,
    unwalkConn   = nil,
    visualsConn  = nil,
    charConn     = nil,
}

-- cleanup old copies
for _, name in ipairs({ "GojoTPHelper" }) do
    local host = (gethui and gethui()) or game:GetService("CoreGui")
    local old  = host:FindFirstChild(name)
    if old then old:Destroy() end
    local pg   = LP:FindFirstChild("PlayerGui")
    local old2 = pg and pg:FindFirstChild(name)
    if old2 then old2:Destroy() end
end

local hostGui = (gethui and gethui()) or game:GetService("CoreGui")

local gui = Instance.new("ScreenGui")
gui.Name           = "GojoTPHelper"
gui.ResetOnSpawn   = false
gui.DisplayOrder   = 999
gui.IgnoreGuiInset = true
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(gui) end
end)
if not pcall(function() gui.Parent = hostGui end) then
    gui.Parent = LP:WaitForChild("PlayerGui")
end

-- ============= MAIN FRAME =============
local main = Instance.new("Frame")
main.Name             = "Main"
main.Size             = UDim2.new(0, 210, 0, 132)
main.Position         = UDim2.new(0.5, -105, 0.5, -66)
main.BackgroundColor3 = Color3.fromRGB(10, 6, 18)
main.BorderSizePixel  = 0
main.Active           = true
main.ClipsDescendants = true
main.Parent           = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color           = Color3.fromRGB(140, 80, 255)
mainStroke.Thickness       = 1.5
mainStroke.Transparency    = 0.35
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ============= TITLE =============
local title = Instance.new("TextLabel", main)
title.Size                   = UDim2.new(1, 0, 0, 22)
title.Position               = UDim2.new(0, 0, 0, 6)
title.BackgroundTransparency = 1
title.Text                   = "SEMI TP HELPER ( GOJO )"
title.TextColor3             = Color3.fromRGB(200, 160, 255)
title.Font                   = Enum.Font.GothamBlack
title.TextSize               = 11
title.TextStrokeTransparency = 0.6
title.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)

-- ============= SPEED INPUT ROW =============
local inputRow = Instance.new("Frame", main)
inputRow.Size             = UDim2.new(1, -16, 0, 26)
inputRow.Position         = UDim2.new(0, 8, 0, 32)
inputRow.BackgroundColor3 = Color3.fromRGB(20, 14, 32)
inputRow.BorderSizePixel  = 0
Instance.new("UICorner", inputRow).CornerRadius = UDim.new(0, 6)
local inputStroke = Instance.new("UIStroke", inputRow)
inputStroke.Color        = Color3.fromRGB(80, 50, 140)
inputStroke.Thickness    = 1
inputStroke.Transparency = 0.5

local spdLbl = Instance.new("TextLabel", inputRow)
spdLbl.Size                   = UDim2.new(0, 90, 1, 0)
spdLbl.Position               = UDim2.new(0, 10, 0, 0)
spdLbl.BackgroundTransparency = 1
spdLbl.Text                   = "Speed (23-30)"
spdLbl.TextColor3             = Color3.fromRGB(190, 170, 230)
spdLbl.Font                   = Enum.Font.GothamBold
spdLbl.TextSize               = 10
spdLbl.TextXAlignment         = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", inputRow)
speedBox.Size             = UDim2.new(0, 48, 0, 20)
speedBox.Position         = UDim2.new(1, -58, 0.5, -10)
speedBox.BackgroundColor3 = Color3.fromRGB(32, 20, 50)
speedBox.BorderSizePixel  = 0
speedBox.Text             = tostring(state.speed)
speedBox.TextColor3       = Color3.fromRGB(235, 215, 255)
speedBox.Font             = Enum.Font.GothamBold
speedBox.TextSize         = 11
speedBox.ClearTextOnFocus = false
speedBox.Parent           = inputRow
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)
local boxStroke = Instance.new("UIStroke", speedBox)
boxStroke.Color        = Color3.fromRGB(140, 80, 255)
boxStroke.Thickness    = 1
boxStroke.Transparency = 0.5

speedBox.Focused:Connect(function()
    TS:Create(boxStroke, TweenInfo.new(0.15), { Transparency = 0 }):Play()
end)
speedBox.FocusLost:Connect(function()
    TS:Create(boxStroke, TweenInfo.new(0.15), { Transparency = 0.5 }):Play()
    local n = tonumber(speedBox.Text)
    if n then
        n = math.clamp(n, 23, 30)
        state.speed = n
        speedBox.Text = tostring(n)
    else
        speedBox.Text = tostring(state.speed)
    end
end)

-- ============= BUTTONS ROW =============
local btnRow = Instance.new("Frame", main)
btnRow.Size                = UDim2.new(1, -16, 0, 30)
btnRow.Position            = UDim2.new(0, 8, 0, 68)
btnRow.BackgroundTransparency = 1

local boostBtn = Instance.new("TextButton", btnRow)
boostBtn.Size             = UDim2.new(0.48, 0, 1, 0)
boostBtn.Position         = UDim2.new(0, 0, 0, 0)
boostBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 160)
boostBtn.BorderSizePixel  = 0
boostBtn.Text             = "BOOST"
boostBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
boostBtn.Font             = Enum.Font.GothamBlack
boostBtn.TextSize         = 12
boostBtn.AutoButtonColor  = false
Instance.new("UICorner", boostBtn).CornerRadius = UDim.new(0, 6)
local boostStroke = Instance.new("UIStroke", boostBtn)
boostStroke.Color        = Color3.fromRGB(160, 110, 255)
boostStroke.Thickness    = 1
boostStroke.Transparency = 0.4

local toggleBtn = Instance.new("TextButton", btnRow)
toggleBtn.Size             = UDim2.new(0.48, 0, 1, 0)
toggleBtn.Position         = UDim2.new(0.52, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 160)
toggleBtn.BorderSizePixel  = 0
toggleBtn.Text             = "ON"
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.Font             = Enum.Font.GothamBlack
toggleBtn.TextSize         = 12
toggleBtn.AutoButtonColor  = false
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color        = Color3.fromRGB(160, 110, 255)
toggleStroke.Thickness    = 1
toggleStroke.Transparency = 0.3

-- ============= STATUS ROW =============
local statusLbl = Instance.new("TextLabel", main)
statusLbl.Size                = UDim2.new(1, -16, 0, 20)
statusLbl.Position            = UDim2.new(0, 8, 0, 104)
statusLbl.BackgroundTransparency = 1
statusLbl.Text                = "FOV: 120 | STRETCH: ON | UNWALK: ON"
statusLbl.TextColor3          = Color3.fromRGB(140, 200, 140)
statusLbl.Font                = Enum.Font.GothamBold
statusLbl.TextSize            = 9
statusLbl.TextXAlignment      = Enum.TextXAlignment.Center

-- ============= SPEED LOGIC =============
local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getMoveDir()
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local md = hum.MoveDirection
    if md.Magnitude < 0.05 then return nil end
    return md.Unit
end

local function applySpeed(spd)
    local hrp = getHRP()
    if not hrp then return end
    local dir = getMoveDir()
    if not dir then return end
    local vy = hrp.AssemblyLinearVelocity.Y
    hrp.AssemblyLinearVelocity = Vector3.new(dir.X * spd, vy, dir.Z * spd)
end

local function startLoop()
    if state.conn then return end
    state.conn = RS.Heartbeat:Connect(function()
        if not state.enabled or not state.alive then return end
        applySpeed(state.speed)
    end)
end

local function stopLoop()
    if state.conn then
        state.conn:Disconnect()
        state.conn = nil
    end
end

local function setToggle(on)
    state.enabled = on and true or false
    if state.enabled then
        toggleBtn.Text             = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 160)
        toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        toggleStroke.Color         = Color3.fromRGB(160, 110, 255)
        toggleStroke.Transparency  = 0.3
        startLoop()
    else
        toggleBtn.Text             = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 62)
        toggleBtn.TextColor3       = Color3.fromRGB(200, 160, 255)
        toggleStroke.Color         = Color3.fromRGB(80, 50, 140)
        toggleStroke.Transparency  = 0.5
        stopLoop()
    end
end

-- ============= AUTO VISUALS: FOV 120 + STRETCH =============
local FOV_VALUE = 120
local STRETCH_SCALE = 0.75   -- 1.0 = off, lower = more stretched

local function startVisuals()
    if state.visualsConn then return end
    state.visualsConn = RS.RenderStepped:Connect(function()
        if not state.alive then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        -- FOV lock
        if cam.FieldOfView ~= FOV_VALUE then
            cam.FieldOfView = FOV_VALUE
        end

        -- Stretch: multiply camera CFrame by a non-uniform scale matrix
        cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0,
            1, 0, 0,
            0, STRETCH_SCALE, 0,
            0, 0, 1)
    end)
end

local function stopVisuals()
    if state.visualsConn then
        state.visualsConn:Disconnect()
        state.visualsConn = nil
    end
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function() cam.FieldOfView = 70 end)
    end
end

-- ============= AUTO UNWALK =============
local function applyUnwalk()
    local c = LP.Character
    if not c then return end

    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop(0) end)
        end
    end

    local anim = c:FindFirstChild("Animate")
    if anim then
        if not state.savedAnimate then
            state.savedAnimate = anim:Clone()
        end
        anim:Destroy()
    end
end

-- keeps animations stopped if something tries to restart them
local function startUnwalkKeeper()
    if state.unwalkConn then state.unwalkConn:Disconnect() end
    state.unwalkConn = RS.Heartbeat:Connect(function()
        if not state.alive then return end
        local c = LP.Character
        if not c then return end
        local anim = c:FindFirstChild("Animate")
        if anim then
            if not state.savedAnimate then
                state.savedAnimate = anim:Clone()
            end
            anim:Destroy()
        end
    end)
end

local function stopUnwalkKeeper()
    if state.unwalkConn then
        state.unwalkConn:Disconnect()
        state.unwalkConn = nil
    end
end

-- reapply on respawn
state.charConn = LP.CharacterAdded:Connect(function()
    task.wait(0.3)
    applyUnwalk()
    startVisuals()  -- visuals conn is idempotent
end)

-- ============= BOOST BUTTON =============
local boostWindow = 0
boostBtn.MouseButton1Click:Connect(function()
    boostWindow = tick() + 0.4
    TS:Create(boostBtn, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(150, 90, 240) }):Play()
    task.delay(0.15, function()
        TS:Create(boostBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(90, 50, 160) }):Play()
    end)
end)

local boostTickConn = RS.Heartbeat:Connect(function()
    if not state.alive then return end
    if boostWindow > 0 and tick() < boostWindow then
        applySpeed(state.speed)
    elseif boostWindow > 0 then
        boostWindow = 0
    end
end)

-- ============= TOGGLE BUTTON =============
toggleBtn.MouseButton1Click:Connect(function()
    setToggle(not state.enabled)
end)

-- ============= DRAGGING =============
local dragging, dragStart, startPos = false, nil, nil
main.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = main.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UIS.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
        local delta = inp.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============= BOOT =============
applyUnwalk()
startUnwalkKeeper()
startVisuals()
startLoop()      -- toggle is ON by default
setToggle(true)

-- ============= RUNTIME HANDLE =============
_G._GojoTP = {
    destroy = function()
        state.alive   = false
        state.enabled = false
        stopLoop()
        stopVisuals()
        stopUnwalkKeeper()
        if boostTickConn then boostTickConn:Disconnect() end
        if state.charConn then state.charConn:Disconnect() end
        if gui then gui:Destroy() end
        _G._GojoTP = nil
    end,
    setSpeed = function(v)
        v = math.clamp(tonumber(v) or state.speed, 23, 30)
        state.speed   = v
        speedBox.Text = tostring(v)
    end,
    toggle  = setToggle,
    get     = function() return state.enabled, state.speed end,
    unwalk  = applyUnwalk,
    fov     = function(v) FOV_VALUE = tonumber(v) or FOV_VALUE end,
    stretch = function(v) STRETCH_SCALE = tonumber(v) or STRETCH_SCALE end,
}

print("[GOJO] Semi TP Helper — FOV 120 + Stretch + Unwalk active | Boost " .. state.speed)
