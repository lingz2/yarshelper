-- Sniffer RemoteEvent FireServer
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local old; old = hookfunction(v.FireServer, function(self, ...)
            print("[RemoteEvent Dipanggil] =>", self.Name, "Args:", ...)
            return old(self, ...)
        end)
    end
end

for _, v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteFunction") then
        local old; old = hookfunction(v.InvokeServer, function(self, ...)
            print("[RemoteFunction Dipanggil] =>", self.Name, "Args:", ...)
            return old(self, ...)
        end)
    end
end
