--// Gunung HTS - Auto Summit Loop + CP Teleport GUI + Notifikasi Toggle + Indikator Status
--// Delta Executor Ready

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Data CP & Summit
local checkpoints = {
    CP1 = CFrame.new(168.964996, 325.432037, 376.070007),
    CP2 = CFrame.new(386.986053, 393.932037, 280.919952, 0.999988198, -3.017489196e-08, -0.00485849567, 3.04457117e-08, 1, 5.56674138e-08, 0.00485849567, -5.581467732e-08, 0.999988198),
    CP3 = CFrame.new(663.062195, 517.432007, 77.9546585, 0.997971058, -5.2473853e-10, -0.0636694878, 5.54794877e-10, 1, 4.5438886e-10, 0.0636694878, -4.88790397e-10, 0.997971058),
    CP4 = CFrame.new(447.947968, 733.432007, -262.273407, 0.999511242, -8.454063766e-08, -0.0312621221, 8.62469136e-08, 1, 5.323131456e-08, 0.0312621221, -5.590155896e-08, 0.999511242),
    CP5 = CFrame.new(71.9999695, 857.432007, -328.859985),
    SUMMIT = CFrame.new(-657.939148, 1089.43201, 270.277374, 0.935168266, -1.00108551e-07, 0.354203761, 9.88319613e-08, 1, 2.16938378e-08, -0.354203761, 1.471926236e-08, 0.935168266)
}

-- Vars
local autoSummit = false
local delayTime = 1.0
local notifEnabled = true
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.ResetOnSpawn = false

-- Notifikasi
local function notify(msg)
    if not notifEnabled then return end
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.Position = UDim2.new(1, -210, 1, -40)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BorderSizePixel = 0

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Text = msg

    frame:TweenPosition(UDim2.new(1,-210,1,-80),"Out","Quad",0.3,true)

    task.delay(2, function()
        frame:TweenPosition(UDim2.new(1,-210,1,0),"In","Quad",0.3,true)
        task.wait(0.3)
        frame:Destroy()
    end)
end

-- Indikator Auto Summit
local statusLabel = Instance.new("TextLabel", gui)
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
statusLabel.Text = "Auto Summit: OFF"
statusLabel.Visible = true

-- GUI utama
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 330)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

-- Titlebar
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 30)
title.Text = "Gunung HTS Teleport"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.BorderSizePixel = 0

-- Close
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -25, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.new(1,0,0)
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Minimize
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0, 20, 0, 20)
minimize.Position = UDim2.new(1, -50, 0, 5)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1,1,0)
minimize.BackgroundTransparency = 1
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(main:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel") then
            if v ~= title and v ~= close and v ~= minimize then
                v.Visible = not minimized
            end
        end
    end
    main.Size = minimized and UDim2.new(0,220,0,30) or UDim2.new(0,220,0,330)
end)

-- Tombol CP
local y = 40
for name,cf in pairs(checkpoints) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = cf
            notify("Teleport ke "..name)
        end
    end)
    y = y + 30
end

-- Label delay
local delayLabel = Instance.new("TextLabel", main)
delayLabel.Size = UDim2.new(1, -20, 0, 25)
delayLabel.Position = UDim2.new(0, 10, 0, y)
delayLabel.BackgroundTransparency = 1
delayLabel.TextColor3 = Color3.fromRGB(255,255,255)
delayLabel.Text = "Delay: "..delayTime.."s"
y = y + 30

-- Tombol delay
local minus = Instance.new("TextButton", main)
minus.Size = UDim2.new(0.5, -15, 0, 25)
minus.Position = UDim2.new(0, 10, 0, y)
minus.Text = "- Delay"
minus.BackgroundColor3 = Color3.fromRGB(80,60,60)
minus.TextColor3 = Color3.fromRGB(255,255,255)
minus.MouseButton1Click:Connect(function()
    delayTime = math.max(0.1, delayTime - 0.1)
    delayLabel.Text = "Delay: "..string.format("%.1f",delayTime).."s"
end)

local plus = Instance.new("TextButton", main)
plus.Size = UDim2.new(0.5, -15, 0, 25)
plus.Position = UDim2.new(0.5, 5, 0, y)
plus.Text = "+ Delay"
plus.BackgroundColor3 = Color3.fromRGB(60,80,60)
plus.TextColor3 = Color3.fromRGB(255,255,255)
plus.MouseButton1Click:Connect(function()
    delayTime = math.min(5, delayTime + 0.1)
    delayLabel.Text = "Delay: "..string.format("%.1f",delayTime).."s"
end)
y = y + 35

-- Auto Summit
local autoBtn = Instance.new("TextButton", main)
autoBtn.Size = UDim2.new(1, -20, 0, 30)
autoBtn.Position = UDim2.new(0, 10, 0, y)
autoBtn.Text = "Auto Summit: OFF"
autoBtn.BackgroundColor3 = Color3.fromRGB(70,70,100)
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
y = y + 40

autoBtn.MouseButton1Click:Connect(function()
    autoSummit = not autoSummit
    autoBtn.Text = "Auto Summit: "..(autoSummit and "ON" or "OFF")
    statusLabel.Text = "Auto Summit: "..(autoSummit and "ON" or "OFF")
    statusLabel.TextColor3 = autoSummit and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    notify("Auto Summit "..(autoSummit and "Aktif" or "Nonaktif"))
end)

-- Toggle Notif
local notifBtn = Instance.new("TextButton", main)
notifBtn.Size = UDim2.new(1, -20, 0, 30)
notifBtn.Position = UDim2.new(0, 10, 0, y)
notifBtn.Text = "Notifikasi: ON"
notifBtn.BackgroundColor3 = Color3.fromRGB(100,70,70)
notifBtn.TextColor3 = Color3.fromRGB(255,255,255)

notifBtn.MouseButton1Click:Connect(function()
    notifEnabled = not notifEnabled
    notifBtn.Text = "Notifikasi: "..(notifEnabled and "ON" or "OFF")
end)

-- Loop Auto Summit
task.spawn(function()
    while task.wait(0.1) do
        if autoSummit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = checkpoints.SUMMIT
            notify("Teleport ke Summit")
            task.wait(delayTime)

            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                notify("Respawn...")
            else
                player.Character:BreakJoints()
                notify("Paksa Mati")
            end

            player.CharacterAdded:Wait()
            task.wait(delayTime)

            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character:WaitForChild("HumanoidRootPart").CFrame = checkpoints.CP1
                notify("Balik ke CP1")
            end

            task.wait(delayTime)
        end
    end
end)
