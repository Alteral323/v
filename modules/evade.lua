local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
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

ESP:AddObjectListener(workspace, {
    Type = "Model",
    Recursive = true,
    PrimaryPart = "HumanoidRootPart",
    CustomName = function(obj)
        return "[DOWNED] " .. tostring(obj.Name)
    end,
    Color = ESP.Presets.Blue,
    Validator = function(obj)
        return obj:GetAttribute("Downed") and obj:GetAttribute("Downed") == true
    end,
    IsEnabled = "downedEsp"
})
ESP.downedEsp = true

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

local NoCameraShake = {Enabled = false}
NoCameraShake = Render.CreateOptionsButton({
    Name = "NoCameraShake",
    Function = function(callback)
        if callback then
            spawn(function()
                repeat wait()
                    LocalPlayer.PlayerScripts.CameraShake.Value = CFrame.new(0, 0, 0) * CFrame.new(0, 0, 0)
                until not NoCameraShake.Enabled
            end)
        end
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
                    if not debounce and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Downed") == true then
                        debounce = true
                        ReplicatedStorage.Events.Respawn:FireServer()
                        wait(2)
                        debounce = false
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
    end
})

local FastRevive = World.CreateOptionsButton({
    Name = "FastRevive",
    Function = function(callback)
        if callback then
            workspace.Game.Settings:SetAttribute("ReviveTime", 2.2)
        else
            workspace.Game.Settings:SetAttribute("ReviveTime", 3)
        end
    end
})

local Speed = {Enabled = false}
local SpeedVal = {Value = 2900}
Speed = Blatant.CreateOptionsButton({
    Name = "Speed",
    Function = function(callback) end
})
SpeedVal = Speed.CreateSlider({
    Name = "Value",
    Min = 1450,
    Max = 12000,
    Function = function() end,
    Default = 2900
})

local JumpPower = {Enabled = false}
local JumpPowerVal = {Value = 5}
JumpPower = Blatant.CreateOptionsButton({
    Name = "JumpPower",
    Function = function(callback) end
})
JumpPowerVal = JumpPower.CreateSlider({
    Name = "Value",
    Min = 3,
    Max = 150,
    Function = function() end,
    Default = 5
})

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if tostring(self) == "Communicator" and method == "InvokeServer" and args[1] == "update" then
        if Speed.Enabled and JumpPower.Enabled then
            return SpeedVal.Value, JumpPowerVal.Value
        end
        if Speed.Enabled then
            return SpeedVal.Value, 3
        end
        if JumpPower.Enabled then
            return 1450, JumpPowerVal.Value
        end
    end
    return old(self, ...)
end))

local GlobalChat = {Enabled = false}
GlobalChat = Blatant.CreateOptionsButton({
    Name = "GlobalChat",
    Function = function(callback)
        spawn(function()
            repeat wait(0.1)
                if LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("ChatScript") then
                    LocalPlayer.PlayerScripts.ChatScript:SetAttribute("GlobalChatEnabled", true)
                end
            until not GlobalChat.Enabled
        end)
    end
})
