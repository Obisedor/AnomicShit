local TargetPlayer = ""
local Amount = 1

local Events = game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events")
local LeftAmount = Amount

repeat
    Events.GiveMoneyToPlr:FireServer()
    if LeftAmount > 250000 then
        Events.GiveMoneyToPlr:FireServer(game.Players[TargetPlayer], "250000")
        LeftAmount = LeftAmount - 250000
    else
        Events.GiveMoneyToPlr:FireServer(game.Players[TargetPlayer], tostring(LeftAmount))
        LeftAmount = 0
    end
    task.wait(12.5)
until LeftAmount == 0 
