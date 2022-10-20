local Services = {
	Players = game:GetService("Players"),
	Workspace = game:GetService("Workspace"),
	CoreGui = game:GetService("CoreGui"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	RunService = game:GetService("RunService"),
	HttpService = game:GetService("HttpService"),
	UserInputService = game:GetService("UserInputService"),
	InsertService = game:GetService("InsertService")
}
setmetatable(Services, {
	__index = function(self, name)
		local suc, res = pcall(game.GetService, game, name)
		if suc then
			Services[name] = res
			return res
		end
		return nil
	end,
	__mode = "v"
})
local LoadURL = function(url)
	return loadstring(game:HttpGet(url))()
end
local gsub = string.gsub
local firetouched = {}
local networkownertick = tick()
local oldpairs = pairs
local globals = {}

globals.Services = Services
globals.LoadURL = LoadURL
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
globals.wait = task.wait
globals.spawn = task.spawn
globals.getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals
globals.getconstants = (debug and debug.getconstants) or getconstants or getconsts
globals.setupvalue = (debug and debug.setupvalue) or setupvalue or setupval
globals.setconstant = (debug and debug.setconstant) or setconstant or setconst
globals.getinfo = getinfo or (debug and (debug.getinfo or debug.info))
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
globals.pairs = function(tbl, func)
	if func and type(func) == "function" then
		local new = {}
		for i, v in next, tbl do
			if func(i, v) then
				new[#new + 1] = v
			end
		end
		return new
	else
		return oldpairs(tbl)
	end
end
globals.sandbox = function(url, custom)
	if type(url) ~= "string" and url == true then
		local genv = getgenv()
		for i, v in pairs(globals) do
			genv[i] = v
		end
		return {}
	end
	if custom and type(custom) == "string" then
		globals.GuiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alteral323/v/main/libs/ui.lua"))()(custom)
		globals.ImportESP = function()
			local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alteral323/v/main/libs/esp.lua"))()
			ESP:Toggle(false)
			ESP.Players = false
			ESP.Tracers = false
			ESP.Boxes = false
			ESP.Names = false
			ESP.Color = ESP.Presets.Green
			return ESP
		end
		globals.maid = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alteral323/v/main/libs/maid.lua"))()
		globals.signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alteral323/v/main/libs/signal.lua"))()
	end
	local module = assert(loadstring(game:HttpGet(url)))
	setfenv(module, setmetatable(globals, {__index = getfenv(1)}))
	return module() or {}
end

return globals.sandbox
