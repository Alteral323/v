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
local sethid = sethiddenproperty or set_hidden_property or set_hidden_prop
local gethid = gethiddenproperty or get_hidden_property or get_hidden_prop
local setsim = setsimulationradius or set_simulation_radius
local newcc = newcclosure or function(f)
	return f
end
local firetouched = {}
local networkownertick = tick()
local oldpairs = pairs
local globals = {
	Services = Services,
	LoadURL = LoadURL,
	sethiddenproperty = sethid,
	gethiddenproperty = gethid,
	setsimulationradius = setsim,
	request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request,
	queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport),
	gethui = get_hidden_gui or gethui,
	setclipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set),
	isfile = isfile or (readfile and function(...)
		local success, _ = pcall(readfile, ...)
		return success
	end),
	cleanfile = function(str)
		return gsub(str, "[*\\?:<>|]+", "")
	end,
	getconnections = getconnections or get_signal_cons,
	setthreadidentity = (syn and syn.set_thread_identity) or setthreadidentity or syn_context_set or setthreadcontext,
	getthreadidentity = (syn and syn.get_thread_identity) or getthreadidentity or syn_context_get or getthreadcontext,
	getnamecallmethod = getnamecallmethod or get_namecall_method or function()
		return ""
	end,
	getrawmetatable = getrawmetatable or function()
		return setmetatable({}, {})
	end,
	checkcaller = checkcaller or function()
		return false
	end,
	newcclosure = newcc,
	setreadonly = setreadonly or (make_writeable and function(tbl, readonly)
		if readonly then
			make_readonly(tbl)
		else
			make_writeable(tbl)
		end
	end),
	isreadyonly = isreadonly or is_readonly,
	getscriptclosure = getscriptclosure or get_script_function,
	getgc = getgc or get_gc_objects,
	wait = task.wait,
	spawn = task.spawn,
	getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals,
	getconstants = (debug and debug.getconstants) or getconstants or getconsts,
	setupvalue = (debug and debug.setupvalue) or setupvalue or setupval,
	setconstant = (debug and debug.setconstant) or setconstant or setconst,
	hookfunction = hookfunction or function(func, newfunc, applycclosure)
		if replaceclosure then
			replaceclosure(func, newfunc)
			return func
		end
		func = applycclosure and newcc or newfunc
		return func
	end,
	firetouchinterest = firetouchinterest or function(part1, part2, toggle)
		if part1 and part2 then
			if toggle == 0 then
				firetouched[1] = part1.CFrame
				part1.CFrame = part2.CFrame
			else
				part1.CFrame = firetouched[1]
				firetouched[1] = nil
			end
		end
	end,
	isnetworkowner = isnetworkowner or function(part)
		if gethid(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Manual then 
			sethid(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
			networkownertick = tick() + 8
		end
		return networkownertick <= tick()
	end,
	getcustomasset = getsynasset or getcustomasset or function(location)
		return "rbxasset://" .. location
	end,
	isexecutorclosure = isexecutorclosure or is_synapse_function,
	pairs = function(tbl, func)
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
}
globals.sandbox = function(url, custom)
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
