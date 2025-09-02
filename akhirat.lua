-- YARS Summit Auto Script - Compact Version
-- Auto Summit Gunung Atin - Simple & Clean

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
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

-- Security Scanner (dengan Custom Notifications)
local function performSecurityScan()
    -- Step 1: Start notification
    print("=== STARTING SECURITY SCAN ===")
    showCustomNotification("🔍 Security Scan", "Scanning server for admins/staff...", Color3.fromRGB(100, 150, 255), 3)
    
    -- Step 2: Get all players
    local allPlayers = Players:GetPlayers()
    local staffFound = {}
    
    -- Step 3: Check each player
    for _, player in pairs(allPlayers) do
        if player ~= Players.LocalPlayer then
            local name = string.lower(player.Name)
            local display = string.lower(player.DisplayName)
            
            print("Checking: " .. player.Name .. " (" .. player.DisplayName .. ")")
            
            -- Simple keyword check
            local keywords = {"admin", "mod", "staff", "dev", "developer", "malaikat", "angel", "owner", "creator", "moderator"}
            
            for _, keyword in pairs(keywords) do
                if string.find(name, keyword) or string.find(display, keyword) then
                    table.insert(staffFound, player.Name)
                    print("🚨 FOUND STAFF: " .. player.Name)
                    break
                end
            end
        end
    end
    
    -- Step 4: Wait for scanning effect
    wait(2.5)
    
    -- Step 5: Show results dengan custom notification
    print("=== SCAN COMPLETE ===")
    print("Staff found: " .. #staffFound)
    
    if #staffFound > 0 then
        -- DANGER - Custom notification
        showCustomNotification("🚨 DANGER DETECTED!", "Found " .. #staffFound .. " staff members in server", Color3.fromRGB(255, 100, 100), 6)
        
        wait(0.5)
        
        -- Show staff names
        local staffList = table.concat(staffFound, ", ")
        if #staffList > 50 then
            staffList = string.sub(staffList, 1, 50) .. "..."
        end
        showCustomNotification("⚠️ Staff Found", "Users: " .. staffList, Color3.fromRGB(255, 150, 100), 5)
        
        wait(0.5)
        
        -- Recommendation
        showCustomNotification("🔒 Recommendation", "Use Private Server for safer farming!", Color3.fromRGB(255, 200, 100), 4)
        
    else
        -- SAFE - Custom notification
        showCustomNotification("✅ Server Safe", "No admins/staff detected in server", Color3.fromRGB(100, 255, 100), 5)
        
        wait(0.5)
        
        -- Server info
        showCustomNotification("📊 Server Info", #allPlayers .. " players online - Safe to farm summit!", Color3.fromRGB(100, 200, 255), 4)
    end
    
    print("=== NOTIFICATIONS SENT ===")
end

-- Fungsi Notifikasi Custom (Sama seperti teleport notification)
local function showCustomNotification(title, text, color, duration)
    local notification = Instance.new("ScreenGui")
    notification.Name = "YARSCustomNotification"
    notification.Parent = CoreGui
    notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 70)
    frame.Position = UDim2.new(1, -370, 0, 20)
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 70, 80)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0, 35)
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = frame
    
    -- Animation masuk
    frame.Position = UDim2.new(1, 20, 0, 20)
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = UDim2.new(1, -370, 0, 20)})
    tweenIn:Play()
    
    -- Auto hilang
    spawn(function()
        wait(duration or 4)
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 20)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Fungsi Notifikasi Roblox Default (untuk teleport success dll)
local function showNotification(title, text, duration)
    spawn(function()
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = title;
                Text = text;
                Duration = duration or 3;
            })
        end)
    end)
end

-- Fungsi Server Hopping ke Private Server (0-1 player)
local function hopToPrivateServer()
    local gameId = game.PlaceId
    local emptyServers = {}
    
    pcall(function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success then
            for _, server in pairs(result.data) do
                if server.playing and server.playing <= 1 and server.id ~= game.JobId then
                    table.insert(emptyServers, server)
                end
            end
            
            table.sort(emptyServers, function(a, b)
                return a.playing < b.playing
            end)
        end
    end)
    
    if #emptyServers > 0 then
        local targetServer = emptyServers[1]
        showNotification("Private Server", "Hopping ke server dengan " .. targetServer.playing .. " player...")
        TeleportService:TeleportToPlaceInstance(gameId, targetServer.id, player)
    else
        showNotification("Private Server", "Tidak ada server kosong, hopping random...")
        TeleportService:Teleport(gameId, player)
    end
end

-- Fungsi Teleport
local function teleportTo(position, locationName)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = position
        showNotification("Teleport", "Berhasil ke " .. locationName)
        return true
    else
        showNotification("Error", "Gagal teleport - Character tidak ditemukan")
        return false
    end
end

-- Fungsi klik tombol "Ke Basecamp" (Enhanced Detection)
local function clickBasecampButton()
    local success = false
    
    -- Method 1: Cari di semua ScreenGui
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, descendant in pairs(gui:GetDescendants()) do
                if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                    local text = string.lower(descendant.Text)
                    -- Cek berbagai variasi teks
                    if string.find(text, "ke basecamp") or string.find(text, "basecamp") or 
                       string.find(text, "base camp") or string.find(text, "reset") then
                        
                        -- Simulate click dengan berbagai method
                        pcall(function()
                            -- Method A: FireClick
                            descendant.MouseButton1Click:Fire()
                        end)
                        
                        pcall(function()
                            -- Method B: GetConnections
                            for _, connection in pairs(getconnections(descendant.MouseButton1Click)) do
                                connection:Fire()
                            end
                        end)
                        
                        pcall(function()
                            -- Method C: GuiService
                            game:GetService("GuiService").SelectedCoreObject = descendant
                        end)
                        
                        success = true
                        showCustomNotification("✅ Summit Reset", "Clicked 'Ke Basecamp' button successfully!", Color3.fromRGB(100, 255, 100), 3)
                        print("SUCCESS: Found and clicked Ke Basecamp button: " .. descendant.Name)
                        break
                    end
                end
            end
            if success then break end
        end
    end
    
    -- Method 2: Cari berdasarkan posisi (tombol biasanya di pojok kanan atas)
    if not success then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, descendant in pairs(gui:GetDescendants()) do
                    if descendant:IsA("GuiButton") and descendant.Visible then
                        -- Cek posisi di kanan atas (X > 0.8, Y < 0.3)
                        if descendant.AbsolutePosition.X > game.Workspace.CurrentCamera.ViewportSize.X * 0.8 and
                           descendant.AbsolutePosition.Y < game.Workspace.CurrentCamera.ViewportSize.Y * 0.3 then
                            
                            pcall(function()
                                descendant.MouseButton1Click:Fire()
                                for _, connection in pairs(getconnections(descendant.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end)
                            
                            success = true
                            showCustomNotification("✅ Position Reset", "Clicked button at top-right position!", Color3.fromRGB(100, 255, 100), 3)
                            print("SUCCESS: Found button by position: " .. descendant.Name)
                            break
                        end
                    end
                end
                if success then break end
            end
        end
    end
    
    if not success then
        showCustomNotification("⚠️ Button Not Found", "Could not find 'Ke Basecamp' button", Color3.fromRGB(255, 150, 100), 3)
        print("ERROR: Ke Basecamp button not found")
        
        -- Fallback: Manual reset
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = 0
            showCustomNotification("💀 Manual Reset", "Used fallback reset method", Color3.fromRGB(255, 200, 100), 3)
        end
    end
    
    return success
end

-- Fungsi deteksi sampai di puncak
local function checkArrivedAtSummit()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentPos = character.HumanoidRootPart.Position
    local summitPos = SUMMIT_POS.Position
    local distance = (currentPos - summitPos).Magnitude
    
    return distance <= 25 and currentPos.Y > 7800
end

-- Fungsi deteksi summit terhitung
local function checkSummitCounted()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local summitStat = leaderstats:FindFirstChild("Summit") or leaderstats:FindFirstChild("Summits") or leaderstats:FindFirstChild("summit")
        if summitStat and summitStat.Value > lastSummitCheck then
            lastSummitCheck = summitStat.Value
            summitCount = summitStat.Value
            showNotification("Success", "SUMMIT TERHITUNG! Total: " .. summitCount)
            return true
        end
    end
    return false
end

-- Fungsi Auto Summit (Enhanced dengan tombol Ke Basecamp)
local function autoSummitLoop()
    spawn(function()
        while autoSummitEnabled do
            showCustomNotification("🚀 Auto Summit", "Starting summit cycle...", Color3.fromRGB(100, 200, 255), 2)
            
            -- Step 1: Teleport ke puncak
            if teleportTo(SUMMIT_POS, "Puncak") then
                
                -- Step 2: Tunggu sampai di puncak (deteksi posisi)
                local startTime = tick()
                local arrivedAtSummit = false
                
                showCustomNotification("⏱️ Waiting", "Waiting to reach summit...", Color3.fromRGB(255, 200, 100), 2)
                
                while tick() - startTime < 8 and autoSummitEnabled do
                    if checkArrivedAtSummit() then
                        arrivedAtSummit = true
                        showCustomNotification("✅ Arrived", "Reached summit position!", Color3.fromRGB(100, 255, 100), 2)
                        break
                    end
                    wait(0.3)
                end
                
                -- Step 3: Klik tombol "Ke Basecamp" untuk reset summit
                if arrivedAtSummit and autoSummitEnabled then
                    wait(1) -- Tunggu sedikit untuk memastikan summit terdaftar
                    
                    showCustomNotification("🔄 Resetting", "Clicking 'Ke Basecamp' button...", Color3.fromRGB(255, 150, 100), 2)
                    
                    local resetSuccess = clickBasecampButton()
                    
                    if resetSuccess then
                        -- Tunggu respawn di basecamp
                        local respawnStart = tick()
                        while not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and tick() - respawnStart < 15 do
                            wait(0.2)
                        end
                        
                        wait(1.5) -- Tunggu character fully loaded dan summit terupdate
                        
                        -- Cek apakah summit bertambah
                        checkSummitCounted()
                        
                        showCustomNotification("🏠 Respawned", "Back to basecamp, checking summit count...", Color3.fromRGB(150, 255, 150), 2)
                        
                    else
                        showCustomNotification("⚠️ Reset Failed", "Button not found, trying manual reset...", Color3.fromRGB(255, 100, 100), 3)
                        wait(3) -- Extra wait untuk manual reset
                    end
                end
                
            else
                showCustomNotification("❌ Teleport Failed", "Retrying in 2 seconds...", Color3.fromRGB(255, 100, 100), 2)
                wait(2)
            end
            
            -- Cooldown antar cycle
            if autoSummitEnabled then
                showCustomNotification("⏳ Cooldown", "Next cycle in 2 seconds...", Color3.fromRGB(200, 200, 255), 2)
                wait(2)
            end
        end
    end)
end

-- Buat UI Compact
local function createUI()
    -- Hapus UI lama
    if playerGui:FindFirstChild("YARSCompactGUI") then
        playerGui.YARSCompactGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YARSCompactGUI"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame (Compact) - increased height for new button
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 295)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -147)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(70, 70, 80)
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "YARS Summit Auto"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -50, 0, 2.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 14
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -25, 0, 2.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Summit Counter
    local summitCounter = Instance.new("TextLabel")
    summitCounter.Name = "SummitCounter"
    summitCounter.Size = UDim2.new(1, 0, 0, 25)
    summitCounter.Position = UDim2.new(0, 0, 0, 5)
    summitCounter.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    summitCounter.Text = "Summit: " .. summitCount
    summitCounter.TextColor3 = Color3.fromRGB(255, 215, 0)
    summitCounter.TextSize = 12
    summitCounter.Font = Enum.Font.GothamBold
    summitCounter.Parent = contentFrame
    
    local counterCorner = Instance.new("UICorner")
    counterCorner.CornerRadius = UDim.new(0, 4)
    counterCorner.Parent = summitCounter
    
    -- Teleport ke Basecamp
    local basecampBtn = Instance.new("TextButton")
    basecampBtn.Name = "BasecampButton"
    basecampBtn.Size = UDim2.new(1, 0, 0, 30)
    basecampBtn.Position = UDim2.new(0, 0, 0, 35)
    basecampBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
    basecampBtn.Text = "🏠 Basecamp"
    basecampBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    basecampBtn.TextSize = 11
    basecampBtn.Font = Enum.Font.Gotham
    basecampBtn.Parent = contentFrame
    
    local basecampCorner = Instance.new("UICorner")
    basecampCorner.CornerRadius = UDim.new(0, 4)
    basecampCorner.Parent = basecampBtn
    
    -- Teleport ke Puncak
    local summitBtn = Instance.new("TextButton")
    summitBtn.Name = "SummitButton"
    summitBtn.Size = UDim2.new(1, 0, 0, 30)
    summitBtn.Position = UDim2.new(0, 0, 0, 70)
    summitBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
    summitBtn.Text = "🚀 Puncak"
    summitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    summitBtn.TextSize = 11
    summitBtn.Font = Enum.Font.Gotham
    summitBtn.Parent = contentFrame
    
    local summitCorner = Instance.new("UICorner")
    summitCorner.CornerRadius = UDim.new(0, 4)
    summitCorner.Parent = summitBtn
    
    -- Auto Summit Button
    local autoBtn = Instance.new("TextButton")
    autoBtn.Name = "AutoButton"
    autoBtn.Size = UDim2.new(1, 0, 0, 35)
    autoBtn.Position = UDim2.new(0, 0, 0, 105)
    autoBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    autoBtn.Text = "⚡ AUTO: OFF"
    autoBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    autoBtn.TextSize = 12
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.Parent = contentFrame
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 4)
    autoCorner.Parent = autoBtn
    
    -- Private Server Button
    local privateBtn = Instance.new("TextButton")
    privateBtn.Name = "PrivateButton"
    privateBtn.Size = UDim2.new(1, 0, 0, 30)
    privateBtn.Position = UDim2.new(0, 0, 0, 145)
    privateBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    privateBtn.Text = "🔒 Private Server"
    privateBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    privateBtn.TextSize = 11
    privateBtn.Font = Enum.Font.Gotham
    privateBtn.Parent = contentFrame
    
    local privateCorner = Instance.new("UICorner")
    privateCorner.CornerRadius = UDim.new(0, 4)
    privateCorner.Parent = privateBtn
    
    -- Server Hop Button
    local hopBtn = Instance.new("TextButton")
    hopBtn.Name = "HopButton"
    hopBtn.Size = UDim2.new(1, 0, 0, 30)
    hopBtn.Position = UDim2.new(0, 0, 0, 180)
    hopBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    hopBtn.Text = "🌐 Server Hop"
    hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hopBtn.TextSize = 11
    hopBtn.Font = Enum.Font.Gotham
    hopBtn.Parent = contentFrame
    
    -- Manual Security Scan Button
    local scanBtn = Instance.new("TextButton")
    scanBtn.Name = "ScanButton"
    scanBtn.Size = UDim2.new(1, 0, 0, 25)
    scanBtn.Position = UDim2.new(0, 0, 0, 215)
    scanBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
    scanBtn.Text = "🔍 Security Scan"
    scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanBtn.TextSize = 10
    scanBtn.Font = Enum.Font.Gotham
    scanBtn.Parent = contentFrame
    
    -- Manual Ke Basecamp Button (untuk testing)
    local manualBasecampBtn = Instance.new("TextButton")
    manualBasecampBtn.Name = "ManualBasecampButton"
    manualBasecampBtn.Size = UDim2.new(1, 0, 0, 25)
    manualBasecampBtn.Position = UDim2.new(0, 0, 0, 240)
    manualBasecampBtn.BackgroundColor3 = Color3.fromRGB(150, 255, 150)
    manualBasecampBtn.Text = "🔄 Click Ke Basecamp"
    manualBasecampBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    manualBasecampBtn.TextSize = 10
    manualBasecampBtn.Font = Enum.Font.Gotham
    manualBasecampBtn.Parent = contentFrame
    
    local manualBasecampCorner = Instance.new("UICorner")
    manualBasecampCorner.CornerRadius = UDim.new(0, 4)
    manualBasecampCorner.Parent = manualBasecampBtn
    
    -- Event Handlers
    basecampBtn.MouseButton1Click:Connect(function()
        teleportTo(BASECAMP_POS, "Basecamp")
    end)
    
    summitBtn.MouseButton1Click:Connect(function()
        teleportTo(SUMMIT_POS, "Puncak")
    end)
    
    autoBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = not autoSummitEnabled
        if autoSummitEnabled then
            autoBtn.Text = "⚡ AUTO: ON"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            showNotification("Auto Summit", "AKTIF - Speed Mode!")
            autoSummitLoop()
        else
            autoBtn.Text = "⚡ AUTO: OFF"
            autoBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            autoBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            showNotification("Auto Summit", "NONAKTIF")
        end
    end)
    
    privateBtn.MouseButton1Click:Connect(function()
        hopToPrivateServer()
    end)
    
    hopBtn.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            mainFrame.Size = UDim2.new(0, 200, 0, 30)
            contentFrame.Visible = false
            minimizeBtn.Text = "□"
            title.Text = "YARS (Minimized)"
        else
            mainFrame.Size = UDim2.new(0, 200, 0, 295)
            contentFrame.Visible = true
            minimizeBtn.Text = "−"
            title.Text = "YARS Summit Auto"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = false
        screenGui:Destroy()
        showNotification("YARS", "Script ditutup")
    end)
    
    -- Update counter
    spawn(function()
        while summitCounter and summitCounter.Parent do
            summitCounter.Text = "Summit: " .. summitCount
            wait(1)
        end
    end)
    
    -- Fixed Dragging System 
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    -- Make header draggable
    local function makeDraggable()
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
                
                local connection
                connection = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        connection:Disconnect()
                    end
                end)
            end
        end)
        
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    local delta = input.Position - dragStart
                    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
    end
    
    makeDraggable()
end

-- Initialize
print("🚀 YARS SCRIPT STARTING...")
showNotification("YARS Ready", "Summit Auto Loaded!")
createUI()

-- Test scan setelah 3 detik
spawn(function()
    wait(3)
    print("🔍 RUNNING INITIAL SCAN...")
    showCustomNotification("Auto Scan", "Running initial security check...", Color3.fromRGB(150, 100, 255), 3)
    performSecurityScan()
end)

-- Auto-update summit count
spawn(function()
    while true do
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local summitStat = leaderstats:FindFirstChild("Summit") or leaderstats:FindFirstChild("Summits") or leaderstats:FindFirstChild("summit")
            if summitStat then
                summitCount = summitStat.Value
            end
        end
        wait(1)
    end
end)
