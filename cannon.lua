local cannon = {}

require 'lib.slam'
local wappen = require('wappen')
local sprite = require('sprite')
local background
local brett
local modulState = false
--/////////////////////////////////////////
local explosionX
local explosionY
local finisher = 0
local fps = 11
local anim_timer = 1/ fps
local frame = 1
local num_frames = 15
local xoffset

alarm = love.audio.newSource("audio/scifiShoot.wav")


--explosionImg = love.graphics.newImage("explosion.png")
--explosions = {}

--function addExplosion(ball)
  --table.insert(explosions, {x = ball.x, y = ball.y}
--end

point1 = {
  x = 0,
  y = 0,
  t = 0,
  goal = "none"
}
point2 = {
  x = 0,
  y = 0,
  t = 0,
  goal = "none"
}



function getBoundingBoxBall(ball)
  local ball_left = ball.x - cannonball1:getWidth() / 2
  local ball_right = ball_left + cannonball1:getWidth()
  local ball_width = cannonball1:getWidth()
  local ball_top = ball.y - cannonball1:getHeight() / 2
  local ball_bottom = ball_top + cannonball1:getHeight()
  local ball_height = cannonball1:getHeight()
  return ball_left, ball_top, ball_width, ball_height
end

function animation(dt)
  anim_timer = anim_timer -dt
  if anim_timer <= 0 then
    anim_timer = 1 / fps
    frame = frame + 1
    xoffset = 128 * frame
    explosion_sprite:setViewport(xoffset, 0, 128,128)
    if frame > num_frames then
      frame = 1
      finisher = 0
    end
  end
end

function checkCollision(ball, cnr)
  ball_left, ball_top, ball_width, ball_height = getBoundingBoxBall(ball)
  local ball_right = ball_left + ball_width
  local ball_bottom = ball_top + ball_height


  --Auskommentiert, damit der Abschuss auch am oberen Bildschirmrand funktioniert.
  --if ball_top < 120 then
      --return false
  --end

  
  local t = wappen.allTargets
  for i = #t, 1, -1 do
    local v = t[i]
    v_left, v_top, v_width, v_height  = wappen.getBoundingBox(v)
    local v_right = v_left + v_width
    local v_bottom = v_top + v_height

    --if ball_right < v_right and
    --ball_left > v_left and
    --ball_bottom < v_bottom and
    --ball_top > v_top then

    -- if (math.abs(ball_left -v_left) * 2 <= (ball_width + v_width)) and
    -- (math.abs(ball_top - v_top) * 2 <=(ball_height + v_height)) then

    if not (ball_left > v_right or 
      ball_right < v_left or
      ball_top > v_bottom or
      ball_bottom < v_top
      ) then
      
      --hier aus v.koordinaten die für die explosion
      --////////////////////////////////////////////////////////////////////////////////////////////////////
       explosionY = v_bottom - (v_bottom-v_top)
       explosionX = v_right - (v_right-v_left)
      
      
      if v.correct == "true" then
        if cnr == 1 then
          if cannon1.item4 == "switch" then
            score1 = score1 - (1 * cannon1.multiplier)
            point1.goal = "false"
          else
            score1 = score1 + (1 * cannon1.multiplier)
            point1.goal = "true"
          end
          
        elseif cnr == 2 then
          if cannon2.item4 == "switch" then
            score2 = score2 - (1 * cannon2.multiplier)
            point2.goal = "false"
          else
            score2 = score2 + (1 * cannon2.multiplier)
            point2.goal = "true"
          end
        end
        
      elseif v.correct == "false" then
        if cnr == 1 then
          if cannon1.item4 == "switch" then
            score1 = score1 + (1 * cannon1.multiplier)
            point1.goal = "true"
          else
            score1 = score1 - (1 * cannon1.multiplier)
            point1.goal = "false"
          end
          
        elseif cnr ==2 then
          if cannon2.item4 == "switch" then
            score2 = score2 + (1 * cannon2.multiplier)
            point2.goal = "true"
          else
            score2 = score2 - (1 * cannon2.multiplier)
            point2.goal = "false"
          end
          
        end
        
      elseif v.correct == "laser" then
          if cnr == 1 then
            laserOn(cannon1)
            point1.goal = "laser"
          else 
            laserOn(cannon2)
            point2.goal = "laser"
          end
      elseif v.correct == "change" then
        if cnr == 1 then
          changeOn(cannon2)
          point1.goal = "change"
        else
          changeOn(cannon1)
          point2.goal = "change"
        end
      elseif v.correct == "double" then
        if cnr == 1 then
          doubleOn(cannon1)
          point1.goal = "double"
        else
          doubleOn(cannon2)
          point2.goal = "double"
        end
      elseif v.correct == "switch" then
        if cnr == 1 then
          switchOn(cannon2)
          point1.goal = "switch"
        else
          switchOn(cannon1)
          point2.goal = "switch"
        end
      end

      love.audio.play(alarm)
      table.remove(wappen.allTargets, i)

      return true
    end
  end
  return false
end

function switchOn(cannon)
  cannon.item4 = "switch"
  cannon.timer4 = switchItem.timer
end

function switchOff(cannon)
  cannon.item4 = "none"
  cannon.timer4 = 0
end

function doubleOn(cannon)
  cannon.item3 = "double"
  cannon.multiplier = doubleItem.multiplier
  cannon.timer3 = doubleItem.timer
end

function doubleOff(cannon)
  cannon.item3 = "none"
  cannon.multiplier = 1
  cannon.timer3 = 0
end


function changeOn(cannon)
  if cannon.name == "cannon1" then
    cannon.left = right1
    cannon.right = left1
  elseif cannon.name == "cannon2" then
    cannon.left = right2
    cannon.right = left2
  end
  cannon.timer2 = changeItem.timer
  cannon.item2 = "change"
end
function changeOff(cannon)
  if cannon.name == "cannon1" then
    cannon.left = left1
    cannon.right = right1
  elseif cannon.name == "cannon2" then

    cannon.left = left2
    cannon.right = right2
  end
  cannon.timer2 = 0
  cannon.item2 = "none"
end


function laserOn(cannon) 
  lItem = laserItem
  cannon.power = lItem.power
  cannon.weapon = lItem.weapon
  cannon.coolDownTime = lItem.coolDownTime
  cannon.shootSprite = lItem.shootSprite
  cannon.timer = lItem.timer
  cannon.item = "laser"
end
function laserOff(cannon) 
  cannon.power = 600
  cannon.weapon = "default"
  cannon.coolDownTime = 60
  cannon.timer = 0
  cannon.item = "none"
  if cannon.name == "cannon1" then
    cannon.shootSprite = cannonball1
  else
    cannon.shootSprite = cannonball2
  end
end

function setDefault(cannon)
  cannon.power = 600
  cannon.weapon = "default"
  cannon.coolDownTime = 60
  cannon.timer = 0
  cannon.item = "none"
  if cannon.name == "cannon1" then
    cannon.left = "left"
    cannon.right = "right"
    cannon.shoot = "m"
    cannon.shootSprite = cannonball1
  else
    cannon.left = "a"
    cannon.right = "d"
    cannon.shoot = "f"
    cannon.shootSprite = cannonball2
  end
end

  


function deg2rad(deg)
  return deg/360*2*pi
end

function rad2deg(rad)
  return rad/2*pi*360
end


function abschussVektor1(cannon)
  dy = - math.sin(cannon1.rohr + cannon1.rotation) * cannon1.power
  dx = - math.cos(cannon1.rohr + cannon1.rotation) * cannon1.power

  return dx, dy
end

function abschussVektor2(cannon)
  dy =  - math.sin(cannon2.rohr - cannon2.rotation) * cannon2.power
  dx =  math.cos(cannon2.rohr - cannon2.rotation) * cannon2.power

  return dx, dy
end

function abschussPosition2(cannon)
  --print ("Direction", direction)
  dist = math.sqrt((cannon.kx-cannon.ox)*(cannon.kx-cannon.ox) + (cannon.ky-cannon.oy)*(cannon.ky-cannon.oy))
  dist = dist * 0.7
  --print ("Distance: ", dist)
  --print("Rotation: ", rad2deg(cannon.rotation))
  y = - math.sin(cannon.alpha-cannon.rotation) * dist 
  x =  math.cos(cannon.alpha-cannon.rotation) * dist
  --print("dx,dy: ", x, y)
  --print("cannon x,y: ", cannon.x, cannon.y)
  resultx = cannon.x + x 
  resulty = cannon.y + y
  --print("result x,y: ", resultx, resulty)
  return resultx, resulty

end


function abschussPosition1(cannon)
  --print ("Direction", direction)
  dist = math.sqrt((cannon.kx-cannon.ox)*(cannon.kx-cannon.ox) + (cannon.ky-cannon.oy)*(cannon.ky-cannon.oy))
  dist = dist * 0.7
  
  print ("Distance: ", dist)
  print("Rotation: ", rad2deg(cannon.rotation))
  
  y = - math.sin(cannon.alpha+cannon.rotation) * dist 
  x = - math.cos(cannon.alpha+cannon.rotation) * dist
  
  print("dx,dy: ", x, y)
  print("cannon x,y: ", cannon.x, cannon.y)
  
  resultx = cannon.x + x 
  resulty = cannon.y + y
  
  print("result x,y: ", resultx, resulty)
  
  return resultx, resulty
end



local function load()
  sprite.load()
  
  score1 = 0
  score2 = 0
  carbonFont = love.graphics.newFont("fonts/carbon.ttf", 60)
  defaultFont = love.graphics.newFont(60)
  defaultFontSmall = love.graphics.newFont(40)
  
  
  --COUNTDOWN
  remainingTime = 61
  gameover = false
  --//////////////////
  
  countdownIsOn = false
  
  
  backgroundMusic = love.audio.newSource("audio/radetzkymarsch.mp3")
  backgroundMusic:setLooping(true)
  backgroundMusic:setVolume(.9)
  love.audio.play(backgroundMusic)
  bang = love.audio.newSource("audio/bang.wav")
  laserSound = love.audio.newSource("audio/laser.wav")
  countdownAlarm = love.audio.newSource("audio/countdown.wav")

  bang:setVolume(1) -- 50% of ordinary volume
--bang:setPitch(0.5) -- one octave lower
--bang:setVolume(0.7)


  background = love.graphics.newImage("background/Hintergrund-Stuttgart-flach.jpg")
  brett = love.graphics.newImage("background/brett-anzeige.png")
  endScreen = love.graphics.newImage("background/game-over.png")
 

  playgroundWidth = love.graphics.getWidth()
  playgroundHeight = love.graphics.getHeight()
  bulletX = playgroundWidth
  bulletY = playgroundHeight
  pi  = 3.14159
  bulletSpeed = 400
  bullets1 = {}
  bullets2 = {}

  rotation1 = 0
  rotation2 = 0

  love.keyboard.setKeyRepeat(false)

  cannonball1 = love.graphics.newImage("cannon/cannonball1.png")
  cannonball2 = love.graphics.newImage("cannon/cannonball2.png")
  cannon1sprite  = love.graphics.newImage("cannon/cannon1.png")
  cannon2sprite  = love.graphics.newImage("cannon/cannon2.png")
  
  left1 = "left"
  right1 = "right"
  shoot1 = "m"

  left2 = "a"
  right2 = "d"
  shoot2 = "f"
  
  cooldown1 = 80
  cooldown2 = 80
  
  cannon1 = {
    name = "cannon1",
    cannonSprite = love.graphics.newImage("cannon/cannon1.png"),
    shootSprite = love.graphics.newImage("cannon/cannonball1.png"),
    x = playgroundWidth - 150, 
    y = playgroundHeight - 100, 
    width = cannon1sprite:getWidth(), 
    height = cannon1sprite:getHeight(), 
    rohr = deg2rad(17.98), 
    alpha = deg2rad(74.5),
    ox = 55, 
    oy = 159,
    rotation = 0,
    kx = 14,
    ky = 19,
    power = 800,
    speed = 2,
    weapon = "default",
    coolDownTime = 0,
    left = left1,
    right = right1,
    shoot = shoot1,
    timer = 0,
    timer2 = 0,
    timer3 = 0,
    timer4 = 0,
    item = "none",
    item2 = "none",
    item3 = "none",
    item4 = "none",
    multiplier = 1
  }
  cannon2 = {
    name = "cannon2",
    cannonSprite = love.graphics.newImage("cannon/cannon2.png"),
    shootSprite = love.graphics.newImage("cannon/cannonball2.png"),
    x = 100, 
    y = playgroundHeight - 100, 
    width = cannon2sprite:getWidth(), 
    height = cannon2sprite:getHeight(), 
    rohr = deg2rad(5.35), 
    alpha = deg2rad(24.4),
    ox = 148, 
    oy = 129,
    rotation = 0,
    kx = 366,
    ky = 25,
    power = 800,
    speed = 2,
    weapon = "default",
    coolDownTime = 0,
    left = left2,
    right = right2,
    shoot = shoot2,
    timer = 0,
    timer2 = 0,
    timer3 = 0,
    timer4 = 0,
    item = "none",
    item2 = "none",
    item3 = "none",
    item4 = "none",
    multiplier = 1
  }
  
  
  
  laserItem = {
    typ = "item",
    name = "laser",
    sprite = love.graphics.newImage("items/blitz.png"),
    power = 1000,
    speed = 4,
    weapon = "laser",
    coolDownTime = 10,
    shootSprite = love.graphics.newImage("cannon/laser.png"),
    timer = 10
  }
  
  changeItem = {
    typ = "item",
    name = "change",
    timer = 10,
    sprite = love.graphics.newImage("items/wechsel.png")
  }
  
  doubleItem = {
    typ = "item",
    name = "double",
    timer = 10,
    sprite = love.graphics.newImage("items/doppel.png"),
    multiplier = 2
  }
  
  switchItem = {
    typ = "item",
    name = "switch",
    timer = 10, 
    sprite = love.graphics.newImage("items/wechsel.png")
    }
  
end
radiusC = 20
local function update(dt)
  
--  if love.keyboard.isDown("space") then
--    modulState = true
--  end
  
  --Countdown für die Punkte bei Abschuss eines Wappen oder Item
  if point1.t > 0 then
    point1.t = point1.t - dt
  end
  if point2.t > 0 then
    point2.t = point2.t - dt
  end
  
  radiusC = radiusC + 1
  cannon2.coolDownTime = cannon2.coolDownTime - 1 
  cannon1.coolDownTime = cannon1.coolDownTime - 1
  
  --Timer für Laser Item
  function laserTimer(cannon) 
    if cannon.timer > 0 then
      cannon.timer = cannon.timer - dt
    elseif cannon.timer < 0 then
      laserOff(cannon)
    end
  end
  laserTimer(cannon1)
  laserTimer(cannon2)
  
  --Timer für Change Item 
  function changeTimer(cannon) 
    if cannon.timer2 > 0 then
      cannon.timer2 = cannon.timer2 - dt
    elseif cannon.timer2 < 0 then
      changeOff(cannon)
    end
  end
  changeTimer(cannon1)
  changeTimer(cannon2)
  
  function doubleTimer(cannon) 
    if cannon.timer3 > 0 then
      cannon.timer3 = cannon.timer3 - dt
    elseif cannon.timer3 < 0 then
      doubleOff(cannon)
    end
  end
  doubleTimer(cannon1)
  doubleTimer(cannon2)
  
  function switchTimer(cannon) 
    if cannon.timer4 > 0 then
      cannon.timer4 = cannon.timer4 - dt
    elseif cannon.timer4 < 0 then
      switchOff(cannon)
    end
  end
  switchTimer(cannon1)
  switchTimer(cannon2)
    
  
  --COUNTDOWN
  remainingTime = remainingTime - dt 
  if remainingTime <= 0 then
    gameover = true
  end
  
--Spiel wird nach Countdown beendet
  if gameover then
    function love.draw()
      love.audio.stop(countdownAlarm)
      love.graphics.draw(endScreen , 0, 0, 0, 
      love.graphics.getWidth() / endScreen:getWidth() , 
      love.graphics.getHeight() / endScreen:getHeight())      
      love.graphics.setColor(255, 10, 10)
      love.graphics.setFont(carbonFont)
      
      love.graphics.print("Game Over", love.graphics.getWidth()/3, playgroundHeight - 500)
      love.graphics.setFont(carbonFont, love.graphics.getHeight() / 20)
      love.graphics.print(score2, love.graphics.getWidth()/4, playgroundHeight - 300)
      love.graphics.print(score1, love.graphics.getWidth()/4 * 3, playgroundHeight - 300)
      love.graphics.setFont(defaultFontSmall)
      love.graphics.print("Drücke p um das Spiel zu verlassen.", 300, playgroundHeight - 100)
      --love.graphics.print("Drücke Leertaste um erneut zu spielen.", 100, playgroundHeight - 50)
      love.graphics.setColor(255, 255, 255)
    
    end
  
    function love.update()
      if love.keyboard.isDown("space") then
      modulState = true
    end
  
    end
    
  end
  --////////////////////////

  --///////////Spieler rechts bewegen///////////////////
  if love.keyboard.isDown(cannon1.left) then
    if cannon1.weapon == "default" then
    cannon1.rotation = cannon1.rotation - deg2rad(cannon1.speed)
    elseif cannon1.weapon == "laser" then
    cannon1.rotation = cannon1.rotation - deg2rad(laserItem.speed)
    end
  elseif love.keyboard.isDown(cannon1.right) then
    if cannon1.weapon == "default" then
    cannon1.rotation = cannon1.rotation + deg2rad(cannon1.speed)
    elseif cannon1.weapon == "laser" then
    cannon1.rotation = cannon1.rotation + deg2rad(laserItem.speed)
    end
  end
  --//////////Spieler rechts schießen///////////////////
  if love.keyboard.isDown(cannon1.shoot) then
    startX, startY = abschussPosition1(cannon1)
    dx, dy = abschussVektor1(cannon1)
    
    if cannon1.coolDownTime <= 0 then
      if cannon1.weapon == "default" then
        cannon1.coolDownTime = cooldown1
        table.insert(bullets1, {x = startX, y = startY, dx = dx, dy = dy})
        bang:play()
      elseif cannon1.weapon == "laser" then
        cannon1.coolDownTime = laserItem.coolDownTime
        table.insert(bullets1, {x = startX, y = startY, dx = dx, dy = dy})
        laserSound:play()
      --cannon2.speed = playgroundWidth / 3
      end
    end
  elseif love.keyboard.isDown("n") then
    startX, startY = abschussPosition1(cannon1)
    dx, dy = abschussVektor1(cannon1)
    
    if cannon1.coolDownTime < 0 then
      if cannon1.weapon == "default" then
        cannon1.coolDownTime = cooldown1
        table.insert(bullets1, {x = startX, y = startY, dx = dx, dy = dy})
        bang:play()
      elseif cannon1.weapon == "laser" then
        cannon1.coolDownTime = laserItem.coolDownTime
        table.insert(bullets1, {x = startX, y = startY, dx = dx, dy = dy})
        table.insert(bullets1, {x = startX, y = startY, dx = dx+20, dy = dy+20})
        table.insert(bullets1, {x = startX, y = startY, dx = dx+40, dy = dy+40})
        laserSound:play()
      --cannon2.speed = playgroundWidth / 3
      end
    end
  end

  --////////////Spieler links bewegen///////////////////
  if love.keyboard.isDown(cannon2.left) then
    if cannon2.weapon == "default" then
    cannon2.rotation = cannon2.rotation - deg2rad(cannon2.speed)
    elseif cannon2.weapon == "laser" then
    cannon2.rotation = cannon2.rotation - deg2rad(laserItem.speed)
    end
  elseif love.keyboard.isDown(cannon2.right) then
    if cannon2.weapon == "default" then
    cannon2.rotation = cannon2.rotation + deg2rad(cannon2.speed)
    elseif cannon2.weapon == "laser" then
    cannon2.rotation = cannon2.rotation + deg2rad(laserItem.speed)
    end
  end
  
  --//////////Spieler links schießen//////////////////
  if love.keyboard.isDown(cannon2.shoot) then
    startX, startY = abschussPosition2(cannon2)
    dx, dy = abschussVektor2(cannon2)
    
    if cannon2.coolDownTime <= 0 then
      if cannon2.weapon == "default" then
        cannon2.coolDownTime = cooldown2
        table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
        bang:play()
      elseif cannon2.weapon == "laser" then
        cannon2.coolDownTime = laserItem.coolDownTime
        table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
        laserSound:play()
      --cannon2.speed = playgroundWidth / 3
      end
    end
  elseif love.keyboard.isDown("g") then
    startX, startY = abschussPosition2(cannon2)
    dx, dy = abschussVektor2(cannon2)
    
    if cannon2.coolDownTime < 0 then
      if cannon2.weapon == "default" then
        cannon2.coolDownTime = 
        table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
        bang:play()
      elseif cannon2.weapon == "laser" then
        cannon2.coolDownTime = cooldown2
        table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
        table.insert(bullets2, {x = startX, y = startY, dx = dx+20, dy = dy+20})
        table.insert(bullets2, {x = startX, y = startY, dx = dx+40, dy = dy+40})
        laserSound:play()
      --cannon2.speed = playgroundWidth / 3
      end
    end
  end


  for i,v in ipairs(bullets1) do
    v.x = v.x + (v.dx * dt) 
    v.y = v.y + (v.dy * dt)
    if cannon1.weapon == "default" then
      v.dy = v.dy + 4
    elseif cannon1.weapon == "laser" then
      v.dy = v.dy + 0
    end
    --/////////////////////////////////////////////////////////////////////////////////////////////7
  --/////////////Kanonenkugeln bei Kollision entfernen//////////////////
    if checkCollision(v, 1) then 
      point1.x = v.x
      point1.y = v.y
      point1.t = 1
      finisher = 1
      --addExplosion(v.x, v.y)
      table.remove(bullets1, i)
    end
  end
  
  if finisher == 1 then
    --sprite.drawExplosion(explosionX, explosionY)
    animation(dt)
    end
  
  for i,v in ipairs(bullets2) do
    v.x = v.x + (v.dx * dt) 
    v.y = v.y + (v.dy * dt)
    if cannon2.weapon == "default" then
      v.dy = v.dy + 4
    elseif cannon2.weapon == "laser" then
      v.dy = v.dy + 0
    end

    if checkCollision(v, 2) then
     point2.x = v.x
      point2.y = v.y
      point2.t = 1
      table.remove(bullets2, i)
    end
  end

end

local function draw()
  love.graphics.setColor(200, 200, 200)
  love.graphics.draw(background, 0, 0, 0,
  love.graphics.getWidth() / background:getWidth() , 
  love.graphics.getHeight() / background:getHeight())
  love.graphics.setColor(255, 255, 255)
  --love.graphics.rectangle("fill",  player.x, player.y, player.width, player.height)
  love.graphics.draw(cannon1.cannonSprite, cannon1.x, cannon1.y, cannon1.rotation, 0.7, 0.7, cannon1.ox, cannon1.oy) 
  love.graphics.draw(cannon2.cannonSprite, cannon2.x, cannon2.y, cannon2.rotation, 0.7, 0.7, cannon2.ox, cannon2.oy) 
  love.graphics.setColor(255, 0, 0)
  --love.graphics.draw(wappen.changeSprite, 100, 100)

  --love.graphics.circle("fill", cannon2.x, cannon2.y, 4)
  startX, startY = abschussPosition1(cannon1)
  --love.graphics.circle("fill", startX, startY, 4)

  --love.graphics.circle("fill", cannon1.x, cannon1.y, 4)

  --love.graphics.circle("fill", startX, startY, 4)
  --startX, startY = abschussPosition1(cannon1)
  dx, dy = abschussVektor1(cannon1)
  --love.graphics.line(startX, startY, startX + dx, startY + dy)

--  startX, startY = abschussPosition2(cannon2)
--  dx, dy = abschussVektor2(cannon2)
--  love.graphics.line(startX, startY, startX + dx, startY + dy)

  love.graphics.setColor(255, 255, 255)
  for i,v in ipairs(bullets1) do
    love.graphics.draw(cannon1.shootSprite, v.x, v.y, 0, 1, 1, cannon1.shootSprite:getWidth()/2, cannon1.shootSprite:getWidth()/2)
    
    if v.x < 0 
    or v.y < 0 
    or v.x > playgroundWidth
    or v.y > playgroundHeight then
      table.remove(bullets1, i)
    end
  end
  
  for i,v in ipairs(bullets2) do
    love.graphics.draw(cannon2.shootSprite, v.x, v.y, 0, 1, 1, cannon2.shootSprite:getWidth()/2, cannon2.shootSprite:getWidth()/2)
    
    if v.x < 0 
    or v.y < 0 
    or v.x > playgroundWidth
    or v.y > playgroundHeight then
      table.remove(bullets2, i)
    end
  end
  
  screenscale = love.graphics.getWidth() / 1536
  
  love.graphics.draw(brett, 370, playgroundHeight - 110, 0, 
    0.8 * screenscale, 0.8 * screenscale)
    
  love.graphics.setFont(carbonFont)
  love.graphics.setColor(0,0,0)
  love.graphics.print(score1, playgroundWidth - 500, playgroundHeight - 100)
  love.graphics.print(score2, 400, playgroundHeight - 100)
  
  --Game Countdown
  love.graphics.print(math.floor(remainingTime), (playgroundWidth / 2) - 20, playgroundHeight - 100)
  love.graphics.setColor(255,255,255)
  
  if remainingTime < 11 and countdownIsOn == false then
    love.audio.play(countdownAlarm)
    countdownIsOn = true
  end
  
   love.graphics.setFont(defaultFontSmall)
  --Item Countdown
  if cannon1.timer > 0 or cannon1.timer2 > 0 or cannon1.timer3 > 0 or cannon1.timer4 > 0 then
    if cannon1.item == "laser" then
      love.graphics.print(math.floor(cannon1.timer), playgroundWidth - 340, playgroundHeight - 50)
      love.graphics.draw(laserItem.sprite, playgroundWidth - 305, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    if cannon1.item2 == "change" then
      love.graphics.print(math.floor(cannon1.timer2), playgroundWidth - 255, playgroundHeight - 50)
      love.graphics.draw(changeItem.sprite, playgroundWidth - 220, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    if cannon1.item3 == "double" then
      love.graphics.print(math.floor(cannon1.timer3), playgroundWidth - 170, playgroundHeight - 50)
      love.graphics.draw(doubleItem.sprite, playgroundWidth - 135, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    if cannon1.item4 == "switch" then
      love.graphics.print(math.floor(cannon1.timer4), playgroundWidth - 85, playgroundHeight - 50)
      love.graphics.draw(switchItem.sprite, playgroundWidth - 50, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    love.graphics.setColor(255,255,255)
  end
  
 
  if cannon2.timer > 0 or cannon2.timer2 > 0 or cannon2.timer3 > 0 or cannon2.timer4 > 0 then
    if cannon2.item == "laser" then
      love.graphics.print(math.floor(cannon2.timer), 5, playgroundHeight - 50)
      love.graphics.draw(laserItem.sprite, 40, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    if cannon2.item2 == "change" then
      love.graphics.print(math.floor(cannon2.timer2), 90, playgroundHeight - 50)
      love.graphics.draw(changeItem.sprite, 125, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    if cannon2.item3 == "double" then
      love.graphics.print(math.floor(cannon2.timer3), 175, playgroundHeight - 50)
      love.graphics.draw(doubleItem.sprite, 210, playgroundHeight - 50, 0, 0.5, 0.5)
    end
     if cannon2.item4 == "switch" then
      love.graphics.print(math.floor(cannon2.timer4), 260, playgroundHeight - 50)
      love.graphics.draw(switchItem.sprite, 295, playgroundHeight - 50, 0, 0.5, 0.5)
    end
    love.graphics.setColor(255,255,255)
  end
  
  --love.graphics.circle("line", 200, 200, radiusC)
  
   love.graphics.setFont(defaultFont)
  --Punkte bei Abschuss anzeigen
  if point1.x > 0 and point1.y > 0 and point1.t > 0 then
    if point1.goal == "true" then
      love.graphics.print("+", point1.x-50, point1.y-50)
      love.graphics.print(cannon1.multiplier, point1.x, point1.y-50)
      love.graphics.setColor(255,255,255)
    elseif point1.goal == "false" then
      love.graphics.print("-", point1.x-50, point1.y-50)
       love.graphics.print(cannon1.multiplier, point1.x-20, point1.y-50)
      love.graphics.setColor(255,255,255)
    elseif point1.goal == "laser" then
      love.graphics.print("laser", point1.x-50, point1.y-50)
      love.graphics.setColor(255,255,255)
    elseif point1.goal == "change" then
      love.graphics.print("change", point1.x-50, point1.y-50)
      love.graphics.setColor(255,255,255)
    elseif point1.goal == "double" then
      love.graphics.print("double", point1.x-50, point1.y-50)
      love.graphics.setColor(255,255,255)
    elseif point1.goal == "switch" then
      love.graphics.print("switch", point1.x-50, point1.y-50)
      love.graphics.setColor(255,255,255)
    end
  end
  
  if point2.x > 0 and point2.y > 0 and point2.t > 0 then
    if point2.goal == "true" then
      love.graphics.print("+", point2.x-50, point2.y-50)
      love.graphics.print(cannon2.multiplier, point2.x, point2.y-50)
      love.graphics.setColor(255,255,255)
    elseif point2.goal == "false" then
      love.graphics.print("-", point2.x-50, point2.y-50)
       love.graphics.print(cannon2.multiplier, point2.x-20, point2.y-50)
      love.graphics.setColor(255,255,255)
    elseif point2.goal == "laser" then
      love.graphics.print("laser", point2.x-50, point2.y-50)
      love.graphics.setColor(255,255,255)
    elseif point2.goal == "change" then
      love.graphics.print("change", point2.x-50, point2.y-50)
      love.graphics.setColor(255,255,255)
    elseif point2.goal == "double" then
      love.graphics.print("double", point2.x-50, point2.y-50)
      love.graphics.setColor(255,255,255)
    elseif point2.goal == "switch" then
      love.graphics.print("switch", point2.x-50, point2.y-50)
      love.graphics.setColor(255,255,255)
    end
  end
  
  
  if point1.x > 0 and point1.y > 0 then
    sprite.drawExplosion(explosionX, explosionY)
    end

  
  
--  love.graphics.rectangle("fill", playgroundWidth - 100, playgroundHeight - 200, 20, -(cannon1.speed/2) + ((      playgroundWidth/6)/2))
--  love.graphics.rectangle("fill", 100, playgroundHeight - 200, 20, -(cannon2.speed/2)+ ((playgroundWidth/6)/2))
end

--function love.keyreleased(key)
--  if key == "m" then
--    startX, startY = abschussPosition1(cannon1)
--    dx, dy = abschussVektor1(cannon1)
--    if #bullets1 < 5 then
--      table.insert(bullets1, {x = startX, y = startY, dx = dx, dy = dy})
--      bang:play()
--      cannon1.speed = playgroundWidth / 3
--    end
--  end
  
--  if key == "f" then
--    startX, startY = abschussPosition2(cannon2)
--    dx, dy = abschussVektor2(cannon2)
--    if cannon2.coolDownTime < 0 then
--      cannon2.coolDownTime = 10
--      table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
--      bang:play()
--      cannon2.speed = playgroundWidth / 3
--    end
--  end
--end

--function love.keypressed(key, scancode, isrepeat)
----  if key == "left" then
----    cannon1.rotation = cannon1.rotation - deg2rad(2)
----  elseif key == "right" then
----    cannon1.rotation = cannon1.rotation + deg2rad(2)
--  if key == "m" then
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
--  elseif key=="f" then
--    startX, startY = abschussPosition2(cannon2)
--    dx, dy = abschussVektor2(cannon2)
--    if #bullets2 < 3 then
--      table.insert(bullets2, {x = startX, y = startY, dx = dx, dy = dy})
--      bang:play()
--    end
--  end
--end

function isDone()
  return modulState
end

cannon.load = load
cannon.update = update
cannon.draw = draw
cannon.done = isDone

return cannon