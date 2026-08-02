local shadersEnabled = true

local xrot, yrot, zrot = 0.0, 0.0, 0.0
local xpos, ypos, zpos = 0.0, 0.0, 0.0
local hue     = 1.3  -- 0.0 à 2.0 (1.3 = bleu)
local opacity = 0.7  -- 0.0 à 1.0

function onCreate()
    if shadersEnabled then
        initLuaShader('3D')
        initLuaShader('blue')

        makeLuaSprite('cam3D', nil)
        makeGraphic('cam3D', screenWidth, screenHeight)
        setSpriteShader('cam3D', '3D')

        makeLuaSprite('camBlue', nil)
        makeGraphic('camBlue', screenWidth, screenHeight)
        setSpriteShader('camBlue', 'blue')

        runHaxeCode([[
            FlxG.game.setFilters([
                new ShaderFilter(game.modchartSprites.get('cam3D').shader),
                new ShaderFilter(game.modchartSprites.get('camBlue').shader)
            ]);
        ]])

        setShaderFloat('cam3D', 'xrot', xrot)
        setShaderFloat('cam3D', 'yrot', yrot)
        setShaderFloat('cam3D', 'zrot', zrot)
        setShaderFloat('cam3D', 'xpos', xpos)
        setShaderFloat('cam3D', 'ypos', ypos)
        setShaderFloat('cam3D', 'zpos', zpos)

        setShaderFloat('camBlue', 'hue', hue)
    end
end

function onDestroy()
    if shadersEnabled then
        runHaxeCode([[ FlxG.game.setFilters([]); ]])
    end
end