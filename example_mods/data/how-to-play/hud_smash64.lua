local iconScale = 0.8
local totalSongLength = 0

function onCreate()
    setProperty('healthBar.x', 400)
    setProperty('healthBar.y', 450)
    scaleObject('healthBar', 0.8, 0.8)
    scaleObject('healthBarBG', 0.8, 0.8)
    setProperty('healthBarBG.visible', false)
    setProperty('healthBar.visible', false)
    
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)

    setProperty('iconP1.x', getProperty('iconP1.x') + 200)
    setProperty('iconP1.y', getProperty('iconP1.y') - 200)
    setProperty('iconP2.x', getProperty('iconP2.x') + 200)
    setProperty('iconP2.y', getProperty('iconP2.y') - 210)

    makeLuaText('smashTimer', '00:00', 0, screenWidth - 340, 430)
    setTextFont('smashTimer', 'Kabel-Heavy Heavy.ttf')
    setTextSize('smashTimer', 60)
    setObjectCamera('smashTimer', 'camHUD')
    addLuaText('smashTimer')

    setProperty('timeTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('scoreTxt.visible', false)
end

function onSongStart()
    totalSongLength = getProperty('songLength')
end

function onBeatHit()
    setProperty('iconP1.scale.x', iconScale)
    setProperty('iconP1.scale.y', iconScale)
    setProperty('iconP2.scale.x', iconScale)
    setProperty('iconP2.scale.y', iconScale)
end

function onUpdate(elapsed)
    setProperty('iconP1.scale.x', iconScale)
    setProperty('iconP1.scale.y', iconScale)
    setProperty('iconP2.scale.x', iconScale)
    setProperty('iconP2.scale.y', iconScale)

    local remaining = totalSongLength - getSongPosition()
    if remaining < 0 then remaining = 0 end
    local seconds = math.floor(remaining / 1000)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    setTextString('smashTimer', string.format("%02d:%02d", minutes, seconds))
end