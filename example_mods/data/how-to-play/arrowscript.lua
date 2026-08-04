local arrowsMoved = false

function onSongStart()
    if not arrowsMoved then
        local spacing = 80
        local baseOpponentX = 220
        local basePlayerX = 700
        local opponentY = downscroll and 380 or 30
        local playerY = downscroll and 380 or 30

        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i,     "x", baseOpponentX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i,     "y", opponentY)
            setPropertyFromGroup('strumLineNotes', i + 4, "x", basePlayerX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i + 4, "y", playerY)
        end

        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.5)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.5)
            updateHitbox('strumLineNotes', i)
        end

        arrowsMoved = true
    end
end

function onSpawnNote(id)
    setPropertyFromGroup('notes', id, 'scale.x', 0.5)
    setPropertyFromGroup('notes', id, 'scale.y', 0.5)
    updateHitbox('notes', id)
end