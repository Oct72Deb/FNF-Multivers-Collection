function onMoveCamera(focus)
    if focus == 'boyfriend' then
        setProperty('defaultCamZoom', 1)

    else if focus == 'dad' then
        setProperty('defaultCamZoom', 0.6)
    end
end
end

function onCreate()
    makeLuaSprite('floor', 'bg/tiny/floor', -700, -350);
	scaleObject('floor', 1.6, 1.6)
	addLuaSprite('floor', false);

	makeLuaSprite('background', 'bg/tiny/bg', -700, -600);
	scaleObject('background', 1.6, 1.6)
	addLuaSprite('background', false);

	makeLuaSprite('HUD', 'fmShade', 0, 0);
	setLuaSpriteScrollFactor('HUD', 1, 1);
	scaleObject('HUD', 1, 1);
    setObjectCamera('HUD', 'camOther');
	addLuaSprite('HUD', false);
end

function onCreatePost()
	setProperty('gf.visible', false)
	
	setObjectOrder('dadGroup', 7)
	setObjectOrder('floor', 6)
	setObjectOrder('boyfriendGroup', 7)
end