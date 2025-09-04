-- Teleport GUI for "Gunung Batu" checkpoints
-- Place this LocalScript in StarterGui (or StarterPlayerScripts) so it runs for each player.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local function waitForCharacter()
    while not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) do
        player.CharacterAdded:Wait()
    end
    return player.Character
end

-- Checkpoint data: each entry is a table of 12 numbers accepted by CFrame.new(x,y,z, r00, r01, r02, r10...)
local cps = {
    cp1 = {-165.121399, 4.23206806, -657.757263, 0.766828477, 2.463231576e-08, -0.641852021, 1.92095833e-08, 1, 6.132685836e-08, 0.641852021, -5.935689276e-08, 0.766828477},
    cp2 = {-121.60952, 8.50454998, 544.049377, 1, 7.03251146e-08, -0.000192576554, -7.03272747e-08, 1, -1.11898748e-08, 0.000192576554, 1.12034186e-08, 1},
    cp3 = {-40.0167122, 392.432037, 673.959045, 0.999995112, -1.76521517e-08, 0.00312702474, 1.7474898e-08, 1, 5.67116274e-08, -0.00312702474, -5.6656706e-08, 0.999995112},
    cp4 = {-297484.432037, 779, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1},
    cp5 = {18.0000038, 572.429688, 692, 1, 0, 0, 0, 1, 0, 0, 0, 1},
    cp6 = {595.273804, 916.432007, 620.967712, 0, 0, 1, 0, 1, 0, -1, 0, 0},
    cp7 = {283.5, 1196.43201, 181.5, 0, 0, 1, 0, 1, 0, -1, 0, 0},
    cp8 = {552.105835, 1528.43201, -581.302246, -1, 0, 0, 0, 1, 0, 0, 0, -1},
    cp9 = {332.142334, 1736.43201, -260.883789, -1, 0, 0, 0, 1, 0, 0, 0, -1},
    cp10 = {290.354126, 1979.03186, -203.905533, -0.99999243, 0, -0.00388448243, 0, 1, 0, 0.00388448243, 0, -0.99999243},
    cp11 = {616.488281, 3260.50879, -66.2258759, -1, 2.69422158e-12, 8.49902406e-08, 2.69851047e-12, 1, 5.04620594e-08, -8.49902406e-08, 5.04620594e-08, -1},
}

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YarsTeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 360)
mainFrame.Position = UDim2.new(0.02, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Rounded corner (if supported)
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 8)
uicorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 34)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -70, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Gunung Batu - Teleport"
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.TextSize = 16
titleLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 24)
minBtn.Position = UDim2.new(1, -68, 0, 6)
minBtn.Text = "–"
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 18
minBtn.Parent = titleBar

-- Container for scroll frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -12, 1, -44)
contentFrame.Position = UDim2.new(0, 6, 0, 38)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local scroll = Instance.new("ScrollFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 8
scroll.Parent = contentFrame

local uiList = Instance.new("UIListLayout")
uiList.Parent = scroll
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0,6)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,6)
padding.PaddingBottom = UDim.new(0,6)
padding.PaddingLeft = UDim.new(0,8)
padding.PaddingRight = UDim.new(0,8)
padding.Parent = scroll

-- Function to teleport
local function teleportTo(cpdata)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ok, cf = pcall(function()
        return CFrame.new(unpack(cpdata))
    end)
    if ok and cf then
        -- attempt to set CFrame safely
        hrp.CFrame = cf
    end
end

-- Create buttons
local order = {}
for name, data in pairs(cps) do
    table.insert(order, name)
end
table.sort(order, function(a,b)
    local na = tonumber((a:gsub("[^%d]",""))) or 0
    local nb = tonumber((b:gsub("[^%d]",""))) or 0
    return na < nb
end)

for i, name in ipairs(order) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.LayoutOrder = i
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = (name:upper())
    btn.Parent = scroll

    btn.MouseButton1Click:Connect(function()
        local data = cps[name]
        if data then
            teleportTo(data)
        end
    end)
end

-- Update canvas size after buttons created
local function updateCanvas()
    local contentSize = uiList.AbsoluteContentSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize + 12)
end

uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- Draggable behavior for mainFrame via titleBar
local dragging = false
local dragStart = Vector2.new(0,0)
local startPos = UDim2.new()

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end

local function onInputChanged(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

titleBar.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)

-- Close and minimize behavior
local minimized = false
local fullSize = mainFrame.Size
local fullPos = mainFrame.Position

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

minBtn.MouseButton1Click:Connect(function()
    if not minimized then
        -- minimize to title bar height
        mainFrame.Size = UDim2.new(0, 280, 0, 36)
        minimized = true
    else
        mainFrame.Size = fullSize
        minimized = false
    end
end)

-- Scroll with mouse wheel (for convenience)
local function onInputWheel(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        local delta = input.Position.Z -- positive or negative
        local newY = math.clamp(scroll.CanvasPosition.Y - delta * 40, 0, scroll.CanvasSize.Y.Offset)
        scroll.CanvasPosition = Vector2.new(0, newY)
    end
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        onInputWheel(input)
    end
end)

-- Keybind to toggle UI (M)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Optional: make sure character exists on spawn
player.CharacterAdded:Connect(function()
    waitForCharacter()
end)

-- End of script
