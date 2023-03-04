local game, workspace, wait, spawn, string, math, table = game, workspace, task.wait, task.spawn, string, math, table
local tfind = function(t, v)
	for _, val in next, t do
		if val == v then
			return val
		end
	end
end

local cloneref = cloneref or function(...) return ... end
local Services = {
    Players = cloneref(game:GetService("Players")),
    Workspace = cloneref(game:GetService("Workspace")),
    CoreGui = cloneref(game:GetService("CoreGui")),
    ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage")),
    RunService = cloneref(game:GetService("RunService")),
    HttpService = cloneref(game:GetService("HttpService")),
    UserInputService = cloneref(game:GetService("UserInputService")),
    InsertService = cloneref(game:GetService("InsertService"))
}
local GetService = game.GetService
setmetatable(Services, {
    __index = function(self, name)
        local suc, result = pcall(GetService, game, name)
        if suc then
            local res = cloneref(result)
            Services[name] = res
            return res
        end
        return nil
    end,
    __mode = "v"
})

local globals = {
    game = game, workspace = workspace, wait = task.wait, spawn = task.spawn,
    tfind = tfind, gsub = string.gsub, sub = string.sub, random = math.random, find = string.find, lower = string.lower, gmatch = string.gmatch, match = string.match,
    insert = table.insert, remove = table.remove, cwrap = coroutine.wrap, split = string.split, format = string.format, upper = string.upper,
    clamp = math.clamp, round = math.round, heartbeat = Services.RunService.Heartbeat, renderstepped = Services.RunService.RenderStepped,
    LocalPlayer = Services.Players.LocalPlayer
}
setfenv(1, setmetatable(globals, {__index = getfenv(1)}))

local ConnectionsCache = {}
local LoadURL = function(url) return loadstring(game:HttpGet(url))() end
local creatingInstance = Instance.new
local firetouched = {}
local networkownertick = tick()
local PressedKeyCache = {}
local GetKeyName = function(input)
	return split(tostring(input), ".")[3]
end
local GetStringFromKeyCode = function(input)
	return globals.filter(Enum.KeyCode:GetEnumItems(), function(_, v)
		return Services.UserInputService:GetStringForKeyCode(v) == input and v
	end)[1]
end
Services.UserInputService.InputBegan:Connect(function(input, processed)
	if not processed then
		if find(tostring(input.UserInputType), "MouseButton") then
			input = GetKeyName(input.UserInputType)
			PressedKeyCache[input] = true
			PressedKeyCache[gsub(input, "MouseButton", "MB")] = true
			return
		end
		input = GetKeyName(input.KeyCode)
		PressedKeyCache[input] = true
	end
end)
Services.UserInputService.InputEnded:Connect(function(input, processed)
	if not processed then
		if find(tostring(input.UserInputType), "MouseButton") then
			input = GetKeyName(input.UserInputType)
			PressedKeyCache[input] = false
			PressedKeyCache[gsub(input, "MouseButton", "MB")] = false
			return
		end
		PressedKeyCache[GetKeyName(input.KeyCode)] = false
	end
end)

globals.Services = Services
globals.LoadURL = LoadURL
globals.RandomString = function() return sub(gsub(Services.HttpService:GenerateGUID(false), "-", ""), 1, random(25, 30)) end
globals.IsKeyDown = function() return PressedKeyCache end
globals.filter = function(tbl, func)
    local new = {}
    for i, v in next, tbl do
        if func(i, v) then
            new[#new + 1] = v
        end
    end
    return new
end
globals.map = function(tbl, func)
    local new = {}
    for i, v in next, tbl do
        local k, x = func(i, v)
        new[x or #new + 1] = k
    end
    return new
end
globals.merge = function(...)
    local new = {}
    for i, v in next, {...} do
        for _, v2 in next, v do
            new[i] = v2
        end
    end
    return new
end
globals.cons = {}
globals.cons.add = function(name, con, func)
	if not func then
		func = con
		con = name
		name = globals.RandomString()
	end
	ConnectionsCache[name] = con:Connect(func)
	return ConnectionsCache[name]
end
globals.cons.remove = function(name)
	if type(name) == "table" then
		for _, connection in next, name do
			if ConnectionsCache[connection] then
				ConnectionsCache[connection]:Disconnect()
				ConnectionsCache[connection] = nil
			end
		end
	else
		if ConnectionsCache[name] then
			ConnectionsCache[name]:Disconnect()
			ConnectionsCache[name] = nil
		end
	end
end
globals.cons.wipe = function()
	for i, v in next, ConnectionsCache do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
			ConnectionsCache[i] = nil
		end
	end
end
globals.NewInstance = function(class, properties)
    local new = creatingInstance(class)
    for property, value in next, properties do
        new[property] = value
    end
    return new
end
globals.maid = LoadURL("https://raw.githubusercontent.com/Alteral323/v/main/libs/maid.lua")
globals.signal = LoadURL("https://raw.githubusercontent.com/Alteral323/v/main/libs/signal.lua")
globals.GetCharacter = function(player)
	player = player or LocalPlayer
	return player and player.Character
end
globals.GetHumanoid = function(character)
	character = character or globals.GetCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end
globals.GetBackpack = function(player)
	player = player or LocalPlayer
	return player and player:FindFirstChildOfClass("Backpack")
end
globals.GetRoot = function(character)
	character = character or globals.GetCharacter()
	return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso"))
end
globals.GetMagnitude = function(player)
	local root, root2 = globals.GetRoot(), globals.GetRoot(globals.GetCharacter(player))
	return player and (root and root2 and (root2.Position - root.Position).magnitude) or math.huge
end
globals.sethiddenproperty = sethiddenproperty or set_hidden_property or set_hidden_prop
globals.gethiddenproperty = gethiddenproperty or get_hidden_property or get_hidden_prop
globals.setsimulationradius = setsimulationradius or set_simulation_radius
globals.request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
globals.queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
globals.gethui = get_hidden_gui or gethui
globals.setclipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
globals.isfile = isfile or (readfile and function(...)
    local success, _ = pcall(readfile, ...)
    return success
end)
globals.cleanfile = function(str)
    return gsub(str, "[*\\?:<>|]+", "")
end
globals.getconnections = getconnections or get_signal_cons
globals.setthreadidentity = (syn and syn.set_thread_identity) or setthreadidentity or syn_context_set or setthreadcontext
globals.getthreadidentity = (syn and syn.get_thread_identity) or getthreadidentity or syn_context_get or getthreadcontext
globals.getnamecallmethod = getnamecallmethod or get_namecall_method or function()
    return ""
end
globals.getrawmetatable = getrawmetatable or (debug and debug.getmetatable) or function()
    return setmetatable({}, {})
end
globals.checkcaller = checkcaller or function()
    return false
end
globals.newcclosure = newcclosure or function(f)
    return f
end
globals.setreadonly = setreadonly or (make_writeable and function(tbl, readonly)
    if readonly then
        make_readonly(tbl)
    else
        make_writeable(tbl)
    end
end)
globals.isreadyonly = isreadonly or is_readonly
globals.getscriptclosure = getscriptclosure or get_script_function
globals.getgc = getgc or get_gc_objects
globals.getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals
globals.getconstants = (debug and debug.getconstants) or getconstants or getconsts
globals.setupvalue = (debug and debug.setupvalue) or setupvalue or setupval
globals.setconstant = (debug and debug.setconstant) or setconstant or setconst
globals.getinfo = (debug and (debug.getinfo or debug.info)) or getinfo
globals.hookfunction = hookfunction or function(func, newfunc, applycclosure)
    if replaceclosure then
        replaceclosure(func, newfunc)
        return func
    end
    func = applycclosure and globals.newcclosure or newfunc
    return func
end
globals.hookmetamethod = hookmetamethod or (globals.hookfunction and function(object, method, hook)
    return globals.hookfunction(globals.getrawmetatable(object)[method], hook)
end)
globals.firetouchinterest = firetouchinterest or function(part1, part2, toggle)
    if part1 and part2 then
        if toggle == 0 then
            firetouched[1] = part1.CFrame
            part1.CFrame = part2.CFrame
        else
            part1.CFrame = firetouched[1]
            firetouched[1] = nil
        end
    end
end
globals.isnetworkowner = isnetworkowner or function(part)
    if globals.gethiddenproperty(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Manual then 
        globals.sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
        networkownertick = tick() + 8
    end
    return networkownertick <= tick()
end
globals.getcustomasset = getsynasset or getcustomasset or function(location)
    return "rbxasset://" .. location
end
globals.isexecutorclosure = isexecutorclosure or is_synapse_function
globals.cloneref = cloneref
local GarbageCollectorChecks = {
    ["function"] = function(Obj, Data) 
        local Name, Constants, Upvalues, IgnoreSyn = (Data.Name), (Data.Constants or {}), (Data.Upvalues or {}), ((Data.IgnoreSyn == nil) or (Data.IgnoreExec == nil)) and true or false
        local ObjName, ObjConstants, ObjUpvalues, ObjIsSyn = (globals.getinfo(Obj).name), (islclosure(Obj) and globals.getconstants(Obj) or {}), (globals.getupvalues(Obj) or {}), (globals.isexecutorclosure(Obj))

        if IgnoreSyn and ObjIsSyn then
            return false
        end

        if Name and ObjName and Name ~= ObjName then
            return false
        end

        for _, v in next, Constants do
            if not tfind(ObjConstants, v) then
                return false
            end
        end

        for _, v in next, Upvalues do
            if not tfind(ObjUpvalues, v) then
                return false
            end
        end

        return true
    end,
    ["table"] = function(Obj, Data) 
        local Keys, Values, KeyValuePairs, Metatable = (Data.Keys or {}), (Data.Values or {}), (Data.KeyValuePairs or {}), (Data.Metatable or {})

        local ObjMetatable = globals.getrawmetatable(Obj)
        if ObjMetatable then
            for i, v in next, ObjMetatable do
                if (Metatable[i] ~= v) then
                    return false
                end
            end
        end

        for _, v in next, Keys do
            if not Obj[v] then
                return false
            end
        end

        for _, v in next, Values do
            if not tfind(Obj, v) then
                return false
            end
        end

        for i, v in next, KeyValuePairs do
            local Other = Obj[i]
            if Other ~= v then
                return false
            end
        end

        return true
    end,
}
globals.filtergc = filtergc or (globals.getgc and function(Type, Data, One)
    local Results = {}
    for _, v in next, globals.getgc(true) do
        if type(v) == Type then
            if GarbageCollectorChecks[Type](v, Data) then
                if One then
                    return v
                end
                insert(Results, v)
            end
        end
    end
    return Results
end)
globals.ImportESP = function()
    local ESP = LoadURL("https://raw.githubusercontent.com/Alteral323/v/main/libs/esp.lua")
    ESP:Toggle(false)
    ESP.Players = false
    ESP.Tracers = false
    ESP.Boxes = false
    ESP.Names = false
    ESP.Color = ESP.Presets.Green
    return ESP
end

--[[
setfenv(1, setmetatable(loadstring(game:HttpGet("https://raw.githubusercontent.com/Alteral323/v/main/libs/compat.lua"))()("/"), {__index = getfenv(1)}))
]]

globals.sandbox = function(url, custom)
    if url == "/" then return globals end
    if type(url) ~= "string" and url == true then
        local genv = (getgenv and getgenv()) or _G
        for i, v in pairs(globals) do
            genv[i] = v
        end
        return {}
    end
    if custom and type(custom) == "string" then globals.GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alteral323/v/main/libs/ui.lua"))()(custom) end
    local module = (shared.VapeDeveloperMode and assert(loadstring(readfile("vape-v4/CustomModules/" .. custom .. ".lua")))) or assert(loadstring(game:HttpGet(url)))
    shared.VapeDeveloperMode = nil
    setfenv(module, setmetatable(globals, {__index = getfenv(1)}))
    return module() or {}
end

return globals.sandbox
