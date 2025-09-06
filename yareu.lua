-- AUTO SUMMIT LOOP (MODERN UI)
-- By Yars

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- CFrame Summit
local SummitCF = CFrame.new(
    -906.765137,804.369141,1874.07275,
    -0.316883892, 8.65463434e-08, -0.948464334,
    8.30728126e-08, 1, 6.349411316e-08,
    0.948464334, -5.867133622e-08, -0.316883892
)

-- Spawn / Respawn Point
local SpawnCF = CFrame.new(workspace.SpawnLocation.Position + Vector3.new(0,5,0))

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,120)
frame.Position = UDim2.new(0.05,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Rounded corner
local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0,12)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Auto Summit"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Toggle Button
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,35)
toggle.Position = UDim2.new(0.05,0,0.25,0)
toggle.Text = "Start"
toggle.BackgroundColor3 = Color3.fromRGB(50,200,80)
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,10)

-- Slider bar
local sliderBar = Instance.new("Frame", frame)
sliderBar.Size = UDim2.new(0.9,0,0,10)
sliderBar.Position = UDim2.new(0.05,0,0.7,0)
sliderBar.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0,8)

-- Slider knob
local knob = Instance.new("Frame", sliderBar)
knob.Size = UDim2.new(0,20,0,20)
knob.Position = UDim2.new(0,0,-0.5,0)
knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- Slider label
local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(1,0,0,20)
sliderLabel.Position = UDim2.new(0,0,0.85,0)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Delay: 0.5s"
sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 14

-- Variabel
local running = false
local delayTime = 0.5
local UIS = game:GetService("UserInputService")

-- Auto Summit Loop
local function autoSummit()
    while running do
        hrp.CFrame = SummitCF
        task.wait(0.2)
        hrp.CFrame = SpawnCF
        task.wait(delayTime)
    end
end

-- Toggle Button
toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "Stop" or "Start"
    toggle.BackgroundColor3 = running and Color3.fromRGB(200,60,60) or Color3.fromRGB(50,200,80)
    if running then
        task.spawn(autoSummit)
    end
end)

-- Drag Slider Knob
local dragging = false

knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local barAbsSize = sliderBar.AbsoluteSize.X
        local barAbsPos = sliderBar.AbsolutePosition.X
        local mousePos = math.clamp((input.Position.X - barAbsPos)/barAbsSize,0,1)

        knob.Position = UDim2.new(mousePos, -10, -0.5, 0)
        delayTime = 0.1 + (0.9 * mousePos)
        sliderLabel.Text = "Delay: "..string.format("%.2f",delayTime).."s"
    end
end)
