local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== File Replay ======
local SAVE_FILE = "Replays.json"
local hasFileAPI = (writefile and readfile and isfile) and true or false

local function safeWrite(data)
    if hasFileAPI then writefile(SAVE_FILE, HttpService:JSONEncode(data)) end
end

local function safeRead()
    if hasFileAPI and isfile(SAVE_FILE) then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end)
        if ok and decoded then return decoded end
    end
    return {}
end

local savedReplays = safeRead()

-- ====== UI Helper ======
local function styleFrame(frame, radius, color)
    frame.BackgroundColor3 = color
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, radius)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(80,80,80)
end

local function styleButton(btn, color)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)
end

local function addShadow(frame)
    local shadow = Instance.new("ImageLabel", frame)
    shadow.ZIndex = 0
    shadow.Size = UDim2.new(1,30,1,30)
    shadow.Position = UDim2.new(0,-15,0,-15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857472"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.5
end

-- ====== Main Frame ======
local guiName = "MountaineerRecorderModern"
local oldGui = playerGui:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,460,0,420)
mainFrame.Position = UDim2.new(0.5,-230,0.2,0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
styleFrame(mainFrame, 12, Color3.fromRGB(35,35,40))
addShadow(mainFrame)

-- ====== Header ======
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1,0,0,40)
styleFrame(header, 12, Color3.fromRGB(45,45,55))

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "🏔 PS SCRIPT AUTO WALK"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-50,0,3)
closeBtn.Text = "✖"
styleButton(closeBtn, Color3.fromRGB(200,70,70))

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0,35,0,35)
minimizeBtn.Position = UDim2.new(1,-95,0,3)
minimizeBtn.Text = "—"
styleButton(minimizeBtn, Color3.fromRGB(80,80,80))

-- ====== Content ======
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1,0,1,-40)
contentFrame.Position = UDim2.new(0,0,0,40)
styleFrame(contentFrame, 12, Color3.fromRGB(45,45,55))

-- Tombol utama
local recordBtn = Instance.new("TextButton", contentFrame)
recordBtn.Size = UDim2.new(0,120,0,35)
recordBtn.Position = UDim2.new(0,15,0,15)
recordBtn.Text = "⏺ Record"
styleButton(recordBtn, Color3.fromRGB(70,130,180))

local saveBtn = Instance.new("TextButton", contentFrame)
saveBtn.Size = UDim2.new(0,120,0,35)
saveBtn.Position = UDim2.new(0,150,0,15)
saveBtn.Text = "💾 Save Replay"
styleButton(saveBtn, Color3.fromRGB(34,139,34))

local loadBtn = Instance.new("TextButton", contentFrame)
loadBtn.Size = UDim2.new(0,120,0,35)
loadBtn.Position = UDim2.new(0,285,0,15)
loadBtn.Text = "📂 Load Path"
styleButton(loadBtn, Color3.fromRGB(100,149,237))

local mergeBtn = Instance.new("TextButton", contentFrame)
mergeBtn.Size = UDim2.new(0,150,0,35)
mergeBtn.Position = UDim2.new(0,15,0,60)
mergeBtn.Text = "🔗 Merge & Play"
styleButton(mergeBtn, Color3.fromRGB(255,140,0))

-- Global speed control
local globalSpeed = 1
local globalSpeedLabel = Instance.new("TextLabel", contentFrame)
globalSpeedLabel.Size = UDim2.new(0,140,0,35)
globalSpeedLabel.Position = UDim2.new(0,175,0,60)
globalSpeedLabel.BackgroundTransparency = 1
globalSpeedLabel.Text = "Global: 1x"
globalSpeedLabel.TextColor3 = Color3.new(1,1,1)
globalSpeedLabel.Font = Enum.Font.GothamBold
globalSpeedLabel.TextSize = 14

local globalMinus = Instance.new("TextButton", contentFrame)
globalMinus.Size = UDim2.new(0,30,0,30)
globalMinus.Position = UDim2.new(0,320,0,62)
globalMinus.Text = "◀"
styleButton(globalMinus, Color3.fromRGB(90,90,90))

local globalPlus = Instance.new("TextButton", contentFrame)
globalPlus.Size = UDim2.new(0,30,0,30)
globalPlus.Position = UDim2.new(0,355,0,62)
globalPlus.Text = "▶"
styleButton(globalPlus, Color3.fromRGB(90,90,90))

globalMinus.MouseButton1Click:Connect(function()
    globalSpeed = math.max(0.5, globalSpeed - 0.5)
    globalSpeedLabel.Text = "Global: "..globalSpeed.."x"
end)
globalPlus.MouseButton1Click:Connect(function()
    globalSpeed = globalSpeed + 0.5
    globalSpeedLabel.Text = "Global: "..globalSpeed.."x"
end)

-- Toggle mode
local playMode = "move"
local toggleBtn = Instance.new("TextButton", contentFrame)
toggleBtn.Size = UDim2.new(0,150,0,30)
toggleBtn.Position = UDim2.new(0,175,0,95)
toggleBtn.Text = "Mode: Animasi Jalan"
styleButton(toggleBtn, Color3.fromRGB(100,100,200))

toggleBtn.MouseButton1Click:Connect(function()
    if playMode == "move" then
        playMode = "cframe"
        toggleBtn.Text = "Mode: Slide Cepat"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200,100,100)
    else
        playMode = "move"
        toggleBtn.Text = "Mode: Animasi Jalan"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100,100,200)
    end
end)

-- Scroll replay
local replayList = Instance.new("ScrollingFrame", contentFrame)
replayList.Size = UDim2.new(1,-30,1,-140)
replayList.Position = UDim2.new(0,15,0,130)
replayList.CanvasSize = UDim2.new(0,0,0,0)
replayList.ScrollBarThickness = 6
styleFrame(replayList, 10, Color3.fromRGB(55,55,65))

local listLayout = Instance.new("UIListLayout", replayList)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,5)

-- ====== Replay Variables ======
local character, humanoidRootPart
local isRecording, isPlaying, isPaused = false, false, false
local recordData = {}

local function onCharacterAdded(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart",10)
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- ====== Record ======
local function startRecording() recordData = {}; isRecording = true end
local function stopRecording() isRecording = false end

RunService.Heartbeat:Connect(function()
    if isRecording and humanoidRootPart and humanoidRootPart.Parent then
        local cf = humanoidRootPart.CFrame
        table.insert(recordData, {
            Position = {cf.Position.X, cf.Position.Y, cf.Position.Z},
            LookVector = {cf.LookVector.X, cf.LookVector.Y, cf.LookVector.Z},
            UpVector = {cf.UpVector.X, cf.UpVector.Y, cf.UpVector.Z}
        })
    end
end)

-- ====== Play Replay ======
local function playReplay(data, speed)
    if isPlaying then return end
    isPlaying = true
    isPaused = false

    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("No humanoid found!")
        isPlaying = false
        return
    end

    for i = 1, #data-1 do
        if not isPlaying then break end
        while isPaused do RunService.Heartbeat:Wait() end

        if humanoidRootPart and humanoidRootPart.Parent then
            local current = Vector3.new(unpack(data[i].Position))
            local nextPos = Vector3.new(unpack(data[i+1].Position))

            if playMode == "move" then
                local dir = (nextPos - current)
                if dir.Magnitude > 0 then
                    humanoid:Move(dir.Unit, true)
                end
            else
                humanoidRootPart.CFrame = CFrame.new(nextPos)
            end
        end

        task.wait(1/30 / speed)
    end

    humanoid:Move(Vector3.zero, true)
    isPlaying = false
end

-- ====== Add Replay Item ======
function addReplayItem(saved, index)
    local item = Instance.new("Frame", replayList)
    item.Size = UDim2.new(1,-10,0,65)
    styleFrame(item,8,Color3.fromRGB(65,65,75))
    item.LayoutOrder = index
    saved.Selected = false
    saved.Speed = saved.Speed or 1

    local nameBox = Instance.new("TextBox", item)
    nameBox.Size = UDim2.new(0.4,0,0,25)
    nameBox.Position = UDim2.new(0,5,0,5)
    nameBox.Text = saved.Name
    nameBox.TextColor3 = Color3.new(1,1,1)
    nameBox.BackgroundColor3 = Color3.fromRGB(90,90,100)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.ClearTextOnFocus = false
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)
    nameBox.FocusLost:Connect(function()
        saved.Name = nameBox.Text
    end)

    local speedLabel = Instance.new("TextLabel", item)
    speedLabel.Size = UDim2.new(0.3,0,0,20)
    speedLabel.Position = UDim2.new(0,5,0,35)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: "..saved.Speed.."x"
    speedLabel.TextColor3 = Color3.new(1,1,1)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 12

    local minus = Instance.new("TextButton", item)
    minus.Size = UDim2.new(0,25,0,20)
    minus.Position = UDim2.new(0.32,0,0,35)
    minus.Text = "◀"
    styleButton(minus, Color3.fromRGB(90,90,90))

    local plus = Instance.new("TextButton", item)
    plus.Size = UDim2.new(0,25,0,20)
    plus.Position = UDim2.new(0.42,0,0,35)
    plus.Text = "▶"
    styleButton(plus, Color3.fromRGB(90,90,90))

    minus.MouseButton1Click:Connect(function()
        saved.Speed = math.max(0.5, saved.Speed - 0.5)
        speedLabel.Text = "Speed: "..saved.Speed.."x"
    end)
    plus.MouseButton1Click:Connect(function()
        saved.Speed = saved.Speed + 0.5
        speedLabel.Text = "Speed: "..saved.Speed.."x"
    end)

    local playBtn = Instance.new("TextButton", item)
    playBtn.Size = UDim2.new(0,35,0,30)
    playBtn.Position = UDim2.new(0.55,0,0.5,-15)
    playBtn.Text = "▶"
    styleButton(playBtn, Color3.fromRGB(70,130,180))

    local pauseBtn = Instance.new("TextButton", item)
    pauseBtn.Size = UDim2.new(0,35,0,30)
    pauseBtn.Position = UDim2.new(0.65,0,0.5,-15)
    pauseBtn.Text = "⏸"
    styleButton(pauseBtn, Color3.fromRGB(255,215,0))

    local delBtn = Instance.new("TextButton", item)
    delBtn.Size = UDim2.new(0,35,0,30)
    delBtn.Position = UDim2.new(0.75,0,0.5,-15)
    delBtn.Text = "🗑"
    styleButton(delBtn, Color3.fromRGB(220,20,60))

    local saveToJsonBtn = Instance.new("TextButton", item)
    saveToJsonBtn.Size = UDim2.new(0,35,0,30)
    saveToJsonBtn.Position = UDim2.new(0.85,0,0.5,-15)
    saveToJsonBtn.Text = "💾"
    styleButton(saveToJsonBtn, Color3.fromRGB(34,139,34))

    local selectCheck = Instance.new("TextButton", item)
    selectCheck.Size = UDim2.new(0,25,0,25)
    selectCheck.Position = UDim2.new(0.93,0,0.5,-12)
    selectCheck.Text = "☐"
    styleButton(selectCheck, Color3.fromRGB(100,100,100))

    selectCheck.MouseButton1Click:Connect(function()
        saved.Selected = not saved.Selected
        selectCheck.Text = saved.Selected and "☑" or "☐"
    end)

    playBtn.MouseButton1Click:Connect(function() 
        task.spawn(function() playReplay(saved.Frames, saved.Speed*globalSpeed) end) 
    end)
    pauseBtn.MouseButton1Click:Connect(function() isPaused = not isPaused end)
    delBtn.MouseButton1Click:Connect(function()
        table.remove(savedReplays, index)
        refreshReplayList()
    end)
    saveToJsonBtn.MouseButton1Click:Connect(function()
        safeWrite(savedReplays)
    end)
end

-- ====== Refresh List ======
function refreshReplayList()
    for _, child in ipairs(replayList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, r in ipairs(savedReplays) do
        addReplayItem(r, i)
    end
    replayList.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 10)
end

refreshReplayList()

-- ====== Button Functions ======
recordBtn.MouseButton1Click:Connect(function()
    if not isRecording then
        recordBtn.Text = "⏹ Stop"
        startRecording()
    else
        recordBtn.Text = "⏺ Record"
        stopRecording()
    end
end)

saveBtn.MouseButton1Click:Connect(function()
    if #recordData > 0 then
        local saved = {Frames=recordData, Name="Replay "..(#savedReplays+1), Selected=false, Speed=1}
        table.insert(savedReplays, saved)
        refreshReplayList()
    end
end)

loadBtn.MouseButton1Click:Connect(function()
    savedReplays = safeRead()
    refreshReplayList()
end)

mergeBtn.MouseButton1Click:Connect(function()
    local mergedFrames = {}
    for _, r in ipairs(savedReplays) do
        if r.Selected then
            for _, frame in ipairs(r.Frames) do
                table.insert(mergedFrames, frame)
            end
        end
    end
    if #mergedFrames > 0 then
        task.spawn(function() playReplay(mergedFrames, globalSpeed) end)
    end
end)

-- ====== Minimize & Close ======
local isMinimized = false
local originalSize = mainFrame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        mainFrame.Size = UDim2.new(0,460,0,40)
        contentFrame.Visible = false
        isMinimized = true
    else
        mainFrame.Size = originalSize
        contentFrame.Visible = true
        isMinimized = false
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
