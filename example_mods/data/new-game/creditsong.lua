function onCreate()

  makeLuaSprite('creditsong', 'hud/creditsong/horrormario', 0, 0)
  scaleObject('creditsong', 0.6, 0.6)
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
    if curStep == 352 then
	doTweenAlpha('creditsong', 'creditsong', 1, 0.5 / playbackRate)

   elseif curStep == 400 then
  doTweenAlpha('creditsong', 'creditsong', 0, 1 / playbackRate)

end
end