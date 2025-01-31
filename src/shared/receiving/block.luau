--[[

* This script causes the character to block in some way to mitigate damage.

* The character can do a bracing block, which is when they block right
  before an attack lands, and makes them 'brace' when the attack lands

* They can also do a synced block, which is when they are holding the
  block button and the character and enemy do syncronized animations
  of them attacking/blocking

]]

local Block = {}
Block.__index = Block

return Block