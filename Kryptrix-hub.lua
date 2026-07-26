-- ================================================================
--  Brainrot Base Farmer  ·  LocalScript
--  Finds the highest‑tier base, dashes to its laser line at 500 spd
--  Speed bypass enforced, pathfinding for obstacles, ESP highlight
--  UI: Modern glass, movable
-- ================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean old
if playerGui:FindFirstChild("BaseFarmer") then
    playerGui.BaseFarmer:Destroy()
end

-- ===================== CONFIG =====================
local DASH_SPEED = 500        -- super‑fast dash speed

-- ===================== STATE =====================
local active = false
local bestPlot = nil
local bestTier = 0
local highlight = nil
local dashConn = nil
local speedBypass = nil       -- Heartbeat that forces WalkSpeed

-- ===================== HELPERS =====================
local function getCharParts()
    local char = player.Character
    if not char then return nil, nil end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

-- ===================== SPEED BYPASS =====================
local function startSpeedBypass()
    if speedBypass then speedBypass:Disconnect() end
    speedBypass = RunService.Heartbeat:Connect(function()
        local _, hum = getCharParts()
        if hum then
            -- Bypass the game's speed clamping
            hum.WalkSpeed = DASH_SPEED
            -- If the game sets the "Stealing" attribute to slow us down, override it
            if player:GetAttribute("Stealing") then
                player:SetAttribute("Stealing", false)
            end
        end
    end)
end

local function stopSpeedBypass()
    if speedBypass then speedBypass:Disconnect(); speedBypass = nil end
end

-- ===================== FIND BEST PLOT =====================
local function scanBestPlot()
    bestPlot = nil
    bestTier = 0
    for _, plot in ipairs(CollectionService:GetTagged("Plot")) do
        local tier = plot:GetAttribute("Tier") or 0
        if tier > bestTier then
            bestTier = tier
            bestPlot = plot
        end
    end

    -- Update highlight
    if highlight then highlight:Destroy(); highlight = nil end
    if bestPlot then
        local primary = bestPlot:FindFirstChild("PlotLaserHitbox", true) or bestPlot.PrimaryPart or bestPlot:FindFirstChildWhichIsA("BasePart")
        if primary then
            highlight = Instance.new("Highlight")
            highlight.Name = "BestBase"
            highlight.Adornee = primary
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.6
            highlight.OutlineColor = Color3.fromRGB(255,215,0)  -- gold
            highlight.OutlineTransparency = 0
            highlight.Parent = primary
        end
    end
end

-- ===================== DASH TO LASER LINE =====================
local function dashToBestBase()
    if not bestPlot then return end
    local hrp, hum = getCharParts()
    if not hrp or not hum then return end

    -- Find the laser hitbox (the entrance line)
    local laserHitbox = bestPlot:FindFirstChild("PlotLaserHitbox", true)
    local targetPos
    if laserHitbox and laserHitbox:IsA("BasePart") then
        targetPos = laserHitbox.Position
    else
        -- Fallback: use the plot's primary part
        targetPos = bestPlot:GetPivot().Position
    end

    -- Cancel any existing dash
    if dashConn then dashConn:Disconnect() end

    -- Start speed bypass
    startSpeedBypass()

    -- Use pathfinding to get to the target
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentMaxSlope = 45,
        WaypointSpacing = 3,
    })
    local success = pcall(function()
        path:ComputeAsync(hrp.Position, targetPos)
    end)
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        local idx = 1
        dashConn = RunService.Heartbeat:Connect(function()
            local hrpNow, humNow = getCharParts()
            if not hrpNow or not humNow then dashConn:Disconnect(); return end

            local dist = (hrpNow.Position - targetPos).Magnitude
            if dist <= 5 then
                hrpNow.Velocity = Vector3.new(0, hrpNow.Velocity.Y, 0)
                dashConn:Disconnect()
                stopSpeedBypass()
                print("[Farmer] Arrived at base!")
                return
            end

            if idx <= #waypoints then
                local wp = waypoints[idx]
                if (hrpNow.Position - wp.Position).Magnitude < 5 then
                    idx = idx + 1
                else
                    humNow:MoveTo(wp.Position)
                end
            else
                humNow:MoveTo(targetPos)
            end
        end)
    else
        -- Fallback: straight line dash
        dashConn = RunService.Heartbeat:Connect(function()
            local hrpNow, humNow = getCharParts()
            if not hrpNow or not humNow then dashConn:Disconnect(); return end

            local dist = (hrpNow.Position - targetPos).Magnitude
            if dist <= 5 then
                hrpNow.Velocity = Vector3.new(0, hrpNow.Velocity.Y, 0)
                dashConn:Disconnect()
                stopSpeedBypass()
                print("[Farmer] Arrived at base!")
                return
            end
            local dir = (targetPos - hrpNow.Position).Unit
            hrpNow.Velocity = Vector3.new(dir.X * DASH_SPEED, hrpNow.Velocity.Y, dir.Z * DASH_SPEED)
        end)
    end
end

-- ===================== HEARTBEAT SCANNER =====================
local scanTimer = 0
RunService.Heartbeat:Connect(function(dt)
    if not active then return end
    scanTimer = scanTimer + dt
    if scanTimer >= 2 then   -- scan every 2 seconds
        scanTimer = 0
        scanBestPlot()
    end
end)

-- ===================== GUI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BaseFarmer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 140)
main.Position = UDim2.new(0.5, -130, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(255,215,0)

local blur = Instance.new("ImageLabel", main)
blur.Size = UDim2.new(1,0,1,0)
blur.BackgroundTransparency = 1
blur.Image = "rbxassetid://9968344105"
blur.ImageTransparency = 0.8
blur.ScaleType = Enum.ScaleType.Slice
blur.SliceCenter = Rect.new(16,16,48,48)

local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.BackgroundColor3 = Color3.fromRGB(30,30,35)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "🏠 Base Farmer"
title.TextColor3 = Color3.fromRGB(255,215,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 13

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,20,0,20)
closeBtn.Position = UDim2.new(1,-24,0,5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,70,70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,10)
closeBtn.MouseButton1Click:Connect(function()
    if dashConn then dashConn:Disconnect() end
    stopSpeedBypass()
    if highlight then highlight:Destroy() end
    screenGui:Destroy()
end)

-- Dragging
local dragStart, dragPos, dragging
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; dragPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Content
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,1,-30)
content.Position = UDim2.new(0,0,0,30)
content.BackgroundTransparency = 1

-- Toggle button
local toggleBtn = Instance.new("TextButton", content)
toggleBtn.Size = UDim2.new(1,-16,0,28)
toggleBtn.Position = UDim2.new(0,8,0,10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
toggleBtn.BackgroundTransparency = 0.9
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,6)

local toggleLbl = Instance.new("TextLabel", toggleBtn)
toggleLbl.Size = UDim2.new(1,-60,1,0)
toggleLbl.Position = UDim2.new(0,10,0,0)
toggleLbl.BackgroundTransparency = 1
toggleLbl.Text = "Auto Scan"
toggleLbl.TextColor3 = Color3.new(1,1,1)
toggleLbl.Font = Enum.Font.GothamSemibold
toggleLbl.TextSize = 12

local pill = Instance.new("Frame", toggleBtn)
pill.Size = UDim2.new(0,36,0,18)
pill.Position = UDim2.new(1,-42,0.5,-9)
pill.BackgroundColor3 = Color3.fromRGB(80,80,90)
pill.BorderSizePixel = 0
Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)

local dot = Instance.new("Frame", pill)
dot.Size = UDim2.new(0,14,0,14)
dot.Position = UDim2.new(0,2,0.5,-7)
dot.BackgroundColor3 = Color3.new(1,1,1)
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = active and Color3.fromRGB(255,215,0) or Color3.fromRGB(80,80,90)
    }):Play()
    TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Position = active and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    }):Play()
    if active then
        scanBestPlot()
    else
        if highlight then highlight:Destroy(); highlight = nil end
    end
end)

-- Dash button
local dashBtn = Instance.new("TextButton", content)
dashBtn.Size = UDim2.new(1,-16,0,30)
dashBtn.Position = UDim2.new(0,8,0,55)
dashBtn.BackgroundColor3 = Color3.fromRGB(255,215,0)
dashBtn.Text = "⚡ DASH TO BEST BASE"
dashBtn.TextColor3 = Color3.new(0.1,0.1,0.1)
dashBtn.Font = Enum.Font.GothamBold
dashBtn.TextSize = 12
dashBtn.BorderSizePixel = 0
Instance.new("UICorner", dashBtn).CornerRadius = UDim.new(0,6)
dashBtn.MouseButton1Click:Connect(dashToBestBase)

-- Info label
local infoLabel = Instance.new("TextLabel", content)
infoLabel.Size = UDim2.new(1,-16,0,16)
infoLabel.Position = UDim2.new(0,8,0,92)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Best: N/A"
infoLabel.TextColor3 = Color3.fromRGB(255,215,0)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11

RunService.Heartbeat:Connect(function()
    if bestPlot then
        local tier = bestPlot:GetAttribute("Tier") or 0
        infoLabel.Text = "Best: Tier " .. tostring(tier)
    else
        infoLabel.Text = "Best: N/A"
    end
end)

-- Entrance animation
main.Size = UDim2.new(0,0,0,140)
TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0,260,0,140)
}):Play()

print("[Base Farmer] Ready – toggle Auto Scan, then dash to the highest‑tier base!")
