function onCreate()
	-- sprites that only load if Low Quality is turned off
	-- Set the stage
	--Audience
	makeAnimatedLuaSprite('audience_front', 'bg/BackStage/gangsta/crowd', 700, 200);
	luaSpriteAddAnimationByPrefix('audience_front', 'audience_front', 'frontbop', '28')
	setLuaSpriteScrollFactor('audience_front', 0.9, 0.9);
	scaleObject('audience_front', 1, 1);

	setProperty('defaultCamZoom', 0.8)
	--Back
	makeLuaSprite('stageback', 'bg/BackStage/gangsta/back', 700, -200);
	scaleObject('stageback', 1.5, 1.5);

	--Ground and courtains
	makeLuaSprite('stagefront', 'bg/BackStage/gangsta/bg', -650, -475);
	scaleObject('stagefront', 1.2, 1.2);

	--Server
	makeLuaSprite('stageserver', 'bg/BackStage/gangsta/server', -125, 150);
	scaleObject('stageserver', 1, 1);

	--Lights
	makeLuaSprite('stagelight', 'bg/BackStage/gangsta/lights', -650, -300);
	setLuaSpriteScrollFactor('stagelight', 1.2, 1.1);
	scaleObject('stagelight', 1.1, 1);
	
	--Add sprites
	addLuaSprite('stageback', false);
	addLuaSprite('audience_front', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stageserver', false);
	addLuaSprite('stagelight', false);
end

function onCreatePost()
    if shadersEnabled then
        initLuaShader('adjustColor')

        applyShaderToSprite('boyfriend', 12, 0, 7, -23)
        applyShaderToSprite('dad', -32, 0, -23, -33)
        applyShaderToSprite('gf', -9, 0, -4, -30)
    end
end

function applyShaderToSprite(tag, hue, saturation, contrast, brightness)
    if not luaShaderExists('adjustColor') then
        debugPrint("Shader 'adjustColor' was not found!")
        return
    end

    setSpriteShader(tag, 'adjustColor')

    setShaderFloat(tag, 'hue', hue)
    setShaderFloat(tag, 'saturation', saturation)
    setShaderFloat(tag, 'contrast', contrast)
    setShaderFloat(tag, 'brightness', brightness)
end

function luaShaderExists(name)
    return pcall(function()
        initLuaShader(name)
    end)
end