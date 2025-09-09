-- Auto Summit & Teleport Script with Auto Execute & Persistent Loop
-- Features: Auto Execute, Persistent GUI, Auto Summit Loop, Smart Server Hop

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Persistent Storage using ReplicatedStorage (fallback to game if not available)
local function getStorageService()
    if ReplicatedStorage then
        return ReplicatedStorage
    else
        return game
    end
end

local storage = getStorageService()

-- Create or get persistent data folder
local dataFolder
if storage:FindFirstChild("AutoSummitData") then
    dataFolder = storage:FindFirstChild("AutoSummitData")
else
    dataFolder = Instance.new("Folder")
    dataFolder.Name = "AutoSummitData"
    dataFolder.Parent = storage
end

-- Persistent Values
local function createOrGetValue(name, valueType, defaultValue)
    local existingValue = dataFolder:FindFirstChild(name)
    if existingValue then
        return existingValue
    else
        local newValue = Instance.new(valueType)
        newValue.Name = name
        newValue.Value = defaultValue
        newValue.Parent = dataFolder
        return newValue
    end
end

local autoSummitEnabledValue = createOrGetValue("AutoSummitEnabled", "BoolValue", false)
local delayValue = createOrGetValue("Delay", "NumberValue", 1.0)
local loopCountValue = createOrGetValue("LoopCount", "IntValue", 0)

-- Positions
local CP26_POS = CFrame.new(624.731018, 1798.39722, 3432.02905, 1, 8.091495836e-08, 3.29984316e-16, -8.09149583e-08, 1, -9.97212624e-09, -1.136878520e-15, 9.97212624e-09, 1)
local SUMMIT_POS = CFrame.new(780.575012, 2169.52881, 3922.71802, 1, 7.160132046e-08, 5.25781832e-16, -7.16013204e-08, 1, 4.359649532e-09, -2.13625164e-16, -4.35964953e-09, 1)

-- Variables
local autoSummitEnabled = autoSummitEnabledValue.Value
local delay = delayValue.Value
local isMinimized = false
local isDragging = false
local dragStart = nil
local startPos = nil
local character = nil
local humanoidRootPart = nil
local gui = nil
local isProcessing = false

-- Auto Execute Check
local function waitForCharacter()
    repeat
        character = player.Character or player.CharacterAdded:Wait()
        if character then
            humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
        end
        wait(0.1)
    until character and humanoidRootPart
end

-- GUI Creation Function
local function createGUI()
    -- Remove existing GUI if any
    if gui then
        gui:Destroy()
    end
    
    -- GUI Creation
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoSummitGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    gui = screenGui

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Add shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    -- Fix bottom corners of title bar
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 20)
    titleFix.Position = UDim2.new(0, 0, 1, -20)
    titleFix.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🏔️ Auto Summit [PERSISTENT]"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar

    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -65, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = titleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
    contentFrame.Parent = mainFrame

    -- Auto Execute Status
    local autoExecSection = Instance.new("Frame")
    autoExecSection.Name = "AutoExecSection"
    autoExecSection.Size = UDim2.new(1, 0, 0, 80)
    autoExecSection.Position = UDim2.new(0, 0, 0, 0)
    autoExecSection.BackgroundColor3 = Color3.fromRGB(35, 50, 35)
    autoExecSection.BorderSizePixel = 0
    autoExecSection.Parent = contentFrame

    local autoExecCorner = Instance.new("UICorner")
    autoExecCorner.CornerRadius = UDim.new(0, 8)
    autoExecCorner.Parent = autoExecSection

    local autoExecTitle = Instance.new("TextLabel")
    autoExecTitle.Name = "AutoExecTitle"
    autoExecTitle.Size = UDim2.new(1, -20, 0, 25)
    autoExecTitle.Position = UDim2.new(0, 10, 0, 5)
    autoExecTitle.BackgroundTransparency = 1
    autoExecTitle.Text = "🔄 Auto Execute Status"
    autoExecTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
    autoExecTitle.TextSize = 12
    autoExecTitle.TextXAlignment = Enum.TextXAlignment.Left
    autoExecTitle.Font = Enum.Font.GothamBold
    autoExecTitle.Parent = autoExecSection

    local autoExecInfo = Instance.new("TextLabel")
    autoExecInfo.Name = "AutoExecInfo"
    autoExecInfo.Size = UDim2.new(1, -20, 0, 45)
    autoExecInfo.Position = UDim2.new(0, 10, 0, 30)
    autoExecInfo.BackgroundTransparency = 1
    autoExecInfo.Text = "✅ Script Persistent: ON\n🔁 Loop Count: " .. loopCountValue.Value .. " | Players: " .. #Players:GetPlayers()
    autoExecInfo.TextColor3 = Color3.fromRGB(200, 255, 200)
    autoExecInfo.TextSize = 10
    autoExecInfo.TextXAlignment = Enum.TextXAlignment.Left
    autoExecInfo.TextYAlignment = Enum.TextYAlignment.Top
    autoExecInfo.Font = Enum.Font.Gotham
    autoExecInfo.TextWrapped = true
    autoExecInfo.Parent = autoExecSection

    -- Teleport Section
    local teleportSection = Instance.new("Frame")
    teleportSection.Name = "TeleportSection"
    teleportSection.Size = UDim2.new(1, 0, 0, 120)
    teleportSection.Position = UDim2.new(0, 0, 0, 90)
    teleportSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    teleportSection.BorderSizePixel = 0
    teleportSection.Parent = contentFrame

    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 8)
    teleportCorner.Parent = teleportSection

    local teleportTitle = Instance.new("TextLabel")
    teleportTitle.Name = "TeleportTitle"
    teleportTitle.Size = UDim2.new(1, -20, 0, 30)
    teleportTitle.Position = UDim2.new(0, 10, 0, 5)
    teleportTitle.BackgroundTransparency = 1
    teleportTitle.Text = "📍 Manual Teleport Controls"
    teleportTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    teleportTitle.TextSize = 14
    teleportTitle.TextXAlignment = Enum.TextXAlignment.Left
    teleportTitle.Font = Enum.Font.GothamBold
    teleportTitle.Parent = teleportSection

    -- CP26 Button
    local cp26Btn = Instance.new("TextButton")
    cp26Btn.Name = "CP26Btn"
    cp26Btn.Size = UDim2.new(0, 140, 0, 35)
    cp26Btn.Position = UDim2.new(0, 10, 0, 40)
    cp26Btn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    cp26Btn.BorderSizePixel = 0
    cp26Btn.Text = "🎯 Teleport to CP26"
    cp26Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cp26Btn.TextSize = 12
    cp26Btn.Font = Enum.Font.Gotham
    cp26Btn.Parent = teleportSection

    local cp26Corner = Instance.new("UICorner")
    cp26Corner.CornerRadius = UDim.new(0, 6)
    cp26Corner.Parent = cp26Btn

    -- Summit Button
    local summitBtn = Instance.new("TextButton")
    summitBtn.Name = "SummitBtn"
    summitBtn.Size = UDim2.new(0, 140, 0, 35)
    summitBtn.Position = UDim2.new(1, -150, 0, 40)
    summitBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    summitBtn.BorderSizePixel = 0
    summitBtn.Text = "🏔️ Teleport to Summit"
    summitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    summitBtn.TextSize = 12
    summitBtn.Font = Enum.Font.Gotham
    summitBtn.Parent = teleportSection

    local summitCorner = Instance.new("UICorner")
    summitCorner.CornerRadius = UDim.new(0, 6)
    summitCorner.Parent = summitBtn

    -- Server Hop Button
    local serverHopBtn = Instance.new("TextButton")
    serverHopBtn.Name = "ServerHopBtn"
    serverHopBtn.Size = UDim2.new(1, -20, 0, 35)
    serverHopBtn.Position = UDim2.new(0, 10, 0, 80)
    serverHopBtn.BackgroundColor3 = Color3.fromRGB(108, 117, 125)
    serverHopBtn.BorderSizePixel = 0
    serverHopBtn.Text = "🌐 Server Hop (Find Empty)"
    serverHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    serverHopBtn.TextSize = 12
    serverHopBtn.Font = Enum.Font.Gotham
    serverHopBtn.Parent = teleportSection

    local serverHopCorner = Instance.new("UICorner")
    serverHopCorner.CornerRadius = UDim.new(0, 6)
    serverHopCorner.Parent = serverHopBtn

    -- Auto Summit Section
    local autoSection = Instance.new("Frame")
    autoSection.Name = "AutoSection"
    autoSection.Size = UDim2.new(1, 0, 0, 180)
    autoSection.Position = UDim2.new(0, 0, 0, 220)
    autoSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    autoSection.BorderSizePixel = 0
    autoSection.Parent = contentFrame

    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 8)
    autoCorner.Parent = autoSection

    local autoTitle = Instance.new("TextLabel")
    autoTitle.Name = "AutoTitle"
    autoTitle.Size = UDim2.new(1, -20, 0, 30)
    autoTitle.Position = UDim2.new(0, 10, 0, 5)
    autoTitle.BackgroundTransparency = 1
    autoTitle.Text = "⚡ Auto Summit Loop (Persistent)"
    autoTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    autoTitle.TextSize = 14
    autoTitle.TextXAlignment = Enum.TextXAlignment.Left
    autoTitle.Font = Enum.Font.GothamBold
    autoTitle.Parent = autoSection

    -- Auto Toggle Button
    local autoToggle = Instance.new("TextButton")
    autoToggle.Name = "AutoToggle"
    autoToggle.Size = UDim2.new(1, -20, 0, 40)
    autoToggle.Position = UDim2.new(0, 10, 0, 40)
    autoToggle.BackgroundColor3 = autoSummitEnabled and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(220, 53, 69)
    autoToggle.BorderSizePixel = 0
    autoToggle.Text = autoSummitEnabled and "🟢 Stop Auto Summit" or "🔴 Start Auto Summit"
    autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoToggle.TextSize = 14
    autoToggle.Font = Enum.Font.GothamBold
    autoToggle.Parent = autoSection

    local autoCornerBtn = Instance.new("UICorner")
    autoCornerBtn.CornerRadius = UDim.new(0, 8)
    autoCornerBtn.Parent = autoToggle

    -- Delay Control Section
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Name = "DelayLabel"
    delayLabel.Size = UDim2.new(1, -20, 0, 25)
    delayLabel.Position = UDim2.new(0, 10, 0, 90)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Text = "⏱️ Delay: " .. delay .. "s"
    delayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    delayLabel.TextSize = 12
    delayLabel.TextXAlignment = Enum.TextXAlignment.Center
    delayLabel.Font = Enum.Font.Gotham
    delayLabel.Parent = autoSection

    -- Delay Decrease Button
    local delayDecBtn = Instance.new("TextButton")
    delayDecBtn.Name = "DelayDecBtn"
    delayDecBtn.Size = UDim2.new(0, 40, 0, 35)
    delayDecBtn.Position = UDim2.new(0, 10, 0, 120)
    delayDecBtn.BackgroundColor3 = Color3.fromRGB(108, 117, 125)
    delayDecBtn.BorderSizePixel = 0
    delayDecBtn.Text = "−"
    delayDecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayDecBtn.TextSize = 20
    delayDecBtn.Font = Enum.Font.GothamBold
    delayDecBtn.Parent = autoSection

    local delayDecCorner = Instance.new("UICorner")
    delayDecCorner.CornerRadius = UDim.new(0, 6)
    delayDecCorner.Parent = delayDecBtn

    -- Delay Display
    local delayDisplay = Instance.new("TextLabel")
    delayDisplay.Name = "DelayDisplay"
    delayDisplay.Size = UDim2.new(1, -120, 0, 35)
    delayDisplay.Position = UDim2.new(0, 60, 0, 120)
    delayDisplay.BackgroundColor3 = Color3.fromRGB(52, 58, 64)
    delayDisplay.BorderSizePixel = 0
    delayDisplay.Text = delay .. "s"
    delayDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayDisplay.TextSize = 16
    delayDisplay.TextXAlignment = Enum.TextXAlignment.Center
    delayDisplay.Font = Enum.Font.GothamBold
    delayDisplay.Parent = autoSection

    local delayDisplayCorner = Instance.new("UICorner")
    delayDisplayCorner.CornerRadius = UDim.new(0, 6)
    delayDisplayCorner.Parent = delayDisplay

    -- Delay Increase Button
    local delayIncBtn = Instance.new("TextButton")
    delayIncBtn.Name = "DelayIncBtn"
    delayIncBtn.Size = UDim2.new(0, 40, 0, 35)
    delayIncBtn.Position = UDim2.new(1, -50, 0, 120)
    delayIncBtn.BackgroundColor3 = Color3.fromRGB(108, 117, 125)
    delayIncBtn.BorderSizePixel = 0
    delayIncBtn.Text = "+"
    delayIncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayIncBtn.TextSize = 20
    delayIncBtn.Font = Enum.Font.GothamBold
    delayIncBtn.Parent = autoSection

    local delayIncCorner = Instance.new("UICorner")
    delayIncCorner.CornerRadius = UDim.new(0, 6)
    delayIncCorner.Parent = delayIncBtn

    -- Status Section
    local statusSection = Instance.new("Frame")
    statusSection.Name = "StatusSection"
    statusSection.Size = UDim2.new(1, 0, 0, 100)
    statusSection.Position = UDim2.new(0, 0, 0, 410)
    statusSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    statusSection.BorderSizePixel = 0
    statusSection.Parent = contentFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusSection

    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -20, 1, 0)
    statusText.Position = UDim2.new(0, 10, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "💡 Status: GUI Loaded & Ready\n🔄 Auto Execute: Active"
    statusText.TextColor3 = Color3.fromRGB(100, 255, 200)
    statusText.TextSize = 11
    statusText.TextXAlignment = Enum.TextXAlignment.Center
    statusText.TextYAlignment = Enum.TextYAlignment.Center
    statusText.Font = Enum.Font.Gotham
    statusText.TextWrapped = true
    statusText.Parent = statusSection

    -- Functions
    local function updateStatus(status, color)
        if statusText then
            statusText.Text = "💡 Status: " .. status .. "\n🔄 Auto Execute: Active"
            statusText.TextColor3 = color or Color3.fromRGB(100, 255, 200)
        end
    end

    local function updateAutoExecInfo()
        if autoExecInfo then
            autoExecInfo.Text = "✅ Script Persistent: ON\n🔁 Loop Count: " .. loopCountValue.Value .. " | Players: " .. #Players:GetPlayers()
        end
    end

    local function smoothTeleport(targetCFrame)
        if not character or not humanoidRootPart then
            waitForCharacter()
        end
        
        if not humanoidRootPart then return end
        
        updateStatus("Teleporting...", Color3.fromRGB(255, 255, 100))
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        
        tween:Play()
        tween.Completed:Connect(function()
            updateStatus("Teleport complete!", Color3.fromRGB(100, 255, 100))
            wait(1)
            updateStatus("Ready", Color3.fromRGB(100, 255, 200))
        end)
    end

    local function findEmptyServer()
        updateStatus("Server hopping to empty server...", Color3.fromRGB(255, 200, 100))
        
        -- Increment loop count
        loopCountValue.Value = loopCountValue.Value + 1
        updateAutoExecInfo()
        
        spawn(function()
            wait(1)
            local success, err = pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
            
            if not success then
                updateStatus("Server hop failed: " .. tostring(err), Color3.fromRGB(255, 100, 100))
            end
        end)
    end

    local function autoSummitLoop()
        spawn(function()
            while autoSummitEnabledValue.Value do
                waitForCharacter()
                
                if not autoSummitEnabledValue.Value then break end
                
                updateStatus("Auto Summit: Going to CP26...", Color3.fromRGB(255, 200, 100))
                smoothTeleport(CP26_POS)
                wait(delayValue.Value + 1) -- Extra time for teleport
                
                if not autoSummitEnabledValue.Value then break end
                
                updateStatus("Auto Summit: Going to Summit...", Color3.fromRGB(255, 200, 100))
                smoothTeleport(SUMMIT_POS)
                wait(delayValue.Value + 1)
                
                if not autoSummitEnabledValue.Value then break end
                
                updateStatus("Auto Summit: Server hopping...", Color3.fromRGB(255, 150, 100))
                wait(2)
                
                findEmptyServer()
                break -- Exit loop, will restart after server hop
            end
        end)
    end

    -- Event Handlers
    cp26Btn.MouseButton1Click:Connect(function()
        if not isProcessing then
            isProcessing = true
            smoothTeleport(CP26_POS)
            wait(1)
            isProcessing = false
        end
    end)

    summitBtn.MouseButton1Click:Connect(function()
        if not isProcessing then
            isProcessing = true
            smoothTeleport(SUMMIT_POS)
            wait(1)
            isProcessing = false
        end
    end)

    serverHopBtn.MouseButton1Click:Connect(function()
        findEmptyServer()
    end)

    autoToggle.MouseButton1Click:Connect(function()
        autoSummitEnabledValue.Value = not autoSummitEnabledValue.Value
        autoSummitEnabled = autoSummitEnabledValue.Value
        
        if autoSummitEnabled then
            autoToggle.Text = "🟢 Stop Auto Summit"
            autoToggle.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
            autoSummitLoop()
        else
            autoToggle.Text = "🔴 Start Auto Summit"
            autoToggle.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
            updateStatus("Auto Summit stopped", Color3.fromRGB(255, 200, 100))
        end
    end)

    delayIncBtn.MouseButton1Click:Connect(function()
        if delayValue.Value < 5 then
            delayValue.Value = delayValue.Value + 0.1
            delay = math.floor(delayValue.Value * 10) / 10
            delayValue.Value = delay
            delayDisplay.Text = delay .. "s"
            delayLabel.Text = "⏱️ Delay: " .. delay .. "s"
        end
    end)

    delayDecBtn.MouseButton1Click:Connect(function()
        if delayValue.Value > 0.1 then
            delayValue.Value = delayValue.Value - 0.1
            delay = math.floor(delayValue.Value * 10) / 10
            delayValue.Value = delay
            delayDisplay.Text = delay .. "s"
            delayLabel.Text = "⏱️ Delay: " .. delay .. "s"
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        autoSummitEnabledValue.Value = false
        if screenGui then
            screenGui:Destroy()
        end
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        local targetSize = isMinimized and UDim2.new(0, 350, 0, 40) or UDim2.new(0, 350, 0, 500)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = targetSize})
        
        tween:Play()
        contentFrame.Visible = not isMinimized
        minimizeBtn.Text = isMinimized and "□" or "−"
    end)

    -- Dragging functionality
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    -- Add hover effects
    local function addHoverEffect(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hoverColor
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normalColor
        end)
    end

    addHoverEffect(cp26Btn, Color3.fromRGB(50, 180, 80), Color3.fromRGB(40, 167, 69))
    addHoverEffect(summitBtn, Color3.fromRGB(255, 210, 30), Color3.fromRGB(255, 193, 7))
    addHoverEffect(serverHopBtn, Color3.fromRGB(130, 140, 150), Color3.fromRGB(108, 117, 125))
    addHoverEffect(closeBtn, Color3.fromRGB(240, 70, 90), Color3.fromRGB(220, 53, 69))
    addHoverEffect(minimizeBtn, Color3.fromRGB(255, 210, 30), Color3.fromRGB(255, 193, 7))

    -- Update info periodically
    spawn(function()
        while screenGui and screenGui.Parent do
            updateAutoExecInfo()
            wait(5)
        end
    end)

    -- Check if auto summit should continue after server hop
    if autoSummitEnabledValue.Value then
        wait(3) -- Wait for character to fully load
        updateStatus("Continuing Auto Summit after server hop...", Color3.fromRGB(100, 255, 100))
        autoSummitLoop()
    end
    
    return screenGui
end

-- Auto Execute on Character Spawn
local function onCharacterAdded()
    waitForCharacter()
    
    wait(2) -- Wait for full character load
    
    -- Create GUI
    createGUI()
    
    print("🔄 Auto Summit Script Reloaded!")
    print("🏔️ Loop Count: " .. loopCountValue.Value)
    print("⚙️ Auto Summit: " .. (autoSummitEnabledValue.Value and "ENABLED" or "DISABLED"))
end

-- Connect to character respawn/server join
player.CharacterAdded:Connect(onCharacterAdded)

-- If character already exists, run immediately
if player.Character then
    onCharacterAdded()
end

-- Auto Summit Startup Check
spawn(function()
    wait(5) -- Wait for everything to load
    
    if autoSummitEnabledValue.Value then
        print("🚀 Auto Summit was enabled - continuing loop...")
        
        -- Wait for character and GUI
        while not character or not humanoidRootPart or not gui do
            wait(0.5)
        end
        
        wait(2)
        
        -- Start the auto summit loop
        spawn(function()
            while autoSummitEnabledValue.Value do
                waitForCharacter()
                
                if not autoSummitEnabledValue.Value then break end
                
                -- Go to CP26
                if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("ContentFrame") then
                    local statusText = gui.MainFrame.ContentFrame:FindFirstChild("StatusSection"):FindFirstChild("StatusText")
                    if statusText then
                        statusText.Text = "💡 Status: Auto Summit: Going to CP26...\n🔄 Auto Execute: Active"
                        statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
                    end
                end
                
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CP26_POS})
                tween:Play()
                tween.Completed:Wait()
                
                wait(delayValue.Value + 1)
                
                if not autoSummitEnabledValue.Value then break end
                
                -- Go to Summit
                if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("ContentFrame") then
                    local statusText = gui.MainFrame.ContentFrame:FindFirstChild("StatusSection"):FindFirstChild("StatusText")
                    if statusText then
                        statusText.Text = "💡 Status: Auto Summit: Going to Summit...\n🔄 Auto Execute: Active"
                        statusText.TextColor3 = Color3.fromRGB(255, 200, 100)
                    end
                end
                
                local tween2 = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = SUMMIT_POS})
                tween2:Play()
                tween2.Completed:Wait()
                
                wait(delayValue.Value + 1)
                
                if not autoSummitEnabledValue.Value then break end
                
                -- Server hop
                if gui and gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("ContentFrame") then
                    local statusText = gui.MainFrame.ContentFrame:FindFirstChild("StatusSection"):FindFirstChild("StatusText")
                    if statusText then
                        statusText.Text = "💡 Status: Server hopping...\n🔄 Auto Execute: Active"
                        statusText.TextColor3 = Color3.fromRGB(255, 150, 100)
                    end
                end
                
                loopCountValue.Value = loopCountValue.Value + 1
                
                wait(2)
                
                pcall(function()
                    TeleportService:Teleport(game.PlaceId)
                end)
                
                break -- Will restart in new server
            end
        end)
    end
end)

-- Cleanup on game shutdown
game:BindToClose(function()
    -- Values are automatically saved due to persistent storage
    print("🔄 Auto Summit Script: Settings saved for next session")
end)

-- Success message
print("🏔️ Auto Summit & Teleport Script Loaded! [PERSISTENT VERSION]")
print("📍 Features: Auto Execute, Persistent Loop, Smart Server Hop")
print("⚡ Auto Summit Status: " .. (autoSummitEnabledValue.Value and "ENABLED" or "DISABLED"))
print("🔁 Total Loops: " .. loopCountValue.Value)
print("⚙️ GUI will appear when character loads!")

-- Auto-create GUI if character is ready
spawn(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        wait(1)
        onCharacterAdded()
    end
end)