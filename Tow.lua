local RandomID = math.random(1, 9999999)
getgenv().ID = RandomID


local TargetVehicle = "Caddy"
local TowTruck
for i, v in pairs(game.Workspace.PlayerVehicles:GetChildren()) do
    if v.Name == "Tow Truck" then
        if v.Properties.Owner.Value.Name == game.Players.localPlayer.Name then TowTruck = v end
    end
end

local Events = game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events")
local LP = game.Players.LocalPlayer

local Vehicles = {}

for i, v in pairs(game.Workspace.PlayerVehicles:GetChildren()) do
    if v.Name == TargetVehicle and v.Properties.Owner.Value.Name ~= game.Players.LocalPlayer.Name then
        Vehicles[v] = {
            Locked = v.VehicleSeat.CarLocked.Value,
            LockDebounce = false
        }
    end
    if v.VehicleSeat.CarLocked.Value then
        Events.LockCar:FireServer(v)
    end
end

task.wait(1.25)

while true do
    for i, v in pairs(Vehicles) do
        if getgenv().ID ~= RandomID then -- Prevent double execute
            return
        end
        if i.VehicleSeat.CarLocked.Value then
            v.Locked = true
            v.LockDebounce = true
            Events.LockCar:FireServer(i)
            task.spawn(function() task.wait(1.5) v.Locked = false v.LockDebounce = false end)
        end
        if not v.Locked and not v.LockDebounce and not i.VehicleSeat.CarLocked.Value then
            local Failed
            local FailedSpot

            Events.EnterVehicle:FireServer(i, "FrontLeft") -- Enter the target vehcile as driver
            print("Enter the target vehicle", i.VehicleSeat.CarLocked.Value)
            local Timeout = 0
            repeat task.wait(.05) Timeout = Timeout + .05 until LP.Character.Humanoid.SeatPart and LP.Character.Humanoid.Sit == true and LP.Character.Humanoid.SeatPart.Parent task.wait(.05) or Timeout >= .75
			print("enterred target vehicle")

            LP.Character.Humanoid.SeatPart.Parent:SetPrimaryPartCFrame(CFrame.new(431, -4, -1777)) -- Teleport the target vehicle to the raod
			task.wait(.05)
            LP.Character.Humanoid.SeatPart.Parent:SetPrimaryPartCFrame(CFrame.new(431, -4, -1777))
            print("Teleport the target vehicle to the road")
            wait(0.5)

            local Timeout = 0 -- Exit the target vehicle
            repeat LP.Character.Humanoid.Jump = true task.wait(.05) Timeout = Timeout + .05 until Timeout >= .75 or not LP.Character.Humanoid.SeatPart and not LP.Character.Humanoid.Sit task.wait(.1)
            print("Get out of the target vehicle")
            if Timeout >= 1 then Failed = true FailedSpot = "Exit target vehicle" end

            LP.Character.HumanoidRootPart.CFrame = TowTruck.VehicleSeat.CFrame -- Teleport HRP to the tow truck
            print("teleport HRP to tow truck")
            wait(.5)
            local Timeout = 0

            Events.GetTowingTool:FireServer(TowTruck) -- Get the towing tool
            print("get tow tool")
            repeat task.wait(.05) Timeout = Timeout + .05 until LP.Character:FindFirstChild("Tow Car") or Timeout >= .75
            if Timeout >= 1 then Failed = true FailedSpot = "GetTowTool" end

            local Timeout = 0 -- Tow the target vehicle
            Events.TowCar:FireServer(TowTruck, "Tow", i)
            print("tow")
            repeat task.wait(.05) Timeout = Timeout + .05 until i.VehicleSeat.Towed.Value and TowTruck.VehicleSeat.TowingVehicle.Value or Timeout >= .75
            if Timeout >= 1 then Failed = true FailedSpot = "Towing" end

            local Timeout = 0 -- Release the target vehicle from the tow bed
            Events.TowCar:FireServer(TowTruck, "Release", i)
            print("release")
            repeat task.wait(.05) Timeout = Timeout + .05 until not i.VehicleSeat.Towed.Value and not TowTruck.VehicleSeat.TowingVehicle.Value or Timeout >= .75 task.wait(.15)
            if Timeout >= 1 then Failed = true FailedSpot = "Release" end
        end
    end
	task.wait()
end
