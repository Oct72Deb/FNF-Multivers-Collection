function onEvent(name, value1, value2)
    if name == 'Camera Speed' then
        local newSpeed = tonumber(value1)
        local tweenTime = tonumber(value2) or 0

        if newSpeed == nil then return end

        if tweenTime > 0 then
            doTweenFloat('camSpeedTween', 'cameraSpeed', newSpeed, tweenTime, 'linear')
        else
            setProperty('cameraSpeed', newSpeed)
        end
    end
end