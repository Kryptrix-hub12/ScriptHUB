print("Leaked by bloodline gg")  -- ðŸ‘ˆ Printed before the script starts

-- // ========================== //
-- //    ADAPT | TP BAT HUB      //
-- //   (GUI + Antiâ€‘Desync)      //
-- // ========================== //

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local workspace = game:GetService("Workspace")

-- // Local Player
local LP = Players.LocalPlayer
if not LP then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LP = Players.LocalPlayer
end

-- // ========================== //
-- //          GUI              //
-- // ========================== //

local AdaptTpBat = Instance.new("ScreenGui")
AdaptTpBat.Name = "AdaptTpBat"
AdaptTpBat.IgnoreGuiInset = true
AdaptTpBat.ResetOnSpawn = false
AdaptTpBat.DisplayOrder = 999999
AdaptTpBat.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AdaptTpBat.Parent = LP:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Position = UDim2.new(0.5, -148, 0.5, -52)
MainFrame.Size = UDim2.new(0, 296, 0, 104)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Parent = AdaptTpBat

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 1.3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Transparency = 0.55
UIStroke.Parent = MainFrame

-- Background Image
local ImageLabel = Instance.new("ImageLabel")
ImageLabel.Size = UDim2.new(1, 0, 1, 0)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Image = "rbxassetid://93993067792974"
ImageLabel.ScaleType = Enum.ScaleType.Crop
ImageLabel.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 14)
UICorner2.Parent = ImageLabel

-- Dark Overlay
local Overlay = Instance.new("Frame")
Overlay.ZIndex = 2
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.35
Overlay.BorderSizePixel = 0
Overlay.Parent = MainFrame

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 14)
UICorner3.Parent = Overlay

local UIGradient = Instance.new("UIGradient")
UIGradient.Rotation = 90
UIGradient.Transparency = NumberSequence.new(0.5, 0.7)
UIGradient.Parent = Overlay

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.ZIndex = 6
TitleLabel.Position = UDim2.new(0, 14, 0, 10)
TitleLabel.Size = UDim2.new(1, -50, 0, 18)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ADAPT  |  TP BAT"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local SubLabel = Instance.new("TextLabel")
SubLabel.ZIndex = 6
SubLabel.Position = UDim2.new(0, 14, 0, 28)
SubLabel.Size = UDim2.new(1, -50, 0, 14)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "toggle to lock nearest player"
SubLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.ZIndex = 8
CloseBtn.Position = UDim2.new(1, -34, 0, 10)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "Ã—"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 15
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = MainFrame

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(1, 0)
UICorner4.Parent = CloseBtn

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Color = Color3.fromRGB(255, 255, 255)
UIStroke2.Transparency = 0.35
UIStroke2.Parent = CloseBtn

-- Invisible click area (for toggle)
local ClickArea = Instance.new("TextButton")
ClickArea.ZIndex = 7
ClickArea.Size = UDim2.new(1, -40, 0, 48)
ClickArea.BackgroundTransparency = 1
ClickArea.Text = ""
ClickArea.AutoButtonColor = false
ClickArea.Parent = MainFrame

-- Bottom bar (primary action)
local Bar = Instance.new("Frame")
Bar.ZIndex = 5
Bar.Position = UDim2.new(0, 12, 0, 58)
Bar.Size = UDim2.new(1, -24, 0, 34)
Bar.BackgroundTransparency = 1
Bar.Parent = MainFrame

local MenuBtn = Instance.new("TextButton")
MenuBtn.ZIndex = 8
MenuBtn.Size = UDim2.new(0, 44, 1, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MenuBtn.BackgroundTransparency = 0.3
MenuBtn.BorderSizePixel = 0
MenuBtn.Text = "Â·Â·Â·"
MenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuBtn.TextSize = 15
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.AutoButtonColor = false
MenuBtn.Parent = Bar

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(1, 0)
UICorner5.Parent = MenuBtn

local UIStroke3 = Instance.new("UIStroke")
UIStroke3.Color = Color3.fromRGB(255, 255, 255)
UIStroke3.Transparency = 0.35
UIStroke3.Parent = MenuBtn

local ActionFrame = Instance.new("Frame")
ActionFrame.ZIndex = 7
ActionFrame.Position = UDim2.new(0, 50, 0, 0)
ActionFrame.Size = UDim2.new(1, -50, 1, 0)
ActionFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ActionFrame.BackgroundTransparency = 0.3
ActionFrame.BorderSizePixel = 0
ActionFrame.Parent = Bar

local UICorner6 = Instance.new("UICorner")
UICorner6.CornerRadius = UDim.new(1, 0)
UICorner6.Parent = ActionFrame

local UIStroke4 = Instance.new("UIStroke")
UIStroke4.Color = Color3.fromRGB(255, 255, 255)
UIStroke4.Transparency = 0.35
UIStroke4.Parent = ActionFrame

-- The main toggle button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.ZIndex = 9
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = "ACTIVATE TP BAT"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ActionFrame

-- Settings panel (hidden by default)
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 5
SettingsPanel.Position = UDim2.new(0, 12, 0, 100)
SettingsPanel.Size = UDim2.new(1, -24, 0, 76)
SettingsPanel.BackgroundTransparency = 1
SettingsPanel.Parent = MainFrame

-- Keyboard row
local KbRow = Instance.new("Frame")
KbRow.ZIndex = 5
KbRow.Size = UDim2.new(1, 0, 0, 32)
KbRow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KbRow.BackgroundTransparency = 0.35
KbRow.BorderSizePixel = 0
KbRow.Parent = SettingsPanel

local UICorner7 = Instance.new("UICorner")
UICorner7.CornerRadius = UDim.new(1, 0)
UICorner7.Parent = KbRow

local UIStroke5 = Instance.new("UIStroke")
UIStroke5.Color = Color3.fromRGB(80, 80, 90)
UIStroke5.Transparency = 0.3
UIStroke5.Parent = KbRow

local KbLabel = Instance.new("TextLabel")
KbLabel.ZIndex = 6
KbLabel.Position = UDim2.new(0, 16, 0, 0)
KbLabel.Size = UDim2.new(0.5, 0, 1, 0)
KbLabel.BackgroundTransparency = 1
KbLabel.Text = "Keyboard"
KbLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
KbLabel.TextSize = 11
KbLabel.Font = Enum.Font.GothamBold
KbLabel.TextXAlignment = Enum.TextXAlignment.Left
KbLabel.Parent = KbRow

local KbBindBtn = Instance.new("TextButton")
KbBindBtn.ZIndex = 8
KbBindBtn.Position = UDim2.new(1, -120, 0.5, -11)
KbBindBtn.Size = UDim2.new(0, 108, 0, 22)
KbBindBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
KbBindBtn.BackgroundTransparency = 0.15
KbBindBtn.BorderSizePixel = 0
KbBindBtn.Text = "[ X ]"
KbBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KbBindBtn.TextSize = 10
KbBindBtn.Font = Enum.Font.GothamBold
KbBindBtn.AutoButtonColor = false
KbBindBtn.Parent = KbRow

local UICorner8 = Instance.new("UICorner")
UICorner8.CornerRadius = UDim.new(1, 0)
UICorner8.Parent = KbBindBtn

local UIStroke6 = Instance.new("UIStroke")
UIStroke6.Color = Color3.fromRGB(255, 255, 255)
UIStroke6.Transparency = 0.25
UIStroke6.Parent = KbBindBtn

-- Controller row
local CtrlRow = Instance.new("Frame")
CtrlRow.ZIndex = 5
CtrlRow.Position = UDim2.new(0, 0, 0, 40)
CtrlRow.Size = UDim2.new(1, 0, 0, 32)
CtrlRow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CtrlRow.BackgroundTransparency = 0.35
CtrlRow.BorderSizePixel = 0
CtrlRow.Parent = SettingsPanel

local UICorner9 = Instance.new("UICorner")
UICorner9.CornerRadius = UDim.new(1, 0)
UICorner9.Parent = CtrlRow

local UIStroke7 = Instance.new("UIStroke")
UIStroke7.Color = Color3.fromRGB(80, 80, 90)
UIStroke7.Transparency = 0.3
UIStroke7.Parent = CtrlRow

local CtrlLabel = Instance.new("TextLabel")
CtrlLabel.ZIndex = 6
CtrlLabel.Position = UDim2.new(0, 16, 0, 0)
CtrlLabel.Size = UDim2.new(0.5, 0, 1, 0)
CtrlLabel.BackgroundTransparency = 1
CtrlLabel.Text = "Controller"
CtrlLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
CtrlLabel.TextSize = 11
CtrlLabel.Font = Enum.Font.GothamBold
CtrlLabel.TextXAlignment = Enum.TextXAlignment.Left
CtrlLabel.Parent = CtrlRow

local CtrlBindBtn = Instance.new("TextButton")
CtrlBindBtn.ZIndex = 8
CtrlBindBtn.Position = UDim2.new(1, -120, 0.5, -11)
CtrlBindBtn.Size = UDim2.new(0, 108, 0, 22)
CtrlBindBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CtrlBindBtn.BackgroundTransparency = 0.15
CtrlBindBtn.BorderSizePixel = 0
CtrlBindBtn.Text = "[ ButtonR1 ]"
CtrlBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CtrlBindBtn.TextSize = 10
CtrlBindBtn.Font = Enum.Font.GothamBold
CtrlBindBtn.AutoButtonColor = false
CtrlBindBtn.Parent = CtrlRow

local UICorner10 = Instance.new("UICorner")
UICorner10.CornerRadius = UDim.new(1, 0)
UICorner10.Parent = CtrlBindBtn

local UIStroke8 = Instance.new("UIStroke")
UIStroke8.Color = Color3.fromRGB(255, 255, 255)
UIStroke8.Transparency = 0.25
UIStroke8.Parent = CtrlBindBtn

-- ========================== //
-- //     TP BAT LOGIC       //
-- ========================== //

-- // Toggles
local autoBat = false
local silentAim = false
local cooldown = false

-- // Keybinds (defaults)
local TOGGLE_BAT = Enum.KeyCode.X
local TOGGLE_SILENT = Enum.KeyCode.Z

-- // Character refs
local char, h, hrp = nil, nil, nil

-- // Functions
local function getBat()
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

local function tryHit()
    if cooldown then return end
    cooldown = true
    pcall(function()
        local bat = getBat()
        if bat then
            bat:Activate()
            local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
        end
    end)
    task.delay(0.05, function() cooldown = false end)
end

local function getClosest()
    if not hrp then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local d = (hrp.Position - tr.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = p
                end
            end
        end
    end
    return best, bestDist
end

local function setupChar(newChar)
    char = newChar
    task.wait(0.1)
    h = char:WaitForChild("Humanoid", 5)
    hrp = char:WaitForChild("HumanoidRootPart", 5)
end

-- // Character respawn handling
LP.CharacterAdded:Connect(setupChar)
if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

-- // MAIN LOOP
RunService.Heartbeat:Connect(function()
    if not (autoBat and h and hrp) then return end

    local target, dist = getClosest()
    if not target or not target.Character then return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    if not tr then return end

    -- 1. Desync
    if sethiddenproperty then
        sethiddenproperty(hrp, "PhysicsRepRootPart", tr)
        pcall(function() sethiddenproperty(hrp, "NetworkOwnership", 9999) end)
    end

    -- 2. Movement â€“ stay within 8 studs
    local targetPos = tr.Position + Vector3.new(0, 0.9, 0)
    if dist > 8 then
        hrp.CFrame = CFrame.new(targetPos)
    end

    -- 3. Aim â€“ lock or free (silent)
    local cam = workspace.CurrentCamera
    if not silentAim then
        cam.CFrame = CFrame.new(cam.CFrame.Position, tr.Position + Vector3.new(0, 0.5, 0))
    end

    -- 4. Hit
    tryHit()
end)

-- // Keybinds
UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = inp.KeyCode

    if k == TOGGLE_BAT then
        autoBat = not autoBat
        ToggleBtn.Text = autoBat and "DEACTIVATE TP BAT" or "ACTIVATE TP BAT"
        print("Auto Bat:", autoBat and "ON" or "OFF")
    elseif k == TOGGLE_SILENT then
        silentAim = not silentAim
        print("Silent Aim:", silentAim and "ON (camera free)" or "OFF (camera lock)")
    end
end)

-- // ========================== //
-- //     GUI EVENT BINDINGS    //
-- // ========================== //

-- Toggle button
ToggleBtn.MouseButton1Click:Connect(function()
    autoBat = not autoBat
    ToggleBtn.Text = autoBat and "DEACTIVATE TP BAT" or "ACTIVATE TP BAT"
    print("Auto Bat toggled via GUI:", autoBat and "ON" or "OFF")
end)

-- Close button â€“ hide GUI
CloseBtn.MouseButton1Click:Connect(function()
    AdaptTpBat.Enabled = false
end)

-- Menu button â€“ show/hide settings
MenuBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

-- // Display current keybinds in settings
KbBindBtn.Text = "[ " .. TOGGLE_BAT.Name .. " ]"
CtrlBindBtn.Text = "[ ButtonR1 ]"  -- controller keybind not implemented

print("ADAPT | TP BAT loaded. Press X to toggle, Z for silent aim.")

print("Leaked by bloodline")  -- ðŸ‘ˆ Printed at the end of the script
