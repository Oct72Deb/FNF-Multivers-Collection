function onCreate()
    setProperty('skipCountdown', true)

    makeLuaSprite('borderL', 'bg/howtoplay/aspect', 0, 0)
    setObjectCamera("borderL", "other")
    addLuaSprite('borderL', false)

    makeLuaSprite('background', 'bg/howtoplay/bg', -500, -1100)
    scaleObject('background', 12, 12)
    setScrollFactor('background', 1.2, 1)
    addLuaSprite('background', false)
        
    makeLuaSprite('sol', 'bg/howtoplay/floor', -400, -20)
    scaleObject('sol', 1.3, 1.3)
    addLuaSprite('sol', false)

    makeLuaSprite('platform', 'bg/howtoplay/platform', 150, 0)
    scaleObject('platform', 1.3, 1.3)
    addLuaSprite('platform', false)


    makeLuaSprite('intro', 'bg/howtoplay/EN/howtoplay', 150, 490)
    scaleObject('intro', 3.3, 3.3)
    setObjectCamera("intro", "camOther")
    addLuaSprite('intro', true)

    makeLuaSprite('step1', 'bg/howtoplay/EN/1', 170, 505)
    scaleObject('step1', 0.5, 0.5)
    setObjectCamera("step1", "camOther")
    setProperty('step1.visible', false)
    addLuaSprite('step1', true)

    makeLuaSprite('key', 'bg/howtoplay/key', 830, 530)
    scaleObject('key', 0.9, 0.9)
    setObjectCamera("key", "camOther")
    setProperty('key.visible', false)
    addLuaSprite('key', true)

    makeLuaSprite('ici', 'bg/howtoplay/EN/here', 640, 495)
    scaleObject('ici', 0.16, 0.16)
    setObjectCamera("ici", "camOther")
    setProperty('ici.visible', false)
    addLuaSprite('ici', true)

    makeLuaSprite('step2', 'bg/howtoplay/EN/2', 170, 510)
    scaleObject('step2', 0.5, 0.5)
    setObjectCamera("step2", "camOther")
    setProperty('step2.visible', false)
    addLuaSprite('step2', true)

    makeLuaSprite('step3', 'bg/howtoplay/EN/3', 170, 530)
    scaleObject('step3', 0.5, 0.5)
    setObjectCamera("step3", "camOther")
    setProperty('step3.visible', false)
    addLuaSprite('step3', true)

    makeLuaSprite('step4', 'bg/howtoplay/EN/4', 170, 500)
    scaleObject('step4', 0.5, 0.5)
    setObjectCamera("step4", "camOther")
    setProperty('step4.visible', false)
    addLuaSprite('step4', true)

    makeLuaSprite('step5', 'bg/howtoplay/EN/5', 170, 505)
    scaleObject('step5', 0.5, 0.5)
    setObjectCamera("step5", "camOther")
    setProperty('step5.visible', false)
    addLuaSprite('step5', true)

    makeLuaSprite('danger', 'bg/howtoplay/danger', 900, 540)
    scaleObject('danger', 0.12, 0.12)
    setObjectCamera("danger", "camOther")
    setProperty('danger.visible', false)
    addLuaSprite('danger', true)

    makeLuaSprite('step6', 'bg/howtoplay/EN/6', 170, 530)
    scaleObject('step6', 0.5, 0.5)
    setObjectCamera("step6", "camOther")
    setProperty('step6.visible', false)
    addLuaSprite('step6', true)

    makeLuaSprite('ecrannoirdenfoire', '', -200, -200)
    makeGraphic('ecrannoirdenfoire', screenWidth + 400, screenHeight + 400, '000000')
    setObjectCamera('ecrannoirdenfoire', 'other')
    setProperty('ecrannoirdenfoire.visible', false)
    addLuaSprite('ecrannoirdenfoire', true)
end

function onStepHit()
    if curStep == 32 then
        setProperty('intro.visible', false)
        setProperty('step1.visible', true)
        setProperty('key.visible', true)

    elseif curStep == 128 then
        setProperty('step1.visible', false)
        setProperty('key.visible', false)
        
        setProperty('step2.visible', true)
        setProperty('ici.visible', true)

        setProperty('healthBarBG.visible', true)
        setProperty('healthBar.visible', true)
        setProperty('scoreTxt.visible', true)
        setProperty('iconP1.visible', true)
        setProperty('iconP2.visible', true)

    elseif curStep == 192 then
        setProperty('step2.visible', false)
        setProperty('ici.visible', false)
        setProperty('step3.visible', true)

    elseif curStep == 256 then
        setProperty('step3.visible', false)
        setProperty('step4.visible', true)

    elseif curStep == 320 then
        setProperty('step4.visible', false)
        setProperty('step5.visible', true)
        setProperty('danger.visible', true)

    elseif curStep == 512 then
        setProperty('step5.visible', false)
        setProperty('danger.visible', false)
        setProperty('step6.visible', true)
        
    elseif curStep == 576 then
        setProperty('step6.visible', false)
        setProperty('ecrannoirdenfoire.visible', true)
    end
end