function onCreate()

  makeLuaSprite('creditsong', 'hud/creditsong/metal', 160, 500)
  scaleObject('creditsong', 0.71, 0.71)
	addLuaSprite('creditsong', true)
	setObjectCamera("creditsong", "hud")
  setProperty('creditsong.alpha', 0)
end

function onStepHit()
    if curStep == 16 then
    setProperty('creditsong.alpha', 1)

   elseif curStep == 53 then
    setProperty('creditsong.alpha', 0)

end
end