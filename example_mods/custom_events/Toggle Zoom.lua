function onEvent(name, value1, value2)
    if name == 'Toggle Zoom' then
        if value1 == 'on' then
            zoomEnabled = true
        elseif value1 == 'off' then
            zoomEnabled = false
            elseif value2 == 'on' then
            zoomEnabled2 = true
            elseif value2 == 'off' then
            zoomEnabled2 = false
            elseif value2 == 'big' then
            zoomEnabled3 = true
            elseif value2 == 'none' then
            zoomEnabled3 = false
            
            
        end
    end
end

function onBeatHit()
    if zoomEnabled then
        triggerEvent('Add Camera Zoom', '0.02', '0.02')
        elseif zoomEnabled2 then
        triggerEvent('Add Camera Zoom', '0.1', '0.1')
                elseif zoomEnabled3 then
        triggerEvent('Add Camera Zoom', '0.5', '0.2')
    end
end