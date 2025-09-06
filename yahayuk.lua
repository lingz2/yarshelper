-- YARS AUTO SUMMIT GUI (Final Version)
-- CP1-CP5 -> Summit -> Respawn -> Basecamp -> Loop
-- Delay Control 0.1s - 1s

if game.CoreGui:FindFirstChild("YARS_SUMMIT_GUI") then
    game.CoreGui:FindFirstChild("YARS_SUMMIT_GUI"):Destroy()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CP & Summit CFrames
local checkpoints = {
    CFrame.new(-429.346497, 248.062042, 789.232971, -1.19209275e-07, 0, -1, 0, 1, 0, 1, 0, -1.19209275e-07), -- CP1
    CFrame.new(-348.049988, 387.692017, 522.400024, -1.19209275e-07, 0, -1,0, 1, 0, 1, 0, -1.19209275e-07), -- CP2
    CFrame.new(287.950012, 428.691956, 503.687042, -1.19209275e-07, 0, -1, 0, 1, 0, 1, 0, -1.19209275e-07), -- CP3
    CFrame.new(333.859863, 489.692017, 348.370453, -0.000248972123, -8.6770342e-08, -0.99999994, 5.96024741e-08, 1, -8.678518536e-08, 0.99999994, -5.96240781e-08, -0.000248972123), -- CP4
    CFrame.new(223.016113, 313.692017, -146.599976, -1.19209275e-07, 0, -1,0, 1, 0, 1, 0, -1.19209275e-07), -- CP5
    CFrame.new(-614, 904.432007, -519, 1, 1.074868116e-08, 6.566553476e-15, -1.07486811e-08, 1, 4.186879116e-08, -6.116519366e-15, -4.18687911e-08, 1) -- Summit
}

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "YARS_SUMMIT_GUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 380)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.1
Frame.Active = true
Frame.Draggable = true
Frame.Name = "MainFrame"

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🏔️ YARS AUTO SUMMIT"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Buttons CP
for i = 1, #checkpoints do
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 40 + (i-1)*35)
    btn.Text = "Teleport CP"..i
    if i == #checkpoints then btn.Text = "🏔️ Summit" end
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16

    btn.MouseButton1Click:Connect(function()
        local char = player.Character or player.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart").CFrame = checkpoints[i]
    end)
end

-- Auto Loop
local loopRunning = false
local delayTime = 0.5

local AutoBtn = Instance.new("TextButton", Frame)
AutoBtn.Size = UDim2.new(1, -20, 0, 40)
AutoBtn.Position = UDim2.new(0, 10, 0, 40 + (#checkpoints)*35)
AutoBtn.Text = "▶️ Start Auto Summit"
AutoBtn.BackgroundColor3 = Color3.fromRGB(80,20,20)
AutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 18

-- Slider for Delay
local DelayLabel = Instance.new("TextLabel", Frame)
DelayLabel.Size = UDim2.new(1, -20, 0, 25)
DelayLabel.Position = UDim2.new(0, 10, 1, -70)
DelayLabel.Text = "Delay: "..delayTime.."s"
DelayLabel.TextColor3 = Color3.fromRGB(255,255,255)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Font = Enum.Font.SourceSansBold
DelayLabel.TextSize = 16

local Slider = Instance.new("TextButton", Frame)
Slider.Size = UDim2.new(1, -20, 0, 25)
Slider.Position = UDim2.new(0, 10, 1, -40)
Slider.Text = "⏳ Adjust Delay"
Slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
Slider.TextColor3 = Color3.fromRGB(200,200,200)
Slider.Font = Enum.Font.SourceSans
Slider.TextSize = 14

Slider.MouseButton1Click:Connect(function()
    delayTime = delayTime + 0.1
    if delayTime > 1 then delayTime = 0.1 end
    DelayLabel.Text = "Delay: "..string.format("%.1f", delayTime).."s"
end)

-- Loop Function
local function AutoSummit()
    loopRunning = true
    AutoBtn.Text = "⏹ Stop Auto Summit"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(20,80,20)

    while loopRunning do
        -- CP1 sampai Summit
        for i = 1, #checkpoints do
            local char = player.Character or player.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart").CFrame = checkpoints[i]
            task.wait(delayTime)
        end

        -- Respawn (reset summit, spawn ke basecamp)
        player:LoadCharacter()
        task.wait(3) -- tunggu respawn selesai

        -- setelah respawn, otomatis loop ulang dari CP1
    end
end

AutoBtn.MouseButton1Click:Connect(function()
    if loopRunning then
        loopRunning = false
        AutoBtn.Text = "▶️ Start Auto Summit"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(80,20,20)
    else
        AutoSummit()
    end
end)
