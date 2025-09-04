-- YARS Summit Helper FINAL (Border CP + Retry Save + Offset Slider)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- daftar checkpoint border
local checkpoints = {
    CFrame.new(-128.860931, 420.21344, -210.443787, -0.382131785, -1.759414176e-09, 0.92410785, 3.28097638e-09, 1, 3.26063621e-09, -0.92410785, 4.27796865e-09, -0.382131785),
    CFrame.new(-13.3578444, 948.377625, -1047.88647, 0.950412035, -2.329092256e-09, 0.310993552, 9.13760267e-09, 1, -2.043577936e-08, -0.310993552, 2.22641461e-08, 0.950412035),
    CFrame.new(103.504997, 1199.91821, -1348.18542, 0.458309442, 4.075202046e-08, 0.888792694, 6.23996144e-09, 1, -4.90686466e-08, -0.888792694, 2.80346573e-08, 0.458309442),
    CFrame.new(109.371323, 1463.27966, -1818.04211, -0.22470805, -3.030606522e-08, -0.97442615, 1.96519032e-08, 1, -3.563328836e-08, 0.97442615, -2.7156414e-08, -0.22470805),
    CFrame.new(292.275543, 1864.36096, -2330.11597, -0.845709741, -1.84433375e-08, 0.533643186, -5.768799136e-08, 1, -5.68618894e-08, -0.533643186, -7.88734553e-08, -0.845709741),
    CFrame.new(555.965149, 2084.33984, -2570.9231, -0.220515072, 5.458198166e-08, 0.97538358, 7.0394627e-08, 1, -4.004466456e-08, -0.97538358, 5.983130796e-08, -0.220515072),
    CFrame.new(743.121399, 2184.43188, -2504.37061, 0.949542642, 2.91279498e-08, -0.313637942, -6.01314269e-08, 1, -8.91773624e-08, 0.313637942, 1.03537211e-07, 0.949542642),
    CFrame.new(781.188354, 2328.43188, -2639.73315, 0.994524181, -1.77558857e-08, 0.104506589, 1.80032149e-08, 1, -1.42332823e-09, -0.104506589, 3.29698896e-09, 0.994524181),
    CFrame.new(980.821838, 2516.43188, -2633.94751, -0.99996984, -6.724003046e-08, 0.00776741421, -6.649077026e-08, 1, 9.672028516e-08, -0.00776741421, 9.620090682e-08, -0.99996984),
    CFrame.new(1249.43677, 2692.23193, -2797.09277, -0.853834391, -1.17835048e-08, 0.520544767, 4.78341491e-08, 1, 1.01097832e-07, -0.520544767, 1.11220622e-07, -0.853834391),
    CFrame.new(1611.08203, 3055.91797, -2757.21118, 0.131025508, -5.10120113e-10, -0.991379023, 1.02527166e-07, 1, 1.30359359e-08, 0.991379023, -1.03351312e-07, 0.131025508),
    CFrame.new(1824.25525, 3576.43188, -3249.31519, 0.999494255, 5.061787436e-08, -0.0317998789, -4.86157076e-08, 1, 6.37347028e-08, 0.0317998789, -6.21564951e-08, 0.999494255),
    CFrame.new(2798.35181, 4420.43164, -4792.23438, 0.968395889, 8.024288436e-08, 0.24941808, -9.42676692e-08, 1, 4.42852439e-08, -0.24941808, -6.63977104e-08, 0.968395889),
    CFrame.new(3464.74072, 4856.23145, -4167.43652, 0.381198376, 7.223593466e-08, 0.924493253, 1.79294659e-08, 1, -8.552860466e-08, -0.924493253, 4.9179036e-08, 0.381198376),
    CFrame.new(3471.62354, 5104.23193, -4268.91064, -0.206839263, 1.298620596e-08, 0.978374958, 5.05800415e-08, 1, -2.58006172e-09, -0.978374958, 4.89525866e-08, -0.206839263),
    CFrame.new(3965.27051, 5664.43115, -3980.47144, 0.515083551, -4.925955476e-08, -0.857140005, 3.662621856e-08, 1, -3.54597809e-08, 0.857140005, -1.31290472e-08, 0.515083551),
    CFrame.new(4494.03174, 5896.43213, -3780.8623, 0.153532073, 2.276739866e-08, 0.988143682, 8.98150105e-08, 1, -3.699551246e-08, -0.988143682, 9.443013486e-08, 0.153532073),
    CFrame.new(5073.77783, 6368.43115, -2972.59082, 0.694449544, -3.551662456e-08, -0.719541371, -1.18178347e-08, 1, -6.076859196e-08, 0.719541371, 5.07041413e-08, 0.694449544),
    CFrame.new(5532.8501, 6588.43115, -2479.97827, 0.248890966, -7.51316787e-09, 0.968531489, 6.723634096e-09, 1, 6.02945427e-09, -0.968531489, 5.01137487e-09, 0.248890966),
    CFrame.new(5540.1416, 6872.43164, -1042.22229, 0.73816818, -3.26914786e-08, 0.674616694, 5.376668e-08, 1, -1.03723696e-08, -0.674616694, 4.392845556e-08, 0.73816818),
    CFrame.new(4329.44238, 7640.52539, 143.648972, -0.612230599, -2.102335916e-08, 0.790679276, -1.113229266e-07, 1, -5.96094267e-08, -0.790679276, -1.24515438e-07, -0.612230599),
    CFrame.new(3465.52759, 7706.62305, 945.052124, -0.776398003, 9.1943525e-10, 0.630242944, 1.28742013e-08, 1, 1.440090546e-08, -0.630242944, 1.92947081e-08, -0.776398003),
}

-- variabel
local auto = false
local offsetStud = 13

-- fungsi teleport
local function tpTo(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(cf.Position + (cf.LookVector * offsetStud))
    end
end

-- fungsi auto loop
local function autoLoop()
    for i, cf in ipairs(checkpoints) do
        repeat
            tpTo(cf)
            task.wait(2)
        until not auto -- nanti bisa diganti cek "checkpoint tersimpan"
        if not auto then break end
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "SummitHelper"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 400)
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(30,30,30)
Main.Active = true
Main.Draggable = true

-- tombol auto
local autoBtn = Instance.new("TextButton", Main)
autoBtn.Size = UDim2.new(1,0,0,40)
autoBtn.Text = "⚡ AUTO: OFF"
autoBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
autoBtn.MouseButton1Click:Connect(function()
    auto = not auto
    autoBtn.Text = auto and "⚡ AUTO: ON" or "⚡ AUTO: OFF"
    if auto then
        task.spawn(autoLoop)
    end
end)

-- tombol reset
local resetBtn = Instance.new("TextButton", Main)
resetBtn.Size = UDim2.new(1,0,0,40)
resetBtn.Position = UDim2.new(0,0,0,45)
resetBtn.Text = "🔄 Reset Summit"
resetBtn.BackgroundColor3 = Color3.fromRGB(255,128,64)
resetBtn.MouseButton1Click:Connect(function()
    tpTo(checkpoints[1])
end)

-- daftar tombol teleport CP
for i, cf in ipairs(checkpoints) do
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Position = UDim2.new(0,0,0,90+(i-1)*32)
    btn.Text = "Teleport CP"..i
    btn.BackgroundColor3 = Color3.fromRGB(100,100,200)
    btn.MouseButton1Click:Connect(function()
        tpTo(cf)
    end)
end

-- label offset
local offsetLabel = Instance.new("TextLabel", Main)
offsetLabel.Size = UDim2.new(1,0,0,25)
offsetLabel.Position = UDim2.new(0,0,1,-25)
offsetLabel.Text = "Offset Stud: "..offsetStud
offsetLabel.BackgroundTransparency = 1

-- tombol + dan - offset
local plus = Instance.new("TextButton", Main)
plus.Size = UDim2.new(0.5,0,0,25)
plus.Position = UDim2.new(0.5,0,1,-50)
plus.Text = "+ Stud"
plus.MouseButton1Click:Connect(function()
    if offsetStud < 20 then
        offsetStud += 1
        offsetLabel.Text = "Offset Stud: "..offsetStud
    end
end)

local minus = Instance.new("TextButton", Main)
minus.Size = UDim2.new(0.5,0,0,25)
minus.Position = UDim2.new(0,0,1,-50)
minus.Text = "- Stud"
minus.MouseButton1Click:Connect(function()
    if offsetStud > 10 then
        offsetStud -= 1
        offsetLabel.Text = "Offset Stud: "..offsetStud
    end
end)
