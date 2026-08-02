function onCreatePost()
    -- Rendre les notes adverses invisibles au début
    for i = 0, 3 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
    end
end

function onUpdatePost(elapsed)
    -- Maintenir leur invisibilité jusqu'au moment voulu
    if curStep < 304 then
        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
        end
    end
end

function onStepHit()
    if curStep == 304 then
        -- Réapparition avec noteTweenAlpha (spécifique pour les strumLineNotes)
        for i = 0, 3 do
            noteTweenAlpha('reappear'..i, i, 1, 1, 'linear')
        end
    end
end