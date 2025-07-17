local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local Character_Block = {}
Character_Block.__index = Character_Block

local blockStart_trackData = {}
blockStart_trackData.Animation = AnimationInstances.FC_BlockStart
blockStart_trackData.AnimationId = blockStart_trackData.Animation.AnimationId
blockStart_trackData.IsPlaying = false

local block_trackData = {} -- pre-defined block data for when we need to play the block animation and manage its data
block_trackData.Animation = AnimationInstances.FC_Block
block_trackData.AnimationId = block_trackData.Animation.AnimationId
block_trackData.IsPlaying = false

local drainRate = 1 -- how much stamina gets drained per wait()
local regenRate = 1 -- how much stamina gets regenerated per wait()


local blockCost = 5
local isRegening = false -- Gets set to true when the character's stamina is regenerating, so it doesn't stack

local function regenStamina(characterInstance) --[[ Will regenerate stamina, if not doing so already. ]]
    if not isRegening then
        isRegening = true
        while (not characterInstance.BlockStartAnimPlaying and not characterInstance.holdingBlock) and characterInstance.stamina.Value < 100 do
            characterInstance.stamina.Value += regenRate
            -- staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, self.characterInstance.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            task.wait(0.1)
        end
        isRegening = false
    end
end

local function drainStamina(characterInstance, trackData) --[[ Function that will drain stamina, depending on whether or not they're blocking in some way. ]]
    if trackData.AnimationId == AnimationInstances.FC_BlockStart.AnimationId then
        -- On block start, we just take a one-time chunk of stamina
        if characterInstance.stamina.Value - blockCost >= 0 then -- If a block occurs when they have less then 10 stamina, then the size of the green bar will not disappear but keep going
            characterInstance.stamina.Value -= blockCost
        else
            characterInstance.stamina.Value = 0
        end

    else
        -- On holding block, we continuously drain their stamina until they stop blocking
        while characterInstance.holdingBlock and characterInstance.stamina.Value > 0 do
            characterInstance.stamina.Value -= drainRate
            task.wait(0.1)
        end
        characterInstance:block(false)
    end
end


function Character_Block:enable() --[[ Raise our guard and prepare to get hit ]]
    
    if not self.characterInstance.isBlocking and not blockStart_trackData.IsPlaying then -- blockStart
        self.characterInstance.isBlocking = true
        blockStart_trackData.IsPlaying = true
        self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockStartAnimation")
        self.characterInstance.manageAnimation(blockStart_trackData)
        self.characterInstance.BlockStartAnimPlaying = true
        self.characterInstance.humanoid.WalkSpeed /= 1.5

        drainStamina(self.characterInstance, blockStart_trackData)
    else -- block
        if not block_trackData.IsPlaying then
            block_trackData.IsPlaying = true
            self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockAnimation")
            self.characterInstance.manageAnimation(block_trackData)
            drainStamina(self.characterInstance, block_trackData)
        end
    end
end

function Character_Block:disable() --[[ Drop our guard ]]
    self.characterInstance.isBlocking = false    
    self.characterInstance.holdingBlock = false
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "stopBlockingAnimation")
    
    if blockStart_trackData.IsPlaying then
        blockStart_trackData.IsPlaying = false
        self.characterInstance.manageAnimation(blockStart_trackData)
        task.wait(0.2)
    end
    if block_trackData.IsPlaying then
        block_trackData.IsPlaying = false
        self.characterInstance.manageAnimation(block_trackData)
    end
    
    if not self.characterInstance.isGettingHit then
        self.characterInstance.SetSpeed(true)
    end

    regenStamina(self.characterInstance)
end

return Character_Block