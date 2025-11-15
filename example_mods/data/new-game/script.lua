function opponentNoteHit()
    if curBeat >= 406 then
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