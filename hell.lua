-- Hell Expedition Auto Summit GUI Loop
-- Watermark: yars ganteng

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CFrame Summit
local summitCFrame = CFrame.new(
    -1513.30737, 1873.19397, -72.6928024,
    0.962206244, 8.961788476e-08, -0.27232185,
    -9.90394611e-08, 1, -2.085215916e-08,
    0.27232185, 4.70346855e-08, 0.962206244
)

-- Respawn Remote
local function doRespawn()
    local args = {"Base"}
    ReplicatedStorage:WaitForChild("RespawnChoiceEvent"):FireServer(unpack(args))
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- ini yang bikin bisa drag di PC (Android perlu manual handler, di bawah)

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,25)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.Text = "Auto Summit - yars ganteng"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = MainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,25,0,25)
closeBtn.Position = UDim2.new(1,-25,0,0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = Title

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0,25,0,25)
minimizeBtn.Position = UDim2.new(1,-50,0,0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Parent = Title

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,25)
statusLabel.Position = UDim2.new(0,0,0,30)
statusLabel.Text = "Status: OFF"
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 14
statusLabel.Parent = MainFrame

-- Delay Control
local delayTime = 1
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1,0,0,25)
delayLabel.Position = UDim2.new(0,0,0,60)
delayLabel.Text = "Delay: "..delayTime.."s"
delayLabel.TextColor3 = Color3.new(1,1,1)
delayLabel.BackgroundTransparency = 1
delayLabel.Font = Enum.Font.SourceSans
delayLabel.TextSize = 14
delayLabel.Parent = MainFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0,40,0,25)
minusBtn.Position = UDim2.new(0,20,0,90)
minusBtn.Text = "-"
minusBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.Parent = MainFrame

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0,40,0,25)
plusBtn.Position = UDim2.new(0,70,0,90)
plusBtn.Text = "+"
plusBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.Parent = MainFrame

-- Teleport Btn
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0,180,0,25)
tpBtn.Position = UDim2.new(0,20,0,120)
tpBtn.Text = "Teleport to Summit"
tpBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.Parent = MainFrame

-- Auto Summit Loop
local autoSummit = false

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,100,0,25)
toggleBtn.Position = UDim2.new(0,110,0,90)
toggleBtn.Text = "Start"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,100,200)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = MainFrame

-- Functions
tpBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = summitCFrame
    end
end)

plusBtn.MouseButton1Click:Connect(function()
    if delayTime < 5 then
        delayTime = delayTime + 0.1
        delayLabel.Text = string.format("Delay: %.1fs", delayTime)
    end
end)

minusBtn.MouseButton1Click:Connect(function()
    if delayTime > 0.1 then
        delayTime = delayTime - 0.1
        delayLabel.Text = string.format("Delay: %.1fs", delayTime)
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    autoSummit = not autoSummit
    if autoSummit then
        toggleBtn.Text = "Stop"
        statusLabel.Text = "Status: ON"
        spawn(function()
            while autoSummit do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = summitCFrame
                end
                task.wait(0.2)
                doRespawn()
                task.wait(delayTime)
            end
        end)
    else
        toggleBtn.Text = "Start"
        statusLabel.Text = "Status: OFF"
    end
end)

-- Minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,child in ipairs(MainFrame:GetChildren()) do
        if child ~= Title and child ~= minimizeBtn and child ~= closeBtn then
            child.Visible = not minimized
        end
    end
    MainFrame.Size = minimized and UDim2.new(0,220,0,25) or UDim2.new(0,220,0,160)
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Drag support untuk Android
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
