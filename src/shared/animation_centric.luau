--[[

* Module that gets called by both the client and server for some things.

* For example, NPC animations are managed on the server, and player one's are
    managed on the client. The method of initializing the animations is the same
    on both the server and client, so they need the same functions in this case.

]]
local Animation_Centric = {}
Animation_Centric.__index = Animation_Centric

local function stopActionTracks(moduleTbl) --[[ Function that will stop an attack, receive, or grab track if they are playing ]]
    if moduleTbl.currentReceiveAnimTRACK 
    and moduleTbl.currentReceiveAnimTRACK.IsPlaying 
    and not moduleTbl.isGettingHit 
    and not moduleTbl.currentReceiveAnimTRACK.Animation:GetAttribute("Secure") then
        moduleTbl.currentReceiveAnimTRACK:Stop()
    end
    if moduleTbl.attackTrack and moduleTbl.attackTrack and moduleTbl.attackTrack.IsPlaying then
        moduleTbl.attackTrack:Stop()
    end
    if moduleTbl.currentGrabTRACK and moduleTbl.currentGrabTRACK.IsPlaying and not moduleTbl.currentGrabTRACK.Animation:GetAttribute("Secure") then
        moduleTbl.currentGrabTRACK:Stop()
    end
end

local function getAnimationTrackById(moduleTbl, AnimationId)
    for _, animationTrack in pairs(moduleTbl.AllAnimations) do
        if animationTrack.Animation.AnimationId == AnimationId then
            return animationTrack
        end
    end

    return warn("No AnimationTrack was found with the given AnimationId: " .. tostring(AnimationId))
end


function Animation_Centric.initialize_animations(moduleTbl) --[[ Will initialize both the animations and their corresponding tracks ]]
    moduleTbl.AllAnimations = {}
    for _, obj in pairs(require(game.ReplicatedStorage.Shared.AnimationInstances)) do
        if obj:IsA("Animation") then

            -- moduleTbl[obj.Name] = obj
            moduleTbl[obj.Name .. "TRACK"] = moduleTbl.charAnimator:LoadAnimation(obj)

            -- Set animation priority based on attributes
            if obj:GetAttribute("Paired") and obj:GetAttribute("AnimType") then
                moduleTbl[obj.Name .. "TRACK"].Priority = Enum.AnimationPriority.Action3
            elseif obj:GetAttribute("Paired") then
                moduleTbl[obj.Name .. "TRACK"].Priority = Enum.AnimationPriority.Action2
            elseif obj:GetAttribute("AnimType") and not obj:GetAttribute("Paired") then
                moduleTbl[obj.Name .. "TRACK"].Priority = Enum.AnimationPriority.Action
            end

            table.insert(moduleTbl.AllAnimations, moduleTbl[obj.Name .. "TRACK"])
        end
    end
    -- Sorting all the animations into other animation tables for managing:

    moduleTbl.attack1Table = {}
    moduleTbl.attack2Table = {}

    moduleTbl.pairedAttacksTable = {} -- the for loop below will fill this with all of the attacking paired animations
    moduleTbl.pairedBlocksTable = {} -- same above except for receiving animations.
    
    moduleTbl.counterAttacksTable = {}
    moduleTbl.dodgeAttacksTable = {}

    moduleTbl.attackTrack = nil -- the animation track of the current attack being performed

    for _, v in pairs(moduleTbl.AllAnimations) do -- this for loop fills in the attack1 and attack2Table based off attributes
        if v.Animation:GetAttribute("AttackSeries") then -- standard attacks have the "AttackSeries" attribute so its how we define it as a stnadard attack
            if v.Animation:GetAttribute("AttackLevel") == 1 then -- level 1's will be added to the attack1Table
                table.insert(moduleTbl.attack1Table, v)
            elseif v.Animation:GetAttribute("AttackLevel") == 2 then -- level 2's will be added to the attack2Table
                table.insert(moduleTbl.attack2Table, v)
            end
        elseif v.Animation:GetAttribute("Paired") then -- adds paired animations into either pairedAttacks or pairedBlocks
            if v.Animation:GetAttribute("AnimType") == 1 then

                if v.Animation:GetAttribute("Counter") then
                    -- is a counter attack
                    table.insert(moduleTbl.counterAttacksTable, v)
                elseif v.Animation:GetAttribute("DodgeAttack") then
                    -- is a dodge attack
                    table.insert(moduleTbl.dodgeAttacksTable, v)
                end
                table.insert(moduleTbl.pairedAttacksTable, v)

            elseif v.Animation:GetAttribute("AnimType") == 2 then
                table.insert(moduleTbl.pairedBlocksTable, v)
            end
        end

        -- making the characterInstance accessible from animation_centric:
        moduleTbl.animation_centric = setmetatable({}, { __index = Animation_Centric})
        moduleTbl.animation_centric.characterInstance = moduleTbl

    end
    
end

function Animation_Centric.setupAttackAnimation(moduleTbl, trackData) --[[ Will setup an attack. Execute after using the .playAttackAnimation() ]]
                                                -- AttackTbl would be the table of attacks, such as attack1Tbl or attack2Tbl
    
    if moduleTbl.attackTrack and moduleTbl.attackTrack.IsPlaying then
        moduleTbl.attackTrack:Stop()
    end
    if moduleTbl.currentReceiveAnimTRACK and moduleTbl.currentReceiveAnimTRACK.IsPlaying and not moduleTbl.isGettingHit then
        moduleTbl.currentReceiveAnimTRACK:Stop()
    end

    moduleTbl.attackTrack = getAnimationTrackById(moduleTbl, trackData.AnimationId)

end

function Animation_Centric.playAttackAnimation(moduleTbl) --[[ We setup an attack animation before (using the .setUpAttackAnimation). This will execute that animation.  ]]
    if not moduleTbl.attackTrack then return warn("Failed to play attack track, as it doesn't exist.") end

        print(moduleTbl.finalStatValuesFolder:WaitForChild("attackSpeed").Value)
        moduleTbl.currentAttack = moduleTbl.attackTrack.Animation
        moduleTbl.attackTrack:AdjustSpeed(moduleTbl.attackTrack.Speed * moduleTbl.finalStatValuesFolder:WaitForChild("attackSpeed").Value)
        moduleTbl.attackTrack:Play()
        -- moduleTbl.lastAttackTrack = moduleTbl.attackTrack

end

function Animation_Centric.setupReceiveAnimation(moduleTbl, data)
    stopActionTracks(moduleTbl)

    -- if data.receivingType == "grabAttempt" then
    --     moduleTbl.FC_IdleTRACK:Stop()
    -- end

    moduleTbl.currentReceiveAnimTRACK = getAnimationTrackById(moduleTbl, data.AnimationId)

    if moduleTbl.currentReceiveAnimTRACK.Animation:GetAttribute("Secure") then
        moduleTbl.currentReceiveGrabSecureTRACK = moduleTbl.currentReceiveAnimTRACK
    end

end

function Animation_Centric.playReceiveAnimation(moduleTbl)
    if not moduleTbl.currentReceiveAnimTRACK then return warn("Failed to play receiving animation track, as it doesn't exist.") end
    

    
    moduleTbl.currentReceiveAnimTRACK:Play()

    if moduleTbl.currentReceiveAnimTRACK.Animation:GetAttribute("Grapple") == true then
        moduleTbl.isGrappling = true
    elseif moduleTbl.currentReceiveAnimTRACK.Animation:GetAttribute("Grapple") == false then
        moduleTbl.isGrappling = false
        if moduleTbl.currentReceiveGrabSecureTRACK then
            moduleTbl.currentReceiveGrabSecureTRACK:Stop()
        end

    end
    print("receive animation playing. Are we grappling?:" , moduleTbl.isGrappling)
end

function Animation_Centric.setupGrabAnimation(moduleTbl, data)
    stopActionTracks(moduleTbl)
    moduleTbl.currentGrabTRACK = getAnimationTrackById(moduleTbl, data.AnimationId)

    if moduleTbl.currentGrabTRACK.Animation:GetAttribute("Secure") then
        moduleTbl.currentGrabSecureTRACK = moduleTbl.currentGrabTRACK
    end

end

function Animation_Centric.playGrabAnimation(moduleTbl, data: any?)
    if not moduleTbl.currentGrabTRACK and not moduleTbl.currentReceiveGrabSecureTRACK then return warn("Failed to play grab animation track, as it doesn't exist.") end

    if data and data.bool == false then
        moduleTbl.isGrappling = false

        if moduleTbl.currentGrabSecureTRACK then
            -- moduleTbl.currentGrabTRACK:Stop()
            moduleTbl.currentGrabSecureTRACK:Stop()
        end

        if moduleTbl.currentReceiveGrabSecureTRACK then
            moduleTbl.currentReceiveGrabSecureTRACK:Stop()
        end
    else
        moduleTbl.currentGrabTRACK:Play()
        
        if moduleTbl.currentGrabTRACK.Animation:GetAttribute("Grapple") == true then
            moduleTbl.isGrappling = true
            -- moduleTbl.FC_IdleTRACK:Stop()
        elseif moduleTbl.currentGrabTRACK.Animation:GetAttribute("Grapple") == false then
            moduleTbl.isGrappling = false
            if moduleTbl.currentGrabSecureTRACK then
                moduleTbl.currentGrabSecureTRACK:Stop()
            end
    
        end
        print("grab animation playing. Are we grappling?:" , moduleTbl.isGrappling)
    end
end

function Animation_Centric.playBlockStartAnimation(moduleTbl)
    moduleTbl.FC_BlockStartTRACK:Play()
end

function Animation_Centric.playBlockAnimation(moduleTbl)
    moduleTbl.FC_BlockTRACK:Play()
end

function Animation_Centric.stopBlocking(moduleTbl)
    moduleTbl.FC_BlockStartTRACK:Stop()
    moduleTbl.FC_BlockTRACK:Stop()
end

return Animation_Centric