return function(save)
    if not isfolder("vape") then
        makefolder("vape")
    end
    if not isfolder("vape/Profiles") then
        makefolder("vape/Profiles")
    end
    if not isfolder("vape/Profiles/3dbfeuh") then
        makefolder("vape/Profiles/3dbfeuh")
    end
    shared.VapeIndependent = true
    shared.CustomSaveVape = "3dbfeuh/" .. save
    local GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua"))()
    task.spawn(function()
        for _, v in pairs(GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Object:GetChildren()) do
            if v.Name == "SettingsWheel" and v.Position ~= UDim2.new(1, -25, 0, 14) then
                v.Visible = false
            end
        end
        GuiLibrary.ObjectsThatCanBeSaved["Blur BackgroundToggle"].Api.ToggleButton(false, true)
        GuiLibrary.Settings.GUIObject.Color = 0.4424818827466613
        GuiLibrary.UpdateUI()
    end)
    return GuiLibrary
end
