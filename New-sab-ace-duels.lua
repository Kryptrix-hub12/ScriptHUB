local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local MaterialService = game:GetService("MaterialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
_G.AceIsMobile = true
_G.AceCursedResetRemote = _G.AceCursedResetRemote or nil
_G.AceCursedResetGuid = _G.AceCursedResetGuid or "f888ee6e-c86d-46e1-93d7-0639d6635d42"
pcall(function()
if not _G.AceCursedResetHooked and hookfunction and newcclosure then
_G.AceCursedResetHooked = true
local oldFire
oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
if not _G.AceCursedResetRemote and typeof(self) == "Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3) == "RE/" then
_G.AceCursedResetRemote = self
end
return oldFire(self, ...)
end))
end
end)
function _G.AceCursedInstaReset()
if not _G.AceCursedResetRemote then
for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
if desc:IsA("RemoteEvent") and desc.Name:sub(1,3) == "RE/" then
_G.AceCursedResetRemote = desc
break
end
end
end
if not _G.AceCursedResetRemote then return end
local character = LP.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health <= 0 then
pcall(function() _G.AceCursedResetRemote:FireServer(_G.AceCursedResetGuid, LP, "balloon") end)
return
end
local resetDetected = false
local resetConns = {}
if humanoid then
table.insert(resetConns, humanoid.Died:Connect(function() resetDetected = true end))
table.insert(resetConns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
if humanoid.Health <= 0 then resetDetected = true end
end))
end
if character then
table.insert(resetConns, character.AncestryChanged:Connect(function(_, parent)
if not parent then resetDetected = true end
end))
end
task.spawn(function()
for _ = 1, 10 do
if resetDetected then break end
pcall(function() _G.AceCursedResetRemote:FireServer(_G.AceCursedResetGuid, LP, "balloon") end)
task.wait(0.05)
end
for _, conn in ipairs(resetConns) do pcall(function() conn:Disconnect() end) end
end)
end
function cursedInstaReset()
return _G.AceCursedInstaReset()
end
for _, name in ipairs({"AceDuelsAdaptReconstruct", "AdaptHubPolished", "CyberHub"}) do
local old = PlayerGui:FindFirstChild(name)
if old then old:Destroy() end
end
local NS = 59.5
local CS = 28.8
local LAGGER_SPEED = 29
local LAGGER_CARRY_SPEED = 15
local currentSpeedMode = "Normal"
autoCarrySpeedEnabled = false
setAutoCarrySpeedVisual = nil
_G.AceAutoCarryWasCarrying = false
_G.AceAutoCarrySavedMode = nil
local autoStealEnabled = false
local selectedStealMode = "Normal"
local autoStealRadius = 62
_G.AceStealRadii = _G.AceStealRadii or {Normal = 62, Semi = 9}
local autoStealRadiusBox = nil
local selectedAimbotMode = "Normal"
local AIMBOT_SPEED = 58
local LAGGER_AIMBOT_SPEED = 40
_G.AceAntiBypassAimbotSpeed = _G.AceAntiBypassAimbotSpeed or 58
if _G.AceAntiBypassLaggerAimbotSpeed == nil or tonumber(_G.AceAntiBypassLaggerAimbotSpeed) == 58 then _G.AceAntiBypassLaggerAimbotSpeed = 40 end
local autoSwingEnabled = false
local mirrorTPDownEnabled = false
_G.AceNormalAimbotOn = _G.AceNormalAimbotOn or false
_G.AceAntiBypassAimbotOn = _G.AceAntiBypassAimbotOn or false
local antiDesyncAutoSwingEnabled = false
_G.AceAntiDesyncAimbotOn = _G.AceAntiDesyncAimbotOn or false
local ANTI_DESYNC_AIMBOT_SPEED = 58
local batCounterEnabled = false
local medCounterEnabled = false
local antiKickEnabled = false
local setSafeModeVisual = nil
local autoResetOnMedEnabled = false
local espEnabled = false
local showTracerEnabled = false
local ragdollCountdownEnabled = false
local fpsBoostEnabled = false
local antiLagVisualEnabled = false
local nukeOptimiserEnabled = false
local fovEnabled = false
local fovValue = 70
local noCamCollisionEnabled = false
_G.AceNoPlayerCollisionEnabled = _G.AceNoPlayerCollisionEnabled or false
local customFontVisualEnabled = false
local skyTheme = "Off"
local setPlayerESPVisual = nil
local setTracerESPVisual = nil
local setRagdollCountdownVisual = nil
local setFPSBoostVisual = nil
local setAntiLagVisual = nil
local setNukeOptimiserVisual = nil
local setFOVVisual = nil
local setNoCamCollisionVisual = nil
_G.AceSetNoPlayerCollisionVisual = _G.AceSetNoPlayerCollisionVisual or nil
local setCustomFontVisual = nil
local skyValueLabel = nil
local autoLeftEnabled = false
local autoRightEnabled = false
local DEFAULT_SPEED_KEYBINDS = {
SpeedToggle = Enum.KeyCode.Q,
LaggerToggle = Enum.KeyCode.R,
DropBrainrot = Enum.KeyCode.X,
Aimbot = Enum.KeyCode.E,
AntiDesyncAimbot = Enum.KeyCode.V,
AutoLeft = Enum.KeyCode.Z,
AutoRight = Enum.KeyCode.C,
InstantReset = Enum.KeyCode.T,
ToggleUI = Enum.KeyCode.LeftControl,
}
local DEFAULT_TP_DOWN_KEYBIND = Enum.KeyCode.F
local speedKeybinds = {
SpeedToggle = DEFAULT_SPEED_KEYBINDS.SpeedToggle,
LaggerToggle = DEFAULT_SPEED_KEYBINDS.LaggerToggle,
DropBrainrot = DEFAULT_SPEED_KEYBINDS.DropBrainrot,
Aimbot = DEFAULT_SPEED_KEYBINDS.Aimbot,
AntiDesyncAimbot = DEFAULT_SPEED_KEYBINDS.AntiDesyncAimbot,
AutoLeft = DEFAULT_SPEED_KEYBINDS.AutoLeft,
AutoRight = DEFAULT_SPEED_KEYBINDS.AutoRight,
InstantReset = DEFAULT_SPEED_KEYBINDS.InstantReset,
ToggleUI = DEFAULT_SPEED_KEYBINDS.ToggleUI,
}
local speedKeybindButtons = {}
local listeningForSpeedKey = nil
local autoTPEnabled = false
local autoTPHeight = 20
local autoTPConn = nil
local autoTPLastRun = 0
local autoTPClickDebounce = false
local tpDownKeybind = Enum.KeyCode.F
local tpDownKeybindButton = nil
local listeningForTPDownKey = false
local keybindListenStartedAt = 0
local setAutoTPVisual = nil
local function doAutoTPDown(force)
local char=LP.Character;if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart");if not hrp then return end
local hum2=char:FindFirstChildOfClass("Humanoid");if not hum2 then return end
if not force then
if hum2.FloorMaterial~=Enum.Material.Air then return end
if hrp.Position.Y<autoTPHeight then return end
end
hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)
*CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0)
hrp.AssemblyLinearVelocity=Vector3.zero
end
local function _clearAutoTPConnection()
if autoTPConn then
pcall(function() autoTPConn:Disconnect() end)
pcall(function() task.cancel(autoTPConn) end)
autoTPConn = nil
end
end
local function startAutoTP()
autoTPEnabled = true
_clearAutoTPConnection()
autoTPLastRun = 0
autoTPConn = RunService.Heartbeat:Connect(function()
if not autoTPEnabled then
_clearAutoTPConnection()
return
end
local now = tick()
if now - autoTPLastRun < 0.1 then return end
autoTPLastRun = now
pcall(function() doAutoTPDown(false) end)
end)
if setAutoTPVisual then setAutoTPVisual(true) end
end
local function stopAutoTP()
autoTPEnabled = false
_clearAutoTPConnection()
if setAutoTPVisual then setAutoTPVisual(false) end
end
local function runTPFloor()
pcall(function() doAutoTPDown(true) end)
end
local function toggleAutoTP(on)
if on then
startAutoTP()
else
stopAutoTP()
end
saveAceConfig()
end
function _G.AceStopAutoTPForAction()
if autoTPEnabled then
stopAutoTP()
pcall(function() if setAutoTPVisual then setAutoTPVisual(false) end end)
pcall(saveAceConfig)
end
end
local dropBrainrotActive = false
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150
local function runDropBrainrot()
if dropBrainrotActive then return end
if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
dropBrainrotActive = true
local startTime = tick()
local dropConn
dropConn = RunService.Heartbeat:Connect(function()
local currentChar = LP.Character
local currentRoot = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
if not currentChar or not currentRoot then
if dropConn then dropConn:Disconnect() end
dropBrainrotActive = false
return
end
if tick() - startTime >= DROP_ASCEND_DURATION then
if dropConn then dropConn:Disconnect() end
local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = {currentChar}
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local rayResult = workspace:Raycast(currentRoot.Position, Vector3.new(0, -2000, 0), rayParams)
if rayResult then
local hum = currentChar:FindFirstChildOfClass("Humanoid")
local offset = (hum and hum.HipHeight or 2) + (currentRoot.Size.Y / 2)
currentRoot.CFrame = CFrame.new(currentRoot.Position.X, rayResult.Position.Y + offset, currentRoot.Position.Z)
currentRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
currentRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end
dropBrainrotActive = false
return
end
currentRoot.Velocity = Vector3.new(currentRoot.Velocity.X, DROP_ASCEND_SPEED, currentRoot.Velocity.Z)
end)
end
local infJumpEnabled = false
local antiRagdollEnabled = false
local antiRagdollConn = nil
local unwalkEnabled = false
local unwalkSavedAnimate = nil
local hitHarderAnimEnabled = false
local hitHarderOriginalAnims = {}
local selectedAnimationPack = "OFF"
local AnimationPacks = {
["Zombie"] = {
idle = {{"rbxassetid://616158929", 1}, {"rbxassetid://616158929", 1}},
walk = "rbxassetid://616168032", run = "rbxassetid://616163682",
jump = "rbxassetid://616161997", fall = "rbxassetid://616157476", climb = "rbxassetid://616156119"
},
["Ninja"] = {
idle = {{"rbxassetid://656117400", 1}, {"rbxassetid://656117400", 1}},
walk = "rbxassetid://656121766", run = "rbxassetid://656118852",
jump = "rbxassetid://656117878", fall = "rbxassetid://656115606", climb = "rbxassetid://656114359"
},
["Knight"] = {
idle = {{"rbxassetid://657595757", 1}, {"rbxassetid://657595757", 1}},
walk = "rbxassetid://657552124", run = "rbxassetid://657564596",
jump = "rbxassetid://658409194", fall = "rbxassetid://657600338", climb = "rbxassetid://658360781"
},
["Elder"] = {
idle = {{"rbxassetid://845397899", 1}, {"rbxassetid://845397899", 1}},
walk = "rbxassetid://845403856", run = "rbxassetid://845386501",
jump = "rbxassetid://845398858", fall = "rbxassetid://845397673", climb = "rbxassetid://845392038"
},
["Levitate"] = {
idle = {{"rbxassetid://616006778", 1}, {"rbxassetid://616006778", 1}},
walk = "rbxassetid://616013216", run = "rbxassetid://616013216",
jump = "rbxassetid://616008936", fall = "rbxassetid://616005863", climb = "rbxassetid://616003713"
},
["Astronaut"] = {
idle = {{"rbxassetid://891621366", 1}, {"rbxassetid://891621366", 1}},
walk = "rbxassetid://891636393", run = "rbxassetid://891636393",
jump = "rbxassetid://891627522", fall = "rbxassetid://891617961", climb = "rbxassetid://891609353"
},
["Pirate"] = {
idle = {{"rbxassetid://750781874", 1}, {"rbxassetid://750781874", 1}},
walk = "rbxassetid://750785693", run = "rbxassetid://750783738",
jump = "rbxassetid://750782230", fall = "rbxassetid://750780242", climb = "rbxassetid://750779899"
},
["Toy"] = {
idle = {{"rbxassetid://782841498", 1}, {"rbxassetid://782841498", 1}},
walk = "rbxassetid://782843345", run = "rbxassetid://782842708",
jump = "rbxassetid://782847020", fall = "rbxassetid://782846423", climb = "rbxassetid://782843869"
},
["Vampire"] = {
idle = {{"rbxassetid://1083445855", 1}, {"rbxassetid://1083445855", 1}},
walk = "rbxassetid://1083473930", run = "rbxassetid://1083462077",
jump = "rbxassetid://1083455352", fall = "rbxassetid://1083443587", climb = "rbxassetid://1083439238"
},
["Werewolf"] = {
idle = {{"rbxassetid://1083195517", 1}, {"rbxassetid://1083195517", 1}},
walk = "rbxassetid://1083178339", run = "rbxassetid://1083216690",
jump = "rbxassetid://1083218792", fall = "rbxassetid://1083189019", climb = "rbxassetid://1083182000"
},
["Rthro"] = {
idle = {{"rbxassetid://2510196951", 1}, {"rbxassetid://2510196951", 1}},
walk = "rbxassetid://2510202577", run = "rbxassetid://2510198475",
jump = "rbxassetid://2510197830", fall = "rbxassetid://2510195892", climb = "rbxassetid://2510192778"
},
["Stylish"] = {
idle = {{"rbxassetid://616136790", 1}, {"rbxassetid://616136790", 1}},
walk = "rbxassetid://616146177", run = "rbxassetid://616140816",
jump = "rbxassetid://616139451", fall = "rbxassetid://616134815", climb = "rbxassetid://616133594"
},
}
local AnimationPackList = {"OFF", "Unwalk", "Hit Harder", "Zombie", "Ninja", "Knight", "Elder", "Levitate", "Astronaut", "Pirate", "Toy", "Vampire", "Werewolf", "Rthro", "Stylish"}
local AnimationPackIndex = 1
local OriginalAnims = {}
local enableUnwalk, disableUnwalk, enableHitHarderAnim, disableHitHarderAnim
local HIT_HARDER_ANIMS = {
idle1 = "rbxassetid://133806214992291",
idle2 = "rbxassetid://94970088341563",
walk = "rbxassetid://707897309",
run = "rbxassetid://707861613",
jump = "rbxassetid://116936326516985",
fall = "rbxassetid://116936326516985",
}
local function getAnimate(char)
char = char or LP.Character
return char and char:FindFirstChild("Animate") or nil
end
local function stopCurrentAnimations(char)
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum then return end
for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
pcall(function() track:Stop(0) end)
end
end
local function backupAnimations(char)
local animate = getAnimate(char)
if not animate or next(OriginalAnims) ~= nil then return end
local function getId(obj) return obj and obj.AnimationId or nil end
OriginalAnims = {
idle1 = getId(animate.idle and animate.idle:FindFirstChild("Animation1")),
idle2 = getId(animate.idle and animate.idle:FindFirstChild("Animation2")),
walk = getId(animate.walk and animate.walk:FindFirstChild("WalkAnim")),
run = getId(animate.run and animate.run:FindFirstChild("RunAnim")),
jump = getId(animate.jump and animate.jump:FindFirstChild("JumpAnim")),
fall = getId(animate.fall and animate.fall:FindFirstChild("FallAnim")),
climb = getId(animate.climb and animate.climb:FindFirstChild("ClimbAnim")),
}
end
local function setAnimId(obj, id)
if obj and id then pcall(function() obj.AnimationId = id end) end
end
local function reloadAnimate(animate)
if not animate then return end
pcall(function()
animate.Disabled = true
task.wait()
animate.Disabled = false
end)
end
local function resetAnimations()
local char = LP.Character
local animate = getAnimate(char)
if not animate or next(OriginalAnims) == nil then return end
stopCurrentAnimations(char)
setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), OriginalAnims.idle1)
setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), OriginalAnims.idle2)
setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), OriginalAnims.walk)
setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), OriginalAnims.run)
setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), OriginalAnims.jump)
setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), OriginalAnims.fall)
setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"), OriginalAnims.climb)
reloadAnimate(animate)
end
local function applyAnimationPack(packName)
selectedAnimationPack = packName or "OFF"
if selectedAnimationPack ~= "Unwalk" and unwalkEnabled then
disableUnwalk()
end
if selectedAnimationPack ~= "Hit Harder" and hitHarderAnimEnabled then
hitHarderAnimEnabled = false
resetAnimations()
end
if selectedAnimationPack == "Unwalk" then
resetAnimations()
enableUnwalk()
return
end
if selectedAnimationPack == "Hit Harder" then
disableUnwalk()
enableHitHarderAnim()
return
end
if selectedAnimationPack == "OFF" then
resetAnimations()
return
end
local pack = AnimationPacks[selectedAnimationPack]
local char = LP.Character
local animate = getAnimate(char)
if not pack or not animate then return end
backupAnimations(char)
stopCurrentAnimations(char)
setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), pack.idle[1][1])
setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), pack.idle[2][1])
setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), pack.walk)
setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), pack.run)
setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), pack.jump)
setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), pack.fall)
setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"), pack.climb)
reloadAnimate(animate)
end
enableUnwalk = function()
unwalkEnabled = true
local char = LP.Character
local animate = getAnimate(char)
if animate then
if not unwalkSavedAnimate then
unwalkSavedAnimate = animate:Clone()
end
stopCurrentAnimations(char)
animate:Destroy()
end
end
disableUnwalk = function()
unwalkEnabled = false
local char = LP.Character
if char and not char:FindFirstChild("Animate") and unwalkSavedAnimate then
local newAnimate = unwalkSavedAnimate:Clone()
newAnimate.Parent = char
end
end
enableHitHarderAnim = function()
hitHarderAnimEnabled = true
local char = LP.Character
local animate = getAnimate(char)
if not animate then return end
backupAnimations(char)
stopCurrentAnimations(char)
setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), HIT_HARDER_ANIMS.idle1)
setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), HIT_HARDER_ANIMS.idle2)
setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), HIT_HARDER_ANIMS.walk)
setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), HIT_HARDER_ANIMS.run)
setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), HIT_HARDER_ANIMS.jump)
setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), HIT_HARDER_ANIMS.fall)
reloadAnimate(animate)
end
disableHitHarderAnim = function()
hitHarderAnimEnabled = false
resetAnimations()
if selectedAnimationPack ~= "OFF" then
task.wait()
applyAnimationPack(selectedAnimationPack)
end
end
local function startAntiRagdoll()
if antiRagdollConn then return end
antiRagdollConn = RunService.Heartbeat:Connect(function()
if not antiRagdollEnabled then return end
local char = LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
local root = char:FindFirstChild("HumanoidRootPart")
if not (hum and root) then return end
local s = hum:GetState()
local ragdolled = (
s == Enum.HumanoidStateType.Physics
or s == Enum.HumanoidStateType.Ragdoll
or s == Enum.HumanoidStateType.FallingDown
)
local endTime = LP:GetAttribute("RagdollEndTime")
if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
ragdolled = true
end
if ragdolled then
pcall(function()
LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
end)
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("BallSocketConstraint") or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
pcall(function() d:Destroy() end)
end
end
for _, obj in ipairs(char:GetDescendants()) do
if obj:IsA("Motor6D") and obj.Enabled == false then
obj.Enabled = true
end
end
if hum.Health > 0 then
hum:ChangeState(Enum.HumanoidStateType.Running)
end
workspace.CurrentCamera.CameraSubject = hum
root.Anchored = false
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
end)
end
local function stopAntiRagdoll()
if antiRagdollConn then
antiRagdollConn:Disconnect()
antiRagdollConn = nil
end
end
local function setAntiRagdoll(on)
antiRagdollEnabled = on and true or false
if antiRagdollEnabled then
startAntiRagdoll()
else
stopAntiRagdoll()
end
end
_G.AceNormalInfJump = _G.AceNormalInfJump or {holdPressed=false, holdActive=false, controllerActive=false, mobilePressed=false, mobileActive=false, hooked={}}
function _G.AceStopNormalInfJumpHoldState()
local S = _G.AceNormalInfJump
S.holdPressed = false
S.holdActive = false
S.controllerActive = false
S.mobilePressed = false
S.mobileActive = false
end
function _G.AceApplyNormalInfJumpBoost(boost)
if not infJumpEnabled then return end
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then return end
root.Velocity = Vector3.new(root.Velocity.X, boost or 50, root.Velocity.Z)
end
UserInputService.JumpRequest:Connect(function()
_G.AceApplyNormalInfJumpBoost(50)
end)
UserInputService.InputBegan:Connect(function(input)
if UserInputService:GetFocusedTextBox() then return end
local S = _G.AceNormalInfJump
if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
S.holdPressed = true
task.delay(0.12, function()
if _G.AceNormalInfJump.holdPressed and infJumpEnabled then
_G.AceNormalInfJump.holdActive = true
_G.AceApplyNormalInfJumpBoost(50)
end
end)
elseif input.KeyCode == Enum.KeyCode.ButtonA and input.UserInputType.Name:match("^Gamepad") then
S.controllerActive = true
end
end)
UserInputService.InputEnded:Connect(function(input)
local S = _G.AceNormalInfJump
if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
S.holdPressed = false
S.holdActive = false
end
if input.KeyCode == Enum.KeyCode.ButtonA and input.UserInputType.Name:match("^Gamepad") then
S.controllerActive = false
end
end)
function _G.AceHookNormalInfMobileJumpButton(obj)
local S = _G.AceNormalInfJump
if not obj or obj.Name ~= "JumpButton" or not obj:IsA("GuiButton") or S.hooked[obj] then return end
S.hooked[obj] = true
obj.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.Touch or not infJumpEnabled then return end
_G.AceNormalInfJump.mobilePressed = true
task.delay(0.12, function()
if _G.AceNormalInfJump.mobilePressed and infJumpEnabled then
_G.AceNormalInfJump.mobileActive = true
_G.AceApplyNormalInfJumpBoost(50)
end
end)
end)
obj.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.Touch then
_G.AceNormalInfJump.mobilePressed = false
_G.AceNormalInfJump.mobileActive = false
end
end)
obj.AncestryChanged:Connect(function(_, parent)
if not parent then
_G.AceNormalInfJump.hooked[obj] = nil
_G.AceNormalInfJump.mobilePressed = false
_G.AceNormalInfJump.mobileActive = false
end
end)
end
for _, obj in ipairs(PlayerGui:GetDescendants()) do
_G.AceHookNormalInfMobileJumpButton(obj)
end
PlayerGui.DescendantAdded:Connect(function(obj)
task.defer(_G.AceHookNormalInfMobileJumpButton, obj)
end)
RunService.Heartbeat:Connect(function()
local S = _G.AceNormalInfJump
if infJumpEnabled and (S.holdActive or S.mobileActive or S.controllerActive) then
_G.AceApplyNormalInfJumpBoost(50)
end
end)
setInfJumpInternal = function(on)
infJumpEnabled = on and true or false
if not infJumpEnabled then
_G.AceStopNormalInfJumpHoldState()
end
end
local currentBackground = 0
local aceGuiScaleValue = 0.52
local aceProgressBarScaleValue = 0.83
CONFIG_FILE = "AceDuels_MainGUI_Config_DefaultsV2.json"
KEYBINDS_CONFIG_FILE = "AceDuels_Keybinds_DefaultsV2.json"
_ace_isfile = isfile or (syn and syn.isfile) or function(path)
local ok, result = pcall(function() return readfile(path) end)
return ok and result ~= nil
end
_ace_readfile = readfile or (syn and syn.readfile)
_ace_writefile = writefile or (syn and syn.writefile)
canSaveConfig = (type(_ace_readfile) == "function" and type(_ace_writefile) == "function")

--// Ace Duels Intro + Songs (ported from old source only)
selectedIntroMusic = selectedIntroMusic or 1
_introEnabled = (_introEnabled ~= false)
setIntroVisual = nil
setIntroSongVisual = nil
INTRO_MUSIC_OPTIONS = INTRO_MUSIC_OPTIONS or {
{name="Song 1", url="https://files.catbox.moe/mzvrir.mp3", file="AceDuelsIntroSong_1.mp3"},
{name="Song 2", url="https://files.catbox.moe/2a7jyx.mp3", file="AceDuelsIntroSong_2.mp3"},
{name="Song 3", url="https://files.catbox.moe/rcgr9f.mp3", file="AceDuelsIntroSong_3.mp3"},
{name="Song 4", url="https://files.catbox.moe/iknfuh.mp3", file="AceDuelsIntroSong_4.mp3"},
{name="Song 5", url="https://files.catbox.moe/6eigoh.mp3", file="AceDuelsIntroSong_5.mp3"},
{name="Song 6", url="https://files.catbox.moe/dvjtjk.mp3", file="AceDuelsIntroSong_6.mp3"},
{name="Song 7", url="https://files.catbox.moe/iyw1cb.mp3", file="AceDuelsIntroSong_7.mp3"},
}
function getIntroSongName()
local opt = INTRO_MUSIC_OPTIONS[selectedIntroMusic]
return opt and opt.name or "No Songs Added"
end
introPreviewSound = nil
introPlaybackSound = nil
introPreviewToken = 0
introPlaybackToken = 0
introSongCache = introSongCache or {}
introSongDownloading = introSongDownloading or {}
function stopIntroPreview()
introPreviewToken = introPreviewToken + 1
if introPreviewSound then
pcall(function() introPreviewSound:Stop() end)
pcall(function() introPreviewSound:Destroy() end)
introPreviewSound = nil
end
end
function stopIntroPlayback()
introPlaybackToken = introPlaybackToken + 1
if introPlaybackSound then
pcall(function() introPlaybackSound:Stop() end)
pcall(function() introPlaybackSound:Destroy() end)
introPlaybackSound = nil
end
end
function _safeNotify(msg)
if showActionNotification then pcall(function() showActionNotification(msg) end) end
end
function cacheIntroSong(option, allowDownload)
if not option or not option.url or option.url == "" then return nil end
if not (writefile and getcustomasset) then return nil end
local fileName = option.file or ("AceDuelsIntroSong_" .. tostring(option.name or "song") .. ".mp3")
local function loadExisting()
if introSongCache[fileName] then return introSongCache[fileName] end
local hasFile = false
pcall(function() hasFile = isfile and isfile(fileName) end)
if hasFile then
local ok = pcall(function() introSongCache[fileName] = getcustomasset(fileName) end)
if ok and introSongCache[fileName] then return introSongCache[fileName] end
end
return nil
end
local cached = loadExisting()
if cached then return cached end
if allowDownload == false then return nil end
if introSongDownloading[fileName] then
local waitStart = tick()
while introSongDownloading[fileName] and tick() - waitStart < 12 do task.wait(0.05) end
cached = loadExisting()
if cached then return cached end
end
introSongDownloading[fileName] = true
local ok = pcall(function()
local data = game:HttpGet(option.url)
if data and #data > 0 then
writefile(fileName, data)
introSongCache[fileName] = getcustomasset(fileName)
end
end)
introSongDownloading[fileName] = nil
if ok and introSongCache[fileName] then return introSongCache[fileName] end
return loadExisting()
end
function preloadIntroSongs()
task.spawn(function()
cacheIntroSong(INTRO_MUSIC_OPTIONS[selectedIntroMusic], true)
for _, option in ipairs(INTRO_MUSIC_OPTIONS) do
if option ~= INTRO_MUSIC_OPTIONS[selectedIntroMusic] then
cacheIntroSong(option, true)
task.wait(0.05)
end
end
end)
end
function makeIntroSoundFromId(soundId, name, parent)
if not soundId then return nil end
local sound = Instance.new("Sound")
sound.Name = name or "AceDuelsIntroMusic"
sound.Volume = 0.65
sound.Looped = false
sound.SoundId = soundId
sound.Parent = parent or SoundService
return sound
end
function createIntroSound(option, fileName, parent, allowDownload)
if not option then return nil end
local soundId = cacheIntroSong(option, allowDownload)
if not soundId then return nil end
return makeIntroSoundFromId(soundId, fileName, parent)
end
function previewIntroMusic(index)
stopIntroPreview()
stopIntroPlayback()
if not INTRO_MUSIC_OPTIONS[index] then _safeNotify("ADD SONG LINKS"); return end
local token = introPreviewToken
task.spawn(function()
local option = INTRO_MUSIC_OPTIONS[index]
local sound = createIntroSound(option, "AceDuelsIntroPreview_" .. tostring(token), SoundService, true)
if token ~= introPreviewToken then if sound then sound:Destroy() end; return end
introPreviewSound = sound
if not sound then _safeNotify("SONG LOADING..."); return end
sound.TimePosition = 0
pcall(function() sound:Play() end)
task.delay(15, function() if token == introPreviewToken then stopIntroPreview() end end)
end)
end
function playIntroMusic()
stopIntroPreview()
stopIntroPlayback()
if not _introEnabled then return end
local option = INTRO_MUSIC_OPTIONS[selectedIntroMusic]
if not option then return end
local token = introPlaybackToken
task.spawn(function()
local sound = createIntroSound(option, "AceDuelsIntroMusic_" .. tostring(token), SoundService, true)
if token ~= introPlaybackToken or not _introEnabled then if sound then pcall(function() sound:Destroy() end) end; return end
introPlaybackSound = sound
if not sound then _safeNotify("SONG FAILED"); return end
sound.TimePosition = 0
local loadStart = tick()
while sound and not sound.IsLoaded and tick() - loadStart < 10 do task.wait(0.05) end
pcall(function() sound:Play() end)
task.delay(15, function() if token == introPlaybackToken then stopIntroPlayback() end end)
end)
end
preloadIntroSongs()

savedConfig = {}
_G.AceGuiLocked = _G.AceGuiLocked == true
_G.AceHideMobileButtons = _G.AceHideMobileButtons == true
_G.AceMobileButtonScale = 0.75
_G.AceMobileButtonPositions = _G.AceMobileButtonPositions or {}
savedMainPositionTable = nil
savedMiniPositionTable = nil
function udim2ToTable(u)
return {xs = u.X.Scale, xo = u.X.Offset, ys = u.Y.Scale, yo = u.Y.Offset}
end
function tableToUDim2(t, fallback)
if type(t) == "table" then
return UDim2.new(tonumber(t.xs) or 0, tonumber(t.xo) or 0, tonumber(t.ys) or 0, tonumber(t.yo) or 0)
end
return fallback
end
function collectAceMobileButtonPositions()
local out = {}
for key, entry in pairs(_G.AceMobileButtonRefs or {}) do
local holder = entry and entry.holder
if holder then out[key] = udim2ToTable(holder.Position) end
end
if next(out) == nil and type(_G.AceMobileButtonPositions) == "table" then
return _G.AceMobileButtonPositions
end
_G.AceMobileButtonPositions = out
return out
end
function keyToString(key)
if not key then return "None" end
return tostring(key):gsub("Enum.KeyCode.", "")
end
function stringToKeyCode(value)
if type(value) ~= "string" or value == "" or value == "None" then return nil end
return Enum.KeyCode[value]
end
function keybindsToTable()
local out = {}
for keyId in pairs(DEFAULT_SPEED_KEYBINDS) do
out[keyId] = keyToString(speedKeybinds[keyId])
end
for keyId, key in pairs(speedKeybinds) do
out[keyId] = keyToString(key)
end
return out
end
function collectAceKeybindConfig()
return {
keybinds = keybindsToTable(),
tpDownKeybind = keyToString(tpDownKeybind),
}
end
function applySavedKeybinds(t)
if type(t) ~= "table" then return end
for keyId in pairs(speedKeybinds) do
if t[keyId] ~= nil then
speedKeybinds[keyId] = stringToKeyCode(t[keyId])
end
end
end
function applyDefaultAceKeybinds()
for keyId, key in pairs(DEFAULT_SPEED_KEYBINDS) do
speedKeybinds[keyId] = key
end
tpDownKeybind = DEFAULT_TP_DOWN_KEYBIND
end
function collectAceConfig()
return {
mainPosition = savedMainPositionTable,
keybinds = keybindsToTable(),
tpDownKeybind = keyToString(tpDownKeybind),
NS = NS,
CS = CS,
LAGGER_SPEED = LAGGER_SPEED,
LAGGER_CARRY_SPEED = LAGGER_CARRY_SPEED,
currentSpeedMode = currentSpeedMode,
autoCarrySpeedEnabled = autoCarrySpeedEnabled == true,
autoTPEnabled = autoTPEnabled,
autoTPHeight = autoTPHeight,
infJumpEnabled = infJumpEnabled,
antiRagdollEnabled = antiRagdollEnabled,
selectedAnimationPack = selectedAnimationPack,
selectedStealMode = selectedStealMode,
autoStealEnabled = autoStealEnabled,
autoStealRadius = autoStealRadius,
aceStealRadii = _G.AceStealRadii,
selectedAimbotMode = selectedAimbotMode,
AIMBOT_SPEED = AIMBOT_SPEED,
LAGGER_AIMBOT_SPEED = LAGGER_AIMBOT_SPEED,
ANTI_BYPASS_AIMBOT_SPEED = _G.AceAntiBypassAimbotSpeed,
ANTI_BYPASS_LAGGER_AIMBOT_SPEED = _G.AceAntiBypassLaggerAimbotSpeed,
ANTI_DESYNC_AIMBOT_SPEED = ANTI_DESYNC_AIMBOT_SPEED,
autoSwingEnabled = autoSwingEnabled,
mirrorTPDownEnabled = mirrorTPDownEnabled,
normalAimbotEnabled = _G.AceNormalAimbotOn == true,
antiBypassAimbotEnabled = _G.AceAntiBypassAimbotOn == true,
antiDesyncAutoSwingEnabled = antiDesyncAutoSwingEnabled,
antiDesyncAimbotEnabled = _G.AceAntiDesyncAimbotOn == true,
batCounterEnabled = batCounterEnabled,
medCounterEnabled = medCounterEnabled,
safeMode = antiKickEnabled == true,
autoResetOnMedEnabled = autoResetOnMedEnabled,
espEnabled = espEnabled,
showTracerEnabled = showTracerEnabled,
ragdollCountdownEnabled = ragdollCountdownEnabled,
fpsBoostEnabled = fpsBoostEnabled,
antiLagVisualEnabled = antiLagVisualEnabled,
nukeOptimiserEnabled = nukeOptimiserEnabled,
fovEnabled = fovEnabled,
fovValue = fovValue,
noCamCollisionEnabled = noCamCollisionEnabled,
noPlayerCollisionEnabled = _G.AceNoPlayerCollisionEnabled,
customFontVisualEnabled = false,
skyTheme = skyTheme,
autoLeftEnabled = autoLeftEnabled,
autoRightEnabled = autoRightEnabled,
currentBackground = currentBackground,
aceGuiScaleValue = aceGuiScaleValue,
aceProgressBarScaleValue = aceProgressBarScaleValue,
introEnabled = _introEnabled == true,
selectedIntroMusic = selectedIntroMusic,
guiLocked = _G.AceGuiLocked == true,
hideMobileButtons = _G.AceHideMobileButtons == true,
aceMobileButtonScale = _G.AceMobileButtonScale,
mobileButtonPositions = collectAceMobileButtonPositions(),
}
end
function saveAceConfig()
if not canSaveConfig then return end
pcall(function()
_ace_writefile(CONFIG_FILE, HttpService:JSONEncode(collectAceConfig()))
_ace_writefile(KEYBINDS_CONFIG_FILE, HttpService:JSONEncode(collectAceKeybindConfig()))
end)
end
function loadAceConfig()
if not canSaveConfig or not _ace_isfile(CONFIG_FILE) then return end
local ok, data = pcall(function()
return HttpService:JSONDecode(_ace_readfile(CONFIG_FILE))
end)
if not ok or type(data) ~= "table" then return end
savedConfig = data
local keybindData = data
pcall(function()
if _ace_isfile(KEYBINDS_CONFIG_FILE) then
local kb = HttpService:JSONDecode(_ace_readfile(KEYBINDS_CONFIG_FILE))
if type(kb) == "table" then keybindData = kb end
end
end)
savedMainPositionTable = data.mainPosition
savedMiniPositionTable = nil
_G.AceGuiLocked = data.guiLocked == true
_G.AceHideMobileButtons = data.hideMobileButtons == true
_G.AceMobileButtonScale = math.clamp(tonumber(data.aceMobileButtonScale) or tonumber(_G.AceMobileButtonScale) or 0.75, 0.30, 1.35)
_G.AceMobileButtonPositions = type(data.mobileButtonPositions) == "table" and data.mobileButtonPositions or {}
applySavedKeybinds(keybindData.keybinds)
if keybindData.tpDownKeybind ~= nil then
if tostring(keybindData.tpDownKeybind) == "None" then
tpDownKeybind = nil
else
tpDownKeybind = stringToKeyCode(keybindData.tpDownKeybind) or DEFAULT_TP_DOWN_KEYBIND
end
end
for keyId, defaultKey in pairs(DEFAULT_SPEED_KEYBINDS) do
local savedKeys = keybindData and keybindData.keybinds
if (not savedKeys or savedKeys[keyId] == nil) and speedKeybinds[keyId] == nil then
speedKeybinds[keyId] = defaultKey
end
end
NS = tonumber(data.NS) or NS
CS = tonumber(data.CS) or CS
LAGGER_SPEED = tonumber(data.LAGGER_SPEED) or LAGGER_SPEED
LAGGER_CARRY_SPEED = tonumber(data.LAGGER_CARRY_SPEED) or LAGGER_CARRY_SPEED
currentSpeedMode = data.currentSpeedMode or currentSpeedMode
if currentSpeedMode ~= "Normal" and currentSpeedMode ~= "Carry" and currentSpeedMode ~= "Lagger" and currentSpeedMode ~= "Lagger Carry" then currentSpeedMode = "Normal" end
autoCarrySpeedEnabled = data.autoCarrySpeedEnabled == true
autoTPEnabled = data.autoTPEnabled == true
autoTPHeight = tonumber(data.autoTPHeight) or autoTPHeight
infJumpEnabled = data.infJumpEnabled == true
antiRagdollEnabled = data.antiRagdollEnabled == true
selectedAnimationPack = data.selectedAnimationPack or selectedAnimationPack
selectedStealMode = data.selectedStealMode or selectedStealMode
if selectedStealMode ~= "Semi" then selectedStealMode = "Normal" end
autoStealEnabled = data.autoStealEnabled == true
if type(data.aceStealRadii) == "table" then
_G.AceStealRadii.Normal = tonumber(data.aceStealRadii.Normal) or _G.AceStealRadii.Normal or 62
_G.AceStealRadii.Semi = tonumber(data.aceStealRadii.Semi) or _G.AceStealRadii.Semi or 9
end
autoStealRadius = tonumber(data.autoStealRadius) or autoStealRadius
if selectedStealMode == "Normal" then
_G.AceStealRadii.Normal = tonumber(autoStealRadius) or _G.AceStealRadii.Normal or 62
autoStealRadius = _G.AceStealRadii.Normal
else
autoStealRadius = _G.AceStealRadii.Semi or 9
end
selectedAimbotMode = data.selectedAimbotMode or selectedAimbotMode
if selectedAimbotMode ~= "Anti Bypass" then selectedAimbotMode = "Normal" end
AIMBOT_SPEED = tonumber(data.AIMBOT_SPEED) or AIMBOT_SPEED
LAGGER_AIMBOT_SPEED = tonumber(data.LAGGER_AIMBOT_SPEED) or LAGGER_AIMBOT_SPEED
_G.AceAntiBypassAimbotSpeed = tonumber(data.ANTI_BYPASS_AIMBOT_SPEED) or _G.AceAntiBypassAimbotSpeed or 58
if data.ANTI_BYPASS_LAGGER_AIMBOT_SPEED == nil or tonumber(data.ANTI_BYPASS_LAGGER_AIMBOT_SPEED) == 58 then
_G.AceAntiBypassLaggerAimbotSpeed = 40
else
_G.AceAntiBypassLaggerAimbotSpeed = tonumber(data.ANTI_BYPASS_LAGGER_AIMBOT_SPEED) or 40
end
ANTI_DESYNC_AIMBOT_SPEED = tonumber(data.ANTI_DESYNC_AIMBOT_SPEED) or ANTI_DESYNC_AIMBOT_SPEED or 58
autoSwingEnabled = data.autoSwingEnabled == true
mirrorTPDownEnabled = data.mirrorTPDownEnabled == true
_G.AceNormalAimbotOn = data.normalAimbotEnabled == true
_G.AceAntiBypassAimbotOn = data.antiBypassAimbotEnabled == true
antiDesyncAutoSwingEnabled = data.antiDesyncAutoSwingEnabled == true
_G.AceAntiDesyncAimbotOn = data.antiDesyncAimbotEnabled == true
batCounterEnabled = data.batCounterEnabled == true
medCounterEnabled = data.medCounterEnabled == true
antiKickEnabled = data.safeMode == true
autoResetOnMedEnabled = data.autoResetOnMedEnabled == true
espEnabled = data.espEnabled == true
showTracerEnabled = data.showTracerEnabled == true
ragdollCountdownEnabled = data.ragdollCountdownEnabled == true
fpsBoostEnabled = data.fpsBoostEnabled == true
antiLagVisualEnabled = data.antiLagVisualEnabled == true
nukeOptimiserEnabled = data.nukeOptimiserEnabled == true
fovEnabled = data.fovEnabled == true
fovValue = tonumber(data.fovValue) or fovValue
noCamCollisionEnabled = data.noCamCollisionEnabled == true
_G.AceNoPlayerCollisionEnabled = data.noPlayerCollisionEnabled == true
customFontVisualEnabled = false
skyTheme = (type(data.skyTheme) == "string" and data.skyTheme) or skyTheme
autoLeftEnabled = data.autoLeftEnabled == true
autoRightEnabled = data.autoRightEnabled == true
if data.introEnabled ~= nil then _introEnabled = data.introEnabled == true end
if data.selectedIntroMusic and INTRO_MUSIC_OPTIONS[data.selectedIntroMusic] then selectedIntroMusic = data.selectedIntroMusic end
if autoLeftEnabled and autoRightEnabled then autoRightEnabled = false end
end
loadAceConfig()
local function syncAnimationPackIndex()
for i, name in ipairs(AnimationPackList) do
if name == selectedAnimationPack then
AnimationPackIndex = i
return
end
end
selectedAnimationPack = "OFF"
AnimationPackIndex = 1
end
local function applySavedAnimationPackToCharacter(char)
syncAnimationPackIndex()
if refreshAnimationPackRow then pcall(refreshAnimationPackRow) end
if not char then char = LP.Character end
if not char then return end
local animate = char:FindFirstChild("Animate") or char:WaitForChild("Animate", 6)
if not animate then return end
task.wait(0.2)
OriginalAnims = {}
unwalkSavedAnimate = nil
if selectedAnimationPack and selectedAnimationPack ~= "OFF" then
pcall(function() applyAnimationPack(selectedAnimationPack) end)
else
pcall(function() resetAnimations() end)
end
end
syncAnimationPackIndex()
task.defer(function()
applySavedAnimationPackToCharacter(LP.Character)
end)
LP.CharacterAdded:Connect(function(char)
task.wait(0.65)
applySavedAnimationPackToCharacter(char)
end)
_G.AceAutoResetOnMed = _G.AceAutoResetOnMed or {}
_G.AceAutoResetOnMed.conns = _G.AceAutoResetOnMed.conns or {}
_G.AceAutoResetOnMed.enabled = autoResetOnMedEnabled == true
_G.AceAutoResetOnMed.medTriggered = false
_G.AceAutoResetOnMed.lastFire = _G.AceAutoResetOnMed.lastFire or 0
_G.AceAutoResetOnMed.cooldown = 2.25
_G.AceAutoResetOnMed.charAddedConn = _G.AceAutoResetOnMed.charAddedConn
_G.AceCursedResetGuid = _G.AceCursedResetGuid or "f888ee6e-c86d-46e1-93d7-0639d6635d42"
_G.AceCursedResetRemote = _G.AceCursedResetRemote or nil
pcall(function()
if hookfunction and newcclosure and not _G.AceCursedResetHooked and not _G.AceAutoResetOnMed.remoteHooked then
_G.AceAutoResetOnMed.remoteHooked = true
local oldFire
oldFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
if not _G.AceCursedResetRemote
and typeof(self) == "Instance"
and self:IsA("RemoteEvent")
and self.Name:sub(1, 3) == "RE/" then
_G.AceCursedResetRemote = self
end
return oldFire(self, ...)
end))
end
end)
function _G.AceFindCursedResetRemote()
if _G.AceCursedResetRemote then return _G.AceCursedResetRemote end
for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
if desc:IsA("RemoteEvent") and desc.Name:sub(1, 3) == "RE/" then
_G.AceCursedResetRemote = desc
break
end
end
return _G.AceCursedResetRemote
end
function _G.AceAutoResetCursedInstaReset()
local remote = _G.AceFindCursedResetRemote and _G.AceFindCursedResetRemote() or _G.AceCursedResetRemote
if not remote then return end
local character = LP.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health <= 0 then
pcall(function()
remote:FireServer(_G.AceCursedResetGuid, LP, "balloon")
end)
return
end
local resetDetected = false
local resetConns = {}
if humanoid then
table.insert(resetConns, humanoid.Died:Connect(function()
resetDetected = true
end))
table.insert(resetConns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
if humanoid.Health <= 0 then
resetDetected = true
end
end))
end
if character then
table.insert(resetConns, character.AncestryChanged:Connect(function(_, parent)
if not parent then
resetDetected = true
end
end))
end
task.spawn(function()
for _ = 1, 10 do
if resetDetected then break end
pcall(function()
remote:FireServer(_G.AceCursedResetGuid, LP, "balloon")
end)
task.wait(0.05)
end
for _, conn in ipairs(resetConns) do
pcall(function()
conn:Disconnect()
end)
end
end)
end
function _G.AceAutoResetShouldFire(part)
local state = _G.AceAutoResetOnMed
if not state or not state.enabled then return false end
if state.medTriggered then return false end
if tick() - (state.lastFire or 0) < (state.cooldown or 2.25) then return false end
if not part or not part.Parent then return false end
if part:FindFirstAncestorOfClass("Tool") or part:FindFirstAncestorOfClass("Accessory") then
return false
end
return part.Anchored and part.Transparency == 1
end
function _G.AceAutoResetFireOnce(part)
if not _G.AceAutoResetShouldFire(part) then return end
local state = _G.AceAutoResetOnMed
state.medTriggered = true
state.lastFire = tick()
task.delay(2.3, function()
if state.enabled then
if _G.AceAutoResetCursedInstaReset then
_G.AceAutoResetCursedInstaReset()
elseif cursedInstaReset then
cursedInstaReset()
end
end
end)
end
function _G.AceAutoResetOnAnchorChanged(part)
return part:GetPropertyChangedSignal("Anchored"):Connect(function()
_G.AceAutoResetFireOnce(part)
end)
end
function _G.AceStopAutoResetOnMed()
local state = _G.AceAutoResetOnMed
if not state then return end
for _, conn in ipairs(state.conns or {}) do
pcall(function()
conn:Disconnect()
end)
end
state.conns = {}
state.medTriggered = false
end
function _G.AceStartAutoResetOnMed(char)
local state = _G.AceAutoResetOnMed
if not state then return end
_G.AceStopAutoResetOnMed()
state.medTriggered = false
char = char or LP.Character
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then
table.insert(state.conns, _G.AceAutoResetOnAnchorChanged(part))
_G.AceAutoResetFireOnce(part)
end
end
table.insert(state.conns, char.DescendantAdded:Connect(function(part)
if part:IsA("BasePart") then
table.insert(state.conns, _G.AceAutoResetOnAnchorChanged(part))
_G.AceAutoResetFireOnce(part)
end
end))
table.insert(state.conns, char.AncestryChanged:Connect(function(_, parent)
if not parent then
state.medTriggered = false
end
end))
end
function _G.AceEnableAutoResetOnMed()
autoResetOnMedEnabled = true
_G.AceAutoResetOnMed.enabled = true
_G.AceStartAutoResetOnMed(LP.Character)
end
function _G.AceDisableAutoResetOnMed()
autoResetOnMedEnabled = false
_G.AceAutoResetOnMed.enabled = false
_G.AceStopAutoResetOnMed()
end
function _G.AceSetAutoResetOnMed(state, noSave)
autoResetOnMedEnabled = state == true
if autoResetOnMedEnabled then
_G.AceEnableAutoResetOnMed()
else
_G.AceDisableAutoResetOnMed()
end
if setAutoResetOnMedVisual then
setAutoResetOnMedVisual(autoResetOnMedEnabled)
end
if not noSave and saveAceConfig then saveAceConfig() end
end
function enableAutoResetOnMed()
_G.AceSetAutoResetOnMed(true)
end
function disableAutoResetOnMed()
_G.AceSetAutoResetOnMed(false)
end
function toggleAutoResetOnMed(on)
_G.AceSetAutoResetOnMed(on == true)
end
if not _G.AceAutoResetOnMed.charAddedConn then
_G.AceAutoResetOnMed.charAddedConn = LP.CharacterAdded:Connect(function(char)
if _G.AceAutoResetOnMed and _G.AceAutoResetOnMed.enabled then
task.wait(0.25)
_G.AceStartAutoResetOnMed(char)
end
end)
end
_G.AceCounterState = _G.AceCounterState or {}
_G.AceCounterState.batConn = nil
_G.AceCounterState.batDebounce = false
_G.AceCounterState.medConns = _G.AceCounterState.medConns or {}
_G.AceCounterState.medDebounce = false
_G.AceCounterState.medLastUsed = _G.AceCounterState.medLastUsed or 0
_G.AceMedusaCooldown = 25
function _G.AceFindMedusa()
local c = LP.Character
if not c then return nil end
for _, t in ipairs(c:GetChildren()) do
if t:IsA("Tool") then
local n = t.Name:lower()
if n:find("medusa") or n:find("head") or n:find("stone") then return t end
end
end
local bp = LP:FindFirstChild("Backpack") or LP:FindFirstChildOfClass("Backpack")
if bp then
for _, t in ipairs(bp:GetChildren()) do
if t:IsA("Tool") then
local n = t.Name:lower()
if n:find("medusa") or n:find("head") or n:find("stone") then return t end
end
end
end
return nil
end
function _G.AceUseMedusaCounter()
if not medCounterEnabled then return end
if _G.AceCounterState.medDebounce then return end
if tick() - (_G.AceCounterState.medLastUsed or 0) < _G.AceMedusaCooldown then return end
local c = LP.Character
if not c then return end
_G.AceCounterState.medDebounce = true
local med = _G.AceFindMedusa()
if not med then
_G.AceCounterState.medDebounce = false
return
end
if med.Parent ~= c then
local hum = c:FindFirstChildOfClass("Humanoid")
if hum then pcall(function() hum:EquipTool(med) end) end
task.wait(0.05)
end
pcall(function() med:Activate() end)
_G.AceCounterState.medLastUsed = tick()
_G.AceCounterState.medDebounce = false
end
function _G.AceOnMedusaAnchorChanged(part)
return part:GetPropertyChangedSignal("Anchored"):Connect(function()
if medCounterEnabled and part.Anchored and part.Transparency == 1 then
_G.AceUseMedusaCounter()
end
end)
end
function _G.AceStartMedCounter(char)
_G.AceStopMedCounter()
char = char or LP.Character
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then
table.insert(_G.AceCounterState.medConns, _G.AceOnMedusaAnchorChanged(part))
end
end
table.insert(_G.AceCounterState.medConns, char.DescendantAdded:Connect(function(part)
if part:IsA("BasePart") then
table.insert(_G.AceCounterState.medConns, _G.AceOnMedusaAnchorChanged(part))
end
end))
end
function _G.AceStopMedCounter()
for _, c in pairs(_G.AceCounterState.medConns or {}) do
pcall(function() c:Disconnect() end)
end
_G.AceCounterState.medConns = {}
_G.AceCounterState.medDebounce = false
end
_G.AceBatCounterSlapList = {"Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap", "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap"}
function _G.AceFindBatForCounter()
local c = LP.Character
if not c then return nil end
local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
for _, name in ipairs(_G.AceBatCounterSlapList) do
local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
if t then return t end
end
for _, ch in ipairs(c:GetChildren()) do
if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
end
if bp then
for _, ch in ipairs(bp:GetChildren()) do
if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
end
end
return nil
end
function _G.AceSwingBatForCounter(bat, char)
if not bat or not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if bat.Parent ~= char then
if hum then pcall(function() hum:EquipTool(bat) end) end
task.wait(0.05)
end
local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
if remote and remote:IsA("RemoteEvent") then
pcall(function() remote:FireServer() end)
task.wait(0.15)
pcall(function() remote:FireServer() end)
else
pcall(function() bat:Activate() end)
task.wait(0.15)
pcall(function() bat:Activate() end)
end
end
function _G.AceCounterIsRagdoll(hum)
if not hum then return false end
local st = hum:GetState()
return st == Enum.HumanoidStateType.Physics
or st == Enum.HumanoidStateType.Ragdoll
or st == Enum.HumanoidStateType.FallingDown
or hum.PlatformStand == true
end
function _G.AceStartBatCounter()
if _G.AceCounterState.batConn then return end
_G.AceCounterState.batDebounce = false
_G.AceCounterState.batConn = RunService.Heartbeat:Connect(function()
if not batCounterEnabled then return end
if _G.AceCounterState.batDebounce then return end
local char = LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then return end
if _G.AceCounterIsRagdoll(hum) then
_G.AceCounterState.batDebounce = true
task.spawn(function()
local bat = _G.AceFindBatForCounter()
if bat then _G.AceSwingBatForCounter(bat, char) end
task.wait(0.5)
_G.AceCounterState.batDebounce = false
end)
end
end)
end
function _G.AceStopBatCounter()
if _G.AceCounterState.batConn then
_G.AceCounterState.batConn:Disconnect()
_G.AceCounterState.batConn = nil
end
_G.AceCounterState.batDebounce = false
end
startBatCounter = _G.AceStartBatCounter
stopBatCounter = _G.AceStopBatCounter
setupMedusaCounter = _G.AceStartMedCounter
stopMedusaCounter = _G.AceStopMedCounter
_G.AceNoPlayerCollisionState = _G.AceNoPlayerCollisionState or {connections = {}}
function _G.AceSetOtherPlayerCollision(state)
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and plr.Character then
for _, part in ipairs(plr.Character:GetDescendants()) do
if part:IsA("BasePart") then
pcall(function() part.CanCollide = state end)
end
end
end
end
end
function enableNoPlayerCollision()
if _G.AceNoPlayerCollisionState.running then return end
_G.AceNoPlayerCollisionEnabled = true
_G.AceNoPlayerCollisionState.running = true
for _, conn in ipairs(_G.AceNoPlayerCollisionState.connections or {}) do
pcall(function() conn:Disconnect() end)
end
_G.AceNoPlayerCollisionState.connections = {}
_G.AceSetOtherPlayerCollision(false)
table.insert(_G.AceNoPlayerCollisionState.connections, LP.CharacterAdded:Connect(function()
task.wait(0.5)
if _G.AceNoPlayerCollisionEnabled then _G.AceSetOtherPlayerCollision(false) end
end))
table.insert(_G.AceNoPlayerCollisionState.connections, Players.PlayerAdded:Connect(function(plr)
local c = plr.CharacterAdded:Connect(function()
task.wait(0.5)
if _G.AceNoPlayerCollisionEnabled then _G.AceSetOtherPlayerCollision(false) end
end)
table.insert(_G.AceNoPlayerCollisionState.connections, c)
end))
local collisionScanElapsed = 0
table.insert(_G.AceNoPlayerCollisionState.connections, RunService.Heartbeat:Connect(function(dt)
if not _G.AceNoPlayerCollisionEnabled then return end
collisionScanElapsed = collisionScanElapsed + (dt or 0)
if collisionScanElapsed < 0.25 then return end
collisionScanElapsed = 0
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and plr.Character then
for _, part in ipairs(plr.Character:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide == true then
pcall(function() part.CanCollide = false end)
end
end
end
end
end))
end
function disableNoPlayerCollision()
if not _G.AceNoPlayerCollisionState.running then
_G.AceNoPlayerCollisionEnabled = false
return
end
_G.AceNoPlayerCollisionEnabled = false
_G.AceNoPlayerCollisionState.running = false
for _, conn in ipairs(_G.AceNoPlayerCollisionState.connections or {}) do
pcall(function() conn:Disconnect() end)
end
_G.AceNoPlayerCollisionState.connections = {}
_G.AceSetOtherPlayerCollision(true)
end
function _G.AceSafeModeGetCountdownLabel()
local ok, label = pcall(function()
return LP.PlayerGui
and LP.PlayerGui:FindFirstChild("DuelsMachineTopFrame")
and LP.PlayerGui.DuelsMachineTopFrame:FindFirstChild("DuelsMachineTopFrame")
and LP.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame:FindFirstChild("Timer")
and LP.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer:FindFirstChild("Label")
end)
return (ok and label) or nil
end
function _G.AceSafeModeCountdownNumber(text)
local t = tostring(text or ""):upper():gsub("^%s+", ""):gsub("%s+$", "")
if t == "GO" or t == "START" or t == "READY" then return true end
local n = tonumber(t)
return n ~= nil and n >= 0 and n <= 10
end
function _G.AceSafeModeInDuelCountdown()
local label = _G.AceSafeModeGetCountdownLabel()
return label and _G.AceSafeModeCountdownNumber(label.Text) or false
end
_G.AceSafeModeBlockedTools = {
bat=true, slap=true, sword=true, gun=true, pistol=true, rifle=true,
medusa=true, hammer=true, axe=true, knife=true, katana=true, blade=true, fist=true,
}
function _G.AceSafeModeIsCarryableTool(tool)
if not tool or not tool:IsA("Tool") then return false end
local name = tool.Name:lower()
for word in pairs(_G.AceSafeModeBlockedTools) do
if name:find(word, 1, true) then return false end
end
return true
end
function _G.AceSafeModeHoldingBrainrot()
local ok, val = pcall(function() return LP:GetAttribute("Stealing") end)
if ok and val == true then return true end
local ok2, val2 = pcall(function() return LP:GetAttribute("AntiKick") end)
if ok2 and val2 == true then return true end
local char = LP.Character
if not char then return false end
local ok3, val3 = pcall(function() return char:GetAttribute("Stealing") end)
if ok3 and val3 == true then return true end
if _G.AutoCarrySpeed and type(_G.AutoCarrySpeed.IsCarryingBrainrot) == "function" then
local okCarry, carrying = pcall(function() return _G.AutoCarrySpeed.IsCarryingBrainrot(char) end)
if okCarry and carrying then return true end
end
for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do
local v = char:FindFirstChild(name, true)
if v then
if v:IsA("BoolValue") and v.Value then return true end
if v:IsA("ObjectValue") and v.Value then return true end
if v:IsA("StringValue") and v.Value ~= "" then return true end
end
end
for _, child in ipairs(char:GetChildren()) do
if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
local n = child.Name:lower()
if n:find("brainrot") or n:find("animal") or n:find("carry") or n:find("grab") or n:find("steal") or n:find("hold") then
return true
end
end
end
return false
end
function _G.AceSafeModeIsLocked()
if not antiKickEnabled then return false end
return _G.AceSafeModeInDuelCountdown() or _G.AceSafeModeHoldingBrainrot()
end
function _G.AceSafeModeForceStop(reason)
local stopped = false
if _G.AceNormalAimbotOn and _G.AceStopNormalAimbot then _G.AceStopNormalAimbot(); stopped = true end
if _G.AceAntiBypassAimbotOn and _G.AceStopAntiBypassAimbot then _G.AceStopAntiBypassAimbot(false); stopped = true end
if _G.AceAntiDesyncAimbotOn and _G.AceStopAntiDesyncAimbot then _G.AceStopAntiDesyncAimbot(); stopped = true end
if autoLeftEnabled then
autoLeftEnabled = false
if _G.AceSetAutoLeftVisual then _G.AceSetAutoLeftVisual(false) end
if _G.AceStopAutoLeft then _G.AceStopAutoLeft() end
stopped = true
end
if autoRightEnabled then
autoRightEnabled = false
if _G.AceSetAutoRightVisual then _G.AceSetAutoRightVisual(false) end
if _G.AceStopAutoRight then _G.AceStopAutoRight() end
stopped = true
end
if stopped and showActionNotification then pcall(function() showActionNotification(reason or "SAFE MODE LOCK") end) end
end
function _G.AceSafeModeTryStart()
if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
_G.AceSafeModeForceStop("SAFE MODE LOCK")
return false
end
return true
end
_G.AceSafeModeMonitorStarted = _G.AceSafeModeMonitorStarted or false
if not _G.AceSafeModeMonitorStarted then
_G.AceSafeModeMonitorStarted = true
RunService.Heartbeat:Connect(function()
if antiKickEnabled and _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
_G.AceSafeModeForceStop("SAFE MODE LOCK")
end
end)
end
LP.CharacterAdded:Connect(function(char)
task.wait(0.5)
if medCounterEnabled then _G.AceStartMedCounter(char) end
if batCounterEnabled then _G.AceStartBatCounter() end
end)
_G.AceNormalAimbot = _G.AceNormalAimbot or {conn = nil, target = nil, swingCooldown = false}
function _G.AceFindAimbotBat()
local char = LP.Character
if not char then return nil end
for _, tool in ipairs(char:GetChildren()) do
if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
return tool
end
end
local bp = LP:FindFirstChild("Backpack")
if bp then
for _, tool in ipairs(bp:GetChildren()) do
if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then
return tool
end
end
end
return nil
end
function _G.AceGetClosestAimbotTarget()
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not root then return nil end
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
return closest
end
function _G.AceGetNormalAimbotSpeed()
if currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry" then
return tonumber(LAGGER_AIMBOT_SPEED) or 40
end
return tonumber(AIMBOT_SPEED) or 58
end
function _G.AceGetAntiBypassAimbotSpeed()
if currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry" then
return tonumber(_G.AceAntiBypassLaggerAimbotSpeed) or 40
end
return tonumber(_G.AceAntiBypassAimbotSpeed) or 58
end
function _G.AceGetSelectedAimbotSpeedValues()
if selectedAimbotMode == "Anti Bypass" then
return tonumber(_G.AceAntiBypassAimbotSpeed) or 58, tonumber(_G.AceAntiBypassLaggerAimbotSpeed) or 40
end
return tonumber(AIMBOT_SPEED) or 58, tonumber(LAGGER_AIMBOT_SPEED) or 40
end
function _G.AceSetSelectedAimbotSpeedValues(normalValue, laggerValue)
if selectedAimbotMode == "Anti Bypass" then
if normalValue then _G.AceAntiBypassAimbotSpeed = normalValue end
if laggerValue then _G.AceAntiBypassLaggerAimbotSpeed = laggerValue end
else
if normalValue then AIMBOT_SPEED = normalValue end
if laggerValue then LAGGER_AIMBOT_SPEED = laggerValue end
end
end
function _G.AceRefreshAimbotSpeedBoxes()
local n, l = _G.AceGetSelectedAimbotSpeedValues()
if _G.AceAimbotSpeedBox then _G.AceAimbotSpeedBox.Text = tostring(n) end
if _G.AceLaggerAimbotSpeedBox then _G.AceLaggerAimbotSpeedBox.Text = tostring(l) end
end
function _G.AceStartNormalAimbot()
if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then return false end
if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end
if _G.AceStopAntiBypassAimbot then _G.AceStopAntiBypassAimbot(false) end
_G.AceAntiBypassAimbotOn = false
_G.AceNormalAimbotOn = true
if _G.AceNormalAimbot.conn then
_G.AceNormalAimbot.conn:Disconnect()
_G.AceNormalAimbot.conn = nil
end
local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum0 then hum0.AutoRotate = false end
_G.AceNormalAimbot.conn = RunService.RenderStepped:Connect(function()
if not _G.AceNormalAimbotOn or selectedAimbotMode ~= "Normal" then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then return end
local bat = char:FindFirstChildOfClass("Tool") or _G.AceFindAimbotBat()
if bat and bat.Parent ~= char then
pcall(function() hum:EquipTool(bat) end)
end
local target = _G.AceGetClosestAimbotTarget()
if not target then return end
_G.AceNormalAimbot.target = target
local targetVel = target.AssemblyLinearVelocity
local myPos = root.Position
local targetPos = target.Position
local predictPos = targetPos + targetVel * 0.14 + target.CFrame.LookVector * 0.3
local direction = predictPos - myPos
if direction.Magnitude < 0.01 then return end
local flatDir = Vector3.new(direction.X, 0, direction.Z)
if flatDir.Magnitude < 0.01 then return end
flatDir = flatDir.Unit
local chaseSpeed = _G.AceGetNormalAimbotSpeed()
local desiredHeight = targetPos.Y + 3.7
local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
if hum.FloorMaterial ~= Enum.Material.Air then
yVel = math.max(yVel, 13)
end
yVel = math.clamp(yVel, -70, 110)
local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
local speed3 = targetVel.Magnitude
local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
local predictedPos = targetPos + targetVel * predictTime
local toPredict = predictedPos - myPos
if toPredict.Magnitude > 0.1 then
local goalCF = CFrame.lookAt(myPos, predictedPos)
local diffCF = root.CFrame:Inverse() * goalCF
local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
rx = math.clamp(rx, -2.5, 2.5)
ry = math.clamp(ry, -2.5, 2.5)
rz = math.clamp(rz, -2.5, 2.5)
root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42))
end
if autoSwingEnabled and bat and not _G.AceNormalAimbot.swingCooldown then
_G.AceNormalAimbot.swingCooldown = true
pcall(function() bat:Activate() end)
task.delay(0.08, function()
if _G.AceNormalAimbot then _G.AceNormalAimbot.swingCooldown = false end
end)
end
end)
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
end
function _G.AceStopNormalAimbot()
_G.AceNormalAimbotOn = false
if _G.AceNormalAimbot and _G.AceNormalAimbot.conn then
_G.AceNormalAimbot.conn:Disconnect()
_G.AceNormalAimbot.conn = nil
end
if _G.AceNormalAimbot then
_G.AceNormalAimbot.target = nil
_G.AceNormalAimbot.swingCooldown = false
end
local c = LP.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if root then
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
local hum2 = c and c:FindFirstChildOfClass("Humanoid")
if hum2 then hum2.AutoRotate = true end
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
end
_G.AceAntiBypassAimbot = _G.AceAntiBypassAimbot or {conn = nil, swingCooldown = false, prevAutoRotate = nil}
_G.AceAntiBypassSlapList = _G.AceAntiBypassSlapList or {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
function _G.AceAntiBypassFindBat()
local char = LP.Character
if not char then return nil end
for _, name in ipairs(_G.AceAntiBypassSlapList) do
local t = char:FindFirstChild(name)
if t and t:IsA("Tool") then return t end
end
local bp = LP:FindFirstChildOfClass("Backpack")
if bp then
for _, name in ipairs(_G.AceAntiBypassSlapList) do
local t = bp:FindFirstChild(name)
if t and t:IsA("Tool") then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then pcall(function() hum:EquipTool(t) end) end
return t
end
end
end
for _, ch in ipairs(char:GetChildren()) do
if ch:IsA("Tool") and (ch.Name:lower():find("bat") or ch.Name:lower():find("slap")) then return ch end
end
return nil
end
function _G.AceAntiBypassTrySwing()
if _G.AceAntiBypassAimbot.swingCooldown then return end
_G.AceAntiBypassAimbot.swingCooldown = true
pcall(function()
local char = LP.Character
if not char then return end
local bat = _G.AceAntiBypassFindBat()
if bat then
if bat.Parent ~= char then
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then pcall(function() hum:EquipTool(bat) end) end
end
pcall(function() bat:Activate() end)
end
end)
task.delay(0.35, function()
if _G.AceAntiBypassAimbot then _G.AceAntiBypassAimbot.swingCooldown = false end
end)
end
function _G.AceAntiBypassGetClosest()
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not root then return nil, math.huge end
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
return closest, minDist
end
function _G.AceStartAntiBypassAimbot()
if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then return false end
if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end
if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end
_G.AceAntiBypassAimbotOn = true
selectedAimbotMode = "Anti Bypass"
if _G.AceAntiBypassAimbot.conn then
_G.AceAntiBypassAimbot.conn:Disconnect()
_G.AceAntiBypassAimbot.conn = nil
end
local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum0 then
if _G.AceAntiBypassAimbot.prevAutoRotate == nil then _G.AceAntiBypassAimbot.prevAutoRotate = hum0.AutoRotate end
hum0.AutoRotate = false
end
_G.AceAntiBypassAimbot.conn = RunService.RenderStepped:Connect(function()
if not _G.AceAntiBypassAimbotOn or selectedAimbotMode ~= "Anti Bypass" then return end
local char = LP.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then return end
if not char:FindFirstChildOfClass("Tool") then
local bat = _G.AceAntiBypassFindBat()
if bat then pcall(function() hum:EquipTool(bat) end) end
end
local target, targetDist = _G.AceAntiBypassGetClosest()
if not target then return end
local myPos = root.Position
local targetPos = target.Position
local direction = targetPos - myPos
local flatDir = Vector3.new(direction.X, 0, direction.Z)
if flatDir.Magnitude > 0 then flatDir = flatDir.Unit else flatDir = Vector3.zero end
local chaseSpeed = _G.AceGetAntiBypassAimbotSpeed()
local desiredHeight = targetPos.Y + 3.7
local yVel = (desiredHeight - myPos.Y) * 19.5
if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end
yVel = math.clamp(yVel, -70, 110)
local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
local toTarget = targetPos - myPos
if toTarget.Magnitude > 0.1 then
local goalCF = CFrame.lookAt(myPos, targetPos)
local diffCF = root.CFrame:Inverse() * goalCF
local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
rx = math.clamp(rx, -2.5, 2.5)
ry = math.clamp(ry, -2.5, 2.5)
rz = math.clamp(rz, -2.5, 2.5)
root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42))
end
if autoSwingEnabled and targetDist <= 8 then _G.AceAntiBypassTrySwing() end
end)
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
end
function _G.AceStopAntiBypassAimbot(keepVisual)
_G.AceAntiBypassAimbotOn = false
if _G.AceAntiBypassAimbot and _G.AceAntiBypassAimbot.conn then
_G.AceAntiBypassAimbot.conn:Disconnect()
_G.AceAntiBypassAimbot.conn = nil
end
if _G.AceAntiBypassAimbot then _G.AceAntiBypassAimbot.swingCooldown = false end
local c = LP.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if root then
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
local hum = c and c:FindFirstChildOfClass("Humanoid")
if hum then
hum.AutoRotate = (_G.AceAntiBypassAimbot.prevAutoRotate == nil) and true or _G.AceAntiBypassAimbot.prevAutoRotate
hum.PlatformStand = false
pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
end
if _G.AceAntiBypassAimbot then _G.AceAntiBypassAimbot.prevAutoRotate = nil end
if keepVisual ~= false and _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
end
function _G.AceToggleSelectedAimbot()
if selectedAimbotMode == "Anti Bypass" then
if _G.AceAntiBypassAimbotOn then
if _G.AceStopAntiBypassAimbot then _G.AceStopAntiBypassAimbot() else _G.AceAntiBypassAimbotOn = false end
else
if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end
if _G.AceStartAntiBypassAimbot then _G.AceStartAntiBypassAimbot() else _G.AceAntiBypassAimbotOn = true end
end
else
if _G.AceNormalAimbotOn then
_G.AceStopNormalAimbot()
else
if _G.AceStopAntiBypassAimbot then _G.AceStopAntiBypassAimbot(false) else _G.AceAntiBypassAimbotOn = false end
_G.AceStartNormalAimbot()
end
end
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
saveAceConfig()
end
function _G.AceRefreshAimbotVisual()
if _G.AceAimbotSetVisual then
if selectedAimbotMode == "Anti Bypass" then
_G.AceAimbotSetVisual(_G.AceAntiBypassAimbotOn == true)
else
_G.AceAimbotSetVisual(_G.AceNormalAimbotOn == true)
end
end
end
_G.AceNormalAimbotStart = _G.AceStartNormalAimbot
_G.AceNormalAimbotStop = _G.AceStopNormalAimbot
_G.AceAntiBypassStart = _G.AceStartAntiBypassAimbot
_G.AceAntiBypassStop = _G.AceStopAntiBypassAimbot

-- Mirror TP Down: mirror a 3-stud opponent drop while Normal, Anti Bypass, or Anti Desync Bat is active.
local MIRROR_TP_DROP_THRESHOLD = 3
local MIRROR_TP_DOWN_Y = -7.00
local mirrorTPPreviousY = {}
local mirrorTPLastTeleport = 0

local function mirrorTPAimbotActive()
return (_G.AceNormalAimbotOn == true) or (_G.AceAntiBypassAimbotOn == true) or (_G.AceAntiDesyncAimbotOn == true)
end

local function mirrorTPTeleportDown()
local character = LP.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not root or not humanoid or humanoid.Health <= 0 then return end
local now = tick()
if now - mirrorTPLastTeleport < 0.08 then return end
mirrorTPLastTeleport = now
local _, yaw = root.CFrame:ToEulerAnglesYXZ()
root.CFrame = CFrame.new(root.Position.X, MIRROR_TP_DOWN_Y, root.Position.Z) * CFrame.Angles(0, yaw, 0)
root.Velocity = Vector3.zero
pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
end

RunService.Heartbeat:Connect(function()
if not mirrorTPDownEnabled or not mirrorTPAimbotActive() then
table.clear(mirrorTPPreviousY)
return
end
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP and player.Character then
local root = player.Character:FindFirstChild("HumanoidRootPart")
if root then
local currentY = root.Position.Y
local previousY = mirrorTPPreviousY[player.UserId]
if previousY and previousY - currentY >= MIRROR_TP_DROP_THRESHOLD then
pcall(mirrorTPTeleportDown)
table.clear(mirrorTPPreviousY)
if type(showActionNotification) == "function" then
pcall(function() showActionNotification("MIRROR TP!") end)
end
return
end
mirrorTPPreviousY[player.UserId] = currentY
end
end
end
end)

function _G.AceSetMirrorTPDown(enabled)
mirrorTPDownEnabled = enabled == true
if not mirrorTPDownEnabled then table.clear(mirrorTPPreviousY) end
if _G.AceMirrorTPDownSetVisual then _G.AceMirrorTPDownSetVisual(mirrorTPDownEnabled) end
end
_G.AceAntiDesync = _G.AceAntiDesync or {conn = nil, hittingCooldown = false, h = nil, hrp = nil}
function _G.AceAntiDesyncGetBat()
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
function _G.AceAntiDesyncTrySwing()
if not _G.AceAntiDesync then return end
if _G.AceAntiDesync.hittingCooldown then return end
_G.AceAntiDesync.hittingCooldown = true
pcall(function()
local bat = _G.AceAntiDesyncGetBat()
if bat then
bat:Activate()
local ev = bat:FindFirstChildWhichIsA("RemoteEvent")
if ev then ev:FireServer() end
end
end)
task.delay(0.08, function()
if _G.AceAntiDesync then
_G.AceAntiDesync.hittingCooldown = false
end
end)
end
function _G.AceAntiDesyncGetClosestPlayer()
local hrp = _G.AceAntiDesync and _G.AceAntiDesync.hrp
if not hrp then return nil, math.huge end
local cp, cd = nil, math.huge
for _, p in pairs(Players:GetPlayers()) do
if p ~= LP and p.Character then
local tr = p.Character:FindFirstChild("HumanoidRootPart")
if tr then
local d = (hrp.Position - tr.Position).Magnitude
if d < cd then
cd = d
cp = p
end
end
end
end
return cp, cd
end
function _G.AceAntiDesyncSetupChar(char)
task.wait(0.1)
if not _G.AceAntiDesync then return end
_G.AceAntiDesync.h = char and char:WaitForChild("Humanoid", 5) or nil
_G.AceAntiDesync.hrp = char and char:WaitForChild("HumanoidRootPart", 5) or nil
end
LP.CharacterAdded:Connect(function(char)
pcall(function()
_G.AceAntiDesyncSetupChar(char)
end)
end)
if LP.Character then
task.spawn(function()
pcall(function()
_G.AceAntiDesyncSetupChar(LP.Character)
end)
end)
end
function _G.AceStartAntiDesyncAimbot()
if _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then return false end
if _G.AceStopAutoTPForAction then _G.AceStopAutoTPForAction() end
if _G.AceStopNormalAimbot then _G.AceStopNormalAimbot() end
if _G.AceStopAntiBypassAimbot then _G.AceStopAntiBypassAimbot(false) end
_G.AceAntiDesyncAimbotOn = true
if _G.AceAntiDesync.conn then
_G.AceAntiDesync.conn:Disconnect()
_G.AceAntiDesync.conn = nil
end
if LP.Character then
pcall(function()
_G.AceAntiDesyncSetupChar(LP.Character)
end)
end
_G.AceAntiDesync.conn = RunService.Heartbeat:Connect(function()
if not (_G.AceAntiDesyncAimbotOn and _G.AceAntiDesync.h and _G.AceAntiDesync.hrp) then return end
local target, dist = _G.AceAntiDesyncGetClosestPlayer()
_aimbotTargetPlr = target
_G.AceCurrentAimbotTarget = target
_G.AceAntiDesyncBatTarget = target
if target and target.Character then
local tr = target.Character:FindFirstChild("HumanoidRootPart")
if tr then
if sethiddenproperty then
pcall(function()
sethiddenproperty(_G.AceAntiDesync.hrp, "PhysicsRepRootPart", tr)
end)
end
local targetPos = tr.Position + Vector3.new(0, 0.9, 0)
if (_G.AceAntiDesync.hrp.Position - targetPos).Magnitude > 8 then
_G.AceAntiDesync.hrp.CFrame = CFrame.new(targetPos)
end
local cam = workspace.CurrentCamera
if cam then
cam.CFrame = CFrame.new(cam.CFrame.Position, tr.Position)
end
if antiDesyncAutoSwingEnabled or autoSwingEnabled then
_G.AceAntiDesyncTrySwing()
end
end
end
end)
if _G.AceAntiDesyncSetVisual then _G.AceAntiDesyncSetVisual(true) end
saveAceConfig()
return true
end
function _G.AceStopAntiDesyncAimbot()
_G.AceAntiDesyncAimbotOn = false
if _G.AceAntiDesync and _G.AceAntiDesync.conn then
_G.AceAntiDesync.conn:Disconnect()
_G.AceAntiDesync.conn = nil
end
if _G.AceAntiDesync then
_G.AceAntiDesync.hittingCooldown = false
end
_G.AceAntiDesyncBatTarget = nil
if _G.AceCurrentAimbotTarget == _aimbotTargetPlr then _G.AceCurrentAimbotTarget = nil end
_aimbotTargetPlr = nil
if _G.AceAntiDesyncSetVisual then _G.AceAntiDesyncSetVisual(false) end
saveAceConfig()
end
function _G.AceToggleAntiDesyncAimbot()
if _G.AceAntiDesyncAimbotOn then
_G.AceStopAntiDesyncAimbot()
else
_G.AceStartAntiDesyncAimbot()
end
end
_G.__AceSetupNormalAutoSteal = function()
_G.AceNormalSteal = _G.AceNormalSteal or {
enabled = false,
radius = 62,
duration = 1.3,
animals = {},
promptCache = {},
internalCache = {},
scannerStarted = false,
scanning = false,
isStealing = false,
stealConn = nil,
refreshThread = nil,
lastSteal = 0,
cooldown = 0.08,
}
if _G.AceNormalSteal.stealConn then pcall(function() _G.AceNormalSteal.stealConn:Disconnect() end); _G.AceNormalSteal.stealConn = nil end
_G.AceNormalSteal.enabled = false
_G.AceNormalSteal.isStealing = false
local function barProgress(p)
p = math.clamp(tonumber(p) or 0, 0, 1)
pcall(function()
if _G.StealBar then
_G.StealBar.SetState("STEALING")
_G.StealBar.SetProgress(p)
end
end)
end
local function resetBar()
pcall(function()
if _G.StealBar then _G.StealBar.Reset() end
end)
end
local function getRoot()
local char = LP.Character
if not char then return nil end
return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
end
local function isMyBase(plotName)
local plots = workspace:FindFirstChild("Plots")
local plot = plots and plots:FindFirstChild(plotName)
if not plot then return false end
local sign = plot:FindFirstChild("PlotSign")
local yourBase = sign and sign:FindFirstChild("YourBase")
return yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled == true
end
local function scanPlots()
local a = _G.AceNormalSteal
a.animals = {}
local plots = workspace:FindFirstChild("Plots")
if not plots then return end
for _, plot in ipairs(plots:GetChildren()) do
if plot:IsA("Model") and not isMyBase(plot.Name) then
local podiums = plot:FindFirstChild("AnimalPodiums")
if podiums then
for _, podium in ipairs(podiums:GetChildren()) do
if podium:IsA("Model") then
local base = podium:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
if spawn then
table.insert(a.animals, {
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
local function ensureScanner()
local a = _G.AceNormalSteal
if a.scannerStarted then return end
a.scannerStarted = true
task.spawn(function()
task.wait(1)
while _G.AceNormalSteal do
if _G.AceNormalSteal.enabled then
pcall(scanPlots)
end
task.wait(3)
end
end)
end
local function findPrompt(data)
if not data then return nil end
local a = _G.AceNormalSteal
local cached = a.promptCache[data.uid]
if cached and cached.Parent then return cached end
local plots = workspace:FindFirstChild("Plots")
local plot = plots and plots:FindFirstChild(data.plot)
local podiums = plot and plot:FindFirstChild("AnimalPodiums")
local podium = podiums and podiums:FindFirstChild(data.slot)
local base = podium and podium:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
local attach = spawn and spawn:FindFirstChild("PromptAttachment")
if not attach then return nil end
for _, prompt in ipairs(attach:GetChildren()) do
if prompt:IsA("ProximityPrompt") then
a.promptCache[data.uid] = prompt
return prompt
end
end
return nil
end
local function cacheCallbacks(prompt)
local a = _G.AceNormalSteal
if a.internalCache[prompt] then return end
local data = {hold = {}, trigger = {}, ready = true}
pcall(function()
if getconnections then
for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
if type(conn.Function) == "function" then table.insert(data.hold, conn.Function) end
end
for _, conn in ipairs(getconnections(prompt.Triggered)) do
if type(conn.Function) == "function" then table.insert(data.trigger, conn.Function) end
end
end
end)
if #data.hold > 0 or #data.trigger > 0 then
a.internalCache[prompt] = data
end
end
local function doSteal(prompt)
local a = _G.AceNormalSteal
if not prompt or not prompt.Parent or a.isStealing then return end
if tick() - (a.lastSteal or 0) < (a.cooldown or 0.08) then return end
cacheCallbacks(prompt)
local data = a.internalCache[prompt]
if not data or not data.ready then return end
data.ready = false
a.isStealing = true
a.lastSteal = tick()
pcall(function() if _G.StealBar then _G.StealBar.SetState("STEALING") end end)
task.spawn(function()
if #data.hold > 0 then
for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end
end
local startTime = tick()
local dur = 1.3
a.duration = dur
while a.enabled and selectedStealMode == "Normal" and tick() - startTime < dur do
barProgress((tick() - startTime) / dur)
task.wait(0.02)
end
if not a.enabled or selectedStealMode ~= "Normal" then
data.ready = true
a.isStealing = false
resetBar()
return
end
barProgress(1)
if #data.trigger > 0 then
for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end
end
pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
task.wait(0.12)
data.ready = true
a.isStealing = false
resetBar()
end)
end
local function nearestAnimal()
local a = _G.AceNormalSteal
local root = getRoot()
if not root then return nil end
local best, bestDist = nil, math.huge
for _, data in ipairs(a.animals) do
if data.worldPosition and not isMyBase(data.plot) then
local dist = (root.Position - data.worldPosition).Magnitude
if dist < bestDist then
best = data
bestDist = dist
end
end
end
if best and bestDist <= (tonumber(a.radius) or 62) then
return best
end
return nil
end
_G.AceNormalAutoStealSetRadius = function(v)
_G.AceNormalSteal.radius = tonumber(v) or _G.AceNormalSteal.radius or 62
end
_G.AceNormalAutoStealStop = function()
local a = _G.AceNormalSteal
a.enabled = false
a.isStealing = false
if a.stealConn then a.stealConn:Disconnect(); a.stealConn = nil end
resetBar()
end
_G.AceNormalAutoStealStart = function()
local a = _G.AceNormalSteal
a.radius = tonumber(autoStealRadius) or a.radius or 62
a.duration = 1.3
a.enabled = true
ensureScanner()
pcall(scanPlots)
if a.stealConn then a.stealConn:Disconnect(); a.stealConn = nil end
a.stealConn = RunService.Heartbeat:Connect(function()
if not a.enabled then return end
if selectedStealMode ~= "Normal" then _G.AceNormalAutoStealStop(); return end
if a.isStealing then return end
local target = nearestAnimal()
if not target then return end
local prompt = findPrompt(target)
if prompt then doSteal(prompt) end
end)
end
_G.AceNormalAutoStealSync = function()
if selectedStealMode == "Normal" and autoStealEnabled then
_G.AceNormalAutoStealStart()
else
_G.AceNormalAutoStealStop()
end
end
end
_G.__AceSetupNormalAutoSteal()
_G.__AceSetupSemiAutoSteal = function()
_G.AceSemiSteal = _G.AceSemiSteal or {}
local A = _G.AceSemiSteal
if A.conn then pcall(function() A.conn:Disconnect() end); A.conn = nil end
A.enabled = false
A.holdMin = 1.3
A.holdMax = 2.6
A.entryDelay = 0.3
A.cooldown = 0.05
A.primeRange = 80
A.radius = tonumber(autoStealRadius) or 10
A.conn = A.conn
A.scanThread = A.scanThread
A.plotSync = A.plotSync or {caches = {}, connections = {}}
A.animals = A.animals or {}
A.promptCache = A.promptCache or {}
A.internalCache = A.internalCache or {}
A.state = A.state or {active = false, startTime = 0, phase = "idle", label = "", lastResult = "", lastResultTime = 0}
local function barSet(p, label)
pcall(function()
if _G.StealBar then
_G.StealBar.SetState(label or "STEALING")
_G.StealBar.SetProgress(math.clamp(tonumber(p) or 0, 0, 1))
end
end)
end
local function barReset()
pcall(function()
if _G.StealBar then _G.StealBar.Reset() end
end)
end
local function rootPart()
local char = LP.Character
return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")) or nil
end
local function splitPath(path)
if typeof(path) == "table" then return path end
local out = {}
for part in string.gmatch(tostring(path), "[^%.]+") do
table.insert(out, tonumber(part) or part)
end
return out
end
local function resolvePath(path, root)
local current, parent, key = root, nil, nil
for _, part in ipairs(splitPath(path)) do
parent = current
key = part
current = current and current[part] or nil
end
return current, parent, key
end
local function applySyncDiff(channelName, packet)
local cache = A.plotSync.caches[channelName]
if typeof(cache) ~= "table" then return end
local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
local current, parent, key = resolvePath(path, cache)
if action == "Changed" then
if parent ~= nil then parent[key] = a end
elseif action == "ArrayInsert" then
if current ~= nil then table.insert(current, b, a) end
elseif action == "ArrayRemoved" then
if current ~= nil then table.remove(current, b) end
elseif action == "DictionaryInsert" then
if current ~= nil then current[b] = a end
elseif action == "DictionaryRemoved" then
if current ~= nil then current[b] = nil end
end
end
local function attachPlotChannel(remote, plots, requestData)
if A.plotSync.connections[remote] then return end
local channelName = tostring(remote.Name)
if not plots:FindFirstChild(channelName) then return end
if requestData and A.plotSync.caches[channelName] == nil then
local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
A.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
elseif A.plotSync.caches[channelName] == nil then
A.plotSync.caches[channelName] = {}
end
A.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
for _, packet in ipairs(queue) do applySyncDiff(channelName, packet) end
end)
end
local function ensureSync()
if A.syncReady then return true end
local ok = pcall(function()
local rs = game:GetService("ReplicatedStorage")
A.packages = rs:WaitForChild("Packages", 10)
A.datas = rs:WaitForChild("Datas", 10)
A.plots = workspace:WaitForChild("Plots", 10)
if not (A.packages and A.datas and A.plots) then return end
A.animalsData = require(A.datas:WaitForChild("Animals", 10))
local sync = A.packages:WaitForChild("Synchronizer", 10)
A.channelFolder = sync:WaitForChild("Channel", 10)
A.routeRemote = sync:WaitForChild("CommunicationRoute", 10)
A.requestData = sync:FindFirstChild("RequestData")
for _, child in ipairs(A.channelFolder:GetChildren()) do
if child:IsA("RemoteEvent") then attachPlotChannel(child, A.plots, A.requestData) end
end
A.channelFolder.ChildAdded:Connect(function(child)
if child:IsA("RemoteEvent") then attachPlotChannel(child, A.plots, A.requestData) end
end)
A.routeRemote.OnClientEvent:Connect(function(actions)
for _, action in ipairs(actions) do
local kind, channelName = action[1], tostring(action[2])
if A.plots and A.plots:FindFirstChild(channelName) then
if kind == "ListenerAdded" then
local remote = A.channelFolder and A.channelFolder:FindFirstChild(channelName)
if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote, A.plots, A.requestData) end
elseif kind == "ListenerRemoved" then
for remote, conn in pairs(A.plotSync.connections) do
if tostring(remote.Name) == channelName then
pcall(function() conn:Disconnect() end)
A.plotSync.connections[remote] = nil
A.plotSync.caches[channelName] = nil
break
end
end
end
end
end
end)
A.syncReady = true
end)
return ok and A.syncReady == true
end
local function getPlotOwner(plot)
local sign = plot and plot:FindFirstChild("PlotSign")
local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
local label = frame and frame:FindFirstChild("TextLabel")
if not label or label.Text == "Empty Base" then return nil end
return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end
local function isMyBaseAnimal(animalData)
if not animalData or not animalData.plot or not A.plots then return false end
local plot = A.plots:FindFirstChild(animalData.plot)
if not plot then return false end
local owner = getPlotOwner(plot)
return owner == LP.DisplayName or owner == LP.Name
end
local function podiumFor(animalData)
local plot = A.plots and A.plots:FindFirstChild(animalData.plot)
local podiums = plot and plot:FindFirstChild("AnimalPodiums")
return podiums and podiums:FindFirstChild(animalData.slot) or nil
end
local function animalPos(animalData)
local podium = podiumFor(animalData)
return podium and podium:GetPivot().Position or nil
end
local function distToAnimal(animalData)
local root = rootPart()
local pos = animalPos(animalData)
return root and pos and (root.Position - pos).Magnitude or math.huge
end
local function findPromptForAnimal(animalData)
if not animalData then return nil end
local cached = A.promptCache[animalData.uid]
if cached and cached.Parent then return cached end
local podium = podiumFor(animalData)
local base = podium and podium:FindFirstChild("Base")
local spawn = base and base:FindFirstChild("Spawn")
local attach = spawn and spawn:FindFirstChild("PromptAttachment")
if not attach then return nil end
for _, prompt in ipairs(attach:GetChildren()) do
if prompt:IsA("ProximityPrompt") then
A.promptCache[animalData.uid] = prompt
return prompt
end
end
return nil
end
local function scanAllPlots()
if not ensureSync() then return 0 end
local newCache = {}
for _, plot in ipairs(A.plots:GetChildren()) do
local cache = A.plotSync.caches[plot.Name]
local animalList = cache and cache.AnimalList
if typeof(animalList) == "table" then
for slot, animalData in pairs(animalList) do
if type(animalData) == "table" then
local animalName = animalData.Index
local info = A.animalsData and A.animalsData[animalName]
if info then
table.insert(newCache, {
name = info.DisplayName or animalName,
plot = plot.Name,
slot = tostring(slot),
uid = plot.Name .. "_" .. tostring(slot),
})
end
end
end
end
end
A.animals = newCache
return #newCache
end
local function pickClosest()
local root = rootPart()
if not root then return nil end
local best, bestDist = nil, math.huge
for _, animalData in ipairs(A.animals) do
if not isMyBaseAnimal(animalData) then
local pos = animalPos(animalData)
local dist = pos and (root.Position - pos).Magnitude or math.huge
if dist <= (A.primeRange or 80) and dist < bestDist then
best, bestDist = animalData, dist
end
end
end
return best
end
local function buildCallbacks(prompt)
if A.internalCache[prompt] then return end
local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
if okHold and type(holds) == "table" then
for _, conn in ipairs(holds) do
if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
end
end
local okTrigger, triggers = pcall(getconnections, prompt.Triggered)
if okTrigger and type(triggers) == "table" then
for _, conn in ipairs(triggers) do
if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
end
end
if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then A.internalCache[prompt] = data end
end
local function executeSemi(prompt, animalData)
if not prompt or not prompt.Parent or not animalData then return false end
buildCallbacks(prompt)
local data = A.internalCache[prompt]
if not data or not data.ready then return false end
data.ready = false
A.state.active = true
A.state.startTime = tick()
A.state.phase = "holding"
A.state.label = animalData.name or "Animal"
task.spawn(function()
local startTime = A.state.startTime
for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end
while A.enabled and selectedStealMode == "Semi" and tick() - startTime < (A.holdMin or 1.3) do
barSet((tick() - startTime) / (A.holdMax or 2.6), "STEALING")
task.wait()
end
A.state.phase = "waitingRange"
local alreadyInRange = distToAnimal(animalData) <= (tonumber(A.radius) or 10)
local fired = false
while A.enabled and selectedStealMode == "Semi" and prompt.Parent do
local elapsed = tick() - startTime
if elapsed > (A.holdMax or 2.6) then break end
barSet(elapsed / (A.holdMax or 2.6), "STEALING")
if distToAnimal(animalData) <= (tonumber(A.radius) or 10) then
if not alreadyInRange then task.wait(A.entryDelay or 0.3) end
if A.enabled and selectedStealMode == "Semi" then
for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
fired = true
end
break
end
task.wait()
end
A.state.lastResult = fired and ("Stole " .. tostring(A.state.label)) or ("Missed window: " .. tostring(A.state.label))
A.state.active = false
A.state.phase = "idle"
A.state.lastResultTime = tick()
if fired then barSet(1, "STEALING") end
task.wait(A.cooldown or 0.05)
data.ready = true
barReset()
end)
return true
end
local function ensureScanThread()
if A.scanThread then return end
A.scanThread = task.spawn(function()
while _G.AceSemiSteal do
if A.enabled or selectedStealMode == "Semi" then pcall(scanAllPlots) end
task.wait(5)
end
end)
end
_G.AceSemiAutoStealSetRadius = function(v)
local n = tonumber(v)
if n then A.radius = n end
end
_G.AceSemiAutoStealStop = function()
A.enabled = false
if A.conn then A.conn:Disconnect(); A.conn = nil end
A.state.active = false
A.state.phase = "idle"
barReset()
end
_G.AceSemiAutoStealStart = function()
A.radius = tonumber(autoStealRadius) or A.radius or 10
A.enabled = true
ensureSync()
ensureScanThread()
pcall(scanAllPlots)
if A.conn then A.conn:Disconnect(); A.conn = nil end
A.conn = RunService.Heartbeat:Connect(function()
if not A.enabled then return end
if selectedStealMode ~= "Semi" then _G.AceSemiAutoStealStop(); return end
if A.state.active then return end
local target = pickClosest()
if not target then return end
local prompt = findPromptForAnimal(target)
if prompt then executeSemi(prompt, target) end
end)
end
_G.AceSemiAutoStealSync = function()
if selectedStealMode == "Semi" and autoStealEnabled then
_G.AceSemiAutoStealStart()
else
_G.AceSemiAutoStealStop()
end
end
end
_G.__AceSetupSemiAutoSteal()
_G.AceAutoStealSync = function()
if not autoStealEnabled then
if _G.AceNormalAutoStealStop then _G.AceNormalAutoStealStop() end
if _G.AceSemiAutoStealStop then _G.AceSemiAutoStealStop() end
return
end
if selectedStealMode == "Normal" then
if _G.AceSemiAutoStealStop then _G.AceSemiAutoStealStop() end
if _G.AceNormalAutoStealSync then _G.AceNormalAutoStealSync() end
elseif selectedStealMode == "Semi" then
if _G.AceNormalAutoStealStop then _G.AceNormalAutoStealStop() end
if _G.AceSemiAutoStealSync then _G.AceSemiAutoStealSync() end
end
end
task.spawn(function()
while task.wait(30) do
saveAceConfig()
end
end)
local lastMoveDir = Vector3.new(0, 0, 0)
local function getCurrentSpeedValue()
if currentSpeedMode == "Carry" then
return CS
elseif currentSpeedMode == "Lagger" then
return LAGGER_SPEED
elseif currentSpeedMode == "Lagger Carry" then
return LAGGER_CARRY_SPEED
end
return NS
end
local refreshSpeedModeRows = nil
local function setSpeedMode(mode)
if mode ~= "Normal" and mode ~= "Carry" and mode ~= "Lagger" and mode ~= "Lagger Carry" then
mode = "Normal"
end
currentSpeedMode = mode
if refreshSpeedModeRows then
refreshSpeedModeRows()
end
saveAceConfig()
end
local function toggleCarryMode()
if currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry" then
setSpeedMode("Carry")
elseif currentSpeedMode == "Carry" then
setSpeedMode("Normal")
else
setSpeedMode("Carry")
end
end
local function toggleLaggerMode()
if currentSpeedMode ~= "Lagger" and currentSpeedMode ~= "Lagger Carry" then
setSpeedMode("Lagger Carry")
elseif currentSpeedMode == "Lagger Carry" then
setSpeedMode("Lagger")
else
setSpeedMode("Lagger Carry")
end
end
State = State or {}
State.normalSpeed = NS
State.carrySpeed = CS
State.laggerSpeed = LAGGER_SPEED
State.speedToggled = (currentSpeedMode == "Carry" or currentSpeedMode == "Lagger Carry")
State.laggerEnabled = (currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry")
toggleRefs = toggleRefs or {}
function setCarry(on)
if on then
setSpeedMode("Carry")
else
if currentSpeedMode == "Carry" or currentSpeedMode == "Lagger Carry" then
setSpeedMode("Normal")
end
end
State.speedToggled = on == true
end
function setLagger(on)
if on then
setSpeedMode("Lagger")
else
if currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry" then
setSpeedMode("Normal")
end
end
State.laggerEnabled = on == true
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
State = State or {}
State.normalSpeed = State.normalSpeed or 59
State.carrySpeed = State.carrySpeed or 30
State.laggerSpeed = State.laggerSpeed or 60
State.speedToggled = State.speedToggled or false
State.laggerEnabled = State.laggerEnabled or false
State._autoCarryFromSteal = State._autoCarryFromSteal or false
State._autoCarryGraceUntil = State._autoCarryGraceUntil or 0
State._waitingForCarryPickup = State._waitingForCarryPickup or false
State._carryPickupWatchUntil = State._carryPickupWatchUntil or 0
State._autoCarryReturnMode = State._autoCarryReturnMode or nil
toggleRefs = toggleRefs or {}
local function safeSaveConfig()
if type(saveConfig) == "function" then
task.spawn(saveConfig)
end
end
local function isCarryName(name)
local n = tostring(name or ""):lower()
return n:find("brainrot")
or n:find("animal")
or n:find("carry")
or n:find("grab")
or n:find("steal")
or n:find("hold")
end
local function isIgnoredCarryTool(name)
local n = tostring(name or ""):lower()
return n:find("bat")
or n:find("slap")
or n:find("medusa")
or n:find("head")
or n:find("stone")
end
local function isCarryingBrainrot(char)
if not char then return false end
for _, name in ipairs({"Carrying", "IsCarrying", "Grabbed", "Holding", "StealHold", "HasGrab"}) do
local v = char:FindFirstChild(name, true)
if v then
if v:IsA("BoolValue") and v.Value then
return true
end
if v:IsA("ObjectValue") and v.Value then
return true
end
if v:IsA("StringValue") and v.Value ~= "" then
return true
end
end
end
for _, child in ipairs(char:GetChildren()) do
if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
if child:FindFirstChildOfClass("Humanoid") and child:FindFirstChild("HumanoidRootPart") then
return true
end
if isCarryName(child.Name) then
return true
end
elseif child:IsA("Tool") and not isIgnoredCarryTool(child.Name) then
return true
end
end
return false
end
local function setCarrySpeedMode(on)
State.speedToggled = on
if toggleRefs.carryMode then
toggleRefs.carryMode(on)
end
if type(setCarry) == "function" then
setCarry(on)
end
end
local function setLaggerMode(on)
State.laggerEnabled = on
if toggleRefs.laggerMode then
toggleRefs.laggerMode(on)
end
if type(setLagger) == "function" then
setLagger(on)
end
end
local function enableCarrySpeedForSteal()
State._waitingForCarryPickup = false
State._carryPickupWatchUntil = 0
if not State._autoCarryFromSteal then
State._autoCarryReturnMode = currentSpeedMode
end
State._autoCarryFromSteal = true
State._autoCarryGraceUntil = tick() + 0.75
local wasLagger = (State._autoCarryReturnMode == "Lagger" or State._autoCarryReturnMode == "Lagger Carry"
or currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry")
if wasLagger then
State.laggerEnabled = true
State.speedToggled = true
if toggleRefs.laggerMode then toggleRefs.laggerMode(true) end
if toggleRefs.carryMode then toggleRefs.carryMode(true) end
setSpeedMode("Lagger Carry")
else
setLaggerMode(false)
setCarrySpeedMode(true)
end
safeSaveConfig()
end
local function disableAutoCarrySpeed()
if not State._autoCarryFromSteal and not State._waitingForCarryPickup then return end
local wasAutoApplied = State._autoCarryFromSteal == true
local returnMode = State._autoCarryReturnMode
State._autoCarryFromSteal = false
State._waitingForCarryPickup = false
State._autoCarryGraceUntil = 0
State._carryPickupWatchUntil = 0
State._autoCarryReturnMode = nil
if not wasAutoApplied then
return
end
if returnMode == "Lagger" or returnMode == "Lagger Carry" then
State.laggerEnabled = true
State.speedToggled = false
if toggleRefs.laggerMode then toggleRefs.laggerMode(true) end
if toggleRefs.carryMode then toggleRefs.carryMode(false) end
setSpeedMode("Lagger")
elseif returnMode == "Carry" then
State.laggerEnabled = false
State.speedToggled = true
if toggleRefs.laggerMode then toggleRefs.laggerMode(false) end
if toggleRefs.carryMode then toggleRefs.carryMode(true) end
setSpeedMode("Carry")
else
setLaggerMode(false)
setCarrySpeedMode(false)
end
safeSaveConfig()
end
local function startAutoCarryPickupWatch(seconds)
if autoCarrySpeedEnabled ~= true then return end
State._waitingForCarryPickup = true
State._carryPickupWatchUntil = tick() + (seconds or 1.25)
end
local _stealAttrWasActive = false
RunService.RenderStepped:Connect(function()
if autoCarrySpeedEnabled ~= true then
disableAutoCarrySpeed()
return
end
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
if not char or not hum or not root then
disableAutoCarrySpeed()
_stealAttrWasActive = false
return
end
local st = hum:GetState()
local gotHit = st == Enum.HumanoidStateType.Physics
or st == Enum.HumanoidStateType.Ragdoll
or st == Enum.HumanoidStateType.FallingDown
local stealingAttr = LP:GetAttribute("Stealing") == true
local carryingBrainrot = isCarryingBrainrot(char)
if stealingAttr and not _stealAttrWasActive then
_stealAttrWasActive = true
enableCarrySpeedForSteal()
elseif not stealingAttr then
_stealAttrWasActive = false
end
if State._waitingForCarryPickup then
if gotHit or tick() > (State._carryPickupWatchUntil or 0) then
State._waitingForCarryPickup = false
State._carryPickupWatchUntil = 0
elseif carryingBrainrot then
enableCarrySpeedForSteal()
end
end
if carryingBrainrot and not State._autoCarryFromSteal then
enableCarrySpeedForSteal()
end
if State._autoCarryFromSteal then
local graceDone = tick() > (State._autoCarryGraceUntil or 0)
if gotHit or (graceDone and not carryingBrainrot and not stealingAttr) then
disableAutoCarrySpeed()
end
end
end)
_G.AutoCarrySpeed = {
IsCarryingBrainrot = isCarryingBrainrot,
Enable = enableCarrySpeedForSteal,
Disable = disableAutoCarrySpeed,
WatchPickup = startAutoCarryPickupWatch,
}
_G.AceAutoPathState = _G.AceAutoPathState or {leftConn=nil,rightConn=nil,leftPhase=1,rightPhase=1}
_G.AceAutoPathPoints = _G.AceAutoPathPoints or {
L1=Vector3.new(-476.48,-6.28,92.73), L2=Vector3.new(-483.12,-4.95,94.80), LFace=Vector3.new(-482.25,-4.96,92.09),
R1=Vector3.new(-476.16,-6.52,25.62), R2=Vector3.new(-483.06,-5.03,25.48), RFace=Vector3.new(-482.06,-6.93,35.47),
}
function _G.AceAutoPathSpeed()
if currentSpeedMode == "Lagger" or currentSpeedMode == "Lagger Carry" then
return LAGGER_SPEED
end
return NS
end
function _G.AceStopAutoLeft()
local S=_G.AceAutoPathState
if S.leftConn then S.leftConn:Disconnect(); S.leftConn=nil end
S.leftPhase=1
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hum then hum:Move(Vector3.zero,false) end
if hrp then hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0) end
end
function _G.AceStopAutoRight()
local S=_G.AceAutoPathState
if S.rightConn then S.rightConn:Disconnect(); S.rightConn=nil end
S.rightPhase=1
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hum then hum:Move(Vector3.zero,false) end
if hrp then hrp.AssemblyLinearVelocity=Vector3.new(0,hrp.AssemblyLinearVelocity.Y,0) end
end
function _G.AceSetAutoLeft(on, skipSave)
if on and _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then
autoLeftEnabled = false
if _G.AceSetAutoLeftVisual then _G.AceSetAutoLeftVisual(false) end
if not skipSave then saveAceConfig() end
return false
end
autoLeftEnabled = on and true or false
if _G.AceSetAutoLeftVisual then _G.AceSetAutoLeftVisual(autoLeftEnabled) end
if autoLeftEnabled then
autoRightEnabled=false
if _G.AceSetAutoRightVisual then _G.AceSetAutoRightVisual(false) end
if _G.AceStopAutoRight then _G.AceStopAutoRight() end
if _G.AceStartAutoLeft then _G.AceStartAutoLeft() end
else
if _G.AceStopAutoLeft then _G.AceStopAutoLeft() end
end
if not skipSave then saveAceConfig() end
end
function _G.AceSetAutoRight(on, skipSave)
if on and _G.AceSafeModeTryStart and not _G.AceSafeModeTryStart() then
autoRightEnabled = false
if _G.AceSetAutoRightVisual then _G.AceSetAutoRightVisual(false) end
if not skipSave then saveAceConfig() end
return false
end
autoRightEnabled = on and true or false
if _G.AceSetAutoRightVisual then _G.AceSetAutoRightVisual(autoRightEnabled) end
if autoRightEnabled then
autoLeftEnabled=false
if _G.AceSetAutoLeftVisual then _G.AceSetAutoLeftVisual(false) end
if _G.AceStopAutoLeft then _G.AceStopAutoLeft() end
if _G.AceStartAutoRight then _G.AceStartAutoRight() end
else
if _G.AceStopAutoRight then _G.AceStopAutoRight() end
end
if not skipSave then saveAceConfig() end
end
function _G.AceStartAutoLeft()
local S=_G.AceAutoPathState
if S.leftConn then S.leftConn:Disconnect() end
S.leftPhase=1
S.leftConn=RunService.Heartbeat:Connect(function()
if not autoLeftEnabled then return end
local char=LP.Character; if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local hum=char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then return end
local st=hum:GetState()
if hum.PlatformStand or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then hum:Move(Vector3.zero,false); return end
local P=_G.AceAutoPathPoints
local spd=_G.AceAutoPathSpeed()
if S.leftPhase==1 then
local tgt=Vector3.new(P.L1.X,hrp.Position.Y,P.L1.Z)
if (tgt-hrp.Position).Magnitude<1 then
S.leftPhase=2
local d=P.L2-hrp.Position
local mv=Vector3.new(d.X,0,d.Z).Unit
hum:Move(mv,false)
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
return
end
local d=P.L1-hrp.Position
local mv=Vector3.new(d.X,0,d.Z).Unit
hum:Move(mv,false)
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
elseif S.leftPhase==2 then
local tgt=Vector3.new(P.L2.X,hrp.Position.Y,P.L2.Z)
if (tgt-hrp.Position).Magnitude<1 then
hum:Move(Vector3.zero,false)
hrp.AssemblyLinearVelocity=Vector3.zero
autoLeftEnabled=false
if S.leftConn then S.leftConn:Disconnect(); S.leftConn=nil end
S.leftPhase=1
if _G.AceSetAutoLeftVisual then _G.AceSetAutoLeftVisual(false) end
if P.LFace and (P.LFace-hrp.Position).Magnitude>0.01 then
hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(P.LFace.X,hrp.Position.Y,P.LFace.Z))
end
saveAceConfig()
return
end
local d=P.L2-hrp.Position
local mv=Vector3.new(d.X,0,d.Z).Unit
hum:Move(mv,false)
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
end
end)
end
function _G.AceStartAutoRight()
local S=_G.AceAutoPathState
if S.rightConn then S.rightConn:Disconnect() end
S.rightPhase=1
S.rightConn=RunService.Heartbeat:Connect(function()
if not autoRightEnabled then return end
local char=LP.Character; if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local hum=char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then return end
local st=hum:GetState()
if hum.PlatformStand or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then hum:Move(Vector3.zero,false); return end
local P=_G.AceAutoPathPoints
local spd=_G.AceAutoPathSpeed()
if S.rightPhase==1 then
local tgt=Vector3.new(P.R1.X,hrp.Position.Y,P.R1.Z)
if (tgt-hrp.Position).Magnitude<1 then
S.rightPhase=2
local d=P.R2-hrp.Position
local mv=Vector3.new(d.X,0,d.Z).Unit
hum:Move(mv,false)
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
return
end
local d=P.R1-hrp.Position
local mv=Vector3.new(d.X,0,d.Z).Unit
hum:Move(mv,false)
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
elseif S.rightPhase==2 then
local tgt=Vector3.new(P.R2.X,hrp.Position.Y,P.R2.Z)
if (tgt-hrp.Position).Magnitude<1 then
hum:Move(Vector3.zero,false)
hrp.AssemblyLinearVelocity=Vector3.zero
autoRightEnabled=false
if S.rightConn then S.rightConn:Disconnect(); S.rightConn=nil end
S.rightPhase=1
if _G.AceSetAutoRightVisual then _G.AceSetAutoRightVisual(false) end
if P.RFace and (P.RFace-hrp.Position).Magnitude>0.01 then
hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(P.RFace.X,hrp.Position.Y,P.RFace.Z))
end
saveAceConfig()
return
end
local d=P.R2-hrp.Position
local mv=Vector3.new(d.X,0,d.Z).Unit
hum:Move(mv,false)
hrp.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp.AssemblyLinearVelocity.Y,mv.Z*spd)
end
end)
end
LP.CharacterAdded:Connect(function()
task.wait(0.5)
if autoLeftEnabled and _G.AceStartAutoLeft then _G.AceStartAutoLeft() end
if autoRightEnabled and _G.AceStartAutoRight then _G.AceStartAutoRight() end
end)
local overheadGui = nil
local overheadSpeedLabel = nil
local function setupOverheadInfo(char)
if overheadGui then
pcall(function() overheadGui:Destroy() end)
overheadGui = nil
overheadSpeedLabel = nil
end
if not char then return end
local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
if not head then return end
overheadGui = Instance.new("BillboardGui")
overheadGui.Name = "AceDuelsOverheadInfo"
overheadGui.Size = UDim2.new(0, 250, 0, 88)
overheadGui.StudsOffset = Vector3.new(0, 1.75, 0)
overheadGui.AlwaysOnTop = true
overheadGui.LightInfluence = 0
overheadGui.Parent = head
ragdollCountdownLabel = Instance.new("TextLabel")
ragdollCountdownLabel.Name = "RagdollCountdown"
ragdollCountdownLabel.Size = UDim2.new(1, 0, 0, 26)
ragdollCountdownLabel.Position = UDim2.new(0, 0, 0, 0)
ragdollCountdownLabel.BackgroundTransparency = 1
ragdollCountdownLabel.Text = ""
ragdollCountdownLabel.Visible = false
ragdollCountdownLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
ragdollCountdownLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ragdollCountdownLabel.TextStrokeTransparency = 0
ragdollCountdownLabel.Font = Enum.Font.GothamBlack
ragdollCountdownLabel.TextSize = 22
ragdollCountdownLabel.TextXAlignment = Enum.TextXAlignment.Center
ragdollCountdownLabel.ZIndex = 10
ragdollCountdownLabel.Parent = overheadGui
local discordLbl = Instance.new("TextLabel")
discordLbl.Name = "Discord"
discordLbl.Size = UDim2.new(1, 0, 0, 30)
discordLbl.Position = UDim2.new(0, 0, 0, 26)
discordLbl.BackgroundTransparency = 1
discordLbl.Text = "discord.gg/aceduels"
discordLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
discordLbl.TextStrokeTransparency = 0
discordLbl.Font = Enum.Font.GothamBlack
discordLbl.TextSize = 21
discordLbl.TextXAlignment = Enum.TextXAlignment.Center
discordLbl.ZIndex = 10
discordLbl.Parent = overheadGui
overheadSpeedLabel = Instance.new("TextLabel")
overheadSpeedLabel.Name = "Speed"
overheadSpeedLabel.Size = UDim2.new(1, 0, 0, 26)
overheadSpeedLabel.Position = UDim2.new(0, 0, 0, 54)
overheadSpeedLabel.BackgroundTransparency = 1
overheadSpeedLabel.Text = "Speed: 0"
overheadSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
overheadSpeedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
overheadSpeedLabel.TextStrokeTransparency = 0
overheadSpeedLabel.Font = Enum.Font.GothamBlack
overheadSpeedLabel.TextSize = 19
overheadSpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
overheadSpeedLabel.ZIndex = 10
overheadSpeedLabel.Parent = overheadGui
end
local ragdollCountdownConn = nil
local ragdollCountdownCharConn = nil
local ragdollCountdownEndTime = 0
local RAGDOLL_COUNTDOWN_SECONDS = 2.6
function stopRagdollCountdown()
if ragdollCountdownConn then ragdollCountdownConn:Disconnect(); ragdollCountdownConn = nil end
if ragdollCountdownCharConn then ragdollCountdownCharConn:Disconnect(); ragdollCountdownCharConn = nil end
if ragdollCountdownLabel then
ragdollCountdownLabel.Visible = false
ragdollCountdownLabel.Text = ""
end
end
function hookRagdollCountdown(char)
stopRagdollCountdown()
if not ragdollCountdownEnabled then return end
char = char or LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 4)
if not hum then return end
local function beginCountdown()
ragdollCountdownEndTime = tick() + RAGDOLL_COUNTDOWN_SECONDS
if ragdollCountdownLabel then
ragdollCountdownLabel.Visible = true
end
end
local function isRagdollStateForCountdown()
local st = hum:GetState()
return hum.PlatformStand
or st == Enum.HumanoidStateType.Physics
or st == Enum.HumanoidStateType.Ragdoll
or st == Enum.HumanoidStateType.FallingDown
end
ragdollCountdownCharConn = hum.StateChanged:Connect(function(_, newState)
if newState == Enum.HumanoidStateType.Physics
or newState == Enum.HumanoidStateType.Ragdoll
or newState == Enum.HumanoidStateType.FallingDown then
beginCountdown()
end
end)
ragdollCountdownConn = RunService.RenderStepped:Connect(function()
if not ragdollCountdownEnabled then stopRagdollCountdown(); return end
if not ragdollCountdownLabel or not ragdollCountdownLabel.Parent then return end
if isRagdollStateForCountdown() and ragdollCountdownEndTime < tick() then
beginCountdown()
end
local left = math.max(0, ragdollCountdownEndTime - tick())
if left > 0 then
ragdollCountdownLabel.Visible = true
ragdollCountdownLabel.Text = string.format("RAGDOLL %.1f", left)
if left <= 1 then
ragdollCountdownLabel.TextColor3 = Color3.fromRGB(255, 230, 90)
else
ragdollCountdownLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
end
else
ragdollCountdownLabel.Visible = false
ragdollCountdownLabel.Text = ""
end
end)
end
if LP.Character then
task.spawn(function()
setupOverheadInfo(LP.Character)
end)
end
LP.CharacterAdded:Connect(function(char)
task.wait(0.5)
setupOverheadInfo(char)
if ragdollCountdownEnabled then hookRagdollCountdown(char) end
end)
RunService.RenderStepped:Connect(function()
local char = LP.Character
if not char then return end
local hum = char:FindFirstChildOfClass("Humanoid")
local hrp = char:FindFirstChild("HumanoidRootPart")
if not hum or not hrp then return end
local state = hum:GetState()
if hum.PlatformStand
or state == Enum.HumanoidStateType.Physics
or state == Enum.HumanoidStateType.Ragdoll
or state == Enum.HumanoidStateType.FallingDown then
lastMoveDir = Vector3.new(0, 0, 0)
return
end
local md = hum.MoveDirection
local spd = getCurrentSpeedValue()
if not autoLeftEnabled and not autoRightEnabled and md.Magnitude > 0 then
lastMoveDir = md
hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
end
if overheadSpeedLabel then
local v = hrp.AssemblyLinearVelocity or hrp.Velocity
local speedMag = Vector3.new(v.X, 0, v.Z).Magnitude
local rounded = math.floor(speedMag * 10 + 0.5) / 10
if math.abs(rounded - math.floor(rounded)) < 0.05 then
overheadSpeedLabel.Text = string.format("Speed: %d", math.floor(rounded + 0.5))
else
overheadSpeedLabel.Text = string.format("Speed: %.1f", rounded)
end
end
end)
local COLORS = {
bg = Color3.fromRGB(0, 0, 0),
row = Color3.fromRGB(6, 6, 9),
row2 = Color3.fromRGB(8, 8, 12),
stroke = Color3.fromRGB(90, 90, 105),
strokeSoft = Color3.fromRGB(60, 60, 72),
white = Color3.fromRGB(255, 255, 255),
textDim = Color3.fromRGB(180, 180, 190),
toggleBg = Color3.fromRGB(18, 18, 26),
knob = Color3.fromRGB(238, 238, 245),
}
function corner(parent, radius)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, radius or 8)
c.Parent = parent
return c
end
function stroke(parent, color, thickness, transparency)
local s = Instance.new("UIStroke")
s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
s.Color = color or COLORS.stroke
s.Thickness = thickness or 1
s.Transparency = transparency or 0.35
s.Parent = parent
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(155, 160, 185)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
g.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.55),
NumberSequenceKeypoint.new(0.5, 0.1),
NumberSequenceKeypoint.new(1, 0.55),
})
g.Parent = s
return s
end
function tween(obj, props, time)
TweenService:Create(obj, TweenInfo.new(time or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
function makeDraggable(frame)
local dragging = false
local dragStart
local startPos
local dragInput
frame.InputBegan:Connect(function(input)
if _G.AceGuiLocked == true then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = frame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
end
end)
end
end)
frame.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if _G.AceGuiLocked == true then return end
if input == dragInput and dragging then
local delta = input.Position - dragStart
frame.Position = UDim2.new(
startPos.X.Scale,
startPos.X.Offset + delta.X,
startPos.Y.Scale,
startPos.Y.Offset + delta.Y
)
end
end)
end
local Gui = Instance.new("ScreenGui")
Gui.Name = "AceDuelsAdaptReconstruct"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui
local FULL_MAIN_SIZE = UDim2.new(0, 356, 0, 536)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0, 0.5)
Main.Size = FULL_MAIN_SIZE
Main.Position = tableToUDim2(savedMainPositionTable, UDim2.new(0, 20, 0.5, 0))
savedMainPositionTable = udim2ToTable(Main.Position)
Main.BackgroundColor3 = COLORS.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = false
Main.Parent = Gui
corner(Main, 14)
stroke(Main, COLORS.stroke, 1.1, 0.35)
makeDraggable(Main)
Main:GetPropertyChangedSignal("Position"):Connect(function()
savedMainPositionTable = udim2ToTable(Main.Position)
end)
local MiniFrame = Instance.new("Frame")
MiniFrame.Name = "MiniFrame"
MiniFrame.AnchorPoint = Vector2.new(0, 0)
MiniFrame.Size = UDim2.new(0, 78, 0, 28)
local MINI_DEFAULT_POSITION = UDim2.new(0, 132, 0, 112)
MiniFrame.Position = MINI_DEFAULT_POSITION
savedMiniPositionTable = nil
MiniFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MiniFrame.BackgroundTransparency = 0
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.ZIndex = 20
MiniFrame.Parent = Gui
corner(MiniFrame, 8)
stroke(MiniFrame, Color3.fromRGB(120, 120, 130), 1, 0.22)
local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Size = UDim2.new(1, 0, 1, 0)
MiniButton.BackgroundTransparency = 1
MiniButton.Text = "ACE"
MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
MiniButton.TextStrokeTransparency = 0.18
MiniButton.TextSize = 17
MiniButton.Font = Enum.Font.GothamBlack
MiniButton.AutoButtonColor = false
MiniButton.ZIndex = 21
MiniButton.Parent = MiniFrame
local MiniShade = Instance.new("Frame")
MiniShade.Name = "MiniShade"
MiniShade.Size = UDim2.new(1, -4, 1, -4)
MiniShade.Position = UDim2.new(0, 2, 0, 2)
MiniShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MiniShade.BackgroundTransparency = 0.12
MiniShade.BorderSizePixel = 0
MiniShade.ZIndex = 20
MiniShade.Parent = MiniFrame
corner(MiniShade, 7)
do
local miniDragging = false
local miniDragStart = nil
local miniStartPos = nil
local miniMoved = false
local miniHeldInput = nil
local DRAG_DEADZONE = 6
MiniButton.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
miniDragging = true
miniMoved = false
miniHeldInput = input
miniDragStart = input.Position
miniStartPos = MiniFrame.Position
end
end)
UserInputService.InputChanged:Connect(function(input)
if not miniDragging then return end
if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
if not miniDragStart or not miniStartPos then return end
local delta = input.Position - miniDragStart
if math.abs(delta.X) > DRAG_DEADZONE or math.abs(delta.Y) > DRAG_DEADZONE then
miniMoved = true
end
MiniFrame.Position = UDim2.new(
miniStartPos.X.Scale,
miniStartPos.X.Offset + delta.X,
miniStartPos.Y.Scale,
miniStartPos.Y.Offset + delta.Y
)
end)
UserInputService.InputEnded:Connect(function(input)
if input ~= miniHeldInput then return end
local wasDrag = miniMoved
miniDragging = false
miniHeldInput = nil
miniDragStart = nil
miniStartPos = nil
if wasDrag then
return
end
Main.Visible = true
MiniFrame.Visible = false
Main.Size = FULL_MAIN_SIZE
savedMainPositionTable = udim2ToTable(Main.Position)
end)
end
local BackgroundIDs = {
"99416158073201",
"126860692354524",
"73226092831324",
"90280869222992",
}
currentBackground = tonumber(savedConfig.currentBackground) or currentBackground
local BgImage = Instance.new("ImageLabel")
BgImage.Name = "CustomBackground"
BgImage.BackgroundTransparency = 1
BgImage.ImageTransparency = 0
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.Position = UDim2.new(0, 0, 0, 0)
BgImage.Visible = false
BgImage.ZIndex = 1
BgImage.Parent = Main
corner(BgImage, 14)
function applyBackground(index)
currentBackground = index or 0
if currentBackground == 0 then
Main.BackgroundColor3 = COLORS.bg
BgImage.Visible = false
saveAceConfig()
return "None"
end
local id = BackgroundIDs[currentBackground]
if id then
BgImage.Image = "rbxassetid://" .. id
BgImage.Visible = true
saveAceConfig()
return "Image " .. tostring(currentBackground)
end
currentBackground = 0
BgImage.Visible = false
saveAceConfig()
return "None"
end
applyBackground(currentBackground)
local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Name = "LogoIcon"
LogoIcon.BackgroundColor3 = Color3.fromRGB(7, 7, 10)
LogoIcon.BackgroundTransparency = 0.12
LogoIcon.BorderSizePixel = 0
LogoIcon.Image = "rbxassetid://84453255265251"
LogoIcon.ScaleType = Enum.ScaleType.Fit
LogoIcon.Size = UDim2.new(0, 58, 0, 58)
LogoIcon.Position = UDim2.new(0, 16, 0, 17)
LogoIcon.ZIndex = 6
LogoIcon.Parent = Main
corner(LogoIcon, 12)
stroke(LogoIcon, COLORS.strokeSoft, 1, 0.35)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -118, 0, 30)
Title.Position = UDim2.new(0, 86, 0, 24)
Title.Text = "ACE DUELS"
Title.TextColor3 = COLORS.white
Title.TextStrokeTransparency = 0.65
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 27
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6
Title.Parent = Main
local Discord = Instance.new("TextLabel")
Discord.Name = "Discord"
Discord.BackgroundTransparency = 1
Discord.Size = UDim2.new(1, -118, 0, 18)
Discord.Position = UDim2.new(0, 87, 0, 55)
Discord.Text = "discord.gg/aceduels"
Discord.TextColor3 = Color3.fromRGB(235, 235, 245)
Discord.Font = Enum.Font.GothamSemibold
Discord.TextSize = 14
Discord.TextXAlignment = Enum.TextXAlignment.Left
Discord.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Discord.TextStrokeTransparency = 0.25
Discord.ZIndex = 6
Discord.Parent = Main
local HeaderDivider = Instance.new("Frame")
HeaderDivider.Name = "HeaderDivider"
HeaderDivider.BackgroundColor3 = Color3.fromRGB(70, 70, 82)
HeaderDivider.BackgroundTransparency = 0.45
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Size = UDim2.new(1, -34, 0, 1)
HeaderDivider.Position = UDim2.new(0, 17, 0, 96)
HeaderDivider.ZIndex = 6
HeaderDivider.Parent = Main
local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Close.BackgroundTransparency = 0.28
Close.Text = "-"
Close.TextColor3 = COLORS.white
Close.TextSize = 22
Close.Font = Enum.Font.GothamSemibold
Close.Size = UDim2.new(0, 32, 0, 28)
Close.Position = UDim2.new(1, -42, 0, 14)
Close.AutoButtonColor = false
Close.ZIndex = 5
Close.Parent = Main
corner(Close, 8)
stroke(Close, COLORS.stroke, 1, 0.35)
AceLockTopButton = Instance.new("TextButton")
AceLockTopButton.Name = "LockGUI"
AceLockTopButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AceLockTopButton.BackgroundTransparency = 0.28
AceLockTopButton.TextColor3 = COLORS.white
AceLockTopButton.TextSize = 8
AceLockTopButton.Font = Enum.Font.GothamBlack
AceLockTopButton.Size = UDim2.new(0, 32, 0, 28)
AceLockTopButton.Position = UDim2.new(1, -78, 0, 14)
AceLockTopButton.AutoButtonColor = false
AceLockTopButton.ZIndex = 5
AceLockTopButton.Parent = Main
corner(AceLockTopButton, 8)
stroke(AceLockTopButton, COLORS.stroke, 1, 0.35)
function AceUpdateGuiLockVisual()
if AceLockTopButton then
AceLockTopButton.Text = (_G.AceGuiLocked == true) and "UNLOCK" or "LOCK"
AceLockTopButton.BackgroundTransparency = (_G.AceGuiLocked == true) and 0.08 or 0.28
local st = AceLockTopButton:FindFirstChildOfClass("UIStroke")
if st then
st.Transparency = (_G.AceGuiLocked == true) and 0.08 or 0.35
st.Color = (_G.AceGuiLocked == true) and Color3.fromRGB(255,255,255) or COLORS.stroke
end
end
if setLockGuiVisual then pcall(setLockGuiVisual, _G.AceGuiLocked == true) end
end
AceLockTopButton.Activated:Connect(function()
_G.AceGuiLocked = not (_G.AceGuiLocked == true)
AceUpdateGuiLockVisual()
saveAceConfig()
end)
AceUpdateGuiLockVisual()
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 13, 0, 145)
Content.Size = UDim2.new(1, -26, 1, -157)
Content.ZIndex = 3
Content.Parent = Main
local Tabs = Instance.new("Frame")
Tabs.Name = "Tabs"
Tabs.BackgroundTransparency = 1
Tabs.Position = UDim2.new(0, 12, 0, 103)
Tabs.Size = UDim2.new(1, -24, 0, 34)
Tabs.ZIndex = 3
Tabs.Parent = Main
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Parent = Tabs
local pages = {}
local tabButtons = {}
local tabNames = {"MOVEMENT", "COMBAT", "KEYBINDS", "VISUALS", "SETTINGS"}
local activeTab = "MOVEMENT"
function addPage(name)
local page = Instance.new("ScrollingFrame")
page.Name = name
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.ScrollBarThickness = 0
page.ScrollBarImageTransparency = 1
page.CanvasSize = UDim2.new(0, 0, 0, 0)
page.AutomaticCanvasSize = Enum.AutomaticSize.Y
page.Size = UDim2.new(1, 0, 1, 0)
page.ZIndex = 3
page.Visible = false
page.Parent = Content
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = page
pages[name] = page
return page
end
function setTab(name)
activeTab = name
for pageName, page in pairs(pages) do
page.Visible = pageName == name
end
for tabName, btn in pairs(tabButtons) do
local on = tabName == name
btn.TextColor3 = on and COLORS.white or Color3.fromRGB(170, 170, 180)
btn.BackgroundTransparency = on and 0.28 or 0.72
local st = btn:FindFirstChildOfClass("UIStroke")
if st then
st.Transparency = on and 0.05 or 0.52
st.Color = on and Color3.fromRGB(245, 245, 255) or COLORS.stroke
end
end
end
for _, name in ipairs(tabNames) do
addPage(name)
local btn = Instance.new("TextButton")
btn.Name = name
btn.Size = UDim2.new(0, 62, 0, 34)
btn.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
btn.BackgroundTransparency = 0.72
btn.BorderSizePixel = 0
btn.Text = name
btn.TextColor3 = Color3.fromRGB(170, 170, 180)
btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
btn.TextStrokeTransparency = 0.35
btn.TextSize = 8
btn.Font = Enum.Font.GothamBlack
btn.AutoButtonColor = false
btn.ZIndex = 4
btn.Parent = Tabs
corner(btn, 7)
stroke(btn, COLORS.stroke, 1, 0.52)
tabButtons[name] = btn
btn.MouseButton1Click:Connect(function()
setTab(name)
end)
end
function section(parent, text, order)
local label = Instance.new("TextLabel")
label.Name = text
label.BackgroundTransparency = 1
label.Text = text
label.TextColor3 = Color3.fromRGB(245, 245, 255)
label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
label.TextStrokeTransparency = 0.22
label.TextSize = 11
label.Font = Enum.Font.GothamBlack
label.TextXAlignment = Enum.TextXAlignment.Left
label.Size = UDim2.new(1, -6, 0, 15)
label.LayoutOrder = order
label.ZIndex = 8
label.Parent = parent
return label
end
function baseRow(parent, labelText, order)
local row = Instance.new("Frame")
row.Name = labelText
row.BackgroundColor3 = COLORS.row
row.BackgroundTransparency = 0.3
row.Size = UDim2.new(1, -4, 0, 34)
row.BorderSizePixel = 0
row.LayoutOrder = order
row.ZIndex = 4
row.Parent = parent
corner(row, 9)
stroke(row, COLORS.strokeSoft, 1.15, 0.38)
local label = Instance.new("TextLabel")
label.Name = "Label"
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 = Color3.fromRGB(245, 245, 255)
label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
label.TextStrokeTransparency = 0.25
label.TextSize = 12
label.Font = Enum.Font.GothamSemibold
label.TextXAlignment = Enum.TextXAlignment.Left
label.Position = UDim2.new(0, 12, 0, 0)
label.Size = UDim2.new(1, -132, 1, 0)
label.ZIndex = 5
label.Parent = row
row.MouseEnter:Connect(function()
tween(row, {BackgroundTransparency = 0.22})
end)
row.MouseLeave:Connect(function()
tween(row, {BackgroundTransparency = 0.3})
end)
return row
end
function textboxRow(parent, labelText, value, order)
local row = baseRow(parent, labelText, order)
local box = Instance.new("TextBox")
box.Name = "ValueBox"
box.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
box.BackgroundTransparency = 0.18
box.Text = tostring(value or "")
box.TextColor3 = COLORS.white
box.TextSize = 12
box.Font = Enum.Font.GothamSemibold
box.ClearTextOnFocus = false
box.Size = UDim2.new(0, 58, 0, 24)
box.Position = UDim2.new(1, -68, 0.5, -12)
box.BorderSizePixel = 0
box.ZIndex = 6
box.Parent = row
corner(box, 7)
stroke(box, COLORS.strokeSoft, 1, 0.45)
return row, box
end
function toggleRow(parent, labelText, default, order)
local row = baseRow(parent, labelText, order)
local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.BackgroundTransparency = 1
button.Text = ""
button.Size = UDim2.new(1, 0, 1, 0)
button.Position = UDim2.new(0, 0, 0, 0)
button.AutoButtonColor = false
button.ZIndex = 7
button.Parent = row
local track = Instance.new("Frame")
track.Name = "Track"
track.BackgroundColor3 = COLORS.toggleBg
track.BackgroundTransparency = 0.2
track.Size = UDim2.new(0, 34, 0, 18)
track.Position = UDim2.new(1, -44, 0.5, -9)
track.BorderSizePixel = 0
track.ZIndex = 5
track.Parent = button
corner(track, 9)
stroke(track, COLORS.strokeSoft, 1, 0.45)
local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.BackgroundColor3 = COLORS.knob
knob.Size = UDim2.new(0, 13, 0, 13)
knob.Position = default and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
knob.BorderSizePixel = 0
knob.ZIndex = 6
knob.Parent = track
corner(knob, 999)
local shine = Instance.new("Frame")
shine.Name = "Shine"
shine.BackgroundColor3 = COLORS.white
shine.BackgroundTransparency = 0.72
shine.Size = UDim2.new(1, -4, 0, 4)
shine.Position = UDim2.new(0, 2, 0, 2)
shine.BorderSizePixel = 0
shine.ZIndex = 7
shine.Parent = knob
corner(shine, 4)
local state = default and true or false
local trackStroke = track:FindFirstChildOfClass("UIStroke")
local rowStroke = row:FindFirstChildOfClass("UIStroke")
local function setVisual(on)
state = on and true or false
tween(knob, {Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
tween(track, {
BackgroundTransparency = state and 0.03 or 0.2,
BackgroundColor3 = state and Color3.fromRGB(36, 36, 46) or COLORS.toggleBg
})
if trackStroke then
tween(trackStroke, {
Color = state and Color3.fromRGB(255, 255, 255) or COLORS.strokeSoft,
Transparency = state and 0.05 or 0.45,
Thickness = state and 1.25 or 1
})
end
if rowStroke then
tween(rowStroke, {
Color = state and Color3.fromRGB(245, 245, 255) or COLORS.strokeSoft,
Transparency = state and 0.12 or 0.38,
Thickness = state and 1.25 or 1.15
})
end
tween(row, {BackgroundTransparency = state and 0.16 or 0.3})
end
setVisual(state)
button.Activated:Connect(function()
end)
return row, setVisual
end
_G.AceSyncToggleVisuals = function()
pcall(function() if setAutoStealVisual then setAutoStealVisual(autoStealEnabled == true) end end)
pcall(function() if setInfJumpVisual then setInfJumpVisual(infJumpEnabled == true) end end)
pcall(function() if setAntiRagdollVisual then setAntiRagdollVisual(antiRagdollEnabled == true) end end)
pcall(function() if setAutoCarrySpeedVisual then setAutoCarrySpeedVisual(autoCarrySpeedEnabled == true) end end)
pcall(function() if setAutoTPVisual then setAutoTPVisual(autoTPEnabled == true) end end)
pcall(function() if setAutoResetOnMedVisual then setAutoResetOnMedVisual(autoResetOnMedEnabled == true) end end)
end
_G.AceActionToggleRow = function(parent, labelText, default, order)
local row = baseRow(parent, labelText, order)
local button = Instance.new("TextButton")
button.Name = "ToggleButton"
button.BackgroundTransparency = 1
button.Text = ""
button.Size = UDim2.new(1, 0, 1, 0)
button.Position = UDim2.new(0, 0, 0, 0)
button.AutoButtonColor = false
button.ZIndex = 7
button.Parent = row
local track = Instance.new("Frame")
track.Name = "Track"
track.BackgroundColor3 = COLORS.toggleBg
track.BackgroundTransparency = 0.2
track.Size = UDim2.new(0, 34, 0, 18)
track.Position = UDim2.new(1, -44, 0.5, -9)
track.BorderSizePixel = 0
track.ZIndex = 5
track.Parent = button
corner(track, 9)
stroke(track, COLORS.strokeSoft, 1, 0.45)
local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.BackgroundColor3 = COLORS.knob
knob.Size = UDim2.new(0, 13, 0, 13)
knob.Position = default and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
knob.BorderSizePixel = 0
knob.ZIndex = 6
knob.Parent = track
corner(knob, 999)
local shine = Instance.new("Frame")
shine.Name = "Shine"
shine.BackgroundColor3 = COLORS.white
shine.BackgroundTransparency = 0.72
shine.Size = UDim2.new(1, -4, 0, 4)
shine.Position = UDim2.new(0, 2, 0, 2)
shine.BorderSizePixel = 0
shine.ZIndex = 7
shine.Parent = knob
corner(shine, 4)
local trackStroke = track:FindFirstChildOfClass("UIStroke")
local rowStroke = row:FindFirstChildOfClass("UIStroke")
local function setVisual(on)
local state = on and true or false
tween(knob, {Position = state and UDim2.new(1, -16, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
tween(track, {
BackgroundTransparency = state and 0.03 or 0.2,
BackgroundColor3 = state and Color3.fromRGB(36, 36, 46) or COLORS.toggleBg
})
if trackStroke then
tween(trackStroke, {
Color = state and Color3.fromRGB(255, 255, 255) or COLORS.strokeSoft,
Transparency = state and 0.05 or 0.45,
Thickness = state and 1.25 or 1
})
end
if rowStroke then
tween(rowStroke, {
Color = state and Color3.fromRGB(245, 245, 255) or COLORS.strokeSoft,
Transparency = state and 0.12 or 0.38,
Thickness = state and 1.25 or 1.15
})
end
tween(row, {BackgroundTransparency = state and 0.16 or 0.3})
end
setVisual(default)
return row, setVisual, button
end
function dropdownRow(parent, labelText, value, order)
local row = baseRow(parent, labelText, order)
local select = Instance.new("TextButton")
select.Name = "Dropdown"
select.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
select.BackgroundTransparency = 0.18
select.Text = tostring(value or "None") .. "  â–¼"
select.TextColor3 = COLORS.white
select.TextSize = 11
select.Font = Enum.Font.GothamSemibold
select.Size = UDim2.new(0, 70, 0, 24)
select.Position = UDim2.new(1, -80, 0.5, -12)
select.BorderSizePixel = 0
select.ZIndex = 6
select.Parent = row
corner(select, 7)
stroke(select, COLORS.strokeSoft, 1, 0.45)
return row, select
end
local animationPackValueLabel = nil
function refreshAnimationPackRow()
if animationPackValueLabel then
animationPackValueLabel.Text = selectedAnimationPack
end
end
function animationPackRow(parent, order)
local row = baseRow(parent, "Animation Pack", order)
row.Size = UDim2.new(1, -4, 0, 42)
local label = row:FindFirstChild("Label")
if label then
label.Text = "Animation Pack"
label.Size = UDim2.new(0, 112, 1, 0)
label.TextSize = 11
end
local left = Instance.new("TextButton")
left.Name = "LeftArrow"
left.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
left.BackgroundTransparency = 0.18
left.Text = "<"
left.TextColor3 = COLORS.white
left.TextSize = 12
left.Font = Enum.Font.GothamSemibold
left.Size = UDim2.new(0, 42, 0, 28)
left.Position = UDim2.new(1, -156, 0.5, -14)
left.BorderSizePixel = 0
left.ZIndex = 6
left.Parent = row
corner(left, 8)
stroke(left, COLORS.strokeSoft, 1, 0.45)
animationPackValueLabel = Instance.new("TextLabel")
animationPackValueLabel.Name = "AnimationPackValue"
animationPackValueLabel.BackgroundTransparency = 1
animationPackValueLabel.Text = selectedAnimationPack
animationPackValueLabel.TextColor3 = COLORS.white
animationPackValueLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
animationPackValueLabel.TextStrokeTransparency = 0.25
animationPackValueLabel.TextSize = 11
animationPackValueLabel.Font = Enum.Font.GothamSemibold
animationPackValueLabel.TextXAlignment = Enum.TextXAlignment.Center
animationPackValueLabel.Size = UDim2.new(0, 62, 1, 0)
animationPackValueLabel.Position = UDim2.new(1, -112, 0, 0)
animationPackValueLabel.ZIndex = 6
animationPackValueLabel.Parent = row
local right = Instance.new("TextButton")
right.Name = "RightArrow"
right.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
right.BackgroundTransparency = 0.18
right.Text = ">"
right.TextColor3 = COLORS.white
right.TextSize = 12
right.Font = Enum.Font.GothamSemibold
right.Size = UDim2.new(0, 42, 0, 28)
right.Position = UDim2.new(1, -48, 0.5, -14)
right.BorderSizePixel = 0
right.ZIndex = 6
right.Parent = row
corner(right, 8)
stroke(right, COLORS.strokeSoft, 1, 0.45)
local function setPackIndex(nextIndex)
if nextIndex < 1 then nextIndex = #AnimationPackList end
if nextIndex > #AnimationPackList then nextIndex = 1 end
AnimationPackIndex = nextIndex
selectedAnimationPack = AnimationPackList[AnimationPackIndex]
refreshAnimationPackRow()
applyAnimationPack(selectedAnimationPack)
if saveAceConfig then pcall(saveAceConfig) end
end
left.MouseButton1Click:Connect(function()
setPackIndex(AnimationPackIndex - 1)
end)
right.MouseButton1Click:Connect(function()
setPackIndex(AnimationPackIndex + 1)
end)
return row
end
function keyName(key)
if not key then return "None" end
local name = tostring(key):gsub("Enum.KeyCode.", "")
name = name:gsub("Button", "BTN ")
name = name:gsub("DPad", "DPad ")
return name
end
function refreshSpeedKeybindButton(keyId)
local btn = speedKeybindButtons[keyId]
if btn then
if listeningForSpeedKey == keyId then
btn.Text = "Press..."
else
btn.Text = keyName(speedKeybinds[keyId])
end
end
end
function refreshAllSpeedKeybinds()
for keyId in pairs(speedKeybindButtons) do
refreshSpeedKeybindButton(keyId)
end
end
function refreshTPDownKeybind()
if tpDownKeybindButton then
tpDownKeybindButton.Text = listeningForTPDownKey and "Press..." or keyName(tpDownKeybind)
end
end
function tpDownKeybindRow(parent, order)
local row = baseRow(parent, "TP Down", order)
local btn = Instance.new("TextButton")
btn.Name = "TPDownKeybindButton"
btn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
btn.BackgroundTransparency = 0.18
btn.Text = keyName(tpDownKeybind)
btn.TextColor3 = COLORS.white
btn.TextSize = 11
btn.Font = Enum.Font.GothamSemibold
btn.Size = UDim2.new(0, 56, 0, 24)
btn.Position = UDim2.new(1, -64, 0.5, -12)
btn.BorderSizePixel = 0
btn.ZIndex = 6
btn.AutoButtonColor = false
btn.Parent = row
corner(btn, 7)
stroke(btn, COLORS.strokeSoft, 1, 0.45)
local clearBtn = Instance.new("TextButton")
clearBtn.Name = "ClearKeybindButton"
clearBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
clearBtn.BackgroundTransparency = 0.18
clearBtn.Text = "Ã—"
clearBtn.TextColor3 = COLORS.white
clearBtn.TextSize = 14
clearBtn.Font = Enum.Font.GothamBlack
clearBtn.Size = UDim2.new(0, 22, 0, 24)
clearBtn.Position = UDim2.new(1, -90, 0.5, -12)
clearBtn.BorderSizePixel = 0
clearBtn.ZIndex = 6
clearBtn.AutoButtonColor = false
clearBtn.Parent = row
corner(clearBtn, 7)
stroke(clearBtn, COLORS.strokeSoft, 1, 0.45)
tpDownKeybindButton = btn
btn.Activated:Connect(function()
listeningForSpeedKey = nil
listeningForTPDownKey = true
keybindListenStartedAt = tick()
refreshAllSpeedKeybinds()
refreshTPDownKeybind()
end)
clearBtn.Activated:Connect(function()
listeningForSpeedKey = nil
listeningForTPDownKey = false
tpDownKeybind = nil
if tpDownKeybindButton then tpDownKeybindButton.Text = "None" end
refreshAllSpeedKeybinds()
refreshTPDownKeybind()
saveAceConfig()
end)
return row, btn
end
function speedKeybindRow(parent, labelText, keyId, order)
local row = baseRow(parent, labelText, order)
local btn = Instance.new("TextButton")
btn.Name = "KeybindButton"
btn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
btn.BackgroundTransparency = 0.18
btn.Text = keyName(speedKeybinds[keyId])
btn.TextColor3 = COLORS.white
btn.TextSize = 11
btn.Font = Enum.Font.GothamSemibold
btn.Size = UDim2.new(0, 56, 0, 24)
btn.Position = UDim2.new(1, -64, 0.5, -12)
btn.BorderSizePixel = 0
btn.ZIndex = 6
btn.AutoButtonColor = false
btn.Parent = row
corner(btn, 7)
stroke(btn, COLORS.strokeSoft, 1, 0.45)
local clearBtn = Instance.new("TextButton")
clearBtn.Name = "ClearKeybindButton"
clearBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
clearBtn.BackgroundTransparency = 0.18
clearBtn.Text = "Ã—"
clearBtn.TextColor3 = COLORS.white
clearBtn.TextSize = 14
clearBtn.Font = Enum.Font.GothamBlack
clearBtn.Size = UDim2.new(0, 22, 0, 24)
clearBtn.Position = UDim2.new(1, -90, 0.5, -12)
clearBtn.BorderSizePixel = 0
clearBtn.ZIndex = 6
clearBtn.AutoButtonColor = false
clearBtn.Parent = row
corner(clearBtn, 7)
stroke(clearBtn, COLORS.strokeSoft, 1, 0.45)
speedKeybindButtons[keyId] = btn
btn.Activated:Connect(function()
listeningForSpeedKey = keyId
listeningForTPDownKey = false
keybindListenStartedAt = tick()
refreshAllSpeedKeybinds()
refreshTPDownKeybind()
end)
clearBtn.Activated:Connect(function()
listeningForSpeedKey = nil
listeningForTPDownKey = false
speedKeybinds[keyId] = nil
if speedKeybindButtons[keyId] then speedKeybindButtons[keyId].Text = "None" end
refreshAllSpeedKeybinds()
refreshTPDownKeybind()
saveAceConfig()
end)
return row, btn
end
local normalModeValueLabel = nil
local laggerModeValueLabel = nil
local aimbotButtonLabel = nil
local aimbotSpeedLabel = nil
local laggerAimbotSpeedLabel = nil
local combatAimbotKeybindLabel = nil
function getAimbotModeDisplay()
if selectedAimbotMode == "Anti Bypass" or selectedAimbotMode == "Bypass" then
return "Anti Bypass"
end
return "Normal"
end
function refreshAimbotButtonLabel()
if aimbotButtonLabel then
aimbotButtonLabel.Text = getAimbotModeDisplay() .. " Aimbot"
end
end
function refreshAimbotModeLabels()
local modeName = getAimbotModeDisplay()
if aimbotSpeedLabel then
aimbotSpeedLabel.Text = modeName .. " Aimbot Speed"
end
if laggerAimbotSpeedLabel then
laggerAimbotSpeedLabel.Text = modeName .. " Lagger Aimbot Speed"
end
if combatAimbotKeybindLabel then
combatAimbotKeybindLabel.Text = modeName .. " Aimbot"
end
refreshAimbotButtonLabel()
end
refreshSpeedModeRows = function()
if normalModeValueLabel then
normalModeValueLabel.Text = (currentSpeedMode == "Carry") and "Carry" or "Normal"
end
if laggerModeValueLabel then
laggerModeValueLabel.Text = (currentSpeedMode == "Lagger Carry") and "Lagger Carry" or "Lagger"
end
end
function modeDisplayRow(parent, order, side)
local row = baseRow(parent, "Mode", order)
row.Size = UDim2.new(1, -4, 0, 42)
row.BackgroundTransparency = 0.42
local label = row:FindFirstChild("Label")
if label then
label.Text = "Mode"
label.TextSize = 11
label.Size = UDim2.new(0, 110, 1, 0)
label.Position = UDim2.new(0, 12, 0, 0)
label.TextColor3 = Color3.fromRGB(245, 245, 255)
end
local value = Instance.new("TextLabel")
value.Name = "ModeValue"
value.BackgroundTransparency = 1
value.Text = side == "Normal" and "Normal" or "Lagger"
value.TextColor3 = Color3.fromRGB(255, 255, 255)
value.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
value.TextStrokeTransparency = 0.25
value.TextSize = 12
value.Font = Enum.Font.GothamSemibold
value.TextXAlignment = Enum.TextXAlignment.Right
value.Position = UDim2.new(1, -132, 0, 0)
value.Size = UDim2.new(0, 120, 1, 0)
value.ZIndex = 6
value.Parent = row
local click = Instance.new("TextButton")
click.Name = "ModeClick"
click.BackgroundTransparency = 1
click.Text = ""
click.Size = UDim2.new(1, 0, 1, 0)
click.Position = UDim2.new(0, 0, 0, 0)
click.AutoButtonColor = false
click.ZIndex = 8
click.Parent = row
if side == "Normal" then
normalModeValueLabel = value
click.MouseButton1Click:Connect(function()
setSpeedMode(currentSpeedMode == "Normal" and "Carry" or "Normal")
end)
else
laggerModeValueLabel = value
click.MouseButton1Click:Connect(function()
setSpeedMode(currentSpeedMode == "Lagger" and "Lagger Carry" or "Lagger")
end)
end
refreshSpeedModeRows()
return row, value
end
function aimbotModeButtonRow(parent, order)
local row, setVisual = toggleRow(parent, tostring(selectedAimbotMode) .. " Aimbot", false, order)
aimbotButtonLabel = row and row:FindFirstChild("Label")
_G.AceAimbotSetVisual = setVisual
refreshAimbotButtonLabel()
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
if _G.AceToggleSelectedAimbot then _G.AceToggleSelectedAimbot() end
end)
end
return row, setVisual
end
_G.AceAimbotSelectorRow = function(parent, order)
local holder = Instance.new("Frame")
holder.Name = "Aimbot Mode"
holder.BackgroundColor3 = COLORS.row
holder.BackgroundTransparency = 0.28
holder.Size = UDim2.new(1, -4, 0, 42)
holder.BorderSizePixel = 0
holder.LayoutOrder = order
holder.ZIndex = 4
holder.ClipsDescendants = true
holder.Parent = parent
corner(holder, 9)
stroke(holder, COLORS.strokeSoft, 1.15, 0.38)
local slide = Instance.new("Frame")
slide.Name = "SelectedSlide"
slide.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
slide.BackgroundTransparency = 0.08
slide.Size = UDim2.new(0.5, -3, 1, -8)
slide.Position = UDim2.new(0, 4, 0, 4)
slide.BorderSizePixel = 0
slide.ZIndex = 5
slide.Parent = holder
corner(slide, 9)
local slideStroke = Instance.new("UIStroke")
slideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
slideStroke.Color = Color3.fromRGB(235, 235, 245)
slideStroke.Thickness = 1
slideStroke.Transparency = 0.08
slideStroke.Parent = slide
local slideGradient = Instance.new("UIGradient")
slideGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(46, 46, 52)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22)),
})
slideGradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.08),
NumberSequenceKeypoint.new(0.5, 0.02),
NumberSequenceKeypoint.new(1, 0.08),
})
slideGradient.Parent = slide
local normalText = Instance.new("TextLabel")
normalText.Name = "NormalText"
normalText.BackgroundTransparency = 1
normalText.Text = "NORMAL"
normalText.TextColor3 = COLORS.white
normalText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
normalText.TextStrokeTransparency = 0.2
normalText.TextSize = 11
normalText.Font = Enum.Font.GothamSemibold
normalText.TextXAlignment = Enum.TextXAlignment.Center
normalText.Size = UDim2.new(0.5, 0, 1, 0)
normalText.Position = UDim2.new(0, 0, 0, 0)
normalText.ZIndex = 8
normalText.Parent = holder
local bypassText = Instance.new("TextLabel")
bypassText.Name = "BypassText"
bypassText.BackgroundTransparency = 1
bypassText.Text = "ANTI BYPASS"
bypassText.TextColor3 = COLORS.white
bypassText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
bypassText.TextStrokeTransparency = 0.2
bypassText.TextSize = 10
bypassText.Font = Enum.Font.GothamSemibold
bypassText.TextXAlignment = Enum.TextXAlignment.Center
bypassText.Size = UDim2.new(0.5, 0, 1, 0)
bypassText.Position = UDim2.new(0.5, 0, 0, 0)
bypassText.ZIndex = 8
bypassText.Parent = holder
local normalClick = Instance.new("TextButton")
normalClick.Name = "NormalClick"
normalClick.BackgroundTransparency = 1
normalClick.Text = ""
normalClick.AutoButtonColor = false
normalClick.Size = UDim2.new(0.5, 0, 1, 0)
normalClick.Position = UDim2.new(0, 0, 0, 0)
normalClick.ZIndex = 10
normalClick.Parent = holder
local bypassClick = Instance.new("TextButton")
bypassClick.Name = "BypassClick"
bypassClick.BackgroundTransparency = 1
bypassClick.Text = ""
bypassClick.AutoButtonColor = false
bypassClick.Size = UDim2.new(0.5, 0, 1, 0)
bypassClick.Position = UDim2.new(0.5, 0, 0, 0)
bypassClick.ZIndex = 10
bypassClick.Parent = holder
local function setMode(mode)
if mode == "Bypass" then
mode = "Anti Bypass"
elseif mode ~= "Anti Bypass" then
mode = "Normal"
end
selectedAimbotMode = mode
refreshAimbotModeLabels()
if _G.AceRefreshAimbotSpeedBoxes then _G.AceRefreshAimbotSpeedBoxes() end
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
saveAceConfig()
local onBypass = selectedAimbotMode == "Anti Bypass"
tween(slide, {
Position = onBypass and UDim2.new(0.5, -1, 0, 4) or UDim2.new(0, 4, 0, 4)
}, 0.18)
tween(normalText, {
TextTransparency = onBypass and 0.18 or 0,
TextStrokeTransparency = onBypass and 0.38 or 0.2
}, 0.14)
tween(bypassText, {
TextTransparency = onBypass and 0 or 0.18,
TextStrokeTransparency = onBypass and 0.2 or 0.38
}, 0.14)
end
normalClick.MouseButton1Click:Connect(function()
setMode("Normal")
end)
bypassClick.MouseButton1Click:Connect(function()
setMode("Anti Bypass")
end)
setMode(selectedAimbotMode)
return holder, setMode
end
function autoStealSelectorRow(parent, order)
local holder = Instance.new("Frame")
holder.Name = "Auto Steal Mode"
holder.BackgroundColor3 = COLORS.row
holder.BackgroundTransparency = 0.28
holder.Size = UDim2.new(1, -4, 0, 42)
holder.BorderSizePixel = 0
holder.LayoutOrder = order
holder.ZIndex = 4
holder.ClipsDescendants = true
holder.Parent = parent
corner(holder, 9)
stroke(holder, COLORS.strokeSoft, 1.15, 0.38)
local slide = Instance.new("Frame")
slide.Name = "SelectedSlide"
slide.BackgroundColor3 = Color3.fromRGB(58, 58, 64)
slide.BackgroundTransparency = 0.08
slide.Size = UDim2.new(0.5, -3, 1, -8)
slide.Position = UDim2.new(0, 4, 0, 4)
slide.BorderSizePixel = 0
slide.ZIndex = 5
slide.Parent = holder
corner(slide, 9)
local slideStroke = Instance.new("UIStroke")
slideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
slideStroke.Color = Color3.fromRGB(235, 235, 245)
slideStroke.Thickness = 1
slideStroke.Transparency = 0.08
slideStroke.Parent = slide
local slideGradient = Instance.new("UIGradient")
slideGradient.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 24, 28)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(46, 46, 52)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22)),
})
slideGradient.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0.08),
NumberSequenceKeypoint.new(0.5, 0.02),
NumberSequenceKeypoint.new(1, 0.08),
})
slideGradient.Parent = slide
local normalText = Instance.new("TextLabel")
normalText.Name = "NormalText"
normalText.BackgroundTransparency = 1
normalText.Text = "NORMAL"
normalText.TextColor3 = COLORS.white
normalText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
normalText.TextStrokeTransparency = 0.2
normalText.TextSize = 11
normalText.Font = Enum.Font.GothamSemibold
normalText.TextXAlignment = Enum.TextXAlignment.Center
normalText.Size = UDim2.new(0.5, 0, 1, 0)
normalText.Position = UDim2.new(0, 0, 0, 0)
normalText.ZIndex = 8
normalText.Parent = holder
local semiText = Instance.new("TextLabel")
semiText.Name = "SemiText"
semiText.BackgroundTransparency = 1
semiText.Text = "SEMI"
semiText.TextColor3 = COLORS.white
semiText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
semiText.TextStrokeTransparency = 0.2
semiText.TextSize = 11
semiText.Font = Enum.Font.GothamSemibold
semiText.TextXAlignment = Enum.TextXAlignment.Center
semiText.Size = UDim2.new(0.5, 0, 1, 0)
semiText.Position = UDim2.new(0.5, 0, 0, 0)
semiText.ZIndex = 8
semiText.Parent = holder
local normalClick = Instance.new("TextButton")
normalClick.Name = "NormalClick"
normalClick.BackgroundTransparency = 1
normalClick.Text = ""
normalClick.AutoButtonColor = false
normalClick.Size = UDim2.new(0.5, 0, 1, 0)
normalClick.Position = UDim2.new(0, 0, 0, 0)
normalClick.ZIndex = 10
normalClick.Parent = holder
local semiClick = Instance.new("TextButton")
semiClick.Name = "SemiClick"
semiClick.BackgroundTransparency = 1
semiClick.Text = ""
semiClick.AutoButtonColor = false
semiClick.Size = UDim2.new(0.5, 0, 1, 0)
semiClick.Position = UDim2.new(0.5, 0, 0, 0)
semiClick.ZIndex = 10
semiClick.Parent = holder
local function setMode(mode)
if mode ~= "Semi" then
mode = "Normal"
end
_G.AceStealRadii = _G.AceStealRadii or {Normal = 62, Semi = 9}
_G.AceStealRadii[selectedStealMode] = tonumber(autoStealRadius) or _G.AceStealRadii[selectedStealMode]
selectedStealMode = mode
autoStealRadius = _G.AceStealRadii[selectedStealMode] or ((selectedStealMode == "Semi") and 9 or 62)
if autoStealRadiusBox then
autoStealRadiusBox.Text = tostring(autoStealRadius)
end
saveAceConfig()
if _G.AceNormalAutoStealSetRadius then _G.AceNormalAutoStealSetRadius(_G.AceStealRadii.Normal or 62) end
if _G.AceSemiAutoStealSetRadius then _G.AceSemiAutoStealSetRadius(_G.AceStealRadii.Semi or 9) end
if _G.AceAutoStealSync then _G.AceAutoStealSync() end
local onSemi = selectedStealMode == "Semi"
tween(slide, {
Position = onSemi and UDim2.new(0.5, -1, 0, 4) or UDim2.new(0, 4, 0, 4)
}, 0.18)
tween(normalText, {
TextTransparency = onSemi and 0.18 or 0,
TextStrokeTransparency = onSemi and 0.38 or 0.2
}, 0.14)
tween(semiText, {
TextTransparency = onSemi and 0 or 0.18,
TextStrokeTransparency = onSemi and 0.2 or 0.38
}, 0.14)
end
normalClick.MouseButton1Click:Connect(function()
setMode("Normal")
end)
semiClick.MouseButton1Click:Connect(function()
setMode("Semi")
end)
setMode(selectedStealMode)
return holder, setMode
end
-- Spread the large one-time UI build over several frames so executing the
-- loadstring does not monopolize the client thread and visibly freeze play.
task.wait()
Movement = pages.MOVEMENT
section(Movement, "AUTO SPEED", -2)
_, setAutoCarrySpeedVisual = toggleRow(Movement, "Auto Carry Speed", autoCarrySpeedEnabled, -1)
do
local row = Movement:FindFirstChild("Auto Carry Speed")
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
autoCarrySpeedEnabled = not autoCarrySpeedEnabled
if autoCarrySpeedEnabled ~= true and _G.AutoCarrySpeed and _G.AutoCarrySpeed.Disable then
_G.AutoCarrySpeed.Disable()
end
if setAutoCarrySpeedVisual then setAutoCarrySpeedVisual(autoCarrySpeedEnabled == true) end
saveAceConfig()
end)
end
end
section(Movement, "NORMAL SPEED", 1)
_, normalSpeedBox = textboxRow(Movement, "Normal Speed", tostring(NS), 2)
normalSpeedBox.FocusLost:Connect(function()
local v = tonumber(normalSpeedBox.Text)
if v and v > 0 and v <= 250 then
NS = v
end
normalSpeedBox.Text = tostring(NS)
end)
_, carrySpeedBox = textboxRow(Movement, "Carry Speed", tostring(CS), 3)
carrySpeedBox.FocusLost:Connect(function()
local v = tonumber(carrySpeedBox.Text)
if v and v > 0 and v <= 250 then
CS = v
end
carrySpeedBox.Text = tostring(CS)
end)
modeDisplayRow(Movement, 4, "Normal")
section(Movement, "LAGGER SPEED", 5)
_, laggerSpeedBox = textboxRow(Movement, "Lagger Speed", tostring(LAGGER_SPEED), 6)
laggerSpeedBox.FocusLost:Connect(function()
local v = tonumber(laggerSpeedBox.Text)
if v and v > 0 and v <= 250 then
LAGGER_SPEED = v
end
laggerSpeedBox.Text = tostring(LAGGER_SPEED)
end)
_, laggerCarrySpeedBox = textboxRow(Movement, "Lagger Carry Speed", tostring(LAGGER_CARRY_SPEED), 7)
laggerCarrySpeedBox.FocusLost:Connect(function()
local v = tonumber(laggerCarrySpeedBox.Text)
if v and v > 0 and v <= 250 then
LAGGER_CARRY_SPEED = v
end
laggerCarrySpeedBox.Text = tostring(LAGGER_CARRY_SPEED)
end)
modeDisplayRow(Movement, 8, "Lagger")
section(Movement, "TELEPORT", 9)
autoTPRow = nil
autoTPRow, setAutoTPVisual = toggleRow(Movement, "Auto TP Down", autoTPEnabled, 10)
do
local autoTPButton = autoTPRow and autoTPRow:FindFirstChild("ToggleButton")
if autoTPButton then
autoTPButton.MouseButton1Click:Connect(function()
if autoTPClickDebounce then return end
autoTPClickDebounce = true
local nextState = not autoTPEnabled
toggleAutoTP(nextState)
task.delay(0.15, function()
autoTPClickDebounce = false
if setAutoTPVisual then setAutoTPVisual(autoTPEnabled) end
end)
end)
end
if autoTPEnabled then
startAutoTP()
else
stopAutoTP()
end
end
_, autoTPHeightBox = textboxRow(Movement, "Auto TP Height", tostring(autoTPHeight), 11)
autoTPHeightBox.FocusLost:Connect(function()
local v = tonumber(autoTPHeightBox.Text)
if v and v >= -500 and v <= 500 then
autoTPHeight = v
end
autoTPHeightBox.Text = tostring(autoTPHeight)
saveAceConfig()
end)
section(Movement, "JUMP", 15)
_, setInfJumpVisual = toggleRow(Movement, "Infinite Jump", infJumpEnabled, 16)
do
local row = Movement:FindFirstChild("Infinite Jump")
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
setInfJumpInternal(not infJumpEnabled)
if setInfJumpVisual then setInfJumpVisual(infJumpEnabled == true) end
saveAceConfig()
end)
end
end
_, setAntiRagdollVisual = toggleRow(Movement, "Anti Ragdoll", antiRagdollEnabled, 17)
do
local row = Movement:FindFirstChild("Anti Ragdoll")
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
setAntiRagdoll(not antiRagdollEnabled)
if setAntiRagdollVisual then setAntiRagdollVisual(antiRagdollEnabled == true) end
saveAceConfig()
end)
end
end
animationPackRow(Movement, 15)
refreshSpeedModeRows()
task.wait()
Combat = pages.COMBAT
section(Combat, "AUTO STEAL", 1)
autoStealSelectorRow(Combat, 2)
_aceRow, setAutoStealVisual = toggleRow(Combat, "Auto Steal", autoStealEnabled, 3)
do
_aceBtn = _aceRow and _aceRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
autoStealEnabled = not autoStealEnabled
if setAutoStealVisual then
setAutoStealVisual(autoStealEnabled)
end
if _G.AceAutoStealSync then _G.AceAutoStealSync() end
saveAceConfig()
end)
end
end
_, radiusBox = textboxRow(Combat, "Radius", tostring(autoStealRadius), 4)
autoStealRadiusBox = radiusBox
radiusBox.FocusLost:Connect(function()
local v = tonumber(radiusBox.Text)
if v and v > 0 and v <= 500 then
autoStealRadius = v
end
_G.AceStealRadii = _G.AceStealRadii or {Normal = 62, Semi = 9}
_G.AceStealRadii[selectedStealMode] = autoStealRadius
radiusBox.Text = tostring(autoStealRadius)
if _G.AceNormalAutoStealSetRadius then _G.AceNormalAutoStealSetRadius(_G.AceStealRadii.Normal or 62) end
if _G.AceSemiAutoStealSetRadius then _G.AceSemiAutoStealSetRadius(_G.AceStealRadii.Semi or 9) end
if _G.AceAutoStealSync then _G.AceAutoStealSync() end
saveAceConfig()
end)
section(Combat, "NORMAL/BYPASS AIMBOT", 5)
_G.AceAimbotSelectorRow(Combat, 6)
_G.AceAimbotSetVisual = nil
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
_G.AceNormalAutoSwingRow, _G.AceNormalAutoSwingSetVisual, _G.AceNormalAutoSwingBtn = _G.AceActionToggleRow(Combat, "Auto Swing", autoSwingEnabled, 7)
do
if _G.AceNormalAutoSwingBtn then
_G.AceNormalAutoSwingBtn.MouseButton1Click:Connect(function()
if _G.AceAutoSwingClickBusy then return end
_G.AceAutoSwingClickBusy = true
autoSwingEnabled = not autoSwingEnabled
if _G.AceNormalAutoSwingSetVisual then _G.AceNormalAutoSwingSetVisual(autoSwingEnabled) end
saveAceConfig()
task.delay(0.12, function() _G.AceAutoSwingClickBusy = false end)
end)
end
end
_G.AceMirrorTPDownRow, _G.AceMirrorTPDownSetVisual, _G.AceMirrorTPDownBtn = _G.AceActionToggleRow(Combat, "Mirror TP Down (Recommended)", mirrorTPDownEnabled, 7.1)
local mirrorTPDownLabel = _G.AceMirrorTPDownRow and _G.AceMirrorTPDownRow:FindFirstChild("Label")
if mirrorTPDownLabel then mirrorTPDownLabel.TextSize = 10 end
if _G.AceMirrorTPDownBtn then
_G.AceMirrorTPDownBtn.MouseButton1Click:Connect(function()
if _G.AceMirrorTPDownClickBusy then return end
_G.AceMirrorTPDownClickBusy = true
_G.AceSetMirrorTPDown(not mirrorTPDownEnabled)
saveAceConfig()
task.delay(0.12, function() _G.AceMirrorTPDownClickBusy = false end)
end)
end
aimbotSpeedRow, aimbotSpeedBox = textboxRow(Combat, "Normal Aimbot Speed", tostring(AIMBOT_SPEED), 8)
_G.AceAimbotSpeedBox = aimbotSpeedBox
aimbotSpeedLabel = aimbotSpeedRow and aimbotSpeedRow:FindFirstChild("Label")
refreshAimbotModeLabels()
aimbotSpeedBox.FocusLost:Connect(function()
local v = tonumber(aimbotSpeedBox.Text)
if v and v > 0 and v <= 250 then
_G.AceSetSelectedAimbotSpeedValues(v, nil)
end
if _G.AceRefreshAimbotSpeedBoxes then _G.AceRefreshAimbotSpeedBoxes() else aimbotSpeedBox.Text = tostring(AIMBOT_SPEED) end
saveAceConfig()
end)
laggerAimbotSpeedRow, laggerAimbotSpeedBox = textboxRow(Combat, "Normal Lagger Aimbot Speed", tostring(LAGGER_AIMBOT_SPEED), 9)
_G.AceLaggerAimbotSpeedBox = laggerAimbotSpeedBox
laggerAimbotSpeedLabel = laggerAimbotSpeedRow and laggerAimbotSpeedRow:FindFirstChild("Label")
refreshAimbotModeLabels()
if _G.AceRefreshAimbotSpeedBoxes then _G.AceRefreshAimbotSpeedBoxes() end
laggerAimbotSpeedBox.FocusLost:Connect(function()
local v = tonumber(laggerAimbotSpeedBox.Text)
if v and v > 0 and v <= 250 then
_G.AceSetSelectedAimbotSpeedValues(nil, v)
end
if _G.AceRefreshAimbotSpeedBoxes then _G.AceRefreshAimbotSpeedBoxes() else laggerAimbotSpeedBox.Text = tostring(LAGGER_AIMBOT_SPEED) end
saveAceConfig()
end)
section(Combat, "ANTI DESYNC BAT", 10)
_G.AceAntiDesyncAutoSwingRow, _G.AceAntiDesyncAutoSwingSetVisual, _G.AceAntiDesyncAutoSwingBtn = _G.AceActionToggleRow(Combat, "Auto Swing", antiDesyncAutoSwingEnabled, 11)
do
if _G.AceAntiDesyncAutoSwingBtn then
_G.AceAntiDesyncAutoSwingBtn.MouseButton1Click:Connect(function()
if _G.AceAntiDesyncAutoSwingClickBusy then return end
_G.AceAntiDesyncAutoSwingClickBusy = true
antiDesyncAutoSwingEnabled = not antiDesyncAutoSwingEnabled
if _G.AceAntiDesyncAutoSwingSetVisual then _G.AceAntiDesyncAutoSwingSetVisual(antiDesyncAutoSwingEnabled) end
saveAceConfig()
task.delay(0.12, function() _G.AceAntiDesyncAutoSwingClickBusy = false end)
end)
end
end
_G.AceAntiDesyncSetVisual = function(_) end
section(Combat, "COUNTERS", 13)
_aceRow, setBatCounterVisual = _G.AceActionToggleRow(Combat, "Bat Counter", batCounterEnabled, 14)
do
_aceBtn = _aceRow and _aceRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
batCounterEnabled = not batCounterEnabled
if setBatCounterVisual then
setBatCounterVisual(batCounterEnabled)
end
if batCounterEnabled then
if _G.AceStartBatCounter then _G.AceStartBatCounter() end
else
if _G.AceStopBatCounter then _G.AceStopBatCounter() end
end
saveAceConfig()
end)
end
end
_aceRow, setMedCounterVisual = _G.AceActionToggleRow(Combat, "Med Counter", medCounterEnabled, 15)
do
_aceBtn = _aceRow and _aceRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
medCounterEnabled = not medCounterEnabled
if setMedCounterVisual then
setMedCounterVisual(medCounterEnabled)
end
if medCounterEnabled then
if _G.AceStartMedCounter then _G.AceStartMedCounter(LP.Character) end
else
if _G.AceStopMedCounter then _G.AceStopMedCounter() end
end
saveAceConfig()
end)
end
end
_aceRow, _G.AceSetNoPlayerCollisionVisual = _G.AceActionToggleRow(Combat, "No Player Collision", _G.AceNoPlayerCollisionEnabled, 16)
do
_aceBtn = _aceRow and _aceRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
_G.AceNoPlayerCollisionEnabled = not _G.AceNoPlayerCollisionEnabled
if _G.AceSetNoPlayerCollisionVisual then _G.AceSetNoPlayerCollisionVisual(_G.AceNoPlayerCollisionEnabled) end
if _G.AceNoPlayerCollisionEnabled then
if enableNoPlayerCollision then enableNoPlayerCollision() end
else
if disableNoPlayerCollision then disableNoPlayerCollision() end
end
saveAceConfig()
end)
end
end
_aceRow, setSafeModeVisual = _G.AceActionToggleRow(Combat, "Safe Mode", antiKickEnabled, 17)
do
_aceBtn = _aceRow and _aceRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
antiKickEnabled = not antiKickEnabled
if setSafeModeVisual then setSafeModeVisual(antiKickEnabled) end
if antiKickEnabled and _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE") end
saveAceConfig()
end)
end
end
_aceRow, setAutoResetOnMedVisual = toggleRow(Combat, "Auto Reset On Med Fling", autoResetOnMedEnabled, 18)
do
_aceBtn = _aceRow and _aceRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
if _G.AceSetAutoResetOnMed then
_G.AceSetAutoResetOnMed(not autoResetOnMedEnabled)
else
autoResetOnMedEnabled = not autoResetOnMedEnabled
if setAutoResetOnMedVisual then setAutoResetOnMedVisual(autoResetOnMedEnabled) end
saveAceConfig()
end
end)
end
end
task.wait()
Keybinds = pages.KEYBINDS
section(Keybinds, "MOVEMENT KEYBINDS", 1)
speedKeybindRow(Keybinds, "Speed Key", "SpeedToggle", 2)
speedKeybindRow(Keybinds, "Lagger Mode Key", "LaggerToggle", 3)
tpDownKeybindRow(Keybinds, 4)
speedKeybindRow(Keybinds, "Drop Brainrot", "DropBrainrot", 5)
section(Keybinds, "COMBAT KEYBINDS", 6)
aimbotKeybindRow = speedKeybindRow(Keybinds, "Normal Aimbot", "Aimbot", 7)
combatAimbotKeybindLabel = aimbotKeybindRow and aimbotKeybindRow:FindFirstChild("Label")
refreshAimbotModeLabels()
speedKeybindRow(Keybinds, "Anti Desync Bat", "AntiDesyncAimbot", 8)
speedKeybindRow(Keybinds, "Auto Left", "AutoLeft", 9)
speedKeybindRow(Keybinds, "Auto Right", "AutoRight", 10)
speedKeybindRow(Keybinds, "Instant Reset", "InstantReset", 12)
do
THEME_ACCENT = THEME_ACCENT or Color3.fromRGB(230, 230, 230)
THEME_ACCENT_DIM = THEME_ACCENT_DIM or Color3.fromRGB(145, 145, 145)
PlayerESP = PlayerESP or {enabled=false, playerData={}, conns={}, discordText="discord.gg/aceduels"}
BoxedESPOptions = BoxedESPOptions or {box=false, tracer=false}
BoxedESPData = BoxedESPData or {}
BoxedESPConn = BoxedESPConn or nil
stretchRezConn = stretchRezConn or nil
antiLagDescConn = antiLagDescConn or nil
noCamCollisionConn = noCamCollisionConn or nil
noCamCollisionParts = noCamCollisionParts or {}
_aceNukeConns = _aceNukeConns or {}
_aceNukeOn = _aceNukeOn or false
_aceCustomFontOrig = _aceCustomFontOrig or {}
_aceCustomFontConn = _aceCustomFontConn or nil
_aceCustomFont = _aceCustomFont or nil
function startPlayerESP()
if PlayerESP.enabled then return end
PlayerESP.enabled = true
function cleanup(plr)
local d=PlayerESP.playerData[plr]; if not d then return end
pcall(function() if d.highlight then d.highlight:Destroy() end end)
pcall(function() if d.billboard then d.billboard:Destroy() end end)
if d.conns then for _,c in ipairs(d.conns) do pcall(function() c:Disconnect() end) end end
PlayerESP.playerData[plr]=nil
end
function setup(plr,char)
if not PlayerESP.enabled or plr==LP then return end
cleanup(plr)
local hrp=char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart",5))
local head=char and (char:FindFirstChild("Head") or char:WaitForChild("Head",5))
if not hrp or not head then return end
local hl=Instance.new("Highlight")
hl.Name="AceDuelsESP"; hl.Adornee=char; hl.FillColor=Color3.fromRGB(35,35,35); hl.FillTransparency=0.72
hl.OutlineColor=Color3.fromRGB(245,245,245); hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char
local bb=Instance.new("BillboardGui")
bb.Name="AceDuelsESPTag"; bb.Adornee=head; bb.Size=UDim2.new(0,124,0,34); bb.StudsOffset=Vector3.new(0,2.7,0); bb.AlwaysOnTop=true; bb.LightInfluence=0; bb.Parent=head
local box=Instance.new("Frame",bb); box.Size=UDim2.new(1,0,1,0); box.BackgroundTransparency=1; box.BorderSizePixel=0
Instance.new("UICorner",box).CornerRadius=UDim.new(0,9)
local n=Instance.new("TextLabel",box); n.Size=UDim2.new(1,-10,0,17); n.Position=UDim2.new(0,5,0,2); n.BackgroundTransparency=1; n.TextColor3=Color3.fromRGB(255,255,255); n.Font=Enum.Font.GothamBlack; n.TextSize=15; n.TextStrokeTransparency=0.38
local sub=Instance.new("TextLabel",box); sub.Size=UDim2.new(1,-10,0,11); sub.Position=UDim2.new(0,5,0,19); sub.BackgroundTransparency=1; sub.TextColor3=Color3.fromRGB(180,180,180); sub.Font=Enum.Font.GothamBold; sub.TextSize=10; sub.TextStrokeTransparency=0.58
local conn=RunService.Heartbeat:Connect(function()
if not PlayerESP.enabled or not hrp.Parent then return end
local v=hrp.AssemblyLinearVelocity or hrp.Velocity
n.Text=string.format("%d speed", math.floor(Vector3.new(v.X,0,v.Z).Magnitude+0.5)); sub.Text=plr.Name
end)
PlayerESP.playerData[plr]={highlight=hl,billboard=bb,conns={conn}}
end
for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then if plr.Character then setup(plr,plr.Character) end; table.insert(PlayerESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(setup,plr,c) end)) end end
table.insert(PlayerESP.conns, Players.PlayerAdded:Connect(function(plr) if plr~=LP then table.insert(PlayerESP.conns, plr.CharacterAdded:Connect(function(c) task.defer(setup,plr,c) end)) end end))
table.insert(PlayerESP.conns, Players.PlayerRemoving:Connect(cleanup))
end
function stopPlayerESP()
PlayerESP.enabled=false
for _,c in ipairs(PlayerESP.conns or {}) do pcall(function() c:Disconnect() end) end
PlayerESP.conns={}
for plr,d in pairs(PlayerESP.playerData or {}) do pcall(function() if d.highlight then d.highlight:Destroy() end end); pcall(function() if d.billboard then d.billboard:Destroy() end end) end
PlayerESP.playerData={}
end
function _aceEspColor()
return THEME_ACCENT or Color3.fromRGB(230,230,230)
end
function _safeDrawing(kind, props)
if not Drawing or not Drawing.new then return nil end
local ok, obj = pcall(function() return Drawing.new(kind) end)
if not ok or not obj then return nil end
for k,v in pairs(props or {}) do pcall(function() obj[k]=v end) end
return obj
end
function _cleanupBoxedESPPlayer(player)
local data = BoxedESPData[player]
if not data then return end
for _,obj in pairs(data) do
pcall(function()
obj.Visible = false
if obj.Remove then obj:Remove() end
end)
end
BoxedESPData[player] = nil
end
function _cleanupBoxedESP()
for player,_ in pairs(BoxedESPData) do _cleanupBoxedESPPlayer(player) end
end
function _updateBoxedESP()
local cam = workspace.CurrentCamera
if not cam then return end
local anyOn = BoxedESPOptions.box or BoxedESPOptions.tracer
if not anyOn then
_cleanupBoxedESP()
return
end
for _,player in ipairs(Players:GetPlayers()) do
if player == LP then continue end
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local head = char and char:FindFirstChild("Head")
if not root or not head then
_cleanupBoxedESPPlayer(player)
continue
end
local rootPos,onScreen = cam:WorldToViewportPoint(root.Position)
local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.55,0))
local data = BoxedESPData[player]
if not data then
data = {
box = _safeDrawing("Square",{Thickness=2,Filled=false,Transparency=1,Color=_aceEspColor()}),
tracer = _safeDrawing("Line",{Thickness=2,Transparency=1,Color=_aceEspColor()}),
}
BoxedESPData[player] = data
end
local color = _aceEspColor()
local height = math.abs(headPos.Y - rootPos.Y) * 2.15
if height < 20 or height ~= height then height = 65 end
local width = height / 2.15
local view = cam.ViewportSize
local centerX, centerY = view.X/2, view.Y/2
local targetX, targetY = rootPos.X, rootPos.Y + height/2
local targetVisible = onScreen and rootPos.Z > 0
if not targetVisible then
local dx = rootPos.X - centerX
local dy = rootPos.Y - centerY
if rootPos.Z <= 0 then
dx = -dx
dy = -dy
end
if math.abs(dx) < 1 and math.abs(dy) < 1 then
local rel = cam.CFrame:PointToObjectSpace(root.Position)
dx = rel.X
dy = -rel.Y
if rootPos.Z <= 0 then
dx = -dx
dy = -dy
end
end
local edgePad = 10
local scaleX = (dx ~= 0) and ((view.X/2 - edgePad) / math.abs(dx)) or math.huge
local scaleY = (dy ~= 0) and ((view.Y/2 - edgePad) / math.abs(dy)) or math.huge
local scale = math.min(scaleX, scaleY)
if scale == math.huge or scale ~= scale then scale = 1 end
targetX = math.clamp(centerX + dx * scale, edgePad, view.X - edgePad)
targetY = math.clamp(centerY + dy * scale, edgePad, view.Y - edgePad)
end
if data.box then
data.box.Color = color
data.box.Size = Vector2.new(width,height)
data.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
data.box.Visible = BoxedESPOptions.box == true and targetVisible
end
if data.tracer then
data.tracer.Color = color
local localChar = LP.Character
local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
local localHead = localChar and localChar:FindFirstChild("Head")
local fromX, fromY
if localRoot then
local localScreen = cam:WorldToViewportPoint(localRoot.Position)
fromX = localScreen.X
fromY = localScreen.Y + 15
end
if not fromX or not fromY then
fromX = cam.ViewportSize.X/2
fromY = cam.ViewportSize.Y - 88
end
data.tracer.From = Vector2.new(fromX, fromY)
data.tracer.To = Vector2.new(targetX, targetY)
data.tracer.Visible = BoxedESPOptions.tracer == true
end
end
end
function refreshBoxedESP()
local anyOn = BoxedESPOptions.box or BoxedESPOptions.tracer
if anyOn and not BoxedESPConn then
BoxedESPConn = RunService.RenderStepped:Connect(_updateBoxedESP)
elseif (not anyOn) and BoxedESPConn then
BoxedESPConn:Disconnect()
BoxedESPConn = nil
_cleanupBoxedESP()
end
end
Players.PlayerRemoving:Connect(_cleanupBoxedESPPlayer)
SKY_PRESETS_LIST={"Off","Night","Aurora","Sunset","Galaxy","Tech","Sakura","Pink Night","Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse","Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}
SKY_PRESETS={Off={kind="off"},Night={clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140}},Aurora={clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150}},Sunset={clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110}},Galaxy={clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110}},Tech={clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180}},Sakura={clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170}},["Pink Night"]={clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120}},["Blood Moon"]={clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50}},["Emerald Dawn"]={clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150}},Volcanic={clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50}},Arctic={clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245}},["Midnight Ocean"]={clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140}},Vaporwave={clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210}},Toxic={clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90}},["Solar Eclipse"]={clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70}},Hellscape={clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40}},Heaven={clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220}},Storm={clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120}},Sunrise={clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140}},["Deep Space"]={clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60}},["Lavender Dream"]={clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230}},Inferno={clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50}},["Mint Sky"]={clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220}}}
function _vC3(t) return Color3.fromRGB(t[1],t[2],t[3]) end
function _v4mpClearSky()
for _,v in ipairs(Lighting:GetChildren()) do if v:GetAttribute("_AceDuelsSky") then pcall(function() v:Destroy() end) end end
local terrain=workspace:FindFirstChildOfClass("Terrain"); if terrain then for _,v in ipairs(terrain:GetChildren()) do if v:GetAttribute("_AceDuelsSky") then pcall(function() v:Destroy() end) end end end
end
function applyCustomSky(mode)
_v4mpClearSky(); local p=SKY_PRESETS[mode]
if not p or p.kind=="off" then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.GlobalShadows=true; skyTheme="Off"; return end
Lighting.ClockTime=p.clock or 14; Lighting.Brightness=p.brightness or 2; if p.ambient then Lighting.Ambient=_vC3(p.ambient) end; if p.outAmb then Lighting.OutdoorAmbient=_vC3(p.outAmb) end
local atm=Instance.new("Atmosphere"); atm:SetAttribute("_AceDuelsSky",true); atm.Density=0.35; atm.Color=Lighting.Ambient; atm.Decay=Lighting.OutdoorAmbient; atm.Parent=Lighting
local sky=Instance.new("Sky"); sky:SetAttribute("_AceDuelsSky",true); sky.StarCount=(mode=="Galaxy" or mode=="Deep Space") and 10000 or 2000; sky.Parent=Lighting
skyTheme=mode
end
_G.AceStretchFOV = _G.AceStretchFOV or 120
function enableStretchRez()
fpsBoostEnabled=true
local cam=workspace.CurrentCamera
if not cam then return end
if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn=nil end
stretchRezConn=RunService.RenderStepped:Connect(function()
if not fpsBoostEnabled then if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn=nil end; return end
cam=workspace.CurrentCamera
if cam then
if not fovEnabled then pcall(function() cam.FieldOfView=_G.AceStretchFOV end) end
end
end)
end
function disableStretchRez()
fpsBoostEnabled=false
if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn=nil end
if not fovEnabled and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=70 end
end
function enableCustomFov() fovEnabled=true; workspace.CurrentCamera.FieldOfView=fovValue; if customFovConn then customFovConn:Disconnect() end; customFovConn=RunService.RenderStepped:Connect(function() if not fovEnabled then customFovConn:Disconnect(); customFovConn=nil; return end; workspace.CurrentCamera.FieldOfView=fovValue end) end
function disableCustomFov() fovEnabled=false; if customFovConn then customFovConn:Disconnect(); customFovConn=nil end; workspace.CurrentCamera.FieldOfView=fpsBoostEnabled and 107 or 70 end
function _applyAntiLagObj(obj)
pcall(function()
if obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic; obj.Reflectance=0; obj.CastShadow=false
elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled=false end
end)
end
function applyKTMOptimization()
pcall(function() Lighting.GlobalShadows=false; Lighting.FogEnd=1e10; Lighting.EnvironmentDiffuseScale=0; Lighting.EnvironmentSpecularScale=0 end)
for _,obj in ipairs(workspace:GetDescendants()) do _applyAntiLagObj(obj) end
if antiLagDescConn then antiLagDescConn:Disconnect() end
antiLagDescConn=workspace.DescendantAdded:Connect(function(obj) if antiLagVisualEnabled or nukeOptimiserEnabled then _applyAntiLagObj(obj) end end)
end
function enableAntiLag() antiLagVisualEnabled=true; applyKTMOptimization() end
function disableAntiLag() antiLagVisualEnabled=false; if antiLagDescConn and not nukeOptimiserEnabled then antiLagDescConn:Disconnect(); antiLagDescConn=nil end end
function enableNukeOptimizer()
nukeOptimiserEnabled=true; _aceNukeOn=true; applyKTMOptimization(); applyCustomSky("Off")
for _,c in ipairs(_aceNukeConns) do pcall(function() c:Disconnect() end) end; _aceNukeConns={}
table.insert(_aceNukeConns, workspace.DescendantAdded:Connect(function(o) if nukeOptimiserEnabled then _applyAntiLagObj(o) end end))
task.spawn(function() while nukeOptimiserEnabled do pcall(function() setfpscap(240) end); task.wait(3) end end)
end
function disableNukeOptimizer() nukeOptimiserEnabled=false; _aceNukeOn=false; for _,c in ipairs(_aceNukeConns) do pcall(function() c:Disconnect() end) end; _aceNukeConns={} end
function enableNoCamCollision()
noCamCollisionEnabled=true; if noCamCollisionConn then noCamCollisionConn:Disconnect() end
noCamCollisionConn=RunService.RenderStepped:Connect(function()
if not noCamCollisionEnabled then return end
local cam=workspace.CurrentCamera; local char=LP.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); if not cam or not hrp then return end
local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={char}; params.IgnoreWater=true
local res=workspace:Raycast(cam.CFrame.Position,(hrp.Position+Vector3.new(0,1.5,0))-cam.CFrame.Position,params)
local hit={}
if res and res.Instance and res.Instance:IsA("BasePart") then hit[res.Instance]=true; if noCamCollisionParts[res.Instance]==nil then noCamCollisionParts[res.Instance]=res.Instance.LocalTransparencyModifier end; res.Instance.LocalTransparencyModifier=1 end
for part,orig in pairs(noCamCollisionParts) do if not hit[part] then pcall(function() if part and part.Parent then part.LocalTransparencyModifier=orig end end); noCamCollisionParts[part]=nil end end
end)
end
function disableNoCamCollision() noCamCollisionEnabled=false; if noCamCollisionConn then noCamCollisionConn:Disconnect(); noCamCollisionConn=nil end; for p,orig in pairs(noCamCollisionParts) do pcall(function() if p and p.Parent then p.LocalTransparencyModifier=orig end end) end; noCamCollisionParts={} end
function enableCustomFont() customFontVisualEnabled=false; if V then V.customFontEnabled=false end end
function disableCustomFont() customFontVisualEnabled=false; if V then V.customFontEnabled=false end end
end
V = V or {}
V.skyTheme = skyTheme or V.skyTheme or "Off"
V.nukeOptEnabled = nukeOptimiserEnabled == true
V.customFontEnabled = false
V.potatoGraphicsEnabled = V.potatoGraphicsEnabled or false
function enableNoCamCollision()
noCamCollisionEnabled = true
if noCamCollisionConn then noCamCollisionConn:Disconnect() end
noCamCollisionConn = RunService.RenderStepped:Connect(function()
if not noCamCollisionEnabled then
if noCamCollisionConn then noCamCollisionConn:Disconnect();noCamCollisionConn=nil end
return
end
local cam = workspace.CurrentCamera
local char = LP.Character
if not cam or not char then return end
local hrp = char:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local camPos = cam.CFrame.Position
local charPos = hrp.Position + Vector3.new(0,1.5,0)
local toChar = charPos - camPos
if toChar.Magnitude < 0.3 then return end
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {char}
params.IgnoreWater = true
local hit = {}
local origin = camPos
local remaining = toChar
for _ = 1,12 do
if remaining.Magnitude < 0.2 then break end
local res = workspace:Raycast(origin,remaining,params)
if not res then break end
local part = res.Instance
if part and part:IsA("BasePart") and not part:IsDescendantOf(char) then
hit[part] = true
if noCamCollisionParts[part] == nil then noCamCollisionParts[part] = part.LocalTransparencyModifier end
part.LocalTransparencyModifier = 1
end
origin = res.Position + remaining.Unit * 0.02
remaining = charPos - origin
end
for part,orig in pairs(noCamCollisionParts) do
if not hit[part] then
pcall(function() if part and part.Parent then part.LocalTransparencyModifier = orig end end)
noCamCollisionParts[part] = nil
end
end
end)
end
function disableNoCamCollision()
noCamCollisionEnabled = false
if noCamCollisionConn then noCamCollisionConn:Disconnect();noCamCollisionConn=nil end
for part,orig in pairs(noCamCollisionParts) do
pcall(function() if part and part.Parent then part.LocalTransparencyModifier = orig end end)
end
noCamCollisionParts = {}
end
SKY_PRESETS_LIST = {"Off","Night","Aurora","Sunset","Galaxy","Tech","Sakura","Pink Night",
"Blood Moon","Emerald Dawn","Volcanic","Arctic","Midnight Ocean","Vaporwave","Toxic","Solar Eclipse",
"Hellscape","Heaven","Storm","Sunrise","Deep Space","Lavender Dream","Inferno","Mint Sky"}
SKY_PRESETS = {
["Off"] = {kind = "off"},
["Night"] = {clock=22,brightness=2,ambient={110,100,130},outAmb={120,110,140},sky={stars=4000,moon=18,sun=0,moonTex=true},atm={dens=0.45,color={120,60,180},decay={60,20,100},glare=0.5,haze=1.2}},
["Aurora"] = {clock=14,brightness=3,ambient={150,120,150},outAmb={160,130,150},atm={dens=0.55,color={255,80,200},decay={255,20,150},glare=2.5,haze=3},clouds={cover=0.7,dens=0.7,color={255,240,250}}},
["Sunset"] = {clock=17.2,brightness=2.5,ambient={170,120,100},outAmb={180,130,110},sky={stars=0,sun=25,moon=0},atm={dens=0.5,color={255,130,60},decay={255,80,30},glare=2,haze=2.5},clouds={cover=0.55,dens=0.55,color={255,200,140}}},
["Galaxy"] = {clock=0,brightness=1.5,ambient={70,60,100},outAmb={80,70,110},sky={stars=10000,moon=30,sun=0},atm={dens=0.15,color={40,20,80},decay={20,10,50},glare=0.3,haze=0.5}},
["Tech"] = {clock=21,brightness=2.2,ambient={90,130,170},outAmb={100,140,180},sky={stars=2000,moon=12},atm={dens=0.4,color={0,200,255},decay={150,0,255},glare=2,haze=2},clouds={cover=0.4,dens=0.6,color={100,200,255}}},
["Sakura"] = {clock=11,brightness=3.5,ambient={170,150,160},outAmb={180,160,170},sky={sun=8},atm={dens=0.3,color={255,200,220},decay={255,170,200},glare=1,haze=1.5},clouds={cover=0.6,dens=0.4,color={255,250,252}}},
["Pink Night"] = {clock=23,brightness=2.2,ambient={120,60,110},outAmb={140,70,120},sky={stars=5000,moon=22,sun=0,moonTex=true},atm={dens=0.5,color={255,80,180},decay={140,30,100},glare=0.7,haze=1.4},clouds={cover=0.3,dens=0.5,color={180,90,150}}},
["Blood Moon"] = {clock=22.5,brightness=1.6,ambient={130,40,40},outAmb={150,50,50},sky={stars=1500,moon=28,sun=0,moonTex=true},atm={dens=0.6,color={220,30,30},decay={120,10,10},glare=1.4,haze=2},clouds={cover=0.5,dens=0.7,color={120,30,30}}},
["Emerald Dawn"] = {clock=6.5,brightness=2.8,ambient={130,170,140},outAmb={140,180,150},sky={sun=18,moon=0,stars=0},atm={dens=0.4,color={80,200,140},decay={40,150,90},glare=1.8,haze=2.2},clouds={cover=0.5,dens=0.5,color={200,255,220}}},
["Volcanic"] = {clock=19,brightness=2,ambient={180,80,40},outAmb={200,90,50},sky={stars=200,sun=12,moon=0},atm={dens=0.75,color={255,60,0},decay={180,20,0},glare=3,haze=3.5},clouds={cover=0.8,dens=0.9,color={120,40,20}}},
["Arctic"] = {clock=9,brightness=3.2,ambient={200,220,235},outAmb={210,230,245},sky={sun=10,stars=0,moon=0},atm={dens=0.3,color={180,220,255},decay={140,200,240},glare=1.5,haze=1.8},clouds={cover=0.7,dens=0.6,color={250,253,255}}},
["Midnight Ocean"] = {clock=1.5,brightness=1.7,ambient={60,90,130},outAmb={70,100,140},sky={stars=6000,moon=24,sun=0,moonTex=true},atm={dens=0.5,color={20,60,140},decay={10,30,90},glare=0.6,haze=1.5}},
["Vaporwave"] = {clock=19.5,brightness=2.4,ambient={180,120,200},outAmb={190,130,210},sky={stars=1000,moon=14},atm={dens=0.45,color={255,100,220},decay={120,60,255},glare=2.2,haze=2.4},clouds={cover=0.5,dens=0.55,color={200,150,255}}},
["Toxic"] = {clock=13,brightness=2.5,ambient={140,180,80},outAmb={150,190,90},atm={dens=0.55,color={100,220,40},decay={60,150,20},glare=1.8,haze=2.6},clouds={cover=0.65,dens=0.7,color={180,255,120}}},
["Solar Eclipse"] = {clock=12,brightness=0.9,ambient={50,40,60},outAmb={60,50,70},sky={stars=3500,sun=22,moon=0},atm={dens=0.5,color={255,140,40},decay={30,20,40},glare=2.8,haze=1.8}},
["Hellscape"] = {clock=18,brightness=1.8,ambient={200,60,30},outAmb={220,70,40},sky={stars=100,sun=30,moon=0},atm={dens=0.85,color={255,30,0},decay={120,0,0},glare=3.5,haze=4},clouds={cover=0.95,dens=0.95,color={80,20,10}}},
["Heaven"] = {clock=12,brightness=4,ambient={240,235,210},outAmb={250,245,220},sky={sun=16,moon=0,stars=0},atm={dens=0.25,color={255,250,220},decay={255,240,200},glare=3,haze=1.5},clouds={cover=0.85,dens=0.5,color={255,255,255}}},
["Storm"] = {clock=15,brightness=1.4,ambient={90,90,110},outAmb={100,100,120},sky={stars=0,sun=6,moon=0},atm={dens=0.65,color={80,90,120},decay={40,50,80},glare=0.5,haze=3},clouds={cover=0.95,dens=0.95,color={60,65,80}}},
["Sunrise"] = {clock=6.2,brightness=2.8,ambient={220,180,130},outAmb={230,190,140},sky={sun=22,stars=0,moon=0},atm={dens=0.45,color={255,180,100},decay={255,140,80},glare=2.4,haze=2.2},clouds={cover=0.4,dens=0.4,color={255,220,180}}},
["Deep Space"] = {clock=0,brightness=1,ambient={30,25,50},outAmb={40,35,60},sky={stars=15000,moon=0,sun=0},atm={dens=0.08,color={15,5,40},decay={5,0,20},glare=0.2,haze=0.3}},
["Lavender Dream"] = {clock=18.5,brightness=2.6,ambient={180,160,220},outAmb={190,170,230},sky={stars=800,moon=16,sun=0},atm={dens=0.4,color={200,160,255},decay={160,120,220},glare=1.4,haze=1.8},clouds={cover=0.55,dens=0.5,color={220,200,255}}},
["Inferno"] = {clock=17.5,brightness=2.2,ambient={220,100,40},outAmb={235,110,50},sky={sun=26,moon=0,stars=0},atm={dens=0.6,color={255,90,20},decay={200,40,0},glare=3,haze=3.2},clouds={cover=0.7,dens=0.7,color={200,80,40}}},
["Mint Sky"] = {clock=10,brightness=3.2,ambient={180,230,210},outAmb={190,240,220},sky={sun=10},atm={dens=0.32,color={150,255,210},decay={100,220,180},glare=1.6,haze=1.6},clouds={cover=0.55,dens=0.45,color={240,255,250}}},
}
function _vC3(t) return Color3.fromRGB(t[1], t[2], t[3]) end
function _v4mpClearSky()
for _, v in ipairs(Lighting:GetChildren()) do
if v:GetAttribute("_AceDuelsSky") then pcall(function() v:Destroy() end) end
end
local terrain = workspace:FindFirstChildOfClass("Terrain")
if terrain then
for _, v in ipairs(terrain:GetChildren()) do
if v:GetAttribute("_AceDuelsSky") then pcall(function() v:Destroy() end) end
end
end
end
function applyCustomSky(mode)
_v4mpClearSky()
local preset = SKY_PRESETS[mode]
if not preset or preset.kind == "off" then
Lighting.FogEnd = 100000; Lighting.FogStart = 0
Lighting.FogColor = Color3.fromRGB(192,192,192)
Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = true
V.skyTheme = "Off"
return
end
Lighting.FogEnd = 100000; Lighting.FogStart = 0
Lighting.FogColor = Color3.fromRGB(200,200,200)
Lighting.GlobalShadows = true
Lighting.ClockTime = preset.clock or 14
Lighting.Brightness = preset.brightness or 2
if preset.outAmb then Lighting.OutdoorAmbient = _vC3(preset.outAmb) end
if preset.ambient then Lighting.Ambient = _vC3(preset.ambient) end
if preset.sky then
local sky = Instance.new("Sky")
sky:SetAttribute("_AceDuelsSky", true)
if preset.sky.stars then sky.StarCount = preset.sky.stars end
if preset.sky.moon then sky.MoonAngularSize = preset.sky.moon end
if preset.sky.sun then sky.SunAngularSize = preset.sky.sun end
if preset.sky.moonTex then sky.MoonTextureId = "rbxasset://sky/moon.jpg" end
sky.Parent = Lighting
end
if preset.atm then
local atm = Instance.new("Atmosphere")
atm:SetAttribute("_AceDuelsSky", true)
atm.Density = preset.atm.dens or 0.3
atm.Color = _vC3(preset.atm.color)
atm.Decay = _vC3(preset.atm.decay)
atm.Glare = preset.atm.glare or 1
atm.Haze = preset.atm.haze or 1
atm.Parent = Lighting
end
local terrain = workspace:FindFirstChildOfClass("Terrain")
if preset.clouds and terrain then
local clouds = Instance.new("Clouds")
clouds:SetAttribute("_AceDuelsSky", true)
clouds.Cover = preset.clouds.cover or 0.5
clouds.Density = preset.clouds.dens or 0.5
clouds.Color = _vC3(preset.clouds.color)
clouds.Parent = terrain
end
V.skyTheme = mode
end
function enableUltraMode()
V.ultraModeEnabled = true
applyKTMOptimization()
end
function disableUltraMode()
V.ultraModeEnabled = false
end
function enableRemoveAccessories()
V.removeAccessoriesEnabledSep = true
removeAccessoriesEnabled = true
removeAllAccessories()
if V.removeAccConn then V.removeAccConn:Disconnect() end
V.removeAccConn = Players.PlayerAdded:Connect(function(player)
player.CharacterAdded:Connect(function(char)
task.wait(0.5)
if V.removeAccessoriesEnabledSep or removeAccessoriesEnabled then
for _,obj in ipairs(char:GetDescendants()) do processAntiLagDescendant(obj) end
end
end)
end)
if antiLagDescConn then antiLagDescConn:Disconnect() end
antiLagDescConn = Workspace.DescendantAdded:Connect(function(obj)
if antiLagEnabled or V.ultraModeEnabled or removeAccessoriesEnabled or V.removeAccessoriesEnabledSep then
processAntiLagDescendant(obj)
end
end)
end
function disableRemoveAccessories()
V.removeAccessoriesEnabledSep = false
removeAccessoriesEnabled = false
if V.removeAccConn then V.removeAccConn:Disconnect(); V.removeAccConn = nil end
if not antiLagEnabled and not V.ultraModeEnabled and antiLagDescConn then antiLagDescConn:Disconnect(); antiLagDescConn = nil end
end
_nukeOptimizerOn = false
_nukeOptimizerConns = {}
_nukeOptimizerThreads = {}
function enableNukeOptimizer()
if _nukeOptimizerOn then return end
_nukeOptimizerOn = true
nukeOptimiserEnabled = true
V.nukeOptEnabled = true
local MaterialService = game:GetService("MaterialService")
local XMin, XMax = -560, -240
local ClothingClasses = {"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
local BASE_NAMES = {"baseplate","spawnlocation","spawn location","spawn"}
function SafeDestroy(obj)
if obj and obj.Name == "Overhead" then return end
pcall(function() obj:Destroy() end)
end
function IsClothing(obj)
for _, className in ipairs(ClothingClasses) do
if obj:IsA(className) then return true end
end
return false
end
function IsCharacterPart(obj)
for _, plr in ipairs(Players:GetPlayers()) do
if plr.Character and obj:IsDescendantOf(plr.Character) then return true end
end
return false
end
function IsOutOfRange(obj)
if obj:IsA("BasePart") then
local x = obj.Position.X
return x < XMin or x > XMax
end
return false
end
function IsBase(obj)
if not obj:IsA("BasePart") then return false end
local nl = obj.Name:lower()
for _, n in ipairs(BASE_NAMES) do
if nl:find(n, 1, true) then return true end
end
return false
end
function IsInBase(obj)
local p = obj.Parent
while p and p ~= workspace do
if IsBase(p) then return true end
p = p.Parent
end
return false
end
function MakeTransparent(obj)
pcall(function()
if IsBase(obj) and not IsCharacterPart(obj) then
obj.Transparency = 1
obj.CastShadow = false
end
end)
end
function StripObject(obj)
pcall(function()
if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
SafeDestroy(obj)
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
pcall(function() obj.Enabled = false end)
SafeDestroy(obj)
elseif obj:IsA("SurfaceAppearance") then
SafeDestroy(obj)
elseif obj:IsA("BasePart") then
obj.CastShadow = false
obj.Material = Enum.Material.Plastic
obj.MaterialVariant = ""
obj.Reflectance = 0
end
end)
end
function CleanObject(obj)
pcall(function()
if obj:IsA("SurfaceAppearance") then
SafeDestroy(obj)
elseif obj:IsA("Decal") or obj:IsA("Texture") then
if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then SafeDestroy(obj) end
elseif obj:IsA("SpecialMesh") then
obj.TextureId = ""
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
SafeDestroy(obj)
elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
SafeDestroy(obj)
elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
SafeDestroy(obj)
elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
SafeDestroy(obj)
elseif obj:IsA("BasePart") then
obj.CastShadow = false
obj.Material = Enum.Material.Plastic
obj.MaterialVariant = ""
obj.Reflectance = 0
end
end)
end
function ApplyGreySky()
pcall(function()
for _, obj in ipairs(Lighting:GetChildren()) do
if obj:IsA("Sky") then obj:Destroy() end
end
local sky = Instance.new("Sky")
sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
sky.CelestialBodiesShown = false
sky.Name = "_AceDuelsNukeSky"
sky.Parent = Lighting
end)
end
function OptimizeLighting()
pcall(function()
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.FogStart = 9e9
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.Brightness = 1.5
Lighting.Ambient = Color3.fromRGB(60,60,60)
for _, v in ipairs(Lighting:GetChildren()) do
if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
v:Destroy()
end
end
ApplyGreySky()
end)
end
function ApplyTerrain()
pcall(function()
local terrain = workspace:FindFirstChildOfClass("Terrain")
if terrain then
terrain.Decoration = false
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 1
end
end)
end
function OptimizeCharacter(char)
if not char then return end
task.spawn(function()
task.wait(0.3)
if not _nukeOptimizerOn then return end
for _, obj in ipairs(char:GetDescendants()) do
if IsClothing(obj) then SafeDestroy(obj) else CleanObject(obj) end
end
end)
end
pcall(function()
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
end)
pcall(function() if setfpscap then setfpscap(999) end end)
table.insert(_nukeOptimizerThreads, task.spawn(function()
if not game:IsLoaded() then game.Loaded:Wait() end
OptimizeLighting()
ApplyTerrain()
for _, obj in ipairs(workspace:GetDescendants()) do
if not _nukeOptimizerOn then return end
if IsBase(obj) then
MakeTransparent(obj)
elseif IsClothing(obj) then
SafeDestroy(obj)
elseif IsInBase(obj) then
elseif IsCharacterPart(obj) then
elseif IsOutOfRange(obj) then
SafeDestroy(obj)
else
CleanObject(obj)
StripObject(obj)
end
end
for _, obj in ipairs(workspace:GetDescendants()) do MakeTransparent(obj) end
end))
table.insert(_nukeOptimizerConns, workspace.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
task.defer(function()
if not _nukeOptimizerOn then return end
if IsBase(obj) then MakeTransparent(obj); return end
if IsClothing(obj) then
SafeDestroy(obj)
elseif IsInBase(obj) then
elseif IsCharacterPart(obj) then
elseif IsOutOfRange(obj) then
SafeDestroy(obj)
else
CleanObject(obj)
StripObject(obj)
end
end)
end))
table.insert(_nukeOptimizerConns, Lighting.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then SafeDestroy(obj) end
end))
table.insert(_nukeOptimizerConns, MaterialService.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
SafeDestroy(obj)
end))
for _, plr in ipairs(Players:GetPlayers()) do
OptimizeCharacter(plr.Character)
table.insert(_nukeOptimizerConns, plr.CharacterAdded:Connect(OptimizeCharacter))
end
table.insert(_nukeOptimizerConns, Players.PlayerAdded:Connect(function(plr)
table.insert(_nukeOptimizerConns, plr.CharacterAdded:Connect(OptimizeCharacter))
end))
table.insert(_nukeOptimizerThreads, task.spawn(function()
while _nukeOptimizerOn do
task.wait(15)
pcall(function() collectgarbage("collect") end)
end
end))
end
function disableNukeOptimizer()
_nukeOptimizerOn = false
nukeOptimiserEnabled = false
V.nukeOptEnabled = false
for _, c in ipairs(_nukeOptimizerConns) do pcall(function() c:Disconnect() end) end
_nukeOptimizerConns = {}
_nukeOptimizerThreads = {}
end
function enableCustomFont() customFontVisualEnabled=false; if V then V.customFontEnabled=false end end
function disableCustomFont() customFontVisualEnabled=false; if V then V.customFontEnabled=false end end
__ace_src_enableNoCamCollision = enableNoCamCollision
function enableNoCamCollision()
__ace_src_enableNoCamCollision()
noCamCollisionEnabled = true
end
__ace_src_disableNoCamCollision = disableNoCamCollision
function disableNoCamCollision()
__ace_src_disableNoCamCollision()
noCamCollisionEnabled = false
end
function __AceDuelsSetupVisualsUI()
local Utility = pages.VISUALS
local skyThemes = SKY_PRESETS_LIST or {"Off", "Night", "Aurora", "Sunset", "Galaxy", "Tech", "Sakura"}
local skyIndex = 1
for i, name in ipairs(skyThemes) do if name == skyTheme then skyIndex = i break end end
function skyThemeSelectorRow(parent, order)
local row = baseRow(parent, "Sky Theme", order)
row.Size = UDim2.new(1, -4, 0, 42)
row.ClipsDescendants = true
local label = row:FindFirstChild("Label")
if label then
label.Size = UDim2.new(0, 92, 1, 0)
label.TextSize = 11
end
local left = Instance.new("TextButton")
left.Name = "SkyLeft"
left.BackgroundColor3 = Color3.fromRGB(7, 7, 10)
left.BackgroundTransparency = 0.04
left.Text = "<"
left.TextColor3 = COLORS.white
left.TextSize = 12
left.Font = Enum.Font.GothamSemibold
left.Size = UDim2.new(0, 42, 0, 28)
left.Position = UDim2.new(1, -186, 0.5, -14)
left.BorderSizePixel = 0
left.ZIndex = 8
left.AutoButtonColor = false
left.Parent = row
corner(left, 8)
stroke(left, COLORS.strokeSoft, 1, 0.42)
local holder = Instance.new("Frame")
holder.Name = "SkyValueHolder"
holder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
holder.BackgroundTransparency = 0.28
holder.BorderSizePixel = 0
holder.Size = UDim2.new(0, 92, 0, 28)
holder.Position = UDim2.new(1, -139, 0.5, -14)
holder.ClipsDescendants = true
holder.ZIndex = 7
holder.Parent = row
corner(holder, 8)
stroke(holder, Color3.fromRGB(235, 235, 245), 1, 0.35)
local smoky = Instance.new("ImageLabel")
smoky.Name = "SmokyBackground"
smoky.BackgroundTransparency = 1
smoky.Image = "rbxassetid://99416158073201"
smoky.ImageTransparency = 1
smoky.ScaleType = Enum.ScaleType.Crop
smoky.Size = UDim2.new(1, 0, 1, 0)
smoky.Position = UDim2.new(0, 0, 0, 0)
smoky.Visible = false
smoky.ZIndex = 7
smoky.Parent = holder
corner(smoky, 8)
skyValueLabel = Instance.new("TextLabel")
skyValueLabel.Name = "SkyValue"
skyValueLabel.BackgroundTransparency = 1
skyValueLabel.Text = skyThemes[skyIndex]
skyValueLabel.TextColor3 = COLORS.white
skyValueLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
skyValueLabel.TextStrokeTransparency = 0.22
skyValueLabel.TextSize = 11
skyValueLabel.Font = Enum.Font.GothamSemibold
skyValueLabel.TextXAlignment = Enum.TextXAlignment.Center
skyValueLabel.Size = UDim2.new(1, 0, 1, 0)
skyValueLabel.ZIndex = 9
skyValueLabel.Parent = holder
local right = Instance.new("TextButton")
right.Name = "SkyRight"
right.BackgroundColor3 = Color3.fromRGB(7, 7, 10)
right.BackgroundTransparency = 0.04
right.Text = ">"
right.TextColor3 = COLORS.white
right.TextSize = 12
right.Font = Enum.Font.GothamSemibold
right.Size = UDim2.new(0, 42, 0, 28)
right.Position = UDim2.new(1, -42, 0.5, -14)
right.BorderSizePixel = 0
right.ZIndex = 8
right.AutoButtonColor = false
right.Parent = row
corner(right, 8)
stroke(right, COLORS.strokeSoft, 1, 0.42)
local function setSkyIndex(nextIndex)
if nextIndex < 1 then nextIndex = #skyThemes end
if nextIndex > #skyThemes then nextIndex = 1 end
skyIndex = nextIndex
skyTheme = skyThemes[skyIndex]
if applyCustomSky then applyCustomSky(skyTheme) end
if skyValueLabel then skyValueLabel.Text = skyTheme end
saveAceConfig()
end
left.Activated:Connect(function()
setSkyIndex(skyIndex - 1)
end)
right.Activated:Connect(function()
setSkyIndex(skyIndex + 1)
end)
return row
end
section(Utility, "ESP", 1)
do
local espRow, setESPVisual = toggleRow(Utility, "ESP", espEnabled, 2)
setPlayerESPVisual = setESPVisual
_aceBtn = espRow and espRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
espEnabled = not espEnabled
if espEnabled then
if startPlayerESP then startPlayerESP() end
if BoxedESPOptions then BoxedESPOptions.box = true end
else
if stopPlayerESP then stopPlayerESP() end
if BoxedESPOptions then BoxedESPOptions.box = false end
end
if refreshBoxedESP then refreshBoxedESP() end
if setESPVisual then setESPVisual(espEnabled) end
saveAceConfig()
end)
end
end
do
local tracerRow, setTracerVisual = toggleRow(Utility, "Show Tracker", showTracerEnabled, 3)
setTracerESPVisual = setTracerVisual
_aceBtn = tracerRow and tracerRow:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
showTracerEnabled = not showTracerEnabled
if BoxedESPOptions then
BoxedESPOptions.tracer = showTracerEnabled
BoxedESPOptions.box = espEnabled == true
end
if refreshBoxedESP then refreshBoxedESP() end
if setTracerVisual then setTracerVisual(showTracerEnabled) end
saveAceConfig()
end)
end
end
do
local row, setVisual = _G.AceActionToggleRow(Utility, "Ragdoll Countdown", ragdollCountdownEnabled, 4)
setRagdollCountdownVisual = setVisual
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
ragdollCountdownEnabled = not ragdollCountdownEnabled
if ragdollCountdownEnabled then hookRagdollCountdown(LP.Character) else stopRagdollCountdown() end
if setVisual then setVisual(ragdollCountdownEnabled) end
saveAceConfig()
end)
end
end
section(Utility, "SKY THEME", 5)
skyThemeSelectorRow(Utility, 6)
section(Utility, "PERFORMANCE", 7)
do
local row, setVisual = toggleRow(Utility, "Stretch Rez", fpsBoostEnabled, 8)
setFPSBoostVisual = setVisual
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
fpsBoostEnabled = not fpsBoostEnabled
if fpsBoostEnabled then enableStretchRez() else disableStretchRez() end
if setVisual then setVisual(fpsBoostEnabled) end
saveAceConfig()
end)
end
end
do
local row, setVisual = toggleRow(Utility, "Anti Lag", antiLagVisualEnabled, 9)
setAntiLagVisual = setVisual
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
if antiLagVisualEnabled then disableAntiLag() else enableAntiLag() end
if setVisual then setVisual(antiLagVisualEnabled) end
saveAceConfig()
end)
end
end
do
local row, setVisual = _G.AceActionToggleRow(Utility, "Nuke Optimiser", nukeOptimiserEnabled, 10)
setNukeOptimiserVisual = setVisual
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
if nukeOptimiserEnabled then disableNukeOptimizer() else enableNukeOptimizer() end
if setVisual then setVisual(nukeOptimiserEnabled) end
saveAceConfig()
end)
end
end
section(Utility, "CAMERA", 11)
do
local row, setVisual = toggleRow(Utility, "FOV", fovEnabled, 12)
setFOVVisual = setVisual
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
if fovEnabled then disableCustomFov() else enableCustomFov() end
if setVisual then setVisual(fovEnabled) end
saveAceConfig()
end)
end
end
do
local _, box = textboxRow(Utility, "FOV Value", tostring(fovValue), 13)
box.FocusLost:Connect(function()
local v = tonumber(box.Text)
if v and v >= 30 and v <= 120 then
fovValue = v
if fovEnabled and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = fovValue end
end
box.Text = tostring(fovValue)
saveAceConfig()
end)
end
do
local row, setVisual = toggleRow(Utility, "No Cam Collision", noCamCollisionEnabled, 14)
setNoCamCollisionVisual = setVisual
_aceBtn = row and row:FindFirstChild("ToggleButton")
if _aceBtn then
_aceBtn.Activated:Connect(function()
if noCamCollisionEnabled then disableNoCamCollision() else enableNoCamCollision() end
if setVisual then setVisual(noCamCollisionEnabled) end
saveAceConfig()
end)
end
end
end
task.wait()
__AceDuelsSetupVisualsUI()
Settings = pages.SETTINGS
aceGuiScaleValue = tonumber(savedConfig.aceGuiScaleValue) or aceGuiScaleValue
aceGuiScaleValue = math.clamp(tonumber(aceGuiScaleValue) or 0.52, 0.50, 1.50)
aceProgressBarScaleValue = tonumber(savedConfig.aceProgressBarScaleValue) or aceProgressBarScaleValue
aceMainScale = Main:FindFirstChild("AceMainScale") or Instance.new("UIScale")
aceMainScale.Name = "AceMainScale"
aceMainScale.Scale = aceGuiScaleValue
aceMainScale.Parent = Main
local function applyAceProgressBarScale()
local sg = PlayerGui:FindFirstChild("StealBarGui")
local bar = sg and sg:FindFirstChild("StealBar")
if not bar then return end
local sc = bar:FindFirstChild("AceProgressBarScale") or Instance.new("UIScale")
sc.Name = "AceProgressBarScale"
sc.Scale = aceProgressBarScaleValue
sc.Parent = bar
end
_G.__AceDuelsSetupSettingsUI = function()
section(Settings, "GUI SETTINGS", 1)
do
local row, setVisual = _G.AceActionToggleRow(Settings, "Lock GUI", _G.AceGuiLocked == true, 7)
setLockGuiVisual = setVisual
local btn = row and row:FindFirstChild("ToggleButton")
if btn then
btn.Activated:Connect(function()
_G.AceGuiLocked = not (_G.AceGuiLocked == true)
if setVisual then setVisual(_G.AceGuiLocked == true) end
if AceUpdateGuiLockVisual then AceUpdateGuiLockVisual() end
saveAceConfig()
end)
end
end
do
local row, setVisual = _G.AceActionToggleRow(Settings, "Hide Mobile Buttons", _G.AceHideMobileButtons == true, 8)
setHideMobileButtonsVisual = setVisual
local btn = row and row:FindFirstChild("ToggleButton")
if btn then
btn.Activated:Connect(function()
_G.AceHideMobileButtons = not (_G.AceHideMobileButtons == true)
if setVisual then setVisual(_G.AceHideMobileButtons == true) end
if _G.AceApplyMobileButtonsHidden then _G.AceApplyMobileButtonsHidden() end
saveAceConfig()
end)
end
end
local bgRow = Instance.new("Frame")
bgRow.Name = "Background Image Picker"
bgRow.BackgroundColor3 = COLORS.row
bgRow.BackgroundTransparency = 0.3
bgRow.Size = UDim2.new(1, -4, 0, 58)
bgRow.BorderSizePixel = 0
bgRow.LayoutOrder = 2
bgRow.ZIndex = 4
bgRow.Parent = Settings
corner(bgRow, 9)
stroke(bgRow, COLORS.strokeSoft, 1.15, 0.38)
local bgButtons = {}
function updateBackgroundButtons()
for index, button in pairs(bgButtons) do
local selected = index == currentBackground
button.BackgroundTransparency = selected and 0.12 or 0.42
local st = button:FindFirstChildOfClass("UIStroke")
if st then
st.Color = selected and Color3.fromRGB(245, 245, 255) or COLORS.strokeSoft
st.Transparency = selected and 0.12 or 0.55
st.Thickness = selected and 1.15 or 1
end
end
end
function makeNoneButton(index, x)
local btn = Instance.new("TextButton")
btn.Name = "None"
btn.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
btn.BackgroundTransparency = 0.12
btn.BorderSizePixel = 0
btn.Text = "None"
btn.TextColor3 = COLORS.white
btn.TextSize = 8
btn.Font = Enum.Font.GothamSemibold
btn.AutoButtonColor = false
btn.Size = UDim2.new(0, 52, 0, 40)
btn.Position = UDim2.new(0, x, 0.5, -20)
btn.ZIndex = 6
btn.ClipsDescendants = true
btn.Parent = bgRow
corner(btn, 8)
stroke(btn, Color3.fromRGB(245, 245, 255), 1.15, 0.12)
bgButtons[index] = btn
btn.MouseButton1Click:Connect(function()
applyBackground(index)
updateBackgroundButtons()
end)
end
function makeImageButton(index, x)
local holder = Instance.new("Frame")
holder.Name = "Image " .. tostring(index)
holder.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
holder.BackgroundTransparency = 0.35
holder.BorderSizePixel = 0
holder.Size = UDim2.new(0, 58, 0, 40)
holder.Position = UDim2.new(0, x, 0.5, -20)
holder.ZIndex = 6
holder.ClipsDescendants = true
holder.Parent = bgRow
corner(holder, 8)
stroke(holder, COLORS.strokeSoft, 1, 0.45)
local img = Instance.new("ImageLabel")
img.Name = "Preview"
img.BackgroundTransparency = 1
img.Image = "rbxassetid://" .. BackgroundIDs[index]
img.ScaleType = Enum.ScaleType.Crop
img.Size = UDim2.new(1, 0, 1, 0)
img.Position = UDim2.new(0, 0, 0, 0)
img.ZIndex = 6
img.Parent = holder
corner(img, 8)
local click = Instance.new("TextButton")
click.Name = "Click"
click.BackgroundTransparency = 1
click.Text = ""
click.AutoButtonColor = false
click.Size = UDim2.new(1, 0, 1, 0)
click.Position = UDim2.new(0, 0, 0, 0)
click.ZIndex = 7
click.Parent = holder
bgButtons[index] = holder
click.MouseButton1Click:Connect(function()
applyBackground(index)
updateBackgroundButtons()
end)
end
function stepperRow(parent, labelText, defaultValue, order, callback, minValue, maxValue)
local row = Instance.new("Frame")
row.Name = labelText
row.BackgroundColor3 = COLORS.row
row.BackgroundTransparency = 0.22
row.Size = UDim2.new(1, -4, 0, 42)
row.BorderSizePixel = 0
row.LayoutOrder = order
row.ZIndex = 4
row.Parent = parent
corner(row, 10)
stroke(row, COLORS.strokeSoft, 1.15, 0.32)
local label = Instance.new("TextLabel")
label.Name = "Label"
label.BackgroundTransparency = 1
label.Text = labelText
label.TextColor3 = Color3.fromRGB(245, 245, 255)
label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
label.TextStrokeTransparency = 0.25
label.TextSize = 11
label.Font = Enum.Font.GothamMedium
label.TextXAlignment = Enum.TextXAlignment.Left
label.Position = UDim2.new(0, 12, 0, 0)
label.Size = UDim2.new(1, -155, 1, 0)
label.ZIndex = 5
label.Parent = row
local value = defaultValue
local minus = Instance.new("TextButton")
minus.Name = "Minus"
minus.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
minus.BackgroundTransparency = 0.1
minus.BorderSizePixel = 0
minus.Text = "-"
minus.TextColor3 = Color3.fromRGB(245, 245, 255)
minus.TextSize = 14
minus.Font = Enum.Font.GothamBlack
minus.AutoButtonColor = false
minus.Size = UDim2.new(0, 28, 0, 26)
minus.Position = UDim2.new(1, -118, 0.5, -13)
minus.ZIndex = 6
minus.Parent = row
corner(minus, 7)
stroke(minus, COLORS.strokeSoft, 1, 0.5)
local valueBox = Instance.new("TextLabel")
valueBox.Name = "Value"
valueBox.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
valueBox.BackgroundTransparency = 0.05
valueBox.BorderSizePixel = 0
valueBox.Text = string.format("%.2f", value)
valueBox.TextColor3 = Color3.fromRGB(245, 245, 255)
valueBox.TextSize = 13
valueBox.Font = Enum.Font.GothamBlack
valueBox.TextXAlignment = Enum.TextXAlignment.Center
valueBox.Size = UDim2.new(0, 48, 0, 26)
valueBox.Position = UDim2.new(1, -84, 0.5, -13)
valueBox.ZIndex = 6
valueBox.Parent = row
corner(valueBox, 7)
stroke(valueBox, COLORS.strokeSoft, 1, 0.5)
local plus = Instance.new("TextButton")
plus.Name = "Plus"
plus.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
plus.BackgroundTransparency = 0.1
plus.BorderSizePixel = 0
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(245, 245, 255)
plus.TextSize = 14
plus.Font = Enum.Font.GothamBlack
plus.AutoButtonColor = false
plus.Size = UDim2.new(0, 28, 0, 26)
plus.Position = UDim2.new(1, -30, 0.5, -13)
plus.ZIndex = 6
plus.Parent = row
corner(plus, 7)
stroke(plus, COLORS.strokeSoft, 1, 0.5)
local function setValue(nextValue)
value = math.clamp(math.floor((nextValue * 100) + 0.5) / 100, minValue or 0.50, maxValue or 1.50)
valueBox.Text = string.format("%.2f", value)
if callback then callback(value) end
end
minus.MouseButton1Click:Connect(function()
setValue(value - 0.05)
end)
plus.MouseButton1Click:Connect(function()
setValue(value + 0.05)
end)
return row
end
makeNoneButton(0, 8)
makeImageButton(1, 66)
makeImageButton(2, 128)
makeImageButton(3, 190)
makeImageButton(4, 252)
updateBackgroundButtons()
stepperRow(Settings, "GUI Scale", aceGuiScaleValue, 3, function(v)
aceGuiScaleValue = v
aceMainScale.Scale = v
saveAceConfig()
end)
stepperRow(Settings, "Progress Bar Size", aceProgressBarScaleValue, 4, function(v)
aceProgressBarScaleValue = v
applyAceProgressBarScale()
saveAceConfig()
end)
speedKeybindRow(Settings, "Toggle UI", "ToggleUI", 5)
section(Settings, "MOBILE BUTTONS", 6)
stepperRow(Settings, "Mobile Buttons Size", tonumber(_G.AceMobileButtonScale) or 0.75, 9, function(v)
_G.AceMobileButtonScale = math.clamp(tonumber(v) or 0.35, 0.30, 1.35)
if _G.AceApplyMobileButtonSize then _G.AceApplyMobileButtonSize() end
saveAceConfig()
end, 0.30, 1.35)
do
local row = baseRow(Settings, "Reset Mobile Buttons", 10)
local button = Instance.new("TextButton")
button.Name = "ResetMobileButtons"
button.BackgroundColor3 = Color3.fromRGB(232, 232, 238)
button.BackgroundTransparency = 0
button.BorderSizePixel = 0
button.Text = "RESET"
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.TextSize = 11
button.Font = Enum.Font.GothamBlack
button.AutoButtonColor = false
button.Size = UDim2.new(0, 78, 0, 26)
button.Position = UDim2.new(1, -88, 0.5, -13)
button.ZIndex = 7
button.Parent = row
corner(button, 8)
stroke(button, Color3.fromRGB(255, 255, 255), 1, 0.18)
button.Activated:Connect(function()
if _G.AceResetMobileButtons then
_G.AceResetMobileButtons()
else
_G.AceMobileButtonScale = 0.75
_G.AceHideMobileButtons = false
if _G.AceApplyMobileButtonsHidden then _G.AceApplyMobileButtonsHidden() end
if _G.AceApplyMobileButtonSize then _G.AceApplyMobileButtonSize() end
saveAceConfig()
end
end)
end

section(Settings, "INTRO", 50)
do
local row, setVisual = toggleRow(Settings, "Intro", _introEnabled, 51)
setIntroVisual = setVisual
local btn = row and row:FindFirstChild("ToggleButton")
if btn then
btn.Activated:Connect(function()
_introEnabled = not _introEnabled
if not _introEnabled then stopIntroPlayback(); stopIntroPreview() end
if setIntroVisual then setIntroVisual(_introEnabled) end
saveAceConfig()
end)
end
if setIntroVisual then setIntroVisual(_introEnabled) end
end
do
local row = Instance.new("Frame")
row.Name = "Intro Song"
row.BackgroundColor3 = COLORS.row
row.BackgroundTransparency = 0.22
row.Size = UDim2.new(1, -4, 0, 42)
row.BorderSizePixel = 0
row.LayoutOrder = 52
row.ZIndex = 4
row.Parent = Settings
corner(row, 10)
stroke(row, COLORS.strokeSoft, 1.15, 0.32)
local label = Instance.new("TextLabel")
label.Name = "Label"
label.BackgroundTransparency = 1
label.Text = "Intro Song"
label.TextColor3 = Color3.fromRGB(245,245,255)
label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
label.TextStrokeTransparency = 0.25
label.TextSize = 11
label.Font = Enum.Font.GothamMedium
label.TextXAlignment = Enum.TextXAlignment.Left
label.Position = UDim2.new(0, 12, 0, 0)
label.Size = UDim2.new(1, -145, 1, 0)
label.ZIndex = 5
label.Parent = row
local btn = Instance.new("TextButton")
btn.Name = "Intro Song Button"
btn.BackgroundColor3 = Color3.fromRGB(232,232,238)
btn.BackgroundTransparency = 0
btn.BorderSizePixel = 0
btn.Text = getIntroSongName()
btn.TextColor3 = Color3.fromRGB(0,0,0)
btn.TextSize = 12
btn.Font = Enum.Font.GothamBlack
btn.AutoButtonColor = false
btn.Size = UDim2.new(0, 118, 0, 28)
btn.Position = UDim2.new(1, -128, 0.5, -14)
btn.ZIndex = 6
btn.Parent = row
corner(btn, 8)
stroke(btn, Color3.fromRGB(255,255,255), 1, 0.15)
setIntroSongVisual = function()
if btn and btn.Parent then btn.Text = getIntroSongName(); btn.TextColor3 = Color3.fromRGB(0,0,0) end
end
btn.MouseButton1Click:Connect(function()
selectedIntroMusic = selectedIntroMusic + 1
if selectedIntroMusic > #INTRO_MUSIC_OPTIONS then selectedIntroMusic = 1 end
if setIntroSongVisual then setIntroSongVisual() end
previewIntroMusic(selectedIntroMusic)
saveAceConfig()
end)
end

section(Settings, "SETTINGS", 999)
local resetHolder = Instance.new("Frame")
resetHolder.Name = "Reset All Settings Holder"
resetHolder.BackgroundTransparency = 1
resetHolder.BorderSizePixel = 0
resetHolder.Size = UDim2.new(1, -4, 0, 44)
resetHolder.LayoutOrder = 1000
resetHolder.ZIndex = 5
resetHolder.Parent = Settings
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "Reset All Settings"
resetBtn.BackgroundColor3 = Color3.fromRGB(232, 232, 238)
resetBtn.BackgroundTransparency = 0
resetBtn.BorderSizePixel = 0
resetBtn.Text = "Reset All Settings"
resetBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
resetBtn.TextStrokeTransparency = 1
resetBtn.TextSize = 12
resetBtn.Font = Enum.Font.GothamBlack
resetBtn.AutoButtonColor = false
resetBtn.Size = UDim2.new(1, -16, 0, 42)
resetBtn.Position = UDim2.new(0, 8, 0, 1)
resetBtn.ZIndex = 6
resetBtn.Parent = resetHolder
corner(resetBtn, 10)
local resetStroke = Instance.new("UIStroke")
resetStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
resetStroke.Color = Color3.fromRGB(255, 255, 255)
resetStroke.Thickness = 1
resetStroke.Transparency = 0.12
resetStroke.Parent = resetBtn
local resetDefaultBg = Color3.fromRGB(232, 232, 238)
local resetHoverBg = Color3.fromRGB(245, 245, 250)
local resetConfirmBg = Color3.fromRGB(35, 35, 38)
local resetDoneBg = Color3.fromRGB(28, 40, 30)
local resetDefaultText = Color3.fromRGB(0, 0, 0)
local resetConfirmText = Color3.fromRGB(255, 210, 80)
local resetDoneText = Color3.fromRGB(140, 230, 160)
local confirmState = false
local confirmTimer = nil
function setResetDefaultTheme()
confirmState = false
resetBtn.Text = "RESET ALL SETTINGS"
resetBtn.TextColor3 = resetDefaultText
tween(resetBtn, {BackgroundColor3 = resetDefaultBg}, 0.18)
tween(resetStroke, {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.12, Thickness = 1}, 0.18)
end
function setResetConfirmTheme()
resetBtn.Text = "CLICK AGAIN TO CONFIRM"
resetBtn.TextColor3 = resetConfirmText
tween(resetBtn, {BackgroundColor3 = resetConfirmBg}, 0.18)
tween(resetStroke, {Color = resetConfirmText, Transparency = 0.02, Thickness = 1.4}, 0.18)
end
function setResetDoneTheme()
resetBtn.Text = "DONE - REJOINING..."
resetBtn.TextColor3 = resetDoneText
tween(resetBtn, {BackgroundColor3 = resetDoneBg}, 0.18)
tween(resetStroke, {Color = resetDoneText, Transparency = 0.02, Thickness = 1.4}, 0.18)
end
resetBtn.Text = "RESET ALL SETTINGS"
resetBtn.MouseEnter:Connect(function()
if not confirmState then
tween(resetBtn, {BackgroundColor3 = resetHoverBg}, 0.12)
end
end)
resetBtn.MouseLeave:Connect(function()
if not confirmState then
tween(resetBtn, {BackgroundColor3 = resetDefaultBg}, 0.12)
end
end)
resetBtn.MouseButton1Click:Connect(function()
if not confirmState then
confirmState = true
setResetConfirmTheme()
if confirmTimer then task.cancel(confirmTimer) end
confirmTimer = task.delay(3, function()
setResetDefaultTheme()
end)
return
end
if confirmTimer then
task.cancel(confirmTimer)
confirmTimer = nil
end
resetBtn.Text = "RESETTING..."
pcall(function()
local files = {
CONFIG_FILE,
KEYBINDS_CONFIG_FILE,
"AceDuels_MainGUI_Config.json",
"AceDuelsConfig.json",
"AceDuels_Settings.json",
"AceDuels_Keybinds.json",
"AceDuels_GUI.json",
}
for _, fname in ipairs(files) do
pcall(function()
if fname and isfile and isfile(fname) and delfile then
delfile(fname)
end
end)
end
end)
pcall(function()
aceGuiScaleValue = 0.52
aceProgressBarScaleValue = 0.83
NS = 59.5; CS = 28.8; LAGGER_SPEED = 29; LAGGER_CARRY_SPEED = 15
currentSpeedMode = "Normal"
autoCarrySpeedEnabled = false
autoTPHeight = 20
autoStealEnabled = false; selectedStealMode = "Normal"; autoStealRadius = 62
_G.AceStealRadii = {Normal = 62, Semi = 9}
selectedAnimationPack = "OFF"; selectedAimbotMode = "Normal"
AIMBOT_SPEED = 58; LAGGER_AIMBOT_SPEED = 40
_G.AceAntiBypassAimbotSpeed = 58; _G.AceAntiBypassLaggerAimbotSpeed = 40; ANTI_DESYNC_AIMBOT_SPEED = 58
autoSwingEnabled = false; mirrorTPDownEnabled = false; antiDesyncAutoSwingEnabled = false
_G.AceNormalAimbotOn = false; _G.AceAntiBypassAimbotOn = false; _G.AceAntiDesyncAimbotOn = false
antiRagdollEnabled = false; infJumpEnabled = false; autoTPEnabled = false
batCounterEnabled = false; medCounterEnabled = false; antiKickEnabled = false; autoResetOnMedEnabled = false
espEnabled = false; showTracerEnabled = false; ragdollCountdownEnabled = false
fpsBoostEnabled = false; antiLagVisualEnabled = false; nukeOptimiserEnabled = false
fovEnabled = false; fovValue = 70; noCamCollisionEnabled = false; _G.AceNoPlayerCollisionEnabled = false
skyTheme = "Off"; currentBackground = 0
selectedIntroMusic = 1; _introEnabled = true
if setIntroVisual then setIntroVisual(_introEnabled) end
if setIntroSongVisual then setIntroSongVisual() end
stopIntroPlayback(); stopIntroPreview()
autoLeftEnabled = false; autoRightEnabled = false
_G.AceGuiLocked = false; _G.AceHideMobileButtons = false; _G.AceMobileButtonScale = 0.75
aceMainScale.Scale = aceGuiScaleValue
applyAceProgressBarScale()
applyBackground(0)
updateBackgroundButtons()
applyDefaultAceKeybinds()
refreshAllSpeedKeybinds()
refreshTPDownKeybind()
if stopAutoTP then stopAutoTP() end
if stopAntiRagdoll then stopAntiRagdoll() end
if normalSpeedBox then normalSpeedBox.Text = tostring(NS) end
if carrySpeedBox then carrySpeedBox.Text = tostring(CS) end
if laggerSpeedBox then laggerSpeedBox.Text = tostring(LAGGER_SPEED) end
if laggerCarrySpeedBox then laggerCarrySpeedBox.Text = tostring(LAGGER_CARRY_SPEED) end
if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPHeight) end
if radiusBox then radiusBox.Text = tostring(autoStealRadius) end
if _G.AceRefreshAimbotSpeedBoxes then _G.AceRefreshAimbotSpeedBoxes() end
if type(applyCustomSky) == "function" then applyCustomSky("Off") end
if skyValueLabel then skyValueLabel.Text = "Off" end
if _G.AceResetMobileButtons then _G.AceResetMobileButtons() end
if _G.AceDuelsApplySavedGameplayStates then _G.AceDuelsApplySavedGameplayStates() end
saveAceConfig()
end)
task.wait(0.35)
setResetDoneTheme()
task.wait(0.6)
pcall(function()
local TeleportService = game:GetService("TeleportService")
TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
end)
end)
end
task.wait()
_G.__AceDuelsSetupSettingsUI()
if AceUpdateGuiLockVisual then AceUpdateGuiLockVisual() end
if _G.AceApplyMobileButtonsHidden then _G.AceApplyMobileButtonsHidden() end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
local isControllerInput = tostring(input.UserInputType):find("Gamepad") ~= nil
if gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and not listeningForSpeedKey and not listeningForTPDownKey then return end
if UserInputService:GetFocusedTextBox() then return end
if input.UserInputType ~= Enum.UserInputType.Keyboard and not isControllerInput then return end
if input.KeyCode == Enum.KeyCode.Unknown then return end
if speedKeybinds.ToggleUI and input.KeyCode == speedKeybinds.ToggleUI then
if Main.Visible then
Main.Visible = false
MiniFrame.Visible = true
else
Main.Visible = true
MiniFrame.Visible = false
Main.Size = FULL_MAIN_SIZE
end
saveAceConfig()
return
end
if listeningForSpeedKey then
if tick() - (keybindListenStartedAt or 0) < 0.18 then return end
local targetKey = listeningForSpeedKey
if input.KeyCode == Enum.KeyCode.Escape then
listeningForSpeedKey = nil
refreshAllSpeedKeybinds()
return
end
if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
speedKeybinds[targetKey] = nil
else
for otherKeyId, boundKey in pairs(speedKeybinds) do
if otherKeyId ~= targetKey and boundKey == input.KeyCode then
speedKeybinds[otherKeyId] = nil
end
end
if tpDownKeybind == input.KeyCode then
tpDownKeybind = nil
refreshTPDownKeybind()
end
speedKeybinds[targetKey] = input.KeyCode
end
listeningForSpeedKey = nil
refreshAllSpeedKeybinds()
saveAceConfig()
return
end
if listeningForTPDownKey then
if tick() - (keybindListenStartedAt or 0) < 0.18 then return end
if input.KeyCode == Enum.KeyCode.Escape then
listeningForTPDownKey = false
refreshTPDownKeybind()
return
end
if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
tpDownKeybind = nil
else
for keyId, boundKey in pairs(speedKeybinds) do
if boundKey == input.KeyCode then
speedKeybinds[keyId] = nil
end
end
tpDownKeybind = input.KeyCode
end
listeningForTPDownKey = false
refreshAllSpeedKeybinds()
refreshTPDownKeybind()
saveAceConfig()
return
end
if speedKeybinds.SpeedToggle and input.KeyCode == speedKeybinds.SpeedToggle then
toggleCarryMode()
return
end
if speedKeybinds.LaggerToggle and input.KeyCode == speedKeybinds.LaggerToggle then
toggleLaggerMode()
return
end
if speedKeybinds.Aimbot and input.KeyCode == speedKeybinds.Aimbot then
if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
return
end
if _G.AceToggleSelectedAimbot then
_G.AceToggleSelectedAimbot()
elseif selectedAimbotMode == "Anti Bypass" and _G.AceStartAntiBypassAimbot and _G.AceStopAntiBypassAimbot then
if _G.AceAntiBypassAimbotOn then _G.AceStopAntiBypassAimbot() else _G.AceStartAntiBypassAimbot() end
elseif _G.AceStartNormalAimbot and _G.AceStopNormalAimbot then
if _G.AceNormalAimbotOn then _G.AceStopNormalAimbot() else _G.AceStartNormalAimbot() end
end
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
return
end
if speedKeybinds.AntiDesyncAimbot and input.KeyCode == speedKeybinds.AntiDesyncAimbot then
if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
return
end
if _G.AceToggleAntiDesyncAimbot then
_G.AceToggleAntiDesyncAimbot()
elseif _G.AceStartAntiDesyncAimbot and _G.AceStopAntiDesyncAimbot then
if _G.AceAntiDesyncAimbotOn then _G.AceStopAntiDesyncAimbot() else _G.AceStartAntiDesyncAimbot() end
end
return
end
if speedKeybinds.DropBrainrot and input.KeyCode == speedKeybinds.DropBrainrot then
runDropBrainrot()
return
end
if speedKeybinds.AutoLeft and input.KeyCode == speedKeybinds.AutoLeft then
if _G.AceSetAutoLeft then _G.AceSetAutoLeft(not autoLeftEnabled) end
return
end
if speedKeybinds.AutoRight and input.KeyCode == speedKeybinds.AutoRight then
if _G.AceSetAutoRight then _G.AceSetAutoRight(not autoRightEnabled) end
return
end
if speedKeybinds.InstantReset and input.KeyCode == speedKeybinds.InstantReset then
if _G.AceCursedInstaReset then _G.AceCursedInstaReset() end
return
end
if tpDownKeybind and input.KeyCode == tpDownKeybind then
runTPFloor()
return
end
end)
setTab("MOVEMENT")
_G.__AceDuelsSetupStealBar = function()
local RunService   = game:GetService("RunService")
local UIS = UserInputService
local TS = TweenService
local Stats        = game:GetService("Stats")
local existingStealBar = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("StealBarGui")
if existingStealBar then existingStealBar:Destroy() end
local THEME_ACCENT        = Color3.fromRGB(235, 235, 245)
local THEME_ACCENT_BRIGHT = Color3.fromRGB(255, 255, 255)
local THEME_ACCENT_DIM    = Color3.fromRGB(120, 120, 130)
local gui = Instance.new("ScreenGui")
gui.Name = "StealBarGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui
function drag(frame)
local dragging, dragStart, startPos = false, nil, nil
frame.InputBegan:Connect(function(input)
if _G.AceGuiLocked == true then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = frame.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then dragging = false end
end)
end
end)
UIS.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local delta = input.Position - dragStart
frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
end
local pbFrame = Instance.new("Frame", gui)
pbFrame.Name = "StealBar"
pbFrame.Size = UDim2.new(0, 372, 0, 42)
pbFrame.Position = UDim2.new(0.5, -186, 1, -92)
pbFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pbFrame.BorderSizePixel = 0
pbFrame.Active = true
pbFrame.ClipsDescendants = true
Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(1, 0)
local pbSt = Instance.new("UIStroke", pbFrame)
pbSt.Color = THEME_ACCENT
pbSt.Thickness = 1.4
pbSt.Transparency = 0.2
drag(pbFrame)
local pbScale = Instance.new("UIScale")
pbScale.Name = "AceProgressBarScale"
pbScale.Scale = aceProgressBarScaleValue or 1
pbScale.Parent = pbFrame
local fillRegion = Instance.new("Frame", pbFrame)
fillRegion.Size = UDim2.new(0, 214, 1, -10)
fillRegion.Position = UDim2.new(0, 6, 0, 5)
fillRegion.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
fillRegion.BorderSizePixel = 0
fillRegion.ClipsDescendants = true
fillRegion.ZIndex = 2
Instance.new("UICorner", fillRegion).CornerRadius = UDim.new(1, 0)
local fillRegGradient = Instance.new("UIGradient", fillRegion)
fillRegGradient.Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(14, 14, 14))
fillRegGradient.Rotation = 90
local fillRegStroke = Instance.new("UIStroke", fillRegion)
fillRegStroke.Color = THEME_ACCENT
fillRegStroke.Thickness = 1
fillRegStroke.Transparency = 0.6
local progressFill = Instance.new("Frame", fillRegion)
progressFill.Name = "Fill"
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.Position = UDim2.new(0, 0, 0, 0)
progressFill.BackgroundColor3 = THEME_ACCENT
progressFill.BorderSizePixel = 0
progressFill.ZIndex = 3
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
local fillGradient = Instance.new("UIGradient", progressFill)
fillGradient.Color = ColorSequence.new(THEME_ACCENT_BRIGHT, THEME_ACCENT_DIM)
fillGradient.Rotation = 90
local stealLbl = Instance.new("TextLabel", fillRegion)
stealLbl.Size = UDim2.new(0, 50, 1, 0)
stealLbl.Position = UDim2.new(0, 10, 0, 0)
stealLbl.BackgroundTransparency = 1
stealLbl.Text = "STEAL"
stealLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
stealLbl.Font = Enum.Font.GothamSemibold
stealLbl.TextSize = 13
stealLbl.TextXAlignment = Enum.TextXAlignment.Left
stealLbl.ZIndex = 5
local progressPct = Instance.new("TextLabel", fillRegion)
progressPct.Size = UDim2.new(0, 50, 1, 0)
progressPct.Position = UDim2.new(1, -55, 0, 0)
progressPct.BackgroundTransparency = 1
progressPct.Text = "0%"
progressPct.TextColor3 = Color3.fromRGB(230, 230, 230)
progressPct.Font = Enum.Font.GothamSemibold
progressPct.TextSize = 12
progressPct.TextXAlignment = Enum.TextXAlignment.Right
progressPct.ZIndex = 5
local progressRadLbl = Instance.new("TextLabel", pbFrame)
progressRadLbl.Size = UDim2.new(0, 144, 1, 0)
progressRadLbl.Position = UDim2.new(0, 222, 0, 0)
progressRadLbl.BackgroundTransparency = 1
progressRadLbl.Text = "0 FPS | 0ms"
progressRadLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
progressRadLbl.Font = Enum.Font.GothamSemibold
progressRadLbl.TextSize = 13
progressRadLbl.TextScaled = false
progressRadLbl.TextWrapped = false
progressRadLbl.TextXAlignment = Enum.TextXAlignment.Center
progressRadLbl.ZIndex = 4
local barState = "IDLE"
function setBarState(state)
barState = state
if state == "STEALING" then
TS:Create(stealLbl, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
TS:Create(fillRegion, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 26)}):Play()
elseif state == "READY" then
TS:Create(stealLbl, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
TS:Create(fillRegion, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 32)}):Play()
progressPct.Text = "0%"
progressPct.TextColor3 = Color3.fromRGB(235, 235, 235)
else
TS:Create(stealLbl, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
TS:Create(fillRegion, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 26)}):Play()
progressPct.Text = "0%"
progressPct.TextColor3 = Color3.fromRGB(150, 150, 150)
end
end
task.spawn(function()
local lastFrame = tick()
local fpsSamples = {}
local fpsAvg = 60
RunService.RenderStepped:Connect(function()
local now = tick()
local dt = now - lastFrame
lastFrame = now
if dt > 0 then
table.insert(fpsSamples, 1 / dt)
if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
local sum = 0
for _, v in ipairs(fpsSamples) do sum = sum + v end
fpsAvg = sum / #fpsSamples
end
end)
while pbFrame and pbFrame.Parent do
local ping = 0
pcall(function()
local stat = Stats.Network.ServerStatsItem["Data Ping"]
if stat then ping = tonumber(stat:GetValue()) or 0 end
end)
progressRadLbl.Text = string.format("FPS:%d | PING:%dms", math.floor(fpsAvg + 0.5), math.floor(ping + 0.5))
task.wait(0.5)
end
end)
local StealBar = {}
function StealBar.SetProgress(p)
p = math.clamp(p, 0, 1)
progressFill.Size = UDim2.new(p, 0, 1, 0)
progressPct.Text = math.floor(p * 100 + 0.5) .. "%"
end
function StealBar.Reset()
StealBar.SetProgress(0)
setBarState("IDLE")
end
function StealBar.SetState(state)
setBarState(state)
end
setBarState("IDLE")
_G.StealBar = StealBar
end
_G.__AceDuelsSetupStealBar()
if _G.AceAutoStealSync then task.defer(_G.AceAutoStealSync) end
_G.__AceDuelsSetupMinimizeToggle = function()
_G.__AceDuelsMinimized = false
Close.MouseButton1Click:Connect(function()
_G.__AceDuelsMinimized = not _G.__AceDuelsMinimized
if _G.__AceDuelsMinimized then
Main.Visible = false
MiniFrame.Visible = true
else
Main.Visible = true
MiniFrame.Visible = false
Main.Size = FULL_MAIN_SIZE
end
saveAceConfig()
end)
end
_G.__AceDuelsSetupMinimizeToggle()

_G.__AceDuelsRunIntro = function()
local TS = TweenService
local introGuiParent = Gui and Gui.Parent or PlayerGui
local origSize = FULL_MAIN_SIZE or Main.Size
local wasMinimizedBeforeIntro = (_G.__AceDuelsMinimized == true)
if not _introEnabled then
stopIntroPlayback()
stopIntroPreview()
Main.Size = origSize
if not wasMinimizedBeforeIntro then
Main.Visible = true
MiniFrame.Visible = false
else
Main.Visible = false
MiniFrame.Visible = true
end
return
end
playIntroMusic()
-- Keep the full menu/minimize tab hidden while the intro is playing.
Main.Visible = false
MiniFrame.Visible = false
Main.Size = UDim2.new(0, 0, 0, 0)
task.spawn(function()
local introGui = Instance.new("ScreenGui")
introGui.Name = "AceDuelsIntro"
introGui.IgnoreGuiInset = true
introGui.DisplayOrder = 100
introGui.ResetOnSpawn = false
introGui.Parent = introGuiParent
local introActive = true
function finishIntro()
if not introActive then return end
introActive = false
stopIntroPlayback()
MiniFrame.Visible = false
Main.Visible = true
pcall(function()
TS:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = origSize}):Play()
end)
task.delay(0.75, function()
pcall(function() introGui:Destroy() end)
end)
end
local darkBg = Instance.new("Frame", introGui)
darkBg.Size = UDim2.new(1, 0, 1, 0)
darkBg.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
darkBg.BackgroundTransparency = 1
darkBg.BorderSizePixel = 0
darkBg.ZIndex = 1
local bgGrad = Instance.new("UIGradient", darkBg)
bgGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(42,42,46)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18,18,20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,12))})
bgGrad.Rotation = 90
local redWash = Instance.new("Frame", introGui)
redWash.Size = UDim2.new(1,0,1,0)
redWash.BackgroundColor3 = Color3.fromRGB(255,255,255)
redWash.BackgroundTransparency = 1
redWash.BorderSizePixel = 0
redWash.ZIndex = 2
local skipBtn = Instance.new("TextButton", introGui)
skipBtn.Name = "SkipIntro"
skipBtn.AnchorPoint = Vector2.new(1,0)
skipBtn.Position = UDim2.new(1,-22,0,22)
skipBtn.Size = UDim2.new(0,104,0,34)
skipBtn.BackgroundColor3 = Color3.fromRGB(235,235,240)
skipBtn.BackgroundTransparency = 0.08
skipBtn.BorderSizePixel = 0
skipBtn.Text = "SKIP INTRO"
skipBtn.TextColor3 = Color3.fromRGB(0,0,0)
skipBtn.TextSize = 11
skipBtn.Font = Enum.Font.GothamBlack
skipBtn.AutoButtonColor = false
skipBtn.ZIndex = 80
Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0,10)
local skipStroke = Instance.new("UIStroke", skipBtn)
skipStroke.Color = Color3.fromRGB(255,255,255)
skipStroke.Thickness = 1
skipStroke.Transparency = 0.12
skipBtn.MouseButton1Click:Connect(finishIntro)
function makeAceCard(parent, size, z)
local card = Instance.new("Frame", parent)
card.Size = UDim2.new(0, math.floor(size * 0.68), 0, size)
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.BackgroundColor3 = Color3.fromRGB(238, 238, 232)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.ZIndex = z or 6
Instance.new("UICorner", card).CornerRadius = UDim.new(0, math.max(8, math.floor(size * 0.08)))
local stroke = Instance.new("UIStroke", card)
stroke.Color = Color3.fromRGB(190,190,190)
stroke.Thickness = 1
stroke.Transparency = 1
local grad = Instance.new("UIGradient", card)
grad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(195,198,200))
grad.Rotation = 125
local a1 = Instance.new("TextLabel", card)
a1.Size = UDim2.new(0.28,0,0.25,0); a1.Position = UDim2.new(0.06,0,0.04,0)
a1.BackgroundTransparency = 1; a1.Text = "A\nâ™ "; a1.TextColor3 = Color3.fromRGB(0,0,0)
a1.Font = Enum.Font.GothamBlack; a1.TextScaled = true; a1.TextTransparency = 1; a1.ZIndex = (z or 6) + 1
local suit = Instance.new("TextLabel", card)
suit.Size = UDim2.new(0.62,0,0.52,0); suit.Position = UDim2.new(0.19,0,0.25,0)
suit.BackgroundTransparency = 1; suit.Text = "â™ "; suit.TextColor3 = Color3.fromRGB(0,0,0)
suit.Font = Enum.Font.GothamBlack; suit.TextScaled = true; suit.TextTransparency = 1; suit.ZIndex = (z or 6) + 1
local a2 = Instance.new("TextLabel", card)
a2.Size = UDim2.new(0.28,0,0.25,0); a2.Position = UDim2.new(0.66,0,0.71,0)
a2.BackgroundTransparency = 1; a2.Text = "A\nâ™ "; a2.TextColor3 = Color3.fromRGB(0,0,0)
a2.Font = Enum.Font.GothamBlack; a2.TextScaled = true; a2.TextTransparency = 1; a2.Rotation = 180; a2.ZIndex = (z or 6) + 1
return card, {a1, suit, a2}, stroke
end
local cards = {}
for i = 1, 24 do
local size = math.random(46, 108)
local card, labels, stroke = makeAceCard(introGui, size, 5 + i)
local side = (i % 2 == 0) and -0.35 or 1.35
local targetSide = (i % 2 == 0) and 1.35 or -0.35
local y = math.random(4, 96) / 100
card.Position = UDim2.new(side, 0, y, 0)
card.Rotation = math.random(-40, 40)
cards[i] = {frame=card, labels=labels, stroke=stroke, startX=side, endX=targetSide, y=y, speed=0.09+math.random()*0.10, bob=math.random()*6.28, rot=math.random(-55,55), drift=math.random(-14,14)/100}
end
local aceLogo, aceLabels, aceStroke = makeAceCard(introGui, 170, 25)
aceLogo.Position = UDim2.new(0.5,0,-0.35,0)
aceLogo.Rotation = -12
local t = 0
local driftConn = RunService.Heartbeat:Connect(function(dt)
if not introActive then return end
t = t + dt
for _, cd in ipairs(cards) do
local currentX = cd.frame.Position.X.Scale
local dir = cd.startX < cd.endX and 1 or -1
local newX = currentX + dir * cd.speed * dt
if (dir == 1 and newX > 1.40) or (dir == -1 and newX < -0.40) then newX = cd.startX end
local newY = math.clamp(cd.y + math.sin(t * 1.5 + cd.bob) * 0.035 + cd.drift, -0.08, 1.08)
cd.frame.Position = UDim2.new(newX, 0, newY, 0)
cd.frame.Rotation = cd.rot + math.sin(t * 2.5 + cd.bob) * 14
end
end)
local center = Instance.new("Frame", introGui)
center.AnchorPoint = Vector2.new(0.5,0.5); center.Position = UDim2.new(0.5,0,0.5,0); center.Size = UDim2.new(0,660,0,250)
center.BackgroundTransparency = 1; center.ZIndex = 40
local lineTop = Instance.new("Frame", center)
lineTop.AnchorPoint = Vector2.new(0.5,0); lineTop.Position = UDim2.new(0.5,0,0,58); lineTop.Size = UDim2.new(0,0,0,2)
lineTop.BackgroundColor3 = Color3.fromRGB(225,225,225); lineTop.BorderSizePixel = 0; lineTop.ZIndex = 41
local lineBot = Instance.new("Frame", center)
lineBot.AnchorPoint = Vector2.new(0.5,1); lineBot.Position = UDim2.new(0.5,0,1,-8); lineBot.Size = UDim2.new(0,0,0,2)
lineBot.BackgroundColor3 = Color3.fromRGB(225,225,225); lineBot.BorderSizePixel = 0; lineBot.ZIndex = 41
local titleShadow = Instance.new("TextLabel", center)
titleShadow.Size = UDim2.new(1,0,0,86); titleShadow.Position = UDim2.new(0,4,0,83); titleShadow.BackgroundTransparency = 1
titleShadow.Text = "ACE DUELS"; titleShadow.TextColor3 = Color3.fromRGB(0,0,0); titleShadow.Font = Enum.Font.GothamBlack; titleShadow.TextSize = 72
titleShadow.TextTransparency = 1; titleShadow.TextStrokeTransparency = 1; titleShadow.ZIndex = 42
local title = Instance.new("TextLabel", center)
title.Size = UDim2.new(1,0,0,86); title.Position = UDim2.new(0,0,0,78); title.BackgroundTransparency = 1
title.Text = "ACE DUELS"; title.TextColor3 = Color3.fromRGB(245,245,245); title.Font = Enum.Font.GothamBlack; title.TextSize = 72
title.TextTransparency = 1; title.TextStrokeTransparency = 1; title.TextStrokeColor3 = Color3.fromRGB(35,35,35); title.ZIndex = 43
local subtitle = Instance.new("TextLabel", center)
subtitle.Size = UDim2.new(1,0,0,26); subtitle.Position = UDim2.new(0,0,0,169); subtitle.BackgroundTransparency = 1
subtitle.Text = "Eugene"; subtitle.TextColor3 = Color3.fromRGB(200,200,200); subtitle.Font = Enum.Font.GothamMedium; subtitle.TextSize = 19; subtitle.TextTransparency = 1; subtitle.ZIndex = 43
TS:Create(darkBg, TweenInfo.new(0.65), {BackgroundTransparency = 0.22}):Play()
for _, cd in ipairs(cards) do
task.delay(math.random() * 0.9, function()
if not introActive then return end
TS:Create(cd.frame, TweenInfo.new(0.65), {BackgroundTransparency = 0.08}):Play()
if cd.stroke then TS:Create(cd.stroke, TweenInfo.new(0.65), {Transparency = 0.25}):Play() end
for _, lbl in ipairs(cd.labels) do TS:Create(lbl, TweenInfo.new(0.65), {TextTransparency = 0}):Play() end
end)
end
task.wait(0.85); if not introActive then pcall(function() driftConn:Disconnect() end); return end
TS:Create(aceLogo, TweenInfo.new(1.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.20,0), BackgroundTransparency = 0.02, Rotation = 8}):Play()
if aceStroke then TS:Create(aceStroke, TweenInfo.new(0.55), {Transparency = 0.15}):Play() end
for _, lbl in ipairs(aceLabels) do TS:Create(lbl, TweenInfo.new(0.55), {TextTransparency = 0}):Play() end
task.wait(1.05); if not introActive then pcall(function() driftConn:Disconnect() end); return end
TS:Create(lineTop, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,500,0,2)}):Play()
TS:Create(lineBot, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0,500,0,2)}):Play()
task.wait(0.12)
TS:Create(titleShadow, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0.35, TextStrokeTransparency = 1}):Play()
TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0.18}):Play()
task.wait(0.42)
TS:Create(subtitle, TweenInfo.new(0.42), {TextTransparency = 0}):Play()
for i = 1, 3 do
if not introActive then break end
TS:Create(title, TweenInfo.new(0.06), {TextColor3 = Color3.fromRGB(185,185,185)}):Play(); task.wait(0.06)
TS:Create(title, TweenInfo.new(0.06), {TextColor3 = Color3.fromRGB(245,245,245)}):Play(); task.wait(0.06)
end
task.wait(3.05)
if not introActive then pcall(function() driftConn:Disconnect() end); return end
TS:Create(center, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
TS:Create(title, TweenInfo.new(0.36), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
TS:Create(titleShadow, TweenInfo.new(0.36), {TextTransparency = 1}):Play()
TS:Create(subtitle, TweenInfo.new(0.32), {TextTransparency = 1}):Play()
TS:Create(lineTop, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,2)}):Play()
TS:Create(lineBot, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,2)}):Play()
TS:Create(aceLogo, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5,0,1.25,0), BackgroundTransparency = 1, Rotation = 28}):Play()
for _, lbl in ipairs(aceLabels) do TS:Create(lbl, TweenInfo.new(0.45), {TextTransparency = 1}):Play() end
if aceStroke then TS:Create(aceStroke, TweenInfo.new(0.45), {Transparency = 1}):Play() end
TS:Create(darkBg, TweenInfo.new(0.75), {BackgroundTransparency = 1}):Play()
for _, cd in ipairs(cards) do
TS:Create(cd.frame, TweenInfo.new(0.55), {BackgroundTransparency = 1}):Play()
if cd.stroke then TS:Create(cd.stroke, TweenInfo.new(0.55), {Transparency = 1}):Play() end
for _, lbl in ipairs(cd.labels) do TS:Create(lbl, TweenInfo.new(0.55), {TextTransparency = 1}):Play() end
end
Main.Visible = true
MiniFrame.Visible = false
TS:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = origSize}):Play()
task.wait(0.9)
introActive = false
pcall(function() driftConn:Disconnect() end)
pcall(function() introGui:Destroy() end)
end)
end
_G.__AceDuelsRunIntro()

_G.AceDuelsForceSyncLoadedButtons = function()
pcall(function()
if setAutoTPVisual then setAutoTPVisual(autoTPEnabled) end
if autoTPEnabled then startAutoTP() else stopAutoTP() end
end)
pcall(function()
if setInfJumpVisual then setInfJumpVisual(infJumpEnabled) end
if setInfJumpInternal then setInfJumpInternal(infJumpEnabled) end
end)
pcall(function()
if setAntiRagdollVisual then setAntiRagdollVisual(antiRagdollEnabled) end
setAntiRagdoll(antiRagdollEnabled)
end)
pcall(function()
if _G.AceSetAutoLeft then _G.AceSetAutoLeft(autoLeftEnabled, true) end
if _G.AceSetAutoRight then _G.AceSetAutoRight(autoRightEnabled, true) end
end)
pcall(function()
if setAutoStealVisual then setAutoStealVisual(autoStealEnabled) end
if _G.AceAutoStealSync then _G.AceAutoStealSync() end
end)
pcall(function()
if _G.AceNormalAutoSwingSetVisual then _G.AceNormalAutoSwingSetVisual(autoSwingEnabled) end
if _G.AceMirrorTPDownSetVisual then _G.AceMirrorTPDownSetVisual(mirrorTPDownEnabled) end
if _G.AceAntiDesyncAutoSwingSetVisual then _G.AceAntiDesyncAutoSwingSetVisual(antiDesyncAutoSwingEnabled) end
if _G.AceAntiDesyncSetVisual then _G.AceAntiDesyncSetVisual(_G.AceAntiDesyncAimbotOn == true) end
if _G.AceAntiDesyncAimbotOn and _G.AceStartAntiDesyncAimbot then
_G.AceStartAntiDesyncAimbot()
elseif _G.AceStopAntiDesyncAimbot then
_G.AceStopAntiDesyncAimbot()
end
end)
pcall(function()
if selectedAimbotMode == "Anti Bypass" then
if _G.AceNormalAimbotStop then _G.AceNormalAimbotStop() end
if _G.AceAntiBypassAimbotOn and _G.AceAntiBypassStart then
_G.AceAntiBypassStart()
elseif _G.AceAntiBypassStop then
_G.AceAntiBypassStop()
end
else
if _G.AceAntiBypassStop then _G.AceAntiBypassStop() end
if _G.AceNormalAimbotOn and _G.AceNormalAimbotStart then
_G.AceNormalAimbotStart()
elseif _G.AceNormalAimbotStop then
_G.AceNormalAimbotStop()
end
end
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
end)
pcall(function()
if setBatCounterVisual then setBatCounterVisual(batCounterEnabled) end
if setMedCounterVisual then setMedCounterVisual(medCounterEnabled) end
if setSafeModeVisual then setSafeModeVisual(antiKickEnabled) end
if batCounterEnabled then
if _G.AceStartBatCounter then _G.AceStartBatCounter() end
else
if _G.AceStopBatCounter then _G.AceStopBatCounter() end
end
if medCounterEnabled then
if _G.AceStartMedCounter then _G.AceStartMedCounter(LP.Character) end
else
if _G.AceStopMedCounter then _G.AceStopMedCounter() end
end
if _G.AceSetNoPlayerCollisionVisual then _G.AceSetNoPlayerCollisionVisual(_G.AceNoPlayerCollisionEnabled) end
if _G.AceNoPlayerCollisionEnabled then
if enableNoPlayerCollision then enableNoPlayerCollision() end
else
if disableNoPlayerCollision then disableNoPlayerCollision() end
end
if _G.AceSetAutoResetOnMed then
_G.AceSetAutoResetOnMed(autoResetOnMedEnabled, true)
else
if setAutoResetOnMedVisual then setAutoResetOnMedVisual(autoResetOnMedEnabled) end
end
end)
pcall(function()
if setPlayerESPVisual then setPlayerESPVisual(espEnabled) end
if espEnabled then if startPlayerESP then startPlayerESP() end; if BoxedESPOptions then BoxedESPOptions.box = true end else if stopPlayerESP then stopPlayerESP() end; if BoxedESPOptions then BoxedESPOptions.box = false end end
if setTracerESPVisual then setTracerESPVisual(showTracerEnabled) end
if BoxedESPOptions then BoxedESPOptions.tracer = showTracerEnabled end
if refreshBoxedESP then refreshBoxedESP() end
if setRagdollCountdownVisual then setRagdollCountdownVisual(ragdollCountdownEnabled) end
if ragdollCountdownEnabled then hookRagdollCountdown(LP.Character) else stopRagdollCountdown() end
if setFPSBoostVisual then setFPSBoostVisual(fpsBoostEnabled) end
if fpsBoostEnabled then enableStretchRez() else disableStretchRez() end
if setAntiLagVisual then setAntiLagVisual(antiLagVisualEnabled) end
if antiLagVisualEnabled then enableAntiLag() else disableAntiLag() end
if setNukeOptimiserVisual then setNukeOptimiserVisual(nukeOptimiserEnabled) end
if nukeOptimiserEnabled then enableNukeOptimizer() else disableNukeOptimizer() end
if setFOVVisual then setFOVVisual(fovEnabled) end
if fovEnabled then enableCustomFov() else disableCustomFov() end
if setNoCamCollisionVisual then setNoCamCollisionVisual(noCamCollisionEnabled) end
if noCamCollisionEnabled then enableNoCamCollision() else disableNoCamCollision() end
if type(applyCustomSky) == "function" then
applyCustomSky((skyTheme and skyTheme ~= "") and skyTheme or "Off")
end
if skyValueLabel then skyValueLabel.Text = skyTheme or "Off" end
end)
pcall(saveAceConfig)
end
task.defer(function()
task.wait(0.35)
if type(applyCustomSky) == "function" then
pcall(function() applyCustomSky((skyTheme and skyTheme ~= "") and skyTheme or "Off") end)
end
if skyValueLabel then skyValueLabel.Text = skyTheme or "Off" end
end)
task.defer(_G.AceDuelsForceSyncLoadedButtons)
task.delay(1, function()
if _G.AceDuelsForceSyncLoadedButtons then _G.AceDuelsForceSyncLoadedButtons() end
end)
task.defer(function()
task.wait(0.2)
if _G.AceSyncToggleVisuals then _G.AceSyncToggleVisuals() end
end)
customFontVisualEnabled = false
if V then V.customFontEnabled = false end
function enableCustomFont() customFontVisualEnabled=false; if V then V.customFontEnabled=false end end
function disableCustomFont() customFontVisualEnabled=false; if V then V.customFontEnabled=false end end
_G.AceDuelsApplySavedGameplayStates = function()
pcall(function()
if setAutoTPVisual then setAutoTPVisual(autoTPEnabled == true) end
if autoTPEnabled then startAutoTP() else stopAutoTP() end
end)
pcall(function()
if setInfJumpVisual then setInfJumpVisual(infJumpEnabled == true) end
if setInfJumpInternal then setInfJumpInternal(infJumpEnabled == true) end
end)
pcall(function()
if setAntiRagdollVisual then setAntiRagdollVisual(antiRagdollEnabled == true) end
if setAntiRagdoll then setAntiRagdoll(antiRagdollEnabled == true) end
end)
pcall(function()
if setAutoStealVisual then setAutoStealVisual(autoStealEnabled == true) end
if _G.AceAutoStealSync then _G.AceAutoStealSync() end
end)
pcall(function()
if setBatCounterVisual then setBatCounterVisual(batCounterEnabled == true) end
if batCounterEnabled and _G.AceStartBatCounter then _G.AceStartBatCounter() elseif _G.AceStopBatCounter then _G.AceStopBatCounter() end
end)
pcall(function()
if setMedCounterVisual then setMedCounterVisual(medCounterEnabled == true) end
if medCounterEnabled and _G.AceStartMedCounter then _G.AceStartMedCounter(LP.Character) elseif _G.AceStopMedCounter then _G.AceStopMedCounter() end
end)
pcall(function()
if _G.AceSetNoPlayerCollisionVisual then _G.AceSetNoPlayerCollisionVisual(_G.AceNoPlayerCollisionEnabled == true) end
if _G.AceNoPlayerCollisionEnabled then enableNoPlayerCollision() else disableNoPlayerCollision() end
end)
pcall(function()
if setSafeModeVisual then setSafeModeVisual(antiKickEnabled == true) end
end)
pcall(function()
if _G.AceSetAutoResetOnMed then _G.AceSetAutoResetOnMed(autoResetOnMedEnabled == true, true) end
end)
pcall(function()
if setPlayerESPVisual then setPlayerESPVisual(espEnabled == true) end
if espEnabled then if startPlayerESP then startPlayerESP() end else if stopPlayerESP then stopPlayerESP() end end
end)
pcall(function()
if setTracerESPVisual then setTracerESPVisual(showTracerEnabled == true) end
if BoxedESPOptions then BoxedESPOptions.tracer = showTracerEnabled == true end
if refreshBoxedESP then refreshBoxedESP() end
end)
pcall(function()
if setRagdollCountdownVisual then setRagdollCountdownVisual(ragdollCountdownEnabled == true) end
if ragdollCountdownEnabled then hookRagdollCountdown(LP.Character) else stopRagdollCountdown() end
end)
pcall(function()
if setFPSBoostVisual then setFPSBoostVisual(fpsBoostEnabled == true) end
if fpsBoostEnabled then enableStretchRez() else disableStretchRez() end
end)
pcall(function()
if setAntiLagVisual then setAntiLagVisual(antiLagVisualEnabled == true) end
if antiLagVisualEnabled then enableAntiLag() else disableAntiLag() end
end)
pcall(function()
if setNukeOptimiserVisual then setNukeOptimiserVisual(nukeOptimiserEnabled == true) end
if nukeOptimiserEnabled then enableNukeOptimizer() else disableNukeOptimizer() end
end)
pcall(function()
if setFOVVisual then setFOVVisual(fovEnabled == true) end
if fovEnabled then enableCustomFov() else disableCustomFov() end
end)
pcall(function()
if setNoCamCollisionVisual then setNoCamCollisionVisual(noCamCollisionEnabled == true) end
if noCamCollisionEnabled then enableNoCamCollision() else disableNoCamCollision() end
end)
pcall(function()
if type(applyCustomSky) == "function" then applyCustomSky((skyTheme and skyTheme ~= "") and skyTheme or "Off") end
if skyValueLabel then skyValueLabel.Text = skyTheme or "Off" end
end)
pcall(function()
if syncAnimationPackIndex then syncAnimationPackIndex() end
if refreshAnimationPackRow then refreshAnimationPackRow() end
if applySavedAnimationPackToCharacter then applySavedAnimationPackToCharacter(LP.Character) end
end)
end
task.defer(function()
task.wait(0.25)
if _G.AceDuelsApplySavedGameplayStates then _G.AceDuelsApplySavedGameplayStates() end
end)
task.delay(1.25, function()
if _G.AceDuelsApplySavedGameplayStates then _G.AceDuelsApplySavedGameplayStates() end
end)
task.delay(3, function()
if antiLagVisualEnabled and type(applyKTMOptimization) == "function" then pcall(applyKTMOptimization) end
if nukeOptimiserEnabled and type(applyKTMOptimization) == "function" then pcall(applyKTMOptimization) end
end)
_G.AceAutoTPRestoreWanted = _G.AceAutoTPRestoreWanted or false
_G.AceAutoTPRestoreBlockedUntil = _G.AceAutoTPRestoreBlockedUntil or 0
function aceAnyAimbotActive()
return (_G.AceNormalAimbotOn == true) or (_G.AceAntiBypassAimbotOn == true) or (_G.AceAntiDesyncAimbotOn == true) or (_G.AceAntiDesyncAimbotOn == true)
end
_G.AceStopAutoTPForAction = function()
if autoTPEnabled then
_G.AceAutoTPRestoreWanted = true
_G.AceAutoTPRestoreBlockedUntil = tick() + 0.35
stopAutoTP()
if setAutoTPVisual then setAutoTPVisual(false) end
end
end
function aceTryRestoreAutoTP()
if not _G.AceAutoTPRestoreWanted then return end
if tick() < (_G.AceAutoTPRestoreBlockedUntil or 0) then return end
if aceAnyAimbotActive() then return end
if dropBrainrotActive then return end
_G.AceAutoTPRestoreWanted = false
startAutoTP()
if setAutoTPVisual then setAutoTPVisual(true) end
saveAceConfig()
end
RunService.Heartbeat:Connect(aceTryRestoreAutoTP)
_G._oldAceStopNormalAimbot = _G.AceStopNormalAimbot
_G.AceStopNormalAimbot = function(...)
local r = {_G._oldAceStopNormalAimbot(...)}
_G.AceAutoTPRestoreBlockedUntil = tick() + 0.05
task.delay(0.08, aceTryRestoreAutoTP)
return unpack(r)
end
_G.AceNormalAimbotStop = _G.AceStopNormalAimbot
_G._oldAceStopAntiBypassAimbot = _G.AceStopAntiBypassAimbot
_G.AceStopAntiBypassAimbot = function(...)
local r = {_G._oldAceStopAntiBypassAimbot(...)}
_G.AceAutoTPRestoreBlockedUntil = tick() + 0.05
task.delay(0.08, aceTryRestoreAutoTP)
return unpack(r)
end
_G.AceAntiBypassStop = _G.AceStopAntiBypassAimbot
_G._oldAceStopAntiDesyncAimbot = _G.AceStopAntiDesyncAimbot
_G.AceStopAntiDesyncAimbot = function(...)
local r = {_G._oldAceStopAntiDesyncAimbot(...)}
_G.AceAutoTPRestoreBlockedUntil = tick() + 0.05
task.delay(0.08, aceTryRestoreAutoTP)
return unpack(r)
end
task.spawn(function()
local wasDropping = false
while task.wait(0.05) do
if dropBrainrotActive then
wasDropping = true
elseif wasDropping then
wasDropping = false
_G.AceAutoTPRestoreBlockedUntil = tick() + 0.05
task.delay(0.08, aceTryRestoreAutoTP)
end
end
end)
function aceRepairKeybinds()
for keyId, defaultKey in pairs(DEFAULT_SPEED_KEYBINDS) do
if speedKeybinds[keyId] == Enum.KeyCode.Unknown then
speedKeybinds[keyId] = defaultKey
end
end
if tpDownKeybind == Enum.KeyCode.Unknown then tpDownKeybind = DEFAULT_TP_DOWN_KEYBIND end
if refreshAllSpeedKeybinds then refreshAllSpeedKeybinds() end
if refreshTPDownKeybind then refreshTPDownKeybind() end
end
_G._oldSaveAceConfigStable = saveAceConfig
saveAceConfig = function()
aceRepairKeybinds()
return _G._oldSaveAceConfigStable()
end
aceRepairKeybinds()
task.defer(function()
task.wait(0.2)
aceRepairKeybinds()
saveAceConfig()
end)
task.defer(function()
task.wait(0.35)
local TS = game:GetService("TweenService")
local old = PlayerGui:FindFirstChild("AceMobileButtons")
if old then old:Destroy() end
local mobileGui = Instance.new("ScreenGui")
mobileGui.Name = "AceMobileButtons"
mobileGui.ResetOnSpawn = false
mobileGui.IgnoreGuiInset = true
mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mobileGui.DisplayOrder = 1000
mobileGui.Parent = PlayerGui
_G.AceMobileButtonRefs = {}
local mobileButtons = _G.AceMobileButtonRefs
function _G.AceApplyMobileButtonsHidden()
local g = PlayerGui:FindFirstChild("AceMobileButtons")
if g then g.Enabled = not (_G.AceHideMobileButtons == true) end
if setHideMobileButtonsVisual then pcall(setHideMobileButtonsVisual, _G.AceHideMobileButtons == true) end
end
function _G.AceApplyMobileButtonSize()
_G.AceMobileButtonScale = math.clamp(tonumber(_G.AceMobileButtonScale) or 0.75, 0.30, 1.35)
for _, entry in pairs(mobileButtons) do
local holder = entry and entry.holder
if holder then
local sc = holder:FindFirstChild("MobileButtonScale") or Instance.new("UIScale")
sc.Name = "MobileButtonScale"
sc.Scale = _G.AceMobileButtonScale
sc.Parent = holder
end
end
pcall(function()
local gui = PlayerGui:FindFirstChild("AceDuelsAdaptReconstruct") or PlayerGui:FindFirstChild("AdaptHubPolished") or PlayerGui:FindFirstChild("CyberHub")
local root = gui or PlayerGui
for _, obj in ipairs(root:GetDescendants()) do
if obj.Name == "Mobile Buttons Size" then
local valueBox = obj:FindFirstChild("Value")
if valueBox and valueBox:IsA("TextLabel") then
valueBox.Text = string.format("%.2f", _G.AceMobileButtonScale)
end
end
end
end)
end
local function setActive(btn, state)
if not btn then return end
local pressed = btn:GetAttribute("AceMobilePressed") == true
state = (state == true) or pressed
local visualState = state and "on" or "off"
if btn:GetAttribute("AceMobileVisualState") == visualState then return end
btn:SetAttribute("AceMobileVisualState", visualState)
local holder = btn.Parent
local glow = holder and holder:FindFirstChild("Glow")
local st = btn:FindFirstChildOfClass("UIStroke")
TS:Create(btn, TweenInfo.new(0.18), {
BackgroundColor3 = state and Color3.fromRGB(238,238,238) or Color3.fromRGB(8,8,8),
TextColor3 = state and Color3.fromRGB(0,0,0) or Color3.fromRGB(225,225,225),
TextTransparency = 0,
}):Play()
if st then
TS:Create(st, TweenInfo.new(0.18), {
Color = state and Color3.fromRGB(190,190,190) or Color3.fromRGB(85,85,85),
Thickness = 1,
Transparency = state and 0 or 0.4,
}):Play()
end
if glow then
glow.Visible = false
glow.BackgroundTransparency = 1
local gs = glow:FindFirstChildOfClass("UIStroke")
if gs then gs.Transparency = 1 end
end
end
local function pulse(btn)
if not btn then return end
btn:SetAttribute("AceMobilePressed", true)
setActive(btn, true)
task.delay(0.18, function()
if btn and btn.Parent then
btn:SetAttribute("AceMobilePressed", false)
setActive(btn, false)
end
end)
end
local function makeButton(key, label, pos, onPress)
local holder = Instance.new("Frame")
holder.Name = "MBH_" .. key
holder.Size = UDim2.new(0, 78, 0, 58)
holder.Position = tableToUDim2(_G.AceMobileButtonPositions[key], pos)
holder.BackgroundTransparency = 1
holder.BorderSizePixel = 0
holder.ZIndex = 1000
holder.Active = true
holder.Parent = mobileGui
local glow = Instance.new("Frame", holder)
glow.Name = "Glow"
glow.Size = UDim2.new(1, 4, 1, 4)
glow.Position = UDim2.new(0, -2, 0, -2)
glow.BackgroundColor3 = Color3.fromRGB(255,255,255)
glow.BackgroundTransparency = 1
glow.BorderSizePixel = 0
glow.ZIndex = 1000
Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 13)
local glowStroke = Instance.new("UIStroke", glow)
glowStroke.Color = Color3.fromRGB(255,255,255)
glowStroke.Thickness = 0.8
glowStroke.Transparency = 1
glowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local btn = Instance.new("TextButton", holder)
btn.Name = "MB_" .. key
btn.Size = UDim2.new(1, 0, 1, 0)
btn.Position = UDim2.new(0, 0, 0, 0)
btn.BackgroundColor3 = Color3.fromRGB(8,8,8)
btn.BackgroundTransparency = 0
btn.BorderSizePixel = 0
btn.Text = label
btn.TextColor3 = Color3.fromRGB(225,225,225)
btn.Font = Enum.Font.GothamBlack
btn.TextSize = 10
btn.TextWrapped = true
btn.AutoButtonColor = false
btn.ZIndex = 1002
btn.Active = true
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", btn)
stroke.Color = Color3.fromRGB(85,85,85)
stroke.Thickness = 1
stroke.Transparency = 0.4
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local pressing, dragging = false, false
local pressPos, holderStart = nil, nil
btn.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
pressing = true
dragging = false
pressPos = i.Position
holderStart = holder.Position
btn:SetAttribute("AceMobilePressed", true)
setActive(btn, true)
pcall(function()
TS:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Position = UDim2.new(0, 0, 0, 4),
Size = UDim2.new(1, 0, 1, -4)
}):Play()
end)
end
end)
btn.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
if pressing and not dragging then pcall(onPress, btn) end
if dragging then saveAceConfig() end
pressing = false
dragging = false
btn:SetAttribute("AceMobilePressed", false)
pcall(function()
TS:Create(btn, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Position = UDim2.new(0, 0, 0, 0),
Size = UDim2.new(1, 0, 1, 0)
}):Play()
end)
task.delay(0.08, function()
if btn and btn.Parent then
local keepOn = false
if key == "autoLeft" then keepOn = autoLeftEnabled == true
elseif key == "autoRight" then keepOn = autoRightEnabled == true
elseif key == "aimbot" then keepOn = (_G.AceNormalAimbotOn == true) or (_G.AceAntiBypassAimbotOn == true)
elseif key == "antiDesync" then keepOn = _G.AceAntiDesyncAimbotOn == true
elseif key == "carry" then keepOn = currentSpeedMode == "Carry"
elseif key == "laggerNormal" then keepOn = currentSpeedMode == "Lagger"
elseif key == "laggerCarry" then keepOn = currentSpeedMode == "Lagger Carry"
end
setActive(btn, keepOn)
end
end)
end
end)
UserInputService.InputChanged:Connect(function(i)
if _G.AceGuiLocked == true or not pressing then return end
if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
local delta = i.Position - pressPos
if not dragging and (math.abs(delta.X) > 6 or math.abs(delta.Y) > 6) then dragging = true end
if dragging then
holder.Position = UDim2.new(holderStart.X.Scale, holderStart.X.Offset + delta.X, holderStart.Y.Scale, holderStart.Y.Offset + delta.Y)
end
end)
mobileButtons[key] = {holder = holder, btn = btn, setActive = function(state) setActive(btn, state) end}
return btn
end
local x1, x2, x3 = -218, -154, -90
local y1, y2, y3, y4 = -150, -102, -54, -6
local defaults = {
insta        = UDim2.new(1, x1, 0.5, y1),
drop         = UDim2.new(1, x2, 0.5, y1),
autoLeft     = UDim2.new(1, x3, 0.5, y1),
antiDesync   = UDim2.new(1, x1, 0.5, y2),
aimbot       = UDim2.new(1, x2, 0.5, y2),
autoRight    = UDim2.new(1, x3, 0.5, y2),
tp           = UDim2.new(1, x2, 0.5, y3),
carry        = UDim2.new(1, x3, 0.5, y3),
laggerNormal = UDim2.new(1, x2, 0.5, y4),
laggerCarry  = UDim2.new(1, x3, 0.5, y4),
}
function _G.AceResetMobileButtons()
_G.AceMobileButtonScale = 0.75
_G.AceHideMobileButtons = false
for key, defaultPos in pairs(defaults) do
local entry = mobileButtons[key]
local holder = entry and entry.holder
if holder then
holder.Position = defaultPos
holder.Size = UDim2.new(0, 78, 0, 58)
local btn = entry.btn
if btn then
btn.Position = UDim2.new(0, 0, 0, 0)
btn.Size = UDim2.new(1, 0, 1, 0)
btn:SetAttribute("AceMobilePressed", false)
btn:SetAttribute("AceMobileVisualState", nil)
end
end
end
if _G.AceApplyMobileButtonSize then _G.AceApplyMobileButtonSize() end
if _G.AceApplyMobileButtonsHidden then _G.AceApplyMobileButtonsHidden() end
if showActionNotification then pcall(function() showActionNotification("MOBILE BUTTONS RESET") end) end
saveAceConfig()
end
makeButton("insta", "INSTA\nRESET", defaults.insta, function(btn)
if _G.AceCursedInstaReset then _G.AceCursedInstaReset() elseif cursedInstaReset then cursedInstaReset() end
pulse(btn)
end)
makeButton("drop", "DROP\nBR", defaults.drop, function(btn)
if runDropBrainrot then runDropBrainrot() elseif runDrop then runDrop() end
pulse(btn)
end)
makeButton("autoLeft", "AUTO\nLEFT", defaults.autoLeft, function(btn)
if _G.AceSetAutoLeft then _G.AceSetAutoLeft(not autoLeftEnabled) end
task.delay(0.03, function()
if mobileButtons.autoLeft then mobileButtons.autoLeft.setActive(autoLeftEnabled == true) end
if mobileButtons.autoRight then mobileButtons.autoRight.setActive(autoRightEnabled == true) end
end)
end)
makeButton("antiDesync", "ANTI\nDESYNC", defaults.antiDesync, function(btn)
if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
return
end
if _G.AceToggleAntiDesyncAimbot then
_G.AceToggleAntiDesyncAimbot()
elseif _G.AceStartAntiDesyncAimbot and _G.AceStopAntiDesyncAimbot then
if _G.AceAntiDesyncAimbotOn then _G.AceStopAntiDesyncAimbot() else _G.AceStartAntiDesyncAimbot() end
end
task.delay(0.03, function() setActive(btn, _G.AceAntiDesyncAimbotOn == true) end)
end)
makeButton("aimbot", "BAT\nBOT", defaults.aimbot, function(btn)
if _G.AceSafeModeIsLocked and _G.AceSafeModeIsLocked() then
if _G.AceSafeModeForceStop then _G.AceSafeModeForceStop("SAFE MODE LOCK") end
return
end
if _G.AceToggleSelectedAimbot then _G.AceToggleSelectedAimbot() end
if _G.AceRefreshAimbotVisual then _G.AceRefreshAimbotVisual() end
task.delay(0.03, function()
setActive(btn, (_G.AceNormalAimbotOn == true) or (_G.AceAntiBypassAimbotOn == true))
end)
end)
makeButton("autoRight", "AUTO\nRIGHT", defaults.autoRight, function(btn)
if _G.AceSetAutoRight then _G.AceSetAutoRight(not autoRightEnabled) end
task.delay(0.03, function()
if mobileButtons.autoRight then mobileButtons.autoRight.setActive(autoRightEnabled == true) end
if mobileButtons.autoLeft then mobileButtons.autoLeft.setActive(autoLeftEnabled == true) end
end)
end)
makeButton("tp", "TP\nDOWN", defaults.tp, function(btn)
if runTPFloor then runTPFloor() end
pulse(btn)
end)
makeButton("carry", "CARRY\nSPEED", defaults.carry, function(btn)
if setSpeedMode then setSpeedMode(currentSpeedMode == "Carry" and "Normal" or "Carry") end
task.delay(0.03, function()
if mobileButtons.carry then mobileButtons.carry.setActive(currentSpeedMode == "Carry") end
if mobileButtons.laggerNormal then mobileButtons.laggerNormal.setActive(currentSpeedMode == "Lagger") end
if mobileButtons.laggerCarry then mobileButtons.laggerCarry.setActive(currentSpeedMode == "Lagger Carry") end
end)
end)
makeButton("laggerNormal", "LAGGER\nNORMAL", defaults.laggerNormal, function(btn)
if setSpeedMode then setSpeedMode(currentSpeedMode == "Lagger" and "Normal" or "Lagger") end
task.delay(0.03, function()
if mobileButtons.carry then mobileButtons.carry.setActive(currentSpeedMode == "Carry") end
if mobileButtons.laggerNormal then mobileButtons.laggerNormal.setActive(currentSpeedMode == "Lagger") end
if mobileButtons.laggerCarry then mobileButtons.laggerCarry.setActive(currentSpeedMode == "Lagger Carry") end
end)
end)
makeButton("laggerCarry", "LAGGER\nCARRY", defaults.laggerCarry, function(btn)
if setSpeedMode then setSpeedMode(currentSpeedMode == "Lagger Carry" and "Normal" or "Lagger Carry") end
task.delay(0.03, function()
if mobileButtons.carry then mobileButtons.carry.setActive(currentSpeedMode == "Carry") end
if mobileButtons.laggerNormal then mobileButtons.laggerNormal.setActive(currentSpeedMode == "Lagger") end
if mobileButtons.laggerCarry then mobileButtons.laggerCarry.setActive(currentSpeedMode == "Lagger Carry") end
end)
end)
_G.AceApplyMobileButtonSize()
_G.AceApplyMobileButtonsHidden()
RunService.Heartbeat:Connect(function()
if mobileButtons.autoLeft then mobileButtons.autoLeft.setActive(autoLeftEnabled == true) end
if mobileButtons.autoRight then mobileButtons.autoRight.setActive(autoRightEnabled == true) end
if mobileButtons.aimbot then mobileButtons.aimbot.setActive((_G.AceNormalAimbotOn == true) or (_G.AceAntiBypassAimbotOn == true)) end
if mobileButtons.antiDesync then mobileButtons.antiDesync.setActive(_G.AceAntiDesyncAimbotOn == true) end
if mobileButtons.carry then mobileButtons.carry.setActive(currentSpeedMode == "Carry") end
if mobileButtons.laggerNormal then mobileButtons.laggerNormal.setActive(currentSpeedMode == "Lagger") end
if mobileButtons.laggerCarry then mobileButtons.laggerCarry.setActive(currentSpeedMode == "Lagger Carry") end
end)
end)
