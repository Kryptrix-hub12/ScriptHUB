if _G.BloodHoundsRunning then return end
_G.BloodHoundsRunning = true

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ============================================================
-- CACHÉ LOCAL DE SERVICIOS Y FUNCIONES (hot paths)
-- ============================================================
local _tick          = tick
local _clamp         = math.clamp
local _floor         = math.floor
local _abs           = math.abs
local _huge          = math.huge
local _sqrt          = math.sqrt
local _V3new         = Vector3.new
local _V3zero        = Vector3.zero
local _CFnew         = CFrame.new
local _CFlookAt      = CFrame.lookAt
local _RayParams_new = RaycastParams.new

local _GetPlayersCached
do
    local cache, cacheTime = nil, 0
    _GetPlayersCached = function()
        local now = _tick()
        if cache and now - cacheTime < 0.03 then return cache end
        cache = Players:GetPlayers()
        cacheTime = now
        return cache
    end
end

local function waitForCharReady(char, timeout)
    timeout = timeout or 5
    local deadline = _tick() + timeout
    while (not char) or (not char.Parent)
          or (not char:FindFirstChild("HumanoidRootPart"))
          or (not char:FindFirstChildOfClass("Humanoid")) do
        if _tick() > deadline then return false end
        task.wait(0.05)
    end
    return true
end

NS = 60
CS = 29
LAGGER_SPEED = 15
LAGGER_CARRY_SPEED = 24.5
MEDUSA_COOLDOWN = 25
BAT_AIMBOT_SPEED = 58
BYPASS_AIMBOT_SPEED = 60
MOBILE_PANEL_WIDTH = 128
MOBILE_PANEL_HEIGHT = 294
CONFIG_FILE = "BloodHounds.json"
BAT_V2_HIT_DIST = 4.5
_isDraggingButton = false

backgroundIndex = 1
backgroundImages = {
    "125799705833148",
    "127654598995136",
    "80248981806803",
    "114087328237383",
    "113186415777649",
    "107047683418142",
    "86570421984891",
    "93585037174641",
    "80538140936880"
}

backgroundImageTransparency = 0
floatingButtonScale = 1
_floatingUIScales = {}

local CarrySystem = {

    normalSpeed = NS,
    carrySpeed = CS,
    laggerSpeed = LAGGER_SPEED,
    laggerCarrySpeed = LAGGER_CARRY_SPEED,

    speedToggled = false,
    laggerMode = 0,

    softStealEnabled = false,
    softStealRadius = 10,
    softStealSpeed = 30,
    softStealLatched = false,

    _isCarrying = false,
    _lastCarryCheck = 0,

    _lvBoost = nil,
    _lvAtt = nil,
    _blockedTime = 0,
    _maxForce = 2200,
    _freeForce = 500,

    _heartbeatConn = nil,
    _softStealScanner = nil,
    _softStealAnimals = {},
    _softStealScanning = false,

    _state = nil,
    _dropInProgress = false,
    _batAimbotToggled = false,

    _rayParams = nil,
    _rayFilter = nil,
    _rayFilterTime = 0,
}

function CarrySystem:isCarrying()
    local now = _tick()
    if now - (self._lastCarryCheck or 0) < 0.1 then
        return self._isCarrying
    end
    self._lastCarryCheck = now
    local char = LP.Character
    if not char then self._isCarrying = false; return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local ws = hum and hum.WalkSpeed or 16
    local bySpeed = (ws < 25 and ws > 0)
    local byAttr = false
    local ok, v = pcall(function() return LP:GetAttribute("Stealing") end)
    if ok and v == true then byAttr = true end
    local ok2, v2 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok2 and v2 == true then byAttr = true end
    if not byAttr then
        for _, name in ipairs({"Carrying","IsCarrying","Grabbed","Holding","StealHold","HasGrab"}) do
            local obj = char:FindFirstChild(name)
            if obj then
                if (obj:IsA("BoolValue") and obj.Value) or
                   (obj:IsA("ObjectValue") and obj.Value) or
                   (obj:IsA("StringValue") and obj.Value ~= "") then
                    byAttr = true; break
                end
            end
        end
    end
    self._isCarrying = bySpeed or byAttr
    return self._isCarrying
end

function CarrySystem:getActiveSpeed()
    if self._state and (self._state.autoLeftEnabled or self._state.autoRightEnabled) then
        return self.normalSpeed
    end
    if self.softStealEnabled then
        local _, dist = self:getNearestSoftStealAnimal(self.softStealRadius)
        local inRange = dist and dist <= self.softStealRadius
        if inRange then
            self.softStealLatched = true
            return self.softStealSpeed
        end
        if self.softStealLatched and self:isCarrying() then
            return self.softStealSpeed
        else
            self.softStealLatched = false
        end
    end
    if self.laggerMode == 1 then return self.laggerSpeed end
    if self.laggerMode == 2 then return self.laggerCarrySpeed end
    if self.speedToggled then return self.carrySpeed end
    return self.normalSpeed
end

function CarrySystem:getStatus()
    if self._state and (self._state.autoLeftEnabled or self._state.autoRightEnabled) then
        return "NORMAL", self.normalSpeed
    end
    if self.softStealEnabled then
        local _, dist = self:getNearestSoftStealAnimal(self.softStealRadius)
        local inRange = dist and dist <= self.softStealRadius
        if inRange or (self.softStealLatched and self:isCarrying()) then
            return "AUTO CARRY", self.softStealSpeed
        end
    end
    if self.laggerMode == 1 then return "LAGGER", self.laggerSpeed end
    if self.laggerMode == 2 then return "LAGGER CARRY", self.laggerCarrySpeed end
    if self.speedToggled then return "CARRY", self.carrySpeed end
    return "NORMAL", self.normalSpeed
end

local function destroyLV()
    if CarrySystem._lvBoost and CarrySystem._lvBoost.Parent then pcall(function() CarrySystem._lvBoost:Destroy() end) end
    if CarrySystem._lvAtt and CarrySystem._lvAtt.Parent then pcall(function() CarrySystem._lvAtt:Destroy() end) end
    CarrySystem._lvBoost = nil; CarrySystem._lvAtt = nil
end

local function setupLV(hrp)
    if CarrySystem._lvBoost and CarrySystem._lvBoost.Parent == hrp then return end
    destroyLV()
    local att = Instance.new("Attachment"); att.Parent = hrp
    local lv = Instance.new("LinearVelocity")
    lv.Name = "CarryBoostLV"
    lv.Attachment0 = att
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    lv.PrimaryTangentAxis = _V3new(1,0,0)
    lv.SecondaryTangentAxis = _V3new(0,0,1)
    lv.MaxForce = CarrySystem._maxForce
    lv.PlaneVelocity = Vector2.zero
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = hrp
    CarrySystem._lvAtt = att
    CarrySystem._lvBoost = lv
    pcall(function() hrp:SetNetworkOwner(LP) end)
end

function CarrySystem:scanSoftStealAnimals()
    self._softStealAnimals = {}
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, podium in ipairs(podiums:GetChildren()) do
                    if podium:IsA("Model") then
                        local base = podium:FindFirstChild("Base")
                        local spawn = base and base:FindFirstChild("Spawn")
                        if spawn then
                            table.insert(self._softStealAnimals, {
                                plot = plot.Name,
                                slot = podium.Name,
                                worldPosition = spawn.Position,
                                uid = plot.Name .. "_" .. podium.Name,
                            })
                        end
                    end
                end
            end
        end
    end
end

function CarrySystem:startSoftStealScanner()
    if self._softStealScanner then return end
    self._softStealScanning = true
    self:scanSoftStealAnimals()
    self._softStealScanner = RunService.Heartbeat:Connect(function()
        if not self._softStealScanning then return end
        self:scanSoftStealAnimals()
    end)
end

function CarrySystem:stopSoftStealScanner()
    self._softStealScanning = false
    if self._softStealScanner then
        self._softStealScanner:Disconnect()
        self._softStealScanner = nil
    end
end

function CarrySystem:getNearestSoftStealAnimal(radius)
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
    if not root then return nil, _huge end
    local best, bestDist = nil, _huge
    local animals = self._softStealAnimals
    local rpos = root.Position
    for i = 1, #animals do
        local data = animals[i]
        if data.worldPosition then
            local dx = rpos.X - data.worldPosition.X
            local dy = rpos.Y - data.worldPosition.Y
            local dz = rpos.Z - data.worldPosition.Z
            local dist = _sqrt(dx*dx + dy*dy + dz*dz)
            if dist < bestDist then
                best = data; bestDist = dist
            end
        end
    end
    if radius and bestDist > radius then return nil, bestDist end
    return best, bestDist
end

function CarrySystem:updateMovement(dt)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local speed = self:getActiveSpeed()
    local moveDir = hum.MoveDirection
    local moving = moveDir.Magnitude > 0.1

    local wallNormalFlat = nil
    if moving then
        if not self._rayParams then
            self._rayParams = _RayParams_new()
            self._rayParams.FilterType = Enum.RaycastFilterType.Exclude
            self._rayFilter = {}
            self._rayFilterTime = 0
        end
        local now = _tick()
        if now - self._rayFilterTime > 1 then
            self._rayFilterTime = now
            local filter = self._rayFilter
            while #filter > 0 do filter[#filter] = nil end
            filter[1] = char
            local plist = _GetPlayersCached()
            for i = 1, #plist do
                local p = plist[i]
                if p.Character then
                    filter[#filter + 1] = p.Character
                end
            end
            self._rayParams.FilterDescendantsInstances = filter
        else
            local filter = self._rayFilter
            local found = false
            for i = 1, #filter do
                if filter[i] == char then found = true; break end
            end
            if not found then
                filter[1] = char
                self._rayParams.FilterDescendantsInstances = filter
            end
        end
        local flatDir = _V3new(moveDir.X, 0, moveDir.Z).Unit
        local hit = Workspace:Raycast(hrp.Position + _V3new(0,1,0), flatDir * 2.5, self._rayParams)
        if hit and hit.Instance and hit.Instance.CanCollide then
            local nf = _V3new(hit.Normal.X, 0, hit.Normal.Z)
            if nf.Magnitude > 0.7 then wallNormalFlat = nf.Unit end
        end
    end

    local hVel = _V3new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
    local blocked = wallNormalFlat ~= nil or (moving and hVel.Magnitude < 2)

    if blocked then
        for _, model in ipairs(char:GetChildren()) do
            if model:IsA("Model") then
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
        for _, name in ipairs({"Carrying","IsCarrying","Grabbed","Holding","StealHold","HasGrab"}) do
            local v = char:FindFirstChild(name)
            if v and v:IsA("ObjectValue") and v.Value and v.Value:IsA("Model") then
                for _, part in ipairs(v.Value:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end

    local state = hum:GetState()
    local ragdolled = state == Enum.HumanoidStateType.Physics
                   or state == Enum.HumanoidStateType.Ragdoll
                   or state == Enum.HumanoidStateType.FallingDown
    local moverBlocked = ragdolled or self._dropInProgress or self._batAimbotToggled

    if not moverBlocked then
        if not CarrySystem._lvBoost or CarrySystem._lvBoost.Parent ~= hrp then setupLV(hrp) end
        local lv = CarrySystem._lvBoost
        if lv then
            if not lv.Enabled then lv.Enabled = true end
            if moveDir.Magnitude > 0.1 then
                local flat = _V3new(moveDir.X, 0, moveDir.Z).Unit
                if wallNormalFlat then
                    local wanted = flat * speed
                    local along = wanted - wallNormalFlat * wanted:Dot(wallNormalFlat)
                    if along.Magnitude < 0.5 then
                        lv.PlaneVelocity = Vector2.zero
                    else
                        lv.PlaneVelocity = Vector2.new(along.X, along.Z)
                    end
                else
                    lv.PlaneVelocity = Vector2.new(flat.X * speed, flat.Z * speed)
                end
            else
                lv.PlaneVelocity = Vector2.zero
            end
            if blocked then
                self._blockedTime = self._blockedTime + (dt or 0.016)
            else
                self._blockedTime = 0
            end
            if self._blockedTime > 0.35 then
                if lv.MaxForce ~= self._freeForce then lv.MaxForce = self._freeForce end
            elseif lv.MaxForce ~= self._maxForce then
                lv.MaxForce = self._maxForce
            end
        end
    elseif CarrySystem._lvBoost then
        CarrySystem._lvBoost.PlaneVelocity = Vector2.zero
        if CarrySystem._lvBoost.Enabled then CarrySystem._lvBoost.Enabled = false end
    end
end

function CarrySystem:start()
    if self._heartbeatConn then return end
    self._heartbeatConn = RunService.Heartbeat:Connect(function(dt) self:updateMovement(dt) end)
    if self.softStealEnabled then self:startSoftStealScanner() end
    print("[CarrySystem] Activado")
end

function CarrySystem:stop()
    if self._heartbeatConn then
        self._heartbeatConn:Disconnect()
        self._heartbeatConn = nil
    end
    self:stopSoftStealScanner()
    destroyLV()
    self.softStealLatched = false
    print("[CarrySystem] Desactivado")
end

function CarrySystem:setNormalSpeed(v) self.normalSpeed = _clamp(v,1,500) end
function CarrySystem:setCarrySpeed(v) self.carrySpeed = _clamp(v,1,500) end
function CarrySystem:setLaggerSpeed(v) self.laggerSpeed = _clamp(v,0.1,500) end
function CarrySystem:setLaggerCarrySpeed(v) self.laggerCarrySpeed = _clamp(v,0.1,500) end
function CarrySystem:setSoftStealSpeed(v) self.softStealSpeed = _clamp(v,1,500) end
function CarrySystem:setSoftStealRadius(v) self.softStealRadius = _clamp(v,1,200) end

function CarrySystem:toggleCarryMode() self.speedToggled = not self.speedToggled end
function CarrySystem:setLaggerMode(mode)
    if mode == 0 then self.laggerMode = 0
    elseif mode == 1 then self.laggerMode = 1
    elseif mode == 2 then self.laggerMode = 2 end
end
function CarrySystem:toggleLaggerMode()
    if self.laggerMode == 0 then self.laggerMode = 1
    elseif self.laggerMode == 1 then self.laggerMode = 2
    else self.laggerMode = 0 end
end
function CarrySystem:setSoftStealEnabled(enabled)
    self.softStealEnabled = enabled
    if enabled then self:startSoftStealScanner()
    else self:stopSoftStealScanner(); self.softStealLatched = false end
end
function CarrySystem:toggleSoftSteal() self:setSoftStealEnabled(not self.softStealEnabled) end
function CarrySystem:isRunning() return self._heartbeatConn ~= nil end
function CarrySystem:getCurrentSpeed() return self:getActiveSpeed() end

local COLOR_THEMES = {
    ["Gris"] = Color3.fromRGB(180, 180, 190),
    ["Morado"] = Color3.fromRGB(160, 100, 220),
    ["Azul"] = Color3.fromRGB(80, 150, 255),
    ["Rosado"] = Color3.fromRGB(255, 120, 180),
    ["Verde"] = Color3.fromRGB(80, 220, 120),
    ["Vainilla"] = Color3.fromRGB(212, 180, 135),
}

currentColorTheme = "Gris"
selectedColor = COLOR_THEMES["Gris"]

function getThemeColor() return selectedColor end

local _lastThemeUpdate = 0
local _lastThemeColor = nil

function applyColorTheme(themeName)
    local color = COLOR_THEMES[themeName]
    if not color then return end
    currentColorTheme = themeName
    selectedColor = color
    updateAllUIThemeColors(color)
    saveAllSettings()
end

function updateAllUIThemeColors(color)
    local now = _tick()
    if color == _lastThemeColor and now - _lastThemeUpdate < 0.1 then return end
    _lastThemeUpdate = now
    _lastThemeColor = color

    if progressFill then
        progressFill.BackgroundColor3 = color
        local grad = progressFill:FindFirstChildOfClass("UIGradient")
        if grad then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, color),
                ColorSequenceKeypoint.new(0.50, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1.00, color),
            })
        end
    end
    if pbFrame then
        local border = pbFrame:FindFirstChildOfClass("UIStroke")
        if border then border.Color = color end
        local discordLabel = pbFrame:FindFirstChild("DiscordLabel")
        if discordLabel then discordLabel.TextColor3 = color end
        local fpsNeon = pbFrame:FindFirstChild("FPSNeon")
        if fpsNeon then fpsNeon.TextColor3 = color end
    end
    local function searchAndUpdateText(parent)
        for _, child in ipairs(parent:GetDescendants()) do
            if child:IsA("TextLabel") then
                if child.Text:find("discord.gg") or child.Text:find("Spd:") or child.Name == "DiscordText" or
                   child.Name == "BloodHoundsSpeedIndicator" or child.Text:find("FPS") then
                    child.TextColor3 = color
                end
            end
            if child:IsA("UIStroke") then
                if child.Color == Color3.fromRGB(180, 180, 190) then child.Color = color end
            end
        end
    end
    if gui then searchAndUpdateText(gui) end
    if tpBatFloatingButton then
        paintFloatingBtn(tpBatFloatingButton:FindFirstChild("Frame"), batDesyncTpEnabled)
    end
    if batV2FloatingButton then
        paintFloatingBtn(batV2FloatingButton:FindFirstChild("Frame"), autoBatV2Enabled)
    end
    for _, tab in ipairs(tabButtons or {}) do
        if tab.TextColor3 == Color3.fromRGB(180, 180, 190) then tab.TextColor3 = color end
    end
    for _, hl in pairs(espHighlightCache) do
        if hl then hl.FillColor = color; hl.OutlineColor = color end
    end
    for _, lines in pairs(espTracerCache) do
        if lines then
            for _, ln in ipairs(lines) do
                if ln then ln.Color = color end
            end
        end
    end
    for _, bb in pairs(espBillboardCache) do
        if bb then
            local img = bb:FindFirstChildOfClass("ImageLabel")
            if img then
                local stroke = img:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Color = color end
            end
        end
    end
    if main then
        local titleFrame = main:FindFirstChild("Frame")
        if titleFrame then
            for _, child in ipairs(titleFrame:GetDescendants()) do
                if child:IsA("UIStroke") and child.Color == Color3.fromRGB(180, 180, 190) then
                    child.Color = color
                end
            end
        end
    end
    if colorSelectorLabel then
        colorSelectorLabel.Text = currentColorTheme
        colorSelectorLabel.TextColor3 = color
    end
    if miniBtn then
        miniBtn.TextColor3 = color
        local grad = miniBtn:FindFirstChildOfClass("UIGradient")
        if grad then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(0.3, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(0.7, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, color),
            })
        end
    end

    local pGui = LP:FindFirstChild("PlayerGui")
    if pGui then
        local bb = pGui:FindFirstChild("RagCountdownBillboard")
        if bb then
            local lbl = bb:FindFirstChildOfClass("TextLabel")
            if lbl then
                lbl.TextColor3 = color
                local grad = lbl:FindFirstChildOfClass("UIGradient")
                if grad then
                    grad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, color),
                        ColorSequenceKeypoint.new(0.3, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(0.7, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, color),
                    })
                end
            end
        end
    end

    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        if container then
            local btnContainer = container:FindFirstChild("ButtonsContainer")
            if btnContainer then
                for _, btn in ipairs(btnContainer:GetChildren()) do
                    if btn:IsA("TextButton") and btn:FindFirstChild("BtnGrad") then
                        paintFloatingBtn(btn, btn:GetAttribute("MobActive") == true)
                    end
                end
            end
        end
    end
end

local HOMERO_CFG = {
    body = { 10725826963, 86500008, 86500054, 86500036, 86500064, 86500078 },
    aplicarCuerpo = true,
    items = {
        { id = 103227869700418, offset = _CFnew(0,0,0) },
        { id = 84952305140948,   offset = _CFnew(0,0,0) },
        { id = 122465238537030,  offset = _CFnew(0,0,0) },
    },
    shirt = nil,
    pants = "rbxassetid://78591690208112",
    skinColor = Color3.fromRGB(234,184,146),
    headColor = Color3.fromRGB(0,0,0),
}

local TAG = "LocalOutfit_"

local function loadObjects(id)
    local ok, res = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(id))
    end)
    if ok and typeof(res) == "table" and #res > 0 then return res end
    ok, res = pcall(function()
        return game:GetService("InsertService"):LoadAsset(id)
    end)
    if ok and res then return { res } end
    return nil
end

local function collectParts(objs)
    local out = {}
    for _, o in ipairs(objs) do
        if o:IsA("BasePart") then out[#out + 1] = o end
        for _, d in ipairs(o:GetDescendants()) do
            if d:IsA("BasePart") then out[#out + 1] = d end
        end
    end
    return out
end

local function findAtt(char, name)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("Attachment") and p.Name == name and p.Parent:IsA("BasePart") then
            return p
        end
    end
end

local function applyBody(char)
    local total = 0
    for _, id in ipairs(HOMERO_CFG.body) do
        local objs = loadObjects(id)
        if objs then
            for _, mp in ipairs(collectParts(objs)) do
                local orig = char:FindFirstChild(mp.Name)
                if orig and orig:IsA("BasePart") then
                    local c = mp:Clone()
                    c.Name = TAG .. "body_" .. mp.Name
                    c.CanCollide = false
                    c.Anchored = false
                    c.Massless = true
                    c.Size = orig.Size
                    c.CFrame = orig.CFrame
                    c.Parent = char
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = orig
                    w.Part1 = c
                    w.Parent = c
                    orig.Transparency = 1
                    total = total + 1
                end
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end
    return total
end

local function attachItem(char, entry)
    local objs = loadObjects(entry.id)
    if not objs then return false end

    local handle
    for _, p in ipairs(collectParts(objs)) do
        if p.Name == "Handle" then handle = p; break end
        if not handle then handle = p end
    end
    if not handle then
        for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        return false
    end

    local H = handle:Clone()
    for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end

    H.Name = TAG .. "item_" .. tostring(entry.id)
    H.CanCollide = false
    H.Anchored = false
    H.Massless = true

    local wrap = H:FindFirstChildWhichIsA("WrapLayer")
    local target, c0, c1

    if wrap then
        target = char:FindFirstChild("UpperTorso")
              or char:FindFirstChild("Torso")
              or char:FindFirstChild("HumanoidRootPart")
        c0 = entry.offset or _CFnew()
        c1 = _CFnew()
    else
        local hAtt = H:FindFirstChildOfClass("Attachment")
        local bAtt = hAtt and findAtt(char, hAtt.Name)
        if bAtt then
            target = bAtt.Parent
            c0 = bAtt.CFrame * (entry.offset or _CFnew())
            c1 = hAtt.CFrame
        else
            target = char:FindFirstChild("Head")
            c0 = entry.offset or _CFnew(0, 1.4, 0)
            c1 = _CFnew()
        end
    end

    if not target then H:Destroy(); return false end

    H.CFrame = target.CFrame * c0 * c1:Inverse()
    H.Parent = char

    local w = Instance.new("Weld")
    w.Part0 = target
    w.Part1 = H
    w.C0 = c0
    w.C1 = c1
    w.Parent = H
    return true
end

function applyHomeroOutfit(char)
    if not char then char = LP.Character end
    if not char then return end
    char:WaitForChild("Humanoid", 10)
    char:WaitForChild("Head", 10)
    task.wait(0.4)

    for _, d in ipairs(char:GetChildren()) do
        if d.Name:sub(1, #TAG) == TAG then pcall(function() d:Destroy() end) end
    end

    if HOMERO_CFG.skinColor then
        local bc = char:FindFirstChildWhichIsA("BodyColors") or Instance.new("BodyColors")
        bc.HeadColor3 = HOMERO_CFG.headColor or HOMERO_CFG.skinColor
        bc.TorsoColor3 = HOMERO_CFG.skinColor
        bc.LeftArmColor3, bc.RightArmColor3 = HOMERO_CFG.skinColor, HOMERO_CFG.skinColor
        bc.LeftLegColor3, bc.RightLegColor3 = HOMERO_CFG.skinColor, HOMERO_CFG.skinColor
        bc.Parent = char
    end

    for _, a in ipairs(char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then h.Transparency = 1 end
        end
    end

    if HOMERO_CFG.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"
        s.ShirtTemplate = HOMERO_CFG.shirt
        s.Parent = char
    end
    if HOMERO_CFG.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"
        p.PantsTemplate = HOMERO_CFG.pants
        p.Parent = char
    end
    if HOMERO_CFG.aplicarCuerpo then applyBody(char) end
    for _, e in ipairs(HOMERO_CFG.items) do attachItem(char, e) end
end

local function applyNoOutfit(char)
    if not char then char = LP.Character end
    if not char then return end
    for _, d in ipairs(char:GetChildren()) do
        if d.Name:sub(1, #TAG) == TAG then pcall(function() d:Destroy() end) end
    end
    local oldAcc = char:FindFirstChild("AuFfitAccessory")
    if oldAcc then pcall(function() oldAcc:Destroy() end) end
    local oldKorblox = char:FindFirstChild("Korblox_RightLeg")
    if oldKorblox then pcall(function() oldKorblox:Destroy() end) end
    for _, d in ipairs(char:GetChildren()) do
        if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
            pcall(function() d:Destroy() end)
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        head.CanCollide = true
        head.LocalTransparencyModifier = 0
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 0 end
        local sm = head:FindFirstChildWhichIsA("SpecialMesh")
        if sm then pcall(function() sm:Destroy() end) end
    end
    pcall(function()
        local neck = char:FindFirstChild("Neck")
        if neck then neck.Enabled = true end
    end)
    for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local limb = char:FindFirstChild(partName)
        if limb then limb.Transparency = 0 end
    end
    local shirt = char:FindFirstChildWhichIsA("Shirt")
    if shirt then pcall(function() shirt:Destroy() end) end
    local pants = char:FindFirstChildWhichIsA("Pants")
    if pants then pcall(function() pants:Destroy() end) end
    for _, a in ipairs(char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then h.Transparency = 0 end
        end
    end
end

local OUTFITS = {
    {
        accessory = 10159600649,
        offset = _V3new(0, 1, -0.2),
        shirt = "http://www.roblox.com/asset/?id=9683332638",
        pants = "http://www.roblox.com/asset/?id=93182020184041",
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918 ",
        korblox = "none",
        label = "Outfit 1",
        headlessKorblox = true,
    },
    {
        accessory = 1744060292,
        offset = _V3new(0, 1.3, -0.2),
        shirt = "http://www.roblox.com/asset/?id=9683332638",
        pants = "http://www.roblox.com/asset/?id=93182020184041",
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918 ",
        korblox = "none",
        label = "Outfit 2",
        headlessKorblox = true,
    },
    {
        accessory = 8349240186,
        offset = _V3new(0, 0.9, 0),
        shirt = "http://www.roblox.com/asset/?id=11926549070",
        pants = "http://www.roblox.com/asset/?id=13189494471",
        headMesh = "https://assetdelivery.roblox.com/v1/asset/?id=16673245747",
        headTexture = nil,
        korblox = "none",
        label = "Outfit 3",
        headlessKorblox = true,
    },
    {
        accessory = 121097973925756,
        offset = _V3new(0, 0.9, 0),
        shirt = "http://www.roblox.com/asset/?id=123181702116947",
        pants = "http://www.roblox.com/asset/?id=93330291631062",
        headMesh = "http://www.roblox.com/asset/?id=134079402",
        headTexture = "http://www.roblox.com/asset/?id=133940918 ",
        korblox = "none",
        label = "Outfit 4",
        headlessKorblox = true,
    },
    {
        label = "Homero Chino",
        customApply = applyHomeroOutfit,
    },
    {
        label = "NO",
        customApply = applyNoOutfit,
    },
}
local currentOutfitIndex = 1
local outfitSelectorLabel = nil

local function loadObjectsStd(id)
    local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
    if ok and typeof(res) == "table" and #res > 0 then return res end
    ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
    if ok and res then return {res} end
    return nil
end

local function applyHeadlessKorblox(char)
    if not char then return end
    pcall(function() LP.CharacterAvatarType = Enum.AvatarType.R6 end)
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        head.CanCollide = false
        head.LocalTransparencyModifier = 1
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 1 end
    end
    pcall(function()
        local neck = char:FindFirstChild("Neck")
        if neck then neck.Enabled = false end
    end)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Accessory") then
            local w = v:FindFirstChildWhichIsA("Weld") or v:FindFirstChildWhichIsA("WeldConstraint") or v:FindFirstChildWhichIsA("Motor6D")
            if w then
                local p0, p1 = w.Part0, w.Part1
                if (p0 and p0.Name == "Head") or (p1 and p1.Name == "Head") then
                    v.Parent = nil
                end
            end
        end
    end
    local rightLegConfig = {
        id = "rbxassetid://139607718",
        targetBodyPart = "RightUpperLeg",
        partsToHide = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        scale = _V3new(1, 1, 1),
        offset = _CFnew(0, 0, 0)
    }
    local targetPart = char:FindFirstChild(rightLegConfig.targetBodyPart)
    if targetPart then
        local oldAsset = char:FindFirstChild("Korblox_RightLeg")
        if oldAsset then oldAsset:Destroy() end
        for _, partName in ipairs(rightLegConfig.partsToHide) do
            local limb = char:FindFirstChild(partName)
            if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
        end
        local success, objects = pcall(function() return game:GetObjects(rightLegConfig.id) end)
        if success and objects and #objects > 0 then
            local assetModel = objects[1]
            assetModel.Name = "Korblox_RightLeg"
            local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
            if mainMesh then
                mainMesh.Size = mainMesh.Size * rightLegConfig.scale
                mainMesh.CanCollide = false
                mainMesh.CFrame = targetPart.CFrame * rightLegConfig.offset
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = targetPart
                weld.Part1 = mainMesh
                weld.Parent = mainMesh
                assetModel.Parent = char
            end
        end
    end
end

function applyOutfitByIndex(index)
    local cfg = OUTFITS[index]
    if not cfg then return end
    local char = LP.Character
    if not char then return end

    if cfg.customApply then
        cfg.customApply(char)
        if outfitSelectorLabel then outfitSelectorLabel.Text = cfg.label end
        return
    end

    char:WaitForChild("Head", 5)
    local head = char:FindFirstChild("Head")
    if not head then return end
    for _, d in ipairs(char:GetChildren()) do
        if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
            pcall(function() d:Destroy() end)
        end
    end
    local done = false
    if head:IsA("MeshPart") then
        done = pcall(function()
            head.MeshId = cfg.headMesh
            if cfg.headTexture then head.TextureID = cfg.headTexture end
        end)
    end
    if not done then
        local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
        sm.Parent = head
        sm.MeshType = Enum.MeshType.FileMesh
        sm.MeshId = cfg.headMesh
        sm.TextureId = cfg.headTexture or ""
    end
    if cfg.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"
        s.ShirtTemplate = cfg.shirt
        s.Parent = char
    end
    if cfg.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"
        p.PantsTemplate = cfg.pants
        p.Parent = char
    end
    local old = char:FindFirstChild("AuFfitAccessory")
    if old then old:Destroy() end
    if cfg.accessory and head then
        local objs = loadObjectsStd(cfg.accessory)
        if objs then
            local handle
            for _, o in ipairs(objs) do
                if o:IsA("BasePart") then handle = o; break end
                local f = o:FindFirstChildWhichIsA("BasePart", true)
                if f then handle = f; break end
            end
            if handle then
                local h = handle:Clone()
                h.Name = "AuFfitAccessory"
                h.CanCollide = false
                h.Anchored = false
                h.Massless = true
                h.Parent = char
                local weld = Instance.new("Weld")
                weld.Part0 = head
                weld.Part1 = h
                weld.C0 = _CFnew(cfg.offset)
                weld.Parent = h
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end
    if cfg.headlessKorblox then
        applyHeadlessKorblox(char)
    else
        if char then
            local head2 = char:FindFirstChild("Head")
            if head2 then
                head2.Transparency = 0
                head2.CanCollide = true
                head2.LocalTransparencyModifier = 0
                local face2 = head2:FindFirstChild("face")
                if face2 then face2.Transparency = 0 end
            end
            pcall(function()
                local neck = char:FindFirstChild("Neck")
                if neck then neck.Enabled = true end
            end)
            for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
                local limb = char:FindFirstChild(partName)
                if limb then limb.Transparency = 0 end
            end
            local oldKorblox = char:FindFirstChild("Korblox_RightLeg")
            if oldKorblox then oldKorblox:Destroy() end
        end
    end
    if outfitSelectorLabel then outfitSelectorLabel.Text = cfg.label end
end

speedMode = false
antiRagdollMode = "off"
antiDieEnabled = false
antiFlingEnabled = false
jumpEnabled = false
laggerToggled = false
laggerCarryToggled = false
medusaCounterEnabled = false
batCounterEnabled = false
unwalkEnabled = false
autoLeftEnabled = false
autoRightEnabled = false
autoBatEnabled = false
dropMode = 1
antiLagEnabled = false
removeAccessoriesEnabled = false
stretchEnabled = false
stretchFOV = 120
uiLocked = true
editModeEnabled = false
uiScaleValue = 78
espEnabled = false

bodyLockEnabled = false
bodyLockRange = 20
bodyLockRangeBox = nil
_bodyLockConn = nil
_blSuppressCount = 0
_blWasEnabled = false
_blRestoreTimer = nil
_blSmoothRestore = false

savedProgressBarPos = nil
savedButtonPositions = {}
savedMobilePanelPos = nil
tpBatFloatingPos = nil
batV2FloatingPos = nil
instaResetFloatingPos = nil
instaResetFloatingButton = nil

neonWeatherEnabled = false
skyTheme = "Off"
skySelectorLabel = nil
_originalLighting = nil
setNeonWeatherVisual = nil

currentAnimPack = "Off"
originalTryardAnims = nil
tryardHeartbeatConn = nil
animSelectorLabel = nil

autoBatV2Enabled = false
autoBatV2SwingEnabled = true
autoBatV2HitCooldown = false
AUTO_BAT_V2_SPEED = 60
AUTO_BAT_V2_DIST = 1.0
AUTO_BAT_V2_HEIGHT = 1.5
AUTO_BAT_V2_V_OFF = 0.0
AUTO_BAT_V2_HIT_DIST = 4.5
AUTO_BAT_V2_SWING_CD = 0.08
_batV2Conn = nil

useCarrySystem = false
lastMoveDir = _V3zero

local CoreGui = game:GetService("CoreGui")

local InfiniteJump = {
    enabled = false,
    jumpPower = 55,
    minVelocity = 30,
    jumpConn = nil,
    heartbeatConn = nil,
}

local function applyJump(root)
    if not root then return end
    pcall(function()
        root.Velocity = _V3new(root.Velocity.X, InfiniteJump.jumpPower, root.Velocity.Z)
    end)
end

local function onJumpRequest()
    if not InfiniteJump.enabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then applyJump(root) end
end

local function onHeartbeat()
    if not InfiniteJump.enabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local jumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump == true)
    if jumpHeld and root.Velocity.Y < InfiniteJump.minVelocity then
        applyJump(root)
    end
end

local function connectEvents()
    if InfiniteJump.jumpConn then InfiniteJump.jumpConn:Disconnect() end
    if InfiniteJump.heartbeatConn then InfiniteJump.heartbeatConn:Disconnect() end
    InfiniteJump.jumpConn = UIS.JumpRequest:Connect(onJumpRequest)
    InfiniteJump.heartbeatConn = RunService.Heartbeat:Connect(onHeartbeat)
end

function InfiniteJump.start()
    if InfiniteJump.enabled then return end
    InfiniteJump.enabled = true
    connectEvents()
    print("[InfiniteJump] Activado")
end

function InfiniteJump.stop()
    InfiniteJump.enabled = false
    if InfiniteJump.jumpConn then InfiniteJump.jumpConn:Disconnect(); InfiniteJump.jumpConn = nil end
    if InfiniteJump.heartbeatConn then InfiniteJump.heartbeatConn:Disconnect(); InfiniteJump.heartbeatConn = nil end
    print("[InfiniteJump] Desactivado")
end

function InfiniteJump.setJumpPower(power)
    power = tonumber(power) or 55
    InfiniteJump.jumpPower = _clamp(power, 10, 200)
end

function InfiniteJump.isRunning() return InfiniteJump.enabled == true end

InfiniteJump.start()

local function getCharParts()
    local char = LP.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return nil, nil end
    return hum, root
end

local function claimOwnership(root)
    pcall(function() root:SetNetworkOwner(LP) end)
end

function getActiveMoveSpeed()
    if laggerCarryToggled then return LAGGER_CARRY_SPEED
    elseif laggerToggled then return LAGGER_SPEED
    elseif speedMode then return CS
    else return NS end
end

local _velChecked = {}
local _hookedVelParts = {}

local function _setupVelChecked(char)
    _velChecked = {}
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then _velChecked[hrp] = true end
    return hrp
end

local _hookVelSupported = nil
local function _hookVelHRP(hrp)
    if not hrp or _hookedVelParts[hrp] then return end
    if _hookVelSupported == false then return end
    if _hookVelSupported == nil then
        _hookVelSupported = (type(getrawmetatable) == "function")
            and (type(setreadonly) == "function")
            and (type(newcclosure) == "function")
            and (type(checkcaller) == "function")
    end
    if not _hookVelSupported then return end
    _hookedVelParts[hrp] = true
    local ok = pcall(function()
        local mt = getrawmetatable(hrp)
        if not mt then return end
        setreadonly(mt, false)
        local originalVelIndex = rawget(mt, "__index")
        mt.__index = newcclosure(function(self, key)
            if not checkcaller() and _velChecked[self]
               and (key == "AssemblyLinearVelocity" or key == "Velocity") then
                local real
                if type(originalVelIndex) == "function" then
                    real = originalVelIndex(self, key)
                elseif type(originalVelIndex) == "table" then
                    real = originalVelIndex[key]
                end
                if real and real.Magnitude > 20 then return real.Unit * 20 end
                return real
            end
            if type(originalVelIndex) == "function" then
                return originalVelIndex(self, key)
            elseif type(originalVelIndex) == "table" then
                return originalVelIndex[key]
            end
        end)
        setreadonly(mt, true)
    end)
    if not ok then _hookVelSupported = false end
end

if LP.Character then
    local _hrp0 = _setupVelChecked(LP.Character)
    _hookVelHRP(_hrp0)
end

local function _isRagdollState(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand
        or st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
end

local function _applyVelocitySpeed(dir, speed, hrp)
    if not hrp or not hrp.Parent then return end
    if autoBatV2Enabled or batDesyncTpEnabled or autoBatEnabled then return end
    if dir and dir.Magnitude > 0.05 then
        pcall(function()
            if hrp.SetNetworkOwner then hrp:SetNetworkOwner(LP) end
        end)
        local unit = dir.Unit
        local vy = hrp.AssemblyLinearVelocity.Y
        hrp.AssemblyLinearVelocity = _V3new(unit.X * speed, vy, unit.Z * speed)
    else
        local vy = hrp.AssemblyLinearVelocity.Y
        hrp.AssemblyLinearVelocity = _V3new(0, vy, 0)
    end
end

function getAutoPathSpeed()
    if laggerCarryToggled or laggerToggled then return LAGGER_SPEED end
    return NS
end

ANIM_PACKS = {
    ["Zombie"] = { idle1="rbxassetid://616158929", idle2="rbxassetid://616160636", walk="rbxassetid://616168032", run="rbxassetid://616163682", jump="rbxassetid://616161997", fall="rbxassetid://616157476", climb="rbxassetid://616156119", swim="rbxassetid://616165109", swimidle="rbxassetid://616166655" },
    ["Ninja"] = { idle1="rbxassetid://656117400", idle2="rbxassetid://656117400", walk="rbxassetid://656121766", run="rbxassetid://656118852", jump="rbxassetid://656117878", fall="rbxassetid://656115606", climb="rbxassetid://656114359", swim="rbxassetid://656117400", swimidle="rbxassetid://656117400" },
    ["Knight"] = { idle1="rbxassetid://657595757", idle2="rbxassetid://657595757", walk="rbxassetid://657552124", run="rbxassetid://657564596", jump="rbxassetid://658409194", fall="rbxassetid://657600338", climb="rbxassetid://658360781", swim="rbxassetid://657595757", swimidle="rbxassetid://657595757" },
    ["Elder"] = { idle1="rbxassetid://845397899", idle2="rbxassetid://845397899", walk="rbxassetid://845403856", run="rbxassetid://845386501", jump="rbxassetid://845398858", fall="rbxassetid://845397673", climb="rbxassetid://845392038", swim="rbxassetid://845397899", swimidle="rbxassetid://845397899" },
    ["Levitate"] = { idle1="rbxassetid://616006778", idle2="rbxassetid://616006778", walk="rbxassetid://616013216", run="rbxassetid://616013216", jump="rbxassetid://616008936", fall="rbxassetid://616005863", climb="rbxassetid://616003713", swim="rbxassetid://616006778", swimidle="rbxassetid://616006778" },
    ["Astronaut"] = { idle1="rbxassetid://891621366", idle2="rbxassetid://891621366", walk="rbxassetid://891636393", run="rbxassetid://891636393", jump="rbxassetid://891627522", fall="rbxassetid://891617961", climb="rbxassetid://891609353", swim="rbxassetid://891621366", swimidle="rbxassetid://891621366" },
    ["Pirate"] = { idle1="rbxassetid://750781874", idle2="rbxassetid://750781874", walk="rbxassetid://750785693", run="rbxassetid://750783738", jump="rbxassetid://750782230", fall="rbxassetid://750780242", climb="rbxassetid://750779899", swim="rbxassetid://750781874", swimidle="rbxassetid://750781874" },
    ["Toy"] = { idle1="rbxassetid://782841498", idle2="rbxassetid://782841498", walk="rbxassetid://782843345", run="rbxassetid://782842708", jump="rbxassetid://782847020", fall="rbxassetid://782846423", climb="rbxassetid://782843869", swim="rbxassetid://782841498", swimidle="rbxassetid://782841498" },
    ["Vampire"] = { idle1="rbxassetid://1083445855", idle2="rbxassetid://1083445855", walk="rbxassetid://1083473930", run="rbxassetid://1083462077", jump="rbxassetid://1083455352", fall="rbxassetid://1083443587", climb="rbxassetid://1083439238", swim="rbxassetid://1083445855", swimidle="rbxassetid://1083445855" },
    ["Werewolf"] = { idle1="rbxassetid://1083195517", idle2="rbxassetid://1083195517", walk="rbxassetid://1083178339", run="rbxassetid://1083216690", jump="rbxassetid://1083218792", fall="rbxassetid://1083189019", climb="rbxassetid://1083182000", swim="rbxassetid://1083195517", swimidle="rbxassetid://1083195517" },
    ["Rthro"] = { idle1="rbxassetid://2510196951", idle2="rbxassetid://2510196951", walk="rbxassetid://2510202577", run="rbxassetid://2510198475", jump="rbxassetid://2510197830", fall="rbxassetid://2510195892", climb="rbxassetid://2510192778", swim="rbxassetid://2510196951", swimidle="rbxassetid://2510196951" },
    ["Stylish"] = { idle1="rbxassetid://616136790", idle2="rbxassetid://616136790", walk="rbxassetid://616146177", run="rbxassetid://616140816", jump="rbxassetid://616139451", fall="rbxassetid://616134815", climb="rbxassetid://616133594", swim="rbxassetid://616136790", swimidle="rbxassetid://616136790" },
}

ANIM_PACK_ORDER = {{"Off", "Off"}, {"Zombie", "Zombie"}, {"Ninja", "Ninja"}, {"Knight", "Knight"}, {"Elder", "Elder"}, {"Levitate", "Levitate"}, {"Astronaut", "Astronaut"}, {"Pirate", "Pirate"}, {"Toy", "Toy"}, {"Vampire", "Vampire"}, {"Werewolf", "Werewolf"}, {"Rthro", "Rthro"}, {"Stylish", "Stylish"}}

local function isPackAnim(id)
    for _, pack in pairs(ANIM_PACKS) do
        for _, v in pairs(pack) do
            if v == id then return true end
        end
    end
    return false
end

local function saveOriginalAnims(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    local ids = {
        idle1 = g(animate.idle and animate.idle.Animation1),
        idle2 = g(animate.idle and animate.idle.Animation2),
        walk  = g(animate.walk and animate.walk.WalkAnim),
        run   = g(animate.run  and animate.run.RunAnim),
        jump  = g(animate.jump and animate.jump.JumpAnim),
        fall  = g(animate.fall and animate.fall.FallAnim),
        climb = g(animate.climb and animate.climb.ClimbAnim),
        swim  = g(animate.swim and animate.swim.Swim),
        swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
    }
    if not isPackAnim(ids.walk) then originalTryardAnims = ids end
end

local function applyAnimPack(packName)
    currentAnimPack = packName
    if animSelectorLabel then animSelectorLabel.Text = packName end
    if packName == "Off" then
        if originalTryardAnims and LP.Character then
            local animate = LP.Character:FindFirstChild("Animate")
            if animate then
                local function s(obj,id) if obj then obj.AnimationId = id end end
                s(animate.idle and animate.idle.Animation1, originalTryardAnims.idle1)
                s(animate.idle and animate.idle.Animation2, originalTryardAnims.idle2)
                s(animate.walk and animate.walk.WalkAnim, originalTryardAnims.walk)
                s(animate.run  and animate.run.RunAnim,   originalTryardAnims.run)
                s(animate.jump and animate.jump.JumpAnim, originalTryardAnims.jump)
                s(animate.fall and animate.fall.FallAnim, originalTryardAnims.fall)
                s(animate.climb and animate.climb.ClimbAnim, originalTryardAnims.climb)
                s(animate.swim and animate.swim.Swim, originalTryardAnims.swim)
                s(animate.swimidle and animate.swimidle.SwimIdle, originalTryardAnims.swimidle)
            end
        end
        if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect(); tryardHeartbeatConn = nil end
        return
    end
    local pack = ANIM_PACKS[packName]
    if not pack then return end
    if tryardHeartbeatConn then tryardHeartbeatConn:Disconnect() end
    tryardHeartbeatConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        if not c then return end
        local animate = c:FindFirstChild("Animate")
        if not animate then return end
        local function s(obj,id) if obj then obj.AnimationId = id end end
        s(animate.idle and animate.idle.Animation1, pack.idle1)
        s(animate.idle and animate.idle.Animation2, pack.idle2)
        s(animate.walk and animate.walk.WalkAnim, pack.walk)
        s(animate.run  and animate.run.RunAnim,   pack.run)
        s(animate.jump and animate.jump.JumpAnim, pack.jump)
        s(animate.fall and animate.fall.FallAnim, pack.fall)
        s(animate.climb and animate.climb.ClimbAnim, pack.climb)
        s(animate.swim and animate.swim.Swim, pack.swim)
        s(animate.swimidle and animate.swimidle.SwimIdle, pack.swimidle)
    end)
end

local function startAnimPack(packName)
    local char = LP.Character
    if char then
        saveOriginalAnims(char)
        applyAnimPack(packName)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) end
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    else
        applyAnimPack(packName)
    end
    currentAnimPack = packName
end

local function stopAnimPack()
    currentAnimPack = "Off"
    if animSelectorLabel then animSelectorLabel.Text = "Off" end
    applyAnimPack("Off")
end

DEFAULT_KB = {
    DropBrainrot = {kb = Enum.KeyCode.X, gp = nil},
    AutoLeft     = {kb = Enum.KeyCode.Z, gp = nil},
    AutoRight    = {kb = Enum.KeyCode.C, gp = nil},
    AutoBat      = {kb = Enum.KeyCode.E, gp = nil},
    TPFloor      = {kb = Enum.KeyCode.F, gp = nil},
    GuiHide      = {kb = Enum.KeyCode.LeftControl, gp = nil},
    CarryToggle  = {kb = Enum.KeyCode.Q, gp = nil},
    LaggerMode   = {kb = Enum.KeyCode.R, gp = nil},
    TPBat        = {kb = Enum.KeyCode.V, gp = nil},
    BatV2        = {kb = Enum.KeyCode.N, gp = nil},
    InstaReset   = {kb = Enum.KeyCode.H, gp = nil},
}

KB = {
    DropBrainrot = {kb = DEFAULT_KB.DropBrainrot.kb, gp = DEFAULT_KB.DropBrainrot.gp},
    AutoLeft     = {kb = DEFAULT_KB.AutoLeft.kb, gp = DEFAULT_KB.AutoLeft.gp},
    AutoRight    = {kb = DEFAULT_KB.AutoRight.kb, gp = DEFAULT_KB.AutoRight.gp},
    AutoBat      = {kb = DEFAULT_KB.AutoBat.kb, gp = DEFAULT_KB.AutoBat.gp},
    TPFloor      = {kb = DEFAULT_KB.TPFloor.kb, gp = DEFAULT_KB.TPFloor.gp},
    GuiHide      = {kb = DEFAULT_KB.GuiHide.kb, gp = DEFAULT_KB.GuiHide.gp},
    CarryToggle  = {kb = DEFAULT_KB.CarryToggle.kb, gp = DEFAULT_KB.CarryToggle.gp},
    LaggerMode   = {kb = DEFAULT_KB.LaggerMode.kb, gp = DEFAULT_KB.LaggerMode.gp},
    TPBat        = {kb = DEFAULT_KB.TPBat.kb, gp = DEFAULT_KB.TPBat.gp},
    BatV2        = {kb = DEFAULT_KB.BatV2.kb, gp = DEFAULT_KB.BatV2.gp},
    InstaReset   = {kb = DEFAULT_KB.InstaReset.kb, gp = DEFAULT_KB.InstaReset.gp},
}

_isResetting = false
_lastSavedJSON = nil
_isLoading = false

CONFIG = {
    AUTO_STEAL_ENABLED = false,
    STEAL_RANGE = 61,
}

local plots = workspace:WaitForChild("Plots")
local stealConnection = nil

local Steal = {
    AutoStealEnabled = false,
    StealRadius = CONFIG.STEAL_RANGE,
    StealDuration = 1.3,
    StealDelay = 0.25,
    Data = {}
}

local isStealing = false
local autoGrabSetDelayRadius = 9
local autoGrabStopTime = 0.96
local autoGrabStopEnabled = true

local _plotsCache = nil
local _plotsCacheTime = 0
local function getPlotsRoot()
    local now = _tick()
    if _plotsCache and now - _plotsCacheTime < 2 and _plotsCache.Parent then
        return _plotsCache
    end
    _plotsCache = workspace:FindFirstChild("Plots")
    _plotsCacheTime = now
    return _plotsCache
end

local function isMyPlotByName(plotName)
    local plotsRoot = getPlotsRoot()
    if not plotsRoot then return false end
    local plot = plotsRoot:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then
            return yb.Enabled == true
        end
    end
    return false
end

local function findNearestPrompt()
    local char = LP.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local plotsRoot = getPlotsRoot()
    if not plotsRoot then return nil, nil end
    local nearestPrompt, nearestDist, nearestName = nil, _huge, nil
    local rpos = root.Position
    for _, plot in ipairs(plotsRoot:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local sp = spawn.Position
                    local dx = sp.X - rpos.X
                    local dy = sp.Y - rpos.Y
                    local dz = sp.Z - rpos.Z
                    local dist = _sqrt(dx*dx + dy*dy + dz*dz)
                    if dist < nearestDist and dist <= Steal.StealRadius then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, child in ipairs(att:GetChildren()) do
                                if child:IsA("ProximityPrompt") and child.ActionText and child.ActionText:find("Steal") then
                                    nearestPrompt = child
                                    nearestDist = dist
                                    nearestName = pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return nearestPrompt, nearestName
end

local function executeSteal(prompt, podName)
    if isStealing then return end

    if math.random(30) == 1 then
        for p in pairs(Steal.Data) do
            if not p.Parent then Steal.Data[p] = nil end
        end
    end

    if not Steal.Data[prompt] then
        Steal.Data[prompt] = { hold = {}, trigger = {}, ready = true }
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(Steal.Data[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(Steal.Data[prompt].trigger, c.Function) end
                end
            end
        end)
    end

    local data = Steal.Data[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true

    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
    if progressPct then progressPct.Text = "0%" end

    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end

        local startTime = _tick()
        local duration = Steal.StealDuration
        local promptFired = false

        if autoGrabStopEnabled then
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = _tick() - startTime
                if elapsed >= autoGrabStopTime then break end
                local progress = _clamp(elapsed / duration, 0, 1)
                if progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
                if progressPct then progressPct.Text = _floor(progress * 100) .. "%" end
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then
                    break
                end
                task.wait()
            end

            local stopProgress = _clamp(autoGrabStopTime / duration, 0, 1)
            if progressFill then progressFill.Size = UDim2.new(stopProgress, 0, 1, 0) end
            if progressPct then progressPct.Text = _floor(stopProgress * 100) .. "%" end

            local phase2Timeout = math.max(2.99 - autoGrabStopTime - math.max(duration - autoGrabStopTime, 0), 0.05)
            local phase2Start = _tick()

            while isStealing and Steal.AutoStealEnabled do
                if _tick() - phase2Start >= phase2Timeout then
                    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                    if progressPct then progressPct.Text = "0%" end
                    data.ready = true
                    isStealing = false
                    task.wait()
                    local newPrompt, newName = findNearestPrompt()
                    if newPrompt then executeSteal(newPrompt, newName) end
                    return
                end
                if not prompt.Parent or not prompt.Parent.Parent then
                    isStealing = false
                    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                    if progressPct then progressPct.Text = "0%" end
                    data.ready = true
                    return
                end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - prompt.Parent.Parent.Position).Magnitude
                    if dist <= autoGrabSetDelayRadius then
                        break
                    elseif dist > Steal.StealRadius then
                        isStealing = false
                        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                        if progressPct then progressPct.Text = "0%" end
                        data.ready = true
                        return
                    end
                end
                task.wait()
            end

            if isStealing and Steal.AutoStealEnabled then
                local fillStart = _tick()
                local fillDuration = math.max(duration - autoGrabStopTime, 0.05)
                while true do
                    local fp = _clamp((_tick() - fillStart) / fillDuration, 0, 1)
                    local totalProgress = stopProgress + fp * (1 - stopProgress)
                    if progressFill then progressFill.Size = UDim2.new(totalProgress, 0, 1, 0) end
                    if progressPct then progressPct.Text = _floor(totalProgress * 100) .. "%" end
                    if fp >= 1 and not promptFired then
                        promptFired = true
                        pcall(function()
                            for _, f in ipairs(data.trigger) do task.spawn(f) end
                            local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                            if remote and podName then remote:FireServer(podName) end
                            if prompt then prompt:Fire() end
                        end)
                        break
                    end
                    task.wait()
                end
            end
        else
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = _tick() - startTime
                local progress = _clamp(elapsed / duration, 0, 1)
                if progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
                if progressPct then progressPct.Text = _floor(progress * 100) .. "%" end
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then break end
                if elapsed >= duration and not promptFired then
                    promptFired = true
                    pcall(function()
                        for _, f in ipairs(data.trigger) do task.spawn(f) end
                        local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                        if remote and podName then remote:FireServer(podName) end
                        if prompt then prompt:Fire() end
                    end)
                    break
                end
                task.wait()
            end
        end

        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
        if progressPct then progressPct.Text = "0%" end
        data.ready = true
        isStealing = false
    end)
end

function startAutoSteal()
    if stealConnection then
        local connected = false
        pcall(function() connected = stealConnection.Connected == true end)
        if connected then
            Steal.StealRadius = CONFIG.STEAL_RANGE
            Steal.AutoStealEnabled = true
            CONFIG.AUTO_STEAL_ENABLED = true
            return true
        end
        pcall(function() stealConnection:Disconnect() end)
        stealConnection = nil
    end
    Steal.StealRadius = CONFIG.STEAL_RANGE
    Steal.AutoStealEnabled = true
    CONFIG.AUTO_STEAL_ENABLED = true
    stealConnection = RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        local p, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
    return true
end

function stopAutoSteal()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
    isStealing = false
    Steal.AutoStealEnabled = false
    CONFIG.AUTO_STEAL_ENABLED = false
    if progressFill then
        TS:Create(progressFill, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 1, 0) }):Play()
    end
    if progressPct then progressPct.Text = "0%" end
end

medusaDebounce = false
medusaLastUsed = 0
dropActive = false
lastDropTime = 0
lastMoveDir = _V3new(0,0,0)
origFOV = nil
fovEnabled = false
fovValue = 70
customFovConn = nil
setFovVisual = nil
fovSliderSet = nil

_anyKeyListening = false
_aimbotConn = nil
_prevAutoRotate = nil
tpBatConn = nil
tpBatPrevAutoRotate = nil
tpBatHitCD = false
TP_BAT_SWING_CD = 0.08
tpBatFloatingButton = nil
batV2FloatingButton = nil

enemySpeedConn = nil
movementLoop = nil
steppedConn = nil
alConn = nil
arConn = nil
infJumpConn = nil
stretchConn = nil
stretchFovConn = nil
antiLagDescConn = nil
medusaResetConns = {}
dropConnections = {}
enemySpeedLabels = {}
Conns = {autoSteal = nil, batCounter = nil, anchor = {}, progress = nil, autoLeft = nil, autoRight = nil}
keyButtonRefs = {}
progressFill = nil
progressPct = nil
progressRadLbl = nil
pbFrame = nil
speedLabel = nil
modeValLbl = nil
normalBox, carryBox, laggerBox, lagger2Box, radInput, batSpeedBox, uiScaleBox = nil, nil, nil, nil, nil, nil, nil
modeSelectBtn, dropModeBtnRef = nil, nil
setJumpToggleState = nil
autoBatSetVisual, autoLeftSetVisual, autoRightSetVisual, setBatCounterVisual, setMedusaVisual = nil, nil, nil, nil, nil
setAntiRagVisual, setJumpVisual, setUnwalkVisual, setAntiLagVisual, setLockUIVisual, setInstaGrab = nil, nil, nil, nil, nil, nil
setAntiDieVisual = nil
setEditModeVisual = nil
setESPVIsual = nil
mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight, mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2 = nil, nil, nil, nil, nil, nil, nil, nil
autoBatV2SetVisual = nil
miniBtn, main, gui = nil, nil, nil
MobilePanel = nil
instaResetFloatingButton = nil
showGui = nil
hideGui = nil
mainUIScale = nil
animSelectorLabel = nil
pbScale = nil
tabButtons = nil
colorSelectorLabel = nil

carrySystemToggleSetter = nil
carrySysNormalBox = nil
carrySysCarryBox = nil
carrySysLaggerBox = nil
carrySysLaggerCarryBox = nil
carrySysSoftStealSpeedBox = nil
carrySysSoftStealRadiusBox = nil

GAMEPAD_KEYS = {
    [Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true,
    [Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true,
    [Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true,
    [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true,
    [Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true,
    [Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true,
    [Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true,
    [Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true,
}

MOVE_KEYS = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true,
    [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true,
}

BAT_COUNTER_SLAP_LIST = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"
}

AP = {
    L1 = _V3new(-476.48, -6.28, 92.73),
    L2 = _V3new(-483.12, -4.95, 94.80),
    L_FACE = _V3new(-482.25, -4.96, 92.09),
    R1 = _V3new(-476.16, -6.52, 25.62),
    R2 = _V3new(-483.06, -5.03, 25.48),
    R_FACE = _V3new(-482.06, -6.93, 35.47),
}

function isGamepadInput(inp)
    return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil
end

function isBindableInput(inp)
    if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
    if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
    return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
end

function kbMatch(entry, kc)
    return kc and (kc == entry.kb or (entry.gp and kc == entry.gp))
end

function resetProgressBar()
    if progressPct then progressPct.Text = "0%" end
    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function doTpDown()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        root.CFrame = _CFnew(root.Position.X, -7, root.Position.Z) * CFrame.Angles(0, select(2, root.CFrame:ToEulerAnglesYXZ()), 0)
        root.Velocity = _V3zero
    end)
end

local AntiRagdollV1 = {}
AntiRagdollV1.__index = AntiRagdollV1

local BOOST_SPEED = 400
local AR_DEFAULT_SPEED = 16

local stateV1 = {
    active = false,
    isBoosting = false,
    cachedChar = nil,
    ragdollConnections = {},
}

local function disconnectAllV1()
    for _, conn in ipairs(stateV1.ragdollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    stateV1.ragdollConnections = {}
end

local function cacheCharacterV1()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    stateV1.cachedChar = { character = char, humanoid = hum, root = root }
    return true
end

local function isRagdolledV1()
    if not stateV1.cachedChar or not stateV1.cachedChar.humanoid then return false end
    local hum = stateV1.cachedChar.humanoid
    local st = hum:GetState()
    local ragdollStates = {
        [Enum.HumanoidStateType.Physics] = true,
        [Enum.HumanoidStateType.Ragdoll] = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    return ragdollStates[st] or false
end

local function forceExitRagdollV1()
    if not stateV1.cachedChar or not stateV1.cachedChar.humanoid or not stateV1.cachedChar.root then return end
    local hum = stateV1.cachedChar.humanoid
    local root = stateV1.cachedChar.root
    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    for _, descendant in ipairs(stateV1.cachedChar.character:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint") or
           (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            descendant:Destroy()
        end
    end
    if not stateV1.isBoosting then
        stateV1.isBoosting = true
        hum.WalkSpeed = BOOST_SPEED
    end
    if hum.Health > 0 then
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    root.Anchored = false
end

local function heartbeatLoopV1()
    while stateV1.active do
        task.wait()
        if isRagdolledV1() then
            forceExitRagdollV1()
        elseif stateV1.isBoosting and not isRagdolledV1() then
            stateV1.isBoosting = false
            if stateV1.cachedChar and stateV1.cachedChar.humanoid then
                stateV1.cachedChar.humanoid.WalkSpeed = AR_DEFAULT_SPEED
            end
        end
    end
end

function AntiRagdollV1.start()
    if stateV1.active then return end
    AntiRagdollV1.stop()
    if not cacheCharacterV1() then
        warn("[AntiRagdollV1] No se pudo cachear el personaje")
        return
    end
    stateV1.active = true
    stateV1.isBoosting = false
    local camConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        if cam and stateV1.cachedChar and stateV1.cachedChar.humanoid then
            cam.CameraSubject = stateV1.cachedChar.humanoid
        end
    end)
    table.insert(stateV1.ragdollConnections, camConn)
    local respawnConn = LP.CharacterAdded:Connect(function()
        stateV1.isBoosting = false
        task.wait(0.5)
        cacheCharacterV1()
    end)
    table.insert(stateV1.ragdollConnections, respawnConn)
    task.spawn(heartbeatLoopV1)
    print("[AntiRagdollV1] Activado")
end

function AntiRagdollV1.stop()
    stateV1.active = false
    if stateV1.isBoosting and stateV1.cachedChar and stateV1.cachedChar.humanoid then
        stateV1.cachedChar.humanoid.WalkSpeed = AR_DEFAULT_SPEED
    end
    stateV1.isBoosting = false
    disconnectAllV1()
    stateV1.cachedChar = nil
    print("[AntiRagdollV1] Desactivado")
end

function AntiRagdollV1.isRunning() return stateV1.active end

local AntiRagdollV2 = {
    Enabled = false,
    Connection = nil,
    ResetCooldown = 0,
}

local function startAntiRagdollV2()
    if AntiRagdollV2.Connection then return end
    AntiRagdollV2.Enabled = true
    AntiRagdollV2.Connection = RunService.Heartbeat:Connect(function()
        if not AntiRagdollV2.Enabled then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return end
        local state = hum:GetState()
        local now = _tick()
        if state == Enum.HumanoidStateType.Physics or
           state == Enum.HumanoidStateType.Ragdoll or
           state == Enum.HumanoidStateType.FallingDown then
            if now - AntiRagdollV2.ResetCooldown > 0.15 then
                AntiRagdollV2.ResetCooldown = now
                pcall(function()
                    if hum:GetState() == Enum.HumanoidStateType.GettingUp then return end
                    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return end
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    root.Velocity = _V3zero
                    root.RotVelocity = _V3zero
                    root.AssemblyLinearVelocity = _V3zero
                    root.AssemblyAngularVelocity = _V3zero
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("Motor6D") then obj.Enabled = true end
                        if obj:IsA("Constraint") then obj.Enabled = true end
                    end
                    workspace.CurrentCamera.CameraSubject = hum
                    local PM = LP.PlayerScripts:FindFirstChild("PlayerModule")
                    if PM then
                        local CM = require(PM:FindFirstChild("ControlModule"))
                        if CM then CM:Enable() end
                    end
                    hum.AutoRotate = true
                    hum.PlatformStand = false
                    hum.Sit = false
                end)
            end
        end
    end)
end

local function stopAntiRagdollV2()
    AntiRagdollV2.Enabled = false
    if AntiRagdollV2.Connection then
        AntiRagdollV2.Connection:Disconnect()
        AntiRagdollV2.Connection = nil
    end
    AntiRagdollV2.ResetCooldown = 0
end

function setAntiRagdollMode(mode)
    if AntiRagdollV1.isRunning() then AntiRagdollV1.stop() end
    if AntiRagdollV2.Enabled then stopAntiRagdollV2() end
    antiRagdollMode = mode
    if mode == "v1" then AntiRagdollV1.start()
    elseif mode == "v2" then startAntiRagdollV2() end
    if _G.updateAntiRagdollUI then _G.updateAntiRagdollUI(mode) end
    saveAllSettings()
end

local AntiDieModule = {
    enabled = false,
    healthConn = nil,
    diedConn = nil,
    charConn = nil,
    humanoid = nil,
    _reviving = false,
}

local function disconnectHumanoid()
    if AntiDieModule.healthConn then AntiDieModule.healthConn:Disconnect(); AntiDieModule.healthConn = nil end
    if AntiDieModule.diedConn then AntiDieModule.diedConn:Disconnect(); AntiDieModule.diedConn = nil end
    AntiDieModule.humanoid = nil
end

local function activateOnCharacter(char)
    if not AntiDieModule.enabled then return end
    char = char or LP.Character or LP.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
    if not hum or not AntiDieModule.enabled then return end
    disconnectHumanoid()
    AntiDieModule.humanoid = hum

    pcall(function()
        hum.BreakJointsOnDeath = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dying, false)
    end)

    AntiDieModule.healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if not AntiDieModule.enabled or not hum.Parent then return end
        if hum.Health <= 0 and not AntiDieModule._reviving then
            AntiDieModule._reviving = true
            pcall(function()
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                if hum.Health > 0 then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
            task.delay(0.2, function() AntiDieModule._reviving = false end)
        end
    end)

    AntiDieModule.diedConn = hum.Died:Connect(function()
        if not AntiDieModule.enabled or not char.Parent then return end
        if AntiDieModule._reviving then return end
        AntiDieModule._reviving = true
        task.defer(function()
            if not AntiDieModule.enabled or not char.Parent or not hum.Parent then
                AntiDieModule._reviving = false
                return
            end
            pcall(function()
                hum.Health = hum.MaxHealth
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
            AntiDieModule._reviving = false
        end)
    end)
end

function AntiDieModule.start()
    AntiDieModule.enabled = true
    if AntiDieModule.charConn then AntiDieModule.charConn:Disconnect() end
    AntiDieModule.charConn = LP.CharacterAdded:Connect(function(char)
        if AntiDieModule.enabled then task.defer(function() activateOnCharacter(char) end) end
    end)
    task.defer(function() activateOnCharacter(LP.Character) end)
    print("[AntiDie] Activado (interno)")
end

function AntiDieModule.stop()
    AntiDieModule.enabled = false
    if AntiDieModule.charConn then AntiDieModule.charConn:Disconnect(); AntiDieModule.charConn = nil end
    local hum = AntiDieModule.humanoid
    disconnectHumanoid()
    if hum and hum.Parent then
        pcall(function()
            hum.BreakJointsOnDeath = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end)
    end
    print("[AntiDie] Desactivado (interno)")
end

_G.AntiDie = AntiDieModule

local AntiFlingShieldModule = {
    enabled = false,
    loop = nil,
    velocityThreshold = 80,
}

local function stabilizeRoot(root)
    if not root or not root.Parent then return end
    if batDesyncTpEnabled then return end
    local velocity
    local ok = pcall(function() velocity = root.AssemblyLinearVelocity end)
    if not ok or typeof(velocity) ~= "Vector3" then
        local legacyOk
        legacyOk, velocity = pcall(function() return root.Velocity end)
        if not legacyOk or typeof(velocity) ~= "Vector3" then return end
    end
    if velocity.Magnitude <= AntiFlingShieldModule.velocityThreshold then return end
    local stabilized = _V3new(0, velocity.Y, 0)
    pcall(function() root.AssemblyLinearVelocity = stabilized end)
    pcall(function() root.AssemblyAngularVelocity = _V3zero end)
    pcall(function() root.Velocity = stabilized end)
    pcall(function() root.RotVelocity = _V3zero end)
end

function AntiFlingShieldModule.start()
    AntiFlingShieldModule.enabled = true
    if AntiFlingShieldModule.loop then AntiFlingShieldModule.loop:Disconnect() end
    AntiFlingShieldModule.loop = RunService.Heartbeat:Connect(function()
        if not AntiFlingShieldModule.enabled then return end
        local char = LP.Character
        stabilizeRoot(char and char:FindFirstChild("HumanoidRootPart"))
    end)
    print("[AntiFlingShield] Activado (interno)")
end

function AntiFlingShieldModule.stop()
    AntiFlingShieldModule.enabled = false
    if AntiFlingShieldModule.loop then
        AntiFlingShieldModule.loop:Disconnect()
        AntiFlingShieldModule.loop = nil
    end
    print("[AntiFlingShield] Desactivado (interno)")
end

_G.AntiFlingShield = AntiFlingShieldModule

do
    local _ragCountdownRunning = false
    local function _getRagBillboard()
        local char = LP.Character
        if not char then return nil, nil end
        local head = char:FindFirstChild("Head")
        if not head then return nil, nil end
        local pGui = LP.PlayerGui
        local existing = pGui:FindFirstChild("RagCountdownBillboard")
        if existing then existing:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "RagCountdownBillboard"
        bb.Size = UDim2.new(0, 84, 0, 42)
        bb.StudsOffset = _V3new(0, 4.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = pGui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextScaled = true
        lbl.TextColor3 = selectedColor
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        lbl.TextStrokeTransparency = 0
        lbl.Text = ""
        lbl.Parent = bb
        local grad = Instance.new("UIGradient", lbl)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, selectedColor),
            ColorSequenceKeypoint.new(0.3, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.7, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, selectedColor),
        })
        grad.Rotation = 45
        grad.Offset = Vector2.new(0,0)
        return bb, lbl
    end

    local function _ragPunch(lbl, text)
        if not (lbl and lbl.Parent) then return end
        lbl.Text = text
    end

    local function _startRagCountdown()
        if _ragCountdownRunning then return end
        _ragCountdownRunning = true
        task.spawn(function()
            local bb, lbl = _getRagBillboard()
            if not bb then _ragCountdownRunning = false; return end
            local timeLeft = 2.5
            local step = 0.1
            while timeLeft > 0 and bb.Parent do
                _ragPunch(lbl, string.format("%.1f", timeLeft))
                task.wait(step)
                timeLeft = timeLeft - step
            end
            if bb and bb.Parent then
                _ragPunch(lbl, "READY!")
                task.wait(0.5)
                if bb and bb.Parent then bb:Destroy() end
            end
            _ragCountdownRunning = false
        end)
    end

    local _wasRagdolled = false
    RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then _wasRagdolled = false; return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then _wasRagdolled = false; return end
        local st = hum:GetState()
        local inRag = st == Enum.HumanoidStateType.Physics
                   or st == Enum.HumanoidStateType.Ragdoll
                   or st == Enum.HumanoidStateType.FallingDown
        if inRag and not _wasRagdolled then
            _wasRagdolled = true
            _startRagCountdown()
        elseif not inRag then
            _wasRagdolled = false
        end
    end)
end

local espHighlightCache = {}
local espBillboardCache = {}
local espTracerCache = {}
local espConn = nil
local _espLastRun = 0
profileImageCache = {}

local function clearESP()
    for plr in pairs(espHighlightCache) do
        pcall(function() espHighlightCache[plr]:Destroy() end)
    end
    for plr in pairs(espBillboardCache) do
        pcall(function() espBillboardCache[plr]:Destroy() end)
    end
    for plr in pairs(espTracerCache) do
        for _, ln in ipairs(espTracerCache[plr]) do
            pcall(function() ln.Visible = false; ln:Remove() end)
        end
    end
    espHighlightCache = {}
    espBillboardCache = {}
    espTracerCache = {}
end

local function makeESPTracers()
    if not (Drawing and type(Drawing.new) == "function") then return nil end
    local color = getThemeColor()
    local outer = Drawing.new("Line")
    outer.Color = color
    outer.Thickness = 2.2
    outer.Transparency = 0.90
    outer.Visible = false
    local mid = Drawing.new("Line")
    mid.Color = color
    mid.Thickness = 1.2
    mid.Transparency = 0.74
    mid.Visible = false
    local core = Drawing.new("Line")
    core.Color = color
    core.Thickness = 0.6
    core.Transparency = 0.10
    core.Visible = false
    return {outer, mid, core}
end

local function updateESP()
    local now = _tick()
    if now - _espLastRun < 0.05 then return end
    _espLastRun = now
    if not espEnabled then clearESP(); return end
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    local myScreenPos, myOnScreen = camera:WorldToViewportPoint(myPos)
    local myVec = Vector2.new(myScreenPos.X, myScreenPos.Y)
    local currentPlayers = _GetPlayersCached()
    local plrSet = {}
    for _, p in ipairs(currentPlayers) do plrSet[p] = true end
    for plr in pairs(espHighlightCache) do
        if not plrSet[plr] then
            pcall(function() espHighlightCache[plr]:Destroy() end)
            espHighlightCache[plr] = nil
        end
    end
    for plr in pairs(espBillboardCache) do
        if not plrSet[plr] then
            pcall(function() espBillboardCache[plr]:Destroy() end)
            espBillboardCache[plr] = nil
        end
    end
    for plr in pairs(espTracerCache) do
        if not plrSet[plr] then
            for _, ln in ipairs(espTracerCache[plr]) do
                pcall(function() ln.Visible = false; ln:Remove() end)
            end
            espTracerCache[plr] = nil
        end
    end
    local color = getThemeColor()
    for _, plr in ipairs(currentPlayers) do
        if plr == LP then continue end
        local char = plr.Character
        if not char then
            if espHighlightCache[plr] then
                pcall(function() espHighlightCache[plr]:Destroy() end)
                espHighlightCache[plr] = nil
            end
            if espBillboardCache[plr] then
                pcall(function() espBillboardCache[plr]:Destroy() end)
                espBillboardCache[plr] = nil
            end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do
                    pcall(function() ln.Visible = false end)
                end
            end
            continue
        end
        local tRoot = char:FindFirstChild("HumanoidRootPart")
        local tHead = char:FindFirstChild("Head")
        local tHum = char:FindFirstChildOfClass("Humanoid")
        local alive = tRoot and tHead and tHum and tHum.Health > 0
        if alive then
            local hl = espHighlightCache[plr]
            if not hl or not hl.Parent or hl.Parent ~= char then
                if hl then pcall(function() hl:Destroy() end) end
                hl = Instance.new("Highlight")
                hl.Name = "BloodHoundsESP"
                hl.FillColor = color
                hl.FillTransparency = 0.72
                hl.OutlineColor = color
                hl.OutlineTransparency = 0.05
                hl.Adornee = char
                hl.Parent = char
                espHighlightCache[plr] = hl
            end
            local bb = espBillboardCache[plr]
            if not bb or not bb.Parent then
                if bb then pcall(function() bb:Destroy() end) end
                bb = Instance.new("BillboardGui")
                bb.Name = "ProfilePic"
                bb.Size = UDim2.new(0, 56, 0, 56)
                bb.StudsOffset = _V3new(0, 3.8, 0)
                bb.Adornee = tHead
                bb.AlwaysOnTop = true
                bb.Parent = tHead
                local img = Instance.new("ImageLabel", bb)
                img.Size = UDim2.new(1, -6, 1, -6)
                img.Position = UDim2.new(0, 3, 0, 3)
                img.BackgroundTransparency = 1
                img.Image = "rbxassetid://0"
                img.ScaleType = Enum.ScaleType.Fit
                local circle = Instance.new("UICorner", img)
                circle.CornerRadius = UDim.new(1, 0)
                local stroke = Instance.new("UIStroke", img)
                stroke.Color = color
                stroke.Thickness = 1.5
                espBillboardCache[plr] = bb
                task.spawn(function()
                    local userId = plr.UserId
                    local url = profileImageCache[userId]
                    if not url then
                        local success, u = pcall(function()
                            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                        end)
                        if success and u and u ~= "" then
                            url = u
                            profileImageCache[userId] = url
                        else
                            url = "rbxassetid://0"
                        end
                    end
                    if img then img.Image = url end
                end)
            else
                if bb.Adornee ~= tHead then bb.Adornee = tHead end
                bb.Enabled = true
            end
            local lines = espTracerCache[plr]
            if not lines then
                lines = makeESPTracers()
                espTracerCache[plr] = lines or {}
            end
            if lines and #lines > 0 then
                local destPos = tRoot.Position
                local pos, onScreen = camera:WorldToViewportPoint(destPos)
                if onScreen and pos.Z > 0 and myOnScreen then
                    local tVec = Vector2.new(pos.X, pos.Y)
                    for _, ln in ipairs(lines) do
                        ln.From = myVec
                        ln.To = tVec
                        ln.Visible = true
                    end
                else
                    for _, ln in ipairs(lines) do ln.Visible = false end
                end
            end
        else
            if espHighlightCache[plr] then
                pcall(function() espHighlightCache[plr]:Destroy() end)
                espHighlightCache[plr] = nil
            end
            if espBillboardCache[plr] then
                pcall(function() espBillboardCache[plr]:Destroy() end)
                espBillboardCache[plr] = nil
            end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do
                    pcall(function() ln.Visible = false end)
                end
            end
        end
    end
end

local function startESPLoop()
    if espConn then espConn:Disconnect() end
    espConn = RunService.RenderStepped:Connect(updateESP)
end

local function stopESPLoop()
    if espConn then espConn:Disconnect(); espConn = nil end
    clearESP()
end

function toggleESP(on)
    espEnabled = on
    if on then startESPLoop() else stopESPLoop() end
    if setESPVIsual then setESPVIsual(on) end
end

local _enemySpeedAcc = 0
function updateEnemySpeedLabels()
    _enemySpeedAcc = _enemySpeedAcc + 1
    if _enemySpeedAcc < 6 then return end
    _enemySpeedAcc = 0

    local color = getThemeColor()
    local players = _GetPlayersCached()
    for i = 1, #players do
        local player = players[i]
        if player ~= LP then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local v = hrp.AssemblyLinearVelocity
                local speed = _sqrt(v.X*v.X + v.Z*v.Z)
                local label = enemySpeedLabels[player]
                if not label then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 100, 0, 25)
                        bb.StudsOffset = _V3new(0, 5.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Name = "EnemySpeedGui"
                        bb.Parent = head
                        local tl = Instance.new("TextLabel", bb)
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.BackgroundTransparency = 1
                        tl.TextColor3 = color
                        tl.Font = Enum.Font.GothamBold
                        tl.TextScaled = true
                        tl.TextStrokeTransparency = 0
                        tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        enemySpeedLabels[player] = tl
                        label = tl
                    end
                elseif label.Parent and label.Parent.Parent ~= char then
                    local head = char:FindFirstChild("Head")
                    if head then label.Parent.Parent = head end
                end
                if label then
                    label.Text = string.format("%.1f", speed)
                    if label.TextColor3 ~= color then label.TextColor3 = color end
                end
            else
                local label = enemySpeedLabels[player]
                if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
                enemySpeedLabels[player] = nil
            end
        end
    end
end

function startEnemySpeed()
    if enemySpeedConn then enemySpeedConn:Disconnect() end
    enemySpeedConn = RunService.Heartbeat:Connect(updateEnemySpeedLabels)
end

function stopEnemySpeed()
    if enemySpeedConn then enemySpeedConn:Disconnect(); enemySpeedConn = nil end
end

local function getClosestTargetBody()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local rpos = root.Position
    local closest, minDist = nil, _huge
    local plist = _GetPlayersCached()
    for i = 1, #plist do
        local plr = plist[i]
        if plr ~= LP then
            local c = plr.Character
            if c then
                local tRoot = c:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dx = tRoot.Position.X - rpos.X
                        local dy = tRoot.Position.Y - rpos.Y
                        local dz = tRoot.Position.Z - rpos.Z
                        local d = dx*dx + dy*dy + dz*dz
                        if d < minDist then minDist = d; closest = tRoot end
                    end
                end
            end
        end
    end
    return closest
end

local function _bodyLockTick()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local target = getClosestTargetBody()
    if not target then
        if not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    local dist = (target.Position - root.Position).Magnitude
    if dist > bodyLockRange then
        if not hum.AutoRotate then hum.AutoRotate = true end
        return
    end
    if hum.AutoRotate then hum.AutoRotate = false end
    local targetVel = target.AssemblyLinearVelocity
    local speed3 = targetVel.Magnitude
    local predictTime = _clamp(speed3 / 80, 0.08, 0.35)
    local predictedPos = target.Position + targetVel * predictTime
    local targetHead = target.Parent and target.Parent:FindFirstChild("Head")
    local targetHeight = targetHead and targetHead.Position.Y or target.Position.Y
    local myHeight = root.Position.Y + (hum.HipHeight or 0)
    local heightDiff = targetHeight - myHeight
    local verticalCorrection = _clamp(heightDiff * 0.15, -1.5, 1.5)
    local flatTarget = _V3new(predictedPos.X, root.Position.Y + verticalCorrection, predictedPos.Z)
    local toPredict = flatTarget - root.Position
    if toPredict.Magnitude > 0.1 then
        local goalCF = _CFlookAt(root.Position, flatTarget)
        local diffCF = root.CFrame:Inverse() * goalCF
        local _, ry, _ = diffCF:ToEulerAnglesXYZ()
        ry = _clamp(ry, -2.5, 2.5)
        root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(_V3new(0, ry * 42, 0))
    end
end

function startBodyLock()
    if _bodyLockConn then _bodyLockConn:Disconnect() end
    local acc = 0
    _bodyLockConn = RunService.Heartbeat:Connect(function(dt)
        if not bodyLockEnabled then return end
        if _blSuppressCount > 0 then return end
        acc = acc + dt
        if acc < 0.033 then return end
        acc = 0
        _bodyLockTick()
    end)
end

function stopBodyLock()
    if _bodyLockConn then
        _bodyLockConn:Disconnect()
        _bodyLockConn = nil
    end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyAngularVelocity = _V3zero
        root.AssemblyLinearVelocity = _V3new(root.AssemblyLinearVelocity.X, -0.1, root.AssemblyLinearVelocity.Z)
    end
    local hum2 = c and c:FindFirstChildOfClass("Humanoid")
    if hum2 then hum2.AutoRotate = true end
end

function _suppressBodyLock()
    _blSuppressCount = _blSuppressCount + 1
    if _blSuppressCount == 1 and bodyLockEnabled then
        _blWasEnabled = true
        stopBodyLock()
        if bodyLockSetVisual then bodyLockSetVisual(false) end
        if _blRestoreTimer then
            task.cancel(_blRestoreTimer)
            _blRestoreTimer = nil
        end
        _blSmoothRestore = false
    end
end

function _unsuppressBodyLock(delayed)
    if _blSuppressCount > 0 then
        _blSuppressCount = _blSuppressCount - 1
    end
    if _blSuppressCount == 0 and _blWasEnabled then
        _blWasEnabled = false
        if _blRestoreTimer then
            pcall(task.cancel, _blRestoreTimer)
            _blRestoreTimer = nil
        end
        local function restore()
            _blRestoreTimer = nil
            if bodyLockEnabled then
                _blSmoothRestore = true
                startBodyLock()
                if bodyLockSetVisual then bodyLockSetVisual(true) end
                task.delay(0.5, function() _blSmoothRestore = false end)
            end
        end
        if delayed then
            _blRestoreTimer = task.delay(1, restore)
        else
            restore()
        end
    end
end

function setupSpeedIndicator(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    local oldBB = head:FindFirstChild("BloodHoundsSpeedIndicator")
    if oldBB then oldBB:Destroy() end
    local bb = Instance.new("BillboardGui", head)
    bb.Name = "BloodHoundsSpeedIndicator"
    bb.Size = UDim2.new(0, 120, 0, 32)
    bb.StudsOffset = _V3new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    speedLabel = Instance.new("TextLabel", bb)
    speedLabel.Size = UDim2.new(1, 0, 1, 0)
    speedLabel.Position = UDim2.new(0, 0, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Spd: 0.0"
    speedLabel.TextColor3 = getThemeColor()
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextScaled = true
    speedLabel.TextStrokeTransparency = 0
    speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    applyShimmerToText(speedLabel, 0.9)
    local discordBB = head:FindFirstChild("DiscordText")
    if discordBB then discordBB:Destroy() end
    discordBB = Instance.new("BillboardGui", head)
    discordBB.Name = "DiscordText"
    discordBB.Size = UDim2.new(0, 200, 0, 28)
    discordBB.StudsOffset = _V3new(0, 5.2, 0)
    discordBB.AlwaysOnTop = true
    local discordLabel = Instance.new("TextLabel", discordBB)
    discordLabel.Size = UDim2.new(1, 0, 1, 0)
    discordLabel.BackgroundTransparency = 1
    discordLabel.Text = "discord.gg/cleanhub"
    discordLabel.TextColor3 = getThemeColor()
    discordLabel.Font = Enum.Font.GothamBold
    discordLabel.TextScaled = true
    discordLabel.TextStrokeTransparency = 0
    discordLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    applyShimmerToText(discordLabel, 0.9)
end

local unwalkSavedAnimate = nil

function startUnwalk()
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do pcall(function() t:Stop() end) end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        unwalkSavedAnimate = anim:Clone()
        anim:Destroy()
    end
end

function stopUnwalk()
    local c = LP.Character
    if c then
        local existing = c:FindFirstChild("Animate")
        if not existing then
            local src = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterCharacterScripts")
            local starterAnim = src and src:FindFirstChild("Animate")
            if starterAnim then
                starterAnim:Clone().Parent = c
            elseif unwalkSavedAnimate then
                unwalkSavedAnimate:Clone().Parent = c
            end
        end
    end
    unwalkSavedAnimate = nil
end

function refreshSpeedModeLabel()
    if modeValLbl then
        if laggerCarryToggled then modeValLbl.Text = "Lagger Carry"
        elseif laggerToggled then modeValLbl.Text = "Lagger"
        elseif speedMode then modeValLbl.Text = "Carry"
        else modeValLbl.Text = "Normal" end
    end
    if setCarryModeVisual then setCarryModeVisual(speedMode) end
    if setLaggerModeVisual then setLaggerModeVisual(laggerToggled) end
    if setLaggerCarryVisual then setLaggerCarryVisual(laggerCarryToggled) end
end

function resetMovementState()
    refreshSpeedModeLabel()
    if mobSetCarry then mobSetCarry(speedMode) end
    if setLaggerModeVisual then setLaggerModeVisual(laggerToggled) end
    if setLaggerCarryVisual then setLaggerCarryVisual(laggerCarryToggled) end
end

function toggleCarryMode()
    if laggerToggled or laggerCarryToggled then
        laggerToggled = false; laggerCarryToggled = false; speedMode = true
    else speedMode = not speedMode end
    resetMovementState()
end

function toggleLaggerMode()
    if laggerCarryToggled then laggerCarryToggled = false end
    speedMode = false; laggerToggled = not laggerToggled
    resetMovementState()
end
function toggleLaggerCarryMode()
    if laggerToggled then laggerToggled = false end
    speedMode = false; laggerCarryToggled = not laggerCarryToggled
    resetMovementState()
end

function toggleLaggerCycle()
    if speedMode then
        speedMode = false
        laggerToggled = true
        laggerCarryToggled = false
    elseif laggerToggled then
        speedMode = false
        laggerToggled = false
        laggerCarryToggled = true
    else
        speedMode = true
        laggerToggled = false
        laggerCarryToggled = false
    end
    resetMovementState()
end

function stopAutoLeft()
    if alConn then alConn:Disconnect(); alConn = nil end
    alPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(_V3zero, false) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobSetAutoLeft then mobSetAutoLeft(false) end
    _unsuppressBodyLock(true)
end

function startAutoLeft()
    if autoRightEnabled then
        autoRightEnabled = false
        stopAutoRight()
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
    end
    disableAllAimbots()
    _suppressBodyLock()
    if alConn then alConn:Disconnect() end
    alPhase = 1
    alConn = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if alPhase == 1 then
            local tgt = _V3new(AP.L1.X, root.Position.Y, AP.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP.L2 - root.Position
                local mv = _V3new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.L1 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = _V3new(AP.L2.X, root.Position.Y, AP.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(_V3zero, false)
                root.AssemblyLinearVelocity = _V3zero
                autoLeftEnabled = false
                if alConn then alConn:Disconnect(); alConn = nil end
                alPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if mobSetAutoLeft then mobSetAutoLeft(false) end
                _unsuppressBodyLock(true)
                local facePos = _V3new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = _CFnew(root.Position, facePos)
                end
                return
            end
            local d = AP.L2 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

function stopAutoRight()
    if arConn then arConn:Disconnect(); arConn = nil end
    arPhase = 1
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:Move(_V3zero, false) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobSetAutoRight then mobSetAutoRight(false) end
    _unsuppressBodyLock(true)
end

function startAutoRight()
    if autoLeftEnabled then
        autoLeftEnabled = false
        stopAutoLeft()
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
    end
    disableAllAimbots()
    _suppressBodyLock()
    if arConn then arConn:Disconnect() end
    arPhase = 1
    arConn = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if arPhase == 1 then
            local tgt = _V3new(AP.R1.X, root.Position.Y, AP.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP.R2 - root.Position
                local mv = _V3new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = AP.R1 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = _V3new(AP.R2.X, root.Position.Y, AP.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(_V3zero, false)
                root.AssemblyLinearVelocity = _V3zero
                autoRightEnabled = false
                if arConn then arConn:Disconnect(); arConn = nil end
                arPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if mobSetAutoRight then mobSetAutoRight(false) end
                _unsuppressBodyLock(true)
                local facePos = _V3new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then
                    root.CFrame = _CFnew(root.Position, facePos)
                end
                return
            end
            local d = AP.R2 - root.Position
            local mv = _V3new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            root.AssemblyLinearVelocity = _V3new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end

function getClosestTarget()
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local rpos = root.Position
    local closest, minDist = nil, _huge
    local plist = _GetPlayersCached()
    for i = 1, #plist do
        local plr = plist[i]
        if plr ~= LP then
            local c = plr.Character
            if c then
                local tRoot = c:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dx = tRoot.Position.X - rpos.X
                        local dy = tRoot.Position.Y - rpos.Y
                        local dz = tRoot.Position.Z - rpos.Z
                        local d = dx*dx + dy*dy + dz*dz
                        if d < minDist then minDist = d; closest = tRoot end
                    end
                end
            end
        end
    end
    return closest
end

function trySwing()
    pcall(function()
        local char = LP.Character
        if not char then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool and not isBatTool(currentTool) then return end
        local bat = findBat()
        if bat then
            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(bat) end) end
            end
            pcall(function() bat:Activate() end)
        end
    end)
end

function stopAimbotAdapt()
    if _aimbotConn then
        pcall(function() _aimbotConn:Disconnect() end)
        _aimbotConn = nil
    end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.AutoRotate = (_prevAutoRotate == nil) and true or _prevAutoRotate
        hum.PlatformStand = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    if root then
        root.AssemblyLinearVelocity = _V3new(0, -0.1, 0)
        root.AssemblyAngularVelocity = _V3zero
    end
    _prevAutoRotate = nil
    lastMoveDir = _V3zero
    _unsuppressBodyLock(true)
end

function startAimbotAdapt()
    if _aimbotConn then return end
    _suppressBodyLock()
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then
        if _prevAutoRotate == nil then _prevAutoRotate = hum0.AutoRotate end
        hum0.AutoRotate = false
    end
    _aimbotConn = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        local target = getClosestTarget()
        if not target then return end
        local targetVel = target.AssemblyLinearVelocity
        local myPos = root.Position
        local targetPos = target.Position
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = _V3new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = _V3new(0,0,0) end
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
        yVel = _clamp(yVel, -70, 110)
        local desiredVel = _V3new(flatDir.X * BAT_AIMBOT_SPEED, yVel, flatDir.Z * BAT_AIMBOT_SPEED)
        root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        local speed3 = targetVel.Magnitude
        local predictTime = _clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = _CFlookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = _clamp(rx, -2.5, 2.5)
            ry = _clamp(ry, -2.5, 2.5)
            rz = _clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(_V3new(rx * 42, ry * 42, rz * 42))
        end
        local distToTarget = (root.Position - target.Position).Magnitude
        if distToTarget <= 8 then trySwing() end
    end)
end

function disableAutoBat()
    autoBatEnabled = false
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobSetAutoBat then mobSetAutoBat(false) end
    stopAimbotAdapt()
end

function enableAutoBat()
    if autoLeftEnabled then
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(false) end
        stopAutoRight()
    end
    if batDesyncTpEnabled then toggleBatDesyncTp() end
    if autoBatV2Enabled then disableBatV2() end
    autoBatEnabled = true
    if autoBatSetVisual then autoBatSetVisual(true) end
    if mobSetAutoBat then mobSetAutoBat(true) end
    startAimbotAdapt()
end

local function findAnyToolV2()
    local c = LP.Character
    if c then
        for _, v in ipairs(c:GetChildren()) do
            if v:IsA("Tool") then return v end
        end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") then return v end
        end
    end
    return nil
end

local function getClosestPlayerV2()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, _huge end
    local hpos = hrp.Position
    local closest, bestDist = nil, _huge
    local plist = _GetPlayersCached()
    for i = 1, #plist do
        local p = plist[i]
        if p ~= LP then
            local c = p.Character
            if c then
                local tr = c:FindFirstChild("HumanoidRootPart")
                local ph = c:FindFirstChildOfClass("Humanoid")
                if tr and ph and ph.Health > 0 then
                    local dx = hpos.X - tr.Position.X
                    local dy = hpos.Y - tr.Position.Y
                    local dz = hpos.Z - tr.Position.Z
                    local d = _sqrt(dx*dx + dy*dy + dz*dz)
                    if d < bestDist then bestDist = d; closest = p end
                end
            end
        end
    end
    return closest, bestDist
end

local function tryHitBatV2()
    if autoBatV2HitCooldown or not autoBatV2SwingEnabled then return end
    autoBatV2HitCooldown = true
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local tool = findAnyToolV2()
        if tool then
            if tool.Parent ~= char and hum then
                pcall(function() hum:EquipTool(tool) end)
            end
            local remote = tool:FindFirstChildOfClass("RemoteEvent")
            if remote then
                pcall(function() remote:FireServer() end)
            else
                pcall(function() tool:Activate() end)
            end
        end
    end
    task.delay(AUTO_BAT_V2_SWING_CD, function()
        autoBatV2HitCooldown = false
    end)
end

local function startBatV2Aimbot()
    if _batV2Conn then return end
    _batV2Conn = RunService.Heartbeat:Connect(function()
        if not autoBatV2Enabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local target, dist = getClosestPlayerV2()
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local targetVel = targetRoot.AssemblyLinearVelocity or targetRoot.Velocity
                local moveDir = targetVel.Magnitude > 0.1 and targetVel.Unit or targetRoot.CFrame.LookVector
                local offset = moveDir * AUTO_BAT_V2_DIST + _V3new(0, AUTO_BAT_V2_HEIGHT + AUTO_BAT_V2_V_OFF, 0)
                local desiredPos = targetRoot.Position + offset
                local toTarget = desiredPos - root.Position
                if toTarget.Magnitude > 0.5 then
                    local moveVec = toTarget.Unit * AUTO_BAT_V2_SPEED
                    root.AssemblyLinearVelocity = _V3new(moveVec.X, moveVec.Y, moveVec.Z)
                else
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.95
                    if root.AssemblyLinearVelocity.Magnitude < 1 then
                        root.AssemblyLinearVelocity = _V3zero
                    end
                end
                local distToTarget = (root.Position - targetRoot.Position).Magnitude
                if distToTarget <= AUTO_BAT_V2_HIT_DIST then
                    tryHitBatV2()
                end
            end
        else
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.9
            if root.AssemblyLinearVelocity.Magnitude < 1 then
                root.AssemblyLinearVelocity = _V3zero
            end
        end
    end)
end

local function stopBatV2Aimbot()
    if _batV2Conn then
        _batV2Conn:Disconnect()
        _batV2Conn = nil
    end
    local c = LP.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = _V3zero
    end
    autoBatV2HitCooldown = false
end

function enableBatV2()
    if autoBatV2Enabled then return end
    if autoBatEnabled then disableAutoBat() end
    if batDesyncTpEnabled then toggleBatDesyncTp() end
    if autoLeftEnabled then
        autoLeftEnabled = false
        stopAutoLeft()
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
    end
    if autoRightEnabled then
        autoRightEnabled = false
        stopAutoRight()
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
    end
    autoBatV2Enabled = true
    startBatV2Aimbot()
    if autoBatV2SetVisual then autoBatV2SetVisual(true) end
    if batV2FloatingButton then
        local btnFrame = batV2FloatingButton:FindFirstChild("Frame")
        if btnFrame then paintFloatingBtn(btnFrame, true) end
    end
end

function disableBatV2()
    if not autoBatV2Enabled then return end
    autoBatV2Enabled = false
    stopBatV2Aimbot()
    if autoBatV2SetVisual then autoBatV2SetVisual(false) end
    if batV2FloatingButton then
        local btnFrame = batV2FloatingButton:FindFirstChild("Frame")
        if btnFrame then paintFloatingBtn(btnFrame, false) end
    end
end

function toggleBatV2()
    if autoBatV2Enabled then disableBatV2()
    else enableBatV2() end
end

local function updateTpBatButtonWithAntiDie(state)
    if tpBatFloatingButton then
        local btnFrame = tpBatFloatingButton:FindFirstChild("Frame")
        if btnFrame then
            local label = btnFrame:FindFirstChild("TextLabel")
            local stroke = btnFrame:FindFirstChildOfClass("UIStroke")
            if state then
                btnFrame.BackgroundColor3 = getThemeColor()
                if label then
                    label.Text = "TP\nBAT"
                    label.TextColor3 = Color3.fromRGB(0,0,0)
                end
                if stroke then
                    stroke.Color = Color3.fromRGB(255, 215, 0)
                    stroke.Thickness = 2.5
                end
            else
                if label then label.Text = "TP\nBAT" end
                paintFloatingBtn(btnFrame, batDesyncTpEnabled)
            end
        end
    end
end

local batDesyncTpEnabled = false
local batDesyncTpConn = nil
local batDesyncTpSetVisual = nil
local hittingCooldownDesync = false
local _tpBatUnwalkForced = false

-- ============================================================
-- TP BAT DESYNC — lógica interna (MACHO style)
-- ============================================================
local function getBatDesync()
    local char = LP.Character
    if not char then return nil end
    local tool = char:FindFirstChild("Bat")
    if tool then return tool end
    local bp2 = LP:FindFirstChild("Backpack")
    if bp2 then
        tool = bp2:FindFirstChild("Bat")
        if tool then
            tool.Parent = char
            return tool
        end
    end
    return nil
end

local function tryHitBatDesync()
    if hittingCooldownDesync then return end
    hittingCooldownDesync = true
    pcall(function()
        local bat = getBatDesync()
        if bat then
            bat:Activate()
            local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
        end
    end)
    task.delay(0.08, function() hittingCooldownDesync = false end)
end

local function getClosestPlayerDesync()
    local char = LP.Character
    if not char then return nil, _huge end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, _huge end
    local hpos = hrp.Position
    local cp, cd = nil, _huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local d = (hpos - tr.Position).Magnitude
                if d < cd then cd = d; cp = p end
            end
        end
    end
    return cp, cd
end

local function batDesyncTpUpdate()
    if not batDesyncTpEnabled then
        stopBatDesyncTp()
        return
    end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local target = getClosestPlayerDesync()
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            if sethiddenproperty then
                pcall(function()
                    sethiddenproperty(hrp, "PhysicsRepRootPart", tr)
                end)
            end

            local targetPos = tr.Position + _V3new(0, 0.9, 0)
            if (hrp.Position - targetPos).Magnitude > 8 then
                hrp.CFrame = _CFnew(targetPos)
            end

            local cam = workspace.CurrentCamera
            if cam then
                cam.CFrame = _CFnew(cam.CFrame.Position, tr.Position)
            end

            tryHitBatDesync()
        end
    end
end

function startBatDesyncTp()
    if batDesyncTpConn then return end
    if not unwalkEnabled then
        startUnwalk()
        unwalkEnabled = true
        _tpBatUnwalkForced = true
        if setUnwalkVisual then setUnwalkVisual(true) end
    end
    batDesyncTpEnabled = true
    batDesyncTpConn = RunService.Heartbeat:Connect(batDesyncTpUpdate)
    if batDesyncTpSetVisual then batDesyncTpSetVisual(true) end
    updateTpBatButtonWithAntiDie(true)
end

function stopBatDesyncTp()
    if batDesyncTpConn then
        batDesyncTpConn:Disconnect()
        batDesyncTpConn = nil
    end
    batDesyncTpEnabled = false
    if _tpBatUnwalkForced then
        stopUnwalk()
        unwalkEnabled = false
        _tpBatUnwalkForced = false
        if setUnwalkVisual then setUnwalkVisual(false) end
    end
    if batDesyncTpSetVisual then batDesyncTpSetVisual(false) end
    updateTpBatButtonWithAntiDie(false)
end

function toggleBatDesyncTp()
    if batDesyncTpEnabled then
        stopBatDesyncTp()
        updateTpBatButtonWithAntiDie(false)
    else
        disableAllAimbots()
        if autoLeftEnabled then
            autoLeftEnabled = false; stopAutoLeft()
            if autoLeftSetVisual then autoLeftSetVisual(false) end
            if mobSetAutoLeft then mobSetAutoLeft(false) end
        end
        if autoRightEnabled then
            autoRightEnabled = false; stopAutoRight()
            if autoRightSetVisual then autoRightSetVisual(false) end
            if mobSetAutoRight then mobSetAutoRight(false) end
        end
        startBatDesyncTp()
        updateTpBatButtonWithAntiDie(true)
    end
    if batDesyncTpSetVisual then batDesyncTpSetVisual(batDesyncTpEnabled) end
    saveAllSettings()
end

function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = char:FindFirstChild(name)
        if t and t:IsA("Tool") then return t end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
            local t = bp:FindFirstChild(name)
            if t and t:IsA("Tool") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(t) end) end
                return t
            end
        end
    end
    for _, ch in ipairs(char:GetChildren()) do
        if ch:IsA("Tool") and (c
Preview truncated for large file
