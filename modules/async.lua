local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local StarterGui = Services.StarterGui

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Utility = GuiLibrary.ObjectsThatCanBeSaved.UtilityWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
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

local ChangeSetting = ReplicatedStorage.ChangeSetting
local CamerabobSetting = LocalPlayer.LocalPlayerSettings.CamerabobEnabled
local ArrestClient = ReplicatedStorage.ArrestSystem:WaitForChild("AntiReset")
local BlindUI = LocalPlayer:FindFirstChildWhichIsA("PlayerGui").Blind

local NoCameraBob = {Enabled = false}
NoCameraBob = World.CreateOptionsButton({
    Name = "NoCameraBob",
    Function = function(callback)
        ChangeSetting:FireServer({
            Setting = "CamerabobEnabled",
            SetValue = not callback
        })
    end
})
CamerabobSetting:GetPropertyChangedSignal("Value"):Connect(function()
    if NoCameraBob.Enabled and CamerabobSetting.Value == true then
        ChangeSetting:FireServer({
            Setting = "CamerabobEnabled",
            SetValue = false
        })
    end
end)

local AntiArrest = {Enabled = false}
AntiArrest = Utility.CreateOptionsButton({
    Name = "AntiArrest",
    Function = function(callback)
        StarterGui:SetCore("ResetButtonCallback", true)
    end,
    HoverText = "Enables the reset button when you get arrested."
})
ArrestClient.OnClientEvent:Connect(function()
    if AntiArrest.Enabled then
        wait()
        StarterGui:SetCore("ResetButtonCallback", true)
    end
end)

local AntiBlind = {Enabled = false}
AntiBlind = Utility.CreateOptionsButton({
    Name = "AntiBlind",
    Function = function(callback) end,
    HoverText = "Removes the black box."
})
BlindUI:GetPropertyChangedSignal("Enabled"):Connect(function()
    if AntiBlind.Enabled and BlindUI.Enabled == true then
        BlindUI.Enabled = false
    end
end)
