-- Kayla Nguyen
-- CMPM 121 - Klondike Solitaire, But Better
-- 5-7-25

-- Main

io.stdout:setvbuf("no")

require "card"
require "grabber"
require "pile"
require "game_manager"

function love.load()
  love.window.setMode(960, 640)
  love.window.setTitle("Klondike Solitaire, But Better")
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1) -- green
  
  -- math.randomseed(os.time())
  
  game = GameManager:new()
  game:initialize()
end

function love.update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
end

function love.mousepressed(x, y, button)
  game:mousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
  game:mouseReleased(x, y, button)
end