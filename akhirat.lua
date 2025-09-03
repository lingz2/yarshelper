-- YARS Summit Auto Script - FINAL + SPEED CONTROL (FAST DELAY)
-- Auto Summit + Respawn Remote (ReturnToSpawn)
-- Delay range: 0.1s - 1.0s

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
local loopDelay = 0.3 -- default kecepatan (detik), range 0.1 - 1.0

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

-- Teleport
local function teleportTo(cf, name)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
        return true
    end
    return false
end

-- Reset Summit pakai Remote
local function resetSummit()
    pcall(function()
        ReturnToSpawn:FireServer()
    end)
end

-- Auto Summit Loop
local function autoSummitLoop()
    task.spawn(function()
        while autoSummitEnabled do
            if teleportTo(SUMMIT_POS, "Puncak") then
                task.wait(0.2)
                resetSummit()
                task.wait(loopDelay) -- kontrol kecepatan loop
            else
                task.wait(0.5)
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
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,200,0,180)
    frame.Position = UDim2.new(0,20,0.5,-90)
    frame.BackgroundColor3 = Color3.fromRGB(35,35,40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    
    -- Auto Summit
    local autoBtn = Instance.new("TextButton", frame)
    autoBtn.Size = UDim2.new(1,-20,0,35)
    autoBtn.Position = UDim2.new(0,10,0,20)
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
    
    -- Speed Control
    local speedLabel = Instance.new("TextLabel", frame)
    speedLabel.Size = UDim2.new(1,-20,0,20)
    speedLabel.Position = UDim2.new(0,10,0,70)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
    speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    
    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0.5,-15,0,25)
    plusBtn.Position = UDim2.new(0,10,0,100)
    plusBtn.BackgroundColor3 = Color3.fromRGB(100,200,255)
    plusBtn.Text = "+ Delay"
    plusBtn.MouseButton1Click:Connect(function()
        if loopDelay < 1.0 then
            loopDelay = math.floor((loopDelay + 0.1)*10)/10
            speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
        end
    end)
    
    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0.5,-15,0,25)
    minusBtn.Position = UDim2.new(0.5,5,0,100)
    minusBtn.BackgroundColor3 = Color3.fromRGB(255,150,150)
    minusBtn.Text = "- Delay"
    minusBtn.MouseButton1Click:Connect(function()
        if loopDelay > 0.1 then
            loopDelay = math.floor((loopDelay - 0.1)*10)/10
            speedLabel.Text = "⏱️ Delay: "..loopDelay.."s"
        end
    end)
end

-- Start
createUI()
