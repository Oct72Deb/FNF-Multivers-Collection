-- dont mind my super bad not optimized code like listen i dont give a fucking fuck if you guys cant read my code or if its just unnoptimal just like GO FUCK YOURSELF!!
-- thedumbestcat

function onBeatHit()

    if (curBeat >= 36 and curBeat <= 75) or (curBeat == 76 or curStep == 310 or curBeat == 79 or curBeat == 80 or curBeat == 83) or (curBeat >= 84 and curBeat <= 91) or (curBeat == 92 or curBeat == 95) or (curBeat >= 96 and curBeat <= 99) then

        triggerEvent('Add Camera Zoom', 0.021, 0.03)

    end

    if (curBeat >= 164 and curBeat <= 203) or (curBeat == 204 or curBeat == 207 or curBeat == 208 or curBeat == 211) or (curBeat >= 212 and curBeat <= 219) or (curBeat == 220 or curBeat == 223) or (curBeat >= 224 and curBeat <= 227) then

        triggerEvent('Add Camera Zoom', 0.023, 0.04)

    end

    if curBeat == 246 or curBeat == 250 or curBeat == 254 or curBeat == 258 then

        triggerEvent('Add Camera Zoom', 0.024, 0.045)

    end

    if (curBeat >= 264 and curBeat <= 303) or (curBeat == 304 or curBeat == 307 or curBeat == 308 or curBeat == 311) or (curBeat >= 312 and curBeat <= 319) or (curBeat == 320 or curBeat == 323) or (curBeat >= 324 and curBeat <= 327) then

        triggerEvent('Add Camera Zoom', 0.033, 0.06)

    end

    if curBeat == 4 or curBeat == 36 or curBeat == 68 or curBeat == 100 or curBeat == 132 or curBeat == 164 or curBeat == 196 or curBeat == 228 or curBeat == 264 or curBeat == 328 or curBeat == 360 then

        cameraFlash('game', 'ffffff', 1.5, false)

    end
    
    if curBeat == 146 then

		setProperty('defaultCamZoom', 1.2)

    end

    if curBeat == 162 then

		setProperty('defaultCamZoom', 1)

    end


    if curBeat == 264 then

        setProperty('macronBGred.visible', true)
        setProperty('deskred.visible', true)
        setProperty('macronBG.visible', false)
        setProperty('desk.visible', false)

    end

    if curBeat == 228 then

        doTweenZoom('CameraZoomingBecauseSageMadeMeDoItEvenThoughIWasLazy', 'camGame', 1.25, 12.39, 'cubeIn')

    end

end

function onStepHit()

    if curStep == 310 or curStep == 326 or curStep == 374 then

        triggerEvent('Add Camera Zoom', 0.024, 0.04)

    end

    if curStep == 822 or curStep == 838 or curStep == 886 then

        triggerEvent('Add Camera Zoom', 0.025, 0.05)

    end

    if curStep == 1222 or curStep == 1238 or curStep == 1286 then

        triggerEvent('Add Camera Zoom', 0.03, 0.09)

    end

end

function opponentNoteHit()

    if curBeat >= 264 and curBeat < 360 then

        cameraShake('game', 0.01, 0.18)
        cameraShake('hud', 0.004, 0.18)

     if getProperty('health') >= 0.2 then
    if difficulty == 2 then
            setProperty('health', getProperty('health') - 0.015)
        end
            if difficulty == 1 then
            setProperty('health', getProperty('health') - 0.010)
        end

    end

end
end