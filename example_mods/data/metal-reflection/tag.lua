local floatOffset1 = 0
local floatAmplitude1 = 10
local floatSpeed1 = 5
local baseY1 = 50
local playerCreated1 = false

local floatOffset2 = 0
local floatAmplitude2 = 10
local floatSpeed2 = 5
local baseY2 = 50
local playerCreated2 = false

function onStepHit()
	if curStep == 60 then
		makeLuaSprite('playertag', 'bg/metacrystal/EN/playertag', 840, baseY1);
		scaleObject('playertag', 1.5, 1.5);
		addLuaSprite('playertag', false);
		playerCreated1 = true

		makeLuaSprite('cputag', 'bg/metacrystal/EN/cputag', 1700, baseY2);
		scaleObject('cputag', 1.5, 1.5);
		addLuaSprite('cputag', false);
		playerCreated2 = true
	end
end

function onUpdate(elapsed)
	if playerCreated1 then
		floatOffset1 = floatOffset1 + elapsed * floatSpeed1
		local floatY1 = baseY1 + math.sin(floatOffset1) * floatAmplitude1
		setProperty('playertag.y', floatY1)
	end

	if playerCreated2 then
		floatOffset2 = floatOffset2 + elapsed * floatSpeed2
		local floatY2 = baseY2 + math.sin(floatOffset2) * floatAmplitude2
		setProperty('cputag.y', floatY2)
	end
end