local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TeleportUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,250,0,300)
MainFrame.Position = UDim2.new(0,20,0.5,-150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "Teleport Helper"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(50,50,50)

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0,40,0,40)
HideBtn.Position = UDim2.new(1,-40,0,0)
HideBtn.Text = "-"
HideBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
HideBtn.TextColor3 = Color3.new(1,1,1)

local Scroller = Instance.new("ScrollingFrame", MainFrame)
Scroller.Size = UDim2.new(1,0,1,-40)
Scroller.Position = UDim2.new(0,0,0,40)
Scroller.CanvasSize = UDim2.new(0,0,0,0)
Scroller.ScrollBarThickness = 6
Scroller.BackgroundTransparency = 1

-- Hide/Show GUI
local hidden=false
HideBtn.MouseButton1Click:Connect(function()
    hidden = not hidden
    MainFrame.Visible = not hidden
    if hidden then
        HideBtn.Text = "+"
    else
        HideBtn.Text = "-"
    end
end)

-- Scan checkpoint & summit
local checkpoints = {}
local summit = nil

for _,v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        local lname = v.Name:lower()
        if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") or tonumber(lname) then
            table.insert(checkpoints,v)
        elseif lname:find("summit") or lname:find("puncak") then
            summit = v
        end
    end
end

table.sort(checkpoints,function(a,b) return a.Position.Y < b.Position.Y end)

-- Fungsi teleport
local function TeleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
        -- Debug popup
        local popup = Instance.new("TextLabel", ScreenGui)
        popup.Size = UDim2.new(0,220,0,25)
        popup.Position = UDim2.new(0,10,0.5,50)
        popup.BackgroundColor3 = Color3.fromRGB(40,40,40)
        popup.TextColor3 = Color3.new(1,1,1)
        popup.Text = "Teleport ke: "..tostring(pos)
        popup.Font = Enum.Font.SourceSansBold
        popup.TextScaled = true
        delay(2,function() popup:Destroy() end)
    end
end

-- Fungsi buat tombol
local function MakeButton(text,callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,35)
    btn.Position = UDim2.new(0,5,0,0)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Text = text
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Generate tombol teleport
local y=0
for i,cp in ipairs(checkpoints) do
    local b = MakeButton("Teleport CP"..i,function()
        TeleportTo(cp.Position)
    end)
    b.Position = UDim2.new(0,5,0,y)
    b.Parent = Scroller
    y = y + 40
end

if summit then
    local b = MakeButton("Teleport Summit",function()
        TeleportTo(summit.Position)
    end)
    b.Position = UDim2.new(0,5,0,y)
    b.Parent = Scroller
end

Scroller.CanvasSize = UDim2.new(0,0,y)
