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
local transfer = {
	Services = Services,
	LoadURL = LoadURL,
	sethiddenproperty = sethiddenproperty or set_hidden_property or set_hidden_prop,
	gethiddenproperty = gethiddenproperty or get_hidden_property or get_hidden_prop,
	setsimulationradius = setsimulationradius or set_simulation_radius,
	httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request,
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
	newcclosure = newcclosure or function(f)
		return f
	end,
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
	spawn = task.spawn
}
transfer.sandbox = function(url)
	local module = assert(loadstring(game:HttpGet(url)))
	setfenv(module, setmetatable(transfer, {__index = getfenv(1)}))
	return module() or {}
end
return transfer.sandbox
