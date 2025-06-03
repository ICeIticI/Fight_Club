local AnimationInstances = require(game.ReplicatedStorage.Shared.AnimationInstances)

local Character_Block = {}
Character_Block.__index = Character_Block


function Character_Block:enable() --[[ Raise our guard and prepare to get hit ]]
    local trackData = {}
    trackData.Animation = AnimationInstances.FC_BlockStart
    trackData.AnimationId = trackData.Animation.AnimationId
    trackData.IsPlaying = true
    
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "playBlockStartAnimation")
    self.characterInstance.manageAnimation(trackData)
    self.characterInstance.BlockStartAnimPlaying = true
    self.characterInstance.humanoid.WalkSpeed /= 1.5
end

function Character_Block:disable() --[[ Drop our guard ]]
    self.characterInstance.isBlocking = false
    self.characterInstance.GlobalRemoteEvent:FireClient(self.characterInstance.player, "stopBlockingAnimation")
    if not self.characterInstance.isGettingHit then
        self.characterInstance.SetSpeed(true)
    end
end

return Character_Block