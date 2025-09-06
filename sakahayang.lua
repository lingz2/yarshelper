--// AUTO SUMMIT HARD MODE + ROBUST RESPAWN + INVISIBLE (Delta Executor Mobile Ready)
--// Revisi: paksa respawn setelah teleport ke summit, dengan fallback (kill/break joints)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote & Argumen Hard
local RF_GetLevel = ReplicatedStorage:WaitForChild("LevelService"):WaitForChild("RF_GetLevel")
local HardID = 9349848927

-- CFrame Summit (kamu minta ini)
local summitCF = CFrame.new(
    -910.277771, 3142.12842, 562.343323,
    0.921977043, -4.37947945e-09, 0.387244552,
    7.41064721e-09, 1, -6.33441255e-09,
    -0.387244552, 8.70991546e-09, 0.921977043
)

-- Variabel
local running = false
local delayTime = 1
local minDelay, maxDelay = 0.1, 5
local invisible = false
local summitCount = 0

-- GUI (PlayerGui, ResetOnSpawn = false)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSummitGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 250)
Frame.Position = UDim2.new(0.05, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", Frame)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.Text = "🏔️ Auto Summit Hard (Robust)"
title.TextColor3 = Color3.fromRGB(255,215,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 15

local status = Instance.new("TextLabel", Frame)
status.Position = UDim2.new(0,0,0,30)
status.Size = UDim2.new(1,0,0,24)
status.Text = "Status: ❌ OFF"
status.TextColor3 = Color3.fromRGB(255,80,80)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14

local counterLbl = Instance.new("TextLabel", Frame)
counterLbl.Position = UDim2.new(0,0,0,54)
counterLbl.Size = UDim2.new(1,0,0,22)
counterLbl.Text = "Summit Count: 0"
counterLbl.TextColor3 = Color3.fromRGB(100,200,255)
counterLbl.BackgroundTransparency = 1
counterLbl.Font = Enum.Font.Gotham
counterLbl.TextSize = 14

-- Buttons
local startBtn = Instance.new("TextButton", Frame)
startBtn.Position = UDim2.new(0.05,0,0.28,0)
startBtn.Size = UDim2.new(0.4,0,0.16,0)
startBtn.Text = "▶️ Start"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 14
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,8)

local stopBtn = Instance.new("TextButton", Frame)
stopBtn.Position = UDim2.new(0.55,0,0.28,0)
stopBtn.Size = UDim2.new(0.4,0,0.16,0)
stopBtn.Text = "⏹ Stop"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,8)

local invisBtn = Instance.new("TextButton", Frame)
invisBtn.Position = UDim2.new(0.05,0,0.46,0)
invisBtn.Size = UDim2.new(0.9,0,0.14,0)
invisBtn.Text = "👻 Invisible: OFF"
invisBtn.Font = Enum.Font.GothamBold
invisBtn.TextSize = 14
invisBtn.TextColor3 = Color3.new(1,1,1)
invisBtn.BackgroundColor3 = Color3.fromRGB(100,100,255)
Instance.new("UICorner", invisBtn).CornerRadius = UDim.new(0,8)

local delayLbl = Instance.new("TextLabel", Frame)
delayLbl.Position = UDim2.new(0,0,0.62,0)
delayLbl.Size = UDim2.new(1,0,0,22)
delayLbl.Text = "⏱ Delay: "..string.format("%.1f",delayTime).."s"
delayLbl.TextColor3 = Color3.fromRGB(200,200,200)
delayLbl.BackgroundTransparency = 1
delayLbl.Font = Enum.Font.Gotham
delayLbl.TextSize = 14

local minusBtn = Instance.new("TextButton", Frame)
minusBtn.Position = UDim2.new(0.15,0,0.74,0)
minusBtn.Size = UDim2.new(0.3,0,0.12,0)
minusBtn.Text = "-"
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 18
minusBtn.TextColor3 = Color3.new(1,1,1)
minusBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", minusBtn)

local plusBtn = Instance.new("TextButton", Frame)
plusBtn.Position = UDim2.new(0.55,0,0.74,0)
plusBtn.Size = UDim2.new(0.3,0,0.12,0)
plusBtn.Text = "+"
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 18
plusBtn.TextColor3 = Color3.new(1,1,1)
plusBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", plusBtn)

-- Invisible helpers
local function applyInvisible(char)
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function() v.Transparency = 1 end)
            local decal = v:FindFirstChildOfClass("Decal")
            if decal then pcall(function() decal.Transparency = 1 end) end
        elseif v:IsA("Accessory") then
            pcall(function() v:Destroy() end)
        end
    end
end

local function setInvisible(state)
    invisible = state
    if state then
        invisBtn.Text = "👻 Invisible: ON"
        invisBtn.BackgroundColor3 = Color3.fromRGB(50,200,255)
        applyInvisible(player.Character)
    else
        invisBtn.Text = "👻 Invisible: OFF"
        invisBtn.BackgroundColor3 = Color3.fromRGB(100,100,255)
        -- respawn to restore normal appearance
        pcall(function() player:LoadCharacter() end)
    end
end

player.CharacterAdded:Connect(function(char)
    if invisible then
        task.wait(0.5)
        applyInvisible(char)
    end
end)

-- Robust respawn function with timeouts + fallbacks
local function robustRespawn(oldChar)
    -- attempt 1: LoadCharacter()
    pcall(function() player:LoadCharacter() end)
    local start = tick()
    while tick() - start < 5 do
        if player.Character and player.Character ~= oldChar then
            return player.Character
        end
        task.wait(0.1)
    end

    -- attempt 2: try set Humanoid.Health = 0
    if oldChar and oldChar.Parent then
        local hum = oldChar:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.Health = 0 end)
        end
    end
    start = tick()
    while tick() - start < 5 do
        if player.Character and player.Character ~= oldChar then
            return player.Character
        end
        task.wait(0.1)
    end

    -- attempt 3: BreakJoints()
    if oldChar and oldChar.Parent then
        pcall(function() oldChar:BreakJoints() end)
    end
    start = tick()
    while tick() - start < 5 do
        if player.Character and player.Character ~= oldChar then
            return player.Character
        end
        task.wait(0.1)
    end

    -- final attempt: LoadCharacter again and wait (blocking)
    pcall(function() player:LoadCharacter() end)
    local okChar = player.CharacterAdded:Wait(8) -- wait a bit longer
    return okChar
end

-- Main summit loop (robust): teleport -> wait -> force respawn -> continue
local function doSummit()
    while running do
        -- pilih level Hard
        pcall(function()
            RF_GetLevel:InvokeServer(HardID)
        end)

        task.wait(0.3)

        -- teleport ke puncak
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() hrp.CFrame = summitCF end)
        end
        status.Text = "Status: Teleported to summit"
        status.TextColor3 = Color3.fromRGB(200,200,50)

        -- tunggu minimal 1 detik biar server catat summit (jika perlu lebih lama)
        local waitTime = math.max(1, delayTime)
        local t0 = tick()
        while tick() - t0 < waitTime do
            if not running then break end
            task.wait(0.1)
        end

        if not running then break end

        -- RESPWAN (robust)
        status.Text = "Status: Respawning..."
        status.TextColor3 = Color3.fromRGB(255,150,0)
        local newChar = robustRespawn(char)
        if newChar then
            -- apply invisible if needed
            if invisible then
                task.wait(0.4)
                applyInvisible(newChar)
            end

            -- increment counter (summit tercatat di server saat kita di summit)
            summitCount = summitCount + 1
            counterLbl.Text = "Summit Count: "..summitCount
            status.Text = "Status: ✅ Next cycle"
            status.TextColor3 = Color3.fromRGB(50,255,100)
        else
            status.Text = "Status: ❗ Respawn failed"
            status.TextColor3 = Color3.fromRGB(255,80,80)
            -- kalau gagal, kita berhenti supaya tidak loop tanpa respawn
            running = false
            break
        end

        -- jeda sebelum ulang
        local t1 = 0
        while t1 < delayTime do
            if not running then break end
            task.wait(0.1); t1 = t1 + 0.1
        end
    end

    -- jika keluar loop
    if not running then
        status.Text = "Status: ❌ OFF"
        status.TextColor3 = Color3.fromRGB(255,80,80)
    end
end

-- GUI events
startBtn.MouseButton1Click:Connect(function()
    if not running then
        running = true
        status.Text = "Status: ⏳ Starting..."
        status.TextColor3 = Color3.fromRGB(255,200,50)
        task.spawn(doSummit)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
end)

plusBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime + 0.1, minDelay, maxDelay)
    delayLbl.Text = "⏱ Delay: "..string.format("%.1f",delayTime).."s"
end)

minusBtn.MouseButton1Click:Connect(function()
    delayTime = math.clamp(delayTime - 0.1, minDelay, maxDelay)
    delayLbl.Text = "⏱ Delay: "..string.format("%.1f",delayTime).."s"
end)

invisBtn.MouseButton1Click:Connect(function()
    setInvisible(not invisible)
end)
