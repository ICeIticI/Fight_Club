--[[

* This script causes the character to block in some way to mitigate damage.

* The character can do a bracing block, which is when they block right
  before an attack lands, and makes them 'brace' when the attack lands

* They can also do a synced block, which is when they are holding the
  block button and the character and enemy do syncronized animations
  of them attacking/blocking

]]

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local Block = {}
Block.__index = Block


local function getAttackerSyncBlockLevel2()
  if GameVariables.animPair and GameVariables.animPair[1] == 1 then
    if GameVariables.animPair and GameVariables.animPair[2] == 1 then
      return GameVariables.FC_SyncBlock3L1TRACK
    elseif GameVariables.animPair and GameVariables.animPair[2] == 2 then
      return GameVariables.FC_SyncBlock3L2TRACK
    end
  elseif GameVariables.animPair and GameVariables.animPair[1] == 2 then
    if GameVariables.animPair and GameVariables.animPair[2] == 1 then
      return GameVariables.FC_SyncBlock3R1TRACK
    elseif GameVariables.animPair and GameVariables.animPair[2] == 2 then
      return GameVariables.FC_SyncBlock3R2TRACK
    end
  end
end

local function getReceiverSyncBlockLevel1()
  if GameVariables.pairedBlock == GameVariables.FC_SyncBlock1LRECEIVERTRACK then
    return GameVariables.FC_SyncBlock1RRECEIVERTRACK
  elseif GameVariables.pairedBlock == GameVariables.FC_SyncBlock1RRECEIVERTRACK then
    return GameVariables.FC_SyncBlock1LRECEIVERTRACK
  elseif GameVariables.pairedBlock == GameVariables.FC_SyncBlock2LRECEIVERTRACK then
    return GameVariables.FC_SyncBlock2RRECEIVERTRACK
  elseif GameVariables.pairedBlock == GameVariables.FC_SyncBlock2RRECEIVERTRACK then
    return GameVariables.FC_SyncBlock2LRECEIVERTRACK
  end
end

local function getReceiverSyncBlockLevel2(sentAnimPair)
  if sentAnimPair and sentAnimPair[1] == 1 then
    if sentAnimPair and sentAnimPair[2] == 1 then
      return GameVariables.FC_SyncBlock3L1RECEIVERTRACK
    elseif sentAnimPair and sentAnimPair[2] == 2 then
      return GameVariables.FC_SyncBlock3L2RECEIVERTRACK
    end
  elseif sentAnimPair and sentAnimPair[1] == 2 then
    if sentAnimPair and sentAnimPair[2] == 1 then
      return GameVariables.FC_SyncBlock3R1RECEIVERTRACK
    elseif sentAnimPair and sentAnimPair[2] == 2 then
      return GameVariables.FC_SyncBlock3R2RECEIVERTRACK
    end
  end
end

local function getRandomLeftLevel1(sentAnimPair)
  if (sentAnimPair and sentAnimPair[2] == 1) or (GameVariables.animPair and GameVariables.animPair[2] == 1) then
    GameVariables.pairedAttack = GameVariables.FC_SyncBlock1LTRACK
    GameVariables.pairedBlock = GameVariables.FC_SyncBlock1LRECEIVERTRACK
  elseif (sentAnimPair and sentAnimPair[2] == 2) or (GameVariables.animPair and GameVariables.animPair[2] == 2) then
    GameVariables.pairedAttack = GameVariables.FC_SyncBlock2LTRACK
    GameVariables.pairedBlock = GameVariables.FC_SyncBlock2LRECEIVERTRACK
  end
end

local function getRandomRightLevel1(sentAnimPair)
  if (sentAnimPair and sentAnimPair[2] == 1) or (GameVariables.animPair and GameVariables.animPair[2] == 1) then
    GameVariables.pairedAttack = GameVariables.FC_SyncBlock1RTRACK
    GameVariables.pairedBlock = GameVariables.FC_SyncBlock1RRECEIVERTRACK
  elseif (sentAnimPair and sentAnimPair[2] == 2) or (GameVariables.animPair and GameVariables.animPair[2] == 2) then
    GameVariables.pairedAttack = GameVariables.FC_SyncBlock2RTRACK
    GameVariables.pairedBlock = GameVariables.FC_SyncBlock2RRECEIVERTRACK
  end
end

local function getAttackerSyncBlockLevel1()
  if GameVariables.pairedAttack == GameVariables.FC_SyncBlock1LTRACK then
    return GameVariables.FC_SyncBlock1RTRACK
  elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock1RTRACK then
    return GameVariables.FC_SyncBlock1LTRACK
  elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock2LTRACK then
    return GameVariables.FC_SyncBlock2RTRACK
  elseif GameVariables.pairedAttack == GameVariables.FC_SyncBlock2RTRACK then
    return GameVariables.FC_SyncBlock2LTRACK
  end
end

local function reposition()
  			GameVariables.currentAttack = GameVariables.pairedAttack.Animation
			
			if GameVariables.distanceBetween ~= 3 then -- we want the sync to happen at three studs ideally
				local enemyRoot = GameVariables.raycastResult.Instance.Parent.HumanoidRootPart
				
				local direction = enemyRoot.Position - GameVariables.humanoidRootPart.Position -- the direction toward the enemy from the player
				local normalizedDirection = direction.Unit -- makes the unit measuring toward the player equal to 1. It is the |absolute value|
				
				local tweenPart = GameVariables.character:WaitForChild("HumanoidRootPart")

				local Info = TweenInfo.new(

					0.2,
					Enum.EasingStyle.Linear,
					Enum.EasingDirection.Out,
					0,
					false,
					0

				)

				local tweenGoals = {}
				
				tweenGoals.CFrame = CFrame.new(enemyRoot.Position - normalizedDirection * 3) * CFrame.Angles(GameVariables.humanoidRootPart.CFrame:ToOrientation())
																							    -- This above basically makes the player maintain the same orientation.
				local repositionTween = game:GetService("TweenService"):Create(tweenPart, Info, tweenGoals)
				repositionTween:Play()
			end
				
			GameVariables.pairedAttack:Play()
			GameVariables.canFollowUp = true -- once the paired attack starts, the player can immediately follow up (when the animation ends that is)
			
		--end
		-- player will play their part of the synched block while the enemy does theirs.

end

function Block:brace(currentAttack)
  GameVariables.canSyncBlock = false -- Trying to get this to dictate if receiving plr can sync block
	if currentAttack:GetAttribute("AnimDirection") == "Left" then
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockRTRACK -- If the enemy threw an attack to the left, then we brace right since their left is our right
	elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_BracingBlockLTRACK
	end
end

function Block:sync(sentAnimPair, followupCombo)
  warn(followupCombo)
	if GameVariables.pairedChain <= GameVariables.PairedChainMAX and GameVariables.canSyncBlock then
		if followupCombo and followupCombo > 1 or (GameVariables.pairedBlock and GameVariables.pairedBlock.IsPlaying) then -- For followup attacks
			
      if GameVariables.pairedAttack and GameVariables.pairedAttack.IsPlaying then -- runs for the attacker
			GameVariables.pairedAttack:Stop()
			if followupCombo == 3 then -- We want to get the level 2 sync block attack
				GameVariables.pairedAttack = getAttackerSyncBlockLevel2()
			else -- then get us a level 1 sync block attack
				GameVariables.pairedAttack = getAttackerSyncBlockLevel1()
			end
				
			elseif GameVariables.pairedBlock and GameVariables.pairedBlock.IsPlaying then -- runs for the receiver
				GameVariables.pairedBlock:Stop()
				if followupCombo == 3 then
					GameVariables.pairedBlock = getReceiverSyncBlockLevel2(sentAnimPair)
				else
					GameVariables.pairedBlock = getReceiverSyncBlockLevel1()
				end
			end
				
		
		else -- for non-followup attacks
			if (sentAnimPair and sentAnimPair[1] == 1) or (GameVariables.animPair and GameVariables.animPair[1] == 1) then
				getRandomLeftLevel1(sentAnimPair)
			elseif (sentAnimPair and sentAnimPair[1] == 2) or (GameVariables.animPair and GameVariables.animPair[1] == 2) then
				getRandomRightLevel1(sentAnimPair)
			end
		end
		
		GameVariables.pairedPlaying = true
	
		-- if not GameVariables.isBlocking then
		-- 	GameVariables.previousWalkSpeed = GameVariables.lockOnSpeed
		-- elseif GameVariables.isBlocking then
		-- 	GameVariables.previousWalkSpeed = GameVariables.lockOnSpeed / 1.5
		-- end
		
		-- GameVariables.humanoid.WalkSpeed = 0
		GameVariables.SetSpeed(false)
		if GameVariables.isBlocking then
			GameVariables.pairedBlock:Play()
		
		elseif GameVariables.pairedAttack and not GameVariables.isBlocking then -- Script breaks if pairedAttack doesn't exist, so we need to add it in as a check.
      reposition()
		end
	end
end

return Block