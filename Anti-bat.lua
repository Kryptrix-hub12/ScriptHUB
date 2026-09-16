local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AntiBatEnabled = false
local InfiniteJumpEnabled = false
local waitingForKey = false  -- true when rebinding anti-bat key

local antiBatKey = Enum.KeyCode.B  -- default keybind (works for keyboard & controller)

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local AntiBatConn = nil
local AntiRagdollConn = nil
local isMinimized = false

local SILVER = Color3.fromRGB(192, 192, 192)
local MAIN_TEXT = Color3.fromRGB(255, 255, 255)
local MUTED_TEXT = Color3.fromRGB(200, 190, 210)
local STATUS_GREEN = Color3.fromRGB(0, 255, 140)
local STATUS_RED = Color3.fromRGB(255, 70, 100)
local GLASS_COLOR = Color3.fromRGB(20, 12, 8)

local function startAntiBat()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if AntiBatConn then AntiBatConn:Disconnect() end
    AntiBatConn = RunService.Heartbeat:Connect(function()
        if not root or not root.Parent then return end
        local origXZ = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        root.Velocity = Vector3.new(4000, root.Velocity.Y, 4000)
        RunService.RenderStepped:Wait()
        root.Velocity = Vector3.new(origXZ.X, root.Velocity.Y, origXZ.Z)
    end)
end

local function stopAntiBat()
    if AntiBatConn then
        AntiBatConn:Disconnect()
        AntiBatConn = nil
    end
end

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z)
    end
end)

local function startAntiRagdoll()
    if AntiRagdollConn then return end
    AntiRagdollConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum2 then
            local st = hum2:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                hum2:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum2
                pcall(function()
                    local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                    if pm then require(pm:FindFirstChild("ControlModule")):Enable() end
                end)
                if root then
                    root.Velocity = Vector3.new(0,0,0)
                    root.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and not obj.Enabled then
                obj.Enabled = true
            end
        end
    end)
end

pcall(function()
    for _, old in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if old.Name == "K7s Anti Bat" then
            old:Destroy()
        end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "K7s Anti Bat"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.IgnoreGuiInset = true
gui.Parent = game:GetService("CoreGui")

local PW, PH = 160, 180  -- slightly adjusted height
local MINI_H = 34

local dp = Instance.new("Frame", gui)
dp.Name = "MainFrame"
dp.Size = UDim2.new(0, PW, 0, PH)
dp.Position = UDim2.new(0.5, -PW/2, 0.5, -PH/2)
dp.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
dp.BackgroundTransparency = 0.2
dp.Active = true
dp.ClipsDescendants = true

local corner = Instance.new("UICorner", dp)
corner.CornerRadius = UDim.new(0, 14)

local bgImage = Instance.new("ImageLabel", dp)
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://104070936675306"
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 0

local bgCorner = Instance.new("UICorner", bgImage)
bgCorner.CornerRadius = UDim.new(0, 14)

local header = Instance.new("Frame", dp)
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundTransparency = 1
header.ZIndex = 2

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(1, -45, 1, 0)
titleLbl.Position = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "K7 Anti Bat"
titleLbl.TextColor3 = MAIN_TEXT
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 2

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 18, 0, 18)
minimizeBtn.Position = UDim2.new(1, -24, 0.5, -9)
minimizeBtn.BackgroundColor3 = GLASS_COLOR
minimizeBtn.BackgroundTransparency = 0.5
minimizeBtn.Text = "Ã¢Ë†â€™"
minimizeBtn.TextColor3 = MAIN_TEXT
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 12
minimizeBtn.ZIndex = 2
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)
local minStr = Instance.new("UIStroke", minimizeBtn)
minStr.Color = SILVER
minStr.Thickness = 1

local dpSt = Instance.new("UIStroke", dp)
dpSt.Color = SILVER
dpSt.Thickness = 2
dpSt.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local ringAnim = nil
local function pulseRing()
    if ringAnim then ringAnim:Cancel() end
    ringAnim = TweenService:Create(dpSt, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.2
    })
    ringAnim:Play()
end
pulseRing()

local dragging, dragStart, startPos
dp.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = dp.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        dp.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local content = Instance.new("Frame", dp)
content.Size = UDim2.new(1, -20, 1, -56)
content.Position = UDim2.new(0, 10, 0, 38)
content.BackgroundTransparency = 1
content.ZIndex = 2

local layout = Instance.new("UIListLayout", content)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local function makeRow(height)
    local r = Instance.new("Frame", content)
    r.Size = UDim2.new(1, 0, 0, height or 24)
    r.BackgroundColor3 = GLASS_COLOR
    r.BackgroundTransparency = 0.6
    r.ZIndex = 2
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 5)
    local str = Instance.new("UIStroke", r)
    str.Color = SILVER
    str.Thickness = 0.8
    return r, str
end

local statusRow = Instance.new("Frame", content)
statusRow.Size = UDim2.new(1, 0, 0, 12)
statusRow.BackgroundTransparency = 1
statusRow.ZIndex = 2

local statusTxt = Instance.new("TextLabel", statusRow)
statusTxt.Size = UDim2.new(1, 0, 1, 0)
statusTxt.BackgroundTransparency = 1
statusTxt.Text = "STATUS: OFF"
statusTxt.TextColor3 = STATUS_RED
statusTxt.Font = Enum.Font.GothamBlack
statusTxt.TextSize = 9
statusTxt.TextXAlignment = Enum.TextXAlignment.Left
statusTxt.ZIndex = 2

local mainRow, toggleBtnStroke = makeRow(26)
local toggleBtn = Instance.new("TextButton", mainRow)
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = "ACTIVATE ANTI BAT"
toggleBtn.TextColor3 = MAIN_TEXT
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 8
toggleBtn.ZIndex = 2

local jumpRowFrame, jumpStroke = makeRow(24)
local jumpLabel = Instance.new("TextLabel", jumpRowFrame)
jumpLabel.Size = UDim2.new(0.6, 0, 1, 0)
jumpLabel.Position = UDim2.new(0, 6, 0, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Inf Jump"
jumpLabel.TextColor3 = MAIN_TEXT
jumpLabel.Font = Enum.Font.GothamBold
jumpLabel.TextSize = 9
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.ZIndex = 2

local jumpPill = Instance.new("Frame", jumpRowFrame)
jumpPill.Size = UDim2.new(0, 28, 0, 13)
jumpPill.Position = UDim2.new(1, -34, 0.5, -6.5)
jumpPill.BackgroundColor3 = Color3.fromRGB(5, 3, 10)
jumpPill.BackgroundTransparency = 0.3
jumpPill.ZIndex = 2
Instance.new("UICorner", jumpPill).CornerRadius = UDim.new(0, 6)
local pillStroke = Instance.new("UIStroke", jumpPill)
pillStroke.Color = SILVER
pillStroke.Thickness = 1

local jumpDot = Instance.new("Frame", jumpPill)
jumpDot.Size = UDim2.new(0, 8, 0, 8)
jumpDot.Position = UDim2.new(0, 3, 0.5, -4)
jumpDot.BackgroundColor3 = MUTED_TEXT
jumpDot.ZIndex = 2
Instance.new("UICorner", jumpDot).CornerRadius = UDim.new(0, 4)

local jumpToggleClick = Instance.new("TextButton", jumpRowFrame)
jumpToggleClick.Size = UDim2.new(1, 0, 1, 0)
jumpToggleClick.BackgroundTransparency = 1
jumpToggleClick.Text = ""
jumpToggleClick.ZIndex = 2

-- Keybind row for Anti-Bat only
local keyRow = Instance.new("Frame", content)
keyRow.Size = UDim2.new(1, 0, 0, 18)
keyRow.BackgroundTransparency = 1
keyRow.ZIndex = 2

local keyLabel = Instance.new("TextButton", keyRow)
keyLabel.Size = UDim2.new(1, 0, 1, 0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Anti Key: B"
keyLabel.TextColor3 = MUTED_TEXT
keyLabel.Font = Enum.Font.Code
keyLabel.TextSize = 9
keyLabel.ZIndex = 2

-- Footer with discord and credit
local footer = Instance.new("TextLabel", content)
footer.Size = UDim2.new(1, 0, 0, 14)
footer.BackgroundTransparency = 1
footer.Text = "discord.gg/k7hub  |  made by printed"
footer.Font = Enum.Font.Code
footer.TextSize = 8
footer.TextColor3 = MUTED_TEXT
footer.ZIndex = 2

local function toggleMinimize()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and MINI_H or PH
    TweenService:Create(dp, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, PW, 0, targetHeight)}):Play()
    content.Visible = not isMinimized
    minimizeBtn.Text = isMinimized and "+" or "Ã¢Ë†â€™"
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

local function slideDot(dot, pillStr, on)
    TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = on and UDim2.new(1, -13, 0.5, -4) or UDim2.new(0, 3, 0.5, -4),
        BackgroundColor3 = on and STATUS_GREEN or MUTED_TEXT
    }):Play()
    TweenService:Create(pillStr, TweenInfo.new(0.2), {
        Color = on and STATUS_GREEN or SILVER
    }):Play()
end

local function refreshUI()
    if AntiBatEnabled then
        toggleBtnStroke.Color = STATUS_GREEN
        toggleBtn.Text = "DEACTIVATE ANTI BAT"
        statusTxt.Text = "STATUS: ON"
        statusTxt.TextColor3 = STATUS_GREEN
    else
        toggleBtnStroke.Color = SILVER
        toggleBtn.Text = "ACTIVATE ANTI BAT"
        statusTxt.Text = "STATUS: OFF"
        statusTxt.TextColor3 = STATUS_RED
    end
end

local function toggleAntiBat()
    AntiBatEnabled = not AntiBatEnabled
    if AntiBatEnabled then startAntiBat() else stopAntiBat() end
    refreshUI()
end

local function toggleInfiniteJump()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    slideDot(jumpDot, pillStroke, InfiniteJumpEnabled)
end

toggleBtn.MouseButton1Click:Connect(toggleAntiBat)
jumpToggleClick.MouseButton1Click:Connect(toggleInfiniteJump)

-- Update key label
local function updateKeyLabel()
    keyLabel.Text = "Anti Key: " .. antiBatKey.Name
end

-- Keybind rebind logic
keyLabel.MouseButton1Click:Connect(function()
    if waitingForKey then return end
    waitingForKey = true
    keyLabel.Text = "Press any key..."
end)

-- Input handler (works for keyboard & controller)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if waitingForKey then
        -- Check if it's a valid key (KeyCode not Unknown)
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            antiBatKey = input.KeyCode
            updateKeyLabel()
            waitingForKey = false
        end
        return
    end

    -- Normal toggle via keybind
    if input.KeyCode == antiBatKey then
        toggleAntiBat()
    end
end)

-- Also handle if user clicks elsewhere to cancel? Not necessary, but we can add a timeout or click on UI to cancel.
-- For simplicity, if user clicks the keyLabel again while waiting, we cancel.
-- We'll modify the click to cancel if already waiting
keyLabel.MouseButton1Click:Connect(function()
    if waitingForKey then
        waitingForKey = false
        updateKeyLabel()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    if AntiBatEnabled then
        task.wait(0.3)
        startAntiBat()
    end
    task.wait(0.5)
    startAntiRagdoll()
end)

startAntiRagdoll()
refreshUI()
slideDot(jumpDot, pillStroke, InfiniteJumpEnabled)
updateKeyLabel()
