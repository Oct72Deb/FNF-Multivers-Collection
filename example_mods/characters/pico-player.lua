function onCreate()
    precacheImage('Pico_Death_Retry')
end

function onUpdate()
 
 setObjectOrder('wtfpico',1)
 setObjectOrder('picoretry',2)
end

function onGameOverStart()

 makeAnimatedLuaSprite('wtfnene', 'NeneKnifeToss', getProperty('boyfriend.x') - 360, getProperty('boyfriend.y') + 15)
 addAnimationByPrefix('wtfnene', 'whatareyoudoin', 'knife toss', 24, false)
 addLuaSprite('wtfnene', true)
 runTimer('picoisded', 1.5)
 runTimer('nenedisappear', 0.7)
 return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
  if tag == 'picoisded' then
    makeAnimatedLuaSprite('wtfpico', 'Pico_Death_Retry', getProperty('boyfriend.x') + 171, getProperty('boyfriend.y') + 206)
    addAnimationByPrefix('wtfpico', 'picobleedsfuck', 'Retry Text Loop', 24, true)
    addLuaSprite('wtfpico', true);
 end
 
 if tag == 'nenedisappear' then
   removeLuaSprite('wtfnene', true, 'whatareyoudoin')
 end
end

function onGameOverConfirm()

makeAnimatedLuaSprite('picoretry', 'Pico_Death_Retry', getProperty('boyfriend.x') - 82, getProperty('boyfriend.y') + 17)
addAnimationByPrefix('picoretry', 'picoisnowalive', 'Retry Text Confirm', 24, false)
addLuaSprite('picoretry', false);
removeLuaSprite('wtfpico', true, 'picobleedsfuck')
end