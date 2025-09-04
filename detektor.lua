-- REMOTE SCANNER AMAN (Hanya membaca, tidak hook)
-- Delta Executor Ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SafeRemoteScanner"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,400,0,300)
main.Position = UDim2.new(0.05,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,36)
title.BackgroundTransparency = 1
title.Text = "Safe Remote Scanner"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-10,1,-46)
scroll.Position = UDim2.new(0,5,0,40)
scroll.BackgroundColor3 = Color3.fromRGB(35,35,45)
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,0)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0,4)
list.SortOrder = Enum.SortOrder.LayoutOrder

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

-- scan folder tanpa hook
local function scanFolder(folder)
    for _,v in pairs(folder:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            logRemote("[RemoteEvent] "..v:GetFullName())
        elseif v:IsA("RemoteFunction") then
            logRemote("[RemoteFunction] "..v:GetFullName())
        end
    end
end

scanFolder(ReplicatedStorage)
scanFolder(Workspace)
scanFolder(player.PlayerScripts)
scanFolder(player.Backpack)

-- listen remote baru muncul
local folders = {ReplicatedStorage, Workspace, player.PlayerScripts, player.Backpack}
for _,folder in pairs(folders) do
    folder.DescendantAdded:Connect(function(v)
        if v:IsA("RemoteEvent") then
            logRemote("[RemoteEvent] "..v:GetFullName())
        elseif v:IsA("RemoteFunction") then
            logRemote("[RemoteFunction] "..v:GetFullName())
        end
    end)
end
