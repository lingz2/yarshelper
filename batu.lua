-- Gunung Batu Teleport GUI + Auto Summit (Final Revisi Full)
-- Tekan [M] untuk toggle GUI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CP CFrames
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
gui.Name = "GunungBatuFinal"
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

-- Status Label
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,1,-95)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200,200,255)
status.Font = Enum.Font.GothamSemibold
status.TextSize = 14
status.Text = "Status: Idle"

-- Delay default
local cpDelay = 0.5
local summitDelay = 0.7
local autoSummitRunning = false

-- Fungsi teleport
local function tp(cf, label)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = cf
    if label then
        status.Text = "Status: Teleporting "..label
    end
end

-- Fungsi SendSummit + cek berhasil
local function doSummit()
    local stats = player:WaitForChild("leaderstats")
    local summitVal = stats:FindFirstChild("Summit")
    local stageVal = stats:FindFirstChild("Stage")

    local oldSummit = summitVal and summitVal.Value or 0
    local oldStage = stageVal and stageVal.Value or 0

    tp(cps["Puncak"], "Puncak")
    task.wait(summitDelay)

    status.Text = "Status: Waiting Summit…"

    -- Spam sampai sukses
    while autoSummitRunning do
        SendSummit:FireServer(1)
        task.wait(summitDelay)

        if summitVal and summitVal.Value > oldSummit then
            status.Text = "✅ Summit +1!"
            break
        end
        if stageVal and stageVal.Value < oldStage then
            status.Text = "✅ Summit (Stage Reset)!"
            break
        end
    end
end

-- Tombol manual
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
        if name=="SendSummit" then
            doSummit()
        elseif name=="Auto Summit" then
            autoSummitRunning = not autoSummitRunning
            btn.Text = autoSummitRunning and "Stop Auto" or "Auto Summit"
            status.Text = autoSummitRunning and "Status: Auto Summit started" or "Status: Stopped."
            if autoSummitRunning then
                spawn(function()
                    while autoSummitRunning do
                        for i=2,11 do
                            if not autoSummitRunning then break end
                            tp(cps["cp"..i], "CP"..i)
                            task.wait(cpDelay)
                        end
                        if not autoSummitRunning then break end
                        doSummit()
                        task.wait(cpDelay)
                    end
                end)
            end
        else
            tp(cps[name], name)
        end
    end)
end

-- Slider CP Delay
local sliderLabel1 = Instance.new("TextLabel", main)
sliderLabel1.Size = UDim2.new(0.7,0,0,24)
sliderLabel1.Position = UDim2.new(0,10,1,-65)
sliderLabel1.BackgroundTransparency = 1
sliderLabel1.TextColor3 = Color3.fromRGB(255,255,255)
sliderLabel1.Font = Enum.Font.GothamSemibold
sliderLabel1.TextSize = 14
sliderLabel1.Text = "CP Delay: "..cpDelay.." s"

local slider1 = Instance.new("TextBox", main)
slider1.Size = UDim2.new(0.25,0,0,24)
slider1.Position = UDim2.new(0.72,0,1,-65)
slider1.BackgroundColor3 = Color3.fromRGB(55,55,65)
slider1.TextColor3 = Color3.fromRGB(255,255,255)
slider1.Text = tostring(cpDelay)
slider1.Font = Enum.Font.GothamSemibold
slider1.TextSize = 14
Instance.new("UICorner", slider1).CornerRadius = UDim.new(0,6)

slider1.FocusLost:Connect(function()
    local val = tonumber(slider1.Text)
    if val and val >= 0.1 and val <= 1 then
        cpDelay = val
        sliderLabel1.Text = "CP Delay: "..cpDelay.." s"
    else
        slider1.Text = tostring(cpDelay)
    end
end)

-- Slider Summit Delay
local sliderLabel2 = Instance.new("TextLabel", main)
sliderLabel2.Size = UDim2.new(0.7,0,0,24)
sliderLabel2.Position = UDim2.new(0,10,1,-35)
sliderLabel2.BackgroundTransparency = 1
sliderLabel2.TextColor3 = Color3.fromRGB(255,255,255)
sliderLabel2.Font = Enum.Font.GothamSemibold
sliderLabel2.TextSize = 14
sliderLabel2.Text = "Summit Delay: "..summitDelay.." s"

local slider2 = Instance.new("TextBox", main)
slider2.Size = UDim2.new(0.25,0,0,24)
slider2.Position = UDim2.new(0.72,0,1,-35)
slider2.BackgroundColor3 = Color3.fromRGB(55,55,65)
slider2.TextColor3 = Color3.fromRGB(255,255,255)
slider2.Text = tostring(summitDelay)
slider2.Font = Enum.Font.GothamSemibold
slider2.TextSize = 14
Instance.new("UICorner", slider2).CornerRadius = UDim.new(0,6)

slider2.FocusLost:Connect(function()
    local val = tonumber(slider2.Text)
    if val and val >= 0.3 and val <= 1 then
        summitDelay = val
        sliderLabel2.Text = "Summit Delay: "..summitDelay.." s"
    else
        slider2.Text = tostring(summitDelay)
    end
end)

-- update scroll
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+10)
end)

-- close
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- toggle [M]
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
