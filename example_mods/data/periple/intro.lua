function onCreate()
	setProperty('iconP2.alpha',0)
end

function onCreatePost()
    makeLuaSprite("black", nil, 0, 0)
    makeGraphic("black", screenWidth * 2, screenHeight * 2, "000000")
    addLuaSprite("black", false)
    setObjectCamera("black", "hud")
end

function onStepHit()
    if curStep == 1 then
        doTweenAlpha("PLEASE", "black", 0, 5, "linear")
    end

    if curStep == 304 then
    doTweenAlpha('iconP2', 'iconP2', 1, 1,5 / playbackRate)
	doTweenAlpha('stageback', 'stageback', 1, 1,5 / playbackRate)
	doTweenAlpha('stagefront', 'stagefront', 1, 1,5 / playbackRate)
	doTweenAlpha('audience_front', 'audience_front', 1, 1,5 / playbackRate)
	doTweenAlpha('stageserver', 'stageserver', 1, 1,5 / playbackRate)
	doTweenAlpha('stagelight', 'stagelight', 1, 1,5 / playbackRate)
end
end