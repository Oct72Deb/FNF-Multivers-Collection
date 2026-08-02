function onCreate()
    -- Timer
    makeLuaText('smashTimer', '00:00', 0, screenWidth - 390, 50)
    setTextFont('smashTimer', 'Kabel-Heavy Heavy.ttf')
    setTextSize('smashTimer', 85)
    setTextAlignment('smashTimer', 'right')
    setObjectCamera('smashTimer', 'camHUD')
    addLuaText('smashTimer')
end

function onSongStart()
    totalSongLength = getProperty('songLength') -- durée totale de la chanson en ms
end

function onUpdate(elapsed)
    -- Timer
    local remaining = totalSongLength - getSongPosition()
    if remaining < 0 then remaining = 0 end -- éviter les valeurs négatives

    local seconds = math.floor(remaining / 1000)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60

    local timeString = string.format("%02d:%02d", minutes, seconds)
    setTextString('smashTimer', timeString)
end