-- Undo

require "vector"
local Constants = require("constants")

ButtonClass = {}

BUTTON_STATE = {
  IDLE = 0,
  PRESSED = 1,
}

function ButtonClass:new()
  local button = {}
  local metadata = {__index = ButtonClass}
  setmetatable(button, metadata)

  button.position = Vector(Constants.BUTTON_X, Constants.BUTTON_Y)
  button.size = Vector(Constants.BUTTON_WIDTH, Constants.BUTTON_HEIGHT)
  button.state = BUTTON_STATE.IDLE

  return button
end

function ButtonClass:update(dt)

end

function ButtonClass:draw()
  if self.state ~= BUTTON_STATE.PRESSED then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("fill", 330 + 3, 80 + 3, 70, 50, 6, 6)
    love.graphics.rectangle("fill", 330, 80, 70, 50, 6, 6)
    -- love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", 330, 80, 70, 50, 6, 6)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("UNDO", 346, 97)
  else 
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", 330 + 3, 80 + 3, 70, 50, 6, 6)
    love.graphics.setColor(0, 0, 0, 1)

    love.graphics.print("UNDO", 346 + 3, 97 + 3)
  end
end

function ButtonClass:checkForMouseOver(mousePos)
  return mousePos.x > self.position.x and
         mousePos.x < self.position.x + self.size.x and
         mousePos.y > self.position.y and
         mousePos.y < self.position.y + self.size.y
end

function ButtonClass:mousePressed()
  self.state = BUTTON_STATE.PRESSED
  return true
end

function ButtonClass:mouseReleased()
  if self.state == BUTTON_STATE.PRESSED then
    self.state = BUTTON_STATE.IDLE
  end
end