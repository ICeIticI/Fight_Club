local Character_Block = {}
Character_Block.__index = Character_Block

local ModuleLoader

local function regenStamina(characterInstance) --[[ Will regenerate stamina, if not doing so already. ]]
    if not Character_Block.isRegening then
        Character_Block.isRegening = true
        while (not characterInstance.BlockStartAnimPlaying and not characterInstance.holdingBlock) and characterInstance.stamina.Value < 100 do
            characterInstance.stamina.Value += (Character_Block.regenRate * characterInstance.finalStatValues.staminaRegenRate.Value)
            -- staminaBar.Size = UDim2.new(staminaBar.Size.X.Scale, staminaBar.Size.X.Offset, self.characterInstance.stamina/100 * staminaFrameLabel.Size.Y.Scale, staminaBar.Size.Y.Offset)
            task.wait(0.1)
        end
        Character_Block.isRegening = false
    end
end

local function drainStamina(characterInstance, trackData) --[[ Function that will drain stamina, depending on whether or not they're blocking in some way. ]]
    if trackData.AnimationId == ModuleLoader.AnimationInstances.FC_BlockStart.AnimationId then
        -- On block start, we just take a one-time chunk of stamina
        if characterInstance.stamina.Value - Character_Block.blockCost >= 0 then -- If a block occurs when they have less then 10 stamina, then the size of the green bar will not disappear but keep going
            characterInstance.stamina.Value -= Character_Block.blockCost
        else
            characterInstance.stamina.Value = 0
        end

    else
        -- On holding block, we continuously drain their stamina until they stop blocking
        while characterInstance.holdingBlock and characterInstance.stamina.Value > 0 do
            characterInstance.stamina.Value -= (Character_Block.drainRate * characterInstance.finalStatValues.staminaDrainRate.Value)
            task.wait(0.1)
        end
        characterInstance:block(false)
    end
end

function Character_Block.init()

    ModuleLoader = require(game:GetService("ReplicatedStorage").Shared.ModuleLoader)

    Character_Block.blockStart_trackData = {}
    Character_Block.blockStart_trackData.Animation = ModuleLoader.AnimationInstances.FC_BlockStart
    Character_Block.blockStart_trackData.AnimationId = Character_Block.blockStart_trackData.Animation.AnimationId
    Character_Block.blockStart_trackData.IsPlaying = false

    Character_Block.block_trackData = {} -- pre-defined block data for when we need to play the block animation and manage its data
    Character_Block.block_trackData.Animation = ModuleLoader.AnimationInstances.FC_Block
    Character_Block.block_trackData.AnimationId = Character_Block.block_trackData.Animation.AnimationId
    Character_Block.block_trackData.IsPlaying = false

    Character_Block.drainRate = 1 -- how much stamina gets drained per wait()
    Character_Block.regenRate = 1 -- how much stamina gets regenerated per wait()


    Character_Block.blockCost = 5
    Character_Block.isRegening = false -- Gets set to true when the character's stamina is regenerating, so it doesn't stack

end

function Character_Block:enable() --[[ Raise our guard and prepare to get hit ]]
    
    if not self.characterInstance.isBlocking and not Character_Block.blockStart_trackData.IsPlaying then -- blockStart
        self.characterInstance.isBlocking = true
        Character_Block.blockStart_trackData.IsPlaying = true
        self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockStartAnimation")
        self.characterInstance.manageAnimation(Character_Block.blockStart_trackData)
        self.characterInstance.BlockStartAnimPlaying = true
        self.characterInstance.humanoid.WalkSpeed /= 1.5

        drainStamina(self.characterInstance, Character_Block.blockStart_trackData)
    else -- block
        if not Character_Block.block_trackData.IsPlaying then
            Character_Block.block_trackData.IsPlaying = true
            self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockAnimation")
            self.characterInstance.manageAnimation(Character_Block.block_trackData)
            drainStamina(self.characterInstance, Character_Block.block_trackData)
        end
    end
end

function Character_Block:disable() --[[ Drop our guard ]]
    self.characterInstance.isBlocking = false    
    self.characterInstance.holdingBlock = false
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "stopBlockingAnimation")
    
    if Character_Block.blockStart_trackData.IsPlaying then
        Character_Block.blockStart_trackData.IsPlaying = false
        self.characterInstance.manageAnimation(Character_Block.blockStart_trackData)
        task.wait(0.2)
    end
    if Character_Block.block_trackData.IsPlaying then
        Character_Block.block_trackData.IsPlaying = false
        self.characterInstance.manageAnimation(Character_Block.block_trackData)
    end
    
    if not self.characterInstance.isGettingHit then
        self.characterInstance.SetSpeed(true)
    end

    regenStamina(self.characterInstance)
end

return Character_Block