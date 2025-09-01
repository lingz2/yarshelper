-- DETEKSI OBJEK YANG DI SENTUH

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- GUI popup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TouchDetectorGUI"

local function ShowPopup(msg, color)
    color = color or Color3.fromRGB(50,150,50)
    local popup = Instance.new("TextLabel", ScreenGui)
    popup.Size = UDim2.new(0,300,0,35)
    popup.Position = UDim2.new(0.5,-150,0,50)
    popup.BackgroundColor3 = color
    popup.TextColor3 = Color3.new(1,1,1)
    popup.Text = msg
    popup.Font = Enum.Font.SourceSansBold
    popup.TextScaled = true
    popup.BackgroundTransparency = 1
    popup.TextTransparency = 1

    TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency=0, TextTransparency=0}):Play()

    delay(2, function()
        TweenService:Create(popup, TweenInfo.new(0.3), {BackgroundTransparency=1, TextTransparency=1}):Play()
        wait(0.3)
        popup:Destroy()
    end)
end

-- fungsi deteksi touch
local function onTouched(hit)
    if hit and hit:IsA("BasePart") then
        ShowPopup("✅ Kamu menyentuh: "..hit.Name, Color3.fromRGB(100,200,100))
        print("Touched object: "..hit:GetFullName())  -- menampilkan full path di console
    end
end

-- hubungkan semua part di workspace ke event Touched
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Touched:Connect(onTouched)
    end
end

-- opsional: update otomatis jika ada part baru muncul
workspace.DescendantAdded:Connect(function(v)
    if v:IsA("BasePart") then
        v.Touched:Connect(onTouched)
    end
end)
