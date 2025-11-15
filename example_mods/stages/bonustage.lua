function onCreate()
	setProperty('skipCountdown', true)

	makeLuaSprite('borderL', 'aspect',0,0)
	addLuaSprite('borderL', false)
	setObjectCamera("borderL", "other")

	makeLuaSprite('background', 'bg/targets/bg', -1500, -1700);
	scaleObject('background', 6, 6)
	setScrollFactor('background', 1.2, 1);
	addLuaSprite('background', false);
        
    makeLuaSprite('sol', 'bg/targets/floor', -500, -470);
	scaleObject('sol', 1.3, 1.3)
	addLuaSprite('sol', false);

	makeLuaSprite('target', 'bg/targets/target', 530, 200);
	scaleObject('target', 1.4, 1.4)
	addLuaSprite('target', false);

	makeLuaSprite('end', 'bg/targets/end', 90, 0);
	scaleObject('end', 1.7, 1.7)
	addLuaSprite('end', false);
	setObjectCamera("end", "other")
	setProperty('end.alpha',0)
end

function onStepHit()
	if curStep == 544 then
	removeLuaSprite('target', true);
	makeLuaSprite('targetbreak', 'bg/targets/targetbreak', 530, 180);
	scaleObject('targetbreak', 1.8, 1.8)
	addLuaSprite('targetbreak', false);
end
	if curStep == 548 then
	makeLuaSprite('complete', 'bg/targets/complete', 160, 290);
	scaleObject('complete', 3.8, 3.8)
	addLuaSprite('complete', false);
	setObjectCamera("complete", "other")
end
	if curStep == 557 then
	removeLuaSprite('complete', true);
    makeLuaSprite('black',nil,0,0)
    makeGraphic('black',screenWidth,screenHeight,'000000')
    scaleObject('black',20,20)
	addLuaSprite('black',false)
	setObjectCamera("black", "hud")

	setProperty('camHUD.alpha',0)
	
    doTweenAlpha('end', 'end', 1, 1 / playbackRate)
	end
end