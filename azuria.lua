-- Auto Summit Loop (Fly to Summit + Reset)
-- by yars ganteng

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- Koordinat summit
local summitCFrame = CFrame.new(
    -3449.98486, 768.397278, -233.195923,
    -0.990029633, 1.972348266e-10, -0.140859351,
    -1.54502647e-10, 1, 2.48614684e-09,
    0.140859351, 2.48312215e-09, -0.990029633
)

-- Variabel kontrol
local flyDuration = 5 -- lama terbang
local loopDelay = 3   -- delay antar loop
local running = false
local flyingTween

-- Cari HRP terbaru
local function getHRP()
    local char = LP.Character or LP.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Reset ke checkpoint
local function resetSummit()
    local ev = RS:FindFirstChild("ResetToCheckpointEvent")
    if ev and ev.FireServer then
        ev:FireServer()
    end
end

-- Fungsi terbang
local function flyOnce(callback)
    if flyingTween then flyingTween:Cancel() end
    local HRP = getHRP()
    local goal = {CFrame = summitCFrame}
    local info = TweenInfo.new(flyDuration, Enum.EasingStyle.Linear)
    flyingTween = TweenService:Create(HRP, info, goal)
    flyingTween:Play()
    flyingTween.Completed:Wait()
    if callback then callback() end
end

-- Loop auto summit
local function autoSummitLoop()
    running = true
    while running do
        flyOnce(function()
            if not running then return end
            task.wait(1) -- pause di summit
            resetSummit()
            task.wait(loopDelay) -- jeda antar loop
        end)
    end
end

-- Stop loop
local function stopFlying()
    running = false
    if flyingTween then
        flyingTween:Cancel()
        flyingTween = nil
    end
end

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local startBtn = Instance.new("TextButton", gui)
startBtn.Size = UDim2.new(0, 150, 0, 40)
startBtn.Position = UDim2.new(0, 50, 0, 200)
startBtn.Text = "▶ Start Loop"
startBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

local stopBtn = Instance.new("TextButton", gui)
stopBtn.Size = UDim2.new(0, 150, 0, 40)
stopBtn.Position = UDim2.new(0, 50, 0, 250)
stopBtn.Text = "■ Stop"
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

local flyBtn = Instance.new("TextButton", gui)
flyBtn.Size = UDim2.new(0, 150, 0, 40)
flyBtn.Position = UDim2.new(0, 50, 0, 300)
flyBtn.Text = "Durasi: " .. flyDuration .. "s"
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)

local delayBtn = Instance.new("TextButton", gui)
delayBtn.Size = UDim2.new(0, 150, 0, 40)
delayBtn.Position = UDim2.new(0, 50, 0, 350)
delayBtn.Text = "Delay: " .. loopDelay .. "s"
delayBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 200)

-- Aksi tombol
startBtn.MouseButton1Click:Connect(function()
    if not running then
        task.spawn(autoSummitLoop)
    end
end)

stopBtn.MouseButton1Click:Connect(stopFlying)

flyBtn.MouseButton1Click:Connect(function()
    flyDuration = flyDuration + 1
    if flyDuration > 10 then
        flyDuration = 0.1
    end
    flyBtn.Text = "Durasi: " .. flyDuration .. "s"
end)

delayBtn.MouseButton1Click:Connect(function()
    loopDelay = loopDelay + 1
    if loopDelay > 20 then
        loopDelay = 1
    end
    delayBtn.Text = "Delay: " .. loopDelay .. "s"
end)
