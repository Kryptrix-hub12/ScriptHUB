
-- ================================================================
--  Auto Brainrot Farmer  ·  LocalScript
--  Scans all dropped brainrots, finds the most valuable,
--  highlights it, and teleports you to it.
--  UI: Modern glass, movable, single toggle + TP button
-- ================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean old
if playerGui:FindFirstChild("BrainrotFarmer") then
    playerGui.BrainrotFarmer:Destroy()
end

-- ===================== LOAD GAME DATA =====================
local AnimalsData = {}
pcall(function()
    AnimalsData = require(ReplicatedStorage.Datas.Animals)
end)
if not next(AnimalsData) then
    warn("Could not load Datas.Animals – prices won't be available")
end

-- ===================== STATE =====================
local active = false
local bestBrainrot = nil      -- the model with the highest price
local bestPrice = 0
local highlight = nil
local scanConnection = nil

-- ===================== HELPERS =====================
local function getCharParts()
    local char = player.Character
    if not char then return nil, nil end
    return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

-- ===================== SCAN & HIGHLIGHT =====================
local function scanBrainrots()
    -- Reset old highlight
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
    bestBrainrot = nil
    bestPrice = 0

    local animals = CollectionService:GetTagged("Animal")
    for _, model in ipairs(animals) do
        local index = model:GetAttribute("Index")
        if index and AnimalsData[index] then
            local price = AnimalsData[index].Price or 0
            if price > bestPrice then
                bestPrice = price
                bestBrainrot = model
            end
        end
    end

    if bestBrainrot then
        -- Create highlight on the best brainrot
        local hrp = bestBrainrot:FindFirstChild("HumanoidRootPart") or bestBrainrot.PrimaryPart or bestBrainrot:FindFirstChildWhichIsA("BasePart")
        if hrp then
            highlight = Instance.new("Highlight")
            highlight.Name = "BestBrainrot"
            highlight.Adornee = hrp
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 215, 0)  -- gold
            highlight.OutlineTransparency = 0
            highlight.Parent = hrp
        end
    end
end

-- ===================== TELEPORT =====================
local function teleportToBest()
    if not bestBrainrot then
        print("[Farmer] No valuable brainrot found!")
        return
    end
    local hrp, hum = getCharParts()
    if not hrp or not hum then return end

    local targetPos = bestBrainrot:GetPivot().Position
    -- Anti‑ragdoll during teleport
    local ragdollConn
    ragdollConn = hum.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Physics then
            hum.PlatformStand = false
        end
    end)
    -- Instant teleport
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))  -- slightly above the brainrot
    hrp.Velocity = Vector3.zero
    task.delay(0.5, function()
        if ragdollConn then ragdollConn:Disconnect() end
    end)
    print("[Farmer] Teleported to " .. bestBrainrot:GetAttribute("Index") .. " (price: " .. bestPrice .. ")")
end

-- ===================== HEARTBEAT SCANNER =====================
local function startScanning()
    if scanConnection then return end
    scanConnection = RunService.Heartbeat:Connect(function()
        if not active then return end
        scanBrainrots()
        -- Update highlight every 5 seconds to avoid performance hit
        -- We scan once per frame but only create highlight when best changes
    end)
end

local function stopScanning()
    if scanConnection then scanConnection:Disconnect(); scanConnection = nil end
    if highlight then highlight:Destroy(); highlight = nil end
    bestBrainrot = nil
    bestPrice = 0
end

-- ===================== GUI =====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotFarmer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 120)
main.Position = UDim2.new(0.5, -120, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.BackgroundTransparency = 0.25
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(255,215,0)  -- gold accent

-- Blur background
local blur = Instance.new("ImageLabel", main)
blur.Size = UDim2.new(1,0,1,0)
blur.BackgroundTransparency = 1
blur.Image = "rbxassetid://9968344105"
blur.ImageTransparency = 0.8
blur.ScaleType = Enum.ScaleType.Slice
blur.SliceCenter = Rect.new(16,16,48,48)

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1,0,0,30)
titleBar.BackgroundColor3 = Color3.fromRGB(30,30,35)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "🧠 Brainrot Farmer"
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
    stopScanning()
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
        startScanning()
        scanBrainrots()  -- immediate first scan
    else
        stopScanning()
    end
end)

-- Teleport button
local tpBtn = Instance.new("TextButton", content)
tpBtn.Size = UDim2.new(1,-16,0,30)
tpBtn.Position = UDim2.new(0,8,0,55)
tpBtn.BackgroundColor3 = Color3.fromRGB(255,215,0)
tpBtn.Text = "⚡ TELEPORT TO BEST"
tpBtn.TextColor3 = Color3.new(0.1,0.1,0.1)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 12
tpBtn.BorderSizePixel = 0
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)
tpBtn.MouseButton1Click:Connect(teleportToBest)

-- Price label
local priceLabel = Instance.new("TextLabel", content)
priceLabel.Size = UDim2.new(1,-16,0,16)
priceLabel.Position = UDim2.new(0,8,0,92)
priceLabel.BackgroundTransparency = 1
priceLabel.Text = "Best: N/A"
priceLabel.TextColor3 = Color3.fromRGB(255,215,0)
priceLabel.Font = Enum.Font.Gotham
priceLabel.TextSize = 11

-- Update price label periodically
RunService.Heartbeat:Connect(function()
    if bestBrainrot then
        local index = bestBrainrot:GetAttribute("Index")
        priceLabel.Text = "Best: " .. (index or "???") .. " ($" .. tostring(bestPrice) .. ")"
    else
        priceLabel.Text = "Best: N/A"
    end
end)

-- Entrance animation
main.Size = UDim2.new(0,0,0,120)
TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0,240,0,120)
}):Play()

print("[Brainrot Farmer] Ready – toggle Auto Scan, then teleport to the best brainrot!")
