-- Remote Tester GUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteTester"
gui.Parent = player:WaitForChild("PlayerGui")

-- ScrollingFrame biar bisa scroll
local scroll = Instance.new("ScrollingFrame", gui)
scroll.Size = UDim2.new(0, 200, 0, 400)
scroll.Position = UDim2.new(0, 20, 0.5, -200)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- Buat tombol untuk setiap RemoteEvent
for _,v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(50,50,50)
        button.TextColor3 = Color3.fromRGB(255,255,255)
        button.Text = v.Name
        button.Parent = scroll

        button.MouseButton1Click:Connect(function()
            print("🔥 Test Remote:", v.Name)
            local success, err = pcall(function()
                v:FireServer()
            end)
            if not success then
                warn("⚠️ Remote gagal:", v.Name, err)
            else
                print("✅ Remote berhasil dipanggil:", v.Name)
            end
        end)
    end
end

-- Update tinggi canvas agar bisa scroll
layout.Changed:Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)
