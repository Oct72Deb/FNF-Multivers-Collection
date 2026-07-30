local fadeStarted = false

function onCreate()
    setProperty('skipCountdown', true)
    setProperty('camZooming', true)

    makeLuaSprite('borderL', 'aspect', 0, 0)
    setObjectCamera("borderL", "other")
    addLuaSprite('borderL', false)

    makeLuaSprite('background', 'bg/targets/bg', -1500, -1700)
    scaleObject('background', 6, 6)
    setScrollFactor('background', 1.2, 1)
    addLuaSprite('background', false)
        
    makeLuaSprite('sol', 'bg/targets/floor', -500, -470)
    scaleObject('sol', 1.3, 1.3)
    addLuaSprite('sol', false)

    makeLuaSprite('targetstage', 'bg/targets/stuff/versuscreen/target', 530, 200)
    scaleObject('targetstage', 1.4, 1.4)
    addLuaSprite('targetstage', false)

    makeLuaSprite('targetbreak', 'bg/targets/targetbreak', 530, 180)
    scaleObject('targetbreak', 1.8, 1.8)
    setProperty('targetbreak.visible', false)
    addLuaSprite('targetbreak', false)

    makeLuaSprite('complete', 'bg/targets/complete', 160, 290)
    scaleObject('complete', 3.8, 3.8)
    setObjectCamera("complete", "other")
    setProperty('complete.visible', false)
    addLuaSprite('complete', false)

    makeLuaSprite('end', 'bg/targets/end', 90, 0)
    scaleObject('end', 1.7, 1.7)
    setObjectCamera("end", "other")
    setProperty('end.alpha', 0)
    addLuaSprite('end', false)

    makeLuaSprite('ready', 'bg/targets/ready', 0, 0)
    scaleObject('ready', 3, 3)
    screenCenter('ready', 'xy')
    setObjectCamera('ready', 'hud')
    setProperty('ready.alpha', 0)
    addLuaSprite('ready', false)

    makeLuaSprite('go', 'bg/targets/go', 0, 0)
    scaleObject('go', 2.8, 2.8)
    screenCenter('go', 'xy')
    setObjectCamera('go', 'hud')
    setProperty('go.alpha', 0)
    addLuaSprite('go', false)

    makeGraphic('blackFinish', screenWidth, screenHeight, '000000')
    setObjectCamera('blackFinish', 'hud')
    setProperty('blackFinish.alpha', 0)
    addLuaSprite('blackFinish', false)
end

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
    if curStep == 16 then
        doTweenAlpha('readyFade', 'ready', 1, 0.3 / playbackRate)

    elseif curStep == 24 then
        setProperty('ready.visible', false)
        setProperty('go.alpha', 1)

    elseif curStep == 32 then
        doTweenAlpha('gofade', 'go', 0, 0.3 / playbackRate)

    elseif curStep == 544 then
        setProperty('targetstage.visible', false)
        setProperty('targetbreak.visible', true)
    
    elseif curStep == 544 then
        setProperty('targetstage.visible', false)
        setProperty('targetbreak.visible', true)
    
    elseif curStep == 548 then
        setProperty('complete.visible', true)
    
    elseif curStep == 557 then
        setProperty('complete.visible', false)
        setProperty('blackFinish.alpha', 1)
        setProperty('camHUD.alpha', 0)
        doTweenAlpha('endFade', 'end', 1, 1 / playbackRate)
    end
end