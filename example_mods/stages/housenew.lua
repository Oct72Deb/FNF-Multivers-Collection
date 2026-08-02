local scrollSpeed = 2563 / 25

function onCreate()
    makeLuaSprite('effect','bg/doki/shade', -50, -200)
    setObjectCamera('effect','other')
    scaleObject('effect', 0.8, 0.8)
    addLuaSprite('effect', true)

	makeLuaSprite('UpperBarr', 'empty', -150, -50)
	makeGraphic('UpperBarr', 1580, 120, '000000')
	setObjectCamera('UpperBarr', 'hud')
	addLuaSprite('UpperBarr', false)

	makeLuaSprite('LowerBarr', 'empty', -150, 650)
	makeGraphic('LowerBarr', 1580, 120, '000000')
	setObjectCamera('LowerBarr', 'hud')
	addLuaSprite('LowerBarr', false)

    for i = 1, 2 do
        local name = 'bg' .. i
        makeLuaSprite(name, 'bg/doki/house', (i-1) * -2563, 0)
        addLuaSprite(name, false)
    end
    
    startScrolling()
end

function startScrolling()
    setProperty('bg1.x', 0)
    setProperty('bg2.x', -2563)
    
    doTweenX('moveBG1', 'bg1', 2563, 20, 'linear')
    doTweenX('moveBG2', 'bg2', 0, 20, 'linear')

    setTweenCanPause('moveBG1', true)
    setTweenCanPause('moveBG2', true)
end

function onTweenCompleted(tag)
    if tag == 'moveBG1' then
        startScrolling()
    end
end