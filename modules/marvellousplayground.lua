local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local TeleportService = Services.TeleportService
local RunService = Services.RunService
local Mouse = LocalPlayer:GetMouse()

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
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

local sort = table.sort
local Combo = ReplicatedStorage.Characters.Combat.Remotes.Combo
local Adrenaline = ReplicatedStorage.Characters.TheBatman.Remotes.AdShotRemote

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

local KillAura = {Enabled = false}
local KillAuraRange = {Value = 15}

local ClosetEnemy = function()
    local available = map(filter(Players:GetPlayers(), function(_, v) return v ~= LocalPlayer end), function(_, v) return v.Character end)
    local alive = filter(available, function(_, v) return v:FindFirstChildWhichIsA("Humanoid") and v:FindFirstChildWhichIsA("Humanoid").Health > 0 end)
    local magnitudes = map(alive, function(_, v) return {v, (GetRoot(v).CFrame.p - GetRoot().CFrame.p).Magnitude} end)
    local valid = filter(magnitudes, function(_, v) return v[2] <= KillAuraRange.Value end)
    sort(valid, function(a, b) return a[2] < b[2] end)
    return #valid ~= 0 and valid[1][1]
end

KillAura = Combat.CreateOptionsButton({
    Name = "KillAura",
    Function = function(callback)
        if callback then
            repeat wait()
                pcall(function()
                    local enemy = ClosetEnemy()
                    if enemy then Combo:FireServer(enemy) end
                end)
            until not KillAura.Enabled
        end
    end
})
KillAuraRange = KillAura.CreateSlider({
    Name = "Range",
    Min = 0,
    Max = 250,
    Default = 15,
    Function = function() end
})

local AutoHeal = {Enabled = false}
local AutoHealDelay = {Value = 4}
AutoHeal = Combat.CreateOptionsButton({
    Name = "AutoHeal",
    Function = function(callback) if callback then repeat wait(AutoHealDelay.Value) pcall(function() Adrenaline:FireServer(LocalPlayer) end) until not AutoHeal.Enabled end end
})
AutoHealDelay = AutoHeal.CreateSlider({
    Name = "Delay",
    Min = 0,
    Max = 60,
    Default = 4,
    Function = function() end
})
