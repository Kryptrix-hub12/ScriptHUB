-- leaked in fs .gg/vGW4JQmcQS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local NetworkClient = game:GetService("NetworkClient")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local environment = if getgenv then getgenv() else _G
local RUNTIME_KEY = "__HOOK_ANTI_ANTI_RECONSTRUCTION"

local previousRuntime = environment[RUNTIME_KEY]
if type(previousRuntime) == "table" and type(previousRuntime.destroy) == "function" then
    pcall(previousRuntime.destroy)
end

local runtime = {
    alive = true,
    enabled = false,
    awaitingKey = false,
    boundKey = Enum.KeyCode.Delete,
    character = nil,
    rootPart = nil,
    fakeRoot = nil,
    repRootOwner = nil,
    stepConnection = nil,
    connections = {},
    settingsRestore = {},
    captureGeneration = 0,
}
environment[RUNTIME_KEY] = runtime

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(runtime.connections, connection)
    return connection
end

local function disconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function createInstance(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    if parent then
        object.Parent = parent
    end
    return object
end

local function addCorner(parent, radius)
    return createInstance("UICorner", {
        CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius),
    }, parent)
end

local function addStroke(parent, color, transparency, thickness)
    return createInstance("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Transparency = transparency,
        Thickness = thickness,
    }, parent)
end

local function playTween(object, duration, goals)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        goals
    )
    animation:Play()
    return animation
end

local function isBasePart(instance)
    if not instance then
        return false
    end
    local ok, result = pcall(function()
        return instance:IsA("BasePart")
    end)
    return ok and result == true
end

local function getCurrentRoot(character)
    character = character or LocalPlayer.Character
    if not character then
        return nil
    end

    local ok, root = pcall(function()
        return character:FindFirstChild("HumanoidRootPart")
    end)
    if ok and isBasePart(root) then
        return root
    end
    return nil
end

local function findGlobalFunction(...)
    for index = 1, select("#", ...) do
        local name = select(index, ...)
        local value = rawget(environment, name)
        if type(value) == "function" then
            return value
        end
    end
    return nil
end

local function setHidden(instance, property, value)
    if not instance then
        return false
    end

    local setter = findGlobalFunction(
        "sethiddenproperty",
        "set_hidden_property",
        "sethiddenprop",
        "set_hidden_prop"
    )
    if setter then
        local ok = pcall(setter, instance, property, value)
        if ok then
            return true
        end
    end

    return pcall(function()
        instance[property] = value
    end)
end

local function getHidden(instance, property)
    if not instance then
        return false, nil
    end

    local getter = findGlobalFunction(
        "gethiddenproperty",
        "get_hidden_property",
        "gethiddenprop",
        "get_hidden_prop"
    )
    if getter then
        local ok, value = pcall(getter, instance, property)
        if ok then
            return true, value
        end
    end

    local ok, value = pcall(function()
        return instance[property]
    end)
    return ok, value
end

local function rememberSetting(instance, property)
    local ok, value = pcall(function()
        return instance[property]
    end)
    if ok then
        table.insert(runtime.settingsRestore, {
            instance = instance,
            property = property,
            value = value,
        })
    end
end

local function applyPublicSetting(instance, property, value)
    if not instance then
        return false
    end
    rememberSetting(instance, property)
    return pcall(function()
        instance[property] = value
    end)
end

local function configurePhysics()
    setHidden(LocalPlayer, "MaximumSimulationRadius", math.huge)
    setHidden(LocalPlayer, "SimulationRadius", math.huge)

    pcall(function()
        local networkSettings = settings().Network
        applyPublicSetting(
            networkSettings,
            "InterpolationThrottling",
            Enum.InterpolationThrottlingMode.Disabled
        )
    end)

    pcall(function()
        local physicsSettings = settings().Physics
        applyPublicSetting(
            physicsSettings,
            "PhysicsEnvironmentalThrottle",
            Enum.EnviromentalPhysicsThrottle.Disabled
        )
        applyPublicSetting(physicsSettings, "AllowSleep", false)
    end)

    pcall(function()
        NetworkClient:SetOutgoingKBPSLimit(math.huge)
    end)
end

configurePhysics()

local FAKE_ROOT_NAME = "DavidDesyncRoot"
local FAKE_ROOT_Y = -2500
local FAKE_ROOT_VELOCITY = Vector3.new(0, -1000, 0)

local function fakeRootIsUsable()
    local fake = runtime.fakeRoot
    if not isBasePart(fake) then
        return false
    end
    local ok, parent = pcall(function()
        return fake.Parent
    end)
    return ok and parent ~= nil
end

local function destroyFakeRoot()
    local fake = runtime.fakeRoot
    runtime.fakeRoot = nil
    if fake then
        pcall(function()
            fake:Destroy()
        end)
    end
end

local function restoreReplicationRoot()
    local owner = runtime.repRootOwner or runtime.rootPart
    if isBasePart(owner) then
        setHidden(owner, "PhysicsRepRootPart", owner)
    end
    runtime.repRootOwner = nil
end

local function createFakeRoot(rootPart)
    destroyFakeRoot()

    local fake = createInstance("Part", {
        Name = FAKE_ROOT_NAME,
        Size = Vector3.new(2, 2, 1),
        Anchored = true,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
        Transparency = 1,
        CFrame = CFrame.new(0, FAKE_ROOT_Y, 0),
        AssemblyLinearVelocity = FAKE_ROOT_VELOCITY,
    }, Workspace)

    local ok, position = pcall(function()
        return rootPart.Position
    end)
    if ok then
        fake.CFrame = CFrame.new(position.X, FAKE_ROOT_Y, position.Z)
    end

    runtime.fakeRoot = fake
    return fake
end

local function assignFakeReplicationRoot(rootPart, fake)
    if not isBasePart(rootPart) or not isBasePart(fake) then
        return false
    end

    setHidden(rootPart, "PhysicsRepRootPart", rootPart)
    runtime.repRootOwner = rootPart
    return setHidden(rootPart, "PhysicsRepRootPart", fake)
end

local function stepDesync()
    if not runtime.alive or not runtime.enabled then
        return
    end

    local root = runtime.rootPart
    if not isBasePart(root) then
        root = getCurrentRoot(runtime.character)
        runtime.rootPart = root
    end
    if not root then
        return
    end

    if not fakeRootIsUsable() then
        local fake = createFakeRoot(root)
        assignFakeReplicationRoot(root, fake)
        return
    end

    local fake = runtime.fakeRoot

    local ok, rootPosition, fakePosition = pcall(function()
        return root.Position, fake.Position
    end)
    if ok and (
        math.abs(rootPosition.X - fakePosition.X) > 0.01
        or math.abs(rootPosition.Z - fakePosition.Z) > 0.01
        or math.abs(fakePosition.Y - FAKE_ROOT_Y) > 0.01
    ) then
        pcall(function()
            fake.CFrame = CFrame.new(rootPosition.X, FAKE_ROOT_Y, rootPosition.Z)
        end)
    end

    pcall(function()
        fake.Anchored = true
        fake.AssemblyLinearVelocity = FAKE_ROOT_VELOCITY
    end)

    local gotValue, current = getHidden(root, "PhysicsRepRootPart")
    if not gotValue or current ~= fake then
        setHidden(root, "PhysicsRepRootPart", fake)
    end
end

local function stopStepConnection()
    disconnect(runtime.stepConnection)
    runtime.stepConnection = nil
end

local function startStepConnection()
    stopStepConnection()
    runtime.stepConnection = RunService.Stepped:Connect(stepDesync)
end

local function bindCharacter(character)
    local oldRoot = runtime.rootPart
    runtime.character = character
    runtime.rootPart = getCurrentRoot(character)

    if runtime.enabled then
        if isBasePart(oldRoot) and oldRoot ~= runtime.rootPart then
            setHidden(oldRoot, "PhysicsRepRootPart", oldRoot)
        end
        destroyFakeRoot()

        local root = runtime.rootPart
        if not root and character then
            local ok, waitedRoot = pcall(function()
                return character:WaitForChild("HumanoidRootPart", 8)
            end)
            if ok and isBasePart(waitedRoot) then
                root = waitedRoot
                runtime.rootPart = root
            end
        end

        if root then
            local fake = createFakeRoot(root)
            assignFakeReplicationRoot(root, fake)
            startStepConnection()
        end
    end
end

bindCharacter(LocalPlayer.Character)
connect(LocalPlayer.CharacterAdded, function(character)
    task.defer(bindCharacter, character)
end)

local COLORS = {
    main = Color3.fromRGB(12, 3, 12),
    row = Color3.fromRGB(26, 6, 22),
    track = Color3.fromRGB(32, 6, 26),
    button = Color3.fromRGB(18, 4, 20),
    text = Color3.new(1, 1, 1),
    muted = Color3.fromRGB(140, 110, 145),
    accent = Color3.fromRGB(217, 70, 239),
    rowStroke = Color3.fromRGB(190, 32, 168),
}

local uiParent = CoreGui
local oldGui = uiParent:FindFirstChild("HookAntiAntiUI")
if oldGui then
    oldGui:Destroy()
end

local screenGui = createInstance("ScreenGui", {
    Name = "HookAntiAntiUI",
    DisplayOrder = 999,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, nil)

local parented = pcall(function()
    screenGui.Parent = uiParent
end)
if not parented then
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        or LocalPlayer:WaitForChild("PlayerGui")
    uiParent = playerGui
    local stale = uiParent:FindFirstChild("HookAntiAntiUI")
    if stale then
        stale:Destroy()
    end
    screenGui.Parent = uiParent
end
runtime.gui = screenGui

local main = createInstance("Frame", {
    Name = "Main",
    Active = true,
    ClipsDescendants = true,
    BackgroundTransparency = 0.08,
    BackgroundColor3 = COLORS.main,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -155, 0.5, -90),
    Size = UDim2.new(0, 310, 0, 175),
}, screenGui)
addCorner(main, 16)

local mainStroke = addStroke(main, Color3.new(1, 1, 1), 0, 1.8)
local outlineGradient = createInstance("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(75, 0, 125)),
        ColorSequenceKeypoint.new(0.20, Color3.fromRGB(165, 35, 240)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235, 95, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(235, 95, 255)),
        ColorSequenceKeypoint.new(0.80, Color3.fromRGB(165, 35, 240)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(75, 0, 125)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 0.75),
        NumberSequenceKeypoint.new(0.25, 0.40),
        NumberSequenceKeypoint.new(0.50, 0.00),
        NumberSequenceKeypoint.new(0.75, 0.40),
        NumberSequenceKeypoint.new(1.00, 0.75),
    }),
    Rotation = 0,
}, mainStroke)

local mainScale = createInstance("UIScale", {
    Scale = 1,
}, main)

local backdrop = createInstance("ImageLabel", {
    Name = "Backdrop",
    ScaleType = Enum.ScaleType.Crop,
    ImageTransparency = 0.22,
    AnchorPoint = Vector2.new(1, 0),
    Image = "rbxasset://e108b292ebba4c47d7bac2a9aef23afa/hooklagger_bg.png",
    BackgroundTransparency = 1,
    Position = UDim2.new(1, 10, 0, -5),
    ZIndex = 1,
    Size = UDim2.new(0, 210, 1, 10),
}, main)
addCorner(backdrop, 16)

local header = createInstance("Frame", {
    Name = "Header",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 6),
    ZIndex = 10,
    Size = UDim2.new(1, -24, 0, 40),
}, main)
addCorner(header, 6)

local logo = createInstance("ImageLabel", {
    Name = "Logo",
    BackgroundTransparency = 1,
    Image = "rbxasset://e108b292ebba4c47d7bac2a9aef23afa/hookduels_logo.png",
    Position = UDim2.new(0, 2, 0, 6),
    ZIndex = 11,
    Size = UDim2.new(0, 28, 0, 28),
}, header)
addCorner(logo, 6)

local title = createInstance("TextLabel", {
    Name = "Title",
    BackgroundTransparency = 1,
    Text = "HOOK ANTI ANTI",
    TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBlack,
    Position = UDim2.new(0, 38, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 11,
    TextSize = 14,
    Size = UDim2.new(1, -40, 1, 0),
}, header)

local content = createInstance("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 18, 0, 48),
    ZIndex = 5,
    Size = UDim2.new(1, -28, 1, -54),
}, main)
createInstance("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, content)

local function makeRow(name, layoutOrder)
    local row = createInstance("Frame", {
        Name = name,
        BackgroundColor3 = COLORS.row,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 46),
        LayoutOrder = layoutOrder,
        ZIndex = 5,
    }, content)
    addCorner(row, 10)

    createInstance("UIGradient", {
        Color = ColorSequence.new(
            Color3.new(1, 1, 1),
            Color3.fromRGB(205, 210, 230)
        ),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.00, 0.55),
            NumberSequenceKeypoint.new(0.50, 0.85),
            NumberSequenceKeypoint.new(1.00, 0.70),
        }),
        Rotation = 90,
    }, row)
    addStroke(row, COLORS.rowStroke, 0.60, 1)
    return row
end

local toggleRow = makeRow("AntiAntiRow", 1)
local toggleLabel = createInstance("TextLabel", {
    Name = "Label",
    BackgroundTransparency = 1,
    Text = "Enable Anti Anti",
    TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(0, 14, 0, 6),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
    TextSize = 13,
    Size = UDim2.new(1, -74, 0, 18),
}, toggleRow)

local statusLabel = createInstance("TextLabel", {
    Name = "Status",
    BackgroundTransparency = 1,
    Text = "OFF",
    TextColor3 = COLORS.muted,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(0, 14, 0, 24),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
    TextSize = 9,
    Size = UDim2.new(1, -74, 0, 14),
}, toggleRow)

local toggleTrack = createInstance("Frame", {
    Name = "Toggle",
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = COLORS.track,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -12, 0.5, 0),
    ZIndex = 7,
    Size = UDim2.new(0, 44, 0, 22),
}, toggleRow)
addCorner(toggleTrack, 11)
addStroke(toggleTrack, COLORS.rowStroke, 0.50, 1.2)

local toggleKnob = createInstance("Frame", {
    Name = "Knob",
    BackgroundColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0,
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.new(0, 3, 0, 3),
    ZIndex = 8,
}, toggleTrack)
addCorner(toggleKnob, UDim.new(1, 0))

local toggleHit = createInstance("TextButton", {
    Name = "ToggleHit",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 9,
    Size = UDim2.new(1, 0, 1, 0),
}, toggleRow)

local keybindRow = makeRow("KeybindRow", 2)
local keybindLabel = createInstance("TextLabel", {
    Name = "Label",
    BackgroundTransparency = 1,
    Text = "Keybind",
    TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBold,
    Position = UDim2.new(0, 14, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
    TextSize = 13,
    Size = UDim2.new(1, -84, 1, 0),
}, keybindRow)

local keybindButton = createInstance("TextButton", {
    Name = "KeybindBtn",
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = COLORS.button,
    BackgroundTransparency = 0.30,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -12, 0.5, 0),
    Size = UDim2.new(0, 76, 0, 26),
    Text = "Delete",
    TextColor3 = COLORS.accent,
    Font = Enum.Font.GothamBlack,
    TextSize = 11,
    ZIndex = 7,
}, keybindRow)
addCorner(keybindButton, 7)
addStroke(keybindButton, COLORS.rowStroke, 0.50, 1)

local function ripple(row)
    if not runtime.alive or not row or not row.Parent then
        return
    end

    local mousePosition = UserInputService:GetMouseLocation()
    local absolutePosition = row.AbsolutePosition
    local absoluteSize = row.AbsoluteSize
    local x = mousePosition.X - absolutePosition.X
    local y = mousePosition.Y - absolutePosition.Y
    local diameter = math.max(absoluteSize.X, absoluteSize.Y) * 1.35

    local image = createInstance("ImageLabel", {
        Name = "Ripple",
        BackgroundTransparency = 1,
        Image = "rbxassetid://266543268",
        ImageColor3 = COLORS.accent,
        ImageTransparency = 0.40,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = 30,
    }, row)

    local animation = playTween(image, 0.45, {
        Size = UDim2.new(0, diameter, 0, diameter),
        ImageTransparency = 1,
    })
    animation.Completed:Connect(function()
        if image then
            image:Destroy()
        end
    end)
end

local function applyEnabledVisual(value, instant)
    statusLabel.Text = value and "ACTIVE" or "OFF"
    statusLabel.TextColor3 = value and COLORS.accent or COLORS.muted

    local trackColor = value and Color3.fromRGB(122, 30, 134) or COLORS.track
    local knobPosition = value and UDim2.new(1, -19, 0, 3)
        or UDim2.new(0, 3, 0, 3)

    if instant then
        toggleTrack.BackgroundColor3 = trackColor
        toggleKnob.Position = knobPosition
    else
        playTween(toggleTrack, 0.18, { BackgroundColor3 = trackColor })
        playTween(toggleKnob, 0.18, { Position = knobPosition })
    end
end

local function setEnabled(value)
    if not runtime.alive then
        return false
    end

    value = value == true
    if runtime.enabled == value then
        applyEnabledVisual(value, false)
        return value
    end

    runtime.enabled = value
    applyEnabledVisual(value, false)

    if value then
        local root = getCurrentRoot(runtime.character)
        runtime.rootPart = root
        if not root then
            runtime.enabled = false
            applyEnabledVisual(false, false)
            return false
        end

        local fake = createFakeRoot(root)
        assignFakeReplicationRoot(root, fake)
        startStepConnection()
    else
        stopStepConnection()
        restoreReplicationRoot()
        destroyFakeRoot()
    end

    return runtime.enabled
end

local function toggleEnabled()
    return setEnabled(not runtime.enabled)
end

connect(toggleHit.MouseButton1Click, function()
    ripple(toggleRow)
    toggleEnabled()
end)

connect(keybindButton.MouseButton1Click, function()
    if not runtime.alive or runtime.awaitingKey then
        return
    end

    ripple(keybindRow)
    runtime.awaitingKey = true
    runtime.captureGeneration += 1
    local generation = runtime.captureGeneration

    task.spawn(function()
        for _, text in ipairs({".", "..", "..."}) do
            if not runtime.alive
                or not runtime.awaitingKey
                or generation ~= runtime.captureGeneration
            then
                return
            end
            keybindButton.Text = text
            task.wait(0.15)
        end
    end)
end)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if not runtime.alive then
        return
    end

    if runtime.awaitingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode ~= Enum.KeyCode.Unknown
        then
            if input.KeyCode ~= Enum.KeyCode.Escape then
                runtime.boundKey = input.KeyCode
            end
            runtime.awaitingKey = false
            runtime.captureGeneration += 1
            keybindButton.Text = runtime.boundKey.Name
        end
        return
    end

    if not gameProcessed and input.KeyCode == runtime.boundKey then
        ripple(toggleRow)
        toggleEnabled()
    end
end)

local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

connect(main.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragInput = input
        dragStart = input.Position
        startPosition = main.Position

        local changedConnection
        changedConnection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragInput = nil
                disconnect(changedConnection)
            end
        end)
    end
end)

connect(main.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragInput = input
    end
end)

connect(UserInputService.InputChanged, function(input)
    if not dragging or input ~= dragInput or not dragStart or not startPosition then
        return
    end

    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

connect(RunService.RenderStepped, function(deltaTime)
    if not runtime.alive or not outlineGradient.Parent then
        return
    end
    outlineGradient.Rotation = (outlineGradient.Rotation + deltaTime * 140) % 360
end)

local function destroy()
    if not runtime.alive then
        return
    end

    runtime.alive = false
    runtime.enabled = false
    runtime.awaitingKey = false
    runtime.captureGeneration += 1

    stopStepConnection()
    restoreReplicationRoot()
    destroyFakeRoot()

    for _, connection in ipairs(runtime.connections) do
        disconnect(connection)
    end
    table.clear(runtime.connections)

    for index = #runtime.settingsRestore, 1, -1 do
        local entry = runtime.settingsRestore[index]
        pcall(function()
            entry.instance[entry.property] = entry.value
        end)
    end
    table.clear(runtime.settingsRestore)

    if runtime.gui then
        pcall(function()
            runtime.gui:Destroy()
        end)
    end

    if environment[RUNTIME_KEY] == runtime then
        environment[RUNTIME_KEY] = nil
    end
end

runtime.setEnabled = setEnabled
runtime.toggle = toggleEnabled
runtime.step = stepDesync
runtime.bindCharacter = bindCharacter
runtime.setHidden = setHidden
runtime.getHidden = getHidden
runtime.destroy = destroy
runtime.getBoundKey = function()
    return runtime.boundKey
end
runtime.setBoundKey = function(keyCode)
    if keyCode and keyCode ~= Enum.KeyCode.Unknown then
        runtime.boundKey = keyCode
        keybindButton.Text = keyCode.Name
        return true
    end
    return false
end

applyEnabledVisual(false, true)
