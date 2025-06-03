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


function Character_Block:enable() --[[ Raise our guard and prepare to get hit ]]
    
    if not self.characterInstance.isBlocking then -- blockStart
        blockStart_trackData.IsPlaying = true
        self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockStartAnimation")
        self.characterInstance.manageAnimation(blockStart_trackData)
        self.characterInstance.BlockStartAnimPlaying = true
        self.characterInstance.humanoid.WalkSpeed /= 1.5
    else -- block
        block_trackData.IsPlaying = true
        self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockAnimation")
        self.characterInstance.manageAnimation(block_trackData)
    end
end

function Character_Block:disable() --[[ Drop our guard ]]
    self.characterInstance.isBlocking = false
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "stopBlockingAnimation")
    if not self.characterInstance.isGettingHit then
        self.characterInstance.SetSpeed(true)
    end
end

return Character_Block