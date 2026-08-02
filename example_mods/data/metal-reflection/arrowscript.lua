local arrowsMoved = false

function onSongStart()
    if not arrowsMoved then
        -- Tes valeurs personnalisées
        local spacing = 95
        local baseOpponentX = 700
        local basePlayerX = 190
        local opponentY = downscroll and 570 or 50
        local playerY = downscroll and 570 or 50

        for i = 0, 3 do
            -- Positionnement des flèches de l'adversaire
            setPropertyFromGroup('strumLineNotes', i,     "x", baseOpponentX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i,     "y", opponentY)
            
            -- Positionnement des flèches du joueur
            setPropertyFromGroup('strumLineNotes', i + 4, "x", basePlayerX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i + 4, "y", playerY)
        end

        -- Application du scale de 0.6 sur les strums
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.6)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.6)
            updateHitbox('strumLineNotes', i)
        end

        arrowsMoved = true
    end
end

function onSpawnNote(id)
    -- Application du scale de 0.6 sur les notes qui défilent
    setPropertyFromGroup('notes', id, 'scale.x', 0.6)
    setPropertyFromGroup('notes', id, 'scale.y', 0.6)
    updateHitbox('notes', id)
end