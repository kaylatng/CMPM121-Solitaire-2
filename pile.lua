-- Pile

require "vector"
local Constants = require("constants")

PileClass = {}

local suitImage = nil

function PileClass:loadSuit(suit)
  return love.graphics.newImage("assets/" .. tostring(suit) .. ".png")
end

function PileClass:new(x, y, type)
  local pile = {}
  local metadata = {__index = PileClass}
  setmetatable(pile, metadata)
  
  pile.position = Vector(x, y)
  pile.cards = {}
  pile.type = type or "default" -- Possible types: tableau, stock, foundation, waste
  pile.size = Vector(Constants.PILE_WIDTH, Constants.PILE_HEIGHT)
  pile.verticalOffset = 30  -- Offset tableau piles only
  
  return pile
end

function PileClass:update(dt)
  for i, card in ipairs(self.cards) do
    card:update(dt)
  end
end

function PileClass:draw()
  -- Outline
  love.graphics.setColor(0, 0, 0, 0.3) -- 1, 1, 1 white
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", self.position.x - Constants.PADDING_X, self.position.y - Constants.PADDING_Y, self.size.x, self.size.y, Constants.PILE_RADIUS, Constants.PILE_RADIUS)
  
  if self.type == "foundation" then
    love.graphics.rectangle("fill", self.position.x - Constants.PADDING_X, self.position.y - Constants.PADDING_Y, self.size.x, self.size.y, Constants.PILE_RADIUS, Constants.PILE_RADIUS)

    local color = {0, 0, 0, 0.4}
    if not suitImage then
      suitImage = self:loadSuit(self.suit)
    end
      
    love.graphics.setColor(color)
    love.graphics.draw(suitImage, self.position.x - Constants.CARD_WIDTH/4, self.position.y - Constants.CARD_HEIGHT/4 - 5, 0 , 1.5, 1.5)
    suitImage = nil
  end

  -- Cards
  for i, card in ipairs(self.cards) do
    card:draw()
  end
end

function PileClass:addCard(card)
  table.insert(self.cards, card)
  self:updateCardPositions()
  return true
end

function PileClass:removeCard(card)
  for i, pileCard in ipairs(self.cards) do
    if pileCard == card then
      table.remove(self.cards, i)
      self:updateCardPositions()
      return true
    end
  end
  return false
end

-- merged all functions to main pile class
function PileClass:updateCardPositions()
  if self.type == "foundation" then
    for i, card in ipairs(self.cards) do
      card.targetPosition = Vector(self.position.x, self.position.y)
    end

  elseif self.type == "tableau" then
    for i, card in ipairs(self.cards) do
      card.targetPosition = Vector(
        self.position.x,
        self.position.y + (i - 1) * self.verticalOffset
      )
      -- Reasign z position
      card.zOrder = i
  
      -- TO-DO: card prematurely flips
      if i == #self.cards then
        card.faceUp = true
      else
        card.faceUp = false
      end
    end
  
    if #self.cards > 0 then
      local topCard = self.cards[#self.cards]
      if not topCard.faceUp then
        topCard.faceUp = true
      end
    end

  elseif self.type == "stock" then
    for i, card in ipairs(self.cards) do
      card.targetPosition = Vector(self.position.x, self.position.y)
      card.faceUp = false
    end

  else -- type == waste
    local visibleCards = math.min(3, #self.cards)

    for i = 1, #self.cards do
      local card = self.cards[i]
      local index = i - (#self.cards - visibleCards)

      if index > 0 then
        card.targetPosition = Vector(
          self.position.x + (index - 1) * self.horizontalOffset, 
          self.position.y
        )
        card.faceUp = true
      else
        card.targetPosition = Vector(self.position.x, self.position.y)
        card.faceUp = true
      end
    end
  end
end

function PileClass:getTopCard()
  if #self.cards > 0 then
    return self.cards[#self.cards]
  end
  return nil
end

function PileClass:acceptCards(cards, sourcePile)

  -- returns false if the pile cannot accept cards
  return false
end

function PileClass:checkForMouseOver(mousePos)
  return mousePos.x > self.position.x and
         mousePos.x < self.position.x + self.size.x and
         mousePos.y > self.position.y and
         mousePos.y < self.position.y + self.size.y
end

function PileClass:getCardAt(mousePos)
  for i = #self.cards, 1, -1 do
    local card = self.cards[i]
    if mousePos.x > card.position.x and
       mousePos.x < card.position.x + card.size.x and
       mousePos.y > card.position.y and
       mousePos.y < card.position.y + card.size.y then
      return card
    end
  end
  return nil
end

-- Foundation pile (takes cards in order)
FoundationPile = {}
setmetatable(FoundationPile, {__index = PileClass})

function FoundationPile:new(x, y, suit)
  local pile = PileClass:new(x, y, "foundation")
  local metadata = {__index = FoundationPile}
  setmetatable(pile, metadata)
  
  pile.suit = suit
  
  return pile
end

function FoundationPile:acceptCards(cards, sourcePile)
  if #cards ~= 1 then
    return false
  end

  local card = cards[1]
  if card.suit ~= self.suit then
    return false
  end

  if #self.cards == 0 then
    if card.value == "ace" then
      self:addCard(card)
      card:release()
      return true
    else
      return false
    end
  end

  local topCard = self:getTopCard()
  local topValue = topCard:getValue()
  local cardValue = card:getValue()

  if cardValue == topValue + 1 then
    self:addCard(card)
    card:release()
    return true
  end

  return false
end

-- Tableau pile (takes cards, offsets and faces all cards down except top)
TableauPile = {}
setmetatable(TableauPile, {__index = PileClass})

function TableauPile:new(x, y, index)
  local pile = PileClass:new(x, y, "tableau")
  local metadata = {__index = TableauPile}
  setmetatable(pile, metadata)
  
  pile.index = index
  pile.verticalOffset = 30
  
  return pile
end

function TableauPile:acceptCards(cards, sourcePile)
  if #self.cards == 0 then
    local firstCard = cards[1]
    if firstCard.value == "king" then
      for _, card in ipairs(cards) do
        self:addCard(card)
        card:release()
      end
      return true
    else
      return false
    end
  end

  local topCard = self:getTopCard() -- top of tableau
  local firstCard = cards[1] -- held card

  local top = #sourcePile.cards

  if firstCard:getValue() == topCard:getValue() - 1
    and (topCard:isRed() and firstCard:isBlack() or topCard:isBlack() and firstCard:isRed()) then
    -- firstCard:setSolved()
    -- topCard:setSolved()
    print("top card: " .. tostring(topCard.suit) .. ", first card: " .. tostring(firstCard.suit))
    for _, card in ipairs(cards) do
      self:addCard(card)
      card:release()
    end
    topCard.faceUp = true
    return true
  end

  return false
end

-- Stock pile (drawing cards from)
StockPile = {}
setmetatable(StockPile, {__index = PileClass})

local resetImage = nil

function StockPile:loadImage()
  return love.graphics.newImage("assets/reset.png")
end

function StockPile:new(x, y, wastePile)
  local pile = PileClass:new(x, y, "stock")
  local metadata = {__index = StockPile}
  setmetatable(pile, metadata)
  
  pile.wastePile = wastePile
  
  return pile
end

function StockPile:draw()
  if not resetImage then
    resetImage = self:loadImage()
  end

  love.graphics.setColor(0, 0, 0, 0.3)
  love.graphics.rectangle("line", self.position.x - Constants.PADDING_X, self.position.y - Constants.PADDING_Y, self.size.x, self.size.y, Constants.PILE_RADIUS, Constants.PILE_RADIUS)
  
  if #self.cards > 0 then
    self.cards[#self.cards]:draw()
    
    if #self.cards > 1 then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(#self.cards, self.position.x + 10, self.position.y + 10)
    end
  else
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.draw(resetImage, self.position.x, self.position.y)
  end
end

function StockPile:onClick()
  if #self.cards == 0 then
    while #self.wastePile.cards > 0 do
      local card = table.remove(self.wastePile.cards)
      card.faceUp = false
      table.insert(self.cards, card)
    end
    self:updateCardPositions()
    self.wastePile:updateCardPositions()
  else
    local cardsToMove = math.min(3, #self.cards)
    for i = 1, cardsToMove do
      local card = table.remove(self.cards)
      card.faceUp = true
      table.insert(self.wastePile.cards, card)
    end
    self:updateCardPositions()
    self.wastePile:updateCardPositions()
  end
  
  return true
end

-- Waste pile (Drawn cards go here)
WastePile = {}
setmetatable(WastePile, {__index = PileClass})

function WastePile:new(x, y)
  local pile = PileClass:new(x, y, "waste")
  local metadata = {__index = WastePile}
  setmetatable(pile, metadata)
  
  pile.horizontalOffset = 20
  
  return pile
end

function WastePile:getCardAt(mousePos)
  if #self.cards > 0 then
    local topCard = self.cards[#self.cards]
    if mousePos.x > topCard.position.x and
       mousePos.x < topCard.position.x + topCard.size.x and
       mousePos.y > topCard.position.y and
       mousePos.y < topCard.position.y + topCard.size.y then
      return topCard
    end
  end
  return nil
end
