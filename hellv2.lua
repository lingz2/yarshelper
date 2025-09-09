-- Auto Summit Loop GUI for Hell Expedition (Spam Respawn Edition)
-- Watermark: "yars ganteng"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CONFIG ===
local summitCFrame = CFrame.new(
    -1513.30737, 1873.19397, -72.6928024,
    0.962206244, 8.961788476e-08, -0.27232185,
    -9.90394611e-08, 1, -2.085215916e-08,
    0.27232185, 4.70346855e-08, 0.962206244
)

local respawnRemoteName = "RespawnChoiceEvent"
local respawnArg = {"Base"}

local delaySeconds = 1.0
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
mainFrame.Active = true
mainFrame.Draggable = true
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
local function makeBtn(text, pos, size, color)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(0.48, 0, 0, 36)
    b.Position = pos or UDim2.new(0, 0, 0, 0)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 16
    b.BackgroundColor3 = color or Color3.fromRGB(170, 255, 180)
    b.Parent = body
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local teleportBtn = makeBtn("Teleport", UDim2.new(0, 0, 0, 0))
local autoBtn = makeBtn("Auto: OFF", UDim2.new(0.52, 0, 0, 0), nil, Color3.fromRGB(90, 90, 95))
local stopBtn = makeBtn("Stop", UDim2.new(0, 0, 0, 42), UDim2.new(1, 0, 0, 36), Color3.fromRGB(220, 90, 90))

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

local minusBtn = makeBtn("-", UDim2.new(0.65, 0, 0, 82), UDim2.new(0, 36, 0, 24))
local plusBtn = makeBtn("+", UDim2.new(0.65, 40, 0, 82), UDim2.new(0, 36, 0, 24))

-- Minimize & Close
local minimizeBtn = makeBtn("_", UDim2.new(0, 0, 1, -28), UDim2.new(0, 40, 0, 24))
local closeBtn = makeBtn("X", UDim2.new(1, -44, 1, -28), UDim2.new(0, 40, 0, 24), Color3.fromRGB(200, 80, 80))
closeBtn.Parent = mainFrame
minimizeBtn.Parent = mainFrame

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
    TweenService:Create(toast, TweenInfo.new(0.5), {BackgroundTransparency=0.2}):Play()
    task.wait(1.2)
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

local function fastSpamRemote()
    local remote = ReplicatedStorage:FindFirstChild(respawnRemoteName)
    if remote then
        for i = 1,100 do -- spam 100x super cepat
            remote:FireServer(unpack(respawnArg))
        end
    end
end

local function autoLoop()
    while autoMode do
        if teleportSummit() then
            showToast("Teleport → Summit")
            fastSpamRemote()
            showToast("Spam Respawn!")
        end
        task.wait(delaySeconds)
        player.CharacterAdded:Wait()
        task.wait(0.2)
    end
end

-- === BUTTON EVENTS ===
teleportBtn.MouseButton1Click:Connect(function()
    if teleportSummit() then
        fastSpamRemote()
        showToast("Teleport + Spam Respawn")
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    autoMode = not autoMode
    autoBtn.Text = autoMode and "Auto: ON" or "Auto: OFF"
    if autoMode then task.spawn(autoLoop) end
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

minimizeBtn.MouseButton1Click:Connect(function()
    body.Visible = not body.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
    autoMode = false
    screenGui:Destroy()
end)

print("[YARS AUTO SUMMIT] Loaded! Teleport + Spam Respawn aktif 🚀 | Watermark: yars ganteng")
