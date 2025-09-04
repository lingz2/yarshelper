-- UNIVERSAL REMOTE DETECTOR (FireServer)
-- Delta Executor Ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local detected = {}

-- fungsi hook FireServer untuk RemoteEvent
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") and not detected[remote] then
        detected[remote] = true
        local old = remote.FireServer
        remote.FireServer = function(self, ...)
            print("[REMOTE DETECTED] "..remote:GetFullName())
            local args = {...}
            for i,arg in ipairs(args) do
                print("Arg"..i..":", arg)
            end
            return old(self, ...)
        end
    end
end

-- hook semua RemoteEvent di folder tertentu
local function scanFolder(folder)
    for _,v in pairs(folder:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            hookRemote(v)
        end
    end
end

-- scan ReplicatedStorage, Workspace, PlayerScripts
scanFolder(ReplicatedStorage)
scanFolder(Workspace)
scanFolder(player.PlayerScripts)
scanFolder(player.Backpack)

-- listen RemoteEvent baru
ReplicatedStorage.DescendantAdded:Connect(hookRemote)
Workspace.DescendantAdded:Connect(hookRemote)
player.PlayerScripts.DescendantAdded:Connect(hookRemote)
player.Backpack.DescendantAdded:Connect(hookRemote)

-- notifikasi
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "Summit Detector",
    Text = "Tekan tombol Summit di game untuk mendeteksi RemoteEvent",
    Duration = 5
})
