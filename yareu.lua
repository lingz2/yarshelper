-- AUTO SUMMIT LOOP (TOMBOL + / - DELAY, RANGE 0.1s - 5s)
-- By Yars

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CFrame Summit
local SummitCF = CFrame.new(
    -906.765137,804.369141,1874.07275,
    -0.316883892, 8.65463434e-08, -0.948464334,
    8.30728126e-08, 1, 6.349411316e-08,
    0.948464334, -5.867133622e-08, -0.316883892
)

-- GUI (CoreGui biar nggak hilang saat respawn)
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,140)
frame.Position = UDim2.new(0.05,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

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

-- Delay Label
local delayLabel = Instance.new("TextLabel", frame)
delayLabel.Size = UDim2.new(1,0,0,25)
delayLabel.Position = UDim2.new(0,0,0.55,0)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay: 0.5s"
delayLabel.TextColor3 = Color3.fromRGB(255,255,255)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 14

-- Tombol -
local minusBtn = Instance.new("TextButton", frame)
minusBtn.Size = UDim2.new(0.4,0,0,30)
minusBtn.Position = UDim2.new(0.05,0,0.75,0)
minusBtn.Text = "- Delay"
minusBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
minusBtn.TextColor3 = Color3.fromRGB(255,255,255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 14
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0,8)

-- Tombol +
local plusBtn = Instance.new("TextButton", frame)
plusBtn.Size = UDim2.new(0.4,0,0,30)
plusBtn.Position = UDim2.new(0.55,0,0.75,0)
plusBtn.Text = "+ Delay"
plusBtn.BackgroundColor3 = Color3.fromRGB(60,180,220)
plusBtn.TextColor3 = Color3.fromRGB(255,255,255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 14
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0,8)

-- Variabel
local running = false
local delayTime = 0.5
local MIN_DELAY, MAX_DELAY = 0.1, 5.0

-- Fungsi Auto Summit
local function autoSummit()
    while running do
        -- pastikan karakter ada
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        -- teleport ke summit
        hrp.CFrame = SummitCF
        task.wait(0.2)

        -- respawn (kill humanoid)
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end

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

-- Tombol + dan - Delay
plusBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime + 0.1, MIN_DELAY, MAX_DELAY)
    delayLabel.Text = "Delay: "..string.format("%.1f",delayTime).."s"
end)

minusBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime - 0.1, MIN_DELAY, MAX_DELAY)
    delayLabel.Text = "Delay: "..string.format("%.1f",delayTime).."s"
end)
