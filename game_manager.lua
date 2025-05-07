-- Game Manager

require "card"
require "vector"
require "pile"
require "grabber"
require "helper"

GameManager = {}

function GameManager:new()
  local game = {}
  local metadata = {__index = GameManager}
  setmetatable(game, metadata)
  
  game.piles = {}
  game.grabber = GrabberClass:new()
  game.isInitialized = false
  game.moves = 0
  game.won = false
  
  return game
end

function GameManager:initialize()
  -- Sanity check
  if self.isInitialized then return end
  
  for i, suit in ipairs(SUITS) do
    local foundationPile = FoundationPile:new(430 + (i-1) * 130, 30, suit)
    table.insert(self.piles, foundationPile)
  end

  for i = 1, 7 do
    local tableauPile = TableauPile:new(40 + (i-1) * 130, 220, i)
    table.insert(self.piles, tableauPile)
  end

  local wastePile = WastePile:new(170, 30)
  table.insert(self.piles, wastePile)

  local stockPile = StockPile:new(40, 30, wastePile)
  table.insert(self.piles, stockPile)

  local deck = self:createDeck()
  self:dealCards(deck, self.piles)

  self.isInitialized = true
end

function GameManager:createDeck()
  local deck = {}

  for _, suit in ipairs(SUITS) do
    for _, value in ipairs(CARD_VALUES) do
      local card = CardClass:new(suit, value, 0, 0, false)
      table.insert(deck, card)
    end
  end

  for i = #deck, 2, -1 do
    local j = math.random(i)
    deck[i], deck[j] = deck[j], deck[i]
  end

  return deck
end

function GameManager:dealCards(deck, piles)
  local tableauPiles = {}
  local stockPile = nil

  for _, pile in ipairs(piles) do
    if pile.type == "tableau" then
      table.insert(tableauPiles, pile)
    elseif pile.type == "stock" then
      stockPile = pile
    end
  end

  table.sort(tableauPiles, function(a, b) return a.index < b.index end)

  for i, pile in ipairs(tableauPiles) do
    for j = 1, i do
      local card = table.remove(deck)
      if j == i then
        card.faceUp = true
      end
      pile:addCard(card)
    end
  end

  for _, card in ipairs(deck) do
    stockPile:addCard(card)
  end
end

function GameManager:update(dt)
  if self.won then return end

  self.grabber:update(dt)

  for _, pile in ipairs(self.piles) do
    pile:update(dt)
  end

  if self:checkForWin() then
    self.won = true
  end
end

function GameManager:draw()
  for _, pile in ipairs(self.piles) do
    pile:draw()
  end

  for _, card in ipairs(self.grabber.heldCards) do
    card:draw()
  end

  love.graphics.setColor(1, 1, 1, 1)

  love.graphics.setColor(1, 1, 1, 1)
  -- love.graphics.print("Mouse: " .. tostring(self.grabber.currentMousePos.x) .. ", " .. tostring(self.grabber.currentMousePos.y))
  love.graphics.print("Moves: " .. tostring(self.moves), 0, 0) -- y = 15

  if self.won then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("You Win!", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    love.graphics.printf("Press 'R' to play again", 0, love.graphics.getHeight() / 2 + 80, love.graphics.getWidth(), "center")
  end

end

function GameManager:mousePressed(x, y, button)
  local mousePos = Vector(x, y)

  if self.grabber:isHoldingCards() then
    local targetPile = nil

    for _, pile in ipairs(self.piles) do
      if pile:checkForMouseOver(mousePos) then
        targetPile = pile
        break
      end
    end

    if self.grabber:tryRelease(targetPile) then
      self.moves = self.moves + 1
    end
    return
  else -- not holding cards
    for _, pile in ipairs(self.piles) do
      if pile:checkForMouseOver(mousePos) then
        if pile.type == "stock" then
          if pile:onClick() then
            self.moves = self.moves + 1
          end
          return
        end
  
        local card = pile:getCardAt(mousePos)
        -- print("CARD: " .. tostring(card.suit).. " " .. tostring(card.value))
        if card then
          if self.grabber:tryGrab(card, pile) then
            -- TO-DO
          end
          return
        end
      end
    end
  end
end

function GameManager:mouseReleased(x, y, button)
  if self.grabber:isHoldingCards() then
    local mousePos = Vector(x, y)
    local targetPile = nil

    for _, pile in ipairs(self.piles) do
      if pile:checkForMouseOver(mousePos) then
        targetPile = pile
        break
      end
    end

    if self.grabber:tryRelease(targetPile) then
      self.moves = self.moves + 1
    end
  end
end

function GameManager:checkForWin()
  local foundationPiles = {}
  
  for _, pile in ipairs(self.piles) do
    if pile.type == "foundation" then
      table.insert(foundationPiles, pile)
    end
  end
  
  -- Check if all foundation stacks have 13 cards
  for _, pile in ipairs(foundationPiles) do
    if #pile.cards < 13 then
      return false
    end
  end
  
  return true
end
