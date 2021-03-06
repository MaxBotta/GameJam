
require('lib.slam')
local wappen = require('wappen')
local cannon = require('cannon')
local selection = require('selection')
local coundownAndRememberWappen = require('coundownAndRememberWappen')
local startmenu = require ('startmenu')

local gamestate = "start"

function love.load()
    love.window.setFullscreen(true)
    startmenu.load()
    selection.load()
    coundownAndRememberWappen.load()
    wappen.load()
    cannon.load()
    print("Window size: ", love.graphics.getWidth(), love.graphics.getHeight())
    love.keyboard.setKeyRepeat(false)
end

function love.update(dt)
  if gamestate=="start" then
    startmenu.update(dt)
    if startmenu.done() then
      gamestate = "selection"
    end
  elseif gamestate=="selection" then
    selection.update(dt)
    if selection.done() then
      gamestate = "remember"
    end
  elseif gamestate=="remember" then
    coundownAndRememberWappen.update(dt)
    if coundownAndRememberWappen.done() then
      gamestate = "spiel"
    end
  elseif gamestate=="spiel" then
    wappen.update(dt)
    cannon.update(dt)
    if cannon.done() then
      gamestate = "start"
    end
  end

end

function love.draw()
  if gamestate=="start" then
    startmenu.draw()
  elseif gamestate=="selection" then
    selection.draw()
  elseif gamestate=="remember" then
    coundownAndRememberWappen.draw()
  elseif gamestate=="spiel" then
    cannon.draw()
    wappen.draw()
  end

end

--function love.keypressed(key, scancode, isrepeat)
----  if key == "left" then
----    cannon1.rotation = cannon1.rotation - deg2rad(2)
----  elseif key == "right" then
----    cannon1.rotation = cannon1.rotation + deg2rad(2)
--  if key == "m" and gamestate == "spiel" then
--    startX, startY = abschussPosition1(cannon1)
--    dx, dy = abschussVektor1(cannon1)
--    if #bullets1 < 3 then
--      table.insert(bullets1, {x = startX, y = startY, dx = dx, dy = dy})
--      bang:play()
--    end

----  elseif key == "a" then
----    cannon2.rotation = cannon2.rotation - deg2rad(2)
----  elseif key=="d" then
----    cannon2.rotation = cannon2.rotation + deg2rad(2)
--  elseif key=="f" and gamestate == "spiel" then
--    startX, startY = abschussPosition2(cannon2)
--    dx, dy = abschussVektor2(cannon2)
--    if #bullets2 < 3 then
--      table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
--      bang:play()
--    end
    
--  elseif key=="p" then
--     love.event.quit() 
--  end   
--end

function love.keypressed(key)
  if key=="p" then
     love.event.quit() 
  end 
  
  if gamestate=="selection" then
    selection.keypressed(key)
  end
  
  
end
