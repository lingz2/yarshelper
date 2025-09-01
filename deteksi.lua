-- DETEKSI PIJAK DAN LABEL OBJEK RAPI

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GUI popup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "MapInfoGUI"

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
    if lastPopup == msg then return end  -- mencegah duplikasi popup
    lastPopup = msg
    PopupLabel.Text = msg
    PopupLabel.BackgroundColor3 = color
    TweenService:Create(PopupLabel, TweenInfo.new(0.3), {BackgroundTransparency=0.3}):Play()
    delay(2, function()
        TweenService:Create(PopupLabel, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
        lastPopup = nil
    end)
end

-- Fungsi deteksi pijakan
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local rayOrigin = char.HumanoidRootPart.Position
        local rayDirection = Vector3.new(0,-5,0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {char}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if rayResult and rayResult.Instance then
            local part = rayResult.Instance
            local lname = part.Name:lower()
            if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") then
                ShowPopup("👣 Checkpoint/Base: "..part.Name, Color3.fromRGB(50,200,50))
            elseif lname:find("summit") or lname:find("puncak") or lname:find("peak") then
                ShowPopup("🏔 Summit: "..part.Name, Color3.fromRGB(220,200,50))
            else
                ShowPopup("👀 Objek: "..part.Name, Color3.fromRGB(255,255,255))
            end
        end
    end
end)

-- Fungsi label nama objek di dunia
local function CreateNameLabel(part)
    if part:FindFirstChild("NameLabel") then return end
    local billboard = Instance.new("BillboardGui", part)
    billboard.Name = "NameLabel"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0,120,0,30)
    billboard.StudsOffset = Vector3.new(0,part.Size.Y+0.5,0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1,1,1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true

    local lname = part.Name:lower()
    if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") then
        textLabel.TextColor3 = Color3.fromRGB(50,200,50)
    elseif lname:find("summit") or lname:find("puncak") or lname:find("peak") then
        textLabel.TextColor3 = Color3.fromRGB(220,200,50)
    else
        textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    end

    textLabel.Text = part.Name
end

-- Pasang ke semua part yang ada
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        CreateNameLabel(v)
    end
end

-- Update otomatis jika ada part baru muncul
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("BasePart") then
        CreateNameLabel(v)
    end
end)
