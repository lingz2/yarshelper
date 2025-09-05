-- Gunung Anurika Ultimate Realistic Auto Summit
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Checkpoints
local CPs = {
    ["CP1"] = CFrame.new(135.192032, 140.966553, -175.245834),
    ["CP2"] = CFrame.new(326.375885, 88.9806747, -433.956573),
    ["CP3"] = CFrame.new(475.910278, 168.998825, -939.516602),
    ["CP4"] = CFrame.new(930.097229, 132.571213, -626.028931),
    ["CP5"] = CFrame.new(923.416199, 100.85717, 279.597198),
    ["Summit"] = CFrame.new(250.567139, 318.749023, 674.083618)
}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "GunungAnurikaUltimateGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 550)
MainFrame.Position = UDim2.new(0.7,0,0.25,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local CPColors = {
    ["CP1"] = Color3.fromRGB(255,85,85),
    ["CP2"] = Color3.fromRGB(255,170,0),
    ["CP3"] = Color3.fromRGB(255,255,85),
    ["CP4"] = Color3.fromRGB(85,255,85),
    ["CP5"] = Color3.fromRGB(85,170,255),
    ["Summit"] = Color3.fromRGB(170,85,255)
}

-- Kontrol Variabel
local CPButtons = {}
local activeButton = nil
local autoSummit = false
local paused = false
local waypointDelay = 0.3
local walkSpeed = 16
local currentWaypointIndex = 1
local waypoints = {}

-- Tombol Helper
local function createButton(name, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = CPColors[name] or Color3.fromRGB(150,150,150)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Fungsi Realistik Ultimate
local function moveToTarget(targetPosition)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 15,
        AgentMaxSlope = 45
    })
    path:ComputeAsync(hrp.Position, targetPosition)
    waypoints = path:GetWaypoints()
    currentWaypointIndex = 1

    while currentWaypointIndex <= #waypoints do
        if paused then
            wait(0.1)
        else
            local wp = waypoints[currentWaypointIndex]

            local verticalDiff = wp.Position.Y - hrp.Position.Y

            -- Lompat alami sesuai tinggi
            if wp.Action == Enum.PathWaypointAction.Jump or verticalDiff > 2 then
                humanoid.Jump = true
            end

            -- Tween smooth movement
            humanoid.WalkSpeed = walkSpeed
            local distance = (hrp.Position - wp.Position).Magnitude
            local duration = math.clamp(distance / walkSpeed, 0.1, 1.5)
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(wp.Position)})
            tween:Play()
            tween.Completed:Wait()

            currentWaypointIndex = currentWaypointIndex + 1
            wait(waypointDelay)
        end
    end
end

-- Tombol CP manual
for cpName, cpCFrame in pairs(CPs) do
    CPButtons[cpName] = createButton(cpName, MainFrame, function()
        moveToTarget(cpCFrame.Position)
        if activeButton then activeButton.BorderSizePixel = 0 end
        local btn = CPButtons[cpName]
        btn.BorderSizePixel = 3
        btn.BorderColor3 = Color3.fromRGB(255,255,255)
        activeButton = btn
    end)
end

-- Auto Summit
local AutoButton = createButton("Toggle Auto Summit", MainFrame, function()
    autoSummit = not autoSummit
    AutoButton.Text = autoSummit and "Auto Summit: ON" or "Auto Summit: OFF"
    if autoSummit then
        spawn(function()
            while autoSummit do
                for _, cpName in ipairs({"CP1","CP2","CP3","CP4","CP5","Summit"}) do
                    moveToTarget(CPs[cpName].Position)
                    if activeButton then activeButton.BorderSizePixel = 0 end
                    local btn = CPButtons[cpName]
                    btn.BorderSizePixel = 3
                    btn.BorderColor3 = Color3.fromRGB(255,255,255)
                    activeButton = btn
                end
            end
        end)
    end
end)

-- Pause / Continue
local PauseButton = createButton("Pause", MainFrame, function()
    paused = not paused
    PauseButton.Text = paused and "Continue" or "Pause"
end)

-- Slider WalkSpeed
local SpeedLabel = Instance.new("TextLabel", MainFrame)
SpeedLabel.Size = UDim2.new(1, -10, 0, 25)
SpeedLabel.Text = string.format("WalkSpeed: %.1f", walkSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 16

local SpeedSlider = Instance.new("Frame", MainFrame)
SpeedSlider.Size = UDim2.new(1, -10, 0, 25)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(80,80,80)

local SliderHandle = Instance.new("Frame", SpeedSlider)
SliderHandle.Size = UDim2.new((walkSpeed-8)/32,0,1,0)
SliderHandle.BackgroundColor3 = Color3.fromRGB(200,200,200)

local dragging = false
SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
SliderHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX = player:GetMouse().X
        local pos = math.clamp(mouseX - SpeedSlider.AbsolutePosition.X, 0, SpeedSlider.AbsoluteSize.X)
        SliderHandle.Size = UDim2.new(pos / SpeedSlider.AbsoluteSize.X,0,1,0)
        walkSpeed = 8 + 32*(pos/SpeedSlider.AbsoluteSize.X)
        SpeedLabel.Text = string.format("WalkSpeed: %.1f", walkSpeed)
    end
end)
