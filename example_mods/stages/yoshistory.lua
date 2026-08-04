function onCreate()
    setProperty('camZooming', true)

    makeLuaSprite('background', 'bg/yoshistory/bg', 0, 0);
	addLuaSprite('background', false);
    setObjectOrder('background', 10)
end

function onCreatePost()
    setProperty('camFollow.x', 950)
    setProperty('camFollow.y', 540)

    setProperty('isCameraOnForcedPos', true)
end