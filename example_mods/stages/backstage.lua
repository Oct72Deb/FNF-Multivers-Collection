function onCreate()	   
	setProperty('defaultCamZoom', 0.6)
	-- sprites that only load if Low Quality is turned off
	-- Set the stage
	--Audience
	makeAnimatedLuaSprite('audience_front', 'bg/BackStage/periple/crowd', 700, 200);
	luaSpriteAddAnimationByPrefix('audience_front', 'audience_front', 'frontbop', '28')
	setLuaSpriteScrollFactor('audience_front', 0.9, 0.9);
	scaleObject('audience_front', 1, 1);
	
	--Back
	makeLuaSprite('stageback', 'bg/BackStage/periple/back', 700, -200);
	scaleObject('stageback', 1.5, 1.5);

	--Ground and courtains
	makeLuaSprite('stagefront', 'bg/BackStage/periple/bg', -950, -475);
	scaleObject('stagefront', 1.2, 1.2);

	--Server
	makeLuaSprite('stageserver', 'bg/BackStage/periple/server', 0, 150);
	scaleObject('stageserver', 1, 1);

	--Lights
	makeLuaSprite('stagelight', 'bg/BackStage/periple/lights', -650, -300);
	setLuaSpriteScrollFactor('stagelight', 1.2, 1.1);
	scaleObject('stagelight', 1.1, 1);
	
	--Add sprites
	addLuaSprite('stageback', false);
	addLuaSprite('audience_front', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stageserver', false);
	addLuaSprite('stagelight', true);

	setProperty('stageback.alpha', 0)
	setProperty('stagefront.alpha', 0)
	setProperty('audience_front.alpha', 0)
	setProperty('stageserver.alpha', 0)
	setProperty('stagelight.alpha', 0)
end