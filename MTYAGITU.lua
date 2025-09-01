-- Auto Summit Final Ultra
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local PlaceId = game.PlaceId

-- CFrame checkpoints & summit
local checkpointsCFrame = {
    ["Basecamp"]=CFrame.new(-13,-82,-237),
    ["CP1"]=CFrame.new(-228,6,482),["CP2"]=CFrame.new(-167,62,852),
    ["CP3"]=CFrame.new(541,346,848),["CP4"]=CFrame.new(715,462,1409),["CP5"]=CFrame.new(727,650,451),
    ["CP6"]=CFrame.new(476,682,61),["CP7"]=CFrame.new(503,786,-579),["CP8"]=CFrame.new(1233,860,-561),
    ["CP9"]=CFrame.new(1928,694,-530),["CP10"]=CFrame.new(2519,906,-551),["CP11"]=CFrame.new(3379,844,-538),
    ["CP12"]=CFrame.new(1928,694,-749),["CP13"]=CFrame.new(1983,694,-1122),["CP14"]=CFrame.new(1897,934,-1159),
    ["Summit"]=CFrame.new(1935,1345,-2070)
}
local checkpointsOrder={"Basecamp","CP1","CP2","CP3","CP4","CP5","CP6","CP7","CP8","CP9","CP10","CP11","CP12","CP13","CP14","Summit"}

-- Persistent toggle status
if not LocalPlayer:FindFirstChild("AutoSummitStatus") then
    local status=Instance.new("Folder")
    status.Name="AutoSummitStatus"
    status.Parent=LocalPlayer
    local ViaCP=Instance.new("BoolValue");ViaCP.Name="LoopViaCP";ViaCP.Value=false;ViaCP.Parent=status
    local Direct=Instance.new("BoolValue");Direct.Name="LoopDirect";Direct.Value=false;Direct.Parent=status
end

-- Teleport + notify
local function notify(msg)
    game.StarterGui:SetCore("SendNotification",{Title="Auto Summit",Text=msg,Duration=2})
end

local function teleportTo(cf, summitDelay)
    local root=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        TweenService:Create(root,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=cf}):Play()
        if summitDelay then wait(20) else wait(math.random(10,30)/10) end
        notify("Teleport berhasil!")
    end
end

-- UI creation (tidak bisa digeser)
local function CreateUI()
    if PlayerGui:FindFirstChild("AutoSummitUI") then return end
    local ScreenGui=Instance.new("ScreenGui")
    ScreenGui.Name="AutoSummitUI"
    ScreenGui.Parent=PlayerGui

    -- Main frame
    local MainFrame=Instance.new("Frame")
    MainFrame.Size=UDim2.new(0,200,0,350)
    MainFrame.Position=UDim2.new(0,10,0.5,-175)
    MainFrame.BackgroundColor3=Color3.fromRGB(30,30,30)
    MainFrame.BorderSizePixel=0
    MainFrame.Visible=true
    MainFrame.Parent=ScreenGui

    local Scroll=Instance.new("ScrollingFrame")
    Scroll.Size=UDim2.new(1,0,1,0)
    Scroll.ScrollBarThickness=6
    Scroll.BackgroundTransparency=1
    Scroll.Parent=MainFrame

    local UIListLayout=Instance.new("UIListLayout")
    UIListLayout.Padding=UDim.new(0,3)
    UIListLayout.Parent=Scroll
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y + 5)
    end)

    -- Hide/Show
    local HideBtn=Instance.new("TextButton")
    HideBtn.Size=UDim2.new(0,200,0,25)
    HideBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
    HideBtn.TextColor3=Color3.fromRGB(255,255,255)
    HideBtn.Text="Hide UI"
    HideBtn.Parent=Scroll

    local ShowBtn=Instance.new("TextButton")
    ShowBtn.Size=UDim2.new(0,80,0,25)
    ShowBtn.Position=UDim2.new(0,10,0.5,-10)
    ShowBtn.Text="yars cakep"
    ShowBtn.BackgroundColor3=Color3.fromRGB(150,50,200)
    ShowBtn.TextColor3=Color3.fromRGB(255,255,255)
    ShowBtn.Visible=false
    ShowBtn.Parent=ScreenGui

    -- Dragging ShowBtn
    local dragging=false
    local dragInput,mousePos,startPos
    local function update(input)
        local delta = input.Position - mousePos
        ShowBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    ShowBtn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true
            mousePos=input.Position
            startPos=ShowBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    ShowBtn.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement then
            dragInput=input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input==dragInput and dragging then update(input) end
    end)

    HideBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible=false
        ShowBtn.Visible=true
    end)
    ShowBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible=true
        ShowBtn.Visible=false
    end)

    -- Toggle helper
    local function createToggle(name,boolValue)
        local frame=Instance.new("Frame")
        frame.Size=UDim2.new(0,180,0,20)
        frame.BackgroundColor3=Color3.fromRGB(45,45,45)
        frame.Parent=Scroll

        local label=Instance.new("TextLabel")
        label.Size=UDim2.new(0.6,0,1,0)
        label.Text=name;label.TextColor3=Color3.fromRGB(255,255,255)
        label.BackgroundTransparency=1
        label.Parent=frame

        local slider=Instance.new("Frame")
        slider.Size=UDim2.new(0,40,0,16)
        slider.Position=UDim2.new(0.65,0,0,2)
        slider.BackgroundColor3=Color3.fromRGB(70,70,70)
        slider.Parent=frame

        local knob=Instance.new("TextButton")
        knob.Size=UDim2.new(0,16,0,16)
        knob.Position=boolValue.Value and UDim2.new(1,-16,0,0) or UDim2.new(0,0,0,0)
        knob.Text=""
        knob.BackgroundColor3=boolValue.Value and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
        knob.Parent=slider

        knob.MouseButton1Click:Connect(function()
            boolValue.Value=not boolValue.Value
            knob.Position=boolValue.Value and UDim2.new(1,-16,0,0) or UDim2.new(0,0,0,0)
            knob.BackgroundColor3=boolValue.Value and Color3.fromRGB(50,200,50) or Color3.fromRGB(200,50,50)
        end)
        return boolValue
    end

    local LoopViaCP=createToggle("Loop via CP",LocalPlayer.AutoSummitStatus.LoopViaCP)
    local LoopDirect=createToggle("Loop Direct",LocalPlayer.AutoSummitStatus.LoopDirect)

    -- Manual teleport
    for _, name in ipairs(checkpointsOrder) do
        local cf=checkpointsCFrame[name]
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(0,180,0,18)
        btn.BackgroundColor3=Color3.fromRGB(60,60,60)
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.Text="→ "..name
        btn.Parent=Scroll
        btn.MouseButton1Click:Connect(function() teleportTo(cf,name=="Summit") end)
    end

    -- Reset summit
    local resetBtn=Instance.new("TextButton")
    resetBtn.Size=UDim2.new(0,180,0,20)
    resetBtn.Text="Reset Summit"
    resetBtn.BackgroundColor3=Color3.fromRGB(200,100,50)
    resetBtn.TextColor3=Color3.fromRGB(255,255,255)
    resetBtn.Parent=Scroll
    resetBtn.MouseButton1Click:Connect(function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
            notify("Summit reset! Respawned at basecamp.")
        end
    end)

    -- Server hop
    local hopBtn=Instance.new("TextButton")
    hopBtn.Size=UDim2.new(0,180,0,20)
    hopBtn.Text="Server Hop"
    hopBtn.BackgroundColor3=Color3.fromRGB(100,150,250)
    hopBtn.TextColor3=Color3.fromRGB(255,255,255)
    hopBtn.Parent=Scroll
    hopBtn.MouseButton1Click:Connect(function()
        local success,servers=pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and servers and servers.data then
            table.sort(servers.data,function(a,b) return a.playing<b.playing end)
            local chosen
            for _,s in pairs(servers.data) do
                if s.id~=game.JobId then chosen=s break end
            end
            if chosen then
                TeleportService:TeleportToPlaceInstance(PlaceId,chosen.id,LocalPlayer)
            else
                notify("Tidak ada server tersedia!")
            end
        else
            notify("Gagal fetch server list!")
        end
    end)

    -- Auto loop
    spawn(function()
        while true do
            if LoopViaCP.Value then
                teleportTo(checkpointsCFrame["Basecamp"])
                for _, cp in ipairs(checkpointsOrder) do
                    if not LoopViaCP.Value then break end
                    teleportTo(checkpointsCFrame[cp],cp=="Summit")
                end
                teleportTo(checkpointsCFrame["Basecamp"])
            elseif LoopDirect.Value then
                teleportTo(checkpointsCFrame["Basecamp"])
                if LoopDirect.Value then teleportTo(checkpointsCFrame["Summit"],true) end
                teleportTo(checkpointsCFrame["Basecamp"])
            else wait(0.5) end
        end
    end)
end

-- Init
CreateUI()
LocalPlayer.CharacterAdded:Connect(function() wait(1) CreateUI() end)
