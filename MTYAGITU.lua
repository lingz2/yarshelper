-- Auto Summit CFrame Ultra Final + Animasi Tombol
-- LocalScript di StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LocalPlayer = Players.LocalPlayer
local TweenTime = 0.5

-- CFrame tiap checkpoint + summit
local checkpointsCFrame = {
    ["Basecamp"] = CFrame.new(-13, -82.0019836, -237,0,0,1,0,1,0,-1,0,0),
    ["CP1"] = CFrame.new(-228, 5.99802494, 482,1,0,0,0,1,0,0,0,1),
    ["CP2"] = CFrame.new(-167.794037, 61.9980164, 851.62677,1,0,0,0,1,0,0,0,1),
    ["CP3"] = CFrame.new(541, 345.997986, 848,1,0,0,0,1,0,0,0,1),
    ["CP4"] = CFrame.new(715.126587, 461.997986, 1409.17212,1,0,0,0,1,0,0,0,1),
    ["CP5"] = CFrame.new(727, 649.997986, 451,1,0,0,0,1,0,0,0,1),
    ["CP6"] = CFrame.new(476, 681.997986, 61,1,0,0,0,1,0,0,0,1),
    ["CP7"] = CFrame.new(502.726746, 785.764587, -579,1,0,0,0,1,0,0,0,1),
    ["CP8"] = CFrame.new(1233, 859.953186, -561,1,0,0,0,1,0,0,0,1),
    ["CP9"] = CFrame.new(1927.70361, 694.211548, -529.572693,1,0,0,0,1,0,0,0,1),
    ["CP10"] = CFrame.new(2519.29712, 905.800842, -550.640564,0,0,1,0,1,0,-1,0,0),
    ["CP11"] = CFrame.new(3378.99536, 843.591553, -538,1,-6.017387926e-09,-2.67559083e-11,6.01738792e-09,1,-1.14802655e-11,2.67559083e-11,1.14802655e-11,1),
    ["CP12"] = CFrame.new(1928.22144, 694.483032, -749,1,1.00838221e-07,-1.35328726e-10,-1.00838221e-07,1,2.85971302e-10,1.35328748e-10,-2.85971302e-10,1),
    ["CP13"] = CFrame.new(1982.88025, 693.84906, -1122.42957,1,3.6866723e-08,-1.35344305e-10,-3.6866723e-08,1,1.08166559e-10,1.35344305e-10,-1.08166552e-10,1),
    ["CP14"] = CFrame.new(1896.76208, 934.387756, -1159.42957,1,-5.684786696e-08,-1.35344416e-10,5.68478669e-08,1,-1.66467229e-10,1.3534443e-10,1.66467215e-10,1),
    ["Summit"] = CFrame.new(1934.72192, 1345.24438, -2069.70532,0.997757912,0.0403336696,-0.0534070395,-3.06416204e-09,0.797998965,0.602658808,0.0669262037,-0.601307631,0.796209812)
}

local checkpointsOrder = {"CP1","CP2","CP3","CP4","CP5","CP6","CP7","CP8","CP9","CP10","CP11","CP12","CP13","CP14","Summit"}

-- UI scrollable
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitUI"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,250,0,300)
MainFrame.Position = UDim2.new(0,10,0.5,-150)
MainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1,0,1,0)
Scroll.CanvasSize = UDim2.new(0,0,0,1000)
Scroll.ScrollBarThickness = 8
Scroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.Parent = Scroll

-- Tombol Hide / Show
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 250,0,25)
HideBtn.Text = "Hide UI"
HideBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
HideBtn.TextColor3 = Color3.fromRGB(255,255,255)
HideBtn.Parent = Scroll

local ShowBtn = Instance.new("TextButton")
ShowBtn.Size = UDim2.new(0,100,0,25)
ShowBtn.Position = UDim2.new(0,10,0.5,-12)
ShowBtn.Text = "yars cakep"
ShowBtn.BackgroundColor3 = Color3.fromRGB(120,50,200)
ShowBtn.TextColor3 = Color3.fromRGB(255,255,255)
ShowBtn.Visible = false
ShowBtn.BackgroundTransparency = 1
ShowBtn.Parent = ScreenGui

-- Notifikasi
local function notify(msg)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Auto Summit",
        Text = msg,
        Duration = 2
    })
end

-- Fungsi teleport dengan delay 1-3 detik
local function teleportTo(cf)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local tween = TweenService:Create(root, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = cf})
        tween:Play()
        tween.Completed:Wait()
        wait(math.random(10,30)/10)
        notify("Teleport berhasil!")
    end
end

-- Animasi tombol muncul/hilang
local function showYarsButton()
    ShowBtn.Visible = true
    TweenService:Create(ShowBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(0,120,0,30), BackgroundTransparency=0}):Play()
end

local function hideYarsButton(callback)
    local tween = TweenService:Create(ShowBtn, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.new(0,100,0,25), BackgroundTransparency=1})
    tween:Play()
    tween.Completed:Connect(function()
        ShowBtn.Visible = false
        if callback then callback() end
    end)
end

-- Event Hide/Show UI
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    showYarsButton()
end)

ShowBtn.MouseButton1Click:Connect(function()
    hideYarsButton(function()
        MainFrame.Visible = true
    end)
end)

-- Auto loop
local AutoLoop = false
local AutoLoopMode = 1

local AutoLoopBtn = Instance.new("TextButton")
AutoLoopBtn.Size = UDim2.new(0,230,0,25)
AutoLoopBtn.BackgroundColor3 = Color3.fromRGB(70,120,70)
AutoLoopBtn.TextColor3 = Color3.fromRGB(255,255,255)
AutoLoopBtn.Text = "Start Auto Loop (Via CP)"
AutoLoopBtn.Parent = Scroll
AutoLoopBtn.MouseButton1Click:Connect(function()
    AutoLoop = not AutoLoop
    if AutoLoop then
        AutoLoopMode = 1
        AutoLoopBtn.Text = "Stop Auto Loop"
    else
        AutoLoopBtn.Text = "Start Auto Loop (Via CP)"
    end
end)

local DirectSummitBtn = Instance.new("TextButton")
DirectSummitBtn.Size = UDim2.new(0,230,0,25)
DirectSummitBtn.BackgroundColor3 = Color3.fromRGB(50,100,150)
DirectSummitBtn.TextColor3 = Color3.fromRGB(255,255,255)
DirectSummitBtn.Text = "Start Auto Loop (Direct Summit)"
DirectSummitBtn.Parent = Scroll
DirectSummitBtn.MouseButton1Click:Connect(function()
    AutoLoop = not AutoLoop
    if AutoLoop then
        AutoLoopMode = 2
        DirectSummitBtn.Text = "Stop Auto Loop"
    else
        DirectSummitBtn.Text = "Start Auto Loop (Direct Summit)"
    end
end)

-- Auto loop logic
spawn(function()
    while true do
        if AutoLoop then
            teleportTo(checkpointsCFrame["Basecamp"])
            wait(0.5)
            if AutoLoopMode == 1 then
                for _, cp in ipairs(checkpointsOrder) do
                    teleportTo(checkpointsCFrame[cp])
                end
            else
                teleportTo(checkpointsCFrame["Summit"])
            end
            teleportTo(checkpointsCFrame["Basecamp"])
            wait(1)
        else
            wait(1)
        end
    end
end)

-- Tombol teleport manual
for name, cf in pairs(checkpointsCFrame) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,230,0,25)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = "Teleport ke "..name
    btn.Parent = Scroll

    btn.MouseButton1Click:Connect(function()
        teleportTo(cf)
    end)
end

