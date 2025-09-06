-- YARS AUTO SUMMIT GUI (FINAL + MODE RESPAWN)
-- CP1-5 -> Summit -> Respawn (Mati/Load) -> Basecamp -> Loop

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
    -- Summit BARU
    CFrame.new(-706.752991, 899.102783, -509.533905, -0.809278965, 0.586797476, -0.027134439, -0.0784856081, -0.0622340403, 0.994970798, 0.582157671, 0.807338655, 0.096419856)
}

-- GUI utama
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "YARS_SUMMIT_GUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 520)
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

-- Info Panel
local InfoBox = Instance.new("TextLabel", Frame)
InfoBox.Size = UDim2.new(1, -20, 0, 60)
InfoBox.Position = UDim2.new(0, 10, 0, 45 + (#checkpoints)*35)
InfoBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
InfoBox.TextColor3 = Color3.fromRGB(0,255,0)
InfoBox.Text = "ℹ️ Ready."
InfoBox.TextWrapped = true
InfoBox.Font = Enum.Font.SourceSansBold
InfoBox.TextSize = 14

-- Summit Counter
local SummitCount = 0
local CountLabel = Instance.new("TextLabel", Frame)
CountLabel.Size = UDim2.new(1, -20, 0, 30)
CountLabel.Position = UDim2.new(0, 10, 0, 120 + (#checkpoints)*35)
CountLabel.BackgroundColor3 = Color3.fromRGB(35,35,35)
CountLabel.TextColor3 = Color3.fromRGB(255,255,0)
CountLabel.Text = "Summit Count: 0"
CountLabel.Font = Enum.Font.SourceSansBold
CountLabel.TextSize = 16

-- Toast Notification
local function showToast(msg, color)
    local Toast = Instance.new("TextLabel", ScreenGui)
    Toast.Size = UDim2.new(0, 250, 0, 30)
    Toast.Position = UDim2.new(1, -260, 0, 40)
    Toast.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Toast.TextColor3 = color or Color3.fromRGB(255,255,255)
    Toast.Text = msg
    Toast.Font = Enum.Font.SourceSansBold
    Toast.TextSize = 16
    Toast.BackgroundTransparency = 0.1
    Toast.BorderSizePixel = 0

    spawn(function()
        wait(2.5)
        for i = 1, 10 do
            Toast.TextTransparency = i/10
            Toast.BackgroundTransparency = 0.1 + (i/10)
            wait(0.1)
        end
        Toast:Destroy()
    end)
end

-- Tombol CP
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
        InfoBox.Text = "✅ Teleport ke "..btn.Text.." berhasil!"
        showToast("✅ "..btn.Text.." berhasil!", Color3.fromRGB(0,255,0))
    end)
end

-- Variabel Loop
local loopRunning = false
local delayTime = 0.5
local loopCount = 0
local respawnMode = "Mati" -- Default: Respawn Mati

-- Tombol Auto Summit
local AutoBtn = Instance.new("TextButton", Frame)
AutoBtn.Size = UDim2.new(1, -20, 0, 40)
AutoBtn.Position = UDim2.new(0, 10, 0, 160 + (#checkpoints)*35)
AutoBtn.Text = "▶️ Start Auto Summit"
AutoBtn.BackgroundColor3 = Color3.fromRGB(80,20,20)
AutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 18

-- Pilihan Mode Respawn
local RespawnBtn = Instance.new("TextButton", Frame)
RespawnBtn.Size = UDim2.new(1, -20, 0, 30)
RespawnBtn.Position = UDim2.new(0, 10, 1, -100)
RespawnBtn.Text = "Mode Respawn: 🔴 Mati"
RespawnBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
RespawnBtn.TextColor3 = Color3.fromRGB(255,255,255)
RespawnBtn.Font = Enum.Font.SourceSansBold
RespawnBtn.TextSize = 14

RespawnBtn.MouseButton1Click:Connect(function()
    if respawnMode == "Mati" then
        respawnMode = "Load"
        RespawnBtn.Text = "Mode Respawn: 🟡 Load"
        showToast("Respawn Mode = LoadCharacter()", Color3.fromRGB(255,255,0))
    else
        respawnMode = "Mati"
        RespawnBtn.Text = "Mode Respawn: 🔴 Mati"
        showToast("Respawn Mode = Mati", Color3.fromRGB(255,100,100))
    end
end)

-- Delay Control
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
    showToast("⏳ Delay set ke "..string.format("%.1f", delayTime).."s", Color3.fromRGB(255,255,0))
end)

-- Fungsi Auto Summit
local function AutoSummit()
    loopRunning = true
    loopCount = 0
    AutoBtn.Text = "⏹ Stop Auto Summit"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(20,80,20)
    showToast("▶️ Auto Summit dimulai!", Color3.fromRGB(0,200,255))

    while loopRunning do
        loopCount += 1
        InfoBox.Text = "🔄 Loop ke-"..loopCount.." dimulai..."
        showToast("🔄 Loop ke-"..loopCount.." dimulai", Color3.fromRGB(0,200,255))

        -- Teleport semua CP sampai Summit
        for i = 1, #checkpoints do
            local char = player.Character or player.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart").CFrame = checkpoints[i]
            if i < #checkpoints then
                InfoBox.Text = "✅ Teleport ke CP"..i.." berhasil!"
                showToast("✅ CP"..i.." sukses", Color3.fromRGB(0,255,0))
            else
                SummitCount += 1
                CountLabel.Text = "Summit Count: "..SummitCount
                InfoBox.Text = "🏔️ Summit berhasil! Total: "..SummitCount
                showToast("🏔️ Summit #"..SummitCount.."!", Color3.fromRGB(255,200,0))
            end
            task.wait(delayTime)
        end

        -- Respawn sesuai mode
        if respawnMode == "Mati" then
            InfoBox.Text = "💀 Respawn (Mati)..."
            showToast("💀 Respawn: Mati", Color3.fromRGB(200,100,100))
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.Health = 0 end
            task.wait(5)
        else
            InfoBox.Text = "♻️ Respawn (LoadCharacter)..."
            showToast("♻️ Respawn: LoadCharacter", Color3.fromRGB(200,200,200))
            player:LoadCharacter()
            task.wait(3)
        end

        InfoBox.Text = "🔁 Siap loop berikutnya..."
    end
end

AutoBtn.MouseButton1Click:Connect(function()
    if loopRunning then
        loopRunning = false
        AutoBtn.Text = "▶️ Start Auto Summit"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(80,20,20)
        InfoBox.Text = "⏹ Auto Summit dihentikan."
        showToast("⏹ Auto Summit berhenti", Color3.fromRGB(255,0,0))
    else
        AutoSummit()
    end
end)
