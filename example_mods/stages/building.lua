function onCreate()
        makeLuaSprite('bg', 'bg/star/bg', -950, -750)
        setLuaSpriteScrollFactor('bg', 0.1, 0.1)
        scaleObject('bg', 2.4, 3.0)
        addLuaSprite('bg', false)

		makeLuaSprite('bat2', 'bg/star/immeubles2', -925, -450)
        setLuaSpriteScrollFactor('bat2', 0.3, 0.2)
        scaleObject('bat2', 1.9, 1.9)
        addLuaSprite('bat2', false)

		makeLuaSprite('bat1', 'bg/star/immeubles1', -1000, -460)
		setLuaSpriteScrollFactor('bat1', 0.4, 0.3)
        scaleObject('bat1', 1.9, 1.9)
        addLuaSprite('bat1', false)

		makeLuaSprite('aurableu', 'bg/star/aurableu', -1100, 400)
        scaleObject('aurableu', 1.9, 1.9)
        addLuaSprite('aurableu', false)

        makeLuaSprite('sol', 'bg/star/sol', -1100, -610)
        scaleObject('sol', 1.9, 1.9)
        addLuaSprite('sol', false)

	    makeLuaSprite('canettes', 'bg/star/canettes', -1100, -610)
        scaleObject('canettes', 1.9, 1.9)
        addLuaSprite('canettes', true)
end


function onCreatePost()
    if shadersEnabled then
        initLuaShader('adjustColor')

        applyShaderToSprite('boyfriend', -32, 0, 0, -40)
        applyShaderToSprite('dad', -12, 0, 0, -40)
        applyShaderToSprite('gf', -32, 0, 0, -40)
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