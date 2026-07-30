function onStepHit()
	if curStep == 304 then
	doTweenAlpha('stageback', 'stageback', 1, 1,5 / playbackRate)
	doTweenAlpha('stagefront', 'stagefront', 1, 1,5 / playbackRate)
	doTweenAlpha('audience_front', 'audience_front', 1, 1,5 / playbackRate)
	doTweenAlpha('stageserver', 'stageserver', 1, 1,5 / playbackRate)
	doTweenAlpha('stagelight', 'stagelight', 1, 1,5 / playbackRate)
end
end