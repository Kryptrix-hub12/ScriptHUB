-- CZ Hub AntiBat (Purple Theme, 2 toggles)
-- LEAKED BY PR1MEJH4Y AND XX (Modified UI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ----------------------------------------------------------------
--  Colors & State (Deep Purple)
-- ----------------------------------------------------------------
local State = {
    antiBatActive = false,
    infJumpActive = false,
    antiBatThread = nil,
    infJumpThread = nil,
    guiVisible = true
}

local C = {
    bg = Color3.fromRGB(20, 10, 30),        -- Very dark purple background
    card = Color3.fromRGB(40, 20, 55),      -- Medium purple card background
    border = Color3.fromRGB(80, 50, 120),   -- Thin purple card border
    text = Color3.fromRGB(255, 255, 255),   -- Main text
    textSub = Color3.fromRGB(180, 150, 210),-- Inactive status text
    accent = Color3.fromRGB(160, 80, 255),  -- Vibrant purple (Status Active)
    pillOff = Color3.fromRGB(60, 40, 80),   -- Inactive toggle pill
    pillOn = Color3.fromRGB(160, 80, 255),  -- Active toggle pill
    dotOff = Color3.fromRGB(180, 150, 210), -- Inactive toggle ball
    dotOn = Color3.fromRGB(255, 255, 255),  -- Active toggle ball (White)
    greenDot = Color3.fromRGB(200, 100, 255), -- Top right indicator (Purple-pink)
    watermark = Color3.fromRGB(140, 100, 180)
}

-- ----------------------------------------------------------------
--  Anti Bat Toggle
-- ----------------------------------------------------------------
local antiBatStatus, antiBatSwitchBall, antiBatRow, antiBatRowStroke, antiBatPill
local function toggleAntiBat()
    State.antiBatActive = not State.antiBatActive
    if antiBatStatus then
        antiBatStatus.Text = State.antiBatActive and "ENABLED" or "DISABLED"
        antiBatStatus.TextColor3 = State.antiBatActive and C.accent or C.textSub
    end
    if antiBatRow and antiBatRowStroke then
        TweenService:Create(antiBatRowStroke, TweenInfo.new(0.2), {
            Color = State.antiBatActive and C.accent or C.border
        }):Play()
    end
    if antiBatPill then
        TweenService:Create(antiBatPill, TweenInfo.new(0.2), {
            BackgroundColor3 = State.antiBatActive and C.pillOn or C.pillOff
        }):Play()
    end
    if antiBatSwitchBall then
        TweenService:Create(antiBatSwitchBall, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = State.antiBatActive and UDim2.new(1, -5, 0.5, -5) or UDim2.new(0, 3, 0.5, -5),
            BackgroundColor3 = State.antiBatActive and C.dotOn or C.dotOff,
        }):Play()
    end
    if State.antiBatActive then
        if State.antiBatThread then State.antiBatThread:Disconnect() end
        State.antiBatThread = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            if hum.MoveDirection.Magnitude <= 0 then return end
            local vel = hrp.Velocity
            hrp.Velocity = Vector3.new(vel.X * 50, 50, vel.Z * 50)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, 0.05, 0)
        end)
    else
        if State.antiBatThread then
            State.antiBatThread:Disconnect()
            State.antiBatThread = nil
        end
    end
end

-- ----------------------------------------------------------------
--  Infinite Jump (Hold to jump repeatedly)
-- ----------------------------------------------------------------
local infJumpStatus, infJumpSwitchBall, infJumpRow, infJumpRowStroke, infJumpPill
local jumpHeld = false
local lastJumpBoostTime = 0
local JUMP_BOOST_INTERVAL = 0.05

task.spawn(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
    if pg then
        local function hookJumpButton(btn)
            if btn:IsA("GuiButton") and btn.Name == "JumpButton" and not btn:GetAttribute("InfJumpHooked") then
                btn:SetAttribute("InfJumpHooked", true)
                btn.MouseButton1Down:Connect(function()
                    if State.infJumpActive then jumpHeld = true end
                end)
                btn.MouseButton1Up:Connect(function() jumpHeld = false end)
                btn.MouseLeave:Connect(function() jumpHeld = false end)
            end
        end
        for _, d in ipairs(pg:GetDescendants()) do hookJumpButton(d) end
        pg.DescendantAdded:Connect(hookJumpButton)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.infJumpActive then
        jumpHeld = true
        task.wait(0.05)
        jumpHeld = false
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if State.infJumpActive and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == Enum.KeyCode.Space then
        jumpHeld = true
    end
end)
UserInputService.InputEnded:Connect(function(inp, gpe)
    if inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == Enum.KeyCode.Space then
        jumpHeld = false
    end
end)

local function startInfJumpLoop()
    if State.infJumpThread then State.infJumpThread:Disconnect() end
    State.infJumpThread = RunService.Stepped:Connect(function()
        if not State.infJumpActive then return end
        if not jumpHeld then return end
        local now = tick()
        if now - lastJumpBoostTime < JUMP_BOOST_INTERVAL then return end
        lastJumpBoostTime = now
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then return end
        local vel = hrp.AssemblyLinearVelocity
        if vel.Y < 55 then
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 65, vel.Z)
        end
    end)
end

local function stopInfJumpLoop()
    if State.infJumpThread then
        State.infJumpThread:Disconnect()
        State.infJumpThread = nil
    end
    jumpHeld = false
    lastJumpBoostTime = 0
end

local function toggleInfJump()
    State.infJumpActive = not State.infJumpActive
    if infJumpStatus then
        infJumpStatus.Text = State.infJumpActive and "ENABLED" or "DISABLED"
        infJumpStatus.TextColor3 = State.infJumpActive and C.accent or C.textSub
    end
    if infJumpRow and infJumpRowStroke then
        TweenService:Create(infJumpRowStroke, TweenInfo.new(0.2), {
            Color = State.infJumpActive and C.accent or C.border
        }):Play()
    end
    if infJumpPill then
        TweenService:Create(infJumpPill, TweenInfo.new(0.2), {
            BackgroundColor3 = State.infJumpActive and C.pillOn or C.pillOff
        }):Play()
    end
    if infJumpSwitchBall then
        TweenService:Create(infJumpSwitchBall, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = State.infJumpActive and UDim2.new(1, -5, 0.5, -5) or UDim2.new(0, 3, 0.5, -5),
            BackgroundColor3 = State.infJumpActive and C.dotOn or C.dotOff,
        }):Play()
    end
    if State.infJumpActive then
        startInfJumpLoop()
    else
        stopInfJumpLoop()
    end
end

-- ----------------------------------------------------------------
--  HEAD TEXT
-- ----------------------------------------------------------------
local function createHeadText()
    local old = LocalPlayer.Character:FindFirstChild("HeadText")
    if old then old:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HeadText"
    billboard.Adornee = LocalPlayer.Character:FindFirstChild("Head") or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 250, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "#1 antibat discord.gg/p3E77CCeJE"
    text.TextColor3 = C.accent
    text.TextStrokeTransparency = 0.3
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.TextScaled = true
    text.TextWrapped = true
    billboard.Parent = LocalPlayer.Character
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if char and char:FindFirstChild("Head") then createHeadText() end
end)
if LocalPlayer.Character then createHeadText() end

-- ----------------------------------------------------------------
--  GUI CREATION (Purple Themed)
-- ----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "CZHubAntiBat"
gui.ResetOnSpawn = false
pcall(function()
    gui.Parent = game:GetService("CoreGui")
    if syn and syn.protect_gui then syn.protect_gui(gui) end
end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local mainOuter = Instance.new("Frame", gui)
mainOuter.Size = UDim2.new(0, 210, 0, 205) 
mainOuter.Position = UDim2.new(0.05, 0, 0.3, 0)
mainOuter.BackgroundColor3 = C.bg
mainOuter.BackgroundTransparency = 0
mainOuter.BorderSizePixel = 0
mainOuter.ClipsDescendants = true
mainOuter.ZIndex = 2

-- Main Rounded Corners
local mainCorner = Instance.new("UICorner", mainOuter)
mainCorner.CornerRadius = UDim.new(0, 12)

-- Background Image (The CZ Logo)
-- INSTRUCTION: Replace "rbxassetid://YOUR_LOGO_ID" with the actual Roblox Decal ID of the "CZ hub" image you provided
local bgImage = Instance.new("ImageLabel", mainOuter)
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://YOUR_LOGO_ID" -- REPLACE THIS ID
bgImage.ImageTransparency = 0.85 -- Transparency to make text readable
bgImage.ScaleType = Enum.ScaleType.Stretch
bgImage.ZIndex = 1

-- Title
local title = Instance.new("TextLabel", mainOuter)
title.Size = UDim2.new(0.8, 0, 0, 20)
title.Position = UDim2.new(0.05, 0, 0.02, 0)
title.BackgroundTransparency = 1
title.Text = "CZ Hub AntiBat"
title.TextColor3 = C.text
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3

-- Purple Dot Indicator (Replacing the green one to match the theme)
local dot = Instance.new("Frame", mainOuter)
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(1, -12, 0, 6)
dot.BackgroundColor3 = C.greenDot
dot.BorderSizePixel = 0
dot.ZIndex = 3
local dotCorner = Instance.new("UICorner", dot)
dotCorner.CornerRadius = UDim.new(0, 4)

-- ----------------------------------------------------------------
--  ROW 1: Anti Bat Card
-- ----------------------------------------------------------------
antiBatRow = Instance.new("Frame", mainOuter)
antiBatRow.Size = UDim2.new(1, -16, 0, 58)
antiBatRow.Position = UDim2.new(0, 8, 0, 32)
antiBatRow.BackgroundColor3 = C.card
antiBatRow.BackgroundTransparency = 0
antiBatRow.ZIndex = 2
local antiBatCorner = Instance.new("UICorner", antiBatRow)
antiBatCorner.CornerRadius = UDim.new(0, 8)

antiBatRowStroke = Instance.new("UIStroke", antiBatRow)
antiBatRowStroke.Thickness = 1
antiBatRowStroke.Color = C.border
antiBatRowStroke.Transparency = 0

local abLabel = Instance.new("TextLabel", antiBatRow)
abLabel.Size = UDim2.new(1, -60, 0, 16)
abLabel.Position = UDim2.new(0, 12, 0, 8)
abLabel.BackgroundTransparency = 1
abLabel.Text = "ANTI BAT"
abLabel.TextColor3 = C.text
abLabel.Font = Enum.Font.GothamBold
abLabel.TextSize = 12
abLabel.TextXAlignment = Enum.TextXAlignment.Left
abLabel.ZIndex = 3

antiBatStatus = Instance.new("TextLabel", antiBatRow)
antiBatStatus.Size = UDim2.new(1, -60, 0, 14)
antiBatStatus.Position = UDim2.new(0, 12, 0, 26)
antiBatStatus.BackgroundTransparency = 1
antiBatStatus.Text = "DISABLED"
antiBatStatus.TextColor3 = C.textSub
antiBatStatus.Font = Enum.Font.GothamSemibold
antiBatStatus.TextSize = 10
antiBatStatus.TextXAlignment = Enum.TextXAlignment.Left
antiBatStatus.ZIndex = 3

antiBatPill = Instance.new("Frame", antiBatRow)
antiBatPill.Size = UDim2.new(0, 34, 0, 18)
antiBatPill.Position = UDim2.new(1, -42, 0.5, -9)
antiBatPill.BackgroundColor3 = C.pillOff
antiBatPill.ZIndex = 3
local pillCorner = Instance.new("UICorner", antiBatPill)
pillCorner.CornerRadius = UDim.new(0, 9)
local pillStroke = Instance.new("UIStroke", antiBatPill)
pillStroke.Color = C.border
pillStroke.Thickness = 1
pillStroke.Transparency = 0.4

antiBatSwitchBall = Instance.new("Frame", antiBatPill)
antiBatSwitchBall.Size = UDim2.new(0, 10, 0, 10)
antiBatSwitchBall.Position = UDim2.new(0, 3, 0.5, -5)
antiBatSwitchBall.BackgroundColor3 = C.dotOff
antiBatSwitchBall.ZIndex = 4
local ballCorner = Instance.new("UICorner", antiBatSwitchBall)
ballCorner.CornerRadius = UDim.new(0, 5)

local abBtn = Instance.new("TextButton", antiBatRow)
abBtn.Size = UDim2.new(1, 0, 1, 0)
abBtn.BackgroundTransparency = 1
abBtn.Text = ""
abBtn.ZIndex = 5
abBtn.MouseButton1Click:Connect(toggleAntiBat)

-- ----------------------------------------------------------------
--  ROW 2: Inf Jump Card
-- ----------------------------------------------------------------
infJumpRow = Instance.new("Frame", mainOuter)
infJumpRow.Size = UDim2.new(1, -16, 0, 58)
infJumpRow.Position = UDim2.new(0, 8, 0, 96)
infJumpRow.BackgroundColor3 = C.card
infJumpRow.BackgroundTransparency = 0
infJumpRow.ZIndex = 2
local infJumpCorner = Instance.new("UICorner", infJumpRow)
infJumpCorner.CornerRadius = UDim.new(0, 8)

infJumpRowStroke = Instance.new("UIStroke", infJumpRow)
infJumpRowStroke.Thickness = 1
infJumpRowStroke.Color = C.border
infJumpRowStroke.Transparency = 0

local ijLabel = Instance.new("TextLabel", infJumpRow)
ijLabel.Size = UDim2.new(1, -60, 0, 16)
ijLabel.Position = UDim2.new(0, 12, 0, 8)
ijLabel.BackgroundTransparency = 1
ijLabel.Text = "INF JUMP"
ijLabel.TextColor3 = C.text
ijLabel.Font = Enum.Font.GothamBold
ijLabel.TextSize = 12
ijLabel.TextXAlignment = Enum.TextXAlignment.Left
ijLabel.ZIndex = 3

infJumpStatus = Instance.new("TextLabel", infJumpRow)
infJumpStatus.Size = UDim2.new(1, -60, 0, 14)
infJumpStatus.Position = UDim2.new(0, 12, 0, 26)
infJumpStatus.BackgroundTransparency = 1
infJumpStatus.Text = "DISABLED"
infJumpStatus.TextColor3 = C.textSub
infJumpStatus.Font = Enum.Font.GothamSemibold
infJumpStatus.TextSize = 10
infJumpStatus.TextXAlignment = Enum.TextXAlignment.Left
infJumpStatus.ZIndex = 3

infJumpPill = Instance.new("Frame", infJumpRow)
infJumpPill.Size = UDim2.new(0, 34, 0, 18)
infJumpPill.Position = UDim2.new(1, -42, 0.5, -9)
infJumpPill.BackgroundColor3 = C.pillOff
infJumpPill.ZIndex = 3
local pillCorner2 = Instance.new("UICorner", infJumpPill)
pillCorner2.CornerRadius = UDim.new(0, 9)
local pillStroke2 = Instance.new("UIStroke", infJumpPill)
pillStroke2.Color = C.border
pillStroke2.Thickness = 1
pillStroke2.Transparency = 0.4

infJumpSwitchBall = Instance.new("Frame", infJumpPill)
infJumpSwitchBall.Size = UDim2.new(0, 10, 0, 10)
infJumpSwitchBall.Position = UDim2.new(0, 3, 0.5, -5)
infJumpSwitchBall.BackgroundColor3 = C.dotOff
infJumpSwitchBall.ZIndex = 4
local ballCorner2 = Instance.new("UICorner", infJumpSwitchBall)
ballCorner2.CornerRadius = UDim.new(0, 5)

local ijBtn = Instance.new("TextButton", infJumpRow)
ijBtn.Size = UDim2.new(1, 0, 1, 0)
ijBtn.BackgroundTransparency = 1
ijBtn.Text = ""
ijBtn.ZIndex = 5
ijBtn.MouseButton1Click:Connect(toggleInfJump)

-- ----------------------------------------------------------------
--  Footer
-- ----------------------------------------------------------------
local footer = Instance.new("Frame", mainOuter)
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -22)
footer.BackgroundTransparency = 1
footer.ZIndex = 3

local inviteLabel = Instance.new("TextLabel", footer)
inviteLabel.Size = UDim2.new(1, 0, 0, 20)
inviteLabel.Position = UDim2.new(0, 0, 0, 0)
inviteLabel.BackgroundTransparency = 1
inviteLabel.Text = "BEST ANTI BAT"
inviteLabel.TextColor3 = C.watermark
inviteLabel.Font = Enum.Font.GothamBold
inviteLabel.TextSize = 9
inviteLabel.TextXAlignment = Enum.TextXAlignment.Center
inviteLabel.ZIndex = 3

-- ----------------------------------------------------------------
--  Dragging
-- ----------------------------------------------------------------
local drag = {}
mainOuter.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        drag.active = true
        drag.start = inp.Position
        drag.startPos = mainOuter.Position
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then drag.active = false end
        end)
    end
end)
mainOuter.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
        drag.input = inp
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if inp == drag.input and drag.active then
        local delta = inp.Position - drag.start
        mainOuter.Position = UDim2.new(drag.startPos.X.Scale, drag.startPos.X.Offset + delta.X, drag.startPos.Y.Scale, drag.startPos.Y.Offset + delta.Y)
    end
end)

-- ----------------------------------------------------------------
--  Hide/Show with LeftCtrl
-- ----------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        State.guiVisible = not State.guiVisible
        gui.Enabled = State.guiVisible
    end
end)

print("CZ Hub AntiBat Loaded (Purple Theme). Press LCTRL to hide/show.")
