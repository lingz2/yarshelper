-- YARS AUTO SUMMIT FINAL (dengan Save CP)
-- Basecamp -> CP1 -> ... -> CP11 -> SendSummit -> balik Basecamp
-- Jika mati, lanjut dari CP terakhir
-- Tekan [M] untuk toggle GUI (jika perlu bisa ditambah)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- koordinat checkpoint (cp1 diperbarui sesuai yang kamu kirim)
local checkpoints = {
    ["basecamp"] = CFrame.new(167.319855, 4.23206806, -621.273193, 0, 0, 1, 0, 1, 0, -1, 0, 0), -- basecamp (sesuai yg kamu sebutkan)
    [1] = CFrame.new(
        -165.121399, 4.23206806, -657.757263,
        0.766828477, 2.463231576e-08, -0.641852021,
        1.92095833e-08, 1, 6.132685836e-08,
        0.641852021, -5.935689276e-08, 0.766828477
    ), -- CP1 (Diperbarui)
    [2] = CFrame.new(-121.60952, 8.50454998, 544.049377),
    [3] = CFrame.new(-40.0167122, 392.432037, 673.959045),
    [4] = CFrame.new(-296.999634, 484.432037, 779.003052),
    [5] = CFrame.new(18.0000038, 572.429688, 692),
    [6] = CFrame.new(595.273804, 916.432007, 620.967712),
    [7] = CFrame.new(283.5, 1196.43201, 181.5),
    [8] = CFrame.new(552.105835, 1528.43201, -581.302246),
    [9] = CFrame.new(332.142334, 1736.43201, -260.883789),
    [10] = CFrame.new(290.354126, 1979.03186, -203.905533),
    [11] = CFrame.new(616.488281, 3260.50879, -66.2258759), -- CP11
    ["summit"] = CFrame.new(
        408.080811, 3261.43188, -110.906059,
        0.664278328, 3.246494276e-08, 0.74748534,
        3.87810708e-08, 1, -7.789633836e-08,
        -0.74748534, 8.073312336e-08, 0.664278328
    )
}

-- remote (gunakan remotes sesuai game)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = nil
pcall(function() RemotesFolder = ReplicatedStorage:WaitForChild("Remotes") end)
local SendSummit = nil
if RemotesFolder then
    pcall(function() SendSummit = RemotesFolder:WaitForChild("SendSummit") end)
end

-- state
local HumanoidRootPart = nil
local lastCP = "basecamp" -- disimpan sebagai "basecamp" atau angka 1..11 atau "summit"
local autoRunning = false
local cpDelay = 2 -- delay default antar CP (kamu bisa ubah)
local summitDelay = 2 -- delay default antar SendSummit spam (kamu bisa ubah)

-- safety helper: teleport ke CFrame bila ada HRP
local function tpTo(cf)
    if not HumanoidRootPart then return end
    pcall(function()
        HumanoidRootPart.CFrame = cf + Vector3.new(0,3,0)
    end)
end

-- spam SendSummit sampai nilai summit di leaderstats meningkat
local function sendSummitUntilIncrease()
    if not SendSummit then
        warn("SendSummit remote not found.")
        return
    end

    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local summitVal = ls and (ls:FindFirstChild("Summit") or ls:FindFirstChild("summit"))
    local before = summitVal and summitVal.Value or nil
    local tries = 0

    -- jika tidak ada leaderstat summit, lakukan beberapa kali panggilan tapi batasi tries
    while autoRunning do
        pcall(function() SendSummit:FireServer(1) end)
        tries = tries + 1
        task.wait(summitDelay)

        if summitVal and before ~= nil and summitVal.Value > before then
            -- sukses
            break
        end

        -- safety timeout: kalau tidak ada leaderstats, kita coba beberapa kali lalu break
        if not summitVal and tries >= 10 then
            break
        end
    end
end

-- fungsi core auto (jalankan dari basecamp -> cp1..cp11 -> sendSummit -> basecamp)
local function autoLoop()
    autoRunning = true
    -- pastikan HRP ada
    HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or HumanoidRootPart

    while autoRunning do
        -- Loop CP1..CP11 (mulai dari 1)
        for i = 1, 11 do
            if not autoRunning then break end
            local cp = checkpoints[i]
            if cp then
                tpTo(cp)
                lastCP = i
                task.wait(cpDelay)
            end
        end

        if not autoRunning then break end

        -- langsung ke sendSummit (tidak perlu puncak jika kamu mau)
        -- jika kamu ingin tetap ke puncak sebelum sendsummit, tpTo(checkpoints["summit"]) dulu
        sendSummitUntilIncrease()

        -- setelah sukses, teleport balik ke basecamp (lokasi yang kamu sebutkan)
        if not autoRunning then break end
        tpTo(checkpoints["basecamp"])
        lastCP = "basecamp"
        task.wait(1)
        -- loop ulang dari basecamp -> cp1...
    end
end

-- resume handler bila respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    task.wait(0.8) -- biarkan server settle

    -- jika auto sedang berjalan dan lastCP bukan basecamp, lanjutkan dari lastCP
    if autoRunning then
        if lastCP == "basecamp" then
            -- nothing special, autoLoop akan mulai dari awal
            return
        end

        -- teleport ke lastCP dulu (jika valid)
        if type(lastCP) == "number" and checkpoints[lastCP] then
            tpTo(checkpoints[lastCP])
            task.wait(0.6)
            -- lanjut dari lastCP+1 -> 11
            for i = (lastCP + 1), 11 do
                if not autoRunning then break end
                tpTo(checkpoints[i])
                lastCP = i
                task.wait(cpDelay)
            end
            if autoRunning then
                -- send summit then basecamp like normal
                sendSummitUntilIncrease()
                tpTo(checkpoints["basecamp"])
                lastCP = "basecamp"
            end
        else
            -- jika lastCP bukan angka, biarkan loop normal berjalan
        end
    end
end)

-- GUI sederhana: start/stop
local gui = Instance.new("ScreenGui")
gui.Name = "YARS_AutoSummit_GUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,160,0,36)
btn.Position = UDim2.new(0.02,0,0.05,0)
btn.Text = "Start Auto Summit"
btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14

local stopBtn = Instance.new("TextButton", gui)
stopBtn.Size = UDim2.new(0,160,0,36)
stopBtn.Position = UDim2.new(0.02,0,0.12,0)
stopBtn.Text = "Stop Auto Summit"
stopBtn.BackgroundColor3 = Color3.fromRGB(80,40,40)
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14

btn.MouseButton1Click:Connect(function()
    if not autoRunning then
        -- try set HumanoidRootPart now if character exists
        HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or HumanoidRootPart
        task.spawn(autoLoop)
        btn.Text = "Running..."
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    autoRunning = false
    btn.Text = "Start Auto Summit"
end)

-- optional: allow M toggle GUI visibility
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
