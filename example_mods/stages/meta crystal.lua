function onCreate()
	makeLuaSprite('borderL', 'aspect', 0,0)
	addLuaSprite('borderL', true)
	setObjectCamera("borderL", "other")
    
	setProperty('skipCountdown', true)

    makeLuaSprite('background', 'bg/metacrystal/bg', -300, -1000);
	scaleObject('background', 3, 3)
	setScrollFactor('background', 1.2, 1);
	addLuaSprite('background', false);

    makeLuaSprite('solarriere', 'bg/metacrystal/solarriere', -400, -1330);
	scaleObject('solarriere', 1.8, 1.8)
	addLuaSprite('solarriere', false);

    makeLuaSprite('diamants', 'bg/metacrystal/diamants', -400, -1330);
	scaleObject('diamants', 1.8, 1.8)
	addLuaSprite('diamants', false);
	
    makeLuaSprite('sol', 'bg/metacrystal/floor', -400, -1330);
	scaleObject('sol', 1.8, 1.8)
	addLuaSprite('sol', false);

    makeLuaSprite('platform', 'bg/metacrystal/platform', -200, -1360);
	scaleObject('platform', 1.8, 1.8)
	addLuaSprite('platform', true);
end

local fadeStarted = false

function onCreatePost()
    setProperty("gf.visible", false)

    makeLuaSprite('blackFade', nil, 0, 0)
    makeGraphic('blackFade', screenWidth, screenHeight, '000000')
    setScrollFactor('blackFade', 0, 0)
    setObjectCamera('blackFade', 'hud')
    setProperty('blackFade.alpha', 1)
    addLuaSprite('blackFade', true)
end

function onUpdatePost(elapsed)
    if not fadeStarted and getSongPosition() > 200 then
        doTweenAlpha('fadeToGame', 'blackFade', 0, 0.7, 'linear')
        fadeStarted = true
end
end

function onStepHit()    
    if curStep == 1344 then
		setProperty('camGame.alpha',0)
    end
end

function onBeatHit()	
    if curBeat % 4 == 0 then
	
		local r = string.format("%02X", getRandomInt(100, 255))
		local g = string.format("%02X", getRandomInt(100, 255))
		local b = string.format("%02X", getRandomInt(100, 255))
		local randomColor = r .. g .. b
		
		local tweenDuration = (crochet / 1000) * 2

		doTweenColor('diamantsColorTween', 'diamants', randomColor, tweenDuration, 'linear')
	end
end