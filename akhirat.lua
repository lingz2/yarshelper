-- YARS Summit Auto Script - FINAL + CP CONTROL + SMART AUTO
-- Auto Summit per Checkpoint (cek leaderstats) + Manual Teleport CP
-- Delay control 0.1s - 1.0s

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Koordinat CP & Summit
local checkpoints = {
    -- CP1 Diperbarui:
    CFrame.new(-134.886337, 419.735596, -220.92305),

    CFrame.new(3.00000501, 948.160339, -1054.29395),
    CFrame.new(108.989052, 1200.19873, -1359.28259),
    CFrame.new(102.756409, 1463.6759, -1807.98047),
    CFrame.new(299.767181, 1863.83423, -2331.90723),
    CFrame.new(560.049927, 2083.41382, -2560.3584),
    CFrame.new(754.672485, 2184.43188, -2500.25903),
    CFrame.new(793, 2328.43188, -2641.29492),
    CFrame.new(969, 2516.43188, -2632.29443),
    CFrame.new(1239, 2692.23193, -2803.29468),
    CFrame.new(1621.73401, 3056.23193, -2752.29712),
    CFrame.new(1812.91406, 3576.43188, -3246.64526),
    CFrame.new(2809.92578, 4418.99805, -4792.25928),
    CFrame.new(3470, 4856.23193, -4178.29346),
    CFrame.new(3477.91699, 5102.79199, -4273.47607),
    CFrame.new(3974.8938, 5664.43164, -3970.72803),
    CFrame.new(4497.52051, 5896.43164, -3786.26978),
    CFrame.new(5062.7915, 6368.43164, -2973.97192),
    CFrame.new(5537.99805, 6588.43164, -2484.27026),
    CFrame.new(5548.54932, 6870.99072, -1047.39441),
    CFrame.new(4328.27344, 7638.65674, 131.682388),
    CFrame.new(3456.18457, 7708.39209, 937.936584),
    CFrame.new(3041.74048, 7876.99756, 1037.59253) -- Summit
}

local BASECAMP_POS = CFrame.new(-243.999069, 120.998016, 202.997528)

-- Remote Reset Summit
local ReturnToSpawn = ReplicatedStorage:WaitForChild("ReturnToSpawn")

-- Vars
local autoSummitEnabled = false
local loopDelay = 0.3
local isMinimized = false

-- Custom Notification
local function showCustomNotification(title, text, color, duration)
    local notification = Instance.new("ScreenGui")
    notification.Name = "YARSCustomNotification"
    notification.Parent = CoreGui
    notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = color or Color3.fromRGB(30,30,35)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(1, -20, 0, 30)
    textLabel.Position = UDim2.new(0, 10, 0, 25)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(220,220,220)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    
    frame.Position = UDim2.new(1, 20, 0, 20)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(1, -320, 0, 20)}):Play()
    
    task.spawn(function()
        wait(duration or 3)
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 20)}):Play()
        wait(0.35)
        notification:Destroy()
    end)
end

-- Notification bawaan
local function showNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 3;
        })
    end)
end

-- Teleport
local function teleportTo(cf, name)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
        showNotification("Teleport", "Ke "..name)
        return true
    end
    return false
end

-- Reset Summit pakai Remote
local function resetSummit()
    pcall(function()
        ReturnToSpawn:FireServer()
        showCustomNotification("🔄 Reset Summit", "ReturnToSpawn Remote Fired!", Color3.fromRGB(100,255,100), 2)
    end)
end

-- Auto Summit Loop (cek checkpoint naik)
local function autoSummitLoop()
    task.spawn(function()
        local leaderstats = player:WaitForChild("leaderstats")
        local cpValue = leaderstats:WaitForChild("Checkpoint")

        while autoSummitEnabled do
            for i, cf in ipairs(checkpoints) do
                if not autoSummitEnabled then break end

                repeat
                    teleportTo(cf, (i == #checkpoints) and "Summit" or ("CP"..i))
                    wait(loopDelay)
                until cpValue.Value >= i or not autoSummitEnabled
            end

            if autoSummitEnabled then
                wait(0.2)
                resetSummit()
                showCustomNotification("✅ Summit", "Satu putaran selesai!", Color3.fromRGB(100,255,100), 3)
                wait(loopDelay)
            end
        end
    end)
end

-- UI
local function createUI()
    if playerGui:FindFirstChild("YARSCompactGUI") then
        playerGui.YARSCompactGUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "YARSCompactGUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,220,0,330)
    frame.Position = UDim2.new(0,20,0.5,-165)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    
    -- Header
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1,0,0,30)
    header.BackgroundColor3 = Color3.fromRGB(45,45,50)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,8)
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1,-60,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.BackgroundTransparency = 1
    title.Text = "YARS Summit Auto"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close
    local close = Instance.new("TextButton", header)
    close.Size = UDim2.new(0,25,0,25)
    close.Position = UDim2.new(1,-30,0,2.5)
    close.BackgroundColor3 = Color3.fromRGB(255,100,100)
    close.Text = "✕"
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 12
    close.MouseButton1Click:Connect(function()
        autoSummitEnabled = false
        gui:Destroy()
        showNotification("YARS", "Script Closed")
    end)
    
    -- Tombol Basecamp
    local baseBtn = Instance.new("TextButton", frame)
    baseBtn.Size = UDim2.new(1,-20,0,30)
    baseBtn.Position = UDim2.new(0,10,0,40)
    baseBtn.BackgroundColor3 = Color3.fromRGB(150,150,255)
    baseBtn.Text = "🏠 Basecamp"
    baseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    baseBtn.MouseButton1Click:Connect(function()
        teleportTo(BASECAMP_POS, "Basecamp")
    end)
    
    -- Auto Summit Toggle
    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(1,-20,0,35)
    autoBtn.Position = UDim2.new(0,10,0,80)
    autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
    autoBtn.Text = "⚡ AUTO: OFF"
    autoBtn.TextColor3 = Color3.fromRGB(0,0,0)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 12
    autoBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = not autoSummitEnabled
        if autoSummitEnabled then
            autoBtn.Text = "⚡ AUTO: ON"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
            autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
            autoSummitLoop()
        else
            autoBtn.Text = "⚡ AUTO: OFF"
            autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
            autoBtn.TextColor3 = Color3.fromRGB(0,0,0)
        end
    end)
    
    -- Speed Control
    local speedLabel = Instance.new("TextLabel", frame)
    speedLabel.Size = UDim2.new(1,-20,0,20)
    speedLabel.Position = UDim2.new(0,10,0,125)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
    speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    
    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0.5,-15,0,25)
    plusBtn.Position = UDim2.new(0,10,0,150)
    plusBtn.BackgroundColor3 = Color3.fromRGB(100,200,255)
    plusBtn.Text = "+ Delay"
    plusBtn.TextColor3 = Color3.fromRGB(0,0,0)
    plusBtn.MouseButton1Click:Connect(function()
        if loopDelay < 1.0 then
            loopDelay = math.floor((loopDelay + 0.1)*10)/10
            speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
        end
    end)
    
    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0.5,-15,0,25)
    minusBtn.Position = UDim2.new(0.5,5,0,150)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255,150,150)
    minusBtn.Text = "- Delay"
    minusBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minusBtn.MouseButton1Click:Connect(function()
        if loopDelay > 0.1 then
            loopDelay = math.floor((loopDelay - 0.1)*10)/10
            speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
        end
    end)
    
    -- ScrollFrame untuk tombol CP
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,0,140)
    scroll.Position = UDim2.new(0,10,0,185)
    scroll.CanvasSize = UDim2.new(0,0,0,#checkpoints * 35)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundColor3 = Color3.fromRGB(45,45,50)
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0,6)
    
    for i, cf in ipairs(checkpoints) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,-10,0,30)
        btn.Position = UDim2.new(0,5,0,(i-1)*35)
        btn.BackgroundColor3 = Color3.fromRGB(200,200,200)
        btn.Text = (i == #checkpoints) and "🏔️ Summit" or ("📍 CP"..i)
        btn.TextColor3 = Color3.fromRGB(0,0,0)
        btn.MouseButton1Click:Connect(function()
            teleportTo(cf, (i == #checkpoints) and "Summit" or "CP"..i)
        end)
    end
end

-- Start
showNotification("YARS Ready", "Summit Auto Loaded!")
createUI()
