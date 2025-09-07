-- Gunung Batu Teleport GUI + Auto Summit (CP Delay + Summit Delay) + Status
-- Delta Executor Ready
-- Tekan [M] untuk toggle GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Data CP
local cps = {
    cp1  = CFrame.new(-165.121399, 4.23206806, -657.757263, 0.766828477, 2.463231576e-08, -0.641852021,
                      1.92095833e-08, 1, 6.132685836e-08, 0.641852021, -5.935689276e-08, 0.766828477),
    cp2  = CFrame.new(-121.60952, 8.50454998, 544.049377),
    cp3  = CFrame.new(-40.0167122, 392.432037, 673.959045),
    cp4  = CFrame.new(-296.999634, 484.432037, 779.003052),
    cp5  = CFrame.new(17.3621044, 572.231995, 663.503784),
    cp6  = CFrame.new(587.364868, 916.432007, 637.027405),
    cp7  = CFrame.new(283.5, 1196.43201, 181.5),
    cp8  = CFrame.new(552.105835, 1528.43201, -581.302246),
    cp9  = CFrame.new(332.142334, 1736.43201, -260.883789),
    cp10 = CFrame.new(290.354126, 1979.03186, -203.905533),
    cp11 = CFrame.new(616.488281, 3260.50879, -66.2258759)
}

-- Remote
local SendSummit = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SendSummit")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GunungBatuTP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 500)
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
scroll.Size = UDim2.new(1, -10, 1, -150)
scroll.Position = UDim2.new(0,5,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 0.1
scroll.BackgroundColor3 = Color3.fromRGB(35,35,45)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0,6)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Status label
local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(1,-20,0,24)
statusLabel.Position = UDim2.new(0,10,1,-105)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255,255,0)
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextSize = 14
statusLabel.Text = "Status: Idle"

-- Slider CP Delay
local cpLabel = Instance.new("TextLabel", main)
cpLabel.Size = UDim2.new(0.7,0,0,24)
cpLabel.Position = UDim2.new(0,10,1,-75)
cpLabel.BackgroundTransparency = 1
cpLabel.TextColor3 = Color3.fromRGB(255,255,255)
cpLabel.Font = Enum.Font.GothamSemibold
cpLabel.TextSize = 14

local cpDelay = 0.5
cpLabel.Text = "CP Delay: "..cpDelay.." s"

local cpSlider = Instance.new("TextBox", main)
cpSlider.Size = UDim2.new(0.25,0,0,24)
cpSlider.Position = UDim2.new(0.72,0,1,-75)
cpSlider.BackgroundColor3 = Color3.fromRGB(55,55,65)
cpSlider.TextColor3 = Color3.fromRGB(255,255,255)
cpSlider.Text = tostring(cpDelay)
cpSlider.Font = Enum.Font.GothamSemibold
cpSlider.TextSize = 14
Instance.new("UICorner", cpSlider).CornerRadius = UDim.new(0,6)

cpSlider.FocusLost:Connect(function()
    local val = tonumber(cpSlider.Text)
    if val and val >= 0.1 and val <= 1 then
        cpDelay = val
        cpLabel.Text = "CP Delay: "..cpDelay.." s"
    else
        cpSlider.Text = tostring(cpDelay)
    end
end)

-- Slider Summit Delay
local summitLabel = Instance.new("TextLabel", main)
summitLabel.Size = UDim2.new(0.7,0,0,24)
summitLabel.Position = UDim2.new(0,10,1,-45)
summitLabel.BackgroundTransparency = 1
summitLabel.TextColor3 = Color3.fromRGB(255,255,255)
summitLabel.Font = Enum.Font.GothamSemibold
summitLabel.TextSize = 14

local summitDelay = 0.7
summitLabel.Text = "Summit Delay: "..summitDelay.." s"

local summitSlider = Instance.new("TextBox", main)
summitSlider.Size = UDim2.new(0.25,0,0,24)
summitSlider.Position = UDim2.new(0.72,0,1,-45)
summitSlider.BackgroundColor3 = Color3.fromRGB(55,55,65)
summitSlider.TextColor3 = Color3.fromRGB(255,255,255)
summitSlider.Text = tostring(summitDelay)
summitSlider.Font = Enum.Font.GothamSemibold
summitSlider.TextSize = 14
Instance.new("UICorner", summitSlider).CornerRadius = UDim.new(0,6)

summitSlider.FocusLost:Connect(function()
    local val = tonumber(summitSlider.Text)
    if val and val >= 0.1 and val <= 1 then
        summitDelay = val
        summitLabel.Text = "Summit Delay: "..summitDelay.." s"
    else
        summitSlider.Text = tostring(summitDelay)
    end
end)

-- Fungsi teleport
local function tp(cf)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = cf
end

-- Fungsi trigger SendSummit (spam cepat)
local function triggerSendSummit()
    statusLabel.Text = "Status: Spam Summit..."
    for i = 1, 10 do
        local args = {1}
        pcall(function()
            SendSummit:FireServer(unpack(args))
        end)
        task.wait(summitDelay)
    end
    statusLabel.Text = "Status: Summit ✅"
end

-- Tombol
local order = {"cp2","cp3","cp4","cp5","cp6","cp7","cp8","cp9","cp10","cp11","SendSummit","Auto Summit"}
local autoSummitRunning = false
local loopDelay = 1 -- jeda setelah summit selesai sebelum balik ke cp2

for _,name in ipairs(order) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,36)
    btn.Text = name
    btn.BackgroundColor3 = (name=="SendSummit") and Color3.fromRGB(60,160,100)
                          or (name=="Auto Summit") and Color3.fromRGB(160,100,60)
                          or Color3.fromRGB(55,55,65)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        if name=="SendSummit" then
            triggerSendSummit()
        elseif name=="Auto Summit" then
            autoSummitRunning = not autoSummitRunning
            btn.Text = autoSummitRunning and "Stop Auto" or "Auto Summit"
            if autoSummitRunning then
                spawn(function()
                    while autoSummitRunning do
                        -- Naik CP2 - CP11
                        for i=2,11 do
                            if not autoSummitRunning then break end
                            statusLabel.Text = "Status: Naik CP"..i
                            tp(cps["cp"..i])
                            task.wait(cpDelay)
                        end
                        -- Spam Summit
                        if not autoSummitRunning then break end
                        triggerSendSummit()
                        task.wait(loopDelay)
                    end
                end)
            end
        else
            tp(cps[name])
        end
    end)
end

-- update scroll
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+10)
end)

-- toggle [M]
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
