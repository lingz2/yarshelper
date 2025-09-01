-- Ultra Final Auto Summit + Server Hop + Respawn Reset
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

-- Notify helper
local function notify(msg)
    game.StarterGui:SetCore("SendNotification",{Title="Auto Summit",Text=msg,Duration=2})
end

-- Teleport helper
local function teleportTo(cf, summitDelay)
    local root=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        TweenService:Create(root,TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=cf}):Play()
        if summitDelay then wait(60) else wait(math.random(10,30)/10) end
        notify("Teleport berhasil!")
    end
end

-- Server Hop helper
local function serverHop()
    local success,servers=pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if not success then notify("Gagal mengambil server"); return end
    local bestServer
    local fewestPlayers=math.huge
    for _,v in ipairs(servers.data or {}) do
        if v.playing < fewestPlayers and v.maxPlayers>v.playing then
            fewestPlayers=v.playing
            bestServer=v.id
        end
    end
    if bestServer then
        notify("Server hop ke server dengan "..fewestPlayers.." player...")
        wait(2)
        TeleportService:TeleportToPlaceInstance(PlaceId, bestServer, LocalPlayer)
    else
        notify("Tidak ada server kosong tersedia!")
    end
end

-- Reset summit / auto loop saat respawn
local function resetOnRespawn()
    if LocalPlayer.Character then
        LocalPlayer.Character:WaitForChild("Humanoid").Died:Connect(function()
            wait(1)
            LocalPlayer.AutoSummitStatus.LoopViaCP.Value=false
            LocalPlayer.AutoSummitStatus.LoopDirect.Value=false
            notify("Summit reset setelah respawn, toggle dimatikan")
        end)
    end
    Players.PlayerAdded:Connect(function(player)
        if player==LocalPlayer then
            local character=player.Character or player.CharacterAdded:Wait()
            character:WaitForChild("HumanoidRootPart")
            LocalPlayer.AutoSummitStatus.LoopViaCP.Value=false
            LocalPlayer.AutoSummitStatus.LoopDirect.Value=false
            notify("Summit reset, toggle auto loop dimatikan")
        end
    end)
end

resetOnRespawn()

-- UI creation
local function CreateUI()
    if PlayerGui:FindFirstChild("AutoSummitUI") then return end
    local ScreenGui=Instance.new("ScreenGui")
    ScreenGui.Name="AutoSummitUI"
    ScreenGui.Parent=PlayerGui

    local MainFrame=Instance.new("Frame")
    MainFrame.Size=UDim2.new(0,220,0,350)
    MainFrame.Position=UDim2.new(0,10,0.5,-175)
    MainFrame.BackgroundColor3=Color3.fromRGB(30,30,30)
    MainFrame.BorderSizePixel=0
    MainFrame.Visible=true
    MainFrame.Parent=ScreenGui

    local TabsFrame=Instance.new("Frame")
    TabsFrame.Size=UDim2.new(1,0,0,25)
    TabsFrame.BackgroundTransparency=1
    TabsFrame.Parent=MainFrame

    local TeleportTab = Instance.new("TextButton")
    TeleportTab.Size = UDim2.new(0.5,0,1,0)
    TeleportTab.Text="Teleport"
    TeleportTab.BackgroundColor3=Color3.fromRGB(60,60,60)
    TeleportTab.TextColor3=Color3.fromRGB(255,255,255)
    TeleportTab.Parent=TabsFrame

    local InfoTab = Instance.new("TextButton")
    InfoTab.Size = UDim2.new(0.5,0,1,0)
    InfoTab.Position = UDim2.new(0.5,0,0,0)
    InfoTab.Text="Informasi"
    InfoTab.BackgroundColor3=Color3.fromRGB(40,40,40)
    InfoTab.TextColor3=Color3.fromRGB(255,255,255)
    InfoTab.Parent=TabsFrame

    local TeleportFrame = Instance.new("ScrollingFrame")
    TeleportFrame.Size=UDim2.new(1,0,1,-25)
    TeleportFrame.Position=UDim2.new(0,0,0,25)
    TeleportFrame.ScrollBarThickness=6
    TeleportFrame.BackgroundTransparency=1
    TeleportFrame.Parent=MainFrame

    local InfoFrame = Instance.new("ScrollingFrame")
    InfoFrame.Size=UDim2.new(1,0,1,-25)
    InfoFrame.Position=UDim2.new(0,0,0,25)
    InfoFrame.ScrollBarThickness=6
    InfoFrame.BackgroundTransparency=1
    InfoFrame.Visible=false
    InfoFrame.Parent=MainFrame

    -- Tab switching
    TeleportTab.MouseButton1Click:Connect(function()
        TeleportFrame.Visible=true
        InfoFrame.Visible=false
        TeleportTab.BackgroundColor3=Color3.fromRGB(60,60,60)
        InfoTab.BackgroundColor3=Color3.fromRGB(40,40,40)
    end)
    InfoTab.MouseButton1Click:Connect(function()
        TeleportFrame.Visible=false
        InfoFrame.Visible=true
        TeleportTab.BackgroundColor3=Color3.fromRGB(40,40,40)
        InfoTab.BackgroundColor3=Color3.fromRGB(60,60,60)
    end)

    -- Hide/Show draggable
    local HideBtn=Instance.new("TextButton")
    HideBtn.Size=UDim2.new(1,0,0,25)
    HideBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
    HideBtn.TextColor3=Color3.fromRGB(255,255,255)
    HideBtn.Text="Hide UI"
    HideBtn.Parent=TeleportFrame

    local ShowBtn=Instance.new("TextButton")
    ShowBtn.Size=UDim2.new(0,80,0,25)
    ShowBtn.Position=UDim2.new(0,10,0.5,-10)
    ShowBtn.Text="yars cakep"
    ShowBtn.BackgroundColor3=Color3.fromRGB(150,50,200)
    ShowBtn.TextColor3=Color3.fromRGB(255,255,255)
    ShowBtn.Visible=false
    ShowBtn.Parent=ScreenGui

    -- Dragging ShowBtn
    local dragging=false; local dragInput,mousePos,startPos
    local function update(input)
        local delta = input.Position - mousePos
        ShowBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                     startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    ShowBtn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; mousePos=input.Position; startPos=ShowBtn.Position
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

    -- Toggle switches
    local function createToggle(name,boolValue,parent)
        local frame=Instance.new("Frame")
        frame.Size=UDim2.new(1,0,0,25)
        frame.BackgroundTransparency=1
        frame.Parent=parent

        local label=Instance.new("TextLabel")
        label.Size=UDim2.new(0.6,0,1,0)
        label.Text=name
        label.BackgroundTransparency=1
        label.TextColor3=Color3.fromRGB(255,255,255)
        label.Parent=frame

        local slider=Instance.new("Frame")
        slider.Size=UDim2.new(0.35,0,0.5,0)
        slider.Position=UDim2.new(0.6,0,0.25,0)
        slider.BackgroundColor3=Color3.fromRGB(100,100,100)
        slider.Parent=frame

        local knob=Instance.new("Frame")
        knob.Size=UDim2.new(0,18,0,16)
        knob.Position=boolValue.Value and UDim2.new(0.5,0,0,0) or UDim2.new(0,0,0,0)
        knob.BackgroundColor3=Color3.fromRGB(200,200,200)
        knob.Parent=slider

        local function toggle()
            boolValue.Value=not boolValue.Value
            knob.Position=boolValue.Value and UDim2.new(0.5,0,0,0) or UDim2.new(0,0,0,0)
        end
        slider.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then toggle() end
        end)
        return boolValue
    end

    local LoopViaCP=createToggle("Loop Via CP",LocalPlayer.AutoSummitStatus.LoopViaCP,TeleportFrame)
    local LoopDirect=createToggle("Loop Direct",LocalPlayer.AutoSummitStatus.LoopDirect,TeleportFrame)

    -- Manual teleport buttons
    for _,name in ipairs(checkpointsOrder) do
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(1,0,0,25)
        btn.Text="Teleport "..name
        btn.BackgroundColor3=Color3.fromRGB(60,60,60)
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.Parent=TeleportFrame

        btn.MouseButton1Click:Connect(function()
            teleportTo(checkpointsCFrame[name],name=="Summit")
        end)
    end

    -- Server Hop button
    local hopBtn = Instance.new("TextButton")
    hopBtn.Size = UDim2.new(1,0,0,25)
    hopBtn.Text = "Server Hop"
    hopBtn.BackgroundColor3 = Color3.fromRGB(120,60,60)
    hopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    hopBtn.Parent = TeleportFrame
    hopBtn.MouseButton1Click:Connect(function() serverHop() end)

    -- Info tab: waktu minimum
    local infoLabel=Instance.new("TextLabel")
    infoLabel.Size=UDim2.new(1,0,0,25)
    infoLabel.BackgroundTransparency=1
    infoLabel.TextColor3=Color3.fromRGB(255,255,255)
    infoLabel.Text="Waktu minimum Basecamp → Summit: belum dihitung"
    infoLabel.Parent=InfoFrame

    local lastStart,lastEnd
    local function startTimer() lastStart=tick() end
    local function endTimer()
        lastEnd=tick()
        local elapsed=math.floor(lastEnd-lastStart)
        infoLabel.Text="Waktu Basecamp → Summit: "..elapsed.." detik"
    end

    -- Auto loop
    spawn(function()
        while true do
            if LoopViaCP.Value or LoopDirect.Value then
                startTimer()
                teleportTo(checkpointsCFrame["Basecamp"])
                if LoopViaCP.Value then
                    for i,cp in ipairs(checkpointsOrder) do
                        if not LoopViaCP.Value then break end
                        teleportTo(checkpointsCFrame[cp],cp=="Summit")
                    end
                elseif LoopDirect.Value then
                    teleportTo(checkpointsCFrame["Summit"],true)
                    wait(60)
                end
                teleportTo(checkpointsCFrame["Basecamp"])
                endTimer()
            else wait(1) end
        end
    end)
end

CreateUI()
