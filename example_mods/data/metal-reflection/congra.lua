-- Écran de félicitation après la chanson
function onEndSong()
    if not congratScreenShown then
        congratScreenShown = true
        playSound('congratulations', 1, 'goodplayerSfx')

        -- Image d’écran de félicitations
        makeLuaSprite('congra', 'bg/metacrystal/wow', 0, 0)
        setObjectCamera('congra', 'other')
        scaleObject('congra', 0.67, 0.67)
        addLuaSprite('congra', true)
        setProperty('congra.alpha', 0)

        -- Apparition progressive
        doTweenAlpha('fadeInBG', 'congra', 1, 0.01, 'linear')

        -- Lancer un timer avant de repartir
        runTimer('waitEnd', 3)

        return Function_Stop -- empêche la fin immédiate de la chanson
    end
    return Function_Continue
end

function onTimerCompleted(tag)
    if tag == 'waitEnd' then
        -- Disparaît en fondu
        doTweenAlpha('fadeOutAll', 'congra', 0, 1, 'linear')
        runTimer('goBackToMenu', 3)
    elseif tag == 'goBackToMenu' then
        -- Retour au menu principal
        exitSong(true)
    end
end