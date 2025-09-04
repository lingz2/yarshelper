-- YARS SUMMIT FINAL SMART AUTO
-- Auto CP1-22 > Summit > ReturnToSpawn
-- Teleport pinggir dengan offset stud (atur via GUI)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local ReturnToSpawn = ReplicatedStorage:WaitForChild("ReturnToSpawn")
local autoEnabled = false
local offsetStud = 13 -- default jarak geser pinggir

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 3
        })
    end)
end

-- cek apakah checkpoint ke-i sudah tercatat
local function isCheckpointSaved(index)
    -- sesuaikan dengan game: misalnya leaderstats.Checkpoint.Value == index
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Checkpoint") then
        return stats.Checkpoint.Value >= index
    end
    return false
end

-- Pusat bundaran checkpoint (XYZ saja)
local cpList = {
    Vector3.new(-134.886,419.735,-220.923), -- cp1
    Vector3.new(3,948.16,-1054.293), -- cp2
    Vector3.new(108.989,1200.198,-1359.282), -- cp3
    Vector3.new(102.756,1463.675,-1807.980), -- cp4
    Vector3.new(299.767,1863.834,-2331.907), -- cp5
    Vector3.new(560.049,2083.413,-2560.358), -- cp6
    Vector3.new(754.672,2184.431,-2500.259), -- cp7
    Vector3.new(793,2328.431,-2641.294), -- cp8
    Vector3.new(969,2516.431,-2632.294), -- cp9
    Vector3.new(1239,2692.231,-2803.294), -- cp10
    Vector3.new(1621.734,3056.231,-2752.297), -- cp11
    Vector3.new(1812.914,3576.431,-3246.645), -- cp12
    Vector3.new(2809.925,4418.998,-4792.259), -- cp13
    Vector3.new(3470,4856.231,-4178.293), -- cp14
    Vector3.new(3477.916,5102.791,-4273.476), -- cp15
    Vector3.new(3974.893,5664.431,-3970.728), -- cp16
    Vector3.new(4497.52,5896.431,-3786.269), -- cp17
    Vector3.new(5062.791,6368.431,-2973.971), -- cp18
    Vector3.new(5537.998,6588.431,-2484.27), -- cp19
    Vector3.new(5548.549,6870.99,-1047.394), -- cp20
    Vector3.new(4328.273,7638.656,131.682), -- cp21
    Vector3.new(3456.184,7708.392,937.936) -- cp22
}
local summit = Vector3.new(3041.74,7876.997,1037.592)

-- Teleport: pinggir -> tengah
local function tpTo(pos, name)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local root = char.HumanoidRootPart
    local cf = CFrame.new(pos)
    root.CFrame = cf * CFrame.new(offsetStud,0,0) -- pinggir
    task.wait(0.3)
    root.CFrame = cf -- tengah
    notify("Teleport", name.." ✅")
end

local function resetSummit()
    pcall(function() ReturnToSpawn:FireServer() end)
    notify("Reset Summit","ReturnToSpawn ✅")
end

-- Auto loop dengan cek checkpoint
local function autoLoop()
    task.spawn(function()
        while autoEnabled do
            for i,pos in ipairs(cpList) do
                if not autoEnabled then break end
                repeat
                    tpTo(pos,"CP"..i)
                    task.wait(0.8)
                until not autoEnabled or isCheckpointSaved(i)
            end
            tpTo(summit,"Summit")
            resetSummit()
            task.wait(1)
        end
    end)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "YARSFinal"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,360)
frame.Position = UDim2.new(0,20,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "YARS Summit Helper"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- Tombol auto
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1,-20,0,30)
autoBtn.Position = UDim2.new(0,10,0,40)
autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
autoBtn.Text = "⚡ AUTO: OFF"
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        autoBtn.Text = "⚡ AUTO: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
        autoLoop()
    else
        autoBtn.Text = "⚡ AUTO: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
    end
end)

-- Tombol reset summit
local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(1,-20,0,30)
resetBtn.Position = UDim2.new(0,10,0,80)
resetBtn.BackgroundColor3 = Color3.fromRGB(255,200,150)
resetBtn.Text = "🔄 Reset Summit"
resetBtn.MouseButton1Click:Connect(resetSummit)

-- Scroll daftar CP
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,-20,0,200)
scroll.Position = UDim2.new(0,10,0,120)
scroll.CanvasSize = UDim2.new(0,0,0,35*(#cpList+1))
scroll.ScrollBarThickness = 6

for i,pos in ipairs(cpList) do
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1,-10,0,30)
    b.Position = UDim2.new(0,5,0,(i-1)*35)
    b.Text = "Teleport CP"..i
    b.BackgroundColor3 = Color3.fromRGB(80,80,150)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        tpTo(pos,"CP"..i)
    end)
end

local sb = Instance.new("TextButton", scroll)
sb.Size = UDim2.new(1,-10,0,30)
sb.Position = UDim2.new(0,5,0,#cpList*35)
sb.Text = "Teleport Summit"
sb.BackgroundColor3 = Color3.fromRGB(200,80,80)
sb.TextColor3 = Color3.new(1,1,1)
sb.MouseButton1Click:Connect(function()
    tpTo(summit,"Summit")
end)

-- Slider offset stud
local slider = Instance.new("TextButton", frame)
slider.Size = UDim2.new(1,-20,0,30)
slider.Position = UDim2.new(0,10,0,330)
slider.BackgroundColor3 = Color3.fromRGB(150,150,80)
slider.Text = "Offset Stud: "..offsetStud
slider.MouseButton1Click:Connect(function()
    offsetStud = offsetStud + 1
    if offsetStud > 20 then offsetStud = 10 end
    slider.Text = "Offset Stud: "..offsetStud
end)

notify("YARS Summit","Final Smart Auto Loaded ✅")
