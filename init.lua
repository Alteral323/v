ocal IDs = {
    [3647333358] = "evade",
    [3104101863] = "michaelszombies",
    [2534724415] = "liberty"
}
local modules = "https://raw.githubusercontent.com/Alteral323/v/main/modules/"
local compat = "https://raw.githubusercontent.com/Alteral323/v/main/libs/compat.lua"
local exists = IDs[game.PlaceId] or IDs[game.GameId]
if exists then
    local sandbox = loadstring(game:HttpGet(compat))()
    sandbox(modules .. exists .. ".lua", exists)
    shared.VapeManualLoad = true
end
