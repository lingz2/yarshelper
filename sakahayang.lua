--// AUTO SUMMIT HARD MODE + INVISIBLE TOGGLE (Delta Executor Mobile Ready)
--// Dibuat oleh Yars

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote & Argumen Hard
local RF_GetLevel = ReplicatedStorage:WaitForChild("LevelService"):WaitForChild("RF_GetLevel")
local HardID = 9349848927

-- CFrame Summit
local summitCF = CFrame.new(
    -910.277771, 3142.12842, 562.343323,
    0.921977043, -4.37947945e-09, 0.387244552,
    7.41064721e-09, 1, -6.33441255e-09,
    -0.387244552, 8.70991546e-09, 0.921977043
)

-- Variabel
local running = false
local delayTime = 1
local minDelay, maxDelay = 0.1, 5
local invisible = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🏔️ Auto Summit Hard"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local status = Instance.new("TextLabel", Frame)
status.Position = UDim2.new(0, 0, 0, 30)
status.Size = UDim2.new(1, 0, 0, 25)
status.Text = "Status: ❌ OFF"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14

-- Tombol Start
local startBtn = Instance.new("TextButton", Frame)
startBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
startBtn.Size = UDim2.new(0.4, 0, 0.18, 0)
startBtn.Text = "▶️ Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)

-- Tombol Stop
local stopBtn = Instance.new("TextButton", Frame)
stopBtn.Position = UDim2.new(0.55, 0, 0.28, 0)
stopBtn.Size = UDim2.new(0.4, 0, 0.18, 0)
stopBtn.Text = "⏹ Stop"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 8)

-- Tombol Invisible
local invisBtn = Instance.new("TextButton", Frame)
invisBtn.Position = UDim2.new(0.05,0,0.5,0)
invisBtn.Size = UDim2.new(0.9,0,0.18,0)
invisBtn.Text = "👻 Invisible: OFF"
invisBtn.Font = Enum.Font.GothamBold
invisBtn.TextSize = 14
invisBtn.TextColor3 = Color3.new(1,1,1)
invisBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
Instance.new("UICorner", invisBtn).CornerRadius = UDim.new(0, 8)

-- Label Delay
local delayLbl = Instance.new("TextLabel", Frame)
delayLbl.Position = UDim2.new(0,0,0.73,0)
delayLbl.Size = UDim2.new(1,0,0,25)
delayLbl.Text = "⏱ Delay: "..delayTime.."s"
delayLbl.TextColor3 = Color3.fromRGB(200,200,200)
delayLbl.Font = Enum.Font.Gotham
delayLbl.BackgroundTransparency = 1
delayLbl.TextSize = 14

-- Tombol Minus
local minusBtn = Instance.new("TextButton", Frame)
minusBtn.Position = UDim2.new(0.15,0,0.87,0)
minusBtn.Size = UDim2.new(0.3,0,0.12,0)
minusBtn.Text = "-"
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 18
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", minusBtn)

-- Tombol Plus
local plusBtn = Instance.new("TextButton", Frame)
plusBtn.Position = UDim2.new(0.55,0,0.87,0)
plusBtn.Size = UDim2.new(0.3,0,0.12,0)
plusBtn.Text = "+"
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 18
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Instance.new("UICorner", plusBtn)

-- Fungsi Summit
local function doSummit()
    while running do
        pcall(function()
            RF_GetLevel:InvokeServer(HardID)
        end)

        task.wait(0.3)

        local char = player.Character or player.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = summitCF
        end

        task.wait(delayTime)

        player:LoadCharacter()
        task.wait(delayTime)
    end
end

-- Fungsi Invisible
local function applyInvisible(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
            if v:FindFirstChildOfClass("Decal") then
                v:FindFirstChildOfClass("Decal").Transparency = 1
            end
        elseif v:IsA("Accessory") then
            v:Destroy()
        end
    end
end

local function setInvisible(state)
    invisible = state
    if state then
        invisBtn.Text = "👻 Invisible: ON"
        invisBtn.BackgroundColor3 = Color3.fromRGB(50,200,255)
        applyInvisible(player.Character)
    else
        invisBtn.Text = "👻 Invisible: OFF"
        invisBtn.BackgroundColor3 = Color3.fromRGB(100,100,255)
        player:LoadCharacter()
    end
end

player.CharacterAdded:Connect(function(char)
    if invisible then
        task.wait(0.5)
        applyInvisible(char)
    end
end)

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

invisBtn.MouseButton1Click:Connect(function()
    setInvisible(not invisible)
end)
