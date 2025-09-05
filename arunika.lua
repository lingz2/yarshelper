-- Gunung Anurika Teleport & Auto Summit + Stylish GUI
-- Delta Executor Ready

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CFrame tiap checkpoint
local CPs = {
    ["CP1"] = CFrame.new(135.192032, 140.966553, -175.245834, -0.527359784, -2.354429766e-09, -0.849642098, 8.16806345e-10, 1, -3.27806338e-09, 0.849642098, -2.422711816e-09, -0.527359784),
    ["CP2"] = CFrame.new(326.375885, 88.9806747, -433.956573, 0.76137346, 0, 0.648313582, 0, 1, 0, -0.648313582, 0, 0.76137346),
    ["CP3"] = CFrame.new(475.910278, 168.998825, -939.516602, 0.999993205, 1.82620236e-08, 0.00368272397, -1.85378148e-08, 1, 7.485356692e-08, -0.00368272397, -7.49213314e-08, 0.999993205),
    ["CP4"] = CFrame.new(930.097229, 132.571213, -626.028931, 0.647055387, 0, -0.762443006, 0, 1, 0, 0.762443006, 0, 0.647055387),
    ["CP5"] = CFrame.new(923.416199, 100.85717, 279.597198, 0.812660992, 0, -0.582736731, 0, 1, 0, 0.582736731, 0, 0.812660992),
    ["Summit"] = CFrame.new(250.567139, 318.749023, 674.083618, -0.736146212, -2.584927836e-08, 0.676822543, -7.11240622e-09, 1, 3.045629536e-08, -0.676822543, 1.76064496e-08, -0.736146212)
}

local teleportSpeed = 0.5 -- default 0.5s
local autoSummit = false
local activeButton = nil

-- GUI utama
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "GunungAnurikaGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 360)
MainFrame.Position = UDim2.new(0.7,0,0.3,0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Warna tombol tiap CP
local CPColors = {
    ["CP1"] = Color3.fromRGB(255,85,85),
    ["CP2"] = Color3.fromRGB(255,170,0),
    ["CP3"] = Color3.fromRGB(255,255,85),
    ["CP4"] = Color3.fromRGB(85,255,85),
    ["CP5"] = Color3.fromRGB(85,170,255),
    ["Summit"] = Color3.fromRGB(170,85,255)
}

-- Fungsi membuat tombol
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

-- Fungsi teleport
local function teleportTo(cframe)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframe
    end
end

-- Buat tombol tiap CP
local CPButtons = {}
for cpName, cpCFrame in pairs(CPs) do
    CPButtons[cpName] = createButton(cpName, MainFrame, function()
        teleportTo(cpCFrame)
        -- Highlight tombol yang aktif
        if activeButton then activeButton.BorderSizePixel = 0 end
        local btn = CPButtons[cpName]
        btn.BorderSizePixel = 3
        btn.BorderColor3 = Color3.fromRGB(255,255,255)
        activeButton = btn
    end)
end

-- Auto Summit Loop
local AutoButton = Instance.new("TextButton", MainFrame)
AutoButton.Size = UDim2.new(1, -10, 0, 40)
AutoButton.Text = "Toggle Auto Summit"
AutoButton.BackgroundColor3 = Color3.fromRGB(100,50,50)
AutoButton.TextColor3 = Color3.fromRGB(255,255,255)
AutoButton.Font = Enum.Font.SourceSansBold
AutoButton.TextSize = 16
AutoButton.BorderSizePixel = 0
AutoButton.MouseButton1Click:Connect(function()
    autoSummit = not autoSummit
    AutoButton.Text = autoSummit and "Auto Summit: ON" or "Auto Summit: OFF"
    if autoSummit then
        spawn(function()
            while autoSummit do
                for _, cpName in ipairs({"CP1","CP2","CP3","CP4","CP5","Summit"}) do
                    teleportTo(CPs[cpName])
                    -- Highlight tombol
                    if activeButton then activeButton.BorderSizePixel = 0 end
                    local btn = CPButtons[cpName]
                    btn.BorderSizePixel = 3
                    btn.BorderColor3 = Color3.fromRGB(255,255,255)
                    activeButton = btn
                    wait(teleportSpeed)
                end
            end
        end)
    end
end)

-- Slider Speed
local SpeedLabel = Instance.new("TextLabel", MainFrame)
SpeedLabel.Size = UDim2.new(1, -10, 0, 25)
SpeedLabel.Text = string.format("Teleport Speed: %.2fs", teleportSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextSize = 16

local SpeedSlider = Instance.new("Frame", MainFrame)
SpeedSlider.Size = UDim2.new(1, -10, 0, 25)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(80,80,80)

local SliderHandle = Instance.new("Frame", SpeedSlider)
SliderHandle.Size = UDim2.new((teleportSpeed-0.1)/0.9, 0, 1, 0)
SliderHandle.BackgroundColor3 = Color3.fromRGB(200,200,200)

-- Fungsi drag slider
local dragging = false
SliderHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
SliderHandle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mouseX = game.Players.LocalPlayer:GetMouse().X
        local pos = math.clamp(mouseX - SpeedSlider.AbsolutePosition.X, 0, SpeedSlider.AbsoluteSize.X)
        SliderHandle.Size = UDim2.new(pos / SpeedSlider.AbsoluteSize.X, 0, 1, 0)
        teleportSpeed = 0.1 + (0.9 * (pos / SpeedSlider.AbsoluteSize.X))
        SpeedLabel.Text = string.format("Teleport Speed: %.2fs", teleportSpeed)
    end
end)
