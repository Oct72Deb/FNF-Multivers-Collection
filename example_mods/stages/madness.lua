function onCreate()
	setProperty('skipCountdown', true)
	
	makeLuaSprite('HUD', 'fmShade', 0, 0);
	setLuaSpriteScrollFactor('HUD', 1, 1);
	scaleObject('HUD', 1, 1);
    setObjectCamera('HUD', 'camOther');
	addLuaSprite('HUD', false);

	makeLuaSprite('black','black', -5000, -5000);
	setLuaSpriteScrollFactor('black', 0, 0);
	scaleObject('black', 20, 20);
	addLuaSprite('black', true);
end

function onSongStart()
	setProperty('camHUD.alpha',0)
end

function onStepHit()
	if curStep == 352 then
	setProperty('black.alpha',0)
	setProperty('camHUD.alpha',1)
	end
	if curStep == 1375 then
    setProperty('cameraSpeed', 0.5)
	end
		if curStep == 1622 then
		setProperty('black.alpha',1)
end
		if curStep == 1632 then
		setProperty('black.alpha',0)
end
end