function onCreate()
    setProperty('skipCountdown', true)
    
    makeLuaSprite('HUD', 'fmShade', 0, 0)
    setLuaSpriteScrollFactor('HUD', 0, 0)
    setObjectCamera('HUD', 'camOther')
    addLuaSprite('HUD', false)

    makeGraphic('black', screenWidth * 2, screenHeight * 2, '000000')
    updateHitbox('black')
    screenCenter('black')
    setScrollFactor('black', 0, 0)
    addLuaSprite('black', true)
end

function onSongStart()
    setProperty('camHUD.alpha', 0)
end

function onStepHit()
    if curStep == 352 then
        setProperty('black.alpha', 0)
        setProperty('camHUD.alpha', 1)
    elseif curStep == 1375 then
        setProperty('cameraSpeed', 0.5)
    elseif curStep == 1622 then
        setProperty('black.alpha', 1)
    elseif curStep == 1632 then
        setProperty('black.alpha', 0)
    end
end