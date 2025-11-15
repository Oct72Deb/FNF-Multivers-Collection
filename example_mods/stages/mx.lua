function onCreate()
		setProperty('defaultCamZoom', 0.8)
	
        makeLuaSprite('sol', 'bg/mxfake/floor', -320, -200);
	scaleObject('sol', 1.0, 1.0);
	addLuaSprite('sol', false);
end
function onStepHit()
	if curStep == 400 then
		removeLuaSprite('sol', true);

		makeLuaSprite('background', 'bg/mx/black', -500, -430);
		addLuaSprite('background', false);
	
			makeLuaSprite('nuage', 'bg/mx/nuage', 1000, -150);
		scaleObject('nuage', 0.8, 0.8);
		addLuaSprite('nuage', false);
			setScrollFactor('nuage', 0.8, 1);
	
			makeLuaSprite('d', 'bg/mx/d', -200, 100);
		scaleObject('d', 0.9, 0.9);
		addLuaSprite('d', false);
			setScrollFactor('d', 0.9, 1);
			
			makeLuaSprite('floor', 'bg/mx/fullfloor', -390, -130);
		addLuaSprite('floor', false);
	
			makeLuaSprite('drapeau', 'bg/mx/drapeau', 1400, -200);
		addLuaSprite('drapeau', false);
	end
end