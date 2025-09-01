for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Part") then
        v.Touched:Connect(function(hit)
            if hit.Parent == LocalPlayer.Character then
                print("✅ Menyentuh: "..v.Name)
            end
        end)
    end
end
