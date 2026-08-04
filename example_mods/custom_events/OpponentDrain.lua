local drainIntensity = 0.02
local isDrainActive = false

function onEvent(name, value1, value2)
    if name == 'OpponentDrain' then
        drainIntensity = tonumber(value1) or 0.02
        
        if value2 == 'on' then
            isDrainActive = true
        elseif value2 == 'off' then
            isDrainActive = false
        end
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
    if isDrainActive and not isSustainNote then
        local health = getProperty('health')
        
        if health > 0.05 then
            setProperty('health', health - drainIntensity)
        end
    end
end