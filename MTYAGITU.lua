-- Auto Summit Ultimate Persistent UI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Persistent UI function (re-attach on respawn)
local function CreateUI()
    if PlayerGui:FindFirstChild("AutoSummitUI") then
        return -- sudah ada
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoSummitUI"
    ScreenGui.Parent = PlayerGui

    -- Main Frame Scrollable
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

    -- Hide/Show UI
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

    -- draggable yars cakep
    local dragging = false
    local dragInput, mousePos, framePos
    ShowBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = ShowBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    ShowBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            ShowBtn.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    -- Hide/Show logic
    HideBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        ShowBtn.Visible = true
        TweenService:Create(ShowBtn, TweenInfo.new(0.5), {Size=UDim2.new(0,120,0,30), BackgroundTransparency=0}):Play()
    end)
    ShowBtn.MouseButton1Click:Connect(function()
        TweenService:Create(ShowBtn, TweenInfo.new(0.5), {Size=UDim2.new(0,100,0,25), BackgroundTransparency=1}):Play()
        wait(0.5)
        MainFrame.Visible = true
        ShowBtn.Visible = false
    end)

    -- Auto Loop Toggle (Slide On/Off)
    local function createToggle(name, parent)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(0, 230, 0, 30)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        toggleFrame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6,0,1,0)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = toggleFrame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0,60,0,25)
        slider.Position = UDim2.new(0.65,0,0.1,0)
        slider.BackgroundColor3 = Color3.fromRGB(80,80,80)
        slider.Parent = toggleFrame

        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0,25,0,25)
        knob.Position = UDim2.new(0,0,0,0)
        knob.Text = ""
        knob.BackgroundColor3 = Color3.fromRGB(200,50,50)
        knob.Parent = slider

        local state = false
        knob.MouseButton1Click:Connect(function()
            state = not state
            if state then
                knob.Position = UDim2.new(1, -25,0,0)
                knob.BackgroundColor3 = Color3.fromRGB(50,200,50)
            else
                knob.Position = UDim2.new(0,0,0,0)
                knob.BackgroundColor3 = Color3.fromRGB(200,50,50)
            end
        end)

        return function() return state end -- getter
    end

    local LoopViaCP = createToggle("Loop Via CP", Scroll)
    local LoopDirect = createToggle("Loop Direct Summit", Scroll)

    -- Teleport function
    local function notify(msg)
        game.StarterGui:SetCore("SendNotification",{Title="Auto Summit",Text=msg,Duration=2})
    end
    local function teleportTo(cf)
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            TweenService:Create(root, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame=cf}):Play()
            wait(math.random(10,30)/10)
            notify("Teleport berhasil!")
        end
    end

    -- CFrame table
    local checkpointsCFrame = {
        ["Basecamp"] = CFrame.new(-13, -82, -237),
        ["CP1"] = CFrame.new(-228,6,482),
        ["CP2"] = CFrame.new(-167,62,852),
        ["CP3"] = CFrame.new(541,346,848),
        ["CP4"] = CFrame.new(715,462,1409),
        ["CP5"] = CFrame.new(727,650,451),
        ["CP6"] = CFrame.new(476,682,61),
        ["CP7"] = CFrame.new(503,786,-579),
        ["CP8"] = CFrame.new(1233,860,-561),
        ["CP9"] = CFrame.new(1928,694,-530),
        ["CP10"]= CFrame.new(2519,906,-551),
        ["CP11"]= CFrame.new(3379,844,-538),
        ["CP12"]= CFrame.new(1928,694,-749),
        ["CP13"]= CFrame.new(1983,694,-1122),
        ["CP14"]= CFrame.new(1897,934,-1159),
        ["Summit"]= CFrame.new(1935,1345,-2070)
    }
    local checkpointsOrder = {"CP1","CP2","CP3","CP4","CP5","CP6","CP7","CP8","CP9","CP10","CP11","CP12","CP13","CP14","Summit"}

    -- Auto loop
    spawn(function()
        while true do
            if LoopViaCP() then
                teleportTo(checkpointsCFrame["Basecamp"])
                for _, cp in ipairs(checkpointsOrder) do
                    teleportTo(checkpointsCFrame[cp])
                end
                teleportTo(checkpointsCFrame["Basecamp"])
            elseif LoopDirect() then
                teleportTo(checkpointsCFrame["Basecamp"])
                teleportTo(checkpointsCFrame["Summit"])
                teleportTo(checkpointsCFrame["Basecamp"])
            end
            wait(1)
        end
    end)

    -- Manual teleport buttons
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
end

-- Initial UI
CreateUI()

-- Reattach on respawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    CreateUI()
end)
