local starMode = false
local colors = {}
local colorIndex = 1
local timer = 0

function onCreate()
    local hexList = {"FF0000", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF"}
    for i=1, #hexList do
        colors[i] = getColorFromHex(hexList[i])
    end
end

function onStepHit()
    if curStep == 1631 then
        starMode = true
    elseif curStep == 1887 then
        starMode = false
        resetNotesColor()
    end
end

function onUpdate(elapsed)
    if starMode then
        timer = timer + elapsed
        if timer >= 0.1 then
            timer = 0
            colorIndex = (colorIndex % #colors) + 1
            local col = colors[colorIndex]

            setProperty('iconP1.color', col)
            setProperty('iconP2.color', col)
            setProperty('healthBarBG.color', col)
            setProperty('healthBar.color', col)

            for i = 0, 3 do
                setPropertyFromGroup('playerStrums', i, 'color', col)
                setPropertyFromGroup('opponentStrums', i, 'color', col)
            end
            
            for i = 0, getProperty('notes.length')-1 do
                setPropertyFromGroup('notes', i, 'color', col)
            end
        end
    end
end

function onSpawnNote(id, data, type, isSustain)
    if starMode then
        setPropertyFromGroup('notes', id, 'color', colors[colorIndex])
    end
end

function resetNotesColor()
    local white = getColorFromHex("FFFFFF")
    setProperty('iconP1.color', white)
    setProperty('iconP2.color', white)
    setProperty('healthBarBG.color', white)
    setProperty('healthBar.color', white)

    for i = 0, 3 do
        setPropertyFromGroup('playerStrums', i, 'color', white)
        setPropertyFromGroup('opponentStrums', i, 'color', white)
    end
    
    for i = 0, getProperty('notes.length')-1 do
        setPropertyFromGroup('notes', i, 'color', white)
    end
end