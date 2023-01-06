local IDs = {
    [3647333358] = "evade",
    [3104101863] = "michaelszombies",
    [2534724415] = "liberty",
    [10243982775] = "redbox",
    [9256427353] = "async",
    [2686500207] = "abd",
    [9000622508] = "mosacademy"
}
local modules = "https://raw.githubusercontent.com/Alteral323/v/main/modules/"
local compat = "https://raw.githubusercontent.com/Alteral323/v/main/libs/compat.lua"
local exists = IDs[game.PlaceId] or IDs[game.GameId]
if exists then
    local sandbox = loadstring(game:HttpGet(compat))()
    sandbox(modules .. exists .. ".lua", exists)
    shared.VapeManualLoad = true
end
