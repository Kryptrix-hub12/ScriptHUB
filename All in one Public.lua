--// =========================================================
--// BLACAN INSTAGRAB - COMBINED
--// Next Base + Podium ESP + Projected Floors
--// X-Ray + Anti-Lag + Hold Infinite Jump + Auto Steal
--// =========================================================

if _G.__BlacanInstagrabCleanup then
	pcall(_G.__BlacanInstagrabCleanup)
end

--// =========================================================
--// SERVICES
--// =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end

local Plots = Workspace:WaitForChild("Plots")
local Map = Workspace:WaitForChild("Map")

local hui = (gethui and gethui()) or CoreGui

--// =========================================================
--// CLEANUP STORAGE
--// =========================================================

local connections = {}
local destroyedObjects = {}

local function addConnection(connection)
	if connection then
		connections[#connections + 1] = connection
	end
	return connection
end

local function disconnectAll()
	for _, connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(connections)
end

local function destroyObject(object)
	if object then
		pcall(function()
			object:Destroy()
		end)
	end
end

--// =========================================================
--// SPLASH SCREEN
--// =========================================================

task.spawn(function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BlacanSplash"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = CoreGui

	destroyedObjects[#destroyedObjects + 1] = screenGui

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BorderSizePixel = 0
	background.ZIndex = 999
	background.Parent = screenGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.4, 0)
	title.Position = UDim2.fromScale(0, 0.20)
	title.BackgroundTransparency = 1
	title.Text = "BLACAN INSTAGRAB"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.ZIndex = 1000
	title.Parent = background

	local glow = Instance.new("UIStroke")
	glow.Thickness = 3
	glow.Transparency = 0.3
	glow.Color = Color3.new(1, 1, 1)
	glow.Parent = title

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, 0, 0.12, 0)
	subtitle.Position = UDim2.fromScale(0, 0.65)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "BY WINO AND SOCIOXX"
	subtitle.TextColor3 = Color3.new(1, 1, 1)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextScaled = true
	subtitle.ZIndex = 1000
	subtitle.Parent = background

	local discord = Instance.new("TextLabel")
	discord.Size = UDim2.new(1, 0, 0.08, 0)
	discord.Position = UDim2.fromScale(0, 0.78)
	discord.BackgroundTransparency = 1
	discord.Text = "https://discord.gg/blacanscripts"
	discord.TextColor3 = Color3.new(1, 1, 1)
	discord.Font = Enum.Font.GothamBold
	discord.TextScaled = true
	discord.ZIndex = 1000
	discord.Parent = background

	task.wait(2)

	if not screenGui.Parent then
		return
	end

	local tween = TweenService:Create(
		background,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear),
		{BackgroundTransparency = 1}
	)

	tween:Play()
	tween.Completed:Wait()

	destroyObject(screenGui)
end)

--// =========================================================
--// ANTI-LAG
--// =========================================================

local function applyAntiLag(instance)
	if instance:IsA("ParticleEmitter") then
		instance.Enabled = false

	elseif instance:IsA("Decal") then
		instance.Transparency = 1

	elseif instance:IsA("BasePart") then
		instance.Material = Enum.Material.Plastic
		instance.Reflectance = 0
		instance.CastShadow = false
	end
end

local function enableAntiLag()
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.Brightness = 1
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	for _, object in ipairs(Lighting:GetChildren()) do
		if object:IsA("BloomEffect")
			or object:IsA("BlurEffect")
			or object:IsA("SunRaysEffect") then

			object.Enabled = false
		end
	end

	for _, object in ipairs(Workspace:GetDescendants()) do
		applyAntiLag(object)
	end

	addConnection(
		Workspace.DescendantAdded:Connect(function(object)
			task.defer(applyAntiLag, object)
		end)
	)
end

enableAntiLag()

--// =========================================================
--// HOLD INFINITE JUMP
--// =========================================================

local INFINITE_JUMP_POWER = 55
local FALL_LIMIT = -120

addConnection(
	UserInputService.JumpRequest:Connect(function()
		local character = LocalPlayer.Character
		if not character then
			return
		end

		local root = character:FindFirstChild("HumanoidRootPart")
		if root then
			root.Velocity = Vector3.new(
				root.Velocity.X,
				INFINITE_JUMP_POWER,
				root.Velocity.Z
			)
		end
	end)
)

addConnection(
	RunService.Heartbeat:Connect(function()
		local character = LocalPlayer.Character
		if not character then
			return
		end

		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		local jumpHeld =
			UserInputService:IsKeyDown(Enum.KeyCode.Space)
			or (humanoid and humanoid.Jump == true)

		if jumpHeld and root.Velocity.Y < 30 then
			root.Velocity = Vector3.new(
				root.Velocity.X,
				INFINITE_JUMP_POWER,
				root.Velocity.Z
			)
		end

		if root.Velocity.Y < FALL_LIMIT then
			root.Velocity = Vector3.new(
				root.Velocity.X,
				FALL_LIMIT,
				root.Velocity.Z
			)
		end
	end)
)

--// =========================================================
--// X-RAY
--// =========================================================

local XRAY_TRANSPARENCY = 0.8
local xraySpoofed = {}
local xrayHookInstalled = false

local function shouldXray(object)
	if not object:IsA("BasePart") then
		return false
	end

	local name = object.Name:lower()
	local parentName =
		object.Parent and object.Parent.Name:lower() or ""

	return
		name:find("base")
		or name:find("claim")
		or parentName:find("base")
		or parentName:find("claim")
end

local function installXrayHook()
	if xrayHookInstalled then
		return
	end

	if not (hookmetamethod and checkcaller) then
		return
	end

	xrayHookInstalled = true

	local oldIndex

	oldIndex = hookmetamethod(game, "__index", function(self, key)
		if not checkcaller()
			and typeof(self) == "Instance"
			and self:IsA("BasePart")
			and key == "LocalTransparencyModifier"
			and xraySpoofed[self] ~= nil then

			return xraySpoofed[self]
		end

		return oldIndex(self, key)
	end)
end

local function applyXray(object)
	if not shouldXray(object) then
		return
	end

	xraySpoofed[object] = 0

	pcall(function()
		object.LocalTransparencyModifier = XRAY_TRANSPARENCY
	end)
end

local function enableXray()
	installXrayHook()

	for _, object in ipairs(Workspace:GetDescendants()) do
		applyXray(object)
	end

	addConnection(
		Workspace.DescendantAdded:Connect(function(object)
			task.defer(applyXray, object)
		end)
	)

	pcall(function()
		LocalPlayer.DevEnableMouseLock = true
		LocalPlayer.DevCameraOcclusionMode =
			Enum.DevCameraOcclusionMode.Invisicam
	end)
end

enableXray()

addConnection(
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)

		for _, object in ipairs(Workspace:GetDescendants()) do
			applyXray(object)
		end
	end)
)

--// =========================================================
--// NEXT EMPTY BASE
--// =========================================================

local BASE_POSITIONS = {
	Vector3.new(-342.439, 10.399, 113.107),
	Vector3.new(-342.439, 10.465, 6.107),
	Vector3.new(-476.752, 10.465, 114.107),
	Vector3.new(-476.752, 10.465, 7.107),
	Vector3.new(-342.440, 10.464, 220.107),
	Vector3.new(-476.752, 10.465, 221.107),
	Vector3.new(-342.439, 10.465, -100.893),
	Vector3.new(-476.752, 10.465, -99.893),
}

local BASE_MATCH_TOLERANCE = 6
local EMPTY_BASE_TEXT = "Empty Base"
local ARROW_ICON = utf8.char(0x2B07)

local bases = {}
local connectedLabels = {}

local anchorPart = Instance.new("Part")
anchorPart.Name = "__BlacanNextBaseAnchor"
anchorPart.Anchored = true
anchorPart.CanCollide = false
anchorPart.CanQuery = false
anchorPart.CanTouch = false
anchorPart.Transparency = 1
anchorPart.Size = Vector3.new(1, 1, 1)
anchorPart.Parent = CoreGui

destroyedObjects[#destroyedObjects + 1] = anchorPart

local billboard = Instance.new("BillboardGui")
billboard.Name = "NextBaseBillboard"
billboard.Adornee = anchorPart
billboard.Size = UDim2.fromScale(32, 13)
billboard.StudsOffset = Vector3.new(0, 10, 0)
billboard.MaxDistance = math.huge
billboard.AlwaysOnTop = true
billboard.LightInfluence = 0
billboard.Enabled = false
billboard.Parent = anchorPart

local topLabel = Instance.new("TextLabel")
topLabel.BackgroundTransparency = 1
topLabel.AnchorPoint = Vector2.new(0.5, 0.5)
topLabel.Position = UDim2.fromScale(0.5, 0.30)
topLabel.Size = UDim2.fromScale(0.95, 0.50)
topLabel.Font = Enum.Font.GothamBlack
topLabel.Text = ARROW_ICON .. "  NEXT  " .. ARROW_ICON
topLabel.TextScaled = true
topLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
topLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
topLabel.TextStrokeTransparency = 0
topLabel.Parent = billboard

local bottomLabel = Instance.new("TextLabel")
bottomLabel.BackgroundTransparency = 1
bottomLabel.AnchorPoint = Vector2.new(0.5, 0.5)
bottomLabel.Position = UDim2.fromScale(0.5, 0.72)
bottomLabel.Size = UDim2.fromScale(0.95, 0.42)
bottomLabel.Font = Enum.Font.GothamBlack
bottomLabel.Text = "EMPTY BASE"
bottomLabel.TextScaled = true
bottomLabel.TextColor3 = Color3.new(1, 1, 1)
bottomLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
bottomLabel.TextStrokeTransparency = 0
bottomLabel.Parent = billboard

local function getBaseIndex(model)
	local success, cf = pcall(function()
		return model:GetBoundingBox()
	end)

	if not success or not cf then
		return nil
	end

	local position = cf.Position
	local bestIndex
	local bestDistance

	for index, basePosition in ipairs(BASE_POSITIONS) do
		local dx = position.X - basePosition.X
		local dz = position.Z - basePosition.Z
		local distance = math.sqrt(dx * dx + dz * dz)

		if not bestDistance or distance < bestDistance then
			bestIndex = index
			bestDistance = distance
		end
	end

	if bestDistance and bestDistance <= BASE_MATCH_TOLERANCE then
		return bestIndex
	end

	return nil
end

local function isBaseEmpty(label)
	return
		label.Text:gsub("^%s+", ""):gsub("%s+$", "")
		== EMPTY_BASE_TEXT
end

local function updateNextBase()
	local targetIndex

	for index = 1, #BASE_POSITIONS do
		local base = bases[index]

		if base
			and base.label
			and base.label.Parent
			and isBaseEmpty(base.label) then

			targetIndex = index
			break
		end
	end

	if targetIndex then
		anchorPart.CFrame = bases[targetIndex].cf
		billboard.Enabled = true
	else
		billboard.Enabled = false
	end
end

local function connectBaseLabel(label)
	if connectedLabels[label] then
		return
	end

	connectedLabels[label] = true

	addConnection(
		label:GetPropertyChangedSignal("Text"):Connect(updateNextBase)
	)
end

local function scanPlots()
	for _, plot in ipairs(Plots:GetChildren()) do
		local sign = plot:FindFirstChild("PlotSign")
		local model = sign and sign:FindFirstChild("Model")
		local gui = sign and sign:FindFirstChild("SurfaceGui")
		local frame = gui and gui:FindFirstChild("Frame")
		local label = frame and frame:FindFirstChild("TextLabel")

		if model and label then
			local index = getBaseIndex(model)

			if index then
				local success, cf = pcall(function()
					return model:GetBoundingBox()
				end)

				if success then
					bases[index] = {
						label = label,
						cf = cf
					}

					connectBaseLabel(label)
				end
			end
		end
	end

	updateNextBase()
end

scanPlots()

addConnection(
	Plots.DescendantAdded:Connect(function(object)
		if object:IsA("TextLabel") then
			task.defer(scanPlots)
		end
	end)
)

addConnection(
	Plots.ChildAdded:Connect(function()
		task.defer(scanPlots)
	end)
)

--// =========================================================
--// PODIUM MARKERS
--// =========================================================

local MARKER_COLOR = Color3.fromRGB(175, 95, 255)

local FLOOR_TOLERANCE = 8
local SLOT_HORIZONTAL_TOLERANCE = 1.5
local SLOT_VERTICAL_TOLERANCE = 2

local FLOOR_COUNT = 3
local FALLBACK_FLOOR_SPACING = 18
local THIRD_FLOOR_DROP = 0.5
local COLLISION_THICKNESS = 0.5

local markerHolder =
	Map:FindFirstChild("__BlacanPodiumMarkers")

if markerHolder then
	markerHolder:Destroy()
end

markerHolder = Instance.new("Folder")
markerHolder.Name = "__BlacanPodiumMarkers"
markerHolder.Parent = Map

destroyedObjects[#destroyedObjects + 1] = markerHolder

local cachedFloorSpacing

local function getBaseBounds(slot)
	local target =
		slot:FindFirstChild("Base", true)
		or slot

	if target:IsA("Model") then
		local success, cf, size = pcall(function()
			return target:GetBoundingBox()
		end)

		if success then
			return cf, size
		end

	elseif target:IsA("BasePart") then
		return target.CFrame, target.Size
	end

	return nil, nil
end

local function makeCollisionMarker(cf, size, projected)
	local marker = Instance.new("Part")

	marker.Name =
		projected
		and "ProjectedPodiumMarker"
		or "ExistingPodiumMarker"

	marker.Anchored = true
	marker.CanCollide = false
	marker.CanQuery = false
	marker.CanTouch = false
	marker.CastShadow = false
	marker.Transparency = 1
	marker.Size = size
	marker.CFrame = cf
	marker.Parent = markerHolder

	local selection = Instance.new("SelectionBox")
	selection.Name = "PodiumESP"
	selection.Adornee = marker
	selection.Color3 = MARKER_COLOR
	selection.SurfaceColor3 = MARKER_COLOR
	selection.LineThickness = 0.06
	selection.Transparency = 0
	selection.SurfaceTransparency = 0.82
	selection.Parent = marker

	local collision = Instance.new("Part")

	collision.Name =
		projected
		and "ProjectedPodiumCollision"
		or "ExistingPodiumCollision"

	collision.Anchored = true
	collision.CanCollide = true
	collision.CanQuery = true
	collision.CanTouch = false
	collision.CastShadow = false
	collision.Transparency = 1

	collision.Size = Vector3.new(
		size.X,
		COLLISION_THICKNESS,
		size.Z
	)

	collision.CFrame =
		cf
		* CFrame.new(
			0,
			-(size.Y - COLLISION_THICKNESS) / 2,
			0
		)

	collision.Parent = markerHolder
end

local function addFloorLevel(levels, y)
	for _, level in ipairs(levels) do
		if math.abs(level.y - y) <= FLOOR_TOLERANCE then
			level.count += 1
			level.y += (y - level.y) / level.count
			return
		end
	end

	levels[#levels + 1] = {
		y = y,
		count = 1
	}
end

local function getPlotLevels(podiums)
	local levels = {}

	for _, slot in ipairs(podiums:GetChildren()) do
		local cf = getBaseBounds(slot)

		if cf then
			addFloorLevel(levels, cf.Position.Y)
		end
	end

	table.sort(levels, function(a, b)
		return a.y < b.y
	end)

	return levels
end

local function detectFloorSpacing()
	local bestSpacing
	local bestConfidence = 0

	for _, plot in ipairs(Plots:GetChildren()) do
		local podiums = plot:FindFirstChild("AnimalPodiums")

		if podiums then
			local levels = getPlotLevels(podiums)

			if #levels >= 2 then
				local spacing =
					levels[2].y - levels[1].y

				if spacing > FLOOR_TOLERANCE then
					local confidence =
						levels[1].count
						+ levels[2].count

					if confidence > bestConfidence then
						bestConfidence = confidence
						bestSpacing = spacing
					end
				end
			end
		end
	end

	if bestSpacing then
		cachedFloorSpacing = bestSpacing
		return bestSpacing
	end

	return cachedFloorSpacing or FALLBACK_FLOOR_SPACING
end

local function sameSlotPosition(a, b)
	local horizontal =
		Vector2.new(
			a.X - b.X,
			a.Z - b.Z
		).Magnitude

	local vertical =
		math.abs(a.Y - b.Y)

	return
		horizontal <= SLOT_HORIZONTAL_TOLERANCE
		and vertical <= SLOT_VERTICAL_TOLERANCE
end

local function positionExists(position, occupied)
	for _, existing in ipairs(occupied) do
		if sameSlotPosition(position, existing) then
			return true
		end
	end

	return false
end

local function getProjectedCFrame(baseCF, floorNumber, spacing)
	local offset = spacing * (floorNumber - 1)

	if floorNumber == 3 then
		offset -= THIRD_FLOOR_DROP
	end

	return baseCF + Vector3.new(0, offset, 0)
end

local function buildPlotMarkers(plot, defaultSpacing)
	local podiums = plot:FindFirstChild("AnimalPodiums")

	if not podiums then
		return
	end

	local levels = getPlotLevels(podiums)

	if #levels == 0 then
		return
	end

	local spacing = defaultSpacing

	if #levels >= 2 then
		local measured =
			levels[2].y - levels[1].y

		if measured > FLOOR_TOLERANCE then
			spacing = measured
		end
	end

	local lowestY = levels[1].y

	local slots = {}
	local occupied = {}

	for _, slot in ipairs(podiums:GetChildren()) do
		local cf, size = getBaseBounds(slot)

		if cf and size then
			slots[#slots + 1] = {
				cf = cf,
				size = size
			}

			occupied[#occupied + 1] = cf.Position
		end
	end

	for _, slot in ipairs(slots) do
		makeCollisionMarker(
			slot.cf,
			slot.size,
			false
		)
	end

	for _, slot in ipairs(slots) do
		local lowest =
			math.abs(
				slot.cf.Position.Y - lowestY
			) <= FLOOR_TOLERANCE

		if lowest then
			for floor = 2, FLOOR_COUNT do
				local projected =
					getProjectedCFrame(
						slot.cf,
						floor,
						spacing
					)

				if not positionExists(
					projected.Position,
					occupied
				) then

					makeCollisionMarker(
						projected,
						slot.size,
						true
					)

					occupied[#occupied + 1] =
						projected.Position
				end
			end
		end
	end
end

local markerRebuildPending = false

local function rebuildMarkers()
	if markerRebuildPending then
		return
	end

	markerRebuildPending = true

	task.delay(0.35, function()
		markerRebuildPending = false

		if not markerHolder.Parent then
			return
		end

		markerHolder:ClearAllChildren()

		local spacing =
			detectFloorSpacing()

		for _, plot in ipairs(Plots:GetChildren()) do
			buildPlotMarkers(
				plot,
				spacing
			)
		end
	end)
end

local watchedPodiums = {}

local function watchPlot(plot)
	local podiums =
		plot:WaitForChild(
			"AnimalPodiums",
			20
		)

	if not podiums or watchedPodiums[podiums] then
		return
	end

	watchedPodiums[podiums] = true

	addConnection(
		podiums.ChildAdded:Connect(rebuildMarkers)
	)

	addConnection(
		podiums.ChildRemoved:Connect(rebuildMarkers)
	)

	addConnection(
		podiums.DescendantAdded:Connect(rebuildMarkers)
	)

	addConnection(
		podiums.DescendantRemoving:Connect(rebuildMarkers)
	)

	addConnection(
		podiums.AncestryChanged:Connect(function()
			if not podiums:IsDescendantOf(Plots) then
				watchedPodiums[podiums] = nil
			end
		end)
	)

	rebuildMarkers()
end

for _, plot in ipairs(Plots:GetChildren()) do
	task.spawn(watchPlot, plot)
end

addConnection(
	Plots.ChildAdded:Connect(function(plot)
		task.spawn(watchPlot, plot)
		rebuildMarkers()
	end)
)

addConnection(
	Plots.ChildRemoved:Connect(rebuildMarkers)
)

task.delay(1, rebuildMarkers)

--// =========================================================
--// PODIUM ESP TEMPLATE
--// =========================================================

local FLOOR_COLORS = {
	Color3.fromRGB(255, 60, 60),
	Color3.fromRGB(255, 60, 60),
	Color3.fromRGB(255, 60, 60)
}

local FILL_TRANS = 0.55
local INNER_TRANS = 0.42
local MISS_TRANS = 0.10
local THICKNESS = 0.05
local PULSE_SPEED = 2
local PULSE_AMOUNT = 0.12

local PODIUM_TEMPLATE = {
	{18.500, 1.531, -14.476, 90},
	{18.500, 1.531, -6.976, 90},
	{18.500, 1.531, 0.524, 90},
	{18.500, 1.531, 8.024, 90},
	{18.500, 1.531, 15.524, 90},

	{-18.536, 1.531, 15.524, -90},
	{-18.536, 1.531, 8.024, -90},
	{-18.536, 1.531, 0.524, -90},
	{-18.536, 1.531, -6.976, -90},
	{-18.536, 1.531, -14.476, -90},

	{18.500, 19.531, -14.476, 90},
	{18.500, 19.531, -6.976, 90},
	{18.500, 19.531, 0.524, 90},
	{18.500, 19.531, 8.024, 90},
	{18.500, 19.531, 15.524, 90},

	{-18.380, 19.531, -14.452, -90},
	{-18.380, 19.531, -6.952, -90},
	{-18.380, 19.531, 0.548, -90},

	{18.500, 36.531, -12.476, 90},
	{18.500, 36.531, -4.976, 90},
	{18.500, 36.531, 2.524, 90},
	{18.500, 36.531, 10.024, 90},
	{18.500, 36.531, 17.524, 90},

	{-18.472, 36.531, -12.501, -90},
	{-18.471, 36.531, -5.001, -90},
	{-18.471, 36.531, 2.499, -90},
	{-18.471, 36.531, 9.999, -90},
	{-18.471, 36.531, 17.499, -90}
}

local OUTER_SIZE = Vector3.new(6, 0.25, 6)
local INNER_SIZE = Vector3.new(4, 0.25, 4)
local INNER_OFFSET_Y = 0.25

local oldESP =
	Workspace:FindFirstChild("__PodiumMarkers")

if oldESP then
	oldESP:Destroy()
end

local markers = {}
local fills = {}

local function keepAdornment(object)
	markers[#markers + 1] = object
	object.Parent = hui
	return object
end

local function clearESP()
	for _, marker in ipairs(markers) do
		pcall(function()
			marker:Destroy()
		end)
	end

	table.clear(markers)
	table.clear(fills)
end

local function createBoxAdornment(
	adornee,
	cf,
	size,
	color,
	transparency,
	isFill
)
	local adornment =
		Instance.new("BoxHandleAdornment")

	adornment.Adornee = adornee
	adornment.Size = size
	adornment.CFrame = cf
	adornment.Color3 = color
	adornment.Transparency = transparency
	adornment.AlwaysOnTop = false
	adornment.ZIndex = 0

	keepAdornment(adornment)

	if isFill then
		fills[#fills + 1] = {
			a = adornment,
			base = transparency
		}
	end

	return adornment
end

local function createOutline(part, color)
	local box = Instance.new("SelectionBox")

	box.Adornee = part
	box.Color3 = color
	box.SurfaceColor3 = color
	box.LineThickness = THICKNESS
	box.Transparency = 0
	box.SurfaceTransparency = 1

	return keepAdornment(box)
end

local function drawEdges(root, cf, size, color)
	local thickness = THICKNESS * 1.6

	local hx = size.X * 0.5
	local hz = size.Z * 0.5
	local y = size.Y * 0.5

	createBoxAdornment(
		root,
		cf * CFrame.new(0, y, hz),
		Vector3.new(size.X, thickness, thickness),
		color,
		0,
		false
	)

	createBoxAdornment(
		root,
		cf * CFrame.new(0, y, -hz),
		Vector3.new(size.X, thickness, thickness),
		color,
		0,
		false
	)

	createBoxAdornment(
		root,
		cf * CFrame.new(hx, y, 0),
		Vector3.new(thickness, thickness, size.Z),
		color,
		0,
		false
	)

	createBoxAdornment(
		root,
		cf * CFrame.new(-hx, y, 0),
		Vector3.new(thickness, thickness, size.Z),
		color,
		0,
		false
	)
end

local function getColorForIndex(index)
	if index <= 10 then
		return FLOOR_COLORS[1]
	elseif index <= 18 then
		return FLOOR_COLORS[2]
	end

	return FLOOR_COLORS[3]
end

local function getSlabs(slot)
	local base =
		slot:FindFirstChild("Base")
		or slot

	local decorations =
		base:FindFirstChild("Decorations")

	local parts = {}

	if decorations then
		for _, child in ipairs(decorations:GetChildren()) do
			if child:IsA("BasePart")
				and child.Transparency < 1 then

				parts[#parts + 1] = child
			end
		end
	end

	table.sort(parts, function(a, b)
		return
			a.Size.X * a.Size.Z
			>
			b.Size.X * b.Size.Z
	end)

	return parts
end

local function drawReal(parts, color)
	local root = parts[1]

	for index, part in ipairs(parts) do
		local relative =
			root.CFrame:Inverse()
			* part.CFrame

		createBoxAdornment(
			root,
			relative,
			part.Size
				+ Vector3.new(0.03, 0.03, 0.03),
			color,
			index == 1
				and FILL_TRANS
				or INNER_TRANS,
			true
		)

		createOutline(part, color)
	end
end

local function drawGhost(root, entry, color)
	local cf =
		CFrame.new(
			entry[1],
			entry[2],
			entry[3]
		)
		* CFrame.Angles(
			0,
			math.rad(entry[4]),
			0
		)

	createBoxAdornment(
		root,
		cf,
		OUTER_SIZE,
		color,
		FILL_TRANS + MISS_TRANS,
		true
	)

	createBoxAdornment(
		root,
		cf * CFrame.new(
			0,
			INNER_OFFSET_Y,
			0
		),
		INNER_SIZE,
		color,
		INNER_TRANS + MISS_TRANS,
		true
	)

	drawEdges(
		root,
		cf,
		OUTER_SIZE,
		color
	)
end

local espRebuildPending = false

local function buildESP()
	if espRebuildPending then
		return
	end

	espRebuildPending = true

	task.delay(0.25, function()
		espRebuildPending = false

		clearESP()

		for _, plot in ipairs(Plots:GetChildren()) do
			local root =
				plot:FindFirstChild("MainRoot")

			local pods =
				plot:FindFirstChild("AnimalPodiums")

			if root and pods then
				for index = 1, #PODIUM_TEMPLATE do
					local slot =
						pods:FindFirstChild(
							tostring(index)
						)

					local parts =
						slot
						and getSlabs(slot)

					local color =
						getColorForIndex(index)

					if parts and parts[1] then
						drawReal(parts, color)
					else
						drawGhost(
							root,
							PODIUM_TEMPLATE[index],
							color
						)
					end
				end
			end
		end
	end)
end

buildESP()

--// =========================================================
--// ESP PULSE
--// =========================================================

addConnection(
	RunService.Heartbeat:Connect(function()
		local pulse =
			math.sin(
				os.clock() * PULSE_SPEED
			)
			* PULSE_AMOUNT

		for _, fill in ipairs(fills) do
			if fill.a.Parent then
				fill.a.Transparency =
					math.clamp(
						fill.base + pulse,
						0,
						1
					)
			end
		end
	end)
)

--// =========================================================
--// AUTO STEAL
--// =========================================================

local Steal = {
	AutoStealEnabled = true,
	StealRadius = 250,
	StealDuration = 0.1,

	Mode = "half",

	HalfFireRange = 10,
	HalfHoldMin = 1.3,
	HalfHoldMax = 2.6,
	HalfEntryDelay = 0.3,

	Data = {}
}

local isStealing = false
local stealStartTime
local currentTargetPrompt

local function modifyPrompt(prompt)
	if not prompt then
		return
	end

	pcall(function()
		prompt.MaxActivationDistance = 250
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.E
	end)
end

local function isMyPlot(plotName)
	local plot =
		Plots:FindFirstChild(plotName)

	if not plot then
		return false
	end

	local sign =
		plot:FindFirstChild("PlotSign")

	if not sign then
		return false
	end

	local yourBase =
		sign:FindFirstChild("YourBase")

	if yourBase
		and yourBase:IsA("BillboardGui") then

		return yourBase.Enabled == true
	end

	return false
end

local function getCharacterRoot()
	local character =
		LocalPlayer.Character

	if not character then
		return nil
	end

	return
		character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
end

local function findNearestPrompt()
	local root = getCharacterRoot()

	if not root then
		return nil
	end

	local nearest
	local minimumDistance = math.huge

	for _, plot in ipairs(Plots:GetChildren()) do
		if plot:IsA("Model")
			and not isMyPlot(plot.Name) then

			local podiums =
				plot:FindFirstChild(
					"AnimalPodiums"
				)

			if podiums then
				for _, podium in ipairs(
					podiums:GetChildren()
				) do

					local base =
						podium:FindFirstChild("Base")

					local spawn =
						base
						and base:FindFirstChild(
							"Spawn"
						)

					if spawn then
						local distance =
							(
								spawn.Position
								- root.Position
							).Magnitude

						if distance <= Steal.StealRadius
							and distance < minimumDistance then

							local prompt

							local attachment =
								spawn:FindFirstChild(
									"PromptAttachment"
								)

							local pool =
								attachment
								and attachment:GetChildren()
								or spawn:GetDescendants()

							for _, object in ipairs(pool) do
								if object:IsA(
									"ProximityPrompt"
								)
								and object.ActionText
								and object.ActionText:find(
									"Steal"
								) then

									prompt = object
									modifyPrompt(object)
									break
								end
							end

							if prompt then
								nearest = prompt
								minimumDistance = distance
							end
						end
					end
				end
			end
		end
	end

	return nearest
end

local function getPromptDistance(prompt)
	local root = getCharacterRoot()

	if not root or not prompt then
		return math.huge
	end

	local parent = prompt.Parent

	if parent
		and parent:IsA("Attachment") then

		parent = parent.Parent
	end

	if parent
		and parent:IsA("BasePart") then

		return (
			parent.Position
			- root.Position
		).Magnitude
	end

	return math.huge
end

local function getBrainrotName(prompt)
	local index =
		LocalPlayer:GetAttribute(
			"StealingIndex"
		)

	if type(index) == "string"
		and index ~= "" then

		return index
	end

	if not prompt
		or not prompt.Parent then

		return "Searching..."
	end

	local node = prompt

	for _ = 1, 8 do
		if not node then
			break
		end

		local attribute =
			node:GetAttribute("DisplayName")
			or node:GetAttribute("BrainrotName")
			or node:GetAttribute("Name")

		if type(attribute) == "string"
			and attribute ~= "" then

			return attribute
		end

		local value =
			node:FindFirstChild(
				"DisplayName"
			)
			or node:FindFirstChild(
				"BrainrotName"
			)
			or node:FindFirstChild(
				"Name"
			)

		if value
			and value:IsA("StringValue")
			and value.Value ~= "" then

			return value.Value
		end

		node = node.Parent
	end

	return "Brainrot"
end

local function executeSteal(prompt)
	if isStealing or not prompt then
		return
	end

	currentTargetPrompt = prompt
	modifyPrompt(prompt)

	if not Steal.Data[prompt] then
		Steal.Data[prompt] = {
			hold = {},
			trigger = {},
			ready = true
		}

		if getconnections then
			for _, connection in ipairs(
				getconnections(
					prompt.PromptButtonHoldBegan
				)
			) do
				if connection.Function then
					table.insert(
						Steal.Data[prompt].hold,
						connection.Function
					)
				end
			end

			for _, connection in ipairs(
				getconnections(
					prompt.Triggered
				)
			) do
				if connection.Function then
					table.insert(
						Steal.Data[prompt].trigger,
						connection.Function
					)
				end
			end
		end
	end

	local data = Steal.Data[prompt]

	if not data.ready then
		return
	end

	data.ready = false
	isStealing = true
	stealStartTime = tick()

	task.spawn(function()
		for _, callback in ipairs(data.hold) do
			task.spawn(callback)
		end

		if Steal.Mode == "half" then
			task.wait(Steal.HalfHoldMin)

			while true do
				if
					tick() - stealStartTime
						> Steal.HalfHoldMax
					or not prompt.Parent
				then
					break
				end

				if getPromptDistance(prompt)
					<= Steal.HalfFireRange then

					for _, callback in ipairs(
						data.trigger
					) do
						task.spawn(callback)
					end

					break
				end

				task.wait()
			end
		else
			task.wait(Steal.StealDuration)

			for _, callback in ipairs(
				data.trigger
			) do
				task.spawn(callback)
			end
		end

		task.wait(0.05)

		data.ready = true
		isStealing = false
		currentTargetPrompt = nil
	end)
end

local autoStealConnection

local function startAutoSteal()
	if autoStealConnection then
		return
	end

	autoStealConnection =
		RunService.Heartbeat:Connect(function()
			if not Steal.AutoStealEnabled
				or isStealing then

				return
			end

			local prompt =
				findNearestPrompt()

			if prompt then
				executeSteal(prompt)
			end
		end)

	addConnection(autoStealConnection)
end

--// =========================================================
--// GRAB UI
--// =========================================================

local ui = {}

local function updateProgressBar(progress)
	if ui.ProgressFill then
		ui.ProgressFill.Size =
			UDim2.new(
				math.clamp(progress, 0, 1),
				0,
				1,
				0
			)
	end

	if ui.PercentLabel then
		ui.PercentLabel.Text =
			math.floor(
				progress * 100
			)
			.. "%"
	end
end

local function createGrabUI()
	local playerGui =
		LocalPlayer:WaitForChild("PlayerGui")

	local old =
		playerGui:FindFirstChild("GalaxyUI")

	if old then
		old:Destroy()
	end

	local screenGui =
		Instance.new("ScreenGui")

	screenGui.Name = "GalaxyUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior =
		Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	destroyedObjects[#destroyedObjects + 1] =
		screenGui

	local main =
		Instance.new("Frame")

	main.Name = "AutoGrabBar"
	main.Size = UDim2.fromOffset(
		240,
		105
	)

	main.Position =
		UDim2.new(
			0.5,
			0,
			1,
			-170
		)

	main.AnchorPoint =
		Vector2.new(0.5, 1)

	main.BackgroundColor3 =
		Color3.new(0, 0, 0)

	main.BackgroundTransparency = 0.02
	main.BorderSizePixel = 0
	main.ZIndex = 20
	main.Parent = screenGui

	Instance.new(
		"UICorner",
		main
	).CornerRadius =
		UDim.new(0, 10)

	local stroke =
		Instance.new(
			"UIStroke",
			main
		)

	stroke.Thickness = 2.5
	stroke.Transparency = 0.05
	stroke.Color =
		Color3.new(1, 1, 1)

	local title =
		Instance.new(
			"TextLabel",
			main
		)

	title.Size =
		UDim2.new(
			1,
			-16,
			0,
			18
		)

	title.Position =
		UDim2.fromOffset(8, 5)

	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 12
	title.Text = "BL INSTAGRAB"
	title.TextColor3 =
		Color3.new(1, 1, 1)
	title.ZIndex = 23

	ui.TargetName =
		Instance.new(
			"TextLabel",
			main
		)

	ui.TargetName.Size =
		UDim2.new(
			1,
			-16,
			0,
			16
		)

	ui.TargetName.Position =
		UDim2.fromOffset(8, 23)

	ui.TargetName.BackgroundTransparency = 1
	ui.TargetName.Text = "Searching..."
	ui.TargetName.Font =
		Enum.Font.GothamBold

	ui.TargetName.TextSize = 9
	ui.TargetName.TextColor3 =
		Color3.new(1, 1, 1)

	ui.TargetName.ZIndex = 22

	local progressBackground =
		Instance.new(
			"Frame",
			main
		)

	progressBackground.Size =
		UDim2.new(
			1,
			-16,
			0,
			18
		)

	progressBackground.Position =
		UDim2.fromOffset(8, 41)

	progressBackground.BackgroundColor3 =
		Color3.fromRGB(20, 20, 20)

	progressBackground.ZIndex = 21

	ui.ProgressFill =
		Instance.new(
			"Frame",
			progressBackground
		)

	ui.ProgressFill.Size =
		UDim2.new(0, 0, 1, 0)

	ui.ProgressFill.BackgroundColor3 =
		Color3.new(1, 1, 1)

	ui.ProgressFill.ZIndex = 22

	ui.PercentLabel =
		Instance.new(
			"TextLabel",
			progressBackground
		)

	ui.PercentLabel.Size =
		UDim2.fromScale(1, 1)

	ui.PercentLabel.BackgroundTransparency = 1
	ui.PercentLabel.Text = "0%"
	ui.PercentLabel.TextColor3 =
		Color3.new(1, 1, 1)

	local discordButton =
		Instance.new(
			"TextButton",
			main
		)

	discordButton.Size =
		UDim2.new(
			1,
			-16,
			0,
			27
		)

	discordButton.Position =
		UDim2.fromOffset(8, 68)

	discordButton.BackgroundTransparency = 1
	discordButton.Text =
		"https://discord.gg/blacanscripts"

	discordButton.Font =
		Enum.Font.GothamBold

	discordButton.TextSize = 9
	discordButton.TextColor3 =
		Color3.new(1, 1, 1)

	--// Dragging
	local dragStart
	local startPosition
	local dragging = false

	addConnection(
		main.InputBegan:Connect(function(input)
			if input.UserInputType ==
				Enum.UserInputType.MouseButton1 then

				dragging = true
				dragStart = input.Position
				startPosition =
					main.Position
			end
		end)
	)

	addConnection(
		UserInputService.InputChanged:Connect(
			function(input)
				if dragging
					and input.UserInputType ==
						Enum.UserInputType.MouseMovement then

					local delta =
						input.Position
						- dragStart

					main.Position =
						UDim2.new(
							startPosition.X.Scale,
							startPosition.X.Offset
								+ delta.X,

							startPosition.Y.Scale,
							startPosition.Y.Offset
								+ delta.Y
						)
				end
			end
		)
	)

	addConnection(
		UserInputService.InputEnded:Connect(
			function(input)
				if input.UserInputType ==
					Enum.UserInputType.MouseButton1 then

					dragging = false
				end
			end
		)
	)

	addConnection(
		RunService.RenderStepped:Connect(function()
			local index =
				LocalPlayer:GetAttribute(
					"StealingIndex"
				)

			if type(index) == "string"
				and index ~= "" then

				ui.TargetName.Text = index

			elseif isStealing
				and stealStartTime then

				local progress =
					(
						tick()
						- stealStartTime
					)
					/ Steal.StealDuration

				updateProgressBar(progress)

				ui.TargetName.Text =
					getBrainrotName(
						currentTargetPrompt
					)

			else
				updateProgressBar(0)

				ui.TargetName.Text =
					currentTargetPrompt
					and getBrainrotName(
						currentTargetPrompt
					)
					or "Searching..."
			end
		end)
	)
end

addConnection(
	LocalPlayer.AttributeChanged:Connect(
		function(attribute)
			if attribute ==
				"StealingIndex"
				and ui.TargetName then

				ui.TargetName.Text =
					LocalPlayer:GetAttribute(
						"StealingIndex"
					)
					or "Searching..."
			end
		end
	)
)

--// =========================================================
--// FINAL INITIALIZATION
--// =========================================================

task.wait(2.5)

createGrabUI()
startAutoSteal()

print("========================================")
print(" BLACAN INSTAGRAB LOADED")
print(" Next Base: ON")
print(" Podium ESP: ON")
print(" Projected Floors: ON")
print(" X-Ray: ON")
print(" Anti-Lag: ON")
print(" Hold Infinite Jump: ON")
print(" Auto Steal: ON")
print("========================================")

--// =========================================================
--// UNIFIED CLEANUP
--// =========================================================

_G.__BlacanInstagrabCleanup = function()
	disconnectAll()

	for _, object in ipairs(destroyedObjects) do
		destroyObject(object)
	end

	table.clear(destroyedObjects)

	clearESP()

	if markerHolder then
		destroyObject(markerHolder)
	end

	table.clear(bases)
	table.clear(connectedLabels)
	table.clear(watchedPodiums)
	table.clear(xraySpoofed)
	table.clear(Steal.Data)

	isStealing = false
	currentTargetPrompt = nil
	autoStealConnection = nil

	_G.__BlacanInstagrabCleanup = nil
end
