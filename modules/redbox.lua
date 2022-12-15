local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local TeleportService = Services.TeleportService
local RunService = Services.RunService

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
local ESP = ImportESP()
ESP.Overrides.GetColor = function()
    return ESP.Presets.White
end

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

local CreateWarning = function(title, text, del)
    local suc, res = pcall(function()
        local frame = GuiLibrary.CreateNotification(title, text, del, "assets/WarningNotification.png")
        frame.Frame.Frame.ImageColor3 = Color3.fromRGB(236, 129, 44)
        return frame
    end)
    return (suc and res)
end

local GetRoot = function(char)
    char = char or LocalPlayer.Character
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local AddTool = ReplicatedStorage.AddTool
local Loadout = ReplicatedStorage.Assets.Loadout
local Tools = {Enabled = false}
Tools = Combat.CreateOptionsButton({
    Name = "Tools",
    Function = function(callback)
        if callback then
            Tools.ToggleButton(false)
            AddTool:FireServer(LocalPlayer.Character, Loadout.Melee.Halberd)
            AddTool:FireServer(LocalPlayer.Character, Loadout.Secondary:FindFirstChild("Beretta M9"))
            AddTool:FireServer(LocalPlayer.Character, Loadout.Primary["Pump Shotgun"])
            AddTool:FireServer(LocalPlayer.Character, Loadout.Primary["M4A1"])
            AddTool:FireServer(LocalPlayer.Character, Loadout.Misc:FindFirstChild("Frag Grenade"))
            AddTool:FireServer(LocalPlayer.Character, Loadout.Misc:FindFirstChild("Incendiary Grenade"))
            AddTool:FireServer(LocalPlayer.Character, Loadout.Misc:FindFirstChild("Cuffs"))
        end
    end
})

local InvisStorage = {}
local Invisibility = World.CreateOptionsButton({
    Name = "Invisibility",
    Function = function(callback)
        if callback then
            local Root = GetRoot()
            local OldPos = Root.CFrame
            local Seat = Instance.new("Seat")
            local Weld = Instance.new("Weld")
            Root.CFrame = CFrame.new(9e9, 9e9, 9e9)
            wait(0.2)
            Root.Anchored = true
            Seat.Parent = workspace
            Seat.CFrame = Root.CFrame
            Seat.Anchored = false
            Weld.Parent = Seat
            Weld.Part0 = Seat
            Weld.Part1 = Root
            Root.Anchored = false
            Seat.CFrame = OldPos
            InvisStorage.Seat = Seat
            InvisStorage.Weld = Weld
            for _, v in next, Root.Parent:GetChildren() do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") then
                    InvisStorage[v] = v.Transparency
                    v.Transparency = v.Transparency <= 0.3 and 0.4 or v.Transparency
                elseif v:IsA("Accessory") then
                    local Handle = v:FindFirstChildWhichIsA("MeshPart") or v:FindFirstChildWhichIsA("Part")
                    if Handle then
                        InvisStorage[Handle] = Handle.Transparency
                        Handle.Transparency = Handle.Transparency <= 0.3 and 0.4 or Handle.Transparency
                    end
                end
            end
            Seat.Transparency = 1
        else
            local Seat = InvisStorage.Seat
            local Weld = InvisStorage.Weld
            if Seat and Weld then
                Weld.Part0 = nil
                Weld.Part1 = nil
                Seat:Destroy()
                Weld:Destroy()
                InvisStorage.Seat = nil
                InvisStorage.Weld = nil
                for i, v in next, InvisStorage do
                    if type(v) == "number" then
                        i.Transparency = v
                    end
                end
            end
        end
    end
})

local IsStaff = function(player)
    if player and player:IsInGroup(10589628) and player:GetRankInGroup(10589628) >= 252 then
        return {true, player:GetRoleInGroup(10589628)}
    end
    return {false, "Guest"}
end
local CheckStaff = function(player)
    local data = IsStaff(player)
    if data[1] then
        CreateWarning("StaffCheck", "Staff Detected: " .. (player.DisplayName and player.DisplayName .. " (" .. player.Name .. ")" or player.Name) .. " has the rank " .. data[2], 60)
    end
end
local StaffWatch = {Enabled = false}
StaffWatch = Utility.CreateOptionsButton({
    Name = "StaffCheck",
    Function = function(callback)
        if callback then
            for _, v in next, Players:GetChildren() do
                CheckStaff(v)
            end
        end
    end
})
Players.PlayerAdded:Connect(function(player)
    if StaffWatch.Enabled then
        CheckStaff(player)
    end
end)

local Rejoin = {Enabled = false}
Rejoin = Utility.CreateOptionsButton({
    Name = "Rejoin",
    Function = function(callback)
        if callback then
            Rejoin.ToggleButton(false)
            if #Players:GetPlayers() <= 1 then
                LocalPlayer:Kick("\nRejoining...")
                wait()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end
    end
})

local OldSpeed = nil
local SpeedConnection = nil
local SpeedVal = {Value = 65}
local Speed = Blatant.CreateOptionsButton({
    Name = "Speed",
    Function = function(callback)
        if callback then
            pcall(function()
                SpeedConnection:Disconnect()
                SpeedConnection = nil
            end)
            SpeedConnection = RunService.Heartbeat:Connect(function()
                local Humanoid = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid then
                    if OldSpeed == nil then
                        OldSpeed = Humanoid.WalkSpeed
                    end
                    Humanoid.WalkSpeed = SpeedVal.Value
                end
            end)
        else
            local Humanoid = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid and OldSpeed then
                Humanoid.WalkSpeed = OldSpeed
            end
            OldSpeed = nil
            pcall(function()
                SpeedConnection:Disconnect()
                SpeedConnection = nil
            end)
        end
    end
})
SpeedVal = Speed.CreateSlider({
    Name = "Speed",
    Min = 1,
    Max = 250,
    Default = 65,
    Function = function() end
})

local OldJumpPower = nil
local JumpConnection = nil
local JumpVal = {Value = 75}
local JumpPower = Blatant.CreateOptionsButton({
    Name = "JumpPower",
    Function = function(callback)
        if callback then
            pcall(function()
                JumpConnection:Disconnect()
                JumpConnection = nil
            end)
            JumpConnection = RunService.Heartbeat:Connect(function()
                local Humanoid = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid then
                    if OldJumpPower == nil then
                        OldJumpPower = Humanoid.JumpPower
                    end
                    Humanoid.JumpPower = JumpVal.Value
                end
            end)
        else
            local Humanoid = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid and OldJumpPower then
                Humanoid.JumpPower = OldJumpPower
            end
            OldJumpPower = nil
            pcall(function()
                JumpConnection:Disconnect()
                JumpConnection = nil
            end)
        end
    end
})
JumpVal = JumpPower.CreateSlider({
    Name = "Power",
    Min = 1,
    Max = 250,
    Default = 75,
    Function = function() end
})

local equipMelee = function()
    if LocalPlayer and LocalPlayer:FindFirstChildWhichIsA("Backpack") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
        local Backpack = LocalPlayer:FindFirstChildWhichIsA("Backpack")
        local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        Humanoid:UnequipTools()
        for _, v in pairs(Backpack:GetDescendants()) do
            if v.Name == "toolSettings" and v:IsA("ModuleScript") and require(v).toolType == "melee" then
                local melee = v.Parent
                Humanoid:EquipTool(melee)
                return melee
            end
        end
    end
    return false
end

local HitMelee = ReplicatedStorage.Assets.Remotes.hitMelee
local KillAll = {Enabled = false}
KillAll = Blatant.CreateOptionsButton({
    Name = "KillAll",
    Function = function(callback)
        if callback then
            KillAll.ToggleButton(false)
            local melee = equipMelee()
            wait(0.81)
            if melee then
                for _, v in pairs(Players:GetChildren()) do
                    if v ~= LocalPlayer and v.Character then
                        local Humanoid = v.Character:FindFirstChildWhichIsA("Humanoid")
                        local Head = v.Character:FindFirstChild("Head")
                        if Humanoid and Humanoid.Health > 0 and Head then
                            local args = {
                                [1] = Head,
                                [2] = Vector3.new(182.07310485839844, 5.787327289581299, -430.5772705078125),
                                [3] = Vector3.new(-0.783150851726532, 0.18024331331253052, -0.5951363444328308),
                                [4] = Enum.Material.Plastic,
                                [5] = CFrame.new(Vector3.new(-0.159149169921875, -0.2970867156982422, 1.0000152587890625), Vector3.new(0.00001424551010131836, 7.227063179016113e-07, 1.0000001192092896)),
                                [6] = melee
                            }
                            HitMelee:FireServer(unpack(args))
                            HitMelee:FireServer(unpack(args))
                            HitMelee:FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end,
    HoverText = "Requires a melee weapon."
})
