-- Gunung Anurika Ultimate++ Auto Summit (HP Friendly)
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Checkpoints
local CPs = {"CP1","CP2","CP3","CP4","CP5","Summit"}
local CPPositions = {
    CP1 = Vector3.new(135.192032,140.966553,-175.245834),
    CP2 = Vector3.new(326.375885,88.9806747,-433.956573),
    CP3 = Vector3.new(475.910278,168.998825,-939.516602),
    CP4 = Vector3.new(930.097229,132.571213,-626.028931),
    CP5 = Vector3.new(923.416199,100.85717,279.597198),
    Summit = Vector3.new(250.567139,318.749023,674.083618)
}

-- GUI HP Friendly
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoSummitUltimateHP"

local MainFrame = Instance.new("Frame",ScreenGui)
MainFrame.Size = UDim2.new(0,250,0,450)
MainFrame.Position = UDim2.new(0.7,0,0.2,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout",MainFrame)
UIListLayout.Padding = UDim.new(0,5)

local autoSummit = false
local paused = false
local walkSpeed = 16
local waypointDelay = 0.25
local CPButtons = {}
local activeButton = nil

-- Tombol Helper
local function createButton(name,parent,callback)
    local btn = Instance.new("TextButton",parent)
    btn.Size = UDim2.new(1,-10,0,40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Fungsi Pathfinding Ultimate++
local function moveToTarget(targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 20, -- Lompat tinggi
        AgentMaxSlope = 50
    })
    path:ComputeAsync(hrp.Position,targetPos)
    local waypoints = path:GetWaypoints()
    local index = 1

    while index <= #waypoints do
        if paused then wait(0.1)
        else
            local wp = waypoints[index]
            humanoid.WalkSpeed = walkSpeed
            humanoid:MoveTo(wp.Position)

            -- Lompat jika perlu
            if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end

            -- Deteksi jurang / platform bergerak
            local ray = Ray.new(hrp.Position, Vector3.new(0,-5,0))
            local hit, pos = Workspace:FindPartOnRay(ray, character)
            if not hit then
                -- Jika tidak ada tanah di bawah, berhenti dan recompute path
                paused = true
                wait(0.5)
                paused = false
                path:ComputeAsync(hrp.Position,targetPos)
                waypoints = path:GetWaypoints()
                index = 1
                continue
            end

            humanoid.MoveToFinished:Wait()
            wait(waypointDelay)
            index = index + 1
        end
    end
end

-- Tombol CP Manual
for _,cpName in ipairs(CPs) do
    CPButtons[cpName] = createButton(cpName,MainFrame,function()
        moveToTarget(CPPositions[cpName])
        if activeButton then activeButton.BorderSizePixel = 0 end
        local btn = CPButtons[cpName]
        btn.BorderSizePixel = 3
        btn.BorderColor3 = Color3.fromRGB(255,255,255)
        activeButton = btn
    end)
end

-- Auto Summit Button
local AutoButton = createButton("Start Auto Summit",MainFrame,function()
    autoSummit = not autoSummit
    AutoButton.Text = autoSummit and "Stop Auto Summit" or "Start Auto Summit"
    if autoSummit then
        spawn(function()
            while autoSummit do
                for _,cpName in ipairs(CPs) do
                    moveToTarget(CPPositions[cpName])
                    if not autoSummit then break end
                end
                moveToTarget(CPPositions["CP1"])
            end
        end)
    end
end)

-- Pause / Continue
local PauseButton = createButton("Pause",MainFrame,function()
    paused = not paused
    PauseButton.Text = paused and "Continue" or "Pause"
end)

-- WalkSpeed Slider HP
local SpeedLabel = Instance.new("TextLabel",MainFrame)
SpeedLabel.Size = UDim2.new(1,-10,0,25)
SpeedLabel.Text = string.format("WalkSpeed: %.1f",walkSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 16

local SpeedSlider = Instance.new("Frame",MainFrame)
SpeedSlider.Size = UDim2.new(1,-10,0,25)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)

local SliderHandle = Instance.new("Frame",SpeedSlider)
SliderHandle.Size = UDim2.new((walkSpeed-8)/32,0,1,0)
SliderHandle.BackgroundColor3 = Color3.fromRGB(200,200,200)

local dragging=false
SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
end)
SliderHandle.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX=player:GetMouse().X
        local pos=math.clamp(mouseX-SpeedSlider.AbsolutePosition.X,0,SpeedSlider.AbsoluteSize.X)
        SliderHandle.Size=UDim2.new(pos/SpeedSlider.AbsoluteSize.X,0,1,0)
        walkSpeed = 8 + 32*(pos/SpeedSlider.AbsoluteSize.X)
        SpeedLabel.Text = string.format("WalkSpeed: %.1f",walkSpeed)
    end
end)
