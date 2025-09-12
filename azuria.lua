-- Auto Summit Loop Noclip
-- by yars

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local HRP = LP.Character:WaitForChild("HumanoidRootPart")

-- Tujuan summit
local summitCFrame = CFrame.new(
    -3449.98486, 768.397278, -233.195923,
    -0.990029633, 1.972348266e-10, -0.140859351,
    -1.54502647e-10, 1, 2.48614684e-09,
    0.140859351, 2.48312215e-09, -0.990029633
)

-- Variabel kontrol
local running = false
local delayTime = 1 -- default 1 detik per step (bisa 0.1 - 10)

-- Fungsi reset
local function resetSummit()
    RS:WaitForChild("ResetToCheckpointEvent"):FireServer()
end

-- Auto summit loop
local function autoSummit()
    running = true
    local target = summitCFrame.Position

    -- loop sampai dihentikan
    while running do
        -- noclip
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end

        -- geser ke target
        local pos = HRP.Position
        if (pos - target).Magnitude > 5 then
            local step = (target - pos).Unit * 5
            HRP.CFrame = CFrame.new(pos + step, target)
        else
            HRP.CFrame = summitCFrame
        end

        task.wait(delayTime)
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local startBtn = Instance.new("TextButton", ScreenGui)
startBtn.Size = UDim2.new(0, 150, 0, 40)
startBtn.Position = UDim2.new(0, 50, 0, 200)
startBtn.Text = "▶ Start Summit"
startBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

local stopBtn = Instance.new("TextButton", ScreenGui)
stopBtn.Size = UDim2.new(0, 150, 0, 40)
stopBtn.Position = UDim2.new(0, 50, 0, 250)
stopBtn.Text = "■ Stop Summit"
stopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

local resetBtn = Instance.new("TextButton", ScreenGui)
resetBtn.Size = UDim2.new(0, 150, 0, 40)
resetBtn.Position = UDim2.new(0, 50, 0, 300)
resetBtn.Text = "↺ Reset Summit"
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)

-- Slider speed
local slider = Instance.new("TextButton", ScreenGui)
slider.Size = UDim2.new(0, 150, 0, 40)
slider.Position = UDim2.new(0, 50, 0, 350)
slider.Text = "Speed Delay: " .. delayTime .. "s"
slider.BackgroundColor3 = Color3.fromRGB(200, 200, 50)

slider.MouseButton1Click:Connect(function()
    delayTime = delayTime + 0.5
    if delayTime > 10 then
        delayTime = 0.1
    end
    slider.Text = "Speed Delay: " .. delayTime .. "s"
end)

-- Tombol aksi
startBtn.MouseButton1Click:Connect(function()
    if not running then
        task.spawn(autoSummit)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
end)

resetBtn.MouseButton1Click:Connect(resetSummit)
