-- YARS Summit Auto + Scan Combo FIXED
-- Dengan Auto Summit jalan, UI bisa drag, tombol bisa scroll
-- By Yars

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Koordinat
local SUMMIT_POS = CFrame.new(3041.74048, 7876.99756, 1037.59253)
local BASECAMP_POS = CFrame.new(-243.999069, 120.998016, 202.997528)

-- Remote reset summit
local ReturnToSpawn = game.ReplicatedStorage:WaitForChild("ReturnToSpawn")

-- Vars
local autoSummitEnabled = false
local autoLoopThread = nil
local loopDelay = 1.5
local riskyTags = {"malaikat","staff","admin","developer","dev","owner"}
local staffList = {"NamaAdminAsli","NamaDevAsli"} -- opsional

-- Notifikasi
local function showCustomNotification(title, text, color, duration)
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "YARSNotif"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 280, 0, 55)
    frame.Position = UDim2.new(1, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)

    local t1 = Instance.new("TextLabel", frame)
    t1.Size = UDim2.new(1,-20,0,20)
    t1.Position = UDim2.new(0,10,0,5)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = color or Color3.fromRGB(255,255,255)
    t1.Font = Enum.Font.GothamBold
    t1.TextSize = 14
    t1.TextXAlignment = Enum.TextXAlignment.Left

    local t2 = Instance.new("TextLabel", frame)
    t2.Size = UDim2.new(1,-20,0,25)
    t2.Position = UDim2.new(0,10,0,28)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.TextColor3 = Color3.fromRGB(220,220,220)
    t2.Font = Enum.Font.Gotham
    t2.TextSize = 12
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextWrapped = true

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1,-300,0,20)}):Play()
    task.delay(duration or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1,20,0,20)}):Play()
        task.wait(0.35)
        gui:Destroy()
    end)
end

-- Teleport
local function teleportTo(cf)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
        return true
    end
    return false
end

-- Reset summit
local function resetSummit()
    pcall(function()
        ReturnToSpawn:FireServer()
        showCustomNotification("🔄 Reset Summit","ReturnToSpawn Fired!",Color3.fromRGB(200,200,255),2)
    end)
end

-- Auto Summit Loop
local function startAutoSummit()
    if autoLoopThread then
        task.cancel(autoLoopThread)
    end
    autoLoopThread = task.spawn(function()
        while autoSummitEnabled do
            if teleportTo(SUMMIT_POS) then
                task.wait(0.5)
                resetSummit()
                task.wait(loopDelay)
            else
                showCustomNotification("❌ Teleport Gagal","Retrying..",Color3.fromRGB(255,120,120),2)
                task.wait(2)
            end
        end
    end)
end

-- Scan Server
local function scanServer()
    local players = Players:GetPlayers()
    local detected = {}
    for _,p in ipairs(players) do
        local uname = string.lower(p.Name)
        local dname = string.lower(p.DisplayName)
        for _,s in ipairs(staffList) do
            if string.lower(s) == uname then
                table.insert(detected,p.Name.." (STAFF)")
            end
        end
        for _,tag in ipairs(riskyTags) do
            if string.find(uname,tag) or string.find(dname,tag) then
                table.insert(detected,p.Name.." (tag:"..tag..")")
            end
        end
    end
    if #detected > 0 then
        showCustomNotification("⚠️ WARNING","Staff/Admin: "..table.concat(detected,", "),Color3.fromRGB(255,80,80),5)
    else
        showCustomNotification("✅ Aman","Tidak ada staff terdeteksi",Color3.fromRGB(180,255,180),3)
    end
end

-- Auto warning join
Players.PlayerAdded:Connect(function(p)
    local uname = string.lower(p.Name)
    local dname = string.lower(p.DisplayName)
    for _,s in ipairs(staffList) do
        if string.lower(s) == uname then
            showCustomNotification("🚨 Staff Join",p.Name.." masuk!",Color3.fromRGB(255,0,0),5)
        end
    end
    for _,tag in ipairs(riskyTags) do
        if string.find(uname,tag) or string.find(dname,tag) then
            showCustomNotification("🚨 Staff Join",p.Name.." masuk (tag:"..tag..")",Color3.fromRGB(255,0,0),5)
        end
    end
end)

-- Join server sepi
local function joinLowServer()
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    local data = HttpService:JSONDecode(game:HttpGet(url))
    local lowest
    for _,s in ipairs(data.data) do
        if s.playing <= 2 then lowest=s break end
        if not lowest or s.playing < lowest.playing then lowest=s end
    end
    if lowest then
        showCustomNotification("🔒 Teleport","Server ID: "..lowest.id.." | "..lowest.playing.." players",Color3.fromRGB(180,220,255),3)
        TeleportService:TeleportToPlaceInstance(placeId,lowest.id,player)
    else
        showCustomNotification("❌ Gagal","Tidak ada server sepi",Color3.fromRGB(255,120,120),3)
    end
end

-- UI
local function createUI()
    if playerGui:FindFirstChild("YARSCompactGUI") then
        playerGui.YARSCompactGUI:Destroy()
    end
    local gui=Instance.new("ScreenGui",playerGui)
    gui.Name="YARSCompactGUI"

    local frame=Instance.new("Frame",gui)
    frame.Size=UDim2.new(0,230,0,380)
    frame.Position=UDim2.new(0.3,0,0.3,0)
    frame.BackgroundColor3=Color3.fromRGB(35,35,40)
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)

    -- Drag
    local dragging=false local dragInput,dragStart,startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true dragStart=input.Position startPos=frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then
            local delta=input.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)

    -- Scroll area
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,0,1,-30)
    scroll.Position = UDim2.new(0,0,0,30)
    scroll.CanvasSize = UDim2.new(0,0,0,500)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundTransparency=1
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,5)

    -- Header
    local header=Instance.new("Frame",frame)
    header.Size=UDim2.new(1,0,0,30)
    header.BackgroundColor3=Color3.fromRGB(45,45,50)
    Instance.new("UICorner",header).CornerRadius=UDim.new(0,8)

    local title=Instance.new("TextLabel",header)
    title.Size=UDim2.new(1,-90,1,0)
    title.Position=UDim2.new(0,10,0,0)
    title.BackgroundTransparency=1
    title.Text="YARS Summit Auto"
    title.TextColor3=Color3.fromRGB(255,255,255)
    title.Font=Enum.Font.GothamBold
    title.TextSize=12
    title.TextXAlignment=Enum.TextXAlignment.Left

    local close=Instance.new("TextButton",header)
    close.Size=UDim2.new(0,25,0,25)
    close.Position=UDim2.new(1,-30,0,2.5)
    close.BackgroundColor3=Color3.fromRGB(255,100,100)
    close.Text="✕"
    close.MouseButton1Click:Connect(function()
        autoSummitEnabled=false gui:Destroy()
    end)

    -- Tombol generator
    local function makeBtn(text,color,callback)
        local btn=Instance.new("TextButton",scroll)
        btn.Size=UDim2.new(1,-20,0,30)
        btn.BackgroundColor3=color
        btn.Text=text btn.TextColor3=Color3.fromRGB(0,0,0)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    makeBtn("🏠 Basecamp",Color3.fromRGB(150,150,255),function() teleportTo(BASECAMP_POS) end)
    makeBtn("🚀 Puncak",Color3.fromRGB(255,150,100),function() teleportTo(SUMMIT_POS) end)
    makeBtn("🔄 Respawn (Remote)",Color3.fromRGB(255,200,150),function() resetSummit() end)

    local autoBtn=makeBtn("⚡ AUTO: OFF",Color3.fromRGB(100,255,100),function()
        autoSummitEnabled=not autoSummitEnabled
        if autoSummitEnabled then
            autoBtn.Text="⚡ AUTO: ON"
            autoBtn.BackgroundColor3=Color3.fromRGB(255,100,100)
            startAutoSummit()
        else
            autoBtn.Text="⚡ AUTO: OFF"
            autoBtn.BackgroundColor3=Color3.fromRGB(100,255,100)
        end
    end)

    makeBtn("🔍 Scan Server",Color3.fromRGB(255,255,100),function() scanServer() end)
    makeBtn("🔒 Join Server Sepi",Color3.fromRGB(100,255,255),function() joinLowServer() end)

    -- Speed control
    local speedLabel=Instance.new("TextLabel",scroll)
    speedLabel.Size=UDim2.new(1,-20,0,20)
    speedLabel.BackgroundTransparency=1
    speedLabel.Text="⏱️ Delay: "..loopDelay.."s"
    speedLabel.TextColor3=Color3.fromRGB(255,255,255)
    speedLabel.Font=Enum.Font.Gotham
    speedLabel.TextSize=12

    makeBtn("+ Delay",Color3.fromRGB(100,200,255),function()
        if loopDelay < 5 then loopDelay=loopDelay+0.5 speedLabel.Text="⏱️ Delay: "..loopDelay.."s" end
    end)
    makeBtn("- Delay",Color3.fromRGB(255,150,150),function()
        if loopDelay > 0.5 then loopDelay=loopDelay-0.5 speedLabel.Text="⏱️ Delay: "..loopDelay.."s" end
    end)
end

showCustomNotification("YARS Ready","Summit Auto + Scan Loaded!",Color3.fromRGB(200,200,255),3)
createUI()
