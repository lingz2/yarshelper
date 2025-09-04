-- DETEKTOR TOMBOL SUMMIT / REMOTE EVENT
-- Delta Executor Ready

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Menyimpan remote yang terdeteksi
local detectedRemotes = {}

-- Fungsi untuk hook FireServer
local function hookRemote(remote)
    if remote:IsA("RemoteEvent") and not detectedRemotes[remote] then
        detectedRemotes[remote] = true

        -- Hook FireServer
        local oldFireServer = remote.FireServer
        remote.FireServer = function(self, ...)
            print("[DETECTED REMOTE EVENT] Nama:", remote.Name)
            print("[ARGUMENTS]:", ...)
            return oldFireServer(self, ...)
        end
    end
end

-- Cek semua RemoteEvent di ReplicatedStorage awal
for _, v in pairs(ReplicatedStorage:GetChildren()) do
    if v:IsA("RemoteEvent") then
        hookRemote(v)
    end
end

-- Listener untuk RemoteEvent baru yang muncul di ReplicatedStorage
ReplicatedStorage.ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") then
        hookRemote(child)
    end
end)

-- Notifikasi di client
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "Summit Detector",
    Text = "Tekan tombol Summit di game untuk mendeteksi RemoteEvent",
    Duration = 5
})
