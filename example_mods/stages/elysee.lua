function onCreate()
    makeLuaSprite('macronBG', 'bg/praizidan/macronBG', 0, 0)
    makeLuaSprite('desk', 'bg/praizidan/desk front', 0, 0)
    
    makeLuaSprite('macronBGred', 'bg/praizidan/macronBG evil', 0, 0)
    makeLuaSprite('deskred', 'bg/praizidan/desk front evil', 0, 0)
	
    addLuaSprite('macronBG', false)
    addLuaSprite('desk', false)
    addLuaSprite('macronBGred', false)
    addLuaSprite('deskred', false)

    setProperty('macronBGred.visible', false)
    setProperty('deskred.visible', false)

    setProperty('camZooming', true)
end

function onCreatePost()
    setProperty('gf.visible', false)

    setObjectOrder('dadGroup', 5)
    setObjectOrder('desk', 6)
    setObjectOrder('deskred', 6)
    setObjectOrder('boyfriendGroup', 7)
end

function onMoveCamera(focus)
    if focus == 'boyfriend' then
        setProperty('defaultCamZoom', 0.8)
    elseif focus == 'dad' then
        setProperty('defaultCamZoom', 1)
    end
end