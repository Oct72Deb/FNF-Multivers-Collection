local arrowsMoved = false

function onSongStart()
    if not arrowsMoved then
        -- Personnalisation
        local spacing = 80 -- Espacement horizontal entre les flèches
        local baseOpponentX = 220 -- Position X de départ des flèches adverses
        local basePlayerX = 700 -- Position X de départ des flèches joueur

        local opponentY = 30 -- Position Y des flèches adverses
        local playerY = 30 -- Position Y des flèches joueur

        -- Repositionner les flèches de l'adversaire (0 à 3)
        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i, "x", baseOpponentX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i, "y", opponentY)
        end

        -- Repositionner les flèches du joueur (4 à 7)
        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i + 4, "x", basePlayerX + (i * spacing))
            setPropertyFromGroup('strumLineNotes', i + 4, "y", playerY)
        end

        -- Réduction de la taille des flèches
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.5)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.5)
            updateHitbox('strumLineNotes', i)
        end

        arrowsMoved = true
    end
end

function onUpdatePost()
    -- Réduction des flèches qui défilent
    for i = 0, getProperty('notes.length') - 1 do
        setPropertyFromGroup('notes', i, 'scale.x', 0.5)
        setPropertyFromGroup('notes', i, 'scale.y', 0.5)
    end
end