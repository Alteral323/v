local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local ESP = ImportESP()

local CharAdded = function(char)
    if char:FindFirstChild("HRP") then
        return
    end
    local p = Players:FindFirstChild(char.Name)
    if not p or p == Players.LocalPlayer then
        return
    end
    ESP:Add(char, {
        Name = p.Name,
        Player = p,
        PrimaryPart = char.HumanoidRootPart,
        IsEnabled = "plrEsp",
        Color = ESP.Presets.Green
    })
end
workspace.Game.Players.ChildAdded:Connect(CharAdded)
for i,v in pairs(workspace.Game.Players:GetChildren()) do
    coroutine.wrap(CharAdded)(v)
end

ESP:AddObjectListener(workspace.Game.Players, {
    Type = "Model",
    PrimaryPart = "HumanoidRootPart",
    CustomName = function(obj)
        return tostring(obj.Name)
    end,
    Color = ESP.Presets.Red,
    Validator = function(obj)
        return obj:FindFirstChild("HRP")
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
        ESP.plrEsp = callback
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
