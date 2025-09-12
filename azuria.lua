-- Auto Summit Terbang Loop (Tween)
-- by yars

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local HRP = LP.Character:WaitForChild("HumanoidRootPart")

-- Tujuan (puncak)
local summitCFrame = CFrame.new(
    -3449.98486, 768.397278, -233.195923,
    -0.990029633, 1.972348266e-10, -0.140859351,
    -1.54502647e-10, 1, 2.48614684e-09,
    0.140859351, 2.48312215e-09, -0.990029633
)

-- Variabel kontrol
local duration = 5 -- default durasi terbang (detik)
local running = false
local flyingTween

-- Fungsi reset checkpoint
local function resetSummit()
    local ev = RS:FindFirstChild("ResetToCheckpointEvent")
    if ev and ev.FireServer then
        ev:FireServer()
    end
end

-- Fungsi terbang sekali
local function flyOnce(callback)
    if flyingTween then flyingTween:Cancel() end
    local goal = {CFrame = summitCFrame}
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
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
            task.wait(1) -- jeda di puncak
            resetSummit()
            task.wait(2) -- jeda setelah reset
        end)
    end
end

-- Fungsi stop
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

local resetBtn = Instance.new("TextButton", gui)
resetBtn.Size = UDim2.new(0, 150, 0, 40)
resetBtn.Position = UDim2.new(0, 50, 0, 300)
resetBtn.Text = "↺ Reset Sekali"
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)

local speedBtn = Instance.new("TextButton", gui)
speedBtn.Size = UDim2.new(0, 150, 0, 40)
speedBtn.Position = UDim2.new(0, 50, 0, 350)
speedBtn.Text = "Durasi: " .. duration .. "s"
speedBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)

-- Aksi tombol
startBtn.MouseButton1Click:Connect(function()
    if not running then
        task.spawn(autoSummitLoop)
    end
end)

stopBtn.MouseButton1Click:Connect(stopFlying)
resetBtn.MouseButton1Click:Connect(resetSummit)

speedBtn.MouseButton1Click:Connect(function()
    duration = duration + 1
    if duration > 10 then
        duration = 0.1
    end
    speedBtn.Text = "Durasi: " .. duration .. "s"
end)
