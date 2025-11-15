function onCreate()
	setProperty('skipCountdown', true)

    makeLuaSprite('background', 'bg/metacrystal/bg', -300, -1000);
	scaleObject('background', 3, 3)
	setScrollFactor('background', 1.2, 1);
	addLuaSprite('background', false);
	
    makeLuaSprite('sol', 'bg/metacrystal/floor', -400, 0);
	scaleObject('sol', 1.7, 1.7)
	addLuaSprite('sol', false);

	makeLuaSprite('borderL', 'aspect', 0,0)
	addLuaSprite('borderL', true)
	setObjectCamera("borderL", "Other")
end

function onSongStart()
    setProperty('skipText.alpha',0)
end

local fadeStarted = false

function onCreatePost()
    setProperty("gf.visible", false)
    -- Fond noir
    makeLuaSprite('blackFade', nil, 0, 0)
    makeGraphic('blackFade', screenWidth, screenHeight, '000000')
    setScrollFactor('blackFade', 0, 0)
    setObjectCamera('blackFade', 'hud')
    setProperty('blackFade.alpha', 1)
    addLuaSprite('blackFade', true)
end

function onUpdatePost(elapsed)
    if not fadeStarted and getSongPosition() > 200 then
        -- Fade du noir
        doTweenAlpha('fadeToGame', 'blackFade', 0, 0.7, 'linear')
        fadeStarted = true
end
end

function onStepHit()    
    if curstep == 1344 then
	setProperty('camGame.alpha',0)
    end
end
