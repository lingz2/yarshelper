-- GUI Remote Tester
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "RemoteTester"

-- Frame utama
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 400)
frame.Position = UDim2.new(0, 20, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Layout
local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0,5)

-- Cari semua RemoteEvent di ReplicatedStorage
for _,v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local button = Instance.new("TextButton", frame)
        button.Size = UDim2.new(1, -10, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(50,50,50)
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.Text = v.Name

        button.MouseButton1Click:Connect(function()
            print("🔥 Mengirim Remote:", v.Name)
            pcall(function()
                v:FireServer()
            end)
        end)
    end
end
