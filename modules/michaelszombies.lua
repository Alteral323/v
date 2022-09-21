local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local ESP = ImportESP()
ESP.Color = ESP.Presets.Green

ESP:AddObjectListener(workspace, {
    Type = "Model",
    Recursive = true,
    PrimaryPart = "HumanoidRootPart",
    CustomName = "Monster",
    Color = ESP.Presets.Red,
    Validator = function(obj)
        return obj.Parent == workspace.Ignore.Zombies
    end,
    IsEnabled = "Monsters"
})

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
    Name = "Monsters",
    Function = function(callback)
        ESP.Monsters = callback
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

local isNear = function(monster, dist)
    if monster:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return (LocalPlayer.Character.HumanoidRootPart.Position - monster.HumanoidRootPart.Position).Magnitude <= (dist or 30)
    end
    return false
end

local KnifeAura = {Enabled = false}
KnifeAura = Combat.CreateOptionsButton({
    Name = "KnifeAura",
    Function = function(callback)
        if callback then
            spawn(function()
                repeat wait(0.1)
                    for _, v in pairs(workspace.Ignore.Zombies:GetChildren()) do
                        if v and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChild("HumanoidRootPart") and isNear(v, 100) then
                            ReplicatedStorage.Framework.Remotes.KnifeHitbox:FireServer(v:FindFirstChildOfClass("Humanoid"))
                        end
                    end
                until not KnifeAura.Enabled
            end)
        end
    end
})

local GetRoot = function()
    local char = LocalPlayer.Character
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or {CFrame = "", Position = {X = "0", Y = "0", Z = "0"}}
end

local AutoCollect = {Enabled = false}
local collect
AutoCollect = World.CreateOptionsButton({
    Name = "AutoCollect",
    Function = function(callback)
        if callback then
            collect = workspace.Ignore._Powerups.ChildAdded:Connect(function(obj)
                if obj:FindFirstChildWhichIsA("TouchTransmitter") then
                    firetouchinterest(GetRoot(), obj:FindFirstChildWhichIsA("TouchTransmitter"), 0)
                end
            end)
        else
            collect:Disconnect()
        end
    end
})
