-- YARS SUMMIT FINAL SMART AUTO (Revisi)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local ReturnToSpawn = ReplicatedStorage:WaitForChild("ReturnToSpawn")
local autoEnabled = false
local retryDelay = 0.5 -- default 0.5 detik (0.1 - 1 bisa diatur)

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 3
        })
    end)
end

-- ambil CP terakhir yang tersimpan
local function getSavedCheckpoint()
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Checkpoint") then
        return stats.Checkpoint.Value
    end
    return 0
end

-- daftar checkpoint (vector3 masih sama)
local cpList = {
    Vector3.new(-134.886,419.735,-220.923),
    Vector3.new(3,948.16,-1054.293),
    Vector3.new(108.989,1200.198,-1359.282),
    Vector3.new(102.756,1463.675,-1807.980),
    Vector3.new(299.767,1863.834,-2331.907),
    Vector3.new(560.049,2083.413,-2560.358),
    Vector3.new(754.672,2184.431,-2500.259),
    Vector3.new(793,2328.431,-2641.294),
    Vector3.new(969,2516.431,-2632.294),
    Vector3.new(1239,2692.231,-2803.294),
    Vector3.new(1621.734,3056.231,-2752.297),
    Vector3.new(1812.914,3576.431,-3246.645),
    Vector3.new(2809.925,4418.998,-4792.259),
    Vector3.new(3470,4856.231,-4178.293),
    Vector3.new(3477.916,5102.791,-4273.476),
    Vector3.new(3974.893,5664.431,-3970.728),
    Vector3.new(4497.52,5896.431,-3786.269),
    Vector3.new(5062.791,6368.431,-2973.971),
    Vector3.new(5537.998,6588.431,-2484.27),
    Vector3.new(5548.549,6870.99,-1047.394),
    Vector3.new(4328.273,7638.656,131.682),
    Vector3.new(3456.184,7708.392,937.936)
}
local summit = Vector3.new(3041.74,7876.997,1037.592)

-- teleport
local function tpTo(pos, name)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local root = char.HumanoidRootPart
    root.CFrame = CFrame.new(pos)
    notify("Teleport", name.." ✅")
end

-- auto loop
local function autoLoop()
    task.spawn(function()
        while autoEnabled do
            local startIndex = getSavedCheckpoint() + 1
            for i = startIndex, #cpList do
                if not autoEnabled then break end
                repeat
                    tpTo(cpList[i], "CP"..i)
                    task.wait(retryDelay)
                until not autoEnabled or getSavedCheckpoint() >= i
            end
            if autoEnabled then
                tpTo(summit, "Summit")
                ReturnToSpawn:FireServer()
                notify("Summit", "Reset to Basecamp ✅")
                task.wait(1)
            end
        end
    end)
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "YARSFinal"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,400)
frame.Position = UDim2.new(0,20,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "YARS Summit Helper"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- tombol auto
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1,-20,0,30)
autoBtn.Position = UDim2.new(0,10,0,40)
autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
autoBtn.Text = "⚡ AUTO: OFF"
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        autoBtn.Text = "⚡ AUTO: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
        autoLoop()
    else
        autoBtn.Text = "⚡ AUTO: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(100,255,100)
    end
end)

-- slider speed (retryDelay)
local speedBtn = Instance.new("TextButton", frame)
speedBtn.Size = UDim2.new(1,-20,0,30)
speedBtn.Position = UDim2.new(0,10,0,80)
speedBtn.BackgroundColor3 = Color3.fromRGB(150,150,80)
speedBtn.Text = "Retry Delay: "..retryDelay
speedBtn.MouseButton1Click:Connect(function()
    retryDelay = retryDelay + 0.1
    if retryDelay > 1 then retryDelay = 0.1 end
    speedBtn.Text = "Retry Delay: "..string.format("%.1f", retryDelay)
end)

notify("YARS Summit","Revisi Smart Auto Loaded ✅")
