-- Delta Summit Auto Script - Map Akhirat
-- Dibuat untuk auto summit dengan UI keren

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

-- Fungsi Server Hopping ke server sepi
local function hopToEmptyServer()
    local gameId = game.PlaceId
    local servers = {}
    
    -- Ambil data server
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
            
            -- Sort berdasarkan jumlah player (dari yang paling sedikit)
            table.sort(servers, function(a, b)
                return a.playing < b.playing
            end)
        end
    end)
    
    -- Teleport ke server terbaik atau random server jika tidak ada yang sepi
    if #servers > 0 then
        showNotification("🌐 Hopping ke server dengan " .. servers[1].playing .. " player...", Color3.fromRGB(100, 200, 255))
        TeleportService:TeleportToPlaceInstance(gameId, servers[1].id, player)
    else
        showNotification("🔄 Hopping ke server random...", Color3.fromRGB(255, 200, 100))
        TeleportService:Teleport(gameId, player)
    end
end

-- Fungsi Notifikasi
local function showNotification(text, color)
    local notification = Instance.new("ScreenGui")
    notification.Name = "SummitNotification"
    notification.Parent = CoreGui
    notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, -320, 0, 20)
    frame.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    }
    gradient.Rotation = 45
    gradient.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = frame
    
    -- Animation masuk
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -320, 0, 20)})
    tweenIn:Play()
    
    -- Auto hilang setelah 3 detik
    wait(3)
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 20)})
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Fungsi Teleport
local function teleportTo(position, locationName)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = position
        showNotification("✅ Teleport ke " .. locationName .. " berhasil!", Color3.fromRGB(100, 255, 100))
        return true
    else
        showNotification("❌ Gagal teleport - Character tidak ditemukan!", Color3.fromRGB(255, 100, 100))
        return false
    end
end

-- Fungsi cari dan klik tombol "ke basecamp"
local function clickBasecampButton()
    local success = false
    
    -- Cari di semua GUI yang mungkin
    for _, gui in pairs(playerGui:GetChildren()) do
        for _, descendant in pairs(gui:GetDescendants()) do
            if descendant:IsA("TextButton") or descendant:IsA("GuiButton") then
                local text = descendant.Text:lower()
                if text:find("basecamp") or text:find("base camp") or text:find("ke basecamp") then
                    descendant.MouseButton1Click:Fire()
                    success = true
                    break
                end
            end
        end
        if success then break end
    end
    
    -- Jika tidak menemukan tombol, teleport manual
    if not success then
        teleportTo(BASECAMP_POS, "Basecamp (Manual)")
    else
        showNotification("🏠 Kembali ke basecamp via tombol", Color3.fromRGB(255, 255, 100))
    end
end

-- Fungsi deteksi summit (berdasarkan posisi dan leaderstats)
local function checkSummitReached()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local currentPos = character.HumanoidRootPart.Position
    local summitPos = SUMMIT_POS.Position
    local distance = (currentPos - summitPos).Magnitude
    
    -- Jika dalam radius 20 studs dari puncak
    if distance <= 20 and currentPos.Y > 7800 then
        local currentTime = tick()
        
        -- Cek leaderstats untuk konfirmasi (jika ada)
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local summitStat = leaderstats:FindFirstChild("Summit") or leaderstats:FindFirstChild("Summits") or leaderstats:FindFirstChild("summit")
            if summitStat and summitStat.Value > lastSummitCheck and currentTime - lastSummitCheck > 3 then
                lastSummitCheck = summitStat.Value
                summitCount = summitStat.Value
                showNotification("🏔️ SUMMIT BERHASIL! Total: " .. summitCount, Color3.fromRGB(255, 215, 0))
                return true
            end
        else
            -- Jika tidak ada leaderstats, hitung manual berdasarkan waktu
            if currentTime - lastSummitCheck > 5 then
                lastSummitCheck = currentTime
                summitCount = summitCount + 1
                showNotification("🏔️ SUMMIT BERHASIL! Total: " .. summitCount, Color3.fromRGB(255, 215, 0))
                return true
            end
        end
    end
    return false
end

-- Fungsi Auto Summit Loop
local function autoSummitLoop()
    spawn(function()
        while autoSummitEnabled do
            wait(1)
            
            -- Step 1: Teleport ke puncak
            if teleportTo(SUMMIT_POS, "Puncak") then
                wait(2) -- Tunggu teleport selesai
                
                -- Step 2: Tunggu sampai summit terhitung (max 10 detik)
                local startTime = tick()
                local summitDetected = false
                
                while tick() - startTime < 10 and autoSummitEnabled do
                    if checkSummitReached() then
                        summitDetected = true
                        break
                    end
                    wait(0.5)
                end
                
                if not summitDetected and autoSummitEnabled then
                    showNotification("⚠️ Summit tidak terdeteksi, coba lagi...", Color3.fromRGB(255, 200, 100))
                end
                
                -- Step 3: Kembali ke basecamp
                if autoSummitEnabled then
                    wait(1)
                    clickBasecampButton()
                    wait(3) -- Tunggu respawn/teleport
                end
            else
                wait(2) -- Tunggu sebelum retry jika teleport gagal
            end
            
            wait(2) -- Cooldown antar loop
        end
    end)
end

-- Buat UI
local function createUI()
    -- Hapus UI lama jika ada
    if playerGui:FindFirstChild("SummitAutoGUI") then
        playerGui.SummitAutoGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SummitAutoGUI"
    screenGui.Parent = playerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 280)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Rounded corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    -- Gradient background
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    bgGradient.Rotation = 135
    bgGradient.Parent = mainFrame
    
    -- Glow effect
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = Color3.fromRGB(100, 150, 255)
    glow.ImageTransparency = 0.8
    glow.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "🏔️ SUMMIT AUTO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Summit Counter
    local counterLabel = Instance.new("TextLabel")
    counterLabel.Name = "CounterLabel"
    counterLabel.Size = UDim2.new(1, -20, 0, 30)
    counterLabel.Position = UDim2.new(0, 10, 0, 55)
    counterLabel.BackgroundTransparency = 1
    counterLabel.Text = "Summit: " .. summitCount
    counterLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    counterLabel.TextScaled = true
    counterLabel.Font = Enum.Font.Gotham
    counterLabel.Parent = mainFrame
    
    -- Update counter setiap detik
    spawn(function()
        while counterLabel and counterLabel.Parent do
            counterLabel.Text = "Summit: " .. summitCount
            wait(1)
        end
    end)
    
    -- Tombol Puncak
    local summitBtn = Instance.new("TextButton")
    summitBtn.Name = "SummitButton"
    summitBtn.Size = UDim2.new(1, -20, 0, 40)
    summitBtn.Position = UDim2.new(0, 10, 0, 95)
    summitBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    summitBtn.Text = "🚀 TELEPORT PUNCAK"
    summitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    summitBtn.TextScaled = true
    summitBtn.Font = Enum.Font.GothamBold
    summitBtn.Parent = mainFrame
    
    local summitCorner = Instance.new("UICorner")
    summitCorner.CornerRadius = UDim.new(0, 10)
    summitCorner.Parent = summitBtn
    
    -- Tombol Auto Summit
    local autoBtn = Instance.new("TextButton")
    autoBtn.Name = "AutoButton"
    autoBtn.Size = UDim2.new(1, -20, 0, 40)
    autoBtn.Position = UDim2.new(0, 10, 0, 145)
    autoBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
    autoBtn.Text = "⚡ AUTO SUMMIT: OFF"
    autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoBtn.TextScaled = true
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.Parent = mainFrame
    
    local autoCorner = Instance.new("UICorner")
    autoCorner.CornerRadius = UDim.new(0, 10)
    autoCorner.Parent = autoBtn
    
    -- Tombol Hop Server
    local hopBtn = Instance.new("TextButton")
    hopBtn.Name = "HopButton"
    hopBtn.Size = UDim2.new(1, -20, 0, 40)
    hopBtn.Position = UDim2.new(0, 10, 0, 195)
    hopBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    hopBtn.Text = "🌐 HOP SERVER SEPI"
    hopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hopBtn.TextScaled = true
    hopBtn.Font = Enum.Font.GothamBold
    hopBtn.Parent = mainFrame
    
    local hopCorner = Instance.new("UICorner")
    hopCorner.CornerRadius = UDim.new(0, 10)
    hopCorner.Parent = hopBtn
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextScaled = true
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = mainFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 15)
    minimizeCorner.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    -- Minimized State
    local isMinimized = false
    local originalSize = mainFrame.Size
    local minimizedSize = UDim2.new(0, 220, 0, 50)
    
    -- Event Handlers
    summitBtn.MouseButton1Click:Connect(function()
        teleportTo(SUMMIT_POS, "Puncak")
    end)
    
    autoBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = not autoSummitEnabled
        if autoSummitEnabled then
            autoBtn.Text = "⚡ AUTO SUMMIT: ON"
            autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            showNotification("🔥 Auto Summit AKTIF!", Color3.fromRGB(255, 100, 100))
            autoSummitLoop()
        else
            autoBtn.Text = "⚡ AUTO SUMMIT: OFF"
            autoBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            showNotification("⏹️ Auto Summit NONAKTIF", Color3.fromRGB(100, 255, 100))
        end
    end)
    
    hopBtn.MouseButton1Click:Connect(function()
        hopToEmptyServer()
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            -- Hide all elements except title and buttons
            counterLabel.Visible = false
            summitBtn.Visible = false
            autoBtn.Visible = false
            hopBtn.Visible = false
            glow.Visible = false
            
            -- Resize and change text
            mainFrame.Size = minimizedSize
            minimizeBtn.Text = "□"
            title.Text = "🏔️ SUMMIT (" .. summitCount .. ")"
        else
            -- Show all elements
            counterLabel.Visible = true
            summitBtn.Visible = true
            autoBtn.Visible = true
            hopBtn.Visible = true
            glow.Visible = true
            
            -- Restore size and text
            mainFrame.Size = originalSize
            minimizeBtn.Text = "−"
            title.Text = "🏔️ SUMMIT AUTO"
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        autoSummitEnabled = false
        screenGui:Destroy()
        showNotification("👋 Summit Auto ditutup", Color3.fromRGB(255, 255, 100))
    end)
    
    -- Drag functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Spawn protection (respawn di puncak jika sudah pernah sampai)
local function setupSpawnProtection()
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Tunggu character fully loaded
        if summitCount > 0 then
            wait(2) -- Tunggu spawning selesai
            teleportTo(SUMMIT_POS, "Puncak (Auto Spawn)")
        end
    end)
end

-- Initialize
showNotification("🚀 Summit Auto Script Loaded!", Color3.fromRGB(100, 255, 100))
createUI()
setupSpawnProtection()

-- Auto-detect summit dari leaderstats jika ada
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