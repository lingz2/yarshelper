-- 🔥 Gunung Batu Auto Summit (CP2–10 wajib tercatat, Summit spam sampai naik)
-- Delta Executor Ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Data CP
local cps = {
    cp2  = CFrame.new(-121.60952, 8.50454998, 544.049377),
    cp3  = CFrame.new(-40.0167122, 392.432037, 673.959045),
    cp4  = CFrame.new(-296.999634, 484.432037, 779.003052),
    cp5  = CFrame.new(18.0000038, 572.429688, 692),
    cp6  = CFrame.new(595.273804, 916.432007, 620.967712),
    cp7  = CFrame.new(283.5, 1196.43201, 181.5),
    cp8  = CFrame.new(552.105835, 1528.43201, -581.302246),
    cp9  = CFrame.new(332.142334, 1736.43201, -260.883789),
    cp10 = CFrame.new(290.354126, 1979.03186, -203.905533),
    cp11 = CFrame.new(616.488281, 3260.50879, -66.2258759),
    puncak = CFrame.new(
        408.080811, 3261.43188, -110.906059,
        0.664278328, 3.246494276e-08, 0.74748534,
        3.87810708e-08, 1, -7.789633836e-08,
        -0.74748534, 8.073312336e-08, 0.664278328
    )
}

-- Remote
local SendSummit = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SendSummit")

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AutoSummitGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Active, frame.Draggable = true, true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "⛰️ Auto Summit"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- tombol start/stop
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9,0,0,32)
toggleBtn.Position = UDim2.new(0.05,0,0,40)
toggleBtn.Text = "▶️ Start Auto Summit"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,120,60)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,6)

-- slider/textbox cpDelay
local cpLabel = Instance.new("TextLabel", frame)
cpLabel.Position = UDim2.new(0.05,0,0,80)
cpLabel.Size = UDim2.new(0.9,0,0,24)
cpLabel.BackgroundTransparency = 1
cpLabel.TextColor3 = Color3.new(1,1,1)
cpLabel.TextXAlignment = Enum.TextXAlignment.Left
cpLabel.Font = Enum.Font.GothamSemibold
cpLabel.TextSize = 14

local cpBox = Instance.new("TextBox", frame)
cpBox.Size = UDim2.new(0.3,0,0,24)
cpBox.Position = UDim2.new(0.65,0,0,80)
cpBox.BackgroundColor3 = Color3.fromRGB(50,50,60)
cpBox.TextColor3 = Color3.new(1,1,1)
cpBox.Text = "0.5"
cpBox.Font = Enum.Font.GothamSemibold
cpBox.TextSize = 14
Instance.new("UICorner", cpBox).CornerRadius = UDim.new(0,6)

-- slider/textbox summitDelay
local smLabel = Instance.new("TextLabel", frame)
smLabel.Position = UDim2.new(0.05,0,0,110)
smLabel.Size = UDim2.new(0.9,0,0,24)
smLabel.BackgroundTransparency = 1
smLabel.TextColor3 = Color3.new(1,1,1)
smLabel.TextXAlignment = Enum.TextXAlignment.Left
smLabel.Font = Enum.Font.GothamSemibold
smLabel.TextSize = 14

local smBox = Instance.new("TextBox", frame)
smBox.Size = UDim2.new(0.3,0,0,24)
smBox.Position = UDim2.new(0.65,0,0,110)
smBox.BackgroundColor3 = Color3.fromRGB(50,50,60)
smBox.TextColor3 = Color3.new(1,1,1)
smBox.Text = "0.6"
smBox.Font = Enum.Font.GothamSemibold
smBox.TextSize = 14
Instance.new("UICorner", smBox).CornerRadius = UDim.new(0,6)

-- default delay
local cpDelay, summitDelay = 0.5, 0.6
local running = false

local function tp(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = cf
end

-- fungsi tunggu stage berubah
local function waitStage(target)
    local ls = player:WaitForChild("leaderstats")
    local stage = ls:WaitForChild("Stage")
    while tonumber(stage.Value) < target do
        task.wait(0.1)
    end
end

-- fungsi spam summit sampai bertambah
local function sendSummitUntilIncrease()
    local ls = player:WaitForChild("leaderstats")
    local summitVal = ls:WaitForChild("Summit")
    local before = summitVal.Value

    repeat
        SendSummit:FireServer(1)
        task.wait(summitDelay)
    until summitVal.Value > before
end

-- auto loop
local function autoSummitLoop()
    while running do
        for i=2,10 do
            if not running then return end
            tp(cps["cp"..i])
            waitStage(i)
            task.wait(cpDelay)
        end
        if not running then return end
        tp(cps.cp11)
        task.wait(cpDelay)

        tp(cps.puncak)
        task.wait(0.2)
        sendSummitUntilIncrease()
        task.wait(cpDelay)
    end
end

-- update label
local function updateLabels()
    cpLabel.Text = "Delay CP (0.1-1): "..cpDelay.."s"
    smLabel.Text = "Delay Summit (0.1-1): "..summitDelay.."s"
end
updateLabels()

-- textBox handler
cpBox.FocusLost:Connect(function()
    local v = tonumber(cpBox.Text)
    if v and v >= 0.1 and v <= 1 then cpDelay = v end
    cpBox.Text = tostring(cpDelay)
    updateLabels()
end)

smBox.FocusLost:Connect(function()
    local v = tonumber(smBox.Text)
    if v and v >= 0.1 and v <= 1 then summitDelay = v end
    smBox.Text = tostring(summitDelay)
    updateLabels()
end)

-- tombol start/stop
toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    toggleBtn.Text = running and "⏹️ Stop Auto Summit" or "▶️ Start Auto Summit"
    toggleBtn.BackgroundColor3 = running and Color3.fromRGB(160,80,80) or Color3.fromRGB(60,120,60)
    if running then
        task.spawn(autoSummitLoop)
    end
end)

-- toggle [M]
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
