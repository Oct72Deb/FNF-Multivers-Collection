function onEvent(name, value1, value2)

    if name == 'Ddlc Box' then
    
        makeLuaSprite('box', 'bg/doki/box/'..value1..'box' , 60, 30)

    setObjectCamera('box', 'other')

    scaleObject('box', 0.6, 0.6)

    addLuaSprite('box', false)
        
        runTimer('wait', value2);


        function onTimerCompleted(tag, loops, loopsleft)

            if tag == 'wait' then

                doTweenAlpha('byebye', 'box', 0, 0.00001, 'linear');

            end

        end

        

        function onTweenCompleted(tag)

            if tag == 'byebye' then

                removeLuaSprite('box', true);

            end

        end

    end

end