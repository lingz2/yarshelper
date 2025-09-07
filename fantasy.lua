--// Ultra Fast Auto Summit with Dual Delay & Notifications
--// Delta Executor Ready
--// GUI Toggle [M]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Peak CFrame
local summitCFrame = CFrame.new(-975.276672, 1519.43201, 1443.22205, 0.721820176, -3.034696052e-08, -0.692080617, -3.361549976e-08, 1, -7.89088836e-08, 0.692080617, 8.02226623e-08, 0.721820176)

-- Settings
local autoSummit = false
local delayTeleport = 0.5 -- default delay sebelum teleport
local delayRespawn = 0.5 -- default delay sebelum karakter mati
local minDelay, maxDelay = 0.1, 5

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Ultra Fast Auto Summit"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Close & Minimize
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.Text="X"
CloseBtn.BackgroundColor3=Color3.fromRGB(200,50,50)
CloseBtn.TextColor3=Color3.fromRGB(255,255,255)
CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.TextSize=18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0,30,0,30)
MinBtn.Position = UDim2.new(1,-60,0,0)
MinBtn.Text="-"
MinBtn.BackgroundColor3=Color3.fromRGB(100,100,100)
MinBtn.TextColor3=Color3.fromRGB(255,255,255)
MinBtn.Font=Enum.Font.GothamBold
MinBtn.TextSize=18
MinBtn.Parent = MainFrame
MinBtn.MouseButton1Click:Connect(function() MainFrame.Size = UDim2.new(0,300,0,30) end)

-- Start/Stop Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size=UDim2.new(0,220,0,40)
ToggleBtn.Position=UDim2.new(0.5,-110,0,40)
ToggleBtn.Text="Start Auto Summit"
ToggleBtn.BackgroundColor3=Color3.fromRGB(50,150,50)
ToggleBtn.TextColor3=Color3.fromRGB(255,255,255)
ToggleBtn.Font=Enum.Font.GothamBold
ToggleBtn.TextSize=16
ToggleBtn.Parent = MainFrame
ToggleBtn.MouseButton1Click:Connect(function()
    autoSummit = not autoSummit
    ToggleBtn.Text = autoSummit and "Stop Auto Summit" or "Start Auto Summit"
end)

-- Delay Controls Labels
local TeleportLabel = Instance.new("TextLabel")
TeleportLabel.Size=UDim2.new(0,300,0,30)
TeleportLabel.Position=UDim2.new(0,0,0,90)
TeleportLabel.BackgroundTransparency=1
TeleportLabel.Text="Delay Teleport: "..delayTeleport.."s"
TeleportLabel.TextColor3=Color3.fromRGB(255,255,255)
TeleportLabel.Font=Enum.Font.Gotham
TeleportLabel.TextSize=14
TeleportLabel.Parent = MainFrame

local RespawnLabel = Instance.new("TextLabel")
RespawnLabel.Size=UDim2.new(0,300,0,30)
RespawnLabel.Position=UDim2.new(0,0,0,120)
RespawnLabel.BackgroundTransparency=1
RespawnLabel.Text="Delay Respawn: "..delayRespawn.."s"
RespawnLabel.TextColor3=Color3.fromRGB(255,255,255)
RespawnLabel.Font=Enum.Font.Gotham
RespawnLabel.TextSize=14
RespawnLabel.Parent = MainFrame

-- Buttons to increase/decrease teleport delay
local IncTeleport = Instance.new("TextButton")
IncTeleport.Size=UDim2.new(0,25,0,25)
IncTeleport.Position=UDim2.new(0,260,0,90)
IncTeleport.Text="+"
IncTeleport.BackgroundColor3=Color3.fromRGB(50,50,50)
IncTeleport.TextColor3=Color3.fromRGB(255,255,255)
IncTeleport.Font=Enum.Font.GothamBold
IncTeleport.TextSize=14
IncTeleport.Parent = MainFrame
IncTeleport.MouseButton1Click:Connect(function()
    delayTeleport = math.clamp(delayTeleport + 0.1, minDelay, maxDelay)
    TeleportLabel.Text="Delay Teleport: "..string.format("%.1f",delayTeleport).."s"
end)

local DecTeleport = Instance.new("TextButton")
DecTeleport.Size=UDim2.new(0,25,0,25)
DecTeleport.Position=UDim2.new(0,230,0,90)
DecTeleport.Text="-"
DecTeleport.BackgroundColor3=Color3.fromRGB(50,50,50)
DecTeleport.TextColor3=Color3.fromRGB(255,255,255)
DecTeleport.Font=Enum.Font.GothamBold
DecTeleport.TextSize=14
DecTeleport.Parent = MainFrame
DecTeleport.MouseButton1Click:Connect(function()
    delayTeleport = math.clamp(delayTeleport - 0.1, minDelay, maxDelay)
    TeleportLabel.Text="Delay Teleport: "..string.format("%.1f",delayTeleport).."s"
end)

-- Buttons to increase/decrease respawn delay
local IncRespawn = Instance.new("TextButton")
IncRespawn.Size=UDim2.new(0,25,0,25)
IncRespawn.Position=UDim2.new(0,260,0,120)
IncRespawn.Text="+"
IncRespawn.BackgroundColor3=Color3.fromRGB(50,50,50)
IncRespawn.TextColor3=Color3.fromRGB(255,255,255)
IncRespawn.Font=Enum.Font.GothamBold
IncRespawn.TextSize=14
IncRespawn.Parent = MainFrame
IncRespawn.MouseButton1Click:Connect(function()
    delayRespawn = math.clamp(delayRespawn + 0.1, minDelay, maxDelay)
    RespawnLabel.Text="Delay Respawn: "..string.format("%.1f",delayRespawn).."s"
end)

local DecRespawn = Instance.new("TextButton")
DecRespawn.Size=UDim2.new(0,25,0,25)
DecRespawn.Position=UDim2.new(0,230,0,120)
DecRespawn.Text="-"
DecRespawn.BackgroundColor3=Color3.fromRGB(50,50,50)
DecRespawn.TextColor3=Color3.fromRGB(255,255,255)
DecRespawn.Font=Enum.Font.GothamBold
DecRespawn.TextSize=14
DecRespawn.Parent = MainFrame
DecRespawn.MouseButton1Click:Connect(function()
    delayRespawn = math.clamp(delayRespawn - 0.1, minDelay, maxDelay)
    RespawnLabel.Text="Delay Respawn: "..string.format("%.1f",delayRespawn).."s"
end)

-- Toggle GUI with M
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Notification function
local function notify(msg)
    StarterGui:SetCore("SendNotification", {
        Title="Auto Summit";
        Text=msg;
        Duration=2;
    })
end

-- Ultra Fast Auto Summit Loop with dual delay
spawn(function()
    while true do
        if autoSummit then
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")

            -- Delay sebelum teleport
            notify("Teleporting in "..string.format("%.1f",delayTeleport).."s")
            wait(delayTeleport)

            -- Teleport ke puncak
            hrp.CFrame = summitCFrame
            notify("Teleported to Peak!")

            -- Delay sebelum karakter mati / respawn
            notify("Respawning in "..string.format("%.1f",delayRespawn).."s")
            wait(delayRespawn)

            -- Kill Humanoid langsung
            if humanoid then
                humanoid.Health = 0
                notify("Character Died, Respawning...")
            end

            -- Tunggu karakter respawn
            repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            notify("Respawn Complete")
        else
            wait(0.2)
        end
    end
end)
