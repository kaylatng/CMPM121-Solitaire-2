-- Sound

require "vector"
local Constants = require("Constants")

SoundClass = {}

SOUND_STATE = {
  ON = 0,
  OFF = 1,
}

function SoundClass:new()
  local sound = {}
  local metadata = {__index = SoundClass}
  setmetatable(sound, metadata)

  sound.position = Vector(Constants.SOUND_X, Constants.SOUND_Y)
  sound.size = Vector(Constants.SOUND_WIDTH, Constants.SOUND_HEIGHT)
  sound.state = SOUND_STATE.ON

  return sound
end
