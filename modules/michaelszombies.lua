local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local ESP = ImportESP()

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
    end
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

local Knife = ReplicatedStorage.Framework.Remotes.KnifeHitbox
local sort = table.sort

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

local KnifeAura = {Enabled = false}
local KillAuraRange = {Value = 100}
local MonsterInRange = function()
    local alive = filter(workspace.Ignore.Zombies:GetChildren(), function(_, v) return v:FindFirstChildWhichIsA("Humanoid") and v:FindFirstChildWhichIsA("Humanoid").Health > 0 and GetRoot(v) end)
    local magnitudes = map(alive, function(_, v) return {v, (GetRoot(v).CFrame.p - GetRoot().CFrame.p).Magnitude} end)
    local valid = filter(magnitudes, function(_, v) return v[2] <= KillAuraRange.Value end)
    sort(valid, function(a, b) return a[2] < b[2] end)
    return #valid ~= 0 and valid[1][1]
end
KnifeAura = Combat.CreateOptionsButton({
    Name = "KnifeAura",
    Function = function(callback)
        if callback then
            spawn(function()
                repeat wait(0.1)
                    local target = MonsterInRange()
                    if target then Knife:FireServer(target:FindFirstChildWhichIsA("Humanoid")) end
                until not KnifeAura.Enabled
            end)
        end
    end,
    HoverText = "Stabs monsters close enough"
})
KillAuraRange = KnifeAura.CreateSlider({
    Name = "Range",
    Min = 80,
    Max = 200,
    Function = function() end,
    Default = 100
})

local AutoCollect = {Enabled = false}
local MAutoCollect = maid.new()
AutoCollect = World.CreateOptionsButton({
    Name = "AutoCollect",
    Function = function(callback)
        if callback then
            MAutoCollect:GiveTask(workspace.Ignore._Powerups.ChildAdded:Connect(function(powerup)
                if GetRoot() then
                    firetouchinterest(GetRoot(), powerup, 0)
                end
            end))
        else
            MAutoCollect:DoCleaning()
        end
    end,
    HoverText = "Auto collects powerups"
})
