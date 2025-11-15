function opponentNoteHit()
    if curBeat >= 32 then
     if getProperty('health') >= 0.2 then
            setProperty('health', getProperty('health') - 0.010)
        end
end
end