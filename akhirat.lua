-- YARS Summit Auto Script - FINAL SMART TOUCH
-- Auto Summit Loop (cek checkpoint tercatat) + Manual Teleport CP + Reset Summit
-- Dengan metode "Touch Checkpoint" (spawn luar → masuk ke lingkaran hijau)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Koordinat CP & Summit
local checkpoints = {
    -- CP1 (hasil tracking ulang)
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
local loopDelay = 0.5 -- delay antar CP

-- Custom Notification
local function showCustomNotification(title, text, color, duration)
    local sg = Instance.new("ScreenGui", playerGui)
    sg.Name = "YARSNotif"..tick()
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0,280,0,55)
    frame.Position = UDim2.new(1,20,0,20)
    frame.BackgroundColor3 = color or Color3.fromRGB(40,40,45)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1,-20,0,20)
    titleLbl.Position = UDim2.new(0,10,0,5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = Color3.new(1,1,1)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local txtLbl = Instance.new("TextLabel", frame)
    txtLbl.Size = UDim2.new(1,-20,0,25)
    txtLbl.Position = UDim2.new(0,10,0,25)
    txtLbl.BackgroundTransparency = 1
    txtLbl.Text = text
    txtLbl.Font = Enum.Font.Gotham
    txtLbl.TextSize = 12
    txtLbl.TextColor3 = Color3.fromRGB(220,220,220)
    txtLbl.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(frame,TweenInfo.new(0.3,Enum.EasingStyle.Back),{Position=UDim2.new(1,-300,0,20)}):Play()

    task.spawn(function()
        wait(duration or 2.5)
        TweenService:Create(frame,TweenInfo.new(0.3),{Position=UDim2.new(1,20,0,20)}):Play()
        wait(0.35)
        sg:Destroy()
    end)
end

-- Simulasi sentuh checkpoint hijau
local function touchCheckpoint(cf, name)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        -- step 1: spawn di luar lingkaran (mundur 7 stud di sumbu Z)
        root.CFrame = cf * CFrame.new(0,0,-7)
        task.wait(0.25)
        -- step 2: masuk ke dalam lingkaran (CP asli)
        root.CFrame = cf
        showCustomNotification("📍 Touch", name.." disentuh", Color3.fromRGB(150,255,150), 1.5)
        return true
    end
    return false
end

-- Reset Summit pakai Remote
local function resetSummit()
    pcall(function()
        ReturnToSpawn:FireServer()
        showCustomNotification("🔄 Reset Summit", "ReturnToSpawn Remote!", Color3.fromRGB(255,200,100), 2)
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
                -- tunggu sampai checkpoint tercatat
                repeat
                    touchCheckpoint(cf, (i == #checkpoints) and "Summit" or ("CP"..i))
                    task.wait(loopDelay)
                until cpValue.Value >= i or not autoSummitEnabled
            end

            if autoSummitEnabled then
                task.wait(0.5)
                resetSummit()
                showCustomNotification("✅ Summit", "Putaran selesai → Reset → Ulangi", Color3.fromRGB(100,255,100), 3)
                task.wait(loopDelay)
            end
        end
    end)
end

-- GUI (dipersingkat)
local function createUI()
    if playerGui:FindFirstChild("YARSCompactGUI") then playerGui.YARSCompactGUI:Destroy() end
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "YARSCompactGUI"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,220,0,370)
    frame.Position = UDim2.new(0,20,0.5,-185)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    -- Auto Summit Toggle
    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(1,-20,0,35)
    autoBtn.Position = UDim2.new(0,10,0,40)
    autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
    autoBtn.Text = "⚡ AUTO: OFF"
    autoBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = not autoSummitEnabled
        if autoSummitEnabled then
            autoBtn.Text = "⚡ AUTO: ON"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
            autoSummitLoop()
        else
            autoBtn.Text = "⚡ AUTO: OFF"
            autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
        end
    end)

    -- Reset Summit Button
    local resetBtn = Instance.new("TextButton", frame)
    resetBtn.Size = UDim2.new(1,-20,0,30)
    resetBtn.Position = UDim2.new(0,10,0,80)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255,200,100)
    resetBtn.Text = "🔄 Reset Summit"
    resetBtn.MouseButton1Click:Connect(resetSummit)

    -- Scroll Manual CP
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,0,240)
    scroll.Position = UDim2.new(0,10,0,120)
    scroll.CanvasSize = UDim2.new(0,0,0,#checkpoints*35)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundColor3 = Color3.fromRGB(45,45,50)
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0,6)

    for i, cf in ipairs(checkpoints) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,-10,0,30)
        btn.Position = UDim2.new(0,5,0,(i-1)*35)
        btn.BackgroundColor3 = Color3.fromRGB(200,200,200)
        btn.Text = (i == #checkpoints) and "🏔️ Summit" or ("📍 CP"..i)
        btn.MouseButton1Click:Connect(function()
            touchCheckpoint(cf, btn.Text)
        end)
    end
end

-- Start
showCustomNotification("YARS Ready","Summit Auto (Smart Touch) Loaded!",Color3.fromRGB(100,200,255),3)
createUI()
