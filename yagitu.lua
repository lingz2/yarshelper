-- Auto Summit CKPTW Ultra Final (Fixed Teleport)
-- LocalScript di StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LocalPlayer = Players.LocalPlayer
local TweenTime = 0.5

-- Daftar checkpoint + finis
local checkpoints = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","finis"}

-- Leaderboard simulasi
local summitCount = 0
local checkpointReached = {}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportUI"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 550)
MainFrame.Position = UDim2.new(0, 10, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.Parent = MainFrame

-- Show/Hide UI
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 300, 0, 30)
ToggleButton.Position = UDim2.new(0,10,0.5,-310)
ToggleButton.Text = "Hide UI"
ToggleButton.Parent = ScreenGui
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleButton.Text = MainFrame.Visible and "Hide UI" or "Show UI"
end)

-- Start/Stop Auto Loop
local AutoLoop = false
local AutoLoopButton = Instance.new("TextButton")
AutoLoopButton.Size = UDim2.new(0, 280, 0, 25)
AutoLoopButton.BackgroundColor3 = Color3.fromRGB(70,120,70)
AutoLoopButton.TextColor3 = Color3.fromRGB(255,255,255)
AutoLoopButton.Text = "Start Auto Loop"
AutoLoopButton.Parent = MainFrame
AutoLoopButton.MouseButton1Click:Connect(function()
    AutoLoop = not AutoLoop
    AutoLoopButton.Text = AutoLoop and "Stop Auto Loop" or "Start Auto Loop"
end)

-- Fungsi Notifikasi
local function notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Summit CKPTW",
        Text = msg,
        Duration = 2
    })
end

-- Fungsi teleport aman
local function teleportTo(objName)
    local obj = workspace:FindFirstChild(objName, true) -- cari semua descendant
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if obj and obj:IsA("BasePart") and root then
        local tween = TweenService:Create(root, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = obj.CFrame + Vector3.new(0,3,0)})
        tween:Play()
        tween.Completed:Wait()
    else
        notify("Checkpoint "..objName.." tidak ditemukan atau HumanoidRootPart tidak ada")
    end
end

-- Teleport langsung ke finis
local TeleportFinisBtn = Instance.new("TextButton")
TeleportFinisBtn.Size = UDim2.new(0, 280, 0, 25)
TeleportFinisBtn.BackgroundColor3 = Color3.fromRGB(120,50,50)
TeleportFinisBtn.TextColor3 = Color3.fromRGB(255,255,255)
TeleportFinisBtn.Text = "Teleport Langsung ke FINIS"
TeleportFinisBtn.Parent = MainFrame
TeleportFinisBtn.MouseButton1Click:Connect(function()
    teleportTo("finis")
    notify("Teleported langsung ke FINIS")
end)

-- Timer label
local TimerLabel = Instance.new("TextLabel")
TimerLabel.Size = UDim2.new(0, 280, 0, 25)
TimerLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
TimerLabel.TextColor3 = Color3.fromRGB(255,255,255)
TimerLabel.Text = "Summit Time: 0s"
TimerLabel.Parent = MainFrame

local startTime = 0
local timerActive = false

-- Leaderboard label
local LeaderLabel = Instance.new("TextLabel")
LeaderLabel.Size = UDim2.new(0, 280, 0, 25)
LeaderLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
LeaderLabel.TextColor3 = Color3.fromRGB(255,255,255)
LeaderLabel.Text = "Summits: 0 | Checkpoints reached: 0"
LeaderLabel.Parent = MainFrame

-- Auto Loop checkpoint by checkpoint
spawn(function()
    while true do
        if AutoLoop then
            startTime = tick()
            timerActive = true
            checkpointReached = {}
            for _, name in ipairs(checkpoints) do
                teleportTo(name)
                notify("Sampai di checkpoint "..name)
                checkpointReached[name] = true
                LeaderLabel.Text = "Summits: "..summitCount.." | Checkpoints reached: "..#checkpointReached
                wait(0.3)
                if name == "finis" then
                    summitCount = summitCount + 1
                end
            end
            teleportTo("1")
            notify("Kembali ke basecamp")
            timerActive = false
        else
            wait(1)
        end
    end
end)

-- Update Timer
spawn(function()
    while true do
        if timerActive then
            local elapsed = math.floor(tick() - startTime)
            TimerLabel.Text = "Summit Time: "..elapsed.."s"
        end
        wait(0.2)
    end
end)

-- Tombol teleport manual tiap checkpoint
for _, name in ipairs(checkpoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 25)
    btn.Text = "Teleport ke "..name
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = MainFrame

    btn.MouseButton1Click:Connect(function()
        teleportTo(name)
        notify("Teleported ke "..name)
        checkpointReached[name] = true
        LeaderLabel.Text = "Summits: "..summitCount.." | Checkpoints reached: "..#checkpointReached
    end)
end
