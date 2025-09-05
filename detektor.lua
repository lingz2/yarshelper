-- Button Analyzer & Detector Script
-- Menganalisis tombol-tombol di game untuk memahami cara kerja developer
-- Tekan [F] untuk analyze, [B] untuk toggle GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local mouse = Players.LocalPlayer:GetMouse()
local player = Players.LocalPlayer

-- Data yang ditemukan
local detectedButtons = {}
local detectedRemotes = {}
local detectedParts = {}

-- GUI positioning optimized for mobile
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 350, 0, 450)
main.Position = UDim2.new(0.5, -175, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "🔍 Button Analyzer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.BackgroundTransparency = 1
close.Font = Enum.Font.GothamBold
close.TextSize = 14

-- Tab System
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1, -10, 0, 30)
tabFrame.Position = UDim2.new(0, 5, 0, 35)
tabFrame.BackgroundTransparency = 1

local tabs = {"Buttons", "Remotes", "Parts", "Analysis"}
local tabButtons = {}
local currentTab = 1

for i, tabName in ipairs(tabs) do
    local tab = Instance.new("TextButton", tabFrame)
    tab.Size = UDim2.new(0.25, -2, 1, 0)
    tab.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
    tab.Text = tabName
    tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tab.Font = Enum.Font.Gotham
    tab.TextSize = 12
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 5)
    
    tabButtons[i] = tab
    
    tab.MouseButton1Click:Connect(function()
        currentTab = i
        updateTabDisplay()
    end)
end

-- Content Area
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -10, 1, -120)
scroll.Position = UDim2.new(0, 5, 0, 70)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 5
scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 5)

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0, 5)
list.SortOrder = Enum.SortOrder.LayoutOrder

-- Control Panel
local controlFrame = Instance.new("Frame", main)
controlFrame.Size = UDim2.new(1, -10, 0, 40)
controlFrame.Position = UDim2.new(0, 5, 1, -45)
controlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Instance.new("UICorner", controlFrame).CornerRadius = UDim.new(0, 5)

local analyzeBtn = Instance.new("TextButton", controlFrame)
analyzeBtn.Size = UDim2.new(0.3, -5, 1, -10)
analyzeBtn.Position = UDim2.new(0, 5, 0, 5)
analyzeBtn.Text = "Analyze [F]"
analyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
analyzeBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
analyzeBtn.Font = Enum.Font.GothamSemibold
analyzeBtn.TextSize = 12
Instance.new("UICorner", analyzeBtn).CornerRadius = UDim.new(0, 5)

local clearBtn = Instance.new("TextButton", controlFrame)
clearBtn.Size = UDim2.new(0.3, -5, 1, -10)
clearBtn.Position = UDim2.new(0.35, 0, 0, 5)
clearBtn.Text = "Clear"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
clearBtn.Font = Enum.Font.GothamSemibold
clearBtn.TextSize = 12
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)

local exportBtn = Instance.new("TextButton", controlFrame)
exportBtn.Size = UDim2.new(0.3, -5, 1, -10)
exportBtn.Position = UDim2.new(0.7, 0, 0, 5)
exportBtn.Text = "Export"
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 150)
exportBtn.Font = Enum.Font.GothamSemibold
exportBtn.TextSize = 12
Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0, 5)

-- Functions
local function createInfoLabel(parent, text, color)
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 3)
    return label
end

-- Analyze Functions
local function analyzeRemoteEvents()
    print("🔍 Analyzing RemoteEvents...")
    detectedRemotes = {}
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            table.insert(detectedRemotes, {
                name = remote.Name,
                type = remote.ClassName,
                parent = remote.Parent.Name,
                fullPath = remote:GetFullName()
            })
        end
    end
    
    print("Found " .. #detectedRemotes .. " remotes")
end

local function analyzeParts()
    print("🔍 Analyzing Parts...")
    detectedParts = {}
    
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name:lower():find("summit") or 
           part:IsA("BasePart") and part.Name:lower():find("button") or
           part:IsA("BasePart") and part.Name:lower():find("teleport") then
            
            local clickDetector = part:FindFirstChild("ClickDetector")
            local proximityPrompt = part:FindFirstChild("ProximityPrompt")
            
            table.insert(detectedParts, {
                name = part.Name,
                type = part.ClassName,
                parent = part.Parent.Name,
                position = part.Position,
                hasClickDetector = clickDetector ~= nil,
                hasProximityPrompt = proximityPrompt ~= nil,
                fullPath = part:GetFullName(),
                color = part.Color
            })
        end
    end
    
    print("Found " .. #detectedParts .. " relevant parts")
end

local function analyzeGUIButtons()
    print("🔍 Analyzing GUI Buttons...")
    detectedButtons = {}
    
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local connections = {}
            
            -- Try to detect connections (limited info available)
            local buttonInfo = {
                name = gui.Name,
                text = gui.Text or "No Text",
                parent = gui.Parent.Name,
                visible = gui.Visible,
                position = gui.Position,
                size = gui.Size,
                backgroundColor = gui.BackgroundColor3,
                fullPath = gui:GetFullName()
            }
            
            table.insert(detectedButtons, buttonInfo)
        end
    end
    
    print("Found " .. #detectedButtons .. " GUI buttons")
end

local function performFullAnalysis()
    analyzeRemoteEvents()
    analyzeParts()
    analyzeGUIButtons()
    updateTabDisplay()
    print("✅ Analysis complete!")
end

-- Update Display
function updateTabDisplay()
    -- Clear scroll
    for _, child in pairs(scroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    -- Update tab colors
    for i, tab in pairs(tabButtons) do
        if i == currentTab then
            tab.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
            tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            tab.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Display content based on current tab
    if currentTab == 1 then -- Buttons
        for _, btn in pairs(detectedButtons) do
            local frame = Instance.new("Frame", scroll)
            frame.Size = UDim2.new(1, -10, 0, 80)
            frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
            
            createInfoLabel(frame, "🔘 " .. btn.name .. " (" .. btn.text .. ")", Color3.fromRGB(100, 200, 255))
            createInfoLabel(frame, "Path: " .. btn.fullPath, Color3.fromRGB(200, 200, 200))
            createInfoLabel(frame, "Parent: " .. btn.parent .. " | Visible: " .. tostring(btn.visible), Color3.fromRGB(150, 150, 150))
        end
        
    elseif currentTab == 2 then -- Remotes
        for _, remote in pairs(detectedRemotes) do
            local frame = Instance.new("Frame", scroll)
            frame.Size = UDim2.new(1, -10, 0, 60)
            frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
            
            local color = remote.type == "RemoteEvent" and Color3.fromRGB(255, 150, 100) or Color3.fromRGB(100, 255, 150)
            createInfoLabel(frame, "📡 " .. remote.name .. " (" .. remote.type .. ")", color)
            createInfoLabel(frame, "Path: " .. remote.fullPath, Color3.fromRGB(200, 200, 200))
            createInfoLabel(frame, "Parent: " .. remote.parent, Color3.fromRGB(150, 150, 150))
        end
        
    elseif currentTab == 3 then -- Parts
        for _, part in pairs(detectedParts) do
            local frame = Instance.new("Frame", scroll)
            frame.Size = UDim2.new(1, -10, 0, 100)
            frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
            
            createInfoLabel(frame, "🧱 " .. part.name .. " (" .. part.type .. ")", Color3.fromRGB(150, 255, 150))
            createInfoLabel(frame, "Position: " .. tostring(part.position), Color3.fromRGB(200, 200, 200))
            createInfoLabel(frame, "ClickDetector: " .. tostring(part.hasClickDetector), Color3.fromRGB(255, 200, 100))
            createInfoLabel(frame, "ProximityPrompt: " .. tostring(part.hasProximityPrompt), Color3.fromRGB(255, 200, 100))
            createInfoLabel(frame, "Path: " .. part.fullPath, Color3.fromRGB(150, 150, 150))
        end
        
    elseif currentTab == 4 then -- Analysis
        local frame = Instance.new("Frame", scroll)
        frame.Size = UDim2.new(1, -10, 0, 200)
        frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)
        
        createInfoLabel(frame, "📊 ANALYSIS SUMMARY", Color3.fromRGB(255, 255, 100))
        createInfoLabel(frame, "GUI Buttons Found: " .. #detectedButtons, Color3.fromRGB(100, 200, 255))
        createInfoLabel(frame, "Remote Events/Functions: " .. #detectedRemotes, Color3.fromRGB(255, 150, 100))
        createInfoLabel(frame, "Relevant Parts: " .. #detectedParts, Color3.fromRGB(150, 255, 150))
        createInfoLabel(frame, "", Color3.fromRGB(100, 100, 100))
        createInfoLabel(frame, "💡 How Summit might work:", Color3.fromRGB(255, 200, 100))
        createInfoLabel(frame, "1. Touch Summit part with ClickDetector", Color3.fromRGB(200, 200, 200))
        createInfoLabel(frame, "2. Fires Summit RemoteEvent to server", Color3.fromRGB(200, 200, 200))
        createInfoLabel(frame, "3. Server updates player data", Color3.fromRGB(200, 200, 200))
        createInfoLabel(frame, "4. Player resets or teleports", Color3.fromRGB(200, 200, 200))
    end
    
    -- Update scroll canvas
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
    end)
    task.wait(0.1)
    scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end

-- Event Connections
analyzeBtn.MouseButton1Click:Connect(performFullAnalysis)

clearBtn.MouseButton1Click:Connect(function()
    detectedButtons = {}
    detectedRemotes = {}
    detectedParts = {}
    updateTabDisplay()
    print("🗑️ Data cleared")
end)

exportBtn.MouseButton1Click:Connect(function()
    print("📋 EXPORT DATA:")
    print("=== REMOTES ===")
    for _, remote in pairs(detectedRemotes) do
        print(remote.type .. ": " .. remote.fullPath)
    end
    print("=== PARTS ===")
    for _, part in pairs(detectedParts) do
        print(part.name .. " at " .. tostring(part.position) .. " | ClickDetector: " .. tostring(part.hasClickDetector))
    end
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        performFullAnalysis()
    elseif input.KeyCode == Enum.KeyCode.B then
        gui.Enabled = not gui.Enabled
    end
end)

-- Initialize
updateTabDisplay()
print("🔍 Button Analyzer loaded!")
print("Controls: [F] = Analyze, [B] = Toggle GUI")
print("This will help you understand how developers made their buttons!")
