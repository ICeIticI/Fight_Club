local ReceiveCommand = {}

local GameVariables = require(game.ReplicatedStorage.Shared.GameVariables)

local block = require(game.ReplicatedStorage.Shared.receiving.block)
local dodge = require(game.ReplicatedStorage.Shared.receiving.dodge)
local receiveCounter = require(game.ReplicatedStorage.Shared.receiving.receiveCounter)
local receiveDodgeAttack = require(game.ReplicatedStorage.Shared.receiving.receiveDodgeAttack)
local receiveGrapple = require(game.ReplicatedStorage.Shared.receiving.receiveGrapple)
local receiveStrike = require(game.ReplicatedStorage.Shared.receiving.receiveStrike)

local function getHit(currentAttack) --[[ Will result in the character getting hit by an attack in some way ]]
	local currentAttackID = currentAttack.AnimationId -- currentAttack is what the enemy is throwing. It's an animation, not a animationTrack

	
	if currentAttackID == GameVariables.FC_LeftHook1.AnimationId or currentAttackID == GameVariables.FC_LeftJab.AnimationId then -- left reaction, should check for other lvl 1 lefts
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHook1RECEIVERTRACK
	elseif currentAttackID == GameVariables.FC_RightHook1.AnimationId or currentAttackID == GameVariables.FC_RightJab.AnimationId then -- right reaction, same above for rights here
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHook1RECEIVERTRACK
	elseif currentAttackID == GameVariables.FC_LeftUppercut.AnimationId then
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftUppercutRECEIVERTRACK
	elseif currentAttackID == GameVariables.FC_RightUppercut.AnimationId then
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightUppercutRECEIVERTRACK
	elseif currentAttackID == GameVariables.FC_RightHaymaker.AnimationId then
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightHaymakerReceiverTRACK
	elseif currentAttackID == GameVariables.FC_LeftHaymaker.AnimationId then
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftHaymakerRECEIVERTRACK
	end
end

local function parry(currentAttack) --[[ Function that will cause the character to do a parry animation, which should play when the enemy attacks right as they press block. ]]
	
	if currentAttack:GetAttribute("AnimDirection") == "Left" then -- perform a left parry animation that will send to the server to damage the enemy slightly, and also make them do an animation in reaction.
		warn("ParryL")
		-- The parry direction must be reversed. If the enemy throws a left punch, then the player, facing them, has their left and right swapped. The enemy's left is the player's right, and vice versa. So, these have to be switched. Same goes for receiver parry animations.
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightParryTRACK -- If the enemy threw an attack to the left, then we brace right since their left is our right
	elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
		warn("ParryR")
		GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftParryTRACK
	end
	local Protocol = "Parry"

	GameVariables.GlobalRemoteEvent:FireServer(GameVariables.enemyChar, Protocol, currentAttack)

end

local function counter(currentAttack) --[[ Function that fires when the character counters the enemy ]]
	-- We also only want the player to be able to counter when they're not doing a followup attack.
			
	task.wait()
	if not (GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying) then				
		
		GameVariables.isCountering = true
		GameVariables.randAttack:Stop()
		
		if currentAttack:GetAttribute("AnimDirection") == "Left" then -- Left counter
			--GameVariables.currentReceiveAnimTRACK = GameVariables.FC_LeftCounter1TRACK -- Make a 'Left Counters' table and randomize the left countering tracks to get a left counter.
			GameVariables.currentReceiveAnimTRACK = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Left", "Counter", true)
		elseif currentAttack:GetAttribute("AnimDirection") == "Right" then -- Right counter
			-- GameVariables.currentReceiveAnimTRACK = GameVariables.FC_RightCounter1TRACK -- Make a 'Right Counters' table, containing all the right counter tracks and randomize when countering from the right here.
			GameVariables.currentReceiveAnimTRACK = GameVariables.randomAnimationTrack(GameVariables.pairedAttacksTable, "AnimDirection", "Right", "Counter", true)
		end
		-- GameVariables.randAttack = GameVariables.currentReceiveAnimTRACK
		-- GameVariables.currentAttack = GameVariables.currentReceiveAnimTRACK.Animation -- we also want to classify the counter as a currentattack so the basicStriking module will see it as an attack and be able to send to the server for damage.
		
	end
end


function ReceiveCommand:CallReceive(currentAttack, Protocol, sentAnimPair, sentValue) --[[ Method used to find out what reaction the character should do based on what attack the enemy did. ]]

		if Protocol == "Receive" then
			
			if GameVariables.currentReceiveAnimTRACK and GameVariables.currentReceiveAnimTRACK.IsPlaying then
				GameVariables.currentReceiveAnimTRACK:Stop()
			end
			
			if not GameVariables.isBlocking then -- Receiving attack (not blocking)
				if GameVariables.FC_BlockStartTRACK.IsPlaying then -- if the player gets hit while the blockstart track is playing, then they will perform a parry
					parry(currentAttack)
				elseif GameVariables.Protocol ~= "Counter" and GameVariables.randAttack and GameVariables.randAttack.IsPlaying and not GameVariables.currentAttack:GetAttribute("Counter") and not GameVariables.isCountering and not GameVariables.canFollowUp and not GameVariables.attackFrames and not GameVariables.isGettingHit then -- if the player is just starting an attack before the attack frames come in and gets hit by an enemy, then they will counter them.
					counter(currentAttack)
				elseif not GameVariables.isCountering then  -- the blockStart track is not playing, therefore its not a parry:
					getHit(currentAttack)
				end
		
			elseif GameVariables.isBlocking then -- Bracing block
				block:brace(currentAttack)
			end

			if GameVariables.currentReceiveAnimTRACK then
				GameVariables.currentReceiveAnimTRACK:Play()
		
				if GameVariables.currentReceiveAnimTRACK.Animation:GetAttribute("Counter") and not (GameVariables.currentReceiveAnimTRACK == GameVariables.FC_RightParryTRACK or GameVariables.currentReceiveAnimTRACK == GameVariables.FC_LeftParryTRACK) then -- Makes sure this is a counter animation and not a parry animation
					-- When countering, we want to change the position of the player character to be a fixed amount of studs away from the enemy
					GameVariables.character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(GameVariables.enemyChar:WaitForChild("HumanoidRootPart").Position + GameVariables.enemyChar.HumanoidRootPart.CFrame.LookVector * 3 , GameVariables.enemyChar.HumanoidRootPart.Position) -- The comma turns the CFrame.New() function into a Positional function AND a Orientational function, by setting the position and also using CFrame.LookAt() with the comma.
				end
			end

		elseif Protocol == "AttackStarted" then -- if the enemy is starting an attack, and the player is blocking, perform a synched block.
			print(sentValue)
			if GameVariables.isBlocking and GameVariables.canSyncBlock and GameVariables.humanoid.MoveDirection.Magnitude > 0 then -- the player is moving
				
			
				-- If the player is moving and HOLDING block, they can dodge the incoming enemy attack
				print("can dodge")
				local forwardVector = GameVariables.character.HumanoidRootPart.CFrame.LookVector -- The front direction of the character
				local forwardDotProduct = GameVariables.humanoid.MoveDirection:Dot(forwardVector) -- forwardDotProduct will return a value it compares from where the character is facing. If its > 0, then its forward, if its < 0, then its backwards.
				
				if forwardDotProduct < 0 then -- character is moving backwards
					dodge:back()
				--elseif forwardDotProduct > 0 then -- character is moving forwards
					-- I dont know if we will have a "foward" dodge, but it's here if we want to add it.
				else
					local rightVector = GameVariables.character.HumanoidRootPart.CFrame.RightVector -- the right side of where the character's facing
					local rightDotProduct = GameVariables.humanoid.MoveDirection:Dot(rightVector) -- rightDotProduct, like forwardDotProduct, will return a value it compares from the right side of where the character's facing. > 0 is right, < 0 is left.

					if rightDotProduct > 0 then -- character is moving right
						print("right dodge")
						dodge:right()
					elseif rightDotProduct < 0 then -- character is moving left
						print("left dodge")
						dodge:left()
					end
				end
				
				
			elseif GameVariables.isBlocking and GameVariables.canSyncBlock then -- the player is not moving and will perform a sync block.
				-- GameVariables.synchedBlock(sentAnimPair, sentValue)
				block:sync(sentAnimPair, sentValue)
			end
		elseif Protocol == "HoldingBlock" then
			GameVariables.isEnemyHoldingBlock = sentValue

		elseif Protocol == "Parry" then
			-- if the enemy parried the player, then they will do a reaction to what direction the enemy 
			GameVariables.randAttack:Stop()
			-- if the enemy parried to the left, the player's right hand will repelled, and vice versa.
			if currentAttack:GetAttribute("AnimDirection") == "Left" then
				GameVariables.FC_RightParryRECEIVERTRACK:Play()
			elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
				GameVariables.FC_LeftParryRECEIVERTRACK:Play()
			end
			
		elseif Protocol == "Counter" and not (GameVariables.FC_LeftCounter1RECEIVERTRACK.IsPlaying or GameVariables.FC_RightCounter1RECEIVERTRACK.IsPlaying) then
			GameVariables.randAttack:Stop()

			if currentAttack:GetAttribute("AnimDirection") == "Left" then
				-- if the enemy countered to the left, the player's right hand will be countered on, and vice versa.
				receiveCounter:left(currentAttack)
			elseif currentAttack:GetAttribute("AnimDirection") == "Right" then
				receiveCounter:right(currentAttack)
			end
		end
	--elseif isAI == true then
		
end

function ReceiveCommand:CallBlock(input) --[[ Method that will perform the logical checks before executing the actual blocking code in another module ]]
    if input.UserInputType == Enum.UserInputType.MouseButton2 
	and GameVariables.lockOnDebounce.Value 
	and GameVariables.boolCheck({GameVariables.isAttacking, GameVariables.isBlocking, GameVariables.isCountering}) 
	and not GameVariables.pairedPlaying then -- blocking/dodging  
		-- GameVariables.isBlocking = true -- work on this. It interferes with parrying.
		GameVariables.FC_BlockStartTRACK:Play()
		GameVariables.humanoid.WalkSpeed /= 1.5 -- add the GameVariables.SetSpeed() function here when ready!!!
	end
end

function ReceiveCommand:CallEndBlock(input) --[[ Method that is called when the player stops blocking, which will do the logical checks and then the actual blocking code in another script. ]]
    if input.UserInputType == Enum.UserInputType.MouseButton2 
	and (GameVariables.FC_BlockStartTRACK.IsPlaying or GameVariables.FC_BlockTRACK.IsPlaying) 
	and not GameVariables.pairedPlaying then
		GameVariables.isBlocking = false
		GameVariables.FC_BlockStartTRACK:Stop()
		GameVariables.FC_BlockTRACK:Stop()
		GameVariables.SetSpeed(true)
	end
end

return ReceiveCommand