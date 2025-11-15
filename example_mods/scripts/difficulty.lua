function onCreate()
    -- Récupère le nom de la difficulté (ex: "Erect", "Hard", "Normal")
    local diff = difficultyName or getProperty('storyDifficultyText')

    if diff ~= nil and diff ~= '' then
        diff = string.lower(diff) -- met en minuscule pour uniformiser
    else
        diff = 'normal'
    end

    -- Construire les chemins possibles
    local instFile = 'songs/'..songName..'/Inst-'..diff
    local voicesFile = 'songs/'..songName..'/Voices-'..diff

    -- Vérifie si le fichier existe avant de remplacer
    if checkFileExists(instFile..'.ogg') then
        setPropertyFromClass('PlayState', 'SONG.inst', instFile)
    end

    if checkFileExists(voicesFile..'.ogg') then
        setPropertyFromClass('PlayState', 'SONG.voices', voicesFile)
    end
end

-- Fonction utilitaire : vérifie si un fichier existe dans mods/
function checkFileExists(path)
    return checkFileExistsInMods(path) or checkFileExistsInShared(path)
end

-- Vérifie dans le dossier "mods/"
function checkFileExistsInMods(path)
    return getTextFromFile(path) ~= nil
end

-- Vérifie dans le dossier "mods/shared/"
function checkFileExistsInShared(path)
    return getTextFromFile('shared/'..path) ~= nil
end