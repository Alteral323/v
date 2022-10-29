local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local RunService = Services.RunService
local UserInputService = Services.UserInputService

local Render = GuiLibrary.ObjectsThatCanBeSaved.RenderWindow.Api
local Combat = GuiLibrary.ObjectsThatCanBeSaved.CombatWindow.Api
local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api
local Blatant = GuiLibrary.ObjectsThatCanBeSaved.BlatantWindow.Api
local ESP = ImportESP()

ESP.Overrides.GetColor = function(character)
    local player = ESP:GetPlrFromChar(character)
    return player and player.TeamColor.Color or ESP.Color
end

local NewESP = Render.CreateOptionsButton({
    Name = "ESP",
    Function = function(callback)
        ESP:Toggle(callback)
    end
})
NewESP.CreateToggle({
    Name = "Players",
    Function = function(callback)
        ESP.Players = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Boxes",
    Function = function(callback)
        ESP.Boxes = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Nametags",
    Function = function(callback)
        ESP.Names = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Health",
    Function = function(callback)
        ESP.Health = callback
    end,
    Default = true
})
NewESP.CreateToggle({
    Name = "Tracers",
    Function = function(callback)
        ESP.Tracers = callback
    end
})

local SilentAim = {Enabled = false}
local SilentBlacklist = {Friends = false, Mafia = false}
SilentAim = Combat.CreateOptionsButton({
    Name = "SilentAim",
    Function = function() end
})
SilentAim.CreateToggle({
    Name = "Ignore Friends",
    Function = function(callback)
        SilentBlacklist.Friends = callback
    end
})
SilentAim.CreateToggle({
    Name = "Ignore Mafia",
    Function = function(callback)
        SilentBlacklist.Mafia = callback
    end
})

local CarSpeed = {Enabled = false}
CarSpeed = World.CreateOptionsButton({
    Name = "CarSpeed",
    HoverText = "Hold LeftShift while driving to multiply the car's velocity.",
    Function = function(callback) end
})

local fates do
    local oldwait = wait
    getgenv().wait = function() end
    local copy = function(tbl)
        local copy = {}
        for i, v in pairs(tbl) do
            copy[i] = v
        end
        return copy
    end
    local env = copy(getfenv())
    setmetatable(env, {
        __index = function(self, i)
            if rawget(env, i) then
                return rawget(env, i)
            elseif getfenv()[i] then
                return getfenv()[i]
            end
        end
    })
    env.game = nil
    local src = game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"):gsub("local ExecuteCommand =", "ExecuteCommand =")
    src = src:gsub("_L.CLI = false", "ConnectionStuff = Connections\n_L.CLI = false")
    src = src:gsub("Utils.MatchSearch =", "Utils.Notify = function() return {Message = {Text = \"\"}} end\nUtils.MatchSearch =")
    src = src:gsub("AddConnection(CConnect(Services.UserInputService.InputBegan, ", "local bruhhh = function(f) return f end\nbruhhh(bruhhh(")
    setfenv(loadstring(src), env)()
    for _, v in pairs(env.ConnectionStuff.UI) do
        if typeof(v) == "RBXScriptConnection" then
            v:Disconnect()
        end
    end
    fates = function(c) env.ExecuteCommand(c, {}, LocalPlayer) end
    getgenv().wait = oldwait
end

local Noclip = {Enabled = false}
Noclip = Blatant.CreateOptionsButton({
    Name = "Noclip",
    Function = function(callback)
        fates(callback and "noclip" or "unnoclip")
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if Noclip.Enabled then
        fates("noclip")
    end
end)

local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local isIgnored = function(player)
    if SilentBlacklist.Friends and player:IsFriendsWith(LocalPlayer.UserId) then
        return true
    end
    if SilentBlacklist.Mafia and LocalPlayer:FindFirstChild("Mafia") and player:FindFirstChild("Mafia") and player.Mafia.Value == LocalPlayer.Mafia.Value then
        return true
    end
    return false
end
local Enemy = false
local Teams = {Police = true, Sheriff = true, Civilian = true}
local ClosetEnemy = function()
    if SilentAim.Enabled then
        local MousePos = Vector2.new(Mouse.X, Mouse.Y)
        local mindist = math.huge
        local valid = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and LocalPlayer.Character and not isIgnored(v) and Teams[v.Team.name] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid") and v.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local vector, onScreen = Camera:WorldToScreenPoint(v.Character:FindFirstChild("HumanoidRootPart").Position)
                local Distance = (MousePos - Vector2.new(vector.X, vector.Y)).Magnitude
                if onScreen and Distance < mindist then
                    mindist = Distance
                    Enemy = v
                    valid[#valid + 1] = true
                end
            end
        end
        if #valid == 0 then
            Enemy = false
        end
    end
end
RunService:BindToRenderStep("Silent Aim", 120, ClosetEnemy)
local hook
hook = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {hook(self, ...)}
    if not checkcaller() and getcallingscript().name == "Core" and getnamecallmethod() == "ViewportPointToRay" then
        coroutine.wrap(function()
            if SilentAim.Enabled and Enemy then
                args[1] = Ray.new(args[1].Origin, CFrame.lookAt(args[1].Origin, Enemy.Character.Head.position).lookVector)
            end
        end)()
    end
    return unpack(args)
end)

local keydown = UserInputService.IsKeyDown
local kc = Enum.KeyCode.LeftShift
local kc2 = Enum.KeyCode.S
RunService.Heartbeat:Connect(function(delta)
    local k0down = keydown(UserInputService, kc)
    local k1down = keydown(UserInputService, kc2)
    if CarSpeed.Enabled and (k0down or k1down) then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
        if typeof(Humanoid) == "Instance" and typeof(Humanoid.RootPart) == "Instance" and typeof(Humanoid.SeatPart) == "Instance" then
            local rootpart = Humanoid.RootPart
            local seatpart = Humanoid.SeatPart
            local diff = 1 + 3 * delta
            if k0down and not k1down then
                seatpart.AssemblyLinearVelocity *= Vector3.new(diff, 1, diff)
            elseif k1down and not k0down then
                seatpart.AssemblyLinearVelocity /= Vector3.new(diff, 1, diff)
            end
        end
    end
end)
