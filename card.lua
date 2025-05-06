-- Spritesheet code: https://love2d.org/forums/viewtopic.php?t=93682

-- Card

require "vector"
local Constants = require("constants")

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  MOUSE_OVER = 1,
  GRABBED = 2,
}

SUITS = {"clubs", "spades", "diamonds", "hearts"}
CARD_VALUES = {"ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"}

local cardSpritesheet, spritesheet = nil

function CardClass:loadSpritesheet()
  cardSpritesheet = love.graphics.newImage("assets/card_spritesheet.png")
  return cardSpritesheet
end

function CardClass:new(suit, value, xPos, yPos, faceUp)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.suit = suit
  card.value = value
  card.position = Vector(xPos, yPos)
  card.targetPosition = Vector(xPos, yPos)
  card.size = Vector(Constants.CARD_WIDTH, Constants.CARD_HEIGHT)
  card.state = CARD_STATE.IDLE
  card.dragOffset = Vector(0, 0)
  card.zOrder = 0
  card.solved = false
  card.faceUp = faceUp or false

  return card
end

function CardClass:update(dt)
  local x, y = love.mouse.getPosition()
  if self:containsPoint(x, y) then
    self.state = CARD_STATE.MOUSE_OVER
  elseif not self:containsPoint(x,y) then
    self.state = CARD_STATE.IDLE
  end

  -- Delay movement when let go
  if self.state ~= CARD_STATE.GRABBED then
    local distance = self.targetPosition - self.position
    if distance:length() > 1 then
      self.position = self.position + distance * 10 * dt
    else
      self.position = Vector(self.targetPosition.x, self.targetPosition.y)
    end
  end
end

function CardClass:draw()
  if not spritesheet then 
    spritesheet = self:loadSpritesheet()
  end
  
  -- Draw drop shadow for non-idle cards
  if self.state ~= CARD_STATE.IDLE then
    -- print("suit: " .. tostring(self.suit) .. " value: " .. tostring(self.value))
    love.graphics.setColor(0, 0, 0, 0.5) -- color values [0, 1]
    local offset = 4 * (self.state == CARD_STATE.GRABBED and 2 or 1)
    love.graphics.rectangle("fill", self.position.x + offset, self.position.y + offset, self.size.x, self.size.y, Constants.CARD_RADIUS, Constants.CARD_RADIUS)
  end
  
  love.graphics.setColor(1, 1, 1, 1)
  
  local quad
  if self.faceUp then
    local cardSuit = findIndex(SUITS, self.suit) - 1
    local cardValue = findIndex(CARD_VALUES, self.value) - 1
    
    local x = cardValue * Constants.CARD_WIDTH
    local y = cardSuit * Constants.CARD_HEIGHT
    
    quad = love.graphics.newQuad(x, y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT, spritesheet:getDimensions())
  else
    local x = 13 * Constants.CARD_WIDTH
    local y = 2 * Constants.CARD_HEIGHT
    
    quad = love.graphics.newQuad(x, y, Constants.CARD_WIDTH, Constants.CARD_HEIGHT, spritesheet:getDimensions())
  end
  
  love.graphics.draw(spritesheet, quad, self.position.x, self.position.y)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", self.position.x, self.position.y, self.size.x, self.size.y)

  -- Print card state
  love.graphics.print(tostring(self.state), self.position.x + 50, self.position.y - 20)
end

-- function CardClass:flip()
--   if self.solved ~= true then
--     self.faceUp = not self.faceUp
--   end
-- end

function CardClass:setFaceUp()
  if not self.solved then
    self.faceUp = true
  end
end

function CardClass:setFaceDown()
  if not self.solved then
    self.faceUp = false
  end
end

function CardClass:setSolved()
  self.faceUp = true
  self.solved = true
end

function CardClass:checkForMouseOver(grabber)
  if self.state == CARD_STATE.GRABBED then
    return false
  end

  local mousePos = grabber.currentMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and
    mousePos.x < self.position.x + self.size.x and
    mousePos.y > self.position.y and
    mousePos.y < self.position.y + self.size.y

  if isMouseOver then
    self.state = CARD_STATE.MOUSE_OVER
    return true
  else
    self.state = CARD_STATE.IDLE
    return false
  end
end

function CardClass:containsPoint(x, y)
  return x > self.position.x and
  x < self.position.x + self.size.x and
  y > self.position.y and
  y < self.position.y + self.size.y
end

function CardClass:setGrabbed(grabber)
  self.state = CARD_STATE.GRABBED
  self.dragOffset = self.position - grabber.currentMousePos
  self.zOrder = 52  -- Bring to front while dragging
end

function CardClass:release()
  self.state = CARD_STATE.IDLE
end

function CardClass:moveWithMouse(mousePos)
  if self.state == CARD_STATE.GRABBED then
    self.position = mousePos + self.dragOffset
  end
end

function CardClass:isRed()
  return self.suit == "diamonds" or self.suit == "hearts"
end

function CardClass:isBlack()
  return self.suit == "clubs" or self.suit == "spades"
end

function CardClass:getValue()
  local values = {
    ace = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["10"] = 10,
    jack = 11,
    queen = 12,
    king = 13
  }
  
  return values[self.value]
end

function findIndex(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return i
    end
  end
  return nil
end