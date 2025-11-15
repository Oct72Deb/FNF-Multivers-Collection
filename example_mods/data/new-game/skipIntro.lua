-- Temps pour le saut de la chanson
local musicSkipTo = 36410
local skipLimit = 23000
local skipTextShown = false
local skipTextRemoved = false

function onCreatePost()
    -- Crée et affiche le texte au début
    makeLuaText('skipText', 'Press SPACE to skip the cutscene', 2100, 0, 10)
    setTextSize('skipText', 22)
    setObjectCamera('skipText', 'other')
    addLuaText('skipText')
    skipTextShown = true

    -- Commence le clignotement
    setProperty('skipText.alpha', 1)
    doTweenAlpha('fadeOutSkip', 'skipText', 0, 1, 'linear')
end

function onTweenCompleted(tag)
    if tag == 'fadeOutSkip' then
        doTweenAlpha('fadeInSkip', 'skipText', 1, 1, 'linear')
    elseif tag == 'fadeInSkip' then
        doTweenAlpha('fadeOutSkip', 'skipText', 0, 1, 'linear')
    end
end

function onUpdate()
    local songTime = getSongPosition()

    -- Retire le message après 23 secondes s'il est encore là
    if skipTextShown and not skipTextRemoved and songTime >= skipLimit then
        removeLuaText('skipText', true)
        skipTextRemoved = true
    end

    -- Skip musique seulement si on est encore avant 23s
    if keyboardJustPressed('SPACE') and songTime <= skipLimit then
        setPropertyFromClass('Conductor', 'songPosition', musicSkipTo)
        setProperty('songTime', musicSkipTo)
        runHaxeCode([[
            FlxG.sound.music.time = ]] .. musicSkipTo .. [[;
            if (vocals != null) vocals.time = ]] .. musicSkipTo .. [[;
        ]])

        -- Retire le message immédiatement si ESPACE est pressé
        if skipTextShown and not skipTextRemoved then
            removeLuaText('skipText', true)
            skipTextRemoved = true
        end
    end
end
