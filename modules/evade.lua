local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local ESP = ImportESP()
ESP.Color = ESP.Presets.Green

ESP:AddObjectListener(workspace, {
    Type = "Model",
    Recursive = true,
    PrimaryPart = "HumanoidRootPart",
    CustomName = function(obj)
        return tostring(obj.Name)
    end,
    Color = ESP.Presets.Red,
    Validator = function(obj)
        return obj:GetAttribute("AI") and obj:GetAttribute("AI") == true
    end,
    IsEnabled = "nextbotEsp"
})

local NextbotESP = Render.CreateOptionsButton({
    Name = "ESP",
    Function = function(callback)
        ESP:Toggle(callback)
    end
})
NextbotESP.CreateToggle({
    Name = "Players",
    Function = function(callback)
        ESP.Players = callback
    end,
    Default = true
})
NextbotESP.CreateToggle({
    Name = "Nextbots",
    Function = function(callback)
        ESP.nextbotEsp = callback
    end,
    Default = true
})
NextbotESP.CreateToggle({
    Name = "Boxes",
    Function = function(callback)
        ESP.Boxes = callback
    end,
    Default = true
})
NextbotESP.CreateToggle({
    Name = "Nametags",
    Function = function(callback)
        ESP.Names = callback
    end,
    Default = true
})
NextbotESP.CreateToggle({
    Name = "Tracers",
    Function = function(callback)
        ESP.Tracers = callback
    end
})

local Respawn
Respawn = Utility.CreateOptionsButton({
    Name = "Respawn",
    Function = function(callback)
        if callback then
            ReplicatedStorage.Events.Respawn:FireServer()
            Respawn.ToggleButton(false)
        end
    end
})

local AutoRespawn = {Enabled = false}
AutoRespawn = Utility.CreateOptionsButton({
    Name = "AutoRespawn",
    Function = function(callback)
        if callback then
            local debounce = false
            spawn(function()
                repeat wait(1)
                    if not debounce and LocalPlayer and LocalPlayer:FindFirstChildWhichIsA("PlayerGui") then
                        local PlayerGui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
                        if PlayerGui:FindFirstChild("Respawn") and PlayerGui.Respawn:FindFirstChild("RequireRevival") then
                            if PlayerGui.Respawn.RequireRevival.Visible then
                                debounce = true
                                ReplicatedStorage.Events.Reset:FireServer()
                                wait(2)
                                ReplicatedStorage.Events.Respawn:FireServer()
                                wait(2)
                                debounce = false
                            end
                        end
                    end
                until not AutoRespawn.Enabled
            end)
        end
    end
})

local SlipperyFloor
SlipperyFloor = World.CreateOptionsButton({
    Name = "SlipperyFloor",
    Function = function(callback)
        if callback then
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Movement") then
                setconstant(require(LocalPlayer.Character.Movement).ApplyFriction, 9, 0.1)
            else
                SlipperyFloor.ToggleButton(false)
            end
        else
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Movement") then
                setconstant(require(LocalPlayer.Character.Movement).ApplyFriction, 9, 5)
            end
        end
    end,
    HoverText = "Makes the floor slippery"
})
