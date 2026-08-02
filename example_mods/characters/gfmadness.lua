-- On garde en mémoire le dernier focus pour éviter de rejouer l'animation
local lastFocus = ''

function onMoveCamera(focus)
    if focus ~= lastFocus then
        if focus == 'boyfriend' then
            setProperty('gf.idleSuffix', '')
            triggerEvent('Play Animation', 'righturn', 'GF')
        elseif focus == 'dad' then
            setProperty('gf.idleSuffix', '-alt')
            triggerEvent('Play Animation', 'lefturn', 'GF')
        end
        lastFocus = focus -- on met à jour le focus précédent
    end
end
