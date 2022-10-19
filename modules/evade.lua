local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
local ESP = ImportESP()

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
    Name = "Nextbots",
    Function = function(callback)
        ESP.nextbotEsp = callback
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
                        wait(2.2)
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
        return (Speed.Enabled and SpeedVal.Value) or 1450, (JumpPower.Enabled and JumpPowerVal.Value) or 3
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

--[[
local AutoBhop = {Enabled = false}
LocalPlayer.CharacterAdded:Connect(function(character)
    repeat wait() until character:FindFirstChildWhichIsA("Humanoid") == true
    local Humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid then
        Humanoid.StateChanged:Connect(function(State)
            if AutoBhop.Enabled then
                if State == Enum.HumanoidStateType.Landed then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end)
spawn(function()
    repeat wait() until LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") == true
    local Humanoid = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if Humanoid then
        Humanoid.StateChanged:Connect(function(State)
            if AutoBhop.Enabled then
                if State == Enum.HumanoidStateType.Landed then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end)
AutoBhop = Blatant.CreateOptionsButton({
    Name = "AutoBhop",
    Function = function() end
})
]]
