-- YARS Summit Auto Script - FINAL SMART TOUCH + OFFSET SLIDER
-- Auto Summit Loop (cek checkpoint tercatat) + Manual Teleport CP + Reset Summit
-- Metode "Touch Checkpoint" (spawn di luar → masuk lingkaran hijau)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Data Checkpoints (CP1 hasil tracking ulang)
local checkpoints = {
    CFrame.new(-134.886337, 419.735596, -220.92305), -- CP1
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

-- Remote Reset Summit
local ReturnToSpawn = ReplicatedStorage:WaitForChild("ReturnToSpawn")

-- Vars
local autoSummitEnabled = false
local loopDelay = 0.5 -- delay antar CP
local offsetStud = 7   -- default offset spawn sebelum masuk CP

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
        root.CFrame = cf * CFrame.new(0,0,-offsetStud) -- spawn luar
        task.wait(0.25)
        root.CFrame = cf -- masuk dalam lingkaran
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

-- Auto Summit Loop
local function autoSummitLoop()
    task.spawn(function()
        local leaderstats = player:WaitForChild("leaderstats")
        local cpValue = leaderstats:WaitForChild("Checkpoint")

        while autoSummitEnabled do
            for i, cf in ipairs(checkpoints) do
                if not autoSummitEnabled then break end
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

-- UI
local function createUI()
    if playerGui:FindFirstChild("YARSCompactGUI") then playerGui.YARSCompactGUI:Destroy() end
    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "YARSCompactGUI"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,220,0,420)
    frame.Position = UDim2.new(0,20,0.5,-210)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    -- Auto Summit
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

    -- Reset Summit
    local resetBtn = Instance.new("TextButton", frame)
    resetBtn.Size = UDim2.new(1,-20,0,30)
    resetBtn.Position = UDim2.new(0,10,0,80)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255,200,100)
    resetBtn.Text = "🔄 Reset Summit"
    resetBtn.MouseButton1Click:Connect(resetSummit)

    -- Offset Slider
    local sliderLbl = Instance.new("TextLabel", frame)
    sliderLbl.Size = UDim2.new(1,-20,0,20)
    sliderLbl.Position = UDim2.new(0,10,0,115)
    sliderLbl.BackgroundTransparency = 1
    sliderLbl.Text = "Offset: "..offsetStud.." stud"
    sliderLbl.Font = Enum.Font.Gotham
    sliderLbl.TextSize = 12
    sliderLbl.TextColor3 = Color3.fromRGB(220,220,220)

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1,-20,0,20)
    slider.Position = UDim2.new(0,10,0,140)
    slider.BackgroundColor3 = Color3.fromRGB(60,60,70)
    slider.Text = ""

    local handle = Instance.new("Frame", slider)
    handle.Size = UDim2.new(0,20,1,0)
    handle.BackgroundColor3 = Color3.fromRGB(120,200,255)
    Instance.new("UICorner", handle).CornerRadius = UDim.new(0,4)

    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((input.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X,0,1)
            handle.Position = UDim2.new(relX, -10, 0, 0)
            offsetStud = math.floor(3 + (12*relX)) -- 3–15 stud
            sliderLbl.Text = "Offset: "..offsetStud.." stud"
        end
    end)

    -- Scroll Manual CP
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,0,220)
    scroll.Position = UDim2.new(0,10,0,170)
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
