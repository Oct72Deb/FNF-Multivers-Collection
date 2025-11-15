-- Config
local requiredAccuracy = 0.9       -- 90%
local smashWeek = "weeka"          -- Smash Bros
local mjWeek = "weekb"                -- Week à verrouiller/débloquer

-- Fonction pour vérifier si la week MJ peut être jouée
function canPlayMJ()
    local totalNotes = 0
    local totalHit = 0

    -- Parcours des difficultés de Smash Bros
    for i, diff in ipairs({"easy", "normal", "hard", "expert"}) do
        local scoreData = Highscore.getWeekScore(smashWeek, i-1)  -- retourne un entier ou table selon PE
        -- Ici on suppose que scoreData contient accuracy en float 0~1
        -- Si ce n'est qu'un score entier, adapter la formule
        totalHit = totalHit + scoreData.hit
        totalNotes = totalNotes + scoreData.notes
    end

    if totalNotes == 0 then
        return false
    end

    local accuracy = totalHit / totalNotes
    return accuracy >= requiredAccuracy
end

-- Fonction pour cacher ou afficher la week MJ dans les menus
function updateMJVisibility(menu)
    if menu == "story" or menu == "freeplay" then
        if canPlayMJ() then
            showWeek(mjWeek)    -- fonction du moteur pour afficher la week
        else
            hideWeek(mjWeek)    -- fonction du moteur pour cacher la week
        end
    end
end