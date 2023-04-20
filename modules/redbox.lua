local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local TeleportService = Services.TeleportService
local RunService = Services.RunService
local Mouse = LocalPlayer:GetMouse()

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

local AddTool = ReplicatedStorage.AddTool
local Loadout = ReplicatedStorage.Assets.Loadout
local HitMelee = ReplicatedStorage.Assets.Remotes.hitMelee
local InvisStorage = {}
local sort = table.sort

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

local Tools = {Enabled = false}
local Weapons = {Loadout.Melee.Halberd, Loadout.Secondary:FindFirstChild("Beretta M9"), Loadout.Primary["Pump Shotgun"], Loadout.Primary["M4A1"], Loadout.Misc:FindFirstChild("Frag Grenade"), Loadout.Misc:FindFirstChild("Incendiary Grenade"), Loadout.Misc:FindFirstChild("Cuffs")}
Tools = Combat.CreateOptionsButton({
    Name = "Tools",
    Function = function(callback)
        if callback then
            Tools.ToggleButton(false)
            for _, weapon in next, Weapons do AddTool:FireServer(LocalPlayer.Character, weapon) end
        end
    end
})

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
                for i, v in next, InvisStorage do if type(v) == "number" then i.Transparency = v end end
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
    local backpack = LocalPlayer:FindFirstChildWhichIsA("Backpack")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if LocalPlayer.Character and backpack and humanoid then
        for _, v in next, LocalPlayer.Character:GetDescendants() do
            if v:IsA("ModuleScript") and v.Name == "toolSettings" and require(v).toolType == "melee" then
                return v.Parent, ""
            end
        end
        humanoid:UnequipTools()
        for _, v in next, backpack:GetDescendants() do
            if v:IsA("ModuleScript") and v.Name == "toolSettings" and require(v).toolType == "melee" then
                local melee = v.Parent
                humanoid:EquipTool(melee)
                return melee, "equipping"
            end
        end
    end
    return false, ""
end

local filter = function(tbl, func)
    local new = {}
    for i, v in next, tbl do if func(i, v) then new[#new + 1] = v end end
    return new
end

local map = function(tbl, func)
    local new = {}
    for i, v in next, tbl do
        local k, x = func(i, v)
        new[x or #new + 1] = k
    end
    return new
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
    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChildWhichIsA("Humanoid") then
            for _, x in pairs(v.Character:GetChildren()) do
                if x.Name:find("Torso") then
                    local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
                    if Distance < ClosestDistance then
                        ClosestDistance = Distance
                        found = v
                    end
                end
            end
        end
    end
    return found
end

local ClosetEnemy = function()
    local available = filter(Players:GetPlayers(), function(_, v) return v ~= LocalPlayer and v.Character and GetRoot(v.Character) end)
    local alive = filter(available, function(_, v) return v.Character:FindFirstChildWhichIsA("Humanoid") and v.Character:FindFirstChildWhichIsA("Humanoid").Health > 0 end)
    local magnitudes = map(alive, function(_, v) return {v, (GetRoot(v.Character).CFrame.p - GetRoot().CFrame.p).Magnitude} end)
    sort(magnitudes, function(a, b) return a[2] < b[2] end)
    return (#available == 0 and nil) or magnitudes[1][1]
end

local GetEntitiesFromMethod = function(method)
    if method == "Nearest" then return {ClosetEnemy()} end
    if method == "Cursor" then return {GetClosestPlayerFromCursor()} end
    return filter(Players:GetPlayers(), function(_, v) return v ~= LocalPlayer end)
end

local KillMethod = {Value = "All"}
local EntityKill = {Enabled = false}
EntityKill = Blatant.CreateOptionsButton({
    Name = "EntityKill",
    Function = function(callback)
        if callback then
            EntityKill.ToggleButton(false)
            local melee, status = equipMelee()
            if melee then
                if status == "equipping" then wait(require(melee.toolSettings).equipTime + 0.01) end
                for _, target in next, GetEntitiesFromMethod(KillMethod.Value) do
                    if target.Character then
                        local humanoid = target.Character:FindFirstChildWhichIsA("Humanoid")
                        local head = target.Character:FindFirstChild("Head")
                        if humanoid and humanoid.Health > 0 and head then
                            local v3 = Vector3.new(0, 0, 0)
                            local cf = CFrame.new(v3, v3, v3)
                            for _ = 1, 4 do HitMelee:FireServer(head, v3, v3, Enum.Material.Plastic, cf, melee) end
                        end
                    end
                end
            end
        end
    end,
    HoverText = "Requires a melee weapon."
})
KillMethod = EntityKill.CreateDropdown({
    Name = "Mode", 
    List = {"All", "Nearest", "Cursor"},
    Function = function() end
})
