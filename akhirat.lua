-- YARS FINAL SUMMIT SCRIPT
-- Auto Loop CP1-22 + Summit, Teleport dari luar bundaran -> masuk tengah
-- Manual scroll CP buttons + Reset Summit

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote reset
local ReturnToSpawn = ReplicatedStorage:WaitForChild("ReturnToSpawn")

-- Auto config
local loopDelay = 0.3
local autoSummitEnabled = false

local function showNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- Data checkpoint (tengah bundaran, kamu sudah kasih semua)
local cpData = {
    CFrame.new(-134.886337,419.735596,-220.92305,-0.16212301,-1.000955346e-07,0.98677057,-4.42196963e-08,1,9.41723499e-08,-0.98677057,-2.83671913e-08,-0.16212301), -- cp1
    CFrame.new(3.00000501,948.160339,-1054.29395,0.00384849985,-4.131612746e-08,0.999992609,-6.72577585e-08,1,4.15752766e-08,-0.999992609,-6.74172682e-08), -- cp2
    CFrame.new(108.989052,1200.19873,-1359.28259,0.000188985476,-3.548643336e-08,1,1.12774572e-07,1,3.54651206e-08,-1,1.12767864e-07,0.000188985476), -- cp3
    CFrame.new(102.756409,1463.6759,-1807.98047,-0.0636249259,2.355350586e-08,0.997973859,-7.72848594e-08,1,-2.85285522e-08,-0.997973859,-7.89433946e-08,-0.0636249259), -- cp4
    CFrame.new(299.767181,1863.83423,-2331.90723,0.662588239,7.797293486e-08,0.74898386,-1.15960091e-07,1,-1.520912628e-09,-0.74898386,-8.58444977e-08,0.662588239), -- cp5
    CFrame.new(560.049927,2083.41382,-2560.3584,-0.0335851163,-8.911999326e-08,0.999435842,-3.019237976e-09,1,8.90688412e-08,-0.999435842,-2.61471851e-11,-0.0335851163), -- cp6
    CFrame.new(754.672485,2184.43188,-2500.25903,-0.0141575728,4.96246599e-08,0.999899805,6.34378168e-08,1,-4.873141896e-08,-0.999899805,6.27415417e-08,-0.0141575728), -- cp7
    CFrame.new(793,2328.43188,-2641.29492,0.00386172323,-4.14908818e-08,0.999992549,-7.55445271e-08,1,4.178292566e-08,-0.999992549,-7.57053229e-08,0.00386172323), -- cp8
    CFrame.new(969,2516.43188,-2632.29443,0.00384716829,-1.793487676e-08,0.999992609,-5.99104908e-08,1,1.81654976e-08,-0.999992609,-5.997993216e-08,0.00384716829), -- cp9
    CFrame.new(1239,2692.23193,-2803.29468,0.00384851126,9.65163736e-08,0.999992609,7.2669053e-08,1,-9.679675376e-08,-0.999992609,7.304103636e-08,0.00384851126), -- cp10
    CFrame.new(1621.73401,3056.23193,-2752.29712,0.00385404471,7.445918736e-08,0.999992549,2.93347515e-08,1,-7.45727959e-08,-0.999992549,2.96219405e-08,0.00385404471), -- cp11
    CFrame.new(1812.91406,3576.43188,-3246.64526,0.00384842861,-3.335718196e-08,0.999992609,-2.14706404e-08,1,3.344005962e-08,-0.999992609,-2.159917226e-08,0.00384842861), -- cp12
    CFrame.new(2809.92578,4418.99805,-4792.25928,-0.251195997,0.00131308101,0.967935324,0.00142111839,-0.999997497,0.00172538066,0.967935205,0.00180895941,0.251193494), -- cp13
    CFrame.new(3470,4856.23193,-4178.29346,0.00385237299,-4.563311866e-08,0.999992609,-9.19617946e-08,1,4.59877327e-08,-0.999992609,-9.21382721e-08,0.00385237299), -- cp14
    CFrame.new(3477.91699,5102.79199,-4273.47607,-0.0871392116,-0.00649569696,0.996174991,-0.00430737436,-0.999966919,-0.00689720549,0.996186852,-0.00489191571,0.0871083513), -- cp15
    CFrame.new(3974.8938,5664.43164,-3970.72803,0.865141511,-2.262874876e-08,0.501527786,-1.22656318e-09,1,4.723546716e-08,-0.501527786,-4.14805186e-08,0.865141511), -- cp16
    CFrame.new(4497.52051,5896.43164,-3786.26978,0.946825504,-2.536235226e-08,-0.321747541,2.62072786e-09,1,-7.111469812e-08,0.321747541,6.648999576e-08,0.946825504), -- cp17
    CFrame.new(5062.7915,6368.43164,-2973.97192,0.348333001,3.397721446e-09,-0.937370837,-1.21107941e-08,1,-8.75712947e-10,0.937370837,1.16573453e-08,0.348333001), -- cp18
    CFrame.new(5537.99805,6588.43164,-2484.27026,0.91637665,-4.68738476e-09,-0.400317222,-8.55829629e-10,1,-1.36682781e-08,0.400317222,1.28678934e-08,0.91637665), -- cp19
    CFrame.new(5548.54932,6870.99072,-1047.39441,0.493117005,-0.00573010696,0.869944155,-0.00987137947,-0.999950767,-0.000990959816,0.869906962,-0.00809888914,-0.49314931), -- cp20
    CFrame.new(4328.27344,7638.65674,131.682388,0.157138705,0.214573964,0.963984132,0.985838473,0.0238039158,-0.165999711,-0.058565814,0.976417601,-0.207794756), -- cp21
    CFrame.new(3456.18457,7708.39209,937.936584,0.0125137111,5.372164226e-08,0.999921679,4.7604618e-09,1,-5.37854241e-08,-0.999921679,5.4331446e-09,0.0125137111) -- cp22
}
local summit = CFrame.new(3041.74048,7876.99756,1037.59253)

-- Fungsi teleport "pinggir lalu masuk"
local function teleportCheckpoint(cf, name)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local root = char.HumanoidRootPart

    -- pinggir (13 stud ke kanan)
    local pinggir = cf * CFrame.new(13, 0, 0)
    root.CFrame = pinggir
    task.wait(0.2)
    -- lalu masuk ke tengah
    root.CFrame = cf

    showNotification("Teleport", name .. " ✅")
end

-- Reset summit
local function resetSummit()
    pcall(function()
        ReturnToSpawn:FireServer()
        showNotification("Summit Reset", "ReturnToSpawn fired", 2)
    end)
end

-- Auto loop
local function autoSummitLoop()
    task.spawn(function()
        while autoSummitEnabled do
            for i, cf in ipairs(cpData) do
                if not autoSummitEnabled then break end
                teleportCheckpoint(cf, "CP"..i)
                task.wait(loopDelay)
            end
            teleportCheckpoint(summit, "Summit")
            resetSummit()
            task.wait(loopDelay)
        end
    end)
end

-- UI
local function createUI()
    if playerGui:FindFirstChild("YARSFinalGUI") then
        playerGui.YARSFinalGUI:Destroy()
    end

    local gui = Instance.new("ScreenGui", playerGui)
    gui.Name = "YARSFinalGUI"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 220, 0, 300)
    frame.Position = UDim2.new(0, 20, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "YARS Summit Helper"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1

    -- Auto button
    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(1,-20,0,30)
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

    -- Reset button
    local resetBtn = Instance.new("TextButton", frame)
    resetBtn.Size = UDim2.new(1,-20,0,30)
    resetBtn.Position = UDim2.new(0,10,0,80)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255,200,150)
    resetBtn.Text = "🔄 Reset Summit"
    resetBtn.MouseButton1Click:Connect(resetSummit)

    -- Scroll list CP
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-20,0,150)
    scroll.Position = UDim2.new(0,10,0,120)
    scroll.CanvasSize = UDim2.new(0,0,0,35*(#cpData+1))
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency = 0.2
    scroll.BackgroundColor3 = Color3.fromRGB(25,25,30)

    for i, cf in ipairs(cpData) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1,-10,0,30)
        btn.Position = UDim2.new(0,5,0,(i-1)*35)
        btn.Text = "Teleport CP"..i
        btn.BackgroundColor3 = Color3.fromRGB(80,80,150)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.MouseButton1Click:Connect(function()
            teleportCheckpoint(cf, "CP"..i)
        end)
    end
    -- Summit button
    local sb = Instance.new("TextButton", scroll)
    sb.Size = UDim2.new(1,-10,0,30)
    sb.Position = UDim2.new(0,5,0,#cpData*35)
    sb.Text = "Teleport Summit"
    sb.BackgroundColor3 = Color3.fromRGB(200,80,80)
    sb.TextColor3 = Color3.new(1,1,1)
    sb.MouseButton1Click:Connect(function()
        teleportCheckpoint(summit, "Summit")
    end)
end

showNotification("YARS Final", "Summit Script Loaded ✅")
createUI()
