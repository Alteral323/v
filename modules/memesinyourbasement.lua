local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
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
    Name = "Tracers",
    Function = function(callback)
        ESP.Tracers = callback
    end
})

local Remotes = {
    Upload = ReplicatedStorage.Events.InstantUpload
}
local Teleporting = false

local GetRoot = function(char)
    char = char or LocalPlayer.Character
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local Tycoon = (function()
    for _, tycoon in pairs(workspace.Tycoons:GetChildren()) do
        if tycoon:FindFirstChild("TycoonOwner") and tycoon.TycoonOwner.Value == LocalPlayer.Name then
            return tycoon
        end
    end
end)()

local AutoUpload = {Enabled = false}
AutoUpload = Utility.CreateOptionsButton({
    Name = "AutoUpload",
    Function = function(callback)
        if callback then
            repeat wait(1.1)
                Remotes.Upload:FireServer()
            until not AutoUpload
        end
    end
})

local BypassGamepass = {Enabled = false}
BypassGamepass = Utility.CreateOptionsButton({
    Name = "BypassGamepass",
    Function = function(callback) end
})

local AutoWakeup = {Enabled = false}
AutoWakeup = World.CreateOptionsButton({
    Name = "AutoWakeup",
    Function = function(callback)
        if callback then
            repeat wait()
                local Root = GetRoot()
                if not Teleporting and Root then
                    for _, v in pairs(Tycoon.Items:GetChildren()) do
                        if v.Name ~= "Nas" and v:FindFirstChild("Sleeping") and v.Sleeping.Value == true then
                            Teleporting = true
                            local prompt = v.Noob.Torso.ProximityPrompt
                            Root.CFrame = v.Noob.PrimaryPart.CFrame + Vector3.new(0, 4, 0)
                            fireproximityprompt(prompt)
                            Teleporting = false
                        end
                    end
                end
            until not AutoWakeup.Enabled
        end
    end
})

local AutoCollect = {Enabled = false}
AutoCollect = World.CreateOptionsButton({
    Name = "AutoCollect",
    Function = function(callback)
        if callback then
            repeat wait()
                local Root = GetRoot()
                if not Teleporting and Root then
                    for num = 1, 3 do
                        local belt = Tycoon.StaticItems:FindFirstChild("Belt" .. num)
                        if belt and #Tycoon.Drops:FindFirstChild("Belt" .. num):GetChildren() > 0 then
                            Teleporting = true
                            local collect = belt.Collect.CollectPart
                            Root.CFrame = collect.CFrame + Vector3.new(0, 2, 0)
                            fireproximityprompt(collect.ProximityPrompt)
                            Teleporting = false
                        end
                    end
                end
            until not AutoCollect.Enabled
        end
    end
})

do
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if BypassGamepass.Enabled and tostring(self) == "MarketplaceService" and getnamecallmethod() == "UserOwnsGamePassAsync" then
            return true
        end
        return old(self, ...)
    end))
end
