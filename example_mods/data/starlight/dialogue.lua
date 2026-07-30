local doDialogue = true

function onStartCountdown()
    if doDialogue and not seenCutscene and isStoryMode then
        startDialogue('dialogue', 'mus_rival_light')
        
        makeLuaSprite('creditImage', 'bg/star/creditsintro', 20, 20)
        setObjectCamera('creditImage', 'other')
        scaleObject('creditImage', 0.7, 0.7)
        addLuaSprite('creditImage', true)
        runTimer('waitAndFade', 5)
        
        doDialogue = false
        return Function_Stop
    end
    
    return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'waitAndFade' then
        doTweenAlpha('byeImage', 'creditImage', 0, 1, 'linear')
    end
end

function onTweenCompleted(tag)
    if tag == 'byeImage' then
        removeLuaSprite('creditImage', true)
    end
end