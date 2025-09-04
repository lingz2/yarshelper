-- UNIVERSAL REMOTE SCANNER DI GUI
-- Delta Executor Ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local detected = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScannerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.05, 0, 0.1, 0)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,36)
title.BackgroundTransparency = 1
title.Text = "Remote Scanner (Pre-Scan)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,3)
close.Text = "X"
close.TextColor3 = Color3.new(1,0.4,0.4)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-10,1,-46)
scroll.Position = UDim2.new(0,5,0,40)
scroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
scroll.BackgroundTransparency = 0.1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,0)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0,4)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- fungsi tampilkan remote di GUI
local function logRemote(text)
    local lbl = Instance.new("TextLabel", scroll)
    lbl.Size = UDim2.new(1,-10,0,20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.Text = text
    scroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y+10)
end

-- Hook FireServer
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") and not detected[remote] then
        detected[remote] = true
        logRemote("[RemoteEvent] "..remote:GetFullName())
        local old = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            logRemote("[Called] "..remote:GetFullName().." | Args: "..table.concat(args,", "))
            return old(self, ...)
        end
    end
end

-- Hook InvokeServer
local function hookFunction(remote)
    if remote:IsA("RemoteFunction") and not detected[remote] then
        detected[remote] = true
        logRemote("[RemoteFunction] "..remote:GetFullName())
        local old = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            logRemote("[Called] "..remote:GetFullName().." | Args: "..table.concat(args,", "))
            return old(self, ...)
        end
    end
end

-- scan semua folder penting
local function scanFolder(folder)
    for _,v in pairs(folder:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            hookRemote(v)
        elseif v:IsA("RemoteFunction") then
            hookFunction(v)
        end
    end
end

scanFolder(ReplicatedStorage)
scanFolder(Workspace)
scanFolder(player.PlayerScripts)
scanFolder(player.Backpack)

-- listen Remote baru
local folders = {ReplicatedStorage, Workspace, player.PlayerScripts, player.Backpack}
for _,folder in pairs(folders) do
    folder.DescendantAdded:Connect(function(v)
        if v:IsA("RemoteEvent") then hookRemote(v)
        elseif v:IsA("RemoteFunction") then hookFunction(v)
        end
    end)
end

-- notifikasi
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "Remote Scanner Aktif",
    Text = "Semua RemoteEvent / RemoteFunction sudah discan, muncul di GUI",
    Duration = 6
})
