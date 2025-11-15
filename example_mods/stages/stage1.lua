local hueValue = -30
local saturationValue = 10
local contrastValue = 0
local brightnessValue = -5
local notePositions = {}

lightAlpha = 0
alphaDecreasing = false
function onCreate()
    local diff = string.lower(difficultyName or "")

    if diff == 'in-game-version' then
        setProperty('camZooming', true)

        makeLuaSprite('stagebackweird', 'bg/stage1/weird/stageback', -500, -300)
        setLuaSpriteScrollFactor('stagebackweird', 0.9, 0.9)

        makeLuaSprite('stagefrontweird', 'bg/stage1/weird/stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefrontweird', 0.9, 0.9)
        scaleObject('stagefrontweird', 1.1, 1.1)

        makeLuaSprite('stagelight_leftweird', 'bg/stage1/weird/stage_light', -125, -100)
        setLuaSpriteScrollFactor('stagelight_leftweird', 0.9, 0.9)
        scaleObject('stagelight_leftweird', 1.1, 1.1)

        makeLuaSprite('stagelight_rightweird', 'bg/stage1/weird/stage_light', 1225, -100)
        setLuaSpriteScrollFactor('stagelight_rightweird', 0.9, 0.9)
        scaleObject('stagelight_rightweird', 1.1, 1.1)
        setPropertyLuaSprite('stagelight_rightweird', 'flipX', true)

        makeLuaSprite('stagecurtainsweird', 'bg/stage1/weird/stagecurtains', -500, -300)
        setLuaSpriteScrollFactor('stagecurtainsweird', 1.3, 1.3)
        scaleObject('stagecurtainsweird', 0.9, 0.9)

        addLuaSprite('stagebackweird', false)
        addLuaSprite('stagefrontweird', false)
        addLuaSprite('stagelight_leftweird', false)
        addLuaSprite('stagelight_rightweird', false)
        addLuaSprite('stagecurtainsweird', false)
        
    elseif diff == 'in-game-mix' then
        setProperty('camZooming', true)

        makeLuaSprite('stagebackweird', 'bg/stage1/weird/stageback', -500, -300)
        setLuaSpriteScrollFactor('stagebackweird', 0.9, 0.9)

        makeLuaSprite('stagefrontweird', 'bg/stage1/weird/stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefrontweird', 0.9, 0.9)
        scaleObject('stagefrontweird', 1.1, 1.1)

        makeLuaSprite('stagelight_leftweird', 'bg/stage1/weird/stage_light', -125, -100)
        setLuaSpriteScrollFactor('stagelight_leftweird', 0.9, 0.9)
        scaleObject('stagelight_leftweird', 1.1, 1.1)

        makeLuaSprite('stagelight_rightweird', 'bg/stage1/weird/stage_light', 1225, -100)
        setLuaSpriteScrollFactor('stagelight_rightweird', 0.9, 0.9)
        scaleObject('stagelight_rightweird', 1.1, 1.1)
        setPropertyLuaSprite('stagelight_rightweird', 'flipX', true)

        makeLuaSprite('stagecurtainsweird', 'bg/stage1/weird/stagecurtains', -500, -300)
        setLuaSpriteScrollFactor('stagecurtainsweird', 1.3, 1.3)
        scaleObject('stagecurtainsweird', 0.9, 0.9)

        addLuaSprite('stagebackweird', false)
        addLuaSprite('stagefrontweird', false)
        addLuaSprite('stagelight_leftweird', false)
        addLuaSprite('stagelight_rightweird', false)
        addLuaSprite('stagecurtainsweird', false)

    function onCreatePost()
    setProperty('iconP1.flipX', 1) --�a permet de mirror les icons
    setProperty('iconP2.flipX', 1)
    setProperty('healthBar.flipX', 1) --�a permet de mirror la Health Bar

    notePositions = {
        defaultPlayerStrumX0,
        defaultPlayerStrumX1,
        defaultPlayerStrumX2,
        defaultPlayerStrumX3,
        defaultOpponentStrumX0,
        defaultOpponentStrumX1,
        defaultOpponentStrumX2,
        defaultOpponentStrumX3
    }
    
    for i = 1, 8, 1 do
        noteTweenX('noteTween'..i, i-1, notePositions[i], 0.01, 'linear')
    end

    function onUpdatePost() --�a permet a ce que la vie bouge dans le bon sens
    setProperty('iconP1.x', -593+getProperty('healthBar.x') + (getProperty('healthBar.width')*(remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0)*0.01))-(150 * getProperty('iconP1.scale.x'))/2 - 26*2)
    setProperty('iconP2.x', -593+getProperty('healthBar.x') + (getProperty('healthBar.width')*(remapToRange(getProperty('healthBar.percent'), 0, -100, 100, 0)*0.01))+(150 * getProperty('iconP2.scale.x')-150)/2 - 26)
end

function remapToRange(value, start1, stop1, start2, stop2) --�a permet que les icons aillent dans le bon sens 
    return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end
end
    elseif diff == 'dead-in-game-version' then

        setProperty('scoreTxt.visible', false);

        setProperty('camZooming', true)

        makeLuaSprite('stagebackweird2', 'bg/stage1/weird2/stageback', -500, -300)
        setLuaSpriteScrollFactor('stagebackweird2', 0.9, 0.9)

        makeLuaSprite('stagefrontweird2', 'bg/stage1/weird2/stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefrontweird2', 0.9, 0.9)
        scaleObject('stagefrontweird2', 1.1, 1.1)

        addLuaSprite('stagebackweird2', false)
        addLuaSprite('stagefrontweird2', false)

    elseif diff == 'dead-in-game-mix' then

    makeLuaSprite('whitebar', 'bg/stage1/whitebar', 0, 50)
    setProperty('whitebar.scale.x', 1.1)
    setProperty('whitebar.scale.y', 0.4)
    addLuaSprite('whitebar', true);
    setObjectCamera("whitebar", "other")

	setProperty('skipCountdown', true)
    setProperty('cameraSpeed', 999) 
    setProperty('isCameraOnForcedPos', true) -- reste fixée ici
    
    function onUpdatePost()
    setProperty('camHUD.visible', false);

function onGameOver()
    return Function_Stop -- empêche l'écran de game over
end

function onBeatHit()
    setProperty('dad.scale.x', 1.1)
    setProperty('dad.scale.y', 1.1)
    doTweenX('dadBackX','dad.scale',1,0.05,'linear')
    doTweenY('dadBackY','dad.scale',1,0.05,'linear')
end
    
function onCreatePost()
	setProperty('gf.visible', false)
end
end

    elseif diff == 'bad' then
        makeLuaSprite('stagebackbad', 'bg/stage1/bad/stageback', -500, -300)
        setLuaSpriteScrollFactor('stagebackbad', 0.9, 0.9)

        makeLuaSprite('stagefrontbad', 'bg/stage1/bad/stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefrontbad', 0.9, 0.9)
        scaleObject('stagefrontbad', 1.1, 1.1)

        makeLuaSprite('stagecurtainsbad', 'bg/stage1/bad/stagecurtains', -500, -300)
        setLuaSpriteScrollFactor('stagecurtainsbad', 1.3, 1.3)
        scaleObject('stagecurtainsbad', 0.9, 0.9)

        addLuaSprite('stagebackbad', false)
        addLuaSprite('stagefrontbad', false)
        addLuaSprite('stagecurtainsbad', false)

    elseif diff == 'corruption' then
        makeLuaSprite('stagebackcorruption', 'bg/stage1/corruption/stageback', -500, -300);
	    setLuaSpriteScrollFactor('stagebackcorruption', 0.9, 0.9);
	
    	makeLuaSprite('stagefrontcorruption', 'bg/stage1/corruption/stagefront', -650, 600);
    	setLuaSpriteScrollFactor('stagefrontcorruption', 0.9, 0.9);
    	scaleObject('stagefrontcorruption', 1.1, 1.1);

	    makeLuaSprite('stagecurtainscorruption', 'bg/stage1/corruption/stagecurtains', -500, -300);   
        setLuaSpriteScrollFactor('stagecurtainscorruption', 1.3, 1.3);
    	scaleObject('stagecurtainscorruption', 0.9, 0.9);

    	addLuaSprite('stagebackcorruption', false);
    	addLuaSprite('stagefrontcorruption', false);
    	addLuaSprite('stagelight_leftcorruption', false);
    	addLuaSprite('stagelight_rightcorruption', false);
    	addLuaSprite('stagecurtainscorruption', false);

    elseif diff == 'erect' or diff == 'nightmare' then
        initLuaShader('adjustColor')
        makeLuaSprite('stagebackerect', 'bg/stage1/erect/stageback', -500, -300)
        setLuaSpriteScrollFactor('stagebackweird', 0.9, 0.9)

        makeLuaSprite('stagefronterect', 'bg/stage1/erect/stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefronterect', 0.9, 0.9)
        scaleObject('stagefronterect', 1.1, 1.1)

        makeLuaSprite('stagelight_lefterect', 'bg/stage1/erect/stage_light', -125, -100)
        setLuaSpriteScrollFactor('stagelight_lefterect', 0.9, 0.9)
        scaleObject('stagelight_lefterect', 1.1, 1.1)

        makeLuaSprite('stagelight_righterect', 'bg/stage1/erect/stage_light', 1225, -100)
        setLuaSpriteScrollFactor('stagelight_righterect', 0.9, 0.9)
        scaleObject('stagelight_righterect', 1.1, 1.1)
        setPropertyLuaSprite('stagelight_righterect', 'flipX', true)

        makeLuaSprite('stagecurtainserect', 'bg/stage1/erect/stagecurtains', -500, -300)
        setLuaSpriteScrollFactor('stagecurtainserect', 1.3, 1.3)
        scaleObject('stagecurtainserect', 0.9, 0.9)

        addLuaSprite('stagebackerect', false)
        addLuaSprite('stagefronterect', false)
        addLuaSprite('stagelight_lefterect', false)
        addLuaSprite('stagelight_righterect', false)
        addLuaSprite('stagecurtainserect', false)
        
        function onUpdate(elapsed)
        for _, char in ipairs({'dad', 'gf', 'boyfriend'}) do
        setSpriteShader(char, 'adjustColor')
        setShaderFloat(char, 'hue', hueValue)
        setShaderFloat(char, 'saturation', saturationValue)
        setShaderFloat(char, 'contrast', contrastValue)
        setShaderFloat(char, 'brightness', brightnessValue)
        end
    if alphaDecreasing then
        lightAlpha = lightAlpha - (elapsed * 0.55)
        if lightAlpha <= 0 then
            lightAlpha = 0
            alphaDecreasing = false
        end
    end
end
    else        
        makeLuaSprite('stageback', 'bg/stage1/stageback', -500, -300)
        setLuaSpriteScrollFactor('stageback', 0.9, 0.9)

        makeLuaSprite('stagefront', 'bg/stage1/stagefront', -650, 600)
        setLuaSpriteScrollFactor('stagefront', 0.9, 0.9)
        scaleObject('stagefront', 1.1, 1.1)

        if not lowQuality then
            makeLuaSprite('stagelight_left', 'bg/stage1/stage_light', -125, -100)
            setLuaSpriteScrollFactor('stagelight_left', 0.9, 0.9)
            scaleObject('stagelight_left', 1.1, 1.1)

            makeLuaSprite('stagelight_right', 'bg/stage1/stage_light', 1225, -100)
            setLuaSpriteScrollFactor('stagelight_right', 0.9, 0.9)
            scaleObject('stagelight_right', 1.1, 1.1)
            setPropertyLuaSprite('stagelight_right', 'flipX', true)

            makeLuaSprite('stagecurtains', 'bg/stage1/stagecurtains', -500, -300)
            setLuaSpriteScrollFactor('stagecurtains', 1.3, 1.3)
            scaleObject('stagecurtains', 0.9, 0.9)
        end

        addLuaSprite('stageback', false)
        addLuaSprite('stagefront', false)
        addLuaSprite('stagelight_left', false)
        addLuaSprite('stagelight_right', false)
        addLuaSprite('stagecurtains', false)
    end
end