    function onCreate()
        setProperty('skipCountdown', true)
        setProperty('iconP2.alpha',0)
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