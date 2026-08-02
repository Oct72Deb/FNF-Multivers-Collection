local allowCountdown = false
local confirmed = 0

function onCreate()
    playSound('64/versus', 0.7, 'versusSfx')
    playSound('64/versus_metal', 0.7, 'versusmetal')

    -- Texte
    makeLuaText('skipText', 'Press A to continue', 1280, 0, 650)
    setTextAlignment('skipText', 'center')
    setTextFont('skipText', 'Kabel-Heavy Heavy.ttf')
    setTextSize('skipText', 45)
    setObjectCamera('skipText', 'other')
    setProperty('skipText.alpha', 0)
    addLuaText('skipText')

    -- Sprites
    makeLuaSprite('bg', 'bg/targets/stuff/versuscreen/bg', 160, 150)
    scaleObject('bg', 3.2, 3.2)
    setObjectCamera('bg', 'other')
    addLuaSprite('bg', false)

    makeLuaSprite('versus', 'bg/metacrystal/stuff/versuscreen/VS', 540, 300)
    scaleObject('versus', 3.3, 3.3)
    setObjectCamera('versus', 'other')
    addLuaSprite('versus', false)

    makeLuaSprite('mario', 'bg/metacrystal/stuff/versuscreen/mario', -450, 195)
    scaleObject('mario', 0.68, 0.68)
    setObjectCamera('mario', 'other')
    addLuaSprite('mario', false)

    makeLuaSprite('metal', 'bg/metacrystal/stuff/versuscreen/metal', 1350, 195)
    scaleObject('metal', 0.68, 0.68)
    setObjectCamera('metal', 'other')
    addLuaSprite('metal', false)

    makeLuaSprite('hud', 'bg/metacrystal/stuff/versuscreen/hud', -30, -15)
    scaleObject('hud', 0.7, 0.7)
    setObjectCamera('hud', 'other')
    addLuaSprite('hud', false)

    setObjectOrder('bg', 2)
    setObjectOrder('versus', 3)
    setObjectOrder('mario', 3)
    setObjectOrder('metal', 3)
    setObjectOrder('hud', 4)

    doTweenX('marioslide', 'mario', 200, 0.3, 'quartOut')
    doTweenX('metalslide', 'metal', 720, 0.3, 'quartOut')

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
        confirmed = 1
        startCountdown()

        stopSound('versusSfx')
        stopSound('versusmetal')
        
        removeLuaSprite('bg', true)
        removeLuaSprite('versus', true)
        removeLuaSprite('hud', true)
        removeLuaSprite('metal', true)
        removeLuaSprite('mario', true)
        
        cancelTimer('blinkSkip')
        removeLuaText('skipText', true)
    end
end