local shadersEnabled = true

function onCreate() 
    if shadersEnabled then  
        local var ShaderName = 'vhs'
        initLuaShader(ShaderName)
        makeLuaSprite('camShader', nil)
        makeGraphic('camShader', screenWidth, screenHeight)
        setSpriteShader('camShader', ShaderName)
        

        runHaxeCode([[
            trace(game.getLuaObject('camShader').shader + ' Has Been Loaded!');                      
            FlxG.game.setFilters([new ShaderFilter(game.getLuaObject('camShader').shader)]);
        ]])

        function onUpdate(elapsed)
            setShaderInt('camShader', 'uFrame', math.floor(os.clock() * 60))
        end
    end
end

function onDestroy()
    if shadersEnabled then
        runHaxeCode([[
            FlxG.game.setFilters([]);
        ]])
    end
end