		--[[
    AUTO BAT (Aimbot) â€“ from Cursed Hub PC
    - Draggable toggle button
    - Moves toward nearest enemy 
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- ========== CONFIGURATION ==========
local AUTO_BAT_ENABLED = false          -- start disabled
local AUTO_BAT_SPEED = 58               -- horizontal movement speed
local AUTO_BAT_VERT_SPEED = 52          -- vertical movement speed
local AUTO_BAT_DIST = -2.8              -- desired distance from target (negative = close)
local AUTO_BAT_HEIGHT = 4.75            -- desired height offset (stand above ground)
local AUTO_BAT_V_OFF = 1                -- aim upward offset
local AUTO_BAT_TURN_SPEED = 285         -- how fast to turn (degrees per radian)
local AUTO_BAT_MAX_TURN_RATE = 28       -- max angular velocity (rad/s)
local AUTO_SWING_ENABLED = true         -- automatically swing bat when close

-- Internal state
local autoBatConnection = nil
local autoBatEquipped = false
local _autoBatTarget = nil
local _autoBatLastScan = 0
local batTool = nil

-- ========== UTILITY FUNCTIONS ==========
local function getCharacter() return LP.Character end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Find the nearest enemy player's HumanoidRootPart
local function getAutoBatTarget()
    local root = getRootPart()
    if not root then return nil end
    local now = tick()
    -- cache target for 0.1 seconds
    if now - _autoBatLastScan <= 0.1 and _autoBatTarget and _autoBatTarget.Parent then
        local hum = _autoBatTarget.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            return _autoBatTarget
        end
    end
    _autoBatLastScan = now
    _autoBatTarget = nil
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                end
            end
        end
    end
    _autoBatTarget = closest
    return _autoBatTarget
end

-- Find and equip a bat (any slap tool or Bat)
local function findBat()
    local char = getCharacter()
    if not char then return nil end
    -- Check inventory first
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("bat") or name:find("slap") then
                return tool
            end
        end
    end
    -- Check backpack
    local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.Name:lower()
                if name:find("bat") or name:find("slap") then
                    return tool
                end
            end
        end
    end
    return nil
end

-- Equip bat if not already holding a tool
local function ensureBatEquipped()
    local char = getCharacter()
    local hum = getHumanoid()
    if not char or not hum then return end
    if not char:FindFirstChildOfClass("Tool") then
        local bat = findBat()
        if bat then
            pcall(function() hum:EquipTool(bat) end)
            batTool = bat
        end
    else
        -- already holding something, maybe it's the bat
        batTool = char:FindFirstChildOfClass("Tool")
    end
end

-- Reset motion (stop spinning etc.)
local function resetAutoBatMotion()
    local root = getRootPart()
    local hum = getHumanoid()
    if root then
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.3
        root.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then hum.AutoRotate = true end
end

-- ========== AIMBOT CORE LOOP ==========
local function startAutoBat()
    if autoBatConnection then return end
    autoBatConnection = RunService.Heartbeat:Connect(function()
        if not AUTO_BAT_ENABLED then return end

        local char = getCharacter()
        local hum = getHumanoid()
        local root = getRootPart()
        if not char or not hum or not root then return end

        -- Ensure bat equipped
        if not autoBatEquipped then
            autoBatEquipped = true
            ensureBatEquipped()
        end

        local target = getAutoBatTarget()
        if target then
            -- Predict target movement + aim offset
            local targetVel = target.AssemblyLinearVelocity
            local aimTargetPos = target.Position + (targetVel * math.clamp(targetVel.Magnitude / 130, 0.05, 0.15)) + Vector3.new(0, AUTO_BAT_V_OFF, 0)

            -- Disable autoâ€‘rotate so we control it
            hum.AutoRotate = false

            -- Calculate look direction
            local look = aimTargetPos - root.Position
            local flatLook = Vector3.new(look.X, 0, look.Z)

            if look.Magnitude > 0.01 and flatLook.Magnitude > 0.01 then
                -- Yaw (horizontal rotation)
                local targetYaw = math.deg(math.atan2(-flatLook.X, -flatLook.Z))
                local yawDelta = (targetYaw - root.Orientation.Y + 180) % 360 - 180
                -- Pitch (vertical rotation)
                local targetPitch = math.deg(math.atan2(look.Y, flatLook.Magnitude))
                local pitchDelta = (targetPitch - root.Orientation.X + 180) % 360 - 180

                local yawRate = math.clamp(math.rad(yawDelta) * AUTO_BAT_TURN_SPEED, -AUTO_BAT_MAX_TURN_RATE, AUTO_BAT_MAX_TURN_RATE)
                local pitchRate = math.clamp(math.rad(pitchDelta) * AUTO_BAT_TURN_SPEED, -AUTO_BAT_MAX_TURN_RATE, AUTO_BAT_MAX_TURN_RATE)

                local yawRad = math.rad(root.Orientation.Y)
                local rightAxis = Vector3.new(math.cos(yawRad), 0, -math.sin(yawRad))
                root.AssemblyAngularVelocity = Vector3.new(0, yawRate, 0) + (rightAxis * pitchRate)
            else
                root.AssemblyAngularVelocity = Vector3.zero
            end

            -- Movement: stand at optimal distance and height
            local dir = look.Magnitude > 0.01 and look.Unit or Vector3.zero
            local standPos = aimTargetPos - (dir * AUTO_BAT_DIST) + Vector3.new(0, AUTO_BAT_HEIGHT, 0)
            local moveDir = standPos - root.Position
            local hDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            local hVel = hDir.Magnitude > 0.1 and hDir.Unit * AUTO_BAT_SPEED or Vector3.zero
            local vVel = math.abs(moveDir.Y) > 0.1 and Vector3.new(0, math.sign(moveDir.Y) * AUTO_BAT_VERT_SPEED, 0) or Vector3.new(0, -2, 0)
            root.AssemblyLinearVelocity = hVel + vVel
            if hDir.Magnitude > 0.5 then
                hum:Move(hDir.Unit, false)
            end

            -- Auto swing when close
            if AUTO_SWING_ENABLED and (root.Position - target.Position).Magnitude < 6 then
                local bat = findBat() or batTool
                if bat and bat:IsA("Tool") then
                    pcall(function() bat:Activate() end)
                end
            end
        else
            -- No target: reset rotation and movement
            hum.AutoRotate = true
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function stopAutoBat()
    if autoBatConnection then
        autoBatConnection:Disconnect()
        autoBatConnection = nil
    end
    resetAutoBatMotion()
    autoBatEquipped = false
end

local function setAutoBatState(enabled)
    AUTO_BAT_ENABLED = enabled
    if enabled then
        startAutoBat()
    else
        stopAutoBat()
    end
end

-- ========== DRAGGABLE TOGGLE BUTTON ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBatButton"
screenGui.ResetOnSpawn = false
screenGui.Parent = LP:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton", screenGui)
btn.Size = UDim2.new(0, 130, 0, 40)
btn.Position = UDim2.new(0.7, -65, 0.8, 0)  -- default position
btn.Text = "AUTO BAT: OFF"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)  -- red when off
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
btn.Active = true
btn.Draggable = true

-- Toggle action
btn.MouseButton1Click:Connect(function()
    local newState = not AUTO_BAT_ENABLED
    setAutoBatState(newState)
    btn.Text = newState and "AUTO BAT: ON" or "AUTO BAT: OFF"
    btn.BackgroundColor3 = newState and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 40, 40)
end)

-- Reâ€‘equip bat on character respawn (if aimbot is active)
LP.CharacterAdded:Connect(function()
    autoBatEquipped = false
    if AUTO_BAT_ENABLED then
        task.wait(0.5)
        ensureBatEquipped()
    end
end)

print(" Auto Bat by daddy szg (Aimbot) loaded. Click the button to toggle. Drag to move.")
