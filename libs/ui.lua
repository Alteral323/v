return function(save, folder)
    save = save or tostring(game.PlaceId)
    folder = folder or "new"
    if not isfolder("vape") then
        makefolder("vape")
    end
    if not isfolder("vape/Profiles") then
        makefolder("vape/Profiles")
    end
    if not isfolder("vape/Profiles/" .. folder) then
        makefolder("vape/Profiles/" .. folder)
    end
    shared.VapeIndependent = true
    shared.CustomSaveVape = folder .. "/" .. save
    local GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua"))()
    task.spawn(function()
        for _, v in pairs(GuiLibrary.ObjectsThatCanBeSaved.GUIWindow.Object:GetChildren()) do
            if v.Name == "SettingsWheel" and v.Position ~= UDim2.new(1, -25, 0, 14) then
                v.Visible = false
            end
        end
        GuiLibrary.ObjectsThatCanBeSaved["Blur BackgroundToggle"].Api.ToggleButton(false, true)
        GuiLibrary.UpdateUI(0.4622395932674408, 0.9624060392379761, 0.5215686559677124, true)
    end)
    return GuiLibrary
end
