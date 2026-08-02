--[[
    Version: 1.1.0
    Author: Ralsi (https://gamebanana.com/members/1939328)
    GB Page: https://gamebanana.com/tools/12253
    Crediting: If used in a mod, not necessary, but very much appreciated. Do not remove or edit all this info tho.
--]]

-- [[ Changeable Variables ]] --

local addHealthOnMiss = true
local showNotes = false
local playMissSound = false


-- [[ Code ]] --
local dirs = {
    [1] = 'LEFT',[2] = 'DOWN',[3] = 'UP',[4] = 'RIGHT'
}
function onCreate()
    local hpmult = healthGainMult
    for i = 0, getProperty('unspawnNotes.length') - 1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Opponent Miss' then
            setPropertyFromGroup('unspawnNotes', i, 'missHealth', addHealthOnMiss and -.23 * hpmult or 0)
            setPropertyFromGroup('unspawnNotes', i, 'blockHit', true)
            setPropertyFromGroup('unspawnNotes', i, 'lowPriority', true)

            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                if showNotes then
                    setPropertyFromGroup('unspawnNotes', i, 'texture', 'HURTNOTE_assets')
                    setPropertyFromGroup('unspawnNotes', i, 'alpha', .5)
                end
                if not showNotes then setPropertyFromGroup('unspawnNotes', i, 'visible', false) end
                setPropertyFromGroup('unspawnNotes', i, 'noMissAnimation', true)
            else
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true)
            end
        end
    end
end

function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    if noteType == 'Opponent Miss' then
        -- undo the score change
        addMisses(-1)
        setProperty('totalPlayed', getProperty('totalPlayed') - 1)
        addScore(10)
        if getProperty('totalPlayed') < 1 then
            setProperty('scoreTxt.text', 'Score: 0 | Misses: 0 | Rating: ?')
        end
        setProperty('scoreTxt.scale.x', 1)
        setProperty('scoreTxt.scale.y', 1)

        playAnim('dad', 'sing' .. dirs[noteData + 1] .. 'miss', true)
        if playMissSound then
            playSound('missnote'..getRandomInt(1,3), .1)
        end
    end
end