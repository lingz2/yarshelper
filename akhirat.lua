-- YARS Summit Auto Script - FINAL + SPEED CONTROL
-- Auto Summit + Respawn Remote (ReturnToSpawn)

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Koordinat
local SUMMIT_POS = CFrame.new(3041.74048, 7876.99756, 1037.59253) -- Puncak
local BASECAMP_POS = CFrame.new(-243.999069, 120.998016, 202.997528) -- Basecamp

-- Remote Reset Summit
local ReturnToSpawn = game.ReplicatedStorage:WaitForChild("ReturnToSpawn")

-- Vars
local autoSummitEnabled = false
local summitCount = 0
local loopDelay = 1.5 -- default kecepatan (detik)
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
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
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

-- Auto Summit Loop
local function autoSummitLoop()
    task.spawn(function()
        while autoSummitEnabled do
            if teleportTo(SUMMIT_POS, "Puncak") then
                wait(0.5)
                resetSummit()
                wait(loopDelay) -- kontrol kecepatan loop
            else
                showCustomNotification("❌ Teleport Failed", "Retry...", Color3.fromRGB(255,100,100), 2)
                wait(2)
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
    frame.Size = UDim2.new(0,200,0,280)
    frame.Position = UDim2.new(0,20,0.5,-140)
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
    
    -- Tombol ke Basecamp
    local baseBtn = Instance.new("TextButton", frame)
    baseBtn.Size = UDim2.new(1,-20,0,30)
    baseBtn.Position = UDim2.new(0,10,0,40)
    baseBtn.BackgroundColor3 = Color3.fromRGB(150,150,255)
    baseBtn.Text = "🏠 Basecamp"
    baseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    baseBtn.MouseButton1Click:Connect(function()
        teleportTo(BASECAMP_POS, "Basecamp")
    end)
    
    -- Tombol ke Puncak
    local summitBtn = Instance.new("TextButton", frame)
    summitBtn.Size = UDim2.new(1,-20,0,30)
    summitBtn.Position = UDim2.new(0,10,0,80)
    summitBtn.BackgroundColor3 = Color3.fromRGB(255,150,100)
    summitBtn.Text = "🚀 Puncak"
    summitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    summitBtn.MouseButton1Click:Connect(function()
        teleportTo(SUMMIT_POS, "Puncak")
    end)
    
    -- Tombol Respawn Remote
    local respawnBtn = Instance.new("TextButton", frame)
    respawnBtn.Size = UDim2.new(1,-20,0,30)
    respawnBtn.Position = UDim2.new(0,10,0,120)
    respawnBtn.BackgroundColor3 = Color3.fromRGB(255,200,150)
    respawnBtn.Text = "🔄 Respawn (Remote)"
    respawnBtn.TextColor3 = Color3.fromRGB(0,0,0)
    respawnBtn.MouseButton1Click:Connect(function()
        resetSummit()
    end)
    
    -- Auto Summit
    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(1,-20,0,35)
    autoBtn.Position = UDim2.new(0,10,0,160)
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
    speedLabel.Position = UDim2.new(0,10,0,205)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
    speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    
    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0.5,-15,0,25)
    plusBtn.Position = UDim2.new(0,10,0,230)
    plusBtn.BackgroundColor3 = Color3.fromRGB(100,200,255)
    plusBtn.Text = "+ Delay"
    plusBtn.TextColor3 = Color3.fromRGB(0,0,0)
    plusBtn.MouseButton1Click:Connect(function()
        loopDelay = loopDelay + 0.5
        speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
    end)
    
    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0.5,-15,0,25)
    minusBtn.Position = UDim2.new(0.5,5,0,230)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255,150,150)
    minusBtn.Text = "- Delay"
    minusBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minusBtn.MouseButton1Click:Connect(function()
        if loopDelay > 0.5 then
            loopDelay = loopDelay - 0.5
            speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
        end
    end)
end

-- Start
showNotification("YARS Ready", "Summit Auto Loaded!")
createUI()
