-- Helper funcs

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do u[k] = v end
  return u
end

function table.shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function drawRoundedRect(x, y, width, height, radius)
  love.graphics.rectangle("fill", x, y, width, height, radius, radius)
end

function isPointInRect(x, y, rx, ry, rw, rh)
  return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

function getCardColor(suit)
  if suit == "hearts" or suit == "diamonds" then
    return "red"
  else
    return "black"
  end
end

-- removed getValue function
