-- 🪧 Sniffer Tombol + Remote → Output ke Papan di Dunia
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Buat papan (BillboardGui) di atas kepala player
local part = Instance.new("Part", Workspace)
part.Size = Vector3.new(5, 3, 1)
part.Anchored = true
part.CanCollide = false
part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 8, 0)
part.Name = "LogBoard"

local billboard = Instance.new("BillboardGui", part)
billboard.Size = UDim2.new(0, 500, 0, 300)
billboard.StudsOffset = Vector3.new(0, 2, 0)
billboard.AlwaysOnTop = true

local frame = Instance.new("ScrollingFrame", billboard)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.3
frame.CanvasSize = UDim2.new(0, 0, 10, 0)

local layout = Instance.new("UIListLayout", frame)

local function addLog(msg)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = msg
end

-- 📌 Deteksi tombol GUI
PlayerGui.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextButton") then
        obj.MouseButton1Click:Connect(function()
            addLog("[Tombol] " .. obj.Name .. " | Text: " .. obj.Text)
        end)
    end
end)

-- 📌 Hook RemoteEvent & RemoteFunction
local function hookRemotes(obj)
    if obj:IsA("RemoteEvent") then
        local old = obj.FireServer
        obj.FireServer = function(self, ...)
            local args = {...}
            local str = ""
            for i,v in ipairs(args) do
                str = str .. tostring(v) .. (i < #args and ", " or "")
            end
            addLog("[RemoteEvent] " .. self.Name .. " | Args: " .. str)
            return old(self, ...)
        end
    elseif obj:IsA("RemoteFunction") then
        local old = obj.InvokeServer
        obj.InvokeServer = function(self, ...)
            local args = {...}
            local str = ""
            for i,v in ipairs(args) do
                str = str .. tostring(v) .. (i < #args and ", " or "")
            end
            addLog("[RemoteFunction] " .. self.Name .. " | Args: " .. str)
            return old(self, ...)
        end
    end
end

-- Pasang hook ke semua remote yang ada
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        hookRemotes(v)
    end
end

-- Kalau ada remote baru muncul
game.DescendantAdded:Connect(function(obj)
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        hookRemotes(obj)
    end
end)
