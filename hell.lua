-- Auto Summit Loop GUI for Hell Expedition (Extended Version)
-- Watermark: "yars ganteng"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CONFIG (default) ===
local summitCFrame = CFrame.new(
    -1513.30737, 1873.19397, -72.6928024,
    0.962206244, 8.961788476e-08, -0.27232185,
    -9.90394611e-08, 1, -2.085215916e-08,
    0.27232185, 4.70346855e-08, 0.962206244
)

local respawnRemoteName = "RespawnChoiceEvent"
local respawnArg = {"Base"}

local delaySeconds = 1.0
local loopStop = false
local autoMode = false

-- === UI CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YarsAutoSummitGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 270)
mainFrame.Position = UDim2.new(0.5, -190, 0.3, -135)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Text = "Auto Summit - Hell Expedition   |   yars ganteng"
header.Font = Enum.Font.SourceSansBold
header.TextSize = 16
header.TextColor3 = Color3.fromRGB(255, 200, 200)
header.Parent = mainFrame

-- Body
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -10, 1, -40)
body.Position = UDim2.new(0, 5, 0, 35)
body.BackgroundTransparency = 1
body.Parent = mainFrame

-- Buttons
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(0.48, 0, 0, 36)
teleportBtn.Text = "Teleport"
teleportBtn.Font = Enum.Font.SourceSansBold
teleportBtn.TextSize = 16
teleportBtn.BackgroundColor3 = Color3.fromRGB(170, 255, 180)
teleportBtn.Parent = body
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 8)

local autoBtn = teleportBtn:Clone()
autoBtn.Text = "Auto: OFF"
autoBtn.Position = UDim2.new(0.52, 0, 0, 0)
autoBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 95)
autoBtn.Parent = body

local stopBtn = teleportBtn:Clone()
stopBtn.Text = "Stop"
stopBtn.Position = UDim2.new(0, 0, 0, 42)
stopBtn.Size = UDim2.new(1, 0, 0, 36)
stopBtn.BackgroundColor3 = Color3.fromRGB(220, 90, 90)
stopBtn.Parent = body

-- Delay controls
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0.6, 0, 0, 20)
delayLabel.Position = UDim2.new(0, 0, 0, 84)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay: "..delaySeconds.."s"
delayLabel.Font = Enum.Font.SourceSans
delayLabel.TextSize = 14
delayLabel.TextColor3 = Color3.fromRGB(230,230,230)
delayLabel.Parent = body

local minusBtn = teleportBtn:Clone()
minusBtn.Size = UDim2.new(0, 36, 0, 24)
minusBtn.Text = "-"
minusBtn.Position = UDim2.new(0.65, 0, 0, 82)
minusBtn.Parent = body

local plusBtn = teleportBtn:Clone()
plusBtn.Size = UDim2.new(0, 36, 0, 24)
plusBtn.Text = "+"
plusBtn.Position = UDim2.new(0.65, 40, 0, 82)
plusBtn.Parent = body

-- Input CFrame
local inputLabel = delayLabel:Clone()
inputLabel.Text = "Summit CFrame:"
inputLabel.Position = UDim2.new(0, 0, 0, 112)
inputLabel.Parent = body

local cframeBox = Instance.new("TextBox")
cframeBox.Size = UDim2.new(1, -4, 0, 28)
cframeBox.Position = UDim2.new(0, 0, 0, 134)
cframeBox.PlaceholderText = "Masukkan CFrame manual"
cframeBox.Text = ""
cframeBox.Font = Enum.Font.SourceSans
cframeBox.TextSize = 14
cframeBox.TextColor3 = Color3.fromRGB(0,0,0)
cframeBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
cframeBox.ClearTextOnFocus = false
cframeBox.Parent = body
Instance.new("UICorner", cframeBox).CornerRadius = UDim.new(0, 6)

-- Minimize & Close
local minimizeBtn = teleportBtn:Clone()
minimizeBtn.Text = "_"
minimizeBtn.Size = UDim2.new(0, 40, 0, 24)
minimizeBtn.Position = UDim2.new(0, 0, 1, -28)
minimizeBtn.Parent = mainFrame

local closeBtn = teleportBtn:Clone()
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 40, 0, 24)
closeBtn.Position = UDim2.new(1, -44, 1, -28)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.Parent = mainFrame

-- Toast notification
local function showToast(msg)
    local toast = Instance.new("TextLabel")
    toast.Size = UDim2.new(0, 200, 0, 30)
    toast.Position = UDim2.new(0.5, -100, 0.05, 0)
    toast.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toast.TextColor3 = Color3.fromRGB(255,255,255)
    toast.Text = msg
    toast.Font = Enum.Font.SourceSansBold
    toast.TextSize = 14
    toast.Parent = screenGui
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 6)

    local tween = TweenService:Create(toast, TweenInfo.new(0.5), {BackgroundTransparency=0.2, TextTransparency=0})
    tween:Play()
    task.wait(1.5)
    toast:Destroy()
end

-- === CORE LOGIC ===
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportSummit()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = summitCFrame
        return true
    end
    return false
end

local function respawnBase()
    local remote = ReplicatedStorage:FindFirstChild(respawnRemoteName)
    if remote then
        remote:FireServer(unpack(respawnArg))
    end
end

local function autoLoop()
    while autoMode do
        if teleportSummit() then
            showToast("Teleport → Summit")
        end
        task.wait(delaySeconds)
        respawnBase()
        showToast("Respawned")
        player.CharacterAdded:Wait()
        task.wait(0.5)
    end
end

-- === BUTTON EVENTS ===
teleportBtn.MouseButton1Click:Connect(teleportSummit)

autoBtn.MouseButton1Click:Connect(function()
    autoMode = not autoMode
    autoBtn.Text = autoMode and "Auto: ON" or "Auto: OFF"
    if autoMode then
        task.spawn(autoLoop)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    autoMode = false
    autoBtn.Text = "Auto: OFF"
end)

minusBtn.MouseButton1Click:Connect(function()
    delaySeconds = math.max(0.1, delaySeconds - 0.1)
    delayLabel.Text = "Delay: "..string.format("%.1f", delaySeconds).."s"
end)

plusBtn.MouseButton1Click:Connect(function()
    delaySeconds = math.min(5, delaySeconds + 0.1)
    delayLabel.Text = "Delay: "..string.format("%.1f", delaySeconds).."s"
end)

cframeBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and cframeBox.Text ~= "" then
        local ok, cf = pcall(function()
            return loadstring("return CFrame.new("..cframeBox.Text..")")()
        end)
        if ok and typeof(cf) == "CFrame" then
            summitCFrame = cf
            showToast("CFrame updated")
        else
            showToast("Invalid CFrame!")
        end
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    body.Visible = not body.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    autoMode = false
    screenGui:Destroy()
end)

print("[YARS AUTO SUMMIT] Loaded with all features!  Watermark: yars ganteng")
