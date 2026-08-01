-- ================================================================
--  Locked  ·  LocalScript
--  Small draggable button: blue "Lock" → red "Unlock"
--  Follows the closest player at 1.5 studs, air + ground, anti‑jitter
--  No speed changes, hovers slightly off the ground
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean old button
if playerGui:FindFirstChild("LockedButton") then
    playerGui.LockedButton:Destroy()
end

-- ===================== STATE =====================
local active = false
local followConnection = nil
local targetPlayer = nil
local smoothTargetPos = nil   -- smoothed position to avoid jitter

-- ===================== BUTTON GUI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockedButton"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 70, 0, 30)   -- small but not tiny
button.Position = UDim2.new(0, 20, 0.5, -15)
button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)   -- blue
button.Text = "Lock"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Parent = screenGui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

-- Dragging logic
local dragging = false
local dragStart = nil
local startPos = nil

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===================== TOGGLE FUNCTION =====================
local function stopFollow()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
    targetPlayer = nil
    smoothTargetPos = nil
end

local function startFollow()
    stopFollow()  -- just in case

    -- Find the closest other player initially
    local function findClosest()
        local myPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not myPos then return nil end
        local bestDist = math.huge
        local bestPlayer = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (myPos.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPlayer = plr
                end
            end
        end
        return bestPlayer
    end

    targetPlayer = findClosest()
    if targetPlayer then
        smoothTargetPos = targetPlayer.Character.HumanoidRootPart.Position
    end

    followConnection = RunService.Heartbeat:Connect(function()
        if not active then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        -- Refresh closest player periodically (every 0.5s)
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer = findClosest()
            if targetPlayer then
                smoothTargetPos = targetPlayer.Character.HumanoidRootPart.Position
            end
        end

        if not targetPlayer then return end

        local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return end

        -- Smooth target position (anti‑jitter: lerp with factor 0.2)
        local targetPos = targetHrp.Position
        if not smoothTargetPos then
            smoothTargetPos = targetPos
        else
            smoothTargetPos = smoothTargetPos:Lerp(targetPos, 0.2)
        end

        -- Desired position: 1.5 studs behind the target (opposite of direction from target to us?)
        -- Actually we just want to stay 1.5 studs away from them. We can compute a point that is 1.5 studs from target towards our character.
        -- But better: we'll move towards the target, but stop at 1.5 studs distance.
        local toTarget = smoothTargetPos - hrp.Position
        local dist = toTarget.Magnitude
        local moveDir = toTarget.Unit

        if dist > 1.5 then
            -- Move closer
            -- Use Humanoid.MoveTo for ground pathfinding; but also need to fly if target is in air.
            local targetY = smoothTargetPos.Y
            local onGround = (hrp.Velocity.Y >= -1) -- rough ground detection

            -- If the target is more than 3 studs above us, use velocity to fly up
            if targetY - hrp.Position.Y > 3 then
                -- Fly up
                local vel = hrp.Velocity
                hrp.Velocity = Vector3.new(moveDir.X * 60, 50, moveDir.Z * 60)   -- upward boost
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            else
                -- Normal ground/air movement
                -- Use MoveTo which works on ground; if in air, we can add upward velocity to stay level
                hum:MoveTo(smoothTargetPos - moveDir * 1.5)   -- move towards a point 1.5m away from target in the direction away from us
                -- Keep a bit off the ground: if we are too low, apply a small upward velocity
                if hrp.Position.Y - 0.5 < smoothTargetPos.Y then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 2, hrp.Velocity.Z)  -- small hover
                end
            end
        else
            -- Already close enough, just stop
            hum:MoveTo(hrp.Position)   -- stop moving
        end
    end)
end

-- ===================== BUTTON CLICK =====================
button.MouseButton1Click:Connect(function()
    active = not active
    if active then
        button.Text = "Unlock"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)   -- red
        startFollow()
    else
        button.Text = "Lock"
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)   -- blue
        stopFollow()
    end
end)

-- Cleanup on character death
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    if active then
        stopFollow()
        startFollow()
    end
end)

print("[Locked] Ready – drag the button and click to follow nearest player.")
