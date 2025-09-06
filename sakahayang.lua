--// AUTO SUMMIT HARD MODE (Delta Executor Mobile Fix)
--// Dibuat oleh Yars

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote & Argumen Hard
local RF_GetLevel = ReplicatedStorage:WaitForChild("LevelService"):WaitForChild("RF_GetLevel")
local HardID = 9349848927

-- CFrame Puncak
local summitCF = CFrame.new(911.468689, 3141.61108, 562.791443, 
    0.997609913, -1.07775797e-08, 0.0690972731, 
    7.78348674e-09, 1, 4.360079592e-08, 
    -0.0690972731, -4.29587672e-08, 0.997609913)

-- Variabel
local running = false
local delayTime = 1 -- default
local minDelay, maxDelay = 0.1, 5

-- GUI (PASTI MUNCUL DI HP)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui") -- FIX: pakai PlayerGui biar muncul di HP

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 140)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🏔️ Auto Summit Hard"
title.TextColor3 = Color3.fromRGB(255, 215, 0) -- emas
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local status = Instance.new("TextLabel", Frame)
status.Position = UDim2.new(0, 0, 0, 35)
status.Size = UDim2.new(1, 0, 0, 25)
status.Text = "Status: ❌ OFF"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14

local startBtn = Instance.new("TextButton", Frame)
startBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
startBtn.Size = UDim2.new(0.4, 0, 0.25, 0)
startBtn.Text = "▶️ Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100) -- hijau terang
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)

local stopBtn = Instance.new("TextButton", Frame)
stopBtn.Position = UDim2.new(0.55, 0, 0.5, 0)
stopBtn.Size = UDim2.new(0.4, 0, 0.25, 0)
stopBtn.Text = "⏹ Stop"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- merah terang
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 8)

local delayLbl = Instance.new("TextLabel", Frame)
delayLbl.Position = UDim2.new(0,0,0.8,0)
delayLbl.Size = UDim2.new(1,0,0,20)
delayLbl.Text = "⏱ Delay: "..delayTime.."s"
delayLbl.TextColor3 = Color3.fromRGB(200,200,200)
delayLbl.Font = Enum.Font.Gotham
delayLbl.BackgroundTransparency = 1
delayLbl.TextSize = 14

local plusBtn = Instance.new("TextButton", Frame)
plusBtn.Position = UDim2.new(0.7,0,0.8,0)
plusBtn.Size = UDim2.new(0.25,0,0,20)
plusBtn.Text = "+"
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 14
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- biru terang
Instance.new("UICorner", plusBtn)

local minusBtn = Instance.new("TextButton", Frame)
minusBtn.Position = UDim2.new(0.45,0,0.8,0)
minusBtn.Size = UDim2.new(0.25,0,0,20)
minusBtn.Text = "-"
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 14
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- biru terang
Instance.new("UICorner", minusBtn)

-- Fungsi Loop Summit
local function doSummit()
    while running do
        -- pilih level hard
        pcall(function()
            RF_GetLevel:InvokeServer(HardID)
        end)

        task.wait(0.3)

        -- teleport ke puncak
        local char = player.Character or player.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = summitCF
        end

        task.wait(delayTime)

        -- respawn
        player:LoadCharacter()

        task.wait(delayTime)
    end
end

-- Tombol
startBtn.MouseButton1Click:Connect(function()
    if not running then
        running = true
        status.Text = "Status: ✅ ON"
        status.TextColor3 = Color3.fromRGB(50, 255, 100)
        task.spawn(doSummit)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
    status.Text = "Status: ❌ OFF"
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
end)

plusBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime + 0.1, minDelay, maxDelay)
    delayLbl.Text = "⏱ Delay: "..string.format("%.1f",delayTime).."s"
end)

minusBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime - 0.1, minDelay, maxDelay)
    delayLbl.Text = "⏱ Delay: "..string.format("%.1f",delayTime).."s"
end)
