--[[

* Module that controls what the character will do after getting
  counter-attacked after getting countered by an enemy.

* Either the enemy countered their left strike, or their right one.
  So depending on what side that was, they will play a syncronized
  countered animation.

]]

local GameVariables = game.ReplicatedStorage.Shared.GameVariables

local ReceiveCounter = {}
ReceiveCounter.__index = ReceiveCounter

function ReceiveCounter:left(currentAttack) --[[ Method that controls what happens to the character after getting countered to the left ]]
  if currentAttack.AnimationId == GameVariables.FC_LeftCounter1.AnimationId then
    GameVariables.FC_LeftCounter1RECEIVERTRACK:Play()
  elseif currentAttack.AnimationId == GameVariables.FC_LeftCounter2.AnimationId then
    GameVariables.FC_LeftCounter2RECEIVERTRACK:Play()
  end
end

function ReceiveCounter:right(currentAttack) --[[ Method that controls what happens to the character after getting countered to the right ]]
  if currentAttack.AnimationId == GameVariables.FC_RightCounter1.AnimationId then
    GameVariables.FC_RightCounter1RECEIVERTRACK:Play()
  elseif currentAttack.AnimationId == GameVariables.FC_RightCounter2.AnimationId then
    GameVariables.FC_RightCounter2RECEIVERTRACK:Play()
  end
end

return ReceiveCounter