-- UNIVERSAL GUNUNG: FINAL GABUNGAN
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

-- GUI utama
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GunungHelperGUI"

-- Popup minimal
local PopupLabel = Instance.new("TextLabel", ScreenGui)
PopupLabel.Size = UDim2.new(0,350,0,35)
PopupLabel.Position = UDim2.new(0.5,-175,0,50)
PopupLabel.BackgroundColor3 = Color3.fromRGB(50,150,50)
PopupLabel.TextColor3 = Color3.new(1,1,1)
PopupLabel.Font = Enum.Font.SourceSansBold
PopupLabel.TextScaled = true
PopupLabel.BackgroundTransparency = 0.3
PopupLabel.Text = ""
local lastPopup = nil

local function ShowPopup(msg,color)
    color = color or Color3.fromRGB(50,150,50)
    if lastPopup == msg then return end
    lastPopup = msg
    PopupLabel.Text = msg
    PopupLabel.BackgroundColor3 = color
    TweenService:Create(PopupLabel, TweenInfo.new(0.3), {BackgroundTransparency=0.3}):Play()
    delay(2,function()
        TweenService:Create(PopupLabel, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
        lastPopup = nil
    end)
end

-- GUI utama frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,320,0,450)
MainFrame.Position = UDim2.new(0,20,0.5,-225)
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

local ShowBtn = Instance.new("TextButton", ScreenGui)
ShowBtn.Size = UDim2.new(0,120,0,40)
ShowBtn.Position = UDim2.new(0,20,0.5,-20)
ShowBtn.Text = "Show Helper"
ShowBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
ShowBtn.TextColor3 = Color3.new(1,1,1)
ShowBtn.Font = Enum.Font.SourceSansBold
ShowBtn.TextScaled = true
ShowBtn.Visible = false

local Scroller = Instance.new("ScrollingFrame", MainFrame)
Scroller.Size = UDim2.new(1,0,1,-40)
Scroller.Position = UDim2.new(0,0,0,40)
Scroller.CanvasSize = UDim2.new(0,0,0,0)
Scroller.ScrollBarThickness = 6
Scroller.BackgroundTransparency = 1

-- Tombol helper
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

-- Scan map data
local checkpoints, summit = {}, nil
local function ScanMap()
    checkpoints, summit = {}, nil
    local mapName = workspace.Name or "Unknown Map"

    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local lname = v.Name:lower()
            if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") or tonumber(lname) then
                table.insert(checkpoints,v)
            elseif lname:find("summit") or lname:find("puncak") or lname:find("peak") then
                summit = v
            end
        end
    end

    table.sort(checkpoints,function(a,b) return a.Position.Y<b.Position.Y end)

    local cpRequired = #checkpoints>0 and "Ya" or "Tidak"

    -- Deteksi admin/dev
    local admins = {}
    for _,plr in pairs(Players:GetPlayers()) do
        if plr:GetRankInGroup(1) > 0 or plr.UserId==LocalPlayer.UserId then
            table.insert(admins,plr.Name)
        end
    end

    -- Deteksi anticheat sederhana
    local anticheatDetected = false
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then
            local code = v:FindFirstChildWhichIsA("StringValue")
            if code and code.Value:lower():find("anti") then
                anticheatDetected = true
            end
        end
    end

    -- Fitur terlarang
    local bannedFeatures = {}
    if Workspace:FindFirstChild("FlyScript") then table.insert(bannedFeatures,"Fly") end
    if Workspace:FindFirstChild("SpeedScript") then table.insert(bannedFeatures,"Speed") end

    local res = "📌 Map: "..mapName..
                "\n🏁 Summit via CP?: "..cpRequired..
                "\n👑 Admin/Dev: "..(#admins>0 and table.concat(admins,", ") or "Tidak ada")..
                "\n🛡 Anticheat: "..(anticheatDetected and "Ada" or "Tidak ada")..
                "\n⛔ Fitur terlarang: "..(#bannedFeatures>0 and table.concat(bannedFeatures,", ") or "Tidak ada")
    ShowPopup(res)
end

-- Tombol scan
local scanBtn = MakeButton("📡 Scan Map",ScanMap)
scanBtn.Position = UDim2.new(0,5,0,0)
scanBtn.Parent = Scroller

-- Hide/show GUI
local hidden=false
HideBtn.MouseButton1Click:Connect(function()
    hidden=true
    MainFrame.Visible=false
    ShowBtn.Visible=true
end)
ShowBtn.MouseButton1Click:Connect(function()
    hidden=false
    MainFrame.Visible=true
    ShowBtn.Visible=false
end)

-- Teleport tombol CP & Summit
local function GenerateTeleportButtons()
    local y=50
    for i,cp in ipairs(checkpoints) do
        local b = MakeButton("CP"..i.." ("..cp.Name..")",function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(cp.Position + Vector3.new(0,5,0))
                ShowPopup("➡️ Teleport ke CP"..i.." ("..cp.Name..")")
            end
        end)
        b.Position = UDim2.new(0,5,0,y)
        b.Parent = Scroller
        y=y+40
    end
    if summit then
        local b = MakeButton("🏔 Summit ("..summit.Name..")",function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(summit.Position + Vector3.new(0,5,0))
                ShowPopup("➡️ Teleport ke Summit ("..summit.Name..")")
            end
        end)
        b.Position = UDim2.new(0,5,0,y)
        b.Parent = Scroller
        y=y+40
    end
    Scroller.CanvasSize = UDim2.new(0,0,0,y)
end

-- Tombol Generate Teleport
local generateBtn = MakeButton("🗺 Generate Teleport Buttons",GenerateTeleportButtons)
generateBtn.Position = UDim2.new(0,5,0,40)
generateBtn.Parent = Scroller

-- Billboard radius dekat
local maxDistance = 25
local function CreateBillboard(part)
    if part:FindFirstChild("NameBillboard") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameBillboard"
    billboard.Size = UDim2.new(0,100,0,40)
    billboard.Adornee = part
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = part.Name
end
local function RemoveBillboard(part)
    local b = part:FindFirstChild("NameBillboard")
    if b then b:Destroy() end
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    for _,part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(Players) then
            local dist = (part.Position - hrp.Position).Magnitude
            if dist <= maxDistance then
                CreateBillboard(part)
            else
                RemoveBillboard(part)
            end
        end
    end
end)

-- Init scan otomatis saat dijalankan
ScanMap()
GenerateTeleportButtons()
