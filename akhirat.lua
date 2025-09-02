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

-- Security Scanner (Completely Fixed)
local function scanForStaff()
    local dangerousUsers = {}
    local staffKeywords = {
        "admin", "administrator", "developer", "dev", "mod", "moderator", 
        "staff", "owner", "malaikat", "angel", "creator", "founder", 
        "manager", "support", "helper", "team", "official"
    }
    
    print("DEBUG: Scanning " .. #Players:GetPlayers() .. " players...")
    
    -- Scan semua player di server
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local username = string.lower(p.Name)
            local displayName = string.lower(p.DisplayName)
            
            print("DEBUG: Checking player - " .. p.Name .. " (" .. p.DisplayName .. ")")
            
            -- Cek keyword di username atau display name
            for _, keyword in pairs(staffKeywords) do
                if string.find(username, keyword) or string.find(displayName, keyword) then
                    table.insert(dangerousUsers, p.Name)
                    print("DEBUG: Found suspicious user: " .. p.Name)
                    break
                end
            end
            
            -- Cek account age (staff biasanya account lama)
            if p.AccountAge > 2000 then -- 5+ years
                for _, keyword in pairs({"admin", "mod", "staff", "malaikat", "dev"}) do
                    if string.find(username, keyword) or string.find(displayName, keyword) then
                        if not table.find(dangerousUsers, p.Name) then
                            table.insert(dangerousUsers, p.Name .. " [OLD_ACC]")
                        end
                        break
                    end
                end
            end
        end
    end
    
    print("DEBUG: Found " .. #dangerousUsers .. " suspicious users")
    return dangerousUsers
end

-- Security Alert System (Completely Fixed)
local function performSecurityScan()
    -- Step 1: Start notification
    showNotification("🔍 SCANNING...", "Checking server for admins/staff...")
    print("DEBUG: Starting security scan...")
    
    -- Step 2: Wait for scan
    wait(2)
    
    -- Step 3: Get results
    local threats = scanForStaff()
    local totalPlayers = #Players:GetPlayers()
    
    print("DEBUG: Scan complete. Threats found: " .. #threats)
    
    -- Step 4: Show results
    if #threats > 0 then
        -- DANGER - Staff detected
        showNotification("🚨 DANGER DETECTED!", "Found " .. #threats .. " suspicious users!", 6)
        
        -- Show each threat (max 3 to avoid spam)
        local maxShow = math.min(#threats, 3)
        for i = 1, maxShow do
            showNotification("⚠️ Staff Found", "User: " .. threats[i], 5)
        end
        
        if #threats > 3 then
            showNotification("More Threats", "+" .. (#threats - 3) .. " more suspicious users", 4)
        end
        
        -- Recommendation
        showNotification("🔒 RECOMMENDATION", "Use Private Server or hop!", 5)
        
    else
        -- SAFE - No staff detected
        showNotification("✅ SERVER SAFE!", "No admins/staff detected", 4)
        showNotification("Server Info", totalPlayers .. " players online - Safe to farm!", 3)
    end
    
    print("DEBUG: Notifications sent")
end

-- Fungsi Notifikasi (Fixed - konsisten dengan format yang bekerja)
local function showNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "YARS";
            Text = text or "";
            Duration = duration or 3;
        })
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

-- Fungsi klik tombol "Ke Basecamp"
local function clickBasecampButton()
    local success = false
    
    for _, gui in pairs(playerGui:GetChildren()) do
        for _, descendant in pairs(gui:GetDescendants()) do
            if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                local text = descendant.Text:lower()
                if text:find("ke basecamp") or text:find("basecamp") or text:find("base camp") then
                    for _, connection in pairs(getconnections(descendant.MouseButton1Click)) do
                        connection:Fire()
                    end
                    success = true
                    showNotification("Summit", "Klik tombol Ke Basecamp berhasil!")
                    break
                end
            end
        end
        if success then break end
    end
    
    if not success then
        showNotification("Warning", "Tombol Ke Basecamp tidak ditemukan!")
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

-- Fungsi Auto Summit
local function autoSummitLoop()
    spawn(function()
        while autoSummitEnabled do
            -- Step 1: Teleport ke puncak
            if teleportTo(SUMMIT_POS, "Puncak") then
                
                -- Step 2: Tunggu sampai di puncak
                local startTime = tick()
                local arrivedAtSummit = false
                
                while tick() - startTime < 5 and autoSummitEnabled do
                    if checkArrivedAtSummit() then
                        arrivedAtSummit = true
                        break
                    end
                    wait(0.2)
                end
                
                -- Step 3: Klik tombol "Ke Basecamp"
                if arrivedAtSummit and autoSummitEnabled then
                    wait(0.5)
                    
                    local basecampClicked = clickBasecampButton()
                    
                    if basecampClicked then
                        -- Tunggu respawn
                        local respawnStart = tick()
                        while not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and tick() - respawnStart < 10 do
                            wait(0.1)
                        end
                        
                        wait(1)
                        checkSummitCounted()
                    else
                        -- Fallback: force reset
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid.Health = 0
                        end
                        wait(3)
                    end
                end
                
            else
                wait(1)
            end
            
            wait(1)
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
    mainFrame.Size = UDim2.new(0, 200, 0, 270)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -135)
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
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 4)
    scanCorner.Parent = scanBtn
    
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
            mainFrame.Size = UDim2.new(0, 200, 0, 270)
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

-- Initialize dengan Security Scan (Simplified)
showNotification("YARS Loaded", "Summit Auto Ready! 🚀")
createUI()

-- Auto scan saat script load
spawn(function()
    wait(2) -- Tunggu UI load
    showNotification("Auto Scan", "Running initial security check...")
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
