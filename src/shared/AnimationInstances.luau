local AnimationInstances = {}

-- Animation defining:
AnimationInstances.FC_Idle = Instance.new("Animation")
AnimationInstances.FC_Idle.Name = "FC_Idle"
AnimationInstances.FC_Idle.AnimationId = "rbxassetid://16976891984"
AnimationInstances.FC_Idle:SetAttribute("EventCategory", "bAttack") -- For simplicity, we split the remote events into two different functions: bAttackEvents (basic attacks), miscEvents (anything else).

AnimationInstances.FC_BlockStart = Instance.new("Animation")
AnimationInstances.FC_BlockStart.Name = "FC_BlockStart"
AnimationInstances.FC_BlockStart.AnimationId = "rbxassetid://18266066281"
AnimationInstances.FC_BlockStart:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_Block = Instance.new("Animation")
AnimationInstances.FC_Block.Name = "FC_Block"
AnimationInstances.FC_Block.AnimationId = "rbxassetid://16976697757"
AnimationInstances.FC_Block:SetAttribute("EventCategory", "bAttack")



AnimationInstances.FC_LeftHook1 = Instance.new("Animation")
AnimationInstances.FC_LeftHook1.Name = "FC_LeftHook1"
AnimationInstances.FC_LeftHook1.AnimationId = "rbxassetid://16998937874"
AnimationInstances.FC_LeftHook1:SetAttribute("AttackLevel", 1) -- *There will be three types of attack levels: 1 is for jabs and hooks etc, 2 is for haymakers and other powerful attacks, 3 is for finishers, executions and other paired animations.
AnimationInstances.FC_LeftHook1:SetAttribute("AnimType", 1) -- AnimType will distinguish what kind of animation we're dealing with. 1 is attacks, 2 is receives,
AnimationInstances.FC_LeftHook1:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_LeftHook1:SetAttribute("AttackSeries", "Hooks")
AnimationInstances.FC_LeftHook1:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightHook1 = Instance.new("Animation")
AnimationInstances.FC_RightHook1.Name = "FC_RightHook1"
AnimationInstances.FC_RightHook1.AnimationId = "rbxassetid://17021541192"
AnimationInstances.FC_RightHook1:SetAttribute("AttackLevel", 1)
AnimationInstances.FC_RightHook1:SetAttribute("AnimType", 1)
AnimationInstances.FC_RightHook1:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_RightHook1:SetAttribute("AttackSeries", "Hooks")
AnimationInstances.FC_RightHook1:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_LeftJab = Instance.new("Animation")
AnimationInstances.FC_LeftJab.Name = "FC_LeftJab"
AnimationInstances.FC_LeftJab.AnimationId = "rbxassetid://18207098315"
AnimationInstances.FC_LeftJab:SetAttribute("AttackLevel", 1)
AnimationInstances.FC_LeftJab:SetAttribute("AnimType", 1)
AnimationInstances.FC_LeftJab:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_LeftJab:SetAttribute("AttackSeries", "Jabs")
AnimationInstances.FC_LeftJab:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightJab = Instance.new("Animation")
AnimationInstances.FC_RightJab.Name = "FC_RightJab"
AnimationInstances.FC_RightJab.AnimationId = "rbxassetid://18210186455"
AnimationInstances.FC_RightJab:SetAttribute("AttackLevel", 1)
AnimationInstances.FC_RightJab:SetAttribute("AnimType", 1)
AnimationInstances.FC_RightJab:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_RightJab:SetAttribute("AttackSeries", "Jabs")
AnimationInstances.FC_RightJab:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_LeftUppercut = Instance.new("Animation")
AnimationInstances.FC_LeftUppercut.Name = "FC_LeftUppercut"
AnimationInstances.FC_LeftUppercut.AnimationId = "rbxassetid://18224256126"
AnimationInstances.FC_LeftUppercut:SetAttribute("AttackLevel", 1)
AnimationInstances.FC_LeftUppercut:SetAttribute("AnimType", 1)
AnimationInstances.FC_LeftUppercut:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_LeftUppercut:SetAttribute("AttackSeries", "Uppercuts")
AnimationInstances.FC_LeftUppercut:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightUppercut = Instance.new("Animation")
AnimationInstances.FC_RightUppercut.Name = "FC_RightUppercut"
AnimationInstances.FC_RightUppercut.AnimationId = "rbxassetid://18223875093"
AnimationInstances.FC_RightUppercut:SetAttribute("AttackLevel", 1)
AnimationInstances.FC_RightUppercut:SetAttribute("AnimType", 1)
AnimationInstances.FC_RightUppercut:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_RightUppercut:SetAttribute("AttackSeries", "Uppercuts")
AnimationInstances.FC_RightUppercut:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_LeftHaymaker = Instance.new("Animation")
AnimationInstances.FC_LeftHaymaker.Name = "FC_LeftHaymaker"
AnimationInstances.FC_LeftHaymaker.AnimationId = "rbxassetid://18195506368"
AnimationInstances.FC_LeftHaymaker:SetAttribute("AttackLevel", 2)
AnimationInstances.FC_LeftHaymaker:SetAttribute("AnimType", 1)
AnimationInstances.FC_LeftHaymaker:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_LeftHaymaker:SetAttribute("AttackSeries", "Haymakers")
AnimationInstances.FC_LeftHaymaker:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightHaymaker = Instance.new("Animation")
AnimationInstances.FC_RightHaymaker.Name = "FC_RightHaymaker"
AnimationInstances.FC_RightHaymaker.AnimationId = "rbxassetid://17216832518"
AnimationInstances.FC_RightHaymaker:SetAttribute("AttackLevel", 2)
AnimationInstances.FC_RightHaymaker:SetAttribute("AnimType", 1)
AnimationInstances.FC_RightHaymaker:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_RightHaymaker:SetAttribute("AttackSeries", "Haymakers")
AnimationInstances.FC_RightHaymaker:SetAttribute("EventCategory", "bAttack")


AnimationInstances.FC_LeftHook1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_LeftHook1RECEIVER.Name = "FC_LeftHook1RECEIVER"
AnimationInstances.FC_LeftHook1RECEIVER.AnimationId = "rbxassetid://17012688911"
AnimationInstances.FC_LeftHook1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_LeftHook1RECEIVER:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightHook1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_RightHook1RECEIVER.Name = "FC_RightHook1RECEIVER"
AnimationInstances.FC_RightHook1RECEIVER.AnimationId = "rbxassetid://17149671845"
AnimationInstances.FC_RightHook1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_RightHook1RECEIVER:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_LeftUppercutRECEIVER = Instance.new("Animation")
AnimationInstances.FC_LeftUppercutRECEIVER.Name = "FC_LeftUppercutRECEIVER"
AnimationInstances.FC_LeftUppercutRECEIVER.AnimationId = "rbxassetid://18224267835"
AnimationInstances.FC_LeftUppercutRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_LeftUppercutRECEIVER:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightUppercutRECEIVER = Instance.new("Animation")
AnimationInstances.FC_RightUppercutRECEIVER.Name = "FC_RightUppercutRECEIVER"
AnimationInstances.FC_RightUppercutRECEIVER.AnimationId = "rbxassetid://18224216460"
AnimationInstances.FC_RightUppercutRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_RightUppercutRECEIVER:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_LeftHaymakerRECEIVER = Instance.new("Animation")
AnimationInstances.FC_LeftHaymakerRECEIVER.Name = "FC_LeftHaymakerRECEIVER"
AnimationInstances.FC_LeftHaymakerRECEIVER.AnimationId = "rbxassetid://18195570469"
AnimationInstances.FC_LeftHaymakerRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_LeftHaymakerRECEIVER:SetAttribute("EventCategory", "bAttack")

AnimationInstances.FC_RightHaymakerRECEIVER = Instance.new("Animation")
AnimationInstances.FC_RightHaymakerRECEIVER.Name = "FC_RightHaymakerRECEIVER"
AnimationInstances.FC_RightHaymakerRECEIVER.AnimationId = "rbxassetid://17231536892"
AnimationInstances.FC_RightHaymakerRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_RightHaymakerRECEIVER:SetAttribute("EventCategory", "bAttack")



AnimationInstances.FC_SyncBlock1L = Instance.new("Animation")
AnimationInstances.FC_SyncBlock1L.Name = "FC_SyncBlock1L"
AnimationInstances.FC_SyncBlock1L.AnimationId = "rbxassetid://18313294082"
AnimationInstances.FC_SyncBlock1L:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock1L:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock1L:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock1L:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock1LRECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock1LRECEIVER.Name = "FC_SyncBlock1LRECEIVER"
AnimationInstances.FC_SyncBlock1LRECEIVER.AnimationId = "rbxassetid://18313350253"
AnimationInstances.FC_SyncBlock1LRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock1LRECEIVER:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock1LRECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock1R = Instance.new("Animation")
AnimationInstances.FC_SyncBlock1R.Name = "FC_SyncBlock1R"
AnimationInstances.FC_SyncBlock1R.AnimationId = "rbxassetid://18411572433"
AnimationInstances.FC_SyncBlock1R:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock1R:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock1R:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock1R:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock1RRECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock1RRECEIVER.Name = "FC_SyncBlock1RRECEIVER"
AnimationInstances.FC_SyncBlock1RRECEIVER.AnimationId = "rbxassetid://18411663259"
AnimationInstances.FC_SyncBlock1RRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock1RRECEIVER:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock1RRECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock2L = Instance.new("Animation")
AnimationInstances.FC_SyncBlock2L.Name = "FC_SyncBlock2L"
AnimationInstances.FC_SyncBlock2L.AnimationId = "rbxassetid://18513963314"
AnimationInstances.FC_SyncBlock2L:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock2L:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock2L:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock2L:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock2LRECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock2LRECEIVER.Name = "FC_SyncBlock2LRECEIVER"
AnimationInstances.FC_SyncBlock2LRECEIVER.AnimationId = "rbxassetid://18513976177"
AnimationInstances.FC_SyncBlock2LRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock2LRECEIVER:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock2LRECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock2R = Instance.new("Animation")
AnimationInstances.FC_SyncBlock2R.Name = "FC_SyncBlock2R"
AnimationInstances.FC_SyncBlock2R.AnimationId = "rbxassetid://18513983953"
AnimationInstances.FC_SyncBlock2R:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock2R:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock2R:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock2R:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock2RRECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock2RRECEIVER.Name = "FC_SyncBlock2RRECEIVER"
AnimationInstances.FC_SyncBlock2RRECEIVER.AnimationId = "rbxassetid://18513989602"
AnimationInstances.FC_SyncBlock2RRECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock2RRECEIVER:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock2RRECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3L1 = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3L1.Name = "FC_SyncBlock3L1"
AnimationInstances.FC_SyncBlock3L1.AnimationId = "rbxassetid://18740951548"
AnimationInstances.FC_SyncBlock3L1:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock3L1:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock3L1:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock3L1:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3L1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3L1RECEIVER.Name = "FC_SyncBlock3L1RECEIVER"
AnimationInstances.FC_SyncBlock3L1RECEIVER.AnimationId = "rbxassetid://18740954203"
AnimationInstances.FC_SyncBlock3L1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock3L1RECEIVER:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock3L1RECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3R1 = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3R1.Name = "FC_SyncBlock3R1"
AnimationInstances.FC_SyncBlock3R1.AnimationId = "rbxassetid://18743711875"
AnimationInstances.FC_SyncBlock3R1:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock3R1:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock3R1:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock3R1:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3R1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3R1RECEIVER.Name = "FC_SyncBlock3R1RECEIVER"
AnimationInstances.FC_SyncBlock3R1RECEIVER.AnimationId = "rbxassetid://18743714470"
AnimationInstances.FC_SyncBlock3R1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock3R1RECEIVER:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock3R1RECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3L2 = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3L2.Name = "FC_SyncBlock3L2"
AnimationInstances.FC_SyncBlock3L2.AnimationId = "rbxassetid://18747173117"
AnimationInstances.FC_SyncBlock3L2:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock3L2:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock3L2:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock3L2:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3L2RECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3L2RECEIVER.Name = "FC_SyncBlock3L2RECEIVER"
AnimationInstances.FC_SyncBlock3L2RECEIVER.AnimationId = "rbxassetid://18747180819"
AnimationInstances.FC_SyncBlock3L2RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock3L2RECEIVER:SetAttribute("AnimDirection", "Left")
AnimationInstances.FC_SyncBlock3L2RECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3R2 = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3R2.Name = "FC_SyncBlock3R2"
AnimationInstances.FC_SyncBlock3R2.AnimationId = "rbxassetid://18757168674"
AnimationInstances.FC_SyncBlock3R2:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_SyncBlock3R2:SetAttribute("AnimType", 1)
AnimationInstances.FC_SyncBlock3R2:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock3R2:SetAttribute("Paired", true)

AnimationInstances.FC_SyncBlock3R2RECEIVER = Instance.new("Animation")
AnimationInstances.FC_SyncBlock3R2RECEIVER.Name = "FC_SyncBlock3R2RECEIVER"
AnimationInstances.FC_SyncBlock3R2RECEIVER.AnimationId = "rbxassetid://18757172855"
AnimationInstances.FC_SyncBlock3R2RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_SyncBlock3R2RECEIVER:SetAttribute("AnimDirection", "Right")
AnimationInstances.FC_SyncBlock3R2RECEIVER:SetAttribute("Paired", true)



AnimationInstances.FC_BracingBlockL = Instance.new("Animation")
AnimationInstances.FC_BracingBlockL.Name = "FC_BracingBlockL"
AnimationInstances.FC_BracingBlockL.AnimationId = "rbxassetid://125158753103737"
AnimationInstances.FC_BracingBlockL:SetAttribute("AnimType", 2)
AnimationInstances.FC_BracingBlockL:SetAttribute("AnimDirection", "Left")

AnimationInstances.FC_BracingBlockR = Instance.new("Animation")
AnimationInstances.FC_BracingBlockR.Name = "FC_BracingBlockR"
AnimationInstances.FC_BracingBlockR.AnimationId = "rbxassetid://81054055418110"
AnimationInstances.FC_BracingBlockR:SetAttribute("AnimType", 2)
AnimationInstances.FC_BracingBlockR:SetAttribute("AnimDirection", "Right")



AnimationInstances.FC_LeftParry = Instance.new("Animation")
AnimationInstances.FC_LeftParry.Name = "FC_LeftParry"
AnimationInstances.FC_LeftParry.AnimationId = "rbxassetid://98670773281611"
AnimationInstances.FC_LeftParry:SetAttribute("Paired", true)

AnimationInstances.FC_LeftParryRECEIVER = Instance.new("Animation")
AnimationInstances.FC_LeftParryRECEIVER.Name = "FC_LeftParryRECEIVER"
AnimationInstances.FC_LeftParryRECEIVER.AnimationId = "rbxassetid://105843461082459 "
AnimationInstances.FC_LeftParryRECEIVER:SetAttribute("Paired", true)

AnimationInstances.FC_RightParry = Instance.new("Animation")
AnimationInstances.FC_RightParry.Name = "FC_RightParry"
AnimationInstances.FC_RightParry.AnimationId = "rbxassetid://113708135947767"
AnimationInstances.FC_RightParry:SetAttribute("Paired", true)

AnimationInstances.FC_RightParryRECEIVER = Instance.new("Animation")
AnimationInstances.FC_RightParryRECEIVER.Name = "FC_RightParryRECEIVER"
AnimationInstances.FC_RightParryRECEIVER.AnimationId = "rbxassetid://134313731572876"
AnimationInstances.FC_RightParryRECEIVER:SetAttribute("Paired", true)



AnimationInstances.FC_RightCounter1 = Instance.new("Animation")
AnimationInstances.FC_RightCounter1.Name = "FC_RightCounter1"
AnimationInstances.FC_RightCounter1.AnimationId = "rbxassetid://134051879952221"
AnimationInstances.FC_RightCounter1:SetAttribute("Paired", true)
AnimationInstances.FC_RightCounter1:SetAttribute("Counter", true) -- Counter is given to countering animations, including the receiving ones to distinguish our animations
AnimationInstances.FC_RightCounter1:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_RightCounter1:SetAttribute("AnimType", 1)
AnimationInstances.FC_RightCounter1:SetAttribute("AnimDirection", "Right")

AnimationInstances.FC_RightCounter1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_RightCounter1RECEIVER.Name = "FC_RightCounter1RECEIVER"
AnimationInstances.FC_RightCounter1RECEIVER.AnimationId = "rbxassetid://102062393002467"
AnimationInstances.FC_RightCounter1RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_RightCounter1RECEIVER:SetAttribute("Counter", true)
AnimationInstances.FC_RightCounter1RECEIVER:SetAttribute("AnimType", 2)

AnimationInstances.FC_LeftCounter1 = Instance.new("Animation")
AnimationInstances.FC_LeftCounter1.Name = "FC_LeftCounter1"
AnimationInstances.FC_LeftCounter1.AnimationId = "rbxassetid://87128106022021"
AnimationInstances.FC_LeftCounter1:SetAttribute("Paired", true)
AnimationInstances.FC_LeftCounter1:SetAttribute("Counter", true)
AnimationInstances.FC_LeftCounter1:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_LeftCounter1:SetAttribute("AnimType", 1)
AnimationInstances.FC_LeftCounter1:SetAttribute("AnimDirection", "Left")

AnimationInstances.FC_LeftCounter1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_LeftCounter1RECEIVER.Name = "FC_LeftCounter1RECEIVER"
AnimationInstances.FC_LeftCounter1RECEIVER.AnimationId = "rbxassetid://103327338913216"
AnimationInstances.FC_LeftCounter1RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_LeftCounter1RECEIVER:SetAttribute("Counter", true)
AnimationInstances.FC_LeftCounter1RECEIVER:SetAttribute("AnimType", 2)

AnimationInstances.FC_LeftCounter2 = Instance.new("Animation")
AnimationInstances.FC_LeftCounter2.Name = "FC_LeftCounter2"
AnimationInstances.FC_LeftCounter2.AnimationId = "rbxassetid://109432180394178"
AnimationInstances.FC_LeftCounter2:SetAttribute("Paired", true)
AnimationInstances.FC_LeftCounter2:SetAttribute("Counter", true)
AnimationInstances.FC_LeftCounter2:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_LeftCounter2:SetAttribute("AnimType", 1)
AnimationInstances.FC_LeftCounter2:SetAttribute("AnimDirection", "Left")

AnimationInstances.FC_LeftCounter2RECEIVER = Instance.new("Animation")
AnimationInstances.FC_LeftCounter2RECEIVER.Name = "FC_LeftCounter2RECEIVER"
AnimationInstances.FC_LeftCounter2RECEIVER.AnimationId = "rbxassetid://75035751289008"
AnimationInstances.FC_LeftCounter2RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_LeftCounter2RECEIVER:SetAttribute("Counter", true)
AnimationInstances.FC_LeftCounter2RECEIVER:SetAttribute("AnimType", 2)

AnimationInstances.FC_RightCounter2 = Instance.new("Animation")
AnimationInstances.FC_RightCounter2.Name = "FC_RightCounter2"
AnimationInstances.FC_RightCounter2.AnimationId = "rbxassetid://123756150096819"
AnimationInstances.FC_RightCounter2:SetAttribute("Paired", true)
AnimationInstances.FC_RightCounter2:SetAttribute("Counter", true)
AnimationInstances.FC_RightCounter2:SetAttribute("AttackLevel", 3)
AnimationInstances.FC_RightCounter2:SetAttribute("AnimType", 1)
AnimationInstances.FC_RightCounter2:SetAttribute("AnimDirection", "Right")

AnimationInstances.FC_RightCounter2RECEIVER = Instance.new("Animation")
AnimationInstances.FC_RightCounter2RECEIVER.Name = "FC_RightCounter2RECEIVER"
AnimationInstances.FC_RightCounter2RECEIVER.AnimationId = "rbxassetid://126502997166113"
AnimationInstances.FC_RightCounter2RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_RightCounter2RECEIVER:SetAttribute("Counter", true)
AnimationInstances.FC_RightCounter2RECEIVER:SetAttribute("AnimType", 2)



AnimationInstances.FC_LeftDodge = Instance.new("Animation")
AnimationInstances.FC_LeftDodge.Name = "FC_LeftDodge"
AnimationInstances.FC_LeftDodge.AnimationId = "rbxassetid://117027123930220"
AnimationInstances.FC_LeftDodge:SetAttribute("Dodge", true)
AnimationInstances.FC_LeftDodge:SetAttribute("AnimDirection", "Left")

AnimationInstances.FC_RightDodge = Instance.new("Animation")
AnimationInstances.FC_RightDodge.Name = "FC_RightDodge"
AnimationInstances.FC_RightDodge.AnimationId = "rbxassetid://134531579306048"
AnimationInstances.FC_RightDodge:SetAttribute("Dodge", true)
AnimationInstances.FC_RightDodge:SetAttribute("AnimDirection", "Right")

AnimationInstances.FC_BackDodge = Instance.new("Animation")
AnimationInstances.FC_BackDodge.Name = "FC_BackDodge"
AnimationInstances.FC_BackDodge.AnimationId = "rbxassetid://103495259681812"
AnimationInstances.FC_BackDodge:SetAttribute("Dodge", true)
AnimationInstances.FC_BackDodge:SetAttribute("AnimDirection", "Back")

AnimationInstances.FC_LDodgeAttack1 = Instance.new("Animation")
AnimationInstances.FC_LDodgeAttack1.Name = "FC_LDodgeAttack1"
AnimationInstances.FC_LDodgeAttack1.AnimationId = "rbxassetid://93110825889179"
AnimationInstances.FC_LDodgeAttack1:SetAttribute("Paired", true)
AnimationInstances.FC_LDodgeAttack1:SetAttribute("AnimType", 1)
AnimationInstances.FC_LDodgeAttack1:SetAttribute("DodgeAttack", true)
AnimationInstances.FC_LDodgeAttack1:SetAttribute("AnimDirection", "Left")

AnimationInstances.FC_LDodgeAttack1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_LDodgeAttack1RECEIVER.Name = "FC_LDodgeAttack1RECEIVER"
AnimationInstances.FC_LDodgeAttack1RECEIVER.AnimationId = "rbxassetid://90092961450366"
AnimationInstances.FC_LDodgeAttack1RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_LDodgeAttack1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_LDodgeAttack1RECEIVER:SetAttribute("DodgeAttack", true) -- even receiving, this animation falls under the dodge attack animation category
AnimationInstances.FC_LDodgeAttack1RECEIVER:SetAttribute("AnimDirection", "Left") -- even receiving, this animation falls under the dodge attack animation category

AnimationInstances.FC_RDodgeAttack1 = Instance.new("Animation")
AnimationInstances.FC_RDodgeAttack1.Name = "FC_RDodgeAttack1"
AnimationInstances.FC_RDodgeAttack1.AnimationId = "rbxassetid://115517810366402"
AnimationInstances.FC_RDodgeAttack1:SetAttribute("Paired", true)
AnimationInstances.FC_RDodgeAttack1:SetAttribute("AnimType", 1)
AnimationInstances.FC_RDodgeAttack1:SetAttribute("DodgeAttack", true)
AnimationInstances.FC_RDodgeAttack1:SetAttribute("AnimDirection", "Right")

AnimationInstances.FC_RDodgeAttack1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_RDodgeAttack1RECEIVER.Name = "FC_RDodgeAttack1RECEIVER"
AnimationInstances.FC_RDodgeAttack1RECEIVER.AnimationId = "rbxassetid://90880663701721"
AnimationInstances.FC_RDodgeAttack1RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_RDodgeAttack1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_RDodgeAttack1RECEIVER:SetAttribute("DodgeAttack", true)
AnimationInstances.FC_RDodgeAttack1RECEIVER:SetAttribute("AnimDirection", "Right")

AnimationInstances.FC_BDodgeAttack1 = Instance.new("Animation")
AnimationInstances.FC_BDodgeAttack1.Name = "FC_BDodgeAttack1"
AnimationInstances.FC_BDodgeAttack1.AnimationId = "rbxassetid://113674522948281"
AnimationInstances.FC_BDodgeAttack1:SetAttribute("Paired", true)
AnimationInstances.FC_BDodgeAttack1:SetAttribute("AnimType", 1)
AnimationInstances.FC_BDodgeAttack1:SetAttribute("DodgeAttack", true)
AnimationInstances.FC_BDodgeAttack1:SetAttribute("AnimDirection", "Back")

AnimationInstances.FC_BDodgeAttack1RECEIVER = Instance.new("Animation")
AnimationInstances.FC_BDodgeAttack1RECEIVER.Name = "FC_BDodgeAttack1RECEIVER"
AnimationInstances.FC_BDodgeAttack1RECEIVER.AnimationId = "rbxassetid://111445875078566"
AnimationInstances.FC_BDodgeAttack1RECEIVER:SetAttribute("Paired", true)
AnimationInstances.FC_BDodgeAttack1RECEIVER:SetAttribute("AnimType", 2)
AnimationInstances.FC_BDodgeAttack1RECEIVER:SetAttribute("DodgeAttack", true)
AnimationInstances.FC_BDodgeAttack1RECEIVER:SetAttribute("AnimDirection", "Back")

-- Temporarly creating tracks to store the length of said track for management:

-- local temporaryAnimationController = Instance.new("AnimationController") -- for temporarily loading animation tracks to return a length of the track. Needed to parent the animator.
local temporaryAnimator = game.Workspace.TestDummy:WaitForChild("Humanoid").charAnimator -- Needed to load the tempoary animation tracks.
-- temporaryAnimator.Parent = temporaryAnimationController

for _, animation in pairs(AnimationInstances) do
    task.wait()

    local temporaryTrack = temporaryAnimator:LoadAnimation(animation)
    while temporaryTrack.Length == 0 do task.wait() end -- When an animation track isnt fully loaded, its Length property will be 0. Plus we need the length anyways
    if temporaryTrack.Looped then 
        animation:SetAttribute("Looped", true)
        warn(temporaryTrack.Animation.Name .. " got skipped since its looped")
        continue 
    end

    -- Set animation priority based on attributes
    if temporaryTrack.Animation:GetAttribute("AnimType") and not temporaryTrack.Animation:GetAttribute("Paired") then
        temporaryTrack.Priority = Enum.AnimationPriority.Action
    elseif temporaryTrack.Animation:GetAttribute("Paired") then
        temporaryTrack.Priority = Enum.AnimationPriority.Action2
    end
    -- print(temporaryTrack, temporaryTrack.Priority)


    -- print(temporaryTrack.Length)
    task.spawn(function()
        
        animation:SetAttribute("Length", temporaryTrack.Length)
        local temporaryStartOfAttackConnection = temporaryTrack:GetMarkerReachedSignal("StartOfAttack"):Connect(function()
            animation:SetAttribute("TimeUntilStartOfAttack", temporaryTrack.TimePosition)
        end)
        local temporaryEndOfAttackConnection = temporaryTrack:GetMarkerReachedSignal("EndOfAttack"):Connect(function()
            animation:SetAttribute("TimeUntilEndOfAttack", temporaryTrack.TimePosition)
            temporaryTrack:Stop()
        end)
        local temporaryIsBlockingConnection = temporaryTrack:GetMarkerReachedSignal("isBlocking"):Connect(function()
            animation:SetAttribute("TimeUntilIsBlocking", temporaryTrack.TimePosition)
        end)
        temporaryTrack:Play()
        temporaryTrack.Stopped:Wait()
        temporaryStartOfAttackConnection:Disconnect()
        temporaryEndOfAttackConnection:Disconnect()
        temporaryIsBlockingConnection:Disconnect()
        temporaryTrack:Destroy()
    
        temporaryStartOfAttackConnection = nil
        temporaryEndOfAttackConnection = nil
        temporaryIsBlockingConnection = nil
        temporaryTrack = nil
    end)
end

return AnimationInstances