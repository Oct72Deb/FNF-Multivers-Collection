local arrowsMoved = false

function onSongStart()
    if not arrowsMoved then
        local spacing = 85
        local baseOpponentX = -1000
        local basePlayerX = 900
        local opponentY = 50
        local playerY = 50

        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i,     "x", baseOpponentX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i,     "y", opponentY)
            setPropertyFromGroup('strumLineNotes', i + 4, "x", basePlayerX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i + 4, "y", playerY)
        end

        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.6)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.6)
            updateHitbox('strumLineNotes', i)
        end

        arrowsMoved = true
    end
end

function onSpawnNote(id)
    setPropertyFromGroup('notes', id, 'scale.x', 0.6)
    setPropertyFromGroup('notes', id, 'scale.y', 0.6)
    updateHitbox('notes', id)
end