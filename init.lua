local supported = {
    [3647333358] = "evade",
    [3104101863] = "michaelszombies",
    [2534724415] = "liberty",
    [6832382283] = "redbox",
    [9256427353] = "async",
    [2686500207] = "abd",
    [9000622508] = "mosacademy",
    [11346342371] = "memesinyourbasement",
    [1180269832] = "arcaneodyssey",
    [3398014311] = "restauranttycoon2",
    [8657766101] = "marvellousplayground"
}
local modules = "https://raw.githubusercontent.com/Alteral323/v/main/modules/"
local compat = "https://raw.githubusercontent.com/Alteral323/v/main/libs/compat.lua"
local exists = supported[game.PlaceId] or supported[game.GameId]
if exists then
    local sandbox = loadstring(game:HttpGet(compat))()
    sandbox(modules .. exists .. ".lua", exists)
    shared.VapeManualLoad = true
end
