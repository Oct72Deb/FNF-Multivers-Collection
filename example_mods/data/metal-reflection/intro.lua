local allowCountdown = false
local waitThing = false
local confirmed = 0

function onCreate()
    playSound('metal_versus', 0.8, 'versusSfx')

    -- texte invisible au départ
    makeLuaText('skipText', 'Press A to continue', 1280, 0, 650)
    setTextAlignment('skipText', 'center')
    setTextSize('skipText', 30)
    setObjectCamera('skipText', 'other')
    setProperty('skipText.alpha', 0) -- invisible
    addLuaText('skipText')

<<<<<<< HEAD
    makeLuaSprite('versus', 'bg/metacrystal/versuscreen/VS', 540, 300)
    scaleObject('versus', 3.4, 3.4)
    setObjectCamera('versus','other')

=======
>>>>>>> f1ddd8e2b2d22239a90c05f80fca8f4b311670e4
    makeLuaSprite('hud', 'bg/metacrystal/versuscreen/hud',-30,-15)
    scaleObject('hud', 0.7, 0.7)
    setObjectCamera('hud','other')

    makeLuaSprite('metal', 'bg/metacrystal/versuscreen/metal', 1350, 195)
    scaleObject('metal', 0.68, 0.68)
    setObjectCamera('metal','other')

    makeLuaSprite('mario', 'bg/metacrystal/versuscreen/mario', -450, 195)
    scaleObject('mario', 0.68, 0.68)
    setObjectCamera('mario','other')

    makeLuaSprite('hud', 'bg/metacrystal/versuscreen/hud',-30,-15)
    scaleObject('hud', 0.7, 0.7)
    setObjectCamera('hud','other')

    makeLuaSprite('bg', 'bg/metacrystal/versuscreen/bg',160,150)
    scaleObject('bg', 3.2, 3.2)
    setObjectCamera('bg','other')

    addLuaSprite('hud',false)
<<<<<<< HEAD
    addLuaSprite('versus',false)
=======
>>>>>>> f1ddd8e2b2d22239a90c05f80fca8f4b311670e4
    addLuaSprite('mario',false)
    addLuaSprite('metal',false)
    addLuaSprite('bg',false)

    -- lancer un timer pour afficher le texte après 3 secondes
    runTimer('showSkip', 3)
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'showSkip' then
        -- petit fade-in au début
            setProperty('skipText.alpha', 1)
        -- lancer un timer répétitif pour clignoter net après le fondu
        runTimer('blinkSkip', 0.4, 0) -- toutes les 0.5s, infini
    elseif tag == 'blinkSkip' then
        -- alterne instantanément entre 1 et 0
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
    if allowCountdown then
        return Function_Continue
    end
    return Function_Continue;
end

function onUpdate()
<<<<<<< HEAD
    doTweenX('marioslide','mario', 200, 0.3,'quartOut')
    doTweenX('metalslide','metal', 720, 0.3,'quartOut')

    setObjectOrder('mario', 3)
    setObjectOrder('hud', 4)
    setObjectOrder('versus', 3)
=======
    doTweenX('marioslide','mario', 200 ,0.3,'quartOut')
    doTweenX('metalslide','metal', 720,0.3,'quartOut')

    setObjectOrder('mario', 3)
    setObjectOrder('hud', 4)
>>>>>>> f1ddd8e2b2d22239a90c05f80fca8f4b311670e4
    setObjectOrder('bg', 2)
    setObjectOrder('metal', 3)

    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.A') and confirmed == 0 then
        allowCountdown = true
        startCountdown();

        stopSound('versusSfx')
	    removeLuaSprite('bg', true);
<<<<<<< HEAD
        removeLuaSprite('versus', true);
=======
>>>>>>> f1ddd8e2b2d22239a90c05f80fca8f4b311670e4
	    removeLuaSprite('hud', true);
	    removeLuaSprite('metal', true);
	    removeLuaSprite('mario', true);
        cancelTimer('blinkSkip')
        removeLuaText('skipText', true)
        confirmed = 1
    end
end