local allowCountdown = false
local confirmed = 0

function onCreate()
    playSound('64/versus', 0.7, 'versusSfx')
    playSound('64/versus_targets', 0.7, 'versustargets')

    makeLuaText('skipText', 'Press A to continue', 1280, 0, 567)
    setTextFont('skipText', 'Kabel-Heavy Heavy.ttf')
    setTextAlignment('skipText', 'center')
    setTextSize('skipText', 45)
    setObjectCamera('skipText', 'other')
    setProperty('skipText.alpha', 0)
    addLuaText('skipText')

    makeLuaSprite('target', 'bg/targets/stuff/versuscreen/target', 465, 176)
    scaleObject('target', 3.3, 3.3)
    setObjectCamera('target','other')

    makeLuaSprite('hud', 'bg/targets/stuff/versuscreen/hud_targets',-30,-15)
    scaleObject('hud', 0.7, 0.7)
    setObjectCamera('hud','other')

    makeLuaSprite('bg', 'bg/targets/stuff/versuscreen/bg',160,150)
    scaleObject('bg', 3.2, 3.2)
    setObjectCamera('bg','other')

    addLuaSprite('bg', false)
    addLuaSprite('target', false)
    addLuaSprite('hud', false)

    setObjectOrder('bg', 2)
    setObjectOrder('target', 3)
    setObjectOrder('hud', 4)

    runTimer('showSkip', 3)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'showSkip' then
        setProperty('skipText.alpha', 1)
        runTimer('blinkSkip', 0.4, 0)

    elseif tag == 'blinkSkip' then
        if getProperty('skipText.alpha') == 1 then
            setProperty('skipText.alpha', 0)
        else
            setProperty('skipText.alpha', 1)
        end
    end
end

function onStartCountdown()
    if not allowCountdown then
        return Function_Stop
    end
    return Function_Continue
end

function onUpdate()
    if keyboardJustPressed('A') and confirmed == 0 then
        allowCountdown = true
        startCountdown()

        stopSound('versusSfx')
        stopSound('versustargets')
        removeLuaSprite('bg', true)
        removeLuaSprite('target', true)
        removeLuaSprite('hud', true)
        cancelTimer('blinkSkip')
        removeLuaText('skipText', true)
        confirmed = 1
    end
end