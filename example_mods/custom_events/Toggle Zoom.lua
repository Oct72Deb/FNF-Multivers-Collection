local booping = false
local intensity = 0.015 -- Intensité par défaut (0.015 est une valeur sûre)

function onEvent(name, value1, value2)
    if name == 'ScreenBoop' then
        if value1 == 'on' then
            booping = true
            if value2 ~= '' then
                intensity = tonumber(value2)
            end
            debugPrint('Boop activé ! Force: ' .. intensity) -- Message de test
        elseif value1 == 'off' then
            booping = false
            debugPrint('Boop désactivé') -- Message de test
        end
    end
end

function onBeatHit()
    -- On utilise triggerEvent pour appeler l'effet de zoom natif du moteur
    -- C'est beaucoup plus fiable que de modifier manuellement la caméra
    if booping then
        triggerEvent('Add Camera Zoom', intensity, intensity * 0.5)
    end
end