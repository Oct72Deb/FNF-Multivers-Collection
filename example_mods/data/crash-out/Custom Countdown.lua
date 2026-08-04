--Coding By BlixerTheGamer
--Helped for the code Deleted_Name687

--Script Config Fade
FadeTime = 1.2
FadeEase = 'CircInOut'

local playedEnding = false

function onCreate() 
	setProperty('introSoundsSuffix', 'jigglypuff!!!!!!!')

--Two
    makeLuaSprite('CountTwo', 'bg/yoshistory/ready', 0, 0)
	scaleObject('CountTwo', 1.6, 1.6)
	screenCenter('CountTwo', 'xy')
	setObjectCamera('CountTwo', 'other')
	setProperty('CountTwo.visible', false)
--Go	
	makeLuaSprite('CountGO', 'bg/yoshistory/go', 0, 0)
	scaleObject('CountGO', 1.5, 1.5)
	screenCenter('CountGO', 'xy')
	setObjectCamera('CountGO', 'other')
	setProperty('CountGO.visible', false)
--Add Lua Sprites
	addLuaSprite('CountTwo', true)
	addLuaSprite('CountGO', true)
end

--Countdown Time

function onCountdownTick(counter)
	if counter == 0 then
	elseif counter == 1 then
		setProperty('CountTwo.visible', true)
		setProperty('countdownReady.visible', false)
		playSound('melee/ready')	
	elseif counter == 2 then
		setProperty('countdownSet.visible', false)
	elseif counter == 3 then
		setProperty('countdownSet.visible', false)
		setProperty('CountTwo.visible', false)
		setProperty('CountGO.visible', true)
		doTweenAlpha('GoFade', 'CountGO', 0, FadeTime, FadeEase)
		setProperty('countdownGo.visible', false)
		playSound('melee/go')
	end
end

function onEndSong()
    if not playedEnding then
        playedEnding = true

        makeLuaSprite('SUCCESS', 'bg/yoshistory/success', 0, 0)
        setObjectCamera('SUCCESS', 'other')
        scaleObject('SUCCESS', 0.1, 0.1)
        updateHitbox('SUCCESS')
        screenCenter('SUCCESS')
        addLuaSprite('SUCCESS', true)
        doTweenX('SUCCESSX', 'SUCCESS.scale', 1.3, 0.1, 'cubeOut')
        doTweenY('SUCCESSY', 'SUCCESS.scale', 1.3, 0.1, 'cubeOut')

        playSound('melee/success', 1)
        runTimer('SUCCESSTIME', 1)

        return Function_Stop
    end

    return Function_Continue
end

function onTimerCompleted(tag)
    if tag == 'SUCCESSTIME' then
        removeLuaSprite('SUCCESS', true)
        endSong()
    end
end