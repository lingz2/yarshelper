-- DELTA CHECKPOINT & SUMMIT GUI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- ===== GUI POPUP =====
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "DeltaCheckpointGUI"

local function ShowPopup(msg, color)
    color = color or Color3.fromRGB(50,150,50)
    local popup = Instance.new("TextLabel", ScreenGui)
    popup.Size = UDim2.new(0,250,0,30)
    popup.Position = UDim2.new(0.5,-125,0,50)
    popup.BackgroundColor3 = color
    popup.TextColor3 = Color3.new(1,1,1)
    popup.Text = msg
    popup.Font = Enum.Font.SourceSansBold
    popup.TextScaled = true
    popup.BackgroundTransparency = 1
    popup.TextTransparency = 1
    TweenService:Create(popup, TweenInfo.new(0.5), {BackgroundTransparency=0, TextTransparency=0}):Play()
    delay(2, function()
        TweenService:Create(popup, TweenInfo.new(0.5), {BackgroundTransparency=1, TextTransparency=1}):Play()
        wait(0.5)
        popup:Destroy()
    end)
end

-- ===== SCAN CHECKPOINT & SUMMIT =====
local checkpoints, summit = {}, nil

for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Part") then
        local lname = v.Name:lower()
        if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") then
            table.insert(checkpoints,v)
            print("🔹 Checkpoint terdeteksi: "..v.Name.." | Posisi: "..tostring(v.Position))
        elseif lname:find("summit") or lname:find("puncak") or lname:find("peak") then
            summit = v
            print("🏔 Summit terdeteksi: "..v.Name.." | Posisi: "..tostring(v.Position))
        end
    end
end

ShowPopup("🗻 Scan selesai: "..#checkpoints.." CP, Summit: "..(summit and summit.Name or "Tidak ada"))

-- ===== TRIGGER REAlTIME TOUCH =====
for i,cp in ipairs(checkpoints) do
    cp.Touched:Connect(function(hit)
        if hit.Parent == LocalPlayer.Character then
            ShowPopup("✅ Checkpoint "..i..": "..cp.Name, Color3.fromRGB(50,150,50))
            print("✅ Menyentuh Checkpoint "..i.." : "..cp.Name)
        end
    end)
end

if summit then
    summit.Touched:Connect(function(hit)
        if hit.Parent == LocalPlayer.Character then
            ShowPopup("🏔 Summit: "..summit.Name, Color3.fromRGB(200,150,50))
            print("🏔 Menyentuh Summit : "..summit.Name)
        end
    end)
end
