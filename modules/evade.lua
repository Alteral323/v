local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local uilib = loadstring(game:HttpGet("https://raw.githubusercontent.com/3dbfeuh/v/main/ui.lua"))()("Evade")
local Utility = uilib.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = uilib.ObjectsThatCanBeSaved.WorldWindow.Api
local ESP = ImportESP()
ESP:AddObjectListener(workspace.Game.Players, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    CustomName = function(obj)
        return tostring(obj.Name)
    end,
    Color = Color3.fromRGB(255, 0, 128),
    Validator = function(obj)
        if obj:FindFirstChild("StatChanges") or obj:FindFirstChild("HRP") then
            return true
        end
        return false
    end,
    IsEnabled = "nextbotEsp"
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

local SlipperyFloor
SlipperyFloor = World.CreateOptionsButton({
    Name = "SlipperyFloor",
    Function = function(callback)
        if callback then
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Movement") then
                local applyFriction = require(LocalPlayer.Character.Movement).ApplyFriction
                setconstant(applyFriction, 9, 0.1)
            else
                SlipperyFloor.ToggleButton(false)
            end
        else
            if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Movement") then
                local applyFriction = require(LocalPlayer.Character.Movement).ApplyFriction
                setconstant(applyFriction, 9, 5)
            end
        end
    end,
    HoverText = "Makes the floor slippery"
})

shared.VapeManualLoad = true
