--// BAT AIMBOT TOGGLE GUI
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "BatAimbotGUI"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "BatAimbotToggle"
button.Size = UDim2.fromOffset(150, 42)
button.Position = UDim2.new(0, 20, 0.5, -21)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.BorderSizePixel = 0
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 15
button.Font = Enum.Font.GothamBold
button.Text = "BAT AIMBOT: OFF"
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(70, 70, 70)
stroke.Parent = button

local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local function updateButton()
    if autoBatEnabled then
        button.Text = "BAT AIMBOT: ON"
        button.BackgroundColor3 = Color3.fromRGB(35, 120, 65)
    else
        button.Text = "BAT AIMBOT: OFF"
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end
end

button.MouseButton1Click:Connect(function()
    if autoBatEnabled then
        stopBatAimbot()
    else
        startBatAimbot()
    end

    updateButton()
end)

updateButton()
