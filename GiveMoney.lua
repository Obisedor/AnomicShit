local TargetPlayer = game.Players:FindFirstChild("Username")
local Amount = 10 -- In millions

if not TargetPlayer then 
    print("-----------------------")
    error("Target player not found")
    print("-----------------------")
    return
end

local Events = game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events")

local AmountLeft = Amount * 1000000
local TimeLeft = (math.roof(AmountLeft / 250000)) * 1.025
while true do
    if AmountLeft == 0 then return end
    local AmountToGive
    if AmountLeft <= 250000 then
        AmountToGive = 250000
    else
        AmountToGive = AmountLeft
    end
    AmountLeft = AmountLeft - AmountToGive
    TimeLeft = TimeLeft - 10.25
    Events.GiveMoneyToPlr:FireServer(TargetPlr, AmountToGive)
    task.wait(10.25)
end
