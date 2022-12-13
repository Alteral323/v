local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local TeleportService = Services.TeleportService

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
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
            AddTool:FireServer(LocalPlayer.Character, Loadout.Melee.Halberd)
            AddTool:FireServer(LocalPlayer.Character, Loadout.Secondary:FindFirstChild("Beretta M9"))
            AddTool:FireServer(LocalPlayer.Character, Loadout.Primary["Pump Shotgun"])
            AddTool:FireServer(LocalPlayer.Character, Loadout.Primary["M4A1"])
            AddTool:FireServer(LocalPlayer.Character, Loadout.Misc:FindFirstChild("Frag Grenade"))
            AddTool:FireServer(LocalPlayer.Character, Loadout.Misc:FindFirstChild("Incendiary Grenade"))
            AddTool:FireServer(LocalPlayer.Character, Loadout.Misc:FindFirstChild("Cuffs"))
            Tools.ToggleButton(false)
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
    if StaffCheck.Enabled then
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
