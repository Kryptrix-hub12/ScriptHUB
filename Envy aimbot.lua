-- ============================================================
-- WORMING GUI  (Bat Aimbot + Worm toggle)
-- Adds a draggable pill with two switches.
-- ============================================================
do
    local TS   = game:GetService("TweenService")
    local UIS  = UserInputService or game:GetService("UserInputService")
    local CoreGuiRef = (game:GetService("CoreGui") if pcall(function() return game:GetService("CoreGui") end) else nil)

    -- ---------- Worm state ----------
    local Worm = {
        enabled   = false,
        conn      = nil,
        phase     = 0,
        savedAutoRotate = nil,
    }

    local WORM_AMPLITUDE_X = 0.35   -- side-to-side CFrame offset (studs)
    local WORM_AMPLITUDE_Y = 0.18   -- up-down bob (studs)
    local WORM_SPEED       = 9      -- oscillations per second

    local function applyWormOffset()
        local char = LP.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        -- Wiggle the HumanoidRootPart's CFrame offset, not velocity, so
        -- the aimbot's velocity writes are not fought.
        local t = os.clock() * WORM_SPEED
        local offX = math.sin(t)          * WORM_AMPLITUDE_X
        local offY = math.sin(t * 2.0)    * WORM_AMPLITUDE_Y
        local offZ = math.cos(t * 1.3)    * WORM_AMPLITUDE_X * 0.5
        -- Apply as a small CFrame nudge so it desyncs hit registration
        root.CFrame = root.CFrame * CFrame.new(offX, offY, offZ)
    end

    local function startWorm()
        if Worm.conn then return end
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                Worm.savedAutoRotate = hum.AutoRotate
            end
        end
        Worm.conn = RunService.Heartbeat:Connect(function()
            if not Worm.enabled then return end
            pcall(applyWormOffset)
        end)
    end

    local function stopWorm()
        if Worm.conn then Worm.conn:Disconnect(); Worm.conn = nil end
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and Worm.savedAutoRotate ~= nil then
                hum.AutoRotate = Worm.savedAutoRotate
            end
        end
    end

    -- ---------- GUI ----------
    if CoreGuiRef and CoreGuiRef:FindFirstChild("WormingGui") then
        CoreGuiRef.WormingGui:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "WormingGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
    end)
    local parented = pcall(function() gui.Parent = CoreGuiRef end)
    if not parented or not gui.Parent then
        gui.Parent = LP:WaitForChild("PlayerGui")
    end

    -- Main panel
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0, 0.5)
    panel.Position = UDim2.new(0, 20, 0.5, -60)
    panel.Size = UDim2.fromOffset(180, 118)
    panel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Draggable = true
    panel.Parent = gui

    local pCorner = Instance.new("UICorner", panel)
    pCorner.CornerRadius = UDim.new(0, 12)
    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = Color3.fromRGB(70, 140, 220)
    pStroke.Thickness = 1.2
    pStroke.Transparency = 0.25

    -- Header bar
    local header = Instance.new("Frame", panel)
    header.Size = UDim2.new(1, 0, 0, 26)
    header.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
    header.BackgroundTransparency = 0.15
    header.BorderSizePixel = 0
    local hCorner = Instance.new("UICorner", header)
    hCorner.CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -12, 1, 0)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Text = "WORMING"
    title.TextColor3 = Color3.fromRGB(235, 240, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12

    -- Helper: create a toggle row
    local function makeToggle(y, labelText, getState, setState)
        local row = Instance.new("TextButton", panel)
        row.Size = UDim2.new(1, -20, 0, 32)
        row.Position = UDim2.fromOffset(10, y)
        row.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
        row.BackgroundTransparency = 0.15
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        local rCorner = Instance.new("UICorner", row)
        rCorner.CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -56, 1, 0)
        lbl.Position = UDim2.fromOffset(10, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(210, 216, 232)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11

        -- Pill switch
        local track = Instance.new("Frame", row)
        track.AnchorPoint = Vector2.new(1, 0.5)
        track.Position = UDim2.new(1, -8, 0.5, 0)
        track.Size = UDim2.fromOffset(36, 18)
        track.BackgroundColor3 = Color3.fromRGB(50, 54, 66)
        track.BorderSizePixel = 0
        local tCorner = Instance.new("UICorner", track)
        tCorner.CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame", track)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0, 9, 0.5, 0)
        dot.Size = UDim2.fromOffset(14, 14)
        dot.BackgroundColor3 = Color3.fromRGB(200, 205, 220)
        dot.BorderSizePixel = 0
        local dCorner = Instance.new("UICorner", dot)
        dCorner.CornerRadius = UDim.new(1, 0)

        local function paint(on, animate)
            local ti = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            TS:Create(track, ti, {
                BackgroundColor3 = on and Color3.fromRGB(70, 150, 220) or Color3.fromRGB(50, 54, 66)
            }):Play()
            TS:Create(dot, ti, {
                Position = on and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 9, 0.5, 0),
                BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 205, 220)
            }):Play()
            if animate then
                dot.Size = UDim2.fromOffset(10, 10)
                TS:Create(dot, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    { Size = UDim2.fromOffset(14, 14) }):Play()
            end
        end

        paint(getState(), false)

        row.MouseButton1Click:Connect(function()
            local new = not getState()
            setState(new)
            paint(new, true)
        end)

        -- Expose refresh for external changes
        return function(state) paint(state, false) end
    end

    -- Row: Bat Aimbot
    local refreshAimbot = makeToggle(34, "Bat Aimbot",
        function() return autoBatEnabled end,
        function(v)
            if v then
                startBatAimbot()
            else
                stopBatAimbot()
            end
        end)

    -- Row: Worm
    local refreshWorm = makeToggle(74, "Worm (desync)",
        function() return Worm.enabled end,
        function(v)
            Worm.enabled = v
            if v then startWorm() else stopWorm() end
        end)

    -- Keep both pill visuals synced with real state (in case keybinds flip them)
    task.spawn(function()
        local lastA, lastW = autoBatEnabled, Worm.enabled
        while gui.Parent do
            if autoBatEnabled ~= lastA then
                lastA = autoBatEnabled
                refreshAimbot(lastA)
            end
            if Worm.enabled ~= lastW then
                lastW = Worm.enabled
                refreshWorm(lastW)
            end
            task.wait(0.15)
        end
    end)

    -- Stop worm on death/respawn
    LP.CharacterAdded:Connect(function()
        if Worm.enabled then
            stopWorm()
            task.wait(0.4)
            startWorm()
        end
    end)

    -- Expose for external toggles
    _G.Worming = {
        toggleWorm = function(v)
            Worm.enabled = (v ~= nil) and v or (not Worm.enabled)
            if Worm.enabled then startWorm() else stopWorm() end
            refreshWorm(Worm.enabled)
        end,
        getWorm = function() return Worm.enabled end,
        gui = gui,
    }
end
-- ============================================================
