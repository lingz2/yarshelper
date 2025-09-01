-- GUI Tracker CFrame Posisi Karakter
-- Bisa dipakai di Delta Roblox

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 100)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true -- bisa digeser

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "CFrame Tracker"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(60,60,60)

local CoordLabel = Instance.new("TextLabel", Frame)
CoordLabel.Size = UDim2.new(1, -10, 0, 60)
CoordLabel.Position = UDim2.new(0, 5, 0, 35)
CoordLabel.Text = "Loading..."
CoordLabel.TextWrapped = true
CoordLabel.TextColor3 = Color3.fromRGB(0,255,0)
CoordLabel.BackgroundTransparency = 1
CoordLabel.Font = Enum.Font.SourceSans
CoordLabel.TextSize = 16

-- Update terus posisi karakter
spawn(function()
    while true do
        task.wait(0.5) -- update tiap 0.5 detik
        local plr = game.Players.LocalPlayer
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local cf = plr.Character.HumanoidRootPart.CFrame
            CoordLabel.Text = tostring(cf)
        else
            CoordLabel.Text = "Character tidak ditemukan"
        end
    end
end)
