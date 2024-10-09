cool little fighting mechanic I decided to make

4/1/24

- What I was working on: Began making this mechanic. Got the lock on to work as well as the non-rotation while locked on. There is a bug with pressing Q while locked on from afar

upd: slowed the player when locked on, and also just slowed the general speed of the player - this isnt one of those fast flashy games. I also track the player moving direction - important for movement animations and dodging and what not. Created an invisible cube for the
	 camera to revolve around between player and enemy. Also did some other tweeking with the camera. Created a blocking and Idle animation whem locked on
	 

- What I intend to do: Fix this little issue somehow, add animations such as walking (as in around locked target) punching, dodging, blocking, etc. Convert this to work on server as well, and also slow the player when locked on, and auto-unlock when going far away, and other
  functionality.
  
  -- add movement animations such as Foward, Backward, Left, Right, Up-Left, Up-Right and so on. Then begin adding combat to my game.
  
  4/3/24
  
  - What I was working on: Created a couple punching animations, switched to moon animator, started the server script that sucessfully does damage on punches. I even added animation events to the left hook animation, which tracks when the player is done punching.

  	
  - What I intend to do: Fix the issue with the player walking too far from target, add the right hook as a combo following left hook, as well as the other attacks too, add walking animations, and other small stuff.

  
  4/4/24
  
  - What I was working on: Altered enemy damage taken from punch, created bindableEvent for client script to communicate to enemyPlayr script for animation, created bindable event, created enemyManagementScript (nevermind scratch that), instead I created the animation
    on the same local script and played ot there too. Other script seemed too complex to referance the same thing for some reason. Anyways I may just play all animations from the same client script.
    
    - What I intend to do: Add more attack animations and apply them such as jabbing and haymakers. Use the comboCounter variable to track what attack type should play depending on the players last attack.
    
    4/5/24
    
    - What I was working on: Created the rightHook animation, which I realize now both need work in terms of speed and realism. Changed the method at which animations play by randomizing which attack plays, but the same attack plays too often, so that will need changed.

      lastAttack is used to stop the last-played animation, but this causes gitterness when performing the same attack.
      
    - What I intend to do: Speed up & fix attack animations, add more attacks like jabs and haymakers fix that bug where walking far away and unlocking from the enemy causes an error, randomize attacks better to where the last attack is much less likely (but not impossible)
      to play after playing, giving other attacks better c+hance to play (so long as they are in the right attack level), give the attacks a "left" or "right" attack direction attribute, which will dictate which direction the victim will turn when being attacked, tween the
      victim back when getting hit by a heavy attack like a haymaker or kick as well as doing an animation.
      
    4/14/24
    
    - What I was working on: Added an "AttackDirection" attribute to animations to determine which direction victim reacts by turning their head. I also finished the righHook animation which was oddly not finished yet.

    
    - What I intend to do: Refine attack animations, add other attacks like haymakers and uppercuts, make the same attack have a slight chance of playing again after it already played prior, and tweening the victim if they get hit by a heavy attack like haymaker.
    
    4/15/24
    
    - What I was working on: Changed the method at which the enemy's attackRecieve animation plays to prevent delay by making it a var as soon as player touches the enemy. Temporairly took away the "random" punch as the left hook for some reason ALWAYS played and rarely the

      right hook would play. Also, figured out a way for the script to tell the difference between an attack cancel and waiting for an attack to finish entirely.

      
    - What I intend to do: Since the comboCounter works, the player can currently only punch 3 times. I plan on making haymaker attacks for a combo finisher. This should *knock back* the enemy and cause a slight stagger. After this, the player will probably start a new combo
      over with jabs instead of hooks, or uppercuts (not the dodge attack one). OR, they can perform another heavy hook on the other arm and then start a combo over. It may be random. On certain circumstances, the player should be able to kick the opponent back. The player

      should also be able to eventually "finish" or "execute" their enemy.
      
      4/20/24
      
      - What I was working on: Created a haymaker anim for the right arm, lost the keyframes for moon animator :( so to refine I may need to completely remake it.. sad. Uploaded it, added it to the 
      and gave it temporairly parameters to play that need refined.
        Problem is, the haymaker plays every other attack, which needs to be fixed to only play when the comboCounter is high enough.
      
      - What I intend to do: Get the haymaker to play only at appropriate times, refine haymaker animation, create a left haymaker animation as well, create a protocol for "haymaker" to send to the server to deal more damage for the haymaker to enemy. Also to organize my code
        better.. its a mess.
        
        4/29/24
        - What I was doing: Basically got nothing done at all. Attempted to fix the UserInputService part of
          this script to be better structured and all. But because I've not coded in like 9 days, All I
          really did was stare at the code on my screen with no idea what was working and what wasn't
          
        - What I intend to do: Figure out how to code again basically. Thanks to school, I couldn't get
          any coding done. But, we will try to be more consistant so this won't happen again. In other words,
          fix the UserInputService part of the script and then work on the other stuff intended from the 
          29th.
          
        4/30/24
        
        - What I was working on: Fixed the UserInputService issue, added Fight Club to my microsoft to-do,
          and also began implementing hitboxes.
        
        - What I intend to do: Animations only show for only one client, so I will need to make them show
          for both. Properly implement the hitboxes on the player instead of using their body parts to
          attack, add more to my to-do list to have an idea on what I should be working on.
          
        5/3 & 5/5/24
        
        - What I was working on: Added hitboxes properly to the player for arms, legs, head and torso. This is
          defined in server and also referanced in client so client can use events with it. There are two tables:
          Attacking and Receiving. Attacking is for arms and legs that actually attack the opponent, and receiving
          is used for head and torso for.. receiving attacks from opponent.
          
        - What I intend to do: Use a for loop on both the attacking and receiving hitbox tables to detect events.
        The attacking table will look out for .Touched events & more in the context of when the player is attacking
        to deal damage via remote event to server. The receiving table will look out for .Touched events with the
        context of when the other player attacks them, it will play an animation on impact and deal damage to the
        player via remote event.
        
        5/12/24
        
        - What I was working on: Got hitboxes done, with a table to check when they collide, and plays an
        animation on impact. But its a bit delayed. Also made the player do haymakers when the players'
        health is <= 10
        
        - What I intend to do, fix the delay in hitReceived animations and also refine animations and tween
          player when they get hit from a haymaker, similar to the animation but in a tween instead.
          
       5/17/24
       
       - What I was working on: We are getting back in the flow. About done with the heavy-load of school
         work, but we are getting into the habit again.
         Anyways, I began working on a way to let the player know what kind of attack the enemy is doing
         (in the hitboxReceived.Touched:Connect function.) First I tried using an attribute called
         attackAttri, but that didn't work out so well, so now I'm trying to detect what animation
         the enemy plays via the :GetPlayingAnimationTracks() function.
         
         What I intend to do: I will hopefully get the function above to work out with when the player gets
         hit. Breakdown: When the enemy presses attack and hits the player's via their receive hitbox(es),
         the hitbox will detect anything at all times. It will check to make sure the enemy is actually
         attacking before running an animation. How will the player know which receiving hit animation to
         play? Well, as mentioned above, the :GetPlayingAnimationTracks() function will return all
         animations that a animator is playing. When the enemy hits the player, this will fire if it's an
         animator. It will search through all attack animations via the totalAttackTable to find any match
         with the animations the enemy is playing when they hit the player. If there is a match, then
         the function will return what animation was the match. Then finally, the player will play the
         receiving animation that corresponds with the returned animation on their own, and boom! That is 
         how we'd re-create the receiving-attack functionality of the game.
         
         NOTE: A strategy to split up projects moving forward: Psudocode all of our systems in the game (just like
         what we did above). This will provide an outline of what to do. This is probably what I should be
         doing with Microsoft To Do, but now we know. Now this will hopefully give me a strong understanding and
         guidance on what I should do.
         
         5/18/24
         
         - What I was working on: Didn't get much done today. I was figuring out how to get
           :GetPlayingAnimationTracks() to work, but the animations aren't replicating to the server. I did
           transfer all the animations to the server so the server would know they exist since existance
           on the client doesn't work with server.
           
           What I intend to do: Figure out how to get the animations to be seen by the client when using
           :GetPlayingAnimationTracks(). Need to delete the animation creations on client so it will be
           only created on server.
           
        5/22/24
        
        - What I was working on: Imported all animation instances to exist on the server so it can be seen by
          other clients. Unfortunately, the :GetPlayingAnimationTracks() function isn't working too well,
          so I began another strategy of creating an attribute called CAPublic - currentAttackPublic is what
          it stands for. The idea would be that it equals the boiled-down version of currentAttack: What it's
          attack level was and what direction. Thought this would be a better alternative to the
          :GetPlayingAnimationTracks, but then I just realised that changing its values on the client causes
          issues, such as the other client not seeing what it's value is. Kinda regretting it, and I *really*
          want the receiving functionality to be around the animations that the player received.
          
          - What I intend to do: Honestly, I just want to get this system working. I plan to (hopefully) get it
          to work with :GetPlayingAnimationTracks(), but the issue is that the server is only detecting the
          idle animation and nothing more, so I plan to figure that out and get it to work.
          
        5/23/24
        
        - What I was working on: Finally! Got the :GetPlayingAnimationTracks() function to work out. All the
          trouble from before was all thanks to the 'return false' I had, which meant it would run once, then
          never again. So glad that I fixed that. Anyways, also gave the receiving animations an attribute
          called 'CorrespondingAttackID' which is what attacking animation will cause the receiving
          animation, which equals the ID of the attacking animation. Now there is another issue: When
          I try to go through the totalReceive table for attacks, it will only return the first value, but
          the rest will return nil, similar to my last issue. And the one animation that actually plays,
          it would play the wrong animation to what the character was attacked with.
          
        - What I intend to do: Figure out how to return all animation tracks of the receivingAnimation table
        when the enemy gets hit, and also make the enemy play the right receive animation when hit with it's 
        corresponding attack animation.
        
       5/24/24
       
       - What I was working on: A lot of changes today. Regarding yesterday's issue, the problem was that I
         accidently re-defined the leftHookReceiver's 'CorrespondingAttackID' throughout the other receivers.
         When I changed it to their own, it fixed the issue. After that, the receiving system was ready... 
         Well, it was too slow. It was extremely delayed since the script had to go through the entire 
         process. Another issue was the remote events. I found out that each player having their own remote 
         event is redundant, and so I removed each from having their own and instead made a global remote
         event, which actually fixed a client-server-client communication issue I was having earlier. I
         decided to apply this switch since the receiving system was too slow. While this one was faster, it
         was still way too slow. Then I began to apply a :Connect to when the player's health changes,
         inside the :Connect would check how much damage the player received, then would supposively
         play the correct receiving animation depending on what animation the player got hit with. That's
         where I am now and it's doing fantastic. One minor and stupid issue that i'm having is the remote
         event on the server is receiving the signal from the client twice for damage. This is odd, and
         caused me to divide the damage in half - until I figure out why this is happening.
         
       - What I intend to do: Figure out a way for the server to stop receiving the signal twice - it is only
       being sent once. Then I would restore the old damage values back to what it once, make the player
       do the correct receiving animations after calculating how much damage the player took on the client,
       and if all goes well and as planned, that should wrap up the receiving system for players.
       
       Then I can return back to the attacking system and update the animations to move via tween and not by
       the actual animation themselves. Finish off standard attack animations - will only need to add the
       haymaker for the left hook for this, them add variation animations - uppercuts, jabs etc - as level 1
       attacks .. maybe add variations for level 2's. After that I can begin working on executions and
       finishers.
       
      5/25/24
     
      - What I was working on: I figured out what caused the issue. It would fire for how many clients were
      connected to the server, so I thought that was weird. Then as I looked deeper, I realised the :Connect
      for the event receiver on the server was inside the .PlayerAdded function. This means it would fire for
      every client in the server to the server. So I simply moved the remote event receiver outside the player
      function, solving that issue. Also I figured out a pretty fast way to play a receiving animation. It
      plays very smooth on the client, but a little delayed on the server. 
      
      - What I intend to do: I plan to look into this next time, God willing, and see if it is fast enough or 
        if I should return to the :Connect for the client's health.

	  6/1/24
	 
	  - What I was working on: Began updating the hook animations as there was delaying problems with hit-
	  receiving. Finished both which both animations run and look very fine! Added a 'StartOfAttack' marker
	  that I use to allow the attack to do damage and animate. However, there are a couple issues:
	  	1. As mentioned, animations are delayed for the other players but runs on time on the client. So to
	  'speed up' the receive animation, I moved the frames up to the start (whereas before it was synced
	  with the hit. Check the left hook animation in moon animator to see what I mean), but this causes the
	  animation to run too early somehow on the client. Looks better from the view of the attacking player
	  but still a little delayed.
	  	2. Haymaker won't register a hit. Afterwards, if the player were to attack, it will cause damage that
	  	the haymaker should have. This is because of the strategy I use to wait for the attackFrames variable
	  	to turn true. It repeats wait() until true, so when the player haymakers, the attackFrames don't
	  	cause an attack (probable due to the attackFrames not being true), and then when the player would
	  	supposively attack again, they will take haymaker damage. So this approach needs fixed.
	 
	- What I intend to do: Fix the couple issues listed above, with attackReceiver timing and all, and also
	  with the haymaker bug. Then if those two things are fixed, I could go back to finishing & refining
	  the attacking system of the game, then I could move on to blocking and then the rest, then publish the
	  game (hopefully) or do a beta.
	  
	6/4/24
	
	- What I was working on: Little changes, but I added the 'StartOfAttack'
	  marker to the haymaker and that seems to solve this issue.. except
	  there may be a chance the player attackframes ends, they hit an enemy,
	  then the next attack they do will deal damage to the enemy even when
	  the player is afar. I need to find an efficient way to solve this bug.
	  Speaking of the haymaker, I sorta refined it (may need some small
	  changes but looks good!) Because I gave the player the abiliy to
	  'attack cancel' (its a followup combo if they do) I had to check
	  if the animation playing currently is a level 2, and if so it will
	  reset the combo, but the player will still have the opportunity
	  to follow up with an attack.
	  
    - What I intend to do: Same as before, find a better method to use
    attack frames, and also fix hit delay (if I can) then move on to the
    attacking system of the game, then to blocking, etc, release via beta
    or full release. boom.
          
    6/5/24
    
    - What I was working on: With a small alteration to the repeat function for
    attack frames, I (think) I fixed that no-hit issue.. so the player will only
    do damage when they collide their arms and legs with the enemy. Also moved the
    keyframes of the right hook and right haymaker to the beginning of the
    Moon Animator moon2 animation track, which creates the best result for reactions.
    Refined the haymaker received animation, and made it not move in the animation,
    but instead from a tween. Slowed the player down when they are blocking. Not
    currently working on blocking but decided why not add it now. Speaking of tween,
    I tween the player when they get hit with a right haymaker 2 studs back, in synch
    with the right haymaker received back distance from animating. Changed the attack
    functionality into an attack() function because to fix the issue with the player
    needing to "spam" the attack button to follow up with an attack (will be
    explained in the 'what I intend to do section of today'). An issue I ran into
    was when the enemy tweens, the player's center-lock doesn't change with the
    tween, causing the player to not be able to hit the enemy, since the game thinks
    it's still in the same spot.
    
    - What I intend to do: Figure out how to synch player hit distance with the
    hit tween of the right haymaker received animation. Also, picking up from
    the attack() function, I made it a function so the player wouldn't have to 'spam'
    the attack button to throw a follow-up hit. My plan to achieve this is to make
    it a function (I already did), then if the player presses attack after the
    marker for :GetMarkerReachedSignal("EndOfAttack") has been reached, then they
    will throw a follow-up attack. This is because even though the attack has ended,
    the player still has animation playing when it ends, finishing the attack. Or,
    make it trigger a certain time after StartOfAttack has played, or make a new
    marker for when they can register a follow-up attack and it'll play when the
    EndOfAttack marker hits. Then they will automatically attack after it ends.
    That is my plan to increase the window for the player to attack without the need
    to spam the button or key.
    
   6/10/24
   
   - What I was working on: On a haymaker, I successfully tweened the enemy back in
   synch with the animation. Also, if the player attacks again after the
   :GetMarkerReachedSignal("StartOfAttack") fires, they will do a follow-up attack
   after the previous attack ends. I also fixed the issue where the center-lock
   doesnt change when the enemy tweens. All I had to do was referace the raycast
   instance (which is the enemy), whereas I was referancing the instance where it
   originally happened. Now the attacking system is working really good!
   
   - What I intend to do: I need to add another haymaker animation for the left arm,
     create jabbing animations which will share the hook received animations for the
     enemy, create uppercuts for the left and right arm, which will have their own
     recieved animations (because the enemy head will be going up). These uppercuts
     will only be avaliable on a follow-up attack. Maybe create overhands for level
     2 attacks, or not who knows. Then I will check on the lock-on system for
     micrsoft to do and check the boxes. If all is well, I will move on to the
     blocking system.
     
   6/24/24
   
   - What I was working on: I implimented a left haymaker and it's receiver into
     the animations. I endd off working on the left jab, its pretty awkwar d right
     now and needs work. The jabs will have the same receiving animations as the
     hooks.
     
   - What I intend to do: Fix & finish up the jab animations, then begin working on
   uppercuts. After that, I will begin working on the blocking mechanic.
   
   6/25/24
   
   - What I was working on: Created both jab animations. Also added the
   "AttackSeries" attribute to the lvl. 1 attacks. This is used when randomly
   picking what series (jabs, hooks, uppercuts) to pick when attacking. The player
   will perform a series of attacks per combo. It will randomly choose after the
   combo ends. Also began creating uppercuts, which are going to be used as a
   follow-up attack series after finishing a combo.
   
  - What I intend to do: Finish the uppercuts & add to attacks, refine attacks soon,
  	and begin working on blocking. I'm thinking when both players are locked on,
  	if the enemy were to strike the player while the player was blocking, a raycast
	will send out from the player, or the player will get the enemy information on
	lock-on. Either way, the player's scripts will know when the enemy attacks are
	coming in, so while the player is holding blocking and the enemy presses attack,
	the player will play a 'brace' animation, and the enemy's attack will change to
	synch with the brace. And if the player isn't holding block and they block early
	enough to where they won't parry, the player will play a brace on impact while
	the enemy will not have their attack altered to adapt. For counters it will
	basically be attacking right before the enemy strike lands. There will be a new
	animation event called something like 'counterFrames' to where if the player would
	receive an attack while they are just starting their first attack in a combo,
	the player will perform a counter, which will give them a frame advantage after
	the counter ends.
  
  6/26/24
  
  - What I was working on: I implemented uppercuts into the attacks. They can only
  	play on a followup combo. I also changed the method on the players first attack
  	when they spawn in. I pulled each animation of the randomly-selected
  	attack series into a table called randAttackTABLE amd then chose a random index
  	number from that table. This prevents the player from throwing anything but the
  	last attack, which could be a disadadvantage if players catch on to that.
  	
  - What I intend to do: Before I move onto the blocking & countering system, I
  	want to add a small chance during a combo for the player to throw the same
  	level 1 for jabs and hooks. I'm not sure if it would look good with uppercuts
  	but it's a maybe. I also notice the jabbing animations may need to be refined.
  	I noticed that the receiving attacks (particularly lvl 1's) are too long as the
  	player could attack before the receiving animation ends, which could ruin the
  	aesthetic of the fighting, so I would need to shorten the receiving animations.
  	Then after that I could finally move onto the blocking & countering system.
  	
  6/29/24
  
  - What I was working on: Added a 10% chance for the player to throw the same
  lvl. 1 attack back-to-back in a combo, except for uppercuts. Refined the jabbing
  animations and they look good now, made lvl. 1 receiving attacks faster because
  combos are fast. Then I moved onto the blocing & countering system. I created a
  FC_BlockStart animation, which is the startup animation for when the player begins
  to block, them I refined the already-existing blocking animation. The startup
  blocking animation will run when the player blocks, and when the startup ends the
  player will begin playing the looped block animation. I was last figuring out how
  to apply parries and synched blocking.
  
  - What I intend to do: For synched blocking, I'm thinking that both player and 
  enemy will detect when the other is either attacking while the other is holding
  block. For example, if the player is holding block, the player code will detect 
  when the enemy attacks, and the enemy code will know when the enemy throws an 
  attack that the player is blocking. So in that moment of recognition from both 
  parties, the synched block will play by each playing their part of the animation.
  Then for parries, it's just the player pressing block right before the enemy lands
  an attack, which is the same for countering except the player will attack right
  before an incoming attack lands, not block. Also, counters will give frame
  advantage, as well as parries but not as much.
  
  7/1/24
  
  - What I was working on: By locking onto an opponent, I made it where the specific
  	opponent who is locked on is tracked. When the player throws an attack, The
 	protocol will be sent to the opponent, and when the player holds block, a
 	protocol will also be sent to the enemy, so a synched block would be possible.
 	Started a function called synchedBlock which will check if the player is either
 	blocking or attacking before understanding who does what in the synched block.
 	If the player attacks an opponent and they are holding block, there will be
 	code at the beginning of the attack() function that will say 'first of all, is
 	the enemy holding block, and if so we want to perform a synched block. If not,
 	we can attack as usual.'
 	
  - What I intend to do: Create my first synched block animation, and also a
  	followup synched block if the player were to attack twice in a synched block.
  	After that, when the synchedBlock function runs, both opponents will be locked
  	in the synched block and do their own synched animation until it ends.
  	
  7/3/24
  
  - What I was working on: Created the first animation and sorta applied it. The
  syncBlock() function will tell if its an attack or block and act accordingly to
  each player. Currently trying to figure out how to tween the player 3 studs from
  the facing diraction of the enemy.
  
  - What I intend to do: tween the player whos attacking 3 studs from the look
  direction of the enemy, make a followup sync block if the player decides to attack
  twice while the enemy is holding block. Then deal slight damage to the blocker,
  which would of been substantially more damage if they werent blocking. After that,
  move onto parries, UNLESS I make more sync block animations.
  
  7/6/24
  
  - What I was working on: I finally properly tweened the player to attack forward
  if they are need to get closer for a sync block. However the player isn't always
  the same 3 studs away each time... Something I may need to fix. Anyways I also
  made the player stop moving when attacking. I was able to get the tween to work
  by stopping the constant CFrame:lookAt() function that ran for lock-on. I last
  ended off trying to make a followup sync block.
  
  - What I intend to do: Implement a followup sync block, maybe another paired sync
  block animations should be added, then move onto parries and counters and then the
  rest of the stuff.
  
  7/8/24 (18th birthday!)
  
  - What I was working on: After some time I finally figured out how to get the
  	tween to work properly. In short, I created a new CFrame with the enemy's
  	position subtracted by the normalized direction (direction.Unit), multiplied by
  	3. This will get the CFrame of the position, subtract it by the directional
  	unit (which in itself would be 1 stud since its a unit) then * 3 would always
  	be 3 studs away from the enemy. Then I multiplied that by a
  	CFrame.Angles(humanoidRootPart:ToOrientation()) which is the current
  	orientation of the player. This ensures the player will always be in the
  	correct orientation. And thats how I made the enemy always be in the correct
  	spot when tweening. I last ended off by creating a new synched block for the 
  	right side. It's finished for now, but it had an uploading issue, so it just
  	needs uploaded.
  	
  - What I intend to do: Upload the animations, apply it to be able to be a
  	followup/standalone, then create two more paired synch block animations
  	with hook animations to the body to have diversity in synched blocking. After
  	that, I will work on 'bracing blocks' which are when the enemy blocks before
  	the attack lands, but not late enough to be a parry. They will brace.
  	
  7/12/24
  
  - What I was working on: Uploaded the paired sync block (some sort of 
	spelling error prevented me from uploading it... weird,) and I was
	last working on a followup sync block. Having some sync issues.
	The animations are playing at different times when they are
	suppose to be playing at the same time.
	
  - What I intend to do: Figure out how to play both sync animations at
  	the same time during a sync block follow-up, and also make sure the
  	follow-up sync block system is decent as well. After that, create
  	a couple more sync block pairs for hooks to the body that are in a
  	sync block, then implement it. After that, move onto bracing
  	blocks.
  	
  7/13/24
  
  - What I was working on: Figured out why the animations weren't in sync. In short,
    the blocker would immediately block after the attacker clicks to follow up while
    the attacker has to wait until the animation is out of it's 'attacking' phase
    before stopping, so I fixed that. Also, I got the sync block to be in good
    function as of now. Players are frozen in place as they do it 3 studs apart.
    I last ended off starting the next two sync block paired attacks (for 
    diversity).
    
   - What I intend to do: Animate the sync blocks and implement them in. They will 
   	 be kinda like failed haymakers being blocked, so a mix of an uppercut and a 
   	 hook, going to the body that will be sync blocked for left and right. Once
   	 implemented, I can go work on bracing blocks, then after that, parries.
   	 
  7/16/24
  
  - What I was working on: Animated the sync blocks for body shots and began to
  	apply them. However, I'm having issues randomizing the attacks to play the
  	correct attack/receive animation: Currently, its playing the same pair twice
  	on a follow up.
  	
  - What I intend to do: Get the randomization to work, fix a small issue with
  	attacking after the chained sync block ends (enemy would play a received animation
  	even though player didn't attack). After that, find other bugs, maybe update
  	animations for they need to be improved a little, and then I could probably move
  	onto bracing blocks. Which should hopefully be easier.
  
  7/17/24
  
  - What I was working on: I got the randomization of sync blocks to work, and even
  	fixed the issue with a syncBlock playing for the enemy after the 2 chain
  	sync blocks play. Currently, I'm dealing with an issue of the chained sync
  	blocks not ending at 2, and also spamming mouse doesn't let the chained sync
  	blocks work, unlike normal attacking.
  	
  - What I intend to do: Create a short delay after two players have 2 sync blocks
  	in a chain to give both players a delay so the attacker can rethink instead
  	of just spamming attack on a blocking opponent, and also allow the mouse
  	spamming to work with chain sync blocks, just like the normal attacks. After
  	that, check for any other bugs. One bug I noticed was when the enemy blocks,
  	the player will adjust their attacks to the sync block, but if the enemy
  	drops their block, the player will still perform sync blocks. This can easily
  	be fixed by tracking on the release of left click (or the blocking button on
  	other platforms), to send a remote event to the other player that they are no-
  	longer blocking.
  	
  7/20/24
  - What I was working on: Tried creating a short delay with sync block but it seems
  	to not be working properly. It delays, but it required me to not allow the
  	player to attack at all if they have 2 sync blocks - that will need chanded.
  	Also, spamming mouse breaks the sync block process and need to fix it like I
  	did with normal attacks.
  	
  - What I intend to do: Fix the delay issue, allow mouse spamming for sync blocks,
  	make player do normal attacks again when enemy drops guard.


  7/21-22/24 (Switching to OOP)
  
  - What I was working on: Alright so I was completely overwhelmed with how many lines of code were in my single local
    script, let alone the server one as well (wasnt as bad as my client script thom which had over 1100+ lines! Yikes!), so I thought to re-organize my code into multiple scripts instead of just a single local and server script. I also decided to switch to VSC since this project is seemingly bigger than I thought. So far, I added the LockOnSystem script (for when the player presses Q... basically the entire LockOnDebounce variable detection part of my code), and also the UserInput as well. The code isn't really implemented yet as I am trying to figure out client-based communication with a module script involved. Speaking of, I added a module script called GameVariables. This is where all of my variables that the other local scripts depend on will live. These scripts will pull and use from the module's variables as they need. But the issue is I'm trying to get local changes to sync with the rest of the scripts. I tried a remote event first (didn't work because I was trying to use the OnClientEvent from a module that was client-based, which only servers can do), and I last ended off trying to use a bindable event.
  
  - What I intend to do: Hopefully get the bindable event to work with local synchronization for variable changes, then add the rest of the code in various scripts (organized like the OOP way), and hopefully continue where I left off before the OOP reboot.

  7/26/24

  - What I was working on: I actually got the scripts split up and working! It took awhile to figure out, but yeah it wasn't that bad! In fact, I didn't even need a sync() function, as module scripts sync automatically. I split up those two giant local and server scripts into many scripts. I divided the old local script into 4 nice scripts, and split the server script into 2. All of the variables for the local scripts rest inside the GameVariables module script. There is one small issue though: The module script will
  only work for one client at a time as of now, and cloning the script is very bad practice and can cause other issues as well. Because it only works with one client, sync blocking doesn't work until it gets fixed.

  - What I intend to do: Make the script compatable with all clients in a server, then it should be able to work properly. After that, continue where I left off with uh... mouse spamming for sync blocking and making players do normal attacks after the enemy drops their guard... ahahaha!

  7/27/24

  - What I was working on: Didn't even need to add compatability to the module scripts, there just was a duplicate of the init script that acted as the "server" script where all the VSC server files are, but I got rid of that by renaming my script from 'Init' to 'Initial'. That fixed my problem, and I'm right back to where I was before. I began working on the system which allows the player to spam attack during sync block and it will do multiple sync blocks. I believe I got that working, so spamming is no problem. However, now I'm having issues with WHEN a player is allowed to do a followup sync block attack. I started by making it when the attack starts up, but that turned out to be too late of a time for the player, as the other variables that allow a followup attack deny the player by the time they reach the 'StartOfAttack' animation event. So, I made a new animation event for this specific purpose called Anti_Followup which the point is that's the frame where the player is no longer allowed to do a followup. I set it between StartOfAttack and EndOfAttack. But now the problem is that attacks completely break after reaching those events, and it may not even be detecting the events.

  - What I intend to do: Find a way to get the anti_followup situation working, then make sure the sync block system is working as intended. Then fix the small issue with the player doing sync block attaks after the enemy dropps their guard, which sounds like an easy remote event fix. After that, move onto Bracing Blocks.

  7/29-30/24

  - What I was working on: Finally got the sync block system working right now as it should. I sped up the sync block pairs becaused they seemed a bit slow. I also fixed the issue with the player doing sync block attacks even after the enemy dropped their guard, was a simple change to the remote event that fired to the server. I can confidently say I'm nearly done with sync blocks.
  
  - What I intend to do: There is one last thing I want to add though: A third followup sync block pair. I may add either 2 different kinds or 4 (if I want to be unique to each sync block attack.) This third attack may simply be a third attack to the enemy's block, or it may push their character back a little. Speaking of momentum, I'm thinking of implementing a ragdoll-like system where the player will wobble in a ragdoll-y sort of way when hit, or just ragdoll to the ground after getting hit while airborne (or if they also just get killed). I must figure out how to do that, and I may just ask co-pilot to guide me on how to do it.

  8/1/24

  - What I was working on: Decided I'm going to add two different types of thirdhand synced blocks, which will be 4 animation pairs total. The first pair will be for dodging/evading the third hit while the second will be blocking it in a way where it repells the enemy's attack. I created all except the last pair, which will be FC_SyncBlock3R2. I will apply it to the game once its done. However, I'm having a small issue getting it to play. Sending it through the sync block function, I have two parameters: sentAnimPair (the index numbers) and followupCombo (the players current combo). It seems the receiver thinks the followup is a different number that the attacker things it is (ex. 3 when its really 4). The thirdhand sync block animations arent playing oddly either, so I will need to get that working.

  - What I intend to do: Get the 3rd sync block animations to work, add the ragdoll system, then hopefully finally move to the bracing blocks segment of my game.

  8/20/24

  - What I was working on: Not done an update in awhile, but basically throughout this time, I got sync blocks done. Finally! It was more complicated than I thought, but other than possibly tweaking values and stuff or changing/adding animations in the future, I'm basically done. But before I decided to move onto bracing blocks, I wanted to scratch the itch that my game didnt work after the player respawned. So, I added a .CharacterAdded event to the GameVariables file and re-initialized variables when the player respawned to get the game to work on respawn. This fixed many things, but then animations still weren't working. I then also added the animation track folders in the .CharacterAdded event so it will be re-initialized on respawn, which definitely helped. The player can now throw 1 attack after respawn. So this means the animations are working fine.

  - What I intend to do: Find out why the player can't throw more than 1 attack on respawn, make sure everything else is working fine after the player respawned, and eventually start working on bracing blocks.

  8/25/24

  - What I was working on: Found out how to get the player to throw more than 1 attack after respawn. All we had to do was crate some functions such as basically the entire animationManager script, then call that after defining it, and call it again when the player respawns. Also added a wait() statement at the beginning of these functions to allow the player time to load things in. If I was wanting to be more professional, I could make a script that waits for all of the variables to load before allowing these functions to run. But the wait() is simple and did the job. Now, I finally moved onto bracing blocks. I created two animations, one for bracing left and one for bracing right, depending on what attack the enemy threw. If they threw a left punch, then we brace right because our lefts and rights are opposite when facing each other. I was last trying to make the isEnemyHoldingBlock animation being sent to the attacker only work if they are not being attacked as they are brace-blocking.

  - What I intend to do: Figure out how to get that attribute to only send & work if they are not under pressure while brace-blocking. Then we can pretty much move onto the parry mechanic.

  8/29/24

  - What I was working on: Brace-blocking is working out pretty well, but there are some errors that appear, particularly when we block too early to where it becomes a sync block. Decided I was gonna add functionality to the TestDummy so I can test these things on it as if it was a real player, and save some time.
  
  - What I intend to do: Last made a UI that will only appear when locking on with the dummy, and gonna finish its functionality

  9/8-9/24

  - What I was working on: Leaving the test dummy stuff for parrys. Got the parry animations done, and got the remote event code ready. Was last making a check for what kind of attack the enemy threw that affected the damage type when the remote event runs, such as A1 or A2 damage.

  - What I intend to do: Get the damage types done, get parry damage, make the player unable to move when parrying, make a receiving parry animations, give player frame advantage, but not too much so the enemy can block the riposte, and move on to counters hopefully.

9/19/24

- What I was working on: Created receive parry anims, and implemented. Parries are having some issues with attacking after the parry. The enemy char may try to continue chain which it shouldnt.

- What I intend to do: Make sure there is no chains after getting parried, both chars can play normally after a parry, frame advantage for parrier, and then move to counters hopefully.

10/7/24

- We need to reorganize I feel. Start taking a heavy OOP approach, break down our code into understandable chunks, and very importantly: SET DUE DATES FOR CODE!!! Perhaps take an agile

10/8/24

- Ended off adding the .Attack() function of basic striking into when player presses MB1 on the client script. I plan to implement the rest and resume like before.