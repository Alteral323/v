local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local Lighting = Services.Lighting

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
        return "[AI] " .. tostring(obj.Name)
    end,
    Color = ESP.Presets.Red,
    Validator = function(obj)
        return obj:GetAttribute("AI") and obj:GetAttribute("AI") == true
    end,
    IsEnabled = "nextbotEsp"
})

ESP.Overrides.GetColor = function(character)
    local player = ESP:GetPlrFromChar(character)
    if player and ESP.downedEsp and player.Character:GetAttribute("Downed") == true then
        return ESP.Presets.Blue
    end
    return ESP.Color
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
    Name = "Downed",
    Function = function(callback)
        ESP.downedEsp = callback
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

local Fullbright = Render.CreateOptionsButton({
    Name = "Fullbright",
    Function = function(callback)
        if callback then
            Lighting.Brightness = 4
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 12
        else
            if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("Lighting") and workspace.Game.Map.Lighting:FindFirstChild("Stats") then
                local stats = require(workspace.Game.Map.Lighting.Stats)
                if type(stats) == "table" then
                    for i, v in pairs(stats) do
                        Lighting[i] = v
                    end
                end
            end
        end
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
    Function = function() end
})

local SlipperyFloor = {Enabled = false}
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
        workspace.Game.Settings:SetAttribute("ReviveTime", callback and 3 or 2.2)
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

local AutoBhop = {Enabled = false}
AutoBhop = Blatant.CreateOptionsButton({
    Name = "AutoBhop",
    Function = function() end
})

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if tostring(self) == "Communicator" and method == "InvokeServer" and args[1] == "update" then
        return (Speed.Enabled and SpeedVal.Value) or 1500, (JumpPower.Enabled and JumpPowerVal.Value) or 3
    end
    return old(self, ...)
end))

if LocalPlayer.Character then
    LocalPlayer.Character:GetAttributeChangedSignal("Downed"):Connect(function()
        if LocalPlayer.Character:GetAttribute("Downed") == true and AutoRespawn.Enabled then
            ReplicatedStorage.Events.Respawn:FireServer()
        end
    end)
    if LocalPlayer.Character:FindFirstChild("Humanoid") then
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        Humanoid.StateChanged:Connect(function(State)
            if Humanoid and AutoBhop.Enabled and State == Enum.HumanoidStateType.Landed then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid", 1000)
    local Humanoid = character:FindFirstChild("Humanoid")
    if Humanoid then
        Humanoid.StateChanged:Connect(function(State)
            if Humanoid and AutoBhop.Enabled and State == Enum.HumanoidStateType.Landed then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    character:GetAttributeChangedSignal("Downed"):Connect(function()
        if character:GetAttribute("Downed") == true and AutoRespawn.Enabled then
            ReplicatedStorage.Events.Respawn:FireServer()
        end
    end)
    if SlipperyFloor.Enabled then
        character:WaitForChild("Movement", 1000)
        local movement = character:FindFirstChild("Movement")
        if movement then
            setconstant(require(movement).ApplyFriction, 9, 0.1)
        end
    end
end)
