-- Tombol UpdateMDPL (Delta Executor Ready)
-- Script sederhana, aman untuk tes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Cari UpdateMDPL di ReplicatedStorage
local UpdateMDPL = ReplicatedStorage:FindFirstChild("UpdateMDPL")
if not UpdateMDPL then
    warn("UpdateMDPL tidak ditemukan di ReplicatedStorage")
    return
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "UpdateMDPL_GUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,60)
frame.Position = UDim2.new(0.05,0,0.1,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1,-20,1,-20)
btn.Position = UDim2.new(0,10,0,10)
btn.Text = "Update MDPL"
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
btn.BackgroundColor3 = Color3.fromRGB(70,50,160)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

btn.MouseButton1Click:Connect(function()
    if UpdateMDPL:IsA("RemoteEvent") then
        UpdateMDPL:FireServer()
        print("UpdateMDPL:FireServer() dipanggil")
    elseif UpdateMDPL:IsA("RemoteFunction") then
        UpdateMDPL:InvokeServer()
        print("UpdateMDPL:InvokeServer() dipanggil")
    else
        warn("UpdateMDPL bukan RemoteEvent atau RemoteFunction")
    end
end)
