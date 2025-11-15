function onCreate()
	setProperty('skipCountdown', true)

	makeLuaSprite('borderL', 'bg/howtoplay/aspect',0,0)
	addLuaSprite('borderL', false)
	setObjectCamera("borderL", "other")

	makeLuaSprite('background', 'bg/howtoplay/bg', -500, -1100);
	scaleObject('background', 12, 12)
	setScrollFactor('background', 1.2, 1);
	addLuaSprite('background', false);
        
    makeLuaSprite('sol', 'bg/howtoplay/floor', -400, -20);
	scaleObject('sol', 1.3, 1.3)
	addLuaSprite('sol', false);

	makeLuaSprite('platform', 'bg/howtoplay/platform', 150, 0);
	scaleObject('platform', 1.3, 1.3)
	addLuaSprite('platform', false);

	makeLuaSprite('intro', 'bg/howtoplay/FR/commentjouer', 150, 490);
	scaleObject('intro', 3.3, 3.3)
	addLuaSprite('intro', true);
	setObjectCamera("intro", "other")
end

local fadeStarted = false

function onCreatePost()
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
        doTweenAlpha('fadeToGame', 'blackFade', 0, 0.5, 'linear')
        fadeStarted = true
	end
end
function onStepHit()
	if curStep == 32 then
		removeLuaSprite('intro', true);
		makeLuaSprite('1', 'bg/howtoplay/FR/1', 170, 505);
		scaleObject('1', 0.5, 0.5)
		addLuaSprite('1', true);
		setObjectCamera("1", "Camother")

		makeLuaSprite('key', 'bg/howtoplay/key', 830, 530);
		scaleObject('key', 0.9, 0.9)
		addLuaSprite('key', true);
		setObjectCamera("key", "Camother")
end
if curStep == 128 then
	makeLuaSprite('ici', 'bg/howtoplay/FR/ici', 640, 495);
	scaleObject('ici', 0.15, 0.15)
	addLuaSprite('ici', true);
	setObjectCamera("ici", "Camother")

	setProperty('healthBarBG.visible', true)
	setProperty('healthBar.visible', true)
    setProperty('scoreTxt.visible', true)
	setProperty('iconP1.visible', true)
	setProperty('iconP2.visible', true)

	removeLuaSprite('1', true);
	removeLuaSprite('key', true);
	makeLuaSprite('2', 'bg/howtoplay/FR/2', 170, 510);
	scaleObject('2', 0.5, 0.5)
	addLuaSprite('2', true);
	setObjectCamera("2", "Camother")
end
if curStep == 192 then
	removeLuaSprite('2', true);
	removeLuaSprite('ici', true);
	makeLuaSprite('3', 'bg/howtoplay/FR/3', 170, 530);
	scaleObject('3', 0.5, 0.5)
	addLuaSprite('3', true);
	setObjectCamera("3", "Camother")
end
if curStep == 256 then
	removeLuaSprite('3', true);
	makeLuaSprite('4', 'bg/howtoplay/FR/4', 170, 500);
	scaleObject('4', 0.5, 0.5)
	addLuaSprite('4', true);
	setObjectCamera("4", "Camother")
end
if curStep == 320 then
	removeLuaSprite('4', true);
	makeLuaSprite('5', 'bg/howtoplay/FR/5', 170, 505);
	scaleObject('5', 0.5, 0.5)
	addLuaSprite('5', true);
	setObjectCamera("5", "Camother")

		makeLuaSprite('danger', 'bg/howtoplay/danger', 900, 540);
		scaleObject('danger', 0.12, 0.12)
		addLuaSprite('danger', true);
		setObjectCamera("danger", "Camother")
end
if curStep == 512 then
	removeLuaSprite('5', true);
	removeLuaSprite('danger', true);
	makeLuaSprite('6', 'bg/howtoplay/FR/6', 170, 530);
	scaleObject('6', 0.5, 0.5)
	addLuaSprite('6', true);
	setObjectCamera("6", "Camother")
end
end