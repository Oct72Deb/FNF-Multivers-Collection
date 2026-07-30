local hueValue = -30
local saturationValue = 10
local contrastValue = 0
local brightnessValue = -5
local notePositions = {}

local diff = '' 
local currentPixelSize = 0 
local targetPixelSize = 1.2
local pixelActive = false

function onCreate()
    diff = string.lower(difficultyName or "")
    local folder = ''
    if diff == 'in-game-version' or diff == 'in-game-mix' then
        folder = 'weird/'
    elseif diff == 'dead-in-game-version' then
        folder = 'weird2/'
    elseif diff == 'corruption' then
        folder = 'corruption/'
    elseif diff == 'erect' or diff == 'nightmare' then
        folder = 'erect/'
        initLuaShader('adjustColor')
    elseif diff == 'pico-mix' then
        folder = 'backstage/'
        initLuaShader('adjustColor')
    else
        folder = ''
    end

    if diff == 'minus' then
        initLuaShader('pixel')
        initLuaShader('vhs') 
        
        makeLuaSprite('vhsCam', nil)
        makeGraphic('vhsCam', screenWidth, screenHeight)
        setSpriteShader('vhsCam', 'vhs')

        makeLuaSprite('pixelCam', nil)
        makeGraphic('pixelCam', screenWidth, screenHeight)
        setSpriteShader('pixelCam', 'pixel')
        
        shaderCoordFix() 
    end

    if diff == 'dead-in-game-mix' then
        makeLuaSprite('whitebar', 'bg/stage1/whitebar', 0, 50)
        setProperty('whitebar.scale.x', 1.1)
        setProperty('whitebar.scale.y', 0.4)
        addLuaSprite('whitebar', true)
        setObjectCamera("whitebar", "other")
        setProperty('skipCountdown', true)
        setProperty('cameraSpeed', 999) 
        setProperty('isCameraOnForcedPos', true)
        return
    end

    setProperty('camZooming', true)

    if diff == 'pico-mix' then
        setProperty('boyfriendGroup.x', 900)
        setProperty('boyfriendGroup.y', 30)
        
        setProperty('gfGroup.x', 400)
        setProperty('gfGroup.y', 50)
        
        setProperty('dadGroup.x', 50)
        setProperty('dadGroup.y', 30)

        setProperty('defaultCamZoom', 0.8)

        makeLuaSprite('stageback', 'bg/stage1/' .. folder .. 'back', 700, -200)
        scaleObject('stageback', 1.5, 1.5)
        addLuaSprite('stageback', false)

        makeAnimatedLuaSprite('audience_front', 'bg/stage1/' .. folder .. 'crowd', 700, 200)
        luaSpriteAddAnimationByPrefix('audience_front', 'audience_front', 'frontbop', 28, true)
        setLuaSpriteScrollFactor('audience_front', 0.9, 0.9)
        addLuaSprite('audience_front', false)

        makeLuaSprite('stagefront', 'bg/stage1/' .. folder .. 'bg', -650, -475)
        scaleObject('stagefront', 1.2, 1.2)
        addLuaSprite('stagefront', false)

        makeLuaSprite('stageserver', 'bg/stage1/' .. folder .. 'server', -125, 150)
        addLuaSprite('stageserver', false)

        makeLuaSprite('stagelight', 'bg/stage1/' .. folder .. 'lights', -650, -300)
        setLuaSpriteScrollFactor('stagelight', 1.2, 1.1)
        scaleObject('stagelight', 1.1, 1)
        addLuaSprite('stagelight', false)
    else
        -- Code original du Stage 1 pour les autres difficultés
        makeLuaSprite('stageback', 'bg/stage1/' .. folder .. 'stageback', -500, -300)
        setLuaSpriteScrollFactor('stageback', 0.9, 0.9)
        addLuaSprite('stageback', false)

        makeLuaSprite('stagefront', 'bg/stage1/' .. folder .. 'stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefront', 0.9, 0.9)
        scaleObject('stagefront', 1.1, 1.1)
        addLuaSprite('stagefront', false)

        if diff ~= 'dead-in-game-version' then
            if not lowQuality or folder ~= '' then
                makeLuaSprite('stagelight_left', 'bg/stage1/' .. folder .. 'stage_light', -125, -100)
                addLuaSprite('stagelight_left', false)

                makeLuaSprite('stagelight_right', 'bg/stage1/' .. folder .. 'stage_light', 1225, -100)
                setPropertyLuaSprite('stagelight_right', 'flipX', true)
                addLuaSprite('stagelight_right', false)

                makeLuaSprite('stagecurtains', 'bg/stage1/' .. folder .. 'stagecurtains', -500, -300)
                setLuaSpriteScrollFactor('stagecurtains', 1.3, 1.3)
                addLuaSprite('stagecurtains', false)
            end
        end
    end
end

function onStepHit()
    if diff == 'minus' then
        if curStep == 383 then
            pixelActive = true
            currentPixelSize = targetPixelSize
            runHaxeCode([[
                var pixelFilter = new ShaderFilter(game.getLuaObject('pixelCam').shader);
                var vhsFilter = new ShaderFilter(game.getLuaObject('vhsCam').shader);
                FlxG.game.setFilters([pixelFilter, vhsFilter]);
            ]])
        elseif curStep == 640 then
            pixelActive = false
            runHaxeCode([[
                FlxG.game.setFilters([]);
            ]])
        end
    end
end

function onUpdate(elapsed)
    if diff == 'minus' and pixelActive then
        setShaderInt('vhsCam', 'uFrame', math.floor(os.clock() * 60))
        setShaderFloat("pixelCam", "size", currentPixelSize) 
        setShaderFloat("pixelCam", "iTime", os.clock()) 
    end

    if diff == 'erect' or diff == 'nightmare' then
        for _, char in ipairs({'dad', 'gf', 'boyfriend'}) do
            setSpriteShader(char, 'adjustColor')
            setShaderFloat(char, 'hue', hueValue)
            setShaderFloat(char, 'saturation', saturationValue)
        end
    end
end

function onCreatePost()
    if diff == 'in-game-mix' then
        setProperty('iconP1.flipX', 1)
        setProperty('iconP2.flipX', 1)
        setProperty('healthBar.flipX', 1)

        notePositions = {
            defaultPlayerStrumX0, defaultPlayerStrumX1, defaultPlayerStrumX2, defaultPlayerStrumX3,
            defaultOpponentStrumX0, defaultOpponentStrumX1, defaultOpponentStrumX2, defaultOpponentStrumX3
        }
        for i = 1, 8, 1 do
            noteTweenX('noteTween'..i, i-1, notePositions[i], 0.01, 'linear')
        end
    elseif diff == 'dead-in-game-mix' then
        setProperty('gf.visible', false)
    elseif diff == 'pico-mix' then
        if shadersEnabled then
            local charShaders = {
                boyfriend = {h = 12, s = 0, c = 7, b = -23},
                dad = {h = -32, s = 0, c = -23, b = -33},
                gf = {h = -9, s = 0, c = -4, b = -30}
            }

            for charName, values in pairs(charShaders) do
                setSpriteShader(charName, 'adjustColor')
                setShaderFloat(charName, 'hue', values.h)
                setShaderFloat(charName, 'saturation', values.s)
                setShaderFloat(charName, 'contrast', values.c)
                setShaderFloat(charName, 'brightness', values.b)
            end
        end
    end
end

function onUpdatePost()
    if diff == 'in-game-mix' then
        local hpPercent = remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0) * 0.01
        setProperty('iconP1.x', -593 + getProperty('healthBar.x') + (getProperty('healthBar.width') * hpPercent) - (150 * getProperty('iconP1.scale.x')) / 2 - 52)
        setProperty('iconP2.x', -593 + getProperty('healthBar.x') + (getProperty('healthBar.width') * hpPercent) + (150 * getProperty('iconP2.scale.x') - 150) / 2 - 26)
    elseif diff == 'dead-in-game-mix' then
        setProperty('camHUD.visible', false)
    end
end

function onBeatHit()
    if diff == 'dead-in-game-mix' then
        setProperty('dad.scale.x', 1.1)
        setProperty('dad.scale.y', 1.1)
        doTweenX('dadBackX', 'dad.scale', 1, 0.05, 'linear')
        doTweenY('dadBackY', 'dad.scale', 1, 0.05, 'linear')
    end
end

function onGameOver()
    if diff == 'dead-in-game-mix' then
        return Function_Stop
    end
    return Function_Continue
end

function remapToRange(value, start1, stop1, start2, stop2)
    return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end

function shaderCoordFix()
    runHaxeCode([[
        resetCamCache = function(?spr) {
            if (spr == null || spr.filters == null) return;
            spr.__cacheBitmap = null;
            spr.__cacheBitmapData = null;
        }
        fixShaderCoordFix = function(?_) {
            resetCamCache(game.camGame.flashSprite);
            resetCamCache(game.camHUD.flashSprite);
        }
        FlxG.signals.gameResized.add(fixShaderCoordFix);
        fixShaderCoordFix();
    ]])
end