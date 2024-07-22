local GameVariables = {}

GameVariables.player = game.Players.LocalPlayer
GameVariables.character = GameVariables.player.Character or GameVariables.player.CharacterAdded:Wait()
GameVariables.humanoid = GameVariables.character:WaitForChild("Humanoid")
GameVariables.previousHealth = GameVariables.humanoid.Health -- This var is used to determine how much damage the character takes.
GameVariables.charAnimator = GameVariables.character:WaitForChild("Humanoid"):WaitForChild("charAnimator")
GameVariables.humanoidRootPart = GameVariables.character:WaitForChild("HumanoidRootPart")
--GameVariables.attackAttri = character:GetAttribute("attackAttri")

-- character hitboxes
GameVariables.hitboxesFolder = GameVariables.character:WaitForChild(GameVariables.player.Name.."_hitboxesFolder")

GameVariables.hitboxHead = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxHead")
GameVariables.hitboxLeftArm = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxLeftArm")
GameVariables.hitboxLeftLeg = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxLeftLeg")
GameVariables.hitboxRightArm = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxRightArm")
GameVariables.hitboxRightLeg = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxRightLeg")
GameVariables.hitboxTorso = GameVariables.hitboxesFolder:WaitForChild(GameVariables.player.Name.."_hitboxTorso")

-- *Hitbox tables*
GameVariables.hitboxesFolderATTACK = {GameVariables.hitboxLeftArm, GameVariables.hitboxLeftLeg, GameVariables.hitboxRightArm, GameVariables.hitboxRightLeg}
GameVariables.hitboxesFolderRECEIVE = {GameVariables.hitboxHead, GameVariables.hitboxTorso}

-- create a table for hitboxes, then run :Connect function(s) via for loop for .Touched event and more.

GameVariables.Camera = game.Workspace.CurrentCamera
GameVariables.plrObjectsFolder = GameVariables.player:WaitForChild(GameVariables.player.Name .. "_GameObjects")

-- player remote & bindable event"
--GameVariables.remoteEvent = plrObjectsFolder:WaitForChild(player.Name.."_RemoteEvent")
--GameVariables.bindableEvent = plrObjectsFolder:WaitForChild(player.Name.."_BindableEvent")

-- Global Remote Event - Because each player having their own remote event is redundant.
GameVariables.GlobalRemoteEvent = game.ReplicatedStorage:WaitForChild("GlobalRemoteEvent")
GameVariables.LocalBindableEvent = game.ReplicatedStorage:WaitForChild("LocalBindableEvent")

GameVariables.Protocol = nil

GameVariables.walkingSpeed = 12
GameVariables.humanoid.WalkSpeed = GameVariables.walkingSpeed

-- origins
GameVariables.originalWalkSpeed = GameVariables.humanoid.WalkSpeed
GameVariables.originalCamFocus = GameVariables.Camera.Focus
GameVariables.originalCamSubject = GameVariables.Camera.CameraSubject

--bools and values
GameVariables.lockOnDebounce = Instance.new("BoolValue") -- shouldn't this be initialized by the server for more security?
GameVariables.lockOnDebounce.Name = "lockOnDebounce"
GameVariables.lockOnDebounce.Parent = GameVariables.plrObjectsFolder
GameVariables.hitDebounce = false
GameVariables.isBlocking = false
GameVariables.isAttacking = false
GameVariables.waitingToAttack = false
GameVariables.pairedPlaying = false -- used to make sure the paired animations don't play while already playing.
GameVariables.previousWalkSpeed = nil

GameVariables.lockOnSpeed = GameVariables.originalWalkSpeed / 1.85
GameVariables.attackFrames = false -- when the StartOfAttack marker fires in attack anims, this allows damage to pass
--GameVariables.attackEnded = false

GameVariables.isDodging = false
GameVariables.canFollowUp = false
GameVariables.isEnemyHoldingBlock = false -- for attacks to be synched attacks when blocked in a synched block.
GameVariables.followUpCount = 0 -- followUpCount is used so a followup wont be done twice back to back when a follow up is done
GameVariables.lastAttack = nil
GameVariables.comboCounter = 0
GameVariables.parryWindow = 0.5
GameVariables.currentAttack = nil										
--GameVariables.enemyCurrentAttackID = nil -- the anim id the enemy attacked the player with
GameVariables.currentReceiveAnimTRACK = nil -- what animation the player will do based on the enemy attack anim
GameVariables.currentDirection = nil
GameVariables.attackSeries = nil
GameVariables.randAttack = nil
GameVariables.distanceBetween = nil
GameVariables.enemyHumanoid = nil -- pre-defined enemyHumanoid because the script hates global variables. Used for the enemy.
GameVariables.enemyChar = nil
GameVariables.randLvl1Type = nil --[[ Used to determine what lvl 1 attacks
					   the player will use for said combo ]]

GameVariables.animPair = nil

GameVariables.actionTable = {GameVariables.isBlocking, GameVariables.isAttacking, GameVariables.isDodging}

-- NOTE*: Perhaps instead of creating a bunch of animations, we make a single animation then when the player needs to animate, load the animId into the animation. Id's would prob be in a table.
-- *animations (attacker)*
GameVariables.FC_Idle = GameVariables.plrObjectsFolder:WaitForChild("FC_Idle")
GameVariables.FC_IdleTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_Idle)

GameVariables.FC_Block = GameVariables.plrObjectsFolder:WaitForChild("FC_Block")
GameVariables.FC_BlockTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_Block)

GameVariables.FC_BlockStart = GameVariables.plrObjectsFolder:WaitForChild("FC_BlockStart")
GameVariables.FC_BlockStartTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_BlockStart)

GameVariables.FC_LeftHook1 = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHook1")
GameVariables.FC_LeftHook1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHook1)

GameVariables.FC_RightHook1 = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHook1")
GameVariables.FC_RightHook1TRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHook1)

GameVariables.FC_LeftJab = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftJab")
GameVariables.FC_LeftJabTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftJab)

GameVariables.FC_RightJab = GameVariables.plrObjectsFolder:WaitForChild("FC_RightJab")
GameVariables.FC_RightJabTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightJab)

GameVariables.FC_LeftUppercut = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftUppercut")
GameVariables.FC_LeftUppercutTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftUppercut)

GameVariables.FC_RightUppercut = GameVariables.plrObjectsFolder:WaitForChild("FC_RightUppercut")
GameVariables.FC_RightUppercutTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightUppercut)

GameVariables.FC_LeftHaymaker = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHaymaker")
GameVariables.FC_LeftHaymakerTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHaymaker)

GameVariables.FC_RightHaymaker = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHaymaker")
GameVariables.FC_RightHaymakerTrack = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHaymaker)

-- *animations (receiver)*
GameVariables.FC_LeftHook1RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHook1RECEIVER")
GameVariables.FC_LeftHook1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHook1RECEIVER)

GameVariables.FC_RightHook1RECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHook1RECEIVER")
GameVariables.FC_RightHook1RECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHook1RECEIVER)

GameVariables.FC_LeftUppercutRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftUppercutRECEIVER")
GameVariables.FC_LeftUppercutRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftUppercutRECEIVER)

GameVariables.FC_RightUppercutRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightUppercutRECEIVER")
GameVariables.FC_RightUppercutRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightUppercutRECEIVER)

GameVariables.FC_LeftHaymakerRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_LeftHaymakerRECEIVER")
GameVariables.FC_LeftHaymakerRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_LeftHaymakerRECEIVER)

GameVariables.FC_RightHaymakerRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_RightHaymakerRECEIVER")
GameVariables.FC_RightHaymakerReceiverTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_RightHaymakerRECEIVER)

-- *animations (paired)*
GameVariables.FC_SyncBlock1L = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1L")
GameVariables.FC_SyncBlock1LTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1L)

GameVariables.FC_SyncBlock1LRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1LRECEIVER")
GameVariables.FC_SyncBlock1LRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1LRECEIVER)

GameVariables.FC_SyncBlock1R = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1R")
GameVariables.FC_SyncBlock1RTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1R)

GameVariables.FC_SyncBlock1RRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock1RRECEIVER")
GameVariables.FC_SyncBlock1RRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock1RRECEIVER)

GameVariables.FC_SyncBlock2L = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2L")
GameVariables.FC_SyncBlock2LTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2L)

GameVariables.FC_SyncBlock2LRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2LRECEIVER")
GameVariables.FC_SyncBlock2LRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2LRECEIVER)

GameVariables.FC_SyncBlock2R = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2R")
GameVariables.FC_SyncBlock2RTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2R)

GameVariables.FC_SyncBlock2RRECEIVER = GameVariables.plrObjectsFolder:WaitForChild("FC_SyncBlock2RRECEIVER")
GameVariables.FC_SyncBlock2RRECEIVERTRACK = GameVariables.charAnimator:LoadAnimation(GameVariables.FC_SyncBlock2RRECEIVER)

-- *Animation tables*
GameVariables.AllAnimations = {
	GameVariables.FC_IdleTRACK, GameVariables.FC_BlockStartTRACK, GameVariables.FC_BlockTRACK,
	GameVariables.FC_LeftHook1TRACK, GameVariables.FC_RightHook1TRACK, 
	GameVariables.FC_LeftJabTRACK, GameVariables.FC_RightJabTRACK,
	GameVariables.FC_LeftUppercutTRACK, GameVariables.FC_RightUppercutTRACK, 
	GameVariables.FC_LeftHaymakerTRACK, GameVariables.FC_RightHaymakerTrack, 
	GameVariables.FC_LeftHook1RECEIVERTRACK, GameVariables.FC_RightHook1RECEIVERTRACK, 
	GameVariables.FC_LeftUppercutRECEIVERTRACK, GameVariables.FC_RightUppercutRECEIVERTRACK, 
	GameVariables.FC_LeftHaymakerRECEIVERTRACK, GameVariables.FC_RightHaymakerReceiverTRACK,
	GameVariables.FC_SyncBlock1LTRACK, GameVariables.FC_SyncBlock1LRECEIVERTRACK,
	GameVariables.FC_SyncBlock1RTRACK, GameVariables.FC_SyncBlock1RRECEIVERTRACK,
	GameVariables.FC_SyncBlock2LTRACK, GameVariables.FC_SyncBlock2LRECEIVERTRACK,
	GameVariables.FC_SyncBlock2RTRACK, GameVariables.FC_SyncBlock2RRECEIVERTRACK
}

GameVariables.attack1Table = {GameVariables.FC_LeftHook1TRACK, GameVariables.FC_RightHook1TRACK, GameVariables.FC_LeftJabTRACK, GameVariables.FC_RightJabTRACK, GameVariables.FC_LeftUppercutTRACK, GameVariables.FC_RightUppercutTRACK}
GameVariables.attack2Table = {GameVariables.FC_LeftHaymakerTRACK, GameVariables.FC_RightHaymakerTrack}

GameVariables.pairedAttacksTable = {GameVariables.FC_SyncBlock1LTRACK, GameVariables.FC_SyncBlock1RTRACK, GameVariables.FC_SyncBlock2LTRACK, GameVariables.FC_SyncBlock2RTRACK}
GameVariables.pairedBlocksTable = {GameVariables.FC_SyncBlock1LRECEIVERTRACK, GameVariables.FC_SyncBlock1RRECEIVERTRACK, GameVariables.FC_SyncBlock2LRECEIVERTRACK, GameVariables.FC_SyncBlock2RRECEIVERTRACK}
GameVariables.pairedAttack = nil
GameVariables.pairedBlock = nil
GameVariables.pairedChain = 0 -- players can only do 2 sync block attacks in a row.

GameVariables.TestObject = 12

function GameVariables.Set(givenObject, newValue)
    GameVariables[givenObject] = newValue
	
	GameVariables.LocalBindableEvent:Fire(givenObject, newValue)
end

return GameVariables