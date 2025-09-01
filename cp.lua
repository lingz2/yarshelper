-- AUTO TELEPORT CHECKPOINT & SUMMIT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

-- GUI utama
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GunungHelper"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,300,0,400)
MainFrame.Position = UDim2.new(0,20,0.5,-200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "🗻 Gunung Helper"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)

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

-- Popup
local PopupLabel = Instance.new("TextLabel", ScreenGui)
PopupLabel.Size = UDim2.new(0,300,0,35)
PopupLabel.Position = UDim2.new(0.5,-150,0,50)
PopupLabel.BackgroundColor3 = Color3.fromRGB(50,150,50)
PopupLabel.TextColor3 = Color3.new(1,1,1)
PopupLabel.Font = Enum.Font.SourceSansBold
PopupLabel.TextScaled = true
PopupLabel.BackgroundTransparency = 0.3
PopupLabel.Text = ""
local lastPopup = nil

local function ShowPopup(msg, color)
    color = color or Color3.fromRGB(50,150,50)
    if lastPopup == msg then return end
    lastPopup = msg
    PopupLabel.Text = msg
    PopupLabel.BackgroundColor3 = color
    TweenService:Create(PopupLabel, TweenInfo.new(0.3), {BackgroundTransparency=0.3}):Play()
    delay(2, function()
        TweenService:Create(PopupLabel, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
        lastPopup = nil
    end)
end

-- Teleport
local function TeleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(pos)
    end
end

-- Scan map
local checkpoints = {}
local summit = nil

local function ScanMap()
    checkpoints = {}
    summit = nil

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local lname = v.Name:lower()
            if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") or tonumber(lname) then
                table.insert(checkpoints,v)
            elseif lname:find("summit") or lname:find("puncak") or lname:find("peak") then
                summit = v
            end
        end
    end

    table.sort(checkpoints, function(a,b)
        return a.Position.Y < b.Position.Y
    end)

    -- Info popup
    if #checkpoints>0 then
        local names = ""
        for i,p in ipairs(checkpoints) do
            names = names..p.Name..(i<#checkpoints and ", " or "")
        end
        ShowPopup("✅ Checkpoints ("..#checkpoints.."): "..names, Color3.fromRGB(50,200,50))
    else
        ShowPopup("ℹ️ Tidak ada checkpoint terdeteksi", Color3.fromRGB(255,200,0))
    end

    if summit then
        ShowPopup("🏔 Summit terdeteksi: "..summit.Name, Color3.fromRGB(220,200,50))
    else
        ShowPopup("ℹ️ Tidak ada summit terdeteksi", Color3.fromRGB(255,200,0))
    end
end

-- Template button
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
local function GenerateButtons()
    Scroller:ClearAllChildren()
    local y = 0

    local btn = MakeButton("🔄 Rescan",function()
        ScanMap()
        GenerateButtons()
    end)
    btn.Position = UDim2.new(0,5,0,y)
    btn.Parent = Scroller
    y = y + 40

    for i,cp in ipairs(checkpoints) do
        local b = MakeButton("CP"..i.." ("..cp.Name..")",function()
            TeleportTo(cp.Position + Vector3.new(0,5,0))
            ShowPopup("➡️ Teleport ke CP"..i.." ("..cp.Name..")")
        end)
        b.Position = UDim2.new(0,5,0,y)
        b.Parent = Scroller
        y = y + 40
    end

    if summit then
        local b = MakeButton("🏔 Summit ("..summit.Name..")",function()
            TeleportTo(summit.Position + Vector3.new(0,5,0))
            ShowPopup("➡️ Teleport ke Summit ("..summit.Name..")")
        end)
        b.Position = UDim2.new(0,5,0,y)
        b.Parent = Scroller
        y = y + 40
    end

    Scroller.CanvasSize = UDim2.new(0,0,0,y)
end

-- Hide toggle
local hidden=false
HideBtn.MouseButton1Click:Connect(function()
    hidden=not hidden
    MainFrame.Visible = not hidden
end)

-- Init
ScanMap()
GenerateButtons()
