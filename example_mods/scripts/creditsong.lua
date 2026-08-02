local curSong = ''

function onCreate()
    curSong = string.lower(string.gsub(songName, " ", "-"))

    if curSong == 'criminal-targets' then
        makeLuaSprite('creditsong', 'hud/creditsong/targets', 160, 500)
        scaleObject('creditsong', 0.71, 0.71)
        setObjectCamera("creditsong", "hud")

    elseif curSong == 'metal-reflection' then
        makeLuaSprite('creditsong', 'hud/creditsong/metal', 160, 500)
        scaleObject('creditsong', 0.71, 0.71)
        setObjectCamera("creditsong", "hud")

    elseif curSong == 'new-game' then
        makeLuaSprite('creditsong', 'hud/creditsong/horrormario', 0, 0)
        scaleObject('creditsong', 0.6, 0.6)
        setObjectCamera("creditsong", "other")
        addLuaSprite('creditsong', true)
        screenCenter('creditsong', 'xy')

    elseif curSong == 'trick-or-treat-old' then
        makeLuaSprite('creditsong', 'hud/creditsong/dokishit', 0, 0)
        scaleObject('creditsong', 0.4, 0.4)
        setObjectCamera("creditsong", "other")
        addLuaSprite('creditsong', true)
        screenCenter('creditsong', 'xy')

    elseif curSong == 'how-to-play' then
        makeLuaSprite('creditsong', 'hud/creditsong/htp', 160, 380)
        scaleObject('creditsong', 0.71, 0.71)
        setObjectCamera("creditsong", "hud")
        addLuaSprite('creditsong', true)

    elseif curSong == 'trick-or-treat' then
        makeLuaSprite('creditsong', 'hud/creditsong/doki', 0, 0)
        scaleObject('creditsong', 0.4, 0.4)
        setObjectCamera("creditsong", "other")
        addLuaSprite('creditsong', true)
        screenCenter('creditsong', 'xy')
    end

    setProperty('creditsong.alpha', 0)
    
    if curSong ~= 'new-game' and curSong ~= 'trick-or-treat-old' and curSong ~= 'trick-or-treat' and curSong ~= 'how-to-play' then
        addLuaSprite('creditsong', true)
    end
end

function onStepHit()
    if curSong == 'criminal-targets' then
        if curStep == 1 then
            doTweenAlpha('creditsIn', 'creditsong', 1, 0.5, 'linear')
        elseif curStep == 32 then
            doTweenAlpha('creditsOut', 'creditsong', 0, 0.5, 'linear')
        end

    elseif curSong == 'metal-reflection' then
        if curStep == 16 then
            doTweenAlpha('creditsIn', 'creditsong', 1, 0.5, 'linear')
        elseif curStep == 53 then
            doTweenAlpha('creditsOut', 'creditsong', 0, 0.5, 'linear')
        end

    elseif curSong == 'new-game' then
        if curStep == 352 then
            doTweenAlpha('creditsIn', 'creditsong', 1, 0.5 / playbackRate, 'linear')
        elseif curStep == 400 then
            doTweenAlpha('creditsOut', 'creditsong', 0, 1 / playbackRate, 'linear')
        end

    elseif curSong == 'trick-or-treat-old' then
        if curStep == 64 then
            doTweenAlpha('creditsIn', 'creditsong', 1, 1 / playbackRate, 'linear')
        elseif curStep == 95 then
            doTweenAlpha('creditsOut', 'creditsong', 0, 1 / playbackRate, 'linear')
        end

    elseif curSong == 'how-to-play' then
        if curStep == 1 then
            doTweenAlpha('creditsIn', 'creditsong', 1, 0.01 / playbackRate, 'linear')
        elseif curStep == 32 then
            -- CHANGEMENT ICI : Remplacement de 'speed' par un temps de fondu fixe
            doTweenAlpha('creditsOut', 'creditsong', 0, 0.5 / playbackRate, 'linear')
        end

    elseif curSong == 'trick-or-treat' then
        if curStep == 32 then
            doTweenAlpha('creditsIn', 'creditsong', 1, 1 / playbackRate, 'linear')
        elseif curStep == 64 then
            doTweenAlpha('creditsOut', 'creditsong', 0, 1 / playbackRate, 'linear')
        end
    end
end