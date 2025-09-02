-- 📌 Remote Explorer GUI (Delta safe)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Buat GUI utama
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "RemoteExplorer"

local frame = Instance.new("ScrollingFrame", ScreenGui)
frame.Size = UDim2.new(0.4, 0, 0.5, 0)
frame.Position = UDim2.new(0.3, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.CanvasSize = UDim2.new(0,0,10,0)

local layout = Instance.new("UIListLayout", frame)

-- Fungsi buat tombol
local function addButton(remote)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Text = remote.Name .. " ("..remote.ClassName..")"
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)

    btn.MouseButton1Click:Connect(function()
        print("🔹 Mencoba Remote:", remote.Name, "| Type:", remote.ClassName)
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer()
            end)
        elseif remote:IsA("RemoteFunction") then
            pcall(function()
                remote:InvokeServer()
            end)
        end
    end)
end

-- Cari semua Remote di ReplicatedStorage
for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        addButton(v)
    end
end
