-- GUI TELEPORT LAVA SHARD
-- Delta Executor Ready

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")

-- Daftar shard
local shardNames = {"LavaShard_1", "LavaShard_2", "LavaShard_3", "LavaShard_4"}

-- Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "LavaShardTP"
gui.Parent = game.CoreGui

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Ubah style frame
local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 12)

-- Judul
local title = Instance.new("TextLabel")
title.Text = "Teleport Lava Shard"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Fungsi teleport
local function teleportToShard(shardName)
    local shard = workspace:FindFirstChild(shardName, true)
    if shard and shard:IsA("BasePart") then
        hrp.CFrame = shard.CFrame + Vector3.new(0, 5, 0)
        print("Teleport ke:", shardName, shard.Position)
    else
        warn("Tidak ketemu:", shardName)
    end
end

-- Buat tombol per shard
for i, shardName in ipairs(shardNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 30 * i)
    btn.Text = shardName
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = frame
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        teleportToShard(shardName)
    end)
end
