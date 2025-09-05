-- Gunung Batu Teleport GUI + Auto Summit (Delay CP & Summit Terpisah)
-- Tekan [M] untuk toggle GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Data CP
local cps = {
    cp2  = CFrame.new(-121.60952, 8.50454998, 544.049377),
    cp3  = CFrame.new(-40.0167122, 392.432037, 673.959045),
    cp4  = CFrame.new(-296.999634, 484.432037, 779.003052),
    cp5  = CFrame.new(18.0000038, 572.429688, 692),
    cp6  = CFrame.new(595.273804, 916.432007, 620.967712),
    cp7  = CFrame.new(283.5, 1196.43201, 181.5),
    cp8  = CFrame.new(552.105835, 1528.43201, -581.302246),
    cp9  = CFrame.new(332.142334, 1736.43201, -260.883789),
    cp10 = CFrame.new(290.354126, 1979.03186, -203.905533),
    cp11 = CFrame.new(616.488281, 3260.50879, -66.2258759),
    Puncak = CFrame.new(
        408.080811, 3261.43188, -110.906059,
        0.664278328, 3.246494276e-08, 0.74748534,
        3.87810708e-08, 1, -7.789633836e-08,
        -0.74748534, 8.073312336e-08, 0.664278328
    )
}

-- Remote
local SendSummit = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SendSummit")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GunungBatuTP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 480)
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 36)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Gunung Batu Teleport"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,3)
close.Text = "X"
close.TextColor3 = Color3.new(1,0.4,0.4)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -140)
scroll.Position = UDim2.new(0,5,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 0.1
scroll.BackgroundColor3 = Color3.fromRGB(35,35,45)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0,6)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Status
local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(1,-20,0,24)
statusLabel.Position = UDim2.new(0,10,1,-95)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255,255,0)
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextSize = 14
statusLabel.Text = "Status: Idle"

local counterLabel = Instance.new("TextLabel", main)
counterLabel.Size = UDim2.new(1,-20,0,24)
counterLabel.Position = UDim2.new(0,10,1,-70)
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = Color3.fromRGB(0,255,0)
counterLabel.Font = Enum.Font.GothamSemibold
counterLabel.TextSize = 14
counterLabel.Text = "Summit +0"

-- Delay Settings
local cpDelay, summitDelay = 0.5, 0.7

local cpLabel = Instance.new("TextLabel", main)
cpLabel.Size = UDim2.new(0.6,0,0,24)
cpLabel.Position = UDim2.new(0,10,1,-45)
cpLabel.BackgroundTransparency = 1
cpLabel.TextColor3 = Color3.fromRGB(255,255,255)
cpLabel.Font = Enum.Font.GothamSemibold
cpLabel.TextSize = 14
cpLabel.Text = "CP Delay: "..cpDelay.." s"

local cpBox = Instance.new("TextBox", main)
cpBox.Size = UDim2.new(0.3,0,0,24)
cpBox.Position = UDim2.new(0.65,0,1,-45)
cpBox.BackgroundColor3 = Color3.fromRGB(55,55,65)
cpBox.TextColor3 = Color3.fromRGB(255,255,255)
cpBox.Text = tostring(cpDelay)
cpBox.Font = Enum.Font.GothamSemibold
cpBox.TextSize = 14
Instance.new("UICorner", cpBox).CornerRadius = UDim.new(0,6)

cpBox.FocusLost:Connect(function()
    local val = tonumber(cpBox.Text)
    if val and val >= 0.1 and val <= 1 then
        cpDelay = val
        cpLabel.Text = "CP Delay: "..cpDelay.." s"
    else
        cpBox.Text = tostring(cpDelay)
    end
end)

local summitLabel = Instance.new("TextLabel", main)
summitLabel.Size = UDim2.new(0.6,0,0,24)
summitLabel.Position = UDim2.new(0,10,1,-20)
summitLabel.BackgroundTransparency = 1
summitLabel.TextColor3 = Color3.fromRGB(255,255,255)
summitLabel.Font = Enum.Font.GothamSemibold
summitLabel.TextSize = 14
summitLabel.Text = "Summit Delay: "..summitDelay.." s"

local summitBox = Instance.new("TextBox", main)
summitBox.Size = UDim2.new(0.3,0,0,24)
summitBox.Position = UDim2.new(0.65,0,1,-20)
summitBox.BackgroundColor3 = Color3.fromRGB(55,55,65)
summitBox.TextColor3 = Color3.fromRGB(255,255,255)
summitBox.Text = tostring(summitDelay)
summitBox.Font = Enum.Font.GothamSemibold
summitBox.TextSize = 14
Instance.new("UICorner", summitBox).CornerRadius = UDim.new(0,6)

summitBox.FocusLost:Connect(function()
    local val = tonumber(summitBox.Text)
    if val and val >= 0.1 and val <= 1 then
        summitDelay = val
        summitLabel.Text = "Summit Delay: "..summitDelay.." s"
    else
        summitBox.Text = tostring(summitDelay)
    end
end)

-- Fungsi
local function tp(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = cf
end

local autoSummit = false

local function sendSummitUntilSuccess()
    local stats = player:WaitForChild("leaderstats")
    local summitVal = stats:FindFirstChild("Summit")
    local before = summitVal and summitVal.Value or 0
    local success = false

    while autoSummit and not success do
        statusLabel.Text = "Status: Kirim Summit..."
        SendSummit:FireServer(1)
        task.wait(summitDelay)
        if summitVal and summitVal.Value > before then
            success = true
            counterLabel.Text = "Summit +"..summitVal.Value
            statusLabel.Text = "Status: Summit +1 ✅"
        end
    end
end

local function runAutoSummit()
    spawn(function()
        while autoSummit do
            for i=2,11 do
                if not autoSummit then break end
                statusLabel.Text = "Status: CP"..i
                tp(cps["cp"..i])
                task.wait(cpDelay)
            end
            if not autoSummit then break end
            statusLabel.Text = "Status: Puncak"
            tp(cps["Puncak"])
            task.wait(cpDelay)
            sendSummitUntilSuccess()
        end
    end)
end

-- Tombol
local order = {"cp2","cp3","cp4","cp5","cp6","cp7","cp8","cp9","cp10","cp11","Puncak","SendSummit","Auto Summit"}

for _,name in ipairs(order) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,36)
    btn.Text = name
    btn.BackgroundColor3 = (name=="Puncak") and Color3.fromRGB(100,60,160)
                            or (name=="SendSummit") and Color3.fromRGB(60,160,100)
                            or (name=="Auto Summit") and Color3.fromRGB(160,100,60)
                            or Color3.fromRGB(55,55,65)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        if name=="Puncak" then
            tp(cps["Puncak"])
        elseif name=="SendSummit" then
            sendSummitUntilSuccess()
        elseif name=="Auto Summit" then
            autoSummit = not autoSummit
            btn.Text = autoSummit and "Stop Auto" or "Auto Summit"
            if autoSummit then runAutoSummit() end
        else
            tp(cps[name])
        end
    end)
end

-- Scroll auto update
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+10)
end)

-- Toggle [M]
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
