local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api

local remfolder = ReplicatedStorage.RS.Remotes
local remotes = {attack = remfolder.Combat.DealWeaponDamage, sprint = remfolder.Misc.SprintingToggle}
for name, remote in next, remotes do
    remotes[name] = function(...)
        if remote:IsA("RemoteEvent") then remote:FireServer(...) end
        if remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end
end

local GetMagnitude = function(object)
    object = (object:IsA("Model") and object:GetModelCFrame()) or object
    local success, result = pcall(function() return (LocalPlayer.Character:GetModelCFrame().Position - object.Position).Magnitude end)
    return (success and result) or math.huge
end

local GetAttribute = function(obj, attribute)
    local attributes = obj:FindFirstChild("Attributes")
    if attributes and attributes:FindFirstChild(attribute) then
        return true, attributes:FindFirstChild(attribute).Value
    end
    return false, nil
end

local ESP = ImportESP()
if workspace:FindFirstChild("Enemies") then
    ESP:AddObjectListener(workspace.Enemies, {
        Type = "Model",
        PrimaryPart = "HumanoidRootPart",
        CustomName = function(obj) return tostring(obj.Name) end,
        Color = ESP.Presets.Red,
        Validator = function(obj)
            return obj:FindFirstChild("Attributes") == true
        end,
        IsEnabled = "MobEsp"
    })
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
    Name = "Enemies",
    Function = function(callback)
        ESP.MobEsp = callback
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
    Name = "Tracers",
    Function = function(callback)
        ESP.Tracers = callback
    end
})

local AntiDetect = {Enabled = false}
AntiDetect = Utility.CreateOptionsButton({
    Name = "AntiDetect",
    Function = function() end,
    HoverText = "Makes it so enemies cannot detect you."
})
local old
old = hookmetamethod(game, "__namecall", function(...)
    local A, B, C = ...
    local D = {...}
    if A.Name == "SetTarget" and D[2] == LocalPlayer.Character and Settings.Target then D[3] = "Passive" .. D[3] end 
    return old(...)
end)

local KillAura = {Enabled = false}
local KAPlayers = {Enabled = true}
local KAEnemies = {Enabled = true}
KillAura = Combat.CreateOptionsButton({
    Name = "KillAura",
    Function = function(callback)
        if callback then
            repeat wait()
                if KAPlayers.Enabled then
                    for _, v in next, Players:GetPlayers() do
                        if v.Character and GetMagnitude(v.Character) < 10 then
                            remotes.attack(0, LocalPlayer.Character, v.Character, "{\"Level\":2,\"Name\":\"Old Dagger\"}", "Slash")
                        end
                    end
                end
                if KAEnemies.Enabled and workspace:FindFirstChild("Enemies") then
                    for _, v in next, workspace.Enemies:GetChildren() do
                        local has, value = GetAttribute(v, "Health")
                        if has and value ~= 0 and GetMagnitude(v) < 10 then
                            remotes.attack(0, LocalPlayer.Character, v, "{\"Level\":2,\"Name\":\"Old Dagger\"}", "Slash")
                        end
                    end
                end
            until not KillAura.Enabled
        end
    end
})
KAPlayers = KillAura.CreateToggle({
    Name = "Players",
    Function = function() end,
    Default = true
})
KAEnemies = KillAura.CreateToggle({
    Name = "Enemies",
    Function = function() end,
    Default = true
})

local InfiniteJump = {Enabled = false}
InfiniteJump = World.CreateOptionsButton({
    Name = "InfiniteJump",
    Function = function(callback) end
})
Services.UserInputService.JumpRequest:Connect(function()
    local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if InfiniteJump.Enabled and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local AutoSprint = {Enabled = false}
AutoSprint = World.CreateOptionsButton({
    Name = "AutoSprint",
    Function = function(callback)
        if callback then
            repeat wait(1)
                local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid then if Humanoid.WalkSpeed < 17 then remotes.sprint() end end
            until not AutoSprint.Enabled
        end
    end
})

local AntiExhaust = {Enabled = false}
AntiExhaust = World.CreateOptionsButton({
    Name = "AntiExhaust",
    Function = function(callback) end
})
local old2
old2 = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if tostring(self) == "ExhaustionToggle" and AntiExhaust.Enabled and method == "FireServer" and args[1] == true then args[1] = false end
    return old2(self, unpack(args))
end))
