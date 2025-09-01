-- YARS Summit Auto Script - Map Akhirat
-- Auto Summit Gunung Atin - Enhanced Version

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Koordinat
local SUMMIT_POS = CFrame.new(3041.74048, 7876.99756, 1037.59253, 0.98826158, 0, 0.152771264, 0, 1, 0, -0.152771264, 0, 0.98826158)
local BASECAMP_POS = CFrame.new(-243.999069, 120.998016, 202.997528, 1, 7.900260366e-08, -2.258263886e-05, -7.90030512e-08, 1, -1.98717274e-08, 2.258263880e-05, 1.98735126e-08, 1)

-- Variables
local autoSummitEnabled = false
local summitCount = 0
local lastSummitCheck = 0
local isMinimized = false
local currentTab = "teleport"

-- Fungsi Server Hopping ke server sepi
local function hopToEmptyServer()
    local gameId = game.PlaceId
    local servers = {}
    
    pcall(function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success then
            for _, server in pairs(result.data) do
                if server.playing and server.playing <= 2 and server.id ~= game.JobId then
                    table.insert(servers, server)
                end
            end
            
            table.sort(servers, function(a, b)
                return a.playing < b.playing
            end)
        end
    end)
    
    if #servers > 0 then
        showNotification("🌐 Hopping ke server dengan " .. servers[1].playing .. " player...", Color3.fromRGB(100, 200, 255))
        TeleportService:TeleportToPlaceInstance(gameId, servers[1].id, player)
    else
        showNotification("🔄 Hopping ke server random...", Color3.fromRGB(255, 200, 100))
        TeleportService:Teleport(gameId, player)
    end
end

-- Fungsi Notifikasi (YARS Style)
local function showNotification(text, color)
    local notification = Instance.new("ScreenGui")
    notification.Name = "YARSNotification"
    notification.Parent = CoreGui
    notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 70)
    frame.Position = UDim2.new(1, -370, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(70, 70, 80)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = frame
    
    -- Animation
    frame.Position = UDim2.new(1, 20, 0, 20)
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(1, -370, 0, 20)})
    tweenIn:Play()
    
    spawn(function()
        wait(3)
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 20)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Fungsi Teleport (Instant)
local function teleportTo(position, locationName)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = position
        showNotification("✅ Teleport ke " .. locationName, Color3.fromRGB(100, 255, 100))
        return true
    else
        showNotification("❌ Gagal teleport - Character tidak ditemukan", Color3.fromRGB(255, 100, 100))
        return false
    end
end

-- Fungsi force reset player (lebih agresif)
local function forceReset()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        -- Method 1: Reset via Humanoid
        character.Humanoid.Health = 0
        
        -- Method 2: Destroy character parts (backup)
        spawn(function()
            wait(0.1)
            if character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart:Destroy()
            end
        end)
        
        showNotification("💀 Force reset ke basecamp", Color3.fromRGB(255, 200, 100))
        return true
    end
    return false
end

-- Fungsi deteksi summit (lebih sensitif)
local function checkSummitReached()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentPos = character.HumanoidRootPart.Position
    local summitPos = SUMMIT_POS.Position
    local distance = (currentPos - summitPos).Magnitude
    
    -- Deteksi berdasarkan jarak dan ketinggian
    if distance <= 25 and currentPos.Y > 7800 then
        local currentTime = tick()
        
        -- Cek leaderstats dulu
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local summitStat = leaderstats:FindFirstChild("Summit") or leaderstats:FindFirstChild("Summits") or leaderstats:FindFirstChild("summit")
            if summitStat and summitStat.Value > lastSummitCheck then
                lastSummitCheck = summitStat.Value
                summitCount = summitStat.Value
                showNotification("🏔️ SUMMIT BERHASIL! Total: " .. summitCount, Color3.fromRGB(255, 215, 0))
                return true
            end
        end
        
        -- Deteksi manual berdasarkan waktu
        if currentTime - lastSummitCheck > 2 then
            lastSummitCheck = currentTime
            summitCount = summitCount + 1
            showNotification("🏔️ SUMMIT BERHASIL! Total: " .. summitCount, Color3.fromRGB(255, 215, 0))
            return true
        end
    end
    return false
end

-- Fungsi Auto Summit (Enhanced)
local function autoSummitLoop()
    spawn(function()
        while autoSummitEnabled do
            -- Step 1: Teleport ke puncak
            if teleportTo(SUMMIT_POS, "Puncak Gunung") then
                
                -- Step 2: Tunggu summit terdeteksi (maksimal 5 detik)
                local startTime = tick()
                local summitDetected = false
                
                while tick() - startTime < 5 and autoSummitEnabled do
                    if checkSummitReached() then
                        summitDetected = true
                        break
                    end
                    wait(0.2) -- Check setiap 0.2 detik
                end
                
                -- Step 3: Langsung reset setelah summit terdeteksi
                if summitDetected and autoSummitEnabled then
                    wait(0.5) -- Tunggu sebentar biar summit benar-benar terhitung
                    forceReset()
                    
                    -- Tunggu respawn
                    local respawnStart = tick()
                    while not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and tick() - respawnStart < 10 do
                        wait(0.1)
                    end
                    
                    wait(0.5) -- Tunggu character fully loaded
                end
                
            else
                wait(1) -- Tunggu sebelum retry jika teleport gagal
            end
            
            wait(1) -- Cooldown singkat antar loop
        end
    end)
end

-- Switch Tab Function
local function switchTab(tabName, tabButtons, contentFrames)
    currentTab = tabName
    
    -- Reset all tabs
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Show/hide content frames
    for name, frame in pairs(contentFrames) do
        frame.Visible = (name == tabName)
    end
end

-- Buat UI YARS Style
local function createUI()
    -- Hapus UI lama
    if playerGui:FindFirstChild("YARSSummitGUI") then
        playerGui.YARSSummitGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YARSSummitGUI"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame (YARS Style)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(60, 60, 70)
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame
    
    -- Header dengan close dan minimize
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "YARS - FREE VERSION Auto Summit (Gunung Atin)"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 16
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = minimizeBtn
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -20, 0, 50)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    -- Tab Buttons
    local keyTab = Instance.new("TextButton")
    keyTab.Name = "KeyTab"
    keyTab.Size = UDim2.new(0, 120, 1, 0)
    keyTab.Position = UDim2.new(0, 0, 0, 0)
    keyTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    keyTab.Text = "🔒 Key System"
    keyTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyTab.TextSize = 12
    keyTab.Font = Enum.Font.Gotham
    keyTab.Parent = tabContainer
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyTab
    
    local teleportTab = Instance.new("TextButton")
    teleportTab.Name = "TeleportTab"
    teleportTab.Size = UDim2.new(0, 120, 1, 0)
    teleportTab.Position = UDim2.new(0, 130, 0, 0)
    teleportTab.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    teleportTab.Text = "💀 Teleport"
    teleportTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportTab.TextSize = 12
    teleportTab.Font = Enum.Font.Gotham
    teleportTab.Parent = tabContainer
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 6)
    teleportCorner.Parent = teleportTab
    
    local hacksTab = Instance.new("TextButton")
    hacksTab.Name = "HacksTab"
    hacksTab.Size = UDim2.new(0, 120, 1, 0)
    hacksTab.Position = UDim2.new(0, 260, 0, 0)
    hacksTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    hacksTab.Text = "⚙️ Player Hacks"
    hacksTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    hacksTab.TextSize = 12
    hacksTab.Font = Enum.Font.Gotham
    hacksTab.Parent = tabContainer
    
    local hacksCorner = Instance.new("UICorner")
    hacksCorner.CornerRadius = UDim.new(0, 6)
    hacksCorner.Parent = hacksTab
    
    -- Content Frames
    local keyContent = Instance.new("Frame")
    keyContent.Name = "KeyContent"
    keyContent.Size = UDim2.new(1, -20, 1, -120)
    keyContent.Position = UDim2.new(0, 10, 0, 110)
    keyContent.BackgroundTransparency = 1
    keyContent.Visible = false
    keyContent.Parent = mainFrame
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = "🔒 Key System Not Required\n\nYARS is completely FREE!"
    keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyLabel.TextSize = 16
    keyLabel.Font = Enum.Font.Gotham
    keyLabel.Parent = keyContent
    
    local teleportContent = Instance.new("Frame")
    teleportContent.Name = "TeleportContent"
    teleportContent.Size = UDim2.new(1, -20, 1, -120)
    teleportContent.Position = UDim2.new(0, 10, 0, 110)
    teleportContent.BackgroundTransparency = 1
    teleportContent.Visible = true
    teleportContent.Parent = mainFrame
    
    local hacksContent = Instance.new("Frame")
    hacksContent.Name = "HacksContent"
    hacksContent.Size = UDim2.new(1, -20, 1, -120)
    hacksContent.Position = UDim2.new(0, 10, 0, 110)
    hacksContent.BackgroundTransparency = 1
    hacksContent.Visible = false
    hacksContent.Parent = mainFrame
    
    local hacksLabel = Instance.new("TextLabel")
    hacksLabel.Size = UDim2.new(1, 0, 1, 0)
    hacksLabel.BackgroundTransparency = 1
    hacksLabel.Text = "⚙️ Player Hacks\n\nComing Soon..."
    hacksLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    hacksLabel.TextSize = 16
    hacksLabel.Font = Enum.Font.Gotham
    hacksLabel.Parent = hacksContent
    
    -- TELEPORT CONTENT (Main Features)
    -- Summit Counter
    local summitCounter = Instance.new("TextLabel")
    summitCounter.Name = "SummitCounter"
    summitCounter.Size = UDim2.new(1, 0, 0, 40)
    summitCounter.Position = UDim2.new(0, 0, 0, 10)
    summitCounter.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    summitCounter.Text = "🏔️ Summit Count: " .. summitCount
    summitCounter.TextColor3 = Color3.fromRGB(255, 215, 0)
    summitCounter.TextSize = 16
    summitCounter.Font = Enum.Font.GothamBold
    summitCounter.Parent = teleportContent
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.CornerRadius = UDim.new(0, 6)
    counterCorner.Parent = summitCounter
    
    -- Teleport ke Puncak Button
    local summitTeleportBtn = Instance.new("TextButton")
    summitTeleportBtn.Name = "SummitTeleportButton"
    summitTeleportBtn.Size = UDim2.new(1, 0, 0, 45)
    summitTeleportBtn.Position = UDim2.new(0, 0, 0, 60)
    summitTeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
    summitTeleportBtn.Text = "🚀 TELEPORT KE PUNCAK"
    summitTeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    summitTeleportBtn.TextSize = 14
    summitTeleportBtn.Font = Enum.Font.GothamBold
    summitTeleportBtn.Parent = teleportContent
    
    local summitTeleportCorner = Instance.new("UICorner")
    summitTeleportCorner.CornerRadius = UDim.new(0, 6)
    summitTeleportCorner.Parent = summitTeleportBtn
    
    -- Auto Summit Button (Main Feature)
    local autoSummitBtn = Instance.new("TextButton")
    autoSummitBtn.Name = "AutoSummitButton"
    autoSummitBtn.Size = UDim2.new(1, 0, 0, 45)
    autoSummitBtn.Position = UDim2.new(0, 0, 0, 115)
    autoSummitBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    autoSummitBtn.Text = "⚡ AUTO SUMMIT: OFF"
    autoSummitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    autoSummitBtn.TextSize = 14
    autoSummitBtn.Font = Enum.Font.GothamBold
    autoSummitBtn.Parent = teleportContent
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 6)
    autoCorner.Parent = autoSummitBtn
    
    -- Server Hop Button
    local hopBtn = Instance.new("TextButton")
    hopBtn.Name = "HopButton"
    hopBtn.Size = UDim2.new(1, 0, 0, 40)
    hopBtn.Position = UDim2.new(0, 0, 0, 170)
    hopBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    hopBtn.Text = "🌐 HOP SERVER SEPI"
    hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hopBtn.TextSize = 14
    hopBtn.Font = Enum.Font.GothamBold
    hopBtn.Parent = teleportContent
    
    local hopCorner = Instance.new("UICorner")
    hopCorner.CornerRadius = UDim.new(0, 6)
    hopCorner.Parent = hopBtn
    
    -- Tab system
    local tabButtons = {
        key = keyTab,
        teleport = teleportTab,
        hacks = hacksTab
    }
    
    local contentFrames = {
        key = keyContent,
        teleport = teleportContent,
        hacks = hacksContent
    }
    
    -- Event Handlers
    keyTab.MouseButton1Click:Connect(function()
        switchTab("key", tabButtons, contentFrames)
    end)
    
    teleportTab.MouseButton1Click:Connect(function()
        switchTab("teleport", tabButtons, contentFrames)
    end)
    
    hacksTab.MouseButton1Click:Connect(function()
        switchTab("hacks", tabButtons, contentFrames)
    end)
    
    summitTeleportBtn.MouseButton1Click:Connect(function()
        teleportTo(SUMMIT_POS, "Puncak Gunung")
    end)
    
    autoSummitBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = not autoSummitEnabled
        if autoSummitEnabled then
            autoSummitBtn.Text = "⚡ AUTO SUMMIT: ON"
            autoSummitBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            autoSummitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            showNotification("🔥 Auto Summit AKTIF - Speed Mode!", Color3.fromRGB(255, 100, 100))
            autoSummitLoop()
        else
            autoSummitBtn.Text = "⚡ AUTO SUMMIT: OFF"
            autoSummitBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            autoSummitBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            showNotification("⏹️ Auto Summit NONAKTIF", Color3.fromRGB(100, 255, 100))
        end
    end)
    
    hopBtn.MouseButton1Click:Connect(function()
        hopToEmptyServer()
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame.Size = UDim2.new(0, 400, 0, 40)
            tabContainer.Visible = fal
