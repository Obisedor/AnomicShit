local TargetPlayer = "" -- first few characters
-- AMOUNT IN MILLIONS!
local Amount = 10

local Events = game:GetService("ReplicatedStorage"):WaitForChild("_CS.Events")
local LeftAmount = Amount * 1000000

local function findPlayerByPartialName(partialName)
    partialName = string.lower(partialName) -- Make search case-insensitive
    for _, player in ipairs(game.Players:GetPlayers()) do
        if string.sub(string.lower(player.Name), 1, #partialName) == partialName then
            return player
        end
    end
    return nil -- No matching player found
end

repeat
    Events.GiveMoneyToPlr:FireServer()
    if LeftAmount > 250000 then
        Events.GiveMoneyToPlr:FireServer(findPlayerByPartialName(TargetPlayer), "250000")
        LeftAmount = LeftAmount - 250000
    else
        Events.GiveMoneyToPlr:FireServer(findPlayerByPartialName(TargetPlayer), tostring(LeftAmount))
        LeftAmount = 0
    end
    task.wait(12.5)
until LeftAmount == 0 
