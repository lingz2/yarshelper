-- UNIVERSAL GUNUNG AUTO SUMMIT FINAL
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- ===== GUI MINI =====
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GunungMiniUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0,200,0,300)
MainFrame.Position = UDim2.new(0,20,0.5,-150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "🗻 Gunung Helper"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0,30,0,30)
HideBtn.Position = UDim2.new(1,-30,0,0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1,1,1)
HideBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

local Scroller = Instance.new("ScrollingFrame", MainFrame)
Scroller.Size = UDim2.new(1,0,1,-30)
Scroller.Position = UDim2.new(0,0,0,30)
Scroller.CanvasSize = UDim2.new(0,0,0,0)
Scroller.ScrollBarThickness = 5
Scroller.BackgroundTransparency = 1

-- ===== UTILITY =====
local checkpoints, summit, respawnPoint = {}, nil, nil
local mapName = workspace.Name or "Unknown"
local anticheatDetected, adminDetected = false, false
local delayPerCP, delaySummit = 2, 5
local autoLoop = false
local popupQueue = {}

-- Popup antrian
local function ShowPopup(msg, success)
    table.insert(popupQueue,{msg=msg,success=success})
end

local function ProcessPopupQueue()
    spawn(function()
        while true do
            if #popupQueue>0 then
                local p = table.remove(popupQueue,1)
                local popup = Instance.new("TextLabel", ScreenGui)
                popup.Size = UDim2.new(0,180,0,25)
                popup.Position = UDim2.new(1,-190,1,-50)
                popup.BackgroundColor3 = p.success and Color3.fromRGB(30,60,30) or Color3.fromRGB(60,30,30)
                popup.TextColor3 = p.success and Color3.new(0,1,0) or Color3.new(1,0.3,0.3)
                popup.Text = p.msg
                popup.Font = Enum.Font.SourceSansBold
                popup.TextScaled = true
                popup.BackgroundTransparency = 0.2
                popup.ZIndex = 10
                popup.BackgroundTransparency = 1
                popup.TextTransparency = 1
                TweenService:Create(popup,TweenInfo.new(0.5),{BackgroundTransparency=0.2,TextTransparency=0}):Play()
                wait(2.5)
                TweenService:Create(popup,TweenInfo.new(0.5),{BackgroundTransparency=1,TextTransparency=1}):Play()
                wait(0.5)
                popup:Destroy()
            else
                wait(0.5)
            end
        end
    end)
end

ProcessPopupQueue()

-- Teleport helper
local function TeleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(pos)
    end
end

-- Scan map
local function ScanMap()
    checkpoints = {}
    summit = nil
    respawnPoint = nil
    anticheatDetected = false
    adminDetected = false
    local highestY = -math.huge
    local summitCandidate = nil
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") then
            local lname = v.Name:lower()
            if lname:find("cp") or lname:find("checkpoint") or lname:find("pos") then
                table.insert(checkpoints,v)
            elseif lname:find("summit") or lname:find("puncak") or lname:find("peak") then
                summit = v
            elseif lname:find("basecamp") or lname:find("respawn") then
                respawnPoint = v
            elseif lname:find("anti") or lname:find("kick") then
                anticheatDetected = true
            elseif lname:find("admin") or lname:find("developer") then
                adminDetected = true
            end
            -- kandidat summit alternatif jika summit tidak jelas
            if v.Position.Y>highestY then
                highestY = v.Position.Y
                summitCandidate = v
            end
        end
    end
    table.sort(checkpoints,function(a,b) return a.Position.Y<b.Position.Y end)
    if not summit then
        summit = summitCandidate
    end
end

-- Generate tombol
local function GenerateButtons()
    Scroller:ClearAllChildren()
    local y = 0
    local function MakeButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-10,0,30)
        btn.Position = UDim2.new(0,5,0,0)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextScaled = true
        btn.Text = text
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Info popup
    ShowPopup("📍 Map: "..mapName,true)
    ShowPopup("🗻 Checkpoints: "..#checkpoints,true)
    ShowPopup("🏔 Summit: "..(summit and summit.Name or "Tidak Ada"),true)
    ShowPopup("⚠️ Anticheat: "..tostring(anticheatDetected), not anticheatDetected)
    ShowPopup("👑 Admin: "..tostring(adminDetected), not adminDetected)

    -- Tombol CP
    for i,cp in ipairs(checkpoints) do
        local b = MakeButton("CP "..i.." : "..cp.Name,function()
            TeleportTo(cp.Position + Vector3.new(0,5,0))
        end)
        b.Position = UDim2.new(0,5,0,y)
        b.Parent = Scroller
        y = y + 35
    end

    -- Tombol Summit
    if summit then
        local b = MakeButton("🏔 Summit : "..summit.Name,function()
            for _,cp in ipairs(checkpoints) do
                TeleportTo(cp.Position + Vector3.new(0,5,0))
                wait(delayPerCP + (anticheatDetected and 1.5 or 0))
            end
            TeleportTo(summit.Position + Vector3.new(0,5,0))
        end)
        b.Position = UDim2.new(0,5,0,y)
        b.Parent = Scroller
        y = y + 35
    end

    -- Auto Loop Summit
    local loopBtn = MakeButton("▶️ Auto Loop: OFF",function()
        autoLoop = not autoLoop
        loopBtn.Text = autoLoop and "⏸ Auto Loop: ON" or "▶️ Auto Loop: OFF"
        if autoLoop then
            spawn(function()
                while autoLoop do
                    for _,cp in ipairs(checkpoints) do
                        TeleportTo(cp.Position + Vector3.new(0,5,0))
                        wait(delayPerCP + (anticheatDetected and 1.5 or 0))
                    end
                    if summit then
                        TeleportTo(summit.Position + Vector3.new(0,5,0))
                        ShowPopup("✅ Summit tercapai!",true)
                        wait(delaySummit + (anticheatDetected and 1.5 or 0))
                        if respawnPoint then
                            LocalPlayer.Character:BreakJoints()
                        else
                            TeleportService:Teleport(game.PlaceId)
                        end
                    end
                    wait(2)
                end
            end)
        end
    end)
    loopBtn.Position = UDim2.new(0,5,0,y)
    loopBtn.Parent = Scroller
    y = y + 35

    Scroller.CanvasSize = UDim2.new(0,0,0,y)
end

-- Toggle hide/show
local hidden = false
HideBtn.MouseButton1Click:Connect(function()
    hidden = not hidden
    MainFrame.Size = hidden and UDim2.new(0,60,0,30) or UDim2.new(0,200,0,300)
    Scroller.Visible = not hidden
    Title.Text = hidden and "🗻" or "🗻 Gunung Helper"
end)

-- INIT
ScanMap()
GenerateButtons()
