function onCreate()
  makeLuaSprite('creditsong', 'hud/creditsong/htp', 160, 380)
  scaleObject('creditsong', 0.71, 0.71)
	addLuaSprite('creditsong', true)
	setObjectCamera("creditsong", "hud")
  setProperty('creditsong.alpha', 1)
end

function onStepHit()
    if curStep == 32 then
    setProperty('creditsong.alpha', 0)
    end
end