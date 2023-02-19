local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local Mouse = LocalPlayer:GetMouse()

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
local ESP = ImportESP()

local NewESP = Render.CreateOptionsButton({
    Name = "ESP",
    Function = function(callback)
        ESP:Toggle(callback)
    end
})
NewESP.CreateToggle({
    Name = "Players",
    Function = function(callback)
        ESP.Players = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Boxes",
    Function = function(callback)
        ESP.Boxes = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Nametags",
    Function = function(callback)
        ESP.Names = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Health",
    Function = function(callback)
        ESP.Health = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Tracers",
    Function = function(callback)
        ESP.Tracers = callback
    end
})

local Remotes = {
    Damage = ReplicatedStorage.Damage,
    SpaceRipper = ReplicatedStorage.SpaceRipperStingyEyes,
    Epitaph = ReplicatedStorage.DoppioEpitaph,
    TETeleport = ReplicatedStorage.TETeleport,
    RTZEffect = ReplicatedStorage.RTZEffect
}

local CreateWarning = function(title, text, del)
    local suc, res = pcall(function()
        local frame = GuiLibrary.CreateNotification(title, text, del, "assets/WarningNotification.png")
        frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
        return frame
    end)
    return (suc and res)
end

local IsStaff = function(player)
    if player and player:IsInGroup(4516503) and player:GetRankInGroup(4516503) >= 3 then
        return {true, player:GetRoleInGroup(4516503)}
    end
    return {false, "Guest"}
end

local CheckStaff = function(player)
    local data = IsStaff(player)
    if data[1] then
        CreateWarning("StaffCheck", "Staff Detected: " .. (player.DisplayName and player.DisplayName .. " (" .. player.Name .. ")" or player.Name) .. " has the rank " .. data[2], 60)
    end
end

local GetRoot = function(char)
    char = char or LocalPlayer.Character
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(Mouse.X, Mouse.Y)
end

local GetClosestPlayerFromCursor = function()
    local found = nil
    local ClosestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            for _, object in pairs(player.Character:GetChildren()) do
                if object.Name == "Head" and object.Parent == player.Character then
                    local Distance = (WorldToScreen(object) - MousePositionToVector2()).Magnitude
                    if Distance < ClosestDistance then
                        ClosestDistance = Distance
                        found = player
                    end
                end
            end
        end
    end
    return found
end

local SatansEyes = {Enabled = false}
SatansEyes = Combat.CreateOptionsButton({
    Name = "SatansEyes",
    Function = function(callback)
        if callback then
            SatansEyes.ToggleButton(false)
            for i = 1, 30 do
                Remotes.SpaceRipper:FireServer()
            end
        end
    end
})

local SlashMethod = {Value = "Cursor"}
local Slash = {Enabled = false}
Slash = Combat.CreateOptionsButton({
    Name = "QuickDamage",
    Function = function(callback)
        if callback then
            Slash.ToggleButton(false)
            if SlashMethod.Value == "Cursor" then
                if LocalPlayer and LocalPlayer.Character then
                    local target = GetClosestPlayerFromCursor()
                    if target ~= nil and target.Character then
                        local Humanoid = target.Character:FindFirstChildWhichIsA("Humanoid")
                        if Humanoid and Humanoid.Health > 0 then
                            local args = {
                                [1] = Humanoid,
                                [2] = CFrame.new(Vector3.new(-6223.79638671875, 582.9769897460938, -440.1474914550781), Vector3.new(-0.059938546270132065, 0.9967595934867859, -0.053645022213459015)),
                                [3] = 7.5,
                                [4] = 0.25,
                                [5] = Vector3.new(-3.199983596801758, -0.000001355177346340497, 9.474181175231934),
                                [6] = "rbxassetid://241837157",
                                [7] = 0.075,
                                [8] = Color3.new(1, 1, 1),
                                [9] = "rbxassetid://260430079",
                                [10] = 1,
                                [11] = 0.4
                            }
                            for i = 1, 1000 do
                                Remotes.Damage:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
            if SlashMethod.Value == "Nearest" then
                if LocalPlayer and LocalPlayer.Character and GetRoot() then
                    local Root = GetRoot()
                    local lowest = math.huge
                    local target = nil
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character then
                            local distance = v:DistanceFromCharacter(Root.Position)
                            if distance < lowest then
                                lowest = distance
                                target = v
                            end
                        end
                    end
                    if target ~= nil and target.Character then
                        local Humanoid = target.Character:FindFirstChildWhichIsA("Humanoid")
                        if Humanoid and Humanoid.Health > 0 then
                            local args = {
                                [1] = Humanoid,
                                [2] = CFrame.new(Vector3.new(-6223.79638671875, 582.9769897460938, -440.1474914550781), Vector3.new(-0.059938546270132065, 0.9967595934867859, -0.053645022213459015)),
                                [3] = 7.5,
                                [4] = 0.25,
                                [5] = Vector3.new(-3.199983596801758, -0.000001355177346340497, 9.474181175231934),
                                [6] = "rbxassetid://241837157",
                                [7] = 0.075,
                                [8] = Color3.new(1, 1, 1),
                                [9] = "rbxassetid://260430079",
                                [10] = 1,
                                [11] = 0.4
                            }
                            for i = 1, 1000 do
                                Remotes.Damage:FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
            if SlashMethod.Value == "All" then
                if LocalPlayer and LocalPlayer.Character then
                    for _, target in pairs(Players:GetPlayers()) do
                        if target ~= LocalPlayer and target.Character then
                            local Humanoid = target.Character:FindFirstChildWhichIsA("Humanoid")
                            if Humanoid and Humanoid.Health > 0 then
                                local args = {
                                    [1] = Humanoid,
                                    [2] = CFrame.new(Vector3.new(-6223.79638671875, 582.9769897460938, -440.1474914550781), Vector3.new(-0.059938546270132065, 0.9967595934867859, -0.053645022213459015)),
                                    [3] = 7.5,
                                    [4] = 0.25,
                                    [5] = Vector3.new(-3.199983596801758, -0.000001355177346340497, 9.474181175231934),
                                    [6] = "rbxassetid://241837157",
                                    [7] = 0.075,
                                    [8] = Color3.new(1, 1, 1),
                                    [9] = "rbxassetid://260430079",
                                    [10] = 1,
                                    [11] = 0.4
                                }
                                for i = 1, 1000 do
                                    Remotes.Damage:FireServer(unpack(args))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})
SlashMethod = Slash.CreateDropdown({
    Name = "Mode", 
    List = {"Cursor", "Nearest", "All"},
    Function = function() end
})

local Immortality = {Enabled = false}
Immortality = Blatant.CreateOptionsButton({
    Name = "Immortality",
    Function = function(callback)
        if callback then
            Remotes.Epitaph:FireServer()
            repeat wait(0.5)
                Remotes.Epitaph:FireServer()
            until not Immortality.Enabled
        end
    end,
    HoverText = "Requires King Crimson."
})

local Aura = {Enabled = false}
Aura = Blatant.CreateOptionsButton({
    Name = "Aura",
    Function = function(callback)
        if callback then
            repeat wait()
                Remotes.TETeleport:FireServer(BrickColor.new("Light blue"))
            until not Aura.Enabled
        end
    end,
    HoverText = "Requires King Crimson."
})

local BlackOrb = {Enabled = false}
BlackOrb = Blatant.CreateOptionsButton({
    Name = "BlackOrb",
    Function = function(callback)
        if callback then
            repeat wait(0.1)
                Remotes.RTZEffect:FireServer(true)
            until not BlackOrb.Enabled
        end
    end
})

local StaffWatch = {Enabled = false}
StaffWatch = Utility.CreateOptionsButton({
    Name = "StaffCheck",
    Function = function(callback)
        if callback then
            for _, player in next, Players:GetPlayers() do
                if player ~= LocalPlayer then
                    CheckStaff(player)
                end
            end
        end
    end
})
Players.PlayerAdded:Connect(function(player)
    if StaffWatch.Enabled then
        CheckStaff(player)
    end
end)
