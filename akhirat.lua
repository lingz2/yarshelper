-- YARS Summit Auto + Scan Combo - FINAL

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Koordinat (ubah sesuai map)
local SUMMIT_POS = CFrame.new(3041.74048, 7876.99756, 1037.59253)
local BASECAMP_POS = CFrame.new(-243.999069, 120.998016, 202.997528)

-- Remote reset summit
local ReturnToSpawn = game.ReplicatedStorage:WaitForChild("ReturnToSpawn")

-- Vars
local autoSummitEnabled = false
local loopDelay = 1.5
local riskyTags = {"malaikat","staff","admin","developer","dev","owner"} -- keyword

-- Jika ada list username asli staff, taruh di sini
local staffList = {
    "NamaAdminAsli", "NamaDevAsli"
}

-- Notifikasi custom
local function showCustomNotification(title, text, color, duration)
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "YARSNotif"
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 300, 0, 60)
    frame.Position = UDim2.new(1, 20, 0, 20)
    frame.BackgroundColor3 = color or Color3.fromRGB(30,30,35)
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    local t1 = Instance.new("TextLabel", frame)
    t1.Size = UDim2.new(1,-20,0,20)
    t1.Position = UDim2.new(0,10,0,5)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = Color3.fromRGB(255,255,255)
    t1.Font = Enum.Font.GothamBold
    t1.TextSize = 14
    t1.TextXAlignment = Enum.TextXAlignment.Left

    local t2 = Instance.new("TextLabel", frame)
    t2.Size = UDim2.new(1,-20,0,30)
    t2.Position = UDim2.new(0,10,0,25)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.TextColor3 = Color3.fromRGB(220,220,220)
    t2.Font = Enum.Font.Gotham
    t2.TextSize = 12
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextWrapped = true

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1,-320,0,20)}):Play()
    task.delay(duration or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1,20,0,20)}):Play()
        task.wait(0.35)
        gui:Destroy()
    end)
end

-- Teleport
local function teleportTo(cf, name)
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
        showCustomNotification("🔄 Reset Summit","ReturnToSpawn Fired!",Color3.fromRGB(100,255,100),2)
    end)
end

-- Auto Summit Loop
local function autoSummitLoop()
    task.spawn(function()
        while autoSummitEnabled do
            if teleportTo(SUMMIT_POS,"Puncak") then
                task.wait(0.5)
                resetSummit()
                task.wait(loopDelay)
            else
                showCustomNotification("❌ Teleport Gagal","Retrying..",Color3.fromRGB(255,100,100),2)
                task.wait(2)
            end
        end
    end)
end

-- 🔍 Scan Server
local function scanServer()
    local players = Players:GetPlayers()
    local detected = {}

    for _,p in ipairs(players) do
        local uname = string.lower(p.Name)
        local dname = string.lower(p.DisplayName)

        -- Cek username di list
        for _,s in ipairs(staffList) do
            if string.lower(s) == uname then
                table.insert(detected, p.Name.." (STAFF)")
            end
        end

        -- Cek keyword di username / displayname
        for _,tag in ipairs(riskyTags) do
            if string.find(uname, tag) or string.find(dname, tag) then
                table.insert(detected, p.Name.." (tag:"..tag..")")
            end
        end
    end

    if #detected > 0 then
        showCustomNotification("⚠️ WARNING","Staff/Admin terdeteksi: "..table.concat(detected,", "),Color3.fromRGB(255,50,50),5)
    else
        showCustomNotification("✅ Aman","Tidak ada staff terdeteksi",Color3.fromRGB(100,255,100),3)
    end
end

-- 🚨 Auto peringatan jika staff join
Players.PlayerAdded:Connect(function(p)
    local uname = string.lower(p.Name)
    local dname = string.lower(p.DisplayName)

    for _,s in ipairs(staffList) do
        if string.lower(s) == uname then
            showCustomNotification("🚨 Staff Join",p.Name.." masuk server!",Color3.fromRGB(255,0,0),5)
        end
    end

    for _,tag in ipairs(riskyTags) do
        if string.find(uname,tag) or string.find(dname,tag) then
            showCustomNotification("🚨 Staff Join",p.Name.." masuk (tag:"..tag..")",Color3.fromRGB(255,0,0),5)
        end
    end
end)

-- 🔒 Join server sepi
local function joinLowServer()
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    local data = HttpService:JSONDecode(game:HttpGet(url))
    local lowest

    for _,s in ipairs(data.data) do
        if s.playing <= 2 then
            lowest = s
            break
        elseif not lowest or s.playing < lowest.playing then
            lowest = s
        end
    end

    if lowest then
        showCustomNotification("🔒 Teleport","Server ID: "..lowest.id.." | "..lowest.playing.." players",Color3.fromRGB(100,200,255),3)
        TeleportService:TeleportToPlaceInstance(placeId,lowest.id,player)
    else
        showCustomNotification("❌ Gagal","Tidak ada server sepi",Color3.fromRGB(255,100,100),3)
    end
end

-- UI
local function createUI()
    if playerGui:FindFirstChild("YARSCompactGUI") then
        playerGui.YARSCompactGUI:Destroy()
    end
    local gui = Instance.new("ScreenGui",playerGui)
    gui.Name="YARSCompactGUI"
    local frame = Instance.new("Frame",gui)
    frame.Size=UDim2.new(0,220,0,360)
    frame.Position=UDim2.new(0,20,0.5,-180)
    frame.BackgroundColor3=Color3.fromRGB(35,35,40)
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)

    -- Tombol utama
    local function makeBtn(text,y,color,callback)
        local btn=Instance.new("TextButton",frame)
        btn.Size=UDim2.new(1,-20,0,30)
        btn.Position=UDim2.new(0,10,0,y)
        btn.BackgroundColor3=color
        btn.Text=text
        btn.TextColor3=Color3.fromRGB(0,0,0)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    makeBtn("🏠 Basecamp",40,Color3.fromRGB(150,150,255),function() teleportTo(BASECAMP_POS,"Basecamp") end)
    makeBtn("🚀 Puncak",80,Color3.fromRGB(255,150,100),function() teleportTo(SUMMIT_POS,"Puncak") end)
    makeBtn("🔄 Respawn (Remote)",120,Color3.fromRGB(255,200,150),function() resetSummit() end)

    local autoBtn=makeBtn("⚡ AUTO: OFF",160,Color3.fromRGB(100,255,100),function()
        autoSummitEnabled=not autoSummitEnabled
        if autoSummitEnabled then
            autoBtn.Text="⚡ AUTO: ON"
            autoBtn.BackgroundColor3=Color3.fromRGB(255,100,100)
            autoSummitLoop()
        else
            autoBtn.Text="⚡ AUTO: OFF"
            autoBtn.BackgroundColor3=Color3.fromRGB(100,255,100)
        end
    end)

    makeBtn("🔍 Scan Server",200,Color3.fromRGB(255,255,100),function() scanServer() end)
    makeBtn("🔒 Join Server Sepi",240,Color3.fromRGB(100,255,255),function() joinLowServer() end)
end

-- Start
showCustomNotification("YARS Ready","Summit Auto + Scan Loaded!",Color3.fromRGB(100,200,255),4)
createUI()
