local IDs = {
    [3647333358] = "evade",
    [3104101863] = "michaelszombies"
}
local modules = "https://raw.githubusercontent.com/Alteral323/v/main/modules/"
local compat = "https://raw.githubusercontent.com/Alteral323/v/main/libs/compat.lua"
local exists = IDs[game.GameId] or IDs[game.PlaceId]
if exists then
    local sandbox = loadstring(game:HttpGet(compat))()
    sandbox(modules .. exists .. ".lua", exists)
    shared.VapeManualLoad = true
end
