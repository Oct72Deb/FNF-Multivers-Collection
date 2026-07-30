local booping = false
local intensity = 0.015

function onEvent(name, value1, value2)
    if name == 'Toogle_zoom' then
        if value1 == 'on' then
            booping = true
            if value2 ~= '' then
                intensity = tonumber(value2)
            end
        elseif value1 == 'off' then
            booping = false
        end
    end
end

function onBeatHit()
    if booping then
        triggerEvent('Add Camera Zoom', intensity, intensity * 0.5)
    end
end