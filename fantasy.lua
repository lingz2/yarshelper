--// Ultra Smooth Auto Summit
--// Delta Executor Ready
--// GUI Toggle [M]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Peak CFrame
local summitCFrame = CFrame.new(-975.276672, 1519.43201, 1443.22205, 0.721820176, -3.034696052e-08, -0.692080617, -3.361549976e-08, 1, -7.89088836e-08, 0.692080617, 8.02226623e-08, 0.721820176)

-- Settings
local autoSummit = false
local delayTime = 1
local minDelay, maxDelay = 0.1, 5

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Ultra Smooth Auto Summit"
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
MinBtn.MouseButton1Click:Connect(function() MainFrame.Size = UDim2.new(0,250,0,30) end)

-- Start/Stop Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size=UDim2.new(0,200,0,40)
ToggleBtn.Position=UDim2.new(0.5,-100,0,50)
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

-- Delay Controls
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size=UDim2.new(0,250,0,30)
DelayLabel.Position=UDim2.new(0,0,0,100)
DelayLabel.BackgroundTransparency=1
DelayLabel.Text="Delay: "..delayTime.."s"
DelayLabel.TextColor3=Color3.fromRGB(255,255,255)
DelayLabel.Font=Enum.Font.Gotham
DelayLabel.TextSize=16
DelayLabel.Parent = MainFrame

local IncreaseBtn = Instance.new("TextButton")
IncreaseBtn.Size=UDim2.new(0,30,0,30)
IncreaseBtn.Position=UDim2.new(0,200,0,100)
IncreaseBtn.Text="+"
IncreaseBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
IncreaseBtn.TextColor3=Color3.fromRGB(255,255,255)
IncreaseBtn.Font=Enum.Font.GothamBold
IncreaseBtn.TextSize=18
IncreaseBtn.Parent=MainFrame
IncreaseBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime + 0.1, minDelay, maxDelay)
    DelayLabel.Text="Delay: "..string.format("%.1f",delayTime).."s"
end)

local DecreaseBtn = Instance.new("TextButton")
DecreaseBtn.Size=UDim2.new(0,30,0,30)
DecreaseBtn.Position=UDim2.new(0,170,0,100)
DecreaseBtn.Text="-"
DecreaseBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
DecreaseBtn.TextColor3=Color3.fromRGB(255,255,255)
DecreaseBtn.Font=Enum.Font.GothamBold
DecreaseBtn.TextSize=18
DecreaseBtn.Parent = MainFrame
DecreaseBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime - 0.1, minDelay, maxDelay)
    DelayLabel.Text="Delay: "..string.format("%.1f",delayTime).."s"
end)

-- Toggle GUI with M
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Ultra Smooth Auto Summit Loop
spawn(function()
    while true do
        if autoSummit then
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")

            -- Teleport ke puncak
            hrp.CFrame = summitCFrame
            wait(delayTime)

            -- Paksa respawn tapi minimal efek
            if humanoid then
                humanoid:TakeDamage(humanoid.Health)
            end

            -- Tunggu karakter respawn dan HumanoidRootPart muncul
            repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        else
            wait(0.2)
        end
    end
end)
