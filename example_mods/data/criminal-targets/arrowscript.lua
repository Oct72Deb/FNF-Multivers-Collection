local arrowsMoved = false

function onSongStart()
    if not arrowsMoved then
        -- Personnalisation
        local spacing = 95 -- Espacement horizontal entre les flèches
        local baseOpponentX = -400 -- Position X de départ des flèches adverses
<<<<<<< HEAD
        local basePlayerX = 437 -- Position X de départ des flèches joueur
=======
        local basePlayerX = 460 -- Position X de départ des flèches joueur
>>>>>>> f1ddd8e2b2d22239a90c05f80fca8f4b311670e4

        local opponentY = 40 -- Position Y des flèches adverses
        local playerY = 40 -- Position Y des flèches joueur

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
            setPropertyFromGroup('strumLineNotes', i, 'scale.x', 0.6)
            setPropertyFromGroup('strumLineNotes', i, 'scale.y', 0.6)
            updateHitbox('strumLineNotes', i)
        end

        arrowsMoved = true
    end
end

function onUpdatePost()
    -- Réduction des flèches qui défilent
    for i = 0, getProperty('notes.length') - 1 do
        setPropertyFromGroup('notes', i, 'scale.x', 0.6)
        setPropertyFromGroup('notes', i, 'scale.y', 0.6)
    end
end