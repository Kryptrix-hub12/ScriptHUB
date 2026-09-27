-- Green Duels reciente: constantes insertadas directamente.
-- Los valores cifrados que no se pudieron deducir estan aproximados.

local function greenduelsStartupError(err)
  local message = tostring(err)
  warn("[greenduels] Error de inicio: " .. message)
  _G.greenduelsV2_Running = false
  _G.greenduelsV2_MainExecuted = false
  _G.greenduelsStartupError = message

  pcall(function()
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
      return
    end

    local previous = playerGui:FindFirstChild("greenduelsStartupError")
    if previous then
      previous:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "greenduelsStartupError"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000000
    gui.Parent = playerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.8, 0, 0, 110)
    label.Position = UDim2.new(0.1, 0, 0.08, 0)
    label.BackgroundColor3 = Color3.fromRGB(50, 14, 14)
    label.TextColor3 = Color3.fromRGB(255, 235, 235)
    label.TextSize = 17
    label.TextWrapped = true
    label.Text = "Green Duels: error de inicio\n" .. message
    label.Parent = gui
  end)

  return message
end

local function runGreenduelsMain()
  local greenduelsPerfRun, Players, service, service2, TweenService, service3, Lighting, Workspace, localPlayer
  local isfile_, getSignalCons, tbl17, stand, fn29, fn30, tbl18, tbl19, fn31, fn32
  local tbl20, fn33, fn34, fn35, fn36, fn37, fn38, fn39, fn40, fn41
  local fn42, fn43, tbl21, fn44, tbl22, tbl23, fn45, fn46, humanoid, v84
  local fn47, fn48, infiniteJump, antiRagdoll, medusaCounter, setOn, v85, autoSteal, fn49, fn50
  local fn51, fn52, fn53, fn54, fn55, fn56, fn57, fn58, stopDropBrainrot, fn59
  local fn60, fn61, fn62, batCounter, fn63, fn64, tbl24, tbl25, tbl26, normalSpeed
  local carrySpeed, laggerSpeed, laggerCarrySpeed, uiScale, mobileButtonsSize, stealBarSize, Radius, Duration, instance, uiScale2
  local fn65, fn66, safeMode, fn67, textButton, textButton2, textLabel, flag18, fn68, fn69
  local fn70, tbl27, fn71, createUIStroke, n33, fn72, fn73, flag19, tbl28, fn74
  local fn75
  local service4, readfile_, fn76, fn77
  do
    do
      do
        do
          do
            do
              do
                do
                  greenduelsPerfRun = {
                    connections = {},
                    alive = true,
                    track = function(arg)
                      if not greenduelsPerfRun.alive then
                        arg:Disconnect()
                        return arg
                      end
                      greenduelsPerfRun.connections[arg] = true
                      greenduelsPerfRun.added = (greenduelsPerfRun.added or 0) + 1

                      if greenduelsPerfRun.added % 128 == 0 then
                        for k in pairs(greenduelsPerfRun.connections) do
                          if not k.Connected then
                            greenduelsPerfRun.connections[k] = nil
                          end
                        end
                      end

                      return arg
                    end,
                    cleanup = function()
                      if not greenduelsPerfRun.alive then
                        return
                      end
                      greenduelsPerfRun.alive = false

                      for k in pairs(greenduelsPerfRun.connections) do
                        pcall(function()
                          k:Disconnect()
                        end)
                      end

                      table.clear(greenduelsPerfRun.connections)
                    end,
                  }

                  if _G.greenduelsPerfRun then
                    pcall(_G.greenduelsPerfRun.cleanup)
                  end

                  _G.greenduelsPerfRun = greenduelsPerfRun
                  _G.greenduelsLoadTiming = { startedAt = os.clock() }

                  do
                    local function fn78()
                      pcall(function()
                        local craftingMachine =
                          game:GetService("Workspace"):FindFirstChild("CraftingMachine")
                        if
                          not craftingMachine
                          or craftingMachine:FindFirstChild("ChargeSoundPart")
                        then
                          return
                        end

                        local instance2 = Instance.new("Part")
                        instance2.Name = "ChargeSoundPart"
                        instance2.Anchored = true
                        instance2.CanCollide = false
                        instance2.CanTouch = false
                        instance2.CanQuery = false
                        instance2.Transparency = 1
                        instance2.Size = Vector3.new(0.2, 0.2, 0.2)

                        pcall(function()
                          instance2.CFrame = craftingMachine:GetPivot()
                        end)

                        instance2.Parent = craftingMachine

                        local sound = Instance.new("Sound")
                        sound.Name = "ChargeSound"
                        sound.Volume = 0
                        sound.Parent = instance2
                      end)
                    end

                    local function fn79()
                      pcall(function()
                        local v86 = game:GetService("Workspace"):FindFirstChild("Plots")
                        local v87 = v86 and v86:FindFirstChild("ChargeSoundPart")
                        if not v87 or v87:FindFirstChild("Beam") then
                          return
                        end
                        local attachment = v87:FindFirstChild("_greenduelsBeamA0")

                        if not attachment then
                          attachment = Instance.new("Attachment")
                          attachment.Name = "_greenduelsBeamA0"
                          attachment.Parent = v87
                        end

                        local greenduelsBeamA1 = v87:FindFirstChild("_greenduelsBeamA1")

                        if not greenduelsBeamA1 then
                          local attachment2 = Instance.new("Attachment")
                          attachment2.Name = "_greenduelsBeamA1"
                          attachment2.Position = Vector3.new(0, 0.1, 0)
                          attachment2.Parent = v87

                          greenduelsBeamA1 = attachment2
                        end

                        local beam = Instance.new("Beam")
                        beam.Name = "Beam"
                        beam.Enabled = false
                        beam.Attachment0 = attachment
                        beam.Attachment1 = greenduelsBeamA1
                        beam.Transparency = NumberSequence.new(1)
                        beam.Parent = v87
                      end)
                    end

                    fn78()
                    fn79()

                    if not _G.greenduelsCraftingMachineChargeSoundFix then
                      _G.greenduelsCraftingMachineChargeSoundFix = true

                      task.spawn(function()
                        while true do
                          fn78()
                          fn79()
                          task.wait(0.2)
                        end
                end)
              end
          end
        end

                do
                  local writefile_

                  do
                    if _G.greenduelsV2_Running then
                      pcall(function()
                        local localPlayer2 = game:GetService("Players").LocalPlayer
                        local playerGui = localPlayer2 and localPlayer2:FindFirstChild("PlayerGui")
                        local greenduelsV2 = playerGui and playerGui:FindFirstChild("greenduelsV2")

                        if greenduelsV2 then
                          greenduelsV2:Destroy()
                        end

                        playerGui = playerGui and playerGui:FindFirstChild("greenduelsIntro")

                        if playerGui then
                          playerGui:Destroy()
                        end
                      end)

                      _G.greenduelsV2_Running = false
                      _G.greenduelsV2_MainExecuted = false
                    end

                    _G.greenduelsV2_MainExecuted = false
                    _G.greenduelsV2_Running = true

                    do
                      local v86 = game
                      Players = game:GetService("Players")
                      service = game:GetService("RunService")
                      service2 = game:GetService("UserInputService")
                      TweenService = game:GetService("TweenService")
                      service3 = game:GetService("HttpService")
                      service4 = game:GetService("RunService")
                      Lighting = game:GetService("Lighting")
                      Workspace = game:GetService("Workspace")
                      localPlayer = Players.LocalPlayer or Players:WaitForChild("LocalPlayer")

                      readfile_ = readfile
                        or syn and syn.readfile
                        or getgenv and getgenv().readfile
                        or function()
                          return nil
                        end

                      writefile_ = writefile
                        or syn and syn.writefile
                        or getgenv and getgenv().writefile
                        or function()
                          error("File API unavailable", 2)
                        end

                      isfile_ = isfile
                        or syn and syn.isfile
                        or getgenv and getgenv().isfile
                        or function(arg)
                          local ok, result = pcall(function()
                            return readfile_(arg)
                          end)

                          return ok and result ~= nil and result ~= ""
                        end

                      local v87 = getconnections or get_signal_cons or getconnects

                      if v87 then
                        getSignalCons = v87
                      else
                        getSignalCons = syn and syn.get_signal_cons
                      end

                      if not fireproximityprompt then
                        fireproximityprompt = getgenv and getgenv().fireproximityprompt
                          or genv and genv().fireproximityprompt
                          or function(arg)
                            pcall(function()
                              arg:InputHoldBegin()
                              task.wait(0.05)
                              arg:InputHoldEnd()
                            end)
                          end
                      end

                      repeat
                        task.wait()
                      until v86:IsLoaded()
                    end
                  end

                  tbl17 = { STAND = "STAND", JUMP = "JUMP" }
                  stand = tbl17.STAND

                  do
                    -- Config storage: one primary + FOUR independent recovery slots.
                    -- Every slot is verified after writing, and loading selects the
                    -- newest valid snapshot instead of trusting the first readable file.
                    local tbl29 = {
                      "greenduels_settings.json",
                      "greenduelsConfigBackup.json",
                      "greenduelsV2Config.json",
                      "greenduelsConfigRecovery.json",
                      "greenduelsConfigEmergency.json",
                    }

                    local renamefile_ = renamefile
                      or (syn and syn.renamefile)
                      or (getgenv and getgenv().renamefile)

                    local function greenduelsReadConfigFile(name)
                      local ok, result = pcall(function()
                        return readfile_(name)
                      end)

                      if ok and type(result) == "string" and result ~= "" then
                        return result
                      end

                      return nil
                    end

                    local function greenduelsValidConfigJson(raw)
                      if type(raw) ~= "string" or raw == "" then
                        return nil
                      end

                      local ok, decoded = pcall(service3.JSONDecode, service3, raw)
                      if not ok or type(decoded) ~= "table" then
                        return nil
                      end

                      if decoded.version == nil then
                        return nil
                      end

                      return decoded
                    end

                    fn29 = function()
                      local bestRaw = nil
                      local bestFile = nil
                      local bestSavedAt = -math.huge

                      for _, v86 in ipairs(tbl29) do
                        local raw = greenduelsReadConfigFile(v86)
                        local decoded = greenduelsValidConfigJson(raw)

                        if decoded then
                          local savedAt = tonumber(decoded.savedAt) or 0

                          if savedAt > bestSavedAt then
                            bestSavedAt = savedAt
                            bestRaw = raw
                            bestFile = v86
                          elseif not bestRaw then
                            bestRaw = raw
                            bestFile = v86
                          end
                        end
                      end

                      return bestRaw, bestFile
                    end

                    -- Write to all five slots. Each slot gets up to three attempts
                    -- plus read-back validation. When renamefile is available, a
                    -- temporary file is used first to reduce partial-write damage.
                    fn30 = function(arg)
                      if type(arg) ~= "string" or arg == "" then
                        return false
                      end

                      local verifiedCount = 0

                      for _, v86 in ipairs(tbl29) do
                        local saved = false

                        for attempt = 1, 3 do
                          local ok = pcall(function()
                            local tempName = v86 .. ".tmp"

                            if renamefile_ then
                              pcall(function()
                                writefile_(tempName, arg)
                              end)

                              local tempRaw = greenduelsReadConfigFile(tempName)

                              if tempRaw == arg then
                                local renamed = pcall(function()
                                  renamefile_(tempName, v86)
                                end)

                                if not renamed then
                                  writefile_(v86, arg)
                                end
                              else
                                writefile_(v86, arg)
                              end
                            else
                              writefile_(v86, arg)
                            end
                          end)

                          if ok then
                            local verifyRaw = greenduelsReadConfigFile(v86)
                            local verifyDecoded = greenduelsValidConfigJson(verifyRaw)

                            if verifyRaw == arg and verifyDecoded then
                              saved = true
                              break
                            end
                          end

                          task.wait(0.05 * attempt)
                        end

                        if saved then
                          verifiedCount = verifiedCount + 1
                        else
                          warn("[greenduels] Config slot failed: " .. tostring(v86))
                        end
                      end

                      -- Any verified slot is sufficient for recovery. Normally all
                      -- five copies succeed, giving four fallbacks if the primary fails.
                      return verifiedCount > 0, verifiedCount
                    end
                  end
                end
              end

              do
                local function fn78()
                  local v86 = fn29()
                  if not v86 then
                    return nil
                  end

                  local ok, result = pcall(function()
                    return service3:JSONDecode(v86)
                  end)

                  if ok and result and type(result) == "table" then
                    return result
                  end
                  return nil
                end

                local v86 = fn78()

                tbl18 = {
                  normalSpeed = 60,
                  carrySpeed = 40,
                  laggerSpeed = 10.1,
                  laggerCarrySpeed = 15,
                  speedToggled = false,
                  laggerMode = 0,
                  infJumpEnabled = true,
                  antiRagdollEnabled = false,
                  antiCrasherEnabled = false,
                  antiDropEnabled = false,
                  guiVisible = true,
                  uiLocked = false,
                  isStealing = false,
                  autoLeftEnabled = false,
                  autoRightEnabled = false,
                  medusaLastUsed = 0,
                  medusaDebounce = false,
                  medusaCounterEnabled = false,
                  resetOnMedusa = false,
                  batAimbotToggled = false,
                  autoSwingEnabled = false,
                  batCounterEnabled = false,
                  batCounterDebounce = false,
                  _tpInProgress = false,
                  lastMoveDir = Vector3.new(0, 0, 0),
                  _prevCarry = 30,
                  _prevSpeed = false,
                  stackButtonsHidden = false,
                  stackButtonsLocked = false,
                  removeAcc = false,
                  antiLagEnabled = false,
                  potatoGraphicsEnabled = false,
                  stretchedResEnabled = false,
                  fovEnabled = false,
                  fovValue = 70,
                  skyTheme = "Off",
                  vividGraphics = "Off",
                  tryardAnimEnabled = false,
                  aimbot2Toggled = false,
                  espEnabled = true,
                  lineEspEnabled = true,
                  swingHereMarkerEnabled = true,
                  autoStealMode = "Semi",
                  autoChangeSpeed = false,
                  kickWarningEnabled = false,
                  jumpMode = "Hold",
                  safeMode = false,
                  noCamCollisionEnabled = false,
                  antiDieEnabled = false,
                  tpBatMode = "Teleport",
                  tpBatVersion = "V1",
                  tpBatNoCollision = false,
                  bodyLockEnabled = false,
                  bodyLockRadius = 20,
                  autoBatBypass = false,
                  bypassAutoBatSpeed = 58,
                  bypassLaggerAutoBatSpeed = 40,
                  mirrorTPDownEnabled = false,
                  autoTPDownEnabled = false,
                  autoTPDownHeight = 15,
                  mobileButtonScale = 1,
                  stealBarScale = 1,
                  unwalkEnabled = false,
                  introEnabled = true,
                  introMusic = "Intro 1",
                  cosmeticHeadless = false,
                  cosmeticKorblox = "Off",
                  cosmeticHat = "Off",
                }

                if v86 and v86.autoChangeSpeed ~= nil then
                  tbl18.autoChangeSpeed = v86.autoChangeSpeed
                end

                if v86 and v86.kickWarningEnabled ~= nil then
                  tbl18.kickWarningEnabled = v86.kickWarningEnabled
                end

                if v86 and v86.antiCrasherEnabled ~= nil then
                  tbl18.antiCrasherEnabled = v86.antiCrasherEnabled
                end

                if v86 and v86.antiDropEnabled ~= nil then
                  tbl18.antiDropEnabled = v86.antiDropEnabled
                end

                tbl18.autoCarryOnGrab = tbl18.autoChangeSpeed

                if v86 and v86.jumpMode ~= nil then
                  tbl18.jumpMode = v86.jumpMode == "Tap" and "Tap" or "Hold"
                end

                if v86 and v86.safeMode ~= nil then
                  tbl18.safeMode = v86.safeMode
                end

                if v86 and v86.noCamCollisionEnabled ~= nil then
                  tbl18.noCamCollisionEnabled = v86.noCamCollisionEnabled
                end

                if v86 and v86.antiDieEnabled ~= nil then
                  tbl18.antiDieEnabled = v86.antiDieEnabled
                end

                if v86 and v86.fovEnabled ~= nil then
                  tbl18.fovEnabled = v86.fovEnabled
                end

                if v86 and v86.fovValue ~= nil then
                  tbl18.fovValue = tonumber(v86.fovValue) or tbl18.fovValue
                elseif v86 and v86.normalFOV ~= nil then
                  tbl18.fovValue = tonumber(v86.normalFOV) or tbl18.fovValue
                end

                tbl18.introEnabled = true

                if v86 and v86.introMusic ~= nil then
                  local str6 = tostring(v86.introMusic)
                  local introMusic = str6 == "Intro 5" and "Intro 4"
                    or str6 == "Intro 4" and "Intro 3"
                    or (str6 == "Intro 1" or str6 == "Intro 2" or str6 == "Intro 3") and str6

                  if not introMusic then
                    introMusic = (str6 == "Default" or str6 == "Other") and "Intro 1"
                  end

                  tbl18.introMusic = introMusic or "Intro 1"
                end

                if v86 and v86.skyTheme ~= nil then
                  tbl18.skyTheme = tostring(v86.skyTheme)
                end

                if v86 and v86.vividGraphics ~= nil then
                  local v87 = 0
                  tbl18.vividGraphics = tostring(v86.vividGraphics) == v87 and "Game Color"
                    or tostring(v86.vividGraphics)
                end

                if v86 and v86.aimbot2Toggled ~= nil then
                  tbl18.aimbot2Toggled = v86.aimbot2Toggled
                end

                if v86 and v86.tpBatMode ~= nil then
                  tbl18.tpBatMode = v86.tpBatMode
                end

                tbl18.tpBatVersion = "V1"
                tbl18.tpBatNoCollision = false

                if v86 and v86.bodyLockEnabled ~= nil then
                  tbl18.bodyLockEnabled = v86.bodyLockEnabled
                end

                if v86 and v86.bodyLockRadius ~= nil then
                  tbl18.bodyLockRadius =
                    math.clamp(tonumber(v86.bodyLockRadius) or tbl18.bodyLockRadius, 1, 200)
                end

                if v86 and v86.autoBatBypass ~= nil then
                  tbl18.autoBatBypass = v86.autoBatBypass
                end

                if v86 and v86.lineEspEnabled ~= nil then
                  tbl18.lineEspEnabled = v86.lineEspEnabled
                end

                if v86 and v86.potatoGraphicsEnabled ~= nil then
                  tbl18.potatoGraphicsEnabled = v86.potatoGraphicsEnabled
                end

                if v86 and v86.bypassAutoBatSpeed ~= nil then
                  tbl18.bypassAutoBatSpeed = v86.bypassAutoBatSpeed
                end

                if v86 and v86.bypassLaggerAutoBatSpeed ~= nil then
                  tbl18.bypassLaggerAutoBatSpeed = v86.bypassLaggerAutoBatSpeed
                end

                if v86 and v86.mirrorTPDownEnabled ~= nil then
                  tbl18.mirrorTPDownEnabled = v86.mirrorTPDownEnabled
                end

                if v86 and v86.autoTPDownEnabled ~= nil then
                  tbl18.autoTPDownEnabled = v86.autoTPDownEnabled
                end

                if v86 and v86.autoTPDownHeight ~= nil then
                  tbl18.autoTPDownHeight = math.clamp(tonumber(v86.autoTPDownHeight) or 15, 1, 100)
                end

                if v86 and v86.cosmeticHeadless ~= nil then
                  tbl18.cosmeticHeadless = v86.cosmeticHeadless
                end

                if v86 and v86.cosmeticKorblox ~= nil then
                  tbl18.cosmeticKorblox = tostring(v86.cosmeticKorblox)
                end

                if v86 and v86.cosmeticHat ~= nil then
                  tbl18.cosmeticHat = tostring(v86.cosmeticHat)
                end

                if v86 and v86.mobileButtonScale ~= nil then
                  tbl18.mobileButtonScale =
                    math.clamp(tonumber(v86.mobileButtonScale) or 1, 0.5, 2)
                end

                if v86 and v86.stealBarScale ~= nil then
                  tbl18.stealBarScale = math.clamp(tonumber(v86.stealBarScale) or 1, 0.5, 2)
                end
              end

              do
                tbl19 = {
                  speed = Enum.KeyCode.Q,
                  guiHide = Enum.KeyCode.LeftControl,
                  autoLeft = Enum.KeyCode.L,
                  autoRight = Enum.KeyCode.R,
                  lagger = Enum.KeyCode.Unknown,
                  tpDown = Enum.KeyCode.Unknown,
                  drop = Enum.KeyCode.H,
                  reset = Enum.KeyCode.T,
                  aimbot = Enum.KeyCode.Unknown,
                  aimbot2 = Enum.KeyCode.Unknown,
                  tpBat = Enum.KeyCode.Unknown,
                  antiBat = Enum.KeyCode.Unknown,
                }

                do
                  local tbl29 = { "bat", "slap", "medusa", "head", "stone" }

                  fn76 = function(arg)
                    local str6 = tostring(arg):lower()

                    for _, v86 in ipairs(tbl29) do
                      if str6:find(v86) then
                        return true
                      end
                    end

                    return false
                  end
                end
              end

              do
                local tbl29 = {
                  ["animate"] = true,
                  animsaves = true,
                  health = true,
                  ["face"] = true,
                  ["body colors"] = true,
                  bodycolors = true,
                  ["accessory"] = true,
                  head = true,
                  torso = true,
                  uppertorso = true,
                  lowertorso = true,
                  humanoidrootpart = true,
                }

                fn77 = function(arg)
                  local str6 = arg.Name:lower()
                  if tbl29[str6] then
                    return true
                  end

                  if fn76(str6) then
                    return true
                  end

                  if arg:FindFirstChildOfClass("Humanoid") then
                    return true
                  end

                  if arg:FindFirstChildWhichIsA("Accoutrement", true) then
                    return true
                  end
                  return false
                end
              end

              do
                local function fn78(arg, arg2)
                  return arg and arg:IsDescendantOf(arg2)
                end

                fn31 = function()
                  local character = localPlayer.Character
                  if not character then
                    return false
                  end

                  for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Tool") and not fn76(child.Name) then
                      return true
                    end
                  end

                  for _, child in ipairs(character:GetChildren()) do
                    if
                      child:IsA("Model")
                      and not fn77(child)
                      and child:FindFirstChildWhichIsA("BasePart")
                    then
                      return true
                    end
                  end

                  for _, descendant in ipairs(character:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                      for _, v86 in ipairs(descendant:GetJoints()) do
                        if
                          v86:IsA("Weld")
                          or v86:IsA("WeldConstraint")
                          or v86:IsA("Motor6D")
                          or v86:IsA("ManualWeld")
                        then
                          local part0 = v86.Part0
                          local part1 = v86.Part1

                          if not (part0 and not fn78(part0, character)) then
                            local flag20 = part1 and not fn78(part1, character)
                            local v87 = nil

                            if flag20 then
                              part0 = part1
                            else
                              part0 = v87
                            end
                          end

                          if part0 and not fn76(part0.Name) then
                            local model = part0:FindFirstAncestorOfClass("Model")
                            if not (model and Players:GetPlayerFromCharacter(model)) then
                              return true
                            end
                          end
                        end
                      end
                    end
                  end

                  return false
                end
              end
            end

            do
              do
                do
                  do
                    local tbl29 = {
                      "RightHand",
                      "LeftHand",
                      "RightLowerArm",
                      "LeftLowerArm",
                      "Right Arm",
                      "Left Arm",
                    }

                    fn32 = function(arg)
                      local character = localPlayer.Character
                      if not character then
                        return false
                      end

                      for _, child in ipairs(character:GetChildren()) do
                        if child:IsA("Tool") and not fn76(child.Name) then
                          return true
                        end
                      end

                      for _, child in ipairs(character:GetChildren()) do
                        if
                          child:IsA("Model")
                          and not fn77(child)
                          and child:FindFirstChildWhichIsA("BasePart")
                        then
                          return true
                        end
                      end

                      for _, v86 in ipairs(tbl29) do
                        local v87 = character:FindFirstChild(v86)

                        if v87 and v87:IsA("BasePart") then
                          for _, v88 in ipairs(v87:GetJoints()) do
                            if
                              v88:IsA("Weld")
                              or v88:IsA("WeldConstraint")
                              or v88:IsA("Motor6D")
                              or v88:IsA("ManualWeld")
                            then
                              local part0 = v88.Part0
                              local part1 = v88.Part1

                              if not (part0 and not part0:IsDescendantOf(character)) then
                                local flag20 = part1 and not part1:IsDescendantOf(character)
                                part0 = nil

                                if flag20 then
                                  part0 = part1
                                end
                              end

                              if part0 and not fn76(part0.Name) then
                                local model = part0:FindFirstAncestorOfClass("Model")
                                if not (model and Players:GetPlayerFromCharacter(model)) then
                                  return true
                                end
                              end
                            end
                          end
                        end
                      end

                      if arg then
                        return fn31()
                      end
                      return false
                    end
                  end

                  _G._greenduelsAutoCarryV2Range = tonumber(_G._greenduelsAutoCarryV2Range) or 15
                  _G._greenduelsCarryCollectSlowRange = tonumber(
                    _G._greenduelsCarryCollectSlowRange
                  ) or 18

                  _autoCarryV2 = _autoCarryV2
                    or {
                      spots = {},
                      slowParts = {},
                      nextScan = 0,
                      latched = false,
                      held = false,
                      armed = true,
                      graceUntil = 0,
                      watchUntil = 0,
                    }

                  _scanAutoCarryV2Spots = function()
                    local spots = {}
                    local slowParts = {}
                    local plots = workspace:FindFirstChild("Plots")

                    if plots then
                      for _, child in ipairs(plots:GetChildren()) do
                        local plotSign = child:FindFirstChild("PlotSign")
                        plotSign = plotSign and plotSign:FindFirstChild("PlotSign")

                        if
                          not (
                            plotSign
                            and plotSign:IsA("BillboardGui")
                            and plotSign.Enabled == true
                          )
                        then
                          local animalPodiums = child:FindFirstChild("AnimalPodiums")

                          if animalPodiums then
                            for _, child2 in ipairs(animalPodiums:GetChildren()) do
                              local spawn_ = child2:FindFirstChild("PromptAttachment")
                              spawn_ = spawn_ and spawn_:FindFirstChild("Spawn")

                              if spawn_ and spawn_:IsA("BasePart") then
                                spots[#spots + 1] = spawn_.Position
                                slowParts[#slowParts + 1] = spawn_
                              end
                            end
                          end
                        end
                      end
                    end

                    _autoCarryV2.spots = spots
                    _autoCarryV2.slowParts = slowParts
                  end

                  do
                    local function fn78(arg, arg2, arg3)
                      local v86 = arg2.CFrame:PointToObjectSpace(arg.Position)
                      local n34 = arg2.Size * 0.5
                      local n35 = math.clamp(v86.X, -n34.X, n34.X)
                      local n36 = math.clamp(v86.Y, -n34.Y, n34.Y)
                      local n37 = math.clamp(v86.Z, -n34.Z, n34.Z)
                      return (arg.Position - arg2.CFrame:PointToWorldSpace(
                        Vector3.new(n35, n36, n37)
                      )).Magnitude <= arg3
                    end

                    _autoCarryV2InRange = function(arg)
                      local v86 = arg and arg:FindFirstChild("HumanoidRootPart")
                      if not v86 then
                        return false
                      end
                      local n34 = tonumber(_G._greenduelsAutoCarryV2Range) or 15
                      local raVeStealTargetPos = _G._RaVeStealTargetPos
                        or _G.greenduelsStealTargetPos
                      if
                        typeof(raVeStealTargetPos) == "Vector3"
                        and (v86.Position - raVeStealTargetPos).Magnitude <= n34
                      then
                        return true
                      end
                      local now2 = tick()

                      if now2 >= _autoCarryV2.nextScan then
                        _autoCarryV2.nextScan = now2 + 0.5
                        _scanAutoCarryV2Spots()
                      end

                      for _, spot in ipairs(_autoCarryV2.spots) do
                        if (v86.Position - spot).Magnitude <= n34 then
                          return true
                        end
                      end

                      return now2 < _autoCarryV2.watchUntil
                    end

                    _autoCarryV2SlowInRange = function(arg)
                      arg = arg and arg:FindFirstChild("HumanoidRootPart")
                      if not arg then
                        return false
                      end
                      local n34 = tonumber(_G._greenduelsCarryCollectSlowRange) or 18
                      local raVeStealTargetPos = _G._RaVeStealTargetPos
                        or _G.greenduelsStealTargetPos
                      local v86 = "Vector3"
                      if
                        typeof(raVeStealTargetPos) == v86
                        and (arg.Position - raVeStealTargetPos).Magnitude <= n34
                      then
                        return true
                      end
                      local now2 = tick()

                      if _autoCarryV2.nextScan <= now2 then
                        _autoCarryV2.nextScan = now2 + 0.5
                        _scanAutoCarryV2Spots()
                      end

                      local v87 = ipairs
                      local slowParts = _autoCarryV2.slowParts or {}

                      for _, slowPart in v87(slowParts) do
                        if slowPart and slowPart.Parent and fn78(arg, slowPart, n34) then
                          return true
                        end
                      end

                      for _, spot in ipairs(_autoCarryV2.spots) do
                        if (arg.Position - spot).Magnitude <= n34 then
                          return true
                        end
                      end

                      return false
                    end
                  end
                end

                _autoCarryV2ShouldUseCarry = function(arg, arg2)
                  local flag20 = _autoCarryV2InRange(arg)
                  local flag21 = not flag20

                  if flag21 then
                    _autoCarryV2.armed = true
                  end

                  if flag21 or not tbl18.speedToggled then
                    _autoCarryV2.latched = false
                  end

                  if flag20 and _autoCarryV2.armed and not _autoCarryV2.latched then
                    _autoCarryV2.latched = true
                    _autoCarryV2.held = false
                    _autoCarryV2.graceUntil = tick() + 0.75
                    return true
                  end

                  if tbl18.speedToggled then
                    if arg2 then
                      _autoCarryV2.held = true
                      local v86 = false
                      _autoCarryV2.graceUntil = tick() + v86
                      return true
                    end

                    if _autoCarryV2.held then
                      _autoCarryV2.held = false
                      _autoCarryV2.latched = false
                      _autoCarryV2.armed = false
                      return false
                    end

                    if not flag20 then
                      local graceUntil = _autoCarryV2.graceUntil
                      flag20 = tick() <= graceUntil
                    end

                    if flag20 then
                      return true
                    end
                  end

                  return false
                end

                do
                  local flag20 = false

                  tbl20 = {
                    autoSteal = nil,
                    antiRag = nil,
                    autoLeft = nil,
                    autoRight = nil,
                    aimbot = nil,
                    anchor = {},
                    progress = nil,
                    batCounter = nil,
                    aimbot2 = nil,
                    jumpHoldTap = nil,
                    jumpHoldHeartbeat = nil,
                    jumpMobileHeartbeat = nil,
                    jumpInputBegan = nil,
                    jumpInputEnded = nil,
                    jumpTouchBegan = nil,
                    jumpTouchEnded = nil,
                    autoTPDown = nil,
                  }

                  _G.greenduelsManualNormalSpeed = _G.greenduelsManualNormalSpeed or false
                  _G.greenduelsInfiniteJump = _G.greenduelsInfiniteJump or {}
                  _G.greenduelsInfiniteJump.nextTapAt = 0
                  _G.greenduelsInfiniteJump.pulseToken = 0
                  _G.greenduelsInfiniteJump.heldInput = nil
                  _G.greenduelsInfiniteJump.holdToken = 0
                  _G.greenduelsInfiniteJump.attachmentName = "greenduelsInfJumpAttachment"
                  _G.greenduelsInfiniteJump.moverName = "greenduelsInfJumpMover"
                  _G.greenduelsInfiniteJump.pulseDuration = 0.5
                  _G.greenduelsInfiniteJump.jumpSpeed = 40

                  _G.greenduelsInfiniteJump.clear = function(arg)
                    for _, v86 in ipairs({
                      "InfiniteJumpTapVelocity",
                      "InfiniteJumpTapLinearVelocity",
                      "greenduelsHoldJumpLinearVelocity",
                      "WAVEJumpHoldLinearVelocity",
                    }) do
                      local v87 = arg and arg:FindFirstChild(v86)

                      if v87 and v87:IsA("LinearVelocity") then
                        pcall(function()
                          v87:Destroy()
                        end)
                      end
                    end

                    for _, v86 in ipairs({
                      "greenduelsInfJumpAttachment",
                      "greenduelsMobileInfJumpAttachment",
                      "greenduelsHoldJumpAttachment",
                      "WAVEJumpHoldAttachment",
                    }) do
                      local v87 = arg and arg:FindFirstChild(v86)

                      if v87 and v87:IsA("Attachment") then
                        pcall(function()
                          v87:Destroy()
                        end)
                      end
                    end
                  end

                  _G.greenduelsInfiniteJump.jumpPulse = function()
                    if not tbl18.infJumpEnabled then
                      return
                    end
                    local now2 = os.clock()
                    if now2 < _G.greenduelsInfiniteJump.nextTapAt then
                      return
                    end
                    _G.greenduelsInfiniteJump.nextTapAt = now2 + 0.08
                    local character = localPlayer.Character
                    local humanoidRootPart = character
                      and character:FindFirstChild("HumanoidRootPart")
                    character = character and character:FindFirstChildOfClass("Humanoid")
                    local flag21 = not (humanoidRootPart and character) or character.Health <= 0

                    if not flag21 then
                      local dead = Enum.HumanoidStateType.Dead
                      flag21 = character:GetState() == dead
                    end

                    if flag21 then
                      return
                    end
                    _G.greenduelsInfiniteJump.clear(humanoidRootPart)

                    local attachment = Instance.new("Attachment")
                    attachment.Name = _G.greenduelsInfiniteJump.attachmentName
                    attachment.Parent = humanoidRootPart

                    local linearVelocity = Instance.new("LinearVelocity")
                    linearVelocity.Name = _G.greenduelsInfiniteJump.moverName
                    linearVelocity.Attachment0 = attachment
                    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                    linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                    linearVelocity.VectorVelocity =
                      Vector3.new(0, _G.greenduelsInfiniteJump.jumpSpeed, 0)
                    linearVelocity.ForceLimitsEnabled = true
                    linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
                    linearVelocity.MaxAxesForce =
                      Vector3.new(0, humanoidRootPart.AssemblyMass * workspace.Gravity * 4, 0)
                    linearVelocity.Parent = humanoidRootPart

                    _G.greenduelsInfiniteJump.pulseToken = _G.greenduelsInfiniteJump.pulseToken
                      + 1
                    local pulseToken = _G.greenduelsInfiniteJump.pulseToken

                    task.delay(_G.greenduelsInfiniteJump.pulseDuration, function()
                      if
                        _G.greenduelsInfiniteJump
                        and pulseToken == _G.greenduelsInfiniteJump.pulseToken
                      then
                        _G.greenduelsInfiniteJump.clear(humanoidRootPart)
                      end
                    end)
                  end

                  _G.greenduelsInfiniteJump.beginHold = function(heldInput)
                    _G.greenduelsInfiniteJump.heldInput = heldInput
                    _G.greenduelsInfiniteJump.holdToken = _G.greenduelsInfiniteJump.holdToken + 1
                    local holdToken = _G.greenduelsInfiniteJump.holdToken
                    _G.greenduelsInfiniteJump.jumpPulse()

                    task.spawn(function()
                      task.wait(0.11)

                      while
                        tbl18.infJumpEnabled
                        and _G.greenduelsInfiniteJump
                        and _G.greenduelsInfiniteJump.heldInput == heldInput
                        and _G.greenduelsInfiniteJump.holdToken == holdToken
                      do
                        _G.greenduelsInfiniteJump.jumpPulse()
                        task.wait(0.11)
                      end
                    end)
                  end

                  _G.greenduelsInfiniteJump.endHold = function(arg)
                    if _G.greenduelsInfiniteJump.heldInput == arg then
                      _G.greenduelsInfiniteJump.heldInput = nil
                      _G.greenduelsInfiniteJump.holdToken = _G.greenduelsInfiniteJump.holdToken + 1
                    end
                  end

                  _G.greenduelsInfiniteJump.disable = function()
                    _G.greenduelsInfiniteJump.heldInput = nil
                    _G.greenduelsInfiniteJump.holdToken = _G.greenduelsInfiniteJump.holdToken + 1
                    _G.greenduelsInfiniteJump.pulseToken = _G.greenduelsInfiniteJump.pulseToken + 1
                    local character = localPlayer.Character
                    character = character and character:FindFirstChild("HumanoidRootPart")

                    if character then
                      _G.greenduelsInfiniteJump.clear(character)
                    end
                  end

                  local function fn78()
                    if tbl20.jumpHoldTap then
                      tbl20.jumpHoldTap:Disconnect()
                      tbl20.jumpHoldTap = nil
                    end

                    if tbl20.jumpHoldHeartbeat then
                      tbl20.jumpHoldHeartbeat:Disconnect()
                      tbl20.jumpHoldHeartbeat = nil
                    end

                    if tbl20.jumpMobileHeartbeat then
                      tbl20.jumpMobileHeartbeat:Disconnect()
                      tbl20.jumpMobileHeartbeat = nil
                    end

                    if tbl20.jumpInputBegan then
                      tbl20.jumpInputBegan:Disconnect()
                      tbl20.jumpInputBegan = nil
                    end

                    if tbl20.jumpInputEnded then
                      tbl20.jumpInputEnded:Disconnect()
                      tbl20.jumpInputEnded = nil
                    end

                    if tbl20.jumpTouchBegan then
                      tbl20.jumpTouchBegan:Disconnect()
                      tbl20.jumpTouchBegan = nil
                    end

                    if tbl20.jumpTouchEnded then
                      tbl20.jumpTouchEnded:Disconnect()
                      tbl20.jumpTouchEnded = nil
                    end

                    flag20 = false

                    pcall(function()
                      if _G.greenduelsInfiniteJump then
                        _G.greenduelsInfiniteJump.disable()
                      end
                    end)
                  end

                  fn33 = function(arg)
                    arg = arg and arg.UserInputType
                    return arg == Enum.UserInputType.Gamepad1
                      or arg == Enum.UserInputType.Gamepad2
                      or arg == Enum.UserInputType.Gamepad3
                      or arg == Enum.UserInputType.Gamepad4
                      or arg == Enum.UserInputType.Gamepad5
                      or arg == Enum.UserInputType.Gamepad6
                      or arg == Enum.UserInputType.Gamepad7
                      or arg == Enum.UserInputType.Gamepad8
                  end

                  fn34 = function()
                    fn78()
                    if not tbl18.infJumpEnabled then
                      return
                    end

                    tbl20.jumpHoldTap =
                      greenduelsPerfRun.track(service2.JumpRequest:Connect(function()
                        if not tbl18.infJumpEnabled then
                          return
                        end

                        if _G.greenduelsInfiniteJump then
                          _G.greenduelsInfiniteJump.jumpPulse()
                        end
                      end))

                    tbl20.jumpInputBegan = greenduelsPerfRun.track(
                      service2.InputBegan:Connect(function(input, gameProcessed)
                        local flag21 = input.UserInputType == Enum.UserInputType.Keyboard
                          and input.KeyCode == Enum.KeyCode.Space
                        local flag22 = fn33(input) and input.KeyCode == Enum.KeyCode.ButtonA

                        if gameProcessed then
                          gameProcessed = not (flag21 or flag22)
                        end

                        local focusedTextBox = gameProcessed or service2:GetFocusedTextBox()

                        if not focusedTextBox then
                          focusedTextBox = not (flag21 or flag22)
                        end

                        if focusedTextBox then
                          return
                        end

                        if _G.greenduelsInfiniteJump then
                          _G.greenduelsInfiniteJump.beginHold(input)
                        end
                      end)
                    )

                    tbl20.jumpInputEnded =
                      greenduelsPerfRun.track(service2.InputEnded:Connect(function(input)
                        if _G.greenduelsInfiniteJump then
                          _G.greenduelsInfiniteJump.endHold(input)
                        end
                      end))

                    tbl20.jumpMobileHeartbeat =
                      greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                        if
                          not tbl18.infJumpEnabled
                          or tbl18.jumpMode == "Tap"
                          or not service2.TouchEnabled
                          or not _G.greenduelsInfiniteJump
                        then
                          return
                        end
                        local character = localPlayer.Character
                        character = character and character:FindFirstChildOfClass("Humanoid")

                        if character and character.Health > 0 and character.Jump == true then
                          _G.greenduelsInfiniteJump.jumpPulse()
                        end
                      end))

                    return
                  end
                end
              end

              do
                _G._AmbitiousTPDownJumpLocked = _G._AmbitiousTPDownJumpLocked or false
                _G._AmbitiousAutoCarryMode = _G._AmbitiousAutoCarryMode or "Normal"
                _G._AmbitiousAutoCarrySoft = _G._AmbitiousAutoCarrySoft
                  or { radius = 9.5, animals = {}, lastScan = 0, scanInterval = 2 }

                _G._AmbitiousAS = _G._AmbitiousAS
                  or {
                    wasLow = false,
                    locked = false,
                    savedMode = nil,
                    restoring = false,
                  }

                _G.AmbitiousAutoCarryScanAnimals = function()
                  local ambitiousAutoCarrySoft = _G._AmbitiousAutoCarrySoft
                  local animals = {}
                  local plots = workspace:FindFirstChild("Plots")

                  if plots then
                    for _, child in ipairs(plots:GetChildren()) do
                      local plotSign = child:FindFirstChild("PlotSign")
                      plotSign = plotSign and plotSign:FindFirstChild("YourBase")

                      if
                        not (
                          plotSign
                          and plotSign:IsA("BillboardGui")
                          and plotSign.Enabled == true
                        )
                      then
                        local animalPodiums = child:FindFirstChild("AnimalPodiums")

                        if animalPodiums then
                          for _, child2 in ipairs(animalPodiums:GetChildren()) do
                            local base = child2:FindFirstChild("Base")
                            base = base and base:FindFirstChild("PromptAttachment")

                            if base then
                              animals[#animals + 1] = base.Position
                            end
                          end
                        end
                      end
                    end
                  end

                  ambitiousAutoCarrySoft.animals = animals
                end

                _G.AmbitiousAutoCarryNearestAnimalDist = function()
                  local ambitiousAutoCarrySoft = _G._AmbitiousAutoCarrySoft
                  local character = localPlayer.Character

                  if character then
                    character = character:FindFirstChild("HumanoidRootPart")
                      or character:FindFirstChild("UpperTorso")
                  end

                  if not character then
                    return math.huge
                  end
                  local now2 = tick()

                  if
                    now2 - (ambitiousAutoCarrySoft.lastScan or 0)
                    >= (ambitiousAutoCarrySoft.scanInterval or 2)
                  then
                    ambitiousAutoCarrySoft.lastScan = now2
                    pcall(_G.AmbitiousAutoCarryScanAnimals)
                  end

                  local huge = math.huge
                  local v86 = ipairs
                  local animals = ambitiousAutoCarrySoft.animals or {}

                  for _, animal in v86(animals) do
                    local magnitude = (character.Position - animal).Magnitude

                    if magnitude < huge then
                      huge = magnitude
                    end
                  end

                  return huge
                end

                _G.AmbitiousAutoCarryInSoftRadius = function()
                  local ambitiousAutoCarrySoft = _G._AmbitiousAutoCarrySoft
                  return _G.AmbitiousAutoCarryNearestAnimalDist()
                    <= (tonumber(ambitiousAutoCarrySoft.radius) or 9.5)
                end

                do
                  local devCameraOcclusionMode = nil

                  fn35 = function()
                    tbl18.noCamCollisionEnabled = true

                    pcall(function()
                      devCameraOcclusionMode = localPlayer.DevCameraOcclusionMode
                      localPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                    end)
                  end

                  fn36 = function()
                    tbl18.noCamCollisionEnabled = false

                    pcall(function()
                      localPlayer.DevCameraOcclusionMode = devCameraOcclusionMode
                        or Enum.DevCameraOcclusionMode.Zoom
                    end)
                  end
                end
              end

              do
                local tbl29 = {
                  conns = {},
                  charConn = nil,
                  hb = nil,
                  ffName = "greenduelsAntiDieFF",
                }

                local function fn78()
                  for _, conn in ipairs(tbl29.conns) do
                    pcall(function()
                      conn:Disconnect()
                    end)
                  end

                  table.clear(tbl29.conns)

                  if tbl29.charConn then
                    pcall(function()
                      tbl29.charConn:Disconnect()
                    end)

                    tbl29.charConn = nil
                  end

                  if tbl29.hb then
                    pcall(function()
                      tbl29.hb:Disconnect()
                    end)

                    tbl29.hb = nil
                  end
                end

                local function fn79(arg)
                  if not arg or not arg.Parent then
                    return
                  end

                  pcall(function()
                    if arg.MaxHealth < 100 then
                      arg.MaxHealth = 100
                    end

                    arg.Health = arg.MaxHealth
                  end)
                end

                local function fn80(parent)
                  if not tbl18.antiDieEnabled or not parent then
                    return
                  end

                  for _, conn in ipairs(tbl29.conns) do
                    pcall(function()
                      conn:Disconnect()
                    end)
                  end

                  table.clear(tbl29.conns)
                  local humanoid2 = parent:FindFirstChildOfClass("Humanoid")
                    or parent:WaitForChild("Humanoid", 5)
                  if not humanoid2 then
                    return
                  end

                  pcall(function()
                    humanoid2.BreakJointsOnDeath = false
                    humanoid2.RequiresNeck = false
                    humanoid2:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    humanoid2:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                  end)

                  if not parent:FindFirstChild(tbl29.ffName) then
                    local forceField = Instance.new("ForceField")
                    forceField.Name = tbl29.ffName
                    forceField.Visible = false
                    forceField.Parent = parent
                  end

                  table.insert(
                    tbl29.conns,
                    humanoid2.HealthChanged:Connect(function(health)
                      if tbl18.antiDieEnabled and health <= 25 then
                        fn79(humanoid2)
                      end
                    end)
                  )

                  table.insert(
                    tbl29.conns,
                    humanoid2.Died:Connect(function()
                      if tbl18.antiDieEnabled then
                        task.wait()
                        fn79(humanoid2)
                      end
                    end)
                  )

                  table.insert(
                    tbl29.conns,
                    humanoid2.StateChanged:Connect(function(old, new)
                      if
                        tbl18.antiDieEnabled
                        and (
                          new == Enum.HumanoidStateType.Dead
                          or new == Enum.HumanoidStateType.Ragdoll
                          or new == Enum.HumanoidStateType.FallingDown
                        )
                      then
                        pcall(function()
                          humanoid2:ChangeState(Enum.HumanoidStateType.Running)
                        end)

                        fn79(humanoid2)
                      end
                    end)
                  )

                  fn79(humanoid2)
                end

                fn37 = function()
                  tbl18.antiDieEnabled = true
                  fn78()

                  if localPlayer.Character then
                    fn80(localPlayer.Character)
                  end

                  tbl29.charConn = localPlayer.CharacterAdded:Connect(function(character)
                    task.wait(0.15)

                    if tbl18.antiDieEnabled then
                      fn80(character)
                    end
                  end)

                  tbl29.hb = service.Heartbeat:Connect(function()
                    if not tbl18.antiDieEnabled then
                      return
                    end
                    local character = localPlayer.Character
                    character = character and character:FindFirstChildOfClass("Humanoid")

                    if character and character.Health <= 0 then
                      fn79(character)
                    end
                  end)
                end

                fn38 = function()
                  tbl18.antiDieEnabled = false
                  fn78()
                  local character = localPlayer.Character
                  local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

                  if humanoid2 then
                    pcall(function()
                      humanoid2:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                      humanoid2:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                      humanoid2:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    end)
                  end

                  if character then
                    local v86 = character:FindFirstChild(tbl29.ffName)

                    if v86 then
                      pcall(function()
                        v86:Destroy()
                      end)
                    end
                  end
                end
              end
            end

            do
              do
                fn39 = function()
                  local laggerSpeed2

                  if tbl18.laggerMode == 1 then
                    laggerSpeed2 = tbl18.laggerSpeed
                  elseif tbl18.laggerMode == 2 then
                    laggerSpeed2 = tbl18.laggerCarrySpeed
                  else
                    local flag20 = false

                    pcall(function()
                      flag20 = fn32(true)
                    end)

                    if not flag20 then
                      pcall(function()
                        flag20 = fn31()
                      end)
                    end

                    local speedToggled = tbl18.speedToggled

                    if speedToggled then
                      laggerSpeed2 = speedToggled
                    else
                      laggerSpeed2 = tbl18.autoChangeSpeed and flag20
                    end

                    laggerSpeed2 = laggerSpeed2 and tbl18.carrySpeed or tbl18.normalSpeed
                  end

                  return math.clamp(tonumber(laggerSpeed2) or tbl18.normalSpeed or 0, 1, 4000)
                end

                do
                  local tbl29 = {
                    idle1 = "rbxassetid://98281136301627",
                    idle2 = "rbxassetid://98281136301627",
                    walk = "rbxassetid://90478085024465",
                    run = "rbxassetid://134824450619865",
                    jump = "rbxassetid://121454505477205",
                    fall = "rbxassetid://94788218468396",
                    climb = "rbxassetid://121145883950231",
                    swim = "rbxassetid://94788218468396",
                    swimidle = "rbxassetid://98281136301627",
                  }

                  task.spawn(function()
                    task.wait(12)
                    if not tbl18.tryardAnimEnabled then
                      return
                    end

                    pcall(function()
                      service4:PreloadAsync({
                        tbl29.idle1,
                        tbl29.idle2,
                        tbl29.walk,
                        tbl29.run,
                        tbl29.jump,
                        tbl29.fall,
                        tbl29.climb,
                        tbl29.swim,
                        tbl29.swimidle,
                      })
                    end)
                  end)

                  local v86 = nil
                  local v87 = nil

                  local function fn78(arg)
                    for _, v88 in pairs(tbl29) do
                      if v88 == arg then
                        return true
                      end
                    end

                    return false
                  end

                  fn40 = function(arg)
                    local v88 = arg:FindFirstChild("HumanoidRootPart")
                    if not v88 then
                      return
                    end

                    local function fn79(arg2)
                      return arg2 and arg2.AnimationId or nil
                    end

                    local tbl30 = {
                      idle1 = fn79(v88.idle and v88.idle.Animation1),
                      idle2 = fn79(v88.idle and v88.idle.Animation2),
                      walk = fn79(v88.walk and v88.walk.WalkAnim),
                      run = fn79(v88.run and v88.run.RunAnim),
                      jump = fn79(v88.jump and v88.jump.JumpAnim),
                      fall = fn79(v88.fall and v88.fall.FallAnim),
                      climb = fn79(v88.climb and v88.climb.ClimbAnim),
                      swim = fn79(v88.swim and v88.swim.Swim),
                      swimidle = fn79(v88.swimidle and v88.swimidle.SwimIdle),
                    }

                    if not fn78(tbl30.walk) then
                      v87 = tbl30
                    end
                  end

                  fn41 = function(arg)
                    local animate = arg:FindFirstChild("Animate")
                    if not animate then
                      return
                    end

                    local function fn79(arg2, animationId)
                      if arg2 then
                        arg2.AnimationId = animationId
                      end
                    end

                    fn79(animate.idle and animate.idle.Animation1, tbl29.idle1)
                    fn79(animate.idle and animate.idle.Animation2, tbl29.idle2)
                    fn79(animate.walk and animate.walk.WalkAnim, tbl29.walk)
                    fn79(animate.run and animate.run.RunAnim, tbl29.run)
                    fn79(animate.jump and animate.jump.JumpAnim, tbl29.jump)
                    fn79(animate.fall and animate.fall.FallAnim, tbl29.fall)
                    fn79(animate.climb and animate.climb.ClimbAnim, tbl29.climb)
                    fn79(animate.swim and animate.swim.Swim, tbl29.swim)
                    fn79(animate.swimidle and animate.swimidle.SwimIdle, tbl29.swimidle)
                  end

                  fn42 = function()
                    if v86 then
                      v86:Disconnect()
                      v86 = nil
                    end

                    if v87 and localPlayer.Character then
                      local animate = localPlayer.Character:FindFirstChild("Animate")

                      if animate then
                        local function fn79(arg, animationId)
                          if arg then
                            arg.AnimationId = animationId
                          end
                        end

                        fn79(animate.idle and animate.idle.Animation1, v87.idle1)
                        fn79(animate.idle and animate.idle.Animation2, v87.idle2)
                        fn79(animate.walk and animate.walk.WalkAnim, v87.walk)
                        fn79(animate.run and animate.run.RunAnim, v87.run)
                        fn79(animate.jump and animate.jump.JumpAnim, v87.jump)
                        fn79(animate.fall and animate.fall.FallAnim, v87.fall)
                        fn79(animate.climb and animate.climb.ClimbAnim, v87.climb)
                        fn79(animate.swim and animate.swim.Swim, v87.swim)
                        fn79(animate.swimidle and animate.swimidle.SwimIdle, v87.swimidle)
                      end
                    end
                  end

                  fn43 = function()
                    if v86 then
                      v86:Disconnect()
                    end

                    local character = localPlayer.Character

                    if character then
                      fn40(character)
                      fn41(character)
                      local humanoid2 = character:FindFirstChildOfClass("Humanoid")

                      if humanoid2 then
                        for _, v88 in ipairs(humanoid2:GetPlayingAnimationTracks()) do
                          v88:Stop(0)
                        end

                        humanoid2:ChangeState(Enum.HumanoidStateType.Running)
                      end
                    end

                    v86 = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                      if not tbl18.tryardAnimEnabled then
                        return
                      end
                      local character2 = localPlayer.Character

                      if character2 then
                        fn41(character2)
                      end
                    end))
                  end

                  greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function(character)
                    task.wait(0.5)

                    if tbl18.tryardAnimEnabled and v86 then
                      fn40(character)
                      fn41(character)
                    end
                  end))
                end
              end

              _G.greenduelsHatOrder = {
                "Off",
                "8-Bit Royal Crown",
                "Purple Sparkle",
                "Pink Sparkle",
                "Red Sparkle",
                "Midnight Sparkle",
                "Green Sparkle",
                "Black Sparkle",
                "Fiery",
                "Bluesteel",
                "Frozen",
                "Golden",
                "Stormbreak",
              }

              _G.greenduelsHatAssets = {
                ["8-Bit Royal Crown"] = 10159600649,
                ["Purple Sparkle"] = 63043890,
                ["Pink Sparkle"] = 334663683,
                ["Red Sparkle"] = 72082328,
                ["Midnight Sparkle"] = 119916949,
                ["Green Sparkle"] = 100929604,
                ["Black Sparkle"] = 259423244,
                Fiery = 215718515,
                Bluesteel = 98346834,
                Frozen = 74891470,
                Poisoned = 1744060292,
                Stormbreak = 76479271580913,
              }

              _G.greenduelsKorbloxAssets = {
                ["Left Leg"] = {
                  id = "rbxassetid://139607673",
                  targetBodyPart = "LeftUpperLeg",
                  partsToHide = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
                },
                ["Right Leg"] = {
                  id = "rbxassetid://139607718",
                  targetBodyPart = "RightUpperLeg",
                  partsToHide = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
                },
              }

              _G.greenduelsClearKorblox = function()
                local character = localPlayer.Character
                if not character then
                  return
                end

                for _, v86 in ipairs({
                  "Korblox_LeftLeg",
                  "Korblox_RightLeg",
                  "Korblox_LeftArm",
                  "Korblox_RightArm",
                }) do
                  local v87 = character:FindFirstChild(v86)

                  if v87 then
                    pcall(function()
                      v87:Destroy()
                    end)
                  end
                end

                for _, v86 in ipairs({
                  "LeftUpperLeg",
                  "LeftLowerLeg",
                  "LeftFoot",
                  "RightUpperLeg",
                  "RightLowerLeg",
                  "RightFoot",
                }) do
                  local v87 = character:FindFirstChild(v86)

                  if v87 and v87:IsA("BasePart") then
                    v87.Transparency = 0
                    v87.LocalTransparencyModifier = 0
                  end
                end
              end

              _G.greenduelsAttachKorblox = function(arg)
                local v86 = _G.greenduelsKorbloxAssets[arg]
                local character = localPlayer.Character
                if not v86 or not character then
                  return false
                end
                local v87 = character:FindFirstChild(v86.targetBodyPart)
                if not v87 then
                  return false
                end
                local v88 = character:FindFirstChild("Korblox_" .. arg:gsub("%s+", ""))

                if v88 then
                  v88:Destroy()
                end

                for _, v89 in ipairs(v86.partsToHide) do
                  local v90 = character:FindFirstChild(v89)

                  if v90 and v90:IsA("BasePart") then
                    v90.Transparency = 1
                    v90.LocalTransparencyModifier = 1
                  end
                end

                local ok, result = pcall(function()
                  return game:GetObjects(v86.id)
                end)

                if not ok or not result or #result == 0 then
                  return false
                end
                local flag20 = localPlayer.Character ~= character

                if not flag20 then
                  flag20 = tbl18.cosmeticKorblox ~= "Both"

                  if flag20 then
                    flag20 = tbl18.cosmeticKorblox ~= (arg == "Left Leg" and "Left" or "Right")
                  end
                end

                if flag20 then
                  for _, v89 in ipairs(result) do
                    pcall(function()
                      v89:Destroy()
                    end)
                  end

                  return false
                end

                local v89 = result[1]
                v89.Name = "Korblox_" .. arg:gsub("%s+", "")
                local isBasePart = v89:IsA("BasePart") and v89
                  or v89:FindFirstChildWhichIsA("BasePart", true)

                if not isBasePart then
                  pcall(function()
                    v89:Destroy()
                  end)

                  return false
                end

                isBasePart.CanCollide = false
                isBasePart.CanTouch = false
                isBasePart.CanQuery = false
                isBasePart.Massless = true
                isBasePart.CFrame = v87.CFrame

                local weldConstraint = Instance.new("WeldConstraint")
                weldConstraint.Part0 = v87
                weldConstraint.Part1 = isBasePart
                weldConstraint.Parent = isBasePart

                v89.Parent = character
                return true
              end

              _G.greenduelsApplyKorblox = function(cosmeticKorblox)
                cosmeticKorblox = (
                  cosmeticKorblox == "Left"
                  or cosmeticKorblox == "Right"
                  or cosmeticKorblox == "Both"
                )
                    and cosmeticKorblox
                  or "Default"
                tbl18.cosmeticKorblox = cosmeticKorblox
                _G.greenduelsClearKorblox()

                if cosmeticKorblox == "Left" or cosmeticKorblox == "Both" then
                  pcall(_G.greenduelsAttachKorblox, "Left Leg")
                end

                if cosmeticKorblox == "Right" or cosmeticKorblox == "Both" then
                  pcall(_G.greenduelsAttachKorblox, "Right Leg")
                end
              end

              _G.greenduelsApplyHeadless = function(arg, arg2)
                tbl18.cosmeticHeadless = arg and true or false
                arg2 = arg2 or localPlayer.Character
                arg2 = arg2 and arg2:FindFirstChild("Handle")
                if not arg2 then
                  return
                end
                local cosmeticHeadless = tbl18.cosmeticHeadless and 1 or 0
                arg2.Transparency = cosmeticHeadless
                arg2.LocalTransparencyModifier = cosmeticHeadless

                for _, child in ipairs(arg2:GetChildren()) do
                  if child:IsA("Decal") or child:IsA("Texture") then
                    child.Transparency = cosmeticHeadless
                  elseif child:IsA("BasePart") then
                    child.Transparency = cosmeticHeadless
                    child.LocalTransparencyModifier = cosmeticHeadless
                  end
                end
              end

              _G.greenduelsClearHats = function(arg)
                local character = arg or localPlayer.Character
                if not character then
                  return
                end

                for _, child in ipairs(character:GetChildren()) do
                  if
                    child.Name:sub(1, 13) == "GreenDuelHat_"
                    or child:GetAttribute("GreenDuelHat") == true
                  then
                    pcall(function()
                      child:Destroy()
                    end)
                  end
                end
              end

              _G.greenduelsApplyHat = function(cosmeticHat, parent)
                cosmeticHat = _G.greenduelsHatAssets[cosmeticHat] and cosmeticHat or "Off"
                tbl18.cosmeticHat = cosmeticHat
                parent = parent or localPlayer.Character
                _G.greenduelsClearHats(parent)
                if cosmeticHat == "Off" or not parent then
                  return true
                end
                local v86 = _G.greenduelsHatAssets[cosmeticHat]

                local ok, result = pcall(function()
                  return game:GetObjects("rbxassetid://" .. tostring(v86))
                end)

                if not ok or not result or #result == 0 then
                  return false
                end

                if tbl18.cosmeticHat ~= cosmeticHat or localPlayer.Character ~= parent then
                  for _, v87 in ipairs(result) do
                    pcall(function()
                      v87:Destroy()
                    end)
                  end

                  return false
                end

                local v87 = result[1]

                local model = Instance.new("Model")
                model.Name = "GreenDuelHat_" .. cosmeticHat
                model:SetAttribute("GreenDuelHat", true)

                if v87:IsA("BasePart") then
                  v87.Parent = model
                else
                  for _, child in ipairs(v87:GetChildren()) do
                    child.Parent = model
                  end

                  pcall(function()
                    v87:Destroy()
                  end)
                end

                local handle = model:FindFirstChild("Handle")
                  or model:FindFirstChildWhichIsA("BasePart", true)
                if not handle then
                  model:Destroy()
                  return false
                end

                for _, descendant in ipairs(model:GetDescendants()) do
                  if descendant:IsA("BasePart") then
                    descendant.CanCollide = false
                    descendant.CanTouch = false
                    descendant.CanQuery = false
                    descendant.Massless = true
                    descendant.Anchored = false
                  end
                end

                local head = parent:FindFirstChild("Head")
                if not head then
                  model:Destroy()
                  return false
                end
                local attachment = handle:FindFirstChildWhichIsA("Attachment")
                local v88 = nil

                if attachment then
                  v88 = nil

                  for _, child in ipairs(parent:GetChildren()) do
                    if child:IsA("BasePart") then
                      v88 = child:FindFirstChild(attachment.Name)

                      if v88 and v88:IsA("Attachment") then
                        head = child
                        break
                      else
                        v88 = nil
                      end
                    else
                      v88 = nil
                    end
                  end
                end

                if attachment and v88 then
                  handle.CFrame = head.CFrame * v88.CFrame * attachment.CFrame:Inverse()
                else
                  handle.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
                end

                for _, descendant in ipairs(model:GetDescendants()) do
                  if descendant:IsA("BasePart") and descendant ~= handle then
                    local weldConstraint = Instance.new("WeldConstraint")
                    weldConstraint.Part0 = handle
                    weldConstraint.Part1 = descendant
                    weldConstraint.Parent = descendant
                  end
                end

                local instance2 = Instance.new("WeldConstraint")
                instance2.Part0 = head
                instance2.Part1 = handle
                instance2.Parent = handle

                model.Parent = parent
                return true
              end

              greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.9)
                pcall(_G.greenduelsApplyHeadless, tbl18.cosmeticHeadless, character)
                pcall(_G.greenduelsApplyKorblox, tbl18.cosmeticKorblox)
                pcall(_G.greenduelsApplyHat, tbl18.cosmeticHat, character)
              end))

              tbl21 = {
                { key = "drop", label = "DROP\nBR" },
                { key = "autoLeft", label = "AUTO\nLEFT" },
                { key = "aimbot", label = "BAT\nAIMBOT" },
                { key = "autoRight", label = "AUTO\nRIGHT" },
                { key = "tpDown", label = "TP\nDOWN" },
                { key = "carrySpeed", label = "CARRY\nSPD" },
                { key = "laggerCarry", label = "LAGGER\nCARRY" },
                { key = "lagger", label = "LAGGER\nMODE" },
                { key = "aimbot2", label = "TP\nAIMBOT" },
                { key = "reset", label = "RESET" },
              }

              fn44 = function(arg)
                local mobileButtonScale = tbl18.mobileButtonScale or 1
                local n34 = 58 * mobileButtonScale
                local n35 = 58 * mobileButtonScale
                local n36 = 40 * mobileButtonScale
                local n37 = #tbl21
                local n38 = math.floor((arg - 1) / 2)
                return UDim2.new(
                  1,
                  -(2 * (n34 + n36) - n36 + 14) + (arg - 1) % 2 * (n34 + n36),
                  0.5,
                  -(math.ceil(n37 / 2) * (n35 + n36) - n36) / 2 + n38 * (n35 + n36)
                )
              end

              tbl22 = {
                AutoStealEnabled = true,
                StealRadius = 9,
                StealRange = 7,
                StealDuration = 1.33,
                Delay = 8.6,
                Stop = 1,
                PauseProgress = false,
                RangeWait = 1.6,
                StealRadii = { Normal = 61, Semi = 85 },
                Data = {},
              }

              tbl23 = {}

              fn45 = function()
                if not isfile_("greenduelsPresets.json") then
                  return
                end
                local json = nil

                pcall(function()
                  json = readfile_("greenduelsPresets.json")
                end)

                if json then
                  local ok, result = pcall(function()
                    return service3:JSONDecode(json)
                  end)

                  if ok and result then
                    tbl23 = result
                  end
                end
              end

              fn46 = function()
                if not isfile_("greenduelsLastPreset.json") then
                  return nil
                end
                local json = nil

                pcall(function()
                  json = readfile_("greenduelsLastPreset.json")
                end)

                if json then
                  local ok, result = pcall(function()
                    return service3:JSONDecode(json)
                  end)

                  if ok and result then
                    return result.lastPreset
                  end
                end

                return nil
              end

              humanoid = nil
              v84 = nil
              fn47 = nil
              fn48 = nil
              infiniteJump = nil
              antiRagdoll = nil
              medusaCounter = nil
              setOn = nil
              v85 = nil
              autoSteal = nil
              fn49 = nil
              fn50 = nil
              fn51 = nil
              fn52 = nil
              fn53 = nil
              fn54 = nil
              fn55 = nil
              fn56 = nil
              fn57 = nil
              fn58 = nil
              stopDropBrainrot = nil
              fn59 = nil
              fn60 = nil
              fn61 = nil
              fn62 = nil
              batCounter = nil
              fn63 = nil
              fn64 = nil
              tbl24 = {}
              tbl25 = {}
              tbl26 = {}
              normalSpeed = nil
              carrySpeed = nil
              laggerSpeed = nil
              laggerCarrySpeed = nil
              uiScale = nil
              mobileButtonsSize = nil
              stealBarSize = nil
              Radius = nil
              Duration = nil
              instance = nil
              uiScale2 = nil

              fn65 = function()
                local mobileButtonScale =
                  math.clamp(tonumber(tbl18.mobileButtonScale) or 1, 0.5, 2)
                tbl18.mobileButtonScale = mobileButtonScale

                for i, v86 in ipairs(tbl21) do
                  local v87 = tbl25[v86.key]

                  if v87 then
                    local v88 = 0
                    local floor2 = math.floor
                    local n34 = 36 * mobileButtonScale + 0.5
                    v87.Size = UDim2.new(
                      0,
                      math.floor(58 * mobileButtonScale + 0.5),
                      v88,
                      floor2(n34)
                    )
                    v87.TextSize = math.clamp(math.floor(11 * mobileButtonScale + 0.5), 8, 18)
                    v87.Position = fn44(i)
                  end
                end
              end

              fn66 = function()
                local stealBarScale = math.clamp(tonumber(tbl18.stealBarScale) or 1, 0.5, 2)
                tbl18.stealBarScale = stealBarScale

                if uiScale2 then
                  uiScale2.Scale = stealBarScale
                end
              end

              safeMode = nil
              fn67 = nil
              toggleSetters = {}
              textButton = nil
              textButton2 = nil
              textLabel = nil
              flag18 = false

              fn68 = function()
                local character = localPlayer.Character
                local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                return humanoid2 and humanoid2.WalkSpeed < 25
              end

              fn69 = function()
                return tbl18.safeMode and fn68()
              end

              fn70 = function()
                if not fn69() then
                  return false
                end

                if tbl18.autoLeftEnabled then
                  tbl18.autoLeftEnabled = false

                  if fn54 then
                    pcall(fn54)
                  end

                  if tbl24.autoLeft then
                    tbl24.autoLeft.setOn(false)
                  end

                  if fn47 then
                    pcall(fn47, false)
                  end
                end

                if tbl18.autoRightEnabled then
                  tbl18.autoRightEnabled = false

                  if fn56 then
                    pcall(fn56)
                  end

                  if tbl24.autoRight then
                    tbl24.autoRight.setOn(false)
                  end

                  if fn48 then
                    pcall(fn48, false)
                  end
                end

                if tbl18.batAimbotToggled then
                  tbl18.batAimbotToggled = false

                  if fn60 then
                    pcall(fn60)
                  end

                  if tbl24.aimbot then
                    tbl24.aimbot.setOn(false)
                  end

                  if setOn then
                    pcall(setOn, false)
                  end
                end

                if tbl18.aimbot2Toggled and tbl18.tpBatMode ~= "AntiHit" then
                  tbl18.aimbot2Toggled = false

                  if fn64 then
                    pcall(fn64)
                  end

                  if tbl24.aimbot2 then
                    tbl24.aimbot2.setOn(false)
                  end

                  if tbl24.aimbot then
                    tbl24.aimbot.setOn(false)
                  end

                  if toggleSetters["Aimbot"] and not tbl18.autoBatBypass then
                    pcall(toggleSetters.aimbot, false)
                  end

                  if toggleSetters.aimbot2 then
                    pcall(toggleSetters.aimbot2, false)
                  end
                end

                return true
              end

              do
                local n34 = 0

                greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                  if tbl18.safeMode then
                    local now2 = tick()

                    if now2 - n34 > 0.12 then
                      n34 = now2
                      fn70()
                    end
                  end
                end))
              end
            end

            do
              tbl27 = {
                winBg = Color3.fromRGB(9, 17, 14),
                winBg2 = Color3.fromRGB(12, 22, 18),
                winBorder = Color3.fromRGB(32, 81, 54),
                sidebarBg = Color3.fromRGB(2, 10, 20),
                sidebarDiv = Color3.fromRGB(18, 28, 28),
                topBg = Color3.fromRGB(8, 19, 18),
                topTitle = Color3.fromRGB(235, 250, 240),
                topSub = Color3.fromRGB(113, 165, 134),
                topBtn = Color3.fromRGB(14, 24, 18),
                topBtnHov = Color3.fromRGB(170, 45, 56),
                topDivider = Color3.fromRGB(23, 58, 38),
                tabBarBg = Color3.fromRGB(2, 10, 6),
                tabBarDiv = Color3.fromRGB(18, 44, 34),
                tabIdle = Color3.fromRGB(105, 155, 122),
                tabIdleHov = Color3.fromRGB(160, 210, 180),
                tabActive = Color3.fromRGB(230, 245, 235),
                tabActiveBg = Color3.fromRGB(10, 34, 14),
                tabUnderline = Color3.fromRGB(30, 132, 73),
                sectionTxt = Color3.fromRGB(93, 207, 141),
                sectionDiv = Color3.fromRGB(18, 28, 28),
                rowBg = Color3.fromRGB(19, 33, 26),
                rowBorder = Color3.fromRGB(31, 54, 40),
                rowLabel = Color3.fromRGB(210, 190, 228),
                rowSub = Color3.fromRGB(125, 164, 142),
                rowValue = Color3.fromRGB(138, 180, 173),
                rowHov = Color3.fromRGB(0, 45, 33),
                inputBg = Color3.fromRGB(9, 23, 15),
                inputBorder = Color3.fromRGB(39, 111, 65),
                inputFocus = Color3.fromRGB(42, 230, 123),
                inputTxt = Color3.fromRGB(154, 255, 191),
                pillOff = Color3.fromRGB(35, 48, 41),
                pillOn = Color3.fromRGB(52, 90, 96),
                dotOff = Color3.fromRGB(58, 92, 70),
                dotOn = Color3.fromRGB(211, 200, 140),
                pillBorder = Color3.fromRGB(40, 76, 46),
                modeBtnBg = Color3.fromRGB(6, 14, 10),
                modeBtnBrd = Color3.fromRGB(34, 70, 28),
                modeBtnTxt = Color3.fromRGB(180, 225, 210),
                modeBtnActBg = Color3.fromRGB(46, 190, 105),
                modeBtnActTx = Color3.fromRGB(0, 18, 4),
                chipBg = Color3.fromRGB(8, 14, 12),
                chipBorder = Color3.fromRGB(28, 32, 44),
                chipTxt = Color3.fromRGB(78, 245, 145),
                btnBg = Color3.fromRGB(12, 45, 21),
                btnBorder = Color3.fromRGB(28, 76, 46),
                btnTxt = Color3.fromRGB(160, 239, 207),
                btnHov = Color3.fromRGB(20, 65, 33),
                stackBg = Color3.fromRGB(10, 70, 34),
                stackBrd = Color3.fromRGB(160, 210, 108),
                stackTxt = Color3.fromRGB(190, 255, 236),
                stackOn = Color3.fromRGB(36, 160, 92),
                stackActBg = Color3.fromRGB(42, 210, 95),
                stackActTxt = Color3.fromRGB(0, 25, 8),
                stackActBrd = Color3.fromRGB(24, 255, 185),
                accent = Color3.fromRGB(42, 230, 123),
                accent2 = Color3.fromRGB(23, 163, 83),
                danger = Color3.fromRGB(255, 90, 90),
                ok = Color3.fromRGB(46, 190, 105),
              }

              fn71 = function(arg, arg2)
                local instance2 = Instance.new("UICorner", arg)
                instance2.CornerRadius = UDim.new(0, arg2 or 6)
                return instance2
              end

              createUIStroke = function(arg, color, thickness)
                local uiStroke = Instance.new("UIStroke", arg)
                uiStroke.Color = color
                uiStroke.Thickness = thickness or 1
                uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                return uiStroke
              end

              n33 = 0

              fn72 = function(arg)
                local character = localPlayer.Character
                if not character then
                  return
                end
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                  return
                end
                local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                if not humanoid2 then
                  return
                end

                if not arg then
                  if humanoid2.FloorMaterial ~= Enum.Material.Air then
                    return
                  end

                  if humanoidRootPart.Position.Y < 20 then
                    return
                  end
                end

                local v86, v87 = humanoidRootPart.CFrame:ToEulerAnglesYXZ()
                humanoidRootPart.CFrame = CFrame.new(
                  humanoidRootPart.Position.X,
                  -7,
                  humanoidRootPart.Position.Z
                ) * CFrame.Angles(0, v87, 0)
                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
              end

              fn73 = function()
                pcall(function()
                  fn72(true)
                end)
              end

              flag19 = false

              tbl28 = {
                busy = false,
                busyAt = 0,
                queued = false,
                queuedUntil = 0,
                cameraHeld = false,
                cameraHeldAt = 0,
              }

              do
                local greenDuelsAntiCrasher = _G.GreenDuelsAntiCrasher or {}
                _G.GreenDuelsAntiCrasher = greenDuelsAntiCrasher
                greenDuelsAntiCrasher.resetWindow = 1.5
                greenDuelsAntiCrasher.spamThreshold = 2
                greenDuelsAntiCrasher.lastDeathTime = 0
                greenDuelsAntiCrasher.deathCount = 0
                greenDuelsAntiCrasher.spamProtectionActive = false
                greenDuelsAntiCrasher.resetsBlocked = greenDuelsAntiCrasher.resetsBlocked
                  or 0

                fn74 = function()
                  return tbl18.antiCrasherEnabled
                    and greenDuelsAntiCrasher.spamProtectionActive == true
                end

                local function fn78(status)
                  greenDuelsAntiCrasher.status = status
                end

                local function fn79()
                  if greenDuelsAntiCrasher.spamProtectionActive then
                    return
                  end
                  greenDuelsAntiCrasher.spamProtectionActive = true
                  fn78("BLOCKING RESETS")
                  local now2 = os.clock()

                  while os.clock() - now2 < 3 do
                    if tbl18.antiCrasherEnabled then
                      local character = localPlayer.Character
                      local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

                      if humanoid2 and humanoid2.Health <= 0 then
                        pcall(function()
                          humanoid2.Health = math.max(humanoid2.MaxHealth, 100)
                        end)

                        greenDuelsAntiCrasher.resetsBlocked = greenDuelsAntiCrasher.resetsBlocked
                          + 1
                      end

                      task.wait(0.05)
                      continue
                    end

                    break
                  end

                  greenDuelsAntiCrasher.spamProtectionActive = false
                  fn78("Idle")
                end

                fn75 = function(character)
                  if greenDuelsAntiCrasher.stateConnection then
                    pcall(function()
                      greenDuelsAntiCrasher.stateConnection:Disconnect()
                    end)

                    greenDuelsAntiCrasher.stateConnection = nil
                  end

                  greenDuelsAntiCrasher.enabled = tbl18.antiCrasherEnabled
                  greenDuelsAntiCrasher.lastDeathTime = 0
                  greenDuelsAntiCrasher.deathCount = 0
                  greenDuelsAntiCrasher.spamProtectionActive = false
                  if not character then
                    return
                  end
                  local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                    or character:WaitForChild("Humanoid", 3)
                  if not humanoid2 then
                    return
                  end
                  greenDuelsAntiCrasher.character = character
                  greenDuelsAntiCrasher.humanoid = humanoid2

                  greenDuelsAntiCrasher.stateConnection = humanoid2.StateChanged:Connect(
                    function(old, new)
                      if new ~= Enum.HumanoidStateType.Dead then
                        return
                      end
                      local now2 = os.clock()

                      if
                        tbl18.antiCrasherEnabled
                        and not greenDuelsAntiCrasher.spamProtectionActive
                      then
                        if
                          now2 - greenDuelsAntiCrasher.lastDeathTime
                          < greenDuelsAntiCrasher.resetWindow
                        then
                          greenDuelsAntiCrasher.deathCount = greenDuelsAntiCrasher.deathCount
                            + 1
                        else
                          greenDuelsAntiCrasher.deathCount = 1
                        end

                        if
                          greenDuelsAntiCrasher.spamThreshold
                          <= greenDuelsAntiCrasher.deathCount
                        then
                          warn(
                            "[greenduels] Anti Crasher detected reset spam: "
                              .. tostring(greenDuelsAntiCrasher.deathCount)
                          )
                          greenDuelsAntiCrasher.deathCount = 0
                          task.spawn(fn79)
                        else
                          fn78("Spam Detected")
                        end
                      end

                      greenDuelsAntiCrasher.lastDeathTime = now2
                    end
                  )
                end
              end
            end

            _G.GreenDuelsAntiDrop = _G.GreenDuelsAntiDrop or {}

            _G.GreenDuelsSetupAntiDropWatcher = function(arg)
              if _G.GreenDuelsAntiDrop.healthConnection then
                pcall(function()
                  _G.GreenDuelsAntiDrop.healthConnection:Disconnect()
                end)

                _G.GreenDuelsAntiDrop.healthConnection = nil
              end

              if _G.GreenDuelsAntiDrop.diedConnection then
                pcall(function()
                  _G.GreenDuelsAntiDrop.diedConnection:Disconnect()
                end)

                _G.GreenDuelsAntiDrop.diedConnection = nil
              end

              if _G.GreenDuelsAntiDrop.childAddedConnection then
                pcall(function()
                  _G.GreenDuelsAntiDrop.childAddedConnection:Disconnect()
                end)

                _G.GreenDuelsAntiDrop.childAddedConnection = nil
              end

              if _G.GreenDuelsAntiDrop.childRemovedConnection then
                pcall(function()
                  _G.GreenDuelsAntiDrop.childRemovedConnection:Disconnect()
                end)

                _G.GreenDuelsAntiDrop.childRemovedConnection = nil
              end

              if not arg then
                return
              end
              local humanoid2 = arg:FindFirstChildOfClass("Humanoid")
                or arg:WaitForChild("Humanoid", 3)
              if not humanoid2 then
                return
              end
              _G.GreenDuelsAntiDrop.humanoid = humanoid2

              _G.GreenDuelsAntiDrop.healthConnection = humanoid2
                :GetPropertyChangedSignal("Health")
                :Connect(function()
                  if
                    tbl18.antiDropEnabled
                    and humanoid2.Health > 0
                    and humanoid2.Health < humanoid2.MaxHealth
                  then
                    pcall(function()
                      humanoid2.Health = humanoid2.MaxHealth
                    end)
                  end
                end)

              _G.GreenDuelsAntiDrop.diedConnection = humanoid2.Died:Connect(function()
                if tbl18.antiDropEnabled then
                  task.wait()

                  pcall(function()
                    humanoid2.Health = math.max(humanoid2.MaxHealth, 100)
                  end)
                end
              end)

              local function fn78(arg2)
                if arg2 then
                  local flag20 = arg2:IsA("Tool") and not fn76(arg2.Name)

                  if flag20 then
                    arg2 = flag20
                  else
                    arg2 = arg2:IsA("Model") and not fn77(arg2)
                  end
                end

                return arg2
              end

              _G.GreenDuelsAntiDrop.childAddedConnection = arg.ChildAdded:Connect(function(child)
                if tbl18.antiDropEnabled and fn78(child) then
                  local now2 = tick()
                  _G.GreenDuelsAntiDrop.carryGraceUntil = now2 + 2.5
                  _G.GreenDuelsAntiDrop.forceLiftUntil = now2 + 0.75
                  _G.GreenDuelsAntiDrop.lastCarryObject = child
                end
              end)

              _G.GreenDuelsAntiDrop.childRemovedConnection = arg.ChildRemoved:Connect(
                function(child)
                  if tbl18.antiDropEnabled and fn78(child) then
                    local now2 = tick()
                    _G.GreenDuelsAntiDrop.carryGraceUntil = now2 + 2
                    _G.GreenDuelsAntiDrop.forceLiftUntil = now2 + 0.65
                    _G.GreenDuelsAntiDrop.dropPulseUntil = now2 + 0.45
                    local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")

                    if humanoidRootPart then
                      humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 58, 0)
                    end

                    task.defer(function()
                      local humanoid3 = arg:FindFirstChildOfClass("Humanoid")

                      if
                        humanoid3
                        and child
                        and child.Parent == localPlayer:FindFirstChild("Backpack")
                      then
                        pcall(function()
                          humanoid3:EquipTool(child)
                        end)
                      end
                    end)
                  end
                end
              )
            end
          end

          _G.GreenDuelsSetAntiDropEnabled = function(arg)
            tbl18.antiDropEnabled = arg == true
            _G.GreenDuelsAntiDrop.enabled = tbl18.antiDropEnabled

            pcall(function()
              game
                :GetService("StarterGui")
                :SetCore("ResetButtonCallback", not tbl18.antiDropEnabled)
            end)

            _G.GreenDuelsSetupAntiDropWatcher(localPlayer.Character)
          end

          _G.GreenDuelsAntiDrop.spoofedVelocity = Vector3.zero
          _G.GreenDuelsAntiDrop.zoneParts = _G.GreenDuelsAntiDrop.zoneParts or {}
          _G.GreenDuelsAntiDrop.nextZoneScan = 0

          _G.GreenDuelsAntiDropScanCollectZones = function()
            local now2 = tick()
            if now2 < (_G.GreenDuelsAntiDrop.nextZoneScan or 0) then
              return
            end
            _G.GreenDuelsAntiDrop.nextZoneScan = now2 + 1
            table.clear(_G.GreenDuelsAntiDrop.zoneParts)

            for _, descendant in ipairs(workspace:GetDescendants()) do
              if descendant:IsA("BasePart") then
                local str6 = descendant.Name:lower()
                local color, flag20, canTouch, flag21, n34

                if
                  str6:find("collect")
                  or str6:find("deposit")
                  or str6:find("Medusa")
                  or str6:find("sell")
                  or str6:find("zone")
                then
                  _G.GreenDuelsAntiDrop.zoneParts[#_G.GreenDuelsAntiDrop.zoneParts + 1] = descendant

                  if not (#_G.GreenDuelsAntiDrop.zoneParts >= 80) then
                    color = descendant.Color
                    flag20 = color.G > 0.45
                      and color.G > color.R + 0.12
                      and color.G > color.B + 0.12
                    canTouch = descendant.CanTouch
                      or descendant:FindFirstChildOfClass("TouchTransmitter") ~= nil
                    flag21 = descendant.Size.X >= 40
                      and descendant.Size.Z >= 40
                      and descendant.Size.Y <= 6
                    flag21 = canTouch and flag21
                    flag20 = flag21 and flag20

                    if flag20 then
                      n34 = #_G.GreenDuelsAntiDrop.zoneParts + 1
                      _G.GreenDuelsAntiDrop.zoneParts[n34] = descendant
                      if not (100 <= #_G.GreenDuelsAntiDrop.zoneParts) then
                        continue
                      end
                    else
                      continue
                    end
                  end
                else
                  color = descendant.Color
                  flag20 = color.G > 0.45 and color.G > color.R + 0.12 and color.G > color.B + 0.12
                  canTouch = descendant.CanTouch
                    or descendant:FindFirstChildOfClass("TouchTransmitter") ~= nil
                  flag21 = descendant.Size.X >= 40
                    and descendant.Size.Z >= 40
                    and descendant.Size.Y <= 6
                  flag21 = canTouch and flag21
                  flag20 = flag21 and flag20

                  if flag20 then
                    n34 = #_G.GreenDuelsAntiDrop.zoneParts + 1
                    _G.GreenDuelsAntiDrop.zoneParts[n34] = descendant
                    if not (100 <= #_G.GreenDuelsAntiDrop.zoneParts) then
                      continue
                    end
                  else
                    continue
                  end
                end
              else
                continue
              end

              break
            end

            local v86 = ipairs
            local slowParts = _autoCarryV2 and _autoCarryV2.slowParts or {}

            for _, slowPart in v86(slowParts) do
              if slowPart and slowPart.Parent then
                _G.GreenDuelsAntiDrop.zoneParts[#_G.GreenDuelsAntiDrop.zoneParts + 1] = slowPart
                if not (#_G.GreenDuelsAntiDrop.zoneParts >= 120) then
                  continue
                end
              else
                continue
              end

              break
            end
          end

          _G.GreenDuelsAntiDropMovingIntoCollectZone = function(arg, arg2)
            _G.GreenDuelsAntiDropScanCollectZones()

            for _, zonePart in ipairs(_G.GreenDuelsAntiDrop.zoneParts) do
              if zonePart and zonePart.Parent then
                local n34 = arg.Position
                  + arg2
                    * math.clamp(
                      Vector3.new(arg.AssemblyLinearVelocity.X, 0, arg.AssemblyLinearVelocity.Z).Magnitude
                        * 0.2,
                      5,
                      18
                    )
                local v86 = zonePart.CFrame:PointToObjectSpace(arg.Position)
                local n35 = zonePart.Size * 0.5
                local clamp = math.clamp
                local z = v86.Z
                local n36 = -n35.Z
                local z2 = n35.Z
                local position = arg.Position
                local n37 = zonePart.CFrame:PointToWorldSpace(
                  Vector3.new(
                    math.clamp(v86.X, -n35.X, n35.X),
                    math.clamp(v86.Y, -n35.Y, n35.Y),
                    clamp(z, n36, z2)
                  )
                ) - position
                local vector = Vector3.new(n37.X, 0, n37.Z)
                if vector.Magnitude <= 4.5 then
                  return true
                end

                if
                  vector.Magnitude <= 11
                  and vector.Magnitude > 1
                  and arg2:Dot(vector.Unit) > 0.02
                then
                  return true
                end
                local v87 = zonePart.CFrame:PointToObjectSpace(n34)
                local clamp2 = math.clamp
                local z3 = v87.Z
                local n38 = -n35.Z
                local z4 = n35.Z
                local v88 = zonePart.CFrame:PointToWorldSpace(
                  Vector3.new(
                    math.clamp(v87.X, -n35.X, n35.X),
                    math.clamp(v87.Y, -n35.Y, n35.Y),
                    clamp2(z3, n38, z4)
                  )
                )
                if Vector3.new((v88 - n34).X, 0, (v88 - n34).Z).Magnitude <= 5.5 then
                  return true
                end
              end
            end

            return false
          end

          greenduelsPerfRun.track(service.PreSimulation:Connect(function()
            if not tbl18.antiDropEnabled then
              return
            end
            local character = localPlayer.Character
            local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
            local v86 = character and character:FindFirstChild("HumanoidRootPart")
            if not character or not humanoid2 or not v86 or humanoid2.Health <= 0 then
              return
            end
            local v87 = false

            pcall(function()
              v87 = fn32 and fn32(true) or fn68()
            end)

            local now2 = tick()

            if v87 then
              _G.GreenDuelsAntiDrop.carryGraceUntil = now2 + 1.4
            end

            local flag20 = _autoCarryV2

            if flag20 then
              flag20 = now2 < (_autoCarryV2.watchUntil or 0)
            end

            if flag20 then
              v87 = true
            end

            local flag21 = not v87

            if flag21 then
              flag21 = now2 >= (_G.GreenDuelsAntiDrop.carryGraceUntil or 0)
            end

            if flag21 then
              return
            end
            local moveDirection = humanoid2.MoveDirection

            if moveDirection.Magnitude > 0.05 then
              pcall(function()
                if v86.SetNetworkOwner then
                  v86:SetNetworkOwner(localPlayer)
                end
              end)

              local unit = moveDirection.Unit
              local flag22 = now2 < (_G.GreenDuelsAntiDrop.forceLiftUntil or 0)

              if not flag22 then
                flag22 = now2 < (_G.GreenDuelsAntiDrop.dropPulseUntil or 0)
              end

              local flag23

              if flag22 then
                flag23 = flag22
              else
                flag23 = now2 < (_G.GreenDuelsAntiDrop.carryGraceUntil or 0)
                  and humanoid2.FloorMaterial ~= Enum.Material.Air
              end

              if flag23 then
                local n34 = math.max(v86.AssemblyLinearVelocity.Y, 62)
                _G.GreenDuelsAntiDrop.spoofedVelocity =
                  Vector3.new(unit.X * 12, n34, unit.Z * 12)
                v86.AssemblyLinearVelocity = Vector3.new(unit.X * 12, n34, unit.Z * 12)
                return
              end

              if _G.GreenDuelsAntiDropMovingIntoCollectZone(v86, unit) then
                if (_G.GreenDuelsAntiDrop.nextZoneBumpAt or 0) <= now2 then
                  _G.GreenDuelsAntiDrop.nextZoneBumpAt = now2 + 1

                  pcall(function()
                    local v88, v89 = v86.CFrame:ToEulerAnglesYXZ()
                    v86.CFrame = CFrame.new(
                      v86.Position.X - unit.X * 2.8,
                      v86.Position.Y + 3.2,
                      v86.Position.Z - unit.Z * 2.8
                    ) * CFrame.Angles(0, v89, 0)
                  end)
                end

                _G.GreenDuelsAntiDrop.spoofedVelocity =
                  Vector3.new(-unit.X * 12, v86.AssemblyLinearVelocity.Y, -unit.Z * 12)
                local n34 = -unit.Z * 12
                v86.AssemblyLinearVelocity =
                  Vector3.new(-unit.X * 12, math.max(v86.AssemblyLinearVelocity.Y, 0), n34)
                return
              end

              local n34 = math.clamp(
                tonumber(tbl18.laggerMode == 2 and tbl18.laggerCarrySpeed or tbl18.carrySpeed) or 59,
                1,
                500
              )
              _G.GreenDuelsAntiDrop.spoofedVelocity =
                Vector3.new(unit.X * 16, v86.AssemblyLinearVelocity.Y, unit.Z * 12)
              v86.AssemblyLinearVelocity =
                Vector3.new(unit.X * n34, v86.AssemblyLinearVelocity.Y, unit.Z * n34)
            else
              _G.GreenDuelsAntiDrop.spoofedVelocity =
                Vector3.new(0, v86.AssemblyLinearVelocity.Y, 0)
            end
          end))

          _G.__GDIR = _G.__GDIR or {}
          _G.__GDIR.physicsSpeed = tonumber(_G.__GDIR.physicsSpeed) or 1000000

          do
            local gdir = _G.__GDIR
            local clamp = math.clamp
            local floor2 = math.floor
            local n34 = tonumber(_G.__GDIR.physicsPulses) or 2
            local v86 = 20
            gdir.physicsPulses = clamp(floor2(n34), 1, v86)
          end
        end

        local greenduelsInstantReset, fn76, fn77, fn78, fn79, fn80, fn81, fn82, flag20, fn83
        local fn84, v86

        do
          do
            do
              local fn85

              do
                _G.__GDIR.physicsDirection = (tonumber(_G.__GDIR.physicsDirection) or 1) < 0 and -1
                  or 1

                do
                  local function fn86()
                    tbl28.queued = true
                    local v87 = 16
                    tbl28.queuedUntil = os.clock() + v87
                  end

                  fn85 = function(arg)
                    task.spawn(function()
                      local currentCamera = Workspace.CurrentCamera

                      if currentCamera then
                        currentCamera.CameraType = Enum.CameraType.Custom
                      end

                      local humanoid2 = arg
                        and (arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid", 3))
                      local currentCamera2 = Workspace.CurrentCamera

                      if currentCamera2 then
                        currentCamera2.CameraType = Enum.CameraType.Custom

                        if humanoid2 then
                          currentCamera2.CameraSubject = humanoid2
                        end

                        if _G.greenduelsApplyFovState then
                          pcall(_G.greenduelsApplyFovState)
                        end
                      end
                    end)
                  end

                  local function fn87(arg)
                    local v87 = arg and arg:FindFirstChild("HumanoidRootPart")
                    if not v87 or not v87:IsA("BasePart") then
                      return false
                    end
                    local humanoid2 = arg:FindFirstChildOfClass("Humanoid")

                    if humanoid2 and humanoid2.Health > 0 then
                      pcall(function()
                        humanoid2:ChangeState(Enum.HumanoidStateType.Freefall)
                      end)
                    end

                    local n34 = math.clamp(
                      math.abs(tonumber(_G.__GDIR.physicsSpeed) or 45),
                      1000,
                      10000000
                    )
                    local vector = Vector3.new(
                      0,
                      ((tonumber(_G.__GDIR.physicsDirection) or 1) < 0 and -1 or 1) * n34,
                      0
                    )

                    local function fn88()
                      if not v87.Parent then
                        return false
                      end

                      return pcall(function()
                        v87.AssemblyAngularVelocity = Vector3.zero
                        v87.AssemblyLinearVelocity = vector
                      end)
                    end

                    if humanoid2 then
                      pcall(function()
                        humanoid2.PlatformStand = true
                        humanoid2:ChangeState(Enum.HumanoidStateType.Freefall)
                      end)
                    end

                    if not fn88() then
                      return false
                    end

                    task.spawn(function()
                      local preSimulation = service.PreSimulation
                        or service.Stepped
                        or service.Heartbeat
                      local n35 = 0

                      while n35 < 1.5 do
                        local result = preSimulation:Wait()
                        n35 += type(result) == "number" and result or 0.1
                        if not v87.Parent or localPlayer.Character ~= arg then
                          return
                        end
                        fn88()
                      end
                    end)

                    return true
                  end

                  local function fn88(arg)
                    local cameraHeld = tbl28.cameraHeld

                    if cameraHeld then
                      cameraHeld = os.clock() - (tbl28.cameraHeldAt or 0) < 5
                    end

                    if cameraHeld then
                      return
                    end
                    local currentCamera = Workspace.CurrentCamera
                    if not currentCamera then
                      return
                    end
                    tbl28.cameraHeld = true
                    tbl28.cameraHeldAt = os.clock()
                    local cFrame = currentCamera.CFrame
                    local focus = currentCamera.Focus
                    local v87 = nil
                    local v88 = nil
                    local v89 = nil

                    local function fn89(cameraSubject)
                      if v87 then
                        v87:Disconnect()
                        v87 = nil
                      end

                      local currentCamera2 = Workspace.CurrentCamera or currentCamera

                      if currentCamera2 then
                        currentCamera2.CameraType = Enum.CameraType.Custom
                        cameraSubject = cameraSubject
                          and cameraSubject:FindFirstChildOfClass("Humanoid")

                        if cameraSubject then
                          currentCamera2.CameraSubject = cameraSubject
                        end

                        if _G.greenduelsApplyFovState then
                          pcall(_G.greenduelsApplyFovState)
                        end
                      end
                    end

                    local function fn90(character)
                      if not character or v89 == character then
                        return
                      end
                      v89 = character
                      fn89(character)

                      if v88 then
                        v88:Disconnect()
                        v88 = nil
                      end

                      task.spawn(function()
                        local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                          or character:WaitForChild("Humanoid", 2)
                        local currentCamera2 = Workspace.CurrentCamera or currentCamera

                        if currentCamera2 then
                          currentCamera2.CameraType = Enum.CameraType.Custom

                          if humanoid2 then
                            currentCamera2.CameraSubject = humanoid2
                          end

                          if _G.greenduelsApplyFovState then
                            pcall(_G.greenduelsApplyFovState)
                          end
                        end
                      end)
                    end

                    currentCamera.CameraType = Enum.CameraType.Scriptable
                    currentCamera.CFrame = cFrame
                    currentCamera.Focus = focus

                    v87 = greenduelsPerfRun.track(service.RenderStepped:Connect(function()
                      if Workspace.CurrentCamera ~= currentCamera then
                        return
                      end
                      currentCamera.CameraType = Enum.CameraType.Scriptable
                      currentCamera.CFrame = cFrame
                      currentCamera.Focus = focus
                    end))

                    local v90 = greenduelsPerfRun.track(
                      localPlayer.CharacterRemoving:Connect(function(character)
                        if character == arg then
                          fn89(nil)
                        end
                      end)
                    )

                    v88 = greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(fn90))

                    task.spawn(function()
                      local n34 = 0

                      while localPlayer.Character == arg and n34 < 3 do
                        n34 += task.wait()
                      end

                      local character = localPlayer.Character
                      fn89(character ~= arg and character or nil)

                      if character and character ~= arg then
                        fn90(character)
                      end

                      if v90 then
                        v90:Disconnect()
                        v90 = nil
                      end

                      if v88 then
                        v88:Disconnect()
                        v88 = nil
                      end

                      tbl28.cameraHeld = false
                    end)
                  end

                  greenduelsInstantReset = function()
                    if fn74() then
                      return
                    end

                    if flag19 then
                      return
                    end
                    local character = localPlayer.Character
                    local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                    local humanoidRootPart = character
                      and character:FindFirstChild("HumanoidRootPart")

                    if
                      not (
                        not character
                        or not humanoid2
                        or not humanoidRootPart
                        or not humanoidRootPart:IsA("BasePart")
                      )
                    then
                      if humanoid2.Health <= 0 then
                        fn87(character)
                        fn86()
                        return
                      end

                      local busy = tbl28.busy

                      if busy then
                        busy = os.clock() - (tbl28.busyAt or 0) < 5
                      end

                      if busy then
                        return
                      end
                      tbl28.busy = true
                      tbl28.busyAt = os.clock()
                      flag19 = true

                      task.spawn(function()
                        fn88(character)
                        fn87(character)
                        local n34 = 0

                        while localPlayer.Character == character and n34 < 3 do
                          n34 += task.wait()
                        end

                        flag19 = false
                        tbl28.busy = false
                      end)

                      return
                    end

                    fn86()
                    return
                  end
                end
              end

              do
                _G.greenduelsInstantReset = greenduelsInstantReset

                _G.greenduelsResetPhysicsTune = function(arg, arg2, arg3)
                  local num = tonumber(arg)

                  if num then
                    _G.__GDIR.physicsSpeed = math.clamp(math.abs(num), 1000, 10000000)
                  end

                  local num2 = tonumber(arg2)

                  if num2 then
                    _G.__GDIR.physicsPulses = math.clamp(math.floor(num2), 1, 6)
                  end

                  local flag21 = arg3 == "down"
                  local flag22

                  if flag21 then
                    flag22 = flag21
                  else
                    local n34 = -1
                    flag22 = tonumber(arg3) == n34
                  end

                  if flag22 then
                    _G.__GDIR.physicsDirection = -1
                  end

                  if arg3 == "up" or tonumber(arg3) == 1 then
                    _G.__GDIR.physicsDirection = 1
                  end

                  return _G.__GDIR.physicsSpeed,
                    _G.__GDIR.physicsPulses,
                    _G.__GDIR.physicsDirection < 0 and "down" or "up"
                end

                do
                  local flag21 = false
                  local tbl29 = {}

                  fn76 = function()
                    for _, v87 in ipairs(tbl29) do
                      pcall(function()
                        v87:Disconnect()
                      end)
                    end

                    tbl29 = {}
                  end

                  local function fn86(arg)
                    return arg:GetPropertyChangedSignal("Anchored"):Connect(function()
                      if not tbl18.resetOnMedusa or not arg.Anchored then
                        return
                      end

                      if not (arg.Transparency >= 0.95 or arg.Name == "HumanoidRootPart") then
                        return
                      end

                      if flag21 then
                        return
                      end
                      flag21 = true

                      task.spawn(function()
                        pcall(greenduelsInstantReset, "medusa")
                        task.wait(1.5)
                        flag21 = false
                      end)
                    end)
                  end

                  fn77 = function(arg)
                    fn76()
                    if not tbl18.resetOnMedusa or not arg then
                      return
                    end

                    for _, descendant in ipairs(arg:GetDescendants()) do
                      if descendant:IsA("BasePart") then
                        table.insert(tbl29, fn86(descendant))
                      end
                    end

                    table.insert(
                      tbl29,
                      arg.DescendantAdded:Connect(function(descendant)
                        if descendant:IsA("BasePart") then
                          table.insert(tbl29, fn86(descendant))
                        end
                      end)
                    )
                  end
                end
              end

              greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function(character)
                tbl28.busy = false
                flag19 = false
                fn85(character)

                task.defer(function()
                  if _G.greenduelsApplyFovState then
                    pcall(_G.greenduelsApplyFovState)
                  end
                end)

                fn75(character)
                _G.GreenDuelsSetupAntiDropWatcher(character)
                fn77(character)
                if not tbl28.queued then
                  return
                end

                task.spawn(function()
                  local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                    or character:WaitForChild("Humanoid", 5)
                  local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    or character:WaitForChild("HumanoidRootPart", 5)
                  local flag21 = not tbl28.queued

                  if not flag21 then
                    local queuedUntil = tbl28.queuedUntil
                    flag21 = os.clock() > queuedUntil
                  end

                  if flag21 then
                    tbl28.queued = false
                    return
                  end
                  tbl28.queued = false

                  if humanoid2 and humanoid2.Health > 0 and humanoidRootPart then
                    greenduelsInstantReset("queued")
                  end
                end)
              end))

              if localPlayer.Character then
                fn85(localPlayer.Character)
              end
            end

            fn75(localPlayer.Character)
            _G.GreenDuelsSetupAntiDropWatcher(localPlayer.Character)
            fn77(localPlayer.Character)

            fn78 = function()
              if not (tbl18.mirrorTPDownEnabled or tbl18.autoTPDownEnabled) then
                return
              end
              local now2 = tick()
              if now2 - n33 < 0.5 then
                return
              end
              n33 = now2

              pcall(function()
                fn72(false)
              end)
            end

            fn79 = function()
              if tbl20.autoTPDown then
                tbl20.autoTPDown:Disconnect()
                tbl20.autoTPDown = nil
              end

              tbl18.autoTPDownEnabled = true

              tbl20.autoTPDown = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                if not tbl18.autoTPDownEnabled then
                  return
                end
                local character = localPlayer.Character
                if not character then
                  return
                end
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                  return
                end

                if tbl18._tpDownRayChar ~= character or not tbl18._tpDownRayParams then
                  tbl18._tpDownRayChar = character
                  tbl18._tpDownRayParams = RaycastParams.new()
                  tbl18._tpDownRayParams.FilterDescendantsInstances = { character }
                  tbl18._tpDownRayParams.FilterType = Enum.RaycastFilterType.Exclude
                end

                local tpDownRayParams = tbl18._tpDownRayParams
                local hit = Workspace:Raycast(
                  humanoidRootPart.Position,
                  Vector3.new(0, -2000, 0),
                  tpDownRayParams
                )

                if hit then
                  hit = humanoidRootPart.Position.Y - hit.Position.Y
                    > (tbl18.autoTPDownHeight or 15)
                end

                if hit then
                  pcall(fn73)
                end
              end))
            end

            fn80 = function()
              tbl18.autoTPDownEnabled = false

              if tbl20.autoTPDown then
                tbl20.autoTPDown:Disconnect()
                tbl20.autoTPDown = nil
              end
            end

            do
              local clone = nil

              fn81 = function()
                local character = localPlayer.Character
                if not character then
                  return
                end
                local humanoid2 = character:FindFirstChildOfClass("Humanoid")

                if humanoid2 then
                  for _, v87 in ipairs(humanoid2:GetPlayingAnimationTracks()) do
                    pcall(function()
                      v87:Stop()
                    end)
                  end
                end

                local animate = character:FindFirstChild("Animate")

                if animate then
                  if clone then
                    pcall(function()
                      clone:Destroy()
                    end)
                  end

                  clone = animate:Clone()
                  animate:Destroy()
                end
              end

              fn82 = function()
                local character = localPlayer.Character

                if character and clone and not character:FindFirstChild("HumanoidRootPart") then
                  clone:Clone().Parent = character
                end

                if clone then
                  pcall(function()
                    clone:Destroy()
                  end)

                  clone = nil
                end
              end
            end
          end

          do
            local tbl29, fn85

            do
              do
                greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function()
                  task.wait(0.5)

                  if tbl18.unwalkEnabled then
                    pcall(fn81)
                  end
                end))

                tbl29 = {}
                flag20 = false

                do
                  local function fn86()
                    for _, player in ipairs(Players:GetPlayers()) do
                      if player ~= localPlayer and player.Character then
                        for _, child in ipairs(player.Character:GetChildren()) do
                          if child:IsA("BasePart") then
                            child.CanCollide = false
                          end
                        end
                      end
                    end
                  end

                  fn83 = function() end

                  greenduelsPerfRun.track(service.Stepped:Connect(function()
                    fn86()
                  end))

                  fn85 = function()
                    if flag20 then
                      return
                    end
                    flag20 = true

                    local v87 = greenduelsPerfRun.track(service.Stepped:Connect(function()
                      if not flag20 then
                        return
                      end
                      fn86()
                    end))

                    table.insert(tbl29, v87)

                    local thread = coroutine.create(function()
                      while flag20 do
                        service.Heartbeat:Wait()
                        local character = localPlayer.Character
                        character = character and character:FindFirstChild("HumanoidRootPart")

                        if character then
                          local velocity = character.Velocity
                          character.Velocity = velocity * 1 + Vector3.new(0, 10000, 0)
                          service.RenderStepped:Wait()

                          if character and character.Parent then
                            character.Velocity = velocity
                          end

                          service.Stepped:Wait()

                          if character and character.Parent then
                            character.Velocity = velocity + Vector3.new(0, 0.1, 0)
                          end

                          continue
                        end

                        break
                      end
                    end)

                    table.insert(tbl29, thread)
                    coroutine.resume(thread)

                    task.delay(0.5, function()
                      flag20 = false

                      for _, v88 in ipairs(tbl29) do
                        local v89 = "RBXScriptConnection"

                        if typeof(v88) == v89 then
                          v88:Disconnect()
                        elseif type(v88) == "thread" then
                          pcall(coroutine.close, v88)
                        end
                      end

                      tbl29 = {}
                    end)
                  end
                end
              end

              do
                local flag21 = false
                local n34 = 0

                fn84 = function()
                  if flag21 then
                    return true
                  end

                  local ok, result = pcall(function()
                    return fn32 and fn32(true)
                  end)

                  if ok and result then
                    return true
                  end
                  return fn68 and fn68()
                end

                task.spawn(function()
                  while true do
                    task.wait(0.5)
                    local now2 = tick()
                    local flag22 = false

                    pcall(function()
                      flag22 = fn32 and fn32(true)
                    end)

                    if flag22 or fn68() then
                      n34 = now2
                    end

                    flag21 = now2 - n34 < 0.3
                  end
                end)
              end
            end

            local fn86, v87, n34, fn87

            do
              fn86 = function(arg)
                local character = arg
                  or localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not character then
                  return
                end
                local v88 = character:FindFirstChild("HumanoidRootPart")

                if v88 and v88:IsA("LinearVelocity") then
                  pcall(function()
                    v88.Enabled = false
                    v88.VectorVelocity = Vector3.zero
                    v88:Destroy()
                  end)
                end

                local waveDropJumpAttachment = character:FindFirstChild("WAVEDropJumpAttachment")

                if waveDropJumpAttachment and waveDropJumpAttachment:IsA("Attachment") then
                  pcall(function()
                    waveDropJumpAttachment:Destroy()
                  end)
                end
              end

              v87 = nil
              n34 = 0

              do
                local v88 = nil

                fn87 = function()
                  if flag20 then
                    return
                  end
                  local character = localPlayer.Character
                  local v89 = character and character:FindFirstChild("HumanoidRootPart")
                  local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                  if not (character and v89 and humanoid2) then
                    return
                  end
                  local v90 = v88
                  local raycastParams

                  if v88 then
                    raycastParams = v90
                  else
                    raycastParams = RaycastParams.new()
                  end

                  v88 = raycastParams
                  v88.FilterType = Enum.RaycastFilterType.Exclude

                  pcall(function()
                    v88.RespectCanCollide = true
                  end)

                  v88.FilterDescendantsInstances = { character }
                  local hit = workspace:Raycast(
                    v89.Position + Vector3.new(0, 0.35, 0),
                    Vector3.new(0, -2000, 0),
                    v88
                  )
                  if not hit then
                    return
                  end
                  flag20 = true

                  if tbl24.drop then
                    tbl24.drop.setOn(true)
                  end

                  n34 += 1
                  local v91 = n34
                  local rotation = v89.CFrame.Rotation
                  local x = v89.Position.X
                  local z = v89.Position.Z
                  local now2 = tick()

                  if v87 then
                    v87:Disconnect()
                    v87 = nil
                  end

                  local function fn88(arg)
                    if v87 then
                      v87:Disconnect()
                      v87 = nil
                    end

                    local humanoidRootPart = character
                      and character:FindFirstChild("HumanoidRootPart")
                    local humanoid3 = character and character:FindFirstChildOfClass("Humanoid")

                    if arg and humanoidRootPart and humanoid3 and humanoid3.Health > 0 then
                      v88.FilterDescendantsInstances = { character }
                      local hit2 = workspace:Raycast(
                        humanoidRootPart.Position + Vector3.new(0, 0.35, 0),
                        Vector3.new(0, -2000, 0),
                        v88
                      ) or hit

                      if hit2 then
                        humanoidRootPart.CFrame = CFrame.new(
                          x,
                          hit2.Position.Y
                            + humanoid3.HipHeight
                            + humanoidRootPart.Size.Y * 0.5
                            + 0.2,
                          z
                        ) * rotation
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                      end
                    end

                    if _F and _F.stopDropBrainrot then
                      _F.stopDropBrainrot()
                    else
                      stopDropBrainrot()
                    end
                  end

                  v87 = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                    local humanoidRootPart = character
                      and character:FindFirstChild("HumanoidRootPart")
                    local humanoid3 = character and character:FindFirstChildOfClass("Humanoid")

                    if
                      not (
                        v91 ~= n34
                        or localPlayer.Character ~= character
                        or not humanoidRootPart
                        or not humanoid3
                        or humanoid3.Health <= 0
                      )
                    then
                      if tick() - now2 >= 0.18 then
                        fn88(true)
                        return
                      end
                      humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 90, 0)
                      humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                      return
                    end

                    fn88(false)
                    return
                  end))
                end
              end
            end

            do
              local function runDropBrainrot()
                fn86()

                if stand == tbl17.STAND then
                  fn85()
                elseif stand == tbl17.JUMP then
                  fn87()
                end
              end

              v86 = runDropBrainrot

              if _F then
                _F.runDropBrainrot = runDropBrainrot
              end
            end

            greenduelsPerfRun.track(localPlayer.CharacterRemoving:Connect(function()
              flag20 = false

              for _, v88 in ipairs(tbl29) do
                if typeof(v88) == "RBXScriptConnection" then
                  v88:Disconnect()
                else
                  local v89 = "thread"

                  if type(v88) == v89 then
                    pcall(coroutine.close, v88)
                  end
                end
              end

              tbl29 = {}
              n34 += 1

              if v87 then
                v87:Disconnect()
                v87 = nil
              end

              fn86()
            end))

            stopDropBrainrot = function()
              flag20 = false

              if v87 then
                v87:Disconnect()
                v87 = nil
              end

              n34 += 1
              fn86()

              for _, v88 in ipairs(tbl29) do
                if typeof(v88) == "RBXScriptConnection" then
                  v88:Disconnect()
                elseif type(v88) == "thread" then
                  pcall(coroutine.close, v88)
                end
              end

              tbl29 = {}

              if tbl24.drop then
                tbl24.drop.setOn(false)
              end
            end
          end
        end

        local tbl29, fn85, fn86

        do
          local tbl30, flag21, greenduelsLineESP, fn87

          do
            if _F then
              _F.stopDropBrainrot = stopDropBrainrot
            end

            tbl30 = {}
            tbl29 = {}
            flag21 = true
            greenduelsLineESP = nil

            do
              local function fn88()
                if greenduelsLineESP and greenduelsLineESP.Parent then
                  return greenduelsLineESP
                end
                local playerGui = localPlayer:FindFirstChild("PlayerGui")
                if not playerGui then
                  return nil
                end
                greenduelsLineESP = playerGui:FindFirstChild("greenduelsLineESP")

                if not greenduelsLineESP then
                  greenduelsLineESP = Instance.new("ScreenGui")
                  greenduelsLineESP.Name = "greenduelsLineESP"
                  greenduelsLineESP.ResetOnSpawn = false
                  greenduelsLineESP.IgnoreGuiInset = true
                  greenduelsLineESP.DisplayOrder = 100
                  greenduelsLineESP.Parent = playerGui
                end

                return greenduelsLineESP
              end

              fn87 = function(arg)
                if arg == localPlayer then
                  return
                end

                if not arg.Character then
                  return
                end

                if tbl29[arg] then
                  return
                end
                local character = arg.Character
                local v87 = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                if not (v87 and head) then
                  return
                end

                local highlight = Instance.new("Highlight")
                highlight.Name = "followme@rznnq_highlight"
                highlight.Adornee = character
                highlight.FillColor = Color3.fromRGB(45, 255, 130)
                highlight.FillTransparency = 0.9
                highlight.OutlineColor = Color3.fromRGB(125, 200, 185)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character

                local instance2 = Instance.new("BillboardGui")
                instance2.Name = "greenduelsESP"
                instance2.Adornee = head
                instance2.Size = UDim2.new(0, 96, 0, 24)
                instance2.StudsOffset = Vector3.new(0, 2.75, 0)
                instance2.AlwaysOnTop = true
                instance2.Parent = character

                local textLabel2 = Instance.new("TextLabel", instance2)
                textLabel2.Size = UDim2.new(1, 0, 1, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = "0.0 spd"
                textLabel2.TextColor3 = Color3.fromRGB(115, 255, 175)
                textLabel2.Font = Enum.Font.GothamBlack
                textLabel2.TextSize = 14
                textLabel2.TextScaled = false
                textLabel2.TextXAlignment = Enum.TextXAlignment.Center
                textLabel2.TextStrokeTransparency = 0.5
                textLabel2.TextStrokeColor3 = Color3.fromRGB(2, 12, 6)

                local v88 = fn88()
                local frame = nil

                if v88 then
                  frame = Instance.new("Frame")
                  frame.Name = "Line_" .. arg.Name
                  frame.AnchorPoint = Vector2.new(0.5, 0.5)
                  frame.BorderSizePixel = 0
                  frame.BackgroundColor3 = Color3.fromRGB(65, 255, 135)
                  frame.BackgroundTransparency = 0.12
                  frame.Size = UDim2.new(0, 0, 0, 2)
                  frame.Visible = false
                  frame.ZIndex = 10
                  frame.Parent = v88

                  local uiStroke = Instance.new("UIStroke", frame)
                  uiStroke.Color = Color3.fromRGB(180, 255, 205)
                  uiStroke.Thickness = 1
                  uiStroke.Transparency = 0.45
                end

                tbl29[arg] = {
                  highlight = highlight,
                  billboard = instance2,
                  speedLbl = textLabel2,
                  line = frame,
                }
              end
            end
          end

          do
            local function fn88(arg)
              if tbl29[arg] then
                local v87 = tbl29[arg]

                if v87.line then
                  pcall(function()
                    v87.line:Destroy()
                  end)
                end
              end

              if arg.Character then
                local followmeRznnqHighlight =
                  arg.Character:FindFirstChild("followme@rznnq_highlight")
                local greenduelsESP = arg.Character:FindFirstChild("greenduelsESP")

                if followmeRznnqHighlight then
                  followmeRznnqHighlight:Destroy()
                end

                if greenduelsESP then
                  greenduelsESP:Destroy()
                end
              end

              tbl29[arg] = nil
            end

            fn85 = function()
              if flag21 then
                return
              end
              flag21 = true

              for _, v87 in ipairs(tbl30) do
                pcall(v87.Disconnect, v87)
              end

              tbl30 = {}

              task.spawn(function()
                local v87 = 0

                for _, player in ipairs(Players:GetPlayers()) do
                  if not flag21 then
                    return
                  end

                  if player ~= localPlayer then
                    v87 += 1

                    if v87 % 3 == 0 then
                      task.wait()
                    end

                    fn87(player)

                    local connection = player.CharacterAdded:Connect(function()
                      task.delay(0.35, function()
                        if flag21 then
                          fn88(player)
                          fn87(player)
                        end
                      end)
                    end)

                    table.insert(tbl30, connection)
                  end
                end
              end)

              local v87 = greenduelsPerfRun.track(Players.PlayerAdded:Connect(function(player)
                if player == localPlayer then
                  return
                end

                local connection = player.CharacterAdded:Connect(function()
                  task.delay(0.35, function()
                    if flag21 then
                      fn88(player)
                      fn87(player)
                    end
                  end)
                end)

                table.insert(tbl30, connection)

                task.delay(0.5, function()
                  if flag21 then
                    fn87(player)
                  end
                end)
              end))

              table.insert(tbl30, v87)
              local v88 = 0
              local n34 = 0

              local v89 = greenduelsPerfRun.track(service.RenderStepped:Connect(function(deltaTime)
                n34 += deltaTime
                if n34 < 360 then
                  return
                end
                n34 %= 360
                if not flag21 then
                  return
                end
                local currentCamera = Workspace.CurrentCamera
                local viewportSize = currentCamera and currentCamera.ViewportSize
                local character = localPlayer.Character
                character = character and character:FindFirstChild("HumanoidRootPart")
                local v89 = currentCamera and character
                local vector2 = nil

                if v89 then
                  local v90, flag22 = currentCamera:WorldToViewportPoint(character.Position)
                  flag22 = flag22 and v90.Z > 0
                  vector2 = nil

                  if flag22 then
                    vector2 = Vector2.new(v90.X, v90.Y)
                  end
                end

                if not vector2 and viewportSize then
                  vector2 = Vector2.new(viewportSize.X / 2, viewportSize.Y - 10)
                end

                local now2 = tick()
                local flag22 = now2 - v88 > 0.18

                if flag22 then
                  v88 = now2
                end

                for k, v90 in pairs(tbl29) do
                  local character2 = k.Character
                  local humanoidRootPart = character2
                    and character2:FindFirstChild("HumanoidRootPart")
                  character2 = character2 and character2:FindFirstChildOfClass("Humanoid")

                  if v90.line then
                    v90.line.Visible = false
                  end

                  if humanoidRootPart then
                    if
                      tbl18.lineEspEnabled
                      and v90.line
                      and currentCamera
                      and viewportSize
                      and vector2
                      and (not character2 or character2.Health > 0)
                    then
                      local v91 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                      local vector22 = Vector2.new(v91.X, v91.Y)
                      local vector23 = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

                      if v91.Z <= 0 then
                        vector22 = vector23 - vector22 - vector23
                      end

                      local y = vector22.Y
                      local vector24 = Vector2.new(
                        math.clamp(vector22.X, 4, viewportSize.X - 4),
                        math.clamp(y, 4, viewportSize.Y - 4)
                      )
                      local n35 = vector24 - vector2
                      local magnitude = n35.Magnitude

                      if magnitude > 2 then
                        v90.line.Size = UDim2.new(0, magnitude, 0, 2)
                        v90.line.Position = UDim2.new(
                          0,
                          (vector2.X + vector24.X) / 2,
                          0,
                          (vector2.Y + vector24.Y) / 2
                        )
                        v90.line.Rotation = math.deg(math.atan2(n35.Y, n35.X))
                        v90.line.Visible = true
                      end
                    end

                    if flag22 and v90.speedLbl then
                      local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
                      v90.speedLbl.Text = string.format(
                        "%.1f spd",
                        Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude
                      )
                    end
                  elseif flag22 and v90.speedLbl then
                    v90.speedLbl.Text = "0.0"
                  end
                end
              end))

              table.insert(tbl30, v89)
            end

            fn86 = function()
              flag21 = false

              for _, v87 in ipairs(tbl30) do
                pcall(v87.Disconnect, v87)
              end

              tbl30 = {}

              for _, player in ipairs(Players:GetPlayers()) do
                fn88(player)
              end

              if greenduelsLineESP then
                pcall(function()
                  greenduelsLineESP:Destroy()
                end)

                greenduelsLineESP = nil
              end
            end
          end
        end

        local greenduelsStartAntiRagdoll

        do
          _G.greenduelsSwingHere = _G.greenduelsSwingHere or { data = {} }

          _G.greenduelsGetSwingHereFolder = function()
            local greenduelsSwingHere = _G.greenduelsSwingHere
            if greenduelsSwingHere.folder and greenduelsSwingHere.folder.Parent then
              return greenduelsSwingHere.folder
            end
            greenduelsSwingHere.folder = Workspace:FindFirstChild("greenduelsSwingHereMarkers")

            if not greenduelsSwingHere.folder then
              greenduelsSwingHere.folder = Instance.new("Folder")
              greenduelsSwingHere.folder.Name = "greenduelsSwingHereMarkers"
              greenduelsSwingHere.folder.Parent = Workspace
            end

            return greenduelsSwingHere.folder
          end

          _G.greenduelsClearSwingHereMarker = function(arg)
            local v87 = _G.greenduelsSwingHere.data[arg]

            if v87 and v87.marker then
              pcall(function()
                v87.marker:Destroy()
              end)
            end

            if v87 then
              v87.marker = nil
              v87.visible = false
            end
          end

          _G.greenduelsMakeSwingHereMarker = function(arg, position)
            local greenduelsSwingHere = _G.greenduelsSwingHere
            local tbl30 = greenduelsSwingHere.data[arg] or {}
            greenduelsSwingHere.data[arg] = tbl30
            if tbl30.marker and tbl30.marker.Parent then
              tbl30.marker.Position = position
              return tbl30.marker
            end
            local v87 = _G.greenduelsGetSwingHereFolder()

            local part = Instance.new("Part")
            part.Name = "SwingHere_" .. tostring(arg.UserId)
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(0.9, 0.9, 0.9)
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(40, 200, 100)
            part.Position = position
            part.Parent = v87

            local pointLight = Instance.new("PointLight", part)
            pointLight.Color = part.Color
            pointLight.Brightness = 1.25
            pointLight.Range = 6

            local instance2 = Instance.new("BillboardGui", part)
            instance2.Name = "SwingHereBillboard"
            instance2.Adornee = part
            instance2.Size = UDim2.new(0, 120, 0, 40)
            instance2.StudsOffset = Vector3.new(0, 1, 0)
            instance2.AlwaysOnTop = true

            local instance3 = Instance.new("TextLabel", instance2)
            instance3.Size = UDim2.new(1, 0, 1, 0)
            instance3.BackgroundTransparency = 1
            instance3.Text = "Swing Here"
            instance3.TextColor3 = Color3.fromRGB(255, 255, 255)
            instance3.Font = Enum.Font.GothamBlack
            instance3.TextSize = 14
            instance3.TextStrokeTransparency = 0.12
            instance3.TextStrokeColor3 = Color3.fromRGB(0, 20, 8)

            tbl30.marker = part
            tbl30.visible = true
            return part
          end

          _G.greenduelsStartSwingHereMarkers = function()
            local greenduelsSwingHere = _G.greenduelsSwingHere
            if greenduelsSwingHere.conn then
              return
            end
            tbl18.swingHereMarkerEnabled = true
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude

            pcall(function()
              raycastParams.RespectCanCollide = true
            end)

            greenduelsSwingHere.conn = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
              if not tbl18.swingHereMarkerEnabled then
                return
              end
              local now2 = tick()
              if greenduelsSwingHere.lastUpdate and now2 - greenduelsSwingHere.lastUpdate < 0.1 then
                return
              end
              greenduelsSwingHere.lastUpdate = now2
              local filterDescendantsInstances = {}

              if localPlayer.Character then
                filterDescendantsInstances[#filterDescendantsInstances + 1] = localPlayer.Character
              end

              if greenduelsSwingHere.folder then
                filterDescendantsInstances[#filterDescendantsInstances + 1] =
                  greenduelsSwingHere.folder
              end

              for _, child in ipairs(Workspace:GetChildren()) do
                if child.Name == "Decoy" then
                  filterDescendantsInstances[#filterDescendantsInstances + 1] = child
                end
              end

              for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                  filterDescendantsInstances[#filterDescendantsInstances + 1] = player.Character
                end
              end

              raycastParams.FilterDescendantsInstances = filterDescendantsInstances

              for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                  local character = player.Character
                  local humanoidRootPart = character
                    and character:FindFirstChild("HumanoidRootPart")

                  if humanoidRootPart then
                    pcall(function()
                      sethiddenproperty(humanoidRootPart, "PhysicsRepRootPart", nil)
                    end)
                  end

                  local head

                  if humanoidRootPart then
                    head = humanoidRootPart
                  elseif character then
                    head = character:FindFirstChild("Head")
                      or character:FindFirstChild("UpperTorso")
                      or character:FindFirstChild("Torso")
                  else
                    head = character
                  end

                  local v87 = character and character:FindFirstChildOfClass("Humanoid")
                  local tbl30 = greenduelsSwingHere.data[player] or {}
                  greenduelsSwingHere.data[player] = tbl30

                  if head and (not v87 or v87.Health > 0) then
                    local position = head.Position

                    pcall(function()
                      position = character:GetPivot().Position
                    end)

                    pcall(function()
                      position = character:GetBoundingBox().Position
                    end)

                    local hit = Workspace:Raycast(
                      position + Vector3.new(0, 4, 0),
                      Vector3.new(0, -500, 0),
                      raycastParams
                    )
                    local flag21 = v87
                      and v87.FloorMaterial
                      and v87.FloorMaterial ~= Enum.Material.Air
                    flag21 = hit
                        and hit.Instance
                        and hit.Position
                        and position.Y - hit.Position.Y <= 14
                      or flag21
                    local state = v87 and v87:GetState()

                    if
                      flag21
                      and v87
                      and v87.Health > 0
                      and not v87.PlatformStand
                      and state ~= Enum.HumanoidStateType.Ragdoll
                      and state ~= Enum.HumanoidStateType.Physics
                      and state ~= Enum.HumanoidStateType.FallingDown
                      and state ~= Enum.HumanoidStateType.Freefall
                    then
                      hit = hit and hit.Position
                      tbl30.lastLand = (hit or position - Vector3.new(0, 10, 0))
                        + Vector3.new(0, 3.1, 0)
                      tbl30.lastLandAt = now2
                      tbl30.airStarted = nil

                      if tbl30.visible then
                        _G.greenduelsClearSwingHereMarker(player)
                      end
                    else
                      tbl30.airStarted = tbl30.airStarted or now2
                      local lastLand = hit
                          and hit.Position
                          and hit.Position + Vector3.new(0, 1, 0)
                        or tbl30.lastLand
                      local flag22

                      if lastLand then
                        local position2 = hit and hit.Position

                        if position2 then
                          flag22 = position2
                        else
                          flag22 = now2 - (tbl30.lastLandAt or 0) < 12
                        end
                      else
                        flag22 = lastLand
                      end

                      if flag22 then
                        _G.greenduelsMakeSwingHereMarker(player, lastLand)
                      end
                    end
                  else
                    local lastLand = tbl30.lastLand
                    local flag21

                    if lastLand then
                      flag21 = now2 - (tbl30.lastLandAt or 0) < 12
                    else
                      flag21 = lastLand
                    end

                    if flag21 then
                      _G.greenduelsMakeSwingHereMarker(player, lastLand)
                    else
                      _G.greenduelsClearSwingHereMarker(player)
                    end
                  end
                end
              end

              for k in pairs(greenduelsSwingHere.data) do
                if not k.Parent then
                  _G.greenduelsClearSwingHereMarker(k)
                  greenduelsSwingHere.data[k] = nil
                end
              end
            end))
          end

          _G.greenduelsStopSwingHereMarkers = function()
            local greenduelsSwingHere = _G.greenduelsSwingHere
            tbl18.swingHereMarkerEnabled = false

            if greenduelsSwingHere.conn then
              greenduelsSwingHere.conn:Disconnect()
              greenduelsSwingHere.conn = nil
            end

            for k in pairs(greenduelsSwingHere.data) do
              _G.greenduelsClearSwingHereMarker(k)
            end

            table.clear(greenduelsSwingHere.data)

            if greenduelsSwingHere.folder then
              pcall(function()
                greenduelsSwingHere.folder:Destroy()
              end)

              greenduelsSwingHere.folder = nil
            end
          end

          if not _G.EvadeGreenCustomToolsEngineLoaded then
            _G.EvadeGreenCustomToolsEngineLoaded = true

            do
              local function fn87()
                local Players2 = game:GetService("Players")
                local service4 = game:GetService("RunService")

                local localPlayer2 = Players2.LocalPlayer

                local tbl30 = {
                  {
                    key = "Bat",
                    match = function(arg)
                      local str6 = arg:lower()
                      return str6:find("bat") ~= nil or str6:find("slap") ~= nil
                    end,
                  },
                  {
                    key = "Medusa",
                    match = function(arg)
                      return arg:lower():find("medusa") ~= nil
                    end,
                  },
                }

                local function fn88(arg)
                  if
                    not (
                      arg:IsA("Tool")
                      or arg:IsA("Model")
                      or arg:IsA("Accessory")
                      or arg:IsA("BasePart")
                    )
                  then
                    return nil
                  end

                  for _, v87 in ipairs(tbl30) do
                    if v87.match(arg.Name) then
                      return v87
                    end
                  end

                  return nil
                end

                local function fn89(arg)
                  if arg.Name == "LocalReplica" then
                    return true
                  end
                  return arg:FindFirstAncestor("LocalReplica") ~= nil
                end

                local tbl31 = {}
                local tbl32 = { "custom", "rainbow", "transparent" }
                local obj = setmetatable({}, { __mode = "k" })
                local obj2 = setmetatable({}, { __mode = "k" })
                local obj3 = setmetatable({}, { __mode = "k" })

                tbl31.getBaseline = function(arg)
                  local v87 = obj[arg]
                  if v87 ~= nil then
                    return v87
                  end

                  local ok, result = pcall(function()
                    return arg.Transparency
                  end)

                  if not ok then
                    return nil
                  end
                  obj[arg] = result
                  return result
                end

                local function fn90(arg)
                  local v87 = obj2[arg]
                  if not v87 then
                    return nil
                  end

                  for _, v88 in ipairs(tbl32) do
                    if v87[v88] ~= nil then
                      return v87[v88]
                    end
                  end

                  return nil
                end

                local function fn91(arg, transparency)
                  local ok, result = pcall(function()
                    return arg.Transparency
                  end)

                  if ok and result ~= nil and math.abs(result - transparency) <= 0.001 then
                    return
                  end

                  pcall(function()
                    arg.Transparency = transparency
                  end)
                end

                local function fn92(arg)
                  local v87 = fn90(arg)
                  if v87 ~= nil then
                    fn91(arg, v87)
                    return
                  end
                  local v88 = obj[arg]

                  if v88 ~= nil then
                    fn91(arg, v88)
                  end
                end

                local function fn93(arg)
                  if obj3[arg] then
                    return
                  end

                  local ok, result = pcall(function()
                    return arg:GetPropertyChangedSignal("Transparency"):Connect(function()
                      local v87 = fn90(arg)
                      if v87 == nil then
                        return
                      end

                      local ok, result = pcall(function()
                        return arg.Transparency
                      end)

                      if ok and result ~= nil and math.abs(result - v87) > 0.05 then
                        pcall(function()
                          arg.Transparency = v87
                        end)
                      end
                    end)
                  end)

                  if ok and result then
                    obj3[arg] = result
                  end
                end

                local function fn94(arg)
                  local v87 = obj3[arg]

                  if v87 then
                    pcall(function()
                      v87:Disconnect()
                    end)

                    obj3[arg] = nil
                  end
                end

                tbl31.enforce = function()
                  for k in pairs(obj2) do
                    if k.Parent then
                      local v87 = fn90(k)

                      if v87 ~= nil then
                        local ok, result = pcall(function()
                          return k.Transparency
                        end)

                        if ok and result ~= nil and math.abs(result - v87) > 0.001 then
                          pcall(function()
                            k.Transparency = v87
                          end)
                        end
                      end
                    end
                  end
                end

                tbl31.claim = function(arg, arg2, arg3)
                  if not arg then
                    return
                  end

                  if tbl31.getBaseline(arg) == nil then
                    return
                  end
                  local tbl33 = obj2[arg]

                  if not tbl33 then
                    tbl33 = {}
                    obj2[arg] = tbl33
                  end

                  tbl33[arg2] = arg3
                  fn93(arg)
                  fn92(arg)
                end

                tbl31.release = function(arg, arg2)
                  if not arg then
                    return
                  end
                  local v87 = obj2[arg]
                  if not v87 then
                    return
                  end
                  v87[arg2] = nil

                  if next(v87) == nil then
                    obj2[arg] = nil
                    fn94(arg)
                  end

                  if arg.Parent then
                    fn92(arg)
                  end
                end

                local tbl33 = {}

                task.spawn(function()
                  while true do
                    task.wait(10)

                    for _, v87 in ipairs(tbl33) do
                      pcall(v87)
                    end
                  end
                end)

                task.spawn(function()
                  while true do
                    task.wait(0.5)

                    if
                      _G.AmbitiousCustomToolsEnabled == true
                      or _G.AmbitiousTransparentToolsEnabled == true
                      or _G.AmbitiousRainbowToolsEnabled == true
                    then
                      pcall(tbl31.enforce)
                    end
                  end
                end)

                local v87 = false
                local obj4 = setmetatable({}, { __mode = "k" })
                local obj5 = setmetatable({}, { __mode = "k" })
                local fn95 = nil

                local function fn96(arg)
                  if arg:IsA("MeshPart") then
                    return {
                      obj = arg,
                      kind = "part",
                      props = { "Color", "Material", "TextureID" },
                      clearTexture = "TextureID",
                    }
                  end

                  if arg:IsA("BasePart") then
                    return { obj = arg, kind = "part", props = { "Color", "Material" } }
                  end

                  if arg:IsA("SurfaceAppearance") then
                    return { obj = arg, kind = "surface", props = { "Parent" } }
                  end

                  if arg:IsA("Decal") or arg:IsA("Texture") then
                    return { obj = arg, kind = "decal", props = {} }
                  end

                  if arg:IsA("SpecialMesh") then
                    return {
                      obj = arg,
                      kind = "vector",
                      prop = "VertexColor",
                      props = { "VertexColor", "TextureId" },
                      clearTexture = "",
                    }
                  end

                  if arg:IsA("ParticleEmitter") or arg:IsA("Beam") or arg:IsA("Trail") then
                    return { obj = arg, kind = "sequence", prop = "Color", props = { "Color" } }
                  end

                  if arg:IsA("PointLight") or arg:IsA("SpotLight") or arg:IsA("SurfaceLight") then
                    return { obj = arg, kind = "color", prop = "Color", props = { "Color" } }
                  end

                  if arg:IsA("Highlight") then
                    return {
                      obj = arg,
                      kind = "color",
                      prop = "FillColor",
                      props = { "FillColor" },
                    }
                  end
                  return nil
                end

                local function fn97(arg)
                  arg.original = {}

                  for _, prop in ipairs(arg.props) do
                    local ok, result = pcall(function()
                      return arg.obj[prop]
                    end)

                    if ok then
                      arg.original[prop] = result
                    end
                  end
                end

                local function fn98(arg)
                  if arg.kind == "decal" then
                    tbl31.release(arg.obj, "Transparency")
                  end

                  if not arg.original then
                    return
                  end

                  for k, v88 in pairs(arg.original) do
                    pcall(function()
                      arg.obj[k] = v88
                    end)
                  end
                end

                local function fn99(arg)
                  if arg.kind == "surface" then
                    pcall(function()
                      arg.obj.Parent = nil
                    end)
                  elseif arg.kind == "decal" then
                    tbl31.claim(arg.obj, "rainbow", 1)
                  elseif arg.clearTexture then
                    pcall(function()
                      arg.obj[arg.clearTexture] = ""
                    end)
                  end

                  return
                end

                local function fn100(arg, arg2)
                  local v88 = fn96(arg2)
                  if not v88 then
                    return
                  end
                  fn97(v88)
                  fn99(v88)

                  if v88.kind == "part" then
                    table.insert(arg.parts, v88)
                  elseif v88.kind == "surface" or v88.kind == "decal" then
                    table.insert(arg.statics, v88)
                  else
                    table.insert(arg.effects, v88)
                  end
                end

                local function fn101(arg)
                  if obj4[arg] then
                    return
                  end
                  local tbl34 = { parts = {}, effects = {}, statics = {}, conns = {} }
                  obj4[arg] = tbl34

                  for _, descendant in ipairs(arg:GetDescendants()) do
                    fn100(tbl34, descendant)
                  end

                  if arg:IsA("BasePart") then
                    fn100(tbl34, arg)
                  end

                  table.insert(
                    tbl34.conns,
                    arg.DescendantAdded:Connect(function(descendant)
                      fn100(tbl34, descendant)
                    end)
                  )

                  table.insert(
                    tbl34.conns,
                    arg.AncestryChanged:Connect(function(child, parent)
                      if not parent then
                        fn95(arg, false)
                      end
                    end)
                  )
                end

                fn95 = function(arg, arg2)
                  local v88 = obj4[arg]
                  if not v88 then
                    return
                  end

                  for _, conn in ipairs(v88.conns) do
                    pcall(function()
                      conn:Disconnect()
                    end)
                  end

                  if arg2 then
                    for _, part in ipairs(v88.parts) do
                      fn98(part)
                    end

                    for _, effect in ipairs(v88.effects) do
                      fn98(effect)
                    end

                    for _, static in ipairs(v88.statics) do
                      fn98(static)
                    end
                  end

                  obj4[arg] = nil
                end

                local function fn102(child)
                  if not v87 then
                    return
                  end

                  if fn88(child) then
                    fn101(child)
                  end
                end

                local function fn103(arg)
                  local v88 = obj5[arg]
                  if not v88 then
                    return
                  end

                  for _, v89 in ipairs(v88) do
                    pcall(function()
                      v89:Disconnect()
                    end)
                  end

                  obj5[arg] = nil
                end

                local function fn104(arg)
                  if not arg or obj5[arg] then
                    return
                  end
                  obj5[arg] = { arg.ChildAdded:Connect(fn102) }

                  for _, child in ipairs(arg:GetChildren()) do
                    fn102(child)
                  end
                end

                local function fn105()
                  fn104(localPlayer2:FindFirstChildOfClass("Backpack"))
                  fn104(localPlayer2.Character)
                end

                localPlayer2.ChildAdded:Connect(function(child)
                  if v87 and child:IsA("Backpack") then
                    fn104(child)
                  end
                end)

                localPlayer2.CharacterAdded:Connect(function(character)
                  for k in pairs(obj4) do
                    fn95(k, false)
                  end

                  for k in pairs(obj5) do
                    fn103(k)
                  end

                  if not v87 then
                    return
                  end
                  fn104(character)

                  task.defer(function()
                    if v87 then
                      fn105()
                    end
                  end)
                end)

                local n34 = 0

                service4.Heartbeat:Connect(function(deltaTime)
                  if not v87 then
                    return
                  end

                  if next(obj4) == nil then
                    return
                  end
                  n34 += deltaTime
                  if n34 < 0.05 then
                    return
                  end
                  n34 = 0
                  local n35 = tick() * 0.35 % 1

                  for _, v88 in pairs(obj4) do
                    for i, part in ipairs(v88.parts) do
                      local obj6 = part.obj

                      if obj6.Parent then
                        pcall(function()
                          obj6.Color =
                            Color3.fromHSV((n35 + (i - 1) * 0.05) % 1, 1, 1)
                        end)
                      end
                    end

                    for i, effect in ipairs(v88.effects) do
                      if effect.obj.Parent then
                        local color = Color3.fromHSV((n35 + (i - 1) * 0.05) % 1, 1, 1)

                        if effect.kind == "sequence" then
                          pcall(function()
                            effect.obj[effect.prop] = ColorSequence.new(color)
                          end)
                        elseif effect.kind == "vector" then
                          pcall(function()
                            effect.obj[effect.prop] = Vector3.new(color.R, color.G, color.B)
                          end)
                        else
                          pcall(function()
                            effect.obj[effect.prop] = color
                          end)
                        end
                      end
                    end
                  end
                end)

                table.insert(tbl33, function()
                  for k in pairs(obj4) do
                    if not k.Parent then
                      fn95(k, false)
                    end
                  end

                  for k in pairs(obj5) do
                    if k ~= workspace and not k.Parent then
                      fn103(k)
                    end
                  end
                end)

                _G.AmbitiousRainbowTools = {
                  setEnabled = function(arg)
                    local ambitiousRainbowToolsEnabled = arg and true or false
                    v87 = ambitiousRainbowToolsEnabled
                    _G.AmbitiousRainbowToolsEnabled = ambitiousRainbowToolsEnabled

                    if ambitiousRainbowToolsEnabled then
                      fn105()
                    else
                      for k in pairs(obj4) do
                        fn95(k, true)
                      end

                      for k in pairs(obj5) do
                        fn103(k)
                      end
                    end
                  end,
                  isEnabled = function()
                    return v87
                  end,
                }

                local flag21 = false
                local obj6 = setmetatable({}, { __mode = "k" })
                local obj7 = setmetatable({}, { __mode = "k" })
                local fn106 = nil

                local function fn107(arg)
                  if not arg:IsA("BasePart") then
                    return false
                  end
                  local v88 = tbl31.getBaseline(arg)
                  if v88 == nil or v88 >= 1 then
                    return false
                  end
                  return true
                end

                local function fn108(arg, arg2)
                  if not fn107(arg2) then
                    return
                  end

                  if arg.seen[arg2] then
                    return
                  end
                  arg.seen[arg2] = true
                  table.insert(arg.parts, { obj = arg2 })
                  tbl31.claim(arg2, "transparent", 0.5)
                end

                local function fn109(arg)
                  if obj6[arg] then
                    return
                  end
                  local tbl34 = { parts = {}, seen = {}, conns = {} }
                  obj6[arg] = tbl34

                  for _, descendant in ipairs(arg:GetDescendants()) do
                    fn108(tbl34, descendant)
                  end

                  if arg:IsA("BasePart") then
                    fn108(tbl34, arg)
                  end

                  table.insert(
                    tbl34.conns,
                    arg.DescendantAdded:Connect(function(descendant)
                      fn108(tbl34, descendant)
                    end)
                  )

                  table.insert(
                    tbl34.conns,
                    arg.AncestryChanged:Connect(function(child, parent)
                      if not parent then
                        fn106(arg, false)
                      end
                    end)
                  )
                end

                fn106 = function(arg)
                  local v88 = obj6[arg]
                  if not v88 then
                    return
                  end

                  for _, conn in ipairs(v88.conns) do
                    pcall(function()
                      conn:Disconnect()
                    end)
                  end

                  for _, part in ipairs(v88.parts) do
                    tbl31.release(part.obj, "transparent")
                  end

                  obj6[arg] = nil
                end

                local function fn110(child)
                  if not flag21 then
                    return
                  end

                  if fn88(child) then
                    fn109(child)
                  end
                end

                local function fn111(arg)
                  local v88 = obj7[arg]
                  if not v88 then
                    return
                  end

                  for _, v89 in ipairs(v88) do
                    pcall(function()
                      v89:Disconnect()
                    end)
                  end

                  obj7[arg] = nil
                end

                local function fn112(arg)
                  if not arg or obj7[arg] then
                    return
                  end
                  obj7[arg] = { arg.ChildAdded:Connect(fn110) }

                  for _, child in ipairs(arg:GetChildren()) do
                    fn110(child)
                  end
                end

                local function fn113()
                  fn112(localPlayer2:FindFirstChildOfClass("Backpack"))
                  fn112(localPlayer2.Character)
                end

                localPlayer2.ChildAdded:Connect(function(child)
                  if flag21 and child:IsA("Backpack") then
                    fn112(child)
                  end
                end)

                localPlayer2.CharacterAdded:Connect(function(character)
                  for k in pairs(obj6) do
                    fn106(k, false)
                  end

                  for k in pairs(obj7) do
                    fn111(k)
                  end

                  if not flag21 then
                    return
                  end
                  fn112(character)

                  task.defer(function()
                    if flag21 then
                      fn113()
                    end
                  end)
                end)

                table.insert(tbl33, function()
                  for k in pairs(obj6) do
                    if not k.Parent then
                      fn106(k, false)
                    end
                  end

                  for k in pairs(obj7) do
                    if not k.Parent then
                      fn111(k)
                    end
                  end
                end)

                _G.AmbitiousTransparentTools = {
                  setEnabled = function(arg)
                    local ambitiousTransparentToolsEnabled = arg and true or false
                    flag21 = ambitiousTransparentToolsEnabled
                    _G.AmbitiousTransparentToolsEnabled = ambitiousTransparentToolsEnabled

                    if ambitiousTransparentToolsEnabled then
                      fn113()
                    else
                      for k in pairs(obj6) do
                        fn106(k, true)
                      end

                      for k in pairs(obj7) do
                        fn111(k)
                      end
                    end
                  end,
                  isEnabled = function()
                    return flag21
                  end,
                }

                local ambitiousCustomToolAssets = {
                  DiamondSword = {
                    cat = "Bat",
                    label = "Diamond Sword",
                    mesh = "rbxassetid://8827558932",
                    tex = "rbxassetid://8827558969",
                    scale = Vector3.new(0.2, 0.2, 0.2),
                    c0 = CFrame.new(-0.05, -0.5, -0.12)
                      * CFrame.Angles(1.5707963267948966, 0, 300),
                    view = 4.9,
                  },
                  Katana = {
                    cat = "Bat",
                    label = "Katana",
                    mesh = "rbxassetid://13528902482",
                    tex = "rbxassetid://13528902373",
                    scale = Vector3.new(1.4, 1.4, 1.4),
                    c0 = CFrame.new(0, 0.6, 0)
                      * CFrame.Angles(4.7123889803846897, 3.1415926535897931, 3.1415926535897931),
                    view = 6.6,
                  },
                  Keyblade = {
                    cat = "Bat",
                    label = "Keyblade",
                    mesh = "rbxassetid://10324542258",
                    tex = "rbxassetid://10324548131",
                    scale = Vector3.new(1.4, 1.4, 1.4),
                    c0 = CFrame.new(-0.05, -0.1, -0.12)
                      * CFrame.Angles(1.5707963267948966, 3.1415926535897931, 300),
                    view = 4.9,
                  },
                  StarWand = {
                    cat = "Bat",
                    label = "Star Wand",
                    mesh = "rbxassetid://99775819417718",
                    tex = "rbxassetid://98445209461118",
                    scale = Vector3.new(3.6, 0.3, 3.6),
                    c0 = CFrame.new(-0.3, -0.3, 0) * CFrame.Angles(0, 0, 0),
                    view = 8.5,
                  },
                  Skull = {
                    cat = "Medusa",
                    label = "Skull",
                    mesh = "rbxassetid://2050312704",
                    tex = "rbxassetid://2050313393",
                    scale = Vector3.new(1, 1, 1),
                    c0 = CFrame.new(0, -0.3, -0.4) * CFrame.Angles(0.2, 0, 0),
                    view = 4.2,
                  },
                  CustomMedusa = {
                    cat = "Medusa",
                    label = "Custom Medusa",
                    mesh = "rbxassetid://667549686",
                    tex = "",
                    scale = Vector3.new(1, 1, 1),
                    c0 = CFrame.new(0, -0.3, -0.4)
                      * CFrame.Angles(5.7595865315812871, 0, 0),
                    view = 4.2,
                  },
                  GoldenDesertEagle = {
                    cat = "Medusa",
                    label = "Golden Desert Eagle",
                    mesh = "rbxassetid://430251413",
                    tex = "rbxassetid://435840335",
                    scale = Vector3.new(0.01, 1, 0.01),
                    c0 = CFrame.new(0, 0, -0.8)
                      * CFrame.Angles(0.2, 3.1415926535897931, 0),
                    view = 3,
                  },
                }

                _G.AmbitiousCustomToolAssets = ambitiousCustomToolAssets
                _G.AmbitiousCustomToolSkins = _G.AmbitiousCustomToolSkins
                  or { Bat = "DiamondSword", Medusa = "Medusa" }

                local function fn114(arg)
                  local v88 = _G.AmbitiousCustomToolSkins[arg]
                  if
                    v88
                    and ambitiousCustomToolAssets[v88]
                    and ambitiousCustomToolAssets[v88].cat == arg
                  then
                    return v88
                  end
                  return arg == "Bat" and "DiamondSword" or "GoldenDesertEagle"
                end

                local v88 = false
                local obj8 = setmetatable({}, { __mode = "k" })
                local obj9 = setmetatable({}, { __mode = "k" })
                local obj10 = setmetatable({}, { __mode = "k" })
                local fn115 = nil

                local function createModel(part0, arg)
                  local localReplica = part0:FindFirstChild("LocalReplica")

                  if localReplica then
                    localReplica:Destroy()
                  end

                  local diamondSword = ambitiousCustomToolAssets[arg]
                    or ambitiousCustomToolAssets.DiamondSword
                  local model = Instance.new("Model")
                  model.Name = "LocalReplica"

                  local instance2 = Instance.new("Part")
                  instance2.Name = "MainPart"
                  instance2.CanCollide = false
                  instance2.CanQuery = false
                  instance2.CanTouch = false
                  instance2.Massless = true
                  instance2.Size = Vector3.new(1, 1, 1)
                  instance2.Transparency = 0
                  instance2.Anchored = false
                  instance2.Parent = model

                  local specialMesh = Instance.new("SpecialMesh")
                  specialMesh.MeshType = Enum.MeshType.FileMesh
                  specialMesh.MeshId = diamondSword.mesh
                  specialMesh.TextureId = diamondSword.tex
                  specialMesh.Parent = instance2

                  local motor6D = Instance.new("Motor6D")
                  motor6D.Part0 = part0
                  motor6D.Part1 = instance2

                  specialMesh.Scale = diamondSword.scale
                  motor6D.C0 = diamondSword.c0
                  motor6D.Parent = instance2
                  model.Parent = part0
                  return model
                end

                local function fn116(arg, arg2)
                  if fn89(arg2) then
                    return
                  end

                  if arg2:IsA("BasePart") or arg2:IsA("Decal") or arg2:IsA("Texture") then
                    arg.hidden[arg2] = true
                    tbl31.claim(arg2, "Transparency", 1)
                  end
                end

                local fn117 = nil

                fn117 = function(arg)
                  if obj8[arg] then
                    return
                  end
                  local handle = arg:FindFirstChild("Handle")

                  if not handle then
                    if obj10[arg] then
                      return
                    end
                    local v89 = nil

                    obj10[arg] = arg.ChildAdded:Connect(function(child)
                      if child.Name == "Handle" then
                        pcall(function()
                          v89:Disconnect()
                        end)

                        obj10[arg] = nil

                        if v88 then
                          fn117(arg)
                        end
                      end
                    end)

                    return
                  end

                  local tbl34 = { hidden = {}, conns = {} }
                  obj8[arg] = tbl34

                  for _, descendant in ipairs(arg:GetDescendants()) do
                    fn116(tbl34, descendant)
                  end

                  local v89 = fn88(arg)
                  local v90 = fn114(v89 and v89.key == "Bat" and "Bat" or "Medusa")
                  tbl34.cat = v89 and v89.key == "Bat" and "Bat" or "Medusa"
                  createModel(handle, v90)

                  table.insert(
                    tbl34.conns,
                    arg.DescendantAdded:Connect(function(descendant)
                      task.defer(function()
                        if obj8[arg] then
                          fn116(tbl34, descendant)
                        end
                      end)
                    end)
                  )

                  table.insert(
                    tbl34.conns,
                    arg.AncestryChanged:Connect(function(child, parent)
                      if not parent then
                        fn115(arg, false)
                      end
                    end)
                  )
                end

                fn115 = function(arg)
                  local v89 = obj8[arg]
                  if not v89 then
                    return
                  end

                  for _, conn in ipairs(v89.conns) do
                    pcall(function()
                      conn:Disconnect()
                    end)
                  end

                  local handle = arg:FindFirstChild("Handle")

                  if handle then
                    local localReplica = handle:FindFirstChild("LocalReplica")

                    if localReplica then
                      pcall(function()
                        localReplica:Destroy()
                      end)
                    end
                  end

                  for k in pairs(v89.hidden) do
                    tbl31.release(k, "custom")
                  end

                  v89.hidden = {}
                  obj8[arg] = nil
                end

                local function fn118(child)
                  if not v88 then
                    return
                  end

                  if child:IsA("Tool") and fn88(child) then
                    fn117(child)
                  end
                end

                local function fn119(arg)
                  local v89 = obj9[arg]
                  if not v89 then
                    return
                  end

                  for _, v90 in ipairs(v89) do
                    pcall(function()
                      v90:Disconnect()
                    end)
                  end

                  obj9[arg] = nil
                end

                local function fn120(arg)
                  if not arg or obj9[arg] then
                    return
                  end
                  obj9[arg] = { arg.ChildAdded:Connect(fn118) }

                  for _, child in ipairs(arg:GetChildren()) do
                    fn118(child)
                  end
                end

                local function fn121()
                  fn120(localPlayer2:FindFirstChildOfClass("Backpack"))
                  fn120(localPlayer2.Character)
                end

                localPlayer2.ChildAdded:Connect(function(child)
                  if v88 and child:IsA("Backpack") then
                    fn120(child)
                  end
                end)

                localPlayer2.CharacterAdded:Connect(function(character)
                  for k in pairs(obj8) do
                    fn115(k, false)
                  end

                  for _, v89 in pairs(obj10) do
                    pcall(function()
                      v89:Disconnect()
                    end)
                  end

                  table.clear(obj10)

                  for k in pairs(obj9) do
                    fn119(k)
                  end

                  if not v88 then
                    return
                  end
                  fn120(character)

                  task.defer(function()
                    if v88 then
                      fn121()
                    end
                  end)
                end)

                table.insert(tbl33, function()
                  for k in pairs(obj8) do
                    if not k.Parent then
                      fn115(k, false)
                    end
                  end

                  for k, v89 in pairs(obj10) do
                    if not k.Parent then
                      pcall(function()
                        v89:Disconnect()
                      end)

                      obj10[k] = nil
                    end
                  end

                  for k in pairs(obj9) do
                    if not k.Parent then
                      fn119(k)
                    end
                  end
                end)

                local function fn122(arg, arg2, arg3)
                  local handle = arg:FindFirstChild("Handle")
                  if not handle then
                    return
                  end
                  local localReplica = handle:FindFirstChild("LocalReplica")
                  local mainPart = localReplica and localReplica:FindFirstChild("MainPart")
                  local motor6D = mainPart and mainPart:FindFirstChildOfClass("Motor6D")
                  local flag22 = not localReplica
                    or not mainPart
                    or not motor6D
                    or motor6D.Part0 ~= handle

                  if flag22 then
                    local v89 = fn88(arg)
                    createModel(handle, fn114(v89 and v89.key == "Bat" and "Bat" or "Medusa"))
                  end

                  if flag22 or arg3 then
                    for _, descendant in ipairs(arg:GetDescendants()) do
                      fn116(arg2, descendant)
                    end
                  end
                end

                local function fn123(arg)
                  if not v88 then
                    return
                  end
                  fn121()
                  local v89 = localPlayer2:FindFirstChildOfClass("Backpack")

                  if v89 then
                    for _, child in ipairs(v89:GetChildren()) do
                      fn118(child)
                    end
                  end

                  local character = localPlayer2.Character

                  if character then
                    for _, child in ipairs(character:GetChildren()) do
                      fn118(child)
                    end
                  end

                  for k, v90 in pairs(obj8) do
                    if not k.Parent then
                      fn115(k, false)
                    else
                      fn122(k, v90, arg)
                    end
                  end
                end

                _G.AmbitiousCustomToolsRecheck = function()
                  pcall(fn123, true)
                end

                _G.AmbitiousSetCustomToolSkin = function(arg, arg2)
                  if
                    not ambitiousCustomToolAssets[arg2]
                    or ambitiousCustomToolAssets[arg2].cat ~= arg
                  then
                    return
                  end
                  _G.AmbitiousCustomToolSkins[arg] = arg2

                  for k, v89 in pairs(obj8) do
                    if k.Parent and v89.cat == arg then
                      local v90 = k:FindFirstChild("Handle")

                      if v90 then
                        pcall(createModel, v90, arg2)
                      end
                    end
                  end

                  if saveAmbitiousConfig then
                    pcall(saveAmbitiousConfig)
                  end
                end

                task.spawn(function()
                  local n35 = 0

                  while true do
                    task.wait(0.8)

                    if v88 then
                      n35 += 1
                      pcall(fn123, n35 % 5 == 0)
                    end
                  end
                end)

                localPlayer2.CharacterAdded:Connect(function()
                  task.delay(0.1, function()
                    if v88 then
                      pcall(fn123, true)
                    end
                  end)
                end)

                _G.AmbitiousCustomTools = {
                  setEnabled = function(arg)
                    local ambitiousCustomToolsEnabled = arg and true or false
                    v88 = ambitiousCustomToolsEnabled
                    _G.AmbitiousCustomToolsEnabled = ambitiousCustomToolsEnabled

                    if ambitiousCustomToolsEnabled then
                      fn121()
                      pcall(fn123, true)
                    else
                      for k in pairs(obj8) do
                        fn115(k, true)
                      end

                      for _, v89 in pairs(obj10) do
                        pcall(function()
                          v89:Disconnect()
                        end)
                      end

                      table.clear(obj10)

                      for k in pairs(obj9) do
                        fn119(k)
                      end
                    end
                  end,
                  isEnabled = function()
                    return v88
                  end,
                }

                local tbl34 = {
                  Bat = { id = "rbxassetid://5713085119", skip = 0.2 },
                  Medusa = {
                    id = "rbxassetid://3102797479",
                    doublePlay = true,
                    delay = 0.5,
                  },
                }

                local obj11 = setmetatable({}, { __mode = "k" })
                local v89 = false
                local obj12 = setmetatable({}, { __mode = "k" })
                local obj13 = setmetatable({}, { __mode = "k" })
                local obj14 = setmetatable({}, { __mode = "k" })
                local fn124 = nil

                local function fn125(arg)
                  local sound = arg.sound
                  if not sound or not sound.Parent then
                    return
                  end
                  local data = arg.data

                  if arg.timer then
                    pcall(task.cancel, arg.timer)
                    arg.timer = nil
                  end

                  pcall(function()
                    sound:Stop()
                    sound.TimePosition = data.skip or 0
                    sound.Volume = 1
                    sound:Play()
                  end)

                  if data.doublePlay and data.delay then
                    arg.timer = task.delay(data.delay, function()
                      arg.timer = nil
                      if not v89 then
                        return
                      end

                      if sound and sound.Parent then
                        pcall(function()
                          sound:Stop()
                          sound.TimePosition = data.skip or 0
                          sound.Volume = 1
                          sound:Play()
                        end)
                      end
                    end)
                  end
                end

                local function fn126(arg, arg2)
                  if not arg2:IsA("Sound") then
                    return
                  end

                  if arg2.Name == "CustomSound" then
                    return
                  end

                  if obj11[arg2] then
                    return
                  end

                  if arg.muted[arg2] ~= nil then
                    return
                  end
                  arg.muted[arg2] = arg2.Volume
                  obj11[arg2] = true

                  local function fn127()
                    if not v89 then
                      return
                    end

                    if arg2.Playing or arg2.TimePosition > 0 then
                      pcall(function()
                        arg2.Volume = 0
                        arg2:Stop()
                      end)

                      fn125(arg)
                    end
                  end

                  local connection = arg2:GetPropertyChangedSignal("Enabled"):Connect(fn127)
                  local connection2 = arg2:GetPropertyChangedSignal("TimePosition"):Connect(fn127)
                  table.insert(arg.conns, connection)
                  table.insert(arg.conns, connection2)
                  local connection3 = nil

                  connection3 = arg2.AncestryChanged:Connect(function(child, parent)
                    if parent then
                      return
                    end

                    pcall(function()
                      connection:Disconnect()
                    end)

                    pcall(function()
                      connection2:Disconnect()
                    end)

                    pcall(function()
                      connection3:Disconnect()
                    end)

                    obj11[arg2] = nil
                    arg.muted[arg2] = nil

                    if arg.timer then
                      pcall(task.cancel, arg.timer)
                      arg.timer = nil
                    end
                  end)

                  table.insert(arg.conns, connection3)

                  if arg2.Playing then
                    fn127()
                  end
                end

                local fn127 = nil

                fn127 = function(arg)
                  if obj12[arg] then
                    return
                  end
                  local v90 = fn88(arg)
                  if not v90 then
                    return
                  end
                  local v91 = tbl34[v90.key]
                  if not v91 then
                    return
                  end
                  local handle = arg:FindFirstChild("Handle")

                  if not handle then
                    if obj14[arg] then
                      return
                    end
                    local v92 = nil

                    obj14[arg] = arg.ChildAdded:Connect(function(child)
                      if child.Name == "Handle" then
                        pcall(function()
                          v92:Disconnect()
                        end)

                        obj14[arg] = nil

                        if v89 then
                          fn127(arg)
                        end
                      end
                    end)

                    return
                  end

                  local v92 = handle:FindFirstChild("greenduelsBatSound")

                  if v92 then
                    pcall(function()
                      v92:Destroy()
                    end)
                  end

                  local instance2 = Instance.new("Sound")
                  instance2.Name = "greenduelsBatSound"
                  instance2.SoundId = v91.id
                  instance2.Volume = 1
                  instance2.Looped = false
                  instance2.RollOffMode = Enum.RollOffMode.Inverse
                  instance2.MaxDistance = 1000
                  instance2.MinDistance = 1000
                  instance2.Parent = handle

                  local tbl35 = { sound = instance2, data = v91, conns = {}, muted = {} }
                  obj12[arg] = tbl35

                  for _, descendant in ipairs(arg:GetDescendants()) do
                    fn126(tbl35, descendant)
                  end

                  table.insert(
                    tbl35.conns,
                    arg.DescendantAdded:Connect(function(descendant)
                      if obj12[arg] then
                        fn126(tbl35, descendant)
                      end
                    end)
                  )

                  table.insert(
                    tbl35.conns,
                    arg.AncestryChanged:Connect(function(child, parent)
                      if not parent then
                        fn124(arg)
                      end
                    end)
                  )
                end

                fn124 = function(arg)
                  local v90 = obj12[arg]
                  if not v90 then
                    return
                  end

                  if v90.timer then
                    pcall(task.cancel, v90.timer)
                    v90.timer = nil
                  end

                  for _, conn in ipairs(v90.conns) do
                    pcall(function()
                      conn:Disconnect()
                    end)
                  end

                  if v90.sound then
                    pcall(function()
                      v90.sound:Destroy()
                    end)
                  end

                  for k, v91 in pairs(v90.muted) do
                    obj11[k] = nil

                    if k and k.Parent then
                      pcall(function()
                        k.Volume = v91
                      end)
                    end
                  end

                  obj12[arg] = nil
                end

                local function fn128(child)
                  if not v89 then
                    return
                  end

                  if child:IsA("Tool") and fn88(child) then
                    fn127(child)
                  end
                end

                local function fn129(arg)
                  local v90 = obj13[arg]
                  if not v90 then
                    return
                  end

                  for _, v91 in ipairs(v90) do
                    pcall(function()
                      v91:Disconnect()
                    end)
                  end

                  obj13[arg] = nil
                end

                local function fn130(arg)
                  if not arg or obj13[arg] then
                    return
                  end
                  obj13[arg] = { arg.ChildAdded:Connect(fn128) }

                  for _, child in ipairs(arg:GetChildren()) do
                    fn128(child)
                  end
                end

                local function fn131()
                  fn130(localPlayer2:FindFirstChildOfClass("Backpack"))
                  fn130(localPlayer2.Character)
                end

                localPlayer2.ChildAdded:Connect(function(child)
                  if v89 and child:IsA("Backpack") then
                    fn130(child)
                  end
                end)

                localPlayer2.CharacterAdded:Connect(function(character)
                  for k in pairs(obj12) do
                    fn124(k)
                  end

                  for _, v90 in pairs(obj14) do
                    pcall(function()
                      v90:Disconnect()
                    end)
                  end

                  table.clear(obj14)

                  for k in pairs(obj13) do
                    fn129(k)
                  end

                  if not v89 then
                    return
                  end
                  fn130(character)

                  task.defer(function()
                    if v89 then
                      fn131()
                    end
                  end)
                end)

                table.insert(tbl33, function()
                  for k in pairs(obj12) do
                    if not k.Parent then
                      fn124(k)
                    end
                  end

                  for k, v90 in pairs(obj14) do
                    if not k.Parent then
                      pcall(function()
                        v90:Disconnect()
                      end)

                      obj14[k] = nil
                    end
                  end

                  for k in pairs(obj13) do
                    if not k.Parent then
                      fn129(k)
                    end
                  end
                end)

                _G.AmbitiousCustomSounds = {
                  setEnabled = function(arg)
                    local ambitiousCustomSoundsEnabled = arg and true or false
                    v89 = ambitiousCustomSoundsEnabled
                    _G.AmbitiousCustomSoundsEnabled = ambitiousCustomSoundsEnabled

                    if ambitiousCustomSoundsEnabled then
                      fn131()
                    else
                      for k in pairs(obj12) do
                        fn124(k)
                      end

                      for _, v90 in pairs(obj14) do
                        pcall(function()
                          v90:Disconnect()
                        end)
                      end

                      table.clear(obj14)

                      for k in pairs(obj13) do
                        fn129(k)
                      end
                    end
                  end,
                  isEnabled = function()
                    return v89
                  end,
                }

                _G.AmbitiousRainbowToolsEnabled = false
                _G.AmbitiousTransparentToolsEnabled = false
                _G.AmbitiousCustomToolsEnabled = false
                _G.AmbitiousCustomSoundsEnabled = false
              end

              fn87()
            end
          end

          do
            local function greenduelsStartRagdollCountdown(arg)
              tbl18.ragdollTimerEnabled = true
              tbl18._ragdollTimerToken = (tbl18._ragdollTimerToken or 0) + 1
              local ragdollTimerToken = tbl18._ragdollTimerToken

              task.spawn(function()
                local v87 = localPlayer:FindFirstChild("PlayerGui")
                local character = localPlayer.Character
                character = character and character:FindFirstChild("Head")
                if not (v87 and character) then
                  return
                end
                local ragCountdownBillboard = v87:FindFirstChild("RagCountdownBillboard")

                if not ragCountdownBillboard then
                  local billboardGui = Instance.new("BillboardGui")
                  billboardGui.Name = "RagCountdownBillboard"
                  billboardGui.Parent = v87

                  ragCountdownBillboard = billboardGui
                end

                ragCountdownBillboard.Size = UDim2.new(0, 84, 0, 42)
                ragCountdownBillboard.StudsOffset = Vector3.new(0, 3.45, 0)
                ragCountdownBillboard.AlwaysOnTop = true
                ragCountdownBillboard.Adornee = character
                local ragdollTimerLbl = ragCountdownBillboard:FindFirstChild("RagdollTimerLbl")

                if not ragdollTimerLbl then
                  ragdollTimerLbl = Instance.new("TextLabel")
                  ragdollTimerLbl.Name = "RagdollTimerLbl"
                  ragdollTimerLbl.Parent = ragCountdownBillboard
                end

                ragdollTimerLbl.Size = UDim2.new(1, 0, 1, 0)
                ragdollTimerLbl.AnchorPoint = Vector2.new(0.5, 0.5)
                ragdollTimerLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
                ragdollTimerLbl.BackgroundTransparency = 1
                ragdollTimerLbl.Font = Enum.Font.GothamBlack
                ragdollTimerLbl.TextScaled = true
                ragdollTimerLbl.TextColor3 = Color3.fromRGB(0, 255, 100)
                ragdollTimerLbl.TextStrokeColor3 = Color3.fromRGB(2, 10, 6)
                ragdollTimerLbl.TextStrokeTransparency = 0
                ragdollTimerLbl.Visible = true
                local max = math.max
                local floor2 = math.floor
                local n34 = arg or 2.6

                for i = max(1, floor2(n34 * 10 + 0.5)), 1, -1 do
                  if ragdollTimerToken ~= tbl18._ragdollTimerToken then
                    return
                  end
                  ragdollTimerLbl.Text = string.format("%.1f", i * 0.1)
                  task.wait(0.5)
                end

                if ragdollTimerToken == tbl18._ragdollTimerToken then
                  ragdollTimerLbl.Text = ""
                end
              end)
            end

            _G.greenduelsStartRagdollCountdown = greenduelsStartRagdollCountdown

            local function greenduelsStartOtherRagdollCount(arg, arg2)
              if not (arg and arg ~= localPlayer) then
                return
              end
              tbl18._otherRagTokens = tbl18._otherRagTokens or {}
              local userId = arg.UserId
              tbl18._otherRagTokens[userId] = (tbl18._otherRagTokens[userId] or 0) + 1
              local v87 = tbl18._otherRagTokens[userId]

              task.spawn(function()
                local playerGui = localPlayer:FindFirstChild("PlayerGui")
                local character = arg.Character
                character = character and character:FindFirstChild("Head")
                if not (playerGui and character) then
                  return
                end
                local name = "RagCountdownBillboard_" .. tostring(userId)
                local v88 = playerGui:FindFirstChild(name)

                if not v88 then
                  local billboardGui = Instance.new("BillboardGui")
                  billboardGui.Name = name
                  billboardGui.Parent = playerGui

                  v88 = billboardGui
                end

                v88.Size = UDim2.new(0, 84, 0, 42)
                v88.StudsOffset = Vector3.new(0, 3.45, 0)
                v88.AlwaysOnTop = true
                v88.Adornee = character
                local ragdollTimerLbl = v88:FindFirstChild("RagdollTimerLbl")

                if not ragdollTimerLbl then
                  ragdollTimerLbl = Instance.new("TextLabel")
                  ragdollTimerLbl.Name = "RagdollTimerLbl"
                  ragdollTimerLbl.Parent = v88
                end

                ragdollTimerLbl.Size = UDim2.new(1, 0, 1, 0)
                ragdollTimerLbl.AnchorPoint = Vector2.new(0.5, 0.5)
                ragdollTimerLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
                ragdollTimerLbl.BackgroundTransparency = 1
                ragdollTimerLbl.Font = Enum.Font.GothamBlack
                ragdollTimerLbl.TextScaled = true
                ragdollTimerLbl.TextColor3 = Color3.fromRGB(0, 200, 100)
                ragdollTimerLbl.TextStrokeColor3 = Color3.fromRGB(2, 10, 6)
                ragdollTimerLbl.TextStrokeTransparency = 0
                ragdollTimerLbl.Visible = true
                local max = math.max
                local floor2 = math.floor
                local v89 = arg2 or 1.5

                for i = max(1, floor2(v89 * 10 + 0.5)), 1, -1 do
                  if v87 ~= tbl18._otherRagTokens[userId] then
                    return
                  end
                  ragdollTimerLbl.Text = string.format("%.1f", i * 0.1)
                  task.wait(0.1)
                end

                if v87 == tbl18._otherRagTokens[userId] then
                  ragdollTimerLbl.Text = ""
                end
              end)
            end

            _G.greenduelsStartOtherRagdollCountdown = greenduelsStartOtherRagdollCount

            local function fn87(arg)
              if not arg then
                return false
              end
              tbl18._medusaPerfCache = tbl18._medusaPerfCache or setmetatable({}, { __mode = "k" })
              local now2 = os.clock()
              local v87 = tbl18._medusaPerfCache[arg]
              if v87 and now2 < v87.untilAt then
                return v87.value
              end

              local function fn88()
                if not arg then
                  return false
                end
                local humanoid2 = arg:FindFirstChildOfClass("Humanoid")

                for _, v88 in ipairs({
                  "Ragdoll",
                  "Freeze",
                  "Stone",
                  "Stoned",
                  "Medusa",
                  "Petrified",
                  "IsFrozen",
                  "IsStoned",
                  "Petrified",
                }) do
                  local ok, result = pcall(function()
                    return arg:GetAttribute(v88)
                  end)

                  if ok and (result == true or tonumber(result) == 1) then
                    return true
                  end

                  if humanoid2 then
                    local ok2, result2 = pcall(function()
                      return humanoid2:GetAttribute(v88)
                    end)

                    if ok2 and (result2 == true or tonumber(result2) == 1) then
                      return true
                    end
                  end

                  local v89 = arg:FindFirstChild(v88, true)
                  if v89 and v89:IsA("BoolValue") and v89.Value == true then
                    return true
                  end
                end

                for _, descendant in ipairs(arg:GetDescendants()) do
                  if descendant:IsA("BasePart") then
                    local str6 = descendant.Name:lower()
                    local anchored = descendant.Anchored
                    local pos

                    if anchored then
                      pos = descendant.Transparency >= 0.5
                        or descendant.Name == "HumanoidRootPart"
                        or str6:find("stone")
                        or str6:find("petrif")
                        or str6:find("medusa")
                    else
                      pos = anchored
                    end

                    if pos then
                      return true
                    end
                  end
                end

                return false
              end

              local v88 = fn88()
              tbl18._medusaPerfCache[arg] = { value = v88, untilAt = now2 + 0.05 }
              return v88
            end

            greenduelsPerfRun.track(service.Heartbeat:Connect(function()
              tbl18._otherRagLast = tbl18._otherRagLast or {}
              tbl18._otherMedLast = tbl18._otherMedLast or {}

              for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                  local character = player.Character
                  local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                  local userId = player.UserId

                  if not humanoid2 or humanoid2.Health <= 0 then
                    tbl18._otherRagLast[userId] = false
                    tbl18._otherMedLast[userId] = false
                  else
                    local state = humanoid2:GetState()
                    local flag21 = state == Enum.HumanoidStateType.Physics
                      or state == Enum.HumanoidStateType.Ragdoll
                      or state == Enum.HumanoidStateType.FallingDown
                    local v87 = fn87(character)

                    if v87 and not tbl18._otherMedLast[userId] then
                      greenduelsStartOtherRagdollCount(player, 3.6)
                    elseif flag21 and not tbl18._otherRagLast[userId] then
                      greenduelsStartOtherRagdollCount(player, v87 and 3.6 or 1.5)
                    end

                    tbl18._otherRagLast[userId] = flag21
                    tbl18._otherMedLast[userId] = v87
                  end
                end
              end
            end))

            greenduelsPerfRun.track(service.Heartbeat:Connect(function()
              local character = localPlayer.Character
              local v87 = character and character:FindFirstChildOfClass("Humanoid")
              if not v87 or v87.Health <= 0 then
                tbl18._selfMedLast = false
                return
              end
              local v88 = fn87(character)

              if v88 and not tbl18._selfMedLast then
                greenduelsStartRagdollCountdown(3.6)

                if tbl18.resetOnMedusa then
                  tbl18._resetOnMedusaAt = tick()
                  pcall(greenduelsInstantReset, false)
                end
              end

              tbl18._selfMedLast = v88
            end))

            _G.greenduelsAR2 = _G.greenduelsAR2
              or { Enabled = false, Connection = nil, ResetCooldown = 0 }
            AR2 = _G.greenduelsAR2

            _G.greenduelsRecoverFromRagdoll = function(arg, cameraSubject, arg2)
              pcall(function()
                local assemblyLinearVelocity = arg2.AssemblyLinearVelocity
                local assemblyLinearVelocity2 = cameraSubject.MoveDirection.Magnitude > 0.05
                local n34 = -200
                local n35 = math.clamp(math.min(assemblyLinearVelocity.Y, 0), n34, 0)

                if assemblyLinearVelocity2 then
                  local z = assemblyLinearVelocity.Z
                  assemblyLinearVelocity2 = Vector3.new(
                    math.clamp(assemblyLinearVelocity.X, -24, 24),
                    n35,
                    math.clamp(z, -24, 56)
                  )
                end

                assemblyLinearVelocity2 = assemblyLinearVelocity2 or Vector3.new(0, n35, 0)
                cameraSubject.PlatformStand = false

                if not fn84() then
                  arg2.AssemblyLinearVelocity = assemblyLinearVelocity2
                  arg2.Velocity = assemblyLinearVelocity2
                  arg2.RotVelocity = Vector3.zero
                  arg2.AssemblyAngularVelocity = Vector3.zero
                end

                cameraSubject:ChangeState(Enum.HumanoidStateType.GettingUp)

                for _, descendant in ipairs(arg:GetDescendants()) do
                  if descendant:IsA("Motor6D") then
                    descendant.Enabled = true
                  end

                  if descendant:IsA("Constraint") then
                    descendant.Enabled = true
                  end
                end

                local currentCamera = workspace.CurrentCamera

                if currentCamera then
                  currentCamera.CameraSubject = cameraSubject
                end

                local playerModule = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")

                if playerModule then
                  local v87 = playerModule:FindFirstChild("ControlModule")

                  if v87 then
                    local module = require(v87)

                    if module then
                      module:Enable()
                    end
                  end
                end

                cameraSubject.AutoRotate = true
                cameraSubject.PlatformStand = false
                cameraSubject.Sit = false
              end)
            end

            greenduelsStartAntiRagdoll = function()
              if AR2.Connection then
                return
              end
              AR2.Enabled = true
              tbl18.antiRagdollEnabled = true

              AR2.Connection = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                if not AR2.Enabled then
                  return
                end
                local character = localPlayer.Character
                if not character then
                  return
                end
                local v87 = character:FindFirstChildOfClass("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not v87 or not humanoidRootPart or v87.Health <= 0 then
                  return
                end
                local state = v87:GetState()

                if
                  state == Enum.HumanoidStateType.Physics
                  or state == Enum.HumanoidStateType.Ragdoll
                  or state == Enum.HumanoidStateType.FallingDown
                then
                  local now2 = tick()

                  if now2 - AR2.ResetCooldown > 0.15 then
                    AR2.ResetCooldown = now2
                    greenduelsStartRagdollCountdown(fn87(character) and 3.6 or 2.6)
                    _G.greenduelsRecoverFromRagdoll(character, v87, humanoidRootPart)
                  end
                end
              end))
            end
          end
        end

        _G.greenduelsStartAntiRagdoll = greenduelsStartAntiRagdoll

        do
          local function fn87()
            AR2.Enabled = false
            tbl18.antiRagdollEnabled = false

            if AR2.Connection then
              AR2.Connection:Disconnect()
              AR2.Connection = nil
            end
          end

          _G.greenduelsAntiRagdollWatchdog = (_G.greenduelsAntiRagdollWatchdog or 0) + 1

          task.spawn(function()
            local greenduelsAntiRagdollWatchdog = _G.greenduelsAntiRagdollWatchdog

            while _G.greenduelsAntiRagdollWatchdog == greenduelsAntiRagdollWatchdog do
              task.wait(0.5)

              if tbl18 and tbl18.antiRagdollEnabled and not AR2.Connection then
                pcall(greenduelsStartAntiRagdoll)
              end
            end
          end)

          greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function()
            if tbl18.antiRagdollEnabled then
              task.wait(0.5)
              pcall(greenduelsStartAntiRagdoll)
            end
          end))

          if localPlayer.Character then
            task.spawn(function()
              if tbl18.antiRagdollEnabled then
                task.wait(0.5)
                pcall(greenduelsStartAntiRagdoll)
              end

              return
            end)
          end

          _G.greenduelsMain = function()
            if _G.greenduelsV2_MainExecuted then
              return
            end
            _G.greenduelsV2_MainExecuted = true
            local screenGui
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "greenduelsV2"
            screenGui.ResetOnSpawn = false
            screenGui.DisplayOrder = 10
            screenGui.IgnoreGuiInset = true
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
            screenGui.Enabled = false
            local greenduelsPlayIntro
            local TextService = game:GetService("TextService")

            greenduelsPlayIntro = function()
              local playerGui = localPlayer:FindFirstChild("PlayerGui")
                or localPlayer:WaitForChild("PlayerGui", 5)
              if not playerGui then
                return
              end
              local greenduelsIntro = playerGui:FindFirstChild("greenduelsIntro")

              if greenduelsIntro then
                greenduelsIntro:Destroy()
              end

              local screenGui2 = Instance.new("ScreenGui")
              screenGui2.Name = "greenduelsKickWarning"
              screenGui2.IgnoreGuiInset = true
              screenGui2.ResetOnSpawn = false
              screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
              screenGui2.DisplayOrder = 999999
              screenGui2.Enabled = false

              local function fn88()
                task.wait()
              end

              _G.greenduelsIntroPlaying = true
              local flag21 = false

              local function fn89()
                if flag21 then
                  return
                end
                flag21 = true
                _G.greenduelsIntroPlaying = false

                if _G.greenduelsIntroFinished then
                  pcall(_G.greenduelsIntroFinished)
                end
              end

              local flag22 = false
              local v87 = nil
              local fn90 = nil
              local sound = nil
              local n34 = 0

              local tbl30 = {
                ["Intro 1"] = {
                  url = "https://files.catbox.moe/ce09hb.mp3",
                  file = "greenduelsIntroSong1_ce09hb.mp3",
                },
                ["Intro 2"] = {
                  url = "https://files.catbox.moe/aw8k5m.mp3",
                  file = "greenduelsIntroSong2_aw8k5m.mp3",
                },
                ["Intro 3"] = {
                  url = "https://files.catbox.moe/bumu1r.mp3",
                  file = "greenduelsIntroSong3_bumu1r.mp3",
                },
                ["Intro 4"] = {
                  url = "https://files.catbox.moe/rweyqn.mp3",
                  file = "greenduelsIntroSong4_rweyqn.mp3",
                },
              }

              local tbl31 = {}

              local function fn91(arg)
                local v88 = tbl30[arg or "Intro 1"]
                if not v88 then
                  return nil
                end

                if tbl31[arg] then
                  return tbl31[arg]
                end
                local v89 = getcustomasset or getsynasset
                local writefile_ = writefile
                  or syn and syn.writefile
                  or getgenv and getgenv().writefile
                if type(v89) ~= "function" or type(writefile_) ~= "function" then
                  return nil
                end
                local flag23 = false

                pcall(function()
                  flag23 = type(isfile) == "function" and isfile(v88.file)
                end)

                if not flag23 then
                  local ok, result = pcall(function()
                    return game:HttpGet(v88.url)
                  end)

                  if not ok or type(result) ~= "string" or #result == 0 then
                    return nil
                  end

                  if not pcall(writefile_, v88.file, result) then
                    return nil
                  end
                end

                local ok, result = pcall(v89, v88.file)
                if not ok or not result then
                  return nil
                end
                tbl31[arg] = result
                return result
              end

              local function fn92()
                n34 += 1

                if sound then
                  pcall(function()
                    sound:Stop()
                  end)

                  pcall(function()
                    sound:Destroy()
                  end)

                  sound = nil
                end
              end

              local function fn93()
                if flag22 then
                  return
                end
                fn92()
                n34 += 1
                local v88 = n34
                local v89 = fn91(tbl18.introMusic or "Intro 1")
                if v88 ~= n34 or not v89 then
                  return
                end
                sound = Instance.new("Sound")
                sound.Name = "greenduelsIntroMusic"
                sound.SoundId = v89
                sound.Volume = 1
                sound.PlayOnRemove = false
                sound.Looped = false
                sound.Parent = game:GetService("SoundService")

                task.defer(function()
                  if v88 == n34 and sound and sound.Parent and not flag22 then
                    pcall(function()
                      sound:Play()
                    end)

                    task.spawn(function()
                      local n35 = tick() + 2.5

                      while sound and sound.Parent and not sound.IsLoaded and tick() < n35 do
                        task.wait(0.05)
                      end

                      if v88 == n34 and sound and sound.Parent and not flag22 then
                        pcall(function()
                          local timePosition = tbl18.introMusic == "Intro 1" and 58
                            or tbl18.introMusic == "Intro 2" and 45
                            or 0

                          if sound.TimeLength and sound.TimeLength > timePosition + 0.25 then
                            sound.TimePosition = timePosition
                          end
                        end)

                        if not sound.IsPlaying then
                          pcall(function()
                            sound:Play()
                          end)
                        end

                        task.delay(0.5, function()
                          if sound and sound.Parent and not sound.IsPlaying and not flag22 then
                            pcall(function()
                              sound:Play()
                            end)
                          end
                        end)
                      end
                    end)
                  end
                end)
              end

              local color = Color3.fromRGB(70, 220, 105)
              local color2 = Color3.fromRGB(20, 150, 55)
              local blurEffect = Instance.new("BlurEffect")
              blurEffect.Size = 0

              local instance2 = Instance.new("Frame")
              instance2.Size = UDim2.fromScale(1, 1)
              instance2.BackgroundColor3 = Color3.fromRGB(2, 12, 6)
              instance2.BackgroundTransparency = 0.3
              instance2.BorderSizePixel = 0
              instance2.ZIndex = 1
              instance2.Parent = screenGui2

              screenGui2.Parent = playerGui
              screenGui2.Enabled = true
              fn88()

              local instance3 = Instance.new("ImageLabel")
              instance3.Size = UDim2.fromScale(1, 1)
              instance3.BackgroundColor3 = Color3.fromRGB(2, 10, 6)
              instance3.BackgroundTransparency = 0
              instance3.Image = ""
              instance3.ImageTransparency = 0
              instance3.ScaleType = Enum.ScaleType.Crop
              instance3.BorderSizePixel = 0
              instance3.ZIndex = 0
              instance3.Parent = screenGui2

              task.defer(function()
                task.wait()

                if instance3 and instance3.Parent then
                  instance3.Image = "rbxassetid://79007351337249"
                end
              end)

              fn88()

              local imageLabel = Instance.new("ImageLabel")
              imageLabel.Size = UDim2.fromScale(1, 1)
              imageLabel.BackgroundTransparency = 1
              imageLabel.Image = "rbxassetid://195611797"
              imageLabel.ImageColor3 = Color3.fromRGB(2, 10, 6)
              imageLabel.ImageTransparency = 0.35
              imageLabel.ZIndex = 2
              imageLabel.Parent = screenGui2

              local frame = Instance.new("Frame")
              frame.Size = UDim2.new(0, 850, 0, 130)
              frame.AnchorPoint = Vector2.new(0.5, 0.5)
              frame.Position = UDim2.new(0.5, 0, 0.5, 0)
              frame.BackgroundTransparency = 1
              frame.BorderSizePixel = 0
              frame.ClipsDescendants = false
              frame.ZIndex = 5
              frame.Parent = screenGui2

              local textLabel2 = Instance.new("TextLabel")
              textLabel2.Size = UDim2.new(1, 0, 1, 0)
              textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
              textLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
              textLabel2.BackgroundTransparency = 1
              textLabel2.Text = "greenduels"
              textLabel2.TextColor3 = color
              textLabel2.TextStrokeColor3 = Color3.fromRGB(2, 12, 6)
              textLabel2.TextStrokeTransparency = 0
              textLabel2.Font = Enum.Font.GothamBlack
              textLabel2.TextSize = 88
              textLabel2.TextXAlignment = Enum.TextXAlignment.Center
              textLabel2.TextTransparency = 1
              textLabel2.ZIndex = 5
              textLabel2.Parent = frame

              local textLabel3 = Instance.new("TextLabel")
              textLabel3.Size = UDim2.new(0, 480, 1, 0)
              textLabel3.AnchorPoint = Vector2.new(1, 0.5)
              textLabel3.Position = UDim2.new(0.5, -40, 0.5, 0)
              textLabel3.BackgroundTransparency = 1
              textLabel3.Text = "Green"
              textLabel3.TextColor3 = color
              textLabel3.TextStrokeColor3 = Color3.fromRGB(2, 12, 6)
              textLabel3.TextStrokeTransparency = 0
              textLabel3.Font = Enum.Font.GothamBlack
              textLabel3.TextSize = 16
              textLabel3.TextXAlignment = Enum.TextXAlignment.Right
              textLabel3.TextTransparency = 1
              textLabel3.ZIndex = 5
              textLabel3.Visible = true
              textLabel3.Parent = frame

              local textLabel4 = Instance.new("TextLabel")
              textLabel4.Size = UDim2.new(0, 320, 1, 0)
              textLabel4.AnchorPoint = Vector2.new(0, 0.5)
              textLabel4.Position = UDim2.new(0.5, -8, 0.5, 0)
              textLabel4.BackgroundTransparency = 1
              textLabel4.Text = "greenduels"
              textLabel4.TextColor3 = color
              textLabel4.TextStrokeColor3 = Color3.fromRGB(2, 12, 6)
              textLabel4.TextStrokeTransparency = 0
              textLabel4.Font = Enum.Font.GothamBlack
              textLabel4.TextSize = 88
              textLabel4.TextXAlignment = Enum.TextXAlignment.Left
              textLabel4.TextTransparency = 1
              textLabel4.ZIndex = 5
              textLabel4.Visible = true
              textLabel4.Parent = frame

              fn88()

              local frame2 = Instance.new("Frame")
              frame2.Size = UDim2.new(0, 0, 1.1, 0)
              frame2.AnchorPoint = Vector2.new(0, 0.5)
              frame2.Position = UDim2.new(0, -20, 0.5, 0)
              frame2.BackgroundColor3 = color
              frame2.BackgroundTransparency = 0.5
              frame2.BorderSizePixel = 0
              frame2.ZIndex = 6
              frame2.Parent = frame

              local frame3 = Instance.new("Frame")
              frame3.Size = UDim2.new(0, 0, 0.5, 0)
              frame3.AnchorPoint = Vector2.new(0, 0.5)
              frame3.Position = UDim2.new(0, -170, 0.5, 0)
              frame3.BackgroundColor3 = color2
              frame3.BackgroundTransparency = 0.7
              frame3.BorderSizePixel = 0
              frame3.ZIndex = 5
              frame3.Parent = frame

              local frame4 = Instance.new("Frame")
              frame4.Size = UDim2.new(0, 0, 1, 0)
              frame4.AnchorPoint = Vector2.new(0, 0.5)
              frame4.Position = UDim2.new(0, -20, 0.5, 0)
              frame4.BackgroundColor3 = Color3.fromRGB(100, 200, 145)
              frame4.BackgroundTransparency = 0.8
              frame4.BorderSizePixel = 0
              frame4.ZIndex = 7
              frame4.Parent = frame

              local textLabel5 = Instance.new("TextLabel")
              textLabel5.Size = UDim2.new(1, 0, 0, 40)
              textLabel5.AnchorPoint = Vector2.new(0.5, 0)
              textLabel5.Position = UDim2.new(0.5, 0, 0.5, 70)
              textLabel5.BackgroundTransparency = 1
              textLabel5.Text = "greenduels On Top"
              textLabel5.TextColor3 = color
              textLabel5.Font = Enum.Font.GothamBold
              textLabel5.TextSize = 14
              textLabel5.TextXAlignment = Enum.TextXAlignment.Center
              textLabel5.TextTransparency = 1
              textLabel5.ZIndex = 5
              textLabel5.Parent = screenGui2

              local textLabel6 = Instance.new("TextLabel")
              textLabel6.Size = UDim2.new(1, 0, 0, 25)
              textLabel6.AnchorPoint = Vector2.new(0.5, 0)
              textLabel6.Position = UDim2.new(0.5, 0, 0.5, 105)
              textLabel6.BackgroundTransparency = 1
              textLabel6.Text = "TAP THE SCREEN TO SKIP INTRO"
              textLabel6.TextColor3 = Color3.fromRGB(255, 150, 105)
              textLabel6.Font = Enum.Font.Gotham
              textLabel6.TextSize = 11
              textLabel6.TextXAlignment = Enum.TextXAlignment.Center
              textLabel6.TextTransparency = 1
              textLabel6.ZIndex = 5
              textLabel6.Parent = screenGui2

              local frame5 = Instance.new("Frame")
              frame5.Size = UDim2.new(0, 0, 0, 2)
              frame5.AnchorPoint = Vector2.new(0.5, 0)
              frame5.Position = UDim2.new(0.5, 0, 0.5, 62)
              frame5.BackgroundColor3 = color
              frame5.BackgroundTransparency = 0
              frame5.BorderSizePixel = 0
              frame5.ZIndex = 5
              frame5.Parent = screenGui2

              local frame6 = Instance.new("Frame")
              frame6.Size = UDim2.fromScale(1, 1)
              frame6.BackgroundColor3 = Color3.fromRGB(85, 200, 145)
              frame6.BackgroundTransparency = 1
              frame6.BorderSizePixel = 0
              frame6.ZIndex = 10
              frame6.Parent = screenGui2

              fn88()

              local instance4 = Instance.new("Frame")
              instance4.Size = UDim2.new(1, 0, 1, 0)
              instance4.BackgroundTransparency = 1
              instance4.ZIndex = 6
              instance4.Parent = screenGui2

              local frame7 = Instance.new("Frame")
              frame7.Size = UDim2.new(1, 0, 1, 0)
              frame7.BackgroundTransparency = 1
              frame7.ZIndex = 4
              frame7.Parent = screenGui2

              local frame8 = Instance.new("Frame")
              frame8.Size = UDim2.new(0, 90, 0, 40)
              frame8.AnchorPoint = Vector2.new(1, 1)
              frame8.Position = UDim2.new(1, -18, 1, -18)
              frame8.BackgroundColor3 = Color3.fromRGB(8, 42, 18)
              frame8.BackgroundTransparency = 0.25
              frame8.BorderSizePixel = 0
              frame8.ZIndex = 16
              frame8.Parent = screenGui2

              local uiCorner = Instance.new("UICorner")
              uiCorner.CornerRadius = UDim.new(0, 40)
              uiCorner.Parent = frame8

              local instance5 = Instance.new("UIStroke")
              instance5.Color = color
              instance5.Thickness = 1.5
              instance5.Transparency = 0.5
              instance5.Parent = frame8

              local instance6 = Instance.new("TextButton")
              instance6.Size = UDim2.fromScale(1, 1)
              instance6.BackgroundTransparency = 1
              instance6.Text = "SKIP >"
              instance6.TextColor3 = color
              instance6.Font = Enum.Font.GothamBold
              instance6.TextSize = 13
              instance6.TextXAlignment = Enum.TextXAlignment.Center
              instance6.TextTransparency = 0
              instance6.ZIndex = 16
              instance6.Parent = frame8

              instance6.Activated:Connect(function()
                if fn90 then
                  fn90()
                end
              end)

              fn88()

              local function fn94(backgroundColor3, arg, arg2)
                frame6.BackgroundColor3 = backgroundColor3 or Color3.fromRGB(100, 255, 145)
                frame6.BackgroundTransparency = 1 - (arg or 0.85)

                task.delay(arg2 or 0.25, function()
                  if not flag22 then
                    TweenService:Create(
                      frame6,
                      TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                      { BackgroundTransparency = 1 }
                    ):Play()
                  elseif frame6 then
                    frame6.BackgroundTransparency = 1
                  end
                end)
              end

              local function fn95()
                frame2.Size = UDim2.new(0, 200, 1.1, 0)
                frame3.Size = UDim2.new(0, 65, 0.5, 0)
                frame4.Size = UDim2.new(0, 45, 1, 0)
                frame2.BackgroundTransparency = 0.35
                frame3.BackgroundTransparency = 0.55
                frame4.BackgroundTransparency = 0.75
                local tween = TweenService:Create(
                  frame2,
                  TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                  { Position = UDim2.new(1, 20, 0.5, 0) }
                )
                tween:Play()
                TweenService
                  :Create(
                    frame3,
                    TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(1, 20, 0.5, 0) }
                  )
                  :Play()
                TweenService
                  :Create(
                    frame4,
                    TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(1, 20, 0.5, 0) }
                  )
                  :Play()
                local n35 = 0
                local v88 = nil

                v88 = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                  if flag22 then
                    if v88 then
                      v88:Disconnect()
                    end

                    return
                  end

                  n35 += 1

                  if n35 % 10 == 0 then
                    local v89 = 0
                    local n36 = 0.5 + math.sin(n35 * 0.5) * v89
                    frame2.BackgroundTransparency = 0.5 - n36 * 0.2
                    frame3.BackgroundTransparency = 0.5 - n36 * 0.5
                    frame4.BackgroundTransparency = 1 - n36 * 0
                  end
                end))

                tween.Completed:Wait()

                if v88 then
                  v88:Disconnect()
                end

                TweenService
                  :Create(
                    frame2,
                    TweenInfo.new(0.25),
                    { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1.1, 0) }
                  )
                  :Play()
                TweenService
                  :Create(
                    frame3,
                    TweenInfo.new(0.25),
                    { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1.3, 0) }
                  )
                  :Play()
                TweenService:Create(frame4, TweenInfo.new(0.25), {
                  BackgroundTransparency = 1,
                  Size = UDim2.new(0, 0, 1, 0),
                }):Play()
              end

              local function fn96()
                task.wait(0.2)

                if not flag22 then
                  local tbl32 = { TextColor3 = color }
                  TweenService
                    :Create(textLabel2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), tbl32)
                    :Play()
                end
              end

              local tbl32 = { "!", "#", "%", "/", "[", "]", "-", "=", "*", "^", "~", "_", "|" }

              local function fn97(arg, text)
                if flag22 then
                  return
                end

                for i = 1, 4 do
                  if not flag22 then
                    local text2 = ""

                    for match in text:gmatch(".") do
                      local v88 = 0.5
                      text2 ..= math.random() < v88 and tbl32[math.random(#tbl32)] or match
                    end

                    arg.Text = text2
                    task.wait(0.1)
                    continue
                  end

                  break
                end

                if not flag22 then
                  arg.Text = text
                end
              end

              local function fn98()
                local instance7 = Instance.new("Frame")
                instance7.Size = UDim2.new(1, 0, 0, math.random(2, 12))
                local v88 = 100
                local v89 = 0
                instance7.Position = UDim2.new(0, 0, math.random(10, 90) / v88, v89)
                instance7.BackgroundColor3 = color
                instance7.BackgroundTransparency = math.random(45, 70) / 100
                instance7.BorderSizePixel = 0
                instance7.ZIndex = 6
                instance7.Parent = instance4

                task.delay(0.1, function()
                  if instance7 then
                    TweenService
                      :Create(instance7, TweenInfo.new(0.1), { BackgroundTransparency = 1 })
                      :Play()

                    task.delay(0.5, function()
                      if instance7 then
                        instance7:Destroy()
                      end
                    end)
                  end
                end)
              end

              local function fn99(arg, arg2)
                if flag22 then
                  return
                end
                local now2 = tick()

                while tick() - now2 < arg2 and not flag22 do
                  local n35 = arg * (1 - (tick() - now2) / arg2)
                  local floor2 = math.floor
                  local n36 = math.random(-math.floor(n35), floor2(n35))
                  local n37 = math.random(-math.floor(n35 * 0.5), math.floor(n35 * 0.5))
                  textLabel3.Position = UDim2.new(0.5, -8 + n36, 0.5, n37)
                  textLabel4.Position = UDim2.new(0.5, 8 + n36, 0.5, n37)
                  task.wait(0.02)
                end

                if not flag22 then
                  TweenService:Create(
                    textLabel3,
                    TweenInfo.new(0.05),
                    { Position = UDim2.new(0.5, -8, 0.5, 0) }
                  ):Play()
                  TweenService:Create(
                    textLabel4,
                    TweenInfo.new(0.05),
                    { Position = UDim2.new(0.5, 8, 0.5, 0) }
                  ):Play()
                end
              end

              local n35 = 0

              local function fn100(arg, arg2, arg3, arg4, arg5, arg6)
                task.wait(arg6)
                if flag22 then
                  return
                end
                n35 += 1

                local frame9 = Instance.new("Frame")
                frame9.Size = UDim2.new(0, arg3, 0, arg4)
                frame9.Position = UDim2.new(0.5, arg, 0.5, arg2)
                frame9.BackgroundColor3 = color
                frame9.BackgroundTransparency = 0.25
                frame9.BorderSizePixel = 0
                frame9.ZIndex = 7
                frame9.Parent = frame7

                TweenService:Create(frame9, TweenInfo.new(arg5 * 0.35), {
                  Size = UDim2.new(0, arg3, 0, arg4 + 22),
                  BackgroundTransparency = 0.1,
                }):Play()
                task.wait(arg5 * 0.35)

                if flag22 then
                  frame9:Destroy()
                  n35 -= 1
                  return
                end

                local tween = TweenService:Create(
                  frame9,
                  TweenInfo.new(arg5 * 0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                  {
                    Position = UDim2.new(0.5, arg + math.random(-3, 3), 0.5, arg2 + 80),
                    BackgroundTransparency = 1,
                  }
                )

                tween:Play()

                tween.Completed:Connect(function()
                  frame9:Destroy()
                  n35 -= 1
                end)
              end

              local function fn101()
                if _G.greenduelsFastIntro then
                  return
                end

                if flag22 then
                  return
                end
                local gothamBlack = Enum.Font.GothamBlack
                local textSize = TextService:GetTextSize(
                  "greenduels",
                  16,
                  gothamBlack,
                  Vector2.new(math.huge, math.huge)
                )
                local y = textSize.Y
                local tbl33 = {}
                local n36 = 0

                for i = 1, 10 do
                  local x = TextService:GetTextSize(
                    ("greenduels"):sub(i, i),
                    88,
                    gothamBlack,
                    Vector2.new(math.huge, math.huge)
                  ).X
                  local n37 = 0

                  if 1 < i then
                    n37 = TextService:GetTextSize(
                      ("greenduels"):sub(1, i - 1),
                      88,
                      gothamBlack,
                      Vector2.new(math.huge, math.huge)
                    ).X
                  end

                  local n38 = -textSize.X / 2 + n37 + x / 2
                  local n39 = y / 2 + 3
                  local v88 = 10
                  local n40 = math.clamp(math.floor(x * 0.35), v88, 7)
                  local n41 = math.random(4, 7)
                  local n42 = 0.5 + math.random() * 0.2
                  local n43 = n36 * 1

                  table.insert(tbl33, {
                    startX = n38 + math.random(-2, 2),
                    startY = n39 + math.random(0, 4),
                    width = n40,
                    height = n41,
                    duration = n42,
                    delay = n43,
                  })

                  n36 += 1
                end

                for _, v88 in ipairs(tbl33) do
                  if not flag22 then
                    task.spawn(
                      fn100,
                      v88.startX,
                      v88.startY,
                      v88.width,
                      v88.height,
                      v88.duration,
                      v88.delay
                    )
                    continue
                  end
                  break
                end
              end

              fn90 = function()
                if flag22 then
                  return
                end
                flag22 = true
                fn92()

                if v87 then
                  v87:Disconnect()
                end

                local v88 = 0.5
                fn94(Color3.fromRGB(140, 255, 165), 0.8, v88)
                textLabel2.Text = "greenduels"
                local tweenInfo =
                  TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                TweenService:Create(textLabel2, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(textLabel3, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(textLabel4, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(textLabel5, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(textLabel6, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(frame5, tweenInfo, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(instance2, tweenInfo, { BackgroundTransparency = 1 })
                  :Play()
                TweenService:Create(instance3, tweenInfo, { ImageTransparency = 1 }):Play()
                local tbl33 = { Size = 0 }
                TweenService:Create(blurEffect, TweenInfo.new(0.25), tbl33):Play()
                task.wait(0.3)
                fn89()

                if screenGui2 then
                  screenGui2:Destroy()
                end

                if blurEffect then
                  blurEffect:Destroy()
                end
              end

              local function fn102()
                task.spawn(fn93)

                if not blurEffect.Parent then
                  blurEffect.Parent = Lighting
                end

                v87 =
                  greenduelsPerfRun.track(service2.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then
                      return
                    end

                    if
                      input.UserInputType == Enum.UserInputType.Touch
                      or input.UserInputType == Enum.UserInputType.MouseButton1
                    then
                      fn90()
                    end
                  end))

                task.spawn(function()
                  while not flag22 and frame8.Parent do
                    for i = 0.25, 0.6, 0.05 do
                      if not flag22 then
                        frame8.BackgroundTransparency = i
                        task.wait(0.06)
                        continue
                      end

                      break
                    end

                    for i = 0.1, 0.25, -0.05 do
                      if not flag22 then
                        frame8.BackgroundTransparency = i
                        task.wait(0.25)
                        continue
                      end

                      break
                    end
                  end
                end)

                textLabel3.Position = UDim2.new(-0.9, 0, -0.6, 0)
                textLabel4.Position = UDim2.new(1.9, 0, 0, 0)
                textLabel3.Rotation = -40
                textLabel4.Rotation = 30
                textLabel2.TextTransparency = 1
                TweenService:Create(blurEffect, TweenInfo.new(1), { Size = 18 }):Play()
                TweenService:Create(instance2, TweenInfo.new(0.7), { BackgroundTransparency = 0.2 })
                  :Play()
                TweenService:Create(instance3, TweenInfo.new(0.7), { ImageTransparency = 0 }):Play()
                task.wait(0.5)
                if flag22 then
                  return
                end
                local tbl33 = { TextTransparency = 0 }
                TweenService:Create(textLabel3, TweenInfo.new(0.45), tbl33):Play()
                TweenService:Create(textLabel4, TweenInfo.new(0.45), { TextTransparency = 0 })
                  :Play()
                TweenService
                  :Create(
                    textLabel3,
                    TweenInfo.new(0.55, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0.5, -220, 0.5, -80), Rotation = -15 }
                  )
                  :Play()
                TweenService
                  :Create(
                    textLabel4,
                    TweenInfo.new(0.55, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0.5, 120, 0.5, 80), Rotation = 15 }
                  )
                  :Play()
                task.wait(0.45)
                if flag22 then
                  return
                end
                local tweenInfo =
                  TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(
                  textLabel3,
                  tweenInfo,
                  { Position = UDim2.new(0.5, -170, 0.5, -45), Rotation = -8 }
                ):Play()
                TweenService:Create(
                  textLabel4,
                  tweenInfo,
                  { Position = UDim2.new(0.5, 170, 0.5, 45), Rotation = 8 }
                ):Play()
                task.wait(0.35)
                if flag22 then
                  return
                end
                TweenService:Create(
                  textLabel3,
                  tweenInfo,
                  { Position = UDim2.new(0.5, -85, 0.5, -25), Rotation = -4 }
                ):Play()
                TweenService:Create(
                  textLabel4,
                  tweenInfo,
                  { Position = UDim2.new(0.5, 80, 0.5, 25), Rotation = 4 }
                ):Play()
                task.wait(0.3)
                if flag22 then
                  return
                end
                TweenService
                  :Create(
                    textLabel3,
                    tweenInfo,
                    { Position = UDim2.new(0.5, -60, 0.5, -10), Rotation = -2 }
                  )
                  :Play()
                TweenService
                  :Create(
                    textLabel4,
                    tweenInfo,
                    { Position = UDim2.new(0.5, -10, 0.5, 10), Rotation = 2 }
                  )
                  :Play()
                task.wait(0.25)
                if flag22 then
                  return
                end
                local n36 = tick() + 0.9

                while tick() < n36 and not flag22 do
                  local n37 = math.random(-20, 20)
                  local n38 = math.random(-10, 10)
                  textLabel3.Position = UDim2.new(0.5, -60 + n37, 0.5, -10 + n38)
                  textLabel4.Position = UDim2.new(0.5, -12 + n37, 0.5, 10 + n38)

                  if math.random() < 0.35 then
                    task.spawn(fn97, textLabel3, "Green")
                  end

                  if math.random() < 0.35 then
                    task.spawn(fn97, textLabel4, "greenduels")
                  end

                  if math.random() < 0.4 then
                    fn98()
                  end

                  if math.random() < 0.1 then
                    fn94(color, 0.2, 0.03)
                  end

                  task.wait(0.045)
                end

                if flag22 then
                  return
                end
                textLabel3.Visible = false
                textLabel4.Visible = false
                textLabel2.TextTransparency = 0
                textLabel2.TextColor3 = color
                fn94(color, 0.5, 0.05)
                task.wait(0.5)

                if not flag22 then
                  TweenService
                    :Create(
                      textLabel2,
                      TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                      { Position = UDim2.new(0.5, 0, 0.5, 0), TextSize = 92 }
                    )
                    :Play()
                  task.wait(0.12)
                  if flag22 then
                    return
                  end
                  TweenService:Create(textLabel2, TweenInfo.new(0.5), { TextSize = 88 }):Play()
                  local v88 = 0.5
                  fn94(Color3.fromRGB(100, 255, 145), v88, 0.05)
                  task.wait(0.2)
                  fn94(color, 0.65, 0.08)
                  task.spawn(fn99, 10, 0.25)
                  fn95()
                  fn96()
                  TweenService
                    :Create(
                      frame5,
                      TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
                      { Size = UDim2.new(0, 420, 0, 2) }
                    )
                    :Play()
                  task.wait(0.18)
                  if flag22 then
                    return
                  end
                  TweenService:Create(textLabel5, TweenInfo.new(0.4), { TextTransparency = 0.05 })
                    :Play()
                  local tbl34 = { TextTransparency = 0 }
                  TweenService:Create(textLabel6, TweenInfo.new(0.3), tbl34):Play()
                  task.wait(0.1)
                  fn94(Color3.fromRGB(85, 255, 145), 0.3, 0.04)
                  local tbl35 = { TextSize = 16 }
                  TweenService:Create(textLabel5, TweenInfo.new(0.2), tbl35):Play()
                  task.wait(0.2)
                  TweenService:Create(textLabel5, TweenInfo.new(0.2), { TextSize = 14 }):Play()
                  task.wait(0.65)
                  if flag22 then
                    return
                  end
                  fn101()

                  while n35 > 0 and not flag22 do
                    task.wait(0.1)
                  end

                  if flag22 then
                    return
                  end
                  task.wait(0.2)
                  task.wait(0)
                  local tweenInfo2 =
                    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                  TweenService:Create(textLabel2, tweenInfo2, { TextTransparency = 1 })
                    :Play()
                  TweenService:Create(textLabel5, tweenInfo2, { TextTransparency = 1 }):Play()
                  TweenService:Create(textLabel6, tweenInfo2, { TextTransparency = 1 }):Play()
                  TweenService:Create(frame5, tweenInfo2, { BackgroundTransparency = 1 }):Play()
                  TweenService:Create(instance2, tweenInfo2, { BackgroundTransparency = 1 }):Play()
                  TweenService:Create(instance3, tweenInfo2, { ImageTransparency = 1 }):Play()
                  TweenService:Create(blurEffect, TweenInfo.new(0.85), { Size = 0 }):Play()
                  TweenService:Create(frame7, tweenInfo2, { BackgroundTransparency = 1 })
                    :Play()
                  task.wait(0.9)

                  if v87 then
                    v87:Disconnect()
                  end

                  fn89()

                  if screenGui2 then
                    screenGui2:Destroy()
                  end

                  if blurEffect then
                    blurEffect:Destroy()
                  end

                  task.delay(0.5, function()
                    fn92()
                  end)

                  return
                end

                return
              end

              task.defer(function()
                task.wait()
                fn102()
              end)
            end

            _G.greenduelsPlayIntro = greenduelsPlayIntro
            local flag21
            flag21 = false

            if tbl18.introEnabled then
              flag21 = true
              _G.greenduelsFastIntro = false

              task.defer(function()
                pcall(greenduelsPlayIntro)
              end)
            end

            local uiScale3
            uiScale3 = Instance.new("UIScale", screenGui)
            uiScale3.Scale = 1
            local fn88

            fn88 = function(arg, arg2)
              local v87 = arg2 or arg
              local flag22 = false
              local v88 = nil
              local position = nil
              local position2 = nil

              v87.InputBegan:Connect(function(input)
                if tbl18.uiLocked then
                  return
                end

                if
                  input.UserInputType == Enum.UserInputType.MouseButton1
                  or input.UserInputType == Enum.UserInputType.Touch
                then
                  flag22 = true
                  position = input.Position
                  position2 = arg.Position

                  input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                      flag22 = false
                    end
                  end)
                end
              end)

              v87.InputChanged:Connect(function(input)
                if
                  input.UserInputType == Enum.UserInputType.MouseMovement
                  or input.UserInputType == Enum.UserInputType.Touch
                then
                  v88 = input
                end
              end)

              greenduelsPerfRun.track(service2.InputChanged:Connect(function(input)
                if input == v88 and flag22 and not tbl18.uiLocked then
                  arg.Position = UDim2.new(
                    position2.X.Scale,
                    position2.X.Offset + input.Position.X - position.X,
                    position2.Y.Scale,
                    position2.Y.Offset + input.Position.Y - position.Y
                  )
                end
              end))
            end

            local fn89

            fn89 = function(arg, arg2)
              local position = nil
              local position2 = nil
              local flag22 = false
              local flag23 = false
              local flag24 = false
              local n34 = 0
              local thread = nil

              arg.InputBegan:Connect(function(input)
                if
                  input.UserInputType ~= Enum.UserInputType.MouseButton1
                  and input.UserInputType ~= Enum.UserInputType.Touch
                then
                  return
                end
                flag24 = true
                n34 = tick()
                position = input.Position
                position2 = arg.Position
                flag22 = true
                flag23 = false
              end)

              arg.InputChanged:Connect(function(input)
                if not flag22 or tbl18.stackButtonsLocked then
                  return
                end

                if
                  input.UserInputType == Enum.UserInputType.MouseMovement
                  or input.UserInputType == Enum.UserInputType.Touch
                then
                  local n35 = input.Position - position

                  if n35.Magnitude > 40 then
                    flag23 = true
                  end

                  if flag23 then
                    arg.Position = UDim2.new(
                      position2.X.Scale,
                      position2.X.Offset + n35.X,
                      position2.Y.Scale,
                      position2.Y.Offset + n35.Y
                    )
                  end
                end
              end)

              arg.InputEnded:Connect(function()
                local v87 = flag24
                flag24 = false
                if not flag22 then
                  return
                end
                flag22 = false

                if flag23 then
                  if thread then
                    task.cancel(thread)
                  end

                  thread = task.delay(0.2, function()
                    pcall(requestSave)
                    thread = nil
                  end)
                end

                if v87 and not flag23 and tick() - n34 < 0.3 then
                  if arg2 then
                    arg2()
                  end

                  pcall(requestSave)
                end
              end)

              arg.AncestryChanged:Connect(function()
                if not arg.Parent then
                  flag22 = false
                end
              end)
            end

            local frame, fn90

            do
              local n34 = math.min(
                410,
                math.max(
                  260,
                  (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 442) - 32
                )
              )
              local n35 = math.min(
                520,
                math.max(
                  36,
                  (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 560) - 40
                )
              )
              frame = Instance.new("Frame", screenGui)
              frame.Name = "MainOuter"
              frame.Size = UDim2.new(0, n34, 0, n35)
              frame.Position = UDim2.new(0.5, -n34 / 2, 0.5, -n35 / 2)
              frame.BackgroundTransparency = 0
              frame.BackgroundColor3 = Color3.fromRGB(8, 23, 17)
              frame.BorderSizePixel = 0
              frame.ClipsDescendants = true
              fn71(frame, 12)
              fn88(frame)
              local n36 = 0

              greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                if frame and frame.Parent and frame.Visible and not menuAnimating then
                  if tick() - n36 > 0.1 then
                    n36 = tick()
                    _G.greenduelsLastMainPos = frame.Position
                  end
                end
              end))

              local flag22 = false
              local tween = nil
              local uiScale4 = Instance.new("UIScale", frame)
              uiScale4.Scale = 1

              fn90 = function(visible, arg)
                if tween then
                  pcall(function()
                    tween:Cancel()
                  end)

                  tween = nil
                end

                flag22 = true
                frame.Size = UDim2.new(0, n34, 0, n35)
                frame.Position = _G.greenduelsLastMainPos
                  or frame.Position
                  or UDim2.new(0.5, -n34 / 2, 0.5, -n35 / 2)

                if arg then
                  frame.Visible = visible
                  uiScale4.Scale = 1
                  flag22 = false
                  return
                end

                if visible then
                  frame.Visible = true
                  pcall(revealMainScrollNoJump)
                  uiScale4.Scale = 0.88
                  local tbl30 = { Scale = 1 }
                  tween = TweenService:Create(
                    uiScale4,
                    TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    tbl30
                  )
                  tween:Play()

                  tween.Completed:Connect(function()
                    flag22 = false
                    _G.greenduelsLastMainPos = frame.Position
                    tween = nil
                  end)
                else
                  uiScale4.Scale = 1
                  tween = TweenService:Create(
                    uiScale4,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    { Scale = 0.86 }
                  )
                  tween:Play()

                  tween.Completed:Connect(function()
                    frame.Visible = false
                    uiScale4.Scale = 1
                    flag22 = false
                    tween = nil
                  end)
                end
              end
            end

            do
              local instance2 = Instance.new("Frame", frame)
              instance2.Name = "BgFill"
              instance2.Size = UDim2.new(1, 0, 1, 0)
              instance2.BackgroundColor3 = Color3.fromRGB(15, 44, 31)
              instance2.BackgroundTransparency = 0.5
              instance2.BorderSizePixel = 0
              instance2.ZIndex = 0

              fn71(instance2, 12)
              local uiGradient = Instance.new("UIGradient", instance2)
              local colorSequence = ColorSequence.new
              local tbl30 = {}
              local v87 = ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 45, 33))
              local v88 = ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 17, 14))
              local new = ColorSequenceKeypoint.new
              local color = Color3.fromRGB
              local v89 = 20
              tbl30[1] = v87
              tbl30[2] = v88

              do
                local values = table.pack(new(1, color(v89, 16, 10)))
                table.move(values, 1, values.n, 3, tbl30)
              end

              uiGradient.Color = colorSequence(tbl30)
              uiGradient.Rotation = 90
            end

            local frame2 = Instance.new("Frame", frame)
            frame2.Name = "WindowOutline"
            frame2.Position = UDim2.new(0, 1, 0, 1)
            frame2.Size = UDim2.new(1, -2, 1, -2)
            frame2.BackgroundTransparency = 1
            frame2.BorderSizePixel = 0
            frame2.Active = false
            frame2.ZIndex = 40

            fn71(frame2, 11)
            createUIStroke(frame2, Color3.fromRGB(51, 119, 78), 2).Transparency = 0

            do
              local instance2 = Instance.new("Frame", frame)
              instance2.Size = UDim2.new(1, -2, 0, 55)
              instance2.Position = UDim2.new(0, 1, 0, 1)

              fn71(instance2, 11)
              instance2.BackgroundColor3 = tbl27.topBg
              instance2.BackgroundTransparency = 0.12
              instance2.BorderSizePixel = 0
              instance2.ZIndex = 5

              local frame3 = Instance.new("Frame", instance2)
              frame3.Size = UDim2.new(0, 34, 0, 34)
              frame3.Position = UDim2.new(0, 18, 0.5, -17)
              frame3.BackgroundColor3 = Color3.fromRGB(9, 17, 14)
              frame3.BorderSizePixel = 0
              frame3.ZIndex = 6

              fn71(frame3, 16)
              createUIStroke(frame3, Color3.fromRGB(22, 76, 43), 1.5).Transparency = 0.25

              local imageLabel = Instance.new("ImageLabel", frame3)
              imageLabel.Size = UDim2.new(1, -4, 1, -4)
              imageLabel.Position = UDim2.new(0, 2, 0, 2)
              imageLabel.BackgroundTransparency = 1
              imageLabel.Image = ""
              imageLabel.ScaleType = Enum.ScaleType.Crop
              imageLabel.ZIndex = 7

              fn71(imageLabel, 14)
              imageLabel.Visible = true

              task.delay(0.3, function()
                local ok, image = pcall(function()
                  return Players:GetUserThumbnailAsync(
                    localPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size150x150
                  )
                end)

                if ok and image then
                  imageLabel.Image = image
                end
              end)

              greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function()
                task.delay(0.5, function()
                  local ok, image = pcall(function()
                    return Players:GetUserThumbnailAsync(
                      localPlayer.UserId,
                      Enum.ThumbnailType.HeadShot,
                      Enum.ThumbnailSize.Size150x150
                    )
                  end)

                  if ok and image then
                    imageLabel.Image = image
                  end
                end)
              end))

              local textLabel2 = Instance.new("TextLabel", instance2)
              textLabel2.Size = UDim2.new(1, -116, 0, 24)
              textLabel2.Position = UDim2.new(0, 58, 0, 8)
              textLabel2.BackgroundTransparency = 1
              textLabel2.Text = "greenduels"
              textLabel2.TextColor3 = tbl27.topTitle
              textLabel2.Font = Enum.Font.GothamBlack
              textLabel2.TextSize = 18
              textLabel2.TextXAlignment = Enum.TextXAlignment.Left
              textLabel2.ZIndex = 6

              local textLabel3 = Instance.new("TextLabel", instance2)
              textLabel3.Size = UDim2.new(0, 160, 0, 11)
              textLabel3.Position = UDim2.new(0, 59, 0, 33)
              textLabel3.BackgroundTransparency = 1
              textLabel3.Text = "powered by luck"
              textLabel3.TextColor3 = tbl27.topSub
              textLabel3.Font = Enum.Font.GothamMedium
              textLabel3.TextSize = 10
              textLabel3.TextXAlignment = Enum.TextXAlignment.Left
              textLabel3.ZIndex = 6

              local textButton3 = Instance.new("TextButton", instance2)
              textButton3.Size = UDim2.new(0, 40, 0, 30)
              textButton3.Position = UDim2.new(1, -46, 0.5, -15)
              textButton3.BackgroundColor3 = Color3.fromRGB(42, 27, 29)
              textButton3.BorderSizePixel = 0
              textButton3.Text = "X"
              textButton3.TextColor3 = Color3.fromRGB(244, 172, 172)
              textButton3.Font = Enum.Font.GothamBlack
              textButton3.TextSize = 13
              textButton3.ZIndex = 7

              fn71(textButton3, 10)
              local v87 = createUIStroke(textButton3, Color3.fromRGB(84, 48, 53), 1)

              textButton3.MouseEnter:Connect(function()
                TweenService:Create(
                  textButton3,
                  TweenInfo.new(0.5),
                  { BackgroundColor3 = Color3.fromRGB(109, 40, 49) }
                ):Play()
                TweenService
                  :Create(v87, TweenInfo.new(0.1), { Color = Color3.fromRGB(190, 79, 91) })
                  :Play()
              end)

              textButton3.MouseLeave:Connect(function()
                TweenService:Create(
                  textButton3,
                  TweenInfo.new(0.1),
                  { BackgroundColor3 = Color3.fromRGB(42, 27, 29) }
                ):Play()
                TweenService:Create(v87, TweenInfo.new(0.1), { Color = Color3.fromRGB(84, 48, 53) })
                  :Play()
              end)

              textButton3.MouseButton1Click:Connect(function()
                tbl18.guiVisible = false
                fn90(false, false)

                if _G.greenduelsQAHide then
                  pcall(_G.greenduelsQAHide, true)
                end

                requestSave()
              end)
            end

            local frame3 = Instance.new("Frame", frame)
            frame3.Size = UDim2.new(1, -2, 0, 1)
            frame3.Position = UDim2.new(0, 1, 0, 56)
            frame3.BackgroundColor3 = tbl27.topDivider
            frame3.BorderSizePixel = 0
            frame3.ZIndex = 5

            local fn91, fn92, fn93, fn94, fn95, fn96, fn97, fn98, fn99, fn100
            local fn101, fn102, hideButtons, lockButtons

            do
              local instance2 = Instance.new("Frame", frame)
              instance2.Size = UDim2.new(1, -20, 1, -121)
              instance2.Position = UDim2.new(0, 12, 0, 63)
              instance2.BackgroundColor3 = tbl27.winBg2
              instance2.BackgroundTransparency = 0.76
              instance2.BorderSizePixel = 0
              instance2.ClipsDescendants = true

              fn71(instance2, 10)
              instance2.ZIndex = 2

              local scrollingFrame = Instance.new("ScrollingFrame", instance2)
              scrollingFrame.Name = "MainScroll"
              scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
              scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.None
              scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
              scrollingFrame.BackgroundTransparency = 1
              scrollingFrame.BorderSizePixel = 0
              scrollingFrame.ScrollBarThickness = 2
              scrollingFrame.ScrollBarImageColor3 = tbl27.accent
              scrollingFrame.ScrollBarImageTransparency = 0.65
              scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
              scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
              scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
              scrollingFrame.CanvasPosition = Vector2.new(0, 0)
              scrollingFrame.Visible = false
              scrollingFrame.ZIndex = 3

              local uiListLayout = Instance.new("UIListLayout", scrollingFrame)
              uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
              uiListLayout.Padding = UDim.new(0, 6)
              uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

              local uiPadding = Instance.new("UIPadding", scrollingFrame)
              uiPadding.PaddingLeft = UDim.new(0, 6)
              uiPadding.PaddingRight = UDim.new(0, 6)
              uiPadding.PaddingTop = UDim.new(0, 10)
              uiPadding.PaddingBottom = UDim.new(0, 18)

              local function fn103()
                if scrollingFrame then
                  scrollingFrame.Visible = false
                  scrollingFrame.CanvasPosition = Vector2.new(0, 0)

                  task.defer(function()
                    if scrollingFrame then
                      scrollingFrame.CanvasPosition = Vector2.new(0, 0)
                      scrollingFrame.Visible = true
                    end
                  end)
                end
              end

              _G.greenduelsIntroFinished = function()
                if _G.greenduelsLoadTiming and not _G.greenduelsLoadTiming.menuReadySeconds then
                  local startedAt = _G.greenduelsLoadTiming.startedAt
                  _G.greenduelsLoadTiming.menuReadySeconds = os.clock() - startedAt
                end

                if screenGui then
                  screenGui.Enabled = true
                end

                tbl18.guiVisible = true

                if frame then
                  frame.Visible = true
                  pcall(fn103)
                end
              end

              task.delay(2, function()
                if screenGui and screenGui.Parent then
                  screenGui.Enabled = true
                end

                tbl18.guiVisible = true

                if frame and frame.Parent then
                  frame.Visible = true
                  pcall(fn103)
                end
              end)

              local tbl30 = {}
              local v87 = nil
              local n34 = 0

              local function fn104()
                n34 += 1

                if n34 % 24 == 0 then
                  task.wait()
                end

                return n34
              end

              local function fn105(arg)
                local instance3 = Instance.new("Frame", v87)
                instance3.Size = UDim2.new(1, 0, 0, arg or 8)
                instance3.BackgroundTransparency = 1
                instance3.BorderSizePixel = 0
                instance3.LayoutOrder = fn104()
              end

              local function fn106(arg)
                local frame4 = Instance.new("Frame", v87)
                frame4.Size = UDim2.new(1, -10, 0, 32)
                frame4.BackgroundColor3 = Color3.fromRGB(40, 92, 64)
                frame4.BackgroundTransparency = 0.25
                frame4.BorderSizePixel = 0
                frame4.LayoutOrder = fn104()

                fn71(frame4, 10)
                createUIStroke(frame4, Color3.fromRGB(56, 65, 38), 1).Transparency = 0.4

                local frame5 = Instance.new("Frame", frame4)
                frame5.Size = UDim2.new(0, 4, 1, -18)
                frame5.Position = UDim2.new(0, 10, 0, 9)
                frame5.BackgroundColor3 = tbl27.accent
                frame5.BorderSizePixel = 0

                fn71(frame5, 2)

                local textLabel2 = Instance.new("TextLabel", frame4)
                textLabel2.Size = UDim2.new(1, -40, 1, 0)
                textLabel2.Position = UDim2.new(0, 22, 0, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = arg and arg:upper() or ""
                textLabel2.TextColor3 = Color3.fromRGB(218, 255, 233)
                textLabel2.Font = Enum.Font.GothamBold
                textLabel2.TextSize = 14
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left
              end

              local function fn107(arg, arg2, arg3)
                local frame4 = Instance.new("Frame", v87)
                frame4.Size = UDim2.new(1, -16, 0, 42)
                frame4.BackgroundColor3 = tbl27.rowBg
                frame4.BackgroundTransparency = 0.12
                frame4.BorderSizePixel = 0
                frame4.LayoutOrder = fn104()

                fn71(frame4, 16)
                local v88 = createUIStroke(frame4, Color3.fromRGB(31, 54, 40), 1)
                v88.Transparency = 0.5

                frame4.MouseEnter:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
                end)

                frame4.MouseLeave:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.5), { Transparency = 0.5 }):Play()
                end)

                local textLabel2 = Instance.new("TextLabel", frame4)
                textLabel2.Size = UDim2.new(1, -100, 1, 0)
                textLabel2.Position = UDim2.new(0, 12, 0, 0)
                textLabel2.BackgroundTransparency = 1

                local text = arg == "Auto Swing"

                if text then
                  text = "Auto Swing: " .. (defaultOn and "ON" or "OFF")
                end

                textLabel2.Text = text or arg
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamMedium
                textLabel2.TextSize = 13
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local frame5 = Instance.new("Frame", frame4)
                frame5.Size = UDim2.new(0, 76, 0, 40)
                frame5.Position = UDim2.new(1, -16, 0.5, -15)
                frame5.BackgroundColor3 = Color3.fromRGB(9, 23, 15)
                frame5.BorderSizePixel = 0

                fn71(frame5, 13)
                local v89 = 1
                local v90 = createUIStroke(frame5, Color3.fromRGB(31, 54, 40), v89)
                v90.Transparency = 0.3

                local textBox = Instance.new("TextBox", frame5)
                textBox.Size = UDim2.new(1, -40, 1, 0)
                textBox.Position = UDim2.new(0, 4, 0, 0)
                textBox.BackgroundTransparency = 1
                textBox.Text = tostring(arg2)
                textBox.TextColor3 = Color3.fromRGB(154, 255, 191)
                textBox.Font = Enum.Font.GothamBold
                textBox.TextSize = 18
                textBox.ClearTextOnFocus = false
                textBox.ZIndex = 40
                textBox.TextXAlignment = Enum.TextXAlignment.Center

                textBox.Focused:Connect(function()
                  TweenService
                    :Create(
                      v90,
                      TweenInfo.new(0.15),
                      { Color = Color3.fromRGB(22, 76, 43), Transparency = 0 }
                    )
                    :Play()
                end)

                textBox.FocusLost:Connect(function()
                  TweenService
                    :Create(
                      v90,
                      TweenInfo.new(0.15),
                      { Color = Color3.fromRGB(31, 54, 80), Transparency = 0.3 }
                    )
                    :Play()

                  if arg3 then
                    local num = tonumber(textBox.Text)

                    if num then
                      arg3(num)
                      requestSave()
                    else
                      textBox.Text = tostring(arg2)
                    end
                  end
                end)

                return textBox, frame4
              end

              local function fn108(arg, arg2)
                local thread = nil

                local function fn109()
                  if thread then
                    pcall(task.cancel, thread)
                  end

                  thread = task.delay(0.3, function()
                    requestSave()
                  end)
                end

                local n35 = math.clamp(math.floor(tonumber(arg) or 70), 70, 120)

                local frame4 = Instance.new("Frame", v87)
                frame4.Size = UDim2.new(1, -12, 0, 42)
                frame4.BackgroundColor3 = tbl27.rowBg
                frame4.BackgroundTransparency = 0.12
                frame4.BorderSizePixel = 0
                frame4.LayoutOrder = fn104()

                fn71(frame4, 16)
                local v88 = createUIStroke(frame4, Color3.fromRGB(31, 0, 80), 1)
                v88.Transparency = 0.5

                frame4.MouseEnter:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.5), { Transparency = 0.2 }):Play()
                end)

                frame4.MouseLeave:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(frame4, TweenInfo.new(0.5), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.1), { Transparency = 0.5 }):Play()
                end)

                local textLabel2 = Instance.new("TextLabel", frame4)
                textLabel2.Size = UDim2.new(0, 60, 0, 14)
                textLabel2.Position = UDim2.new(0, 16, 0.5, -7)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = "FOV:"
                textLabel2.TextColor3 = tbl27.rowSub
                textLabel2.Font = Enum.Font.GothamBlack
                textLabel2.TextSize = 11
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local textLabel3 = Instance.new("TextLabel", frame4)
                textLabel3.Size = UDim2.new(0, 30, 0, 14)
                textLabel3.Position = UDim2.new(1, -50, 0.5, -4)
                textLabel3.BackgroundTransparency = 1
                textLabel3.Text = tostring(n35)
                textLabel3.TextColor3 = tbl27.sectionTxt
                textLabel3.Font = Enum.Font.GothamBlack
                textLabel3.TextSize = 10
                textLabel3.TextXAlignment = Enum.TextXAlignment.Right

                local instance3 = Instance.new("Frame", frame4)
                instance3.Size = UDim2.new(1, -132, 0, 20)
                instance3.Position = UDim2.new(0, 66, 0.5, -3)
                instance3.BackgroundColor3 = Color3.fromRGB(14, 30, 65)
                instance3.BorderSizePixel = 0

                fn71(instance3, 3)

                local frame5 = Instance.new("Frame", instance3)
                frame5.BackgroundColor3 = tbl27.sectionTxt
                frame5.BorderSizePixel = 0

                fn71(frame5, 3)

                local instance4 = Instance.new("Frame", instance3)
                instance4.Size = UDim2.new(0, 12, 0, 12)
                instance4.BackgroundColor3 = Color3.fromRGB(42, 190, 123)
                instance4.BorderSizePixel = 0
                instance4.ZIndex = 3

                fn71(instance4, 6)
                local flag22 = false

                local textButton3 = Instance.new("TextButton", instance3)
                textButton3.Size = UDim2.new(1, 0, 1, 24)
                textButton3.Position = UDim2.new(0, 0, 0, -12)
                textButton3.BackgroundTransparency = 1
                textButton3.Text = ""
                textButton3.ZIndex = 4

                local function fn110(arg3)
                  local fovValue = math.clamp(math.floor(tonumber(arg3) or 70), 70, 120)
                  local n36 = (fovValue - 70) / 50
                  tbl18.fovValue = fovValue
                  _G._VezyFOV = fovValue
                  frame5.Size = UDim2.new(n36, 0, 1, 0)
                  instance4.Position = UDim2.new(n36, -6, 0.5, -20)
                  textLabel3.Text = tostring(fovValue)

                  if arg2 then
                    arg2(fovValue)
                  end
                end

                local function fn111(arg3)
                  fn110(
                    70
                      + math.clamp(
                          (arg3 - instance3.AbsolutePosition.X)
                            / math.max(instance3.AbsoluteSize.X, 1),
                          0,
                          1
                        )
                        * 50
                  )
                  fn109()
                end

                textButton3.InputBegan:Connect(function(input)
                  if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                  then
                    flag22 = true
                    fn111(input.Position.X)
                  end
                end)

                textButton3.InputEnded:Connect(function(input)
                  if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                  then
                    if flag22 then
                      requestSave()
                    end

                    flag22 = false
                  end
                end)

                greenduelsPerfRun.track(service2.InputChanged:Connect(function(input)
                  if not flag22 then
                    return
                  end

                  if
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                  then
                    fn111(input.Position.X)
                  end
                end))

                fn110(n35)
                return fn110
              end

              local function fn109(arg, arg2, arg3)
                local frame4 = Instance.new("Frame", v87)
                frame4.Size = UDim2.new(1, -12, 0, 42)
                frame4.BackgroundColor3 = tbl27.rowBg
                frame4.BackgroundTransparency = 0.12
                frame4.BorderSizePixel = 0
                frame4.LayoutOrder = fn104()

                fn71(frame4, 12)
                local v88 = createUIStroke(frame4, Color3.fromRGB(31, 54, 40), 1)
                v88.Transparency = 0.5

                frame4.MouseEnter:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
                end)

                frame4.MouseLeave:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  local tbl32 = { Transparency = 0.5 }
                  TweenService:Create(v88, TweenInfo.new(0.1), tbl32):Play()
                end)

                local textLabel2 = Instance.new("TextLabel", frame4)
                textLabel2.Size = UDim2.new(1, -90, 1, 0)
                textLabel2.Position = UDim2.new(0, 12, 0, 0)
                textLabel2.BackgroundTransparency = 1

                local text = arg == "Auto Swing"

                if text then
                  text = "Auto Swing: " .. (arg2 and "ON" or "OFF")
                end

                textLabel2.Text = text or arg
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamMedium
                textLabel2.TextSize = 13
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local instance3 = Instance.new("Frame", frame4)
                instance3.Size = UDim2.new(0, 48, 0, 24)
                instance3.Position = UDim2.new(1, -62, 0.5, -12)
                instance3.BackgroundColor3 = arg2 and Color3.fromRGB(56, 168, 84)
                  or Color3.fromRGB(35, 48, 41)
                instance3.BorderSizePixel = 0
                instance3.ZIndex = 7
                instance3.ClipsDescendants = true

                fn71(instance3, 12)

                local frame5 = Instance.new("Frame", instance3)
                frame5.Size = UDim2.new(0, 16, 0, 16)
                frame5.Position = arg2 and UDim2.new(1, -20, 0.5, -8)
                  or UDim2.new(0, 4, 0.5, -8)
                frame5.BackgroundColor3 = arg2 and Color3.fromRGB(219, 255, 232)
                  or Color3.fromRGB(119, 149, 130)
                frame5.BorderSizePixel = 0
                frame5.ZIndex = 40

                fn71(frame5, 8)
                local flag22 = arg2 or false

                local function fn110(arg4)
                  flag22 = arg4

                  if arg == "Auto Swing" then
                    textLabel2.Text = "Auto Swing: " .. (arg4 and "ON" or "OFF")
                  end

                  TweenService
                    :Create(instance3, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                      BackgroundColor3 = arg4 and Color3.fromRGB(56, 168, 84)
                        or Color3.fromRGB(35, 48, 41),
                    })
                    :Play()

                  TweenService
                    :Create(frame5, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                      Position = arg4 and UDim2.new(1, -20, 0.5, -8)
                        or UDim2.new(0, 4, 0.5, -8),
                      BackgroundColor3 = arg4 and Color3.fromRGB(219, 255, 232)
                        or Color3.fromRGB(119, 149, 130),
                    })
                    :Play()
                end

                local function fn111()
                  flag22 = not flag22
                  fn110(flag22)

                  if arg3 then
                    pcall(arg3, flag22)
                  end

                  requestSave()
                end

                local textButton3 = Instance.new("TextButton", frame4)
                textButton3.Size = UDim2.new(1, -56, 1, 0)
                textButton3.BackgroundTransparency = 1
                textButton3.Text = ""
                textButton3.ZIndex = 5
                textButton3.BorderSizePixel = 0
                textButton3.MouseButton1Click:Connect(fn111)

                local textButton4 = Instance.new("TextButton", instance3)
                textButton4.Size = UDim2.new(1, 0, 1, 0)
                textButton4.BackgroundTransparency = 1
                textButton4.Text = ""
                textButton4.ZIndex = 9
                textButton4.BorderSizePixel = 0
                textButton4.MouseButton1Click:Connect(fn111)

                return fn110, frame4
              end

              fn91 = function(arg, arg2, arg3)
                if not arg then
                  return
                end

                pcall(function()
                  arg:SetAttribute("SelectorActive", arg2 and true or false)
                end)

                local color = arg2 and Color3.fromRGB(14, 76, 38) or Color3.fromRGB(6, 14, 10)
                local color2 = arg2 and Color3.fromRGB(145, 200, 185)
                  or Color3.fromRGB(225, 240, 230)
                local color3 = arg2 and Color3.fromRGB(170, 200, 145)
                  or Color3.fromRGB(56, 54, 40)
                local tbl31 = { BackgroundColor3 = color, TextColor3 = color2 }

                if arg3 then
                  arg.BackgroundColor3 = color
                  arg.TextColor3 = color2
                else
                  TweenService:Create(arg, TweenInfo.new(0.16, Enum.EasingStyle.Quint), tbl31)
                    :Play()
                end

                local selectorStroke = arg:FindFirstChild("SelectorStroke")

                if selectorStroke then
                  selectorStroke.Color = color3
                  selectorStroke.Transparency = arg2 and 0.2 or 0.65
                  selectorStroke.Thickness = arg2 and 1.6 or 1
                end

                local selectorShine = arg:FindFirstChild("SelectorShine")

                if selectorShine then
                  selectorShine.BackgroundTransparency = 1
                end
              end

              local function fn110(text, arg, arg2, arg3)
                local frame4 = Instance.new("Frame", v87)
                frame4.Size = UDim2.new(1, -16, 0, 42)
                frame4.BackgroundColor3 = tbl27.rowBg
                frame4.BackgroundTransparency = 0.12
                frame4.BorderSizePixel = 0
                frame4.LayoutOrder = fn104()

                fn71(frame4, 16)
                local v88 = 1
                local v89 = createUIStroke(frame4, Color3.fromRGB(31, 54, 80), v88)
                v89.Transparency = 0.5

                local textLabel2 = Instance.new("TextLabel", frame4)
                textLabel2.Size = UDim2.new(1, -155, 1, 0)
                textLabel2.Position = UDim2.new(0, 12, 0, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = text
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamMedium
                textLabel2.TextSize = 13
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local instance3 = Instance.new("TextButton", frame4)
                instance3.Size = UDim2.new(0, 132, 0, 28)
                instance3.Position = UDim2.new(1, -142, 0.5, -18)
                instance3.BackgroundColor3 = tbl27.inputBg
                instance3.BorderSizePixel = 0
                instance3.TextColor3 = tbl27.inputTxt
                instance3.Font = Enum.Font.GothamBlack
                instance3.TextSize = 10
                instance3.TextWrapped = true
                instance3.AutoButtonColor = false
                instance3.ZIndex = 8

                fn71(instance3, 9)
                createUIStroke(instance3, tbl27.accent, 1).Transparency = 0.22
                local n35 = 1

                for i, v90 in ipairs(arg) do
                  if v90 == arg2 then
                    n35 = i
                    break
                  end
                end

                local function fn111(arg4, arg5)
                  local n36 = 1

                  for i, v90 in ipairs(arg) do
                    if v90 == arg4 then
                      n36 = i
                      break
                    end
                  end

                  n35 = n36
                  instance3.Text = arg[n35]

                  if arg5 and arg3 then
                    pcall(arg3, arg[n35])
                  end

                  if arg5 then
                    requestSave()
                  end
                end

                instance3.MouseButton1Click:Connect(function()
                  n35 = n35 % #arg + 1
                  fn111(arg[n35], true)
                end)

                frame4.MouseEnter:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v89, TweenInfo.new(0.5), { Transparency = 0.2 }):Play()
                end)

                frame4.MouseLeave:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  local tbl32 = { Transparency = 0.5 }
                  TweenService:Create(v89, TweenInfo.new(0.1), tbl32):Play()
                end)

                fn111(arg2, false)
                return { set = fn111, button = instance3, row = frame4 }
              end

              _G.greenduelsMakePickerRow = function(text, arg, arg2, arg3, arg4, arg5)
                local frame4 = Instance.new("Frame", v87)
                frame4.Size = UDim2.new(1, -12, 0, 42)
                frame4.BackgroundColor3 = tbl27.rowBg
                frame4.BackgroundTransparency = 0.12
                frame4.BorderSizePixel = 0
                frame4.LayoutOrder = fn104()

                fn71(frame4, 16)
                local v88 = createUIStroke(frame4, Color3.fromRGB(31, 54, 80), 1)
                v88.Transparency = 0.5

                local textLabel2 = Instance.new("TextLabel", frame4)
                textLabel2.Size = UDim2.new(1, -90, 1, 0)
                textLabel2.Position = UDim2.new(0, 12, 0, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = text
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamMedium
                textLabel2.TextSize = 13
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local textButton3 = Instance.new("TextButton", frame4)
                textButton3.Size = UDim2.new(1, -155, 1, 0)
                textButton3.Position = UDim2.new(0, 0, 0, 0)
                textButton3.BackgroundTransparency = 1
                textButton3.BorderSizePixel = 0
                textButton3.Text = ""
                textButton3.AutoButtonColor = false
                textButton3.ZIndex = 4

                local frame5 = Instance.new("Frame", frame4)
                frame5.Size = UDim2.new(0, 132, 0, 28)
                frame5.Position = UDim2.new(1, -142, 0.5, -14)
                frame5.BackgroundColor3 = tbl27.inputBg
                frame5.BorderSizePixel = 0
                frame5.ClipsDescendants = true
                frame5.ZIndex = 8

                fn71(frame5, 9)
                createUIStroke(frame5, tbl27.accent, 1).Transparency = 0.18
                local uiGradient = Instance.new("UIGradient", frame5)
                uiGradient.Rotation = 18

                local textButton4 = Instance.new("TextButton", frame5)
                textButton4.Size = UDim2.new(1, -18, 1, 0)
                textButton4.BackgroundTransparency = 1
                textButton4.BorderSizePixel = 0
                textButton4.TextColor3 = Color3.fromRGB(200, 255, 255)
                textButton4.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                textButton4.TextStrokeTransparency = 0.35
                textButton4.Font = Enum.Font.GothamBlack
                textButton4.TextSize = 10
                textButton4.TextWrapped = true
                textButton4.AutoButtonColor = false
                textButton4.ZIndex = 9

                local instance3 = Instance.new("TextButton", frame5)
                instance3.Size = UDim2.new(0, 18, 1, 0)
                instance3.Position = UDim2.new(1, -20, 0, 0)
                instance3.BackgroundTransparency = 1
                instance3.BorderSizePixel = 0
                instance3.AutoButtonColor = false
                instance3.Text = ">"
                instance3.TextColor3 = tbl27.accent
                instance3.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                instance3.TextStrokeTransparency = 0.5
                instance3.Font = Enum.Font.GothamBlack
                instance3.TextSize = 14
                instance3.ZIndex = 10

                local function fn111(arg6)
                  local v89 = arg3 and arg3[arg6]
                  if v89 then
                    return v89
                  end
                  local n35 = 0

                  for i = 1, #tostring(arg6) do
                    n35 = (n35 + string.byte(tostring(arg6), i) * i) % 255
                  end

                  return Color3.fromHSV(n35 / 255, 0.72, 0.95)
                end

                local str6 = arg2 or arg[1] or "Off"

                local function fn112(arg6)
                  str6 = arg6 or str6
                  textButton4.Text = tostring(str6)
                  local v89 = fn111(str6)
                  frame5.BackgroundColor3 = v89
                  local v90 = uiGradient
                  local colorSequence = ColorSequence.new
                  local tbl31 = {}
                  local v91 =
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 200))
                  local v92 = ColorSequenceKeypoint.new(0.35, v89)
                  local new = ColorSequenceKeypoint.new
                  tbl31[1] = v91
                  tbl31[2] = v92

                  do
                    local values = table.pack(new(1, v89))
                    table.move(values, 1, values.n, 3, tbl31)
                  end

                  v90.Color = colorSequence(tbl31)
                  local v93 = uiGradient
                  local numberSequence = NumberSequence.new
                  local tbl32 = {}
                  local v94 = NumberSequenceKeypoint.new(0, 0.55)
                  local v95 = NumberSequenceKeypoint.new(0.35, 0)
                  local new2 = NumberSequenceKeypoint.new
                  tbl32[1] = v94
                  tbl32[2] = v95

                  do
                    local values = table.pack(new2(1, 0))
                    table.move(values, 1, values.n, 3, tbl32)
                  end

                  v93.Transparency = numberSequence(tbl32)
                end

                local screenGui2 = nil

                local function fn113()
                  if screenGui2 and screenGui2.Parent then
                    screenGui2:Destroy()
                  end

                  screenGui2 = nil
                end

                local function fn114()
                  if screenGui2 and screenGui2.Parent then
                    return
                  end
                  local hui = nil

                  pcall(function()
                    if type(gethui) == "function" then
                      hui = gethui()
                    end
                  end)

                  hui = hui
                    or screenGui and screenGui.Parent
                    or localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
                    or game:GetService("CoreGui")
                  screenGui2 = Instance.new("ScreenGui")
                  screenGui2.Name = "greenduels" .. text:gsub("%W", "") .. "Picker"
                  screenGui2.ResetOnSpawn = false
                  screenGui2.IgnoreGuiInset = true
                  screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                  screenGui2.DisplayOrder = 9999
                  screenGui2.Parent = hui

                  local frame6 = Instance.new("Frame", screenGui2)
                  frame6.Size = UDim2.new(1, 0, 1, 0)
                  frame6.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                  frame6.BackgroundTransparency = 0.48
                  frame6.BorderSizePixel = 0
                  frame6.ZIndex = 1

                  local frame7 = Instance.new("Frame", screenGui2)
                  frame7.Size = UDim2.new(0, 380, 0, 36)
                  frame7.Position = UDim2.new(0.5, -160, 0.5, -180)
                  frame7.BackgroundColor3 = Color3.fromRGB(8, 14, 11)
                  frame7.BorderSizePixel = 0
                  frame7.ZIndex = 2

                  fn71(frame7, 12)
                  createUIStroke(frame7, Color3.fromRGB(58, 143, 99), 1).Transparency = 0.25

                  local textLabel3 = Instance.new("TextLabel", frame7)
                  textLabel3.Size = UDim2.new(1, -58, 0, 46)
                  textLabel3.Position = UDim2.new(0, 16, 0, 0)
                  textLabel3.BackgroundTransparency = 1
                  textLabel3.Text = string.upper(arg5 or text)
                  textLabel3.TextColor3 = Color3.fromRGB(255, 255, 200)
                  textLabel3.Font = Enum.Font.GothamBlack
                  textLabel3.TextSize = 16
                  textLabel3.TextXAlignment = Enum.TextXAlignment.Left
                  textLabel3.ZIndex = 3

                  local textButton5 = Instance.new("TextButton", frame7)
                  textButton5.Size = UDim2.new(0, 34, 0, 34)
                  textButton5.Position = UDim2.new(1, -42, 0, 6)
                  textButton5.BackgroundColor3 = Color3.fromRGB(18, 32, 24)
                  textButton5.BorderSizePixel = 0
                  textButton5.Text = "X"
                  textButton5.TextColor3 = Color3.fromRGB(255, 200, 255)
                  textButton5.Font = Enum.Font.GothamBlack
                  textButton5.TextSize = 13
                  textButton5.AutoButtonColor = false
                  textButton5.ZIndex = 40

                  fn71(textButton5, 9)

                  local textButton6 = Instance.new("TextButton", frame7)
                  textButton6.Size = UDim2.new(1, -58, 0, 46)
                  textButton6.Position = UDim2.new(0, 0, 0, 0)
                  textButton6.BackgroundTransparency = 1
                  textButton6.BorderSizePixel = 0
                  textButton6.Text = ""
                  textButton6.AutoButtonColor = false
                  textButton6.ZIndex = 7

                  textButton5.MouseButton1Click:Connect(fn113)
                  textButton5.Activated:Connect(fn113)
                  local flag22 = false
                  local position = nil
                  local position2 = nil
                  local UserInputService = game:GetService("UserInputService")

                  local function fn115(arg6)
                    local n35 = arg6.Position - position
                    frame7.Position = UDim2.new(
                      position2.X.Scale,
                      position2.X.Offset + n35.X,
                      position2.Y.Scale,
                      position2.Y.Offset + n35.Y
                    )
                  end

                  local function fn116(input)
                    if
                      input.UserInputType == Enum.UserInputType.MouseButton1
                      or input.UserInputType == Enum.UserInputType.Touch
                    then
                      flag22 = true
                      position = input.Position
                      position2 = frame7.Position

                      input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                          flag22 = false
                        end
                      end)
                    end
                  end

                  textButton6.InputBegan:Connect(fn116)

                  textButton6.InputChanged:Connect(function(input)
                    if
                      flag22
                      and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                      )
                    then
                      fn115(input)
                    end
                  end)

                  textLabel3.InputBegan:Connect(fn116)

                  textLabel3.InputChanged:Connect(function(input)
                    if
                      flag22
                      and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                      )
                    then
                      fn115(input)
                    end
                  end)

                  UserInputService.InputChanged:Connect(function(input)
                    if
                      flag22
                      and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                      )
                    then
                      fn115(input)
                    end
                  end)

                  local scrollingFrame2 = Instance.new("ScrollingFrame", frame7)
                  scrollingFrame2.Size = UDim2.new(1, -12, 1, -36)
                  scrollingFrame2.Position = UDim2.new(0, 8, 0, 50)
                  scrollingFrame2.BackgroundTransparency = 1
                  scrollingFrame2.BorderSizePixel = 0
                  scrollingFrame2.ScrollBarThickness = 4
                  scrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
                  scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
                  scrollingFrame2.ZIndex = 10

                  local uiGridLayout = Instance.new("UIGridLayout", scrollingFrame2)
                  uiGridLayout.CellSize = UDim2.new(0, 108, 0, 92)
                  uiGridLayout.CellPadding = UDim2.new(0, 10, 0, 12)
                  uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                  uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

                  local uiPadding2 = Instance.new("UIPadding", scrollingFrame2)
                  uiPadding2.PaddingTop = UDim.new(0, 8)
                  uiPadding2.PaddingBottom = UDim.new(0, 8)

                  for i, v89 in ipairs(arg) do
                    local v90 = fn111(v89)

                    local textButton7 = Instance.new("TextButton", scrollingFrame2)
                    textButton7.Name = "Pick_" .. tostring(v89)
                    textButton7.BackgroundColor3 = v90
                    textButton7.BorderSizePixel = 0
                    textButton7.Text = ""
                    textButton7.AutoButtonColor = false
                    textButton7.LayoutOrder = i
                    textButton7.ZIndex = 4
                    textButton7.ClipsDescendants = true

                    fn71(textButton7, 14)
                    local uiGradient2 = Instance.new("UIGradient", textButton7)
                    uiGradient2.Rotation = 90
                    local colorSequence = ColorSequence.new
                    local tbl31 = {}
                    local v91 = ColorSequenceKeypoint.new(0, v90)
                    local floor2 = math.floor
                    local n35 = v90.B * 90
                    local v92 = ColorSequenceKeypoint.new(
                      0.65,
                      Color3.fromRGB(math.floor(v90.R * 90), math.floor(v90.G * 90), floor2(n35))
                    )
                    local new = ColorSequenceKeypoint.new
                    local color = Color3.fromRGB
                    tbl31[1] = v91
                    tbl31[2] = v92

                    do
                      local values = table.pack(new(1, color(10, 10, 14)))
                      table.move(values, 1, values.n, 3, tbl31)
                    end

                    uiGradient2.Color = colorSequence(tbl31)

                    local instance4 = Instance.new("UIStroke", textButton7)
                    instance4.Color = v89 == str6 and Color3.fromRGB(255, 255, 255) or v90
                    instance4.Thickness = v89 == str6 and 2.3 or 1.1
                    instance4.Transparency = v89 == str6 and 0 or 0.45

                    local frame8 = nil

                    if
                      text == "Tool Skin"
                      and _G.AmbitiousCustomToolAssets
                      and _G.AmbitiousCustomToolAssets[v89]
                    then
                      local v93 = _G.AmbitiousCustomToolAssets[v89]

                      local viewportFrame = Instance.new("ViewportFrame", textButton7)
                      viewportFrame.Size = UDim2.new(1, -12, 0, 58)
                      viewportFrame.Position = UDim2.new(0, 20, 0, 6)
                      viewportFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
                      viewportFrame.BackgroundTransparency = 0.18
                      viewportFrame.BorderSizePixel = 0
                      viewportFrame.ZIndex = 5
                      viewportFrame.Ambient = Color3.fromRGB(190, 200, 195)
                      viewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
                      viewportFrame.LightDirection = Vector3.new(-0.4, -1, -0.1)

                      fn71(viewportFrame, 10)

                      local part = Instance.new("Part", viewportFrame)
                      part.Anchored = true
                      part.CanCollide = false
                      part.Size = Vector3.new(1, 1, 1)
                      part.CFrame = CFrame.new()

                      local specialMesh = Instance.new("SpecialMesh", part)
                      specialMesh.MeshType = Enum.MeshType.FileMesh
                      specialMesh.MeshId = v93.mesh or ""
                      specialMesh.TextureId = v93.tex or ""
                      specialMesh.Scale = (v93.scale or Vector3.new(1, 1, 1)) * 1.25

                      local camera = Instance.new("Camera", viewportFrame)
                      camera.FieldOfView = 42
                      viewportFrame.CurrentCamera = camera
                      local n36 = (v93.view or 5) * 0.72
                      local vector = Vector3.new
                      local v94 = 0
                      camera.CFrame = CFrame.new(Vector3.new(0, n36 * 0.35, n36), vector(v94, 0, 0))
                      local connection = nil

                      connection = game
                        :GetService("RunService").RenderStepped
                        :Connect(function(deltaTime)
                          if
                            not (part and part.Parent and viewportFrame and viewportFrame.Parent)
                          then
                            if connection then
                              connection:Disconnect()
                              connection = nil
                            end

                            return
                          end

                          part.CFrame = part.CFrame
                            * CFrame.Angles(0, 1.5707963267948966 * (deltaTime or 0.016), 0)
                        end)
                    else
                      frame8 = Instance.new("Frame", textButton7)
                      frame8.Size = UDim2.new(0, 34, 0, 40)
                      frame8.Position = UDim2.new(0.5, -17, 0, 14)
                      frame8.BackgroundColor3 = v90
                      frame8.BorderSizePixel = 0
                      frame8.ZIndex = 5
                      fn71(frame8, 10)

                      local uiStroke = Instance.new("UIStroke", frame8)
                      uiStroke.Color = Color3.fromRGB(200, 255, 200)
                      uiStroke.Thickness = 1.2
                      uiStroke.Transparency = 0.5
                    end

                    local textLabel4 = Instance.new("TextLabel", textButton7)
                    textLabel4.Size = UDim2.new(1, -40, 0, 24)
                    textLabel4.Position = UDim2.new(0, 4, 1, -30)
                    textLabel4.BackgroundTransparency = 1
                    textLabel4.Text = string.upper(tostring(v89))
                    textLabel4.TextColor3 = Color3.fromRGB(200, 200, 255)
                    textLabel4.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel4.TextStrokeTransparency = 0.38
                    textLabel4.Font = Enum.Font.GothamBlack
                    textLabel4.TextSize = 12
                    textLabel4.TextWrapped = true
                    textLabel4.ZIndex = 6

                    textButton7.MouseEnter:Connect(function()
                      if frame8 then
                        TweenService
                          :Create(frame8, TweenInfo.new(0.12), {
                            Size = UDim2.new(0, 40, 0, 80),
                            Position = UDim2.new(0.5, -170, 0, 11),
                          })
                          :Play()
                      end

                      TweenService
                        :Create(
                          instance4,
                          TweenInfo.new(0.12),
                          { Transparency = 0, Thickness = 2.3 }
                        )
                        :Play()
                    end)

                    textButton7.MouseLeave:Connect(function()
                      if frame8 then
                        TweenService
                          :Create(frame8, TweenInfo.new(0.12), {
                            Size = UDim2.new(0, 40, 0, 34),
                            Position = UDim2.new(0.5, -17, 0, 14),
                          })
                          :Play()
                      end

                      TweenService
                        :Create(instance4, TweenInfo.new(0.12), {
                          Transparency = v89 == str6 and 0 or 0.45,
                          Thickness = v89 == str6 and 2.3 or 1.1,
                        })
                        :Play()
                    end)

                    textButton7.MouseButton1Click:Connect(function()
                      fn112(v89)

                      if arg4 then
                        arg4(v89)
                      end

                      requestSave()
                      fn113()
                    end)
                  end

                  frame6.InputBegan:Connect(function(input)
                    if
                      input.UserInputType == Enum.UserInputType.MouseButton1
                      or input.UserInputType == Enum.UserInputType.Touch
                    then
                      fn113()
                    end
                  end)
                end

                textButton4.MouseButton1Click:Connect(fn114)
                instance3.MouseButton1Click:Connect(fn114)
                textButton3.MouseButton1Click:Connect(fn114)

                frame4.MouseEnter:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
                end)

                frame4.MouseLeave:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(frame4, TweenInfo.new(0.1), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.1), { Transparency = 0.5 }):Play()
                end)

                fn112(str6)

                return {
                  set = function(arg6, arg7)
                    fn112(arg6)

                    if arg7 and arg4 then
                      arg4(arg6)
                    end

                    if arg7 then
                      requestSave()
                    end
                  end,
                  row = frame4,
                  button = textButton4,
                }
              end

              _G.greenduelsSkyThemes = {
                "Reset",
                "Off",
                "Night",
                "Aurora",
                "Sunset",
                "Galaxy",
                "Cyber",
                "Sakura",
                "Blood Moon",
                "Emerald Dawn",
                "Volcanic",
                "Arctic",
                "Midnight Ocean",
                "Toxic",
                "Storm",
                "Heaven",
              }

              _G.greenduelsApplySkyTheme = function(arg)
                local skyTheme = tostring(arg or "Default")
                tbl18.skyTheme = skyTheme

                if skyTheme == "Reset" then
                  tbl18.skyTheme = "Default"
                  skyTheme = "Off"
                end

                local Lighting2 = game:GetService("Lighting")

                local terrain = workspace:FindFirstChildOfClass("Terrain")

                pcall(function()
                  _G.greenduelsSkyBackup = _G.greenduelsSkyBackup
                    or {
                      ClockTime = Lighting2.ClockTime,
                      Brightness = Lighting2.Brightness,
                      Ambient = Lighting2.Ambient,
                      OutdoorAmbient = Lighting2.OutdoorAmbient,
                      FogColor = Lighting2.FogColor,
                      FogEnd = Lighting2.FogEnd,
                    }
                end)

                for _, child in ipairs(Lighting2:GetChildren()) do
                  if child:GetAttribute("greenduelsSkyTheme") then
                    pcall(function()
                      child:Destroy()
                    end)
                  end
                end

                if terrain then
                  for _, child in ipairs(terrain:GetChildren()) do
                    if child:GetAttribute("greenduelsSkyTheme") then
                      pcall(function()
                        child:Destroy()
                      end)
                    end
                  end
                end

                if skyTheme == "Off" then
                  local greenduelsSkyBackup = _G.greenduelsSkyBackup

                  if greenduelsSkyBackup then
                    pcall(function()
                      Lighting2.ClockTime = greenduelsSkyBackup.ClockTime
                      Lighting2.Brightness = greenduelsSkyBackup.Brightness
                      Lighting2.Ambient = greenduelsSkyBackup.Ambient
                      Lighting2.OutdoorAmbient = greenduelsSkyBackup.OutdoorAmbient
                      Lighting2.FogColor = greenduelsSkyBackup.FogColor
                      Lighting2.FogEnd = greenduelsSkyBackup.FogEnd
                    end)
                  end

                  return
                end

                local tbl31 = {
                  ClockTime = 14,
                  Brightness = 2,
                  Ambient = Color3.fromRGB(80, 90, 100),
                  Outdoor = Color3.fromRGB(120, 130, 145),
                  Fog = Color3.fromRGB(190, 210, 255),
                  FogEnd = 900,
                }

                if skyTheme == "Night" then
                  tbl31 = {
                    ClockTime = 0,
                    Brightness = 1.2,
                    Ambient = Color3.fromRGB(18, 22, 45),
                    Outdoor = Color3.fromRGB(40, 40, 80),
                    Fog = Color3.fromRGB(20, 26, 54),
                    FogEnd = 650,
                  }
                elseif skyTheme == "Aurora" then
                  tbl31 = {
                    ClockTime = 1.5,
                    Brightness = 1.6,
                    Ambient = Color3.fromRGB(25, 32, 65),
                    Outdoor = Color3.fromRGB(65, 160, 130),
                    Fog = Color3.fromRGB(40, 95, 90),
                    FogEnd = 750,
                  }
                elseif skyTheme == "Sunset" then
                  tbl31 = {
                    ClockTime = 17.8,
                    Brightness = 2.2,
                    Ambient = Color3.fromRGB(120, 72, 65),
                    Outdoor = Color3.fromRGB(255, 145, 92),
                    Fog = Color3.fromRGB(200, 135, 90),
                    FogEnd = 800,
                  }
                elseif skyTheme == "Galaxy" then
                  tbl31 = {
                    ClockTime = 23.4,
                    Brightness = 1.4,
                    Ambient = Color3.fromRGB(45, 24, 82),
                    Outdoor = Color3.fromRGB(80, 42, 145),
                    Fog = Color3.fromRGB(42, 0, 84),
                    FogEnd = 700,
                  }
                elseif skyTheme == "Cyber" then
                  tbl31 = {
                    ClockTime = 21.5,
                    Brightness = 1.7,
                    Ambient = Color3.fromRGB(20, 85, 95),
                    Outdoor = Color3.fromRGB(60, 255, 210),
                    Fog = Color3.fromRGB(20, 105, 115),
                    FogEnd = 780,
                  }
                elseif skyTheme == "Sakura" then
                  tbl31 = {
                    ClockTime = 15.2,
                    Brightness = 2.2,
                    Ambient = Color3.fromRGB(125, 88, 112),
                    Outdoor = Color3.fromRGB(255, 170, 210),
                    Fog = Color3.fromRGB(255, 190, 220),
                    FogEnd = 850,
                  }
                elseif skyTheme == "Blood Moon" then
                  tbl31 = {
                    ClockTime = 22.5,
                    Brightness = 1.4,
                    Ambient = Color3.fromRGB(120, 50, 45),
                    Outdoor = Color3.fromRGB(130, 60, 60),
                    Fog = Color3.fromRGB(180, 50, 45),
                    FogEnd = 620,
                  }
                elseif skyTheme == "Emerald Dawn" then
                  tbl31 = {
                    ClockTime = 6.5,
                    Brightness = 2.8,
                    Ambient = Color3.fromRGB(130, 170, 140),
                    Outdoor = Color3.fromRGB(140, 180, 24),
                    Fog = Color3.fromRGB(80, 200, 140),
                    FogEnd = 900,
                  }
                elseif skyTheme == "Volcanic" then
                  tbl31 = {
                    ClockTime = 19,
                    Brightness = 1.6,
                    Ambient = Color3.fromRGB(170, 90, 50),
                    Outdoor = Color3.fromRGB(180, 100, 60),
                    Fog = Color3.fromRGB(200, 80, 30),
                    FogEnd = 560,
                  }
                elseif skyTheme == "Arctic" then
                  tbl31 = {
                    ClockTime = 9,
                    Brightness = 3.2,
                    Ambient = Color3.fromRGB(200, 210, 235),
                    Outdoor = Color3.fromRGB(210, 230, 245),
                    Fog = Color3.fromRGB(180, 220, 200),
                    FogEnd = 920,
                  }
                elseif skyTheme == "Midnight Ocean" then
                  tbl31 = {
                    ClockTime = 1.5,
                    Brightness = 1.7,
                    Ambient = Color3.fromRGB(60, 90, 130),
                    Outdoor = Color3.fromRGB(32, 100, 140),
                    Fog = Color3.fromRGB(20, 60, 140),
                    FogEnd = 650,
                  }
                elseif skyTheme == "Toxic" then
                  tbl31 = {
                    ClockTime = 14,
                    Brightness = 2.2,
                    Ambient = Color3.fromRGB(145, 170, 110),
                    Outdoor = Color3.fromRGB(155, 180, 120),
                    Fog = Color3.fromRGB(130, 200, 90),
                    FogEnd = 760,
                  }
                elseif skyTheme == "Storm" then
                  tbl31 = {
                    ClockTime = 15,
                    Brightness = 1.4,
                    Ambient = Color3.fromRGB(90, 90, 110),
                    Outdoor = Color3.fromRGB(100, 100, 85),
                    Fog = Color3.fromRGB(80, 90, 120),
                    FogEnd = 460,
                  }
                elseif skyTheme == "Heaven" then
                  tbl31 = {
                    ClockTime = 12,
                    Brightness = 4,
                    Ambient = Color3.fromRGB(240, 235, 210),
                    Outdoor = Color3.fromRGB(250, 245, 220),
                    Fog = Color3.fromRGB(200, 250, 220),
                    FogEnd = 950,
                  }
                end

                pcall(function()
                  Lighting2.ClockTime = tbl31.ClockTime
                  Lighting2.Brightness = tbl31.Brightness
                  Lighting2.Ambient = tbl31.Ambient
                  Lighting2.OutdoorAmbient = tbl31.Outdoor
                  Lighting2.FogColor = tbl31.Fog
                  Lighting2.FogEnd = tbl31.FogEnd
                end)

                local atmosphere = Instance.new("Atmosphere")
                atmosphere.Name = "greenduelsSkyAtmosphere"
                atmosphere:SetAttribute("greenduelsSkyTheme", true)
                atmosphere.Density = 0.28
                atmosphere.Offset = 0.5
                atmosphere.Color = tbl31.Fog
                atmosphere.Decay = tbl31.Ambient
                atmosphere.Glare = 0.15
                atmosphere.Haze = 1.4
                atmosphere.Parent = Lighting2

                if terrain then
                  local clouds = Instance.new("Clouds")
                  clouds.Name = "greenduelsSkyClouds"
                  clouds:SetAttribute("greenduelsSkyTheme", true)
                  clouds.Cover = 0.2
                  clouds.Density = 0.35
                  clouds.Color = tbl31.Fog
                  clouds.Parent = terrain
                end
              end

              _G.greenduelsVividGraphics = { "Off", "Game Color", "Custom" }
              _G.greenduelsVividSettings = _G.greenduelsVividSettings
                or {
                  saturation = 0.6,
                  bloomIntensity = 0.8,
                  bloomSize = 24,
                  dofFocus = 25,
                  sunIntensity = 0.2,
                }

              _G.greenduelsApplyVividGraphics = function(arg)
                local vividGraphics = tostring(arg or "Default")
                tbl18.vividGraphics = vividGraphics
                local Lighting2 = game:GetService("Lighting")

                for _, child in ipairs(Lighting2:GetChildren()) do
                  if child:GetAttribute("greenduelsVividGraphics") then
                    pcall(function()
                      child:Destroy()
                    end)
                  end
                end

                if _G.greenduelsVividContrastConn then
                  pcall(function()
                    task.cancel(_G.greenduelsVividContrastConn)
                  end)

                  _G.greenduelsVividContrastConn = nil
                end

                if vividGraphics == "Default" then
                  return
                end
                local greenduelsVividSettings = vividGraphics == "Custom"
                    and _G.greenduelsVividSettings
                  or {
                    saturation = 0.6,
                    bloomIntensity = 0.8,
                    bloomSize = 24,
                    dofFocus = 0,
                    sunIntensity = 0.2,
                  }

                local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
                colorCorrectionEffect.Name = "greenduelsVividColor"
                colorCorrectionEffect:SetAttribute("greenduelsVividGraphics", true)
                colorCorrectionEffect.Saturation = greenduelsVividSettings.saturation
                colorCorrectionEffect.Contrast = 0.4
                colorCorrectionEffect.Brightness = 0.05
                colorCorrectionEffect.TintColor = Color3.fromRGB(200, 240, 220)
                colorCorrectionEffect.Parent = Lighting2

                local bloomEffect = Instance.new("BloomEffect")
                bloomEffect.Name = "greenduelsVividBloom"
                bloomEffect:SetAttribute("greenduelsVividGraphics", true)
                bloomEffect.Intensity = greenduelsVividSettings.bloomIntensity
                bloomEffect.Size = greenduelsVividSettings.bloomSize
                bloomEffect.Threshold = 1
                bloomEffect.Parent = Lighting2

                local atmosphere = Instance.new("Atmosphere")
                atmosphere.Name = "greenduelsVividAtmosphere"
                atmosphere:SetAttribute("greenduelsVividGraphics", true)
                atmosphere.Density = 0.3
                atmosphere.Offset = 0.25
                atmosphere.Color = Color3.fromRGB(199, 199, 255)
                atmosphere.Decay = Color3.fromRGB(106, 112, 125)
                atmosphere.Glare = 0.2
                atmosphere.Haze = 1
                atmosphere.Parent = Lighting2

                local sunRaysEffect = Instance.new("SunRaysEffect")
                sunRaysEffect.Name = "greenduelsVividRays"
                sunRaysEffect:SetAttribute("greenduelsVividGraphics", true)
                sunRaysEffect.Intensity = greenduelsVividSettings.sunIntensity
                sunRaysEffect.Spread = 0.8
                sunRaysEffect.Parent = Lighting2

                local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
                depthOfFieldEffect.Name = "greenduelsVividDOF"
                depthOfFieldEffect:SetAttribute("greenduelsVividGraphics", true)
                depthOfFieldEffect.FocusDistance = greenduelsVividSettings.dofFocus
                depthOfFieldEffect.InFocusRadius = 10
                depthOfFieldEffect.NearIntensity = 0.2
                depthOfFieldEffect.FarIntensity = 0.3
                depthOfFieldEffect.Parent = Lighting2

                _G.greenduelsVividContrastConn = task.spawn(function()
                  while tbl18.vividGraphics ~= "Off" do
                    if colorCorrectionEffect and colorCorrectionEffect.Parent then
                      local v88 = 2
                      colorCorrectionEffect.Contrast = 0.35 + math.sin(tick() * v88) * 0.05
                    end

                    task.wait(0.03)
                  end
                end)
              end

              _G.greenduelsOpenVividCustomEditor = function()
                if _G.greenduelsVividEditor and _G.greenduelsVividEditor.Parent then
                  _G.greenduelsVividEditor:Destroy()
                  _G.greenduelsVividEditor = nil
                end

                local hui = nil

                pcall(function()
                  if type(gethui) == "function" then
                    hui = gethui()
                  end
                end)

                hui = hui
                  or localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
                  or game:GetService("CoreGui")

                local screenGui2 = Instance.new("ScreenGui")
                screenGui2.Name = "greenduelsVividCustomEditor"
                screenGui2.ResetOnSpawn = false
                screenGui2.IgnoreGuiInset = true
                screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                screenGui2.DisplayOrder = 1
                screenGui2.Parent = hui

                _G.greenduelsVividEditor = screenGui2

                local instance3 = Instance.new("Frame", screenGui2)
                instance3.Size = UDim2.new(1, 0, 1, 0)
                instance3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                instance3.BackgroundTransparency = 0.5
                instance3.BorderSizePixel = 0
                instance3.ZIndex = 1

                local frame4 = Instance.new("Frame", screenGui2)
                frame4.Size = UDim2.new(0, 390, 0, 330)
                frame4.Position = UDim2.new(0.5, -195, 0.5, -165)
                frame4.BackgroundColor3 = Color3.fromRGB(8, 14, 11)
                frame4.BorderSizePixel = 0
                frame4.ZIndex = 2

                fn71(frame4, 16)
                createUIStroke(frame4, Color3.fromRGB(36, 143, 99), 1).Transparency = 0.2

                local instance4 = Instance.new("TextLabel", frame4)
                instance4.Size = UDim2.new(1, -60, 0, 44)
                instance4.Position = UDim2.new(0, 16, 0, 0)
                instance4.BackgroundTransparency = 1
                instance4.Text = "CUSTOM GAME COLOR"
                instance4.TextColor3 = Color3.fromRGB(255, 255, 255)
                instance4.Font = Enum.Font.GothamBlack
                instance4.TextSize = 15
                instance4.TextXAlignment = Enum.TextXAlignment.Left
                instance4.ZIndex = 3

                local textButton3 = Instance.new("TextButton", frame4)
                textButton3.Size = UDim2.new(0, 34, 0, 40)
                textButton3.Position = UDim2.new(1, -42, 0, 6)
                textButton3.BackgroundColor3 = Color3.fromRGB(18, 45, 24)
                textButton3.BorderSizePixel = 0
                textButton3.Text = "X"
                textButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
                textButton3.Font = Enum.Font.GothamBlack
                textButton3.TextSize = 14
                textButton3.ZIndex = 8

                fn71(textButton3, 9)

                textButton3.MouseButton1Click:Connect(function()
                  screenGui2:Destroy()
                end)

                local instance5 = Instance.new("TextButton", frame4)
                instance5.Size = UDim2.new(1, -58, 0, 46)
                instance5.Position = UDim2.new(0, 0, 0, 0)
                instance5.BackgroundTransparency = 1
                instance5.BorderSizePixel = 0
                instance5.Text = ""
                instance5.AutoButtonColor = false
                instance5.ZIndex = 4

                local flag22 = false
                local position = nil
                local position2 = nil
                local UserInputService = game:GetService("UserInputService")

                local function fn111(arg)
                  local n35 = arg.Position - position
                  frame4.Position = UDim2.new(
                    position2.X.Scale,
                    position2.X.Offset + n35.X,
                    position2.Y.Scale,
                    position2.Y.Offset + n35.Y
                  )
                end

                local function fn112(input)
                  if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                  then
                    flag22 = true
                    position = input.Position
                    position2 = frame4.Position

                    input.Changed:Connect(function()
                      if input.UserInputState == Enum.UserInputState.End then
                        flag22 = false
                      end
                    end)
                  end
                end

                instance5.InputBegan:Connect(fn112)

                instance5.InputChanged:Connect(function(input)
                  if
                    flag22
                    and (
                      input.UserInputType == Enum.UserInputType.MouseMovement
                      or input.UserInputType == Enum.UserInputType.Touch
                    )
                  then
                    fn111(input)
                  end
                end)

                instance4.InputBegan:Connect(fn112)

                instance4.InputChanged:Connect(function(input)
                  if
                    flag22
                    and (
                      input.UserInputType == Enum.UserInputType.MouseMovement
                      or input.UserInputType == Enum.UserInputType.Touch
                    )
                  then
                    fn111(input)
                  end
                end)

                UserInputService.InputChanged:Connect(function(input)
                  if
                    flag22
                    and (
                      input.UserInputType == Enum.UserInputType.MouseMovement
                      or input.UserInputType == Enum.UserInputType.Touch
                    )
                  then
                    fn111(input)
                  end
                end)

                local n35 = 54

                local function fn113(text, arg, arg2, arg3, arg4)
                  local frame5 = Instance.new("Frame", frame4)
                  frame5.Size = UDim2.new(1, -56, 0, 80)
                  frame5.Position = UDim2.new(0, 12, 0, n35)

                  n35 += 46
                  frame5.BackgroundColor3 = Color3.fromRGB(18, 28, 34)
                  frame5.BorderSizePixel = 0
                  frame5.ZIndex = 10
                  fn71(frame5, 12)

                  local textLabel2 = Instance.new("TextLabel", frame5)
                  textLabel2.Size = UDim2.new(1, -152, 1, 0)
                  textLabel2.Position = UDim2.new(0, 12, 0, 0)
                  textLabel2.BackgroundTransparency = 1
                  textLabel2.Text = text
                  textLabel2.TextColor3 = Color3.fromRGB(235, 255, 240)
                  textLabel2.Font = Enum.Font.GothamBold
                  textLabel2.TextSize = 12
                  textLabel2.TextXAlignment = Enum.TextXAlignment.Left
                  textLabel2.ZIndex = 4

                  local instance6 = Instance.new("TextLabel", frame5)
                  instance6.Size = UDim2.new(0, 54, 1, 0)
                  instance6.Position = UDim2.new(1, -100, 0, 0)
                  instance6.BackgroundTransparency = 1
                  instance6.TextColor3 = Color3.fromRGB(255, 255, 255)
                  instance6.Font = Enum.Font.GothamBlack
                  instance6.TextSize = 12
                  instance6.ZIndex = 4

                  local instance7 = Instance.new("TextButton", frame5)
                  instance7.Size = UDim2.new(0, 30, 0, 26)
                  instance7.Position = UDim2.new(1, -138, 0.5, -13)
                  instance7.BackgroundColor3 = Color3.fromRGB(0, 75, 43)
                  instance7.Text = "-"
                  instance7.TextColor3 = Color3.fromRGB(255, 255, 255)
                  instance7.Font = Enum.Font.GothamBlack
                  instance7.TextSize = 16
                  instance7.ZIndex = 4

                  fn71(instance7, 8)

                  local instance8 = Instance.new("TextButton", frame5)
                  instance8.Size = UDim2.new(0, 30, 0, 26)
                  instance8.Position = UDim2.new(1, -36, 0.5, -13)
                  instance8.BackgroundColor3 = Color3.fromRGB(25, 75, 43)
                  instance8.Text = "+"
                  instance8.TextColor3 = Color3.fromRGB(255, 200, 200)
                  instance8.Font = Enum.Font.GothamBlack
                  instance8.TextSize = 12
                  instance8.ZIndex = 4

                  fn71(instance8, 8)

                  local function fn114()
                    instance6.Text = string.format("%.2f", _G.greenduelsVividSettings[arg])
                  end

                  local function fn115(arg5)
                    _G.greenduelsVividSettings[arg] =
                      math.clamp((_G.greenduelsVividSettings[arg] or arg2) + arg5, arg2, arg3)
                    fn114()
                    tbl18.vividGraphics = "Custom"

                    if _G.greenduelsApplyVividGraphics then
                      _G.greenduelsApplyVividGraphics("Custom")
                    end

                    pcall(requestSave)
                  end

                  instance7.MouseButton1Click:Connect(function()
                    fn115(-arg4)
                  end)

                  instance8.MouseButton1Click:Connect(function()
                    fn115(arg4)
                  end)

                  fn114()
                end

                fn113("Saturation", "saturation", 0, 2, 0.05)
                fn113("Bloom Intensity", "bloomIntensity", 0, 3, 0.1)
                fn113("Bloom Size", "bloomSize", 1, 160, 1)
                fn113("Sun Rays", "sunIntensity", 0, 1, 0.05)
                fn113("DOF Focus", "dofFocus", 1, 100, 1)

                local textButton4 = Instance.new("TextButton", frame4)
                textButton4.Size = UDim2.new(1, -56, 0, 38)
                textButton4.Position = UDim2.new(0, 12, 1, -50)
                textButton4.BackgroundColor3 = Color3.fromRGB(25, 75, 43)
                textButton4.Text = "RESET VALUES"
                textButton4.TextColor3 = Color3.fromRGB(255, 255, 200)
                textButton4.Font = Enum.Font.GothamBlack
                textButton4.TextSize = 12
                textButton4.ZIndex = 4

                fn71(textButton4, 10)

                textButton4.MouseButton1Click:Connect(function()
                  _G.greenduelsVividSettings = {
                    saturation = 0.1,
                    bloomIntensity = 0.8,
                    bloomSize = 24,
                    dofFocus = 25,
                    sunIntensity = 0.2,
                  }
                  tbl18.vividGraphics = "Custom"

                  if _G.greenduelsApplyVividGraphics then
                    _G.greenduelsApplyVividGraphics("Custom")
                  end

                  pcall(requestSave)
                  screenGui2:Destroy()
                  task.defer(_G.greenduelsOpenVividCustomEditor)
                end)

                instance3.InputBegan:Connect(function(input)
                  if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                  then
                    screenGui2:Destroy()
                  end
                end)
              end

              local function fn111(arg, arg2)
                arg.AutoButtonColor = false
                arg.Font = Enum.Font.GothamBlack
                arg.TextSize = 11
                arg.TextWrapped = true
                arg.BorderSizePixel = 0
                fn71(arg, 40)

                local v88 = createUIStroke(arg, Color3.fromRGB(56, 54, 34), 1)
                v88.Name = "SelectorStroke"
                v88.Transparency = 0.65

                local frame4 = Instance.new("Frame", arg)
                frame4.Name = "SelectorShine"
                frame4.Size = UDim2.new(1, 0, 0, 10)
                frame4.BackgroundColor3 = Color3.fromRGB(180, 255, 205)
                frame4.BackgroundTransparency = 1
                frame4.BorderSizePixel = 0
                frame4.ZIndex = (arg.ZIndex or 1) + 1

                fn71(frame4, 8)

                arg.MouseEnter:Connect(function()
                  local flag22 = false

                  pcall(function()
                    local v89 = true
                    flag22 = arg:GetAttribute("SelectorActive") == v89
                  end)

                  if not flag22 then
                    local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                    TweenService:Create(arg, TweenInfo.new(0.12), tbl31):Play()
                  end
                end)

                arg.MouseLeave:Connect(function()
                  local flag22 = false

                  pcall(function()
                    flag22 = arg:GetAttribute("SelectorActive") == true
                  end)

                  if not flag22 then
                    fn91(arg, false)
                  else
                    fn91(arg, true)
                  end
                end)

                fn91(arg, arg2, true)
              end

              fn92 = function(arg)
                if arg == Enum.KeyCode.Unknown then
                  return "None"
                end
                local name = arg.Name

                return ({
                  ButtonA = "X",
                  ButtonB = "O",
                  ButtonX = "SQ",
                  ButtonY = "TRI",
                  ButtonL1 = "L1",
                  ButtonL2 = "L2",
                  ButtonL3 = "L3",
                  ButtonR1 = "R1",
                  ButtonR2 = "R2",
                  ButtonR3 = "R3",
                  ButtonSelect = "SHR",
                  ButtonStart = "OPT",
                  DPadUp = "DUP",
                  DPadDown = "DDN",
                  DPadLeft = "DLT",
                  DPadRight = "DRT",
                  Thumbstick1 = "LST",
                  Thumbstick2 = "RST",
                })[name] or name:sub(1, 5)
              end

              local fn112 = nil

              fn93 = function()
                for k, v88 in pairs(tbl26) do
                  if v88 and tbl19[k] then
                    v88.Text = fn92(tbl19[k])
                    fn112(
                      v88,
                      v88:FindFirstChild("KeybindStroke"),
                      tbl19[k] == Enum.KeyCode.Unknown and "none" or "set"
                    )
                  end
                end
              end

              fn112 = function(arg, arg2, arg3)
                local color, color2, color3

                if arg3 == "listen" then
                  color = Color3.fromRGB(78, 245, 145)
                  color2 = Color3.fromRGB(0, 20, 8)
                  color3 = Color3.fromRGB(180, 200, 205)
                elseif arg3 == "none" then
                  color = Color3.fromRGB(18, 26, 20)
                  color2 = Color3.fromRGB(105, 150, 85)
                  color3 = Color3.fromRGB(35, 75, 48)
                else
                  color = Color3.fromRGB(22, 76, 43)
                  color2 = Color3.fromRGB(42, 190, 123)
                  color3 = Color3.fromRGB(92, 255, 150)
                end

                TweenService:Create(
                  arg,
                  TweenInfo.new(0.14, Enum.EasingStyle.Quint),
                  { BackgroundColor3 = color, TextColor3 = color2 }
                ):Play()

                if arg2 then
                  TweenService
                    :Create(
                      arg2,
                      TweenInfo.new(0.14),
                      { Color = color3, Transparency = arg3 == "none" and 0.45 or 0.5 }
                    )
                    :Play()
                  arg2.Thickness = arg3 == "listen" and 2 or 1
                end

                local keybindShine = arg:FindFirstChild("KeybindShine")

                if keybindShine then
                  keybindShine.BackgroundTransparency = 1
                end
              end

              local function createTextButton(arg, arg2, arg3, arg4)
                local instance3 = Instance.new("Frame", v87)
                instance3.Size = UDim2.new(1, -16, 0, 40)
                instance3.BackgroundColor3 = tbl27.rowBg
                instance3.BackgroundTransparency = 0.12
                instance3.BorderSizePixel = 0
                instance3.LayoutOrder = fn104()

                fn71(instance3, 16)
                local v88 = createUIStroke(instance3, Color3.fromRGB(31, 54, 40), 1)
                v88.Transparency = 0.55

                instance3.MouseEnter:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(instance3, TweenInfo.new(0.12), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.12), { Transparency = 0.24 }):Play()
                end)

                instance3.MouseLeave:Connect(function()
                  local tbl31 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(instance3, TweenInfo.new(0.12), tbl31):Play()
                  TweenService:Create(v88, TweenInfo.new(0.12), { Transparency = 0.55 }):Play()
                end)

                local textLabel2 = Instance.new("TextLabel", instance3)
                textLabel2.Size = UDim2.new(1, -96, 1, 0)
                textLabel2.Position = UDim2.new(0, 12, 0, 0)
                textLabel2.BackgroundTransparency = 1

                local text = arg == "Auto Swing"

                if text then
                  text = "Auto Swing: " .. (defaultOn and "ON" or "OFF")
                end

                textLabel2.Text = text or arg
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamMedium
                textLabel2.TextSize = 14
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local textButton3 = Instance.new("TextButton", instance3)
                textButton3.Size = UDim2.new(0, 62, 0, 28)
                textButton3.Position = UDim2.new(1, -72, 0.5, -14)
                textButton3.BackgroundColor3 = Color3.fromRGB(22, 76, 43)
                textButton3.BorderSizePixel = 0
                textButton3.Text = fn92(arg2)
                textButton3.TextColor3 = Color3.fromRGB(42, 230, 123)
                textButton3.Font = Enum.Font.GothamBlack
                textButton3.TextSize = 11
                textButton3.TextWrapped = true
                textButton3.AutoButtonColor = false
                textButton3.ZIndex = 8

                fn71(textButton3, 85)
                local v89 = createUIStroke(textButton3, Color3.fromRGB(92, 255, 150), 1)
                v89.Name = "KeybindStroke"

                local frame4 = Instance.new("Frame", textButton3)
                frame4.Name = "KeybindShine"
                frame4.Size = UDim2.new(1, 0, 0, 10)
                frame4.BackgroundColor3 = Color3.fromRGB(180, 255, 205)
                frame4.BackgroundTransparency = 1
                frame4.BorderSizePixel = 0
                frame4.ZIndex = 9

                fn71(frame4, 85)
                fn112(textButton3, v89, arg2 == Enum.KeyCode.Unknown and "none" or "set")
                local flag22 = false
                local v90 = nil
                local v91 = nil

                local function fn113(arg5)
                  return arg5.UserInputType == Enum.UserInputType.Gamepad1
                    or arg5.UserInputType == Enum.UserInputType.Gamepad2
                    or arg5.UserInputType == Enum.UserInputType.Gamepad3
                    or arg5.UserInputType == Enum.UserInputType.Gamepad4
                end

                local function fn114(arg5)
                  flag22 = false
                  flag18 = false

                  if v90 then
                    v90:Disconnect()
                    v90 = nil
                  end

                  if v91 then
                    v91:Disconnect()
                    v91 = nil
                  end

                  if arg5 then
                    textButton3.Text = fn92(arg5)

                    if arg3 then
                      arg3(arg5)
                    end

                    pcall(requestSave)
                  else
                    textButton3.Text = fn92(tbl19[arg4] or Enum.KeyCode.Unknown)
                  end

                  fn112(
                    textButton3,
                    v89,
                    (arg5 or tbl19[arg4] or Enum.KeyCode.Unknown) == Enum.KeyCode.Unknown and "none"
                      or "set"
                  )
                end

                textButton3.Activated:Connect(function()
                  if flag22 then
                    fn114(nil)
                    return
                  end
                  flag22 = true
                  flag18 = true
                  textButton3.Text = "..."
                  textButton3.TextColor3 = Color3.fromRGB(0, 40, 12)
                  fn112(textButton3, v89, "listen")

                  local function fn115(input)
                    if not flag22 then
                      return
                    end
                    local keyCode = input.KeyCode

                    if input.UserInputType == Enum.UserInputType.Keyboard then
                      if keyCode == Enum.KeyCode.Escape then
                        fn114(nil)
                        return
                      end

                      if keyCode ~= Enum.KeyCode.Unknown then
                        fn114(keyCode)
                      end
                    elseif fn113(input) then
                      if keyCode ~= Enum.KeyCode.Unknown then
                        fn114(keyCode)
                      end
                    end
                  end

                  v90 = greenduelsPerfRun.track(service2.InputBegan:Connect(fn115))
                  v91 = greenduelsPerfRun.track(service2.InputChanged:Connect(fn115))

                  task.delay(40, function()
                    if flag22 then
                      fn114(nil)
                    end
                  end)
                end)

                if arg4 then
                  tbl26[arg4] = textButton3
                end

                return textButton3
              end

              game:GetService("Players")
              game:GetService("RunService")
              local Lighting2 = game:GetService("Lighting")
              local Workspace2 = game:GetService("Workspace")

              local flag22 = false
              local connection = nil

              local function fn113(arg)
                local parent = arg

                while parent do
                  local str6 = tostring(parent.Name)
                  if
                    str6 == "Plots"
                    or str6 == "ChargeSoundPart"
                    or str6 == "CraftingMachine"
                    or str6 == "DO_NOT_REMOVE_ForgeTextureCache"
                  then
                    return
                  end
                  parent = parent.Parent
                end

                pcall(function()
                  if arg:IsA("BasePart") then
                    arg.Material = Enum.Material.Plastic
                    arg.Reflectance = 0
                    arg.CastShadow = false
                  elseif arg:IsA("Decal") or arg:IsA("Texture") then
                    arg.Transparency = 1
                  elseif
                    arg:IsA("ParticleEmitter")
                    or arg:IsA("Trail")
                    or arg:IsA("Beam")
                    or arg:IsA("Fire")
                    or arg:IsA("Smoke")
                    or arg:IsA("Sparkles")
                  then
                    arg.Enabled = false
                  elseif arg:IsA("AnimationController") or arg:IsA("Animator") then
                    for _, v88 in ipairs(arg:GetPlayingAnimationTracks()) do
                      pcall(function()
                        v88:Stop(0)
                      end)
                    end
                  end
                end)
              end

              fn94 = function()
                if flag22 then
                  return
                end
                flag22 = true

                pcall(function()
                  Lighting2.GlobalShadows = false
                  Lighting2.FogEnd = 1e10
                  Lighting2.Brightness = 1
                  Lighting2.EnvironmentDiffuseScale = 0
                  Lighting2.EnvironmentSpecularScale = 0

                  for _, child in pairs(Lighting2:GetChildren()) do
                    local flag23 = not child:GetAttribute("EvadeDuelsVividGraphics")
                      and not child:GetAttribute("greenduelsVividGraphics")

                    if flag23 then
                      flag23 = child:IsA("BlurEffect")
                        or child:IsA("SunRaysEffect")
                        or child:IsA("ColorCorrectionEffect")
                        or child:IsA("BloomEffect")
                        or child:IsA("DepthOfFieldEffect")
                    end

                    if flag23 then
                      child.Enabled = false
                    end
                  end

                  task.spawn(function()
                    local n35 = 0

                    for _, descendant in ipairs(Workspace2:GetDescendants()) do
                      if flag22 then
                        fn113(descendant)
                        n35 += 1

                        if n35 % 350 == 0 then
                          task.wait()
                        end

                        continue
                      end

                      break
                    end
                  end)
                end)

                if connection then
                  connection:Disconnect()
                end

                connection = Workspace2.DescendantAdded:Connect(function(descendant)
                  if flag22 then
                    fn113(descendant)
                  end
                end)
              end

              fn95 = function()
                flag22 = false

                if connection then
                  connection:Disconnect()
                  connection = nil
                end
              end

              potatoGraphicsActive = false
              potatoGraphicsDescConn = nil

              _applyPotatoObj = function(arg)
                local parent = arg

                while parent do
                  local str6 = tostring(parent.Name)
                  if
                    str6 == "TutorialArrow"
                    or str6 == "ChargeSoundPart"
                    or str6 == "CraftingMachine"
                    or str6 == "DO_NOT_REMOVE_ForgeTextureCache"
                  then
                    return
                  end
                  parent = parent.Parent
                end

                pcall(function()
                  if arg:IsA("BasePart") then
                    arg.Material = Enum.Material.Plastic
                    arg.MaterialVariant = ""
                    arg.Reflectance = 0
                    arg.CastShadow = false

                    if arg:IsA("MeshPart") then
                      arg.TextureID = ""
                    end
                  elseif
                    arg:IsA("Decal")
                    or arg:IsA("Texture")
                    or arg:IsA("SurfaceAppearance")
                    or arg:IsA("Shirt")
                    or arg:IsA("Pants")
                    or arg:IsA("ShirtGraphic")
                    or arg:IsA("CharacterMesh")
                  then
                    arg:Destroy()
                  elseif arg:IsA("SpecialMesh") then
                    arg.TextureId = ""
                  elseif
                    arg:IsA("ParticleEmitter")
                    or arg:IsA("Trail")
                    or arg:IsA("Beam")
                    or arg:IsA("Fire")
                    or arg:IsA("Smoke")
                    or arg:IsA("Sparkles")
                    or arg:IsA("PointLight")
                    or arg:IsA("SpotLight")
                    or arg:IsA("SurfaceLight")
                    or arg:IsA("PostEffect")
                  then
                    arg.Enabled = false
                  elseif arg:IsA("AnimationController") or arg:IsA("Animator") then
                    for _, v88 in ipairs(arg:GetPlayingAnimationTracks()) do
                      pcall(function()
                        v88:Stop(0)
                      end)
                    end
                  end
                end)
              end

              enablePotatoGraphics = function()
                if potatoGraphicsActive then
                  return
                end
                potatoGraphicsActive = true
                tbl18.potatoGraphicsEnabled = true
                _G.greenduelsPotatoGraphics = true

                pcall(function()
                  local level01 = Enum.QualityLevel.Level01
                  settings().Rendering.QualityLevel = level01
                end)

                pcall(function()
                  Lighting2.GlobalShadows = false
                  Lighting2.Brightness = 1
                  Lighting2.EnvironmentDiffuseScale = 0
                  Lighting2.EnvironmentSpecularScale = 0
                  Lighting2.FogEnd = 9e9
                  Lighting2.ShadowSoftness = 0

                  for _, child in ipairs(Lighting2:GetChildren()) do
                    if
                      not child:GetAttribute("EvadeDuelsVividGraphics")
                      and not child:GetAttribute("greenduelsVividGraphics")
                      and (
                        child:IsA("BlurEffect")
                        or child:IsA("SunRaysEffect")
                        or child:IsA("BloomEffect")
                        or child:IsA("DepthOfFieldEffect")
                        or child:IsA("ColorCorrectionEffect")
                      )
                    then
                      child.Enabled = false
                    end
                  end
                end)

                pcall(function()
                  local terrain = Workspace2:FindFirstChildOfClass("Terrain")

                  if terrain then
                    terrain.Decoration = false
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 1
                  end
                end)

                task.spawn(function()
                  local n35 = 0

                  for _, descendant in ipairs(Workspace2:GetDescendants()) do
                    if not potatoGraphicsActive then
                      return
                    end
                    _applyPotatoObj(descendant)
                    n35 += 1

                    if n35 % 350 == 0 then
                      task.wait()
                    end
                  end
                end)

                if potatoGraphicsDescConn then
                  potatoGraphicsDescConn:Disconnect()
                end

                potatoGraphicsDescConn = Workspace2.DescendantAdded:Connect(function(descendant)
                  if potatoGraphicsActive then
                    _applyPotatoObj(descendant)
                  end
                end)
              end

              disablePotatoGraphics = function()
                potatoGraphicsActive = false
                tbl18.potatoGraphicsEnabled = false
                _G.greenduelsPotatoGraphics = false

                if potatoGraphicsDescConn then
                  potatoGraphicsDescConn:Disconnect()
                  potatoGraphicsDescConn = nil
                end

                pcall(function()
                  local automatic = Enum.QualityLevel.Automatic
                  settings().Rendering.QualityLevel = automatic
                end)

                pcall(function()
                  local terrain = Workspace2:FindFirstChildOfClass("Terrain")

                  if terrain then
                    terrain.Decoration = true
                  end
                end)
              end

              local flag23 = false
              local v88 = nil
              local v89 = nil

              fn96 = function()
                flag23 = true

                if v88 then
                  v88:Disconnect()
                  v88 = nil
                end

                v88 = greenduelsPerfRun.track(service.RenderStepped:Connect(function()
                  if not flag23 then
                    return
                  end
                  local currentCamera = Workspace.CurrentCamera

                  if currentCamera then
                    currentCamera.CFrame = currentCamera.CFrame
                      * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.7, 0, 0, 0, 1)
                  end
                end))
              end

              fn97 = function()
                flag23 = false

                if v88 then
                  v88:Disconnect()
                  v88 = nil
                end
              end

              fn98 = function()
                if v89 then
                  v89:Disconnect()
                  v89 = nil
                end

                tbl18.fovEnabled = true
                tbl18._defFov = tbl18._defFov
                  or Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView
                  or 70
                _G._VezyFOV = tbl18.fovValue or _G._VezyFOV or 70

                v89 = greenduelsPerfRun.track(service.RenderStepped:Connect(function()
                  if not tbl18.fovEnabled then
                    return
                  end
                  local now2 = tick()
                  if now2 - (_G._greenduelsFovTick or 0) < 0.1 then
                    return
                  end
                  _G._greenduelsFovTick = now2
                  local currentCamera = Workspace.CurrentCamera
                  local fovValue = tbl18.fovValue or _G._VezyFOV or 70

                  if currentCamera and currentCamera.FieldOfView ~= fovValue then
                    currentCamera.FieldOfView = fovValue
                  end
                end))
              end

              local function fn114()
                tbl18.fovEnabled = false

                if v89 then
                  v89:Disconnect()
                  v89 = nil
                end

                local currentCamera = Workspace.CurrentCamera

                if currentCamera then
                  pcall(function()
                    currentCamera.FieldOfView = tbl18._defFov or 70
                  end)
                end
              end

              fn99 = function()
                if tbl24.lagger then
                  tbl24.lagger.setOn(tbl18.laggerMode == 1)
                end

                if tbl24.laggerCarry then
                  tbl24.laggerCarry.setOn(tbl18.laggerMode == 2)
                end

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end
              end

              fn100 = function(laggerMode_)
                if laggerMode_ == tbl18.laggerMode then
                  return
                end
                local laggerMode_2 = tbl18.laggerMode

                if laggerMode_ == 0 then
                  tbl18.carrySpeed = tbl18._prevCarry or 30
                  tbl18.speedToggled = tbl18._prevSpeed or false

                  if tbl24.carrySpeed then
                    tbl24.carrySpeed.setOn(tbl18.speedToggled)
                  end
                elseif laggerMode_ == 1 then
                  if laggerMode_2 == 0 then
                    tbl18._prevCarry = tbl18.carrySpeed
                    tbl18._prevSpeed = tbl18.speedToggled
                  end

                  tbl18.speedToggled = false

                  if tbl24.carrySpeed then
                    tbl24.carrySpeed.setOn(false)
                  end
                elseif laggerMode_ == 2 then
                  if laggerMode_2 == 0 then
                    tbl18._prevCarry = tbl18.carrySpeed
                    tbl18._prevSpeed = tbl18.speedToggled
                  end

                  tbl18.speedToggled = false

                  if tbl24.carrySpeed then
                    tbl24.carrySpeed.setOn(false)
                  end
                end

                tbl18.laggerMode = laggerMode_
                fn99()

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end

                requestSave()
              end

              fn101 = function()
                if tbl18.laggerMode == 0 then
                  fn100(1)
                elseif tbl18.laggerMode == 1 then
                  fn100(2)
                else
                  fn100(1)
                end
              end

              fn102 = function()
                if tbl18.laggerMode ~= 0 then
                  tbl18.laggerMode = 0
                  tbl18.speedToggled = true

                  if tbl24.carrySpeed then
                    tbl24.carrySpeed.setOn(true)
                  end

                  fn99()
                  _G.greenduelsManualNormalSpeed = false

                  if _G._refreshSpeedModeUI then
                    _G._refreshSpeedModeUI()
                  end

                  requestSave()
                  return
                end

                tbl18.speedToggled = not tbl18.speedToggled
                _G.greenduelsManualNormalSpeed = not tbl18.autoChangeSpeed
                  and not tbl18.speedToggled

                if tbl24.carrySpeed then
                  tbl24.carrySpeed.setOn(tbl18.speedToggled)
                end

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end

                requestSave()
              end

              local tbl31 = {
                Speed = "MAIN",
                ["Auto Steal"] = "MAIN",
                Movement = "MAIN",
                Combat = "COMBAT",
                Visual = "VISUALS",
                Settings = "CONFIG",
              }

              local str6 = "MAIN"
              local tbl32 = {}
              local tbl33 = {}
              local tbl34 = {}

              local frame4 = Instance.new("Frame", frame)
              frame4.Name = "BottomNavigation"
              frame4.Position = UDim2.new(0, 10, 1, -54)
              frame4.Size = UDim2.new(1, -20, 0, 44)
              frame4.BackgroundColor3 = Color3.fromRGB(8, 29, 20)
              frame4.BackgroundTransparency = 0.08
              frame4.BorderSizePixel = 0
              frame4.ZIndex = 10

              fn71(frame4, 16)
              createUIStroke(frame4, Color3.fromRGB(58, 143, 99), 1).Transparency = 0.35

              local function fn115()
                for k, v90 in pairs(tbl32) do
                  local flag24 = k == str6
                  v90.BackgroundTransparency = flag24 and 0.18 or 1
                  v90.TextColor3 = flag24 and Color3.fromRGB(232, 200, 242)
                    or Color3.fromRGB(143, 185, 160)
                  tbl33[k].BackgroundColor3 = flag24 and Color3.fromRGB(60, 255, 184)
                    or Color3.fromRGB(48, 83, 62)
                end
              end

              for i, v90 in ipairs({ "MAIN", "COMBAT", "VISUALS", "CONFIG" }) do
                local textButton3 = Instance.new("TextButton", frame4)
                textButton3.Name = "Tab_" .. v90
                textButton3.Size = UDim2.new(0.25, -6, 1, -8)
                textButton3.Position = UDim2.new((i - 1) * 0.25, 3, 0, 4)
                textButton3.BackgroundColor3 = Color3.fromRGB(29, 133, 80)
                textButton3.BorderSizePixel = 0
                textButton3.AutoButtonColor = false
                textButton3.Text = v90
                textButton3.Font = Enum.Font.GothamBold
                textButton3.TextSize = 11
                textButton3.ZIndex = 11

                fn71(textButton3, 12)

                local instance3 = Instance.new("Frame", textButton3)
                instance3.Size = UDim2.new(1, -26, 0, 3)
                instance3.Position = UDim2.new(0, 13, 1, -5)
                instance3.BorderSizePixel = 0
                instance3.ZIndex = 12

                fn71(instance3, 2)
                tbl32[v90] = textButton3
                tbl33[v90] = instance3

                textButton3.Activated:Connect(function()
                  tbl34[str6] = scrollingFrame.CanvasPosition
                  str6 = v90

                  for k, v91 in pairs(tbl30) do
                    if typeof(v91) == "Instance" then
                      v91.Visible = tbl31[k] == str6
                    end
                  end

                  scrollingFrame.CanvasPosition = tbl34[v90] or Vector2.zero
                  fn115()
                end)
              end

              tbl30._addSectionTab = function(arg, arg2)
                arg2.Visible = tbl31[arg] == str6
              end

              fn115()

              local function fn116(name, arg)
                local instance3 = Instance.new("Frame", scrollingFrame)
                instance3.Name = name
                instance3.Size = UDim2.new(1, 0, 0, 0)
                instance3.AutomaticSize = Enum.AutomaticSize.Y
                instance3.BackgroundTransparency = 1
                instance3.BorderSizePixel = 0
                instance3.LayoutOrder = 0

                local uiListLayout2 = Instance.new("UIListLayout", instance3)
                uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
                uiListLayout2.Padding = UDim.new(0, 6)
                uiListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center

                tbl30[name] = instance3
                v87 = instance3
                n34 = 0
                arg()
                v87 = nil
                tbl30._addSectionTab(name, instance3)
                return instance3
              end

              local v90 = 1

              fn116("Speed", function()
                fn105(2)
                fn106("Speed Values")
                fn105(2)

                normalSpeed = fn107("Normal Speed", tbl18.normalSpeed, function(normalSpeed2)
                  if normalSpeed2 > 0 and normalSpeed2 <= 500 then
                    tbl18.normalSpeed = normalSpeed2
                  end
                end)

                carrySpeed = fn107("Carry Speed", tbl18.carrySpeed, function(carrySpeed2)
                  if carrySpeed2 > 0 and carrySpeed2 <= 500 then
                    tbl18.carrySpeed = carrySpeed2
                  end
                end)

                laggerSpeed = fn107("Lagger Speed", tbl18.laggerSpeed, function(laggerSpeed2)
                  if laggerSpeed2 > 0 and laggerSpeed2 <= 500 then
                    tbl18.laggerSpeed = laggerSpeed2
                  end
                end)

                laggerCarrySpeed = fn107(
                  "Lagger Carry Speed",
                  tbl18.laggerCarrySpeed,
                  function(laggerCarrySpeed2)
                    if laggerCarrySpeed2 > 0 and laggerCarrySpeed2 <= 500 then
                      tbl18.laggerCarrySpeed = laggerCarrySpeed2
                    end
                  end
                )

                fn105(4)

                local instance3 = Instance.new("Frame", v87)
                instance3.Size = UDim2.new(1, -10, 0, 44)
                instance3.BackgroundColor3 = tbl27.rowBg
                instance3.BorderSizePixel = 0
                instance3.LayoutOrder = fn104()

                fn71(instance3, 9)
                local v91 = createUIStroke(instance3, tbl27.rowBorder, 1)

                instance3.MouseEnter:Connect(function()
                  local tbl35 = { BackgroundColor3 = tbl27.rowHov }
                  TweenService:Create(instance3, TweenInfo.new(0.1), tbl35):Play()
                  TweenService:Create(v91, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
                end)

                instance3.MouseLeave:Connect(function()
                  local tbl35 = { BackgroundColor3 = tbl27.rowBg }
                  TweenService:Create(instance3, TweenInfo.new(0.1), tbl35):Play()
                  TweenService:Create(v91, TweenInfo.new(0.1), { Transparency = 0.5 }):Play()
                end)

                local textLabel2 = Instance.new("TextLabel", instance3)
                textLabel2.Size = UDim2.new(0.5, 0, 1, 0)
                textLabel2.Position = UDim2.new(0, 18, 0, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = "Current Mode"
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamBold
                textLabel2.TextSize = 13
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                textLabel = Instance.new("TextLabel", instance3)
                textLabel.Size = UDim2.new(0.3, 0, 1, 0)
                textLabel.Position = UDim2.new(0.5, 0, 0, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "Normal"
                textLabel.TextColor3 = tbl27.rowValue
                textLabel.Font = Enum.Font.GothamBold
                textLabel.TextSize = 12
                textLabel.TextXAlignment = Enum.TextXAlignment.Left

                local function refreshSpeedModeUI()
                  if not textLabel then
                    return
                  end
                  local text

                  if tbl18.laggerMode == 1 then
                    text = "Lagger"
                  elseif tbl18.laggerMode == 2 then
                    text = "Lagger Carry"
                  else
                    text = tbl18.speedToggled and "Carry" or "Normal"
                  end

                  textLabel.Text = text
                end

                local v92 = fn102

                fn102 = function()
                  v92()
                  refreshSpeedModeUI()
                end

                local v93 = fn101

                fn101 = function()
                  v93()
                  refreshSpeedModeUI()
                end

                local v94 = fn100

                fn100 = function(arg)
                  v94(arg)
                  refreshSpeedModeUI()
                end

                _G._refreshSpeedModeUI = refreshSpeedModeUI
                fn105(8)
                fn106("Speed Keybinds")
                fn105(2)

                createTextButton("Speed Key (toggles)", tbl19.speed, function(speed)
                  tbl19.speed = speed
                  fn93()
                  requestSave()
                end, "speed")

                createTextButton("Lagger Key (toggles)", tbl19.lagger, function(lagger)
                  tbl19.lagger = lagger
                  fn93()
                  requestSave()
                end, "lagger")

                fn105(4)

                toggleSetters.autoChangeSpeed = fn109(
                  "Auto Change Speed",
                  tbl18.autoChangeSpeed,
                  function(autoChangeSpeed)
                    tbl18.autoChangeSpeed = autoChangeSpeed
                    tbl18.autoCarryOnGrab = autoChangeSpeed
                    _G.greenduelsManualNormalSpeed = false

                    if not autoChangeSpeed then
                      tbl18.speedToggled = false

                      if tbl24.carrySpeed then
                        tbl24.carrySpeed.setOn(false)
                      end

                      if _G._refreshSpeedModeUI then
                        _G._refreshSpeedModeUI()
                      end
                    end

                    requestSave()
                  end
                )
              end).LayoutOrder =
                v90

              fn116("Combat", function()
                fn105(2)
                fn106("Aimbot Options")
                fn105(2)
                tbl18.bypassAutoBatSpeed = tbl18.bypassAutoBatSpeed or 58
                tbl18.bypassLaggerAutoBatSpeed = tbl18.bypassLaggerAutoBatSpeed or 80

                local function fn117(arg, arg2, arg3, arg4)
                  local instance3 = Instance.new("Frame", v87)
                  instance3.Size = UDim2.new(1, -16, 0, 42)
                  instance3.BackgroundColor3 = tbl27.rowBg
                  instance3.BackgroundTransparency = 0.2
                  instance3.BorderSizePixel = 0
                  instance3.LayoutOrder = fn104()

                  fn71(instance3, 16)
                  local v91 = createUIStroke(instance3, tbl27.rowBorder, 1)
                  v91.Transparency = 0.5

                  local textLabel2 = Instance.new("TextLabel", instance3)
                  textLabel2.Size = UDim2.new(1, -24, 1, 0)
                  textLabel2.Position = UDim2.new(0, 12, 0, 0)
                  textLabel2.BackgroundTransparency = 1

                  local text = arg == "Auto Swing"

                  if text then
                    text = "Auto Swing: " .. (arg2 and "ON" or "OFF")
                  end

                  textLabel2.Text = text or arg
                  textLabel2.TextColor3 = tbl27.rowLabel
                  textLabel2.Font = Enum.Font.GothamMedium
                  textLabel2.TextSize = 13
                  textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                  local frame5 = Instance.new("Frame", instance3)
                  frame5.Size = UDim2.new(0, 44, 0, 24)
                  frame5.Position = UDim2.new(1, -116, 0.5, -12)
                  frame5.BackgroundColor3 = arg2 and tbl27.accent or Color3.fromRGB(35, 48, 41)
                  frame5.BorderSizePixel = 0
                  frame5.ZIndex = 7

                  fn71(frame5, 11)

                  local instance4 = Instance.new("Frame", frame5)
                  instance4.Size = UDim2.new(0, 14, 0, 14)
                  instance4.Position = arg2 and UDim2.new(1, -18, 0.5, -7)
                    or UDim2.new(0, 4, 0.5, -7)
                  instance4.BackgroundColor3 = arg2 and Color3.fromRGB(219, 255, 232)
                    or Color3.fromRGB(119, 149, 130)
                  instance4.BorderSizePixel = 0
                  instance4.ZIndex = 8

                  fn71(instance4, 7)

                  local textButton3 = Instance.new("TextButton", instance3)
                  textButton3.Size = UDim2.new(0, 58, 0, 28)
                  textButton3.Position = UDim2.new(1, -64, 0.5, -14)
                  textButton3.BackgroundColor3 = Color3.fromRGB(22, 76, 43)
                  textButton3.BorderSizePixel = 0
                  textButton3.Text = fn92(tbl19[arg4] or Enum.KeyCode.Unknown)
                  textButton3.TextColor3 = Color3.fromRGB(42, 230, 123)
                  textButton3.Font = Enum.Font.GothamBlack
                  textButton3.TextSize = 11
                  textButton3.TextWrapped = true
                  textButton3.AutoButtonColor = false
                  textButton3.ZIndex = 40

                  fn71(textButton3, 9)
                  local v92 = createUIStroke(textButton3, Color3.fromRGB(92, 255, 150), 1)
                  v92.Name = "KeybindStroke"
                  local tbl35 = { keyName = arg4 }

                  local function fn118()
                    textButton3.Text = fn92(tbl19[tbl35.keyName] or Enum.KeyCode.Unknown)
                    fn112(
                      textButton3,
                      v92,
                      (tbl19[tbl35.keyName] or Enum.KeyCode.Unknown) == Enum.KeyCode.Unknown
                          and "none"
                        or "set"
                    )
                    tbl26[tbl35.keyName] = textButton3
                  end

                  fn118()

                  local function fn119(arg5)
                    TweenService
                      :Create(frame5, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                        BackgroundColor3 = arg5 and tbl27.accent or Color3.fromRGB(35, 48, 41),
                      })
                      :Play()
                    TweenService
                      :Create(instance4, TweenInfo.new(0.18, Enum.EasingStyle.Back), {
                        Position = arg5 and UDim2.new(1, -18, 0.5, -7)
                          or UDim2.new(0, 4, 0.5, -7),
                      })
                      :Play()
                  end

                  instance3.MouseEnter:Connect(function()
                    local tbl36 = { BackgroundColor3 = tbl27.rowHov }
                    TweenService:Create(instance3, TweenInfo.new(0.1), tbl36):Play()
                    TweenService:Create(v91, TweenInfo.new(0.1), { Transparency = 0.2 }):Play()
                  end)

                  instance3.MouseLeave:Connect(function()
                    local tbl36 = { BackgroundColor3 = tbl27.rowBg }
                    TweenService:Create(instance3, TweenInfo.new(0.1), tbl36):Play()
                    TweenService:Create(v91, TweenInfo.new(0.5), { Transparency = 0.5 }):Play()
                  end)

                  local textButton4 = Instance.new("TextButton", instance3)
                  textButton4.Size = UDim2.new(1, -72, 1, 0)
                  textButton4.BackgroundTransparency = 1
                  textButton4.Text = ""
                  textButton4.BorderSizePixel = 0
                  textButton4.ZIndex = 5

                  textButton4.MouseButton1Click:Connect(function()
                    if arg3 then
                      pcall(arg3, not (instance3:GetAttribute("On") or false))
                    end
                  end)

                  local textButton5 = Instance.new("TextButton", frame5)
                  textButton5.Size = UDim2.new(1, 0, 1, 0)
                  textButton5.BackgroundTransparency = 1
                  textButton5.Text = ""
                  textButton5.BorderSizePixel = 0
                  textButton5.ZIndex = 9

                  textButton5.MouseButton1Click:Connect(function()
                    if arg3 then
                      pcall(arg3, not (instance3:GetAttribute("On") or false))
                    end
                  end)

                  local flag24 = false
                  local v93 = nil
                  local v94 = nil

                  local function fn120(arg5)
                    return arg5.UserInputType == Enum.UserInputType.Gamepad1
                      or arg5.UserInputType == Enum.UserInputType.Gamepad2
                      or arg5.UserInputType == Enum.UserInputType.Gamepad3
                      or arg5.UserInputType == Enum.UserInputType.Gamepad4
                  end

                  local function fn121(arg5)
                    flag24 = false
                    flag18 = false

                    if v93 then
                      v93:Disconnect()
                      v93 = nil
                    end

                    if v94 then
                      v94:Disconnect()
                      v94 = nil
                    end

                    if arg5 then
                      tbl19[tbl35.keyName] = arg5
                      pcall(requestSave)
                    end

                    fn118()
                  end

                  textButton3.Activated:Connect(function()
                    if flag24 then
                      fn121(nil)
                      return
                    end
                    flag24 = true
                    flag18 = true
                    textButton3.Text = "..."
                    fn112(textButton3, v92, "listen")

                    local function fn122(input)
                      if not flag24 then
                        return
                      end
                      local keyCode = input.KeyCode

                      if input.UserInputType == Enum.UserInputType.Keyboard then
                        if keyCode == Enum.KeyCode.Escape then
                          fn121(nil)
                          return
                        end

                        if keyCode ~= Enum.KeyCode.Unknown then
                          fn121(keyCode)
                        end
                      elseif fn120(input) and keyCode ~= Enum.KeyCode.Unknown then
                        fn121(keyCode)
                      end
                    end

                    v93 = greenduelsPerfRun.track(service2.InputBegan:Connect(fn122))
                    v94 = greenduelsPerfRun.track(service2.InputChanged:Connect(fn122))

                    task.delay(8, function()
                      if flag24 then
                        fn121(nil)
                      end
                    end)
                  end)

                  local tbl36 = {
                    setOn = function(arg5)
                      instance3:SetAttribute("On", arg5 and true or false)
                      fn119(arg5)
                    end,
                    setLabel = function(text2)
                      textLabel2.Text = text2
                    end,
                    setKeyName = function(keyName)
                      if tbl35.keyName ~= keyName then
                        tbl26[tbl35.keyName] = nil
                        tbl35.keyName = keyName
                        fn118()
                      end
                    end,
                    row = instance3,
                  }

                  tbl36.setOn(arg2)
                  return tbl36
                end

                local v91 = nil
                local tpBatAimbot = nil
                local v92 = nil
                local v93 = nil
                local v94 = nil
                local v95 = nil
                local flag24 = false

                local function fn118(arg, visible)
                  if arg then
                    arg.Visible = visible
                    arg.Size = visible and UDim2.new(1, -10, 0, 42) or UDim2.new(1, -10, 0, 0)
                  end
                end

                local function fn119()
                  local v96 = flag24
                  fn118(v92, flag24)
                  fn118(v93, v96)
                  fn118(v94, v96)
                  fn118(v95, v96)
                  fn118(v91 and v91.row, v96)
                end

                local function fn120(arg)
                  for _, child in ipairs(arg:GetChildren()) do
                    if child:IsA("TextLabel") then
                      return child
                    end
                  end
                end

                local function fn121(tpBatMode, aimbot2Toggled)
                  if aimbot2Toggled and fn69() and tpBatMode ~= "AntiHit" then
                    aimbot2Toggled = false
                  end

                  if aimbot2Toggled then
                    tbl18.tpBatMode = tpBatMode
                  end

                  tbl18.aimbot2Toggled = aimbot2Toggled

                  if aimbot2Toggled then
                    if tbl18.batAimbotToggled then
                      tbl18.batAimbotToggled = false
                      fn60()
                    end

                    if tbl24.aimbot and tpBatMode == "AntiHit" then
                      tbl24.aimbot.setOn(true)
                    end

                    fn63()
                  else
                    fn64()

                    if tbl24.aimbot and tpBatMode == "AntiHit" then
                      tbl24.aimbot.setOn(false)
                    end
                  end

                  if tpBatAimbot then
                    tpBatAimbot.setOn(tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")
                  end

                  if v91 then
                    _applyBatModeText()
                  end

                  requestSave()
                end

                local function fn122()
                  local autoBatBypass = tbl18.autoBatBypass

                  if v92 then
                    local v96 = fn120(v92)

                    if v96 then
                      v96.Text = autoBatBypass and "Bypass Auto Bat Speed" or "Auto Bat Speed"
                    end
                  end

                  if v93 then
                    local v96 = fn120(v93)

                    if v96 then
                      v96.Text = autoBatBypass and "Bypass Lagger Auto Bat Speed"
                        or "Lagger Auto Bat Speed"
                    end
                  end

                  if v91 then
                    v91.setLabel(autoBatBypass and "Anti Bat Aimbot" or "Normal Aimbot")
                    v91.setKeyName(autoBatBypass and "antiBat" or "aimbot")
                    v91.setOn(
                      autoBatBypass and tbl18.aimbot2Toggled and tbl18.tpBatMode == "AntiHit"
                        or not autoBatBypass and tbl18.batAimbotToggled
                    )
                  end

                  if tpBatAimbot then
                    tpBatAimbot.setOn(tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")
                  end
                end

                _G.greenduelsSetTpBatMode = function(tpBatMode)
                  tbl18.tpBatMode = tpBatMode

                  if tbl18.aimbot2Toggled then
                    fn64()
                    fn63()
                  end

                  fn122()
                  requestSave()
                end

                local function fn123()
                  local frame5 = Instance.new("Frame", v87)
                  frame5.Size = UDim2.new(1, -12, 0, 42)
                  frame5.BackgroundColor3 = tbl27.rowBg
                  frame5.BackgroundTransparency = 0.2
                  frame5.BorderSizePixel = 0
                  frame5.LayoutOrder = fn104()
                  frame5.ClipsDescendants = true

                  fn71(frame5, 11)
                  local v96 = createUIStroke(frame5, tbl27.rowBorder, 1)
                  v96.Transparency = 0.38

                  local instance3 = Instance.new("TextLabel", frame5)
                  instance3.Size = UDim2.new(1, -96, 0, 42)
                  instance3.Position = UDim2.new(0, 14, 0, 0)
                  instance3.BackgroundTransparency = 1
                  instance3.Text = "Aimbot Options"
                  instance3.TextColor3 = tbl27.rowLabel
                  instance3.Font = Enum.Font.GothamBold
                  instance3.TextSize = 13
                  instance3.TextXAlignment = Enum.TextXAlignment.Left

                  local instance4 = Instance.new("TextButton", frame5)
                  instance4.Size = UDim2.new(0, 42, 0, 28)
                  instance4.Position = UDim2.new(1, -50, 0, 7)
                  instance4.BackgroundColor3 = Color3.fromRGB(10, 14, 12)
                  instance4.BorderSizePixel = 0
                  instance4.Text = utf8.char(9660)
                  instance4.TextColor3 = Color3.fromRGB(235, 245, 238)
                  instance4.Font = Enum.Font.GothamBlack
                  instance4.TextSize = 12
                  instance4.AutoButtonColor = false
                  instance4.ZIndex = 33

                  fn71(instance4, 9)
                  local v97 = createUIStroke(instance4, Color3.fromRGB(28, 48, 36), 1)
                  v97.Transparency = 0.35

                  local frame6 = Instance.new("Frame", frame5)
                  frame6.Size = UDim2.new(1, -8, 0, 40)
                  frame6.Position = UDim2.new(0, 4, 0, 42)
                  frame6.BackgroundColor3 = Color3.fromRGB(7, 9, 8)
                  frame6.BorderSizePixel = 0
                  frame6.Visible = false
                  frame6.ZIndex = 30

                  fn71(frame6, 8)
                  local v98 = createUIStroke(frame6, Color3.fromRGB(22, 76, 43), 1)
                  v98.Transparency = 0.42

                  local frame7 = Instance.new("Frame", frame6)
                  frame7.Size = UDim2.new(0.5, -5, 1, -8)
                  frame7.Position = UDim2.new(0, 4, 0, 4)
                  frame7.BackgroundColor3 = tbl27.accent
                  frame7.BorderSizePixel = 0
                  frame7.ZIndex = 31

                  fn71(frame7, 7)

                  local textButton3 = Instance.new("TextButton", frame6)
                  textButton3.Size = UDim2.new(0.5, 0, 1, 0)
                  textButton3.Position = UDim2.new(0, 0, 0, 0)
                  textButton3.BackgroundTransparency = 1
                  textButton3.BorderSizePixel = 0
                  textButton3.Text = "NORMAL"
                  textButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
                  textButton3.Font = Enum.Font.GothamBlack
                  textButton3.TextSize = 10
                  textButton3.AutoButtonColor = false
                  textButton3.ZIndex = 32

                  local instance5 = Instance.new("TextButton", frame6)
                  instance5.Size = UDim2.new(0.5, 0, 1, 0)
                  instance5.Position = UDim2.new(0.5, 0, 0, 0)
                  instance5.BackgroundTransparency = 1
                  instance5.BorderSizePixel = 0
                  instance5.Text = "BYPASS"
                  instance5.TextColor3 = tbl27.rowLabel
                  instance5.Font = Enum.Font.GothamBlack
                  instance5.TextSize = 10
                  instance5.AutoButtonColor = false
                  instance5.ZIndex = 32

                  local function fn124()
                    local autoBatBypass = tbl18.autoBatBypass
                    local udim2 = autoBatBypass and UDim2.new(0.5, 1, 0, 4)
                      or UDim2.new(0, 4, 0, 4)
                    TweenService
                      :Create(frame7, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
                        Position = udim2,
                        BackgroundColor3 = autoBatBypass and Color3.fromRGB(46, 190, 105)
                          or tbl27.accent,
                      })
                      :Play()
                    textButton3.TextColor3 = autoBatBypass and tbl27.rowLabel
                      or Color3.fromRGB(255, 200, 255)
                    instance5.TextColor3 = autoBatBypass and Color3.fromRGB(255, 255, 255)
                      or tbl27.rowLabel
                    v98.Color = autoBatBypass and tbl27.accent2 or tbl27.accent
                    v97.Color = flag24 and tbl27.accent or Color3.fromRGB(34, 48, 36)
                    fn122()
                  end

                  local function fn125(arg)
                    flag24 = arg
                    instance4.Text = arg and utf8.char(9650) or utf8.char(9660)

                    if arg then
                      frame6.Visible = true
                    else
                      task.delay(0.18, function()
                        if not flag24 then
                          frame6.Visible = false
                        end
                      end)
                    end

                    TweenService
                      :Create(
                        frame5,
                        TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                        {
                          Size = arg and UDim2.new(1, -12, 0, 76)
                            or UDim2.new(1, -12, 0, 42),
                        }
                      )
                      :Play()
                    TweenService
                      :Create(
                        instance4,
                        TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                        {
                          BackgroundColor3 = arg and Color3.fromRGB(18, 28, 22)
                            or Color3.fromRGB(10, 14, 12),
                        }
                      )
                      :Play()
                    v97.Color = arg and tbl27.accent or Color3.fromRGB(28, 48, 36)
                    fn119()
                    fn124()
                  end

                  instance4.MouseButton1Click:Connect(function()
                    fn125(not flag24)
                  end)

                  textButton3.MouseButton1Click:Connect(function()
                    if tbl18.autoBatBypass then
                      tbl18.autoBatBypass = false

                      if tbl18.aimbot2Toggled and tbl18.tpBatMode == "AntiHit" then
                        tbl18.aimbot2Toggled = false
                        fn64()

                        if tbl24.aimbot then
                          tbl24.aimbot.setOn(false)
                        end
                      end

                      requestSave()
                    end

                    fn124()
                  end)

                  instance5.MouseButton1Click:Connect(function()
                    if not tbl18.autoBatBypass then
                      tbl18.autoBatBypass = true

                      if tbl18.batAimbotToggled then
                        tbl18.batAimbotToggled = false
                        fn60()

                        if tbl24.aimbot then
                          tbl24.aimbot.setOn(false)
                        end
                      end

                      requestSave()
                    end

                    fn124()
                  end)

                  frame5.InputBegan:Connect(function(input)
                    if
                      input.UserInputType == Enum.UserInputType.MouseButton1
                      or input.UserInputType == Enum.UserInputType.Touch
                    then
                      fn125(not flag24)
                    end
                  end)

                  frame5.MouseEnter:Connect(function()
                    local tbl35 = { BackgroundColor3 = tbl27.rowHov }
                    TweenService:Create(frame5, TweenInfo.new(0.1), tbl35):Play()
                    TweenService:Create(v96, TweenInfo.new(0.5), { Transparency = 0.18 })
                      :Play()
                  end)

                  frame5.MouseLeave:Connect(function()
                    local tbl35 = { BackgroundColor3 = tbl27.rowBg }
                    TweenService:Create(frame5, TweenInfo.new(0.1), tbl35):Play()
                    TweenService:Create(v96, TweenInfo.new(0.1), { Transparency = 0.38 }):Play()
                  end)

                  fn125(false)
                  fn124()
                end

                local function fn124(batAimbotToggled)
                  tbl18.batAimbotToggled = batAimbotToggled

                  if batAimbotToggled then
                    fn59()
                  else
                    fn60()
                  end

                  if v91 then
                    fn122()
                  end

                  requestSave()
                end

                fn123()
                local autoBatSpeed

                autoBatSpeed, v92 = fn107(
                  "Auto Bat Speed",
                  tbl18.bypassAutoBatSpeed,
                  function(bypassAutoBatSpeed)
                    if
                      bypassAutoBatSpeed
                      and bypassAutoBatSpeed > 0
                      and bypassAutoBatSpeed <= 500
                    then
                      tbl18.bypassAutoBatSpeed = bypassAutoBatSpeed
                      requestSave()
                    end
                  end
                )

                local laggerAutoBatSpeed

                laggerAutoBatSpeed, v93 = fn107(
                  "Lagger Auto Bat Speed",
                  tbl18.bypassLaggerAutoBatSpeed,
                  function(bypassLaggerAutoBatSpeed)
                    if
                      bypassLaggerAutoBatSpeed
                      and bypassLaggerAutoBatSpeed > 0
                      and bypassLaggerAutoBatSpeed <= 500
                    then
                      tbl18.bypassLaggerAutoBatSpeed = bypassLaggerAutoBatSpeed
                      requestSave()
                    end
                  end
                )

                local str7 = tbl18.autoBatBypass and "Anti Bat Aimbot" or "Normal Aimbot"
                local batAimbotToggled = tbl18.autoBatBypass
                    and tbl18.aimbot2Toggled
                    and tbl18.tpBatMode == "AntiHit"
                  or tbl18.batAimbotToggled

                local function fn125(arg)
                  if tbl18.autoBatBypass then
                    fn121("AntiHit", arg)
                  else
                    fn124(arg)
                  end
                end

                v91 = fn117(
                  str7,
                  batAimbotToggled,
                  fn125,
                  tbl18.autoBatBypass and "antiBat" or "aimbot"
                )
                setOn = v91.setOn

                toggleSetters.aimbot = function(arg)
                  if tbl18.autoBatBypass then
                    fn121("AntiHit", arg)
                  else
                    fn124(arg)
                  end
                end

                toggleSetters.aimbot2 = function(arg)
                  fn121("Teleport", arg)
                end

                fn122()
                local autoSwing

                autoSwing, v94 = fn109(
                  "Auto Swing",
                  tbl18.autoSwingEnabled,
                  function(autoSwingEnabled)
                    tbl18.autoSwingEnabled = autoSwingEnabled
                    requestSave()
                  end
                )

                v85 = autoSwing
                toggleSetters.autoSwing = v85
                local mirrorTpDown

                mirrorTpDown, v95 = fn109(
                  "Mirror Tp Down",
                  tbl18.mirrorTPDownEnabled,
                  function(mirrorTPDownEnabled)
                    tbl18.mirrorTPDownEnabled = mirrorTPDownEnabled
                    requestSave()
                  end
                )

                toggleSetters.mirrorTPDown = mirrorTpDown
                fn119()

                tpBatAimbot = fn117(
                  "TP Bat Aimbot",
                  tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport",
                  function(arg)
                    fn121("Teleport", arg)
                  end,
                  "tpBat"
                )

                tbl18.tpBatVersion = "V1"

                toggleSetters.bodyLock = fn109(
                  "Body Lock",
                  tbl18.bodyLockEnabled,
                  function(bodyLockEnabled)
                    tbl18.bodyLockEnabled = bodyLockEnabled

                    if bodyLockEnabled then
                      startBodyLock()
                    else
                      stopBodyLock()
                    end

                    requestSave()
                  end
                )

                fn107("Body Lock Radius", tbl18.bodyLockRadius, function(bodyLockRadius)
                  if bodyLockRadius and bodyLockRadius >= 1 and bodyLockRadius <= 200 then
                    tbl18.bodyLockRadius = bodyLockRadius
                    requestSave()
                  end
                end)

                fn105(6)
                fn106("Bat Counter / Medusa")

                batCounter = fn109("Bat Counter", false, function(batCounterEnabled)
                  tbl18.batCounterEnabled = batCounterEnabled

                  if batCounterEnabled then
                    fn61()
                  else
                    fn62()
                  end

                  requestSave()
                end)

                toggleSetters.batCounter = batCounter

                medusaCounter = fn109("Medusa Counter", false, function(medusaCounterEnabled)
                  tbl18.medusaCounterEnabled = medusaCounterEnabled

                  if medusaCounterEnabled then
                    fn49(localPlayer.Character)
                  else
                    fn50()
                  end
                end)

                toggleSetters.medusaCounter = medusaCounter

                toggleSetters.resetOnMedusa = fn109(
                  "Reset On Medusa",
                  tbl18.resetOnMedusa,
                  function(resetOnMedusa)
                    tbl18.resetOnMedusa = resetOnMedusa

                    if resetOnMedusa then
                      fn77(localPlayer.Character)
                    else
                      fn76()
                    end

                    requestSave()
                  end
                )
              end).LayoutOrder =
                2

              fn116("Auto Steal", function()
                fn105(2)
                fn106("Insta Grab")
                fn105(2)

                autoSteal = fn109("Auto Steal", true, function(autoStealEnabled)
                  tbl22.AutoStealEnabled = autoStealEnabled

                  if autoStealEnabled then
                    fn51()
                  else
                    fn52()
                  end

                  if _G._refreshStealStatus then
                    pcall(_G._refreshStealStatus)
                  end
                end)

                toggleSetters.autoSteal = autoSteal
                fn105(4)

                local function refreshStealStatus() end

                _G._refreshStealStatus = refreshStealStatus
                fn105(4)
                fn106("Steal Config")
                fn105(2)

                Radius = fn107("Radius", tbl22.StealRadius, function(arg)
                  if arg then
                    local stealRadius = math.floor(arg)

                    if stealRadius >= 1 and stealRadius <= 200 then
                      tbl22.StealRadius = stealRadius
                      tbl22.StealRadii[tbl18.autoStealMode or "Normal"] = stealRadius
                      refreshStealStatus()
                      requestSave()
                    end
                  end
                end)

                Duration = fn107("Duration", tbl22.StealDuration, function(arg)
                  if arg then
                    local stealDuration = math.min(arg, 10)

                    if stealDuration >= 0.05 then
                      tbl22.StealDuration = stealDuration
                      refreshStealStatus()
                      requestSave()
                    end
                  end
                end)

                fn105(20)
                fn106("Steal Mode")
                fn105(2)

                local frame5 = Instance.new("Frame", v87)
                frame5.Size = UDim2.new(1, -10, 0, 42)
                frame5.BackgroundColor3 = Color3.fromRGB(8, 18, 12)
                frame5.BorderSizePixel = 0
                frame5.LayoutOrder = fn104()
                frame5.ClipsDescendants = true

                fn71(frame5, 9)
                createUIStroke(frame5, Color3.fromRGB(40, 86, 52), 1).Transparency = 0.32

                local textLabel2 = Instance.new("TextLabel", frame5)
                textLabel2.Size = UDim2.new(1, -78, 0, 42)
                textLabel2.Position = UDim2.new(0, 18, 0, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = "Steal Mode"
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamBlack
                textLabel2.TextSize = 13
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local textButton3 = Instance.new("TextButton", frame5)
                textButton3.Size = UDim2.new(0, 42, 0, 34)
                textButton3.Position = UDim2.new(1, -50, 0, 7)
                textButton3.BackgroundColor3 = Color3.fromRGB(12, 14, 12)
                textButton3.BorderSizePixel = 0
                textButton3.Text = utf8.char(9660)
                textButton3.TextColor3 = Color3.fromRGB(235, 245, 238)
                textButton3.Font = Enum.Font.GothamBlack
                textButton3.TextSize = 12
                textButton3.AutoButtonColor = false
                textButton3.ZIndex = 33

                fn71(textButton3, 85)
                local v91 = createUIStroke(textButton3, Color3.fromRGB(28, 48, 36), 1)
                v91.Transparency = 0.5

                local frame6 = Instance.new("Frame", frame5)
                frame6.Size = UDim2.new(1, -8, 0, 34)
                frame6.Position = UDim2.new(0, 4, 0, 42)
                frame6.BackgroundColor3 = Color3.fromRGB(7, 9, 8)
                frame6.BorderSizePixel = 0
                frame6.Visible = false
                frame6.ZIndex = 40

                fn71(frame6, 8)

                local textButton4 = Instance.new("TextButton", frame6)
                textButton4.Size = UDim2.new(0.5, -5, 1, -40)
                textButton4.Position = UDim2.new(0, 4, 0, 4)
                textButton4.BackgroundColor3 = tbl27.inputBg
                textButton4.BorderSizePixel = 0
                textButton4.Text = "Normal"
                textButton4.TextColor3 = tbl27.inputTxt
                textButton4.ZIndex = 32

                fn71(textButton4, 4)

                local textButton5 = Instance.new("TextButton", frame6)
                textButton5.Size = UDim2.new(0.5, -5, 1, -8)
                textButton5.Position = UDim2.new(0.5, 1, 0, 4)
                textButton5.BackgroundColor3 = tbl27.inputBg
                textButton5.BorderSizePixel = 0
                textButton5.Text = "Semi"
                textButton5.TextColor3 = tbl27.inputTxt
                textButton5.ZIndex = 32

                fn71(textButton5, 7)
                fn111(textButton4, tbl18.autoStealMode == "Normal")
                fn111(textButton5, tbl18.autoStealMode == "Semi")
                local flag24 = false

                local function fn117(arg)
                  flag24 = arg
                  textButton3.Text = arg and utf8.char(9650) or utf8.char(9660)

                  if arg then
                    frame6.Visible = true
                  else
                    task.delay(0.18, function()
                      if not flag24 then
                        frame6.Visible = false
                      end
                    end)
                  end

                  TweenService
                    :Create(
                      frame5,
                      TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                      {
                        Size = arg and UDim2.new(1, -10, 0, 170)
                          or UDim2.new(1, -10, 0, 42),
                      }
                    )
                    :Play()

                  TweenService
                    :Create(
                      textButton3,
                      TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                      {
                        BackgroundColor3 = arg and Color3.fromRGB(18, 28, 22)
                          or Color3.fromRGB(12, 18, 12),
                      }
                    )
                    :Play()

                  v91.Color = arg and tbl27.accent or Color3.fromRGB(28, 48, 36)
                end

                local function fn118(autoStealMode)
                  local num = Radius and tonumber(Radius.Text)

                  if num and num >= 1 and num <= 200 then
                    tbl22.StealRadii[tbl18.autoStealMode or "Normal"] = math.floor(num)
                  end

                  tbl18.autoStealMode = autoStealMode

                  if autoStealMode == "Normal" then
                    local normal = tbl22.StealRadii.Normal or 61
                    fn91(textButton4, true)
                    fn91(textButton5, false)
                    tbl22.StealRadius = normal
                    tbl22.StealDuration = 1.33

                    if Radius then
                      Radius.Text = tostring(normal)
                    end

                    if Duration then
                      Duration.Text = "1.33"
                    end
                  else
                    local semi = tbl22.StealRadii.Semi or 85
                    tbl22.StealRadius = semi
                    tbl22.StealDuration = 0.5

                    if Radius then
                      Radius.Text = tostring(semi)
                    end

                    if Duration then
                      Duration.Text = "1.3"
                    end

                    fn91(textButton5, true)
                    fn91(textButton4, false)
                  end

                  fn52()

                  if tbl22.AutoStealEnabled then
                    fn51()
                  end

                  refreshStealStatus()
                  requestSave()
                end

                textButton3.MouseButton1Click:Connect(function()
                  fn117(not flag24)
                end)

                textButton4.MouseButton1Click:Connect(function()
                  fn118("Normal")
                end)

                textButton5.MouseButton1Click:Connect(function()
                  fn118("Semi")
                end)

                tbl24.stealModeNormal = textButton4
                tbl24.stealModeSemi = textButton5
              end).LayoutOrder =
                3

              fn116("Movement", function()
                fn105(2)
                fn106("Infinite Jump")
                fn105(2)

                infiniteJump = fn109("Infinite Jump", true, function(infJumpEnabled)
                  tbl18.infJumpEnabled = infJumpEnabled
                  fn34()
                end)

                toggleSetters.infJump = infiniteJump
                fn105(2)
                fn106("Jump Mode")
                fn105(2)

                local frame5 = Instance.new("Frame", v87)
                frame5.Size = UDim2.new(1, -16, 0, 42)
                frame5.BackgroundColor3 = Color3.fromRGB(19, 33, 26)
                frame5.BorderSizePixel = 0
                frame5.LayoutOrder = fn104()
                frame5.ClipsDescendants = true

                fn71(frame5, 85)
                local v91 = 1
                createUIStroke(frame5, Color3.fromRGB(31, 54, 40), v91).Transparency = 0.5

                local instance3 = Instance.new("TextLabel", frame5)
                instance3.Size = UDim2.new(1, -78, 0, 42)
                instance3.Position = UDim2.new(0, 14, 0, 0)
                instance3.BackgroundTransparency = 1
                instance3.Text = "Jump Mode"
                instance3.TextColor3 = tbl27.rowLabel
                instance3.Font = Enum.Font.GothamBold
                instance3.TextSize = 14
                instance3.TextXAlignment = Enum.TextXAlignment.Left

                local textButton3 = Instance.new("TextButton", frame5)
                textButton3.Size = UDim2.new(0, 42, 0, 28)
                textButton3.Position = UDim2.new(1, -45, 0, 7)
                textButton3.BackgroundColor3 = Color3.fromRGB(10, 18, 12)
                textButton3.BorderSizePixel = 0
                textButton3.Text = utf8.char(9660)
                textButton3.TextColor3 = Color3.fromRGB(235, 245, 238)
                textButton3.Font = Enum.Font.GothamBlack
                textButton3.TextSize = 12
                textButton3.AutoButtonColor = false
                textButton3.ZIndex = 33

                fn71(textButton3, 85)
                local v92 = createUIStroke(textButton3, Color3.fromRGB(28, 48, 36), 1)
                v92.Transparency = 0.35

                local frame6 = Instance.new("Frame", frame5)
                frame6.Size = UDim2.new(1, -40, 0, 40)
                frame6.Position = UDim2.new(0, 4, 0, 42)
                frame6.BackgroundColor3 = Color3.fromRGB(7, 9, 8)
                frame6.BorderSizePixel = 0
                frame6.Visible = false
                frame6.ZIndex = 30

                fn71(frame6, 40)

                local textButton4 = Instance.new("TextButton", frame6)
                textButton4.Size = UDim2.new(0.5, -5, 1, -8)
                textButton4.Position = UDim2.new(0, 4, 0, 4)
                textButton4.BackgroundColor3 = tbl27.inputBg
                textButton4.BorderSizePixel = 0
                textButton4.Text = "Hold Infinite Jump"
                textButton4.TextColor3 = tbl27.inputTxt
                textButton4.ZIndex = 45

                fn71(textButton4, 7)

                local textButton5 = Instance.new("TextButton", frame6)
                textButton5.Size = UDim2.new(0.5, -5, 1, -40)
                textButton5.Position = UDim2.new(0.5, 1, 0, 4)
                textButton5.BackgroundColor3 = tbl27.inputBg
                textButton5.BorderSizePixel = 0
                textButton5.Text = "Tap Jump"
                textButton5.TextColor3 = tbl27.inputTxt
                textButton5.ZIndex = 32

                fn71(textButton5, 4)
                fn111(textButton4, tbl18.jumpMode ~= "Tap")
                fn111(textButton5, tbl18.jumpMode == "Tap")
                local flag24 = false

                local function fn117(arg)
                  flag24 = arg
                  textButton3.Text = arg and utf8.char(9650) or utf8.char(9660)

                  if arg then
                    frame6.Visible = true
                  else
                    task.delay(0.18, function()
                      if not flag24 then
                        frame6.Visible = false
                      end
                    end)
                  end

                  TweenService
                    :Create(
                      frame5,
                      TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                      {
                        Size = arg and UDim2.new(1, -16, 0, 80)
                          or UDim2.new(1, -16, 0, 42),
                      }
                    )
                    :Play()
                  TweenService
                    :Create(
                      textButton3,
                      TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                      {
                        BackgroundColor3 = arg and Color3.fromRGB(18, 28, 22)
                          or Color3.fromRGB(10, 14, 12),
                      }
                    )
                    :Play()
                  v92.Color = arg and tbl27.accent or Color3.fromRGB(28, 48, 36)
                end

                local function fn118(arg)
                  tbl18.jumpMode = arg == "Tap" and "Tap" or "Hold"
                  fn91(textButton4, tbl18.jumpMode ~= "Tap")
                  fn91(textButton5, tbl18.jumpMode == "Tap")
                  fn34()
                  requestSave()
                end

                textButton3.MouseButton1Click:Connect(function()
                  fn117(not flag24)
                end)

                textButton4.MouseButton1Click:Connect(function()
                  fn118("Hold")
                end)

                textButton5.MouseButton1Click:Connect(function()
                  fn118("Tap")
                end)

                fn105(8)
                fn106("Defense")
                fn105(2)

                antiRagdoll = fn109("Anti Ragdoll", false, function(antiRagdollEnabled)
                  tbl18.antiRagdollEnabled = antiRagdollEnabled

                  if antiRagdollEnabled then
                    greenduelsStartAntiRagdoll()
                  else
                    fn87()
                  end
                end)

                toggleSetters.antiRagdoll = antiRagdoll

                safeMode = fn109("Safe Mode", tbl18.safeMode, function(safeMode2)
                  tbl18.safeMode = safeMode2

                  if safeMode2 then
                    fn70()
                  end

                  requestSave()
                end)

                toggleSetters.safeMode = safeMode

                toggleSetters.noCamCollision = fn109(
                  "No Cam Collision",
                  tbl18.noCamCollisionEnabled,
                  function(arg)
                    if arg then
                      fn35()
                    else
                      fn36()
                    end

                    requestSave()
                  end
                )

                toggleSetters.antiDie = fn109("Anti Die", tbl18.antiDieEnabled, function(arg)
                  if arg then
                    fn37()
                  else
                    fn38()
                  end

                  requestSave()
                end)

                toggleSetters.antiCrasher = fn109(
                  "Anti Crasher (Only If Happening)",
                  tbl18.antiCrasherEnabled,
                  function(antiCrasherEnabled)
                    tbl18.antiCrasherEnabled = antiCrasherEnabled
                    fn75(localPlayer.Character)
                    requestSave()
                  end
                )

                toggleSetters.unwalk = fn109("Unwalk", tbl18.unwalkEnabled, function(unwalkEnabled)
                  tbl18.unwalkEnabled = unwalkEnabled

                  if unwalkEnabled then
                    fn81()
                  else
                    fn82()
                  end

                  requestSave()
                end)

                fn105(40)
                fn106("Auto Movement")
                fn105(2)

                createTextButton("Auto Left", tbl19.autoLeft, function(autoLeft)
                  tbl19.autoLeft = autoLeft
                end, "autoLeft")

                createTextButton("Auto Right", tbl19.autoRight, function(autoRight)
                  tbl19.autoRight = autoRight
                end, "autoRight")

                fn105(20)
                fn106("Auto TP Down")
                fn105(2)

                createTextButton("TP Down Key", tbl19.tpDown, function(tpDown)
                  tbl19.tpDown = tpDown
                end, "tpDown")

                toggleSetters.autoTPDown = fn109(
                  "Auto TP Down",
                  tbl18.autoTPDownEnabled,
                  function(arg)
                    if arg then
                      fn79()
                    else
                      fn80()
                    end

                    requestSave()
                  end
                )

                fn107("Auto TP Height", tbl18.autoTPDownHeight, function(arg)
                  if arg then
                    tbl18.autoTPDownHeight =
                      math.clamp(tonumber(arg) or tbl18.autoTPDownHeight, 1, 100)
                    requestSave()
                  end
                end)

                fn105(6)
                fn106("Drop Settings")
                fn105(2)

                createTextButton("Drop Key", tbl19.drop, function(drop)
                  tbl19.drop = drop
                end, "drop")

                createTextButton("Insta Reset Key", tbl19.reset, function(reset)
                  tbl19.reset = reset
                end, "reset")

                local frame7 = Instance.new("Frame", v87)
                frame7.Size = UDim2.new(1, -16, 0, 42)
                frame7.BackgroundColor3 = Color3.fromRGB(19, 33, 26)
                frame7.BorderSizePixel = 0
                frame7.LayoutOrder = fn104()
                frame7.ClipsDescendants = true

                fn71(frame7, 12)
                createUIStroke(frame7, Color3.fromRGB(31, 54, 80), 1).Transparency = 0.5

                local textLabel2 = Instance.new("TextLabel", frame7)
                textLabel2.Size = UDim2.new(1, -78, 0, 42)
                textLabel2.Position = UDim2.new(0, 18, 0, 0)
                textLabel2.BackgroundTransparency = 1
                textLabel2.Text = "Drop Type"
                textLabel2.TextColor3 = tbl27.rowLabel
                textLabel2.Font = Enum.Font.GothamBold
                textLabel2.TextSize = 14
                textLabel2.TextXAlignment = Enum.TextXAlignment.Left

                local textButton6 = Instance.new("TextButton", frame7)
                textButton6.Size = UDim2.new(0, 42, 0, 28)
                textButton6.Position = UDim2.new(1, -50, 0, 4)
                textButton6.BackgroundColor3 = Color3.fromRGB(10, 14, 12)
                textButton6.BorderSizePixel = 0
                textButton6.Text = utf8.char(9660)
                textButton6.TextColor3 = Color3.fromRGB(235, 245, 238)
                textButton6.Font = Enum.Font.GothamBlack
                textButton6.TextSize = 12
                textButton6.AutoButtonColor = false
                textButton6.ZIndex = 33

                fn71(textButton6, 9)
                local v93 = createUIStroke(textButton6, Color3.fromRGB(28, 48, 36), 1)
                v93.Transparency = 0.35

                local frame8 = Instance.new("Frame", frame7)
                frame8.Size = UDim2.new(1, -40, 0, 34)
                frame8.Position = UDim2.new(0, 4, 0, 42)
                frame8.BackgroundColor3 = Color3.fromRGB(7, 9, 8)
                frame8.BorderSizePixel = 0
                frame8.Visible = false
                frame8.ZIndex = 30

                fn71(frame8, 40)
                textButton = Instance.new("TextButton", frame8)
                textButton.Size = UDim2.new(0.5, -5, 1, -8)
                textButton.Position = UDim2.new(0, 4, 0, 4)
                textButton.BackgroundColor3 = tbl27.inputBg
                textButton.BorderSizePixel = 0
                textButton.Text = "STAND"
                textButton.TextColor3 = tbl27.inputTxt
                textButton.ZIndex = 32
                fn71(textButton, 7)
                textButton2 = Instance.new("TextButton", frame8)
                textButton2.Size = UDim2.new(0.5, -5, 1, -40)
                textButton2.Position = UDim2.new(0.5, 1, 0, 4)
                textButton2.BackgroundColor3 = tbl27.inputBg
                textButton2.BorderSizePixel = 0
                textButton2.Text = "Jump Drop"
                textButton2.TextColor3 = tbl27.inputTxt
                textButton2.ZIndex = 32
                fn71(textButton2, 7)
                fn111(textButton, stand == tbl17.STAND)
                fn111(textButton2, stand == tbl17.JUMP)
                local flag25 = false

                local function fn119(arg)
                  flag25 = arg
                  textButton6.Text = arg and utf8.char(9650) or utf8.char(9660)

                  if arg then
                    frame8.Visible = true
                  else
                    task.delay(0.18, function()
                      if not flag25 then
                        frame8.Visible = false
                      end
                    end)
                  end

                  TweenService
                    :Create(
                      frame7,
                      TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                      {
                        Size = arg and UDim2.new(1, -12, 0, 80) or UDim2.new(1, -16, 0, 42),
                      }
                    )
                    :Play()
                  TweenService
                    :Create(
                      textButton6,
                      TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                      {
                        BackgroundColor3 = arg and Color3.fromRGB(18, 28, 22)
                          or Color3.fromRGB(10, 14, 12),
                      }
                    )
                    :Play()
                  v93.Color = arg and tbl27.accent or Color3.fromRGB(28, 48, 36)
                end

                local function fn120(arg)
                  stand = arg
                  fn91(textButton, arg == tbl17.STAND)
                  fn91(textButton2, arg == tbl17.JUMP)
                  requestSave()
                end

                textButton6.MouseButton1Click:Connect(function()
                  fn119(not flag25)
                end)

                textButton.MouseButton1Click:Connect(function()
                  fn120(tbl17.STAND)
                end)

                textButton2.MouseButton1Click:Connect(function()
                  fn120(tbl17.JUMP)
                end)
              end).LayoutOrder =
                4

              local v91 = nil
              local lowGraphics = nil
              local stretchRez = nil
              local removeAccessories = nil
              local v92 = nil

              fn116("Visual", function()
                fn105(2)
                fn106("Performance")
                fn105(2)

                v91 = fn109("Anti-Lag (recommended)", tbl18.antiLagEnabled, function(antiLagEnabled)
                  tbl18.antiLagEnabled = antiLagEnabled

                  if antiLagEnabled then
                    fn94()
                  else
                    fn95()
                  end
                end)

                toggleSetters.antiLag = v91

                lowGraphics = fn109(
                  "Low Graphics",
                  tbl18.potatoGraphicsEnabled or false,
                  function(potatoGraphicsEnabled)
                    tbl18.potatoGraphicsEnabled = potatoGraphicsEnabled

                    if potatoGraphicsEnabled then
                      enablePotatoGraphics()
                    else
                      disablePotatoGraphics()
                    end

                    requestSave()
                  end
                )

                toggleSetters.potatoGraphics = lowGraphics

                stretchRez = fn109(
                  "Stretch Rez",
                  tbl18.stretchedResEnabled,
                  function(stretchedResEnabled)
                    tbl18.stretchedResEnabled = stretchedResEnabled

                    if stretchedResEnabled then
                      fn96()
                    else
                      fn97()
                    end

                    requestSave()
                  end
                )

                toggleSetters.stretchedRes = stretchRez
                fn105(4)
                fn106("Graphics")
                fn105(2)

                _G.greenduelsVividColors = {
                  Off = Color3.fromRGB(45, 65, 52),
                  ["Game Color"] = Color3.fromRGB(35, 230, 120),
                  Vivid = Color3.fromRGB(35, 190, 120),
                  Custom = Color3.fromRGB(70, 255, 150),
                }

                _G.greenduelsMakePickerRow(
                  "Game Color",
                  _G.greenduelsVividGraphics or { "Off", "Game Color", "Custom" },
                  tbl18.vividGraphics or "Off",
                  _G.greenduelsVividColors,
                  function(vividGraphics)
                    tbl18.vividGraphics = vividGraphics

                    if _G.greenduelsApplyVividGraphics then
                      _G.greenduelsApplyVividGraphics(vividGraphics)
                    end

                    if vividGraphics == "Custom" and _G.greenduelsOpenVividCustomEditor then
                      task.defer(_G.greenduelsOpenVividCustomEditor)
                    end

                    requestSave()
                  end,
                  "Select Game Color"
                )

                fn105(4)
                fn106("Sky Theme")
                fn105(2)

                _G.greenduelsSkyColors = {
                  Reset = Color3.fromRGB(25, 80, 45),
                  Off = Color3.fromRGB(95, 95, 95),
                  Night = Color3.fromRGB(35, 50, 120),
                  Aurora = Color3.fromRGB(55, 255, 185),
                  Sunset = Color3.fromRGB(255, 130, 32),
                  Galaxy = Color3.fromRGB(135, 75, 255),
                  Cyber = Color3.fromRGB(35, 235, 200),
                  Sakura = Color3.fromRGB(200, 150, 215),
                  ["Blood Moon"] = Color3.fromRGB(200, 40, 40),
                  ["Emerald Dawn"] = Color3.fromRGB(80, 200, 140),
                  Volcanic = Color3.fromRGB(220, 90, 30),
                  Arctic = Color3.fromRGB(170, 215, 255),
                  ["Midnight Ocean"] = Color3.fromRGB(30, 80, 160),
                  Toxic = Color3.fromRGB(150, 210, 90),
                  Storm = Color3.fromRGB(90, 95, 115),
                  Heaven = Color3.fromRGB(255, 250, 225),
                }

                _G.greenduelsMakePickerRow(
                  "Sky Theme",
                  _G.greenduelsSkyThemes or { "Off" },
                  tbl18.skyTheme or "Off",
                  _G.greenduelsSkyColors,
                  function(skyTheme)
                    tbl18.skyTheme = skyTheme

                    if _G.greenduelsApplySkyTheme then
                      _G.greenduelsApplySkyTheme(skyTheme)
                    end

                    requestSave()
                  end,
                  "Select Sky Theme"
                )

                fn105(4)
                fn106("Tool Visuals")
                fn105(2)

                toggleSetters.customTools = fn109(
                  "Custom Tools",
                  _G.AmbitiousCustomToolsEnabled == true,
                  function(arg)
                    if _G.AmbitiousCustomTools then
                      _G.AmbitiousCustomTools.setEnabled(arg)
                    end

                    requestSave()
                  end
                )

                _G.greenduelsCustomToolSkinOptions = function(arg)
                  local tbl35 = {}
                  local ambitiousCustomToolAssets = _G.AmbitiousCustomToolAssets or {}
                  local str7 = arg == "Bat" and "DiamondSword" or "GoldenDesertEagle"

                  for k, ambitiousCustomToolAsset in pairs(ambitiousCustomToolAssets) do
                    ambitiousCustomToolAsset = ambitiousCustomToolAsset
                      and ambitiousCustomToolAsset.cat == arg

                    if ambitiousCustomToolAsset then
                      tbl35[#tbl35 + 1] = k
                    end
                  end

                  table.sort(tbl35)

                  if #tbl35 == 0 then
                    tbl35[1] = str7
                  end

                  return tbl35
                end

                _G.AmbitiousCustomToolSkins = _G.AmbitiousCustomToolSkins
                  or { Bat = "DiamondSword", Medusa = "GoldenDesertEagle" }

                _G.greenduelsToolSkinColors = {
                  DiamondSword = Color3.fromRGB(95, 210, 255),
                  Katana = Color3.fromRGB(230, 60, 75),
                  Keyblade = Color3.fromRGB(255, 214, 84),
                  StarWand = Color3.fromRGB(200, 112, 230),
                }

                _G.greenduelsMakePickerRow(
                  "Tool Skin",
                  _G.greenduelsCustomToolSkinOptions("Bat"),
                  _G.AmbitiousCustomToolSkins.Bat or "DiamondSword",
                  _G.greenduelsToolSkinColors,
                  function(bat)
                    if _G.AmbitiousSetCustomToolSkin then
                      _G.AmbitiousSetCustomToolSkin("Bat", bat)
                    else
                      _G.AmbitiousCustomToolSkins.Bat = bat
                    end

                    requestSave()
                  end,
                  "Select Tool Skin"
                )

                fn105(4)

                toggleSetters.fovEnabled = fn109("FOV", tbl18.fovEnabled, function(fovEnabled)
                  tbl18.fovEnabled = fovEnabled

                  if fovEnabled then
                    fn98()
                  else
                    fn114()
                  end

                  requestSave()
                end)

                toggleSetters.fovSlider = fn108(
                  tbl18.fovValue or _G._VezyFOV or 70,
                  function(fovValue)
                    tbl18.fovValue = fovValue
                    _G._VezyFOV = fovValue

                    if tbl18.fovEnabled then
                      local currentCamera = Workspace.CurrentCamera

                      if currentCamera then
                        pcall(function()
                          currentCamera.FieldOfView = fovValue
                        end)
                      end
                    end
                  end
                )

                fn105(8)
                fn106("Other Visuals")
                fn105(2)

                removeAccessories = fn109("Remove Accessories", false, function(removeAcc)
                  tbl18.removeAcc = removeAcc

                  if removeAcc then
                    _G._removeAccStart()
                  else
                    _G._removeAccStop()
                  end
                end)

                toggleSetters.removeAcc = removeAccessories

                toggleSetters.kickWarning = fn109(
                  "Kick Warning",
                  tbl18.kickWarningEnabled,
                  function(kickWarningEnabled)
                    tbl18.kickWarningEnabled = kickWarningEnabled
                    requestSave()
                  end
                )

                fn105(20)
                fn106("Avatar Cosmetics")
                fn105(2)

                toggleSetters.cosmeticHeadless = fn109(
                  "Headless",
                  tbl18.cosmeticHeadless,
                  function(cosmeticHeadless)
                    tbl18.cosmeticHeadless = cosmeticHeadless
                    pcall(_G.greenduelsApplyHeadless, cosmeticHeadless)
                    requestSave()
                  end
                )

                local Korblox = fn110(
                  "Korblox",
                  { "Off", "Left", "Right", "Both" },
                  tbl18.cosmeticKorblox,
                  function(cosmeticKorblox)
                    tbl18.cosmeticKorblox = cosmeticKorblox
                    pcall(_G.greenduelsApplyKorblox, cosmeticKorblox)
                    requestSave()
                  end
                )

                toggleSetters.cosmeticKorblox = function(arg)
                  if Korblox then
                    Korblox.set(arg or tbl18.cosmeticKorblox, false)
                  end
                end

                local Hats = fn110(
                  "Hats",
                  _G.greenduelsHatOrder or { "Off" },
                  tbl18.cosmeticHat,
                  function(cosmeticHat)
                    tbl18.cosmeticHat = cosmeticHat
                    pcall(_G.greenduelsApplyHat, cosmeticHat)
                    requestSave()
                  end
                )

                toggleSetters.cosmeticHat = function(arg)
                  if Hats then
                    Hats.set(arg or tbl18.cosmeticHat, false)
                  end
                end

                fn105(8)
                fn106("ESP")
                fn105(2)

                v92 = fn109(
                  "ESP (Green Highlight + Speed label)",
                  tbl18.espEnabled,
                  function(espEnabled)
                    tbl18.espEnabled = espEnabled

                    if espEnabled then
                      fn85()
                    else
                      fn86()
                    end

                    requestSave()
                  end
                )

                toggleSetters.espEnabled = v92

                toggleSetters.lineEsp = fn109(
                  "Line ESP",
                  tbl18.lineEspEnabled,
                  function(lineEspEnabled)
                    tbl18.lineEspEnabled = lineEspEnabled

                    if not lineEspEnabled then
                      for _, v93 in pairs(tbl29) do
                        if v93.line then
                          v93.line.Visible = false
                        end
                      end
                    end

                    requestSave()
                  end
                )
              end).LayoutOrder =
                5

              hideButtons = nil
              lockButtons = nil

              fn116("Settings", function()
                fn105(2)
                fn106("Interface")
                fn105(2)

                createTextButton("Hide GUI", tbl19.guiHide, function(guiHide)
                  tbl19.guiHide = guiHide
                end, "guiHide")

                uiScale = fn107("UI Scale", 1, function(scale)
                  if scale >= 0.5 and scale <= 2 then
                    if uiScale3 then
                      uiScale3.Scale = scale
                    end
                  end
                end)

                mobileButtonsSize = fn107(
                  "Mobile Buttons Size",
                  tbl18.mobileButtonScale,
                  function(mobileButtonScale)
                    if
                      mobileButtonScale
                      and mobileButtonScale >= 0.5
                      and mobileButtonScale <= 2
                    then
                      tbl18.mobileButtonScale = mobileButtonScale
                      fn65()
                      requestSave()
                    end
                  end
                )

                stealBarSize = fn107("Steal Bar Size", tbl18.stealBarScale, function(stealBarScale)
                  if stealBarScale and stealBarScale >= 0.5 and stealBarScale <= 2 then
                    tbl18.stealBarScale = stealBarScale
                    fn66()
                    requestSave()
                  end
                end)

                hideButtons = fn109("Hide Buttons", false, function(stackButtonsHidden)
                  tbl18.stackButtonsHidden = stackButtonsHidden

                  for _, v93 in pairs(tbl25) do
                    v93.Visible = not stackButtonsHidden
                  end
                end)

                toggleSetters.hideButtons = hideButtons

                lockButtons = fn109("Lock Buttons", false, function(stackButtonsLocked)
                  tbl18.stackButtonsLocked = stackButtonsLocked
                  tbl18.uiLocked = stackButtonsLocked
                end)

                toggleSetters.lockButtons = lockButtons

                toggleSetters.introEnabled = fn109(
                  "Play Intro",
                  tbl18.introEnabled,
                  function(introEnabled)
                    tbl18.introEnabled = introEnabled

                    if introEnabled then
                      task.spawn(function()
                        pcall(greenduelsPlayIntro)
                      end)
                    end

                    requestSave()
                  end
                )

                fn105(6)
                fn106("Intro Music")
                fn105(2)
                introMusicRow = Instance.new("Frame", v87)
                introMusicRow.Size = UDim2.new(1, -10, 0, 42)
                introMusicRow.BackgroundColor3 = tbl27.rowBg
                introMusicRow.BorderSizePixel = 0
                introMusicRow.LayoutOrder = fn104()
                fn71(introMusicRow, 10)
                createUIStroke(introMusicRow, tbl27.rowBorder, 1).Transparency = 0.45
                introMusicLbl = Instance.new("TextLabel", introMusicRow)
                introMusicLbl.Size = UDim2.new(0, 112, 1, 0)
                introMusicLbl.Position = UDim2.new(0, 12, 0, 0)
                introMusicLbl.BackgroundTransparency = 1
                introMusicLbl.Text = "Intro Music"
                introMusicLbl.TextColor3 = tbl27.rowLabel
                introMusicLbl.Font = Enum.Font.GothamBold
                introMusicLbl.TextSize = 13
                introMusicLbl.TextXAlignment = Enum.TextXAlignment.Left
                local tbl35 = {}
                local tbl36 = { "Intro 1", "Intro 2", "Intro 3", "Intro 4" }

                for i, v93 in ipairs(tbl36) do
                  local textButton3 = Instance.new("TextButton", introMusicRow)
                  textButton3.Size = UDim2.new(0, 34, 0, 28)
                  textButton3.Position = UDim2.new(1, -164 + (i - 1) * 80, 0.5, -14)
                  textButton3.Text = tostring(i)
                  textButton3.ZIndex = 40

                  local v94 = fn111
                  local flag24 = (tbl18.introMusic or "Intro 1") == v93

                  if not flag24 then
                    flag24 = (tbl18.introMusic or "Intro 1") == "Default" and v93 == "Intro 1"
                  end

                  v94(textButton3, flag24)

                  textButton3.MouseButton1Click:Connect(function()
                    tbl18.introMusic = v93
                    pcall(_G._refreshIntroMusicButtons)
                    requestSave()
                  end)

                  tbl35[v93] = textButton3
                end

                _G._refreshIntroMusicButtons = function()
                  local introMusic = tbl18.introMusic == "Default" and "Intro 1"
                    or tbl18.introMusic
                    or "Intro 1"

                  for _, v93 in ipairs(tbl36) do
                    if tbl35[v93] then
                      fn91(tbl35[v93], introMusic == v93, true)
                    end
                  end
                end

                fn105(8)
                fn106("Config")
                fn105(2)

                local frame5 = Instance.new("Frame", v87)
                frame5.Size = UDim2.new(1, 0, 0, 46)
                frame5.BackgroundTransparency = 1
                frame5.BorderSizePixel = 0
                frame5.LayoutOrder = fn104()

                local textButton3 = Instance.new("TextButton", frame5)
                textButton3.Size = UDim2.new(1, -28, 0, 32)
                textButton3.Position = UDim2.new(0, 14, 0, 7)
                textButton3.BackgroundColor3 = tbl27.accent
                textButton3.BorderSizePixel = 0
                textButton3.Text = "Save Config Now"
                textButton3.TextColor3 = Color3.fromRGB(0, 20, 8)
                textButton3.Font = Enum.Font.GothamBold
                textButton3.TextSize = 12
                textButton3.ZIndex = 5

                fn71(textButton3, 20)
                createUIStroke(textButton3, tbl27.accent, 1)

                textButton3.MouseEnter:Connect(function()
                  TweenService:Create(
                    textButton3,
                    TweenInfo.new(0.5),
                    { BackgroundColor3 = Color3.fromRGB(46, 160, 90) }
                  ):Play()
                end)

                textButton3.MouseLeave:Connect(function()
                  local tbl37 = { BackgroundColor3 = tbl27.accent }
                  TweenService:Create(textButton3, TweenInfo.new(0.5), tbl37):Play()
                end)

                textButton3.MouseButton1Click:Connect(function()
                  local ok, result = pcall(fn57, true)

                  if ok and result then
                    textButton3.Text = "Saved!"
                    textButton3.BackgroundColor3 = Color3.fromRGB(46, 180, 100)
                  else
                    textButton3.Text = "Save Failed"
                    textButton3.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
                  end

                  task.delay(2.5, function()
                    if textButton3 and textButton3.Parent then
                      textButton3.Text = "Save Config Now"
                      textButton3.BackgroundColor3 = tbl27.accent
                    end
                  end)
                end)

                local frame6 = Instance.new("Frame", v87)
                frame6.Size = UDim2.new(1, -10, 0, 48)
                frame6.BackgroundTransparency = 1
                frame6.LayoutOrder = fn104()

                local instance3 = Instance.new("TextButton", frame6)
                instance3.Size = UDim2.new(1, -28, 0, 32)
                instance3.Position = UDim2.new(0, 14, 0, 7)
                instance3.BackgroundColor3 = Color3.fromRGB(170, 25, 25)
                instance3.BorderSizePixel = 0
                instance3.Text = " Reset All Settings"
                instance3.TextColor3 = Color3.fromRGB(200, 200, 200)
                instance3.Font = Enum.Font.GothamBold
                instance3.TextSize = 12
                instance3.ZIndex = 5

                fn71(instance3, 20)
                local v93 = 1
                createUIStroke(instance3, Color3.fromRGB(130, 45, 200), v93)

                instance3.MouseEnter:Connect(function()
                  TweenService:Create(
                    instance3,
                    TweenInfo.new(0.5),
                    { BackgroundColor3 = Color3.fromRGB(110, 35, 35) }
                  ):Play()
                end)

                instance3.MouseLeave:Connect(function()
                  TweenService:Create(
                    instance3,
                    TweenInfo.new(0.1),
                    { BackgroundColor3 = Color3.fromRGB(80, 0, 25) }
                  ):Play()
                end)

                local n35 = 0
                local thread = nil

                instance3.MouseButton1Click:Connect(function()
                  if n35 == 0 then
                    n35 = 1
                    instance3.Text = " Click again to confirm!"
                    instance3.BackgroundColor3 = Color3.fromRGB(160, 50, 50)

                    if thread then
                      task.cancel(thread)
                    end

                    thread = task.delay(10, function()
                      if instance3 and instance3.Parent then
                        n35 = 0
                        instance3.Text = " Reset All Settings"
                        instance3.BackgroundColor3 = Color3.fromRGB(170, 25, 25)
                      end
                    end)

                    return
                  end

                  n35 = 0

                  if thread then
                    task.cancel(thread)
                    thread = nil
                  end

                  pcall(function()
                    if tbl18.batAimbotToggled then
                      fn60()
                    end
                  end)

                  pcall(function()
                    if tbl18.batCounterEnabled then
                      fn62()
                    end

                    return
                  end)

                  pcall(function()
                    if tbl18.medusaCounterEnabled then
                      fn50()
                    end
                  end)

                  pcall(function()
                    if tbl18.antiRagdollEnabled then
                      fn87()
                    end
                  end)

                  pcall(function()
                    if tbl22.AutoStealEnabled then
                      fn52()
                    end
                  end)

                  pcall(function()
                    if tbl18.autoLeftEnabled then
                      fn54()
                    end
                  end)

                  pcall(function()
                    if tbl18.autoRightEnabled then
                      fn56()
                    end
                  end)

                  pcall(function()
                    if tbl18.autoTPDownEnabled then
                      fn80()
                    end
                  end)

                  pcall(function()
                    if tbl18.unwalkEnabled then
                      fn82()
                    end
                  end)

                  pcall(function()
                    if tbl18.noCamCollisionEnabled then
                      fn36()
                    end
                  end)

                  pcall(function()
                    if tbl18.antiDieEnabled then
                      fn38()
                    end
                  end)

                  pcall(function()
                    if tbl18.antiLagEnabled then
                      fn95()
                    end
                  end)

                  pcall(function()
                    if tbl18.potatoGraphicsEnabled then
                      disablePotatoGraphics()
                    end
                  end)

                  pcall(function()
                    if tbl18.stretchedResEnabled then
                      fn97()
                    end
                  end)

                  pcall(function()
                    if _G.AmbitiousCustomTools then
                      _G.AmbitiousCustomTools.setEnabled(false)
                    end

                    if _G.AmbitiousRainbowTools then
                      _G.AmbitiousRainbowTools.setEnabled(false)
                    end

                    if _G.AmbitiousTransparentTools then
                      _G.AmbitiousTransparentTools.setEnabled(false)
                    end

                    if _G.AmbitiousCustomSounds then
                      _G.AmbitiousCustomSounds.setEnabled(false)
                    end
                  end)

                  pcall(function()
                    if _G._RemoveAccOn and _G._removeAccStop then
                      _G._removeAccStop()
                    end
                  end)

                  pcall(function()
                    if tbl18.aimbot2Toggled then
                      fn64()
                    end
                  end)

                  pcall(function()
                    if tbl18.espEnabled then
                      fn86()
                    end
                  end)

                  tbl18.normalSpeed = 60
                  tbl18.carrySpeed = 30
                  tbl18.laggerSpeed = 10.1
                  tbl18.laggerCarrySpeed = 15
                  tbl18.speedToggled = false
                  tbl18.laggerMode = 0
                  tbl18.infJumpEnabled = true
                  tbl18.antiRagdollEnabled = false
                  tbl18.antiCrasherEnabled = false
                  tbl18.antiDropEnabled = false
                  tbl18.antiLagEnabled = false
                  tbl18.potatoGraphicsEnabled = false
                  tbl18.stretchedResEnabled = false
                  tbl18.medusaCounterEnabled = false
                  tbl18.resetOnMedusa = false
                  tbl18.batCounterEnabled = false
                  tbl18.batAimbotToggled = false
                  tbl18.autoSwingEnabled = false
                  tbl18.autoLeftEnabled = false
                  tbl18.autoRightEnabled = false
                  tbl18.stackButtonsHidden = false
                  tbl18.stackButtonsLocked = false
                  tbl18.uiLocked = false
                  tbl18.mobileButtonScale = 1
                  tbl18.stealBarScale = 1
                  tbl18.introEnabled = true
                  tbl18.introMusic = "Intro 1"
                  tbl18.skyTheme = "Default"
                  tbl18.vividGraphics = "Off"
                  tbl18.kickWarningEnabled = false

                  pcall(function()
                    if _G.EvadeDuelsApplySkyTheme then
                      _G.EvadeDuelsApplySkyTheme("Off")
                    elseif _G.greenduelsApplySkyTheme then
                      _G.greenduelsApplySkyTheme("Off")
                    end

                    if _G.EvadeDuelsApplyVividGraphics then
                      _G.EvadeDuelsApplyVividGraphics("Off")
                    elseif _G.greenduelsApplyVividGraphics then
                      _G.greenduelsApplyVividGraphics("Default")
                    end
                  end)

                  tbl22.StealRadii = { Normal = 61, Semi = 9 }
                  tbl22.StealRadius = 85
                  tbl22.StealDuration = 1.33
                  tbl22.AutoStealEnabled = true
                  tbl18.aimbot2Toggled = false
                  tbl18.espEnabled = false
                  tbl18.autoStealMode = "Semi"
                  tbl18._prevCarry = 40
                  tbl18._prevSpeed = false
                  tbl18.autoChangeSpeed = false
                  tbl18.tpBatMode = "Teleport"
                  tbl18.tpBatVersion = "V1"
                  tbl18.tpBatNoCollision = false
                  tbl18.bodyLockEnabled = false
                  tbl18.bodyLockRadius = 20
                  tbl18.autoBatBypass = false
                  tbl18.mirrorTPDownEnabled = false
                  tbl18.autoTPDownEnabled = false
                  tbl18.autoTPDownHeight = 15
                  tbl18.cosmeticHeadless = false
                  tbl18.cosmeticKorblox = "Off"
                  tbl18.cosmeticHat = "Off"
                  pcall(_G.greenduelsApplyHeadless, false)
                  pcall(_G.greenduelsApplyKorblox, "Default")
                  pcall(_G.greenduelsApplyHat, "Off")
                  tbl18.unwalkEnabled = false
                  tbl18.noCamCollisionEnabled = false
                  tbl18.antiDieEnabled = false
                  tbl19.speed = Enum.KeyCode.Q
                  tbl19.guiHide = Enum.KeyCode.LeftControl
                  tbl19.autoLeft = Enum.KeyCode.L
                  tbl19.autoRight = Enum.KeyCode.R
                  tbl19.lagger = Enum.KeyCode.Unknown
                  tbl19.tpDown = Enum.KeyCode.Unknown
                  tbl19.drop = Enum.KeyCode.H
                  tbl19.reset = Enum.KeyCode.T
                  tbl19.aimbot = Enum.KeyCode.Unknown
                  tbl19.aimbot2 = Enum.KeyCode.Unknown
                  tbl19.tpBat = Enum.KeyCode.Unknown
                  tbl19.antiBat = Enum.KeyCode.Unknown
                  stand = tbl17.STAND

                  if textButton then
                    fn91(textButton, true, true)
                    fn91(textButton2, false, true)
                  end

                  for _, v94 in ipairs({ "cosmeticHeadless", "cosmeticKorblox", "cosmeticHat" }) do
                    if toggleSetters[v94] then
                      pcall(toggleSetters[v94], tbl18[v94])
                    end
                  end

                  if normalSpeed then
                    normalSpeed.Text = tostring(tbl18.normalSpeed)
                  end

                  if carrySpeed then
                    carrySpeed.Text = tostring(tbl18.carrySpeed)
                  end

                  if laggerSpeed then
                    laggerSpeed.Text = tostring(tbl18.laggerSpeed)
                  end

                  if laggerCarrySpeed then
                    laggerCarrySpeed.Text = tostring(tbl18.laggerCarrySpeed)
                  end

                  if Radius then
                    Radius.Text = tostring(tbl22.StealRadius)
                  end

                  if Duration then
                    Duration.Text = tostring(tbl22.StealDuration)
                  end

                  if _G._refreshStealStatus then
                    pcall(_G._refreshStealStatus)
                  end

                  if uiScale3 then
                    uiScale3.Scale = 1
                  end

                  if uiScale then
                    uiScale.Text = "1"
                  end

                  if mobileButtonsSize then
                    mobileButtonsSize.Text = "1"
                  end

                  if stealBarSize then
                    stealBarSize.Text = "1"
                  end

                  fn65()
                  fn66()

                  if toggleSetters.autoSteal then
                    pcall(toggleSetters.autoSteal, true)
                  end

                  if toggleSetters.infJump then
                    pcall(toggleSetters.infJump, true)
                  end

                  if toggleSetters.antiRagdoll then
                    pcall(toggleSetters.antiRagdoll, false)
                  end

                  if toggleSetters.antiCrasher then
                    pcall(toggleSetters.antiCrasher, false)
                  else
                    fn75(localPlayer.Character)
                  end

                  if toggleSetters.antiDrop then
                    pcall(toggleSetters.antiDrop, false)
                  else
                    _G.GreenDuelsSetAntiDropEnabled(false)
                  end

                  if toggleSetters.medusaCounter then
                    pcall(toggleSetters.medusaCounter, false)
                  end

                  if toggleSetters.resetOnMedusa then
                    pcall(toggleSetters.resetOnMedusa, false)
                  end

                  if toggleSetters.batCounter then
                    pcall(toggleSetters.batCounter, false)
                  end

                  if toggleSetters.autoSwing then
                    pcall(toggleSetters.autoSwing, false)
                  end

                  if toggleSetters.hideButtons then
                    pcall(toggleSetters.hideButtons, false)
                  end

                  if toggleSetters.lockButtons then
                    pcall(toggleSetters.lockButtons, false)
                  end

                  if toggleSetters.introEnabled then
                    pcall(toggleSetters.introEnabled, true)
                  end

                  if _G._refreshIntroMusicButtons then
                    pcall(_G._refreshIntroMusicButtons)
                  end

                  if toggleSetters.espEnabled then
                    pcall(toggleSetters.espEnabled, false)
                  end

                  if toggleSetters.autoChangeSpeed then
                    pcall(toggleSetters.autoChangeSpeed, false)
                  end

                  if toggleSetters.mirrorTPDown then
                    pcall(toggleSetters.mirrorTPDown, false)
                  end

                  if toggleSetters.autoTPDown then
                    pcall(toggleSetters.autoTPDown, false)
                  end

                  if toggleSetters.kickWarning then
                    pcall(toggleSetters.kickWarning, false)
                  end

                  if toggleSetters.bodyLock then
                    pcall(toggleSetters.bodyLock, false)
                  end

                  if toggleSetters.aimbot then
                    pcall(toggleSetters.aimbot, false)
                  end

                  if toggleSetters.aimbot2 then
                    pcall(toggleSetters.aimbot2, false)
                  end

                  if tbl24.stealModeNormal and tbl24.stealModeSemi then
                    fn91(tbl24.stealModeNormal, true, true)
                    fn91(tbl24.stealModeSemi, false, true)
                  end

                  if tbl24 then
                    for _, v94 in pairs(tbl24) do
                      if v94 and v94.setOn then
                        pcall(v94.setOn, false)
                      end
                    end
                  end

                  if tbl26 then
                    fn93()
                  end

                  for i, v94 in ipairs(tbl21) do
                    local v95 = tbl25[v94.key]

                    if v95 then
                      TweenService
                        :Create(
                          v95,
                          TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                          { Position = fn44(i) }
                        )
                        :Play()
                    end
                  end

                  if instance then
                    TweenService
                      :Create(
                        instance,
                        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        { Position = UDim2.new(0.5, -230, 0.88, -20) }
                      )
                      :Play()
                  end

                  if _G._refreshSpeedModeUI then
                    _G._refreshSpeedModeUI()
                  end

                  fn34()
                  instance3.Text = "All Settings Reset!"
                  instance3.BackgroundColor3 = Color3.fromRGB(46, 160, 90)

                  task.delay(2, function()
                    if instance3 and instance3.Parent then
                      instance3.Text = " Reset All Settings"
                      instance3.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
                    end
                  end)
                end)

                fn105(8)
                fn106("Layout")
                fn105(2)

                local frame7 = Instance.new("Frame", v87)
                frame7.Size = UDim2.new(1, 0, 0, 46)
                frame7.BackgroundTransparency = 1
                frame7.BorderSizePixel = 0
                frame7.LayoutOrder = fn104()

                local textButton4 = Instance.new("TextButton", frame7)
                textButton4.Size = UDim2.new(1, -34, 0, 32)
                textButton4.Position = UDim2.new(0, 14, 0, 7)
                textButton4.BackgroundColor3 = tbl27.btnBg
                textButton4.BorderSizePixel = 0
                textButton4.Text = "Reset Button Positions"
                textButton4.TextColor3 = tbl27.btnTxt
                textButton4.Font = Enum.Font.GothamBold
                textButton4.TextSize = 12
                textButton4.ZIndex = 5

                fn71(textButton4, 6)
                createUIStroke(textButton4, tbl27.btnBorder, 1)

                textButton4.MouseEnter:Connect(function()
                  local tbl37 = { BackgroundColor3 = tbl27.btnHov }
                  TweenService:Create(textButton4, TweenInfo.new(0.1), tbl37):Play()
                end)

                textButton4.MouseLeave:Connect(function()
                  local tbl37 = { BackgroundColor3 = tbl27.btnBg }
                  TweenService:Create(textButton4, TweenInfo.new(0.1), tbl37):Play()
                end)

                textButton4.MouseButton1Click:Connect(function()
                  for i, v94 in ipairs(tbl21) do
                    local v95 = tbl25[v94.key]

                    if v95 then
                      TweenService
                        :Create(
                          v95,
                          TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                          { Position = fn44(i) }
                        )
                        :Play()
                    end
                  end

                  if instance then
                    TweenService
                      :Create(
                        instance,
                        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        { Position = UDim2.new(0.5, -230, 0.88, -170) }
                      )
                      :Play()
                  end

                  textButton4.Text = "Positions Reset!"

                  task.delay(1.8, function()
                    if textButton4 and textButton4.Parent then
                      textButton4.Text = "Reset Button Positions"
                    end
                  end)
                end)

                fn105(12)

                local frame8 = Instance.new("Frame", v87)
                frame8.Size = UDim2.new(1, 0, 0, 22)
                frame8.BackgroundTransparency = 1
                frame8.BorderSizePixel = 0
                frame8.LayoutOrder = fn104()

                local instance4 = Instance.new("TextLabel", frame8)
                instance4.Size = UDim2.new(1, 0, 1, 0)
                instance4.BackgroundTransparency = 1
                instance4.Text = "greenduels powered by luck"
                instance4.TextColor3 = Color3.fromRGB(50, 100, 65)
                instance4.Font = Enum.Font.Gotham
                instance4.TextSize = 10
                instance4.TextXAlignment = Enum.TextXAlignment.Center

                _G._VezySaveStatusLbl = instance4

                _G._VezyFlashSave = function(arg)
                  if not _G._VezySaveStatusLbl or not _G._VezySaveStatusLbl.Parent then
                    return
                  end
                  local vezySaveStatusLbl = _G._VezySaveStatusLbl

                  if arg then
                    vezySaveStatusLbl.Text = "Auto-saved"
                    vezySaveStatusLbl.TextColor3 = Color3.fromRGB(46, 200, 120)
                  else
                    vezySaveStatusLbl.Text = "Save failed"
                    vezySaveStatusLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
                  end

                  task.delay(1.5, function()
                    if vezySaveStatusLbl and vezySaveStatusLbl.Parent then
                      vezySaveStatusLbl.Text = "greenduels powered by luck"
                      vezySaveStatusLbl.TextColor3 = Color3.fromRGB(45, 100, 65)
                    end
                  end)
                end
              end).LayoutOrder =
                6
            end

            fn67 = function() end

            instance = Instance.new("Frame", screenGui)
            instance.Size = UDim2.new(0, 474, 0, 36)
            instance.Position = UDim2.new(0.5, -237, 0.88, -20)
            instance.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
            instance.BorderSizePixel = 0
            instance.Active = true
            fn71(instance, 18)
            createUIStroke(instance, Color3.fromRGB(46, 200, 85), 1.5)
            fn88(instance, instance)
            uiScale2 = Instance.new("UIScale", instance)
            uiScale2.Scale = tbl18.stealBarScale or 1
            local frame4, textLabel2, textLabel3

            local frame5 = Instance.new("Frame", instance)
            frame5.Size = UDim2.new(0, 220, 1, -8)
            frame5.Position = UDim2.new(0, 4, 0, 4)
            frame5.BackgroundColor3 = Color3.fromRGB(14, 22, 18)
            frame5.BorderSizePixel = 0
            frame5.ClipsDescendants = true

            Instance.new("UICorner", frame5).CornerRadius = UDim.new(1, 0)
            frame4 = Instance.new("Frame", frame5)
            frame4.Size = UDim2.new(0, 0, 1, 0)
            frame4.BackgroundColor3 = Color3.fromRGB(46, 200, 120)
            frame4.BorderSizePixel = 0
            Instance.new("UICorner", frame4).CornerRadius = UDim.new(1, 0)
            textLabel2 = Instance.new("TextLabel", frame5)
            textLabel2.Size = UDim2.new(0, 60, 1, 0)
            textLabel2.Position = UDim2.new(0, 12, 0, 0)
            textLabel2.BackgroundTransparency = 1
            textLabel2.Text = "STEAL"
            textLabel2.TextColor3 = Color3.fromRGB(140, 235, 175)
            textLabel2.Font = Enum.Font.GothamBlack
            textLabel2.TextSize = 12
            textLabel2.TextXAlignment = Enum.TextXAlignment.Left
            textLabel2.ZIndex = 5
            textLabel3 = Instance.new("TextLabel", frame5)
            textLabel3.Size = UDim2.new(0, 45, 1, 0)
            textLabel3.Position = UDim2.new(1, -58, 0, 0)
            textLabel3.BackgroundTransparency = 1
            textLabel3.Text = "0%"
            textLabel3.TextColor3 = Color3.fromRGB(46, 200, 120)
            textLabel3.Font = Enum.Font.GothamBlack
            textLabel3.TextSize = 13
            textLabel3.TextXAlignment = Enum.TextXAlignment.Right
            textLabel3.ZIndex = 5
            local frame6

            do
              local frame7 = Instance.new("Frame", instance)
              frame7.Size = UDim2.new(0, 76, 0, 24)
              frame7.Position = UDim2.new(0, 234, 0.5, -12)
              frame7.BackgroundColor3 = Color3.fromRGB(14, 34, 18)
              frame7.BorderSizePixel = 0

              fn71(frame7, 12)
              createUIStroke(frame7, Color3.fromRGB(35, 96, 58), 1)

              local textLabel4 = Instance.new("TextLabel", frame7)
              textLabel4.Size = UDim2.new(0, 28, 1, 0)
              textLabel4.Position = UDim2.new(0, 43, 0, 0)
              textLabel4.BackgroundTransparency = 1
              textLabel4.Text = "FPS"
              textLabel4.TextColor3 = Color3.fromRGB(165, 215, 185)
              textLabel4.Font = Enum.Font.GothamBold
              textLabel4.TextSize = 10
              textLabel4.TextXAlignment = Enum.TextXAlignment.Left

              local instance2 = Instance.new("TextLabel", frame7)
              instance2.Size = UDim2.new(0, 34, 1, 0)
              instance2.Position = UDim2.new(0, 6, 0, 0)
              instance2.BackgroundTransparency = 1
              instance2.Text = "0"
              instance2.TextColor3 = Color3.fromRGB(245, 255, 248)
              instance2.Font = Enum.Font.GothamBlack
              instance2.TextSize = 12
              instance2.TextXAlignment = Enum.TextXAlignment.Right

              local instance3 = Instance.new("Frame", instance)
              instance3.Size = UDim2.new(0, 94, 0, 24)
              instance3.Position = UDim2.new(0, 318, 0.5, -12)
              instance3.BackgroundColor3 = Color3.fromRGB(14, 34, 18)
              instance3.BorderSizePixel = 0

              fn71(instance3, 12)
              local v87 = 1
              createUIStroke(instance3, Color3.fromRGB(35, 96, 58), v87)

              local textLabel5 = Instance.new("TextLabel", instance3)
              textLabel5.Size = UDim2.new(0, 32, 1, 0)
              textLabel5.Position = UDim2.new(0, 8, 0, 0)
              textLabel5.BackgroundTransparency = 1
              textLabel5.Text = "PING"
              textLabel5.TextColor3 = Color3.fromRGB(165, 215, 185)
              textLabel5.Font = Enum.Font.GothamBold
              textLabel5.TextSize = 10
              textLabel5.TextXAlignment = Enum.TextXAlignment.Left

              local textLabel6 = Instance.new("TextLabel", instance3)
              textLabel6.Size = UDim2.new(0, 48, 1, 0)
              textLabel6.Position = UDim2.new(0, 40, 0, 0)
              textLabel6.BackgroundTransparency = 1
              textLabel6.Text = "0 ms"
              textLabel6.TextColor3 = Color3.fromRGB(245, 200, 248)
              textLabel6.Font = Enum.Font.GothamBlack
              textLabel6.TextSize = 12
              textLabel6.TextXAlignment = Enum.TextXAlignment.Right

              local frame8 = Instance.new("Frame", instance)
              frame8.Size = UDim2.new(0, 34, 0, 22)
              frame8.Position = UDim2.new(1, -40, 0.5, -11)
              frame8.BackgroundColor3 = Color3.fromRGB(14, 22, 18)
              frame8.BorderSizePixel = 0

              fn71(frame8, 11)
              createUIStroke(frame8, Color3.fromRGB(46, 200, 85), 1)
              frame6 = Instance.new("Frame", frame8)
              frame6.Size = UDim2.new(0, 10, 0, 10)
              frame6.Position = UDim2.new(0.5, -5, 0.5, -5)
              frame6.BackgroundColor3 = Color3.fromRGB(46, 200, 120)
              frame6.BorderSizePixel = 0
              fn71(frame6, 5)
              local n34 = 0
              local now2 = tick()

              greenduelsPerfRun.track(service.RenderStepped:Connect(function()
                n34 += 1
                local now3 = tick()

                if now3 - now2 >= 1 then
                  local n35 = math.floor(n34 / (now3 - now2))
                  instance2.Text = tostring(n35)
                  n34 = 0
                  now2 = now3
                end
              end))

              task.spawn(function()
                while task.wait(1) do
                  pcall(function()
                    local Stats = game:GetService("Stats")

                    local ping = Stats.PerformanceStats
                      and Stats.PerformanceStats:FindFirstChild("Ping")

                    if ping then
                      local n35 = math.floor(ping:GetValue() or 0)

                      if textLabel6 then
                        textLabel6.Text = n35 .. " ms"
                      end

                      if frame6 then
                        frame6.BackgroundColor3 = tbl18.isStealing and Color3.fromRGB(80, 240, 150)
                          or Color3.fromRGB(46, 200, 120)
                      end
                    end
                  end)
                end
              end)
            end

            do
              local flag22 = false

              local function fn103()
                if tbl18.bodyLockEnabled and stopBodyLock then
                  flag22 = true
                  stopBodyLock()
                  return true
                end

                return false
              end

              local function fn104()
                if
                  flag22
                  and not tbl18.batAimbotToggled
                  and not tbl18.aimbot2Toggled
                  and startBodyLock
                then
                  flag22 = false
                  startBodyLock()
                  return true
                end

                return false
              end

              local function fn105()
                if _G.greenduelsBodyLockAng then
                  pcall(function()
                    _G.greenduelsBodyLockAng:Destroy()
                  end)

                  _G.greenduelsBodyLockAng = nil
                end

                if _G.greenduelsBodyLockHum and _G.greenduelsBodyLockHum.Parent then
                  _G.greenduelsBodyLockHum.AutoRotate = _G.greenduelsBodyLockOrigAutoRotate ~= nil
                      and _G.greenduelsBodyLockOrigAutoRotate
                    or true
                end

                _G.greenduelsBodyLockHum = nil
                _G.greenduelsBodyLockOrigAutoRotate = nil
              end

              stopBodyLock = function()
                tbl18.bodyLockEnabled = false

                if _G.greenduelsBodyLockConn then
                  _G.greenduelsBodyLockConn:Disconnect()
                  _G.greenduelsBodyLockConn = nil
                end

                fn105()
              end

              startBodyLock = function()
                if _G.greenduelsBodyLockConn then
                  _G.greenduelsBodyLockConn:Disconnect()
                  _G.greenduelsBodyLockConn = nil
                end

                tbl18.bodyLockEnabled = true

                _G.greenduelsBodyLockConn =
                  greenduelsPerfRun.track(service.RenderStepped:Connect(function()
                    if not tbl18.bodyLockEnabled then
                      return
                    end
                    local character = localPlayer.Character
                    local humanoidRootPart = character
                      and character:FindFirstChild("HumanoidRootPart")
                    character = character and character:FindFirstChildOfClass("Humanoid")
                    if not humanoidRootPart or not character or character.Health <= 0 then
                      fn105()
                      return
                    end
                    local n34 = math.max(0, tbl18.bodyLockRadius or 20)
                    local v87 = nil

                    for _, player in ipairs(Players:GetPlayers()) do
                      if player ~= localPlayer and player.Character then
                        local humanoidRootPart2 =
                          player.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid2 = player.Character:FindFirstChildOfClass("Humanoid")

                        if humanoidRootPart2 and humanoid2 and humanoid2.Health > 0 then
                          local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

                          if magnitude <= n34 then
                            n34 = magnitude
                            v87 = humanoidRootPart2
                          end
                        end
                      end
                    end

                    if not v87 then
                      character.AutoRotate = true

                      if _G.greenduelsBodyLockAng then
                        _G.greenduelsBodyLockAng.MaxTorque = Vector3.zero
                        _G.greenduelsBodyLockAng.AngularVelocity = Vector3.zero
                      end

                      return
                    end

                    if
                      not _G.greenduelsBodyLockAng
                      or _G.greenduelsBodyLockAng.Parent ~= humanoidRootPart
                    then
                      fn105()
                      _G.greenduelsBodyLockHum = character
                      _G.greenduelsBodyLockOrigAutoRotate = character.AutoRotate

                      local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
                      bodyAngularVelocity.Name = "greenduelsBodyLock"
                      bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
                      bodyAngularVelocity.P = 5000
                      bodyAngularVelocity.Parent = humanoidRootPart

                      _G.greenduelsBodyLockAng = bodyAngularVelocity
                    end

                    character.AutoRotate = false

                    if _G.greenduelsBodyLockAng then
                      _G.greenduelsBodyLockAng.MaxTorque = Vector3.new(0, math.huge, 0)
                    end

                    local n35 = v87.Position - humanoidRootPart.Position
                    local vector = Vector3.new(n35.X, 0, n35.Z)

                    if vector.Magnitude > 0.01 then
                      local cframe = CFrame.lookAt(
                        humanoidRootPart.Position,
                        humanoidRootPart.Position + vector.Unit
                      )
                      local v88, v89 = (humanoidRootPart.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
                      _G.greenduelsBodyLockAng.AngularVelocity =
                        humanoidRootPart.CFrame:VectorToWorldSpace(
                          Vector3.new(
                            0,
                            math.clamp(v89, -3.1415926535897931, 3.1415926535897931) * 100,
                            0
                          )
                        )
                    end
                  end))
              end

              local v87 = nil

              local function fn106(arg)
                if not (arg and arg:IsA("Tool")) then
                  return false
                end
                local str6 = arg.Name:lower()
                return not (str6:find("medusa") or str6:find("head") or str6:find("stone"))
              end

              local function fn107(arg)
                if not fn106(arg) then
                  return false
                end
                local character = localPlayer.Character
                local v88 = character and character:FindFirstChildOfClass("Humanoid")

                if character and v88 then
                  if arg.Parent ~= character then
                    pcall(function()
                      v88:EquipTool(arg)
                    end)
                  end

                  pcall(function()
                    v88.PlatformStand = false
                    v88.Sit = false
                    v88:ChangeState(Enum.HumanoidStateType.GettingUp)
                  end)

                  pcall(function()
                    v88:ChangeState(Enum.HumanoidStateType.Running)
                  end)

                  for _, descendant in ipairs(character:GetDescendants()) do
                    if descendant:IsA("Motor6D") then
                      pcall(function()
                        descendant.Enabled = true
                      end)
                    end
                  end
                end

                pcall(function()
                  arg.Enabled = true
                end)

                local function fn108()
                  pcall(function()
                    arg.Enabled = true
                  end)

                  pcall(function()
                    arg:Activate()
                  end)

                  local remoteEvent = arg:FindFirstChildWhichIsA("RemoteEvent", true)

                  if remoteEvent then
                    pcall(function()
                      remoteEvent:FireServer()
                    end)

                    return
                  end

                  local remoteFunction = arg:FindFirstChildWhichIsA("RemoteFunction", true)

                  if remoteFunction then
                    pcall(function()
                      remoteFunction:InvokeServer()
                    end)
                  end
                end

                fn108()
                task.defer(fn108)
                task.delay(0.04, fn108)
                return true
              end

              local function fn108()
                local character = localPlayer.Character
                if not character then
                  return nil
                end
                local tool = character:FindFirstChildOfClass("Tool")
                if fn106(tool) then
                  return tool
                end

                for _, child in ipairs(character:GetChildren()) do
                  if
                    child:IsA("Tool")
                    and (child.Name:lower():find("bat") or child.Name:lower():find("slap"))
                  then
                    return child
                  end
                end

                local backpack = localPlayer:FindFirstChild("Backpack")

                if backpack then
                  for _, child in ipairs(backpack:GetChildren()) do
                    if
                      child:IsA("Tool")
                      and (child.Name:lower():find("bat") or child.Name:lower():find("slap"))
                    then
                      return child
                    end
                  end
                end

                return nil
              end

              local flag23 = false
              _waveBatAimbotVelocity = nil
              _G._greenduelsAimbotAttachmentName = "CandyAimbotMoveAttachment"
              _G._greenduelsAimbotMoverName = "CandyAimbotMoveVelocity"
              _G._greenduelsAimbotMinForce = 1000000
              _G._greenduelsAimbotMaxForce = 50000000

              _G._greenduelsClearCandyAimbotMover = function(arg)
                local v88 = arg and arg:FindFirstChild(_G._greenduelsAimbotMoverName)

                if v88 and v88:IsA("LinearVelocity") then
                  v88:Destroy()
                end

                arg = arg and arg:FindFirstChild(_G._greenduelsAimbotAttachmentName)

                if arg and arg:IsA("Attachment") then
                  arg:Destroy()
                end
              end

              _G._CandyClearAimbotMover = function()
                local character = localPlayer.Character
                _G._greenduelsClearCandyAimbotMover(
                  character and character:FindFirstChild("HumanoidRootPart")
                )
              end

              _G._greenduelsGetCandyAimbotMover = function(parent)
                local linearVelocity = parent:FindFirstChild(_G._greenduelsAimbotMoverName)

                if linearVelocity and not linearVelocity:IsA("LinearVelocity") then
                  linearVelocity:Destroy()
                  linearVelocity = nil
                end

                local v88 = parent:FindFirstChild(_G._greenduelsAimbotAttachmentName)
                local attachment

                if v88 and not v88:IsA("Attachment") then
                  v88:Destroy()
                  attachment = nil
                else
                  attachment = v88
                end

                if not attachment then
                  attachment = Instance.new("Attachment")
                  attachment.Name = _G._greenduelsAimbotAttachmentName
                  attachment.Parent = parent
                end

                if not linearVelocity then
                  linearVelocity = Instance.new("LinearVelocity")
                  linearVelocity.Name = _G._greenduelsAimbotMoverName
                  linearVelocity.Attachment0 = attachment
                  linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                  linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                  linearVelocity.ForceLimitsEnabled = true
                  linearVelocity.ForceLimitMode = Enum.ForceLimitMode.PerAxis
                  linearVelocity.VectorVelocity = parent.AssemblyLinearVelocity
                  linearVelocity.Parent = parent
                end

                return linearVelocity
              end

              _G._greenduelsApplyCandyAimbotVelocity = function(arg, arg2, arg3, arg4)
                local v88 = _G._greenduelsGetCandyAimbotMover(arg)
                local n34 = math.clamp(
                  arg.AssemblyMass * math.max((tonumber(arg3) or 0) * 220, 6000),
                  _G._greenduelsAimbotMinForce,
                  _G._greenduelsAimbotMaxForce
                )
                v88.Enabled = true
                v88.MaxAxesForce = Vector3.new(n34, n34, n34)
                v88.VectorVelocity = v88.VectorVelocity:Lerp(
                  arg2,
                  1 - math.exp(-math.max(arg4 or 0.016666666666666666, 0) * 26)
                )
              end

              local function fn109()
                local humanoidRootPart = localPlayer.Character
                  and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then
                  return nil
                end
                local huge = math.huge
                local v88 = nil

                for _, player in ipairs(Players:GetPlayers()) do
                  if player ~= localPlayer and player.Character then
                    local v89 = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid2 = player.Character:FindFirstChildOfClass("Humanoid")

                    if v89 and humanoid2 and humanoid2.Health > 0 then
                      local magnitude = (v89.Position - humanoidRootPart.Position).Magnitude

                      if magnitude < huge then
                        huge = magnitude
                        v88 = v89
                      end
                    end
                  end
                end

                return v88
              end

              fn59 = function()
                if fn69() then
                  tbl18.batAimbotToggled = false

                  if tbl20.aimbot then
                    tbl20.aimbot:Disconnect()
                    tbl20.aimbot = nil
                  end

                  v87 = nil

                  if tbl24.aimbot then
                    tbl24.aimbot.setOn(false)
                  end

                  return
                end

                tbl18.batAimbotMode = "Normal"
                tbl18.ragdollTimerSuppressUntil = tick() + 1

                if fn64 and tbl18.aimbot2Toggled then
                  tbl18.aimbot2Toggled = false
                  fn64()

                  if tbl24.aimbot2 then
                    tbl24.aimbot2.setOn(false)
                  end

                  if toggleSetters.aimbot2 then
                    pcall(toggleSetters.aimbot2, false)
                  end
                end

                fn103()

                if tbl20.aimbot then
                  tbl20.aimbot:Disconnect()
                  tbl20.aimbot = nil
                end

                if tbl18.autoLeftEnabled then
                  tbl18.autoLeftEnabled = false

                  if tbl24.autoLeft then
                    tbl24.autoLeft.setOn(false)
                  end

                  if fn54 then
                    fn54()
                  end

                  if fn47 then
                    pcall(fn47, false)
                  end
                end

                if tbl18.autoRightEnabled then
                  tbl18.autoRightEnabled = false

                  if tbl24.autoRight then
                    tbl24.autoRight.setOn(false)
                  end

                  if fn56 then
                    fn56()
                  end

                  if fn48 then
                    pcall(fn48, false)
                  end
                end

                local humanoid2 = localPlayer.Character
                  and localPlayer.Character:FindFirstChildOfClass("Humanoid")

                if humanoid2 then
                  humanoid2.AutoRotate = false
                end

                flag23 = false

                tbl20.aimbot =
                  greenduelsPerfRun.track(service.RenderStepped:Connect(function(deltaTime)
                    if not tbl18.batAimbotToggled or tbl18.batAimbotMode ~= "Normal" then
                      return
                    end
                    local character = localPlayer.Character
                    if not character then
                      return
                    end
                    local v88 = character:FindFirstChild("HumanoidRootPart")
                    if not v88 then
                      return
                    end
                    local humanoid3 = character:FindFirstChildOfClass("Humanoid")
                    if not humanoid3 then
                      return
                    end

                    if fn69() then
                      tbl18.batAimbotToggled = false

                      if tbl20.aimbot then
                        tbl20.aimbot:Disconnect()
                        tbl20.aimbot = nil
                      end

                      v87 = nil

                      if tbl24.aimbot then
                        tbl24.aimbot.setOn(false)
                      end

                      return
                    end

                    fn78()
                    local tool = character:FindFirstChildOfClass("Tool") or fn108()

                    if tool and tool.Parent ~= character then
                      pcall(function()
                        humanoid3:EquipTool(tool)
                      end)
                    end

                    local v89 = fn109()

                    if not v89 then
                      humanoid3.AutoRotate = true
                      v88.AssemblyAngularVelocity = Vector3.zero
                      _G._greenduelsClearCandyAimbotMover(v88)
                      v87 = nil
                      _waveBatAimbotVelocity = nil
                      return
                    end

                    v87 = v89
                    local assemblyLinearVelocity = v89.AssemblyLinearVelocity
                    local position = v88.Position
                    local position2 = v89.Position
                    local n34 = position2
                      + assemblyLinearVelocity * 0.14
                      + v89.CFrame.LookVector * 0.3
                      - position
                    if n34.Magnitude < 1 then
                      return
                    end
                    local vector = Vector3.new(n34.X, 0, n34.Z)
                    if vector.Magnitude < 0.01 then
                      return
                    end
                    local unit = vector.Unit
                    local bypassLaggerAutoBatSpeed = tbl18.laggerMode ~= 0
                        and tbl18.bypassLaggerAutoBatSpeed
                      or tbl18.bypassAutoBatSpeed
                      or 58
                    local n35 = (position2.Y + 3.7 - position.Y) * 19.5
                      + assemblyLinearVelocity.Y * 0.8
                    local n36

                    if humanoid3.FloorMaterial ~= Enum.Material.Air then
                      n36 = math.max(n35, 14)
                    else
                      n36 = n35
                    end

                    local vector2 = Vector3.new(
                      unit.X * bypassLaggerAutoBatSpeed,
                      math.clamp(n36, -70, 110),
                      unit.Z * bypassLaggerAutoBatSpeed
                    )
                    _waveBatAimbotVelocity = nil
                    _G._greenduelsApplyCandyAimbotVelocity(
                      v88,
                      vector2,
                      bypassLaggerAutoBatSpeed,
                      deltaTime
                    )
                    local n37 = position2
                      + assemblyLinearVelocity
                        * math.clamp(assemblyLinearVelocity.Magnitude / 150, 0.05, 0.2)

                    if (n37 - position).Magnitude > 0.1 then
                      local cframe = CFrame.lookAt(position, n37)
                      local v90, v91, v92 = (v88.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
                      local n38 = math.clamp(v90, -2.5, 2.5)
                      local n39 = math.clamp(v91, -2.5, 2.5)
                      local n40 = math.clamp(v92, -2.5, 2.5)
                      humanoid3.AutoRotate = false
                      v88.AssemblyAngularVelocity =
                        v88.CFrame:VectorToWorldSpace(Vector3.new(n38 * 42, n39 * 42, n40 * 42))
                    end

                    if tbl18.autoSwingEnabled and tool and not flag23 then
                      flag23 = true

                      pcall(function()
                        tool:Activate()
                      end)

                      task.delay(0.5, function()
                        flag23 = false
                      end)
                    end
                  end))
              end

              fn60 = function()
                if tbl20.aimbot then
                  tbl20.aimbot:Disconnect()
                  tbl20.aimbot = nil
                end

                v87 = nil
                _waveBatAimbotVelocity = nil
                flag23 = false
                local character = localPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")

                if humanoid2 then
                  humanoid2.AutoRotate = true
                  humanoid2.PlatformStand = false

                  pcall(function()
                    humanoid2:Move(Vector3.zero, false)
                  end)

                  pcall(function()
                    humanoid2:ChangeState(Enum.HumanoidStateType.Running)
                  end)
                end

                if humanoidRootPart then
                  _G._greenduelsClearCandyAimbotMover(humanoidRootPart)
                  humanoidRootPart.Anchored = false
                  humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                  humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

                  if sethiddenproperty then
                    pcall(sethiddenproperty, humanoidRootPart, "PhysicsRepRootPart", nil)
                  end

                  local cFrame = humanoidRootPart.CFrame
                  local lookVector = cFrame.LookVector
                  local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
                  local vector2

                  if vector.Magnitude < 0.01 then
                    vector2 = Vector3.new(0, 0, -1)
                  else
                    vector2 = vector.Unit
                  end

                  humanoidRootPart.CFrame =
                    CFrame.lookAt(cFrame.Position, cFrame.Position + vector2)
                  humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                  humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                end

                task.spawn(function()
                  for i = 1, 12 do
                    task.wait(0.05)
                    local character2 = localPlayer.Character
                    if not character2 then
                      return
                    end
                    local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
                    local v88 = character2:FindFirstChildOfClass("Humanoid")

                    if v88 then
                      v88.AutoRotate = true
                      v88.PlatformStand = false
                    end

                    if humanoidRootPart2 then
                      humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
                    end
                  end
                end)

                tbl18.hittingCooldown = false
                fn104()
              end

              local flag24 = false
              _G.greenduelsBatAimbotWatchdog = (_G.greenduelsBatAimbotWatchdog or 0) + 1

              task.spawn(function()
                local greenduelsBatAimbotWatchdog = _G.greenduelsBatAimbotWatchdog

                while _G.greenduelsBatAimbotWatchdog == greenduelsBatAimbotWatchdog do
                  if tbl18.batAimbotToggled then
                    local flag25 = false

                    pcall(function()
                      flag25 = tbl20.aimbot and tbl20.aimbot.Connected
                    end)

                    if not flag25 then
                      pcall(fn59)
                    end
                  end

                  task.wait(0.5)
                end
              end)

              local function fn110()
                local character = localPlayer.Character
                if not character then
                  return nil
                end

                local tbl30 = {
                  "Bat",
                  "Slap",
                  "Iron Slap",
                  "Gold Slap",
                  "Diamond Slap",
                  "Emerald Slap",
                  "Ruby Slap",
                  "Dark Matter Slap",
                  "Flame Slap",
                  "Nuclear Slap",
                  "Galaxy Slap",
                  "Glitched Slap",
                }

                local tool = character:FindFirstChildOfClass("Tool")
                if fn106(tool) then
                  return tool
                end

                for _, v88 in ipairs(tbl30) do
                  local v89 = character:FindFirstChild(v88)
                  if v89 and v89:IsA("Tool") then
                    return v89
                  end
                end

                local backpack = localPlayer:FindFirstChild("Backpack")

                if backpack then
                  for _, v88 in ipairs(tbl30) do
                    local v89 = backpack:FindFirstChild(v88)

                    if v89 and v89:IsA("Tool") then
                      local humanoid2 = character:FindFirstChildOfClass("Humanoid")

                      if humanoid2 then
                        pcall(function()
                          humanoid2:EquipTool(v89)
                        end)
                      else
                        v89.Parent = character
                      end

                      return v89
                    end
                  end
                end

                for _, child in ipairs(character:GetChildren()) do
                  if fn106(child) then
                    return child
                  end
                end

                return nil
              end

              local function fn111()
                if flag24 then
                  return
                end
                flag24 = true

                pcall(function()
                  local character = localPlayer.Character
                  if not character then
                    return
                  end
                  local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                  local v88 = fn110()

                  if v88 then
                    if v88.Parent ~= character and humanoid2 then
                      pcall(function()
                        humanoid2:EquipTool(v88)
                      end)
                    end

                    fn107(v88)
                  end
                end)

                task.delay(0.5, function()
                  flag24 = false
                end)
              end

              local vector = nil

              local function fn112()
                if not tbl18.aimbot2Toggled or tbl18.tpBatMode ~= "AntiHit" then
                  return
                end
                local character = localPlayer.Character
                if not character then
                  return
                end
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                if not humanoidRootPart or not humanoid2 then
                  return
                end

                if not fn68() and not character:FindFirstChildOfClass("Tool") then
                  local v88 = fn110()

                  if v88 then
                    pcall(function()
                      humanoid2:EquipTool(v88)
                      return
                    end)
                  end
                end

                local huge = math.huge
                local v88 = nil

                for _, player in ipairs(Players:GetPlayers()) do
                  if player ~= localPlayer and player.Character then
                    local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
                    local v89 = player.Character:FindFirstChildOfClass("Humanoid")

                    if humanoidRootPart2 and v89 and v89.Health > 0 then
                      local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

                      if magnitude < huge then
                        huge = magnitude
                        v88 = humanoidRootPart2
                      end
                    end
                  end
                end

                if not v88 then
                  vector = nil
                  humanoid2.AutoRotate = true
                  humanoid2:Move(Vector3.zero, false)
                  return
                end

                local v89 = fn68()
                fn78()
                local position = humanoidRootPart.Position
                local position2 = v88.Position
                local n34 = position2 - position
                local vector2 = Vector3.new(n34.X, 0, n34.Z)
                local unit

                if vector2.Magnitude > 0 then
                  unit = vector2.Unit
                else
                  unit = Vector3.zero
                end

                local bypassLaggerAutoBatSpeed = tbl18.laggerMode ~= 0
                    and tbl18.bypassLaggerAutoBatSpeed
                  or tbl18.bypassAutoBatSpeed

                if v89 then
                  humanoid2.AutoRotate = true
                  humanoid2:Move(unit, false)

                  if humanoid2.FloorMaterial ~= Enum.Material.Air then
                    humanoidRootPart.Velocity = Vector3.new(
                      unit.X * bypassLaggerAutoBatSpeed,
                      humanoidRootPart.Velocity.Y,
                      unit.Z * bypassLaggerAutoBatSpeed
                    )
                  end

                  return
                end

                humanoid2.AutoRotate = false

                if tbl18.autoSwingEnabled and huge <= 8 then
                  fn111()
                end

                vector = Vector3.new(position2.X, position.Y, position2.Z)
                local n35 = (position2.Y + 3.7 - position.Y) * 19.5
                local n36

                if humanoid2.FloorMaterial == Enum.Material.Air then
                  n36 = n35
                else
                  n36 = math.max(n35, 13)
                end

                humanoidRootPart.AssemblyLinearVelocity =
                  humanoidRootPart.AssemblyLinearVelocity:Lerp(
                    Vector3.new(
                      unit.X * bypassLaggerAutoBatSpeed,
                      math.clamp(n36, -70, 110),
                      unit.Z * bypassLaggerAutoBatSpeed
                    ),
                    0.8
                  )

                if (position2 - position).Magnitude > 0.1 then
                  local cframe = CFrame.lookAt(position, position2)
                  local v90, v91, v92 = (humanoidRootPart.CFrame:Inverse() * cframe):ToEulerAnglesXYZ()
                  humanoidRootPart.AssemblyAngularVelocity =
                    humanoidRootPart.CFrame:VectorToWorldSpace(
                      Vector3.new(
                        math.clamp(v90, -2.5, 2.5) * 42,
                        math.clamp(v91, -2.5, 2.5) * 42,
                        math.clamp(v92, -2.5, 2.5) * 42
                      )
                    )
                end
              end

              local function fn113()
                local character = localPlayer.Character
                if not character then
                  return nil
                end
                local bat = character:FindFirstChild("Bat")
                if bat then
                  return bat
                end
                local backpack = localPlayer:FindFirstChild("Backpack")

                if backpack then
                  local v88 = backpack:FindFirstChild("Bat")
                  if v88 then
                    v88.Parent = character
                    return v88
                  end
                end

                return nil
              end

              local function fn114()
                if tbl18.cooldown then
                  return
                end
                tbl18.cooldown = true

                pcall(function()
                  local v88 = fn113()

                  if v88 then
                    v88:Activate()
                    local remoteEvent = v88:FindFirstChildWhichIsA("RemoteEvent")

                    if remoteEvent then
                      remoteEvent:FireServer()
                    end
                  end
                end)

                task.delay(0.5, function()
                  tbl18.cooldown = false
                end)
              end

              local function fn115()
                if not v84 then
                  return nil
                end
                local huge = math.huge
                local v88 = nil

                for _, player in ipairs(Players:GetPlayers()) do
                  if player ~= localPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

                    if humanoidRootPart then
                      local magnitude = (v84.Position - humanoidRootPart.Position).Magnitude

                      if magnitude < huge then
                        huge = magnitude
                        v88 = player
                      end
                    end
                  end
                end

                return v88
              end

              local cFrame = nil
              local n34 = 0

              local function fn116(arg, arg2)
                if
                  arg
                  and arg2
                  and arg.Position.Y > -0
                  and arg2.FloorMaterial ~= Enum.Material.Air
                then
                  cFrame = arg.CFrame
                  n34 = tick()
                end
              end

              local function fn117(arg, arg2)
                if not arg then
                  return false
                end

                if not (arg.Position.Y < -35 or arg.AssemblyLinearVelocity.Y < -210) then
                  return false
                end

                if not arg2 then
                  local flag25 = cFrame and tick() - n34 < 5
                  arg2 = nil

                  if flag25 then
                    arg2 = cFrame
                  end
                end

                if arg2 then
                  arg.CFrame = arg2 + Vector3.new(0, 10, 0)
                else
                  arg.CFrame = CFrame.new(arg.Position.X, 12, arg.Position.Z)
                end

                arg.AssemblyLinearVelocity = Vector3.zero
                arg.AssemblyAngularVelocity = Vector3.zero
                return true
              end

              _G._greenduelsTPBatDeathCleanup = function(arg)
                tbl18._tpInProgress = false
                pcall(fn83)

                if arg then
                  arg.Anchored = false
                  arg.AssemblyLinearVelocity = Vector3.zero
                  arg.AssemblyAngularVelocity = Vector3.zero

                  if sethiddenproperty then
                    pcall(sethiddenproperty, arg, "PhysicsRepRootPart", nil)
                  end
                end
              end

              fn63 = function()
                tbl18.tpBatVersion = "V1"

                if fn69() and tbl18.tpBatMode ~= "AntiHit" then
                  tbl18.aimbot2Toggled = false

                  if tbl24.aimbot2 then
                    tbl24.aimbot2.setOn(false)
                  end

                  if tbl24.aimbot then
                    tbl24.aimbot.setOn(false)
                  end

                  return
                end

                tbl18.aimbot2Toggled = true

                if tbl20.aimbot2 then
                  tbl20.aimbot2:Disconnect()
                end

                if tbl18.autoLeftEnabled then
                  tbl18.autoLeftEnabled = false

                  if fn54 then
                    fn54()
                  end

                  if tbl24.autoLeft then
                    tbl24.autoLeft.setOn(false)
                  end

                  if fn47 then
                    pcall(fn47, false)
                  end
                end

                if tbl18.autoRightEnabled then
                  tbl18.autoRightEnabled = false

                  if fn56 then
                    fn56()
                  end

                  if tbl24.autoRight then
                    tbl24.autoRight.setOn(false)
                  end

                  if fn48 then
                    pcall(fn48, false)
                  end
                end

                if tbl18.batAimbotToggled then
                  tbl18.batAimbotToggled = false

                  if fn60 then
                    fn60()
                  end

                  if tbl24.aimbot then
                    tbl24.aimbot.setOn(tbl18.tpBatMode == "AntiHit")
                  end

                  if toggleSetters.aimbot and not tbl18.autoBatBypass then
                    pcall(toggleSetters.aimbot, false)
                  end
                end

                fn103()
                local character = localPlayer.Character
                local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                character = character and character:FindFirstChild("HumanoidRootPart")

                if tbl18.tpBatMode == "Teleport" then
                  fn116(character, humanoid2)

                  tbl20.aimbot2 = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                    if not tbl18.aimbot2Toggled then
                      fn64()
                      return
                    end

                    pcall(function()
                      if fn69() and tbl18.tpBatMode ~= "AntiHit" then
                        tbl18.aimbot2Toggled = false
                        fn64()

                        if tbl24.aimbot2 then
                          tbl24.aimbot2.setOn(false)
                        end

                        if tbl24.aimbot then
                          tbl24.aimbot.setOn(false)
                        end

                        return
                      end

                      local character2 = localPlayer.Character
                      local humanoid3 = character2 and character2:FindFirstChildOfClass("Humanoid")
                      local humanoidRootPart = character2
                        and character2:FindFirstChild("HumanoidRootPart")
                      if not (tbl18.aimbot2Toggled and humanoid3 and humanoidRootPart) then
                        return
                      end
                      v84 = humanoidRootPart
                      humanoid = humanoid3
                      fn116(humanoidRootPart, humanoid3)
                      if tbl18.tpBatVersion ~= "V2" and fn117(humanoidRootPart) then
                        return
                      end
                      local v88 = fn115()

                      if v88 and v88.Character then
                        local v89 = v88.Character:FindFirstChild("HumanoidRootPart")

                        if v89 then
                          if tbl18.tpBatVersion ~= "V2" then
                            if v89.Position.Y < -27 then
                              fn117(humanoidRootPart)
                              return
                            end
                            local n35 = v89.Position + Vector3.new(0, 0.9, 0)
                            if n35.Y < -27 then
                              fn117(humanoidRootPart)
                              return
                            end

                            if sethiddenproperty then
                              pcall(function()
                                sethiddenproperty(humanoidRootPart, "PhysicsRepRootPart", v89)
                              end)
                            end

                            if (humanoidRootPart.Position - n35).Magnitude > 8 then
                              humanoidRootPart.CFrame = CFrame.new(n35)
                            end

                            local currentCamera = workspace.CurrentCamera

                            if currentCamera then
                              currentCamera.CFrame =
                                CFrame.new(currentCamera.CFrame.Position, v89.Position)
                            end

                            fn114()
                            return
                          end

                          local n35 = v89.Position + Vector3.new(0, 0.9, 0)
                          local cframe = CFrame.new(n35)
                          local cframe2 = CFrame.new(v89.Position + Vector3.new(0, 1.2, 0))
                          local flag25 = humanoidRootPart.Position.Y < -35
                          local humanoid4 = v88.Character:FindFirstChildOfClass("Humanoid")
                          local flag26

                          if flag25 then
                            flag26 = not humanoid4 or humanoid4.Health <= 0

                            if not flag26 then
                              local dead = Enum.HumanoidStateType.Dead
                              flag26 = humanoid4:GetState() == dead
                            end

                            flag26 = flag26 or v88.Character:FindFirstChildOfClass("ForceField")
                          else
                            flag26 = flag25
                          end

                          if flag26 then
                            if sethiddenproperty then
                              pcall(sethiddenproperty, humanoidRootPart, "PhysicsRepRootPart", nil)
                            end

                            local tpBatLastVoidTargetCF = tbl18._tpBatLastVoidTargetCF

                            if tpBatLastVoidTargetCF then
                              tpBatLastVoidTargetCF = tick() - (tbl18._tpBatLastVoidTargetAt or 0)
                                < 2.5
                            end

                            if tpBatLastVoidTargetCF then
                              if fn117(humanoidRootPart, tbl18._tpBatLastVoidTargetCF) then
                                return
                              end
                              humanoidRootPart.CFrame = tbl18._tpBatLastVoidTargetCF
                              humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                            end

                            return
                          end

                          if tbl18.tpBatVersion == "V2" and (flag25 or v89.Position.Y < -27) then
                            tbl18._tpBatV2Now = tick()

                            if
                              tbl18._tpBatV2PrevY
                              and math.abs(v89.Position.Y - tbl18._tpBatV2PrevY) > 4
                            then
                              tbl18._tpBatV2HoldUntil = tbl18._tpBatV2Now + 0.48
                            end

                            tbl18._tpBatV2PrevY = v89.Position.Y

                            if
                              tbl18._tpBatV2HoldUntil
                              and tbl18._tpBatV2Now < tbl18._tpBatV2HoldUntil
                            then
                              if sethiddenproperty then
                                pcall(
                                  sethiddenproperty,
                                  humanoidRootPart,
                                  "PhysicsRepRootPart",
                                  nil
                                )
                              end

                              if
                                tbl18._tpBatLastVoidTargetCF
                                and fn117(humanoidRootPart, tbl18._tpBatLastVoidTargetCF)
                              then
                                fn114()
                                return
                              end
                              flag25 = flag25 and tbl18._tpBatLastVoidTargetCF

                              if flag25 then
                                humanoidRootPart.CFrame = tbl18._tpBatLastVoidTargetCF
                                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                fn114()
                              end

                              return
                            end

                            local tpBatLastVoidRawY = tbl18._tpBatLastVoidRawY
                            local flag27

                            if tpBatLastVoidRawY then
                              local flag28 = math.abs(v89.Position.Y - tbl18._tpBatLastVoidRawY) > 8

                              if not flag28 then
                                local v90 = 200
                                flag28 = math.abs(v89.AssemblyLinearVelocity.Y) > v90
                              end

                              flag27 = flag28 or v89.Position.Y < -115 or v89.Position.Y > 0
                            else
                              flag27 = tpBatLastVoidRawY
                            end

                            if flag27 then
                              tbl18._tpBatV2HoldUntil = tbl18._tpBatV2Now + 0.48

                              if sethiddenproperty then
                                pcall(
                                  sethiddenproperty,
                                  humanoidRootPart,
                                  "PhysicsRepRootPart",
                                  nil
                                )
                              end

                              local tpBatLastVoidTargetCF = tbl18._tpBatLastVoidTargetCF

                              if tpBatLastVoidTargetCF then
                                tpBatLastVoidTargetCF = tick() - (tbl18._tpBatLastVoidTargetAt or 0)
                                  < 2.5
                              end

                              if tpBatLastVoidTargetCF then
                                if fn117(humanoidRootPart, tbl18._tpBatLastVoidTargetCF) then
                                  fn114()
                                  return
                                end

                                if flag25 then
                                  humanoidRootPart.CFrame = tbl18._tpBatLastVoidTargetCF
                                  humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                  fn114()
                                end
                              end

                              return
                            end

                            if
                              v89.Position.Y < -27
                              and v89.Position.Y > -115
                              and math.abs(v89.AssemblyLinearVelocity.Y) < 45
                            then
                              tbl18._tpBatLastVoidRawY = v89.Position.Y
                            end
                          end

                          if
                            tbl18.tpBatVersion == "V2"
                            and v89.Position.Y < -27
                            and v89.Position.Y > -115
                            and math.abs(v89.AssemblyLinearVelocity.Y) < 60
                          then
                            tbl18._tpBatLastTargetCF = cframe2
                            tbl18._tpBatLastVoidTargetCF = cframe2
                            tbl18._tpBatLastTargetAt = tick()
                            tbl18._tpBatLastVoidTargetAt = tick()
                          else
                            if
                              tbl18.tpBatVersion == "V2"
                              and flag25
                              and (
                                v89.Position.Y >= -27
                                or v89.Position.Y < -115
                                or math.abs(v89.AssemblyLinearVelocity.Y) >= 60
                                or tbl18._tpBatLastVoidTargetCF
                                  and math.abs(
                                    v89.Position.Y - tbl18._tpBatLastVoidTargetCF.Position.Y
                                  ) > 12
                              )
                            then
                              if sethiddenproperty then
                                pcall(
                                  sethiddenproperty,
                                  humanoidRootPart,
                                  "PhysicsRepRootPart",
                                  nil
                                )
                              end

                              local tpBatLastVoidTargetCF = tbl18._tpBatLastVoidTargetCF

                              if tpBatLastVoidTargetCF then
                                tpBatLastVoidTargetCF = tick() - (tbl18._tpBatLastVoidTargetAt or 0)
                                  < 2.5
                              end

                              if tpBatLastVoidTargetCF then
                                if fn117(humanoidRootPart, tbl18._tpBatLastVoidTargetCF) then
                                  return
                                end
                                humanoidRootPart.CFrame = tbl18._tpBatLastVoidTargetCF
                                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                              end

                              return
                            end

                            if
                              tbl18.tpBatVersion == "V2"
                              and (v89.Position.Y > 0 or v89.Position.Y < -115)
                            then
                              if sethiddenproperty then
                                pcall(
                                  sethiddenproperty,
                                  humanoidRootPart,
                                  "PhysicsRepRootPart",
                                  nil
                                )
                              end

                              local tpBatLastVoidTargetCF = tbl18._tpBatLastVoidTargetCF

                              if tpBatLastVoidTargetCF then
                                tpBatLastVoidTargetCF = tick()
                                    - (tbl18._tpBatLastVoidTargetAt or 0)
                                  < 2.5
                              end

                              if tpBatLastVoidTargetCF then
                                if fn117(humanoidRootPart, tbl18._tpBatLastVoidTargetCF) then
                                  return
                                end
                                humanoidRootPart.CFrame = tbl18._tpBatLastVoidTargetCF
                                humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                              end

                              return
                            end

                            if tbl18.tpBatVersion == "V2" then
                              tbl18._tpBatLastTargetCF = cframe2
                              tbl18._tpBatLastTargetAt = tick()
                            end
                          end

                          if sethiddenproperty then
                            if tbl18.tpBatVersion == "V2" and v89.Position.Y < -27 then
                              pcall(sethiddenproperty, humanoidRootPart, "PhysicsRepRootPart", nil)
                            else
                              sethiddenproperty(humanoidRootPart, "PhysicsRepRootPart", v89)
                            end
                          end

                          if
                            fn117(humanoidRootPart, tbl18.tpBatVersion == "V2" and cframe2 or nil)
                          then
                            fn114()

                            if tbl18.tpBatVersion == "V2" then
                              task.delay(0.09, function()
                                if tbl18.aimbot2Toggled then
                                  fn114()
                                end
                              end)
                            end

                            return
                          end

                          if 40 < (humanoidRootPart.Position - n35).Magnitude then
                            humanoidRootPart.CFrame = cframe
                          end

                          if workspace.CurrentCamera then
                            workspace.CurrentCamera.CFrame =
                              CFrame.new(workspace.CurrentCamera.CFrame.Position, v89.Position)
                          end

                          fn114()
                          fn117(humanoidRootPart)
                        end
                      end
                    end)
                  end))
                else
                  tbl20.aimbot2 = greenduelsPerfRun.track(service.Heartbeat:Connect(fn112))
                end

                if tbl24.aimbot2 then
                  tbl24.aimbot2.setOn(tbl18.tpBatMode == "Teleport")
                end

                requestSave()
              end

              fn64 = function()
                tbl18.aimbot2Toggled = false

                if tbl24.aimbot2 then
                  tbl24.aimbot2.setOn(false)
                end

                tbl18._tpInProgress = false

                if tbl20.aimbot2 then
                  tbl20.aimbot2:Disconnect()
                  tbl20.aimbot2 = nil
                end

                fn83()
                local character = localPlayer.Character

                if character then
                  character:FindFirstChild("HumanoidRootPart")
                end

                character = character and character:FindFirstChildOfClass("Humanoid")

                if character then
                  character.AutoRotate = true
                end

                flag24 = false
                fn104()
                requestSave()
              end
            end

            for i, v87 in ipairs(tbl21) do
              local textButton3 = Instance.new("TextButton", screenGui)
              textButton3.Name = "StackBtn_" .. v87.key
              textButton3.Size = UDim2.new(
                0,
                math.floor(58 * (tbl18.mobileButtonScale or 1) + 0.5),
                0,
                math.floor(58 * (tbl18.mobileButtonScale or 1) + 0.5)
              )
              textButton3.Position = fn44(i)
              textButton3.BackgroundColor3 = tbl27.stackBg
              textButton3.BorderSizePixel = 0
              textButton3.AutoButtonColor = false
              textButton3.Text = v87.label
              textButton3.TextColor3 = tbl27.stackTxt
              textButton3.TextScaled = false
              textButton3.TextSize =
                math.clamp(math.floor(11 * (tbl18.mobileButtonScale or 1) + 0.5), 8, 18)
              textButton3.Font = Enum.Font.GothamBold
              textButton3.TextWrapped = true
              textButton3.LineHeight = 1.2
              textButton3.ZIndex = 15

              fn71(textButton3, 12)
              local v88 = createUIStroke(textButton3, tbl27.stackBrd, 1)
              tbl25[v87.key] = textButton3
              local v89 = false

              local function fn103(arg)
                v89 = arg

                TweenService
                  :Create(textButton3, TweenInfo.new(0), {
                    BackgroundColor3 = arg and tbl27.stackActBg or tbl27.stackBg,
                    TextColor3 = arg and tbl27.stackActTxt or tbl27.stackTxt,
                  })
                  :Play()

                TweenService:Create(
                  v88,
                  TweenInfo.new(0.15),
                  { Color = arg and tbl27.stackActBrd or tbl27.stackBrd }
                ):Play()
              end

              tbl24[v87.key] = { setOn = fn103 }

              fn89(textButton3, function()
                if v87.key == "tpDown" then
                  task.spawn(function()
                    if fn73 then
                      pcall(fn73)
                    end

                    fn103(true)
                    task.wait(0.12)
                    fn103(false)
                  end)

                  return
                end

                if v87.key == "drop" then
                  task.spawn(function()
                    pcall(v86)
                  end)

                  return
                end

                if v87.key == "reset" then
                  task.spawn(function()
                    fn103(true)
                    pcall(greenduelsInstantReset, "button")
                    task.wait(0.18)
                    fn103(false)
                  end)

                  return
                end

                if v87.key == "carrySpeed" then
                  if tbl18.laggerMode ~= 0 then
                    tbl18.laggerMode = 0
                    tbl18.speedToggled = true
                    _G.greenduelsManualNormalSpeed = false
                    fn103(true)
                    fn99()

                    if _G._refreshSpeedModeUI then
                      _G._refreshSpeedModeUI()
                    end

                    requestSave()
                    return
                  end

                  tbl18.speedToggled = not tbl18.speedToggled
                  _G.greenduelsManualNormalSpeed = not tbl18.autoChangeSpeed
                    and not tbl18.speedToggled
                  fn103(tbl18.speedToggled)

                  if _G._refreshSpeedModeUI then
                    _G._refreshSpeedModeUI()
                  end

                  requestSave()
                  return
                end

                if v87.key == "lagger" then
                  if tbl18.laggerMode == 1 then
                    fn100(0)
                  else
                    fn100(1)
                  end

                  return
                end

                if v87.key == "laggerCarry" then
                  if tbl18.laggerMode == 2 then
                    fn100(0)
                  else
                    fn100(2)
                  end

                  return
                end

                if v87.key == "aimbot2" then
                  local flag22 = not (tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")

                  if flag22 and fn69() then
                    tbl18.aimbot2Toggled = false
                    fn103(false)
                    return
                  end

                  if flag22 then
                    tbl18.tpBatMode = "Teleport"
                    tbl18.aimbot2Toggled = true
                    fn63()
                  else
                    tbl18.aimbot2Toggled = false
                    fn64()
                  end

                  fn103(tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")

                  if tpBatSet then
                    tpBatSet.setOn(tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")
                  end

                  if modeAimbot then
                    _applyBatModeText()
                  end

                  requestSave()
                  return
                end

                local autoLeftEnabled_ = not v89

                if v87.key ~= "aimbot" then
                  fn103(autoLeftEnabled_)
                end

                local flag22 = autoLeftEnabled_ and fn69()

                if flag22 then
                  flag22 = v87.key == "autoLeft"
                    or v87.key == "autoRight"
                    or v87.key == "aimbot" and not tbl18.autoBatBypass
                    or v87.key == "aimbot2"
                end

                if flag22 then
                  fn103(false)
                  return
                end

                if v87.key == "autoLeft" then
                  tbl18.autoLeftEnabled = autoLeftEnabled_

                  if autoLeftEnabled_ then
                    fn53()
                  else
                    fn54()
                  end
                elseif v87.key == "autoRight" then
                  tbl18.autoRightEnabled = autoLeftEnabled_

                  if autoLeftEnabled_ then
                    fn55()
                  else
                    fn56()
                  end
                elseif v87.key == "aimbot" then
                  if tbl18.autoBatBypass then
                    tbl18.tpBatMode = "AntiHit"
                    tbl18.aimbot2Toggled = autoLeftEnabled_

                    if autoLeftEnabled_ then
                      fn63()
                    else
                      fn64()
                    end

                    fn103(tbl18.aimbot2Toggled and tbl18.tpBatMode == "AntiHit")
                  else
                    tbl18.batAimbotToggled = autoLeftEnabled_

                    if autoLeftEnabled_ then
                      pcall(fn59)
                    else
                      fn60()
                    end

                    fn103(tbl18.batAimbotToggled)
                  end

                  if modeAimbot then
                    _applyBatModeText()
                  end

                  requestSave()
                end
              end)

              if i % 3 == 0 then
                task.wait()
              end
            end

            fn47 = function(arg)
              if tbl24.autoLeft then
                tbl24.autoLeft.setOn(arg)
              end
            end

            fn48 = function(arg)
              if tbl24.autoRight then
                tbl24.autoRight.setOn(arg)
              end
            end

            do
              local vector = Vector3.new(-476.47, -6.28, 92.73)
              local vector2 = Vector3.new(-483.12, -4.95, 94.81)
              local vector3 = Vector3.new(-476.16, -6.52, 25.62)
              local vector4 = Vector3.new(-483.06, -5.03, 25.48)
              local n34 = 1
              local n35 = 1

              local function greenduelsGetAutoPathSpeed()
                if tbl18.laggerMode ~= 0 then
                  return math.clamp(tonumber(tbl18.laggerSpeed) or 0, 0, 500)
                end
                return math.clamp(tonumber(tbl18.normalSpeed) or 0, 0, 500)
              end

              _G.greenduelsGetAutoPathSpeed = greenduelsGetAutoPathSpeed

              fn54 = function()
                if tbl20.autoLeft then
                  tbl20.autoLeft:Disconnect()
                  tbl20.autoLeft = nil
                end

                n34 = 1
                local character = localPlayer.Character

                if character then
                  local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                  local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

                  if humanoid2 then
                    humanoid2:Move(Vector3.zero, false)
                  end

                  if humanoidRootPart then
                    humanoidRootPart.AssemblyLinearVelocity =
                      Vector3.new(0, humanoidRootPart.AssemblyLinearVelocity.Y, 0)
                  end
                end

                tbl18.autoLeftEnabled = false

                if fn47 then
                  pcall(fn47, false)
                end
              end

              fn56 = function()
                if tbl20.autoRight then
                  tbl20.autoRight:Disconnect()
                  tbl20.autoRight = nil
                end

                n35 = 1
                local character = localPlayer.Character

                if character then
                  local v87 = character:FindFirstChildOfClass("Humanoid")
                  local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

                  if v87 then
                    v87:Move(Vector3.zero, false)
                  end

                  if humanoidRootPart then
                    humanoidRootPart.AssemblyLinearVelocity =
                      Vector3.new(0, humanoidRootPart.AssemblyLinearVelocity.Y, 0)
                  end
                end

                tbl18.autoRightEnabled = false

                if fn48 then
                  pcall(fn48, false)
                end
              end

              fn53 = function()
                if fn69() then
                  tbl18.autoLeftEnabled = false

                  if fn47 then
                    pcall(fn47, false)
                  end

                  return
                end

                if tbl20.autoLeft then
                  tbl20.autoLeft:Disconnect()
                end

                n34 = 1
                tbl18.autoLeftEnabled = true

                if fn47 then
                  pcall(fn47, true)
                end

                local function fn103()
                  if not tbl18.autoLeftEnabled then
                    return
                  end

                  if tbl18.safetyLocked then
                    return
                  end
                  local character = localPlayer.Character
                  if not character then
                    return
                  end
                  local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                  local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                  if not humanoidRootPart or not humanoid2 then
                    return
                  end
                  local state = humanoid2:GetState()
                  if
                    humanoid2.PlatformStand
                    or state == Enum.HumanoidStateType.Physics
                    or state == Enum.HumanoidStateType.Ragdoll
                    or state == Enum.HumanoidStateType.FallingDown
                  then
                    return
                  end
                  local v87 = greenduelsGetAutoPathSpeed()

                  if n34 == 1 then
                    local position = humanoidRootPart.Position
                    if
                      (Vector3.new(vector.X, humanoidRootPart.Position.Y, vector.Z) - position).Magnitude
                      < 1
                    then
                      n34 = 2
                      return
                    end
                    local n36 = vector - humanoidRootPart.Position
                    local unit = Vector3.new(n36.X, 0, n36.Z).Unit
                    humanoid2:Move(unit, false)
                    humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                      unit.X * v87,
                      humanoidRootPart.AssemblyLinearVelocity.Y,
                      unit.Z * v87
                    )
                  elseif n34 == 2 then
                    local position = humanoidRootPart.Position

                    if
                      (Vector3.new(vector2.X, humanoidRootPart.Position.Y, vector2.Z) - position).Magnitude
                      < 1
                    then
                      humanoid2:Move(Vector3.zero, false)
                      humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                      tbl18.autoLeftEnabled = false
                      fn54()
                      return
                    end

                    local n36 = vector2 - humanoidRootPart.Position
                    local unit = Vector3.new(n36.X, 0, n36.Z).Unit
                    humanoid2:Move(unit, false)
                    humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                      unit.X * v87,
                      humanoidRootPart.AssemblyLinearVelocity.Y,
                      unit.Z * v87
                    )
                  end
                end

                fn103()
                tbl20.autoLeft = greenduelsPerfRun.track(service.Heartbeat:Connect(fn103))
              end

              fn55 = function()
                if fn69() then
                  tbl18.autoRightEnabled = false

                  if fn48 then
                    pcall(fn48, false)
                  end

                  return
                end

                if tbl20.autoRight then
                  tbl20.autoRight:Disconnect()
                end

                n35 = 1
                tbl18.autoRightEnabled = true

                if fn48 then
                  pcall(fn48, true)
                end

                local function fn103()
                  if not tbl18.autoRightEnabled then
                    return
                  end

                  if not tbl18.safetyLocked then
                    local character = localPlayer.Character
                    if not character then
                      return
                    end
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid2 = character:FindFirstChildOfClass("Humanoid")
                    if not humanoidRootPart or not humanoid2 then
                      return
                    end
                    local state = humanoid2:GetState()
                    if
                      humanoid2.PlatformStand
                      or state == Enum.HumanoidStateType.Physics
                      or state == Enum.HumanoidStateType.Ragdoll
                      or state == Enum.HumanoidStateType.FallingDown
                    then
                      return
                    end
                    local v87 = greenduelsGetAutoPathSpeed()

                    if n35 == 1 then
                      local position = humanoidRootPart.Position
                      if
                        (Vector3.new(vector3.X, humanoidRootPart.Position.Y, vector3.Z) - position).Magnitude
                        < 1
                      then
                        n35 = 2
                        return
                      end
                      local n36 = vector3 - humanoidRootPart.Position
                      local unit = Vector3.new(n36.X, 0, n36.Z).Unit
                      humanoid2:Move(unit, false)
                      humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        unit.X * v87,
                        humanoidRootPart.AssemblyLinearVelocity.Y,
                        unit.Z * v87
                      )
                    elseif n35 == 2 then
                      local position = humanoidRootPart.Position

                      if
                        (Vector3.new(vector4.X, humanoidRootPart.Position.Y, vector4.Z) - position).Magnitude
                        < 1
                      then
                        humanoid2:Move(Vector3.zero, false)
                        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        tbl18.autoRightEnabled = false
                        fn56()
                        return
                      end

                      local n36 = vector4 - humanoidRootPart.Position
                      local unit = Vector3.new(n36.X, 0, n36.Z).Unit
                      humanoid2:Move(unit, false)
                      humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        unit.X * v87,
                        humanoidRootPart.AssemblyLinearVelocity.Y,
                        unit.Z * v87
                      )
                    end

                    return
                  end

                  return
                end

                fn103()
                tbl20.autoRight = greenduelsPerfRun.track(service.Heartbeat:Connect(fn103))
              end
            end

            local greenduelsFunctions, flag22

            do
              local tbl30 = {
                "Bat",
                "Slap",
                "Iron Slap",
                "Gold Slap",
                "Diamond Slap",
                "Emerald Slap",
                "Ruby Slap",
                "Dark Matter Slap",
                "Flame Slap",
                "Nuclear Slap",
                "Galaxy Slap",
                "Glitched Slap",
              }

              greenduelsFunctions = _G.greenduelsFunctions or {}
              _G.greenduelsFunctions = greenduelsFunctions
              local flag23 = false
              flag22 = false

              greenduelsFunctions.applyKickWarningKiraTheme = function()
                local kickWarningRoot = greenduelsFunctions._kickWarningRoot
                if not kickWarningRoot then
                  return
                end
                kickWarningRoot.BackgroundColor3 = tbl27.winBg
                local uiStroke = kickWarningRoot:FindFirstChildOfClass("UIStroke")

                if uiStroke then
                  uiStroke.Color = tbl27.winBorder
                end

                local track = kickWarningRoot:FindFirstChild("Track")

                if track then
                  track.BackgroundColor3 = tbl27.rowBg
                end

                if greenduelsFunctions._kickWarningFill then
                  greenduelsFunctions._kickWarningFill.BackgroundColor3 = tbl27.sectionTxt
                end

                if greenduelsFunctions._kickWarningLabel then
                  greenduelsFunctions._kickWarningLabel.TextColor3 = tbl27.sectionTxt
                end
              end

              greenduelsFunctions.hideKickWarningBar = function()
                greenduelsFunctions._kickWarningToken = (greenduelsFunctions._kickWarningToken or 0)
                  + 1
                local kickWarningToken = greenduelsFunctions._kickWarningToken
                local kickWarningRoot = greenduelsFunctions._kickWarningRoot

                if kickWarningRoot and kickWarningRoot.Parent then
                  TweenService
                    :Create(
                      kickWarningRoot,
                      TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                      { Position = UDim2.new(0.5, 0, 0, -36) }
                    )
                    :Play()
                end

                task.delay(0.18, function()
                  if
                    kickWarningToken == greenduelsFunctions._kickWarningToken
                    and kickWarningRoot
                    and kickWarningRoot.Parent
                  then
                    kickWarningRoot.Visible = false
                  end
                end)
              end

              greenduelsFunctions.showKickWarningBar = function()
                if not tbl18.kickWarningEnabled then
                  return
                end
                local kickWarningDropSuppressUntil =
                  greenduelsFunctions._kickWarningDropSuppressUntil

                if kickWarningDropSuppressUntil then
                  local kickWarningDropSuppressUntil2 =
                    greenduelsFunctions._kickWarningDropSuppressUntil
                  kickWarningDropSuppressUntil = tick() < kickWarningDropSuppressUntil2
                end

                if kickWarningDropSuppressUntil then
                  return
                end
                greenduelsFunctions._kickWarningToken = (
                  greenduelsFunctions._kickWarningToken or 0
                ) + 1
                local kickWarningToken = greenduelsFunctions._kickWarningToken
                local playerGui = localPlayer:FindFirstChild("PlayerGui")

                if
                  not (
                    greenduelsFunctions._kickWarningGui
                    and greenduelsFunctions._kickWarningGui.Parent
                  )
                then
                  local screenGui2 = Instance.new("ScreenGui")
                  screenGui2.Name = "greenduelsKickWarning"
                  screenGui2.ResetOnSpawn = false
                  screenGui2.DisplayOrder = 100000
                  screenGui2.IgnoreGuiInset = true
                  screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

                  pcall(function()
                    screenGui2.Parent = game:GetService("CoreGui")
                  end)

                  if not screenGui2.Parent and playerGui then
                    screenGui2.Parent = playerGui
                  end

                  local instance2 = Instance.new("Frame", screenGui2)
                  instance2.Name = "Root"
                  instance2.AnchorPoint = Vector2.new(0.5, 0)
                  instance2.Size = UDim2.new(0, 320, 0, 44)
                  instance2.Position = UDim2.new(0.5, 0, 0, -36)
                  instance2.BackgroundColor3 = tbl27.winBg
                  instance2.BorderSizePixel = 0
                  instance2.ClipsDescendants = true

                  fn71(instance2, 10)
                  createUIStroke(instance2, tbl27.winBorder, 1.5)

                  local textLabel4 = Instance.new("TextLabel", instance2)
                  textLabel4.Name = "Label"
                  textLabel4.Size = UDim2.new(1, 0, 0, 56)
                  textLabel4.Position = UDim2.new(0, 0, 0, 2)
                  textLabel4.BackgroundTransparency = 1
                  textLabel4.Text = "KICK WARNING (DONT STEAL) 2.3s"
                  textLabel4.TextColor3 = tbl27.sectionTxt
                  textLabel4.Font = Enum.Font.GothamBlack
                  textLabel4.TextSize = 14
                  textLabel4.TextXAlignment = Enum.TextXAlignment.Center
                  textLabel4.ZIndex = 3

                  local instance3 = Instance.new("Frame", instance2)
                  instance3.Name = "Track"
                  instance3.Size = UDim2.new(1, -24, 0, 8)
                  instance3.Position = UDim2.new(0, 12, 1, -14)
                  instance3.BackgroundColor3 = tbl27.rowBg
                  instance3.BorderSizePixel = 0

                  fn71(instance3, 4)

                  local frame7 = Instance.new("Frame", instance3)
                  frame7.Name = "Fill"
                  frame7.Size = UDim2.new(1, 0, 1, 0)
                  frame7.BackgroundColor3 = tbl27.sectionTxt
                  frame7.BorderSizePixel = 0

                  fn71(frame7, 4)
                  greenduelsFunctions._kickWarningGui = screenGui2
                  greenduelsFunctions._kickWarningRoot = instance2
                  greenduelsFunctions._kickWarningFill = frame7
                  greenduelsFunctions._kickWarningLabel = textLabel4
                end

                local kickWarningRoot = greenduelsFunctions._kickWarningRoot
                local kickWarningFill = greenduelsFunctions._kickWarningFill
                local kickWarningLabel = greenduelsFunctions._kickWarningLabel
                if not (kickWarningRoot and kickWarningFill and kickWarningLabel) then
                  return
                end

                if greenduelsFunctions.applyKickWarningKiraTheme then
                  greenduelsFunctions.applyKickWarningKiraTheme()
                end

                kickWarningRoot.Visible = true
                kickWarningRoot.Position = UDim2.new(0.5, 0, 0, -36)
                kickWarningFill.Size = UDim2.new(1, 0, 1, 0)
                TweenService
                  :Create(
                    kickWarningRoot,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { Position = UDim2.new(0.5, 0, 0, 10) }
                  )
                  :Play()

                task.spawn(function()
                  local now2 = tick()

                  while true do
                    if
                      kickWarningToken == greenduelsFunctions._kickWarningToken
                      and kickWarningRoot
                      and kickWarningRoot.Parent
                    then
                      local n34 = math.max(0, 2.3 - tick() - now2)
                      kickWarningLabel.Text = string.format("KICK WARNING (DONT STEAL) %.1fs", n34)
                      kickWarningFill.Size = UDim2.new(n34 / 2.3, 0, 1, 0)
                      if not (n34 <= 0) then
                        service.RenderStepped:Wait()
                        continue
                      end
                    end

                    break
                  end

                  if
                    kickWarningToken == greenduelsFunctions._kickWarningToken
                    and kickWarningRoot
                    and kickWarningRoot.Parent
                  then
                    TweenService
                      :Create(
                        kickWarningRoot,
                        TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        { Position = UDim2.new(0.5, 0, 0, -58) }
                      )
                      :Play()
                  end
                end)
              end

              task.spawn(function()
                while screenGui and screenGui.Parent do
                  local v87 = false

                  pcall(function()
                    v87 = fn32 and fn32(true) or fn31()
                  end)

                  if tbl18.kickWarningEnabled and v87 and not flag23 then
                    pcall(greenduelsFunctions.showKickWarningBar)
                  elseif flag23 and not v87 and greenduelsFunctions.hideKickWarningBar then
                    pcall(greenduelsFunctions.hideKickWarningBar)
                  end

                  flag23 = v87
                  task.wait(0.05)
                end
              end)

              _G.AutoCarrySpeed = _G.AutoCarrySpeed or {}

              _G.AutoCarrySpeed.WatchPickup = function(arg)
                _autoCarryV2.watchUntil = tick() + (tonumber(arg) or 1.25)
                _autoCarryV2.armed = true
                flag22 = true

                if
                  tbl18
                  and tbl18.kickWarningEnabled
                  and greenduelsFunctions
                  and greenduelsFunctions.showKickWarningBar
                then
                  pcall(greenduelsFunctions.showKickWarningBar)
                end

                task.delay(tonumber(arg) or 1.25, function()
                  flag22 = false
                end)
              end

              local function fn103()
                local character = localPlayer.Character
                if not character then
                  return nil
                end
                local v87 = localPlayer:FindFirstChildOfClass("Backpack")

                for _, v88 in ipairs(tbl30) do
                  local v89 = character:FindFirstChild(v88) or v87 and v87:FindFirstChild(v88)
                  if v89 then
                    return v89
                  end
                end

                for _, child in ipairs(character:GetChildren()) do
                  if child:IsA("Tool") and child.Name:lower():find("bat") then
                    return child
                  end
                end

                if v87 then
                  for _, child in ipairs(v87:GetChildren()) do
                    if child:IsA("Tool") and child.Name:lower():find("bat") then
                      return child
                    end
                  end
                end

                return nil
              end

              local n34 = 0
              local flag24 = false

              local function fn104(arg)
                local huge = math.huge
                local v87 = nil

                for _, player in ipairs(Players:GetPlayers()) do
                  if player ~= localPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid2 = player.Character:FindFirstChildOfClass("Humanoid")

                    if humanoidRootPart and humanoid2 and humanoid2.Health > 0 then
                      local magnitude = (humanoidRootPart.Position - arg).Magnitude

                      if magnitude < huge then
                        huge = magnitude
                        v87 = player
                      end
                    end
                  end
                end

                return v87
              end

              local function fn105()
                if not tbl18.batCounterEnabled or tbl18.batCounterDebounce then
                  return
                end
                local now2 = os.clock()
                if now2 - n34 < 0.5 then
                  return
                end
                tbl18.batCounterDebounce = true
                n34 = now2

                task.spawn(function()
                  local character = localPlayer.Character
                  local humanoidRootPart = character
                    and character:FindFirstChild("HumanoidRootPart")
                  local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                  if not character or not humanoidRootPart or not humanoid2 then
                    tbl18.batCounterDebounce = false
                    return
                  end
                  local v87 = fn104(humanoidRootPart.Position)
                  if not v87 then
                    tbl18.batCounterDebounce = false
                    return
                  end
                  local v88 = fn103()

                  if v88 then
                    if v88.Parent ~= character then
                      pcall(function()
                        humanoid2:EquipTool(v88)
                      end)
                    end

                    task.wait(0.2)
                  end

                  local character2 = localPlayer.Character
                  local humanoidRootPart2 = character2
                    and character2:FindFirstChild("HumanoidRootPart")
                  humanoid2 = character2 and character2:FindFirstChildOfClass("Humanoid")
                  local character3 = v87.Character
                  character3 = character3 and character3:FindFirstChild("HumanoidRootPart")
                  if not character2 or not humanoidRootPart2 or not humanoid2 or not character3 then
                    tbl18.batCounterDebounce = false
                    return
                  end
                  humanoid2.AutoRotate = false
                  local position = character3.Position
                  local vector = Vector3.new(position.X, humanoidRootPart2.Position.Y, position.Z)

                  if (vector - humanoidRootPart2.Position).Magnitude > 0.001 then
                    pcall(function()
                      humanoidRootPart2.RotVelocity = Vector3.zero
                      humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
                      humanoidRootPart2.CFrame = CFrame.lookAt(humanoidRootPart2.Position, vector)
                    end)
                  end

                  task.wait(0.03)
                  local v89 = fn103()

                  if v89 and v89.Parent == character2 then
                    pcall(function()
                      v89:Activate()
                      local remoteEvent = v89:FindFirstChildWhichIsA("RemoteEvent")

                      if remoteEvent then
                        remoteEvent:FireServer()
                      end
                    end)
                  end

                  task.wait(0.2)

                  if humanoidRootPart2 and humanoidRootPart2.Parent then
                    humanoidRootPart2.RotVelocity = Vector3.zero
                    humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
                  end

                  if humanoid2 and humanoid2.Parent then
                    humanoid2.AutoRotate = true
                  end

                  tbl18.batCounterDebounce = false
                end)
              end

              fn61 = function()
                tbl18.batCounterEnabled = true
                if tbl20.batCounter then
                  return
                end
                flag24 = false

                tbl20.batCounter = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                  if not tbl18.batCounterEnabled then
                    flag24 = false
                    return
                  end
                  local character = localPlayer.Character
                  local humanoid2 = character and character:FindFirstChildOfClass("Humanoid")
                  if not humanoid2 then
                    flag24 = false
                    return
                  end
                  local physics = Enum.HumanoidStateType.Physics
                  local flag25 = humanoid2:GetState() == physics

                  if flag25 and not flag24 and not tbl18.batCounterDebounce then
                    fn105()
                  end

                  flag24 = flag25
                end))
              end

              fn62 = function()
                tbl18.batCounterEnabled = false
                tbl18.batCounterDebounce = false
                flag24 = false

                if tbl20.batCounter then
                  tbl20.batCounter:Disconnect()
                  tbl20.batCounter = nil
                end
              end
            end

            do
              local n34 = 0

              local function fn103(arg, arg2)
                if not arg then
                  return false
                end
                arg2 = arg2 or 3
                local n35 = 0

                for _, descendant in ipairs(arg:GetDescendants()) do
                  if
                    descendant:IsA("BasePart")
                    and descendant.Anchored
                    and descendant.Transparency == 1
                  then
                    n35 += 1
                    if arg2 <= n35 then
                      return true
                    end
                  end
                end

                return false
              end

              local function fn104(arg)
                if not (arg and arg:IsA("Tool")) then
                  return false
                end
                local str6 = arg.Name:lower()
                return str6:find("medusa") ~= nil
                  or str6:find("head") ~= nil
                  or str6:find("stone") ~= nil
              end

              local function fn105()
                local character = localPlayer.Character
                if not character then
                  return nil
                end

                for _, child in ipairs(character:GetChildren()) do
                  if fn104(child) then
                    return child
                  end
                end

                local v87 = localPlayer:FindFirstChildOfClass("Backpack")

                if v87 then
                  for _, child in ipairs(v87:GetChildren()) do
                    if fn104(child) then
                      return child
                    end
                  end
                end

                return nil
              end

              local function fn106()
                if tbl18.medusaDebounce then
                  return false
                end
                local medusaLastUsed = tbl18.medusaLastUsed
                if os.clock() - medusaLastUsed < 0 then
                  return false
                end
                local character = localPlayer.Character
                if not character then
                  return false
                end
                tbl18.medusaDebounce = true
                local v87 = fn105()
                if not v87 then
                  tbl18.medusaDebounce = false
                  return false
                end

                if v87.Parent ~= character then
                  local v88 = character:FindFirstChildOfClass("Humanoid")

                  if v88 then
                    v88:EquipTool(v87)
                  end
                end

                local ok = pcall(function()
                  v87:Activate()
                end)

                tbl18.medusaLastUsed = os.clock()
                tbl18.medusaDebounce = false
                return ok
              end

              local function fn107(arg)
                return arg:GetPropertyChangedSignal("Anchored"):Connect(function()
                  if not arg.Anchored or arg.Transparency ~= 1 then
                    return
                  end

                  if not tbl18.medusaCounterEnabled then
                    return
                  end
                  local character = localPlayer.Character
                  if not character or not arg:IsDescendantOf(character) then
                    return
                  end

                  if os.clock() - n34 < 1 then
                    return
                  end

                  if not fn103(character) then
                    return
                  end
                  n34 = os.clock()
                  fn106()
                end)
              end

              fn49 = function(arg)
                fn50()
                if not arg or not tbl18.medusaCounterEnabled then
                  return
                end

                for _, descendant in ipairs(arg:GetDescendants()) do
                  if descendant:IsA("BasePart") then
                    table.insert(tbl20.anchor, fn107(descendant))
                  end
                end

                table.insert(
                  tbl20.anchor,
                  arg.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("BasePart") and tbl18.medusaCounterEnabled then
                      table.insert(tbl20.anchor, fn107(descendant))
                    end
                  end)
                )
              end
            end

            fn50 = function()
              for _, v87 in ipairs(tbl20.anchor) do
                pcall(function()
                  v87:Disconnect()
                end)
              end

              tbl20.anchor = {}
              tbl18.medusaDebounce = false
            end

            do
              local flag23 = false
              local n34 = 0
              local str6 = ""
              local now2 = 0
              local stealDuration = tbl22.StealDuration
              local str7 = "idle"
              local n35 = 0
              local n36 = 0
              local str8 = "IDLE"
              local now3 = 0
              local n37 = 0
              local n38 = 0

              local function fn103(arg)
                n36 = math.clamp(tonumber(arg) or 0, 0, 1)
                now3 = tick()
                n37 = tick() + 1.25
              end

              local function fn104()
                str8 = "IDLE"
                n36 = 0
                n37 = 0
                n38 = 0

                if frame4 and textLabel3 then
                  frame4.Size = UDim2.new(0, 0, 1, 0)
                  textLabel3.Text = "0%"
                end
              end

              _G.StealBar = {
                SetProgress = function(arg)
                  str8 = "STEALING"
                  fn103(math.clamp(tonumber(arg) or 0, 0, 1))
                end,
                SetState = function(arg)
                  str8 = arg or str8

                  if arg == "STEALING" then
                    n37 = tick() + 1.25

                    if textLabel2 then
                      textLabel2.TextColor3 = Color3.fromRGB(85, 255, 145)
                    end
                  elseif arg == "READY" then
                    if textLabel3 then
                      textLabel3.Text = "0%"
                      textLabel3.TextColor3 = Color3.fromRGB(235, 235, 235)
                    end
                  elseif textLabel3 then
                    textLabel3.TextColor3 = Color3.fromRGB(150, 150, 150)
                  end
                end,
                Reset = function()
                  fn104()
                end,
              }

              local function fn105()
                local character = localPlayer.Character
                if character then
                  return character:FindFirstChild("HumanoidRootPart")
                    or character:FindFirstChild("UpperTorso")
                    or character:FindFirstChild("Torso")
                end
                return nil
              end

              local function fn106(arg)
                local plots = Workspace:FindFirstChild("Plots")
                if not plots then
                  return false
                end
                local v87 = plots:FindFirstChild(arg)
                if not v87 then
                  return false
                end
                local plotSign = v87:FindFirstChild("PlotSign")

                if plotSign then
                  local yourBase = plotSign:FindFirstChild("YourBase")
                  if yourBase and yourBase:IsA("BillboardGui") then
                    return yourBase.Enabled == true
                  end
                end

                return false
              end

              local function fn107()
                local v87 = fn105()
                if not v87 then
                  return nil, nil
                end
                local plots = Workspace:FindFirstChild("Plots")
                if not plots then
                  return nil, nil
                end
                local huge = math.huge
                local stealRadius = tbl22.StealRadius
                local v88 = nil
                local v89 = nil

                for _, child in ipairs(plots:GetChildren()) do
                  if child:IsA("Model") and not fn106(child.Name) then
                    local animalPodiums = child:FindFirstChild("AnimalPodiums")

                    if animalPodiums then
                      for _, child2 in ipairs(animalPodiums:GetChildren()) do
                        local base = child2:FindFirstChild("Base")
                        base = base and base:FindFirstChild("Spawn")

                        if base then
                          local magnitude = (base.Position - v87.Position).Magnitude

                          if magnitude <= stealRadius and magnitude < huge then
                            local promptAttachment = base:FindFirstChild("PromptAttachment")

                            if promptAttachment then
                              for _, child3 in ipairs(promptAttachment:GetChildren()) do
                                if
                                  child3:IsA("ProximityPrompt")
                                  and child3.ActionText
                                  and child3.ActionText:find("Steal")
                                then
                                  v88 = child3
                                  v89 = base
                                  huge = magnitude
                                end
                              end
                            end

                            if not v88 then
                              for _, descendant in ipairs(base:GetDescendants()) do
                                if
                                  descendant:IsA("ProximityPrompt")
                                  and descendant.ActionText
                                  and descendant.ActionText:find("Steal")
                                then
                                  v88 = descendant
                                  v89 = base
                                  huge = magnitude
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end

                return v88, v89
              end

              local tbl30 = {}
              local v87 = nil

              local function fn108(arg, arg2)
                local n39 = math.clamp(tonumber(arg) or 0, 0, 1)
                n35 = n39
                str8 = arg2 or "STEALING"
                fn103(n39)
                str7 = arg2 or "holding"
                local n40 = n39 * stealDuration
                n34 = tick() - n40
              end

              local function fn109(arg, arg2)
                if flag23 then
                  return
                end

                if not tbl30[arg] then
                  local tbl31 = { hold = {}, trigger = {}, ready = true, label = "Animal" }

                  if getSignalCons then
                    local ok, result = pcall(getSignalCons, arg.PromptButtonHoldBegan)

                    if ok and type(result) == "table" then
                      for _, v88 in ipairs(result) do
                        if v88.Function then
                          table.insert(tbl31.hold, v88.Function)
                        end
                      end
                    end

                    local ok2, result2 = pcall(getSignalCons, arg.Triggered)

                    if ok2 and type(result2) == "table" then
                      for _, v88 in ipairs(result2) do
                        if v88.Function then
                          table.insert(tbl31.trigger, v88.Function)
                        end
                      end
                    end
                  end

                  tbl30[arg] = tbl31
                end

                local v88 = tbl30[arg]
                if not v88.ready then
                  return
                end
                v88.ready = false
                flag23 = true
                tbl18.isStealing = true
                n34 = tick()
                str7 = "holding"
                stealDuration = tbl22.StealDuration or 1.33

                task.spawn(function()
                  local function fn110()
                    flag23 = false
                    tbl18.isStealing = false
                    v88.ready = true
                    str7 = "idle"
                    n35 = 0
                    fn104()
                  end

                  local function fn111()
                    local v89 = fn105()
                    local parent = v89 and arg2 and arg2.Parent

                    if parent then
                      parent = (arg2.Position - v89.Position).Magnitude <= (tbl22.StealRadius or 62)
                    end

                    return parent
                  end

                  local function fn112()
                    local v89 = fn105()
                    local parent = v89 and arg2 and arg2.Parent
                    local flag24

                    if parent then
                      flag24 = (arg2.Position - v89.Position).Magnitude
                        <= (tbl22.StealRange or 4)
                    else
                      flag24 = parent
                    end

                    return flag24
                  end

                  for _, v89 in ipairs(v88.hold) do
                    task.spawn(function()
                      pcall(v89)
                    end)
                  end

                  local stealDuration2 = tbl22.StealDuration or 1.33
                  local pauseProgress = tbl22.PauseProgress or 0.75
                  local n39 = (tbl22.Delay or 8.6) / 1000
                  local now4 = tick()
                  local n40 = stealDuration2 * pauseProgress

                  while flag23 and tbl22.AutoStealEnabled and arg.Parent and tick() - now4 < n40 do
                    if not fn111() then
                      fn110()
                      return
                    end
                    local v89 = 0
                    fn108(
                      math.clamp((tick() - now4) / n40 * pauseProgress, v89, pauseProgress),
                      "STEALING"
                    )
                    task.wait(n39)
                  end

                  if not flag23 or not tbl22.AutoStealEnabled or not arg.Parent or not fn111() then
                    fn110()
                    return
                  end
                  fn108(pauseProgress, "waitingRange")

                  if not fn112() then
                    local n41 = tick() + (tbl22.RangeWait or 1.6)

                    while true do
                      fn108(pauseProgress, "waitingRange")
                      task.wait(n39)
                      if
                        not (
                          not flag23
                          or not tbl22.AutoStealEnabled
                          or not arg.Parent
                          or not fn111()
                          or fn112()
                          or tick() >= n41
                        )
                      then
                        continue
                      end
                      break
                    end

                    if
                      not flag23
                      or not tbl22.AutoStealEnabled
                      or not arg.Parent
                      or not fn111()
                      or not fn112()
                    then
                      fn110()
                      return
                    end
                  end

                  local now5 = tick()
                  local n41 = stealDuration2 * (1 - pauseProgress)

                  while flag23 and tbl22.AutoStealEnabled and arg.Parent and tick() - now5 < n41 do
                    if not fn111() then
                      fn110()
                      return
                    end
                    fn108(
                      pauseProgress + math.clamp((tick() - now5) / n41, 0, 1) * (1 - pauseProgress),
                      "STEALING"
                    )
                    task.wait(n39)
                  end

                  if not flag23 or not tbl22.AutoStealEnabled or not arg.Parent then
                    fn110()
                    return
                  end
                  fn108(1, "STEALING")

                  if type(fireproximityprompt) == "function" then
                    pcall(function()
                      fireproximityprompt(arg, 0)
                    end)
                  else
                    for _, v89 in ipairs(v88.trigger) do
                      task.spawn(function()
                        pcall(v89)
                      end)
                    end
                  end

                  pcall(function()
                    if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
                      _G.AutoCarrySpeed.WatchPickup(tbl22.Stop or 1)
                    end
                  end)

                  str6 = "Stole " .. (v88.label or "Animal")
                  now2 = tick()
                  task.wait(0.05)
                  fn110()
                end)
              end

              local v88 = nil
              local n39 = 0
              local v89 = nil

              local function fn110()
                if v88 then
                  return
                end

                v88 = greenduelsPerfRun.track(service.Heartbeat:Connect(function()
                  if not tbl22.AutoStealEnabled or flag23 then
                    return
                  end
                  local now4 = tick()
                  local v90 = v89

                  if not v90 or not v90.Parent or now4 - n39 > 0.18 then
                    n39 = now4
                    local ok, result, result2 = pcall(fn107)

                    if ok then
                      v89 = result
                      v87 = result2
                      v90 = result
                    end
                  end

                  if v90 and v90.Parent then
                    pcall(fn109, v90, v87)
                  end
                end))
              end

              local function fn111()
                if v88 then
                  v88:Disconnect()
                  v88 = nil
                end

                flag23 = false
                tbl18.isStealing = false
                str7 = "idle"
                n35 = 0
                fn104()
                tbl30 = {}
                v89 = nil
                v87 = nil
              end

              local autoStealMode = tbl18.autoStealMode or "Semi"
              local autoStealEnabled = tbl22.AutoStealEnabled
              local stealRadius = tbl22.StealRadius
              local v90 = service
              _G.AceStealRadii = _G.AceStealRadii or { Normal = 62, Semi = 9 }
              _G.AceStealRadii.Normal = tbl22.StealRadii.Normal or _G.AceStealRadii.Normal or 61
              _G.AceStealRadii.Semi = tbl22.StealRadii.Semi or _G.AceStealRadii.Semi or 85

              _G.__AceSetupSemiAutoSteal = function()
                _G.AceSemiSteal = _G.AceSemiSteal or {}
                local aceSemiSteal = _G.AceSemiSteal

                if aceSemiSteal.conn then
                  pcall(function()
                    aceSemiSteal.conn:Disconnect()
                  end)

                  aceSemiSteal.conn = nil
                end

                aceSemiSteal.enabled = false
                aceSemiSteal.holdMin = 1.3
                aceSemiSteal.holdMax = 1.5
                aceSemiSteal.entryDelay = 0.3
                aceSemiSteal.cooldown = 0.05
                aceSemiSteal.primeRange = 170
                aceSemiSteal.radius = tonumber(stealRadius) or 9
                aceSemiSteal.conn = aceSemiSteal.conn
                aceSemiSteal.scanThread = aceSemiSteal.scanThread
                aceSemiSteal.plotSync = aceSemiSteal.plotSync or { caches = {}, connections = {} }
                aceSemiSteal.animals = aceSemiSteal.animals or {}
                aceSemiSteal.promptCache = aceSemiSteal.promptCache or {}
                aceSemiSteal.internalCache = aceSemiSteal.internalCache or {}
                aceSemiSteal.state = aceSemiSteal.state
                  or {
                    active = false,
                    startTime = 0,
                    phase = "idle",
                    label = "",
                    lastResult = "",
                    lastResultTime = 0,
                  }

                local function fn112(arg, arg2)
                  pcall(function()
                    if _G.StealBar then
                      _G.StealBar.SetState(arg2 or "STEALING")
                      _G.StealBar.SetProgress(math.clamp(tonumber(arg) or 0, 0, 1))
                    end
                  end)
                end

                local function fn113()
                  pcall(function()
                    if _G.StealBar then
                      _G.StealBar.Reset()
                    end
                  end)
                end

                local function fn114()
                  local character = localPlayer.Character

                  if character then
                    character = character:FindFirstChild("HumanoidRootPart")
                      or character:FindFirstChild("UpperTorso")
                  end

                  return character or nil
                end

                local function fn115(arg)
                  if typeof(arg) == "table" then
                    return arg
                  end
                  local tbl31 = {}

                  for match in string.gmatch(tostring(arg), "[^%.]+") do
                    table.insert(tbl31, tonumber(match) or match)
                  end

                  return tbl31
                end

                local function fn116(arg, arg2)
                  local v91, v92, v93 = ipairs(fn115(arg))
                  local v94 = nil
                  local v95 = nil

                  for _, v96 in v91, v92, v93 do
                    local v97 = arg2 and arg2[v96]

                    if v97 then
                      v94 = arg2
                      v95 = v96
                      arg2 = v97
                    else
                      v94 = arg2
                      v95 = v96
                      arg2 = nil
                    end
                  end

                  return arg2, v94, v95
                end

                local function fn117(arg, arg2)
                  local v91 = aceSemiSteal.plotSync.caches[arg]
                  if typeof(v91) ~= "table" then
                    return
                  end
                  local v92 = arg2[2]
                  local v93 = arg2[10]
                  local v94 = arg2[4]
                  local v95, v96, v97 = fn116(arg2[1], v91)

                  if v92 == "Changed" then
                    if v96 ~= nil then
                      v96[v97] = v93
                    end
                  elseif v92 == "ArrayInsert" then
                    if v95 ~= nil then
                      table.insert(v95, v94, v93)
                    end
                  elseif v92 == "ArrayRemoved" then
                    if v95 ~= nil then
                      table.remove(v95, v94)
                    end
                  elseif v92 == "DictionaryInsert" then
                    if v95 ~= nil then
                      v95[v94] = v93
                    end
                  elseif v92 == "DictionaryRemoved" then
                    if v95 ~= nil then
                      v95[v94] = nil
                    end
                  end
                end

                local function fn118(arg, arg2, arg3)
                  if aceSemiSteal.plotSync.connections[arg] then
                    return
                  end
                  local str9 = tostring(arg.Name)
                  if not arg2:FindFirstChild(str9) then
                    return
                  end

                  if arg3 and aceSemiSteal.plotSync.caches[str9] == nil then
                    local ok, result = pcall(function()
                      return arg3:InvokeServer(str9)
                    end)

                    aceSemiSteal.plotSync.caches[str9] = ok and typeof(result) == "table" and result
                      or {}
                  elseif aceSemiSteal.plotSync.caches[str9] == nil then
                    aceSemiSteal.plotSync.caches[str9] = {}
                  end

                  aceSemiSteal.plotSync.connections[arg] = arg.OnClientEvent:Connect(function(arg4)
                    for _, v91 in ipairs(arg4) do
                      fn117(str9, v91)
                    end
                  end)
                end

                local function fn119()
                  if aceSemiSteal.syncReady then
                    return true
                  end

                  return pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")

                    aceSemiSteal.packages = ReplicatedStorage:WaitForChild("Packages", 10)
                    aceSemiSteal.datas = ReplicatedStorage:WaitForChild("Datas", 10)
                    aceSemiSteal.plots = workspace:WaitForChild("Plots", 10)
                    if
                      not (aceSemiSteal.packages and aceSemiSteal.datas and aceSemiSteal.plots)
                    then
                      return
                    end
                    aceSemiSteal.animalsData =
                      require(aceSemiSteal.datas:WaitForChild("Animals", 12))
                    local synchronizer = aceSemiSteal.packages:WaitForChild("Synchronizer", 10)
                    aceSemiSteal.channelFolder = synchronizer:WaitForChild("Channel", 10)
                    aceSemiSteal.routeRemote =
                      synchronizer:WaitForChild("CommunicationRoute", 12)
                    aceSemiSteal.requestData = synchronizer:FindFirstChild("RequestData")

                    for _, child in ipairs(aceSemiSteal.channelFolder:GetChildren()) do
                      if child:IsA("RemoteEvent") then
                        fn118(child, aceSemiSteal.plots, aceSemiSteal.requestData)
                      end
                    end

                    aceSemiSteal.channelFolder.ChildAdded:Connect(function(child)
                      if child:IsA("RemoteEvent") then
                        fn118(child, aceSemiSteal.plots, aceSemiSteal.requestData)
                      end
                    end)

                    aceSemiSteal.routeRemote.OnClientEvent:Connect(function(arg)
                      for _, v91 in ipairs(arg) do
                        local v92 = v91[1]
                        local str9 = tostring(v91[2])

                        if aceSemiSteal.plots and aceSemiSteal.plots:FindFirstChild(str9) then
                          if v92 == "ListenerAdded" then
                            local channelFolder = aceSemiSteal.channelFolder
                              and aceSemiSteal.channelFolder:FindFirstChild(str9)

                            if channelFolder and channelFolder:IsA("RemoteEvent") then
                              fn118(channelFolder, aceSemiSteal.plots, aceSemiSteal.requestData)
                            end
                          elseif v92 == "ListenerRemoved" then
                            for k, connection in pairs(aceSemiSteal.plotSync.connections) do
                              if tostring(k.Name) == str9 then
                                pcall(function()
                                  connection:Disconnect()
                                end)

                                aceSemiSteal.plotSync.connections[k] = nil
                                aceSemiSteal.plotSync.caches[str9] = nil
                                break
                              end
                            end
                          end
                        end
                      end
                    end)

                    aceSemiSteal.syncReady = true
                  end) and aceSemiSteal.syncReady == true
                end

                local function fn120(arg)
                  arg = arg and arg:FindFirstChild("PlotSign")
                  local surfaceGui = arg
                    and arg:FindFirstChild("SurfaceGui")
                    and arg.SurfaceGui:FindFirstChild("Frame")
                  surfaceGui = surfaceGui and surfaceGui:FindFirstChild("TextLabel")
                  if not surfaceGui or surfaceGui.Text == "Empty Base" then
                    return nil
                  end
                  return surfaceGui.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
                end

                local function fn121(arg)
                  if not arg or not arg.plot or not aceSemiSteal.plots then
                    return false
                  end
                  local v91 = aceSemiSteal.plots:FindFirstChild(arg.plot)
                  if not v91 then
                    return false
                  end
                  local v92 = fn120(v91)
                  return v92 == localPlayer.DisplayName or v92 == localPlayer.Name
                end

                local function fn122(arg)
                  local plots = aceSemiSteal.plots and aceSemiSteal.plots:FindFirstChild(arg.plot)
                  plots = plots and plots:FindFirstChild("AnimalPodiums")
                  return plots and plots:FindFirstChild(arg.slot) or nil
                end

                local function fn123(arg)
                  local v91 = fn122(arg)
                  return v91 and v91:GetPivot().Position or nil
                end

                local function fn124(arg)
                  local v91 = fn114()
                  local v92 = fn123(arg)
                  return v91 and v92 and (v91.Position - v92).Magnitude or math.huge
                end

                local function fn125(arg)
                  if not arg then
                    return nil
                  end
                  local v91 = aceSemiSteal.promptCache[arg.uid]
                  if v91 and v91.Parent then
                    return v91
                  end
                  local v92 = fn122(arg)
                  local promptAttachment = v92 and v92:FindFirstChild("PromptAttachment")
                  promptAttachment = promptAttachment and promptAttachment:FindFirstChild("PromptAttachment")
                  promptAttachment = promptAttachment
                    and promptAttachment:FindFirstChild("PromptAttachment")
                  local proximityPrompt = promptAttachment
                    and promptAttachment:FindFirstChildWhichIsA("ProximityPrompt", true)

                  if not proximityPrompt and v92 then
                    proximityPrompt = v92:FindFirstChildWhichIsA("ProximityPrompt", true)
                  end

                  if proximityPrompt then
                    aceSemiSteal.promptCache[arg.uid] = proximityPrompt
                    return proximityPrompt
                  end
                  return nil
                end

                local function fn126()
                  if not fn119() then
                    return 0
                  end
                  local animals = {}

                  for _, child in ipairs(aceSemiSteal.plots:GetChildren()) do
                    local animalList = aceSemiSteal.plotSync.caches[child.Name]
                    animalList = animalList and animalList.AnimalList

                    if typeof(animalList) == "table" then
                      for k, v91 in pairs(animalList) do
                        if type(v91) == "table" then
                          local index = v91.Index
                          local animalsData = aceSemiSteal.animalsData
                            and aceSemiSteal.animalsData[index]

                          if animalsData then
                            table.insert(animals, {
                              name = animalsData.DisplayName or index,
                              plot = child.Name,
                              slot = tostring(k),
                              uid = child.Name .. "_" .. tostring(k),
                            })
                          end
                        end
                      end
                    end
                  end

                  aceSemiSteal.animals = animals
                  return #animals
                end

                local function fn127()
                  local v91 = fn114()
                  if not v91 then
                    return nil
                  end
                  local huge = math.huge
                  local v92 = nil

                  for _, animal in ipairs(aceSemiSteal.animals) do
                    if not fn121(animal) then
                      local magnitude = fn123(animal)
                      magnitude = magnitude and (v91.Position - magnitude).Magnitude or math.huge

                      if magnitude <= (aceSemiSteal.primeRange or 170) and magnitude < huge then
                        huge = magnitude
                        v92 = animal
                      end
                    end
                  end

                  return v92
                end

                local function fn128(arg)
                  if aceSemiSteal.internalCache[arg] then
                    return
                  end
                  local tbl31 = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
                  local ok, result = pcall(getSignalCons, arg.PromptButtonHoldBegan)

                  if ok and type(result) == "table" then
                    for _, v91 in ipairs(result) do
                      if type(v91.Function) == "function" then
                        table.insert(tbl31.holdCallbacks, v91.Function)
                      end
                    end
                  end

                  local ok2, result2 = pcall(getSignalCons, arg.Triggered)

                  if ok2 and type(result2) == "table" then
                    for _, v91 in ipairs(result2) do
                      if type(v91.Function) == "function" then
                        table.insert(tbl31.triggerCallbacks, v91.Function)
                      end
                    end
                  end

                  if #tbl31.holdCallbacks > 0 or #tbl31.triggerCallbacks > 0 then
                    aceSemiSteal.internalCache[arg] = tbl31
                  end
                end

                local function fn129(arg, arg2)
                  if not arg or not arg.Parent or not arg2 then
                    return false
                  end
                  fn128(arg)
                  local v91 = aceSemiSteal.internalCache[arg]
                  if v91 and not v91.ready then
                    return false
                  end

                  if v91 then
                    v91.ready = false
                  end

                  aceSemiSteal.state.active = true
                  aceSemiSteal.state.startTime = tick()
                  aceSemiSteal.state.phase = "holding"
                  aceSemiSteal.state.label = arg2.name or "Animal"

                  task.spawn(function()
                    local startTime = aceSemiSteal.state.startTime

                    local ok = type(fireproximityprompt) ~= "function"
                      and pcall(function()
                        arg:InputHoldBegin()
                      end)

                    if not ok and v91 then
                      for _, holdCallback in ipairs(v91.holdCallbacks) do
                        task.spawn(function()
                          pcall(holdCallback)
                        end)
                      end
                    end

                    while true do
                      local flag24 = aceSemiSteal.enabled and autoStealMode == "Semi"

                      if flag24 then
                        flag24 = tick() - startTime < (aceSemiSteal.holdMin or 1.3)
                      end

                      if flag24 then
                        fn112((tick() - startTime) / (aceSemiSteal.holdMax or 2.6), "STEALING")
                        task.wait()
                        continue
                      end

                      break
                    end

                    aceSemiSteal.state.phase = "waitingRange"
                    local flag24 = fn124(arg2) <= (tonumber(aceSemiSteal.radius) or 85)
                    local exitTo = nil
                    local flag25

                    while true do
                      local parent = aceSemiSteal.enabled and autoStealMode == "Semi" and arg.Parent
                      flag25 = false

                      if parent then
                        local n40 = tick() - startTime

                        if (aceSemiSteal.holdMax or 2.6) < n40 then
                          exitTo = 1
                          break
                        else
                          fn112(n40 / (aceSemiSteal.holdMax or 1.5), "STEALING")

                          if fn124(arg2) <= (tonumber(aceSemiSteal.radius) or 9) then
                            exitTo = 2
                            break
                          else
                            task.wait()
                            continue
                          end
                        end
                      end

                      break
                    end

                    if exitTo == 1 then
                      aceSemiSteal.state.active = false
                      ok = ok and not flag25
                    elseif exitTo == 2 then
                      if not flag24 then
                        task.wait(aceSemiSteal.entryDelay or 0.3)
                      end

                      if aceSemiSteal.enabled and autoStealMode == "Semi" then
                        if type(fireproximityprompt) == "function" then
                          pcall(function()
                            fireproximityprompt(arg, 0)
                          end)
                        elseif ok then
                          pcall(function()
                            arg:InputHoldEnd()
                          end)
                        elseif v91 then
                          for _, triggerCallback in ipairs(v91.triggerCallbacks) do
                            task.spawn(function()
                              pcall(triggerCallback)
                            end)
                          end
                        end

                        pcall(function()
                          if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then
                            _G.AutoCarrySpeed.WatchPickup(1.25)
                          end
                        end)

                        flag25 = true
                        aceSemiSteal.state.active = false
                        ok = ok and not flag25
                      else
                        aceSemiSteal.state.active = false
                        ok = ok and not flag25
                      end
                    else
                      aceSemiSteal.state.active = false
                      ok = ok and not flag25
                    end

                    if ok then
                      pcall(function()
                        arg:InputHoldEnd()
                      end)
                    end

                    aceSemiSteal.state.lastResult = flag25
                        and "Stole " .. tostring(aceSemiSteal.state.label)
                      or "Missed window: " .. tostring(aceSemiSteal.state.label)
                    aceSemiSteal.state.phase = "idle"
                    aceSemiSteal.state.lastResultTime = tick()

                    if flag25 then
                      fn112(1, "STEALING")
                    end

                    task.wait(aceSemiSteal.cooldown or 0.05)

                    if v91 then
                      v91.ready = true
                    end

                    fn113()
                  end)

                  return true
                end

                local function fn130()
                  if aceSemiSteal.scanThread then
                    return
                  end

                  aceSemiSteal.scanThread = task.spawn(function()
                    while _G.AceSemiSteal do
                      if aceSemiSteal.enabled or autoStealMode == "Semi" then
                        pcall(fn126)
                      end

                      task.wait(5)
                    end
                  end)
                end

                _G.AceSemiAutoStealSetRadius = function(arg)
                  local radius = tonumber(arg)

                  if radius then
                    aceSemiSteal.radius = radius
                  end
                end

                _G.AceSemiAutoStealStop = function()
                  aceSemiSteal.enabled = false

                  if aceSemiSteal.conn then
                    aceSemiSteal.conn:Disconnect()
                    aceSemiSteal.conn = nil
                  end

                  aceSemiSteal.state.active = false
                  aceSemiSteal.state.phase = "idle"
                  fn113()
                end

                _G.AceSemiAutoStealStart = function()
                  aceSemiSteal.radius = tonumber(stealRadius) or aceSemiSteal.radius or 9
                  aceSemiSteal.enabled = true
                  fn119()
                  fn130()
                  pcall(fn126)

                  if aceSemiSteal.conn then
                    aceSemiSteal.conn:Disconnect()
                    aceSemiSteal.conn = nil
                  end

                  aceSemiSteal.conn = greenduelsPerfRun.track(v90.Heartbeat:Connect(function()
                    if not aceSemiSteal.enabled then
                      return
                    end

                    if autoStealMode ~= "Semi" then
                      _G.AceSemiAutoStealStop()
                      return
                    end

                    if aceSemiSteal.state.active then
                      return
                    end
                    local v91 = fn127()
                    if not v91 then
                      return
                    end
                    local v92 = fn125(v91)

                    if v92 then
                      fn129(v92, v91)
                    end
                  end))
                end

                _G.AceSemiAutoStealSync = function()
                  if autoStealMode == "Semi" and autoStealEnabled then
                    _G.AceSemiAutoStealStart()
                  else
                    _G.AceSemiAutoStealStop()
                  end
                end
              end

              _G.__AceSetupSemiAutoSteal()
              SemiStealState = _G.AceSemiSteal and _G.AceSemiSteal.state or SemiStealState

              semiScanAllPlots = semiScanAllPlots
                or function()
                  return 0
                end

              local function fn112()
                autoStealMode = tbl18.autoStealMode or "Semi"
                autoStealEnabled = tbl22.AutoStealEnabled
                stealRadius = tbl22.StealRadius
                _G.AceStealRadii.Normal = tbl22.StealRadii.Normal or _G.AceStealRadii.Normal or 61
                _G.AceStealRadii.Semi = tbl22.StealRadii.Semi or _G.AceStealRadii.Semi or 9

                if autoStealMode == "Semi" then
                  _G.AceStealRadii.Semi = stealRadius
                end

                if _G.AceSemiAutoStealSetRadius then
                  _G.AceSemiAutoStealSetRadius(stealRadius)
                end

                SemiStealState = _G.AceSemiSteal and _G.AceSemiSteal.state or SemiStealState

                if _G.AceSemiAutoStealSync then
                  _G.AceSemiAutoStealSync()
                end
              end

              local function fn113()
                autoStealEnabled = false

                if _G.AceSemiAutoStealStop then
                  _G.AceSemiAutoStealStop()
                end
              end

              fn51 = function()
                if tbl18.autoStealMode == "Semi" then
                  fn112()
                else
                  fn110()
                end
              end

              fn52 = function()
                fn111()
                fn113()
              end

              greenduelsPerfRun.track(service.RenderStepped:Connect(function(deltaTime)
                local autoStealMode2 = tbl18.autoStealMode
                local aceSemiSteal, active, startTime, phase, lastResult, lastResultTime

                if autoStealMode2 == "Semi" then
                  aceSemiSteal = _G.AceSemiSteal
                  active = SemiStealState and SemiStealState.active
                  startTime = SemiStealState and SemiStealState.startTime or 0
                  phase = SemiStealState and SemiStealState.phase or str8
                  lastResult = SemiStealState and SemiStealState.lastResult or ""
                  lastResultTime = SemiStealState and SemiStealState.lastResultTime or 0
                  aceSemiSteal = aceSemiSteal and aceSemiSteal.holdMax or 2.6
                  local flag24 = not active

                  if flag24 then
                    flag24 = (n36 or 0) > 0
                  end

                  if flag24 and tick() < n37 then
                    startTime = tick() - (n36 or 0) * aceSemiSteal
                    phase = str8
                    active = true
                  end
                else
                  active = flag23
                  startTime = n34
                  phase = flag23

                  if active then
                    phase = str7 or "holding"
                  end

                  phase = phase or "idle"
                  lastResult = str6 or ""
                  lastResultTime = now2 or 0
                  aceSemiSteal = stealDuration or tbl22.StealDuration
                end

                local autoStealEnabled2 = tbl22.AutoStealEnabled
                local flag24 = lastResultTime > 0 and tick() - lastResultTime < 1.4
                local flag25 = flag24 and string.find(lastResult, "Stole") ~= nil
                local color

                if active then
                  color = phase == "waitingRange" and Color3.fromRGB(255, 200, 80)
                    or Color3.fromRGB(0, 220, 80)
                elseif flag24 then
                  color = flag25 and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 80, 80)
                elseif autoStealEnabled2 then
                  color = Color3.fromRGB(0, 220, 170)
                else
                  color = Color3.fromRGB(80, 100, 85)
                end

                frame6.BackgroundColor3 =
                  frame6.BackgroundColor3:Lerp(color, math.min(deltaTime * 10, 1))

                if autoStealMode2 == "Semi" and tick() < n37 then
                  local n40 = n36 or 0
                  flag25 = phase == "waitingRange" and Color3.fromRGB(255, 200, 170)
                    or Color3.fromRGB(0, 220, 80)
                  n38 += (n40 - n38) * math.min(deltaTime * 18, 1)
                elseif active then
                  local n40 = math.clamp((tick() - startTime) / aceSemiSteal, 0, 1)
                  flag25 = phase == "waitingRange" and Color3.fromRGB(255, 200, 170)
                    or Color3.fromRGB(0, 220, 80)
                  n38 += (n40 - n38) * math.min(deltaTime * 14, 1)
                elseif flag24 then
                  flag25 = flag25 and Color3.fromRGB(0, 255, 120)
                    or Color3.fromRGB(200, 80, 80)
                  n38 += (1 - n38) * math.min(deltaTime * 14, 1)
                else
                  flag25 = Color3.fromRGB(0, 220, 80)
                  n38 += (0 - n38) * math.min(deltaTime * 18, 1)
                end

                frame4.Size = UDim2.new(n38, 0, 1, 0)
                frame4.BackgroundColor3 =
                  frame4.BackgroundColor3:Lerp(flag25, math.min(deltaTime * 8, 1))
                textLabel3.Text = math.floor(n38 * 100 + 0.5) .. "%"
                textLabel3.TextTransparency = autoStealEnabled2 and 0 or 0.25
              end))

              _G._RemoveAccOn = false
              _G._RemoveAccConn = nil
              _G._removedAccessories = {}

              _G._removeAccDo = function()
                if not _G._RemoveAccOn then
                  return
                end
                local character = localPlayer.Character
                if not character then
                  return
                end

                for _, descendant in ipairs(character:GetDescendants()) do
                  if descendant:IsA("Accessory") or descendant:IsA("Hat") then
                    if not _G._removedAccessories[descendant] then
                      _G._removedAccessories[descendant] = true

                      pcall(function()
                        descendant:Destroy()
                      end)
                    end
                  end
                end
              end

              _G._removeAccStart = function()
                if _G._RemoveAccOn then
                  return
                end
                _G._RemoveAccOn = true
                _G._removeAccDo()

                _G._RemoveAccConn =
                  greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function()
                    task.wait(0.5)

                    if _G._RemoveAccOn then
                      _G._removeAccDo()
                    end
                  end))
              end

              _G._removeAccStop = function()
                _G._RemoveAccOn = false

                if _G._RemoveAccConn then
                  _G._RemoveAccConn:Disconnect()
                  _G._RemoveAccConn = nil
                end

                _G._removedAccessories = {}
              end

              local function fn114(character)
                task.wait(0.1)
                humanoid = character:WaitForChild("Humanoid", 5)
                v84 = character:WaitForChild("HumanoidRootPart", 5)
                if not humanoid or not v84 then
                  return
                end
                tbl18._tpInProgress = false

                if tbl18.aimbot2Toggled then
                  pcall(fn64)

                  if tbl24.aimbot2 then
                    pcall(tbl24.aimbot2.setOn, true)
                  end

                  task.delay(0.05, function()
                    if tbl18.aimbot2Toggled and localPlayer.Character == character then
                      pcall(fn63)

                      if tbl24.aimbot2 then
                        pcall(tbl24.aimbot2.setOn, true)
                      end
                    end
                  end)
                end

                pcall(function()
                  humanoid.Died:Connect(function()
                    tbl18._tpInProgress = false
                    local humanoidRootPart = character
                      and character:FindFirstChild("HumanoidRootPart")

                    if _G._greenduelsTPBatDeathCleanup then
                      pcall(_G._greenduelsTPBatDeathCleanup, humanoidRootPart)
                    end

                    if tbl18.aimbot2Toggled then
                      pcall(fn64)

                      if tbl24.aimbot2 then
                        pcall(tbl24.aimbot2.setOn, true)
                      end
                    end
                  end)
                end)

                local head = character:FindFirstChild("Head") or v84
                local greenduelsBB = head:FindFirstChild("greenduelsBB")

                if greenduelsBB then
                  greenduelsBB:Destroy()
                end

                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "greenduelsBB"
                billboardGui.Adornee = head
                billboardGui.Size = UDim2.new(0, 160, 0, 48)
                billboardGui.StudsOffset = Vector3.new(0, 2.25, 0)
                billboardGui.AlwaysOnTop = true
                billboardGui.Parent = head

                local uiListLayout = Instance.new("UIListLayout", billboardGui)
                uiListLayout.FillDirection = Enum.FillDirection.Vertical
                uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
                uiListLayout.Padding = UDim.new(0, 0)

                local textLabel4 = Instance.new("TextLabel", billboardGui)
                textLabel4.Name = "TopLbl"
                textLabel4.Size = UDim2.new(1, 0, 0, 56)
                textLabel4.BackgroundTransparency = 1
                textLabel4.Text = "0.0"
                textLabel4.TextColor3 = Color3.fromRGB(32, 240, 135)
                textLabel4.Font = Enum.Font.GothamBlack
                textLabel4.TextScaled = true
                textLabel4.TextStrokeTransparency = 0.08
                textLabel4.TextStrokeColor3 = Color3.fromRGB(0, 20, 10)
                textLabel4.LayoutOrder = 0

                local textLabel5 = Instance.new("TextLabel", billboardGui)
                textLabel5.Name = "SpeedBillLbl"
                textLabel5.Size = UDim2.new(1, 0, 0, 20)
                textLabel5.BackgroundTransparency = 1
                textLabel5.Text = ".gg/greenduels"
                textLabel5.TextColor3 = Color3.fromRGB(70, 240, 135)
                textLabel5.Font = Enum.Font.GothamBlack
                textLabel5.TextScaled = true
                textLabel5.TextStrokeTransparency = 0.08
                textLabel5.TextStrokeColor3 = Color3.fromRGB(0, 170, 12)
                textLabel5.RichText = true
                textLabel5.LayoutOrder = 1

                task.spawn(function()
                  local n40 = 14

                  while billboardGui.Parent and character.Parent do
                    local tbl31 = {}

                    for i = 1, 14 do
                      local str9

                      if i == n40 then
                        str9 = "D8FFE9"
                      else
                        local flag24 = i == n40 - 1 or i == n40 + 1
                        str9 = "46F087"

                        if flag24 then
                          str9 = "8CFFC0"
                        end
                      end

                      tbl31[#tbl31 + 1] = string.format(
                        '<font color="#%s">%s</font>',
                        str9,
                        (".gg/greenduels"):sub(i, i)
                      )
                    end

                    textLabel5.Text = table.concat(tbl31)
                    n40 -= 1

                    if n40 < 1 then
                      n40 = 14
                    end

                    task.wait(0.13)
                  end
                end)

                task.spawn(function()
                  while textLabel4.Parent and character.Parent do
                    local normalSpeed2 = tbl18.normalSpeed or 0

                    pcall(function()
                      if _G.greenduelsGetActiveMoveSpeed then
                        normalSpeed2 = _G.greenduelsGetActiveMoveSpeed()
                      elseif _V and _V.getActiveMoveSpeed then
                        normalSpeed2 = _V.getActiveMoveSpeed()
                      elseif fn39 then
                        normalSpeed2 = fn39()
                      end
                    end)

                    textLabel4.Text = string.format("%.1f", tonumber(normalSpeed2) or 0)
                    task.wait(0.08)
                  end
                end)

                tbl22.Data = {}

                if tbl18.medusaCounterEnabled then
                  task.delay(1.05, function()
                    if tbl18.medusaCounterEnabled then
                      fn49(character)
                    end
                  end)
                end

                if tbl18.batAimbotToggled then
                  if tbl24.aimbot then
                    pcall(tbl24.aimbot.setOn, true)
                  end

                  task.delay(0.25, function()
                    if tbl18.batAimbotToggled and not tbl20.aimbot then
                      pcall(fn59)
                    end
                  end)
                end

                if tbl18.aimbot2Toggled then
                  tbl18._tpInProgress = false
                  fn64()

                  task.delay(0.05, function()
                    if tbl18.aimbot2Toggled and localPlayer.Character == character then
                      pcall(fn63)

                      if tbl24.aimbot2 then
                        pcall(tbl24.aimbot2.setOn, true)
                      end
                    end
                  end)
                end

                if tbl18.batCounterEnabled then
                  task.delay(1.85, function()
                    if tbl18.batCounterEnabled then
                      fn61()
                    end
                  end)
                end

                if tbl18.tryardAnimEnabled then
                  task.delay(1.65, function()
                    if tbl18.tryardAnimEnabled then
                      fn40(character)
                      fn41(character)
                    end
                  end)
                end

                if tbl18.espEnabled then
                  fn86()

                  task.delay(1.85, function()
                    if tbl18.espEnabled then
                      pcall(fn85)
                    end
                  end)
                end

                fn34()
              end

              greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(fn114))

              if localPlayer.Character then
                task.delay(0.05, function()
                  fn114(localPlayer.Character)
                end)
              end

              local tbl31 = {
                [Enum.KeyCode.W] = true,
                [Enum.KeyCode.A] = true,
                [Enum.KeyCode.S] = true,
                [Enum.KeyCode.D] = true,
                [Enum.KeyCode.Up] = true,
                [Enum.KeyCode.Down] = true,
                [Enum.KeyCode.Left] = true,
                [Enum.KeyCode.Right] = true,
              }

              local tbl32 = {}
              local n40 = 0

              local function fn115()
                for k in pairs(tbl32) do
                  tbl32[k] = nil
                end

                local ok, result = pcall(function()
                  return service2:GetKeysPressed()
                end)

                if ok and result then
                  for _, v91 in ipairs(result) do
                    if v91 and tbl31[v91.KeyCode] then
                      tbl32[v91.KeyCode] = true
                    end
                  end
                else
                  for k in pairs(tbl31) do
                    if service2:IsKeyDown(k) then
                      tbl32[k] = true
                    end
                  end
                end
              end

              _G.greenduelsClearMoveKeys = function()
                for k in pairs(tbl32) do
                  tbl32[k] = nil
                end

                local now4 = tick()
                n40 = now4

                task.delay(0.055, function()
                  if n40 == now4 then
                    fn115()
                  end
                end)
              end

              greenduelsPerfRun.track(service2.InputBegan:Connect(function(input)
                if input and tbl31[input.KeyCode] then
                  tbl32[input.KeyCode] = true
                end
              end))

              greenduelsPerfRun.track(service2.InputEnded:Connect(function(input)
                if input and tbl31[input.KeyCode] then
                  tbl32[input.KeyCode] = nil
                end
              end))

              _G.greenduelsCurrentKeyMoveDir = function()
                local currentCamera = workspace.CurrentCamera
                currentCamera = currentCamera and currentCamera.CFrame
                local vector = currentCamera
                    and Vector3.new(currentCamera.LookVector.X, 0, currentCamera.LookVector.Z)
                  or Vector3.new(0, 0, -1)
                currentCamera = currentCamera
                    and Vector3.new(currentCamera.RightVector.X, 0, currentCamera.RightVector.Z)
                  or Vector3.new(1, 0, 0)

                if 0 < vector.Magnitude then
                  vector = vector.Unit
                end

                if 0 < currentCamera.Magnitude then
                  currentCamera = currentCamera.Unit
                end

                for k in pairs(tbl32) do
                  tbl32[k] = nil
                end

                local ok, result = pcall(function()
                  return service2:GetKeysPressed()
                end)

                if ok and result then
                  for _, v91 in ipairs(result) do
                    if v91 and tbl31[v91.KeyCode] then
                      tbl32[v91.KeyCode] = true
                    end
                  end
                else
                  for k in pairs(tbl31) do
                    if service2:IsKeyDown(k) then
                      tbl32[k] = true
                    end
                  end
                end

                local vector2 = Vector3.zero

                if tbl32[Enum.KeyCode.W] or tbl32[Enum.KeyCode.Up] then
                  vector2 += vector
                end

                if tbl32[Enum.KeyCode.S] or tbl32[Enum.KeyCode.Down] then
                  vector2 -= vector
                end

                if tbl32[Enum.KeyCode.D] or tbl32[Enum.KeyCode.Right] then
                  vector2 += currentCamera
                end

                if tbl32[Enum.KeyCode.A] or tbl32[Enum.KeyCode.Left] then
                  vector2 -= currentCamera
                end

                if vector2.Magnitude > 0.01 then
                  return vector2.Unit
                end
                local humanoid2 = localPlayer.Character
                  and localPlayer.Character:FindFirstChildOfClass("Humanoid")

                if humanoid2 then
                  local moveDirection = humanoid2.MoveDirection
                  local vector3 = Vector3.new(moveDirection.X, 0, moveDirection.Z)
                  if vector3.Magnitude > 0.01 then
                    return vector3.Unit
                  end
                end

                local ok2, result2 = pcall(function()
                  local playerModule = localPlayer.PlayerScripts
                    and localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                  playerModule = playerModule
                    and require(playerModule:FindFirstChild("ControlModule"))
                  return playerModule and playerModule:GetMoveVector() or Vector3.zero
                end)

                if ok2 and result2 and result2.Magnitude > 0.01 then
                  local n41 = currentCamera * result2.X - vector * result2.Z
                  if n41.Magnitude > 0.01 then
                    return n41.Unit
                  end
                end

                return Vector3.zero
              end

              _V = _G.greenduelsSpeedLogic or {}
              _G.greenduelsSpeedLogic = _V
              NS = nil
              CS = nil
              LS = nil
              LS2 = nil
              speedMode = nil
              laggerMode = nil
              laggerPhase = nil
              autoBatEnabled = nil
              autoLeftEnabled = nil
              autoRightEnabled = nil

              _refreshExactSpeedAliases = function()
                NS = tbl18.normalSpeed
                CS = tbl18.carrySpeed
                LS = tbl18.laggerSpeed
                LS2 = tbl18.laggerCarrySpeed
                speedMode = tbl18.speedToggled
                laggerMode = tbl18.laggerMode ~= 0
                laggerPhase = tbl18.laggerMode
                autoBatEnabled = tbl18.batAimbotToggled
                  or tbl18.aimbot2Toggled
                  or tbl18._tpInProgress
                autoLeftEnabled = tbl18.autoLeftEnabled
                autoRightEnabled = tbl18.autoRightEnabled
              end

              _G.greenduelsGetActiveMoveSpeed = function()
                _refreshExactSpeedAliases()
                return _V.getActiveMoveSpeed()
              end

              _refreshExactSpeedAliases()
              _V.s2VelChecked = {}
              _V.s2HookedVelParts = setmetatable({}, { __mode = "k" })
              _V.s2HookedVelMetatables = _V.s2HookedVelMetatables
                or setmetatable({}, { __mode = "k" })

              _V.s2SetupVelChecked = function(arg)
                _V.s2VelChecked = {}
                if not arg then
                  return nil
                end
                local humanoidRootPart = arg:WaitForChild("HumanoidRootPart", 5)

                if humanoidRootPart then
                  _V.s2VelChecked[humanoidRootPart] = true
                end

                return humanoidRootPart
              end

              _V.s2HookVelHRP = function(arg)
                if not arg or _V.s2HookedVelParts[arg] then
                  return
                end

                if not (getrawmetatable and setreadonly and newcclosure and checkcaller) then
                  return
                end
                _V.s2HookedVelParts[arg] = true

                pcall(function()
                  local v91 = getrawmetatable(arg)
                  if not v91 or _V.s2HookedVelMetatables[v91] then
                    return
                  end
                  setreadonly(v91, false)
                  local value = rawget(v91, "__index")

                  v91.__index = newcclosure(function(arg2, arg3)
                    if
                      not checkcaller()
                      and _V.s2VelChecked[arg2]
                      and (arg3 == "AssemblyLinearVelocity" or arg3 == "Velocity")
                    then
                      local v92

                      if type(value) == "function" then
                        v92 = value(arg2, arg3)
                      else
                        v92 = nil

                        if type(value) == "table" then
                          v92 = value[arg3]
                        end
                      end

                      if typeof(v92) == "Vector3" and v92.Magnitude > 170 then
                        return v92.Unit * 20
                      end
                      return v92
                    end

                    if type(value) == "function" then
                      return value(arg2, arg3)
                    end

                    if type(value) == "table" then
                      return value[arg3]
                    end
                  end)

                  setreadonly(v91, true)
                  _V.s2HookedVelMetatables[v91] = true
                end)
              end

              local v91 = tbl18
              local tbl33 =
                { enabled = true, lastMoveDir = Vector3.zero, speed = tbl18.normalSpeed }
              local tbl34 = { lastLiveInput = Vector3.zero }

              local function fn116(arg)
                if not (v91.autoChangeSpeed or v91.autoCarryOnGrab) then
                  return false
                end

                if greenduelsFunctions.autoCarryCachedCarrying == true then
                  return true
                end

                if arg == nil then
                  arg = fn84() == true
                end

                return arg
              end

              local function fn117()
                if service2:GetFocusedTextBox() then
                  return Vector3.zero
                end
                local flag24 = not tbl34.controlModule

                if flag24 then
                  flag24 = tick() >= (tbl34.retryAt or 0)
                end

                if flag24 then
                  local v92 = 1
                  tbl34.retryAt = tick() + v92

                  pcall(function()
                    local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
                    local playerModule = playerScripts
                      and playerScripts:FindFirstChild("PlayerModule")

                    if playerModule then
                      tbl34.controlModule = require(playerModule):GetControls()
                    end
                  end)
                end

                local controlModule = tbl34.controlModule
                local vector = Vector3.zero

                if controlModule then
                  local ok, result = pcall(controlModule.GetMoveVector, controlModule)

                  if ok and typeof(result) == "Vector3" then
                    vector = result
                  else
                    tbl34.controlModule = nil
                  end
                end

                local n41

                if not tbl34.controlModule then
                  if service2:IsKeyDown(Enum.KeyCode.W) or service2:IsKeyDown(Enum.KeyCode.Up) then
                    vector += Vector3.new(0, 0, -1)
                  end

                  if
                    service2:IsKeyDown(Enum.KeyCode.S) or service2:IsKeyDown(Enum.KeyCode.Down)
                  then
                    vector += Vector3.new(0, 0, 1)
                  end

                  if
                    service2:IsKeyDown(Enum.KeyCode.A) or service2:IsKeyDown(Enum.KeyCode.Left)
                  then
                    vector += Vector3.new(-1, 0, 0)
                  end

                  if
                    service2:IsKeyDown(Enum.KeyCode.D)
                    or service2:IsKeyDown(Enum.KeyCode.Right)
                  then
                    n41 = vector + Vector3.new(1, 0, 0)
                  else
                    n41 = vector
                  end
                else
                  n41 = vector
                end

                if n41 == Vector3.zero then
                  tbl34.lastLiveInput = Vector3.zero
                  return Vector3.zero
                end
                local currentCamera = workspace.CurrentCamera
                local isMoveVectorCameraRelative = controlModule
                  and controlModule.activeController
                  and controlModule.activeController.IsMoveVectorCameraRelative
                local flag25 = true

                if isMoveVectorCameraRelative then
                  local ok
                  ok, flag25 = pcall(
                    controlModule.activeController.IsMoveVectorCameraRelative,
                    controlModule.activeController
                  )
                  local flag26 = true

                  if not ok then
                    flag25 = flag26
                  end
                end

                if currentCamera and flag25 then
                  local vector2 = Vector3.new(
                    currentCamera.CFrame.LookVector.X,
                    0,
                    currentCamera.CFrame.LookVector.Z
                  )
                  local vector3 = Vector3.new(
                    currentCamera.CFrame.RightVector.X,
                    0,
                    currentCamera.CFrame.RightVector.Z
                  )

                  if vector2.Magnitude > 0 then
                    vector2 = vector2.Unit
                  end

                  local unit

                  if vector3.Magnitude > 0 then
                    unit = vector3.Unit
                  else
                    unit = vector3
                  end

                  n41 = unit * n41.X - vector2 * n41.Z
                end

                local vector2 = Vector3.new(n41.X, 0, n41.Z)

                if vector2.Magnitude > 0 then
                  vector2 = vector2.Unit
                end

                tbl34.lastLiveInput = vector2
                return vector2
              end

              local function fn118(arg, arg2)
                local v92
                v92 = arg and arg2 or v92
                if tbl33.spoofRoot == v92 then
                  return
                end

                if tbl33.spoofRoot then
                  _V.s2VelChecked[tbl33.spoofRoot] = nil
                end

                tbl33.spoofRoot = v92

                if v92 then
                  _V.s2VelChecked[v92] = true
                  _V.s2HookVelHRP(v92)
                end
              end

              greenduelsFunctions._waveGetAppliedMoveSpeed = function(arg)
                local laggerSpeed2

                if v91.laggerMode == 1 then
                  laggerSpeed2 = v91.laggerSpeed
                elseif v91.laggerMode == 2 then
                  laggerSpeed2 = v91.laggerCarrySpeed
                else
                  laggerSpeed2 = (v91.speedToggled or fn116(arg)) and v91.carrySpeed
                    or v91.normalSpeed
                end

                return math.clamp(tonumber(laggerSpeed2) or v91.normalSpeed or 0, 1, 4000)
              end

              _V.getActiveMoveSpeed = greenduelsFunctions._waveGetAppliedMoveSpeed

              local function fn119(arg)
                local v92 = greenduelsFunctions._waveGetAppliedMoveSpeed(arg)
                tbl33.speed = v92
                return v92
              end

              local function fn120(arg, arg2)
                local char2 = tbl33.char or localPlayer.Character
                local hum = tbl33.hum or char2 and char2:FindFirstChildOfClass("Humanoid")
                char2 = tbl33.root or char2 and char2:FindFirstChild("HumanoidRootPart")
                if not char2 or not hum or not char2 or hum.Health <= 0 then
                  return
                end

                if arg and arg.Magnitude > 0.05 then
                  local now4 = tick()
                  local flag24 = tbl33.netRoot ~= char2
                  local flag25

                  if flag24 then
                    flag25 = flag24
                  else
                    flag25 = now4 >= (tbl33.netAt or 0)
                  end

                  if flag25 then
                    tbl33.netRoot = char2
                    tbl33.netAt = now4 + 0.25

                    pcall(function()
                      if char2.SetNetworkOwner then
                        char2:SetNetworkOwner(localPlayer)
                      end
                    end)
                  end

                  local unit = arg.Unit
                  char2.AssemblyLinearVelocity =
                    Vector3.new(unit.X * arg2, char2.AssemblyLinearVelocity.Y, unit.Z * arg2)
                  v91.lastMoveDir = unit
                  tbl33.lastMoveDir = unit
                  tbl33.lastMoveAt = tick()
                else
                  char2.AssemblyLinearVelocity = Vector3.new(0, char2.AssemblyLinearVelocity.Y, 0)
                end
              end

              local function fn121(arg)
                if not arg then
                  return true
                end
                local state = arg:GetState()
                return arg.PlatformStand
                  or state == Enum.HumanoidStateType.Physics
                  or state == Enum.HumanoidStateType.Ragdoll
                  or state == Enum.HumanoidStateType.FallingDown
              end

              local function fn122()
                if v91.autoLeftEnabled or v91.autoRightEnabled then
                  return
                end

                if
                  v91.batAimbotToggled
                  or v91.antiDesyncEnabled
                  or v91.aimbot2Toggled
                  or v91._tpInProgress
                then
                  return
                end
                local character = localPlayer.Character
                local flag24 = character ~= tbl33.char

                if not flag24 then
                  flag24 = not (tbl33.hum and tbl33.hum.Parent)
                end

                if not flag24 then
                  flag24 = not (tbl33.root and tbl33.root.Parent)
                end

                if flag24 then
                  tbl33.char = character
                  tbl33.hum = character and character:FindFirstChildOfClass("Humanoid")
                  tbl33.root = character and character:FindFirstChild("HumanoidRootPart")
                end

                local hum = tbl33.hum
                local root = tbl33.root
                if not hum or not root then
                  return
                end
                local flag25 = fn84() == true
                fn118(flag25, root)

                if fn121(hum) then
                  local v92 = fn117(true)

                  if 0.1 < v92.Magnitude then
                    tbl33.lastMoveDir = v92
                    v91.lastMoveDir = v92
                    tbl33.lastMoveAt = tick()
                  end

                  return
                end

                local v92 = fn117()
                local moveDirection

                if v92.Magnitude <= 0.03 and not tbl34.controlModule then
                  moveDirection = hum.MoveDirection
                else
                  moveDirection = v92
                end

                local v93 = fn119(flag25)
                local unit

                if moveDirection.Magnitude > 0 then
                  tbl33.lastMoveDir = moveDirection.Unit
                  v91.lastMoveDir = moveDirection.Unit
                  tbl33.lastMoveAt = tick()
                  unit = moveDirection.Unit
                else
                  local flag26 = tbl33.lastMoveDir.Magnitude > 0 and v92.Magnitude > 0.1
                  unit = nil

                  if flag26 then
                    unit = tbl33.lastMoveDir
                  end
                end

                if moveDirection.Magnitude <= 0.03 then
                  tbl34.lastLiveInput = Vector3.zero
                end

                fn120(unit, v93)
              end

              local function fn123()
                if tbl33.conn then
                  tbl33.conn:Disconnect()
                  tbl33.conn = nil
                end

                if tbl33.conn2 then
                  tbl33.conn2:Disconnect()
                  tbl33.conn2 = nil
                end

                if tbl33.conn3 then
                  tbl33.conn3:Disconnect()
                  tbl33.conn3 = nil
                end

                if tbl33.enabled then
                  tbl33.conn = greenduelsPerfRun.track(v90.RenderStepped:Connect(fn122))
                end
              end

              fn123()
            end

            greenduelsPerfRun.track(service2.InputBegan:Connect(function(input, gameProcessed)
              if flag18 then
                return
              end
              local flag23 = input.UserInputType == Enum.UserInputType.Keyboard
              local v87 = fn33(input)
              if not flag23 and not v87 then
                return
              end

              if gameProcessed and flag23 then
                return
              end

              if service2:GetFocusedTextBox() then
                return
              end
              local keyCode = input.KeyCode
              if keyCode == Enum.KeyCode.Unknown then
                return
              end

              local function fn103(tpBatMode)
                if tbl18.aimbot2Toggled and tbl18.tpBatMode == tpBatMode then
                  tbl18.aimbot2Toggled = false
                  fn64()

                  if tbl24.aimbot2 then
                    tbl24.aimbot2.setOn(false)
                  end

                  if tbl24.aimbot and tpBatMode == "AntiHit" then
                    tbl24.aimbot.setOn(false)
                  end

                  if tpBatSet then
                    tpBatSet.setOn(false)
                  end

                  if modeAimbot then
                    _applyBatModeText()
                  end

                  requestSave()
                  return
                end

                if _G.greenduelsSetTpBatMode then
                  pcall(_G.greenduelsSetTpBatMode, tpBatMode)
                else
                  tbl18.tpBatMode = tpBatMode
                end

                if not tbl18.aimbot2Toggled then
                  tbl18.aimbot2Toggled = true
                  fn63()
                end

                if tbl24.aimbot2 then
                  tbl24.aimbot2.setOn(tpBatMode == "Teleport")
                end

                if tbl24.aimbot and tpBatMode == "AntiHit" then
                  tbl24.aimbot.setOn(true)
                end

                if tpBatSet then
                  tpBatSet.setOn(tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")
                end

                if modeAimbot then
                  _applyBatModeText()
                end

                requestSave()
              end

              if keyCode == tbl19.aimbot then
                if tbl18.autoBatBypass then
                  local aimbot2Toggled = not (tbl18.aimbot2Toggled and tbl18.tpBatMode == "AntiHit")
                  tbl18.tpBatMode = "AntiHit"
                  tbl18.aimbot2Toggled = aimbot2Toggled

                  if aimbot2Toggled then
                    fn63()
                  else
                    fn64()
                  end

                  if tbl24.aimbot then
                    tbl24.aimbot.setOn(tbl18.aimbot2Toggled and tbl18.tpBatMode == "AntiHit")
                  end

                  if modeAimbot then
                    _applyBatModeText()
                  end

                  requestSave()
                  return
                end

                if fn69() then
                  return
                end
                tbl18.batAimbotToggled = not tbl18.batAimbotToggled

                if tbl18.batAimbotToggled then
                  pcall(fn59)
                else
                  fn60()
                end

                if tbl24.aimbot then
                  tbl24.aimbot.setOn(tbl18.batAimbotToggled)
                end

                requestSave()
                return
              end

              if keyCode == tbl19.tpBat then
                fn103("Teleport")
                return
              end

              if keyCode == tbl19.antiBat then
                fn103("AntiHit")
                return
              end

              if keyCode == tbl19.speed then
                fn102()

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end
              elseif keyCode == tbl19.autoLeft then
                if fn69() then
                  return
                end
                tbl18.autoLeftEnabled = not tbl18.autoLeftEnabled

                if tbl24.autoLeft then
                  tbl24.autoLeft.setOn(tbl18.autoLeftEnabled)
                end

                if tbl18.autoLeftEnabled then
                  fn53()
                else
                  fn54()
                end

                requestSave()
              elseif keyCode == tbl19.autoRight then
                if fn69() then
                  return
                end
                tbl18.autoRightEnabled = not tbl18.autoRightEnabled

                if tbl24.autoRight then
                  tbl24.autoRight.setOn(tbl18.autoRightEnabled)
                end

                if tbl18.autoRightEnabled then
                  fn55()
                else
                  fn56()
                end

                requestSave()
              elseif keyCode == tbl19.drop then
                if not flag20 then
                  pcall(v86)
                end
              elseif keyCode == tbl19.reset then
                pcall(greenduelsInstantReset, "keybind:" .. keyCode.Name)
              elseif keyCode == tbl19.lagger then
                fn101()

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end
              elseif keyCode == tbl19.tpDown then
                if fn73 then
                  task.spawn(fn73)
                end
              elseif keyCode == tbl19.guiHide then
                if flag23 then
                  tbl18.guiVisible = not tbl18.guiVisible
                  fn90(tbl18.guiVisible, false)

                  if _G.greenduelsQAHide then
                    pcall(_G.greenduelsQAHide, not tbl18.guiVisible)
                  end

                  requestSave()
                end
              end
            end))

            _G._VezyFOV = _G._VezyFOV or tbl18.fovValue or 70
            _G._VezyFOVPropConn = nil

            _G.greenduelsApplyFovState = function()
              local currentCamera = Workspace.CurrentCamera
              if not currentCamera then
                return
              end

              if tbl18.fovEnabled and not tbl18.stretchedResEnabled then
                local fovValue = tbl18.fovValue or _G._VezyFOV or 70
                _G._VezyFOV = fovValue

                pcall(function()
                  currentCamera.FieldOfView = fovValue
                end)
              else
                pcall(function()
                  currentCamera.FieldOfView = tbl18._defFov or 32
                end)
              end
            end

            local function fn103(arg)
              if not arg then
                return
              end

              if _G._VezyFOVPropConn then
                pcall(function()
                  _G._VezyFOVPropConn:Disconnect()
                end)
              end

              pcall(_G.greenduelsApplyFovState)

              _G._VezyFOVPropConn = arg:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                local fovValue = tbl18.fovValue or _G._VezyFOV or 70

                if
                  tbl18.fovEnabled
                  and not tbl18.stretchedResEnabled
                  and arg.FieldOfView ~= fovValue
                then
                  pcall(function()
                    arg.FieldOfView = fovValue
                  end)
                end
              end)
            end

            fn103(Workspace.CurrentCamera)

            Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
              task.wait()
              fn103(Workspace.CurrentCamera)
            end)

            greenduelsPerfRun.track(localPlayer.CharacterAdded:Connect(function()
              task.wait(0.3)
              fn103(Workspace.CurrentCamera)
            end))

            local n34 = 0

            greenduelsPerfRun.track(service.RenderStepped:Connect(function()
              if tick() - n34 < 0.25 then
                return
              end
              n34 = tick()
              local currentCamera = Workspace.CurrentCamera
              if not currentCamera then
                return
              end
              local vezyFOV = _G._VezyFOV or 70

              if
                tbl18.fovEnabled
                and not tbl18.stretchedResEnabled
                and currentCamera.FieldOfView ~= vezyFOV
              then
                pcall(function()
                  currentCamera.FieldOfView = vezyFOV
                end)
              end
            end))

            _G.greenduelsAutoCarryOnGrab = _G.greenduelsAutoCarryOnGrab or {}
            greenduelsFunctions.autoCarryHold = 0.5
            greenduelsFunctions.autoCarryScanEvery = 0.1
            greenduelsFunctions.autoCarryLastTrue = -math.huge
            greenduelsFunctions.autoCarryScanAccumulator = 0
            greenduelsFunctions.autoCarryCachedCarrying = false

            _G.greenduelsAutoCarryOnGrab.SetEnabled = function(arg)
              tbl18.autoChangeSpeed = arg == true
              tbl18.autoCarryOnGrab = tbl18.autoChangeSpeed
            end

            _G.greenduelsAutoCarryOnGrab.IsHoldingBrainrot = function()
              if fn32 then
                return fn32(true)
              end
              return fn31()
            end

            _G.greenduelsAutoCarryOnGrab.EnterCarrySpeed = function()
              if tbl18.laggerMode == 1 then
                fn100(2)
              elseif tbl18.laggerMode == 0 and not tbl18.speedToggled then
                tbl18.speedToggled = true
                _G.greenduelsManualNormalSpeed = false

                if textLabel then
                  textLabel.Text = "Carry"
                end

                if tbl24.carrySpeed then
                  tbl24.carrySpeed.setOn(true)
                end

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end
              end
            end

            _G.greenduelsAutoCarryOnGrab.ExitCarrySpeed = function()
              if tbl18.laggerMode == 2 then
                fn100(1)
              elseif tbl18.laggerMode == 0 and tbl18.speedToggled then
                tbl18.speedToggled = false
                _G.greenduelsManualNormalSpeed = false

                if textLabel then
                  textLabel.Text = "Normal"
                end

                if tbl24.carrySpeed then
                  tbl24.carrySpeed.setOn(false)
                end

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end
              end
            end

            greenduelsFunctions.autoCarryConnection =
              greenduelsPerfRun.track(service.Heartbeat:Connect(function(deltaTime)
                greenduelsFunctions.autoCarryScanAccumulator = greenduelsFunctions.autoCarryScanAccumulator
                  + deltaTime
                if
                  greenduelsFunctions.autoCarryScanAccumulator
                  < greenduelsFunctions.autoCarryScanEvery
                then
                  return
                end
                greenduelsFunctions.autoCarryScanAccumulator = 0
                local now2 = os.clock()
                local flag23 = false

                pcall(function()
                  flag23 = _G.greenduelsAutoCarryOnGrab.IsHoldingBrainrot()
                end)

                if flag23 then
                  greenduelsFunctions.autoCarryLastTrue = now2
                end

                local autoCarryCachedCarrying = false

                if tbl18.autoCarryOnGrab then
                  pcall(function()
                    local v87 = true
                    autoCarryCachedCarrying = _autoCarryV2ShouldUseCarry(
                      localPlayer.Character,
                      flag23
                    ) == v87
                  end)

                  local humanoid2 = localPlayer.Character
                    and localPlayer.Character:FindFirstChildOfClass("Humanoid")
                  humanoid2 = humanoid2 and humanoid2.WalkSpeed < 25

                  if _G._AmbitiousAutoCarryMode == "SOFT" then
                    local ok, result = pcall(_G.AmbitiousAutoCarryInSoftRadius)

                    if ok and result then
                      humanoid2 = true
                    end
                  end

                  if humanoid2 then
                    autoCarryCachedCarrying = true
                  end
                end

                if
                  not autoCarryCachedCarrying
                  and now2 - greenduelsFunctions.autoCarryLastTrue < greenduelsFunctions.autoCarryHold
                  and tbl18.autoCarryOnGrab
                then
                  autoCarryCachedCarrying = true
                end

                if autoCarryCachedCarrying ~= greenduelsFunctions.autoCarryCachedCarrying then
                  if autoCarryCachedCarrying then
                    if tbl18.autoCarryOnGrab then
                      _G.greenduelsAutoCarryOnGrab.EnterCarrySpeed()
                    end
                  elseif tbl18.autoCarryOnGrab then
                    _G.greenduelsAutoCarryOnGrab.ExitCarrySpeed()
                  end

                  greenduelsFunctions.autoCarryCachedCarrying = autoCarryCachedCarrying
                end
              end))

            _G.greenduelsAutoCarryOnGrab.Disconnect = function()
              if greenduelsFunctions.autoCarryConnection then
                greenduelsFunctions.autoCarryConnection:Disconnect()
                greenduelsFunctions.autoCarryConnection = nil
              end
            end

            _G.AutoCarrySpeed = {
              SetEnabled = _G.greenduelsAutoCarryOnGrab.SetEnabled,
              IsHoldingBrainrot = _G.greenduelsAutoCarryOnGrab.IsHoldingBrainrot,
              WatchPickup = function(arg)
                _autoCarryV2.watchUntil = tick() + (tonumber(arg) or 1.25)
                _autoCarryV2.armed = true
                flag22 = true

                if
                  tbl18
                  and tbl18.kickWarningEnabled
                  and greenduelsFunctions
                  and greenduelsFunctions.showKickWarningBar
                then
                  pcall(greenduelsFunctions.showKickWarningBar)
                end

                task.delay(tonumber(arg) or 1.25, function()
                  flag22 = false
                end)
              end,
              Reset = function()
                _autoCarryV2.latched = false
                _autoCarryV2.held = false
                _autoCarryV2.armed = true
                _autoCarryV2.watchUntil = 0
              end,
              Disconnect = _G.greenduelsAutoCarryOnGrab.Disconnect,
            }

            do
              local textButton3 = Instance.new("TextButton", screenGui)
              textButton3.Name = "greenduelsClover"
              textButton3.Size = UDim2.new(0, 140, 0, 36)
              textButton3.Position = UDim2.new(0, 20, 0, 200)
              textButton3.BackgroundColor3 = Color3.fromRGB(22, 86, 38)
              textButton3.BorderSizePixel = 0
              textButton3.Text = "greenduels"
              textButton3.TextColor3 = Color3.fromRGB(210, 255, 210)
              textButton3.Font = Enum.Font.GothamBold
              textButton3.TextSize = 18
              textButton3.ZIndex = 25
              textButton3.Visible = true

              fn71(textButton3, 12)
              createUIStroke(textButton3, Color3.fromRGB(80, 200, 140), 1.5)
              local uiGradient = Instance.new("UIGradient", textButton3)
              local colorSequence = ColorSequence.new
              local tbl30 = {}
              local v87 = ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 180, 72))
              local v88 = ColorSequenceKeypoint.new(0.52, Color3.fromRGB(80, 255, 140))
              local new = ColorSequenceKeypoint.new
              local color = Color3.fromRGB
              local v89 = 210
              tbl30[1] = v87
              tbl30[2] = v88

              do
                local values = table.pack(new(1, color(v89, 255, 90)))
                table.move(values, 1, values.n, 3, tbl30)
              end

              uiGradient.Color = colorSequence(tbl30)
              uiGradient.Rotation = 18
              local position = nil
              local position2 = nil
              local flag23 = false
              local thread = nil

              textButton3.InputBegan:Connect(function(input)
                if tbl18.uiLocked then
                  return
                end

                if
                  input.UserInputType == Enum.UserInputType.MouseButton1
                  or input.UserInputType == Enum.UserInputType.Touch
                then
                  flag23 = true
                  position = input.Position
                  position2 = textButton3.Position

                  input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                      flag23 = false
                    end
                  end)
                end
              end)

              textButton3.InputChanged:Connect(function(input)
                if
                  flag23
                  and not tbl18.uiLocked
                  and (
                    input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch
                  )
                then
                  local n35 = input.Position - position
                  textButton3.Position = UDim2.new(
                    position2.X.Scale,
                    position2.X.Offset + n35.X,
                    position2.Y.Scale,
                    position2.Y.Offset + n35.Y
                  )
                end
              end)

              textButton3.InputEnded:Connect(function()
                if flag23 then
                  flag23 = false

                  if thread then
                    task.cancel(thread)
                  end

                  thread = task.delay(0.2, function()
                    pcall(requestSave)
                    thread = nil
                  end)
                end
              end)

              textButton3.MouseButton1Click:Connect(function()
                tbl18.guiVisible = not tbl18.guiVisible
                fn90(tbl18.guiVisible, false)

                if _G.greenduelsQAHide then
                  pcall(_G.greenduelsQAHide, not tbl18.guiVisible)
                end

                requestSave()
              end)

              textButton3.MouseEnter:Connect(function()
                TweenService:Create(
                  textButton3,
                  TweenInfo.new(0.12),
                  { BackgroundColor3 = Color3.fromRGB(34, 128, 58) }
                ):Play()
              end)

              textButton3.MouseLeave:Connect(function()
                TweenService:Create(
                  textButton3,
                  TweenInfo.new(0.12),
                  { BackgroundColor3 = Color3.fromRGB(22, 86, 38) }
                ):Play()
              end)

              local function fn104()
                if normalSpeed then
                  local normalSpeed2 = tonumber(normalSpeed.Text)

                  if normalSpeed2 and normalSpeed2 > 0 and normalSpeed2 <= 500 then
                    tbl18.normalSpeed = normalSpeed2
                  end
                end

                if carrySpeed then
                  local carrySpeed2 = tonumber(carrySpeed.Text)

                  if carrySpeed2 and carrySpeed2 > 0 and carrySpeed2 <= 500 then
                    tbl18.carrySpeed = carrySpeed2
                  end
                end

                if laggerSpeed then
                  local laggerSpeed2 = tonumber(laggerSpeed.Text)

                  if laggerSpeed2 and laggerSpeed2 > 0 and laggerSpeed2 <= 500 then
                    tbl18.laggerSpeed = laggerSpeed2
                  end
                end

                if laggerCarrySpeed then
                  local laggerCarrySpeed2 = tonumber(laggerCarrySpeed.Text)

                  if laggerCarrySpeed2 and laggerCarrySpeed2 > 0 and laggerCarrySpeed2 <= 500 then
                    tbl18.laggerCarrySpeed = laggerCarrySpeed2
                  end
                end

                if Radius then
                  local num = tonumber(Radius.Text)

                  if num and num >= 1 and num <= 200 then
                    local stealRadius = math.floor(num)
                    tbl22.StealRadius = stealRadius
                    tbl22.StealRadii[tbl18.autoStealMode or "Normal"] = stealRadius
                  end
                end

                if Duration then
                  local stealDuration = tonumber(Duration.Text)

                  if stealDuration and stealDuration >= 0.05 and stealDuration <= 10 then
                    tbl22.StealDuration = stealDuration
                  end
                end

                if uiScale then
                  local scale = tonumber(uiScale.Text)

                  if scale and scale >= 0.5 and scale <= 2 and uiScale3 then
                    uiScale3.Scale = scale
                  end
                end
              end

              local thread2 = nil
              local flag24 = false
              local flag25 = false
              local v90 = nil
              local flag26 = false

              local function greenduelsAutoSave()
                if flag26 then
                  return
                end

                if thread2 then
                  pcall(task.cancel, thread2)
                end

                thread2 = task.delay(0, function()
                  thread2 = nil

                  if not flag26 and fn57 then
                    local ok, result = pcall(fn57, false)

                    if not ok or not result then
                      task.delay(0.2, function()
                        if not flag26 then
                          pcall(fn57, true)
                        end
                      end)
                    end
                  end
                end)
              end

              local function greenduelsSaveNow()
                if not flag26 and fn57 then
                  return pcall(fn57, true)
                end
                return false
              end

              requestSave = greenduelsAutoSave
              _G.greenduelsAutoSave = greenduelsAutoSave
              _G.greenduelsSaveNow = greenduelsSaveNow
              local flag27 = false
              local flag28 = false

              local function fn105(arg)
                if type(arg) ~= "table" then
                  return false
                end

                -- Accept the current format and the older format already used
                -- by this script. Unknown future versions remain rejected.
                local version = tonumber(arg.version)
                return version == 6 or version == 20
              end

              fn57 = function(arg)
                if flag26 and not arg then
                  return false
                end

                if arg and thread2 then
                  pcall(task.cancel, thread2)
                  thread2 = nil
                end

                if flag24 then
                  flag25 = true
                  return false
                end

                if arg then
                  flag28 = true
                  flag27 = false
                end

                if not flag28 and not arg then
                  warn("[greenduels] Auto-save skipped until config load finishes.")
                  return false
                end

                if flag27 and not arg then
                  warn(
                    "[greenduels] Auto-save skipped because config load failed. Press Save Config Now to overwrite."
                  )
                  return false
                end
                local flag29 = false
                flag24 = true

                pcall(function()
                  pcall(fn104)
                  local tbl31 = {}

                  for k, v91 in pairs(tbl25) do
                    if v91 and v91.Position then
                      tbl31[k] = { X = v91.Position.X.Offset, Y = v91.Position.Y.Offset }
                    end
                  end

                  local tbl32 = textButton3
                      and textButton3.Position
                      and {
                        X = textButton3.Position.X.Offset,
                        Y = textButton3.Position.Y.Offset,
                      }
                    or nil
                  local tbl33 = instance
                      and instance.Position
                      and { X = instance.Position.X.Offset, Y = instance.Position.Y.Offset }
                    or nil

                  local tbl34 = {
                    version = 6,
                    savedAt = 0,
                    normalSpeed = tbl18.normalSpeed,
                    carrySpeed = tbl18.carrySpeed,
                    laggerSpeed = tbl18.laggerSpeed,
                    laggerCarrySpeed = tbl18.laggerCarrySpeed,
                    speedToggled = tbl18.speedToggled,
                    laggerMode = tbl18.laggerMode,
                    stealRadius = tbl22.StealRadius,
                    stealRadiiNormal = tbl22.StealRadii and tbl22.StealRadii.Normal
                      or tbl18.autoStealMode == "Normal" and tbl22.StealRadius
                      or 61,
                    stealRadiiSemi = tbl22.StealRadii and tbl22.StealRadii.Semi
                      or tbl18.autoStealMode == "Semi" and tbl22.StealRadius
                      or 85,
                    autoStealMode = tbl18.autoStealMode,
                    stealDuration = tbl22.StealDuration,
                    uiScale = uiScale3 and uiScale3.Scale or 1,
                    mobileButtonScale = tbl18.mobileButtonScale,
                    stealBarScale = tbl18.stealBarScale,
                    stackButtonsHidden = tbl18.stackButtonsHidden,
                    stackButtonsLocked = tbl18.stackButtonsLocked,
                    speedKey = tbl19.speed and tbl19.speed.Name or "Q",
                    autoLeftKey = tbl19.autoLeft and tbl19.autoLeft.Name or "L",
                    autoRightKey = tbl19.autoRight and tbl19.autoRight.Name or "R",
                    autoLeftEnabled = tbl18.autoLeftEnabled,
                    autoRightEnabled = tbl18.autoRightEnabled,
                    guiHideKey = tbl19.guiHide and tbl19.guiHide.Name or "LeftControl",
                    dropKey = tbl19.drop and tbl19.drop.Name or "H",
                    resetKey = tbl19.reset and tbl19.reset.Name or "T",
                    laggerKey = tbl19.lagger and tbl19.lagger.Name or "Unknown",
                    tpDownKey = tbl19.tpDown and tbl19.tpDown.Name or "Unknown",
                    aimbotKey = tbl19.aimbot and tbl19.aimbot.Name or "Unknown",
                    aimbot2Key = tbl19.aimbot2 and tbl19.aimbot2.Name or "Unknown",
                    tpBatKey = tbl19.tpBat and tbl19.tpBat.Name or "Unknown",
                    antiBatKey = tbl19.antiBat and tbl19.antiBat.Name or "Unknown",
                    infJump = tbl18.infJumpEnabled,
                    antiRagdoll = tbl18.antiRagdollEnabled,
                    antiCrasherEnabled = tbl18.antiCrasherEnabled,
                    antiDropEnabled = tbl18.antiDropEnabled,
                    medusaCounter = tbl18.medusaCounterEnabled,
                    resetOnMedusa = tbl18.resetOnMedusa,
                    batCounter = tbl18.batCounterEnabled,
                    autoStealEnabled = tbl22.AutoStealEnabled,
                    autoSwing = tbl18.autoSwingEnabled,
                    batAimbot = tbl18.batAimbotToggled,
                    aimbot2Toggled = tbl18.aimbot2Toggled,
                    antiLagEnabled = tbl18.antiLagEnabled,
                    potatoGraphicsEnabled = tbl18.potatoGraphicsEnabled,
                    stretchedResEnabled = tbl18.stretchedResEnabled,
                    fovEnabled = tbl18.fovEnabled,
                    fovValue = tbl18.fovValue or _G._VezyFOV or 70,
                    normalFOV = tbl18.fovValue or _G._VezyFOV or 70,
                    skyTheme = tbl18.skyTheme or "Off",
                    vividGraphics = tbl18.vividGraphics or "Off",
                    vividSaturation = (
                      _G.EvadeDuelsVividSettings
                      or _G.greenduelsVividSettings
                      or {}
                    ).saturation,
                    vividBloomIntensity = (
                      _G.EvadeDuelsVividSettings
                      or _G.greenduelsVividSettings
                      or {}
                    ).bloomIntensity,
                    vividBloomSize = (
                      _G.EvadeDuelsVividSettings
                      or _G.greenduelsVividSettings
                      or {}
                    ).bloomSize,
                    vividDofFocus = (
                      _G.EvadeDuelsVividSettings
                      or _G.greenduelsVividSettings
                      or {}
                    ).dofFocus,
                    vividSunIntensity = (
                      _G.EvadeDuelsVividSettings
                      or _G.greenduelsVividSettings
                      or {}
                    ).sunIntensity,
                    removeAccessories = tbl18.removeAcc,
                    guiVisible = tbl18.guiVisible,
                    introEnabled = tbl18.introEnabled,
                    introMusic = tbl18.introMusic or "Intro 1",
                    buttonPositions = tbl31,
                    cloverPosition = tbl32,
                    infoBarPosition = tbl33,
                    dropType = stand,
                    prevCarry = tbl18._prevCarry,
                    prevSpeed = tbl18._prevSpeed,
                    espEnabled = tbl18.espEnabled,
                    lineEspEnabled = tbl18.lineEspEnabled,
                    customToolsEnabled = _G.AmbitiousCustomToolsEnabled == true,
                    customToolSkinBat = _G.AmbitiousCustomToolSkins
                        and _G.AmbitiousCustomToolSkins.Bat
                      or "DiamondSword",
                    autoChangeSpeed = tbl18.autoChangeSpeed,
                    kickWarningEnabled = tbl18.kickWarningEnabled,
                    jumpMode = tbl18.jumpMode,
                    safeMode = tbl18.safeMode,
                    noCamCollisionEnabled = tbl18.noCamCollisionEnabled,
                    antiDieEnabled = tbl18.antiDieEnabled,
                    autoBatBypass = tbl18.autoBatBypass,
                    bypassAutoBatSpeed = tbl18.bypassAutoBatSpeed,
                    bypassLaggerAutoBatSpeed = tbl18.bypassLaggerAutoBatSpeed,
                    mirrorTPDownEnabled = tbl18.mirrorTPDownEnabled,
                    autoTPDownEnabled = tbl18.autoTPDownEnabled,
                    autoTPDownHeight = tbl18.autoTPDownHeight,
                    tpBatMode = tbl18.tpBatMode,
                    tpBatVersion = tbl18.tpBatVersion,
                    tpBatNoCollision = false,
                    bodyLockEnabled = tbl18.bodyLockEnabled,
                    bodyLockRadius = tbl18.bodyLockRadius,
                    unwalkEnabled = tbl18.unwalkEnabled,
                    cosmeticHeadless = tbl18.cosmeticHeadless,
                    cosmeticKorblox = tbl18.cosmeticKorblox,
                    cosmeticHat = tbl18.cosmeticHat,
                  }

                  if not fn105(tbl34) then
                    warn("[greenduels] Config validation failed, skipping save.")
                    return
                  end
                  local json = service3:JSONEncode(tbl34)
                  if not arg and json == v90 then
                    flag29 = true
                    return
                  end
                  tbl34.savedAt = os.time and os.time() or tick()
                  local json2 = service3:JSONEncode(tbl34)

                  if fn30(json2) then
                    v90 = json
                    flag29 = true
                    flag27 = false
                  end
                end)

                flag24 = false

                if flag25 then
                  flag25 = false

                  task.defer(function()
                    pcall(fn57, true)
                  end)
                end

                if not flag29 then
                  pcall(_G._VezyFlashSave, false)
                  warn("[greenduels] Config save FAILED!")
                else
                  pcall(_G._VezyFlashSave, true)
                end

                return flag29
              end

              -- Periodic automatic safety-save. Existing change-triggered saves
              -- remain in place; this catches changes that did not call requestSave.
              task.spawn(function()
                local interval = 30

                while _G.greenduelsV2_Running do
                  task.wait(interval)

                  if not _G.greenduelsV2_Running then
                    break
                  end

                  if flag28 and not flag26 and fn57 then
                    local ok, result = pcall(fn57, false)

                    if not ok or not result then
                      task.defer(function()
                        if _G.greenduelsV2_Running and not flag26 and fn57 then
                          pcall(fn57, true)
                        end
                      end)
                    end
                  end
                end
              end)

              fn58 = function()
                local v91 = nil
                local v92 = fn29()

                if v92 and v92 ~= "" then
                  local ok, result = pcall(service3.JSONDecode, service3, v92)

                  if ok and fn105(result) then
                    v91 = result
                  end
                end

                if not v91 then
                  if v92 then
                    flag27 = true
                    warn("[greenduels] Config could not be decoded. Using defaults for this run.")
                  else
                    flag27 = false
                  end

                  flag28 = true
                  return false
                end

                flag27 = false

                local function fn106(arg, arg2, arg3)
                  if v91[arg] ~= nil then
                    arg2 = v91[arg]

                    if arg3 and arg3.Text then
                      arg3.Text = tostring(v91[arg])
                    end
                  end

                  return arg2
                end

                tbl18.normalSpeed = fn106("normalSpeed", tbl18.normalSpeed, normalSpeed)
                tbl18.carrySpeed = fn106("carrySpeed", tbl18.carrySpeed, carrySpeed)
                tbl18.laggerSpeed = fn106("laggerSpeed", tbl18.laggerSpeed, laggerSpeed)
                tbl18.laggerCarrySpeed =
                  fn106("laggerCarrySpeed", tbl18.laggerCarrySpeed, laggerCarrySpeed)
                tbl18.bypassAutoBatSpeed =
                  fn106("bypassAutoBatSpeed", tbl18.bypassAutoBatSpeed, speedBox)
                tbl18.bypassLaggerAutoBatSpeed =
                  fn106("bypassLaggerAutoBatSpeed", tbl18.bypassLaggerAutoBatSpeed, lagSpeedBox)
                tbl22.StealRadius = fn106("stealRadius", tbl22.StealRadius, Radius)

                if v91.stealRadiiNormal ~= nil then
                  tbl22.StealRadii.Normal = tonumber(v91.stealRadiiNormal)
                    or tbl22.StealRadii.Normal
                end

                if v91.stealRadiiSemi ~= nil then
                  tbl22.StealRadii.Semi = tonumber(v91.stealRadiiSemi) or tbl22.StealRadii.Semi
                end

                if v91.stealRadiiNormal == nil or tonumber(v91.stealRadiiNormal) == 62 then
                  tbl22.StealRadii.Normal = 61
                end

                tbl22.StealDuration = fn106("stealDuration", tbl22.StealDuration, Duration)

                if v91.uiScale and uiScale3 then
                  uiScale3.Scale = v91.uiScale

                  if uiScale then
                    uiScale.Text = tostring(v91.uiScale)
                  end
                end

                if v91.mobileButtonScale ~= nil then
                  tbl18.mobileButtonScale =
                    math.clamp(tonumber(v91.mobileButtonScale) or 1, 0.5, 2)

                  if mobileButtonsSize then
                    mobileButtonsSize.Text = tostring(tbl18.mobileButtonScale)
                  end

                  fn65()
                end

                if v91.stealBarScale ~= nil then
                  tbl18.stealBarScale = math.clamp(tonumber(v91.stealBarScale) or 1, 0.5, 2)

                  if stealBarSize then
                    stealBarSize.Text = tostring(tbl18.stealBarScale)
                  end

                  fn66()
                end

                if v91.fovValue ~= nil or v91.normalFOV ~= nil then
                  tbl18.fovValue = tonumber(v91.fovValue or v91.normalFOV) or tbl18.fovValue
                  _G._VezyFOV = tbl18.fovValue

                  if toggleSetters.fovSlider then
                    pcall(toggleSetters.fovSlider, tbl18.fovValue)
                  end
                end

                if v91.fovEnabled ~= nil then
                  tbl18.fovEnabled = v91.fovEnabled
                end

                if tbl18.fovEnabled then
                  task.defer(fn98)
                else
                  local currentCamera = Workspace.CurrentCamera

                  if currentCamera then
                    pcall(function()
                      currentCamera.FieldOfView = tbl18._defFov or 70
                    end)
                  end
                end

                if v91.prevCarry ~= nil then
                  tbl18._prevCarry = v91.prevCarry
                end

                if v91.prevSpeed ~= nil then
                  tbl18._prevSpeed = v91.prevSpeed
                end

                if v91.autoChangeSpeed ~= nil then
                  tbl18.autoChangeSpeed = v91.autoChangeSpeed
                  tbl18.autoCarryOnGrab = tbl18.autoChangeSpeed
                end

                if v91.jumpMode ~= nil then
                  tbl18.jumpMode = v91.jumpMode == "Tap" and "Tap" or "Hold"
                end

                if v91.safeMode ~= nil then
                  tbl18.safeMode = v91.safeMode
                end

                if v91.antiCrasherEnabled ~= nil then
                  tbl18.antiCrasherEnabled = v91.antiCrasherEnabled
                end

                if v91.antiDropEnabled ~= nil then
                  tbl18.antiDropEnabled = v91.antiDropEnabled
                end

                if v91.tpBatMode then
                  tbl18.tpBatMode = v91.tpBatMode
                end

                tbl18.tpBatVersion = "V1"

                if v91.dropType and (v91.dropType == tbl17.STAND or v91.dropType == tbl17.JUMP) then
                  stand = v91.dropType

                  if textButton and textButton2 then
                    if stand == tbl17.STAND then
                      fn91(textButton, true, true)
                      fn91(textButton2, false, true)
                    else
                      fn91(textButton2, true, true)
                      fn91(textButton, false, true)
                    end
                  end
                end

                if v91.autoStealMode then
                  tbl18.autoStealMode = v91.autoStealMode
                end

                if v91.autoTPDownHeight ~= nil then
                  tbl18.autoTPDownHeight =
                    math.clamp(tonumber(v91.autoTPDownHeight) or tbl18.autoTPDownHeight, 1, 100)
                end

                if v91.bodyLockRadius ~= nil then
                  tbl18.bodyLockRadius =
                    math.clamp(tonumber(v91.bodyLockRadius) or tbl18.bodyLockRadius, 1, 200)
                end

                if v91.introMusic ~= nil then
                  local str6 = tostring(v91.introMusic)
                  local v93 = tbl18
                  local str7 = str6 == "Intro 5" and "Intro 4" or str6 == "Intro 4" and "Intro 3"

                  if not str7 then
                    str7 = (str6 == "Intro 1" or str6 == "Intro 2" or str6 == "Intro 3") and str6
                  end

                  v93.introMusic = str7
                    or (str6 == "Default" or str6 == "Other") and "Intro 1"
                    or "Intro 1"
                end

                for k, v93 in pairs({
                  noCamCollisionEnabled = "noCamCollisionEnabled",
                  antiDieEnabled = "antiDieEnabled",
                  cosmeticHeadless = "cosmeticHeadless",
                  stackButtonsHidden = "stackButtonsHidden",
                  stackButtonsLocked = "stackButtonsLocked",
                  infJump = "infJumpEnabled",
                  antiRagdoll = "antiRagdollEnabled",
                  antiCrasherEnabled = "antiCrasherEnabled",
                  antiDropEnabled = "antiDropEnabled",
                  medusaCounter = "medusaCounterEnabled",
                  resetOnMedusa = "resetOnMedusa",
                  batCounter = "batCounterEnabled",
                  autoSwing = "autoSwingEnabled",
                  batAimbot = "batAimbotToggled",
                  aimbot2Toggled = "aimbot2Toggled",
                  antiLagEnabled = "antiLagEnabled",
                  potatoGraphicsEnabled = "potatoGraphicsEnabled",
                  stretchedResEnabled = "stretchedResEnabled",
                  fovEnabled = "fovEnabled",
                  removeAccessories = "removeAcc",
                  kickWarningEnabled = "kickWarningEnabled",
                  speedToggled = "speedToggled",
                  autoLeftEnabled = "autoLeftEnabled",
                  autoRightEnabled = "autoRightEnabled",
                  espEnabled = "espEnabled",
                  lineEspEnabled = "lineEspEnabled",
                  mirrorTPDownEnabled = "mirrorTPDownEnabled",
                  autoTPDownEnabled = "autoTPDownEnabled",
                  bodyLockEnabled = "bodyLockEnabled",
                  unwalkEnabled = "unwalkEnabled",
                  safeMode = "safeMode",
                  autoBatBypass = "autoBatBypass",
                }) do
                  if v91[k] ~= nil then
                    tbl18[v93] = v91[k]
                  end
                end

                if v91.skyTheme ~= nil then
                  tbl18.skyTheme = tostring(v91.skyTheme)
                end

                if _G.greenduelsApplySkyTheme then
                  pcall(_G.greenduelsApplySkyTheme, tbl18.skyTheme or "Off")
                end

                if v91.vividGraphics ~= nil then
                  tbl18.vividGraphics = tostring(v91.vividGraphics) == "Vivid" and "Game Color"
                    or tostring(v91.vividGraphics)
                end

                if _G.greenduelsApplyVividGraphics then
                  pcall(_G.greenduelsApplyVividGraphics, tbl18.vividGraphics or "Default")
                end

                if _G.greenduelsVividSettings then
                  if v91.vividSaturation ~= nil then
                    _G.greenduelsVividSettings.saturation =
                      math.clamp(tonumber(v91.vividSaturation) or 0.6, 0, 2)
                  end

                  if v91.vividBloomIntensity ~= nil then
                    _G.greenduelsVividSettings.bloomIntensity =
                      math.clamp(tonumber(v91.vividBloomIntensity) or 0.8, 0, 3)
                  end

                  if v91.vividBloomSize ~= nil then
                    _G.greenduelsVividSettings.bloomSize =
                      math.clamp(tonumber(v91.vividBloomSize) or 56, 1, 56)
                  end

                  if v91.vividDofFocus ~= nil then
                    _G.greenduelsVividSettings.dofFocus =
                      math.clamp(tonumber(v91.vividDofFocus) or 25, 1, 100)
                  end

                  if v91.vividSunIntensity ~= nil then
                    _G.greenduelsVividSettings.sunIntensity =
                      math.clamp(tonumber(v91.vividSunIntensity) or 0.3, 0, 1)
                  end
                end

                if tbl18.vividGraphics == "Custom" and _G.greenduelsApplyVividGraphics then
                  pcall(_G.greenduelsApplyVividGraphics, "Custom")
                end

                tbl18.tryardAnimEnabled = false
                pcall(fn42)

                if v91.customToolsEnabled ~= nil then
                  _G.AmbitiousCustomToolsEnabled = v91.customToolsEnabled == true
                end

                _G.AmbitiousRainbowToolsEnabled = false
                _G.AmbitiousTransparentToolsEnabled = false
                _G.AmbitiousCustomSoundsEnabled = false
                _G.AmbitiousCustomToolSkins = _G.AmbitiousCustomToolSkins or {}

                if v91.customToolSkinBat ~= nil then
                  _G.AmbitiousCustomToolSkins.Bat = v91.customToolSkinBat
                end

                tbl18.guiVisible = true
                tbl18.introEnabled = true

                if v91.autoStealEnabled ~= nil then
                  tbl22.AutoStealEnabled = v91.autoStealEnabled
                end

                if v91.laggerMode ~= nil then
                  tbl18.laggerMode = v91.laggerMode
                end

                if v91.cosmeticKorblox ~= nil then
                  tbl18.cosmeticKorblox = tostring(v91.cosmeticKorblox)
                end

                if v91.cosmeticHat ~= nil then
                  tbl18.cosmeticHat = tostring(v91.cosmeticHat)
                end

                for k, v93 in pairs({
                  speedKey = "speed",
                  autoLeftKey = "autoLeft",
                  autoRightKey = "autoRight",
                  guiHideKey = "guiHide",
                  dropKey = "drop",
                  resetKey = "reset",
                  laggerKey = "lagger",
                  tpDownKey = "tpDown",
                  aimbotKey = "Aimbot",
                  aimbot2Key = "aimbot2",
                  tpBatKey = "tpBat",
                  antiBatKey = "antiBat",
                }) do
                  if v91[k] then
                    local v94 = Enum.KeyCode[v91[k]]

                    if v94 then
                      tbl19[v93] = v94

                      if tbl26[v93] then
                        tbl26[v93].Text = fn92(v94)
                      end
                    end
                  end
                end

                frame.Visible = tbl18.guiVisible

                if _G.greenduelsQAHide then
                  pcall(_G.greenduelsQAHide, not tbl18.guiVisible)
                end

                for _, v93 in pairs(tbl25) do
                  v93.Visible = not tbl18.stackButtonsHidden
                end

                if hideButtons then
                  hideButtons(tbl18.stackButtonsHidden)
                end

                if lockButtons then
                  lockButtons(tbl18.stackButtonsLocked)
                end

                if toggleSetters.introEnabled then
                  pcall(toggleSetters.introEnabled, tbl18.introEnabled)
                end

                if _G._refreshIntroMusicButtons then
                  pcall(_G._refreshIntroMusicButtons)
                end

                if tbl24.carrySpeed then
                  tbl24.carrySpeed.setOn(tbl18.speedToggled)
                end

                if tbl24.lagger then
                  tbl24.lagger.setOn(tbl18.laggerMode == 1)
                end

                if tbl24.laggerCarry then
                  tbl24.laggerCarry.setOn(tbl18.laggerMode == 2)
                end

                if tbl24.aimbot then
                  tbl24.aimbot.setOn(
                    tbl18.autoBatBypass and tbl18.aimbot2Toggled and tbl18.tpBatMode == "AntiHit"
                      or not tbl18.autoBatBypass and tbl18.batAimbotToggled
                  )
                end

                if tbl24.aimbot2 then
                  tbl24.aimbot2.setOn(tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport")
                end

                if tbl24.autoLeft then
                  tbl24.autoLeft.setOn(tbl18.autoLeftEnabled)
                end

                if tbl24.autoRight then
                  tbl24.autoRight.setOn(tbl18.autoRightEnabled)
                end

                if tbl18.unwalkEnabled then
                  task.delay(0.25, function()
                    if tbl18.unwalkEnabled then
                      fn81()
                    end
                  end)
                else
                  fn82()
                end

                if tbl18.noCamCollisionEnabled then
                  task.delay(0.5, function()
                    if tbl18.noCamCollisionEnabled then
                      fn35()
                    end
                  end)
                end

                if tbl18.antiDieEnabled then
                  task.delay(0.35, function()
                    if tbl18.antiDieEnabled then
                      fn37()
                    end
                  end)
                else
                  fn38()
                end

                if tbl18.antiLagEnabled then
                  task.delay(0.2, function()
                    if tbl18.antiLagEnabled then
                      fn94()
                    end
                  end)
                else
                  fn95()
                end

                if tbl18.potatoGraphicsEnabled then
                  task.delay(0.55, function()
                    if tbl18.potatoGraphicsEnabled then
                      enablePotatoGraphics()
                    end
                  end)
                else
                  disablePotatoGraphics()
                end

                if tbl18.stretchedResEnabled then
                  task.delay(0.65, function()
                    if tbl18.stretchedResEnabled then
                      fn96()
                    end
                  end)
                else
                  fn97()
                end

                task.delay(0.25, function()
                  if _G.AmbitiousRainbowTools then
                    pcall(function()
                      _G.AmbitiousRainbowTools.setEnabled(false)
                    end)
                  end

                  if _G.AmbitiousTransparentTools then
                    pcall(function()
                      _G.AmbitiousTransparentTools.setEnabled(false)
                    end)
                  end

                  if _G.AmbitiousCustomSounds then
                    pcall(function()
                      _G.AmbitiousCustomSounds.setEnabled(false)
                    end)
                  end

                  if _G.AmbitiousCustomToolsEnabled and _G.AmbitiousCustomTools then
                    pcall(function()
                      _G.AmbitiousCustomTools.setEnabled(true)
                    end)
                  end
                end)

                if tbl18.removeAcc then
                  task.delay(1.05, function()
                    if tbl18.removeAcc then
                      _G._removeAccStart()
                    end
                  end)
                else
                  _G._removeAccStop()
                end

                if tbl18.tryardAnimEnabled then
                  task.delay(1.25, function()
                    if tbl18.tryardAnimEnabled then
                      fn43()
                    end
                  end)
                else
                  fn42()
                end

                if tbl18.batAimbotToggled then
                  task.delay(1.45, function()
                    if tbl18.batAimbotToggled then
                      fn59()
                    end
                  end)
                else
                  fn60()
                end

                if tbl18.aimbot2Toggled then
                  task.delay(0.35, function()
                    if tbl18.aimbot2Toggled then
                      fn63()
                    end
                  end)
                else
                  fn64()
                end

                if
                  tbl18.bodyLockEnabled
                  and not tbl18.batAimbotToggled
                  and not tbl18.aimbot2Toggled
                then
                  task.delay(0.45, function()
                    if
                      tbl18.bodyLockEnabled
                      and not tbl18.batAimbotToggled
                      and not tbl18.aimbot2Toggled
                    then
                      startBodyLock()
                    end
                  end)
                else
                  stopBodyLock()
                end

                if tbl18.autoTPDownEnabled then
                  pcall(fn79)
                else
                  pcall(fn80)
                end

                if tbl18.batCounterEnabled then
                  task.delay(1.85, function()
                    if tbl18.batCounterEnabled then
                      fn61()
                    end
                  end)
                else
                  fn62()
                end

                if tbl18.medusaCounterEnabled then
                  task.delay(2.05, function()
                    if tbl18.medusaCounterEnabled then
                      fn49(localPlayer.Character)
                    end
                  end)
                else
                  fn50()
                end

                if tbl18.antiRagdollEnabled then
                  task.defer(function()
                    if tbl18.antiRagdollEnabled then
                      greenduelsStartAntiRagdoll()
                    end
                  end)
                else
                  fn87()
                end

                if not tbl22.AutoStealEnabled then
                  fn52()
                end

                if tbl18.espEnabled then
                  task.delay(2.85, function()
                    if tbl18.espEnabled then
                      fn85()
                    end
                  end)
                else
                  fn86()
                end

                tbl18.swingHereMarkerEnabled = true

                task.delay(0.75, function()
                  tbl18.swingHereMarkerEnabled = true
                  _G.greenduelsStartSwingHereMarkers()
                end)

                if tbl18.autoStealMode == "Semi" then
                  local semi = tbl22.StealRadii.Semi or 9
                  tbl22.StealRadius = semi
                  tbl22.StealDuration = 1.3

                  if Radius then
                    Radius.Text = tostring(semi)
                  end

                  if Duration then
                    Duration.Text = "1.3"
                  end
                elseif tbl18.autoStealMode == "Normal" then
                  local normal = tbl22.StealRadii.Normal or 61

                  if v91.stealRadius ~= nil and v91.stealRadiiNormal == nil then
                    normal = tonumber(v91.stealRadius) or normal
                    tbl22.StealRadii.Normal = normal
                  end

                  tbl22.StealRadius = normal
                  tbl22.StealDuration = 1.33

                  if Radius then
                    Radius.Text = tostring(normal)
                  end

                  if Duration then
                    Duration.Text = "1.33"
                  end
                end

                if _G._refreshStealStatus then
                  pcall(_G._refreshStealStatus)
                end

                for k, v93 in pairs(toggleSetters) do
                  local autoStealEnabled

                  if k == "autoSteal" then
                    autoStealEnabled = tbl22.AutoStealEnabled
                  elseif k == "infJump" then
                    autoStealEnabled = tbl18.infJumpEnabled
                  elseif k == "antiRagdoll" then
                    autoStealEnabled = tbl18.antiRagdollEnabled
                  elseif k == "antiCrasher" then
                    autoStealEnabled = tbl18.antiCrasherEnabled
                  elseif k == "antiDrop" then
                    autoStealEnabled = tbl18.antiDropEnabled
                  elseif k == "medusaCounter" then
                    autoStealEnabled = tbl18.medusaCounterEnabled
                  elseif k == "resetOnMedusa" then
                    autoStealEnabled = tbl18.resetOnMedusa
                  elseif k == "batCounter" then
                    autoStealEnabled = tbl18.batCounterEnabled
                  elseif k == "autoSwing" then
                    autoStealEnabled = tbl18.autoSwingEnabled
                  elseif k == "customTools" then
                    autoStealEnabled = _G.AmbitiousCustomToolsEnabled == true
                  elseif k == "antiLag" then
                    autoStealEnabled = tbl18.antiLagEnabled
                  elseif k == "potatoGraphics" then
                    autoStealEnabled = tbl18.potatoGraphicsEnabled
                  elseif k == "stretchedRes" then
                    autoStealEnabled = tbl18.stretchedResEnabled
                  elseif k == "fovEnabled" then
                    autoStealEnabled = tbl18.fovEnabled
                  elseif k == "removeAcc" then
                    autoStealEnabled = tbl18.removeAcc
                  elseif k == "hideButtons" then
                    autoStealEnabled = tbl18.stackButtonsHidden
                  elseif k == "lockButtons" then
                    autoStealEnabled = tbl18.stackButtonsLocked
                  elseif k == "espEnabled" then
                    autoStealEnabled = tbl18.espEnabled
                  elseif k == "lineEsp" then
                    autoStealEnabled = tbl18.lineEspEnabled
                  elseif k == "autoChangeSpeed" then
                    autoStealEnabled = tbl18.autoChangeSpeed
                  elseif k == "kickWarning" then
                    autoStealEnabled = tbl18.kickWarningEnabled
                  elseif k == "aimbot" then
                    autoStealEnabled = tbl18.autoBatBypass
                        and tbl18.aimbot2Toggled
                        and tbl18.tpBatMode == "AntiHit"
                      or not tbl18.autoBatBypass and tbl18.batAimbotToggled
                  elseif k == "aimbot2" then
                    autoStealEnabled = tbl18.aimbot2Toggled and tbl18.tpBatMode == "Teleport"
                  elseif k == "mirrorTPDown" then
                    autoStealEnabled = tbl18.mirrorTPDownEnabled
                  elseif k == "autoTPDown" then
                    autoStealEnabled = tbl18.autoTPDownEnabled
                  elseif k == "cosmeticHeadless" then
                    autoStealEnabled = tbl18.cosmeticHeadless
                  elseif k == "cosmeticKorblox" then
                    autoStealEnabled = tbl18.cosmeticKorblox
                  elseif k == "cosmeticHat" then
                    autoStealEnabled = tbl18.cosmeticHat
                  elseif k == "unwalk" then
                    autoStealEnabled = tbl18.unwalkEnabled
                  elseif k == "safeMode" then
                    autoStealEnabled = tbl18.safeMode
                  elseif k == "noCamCollision" then
                    autoStealEnabled = tbl18.noCamCollisionEnabled
                  elseif k == "antiDie" then
                    autoStealEnabled = tbl18.antiDieEnabled
                  elseif k == "aimbotBypass" then
                    autoStealEnabled = tbl18.autoBatBypass
                  else
                    autoStealEnabled = nil

                    if k == "bodyLock" then
                      autoStealEnabled = tbl18.bodyLockEnabled
                    end
                  end

                  if autoStealEnabled ~= nil then
                    pcall(v93, autoStealEnabled)
                  end
                end

                if toggleSetters.autoSteal then
                  pcall(toggleSetters.autoSteal, tbl22.AutoStealEnabled)
                end

                fn93()

                if tbl24.stealModeNormal and tbl24.stealModeSemi then
                  if tbl18.autoStealMode == "Normal" then
                    fn91(tbl24.stealModeNormal, true, true)
                    fn91(tbl24.stealModeSemi, false, true)
                  else
                    fn91(tbl24.stealModeSemi, true, true)
                    fn91(tbl24.stealModeNormal, false, true)
                  end
                end

                instance.Visible = true

                if v91.buttonPositions then
                  for k, buttonPosition in pairs(v91.buttonPositions) do
                    local v93 = tbl25[k]

                    if v93 and buttonPosition.X and buttonPosition.Y then
                      v93.Position = UDim2.new(
                        v93.Position.X.Scale,
                        buttonPosition.X,
                        v93.Position.Y.Scale,
                        buttonPosition.Y
                      )
                    end
                  end
                end

                if v91.cloverPosition and textButton3 then
                  textButton3.Position = UDim2.new(0, v91.cloverPosition.X, 0, v91.cloverPosition.Y)
                end

                if v91.infoBarPosition and instance then
                  instance.Position = UDim2.new(
                    instance.Position.X.Scale,
                    v91.infoBarPosition.X,
                    instance.Position.Y.Scale,
                    v91.infoBarPosition.Y
                  )
                end

                if _G._refreshSpeedModeUI then
                  _G._refreshSpeedModeUI()
                end

                fn34()

                task.defer(function()
                  if not screenGui.Parent then
                    return
                  end
                  pcall(_G.greenduelsApplyHeadless, tbl18.cosmeticHeadless)
                  pcall(_G.greenduelsApplyKorblox, tbl18.cosmeticKorblox)
                  if not screenGui.Parent then
                    return
                  end
                  pcall(_G.greenduelsApplyHat, tbl18.cosmeticHat)
                end)

                flag28 = true
                return true
              end

              fn45()
              fn67()

              _G.greenduelsRestoreLastPreset = function()
                local v91 = fn46()

                if v91 and v91 ~= "" then
                  for _, v92 in ipairs(tbl23) do
                    if v92.name == v91 then
                      pcall(function()
                        local data = v92.data or {}

                        if data.normalSpeed then
                          tbl18.normalSpeed = data.normalSpeed

                          if normalSpeed then
                            normalSpeed.Text = tostring(data.normalSpeed)
                          end
                        end

                        if data.carrySpeed then
                          tbl18.carrySpeed = data.carrySpeed

                          if carrySpeed then
                            carrySpeed.Text = tostring(data.carrySpeed)
                          end
                        end

                        if data.laggerSpeed then
                          tbl18.laggerSpeed = data.laggerSpeed

                          if laggerSpeed then
                            laggerSpeed.Text = tostring(data.laggerSpeed)
                          end
                        end

                        if data.laggerCarrySpeed then
                          tbl18.laggerCarrySpeed = data.laggerCarrySpeed

                          if laggerCarrySpeed then
                            laggerCarrySpeed.Text = tostring(data.laggerCarrySpeed)
                          end
                        end

                        if data.stealRadiiNormal ~= nil then
                          tbl22.StealRadii.Normal = tonumber(data.stealRadiiNormal)
                            or tbl22.StealRadii.Normal
                        end

                        if data.stealRadiiSemi ~= nil then
                          tbl22.StealRadii.Semi = tonumber(data.stealRadiiSemi)
                            or tbl22.StealRadii.Semi
                        end

                        if data.autoStealMode then
                          tbl18.autoStealMode = data.autoStealMode
                        end

                        if data.stealRadius then
                          tbl22.StealRadius = data.stealRadius
                          tbl22.StealRadii[tbl18.autoStealMode or "Normal"] = tonumber(
                            data.stealRadius
                          ) or tbl22.StealRadius

                          if Radius and not Radius:IsFocused() then
                            Radius.Text = tostring(tbl22.StealRadius)
                          end
                        end

                        if data.stealDuration then
                          tbl22.StealDuration = data.stealDuration

                          if Duration then
                            Duration.Text = tostring(tbl22.StealDuration)
                          end
                        end

                        if data.autoChangeSpeed ~= nil then
                          tbl18.autoChangeSpeed = data.autoChangeSpeed
                          tbl18.autoCarryOnGrab = tbl18.autoChangeSpeed
                        end

                        if data.autoLeftEnabled ~= nil then
                          tbl18.autoLeftEnabled = data.autoLeftEnabled
                        end

                        if data.autoRightEnabled ~= nil then
                          tbl18.autoRightEnabled = data.autoRightEnabled
                        end

                        if data.jumpMode ~= nil then
                          tbl18.jumpMode = data.jumpMode == "Tap" and "Tap" or "Hold"
                        end

                        if data.lineEspEnabled ~= nil then
                          tbl18.lineEspEnabled = data.lineEspEnabled
                        end

                        if data.fovValue ~= nil or data.normalFOV ~= nil then
                          tbl18.fovValue = tonumber(data.fovValue or data.normalFOV)
                            or tbl18.fovValue
                          _G._VezyFOV = tbl18.fovValue

                          if toggleSetters.fovSlider then
                            pcall(toggleSetters.fovSlider, tbl18.fovValue)
                          end
                        end

                        if data.fovEnabled ~= nil then
                          tbl18.fovEnabled = data.fovEnabled

                          if toggleSetters.fovEnabled then
                            pcall(toggleSetters.fovEnabled, tbl18.fovEnabled)
                          end
                        end

                        if data.bypassAutoBatSpeed ~= nil then
                          tbl18.bypassAutoBatSpeed = data.bypassAutoBatSpeed
                        end

                        if data.bypassLaggerAutoBatSpeed ~= nil then
                          tbl18.bypassLaggerAutoBatSpeed = data.bypassLaggerAutoBatSpeed
                        end

                        if data.safeMode ~= nil then
                          tbl18.safeMode = data.safeMode
                        end

                        if data.aimbot2Toggled ~= nil then
                          tbl18.aimbot2Toggled = data.aimbot2Toggled
                        end

                        if data.tpBatMode then
                          tbl18.tpBatMode = data.tpBatMode
                        end
                      end)

                      break
                    end
                  end
                end
              end

              _G.greenduelsRestoreLastPreset()

              _G.greenduelsRunConfigAndIntroStartup = function()
                flag26 = true
                local ok, result = pcall(fn58)
                result = ok and result or false
                flag26 = false
                local flag29 = false

                local function fn106()
                  if flag29 then
                    return
                  end
                  flag29 = true

                  task.delay(0.1, function()
                    if tbl22.AutoStealEnabled then
                      fn51()
                    end
                  end)

                  task.spawn(function()
                    task.wait(0.8)
                    semiScanAllPlots()

                    while true do
                      if screenGui.Parent and task.wait(5) then
                        if screenGui.Parent then
                          semiScanAllPlots()
                          continue
                        end
                      end

                      break
                    end
                  end)

                  task.spawn(function()
                    task.wait(3)
                    greenduelsSaveNow()

                    while screenGui.Parent do
                      task.wait(12)

                      if screenGui.Parent and flag28 then
                        greenduelsSaveNow()
                      end
                    end
                  end)
                end

                local greenduelsIntroFinished = _G.greenduelsIntroFinished

                _G.greenduelsIntroFinished = function(...)
                  if greenduelsIntroFinished then
                    pcall(greenduelsIntroFinished, ...)
                  end

                  task.defer(fn106)
                end

                if tbl18.introEnabled and not flag21 then
                  if screenGui then
                    screenGui.Enabled = false
                  end

                  if frame then
                    frame.Visible = false
                  end

                  _G.greenduelsFastIntro = false

                  task.delay(0.05, function()
                    if not pcall(greenduelsPlayIntro) then
                      pcall(_G.greenduelsIntroFinished)
                    end

                    task.delay(20, function()
                      if _G.greenduelsIntroPlaying then
                        pcall(_G.greenduelsIntroFinished)
                      end
                    end)
                  end)
                elseif tbl18.introEnabled and flag21 then
                  if _G.greenduelsIntroPlaying then
                    if screenGui then
                      screenGui.Enabled = false
                    end

                    if frame then
                      frame.Visible = false
                    end

                    task.delay(6, function()
                      if _G.greenduelsIntroPlaying then
                        pcall(_G.greenduelsIntroFinished)
                      end
                    end)
                  else
                    pcall(_G.greenduelsIntroFinished)
                  end
                else
                  pcall(_G.greenduelsIntroFinished)
                end

                if not result and isfile_("greenduels_settings.json") then
                  warn("[greenduels] Startup save skipped so existing config is not overwritten.")
                end
              end
              _G.greenduelsRunConfigAndIntroStartup()
              task.defer(function()
                task.wait(0)

                if not _G.greenduelsV2_MainExecuted then
                  if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
                    xpcall(_G.greenduelsMain, greenduelsStartupError)
                  else
                    localPlayer = localPlayer or Players:WaitForChild("LocalPlayer")
                    localPlayer:WaitForChild("PlayerGui")
                    xpcall(_G.greenduelsMain, greenduelsStartupError)
                  end
                end
                end)
              end
          end
          task.defer(function()
            xpcall(_G.greenduelsMain, greenduelsStartupError)
          end)
        end
      end
    end
  end
end
task.delay(15, function()
  local ok, playerGui = pcall(function()
    local player = game:GetService("Players").LocalPlayer
    return player and player:FindFirstChildOfClass("PlayerGui")
  end)
  if ok and playerGui and not playerGui:FindFirstChild("greenduelsV2")
      and not playerGui:FindFirstChild("greenduelsStartupError") then
    if type(_G.greenduelsMain) == "function"
        and type(_G.greenduelsRunConfigAndIntroStartup) == "function" then
      warn("[greenduels] La interfaz tarda en abrir; reintentando el inicio.")
      task.spawn(function()
        xpcall(_G.greenduelsMain, greenduelsStartupError)
      end)
      task.delay(5, function()
        if not playerGui:FindFirstChild("greenduelsV2")
            and not playerGui:FindFirstChild("greenduelsStartupError") then
          greenduelsStartupError("El menu no se pudo abrir. Copia este aviso y el texto de la consola.")
        end
      end)
    else
      greenduelsStartupError("La inicializacion se detuvo antes de crear el menu.")
    end
  end
end)

local ok, result = xpcall(runGreenduelsMain, greenduelsStartupError)
if ok then
  return result
end
