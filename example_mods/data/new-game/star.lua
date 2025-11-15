local starMode = false
local colors = {"FF0000", "FFFF00", "00FF00", "00FFFF", "0000FF", "FF00FF"}
local timer = 0
local colorIndex = 1

function onStepHit()
    if curStep == 1631 then
        starMode = true
    end
    
    if curStep == 1887 then
    starMode = false
    end
end

function onUpdate(elapsed)
    if starMode then
        timer = timer + elapsed
        if timer >= 0.1 then
            timer = 0
            colorIndex = colorIndex + 1
            if colorIndex > #colors then colorIndex = 1 
        end

            setProperty('iconP1.color', getColorFromHex(colors[colorIndex]))
            setProperty('iconP2.color', getColorFromHex(colors[colorIndex]))
            setProperty('healthBarBG.color', getColorFromHex(colors[colorIndex]))
            setProperty('healthBar.color', getColorFromHex(colors[colorIndex]))
        end
    end
end