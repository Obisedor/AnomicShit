local function SendMessageEMBED(url, embed)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title or "",
                ["description"] = embed.description or "",
            }
        }
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end


local TargetVehicle = "Caddy"
local TowTruck = game.Workspace.PlayerVehicles["Tow Truck"]

local Events = game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events")
local LP = game.Players.LocalPlayer

local Vehicles = {}

for i, v in pairs(game.Workspace.PlayerVehicles:GetChildren()) do
    if v.Name == TargetVehicle then
        Vehicles[v] = {
            Locked = v.VehicleSeat.CarLocked.Value,
            LockDebounce = false
        }
    end
    if v.VehicleSeat.CarLocked.Value then
        Events.LockCar:FireServer(v)
    end
end

task.wait(1.5)

while true do
    for i, v in pairs(Vehicles) do
        if not v.Locked and not v.LockDebounce then
            local Failed
            local FailedSpot

            Events.EnterVehicle:FireServer(i, "FrontLeft")
            print("Enter the target vehicle")
            repeat task.wait() until LP.Character.Humanoid.SeatPart task.wait(.15)

            LP.Character.Humanoid.SeatPart.Parent:SetPrimaryPartCFrame(CFrame.new(431, -4, -1777))
			task.wait(.05)
            LP.Character.Humanoid.SeatPart.Parent:SetPrimaryPartCFrame(CFrame.new(431, -4, -1777))
            print("Teleport the target vehicle to the road")
            wait(0.65)

            LP.Character.Humanoid.Jump = true
            repeat task.wait() until not LP.Character.Humanoid.SeatPart
            print("Get out of the target vehicle")
            wait(0.1)

            LP.Character.HumanoidRootPart.CFrame = CFrame.new(395, -2, -1786)
            print("teleport HRP to tow truck")
            wait(1.5)
            Events.GetTowingTool:FireServer(TowTruck)
            print("get tow tool")
            repeat task.wait() until LP.Character:FindFirstChild("Tow Car")

            local Timeout = 0
            Events.TowCar:FireServer(TowTruck, "Tow", i)
            print("tow")
            repeat task.wait(.05) Timeout = Timeout + .05 until i.VehicleSeat.Towed.Value and TowTruck.VehicleSeat.TowingVehicle.Value or Timeout >= 1
            if Timeout >= 1 then Failed = true FailedSpot = "Towing" end

            local Timeout = 0
            Events.TowCar:FireServer(TowTruck, "Release", i)
            print("release")
            repeat task.wait(.05) Timeout = Timeout + .05 until not i.VehicleSeat.Towed.Value and not TowTruck.VehicleSeat.TowingVehicle.Value or Timeout >= 1 task.wait(.05)
            if Timeout >= 1 then Failed = true FailedSpot = "Release" end

            if not Failed then
                v.Locked = true
                v.LockDebounce = true
                Events.LockCar:FireServer(i)
                task.spawn(function() task.wait(1.5) v.Locked = false v.LockDebounce = false end)
            else
                SendMessageEMBED("https://discord.com/api/webhooks/1341709504924094474/7i0_3-5ZZWEPO-V0DoTAFIosXUCNnjhVbWIKq7co-OgARmRodD8-8ICg5d5XNpPQSTzr", {Title = "ERROR", Description = "Error occured in: " .. FailedSpot or "unknown"})
            end
        end
    end
	task.wait()
end
