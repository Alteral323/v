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

local PlayerData = ReplicatedStorage.PlayerData[LocalPlayer.Name]
local LocalHealth = PlayerData.Health.Value
local Remotes = {
    TakeItem = ReplicatedStorage.Remotes.TakeItem,
    UseItem = ReplicatedStorage.Remotes.UseItem,
    ObtainCrowbar = ReplicatedStorage.Remotes.SelectCrow,
    PayBully = ReplicatedStorage.Remotes.PayBully,
    ObtainKey = ReplicatedStorage.Remotes.Key
}

local AutoHeal = {Enabled = false}
AutoHeal = Utility.CreateOptionsButton({
    Name = "AutoHeal",
    Function = function(callback) end
})

PlayerData.Health:GetPropertyChangedSignal("Value"):Connect(function()
    if LocalHealth <= PlayerData.Health.Value then
        LocalHealth = PlayerData.Health.Value
    end
    if LocalHealth > PlayerData.Health.Value then
        if AutoHeal.Enabled then
            Remotes.TakeItem:FireServer("Chicken")
            wait(0.9)
            local HasChicken = PlayerData.Items:FindFirstChild("Chicken")
            if HasChicken then
                Remotes.UseItem:FireServer(HasChicken)
            end
        end
        LocalHealth = PlayerData.Health.Value
    end
end)

local GetKeys = {Enabled = false}
GetKeys = Utility.CreateOptionsButton({
    Name = "GetKeys",
    Function = function(callback)
        if callback then
            GetKeys.ToggleButton(false)
            Remotes.ObtainKey:FireServer("GreenKey")
            Remotes.ObtainKey:FireServer("BlueKey")
            Remotes.ObtainKey:FireServer("RedKey")
        end
    end
})

local Money = {Enabled = false}
Money = Utility.CreateOptionsButton({
    Name = "Money",
    Function = function(callback)
        if callback then
            Money.ToggleButton(false)
            for _ = 1, 30 do
                Remotes.TakeItem:FireServer("Money")
            end
        end
    end
})

local Food = {Enabled = false}
Food = Utility.CreateOptionsButton({
    Name = "Food",
    Function = function(callback)
        if callback then
            Food.ToggleButton(false)
            for _ = 1, 30 do
                Remotes.TakeItem:FireServer("Chicken")
            end
        end
    end
})

local Bully = {Enabled = false}
Bully = World.CreateOptionsButton({
    Name = "PayBully",
    Function = function(callback)
        if callback then
            Bully.ToggleButton(false)
            for _ = 1, 20 do
                Remotes.TakeItem:FireServer("Money")
            end
            Remotes.PayBully:FireServer()
        end
    end
})

local Crowbar = {Enabled = false}
Crowbar = Combat.CreateOptionsButton({
    Name = "Crowbar",
    Function = function(callback)
        if callback then
            Crowbar.ToggleButton(false)
            Remotes.ObtainCrowbar:FireServer()
        end
    end
})

local Slingshot = {Enabled = false}
Slingshot = Combat.CreateOptionsButton({
    Name = "Slingshot",
    Function = function(callback)
        if callback then
            Slingshot.ToggleButton(false)
            Remotes.TakeItem:FireServer("Slingshot")
        end
    end
})

local Batterup = {Enabled = false}
Batterup = Combat.CreateOptionsButton({
    Name = "Bat",
    Function = function(callback)
        if callback then
            Batterup.ToggleButton(false)
            Remotes.TakeItem:FireServer("Bat")
        end
    end
})

local Hammer = {Enabled = false}
Hammer = Combat.CreateOptionsButton({
    Name = "Hammer",
    Function = function(callback)
        if callback then
            Hammer.ToggleButton(false)
            Remotes.TakeItem:FireServer("Hammer")
        end
    end
})

local Medkit = {Enabled = false}
Medkit = Utility.CreateOptionsButton({
    Name = "Medkit",
    Function = function(callback)
        if callback then
            Medkit.ToggleButton(false)
            Remotes.TakeItem:FireServer("Medkit")
        end
    end
})
