-- Teleport Server Handler
-- Location: ServerScriptService

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =====================
-- CONFIG
-- =====================

local WHITELIST = {
	[676767676767] = true, -- replace with your real UserId
	[676767676767] = true,
}

-- =====================
-- REMOTES
-- =====================

local function getRemote(name)
	local remote = ReplicatedStorage:FindFirstChild(name)

	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = ReplicatedStorage
	end

	return remote
end

local teleportEvent = getRemote("TeleportRequest")
local autoTPEvent = getRemote("AutoTPToggle")
local whitelistEvent = getRemote("WhitelistManage")

-- =====================
-- FUNCTIONS
-- =====================

local function isWhitelisted(userId)
	return WHITELIST[userId] == true
end

local function validJobId(jobId)
	return typeof(jobId) == "string" and #jobId > 5
end

local function validPlaceId(placeId)
	return typeof(placeId) == "number" and placeId > 0
end

-- =====================
-- TELEPORT REQUEST
-- =====================

teleportEvent.OnServerEvent:Connect(function(requester, targetPlayer, placeId, jobId)

	print("[SERVER] Teleport request:", requester.Name)

	if not isWhitelisted(requester.UserId) then
		warn("[SERVER] Not allowed:", requester.Name)
		return
	end

	if typeof(targetPlayer) ~= "Instance"
		or not targetPlayer:IsA("Player")
		or not targetPlayer.Parent then

		warn("[SERVER] Invalid target")
		return
	end

	placeId = tonumber(placeId)

	if not validPlaceId(placeId) then
		warn("[SERVER] Invalid PlaceId")
		return
	end

	if not validJobId(jobId) then
		warn("[SERVER] Invalid JobId")
		return
	end


	local success, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(
			placeId,
			jobId,
			targetPlayer
		)
	end)

	if success then
		print("[SERVER] Teleported:", targetPlayer.Name)
	else
		warn("[SERVER] Teleport failed:", err)
	end
end)

-- =====================
-- AUTO TP
-- =====================

local autoTPActive = false
local autoPlaceId
local autoJobId


local function autoTeleport(player)

	if not autoTPActive then return end
	if isWhitelisted(player.UserId) then return end

	if not autoPlaceId or not autoJobId then
		return
	end

	task.wait(1)

	local success, err = pcall(function()
		TeleportService:TeleportToPlaceInstance(
			autoPlaceId,
			autoJobId,
			player
		)
	end)

	if success then
		print("[SERVER] AutoTP:", player.Name)
	else
		warn("[SERVER] AutoTP failed:", err)
	end
end


autoTPEvent.OnServerEvent:Connect(function(requester, enabled, placeId, jobId)

	if not isWhitelisted(requester.UserId) then
		return
	end

	autoTPActive = enabled

	if enabled then
		autoPlaceId = tonumber(placeId)
		autoJobId = jobId

		print("[SERVER] AutoTP enabled")

		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(autoTeleport, player)
		end
	else
		print("[SERVER] AutoTP disabled")
	end
end)


Players.PlayerAdded:Connect(function(player)

	if autoTPActive then
		task.spawn(autoTeleport, player)
	end

end)


-- =====================
-- WHITELIST MANAGEMENT
-- =====================

whitelistEvent.OnServerEvent:Connect(function(requester, action, userId)

	if not isWhitelisted(requester.UserId) then
		return
	end

	userId = tonumber(userId)

	if not userId then
		return
	end


	if action == "add" then

		WHITELIST[userId] = true
		print("[SERVER] Added:", userId)


	elseif action == "remove" then

		WHITELIST[userId] = nil
		print("[SERVER] Removed:", userId)

	end
end)


print("[SERVER] Teleport handler loaded successfully")
