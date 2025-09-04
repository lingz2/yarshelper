-- Gunung Batu Teleport GUI (Delta Executor Ready)
-- Tekan tombol [M] untuk show/hide GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Data CP (CFrame)
local cps = {
    cp1  = CFrame.new(-165.121399, 4.23206806, -657.757263, 0.766828477, 0, -0.641852021, 0, 1, 0, 0.641852021, 0, 0.766828477),
    cp2  = CFrame.new(-121.60952, 8.50454998, 544.049377, 1, 0, -0.000192576554, 0, 1, 0, 0.000192576554, 0, 1),
    cp3  = CFrame.new(-40.0167122, 392.432037, 673.959045, 0.999995112, 0, 0.00312702474, 0, 1, 0, -0.00312702474, 0, 0.999995112),
    cp4  = CFrame.new(-297484.432037, 779, 1), -- simplified (rotasi identity)
    cp5  = CFrame.new(18.0000038, 572.429688, 692),
    cp6  = CFrame.new(595.273804, 916.432007, 620.967712),
    cp7  = CFrame.new(283.5, 1196.43201, 181.5),
    cp8  = CFrame.new(552.105835, 1528.43201,-581.302246),
    cp9  = CFrame.new(332.142334, 1736.43201,-260.883789),
    cp10 = CFrame.new(290.354126, 1979.03186, -203.905533),
    cp11 = CFrame.new(616.488281, 3260.50879, -66.2258759),
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GunungBatuTP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 250, 0, 350)
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Gunung Batu Teleport"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,0)
close.Text = "X"

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0,5,0,35)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 0.2
scroll.BackgroundColor3 = Color3.fromRGB(40,40,40)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0,5)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- fungsi teleport
local function tp(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = cf
end

-- buat tombol tiap CP
for name, cf in pairs(cps) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(function()
        tp(cf)
    end)
end

-- update scroll size
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+10)
end)

-- close
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- toggle dengan M
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
