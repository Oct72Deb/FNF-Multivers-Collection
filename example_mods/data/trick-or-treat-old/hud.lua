function onStepHit()
    if curStep == 580 then
        doTweenAlpha('bar', 'healthBar', 0, 1, 'linear')
        doTweenAlpha('icon1', 'iconP1', 0, 1, 'linear')
        doTweenAlpha('icon2', 'iconP2', 0, 1, 'linear')
        doTweenAlpha('score', 'scoreTxt', 0, 1, 'linear')
        doTweenAlpha('timeBar', 'timeBar', 0, 1, 'linear')
        doTweenAlpha('timeTxt', 'timeTxt', 0, 1, 'linear')
        doTweenAlpha('timeBG', 'timeBarBG', 0, 1, 'linear')
        doTweenAlpha('heal', 'heal', 0, 1, 'linear')

     elseif curStep == 764  then
        doTweenAlpha('bar', 'healthBar', 1, 0.3, 'linear')
        doTweenAlpha('icon1', 'iconP1', 1, 0.3, 'linear')
        doTweenAlpha('icon2', 'iconP2', 1, 0.3, 'linear')
        doTweenAlpha('score', 'scoreTxt', 1, 0.3, 'linear')
        doTweenAlpha('timeBar', 'timeBar', 1, 0.3, 'linear')
        doTweenAlpha('timeTxt', 'timeTxt', 1, 0.3, 'linear')
        doTweenAlpha('timeBG', 'timeBarBG', 1, 0.3, 'linear')
        doTweenAlpha('heal', 'heal', 1, 1, 'linear')

     elseif curStep == 1292 then
        doTweenAlpha('bar', 'healthBar', 0, 1, 'linear')
        doTweenAlpha('icon1', 'iconP1', 0, 1, 'linear')
        doTweenAlpha('icon2', 'iconP2', 0, 1, 'linear')
        doTweenAlpha('score', 'scoreTxt', 0, 1, 'linear')
        doTweenAlpha('timeBar', 'timeBar', 0, 1, 'linear')
        doTweenAlpha('timeTxt', 'timeTxt', 0, 1, 'linear')
        doTweenAlpha('timeBG', 'timeBarBG', 0, 1, 'linear')
        doTweenAlpha('heal', 'heal', 0, 1, 'linear')
end
end