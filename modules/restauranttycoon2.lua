local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts
local ReplicatedStorage = Services.ReplicatedStorage

local World = GuiLibrary.ObjectsThatCanBeSaved.WorldWindow.Api

local remotes = {input = ReplicatedStorage.Events.ClientTycoonInput}
for name, remote in next, remotes do
    remotes[name] = function(...)
        if remote:IsA("RemoteEvent") then remote:FireServer(...) end
        if remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
    end
end

local Worker = require(PlayerScripts.CookingNew.WorkerComponents.WorkerDefault)
local Customers = require(PlayerScripts.ClientMain.Replications.Customers.GetNPCFolder)
local SharedCharacterComponents = ReplicatedStorage.MiscModules.CookingSharedCharacter
local OldCook = Worker.event
local NewCook = function(...)
    local args = {...}
    local npc = Customers.GetNPCFolder(args[1]).ClientWorkers:FindFirstChild(args[2])
    local Task = SharedCharacterComponents:FindFirstChild(args[4])
    if Task then require(Task).finishInteract(npc, args[3], args[4]) end
    return
end
local InstantChef = World.CreateOptionsButton({
    Name = "InstantChef",
    Function = function(callback) Worker.event = callback and NewCook or OldCook end,
    HoverText = "Removes your chefs' cook cooldown."
})

local WalkSequence = require(PlayerScripts.ClientMain.Replications.Workers.DummyWalkSequence)
local OldWalkSequence = WalkSequence.Run
local NewWalkSequence = function(data) return (data.completeCallback or task.wait)() end
local FastEmployees = World.CreateOptionsButton({
    Name = "FastEmployees",
    Function = function(callback) WalkSequence.Run = callback and NewWalkSequence or OldWalkSequence end,
    HoverText = "Makes your employees faster."
})

local AutoCollect = {Enabled = false}
local acBills = {Enabled = true}
local acDrops = {Enabled = true}
local BillsDropped = nil
local RewardDropped = nil
local Tycoon = LocalPlayer.Tycoon.Value
local Surface = Tycoon.Items.OftenFiltered.Surface
local Collect = function(obj) remotes.input(Tycoon, {name = "CollectBill", model = obj.Parent}) end
AutoCollect = World.CreateOptionsButton({
    Name = "AutoCollect",
    Function = function(callback)
        if callback then
            for _, obj in next, Surface:GetDescendants() do if obj.Name == "Bill" then Collect(obj) end end
            for _, obj in next, workspace.DropFolder:GetChildren() do
                if acDrops.Enabled then
                    pcall(function()
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                    end)
                end
            end
            BillsDropped = Surface.DescendantAdded:Connect(function(obj) if obj.Name == "Bill" then Collect(obj) end end)
            RewardDropped = workspace.DropFolder.ChildAdded:Connect(function(obj)
                if acDrops.Enabled then
                    pcall(function()
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                    end)
                end
            end)
        else
            if BillsDropped ~= nil then
                BillsDropped:Disconnect()
                BillsDropped = nil
            end
            if RewardDropped ~= nil then
                RewardDropped:Disconnect()
                RewardDropped = nil
            end
        end
    end
})
acBills = AutoCollect.CreateToggle({Name = "Bills", Function = function() end, Default = true})
acDrops = AutoCollect.CreateToggle({Name = "Drops", Function = function() end, Default = true})
