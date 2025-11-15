local hueValue = -30
local saturationValue = 10
local contrastValue = 0
local brightnessValue = -5
local notePositions = {}

lightAlpha = 0
alphaDecreasing = false

function onCreate()
	    local diff = string.lower(difficultyName or "")
    if diff == 'erect' then
	makeLuaSprite('fade', 'Black', -1000, -100)
	   scaleObject('fade', 4, 4)
	addLuaSprite('fade', true)

	initLuaShader('adjustColor')
	makeLuaSprite('macronBG', 'bg/praizidan/macronBG', 0, 0)
	makeLuaSprite('desk', 'bg/praizidan/desk front', 0, 0)

	makeLuaSprite('macronBGred', 'bg/praizidan/macronBG evil', 0, 0)
	makeLuaSprite('deskred', 'bg/praizidan/desk front evil', 0, 0)

	addLuaSprite('macronBG')
	addLuaSprite('desk')
	addLuaSprite('macronBGred')
	addLuaSprite('deskred')

	setProperty('macronBGred.visible', false)
	setProperty('deskred.visible', false)

	setProperty('camZooming', true)
	
function onSongStart()
	-- Inst and Vocals start playing, songPosition = 0
	doTweenAlpha('fadeout', 'fade', 0, 3, 'linear')
end

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
	makeLuaSprite('macronBG', 'bg/praizidan/macronBG', 0, 0)
	makeLuaSprite('desk', 'bg/praizidan/desk front', 0, 0)

	makeLuaSprite('macronBGred', 'bg/praizidan/macronBG evil', 0, 0)
	makeLuaSprite('deskred', 'bg/praizidan/desk front evil', 0, 0)

	addLuaSprite('macronBG')
	addLuaSprite('desk')
	addLuaSprite('macronBGred')
	addLuaSprite('deskred')

	setProperty('macronBGred.visible', false)
	setProperty('deskred.visible', false)

	setProperty('camZooming', true)
end
end
function onCreatePost()

	setProperty('gf.visible', false)

	setObjectOrder('dadGroup', 5)
	setObjectOrder('desk', 6)
	setObjectOrder('deskred', 6)
	setObjectOrder('boyfriendGroup', 7)

end

function onMoveCamera(focus)
	if focus == 'boyfriend' then
		setProperty('defaultCamZoom', 0.8)
	elseif focus == 'dad' then
		setProperty('defaultCamZoom', 1)
	end
end
