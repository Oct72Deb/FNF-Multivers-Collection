local iconScale = 0.8
local totalSongLength = 0
local floatOffset = 0
local tagsCreated = false

local tags = {
    {tag = 'playertag', image = 'bg/metacrystal/stuff/tag/EN/playertag', x = 840},
    {tag = 'cputag',    image = 'bg/metacrystal/stuff/tag/EN/cputag',    x = 1700}
}

function onCreate()
    setProperty('healthBar.x', 300)
    setProperty('healthBar.y', 650)
    scaleObject('healthBar', 0.8, 0.8)
    scaleObject('healthBarBG', 0.8, 0.8)

    makeLuaText('smashTimer', '00:00', 0, screenWidth - 360, 620)
    setTextFont('smashTimer', 'Kabel-Heavy Heavy.ttf')
    setTextSize('smashTimer', 70)
    setTextAlignment('smashTimer', 'right')
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

function onStepHit()
    if curStep == 60 then
        for _, t in ipairs(tags) do
            makeLuaSprite(t.tag, t.image, t.x, 50)
            scaleObject(t.tag, 1.5, 1.5)
            setObjectCamera(t.tag, 'game')
            addLuaSprite(t.tag, false)
        end
        tagsCreated = true
    end
end

function onBeatHit()
    updateIconScale()
end

function onUpdate(elapsed)
    updateIconScale()

    -- Gestion du Timer
    updateTimerText()

    if tagsCreated then
        floatOffset = floatOffset + elapsed * 5 
        local floatY = 50 + math.sin(floatOffset) * 10
        
        setProperty('playertag.y', floatY)
        setProperty('cputag.y', floatY)
    end
end

function updateIconScale()
    setProperty('iconP1.scale.x', iconScale)
    setProperty('iconP1.scale.y', iconScale)
    setProperty('iconP2.scale.x', iconScale)
    setProperty('iconP2.scale.y', iconScale)
end

function updateTimerText()
    local remaining = totalSongLength - getSongPosition()
    if remaining < 0 then remaining = 0 end

    local seconds = math.floor(remaining / 1000)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60

    local timeString = string.format("%02d:%02d", minutes, seconds)
    setTextString('smashTimer', timeString)
end