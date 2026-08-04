local arrowsMoved = false

function onSongStart()
    if not arrowsMoved then
        local spacing = 95
        local baseOpponentX = -400
        local basePlayerX = 437
        local opponentY = downscroll and 570 or 40
        local playerY = downscroll and 570 or 40

        for i = 0, 3 do
            -- Flèches de l'adversaire
            setPropertyFromGroup('strumLineNotes', i,     "x", baseOpponentX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i,     "y", opponentY)
            
            -- Flèches du joueur
            setPropertyFromGroup('strumLineNotes', i + 4, "x", basePlayerX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i + 4, "y", playerY)
        end

        -- Application de ton scale de 0.6 sur les strums
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.6)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.6)
            updateHitbox('strumLineNotes', i)
        end

        arrowsMoved = true
    end
end

function onSpawnNote(id)
    -- Application de ton scale de 0.6 sur les notes
    setPropertyFromGroup('notes', id, 'scale.x', 0.6)
    setPropertyFromGroup('notes', id, 'scale.y', 0.6)
    updateHitbox('notes', id)
end