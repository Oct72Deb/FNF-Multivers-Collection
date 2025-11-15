function onCreate()

  makeLuaSprite('creditsong', 'hud/creditsong/doki', 270, 200)
  scaleObject('creditsong', 0.4, 0.4)
	addLuaSprite('creditsong', true)
	setObjectCamera("creditsong", "other")
  setProperty('creditsong.alpha', 0)
      -- Récupère la taille de l’image
    local width = getProperty('creditsong.width')
    local height = getProperty('creditsong.height')

    -- Taille de l’écran de base Psych Engine (tu peux changer si ton mod est en 4:3)
    local screenWidth = 1280
    local screenHeight = 720

    -- Centre l’image
    setProperty('creditsong.x', (screenWidth / 2) - (width / 2))
    setProperty('creditsong.y', (screenHeight / 2) - (height / 2))
end

function onStepHit()
    if curStep == 64 then
	doTweenAlpha('creditsong', 'creditsong', 1, 1 / playbackRate)

   elseif curStep == 95 then
  doTweenAlpha('creditsong', 'creditsong', 0, 1 / playbackRate)

end
end