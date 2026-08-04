-- Structure : ['nom'] = { RatingX, RatingY, RatingScale, NumX, NumY, NumScale }
local songConfigs = {
    ['criminal targets']     = {200, 60, 0.7, 320, 200, 0.45},
    ['how to play']       = {200, 420, 0.5, 320, 400, 0.3},
    ['dad-battle']  = {450, 280, 0.69, 450, 400, 0.5},
    ['spookeez']    = {450, 280, 0.69, 450, 400, 0.5},
    ['south']       = {450, 280, 0.69, 450, 400, 0.5},
    ['monster']     = {450, 280, 0.69, 450, 400, 0.5},
    ['pico']        = {450, 280, 0.69, 450, 400, 0.5},
}

    local visible = true
    local pixel = false
    local showCombo = true
    local msTxt = false
    local foreverCount = false
    local countMisses = false
    local missSprite = false

    local path = { ratings = '', nums = '' }
    local ratingGrab = {'sick', 'good', 'bad', 'shit'}
    local numPrefix, numSuffix = 'num', ''
    local combType, missType = 'combo', 'miss'

    local constantGameCam = true
    local camSet = 'hud'

    local ratingPos = {
        game   = {x = nil, y = nil},
        cam    = {x = 525, y = 20},
        offset = {x = 405, y = 230}}

    local numPos = {
        game   = {x = nil, y = nil},
        cam    = {x = 640, y = 130},
        offset = {x = 444, y = 385}}

    local comboPos = {
        game   = {x = nil, y = nil},
        cam    = {x = nil, y = nil}, 
        offset = {x = 470, y = 390}}

    local scales = {
        rating = {0.69, 0.69},
        nums   = {0.45, 0.45},
        combo  = {0.58, 0.58},
        miss   = {0.69, 0.69}}

    local onPlayerCombo = false
    local add5thRating = false
    local customRating = { image = 'marvelous', color = 'ff00ff', score = 500, hitWindow = 22.5, total = 0 }

    local MODES = {
        single = false, stationary = false, showRating = true, showNums = true,
        colorRatings = false, colorSyncing = false, fcColorRating = false, colorFade = false,
        colorNumbers = false, colorSyncNums = false, fcColorNums = false, colorFadeNums = false,
        comboColor = false, comboColorFade = false, randomColor = false, COLORSWAP_rate = false, COLORSWAP_num = false
    }

    local ratingColors = {'ffffff', 'ffffff', 'ffffff', 'ffffff'}
    local colorSync = {'c24b99', '68fafc', '12fa05', 'f9393f'}
    local isThousand, eh, curRating, addedOffset = false, 0, '', false
    local brokeCombo, mainOffset, isEarly = nil, {}, ''

--------------------------------------------------------------------------
-- LOGIQUE DU SCRIPT
--------------------------------------------------------------------------

function onCreate()
    local config = songConfigs[string.lower(songName)]
    if config then
        ratingPos.cam.x = config[1]
        ratingPos.cam.y = config[2]
        scales.rating   = {config[3], config[3]}
        
        numPos.cam.x    = config[4]
        numPos.cam.y    = config[5]
        scales.nums     = {config[6], config[6]}
    end
end

function onDestroy()
    setPropertyFromClass('ClientPrefs', 'hideHud', false)
end

function onCreatePost()
    mainOffset = getPropertyFromClass('ClientPrefs', 'comboOffset')
    if msTxt then
        makeLuaText('msTxt', '', 200, 0, 0)
        addLuaText('msTxt')
        setObjectCamera('msTxt', camSet)
    end

    pixel = getPropertyFromClass('PlayState', 'isPixelStage')
    if pixel then 
        path.ratings, path.nums = 'pixelUI/', 'pixelUI/'
        for i = 1, #ratingGrab do ratingGrab[i] = ratingGrab[i].. '-pixel' end
        customRating.image = customRating.image .. '-pixel'
        scales.rating, scales.nums, scales.combo = {5, 5}, {5.5, 5.5}, {4, 4}
        numSuffix, combType, missType = 'combo-pixel', 'miss-pixel'
    end

    -- Initialisation des positions par défaut si nil
    ratingPos.game.x = (ratingPos.game.x or getProperty('boyfriend.x') - 100)
    ratingPos.game.y = (ratingPos.game.y or getProperty('boyfriend.y') - 100)
    numPos.game.x = (numPos.game.x or ratingPos.game.x + 30)
    numPos.game.y = (numPos.game.y or ratingPos.game.y + 100)
    comboPos.cam.x = (comboPos.cam.x or numPos.cam.x + 30)
    comboPos.cam.y = (comboPos.cam.y or numPos.cam.y)
    comboPos.game.x = (comboPos.game.x or numPos.game.x + 30)
    comboPos.game.y = (comboPos.game.y or numPos.game.y)

    if MODES.COLORSWAP_rate or MODES.COLORSWAP_num then
        addHaxeLibrary('ColorSwap')
        runHaxeCode('colorSw = new ColorSwap();')
    end
end

function onUpdate(elapsed)
    setPropertyFromClass('ClientPrefs', 'hideHud', visible)
    if constantGameCam and camSet == 'game' and visible then
        bf1 = (getProperty('boyfriend.x') + (getMidpointX('boyfriend') / (getProperty('boyfriend.width'))) - 120)
        bf2 = ((getMidpointY('boyfriend') - (getProperty('boyfriend.height') / 1.7)) / (pixel and 1.5 or 1))
        ratingPos.game = {x = bf1, y = bf2}
        numPos.game = {x = ratingPos.game.x + 30, y = ratingPos.game.y + 100}
        comboPos.game = {x = numPos.game.x + (not isThousand and 30 or 70), y = numPos.game.y}
    end
    
    if showCombo then
        isThousand = getProperty('combo') >= 999
        comboPos.game.x = numPos.game.x + (isThousand and 70 or 30)
        comboPos.cam.x = numPos.cam.x + (isThousand and 70 or 30)
    end

    eh = getProperty('combo') + misses
end

function goodNoteHit(id, d, noteType, isSustainNote)
    if visible and not isSustainNote then
        brokeCombo = false
        if MODES.single then eh = 0 end 
        strumTime = getPropertyFromGroup('notes', id, 'strumTime')
        curRating = getRating((strumTime - getSongPosition() + getPropertyFromClass('ClientPrefs','ratingOffset')) / playbackRate)
        
        local ratingNumbers = {['sick'] = 1, ['good'] = 2, ['bad'] = 3, ['shit'] = 4, [customRating.image] = 5}
        ratiNum = ratingNumbers[curRating]
        useColor = (ratiNum and (ratiNum < 5 and ratingColors[ratiNum] or customRating.color) or 'ffffff')
        
        -- Ratings
        local ratingSpr = 'rating'..(MODES.single and '' or curRating..eh)
        local x, y = getXandY(ratingPos, true)
        if ratiNum then
            makeLuaSprite(ratingSpr, path.ratings .. (ratiNum < 5 and ratingGrab[ratiNum] or customRating.image), x, y)
            setObjectCamera(ratingSpr, camSet)
            setObjectOrder(ratingSpr, getObjectOrder('strumLineNotes') - 1)
            scaleObject(ratingSpr, scales.rating[1], scales.rating[2])
            setProperty(ratingSpr .. '.color', getColorFromHex(useColor))
            addLuaSprite(ratingSpr, true)
            if not MODES.stationary then setVelocity(ratingSpr, getRandomInt(0, 10), -180) setProperty(ratingSpr ..'.acceleration.y', 550 * playbackRate^2) end
            runTimer(ratingSpr..'Fade', (crochet * 0.001) / playbackRate)
        end

        -- Numbers
        if MODES.showNums then
            local combo = getProperty('combo')
            local split, numCount = splitNums(combo, foreverCount)
            for i = 1, numCount do
                local numSpr = 'num' .. i .. eh
                local nx, ny = getXandY(numPos, false)
                
                -- ICI : On multiplie 43 par la taille (scales.nums[1]) pour que l'écart rétrécisse avec le chiffre
                local multBy = (((i + 2) - numCount) * (80 * scales.nums[1]))
                
                makeLuaSprite(numSpr, path.nums .. numPrefix .. split[i] .. numSuffix, nx - multBy, ny)
                setObjectCamera(numSpr, camSet)
                
                -- ICI : On les place derrière les flèches (Z-Index)
                setObjectOrder(numSpr, getObjectOrder('strumLineNotes') - 1)
                
                scaleObject(numSpr, scales.nums[1], scales.nums[2])
                addLuaSprite(numSpr, true)
                
                if not MODES.stationary then 
                    setVelocity(numSpr, getRandomInt(-5, 5), -150) 
                    setProperty(numSpr .. '.acceleration.y', getRandomInt(200, 400) * playbackRate^2) 
                end
                runTimer(numSpr..'Fade', (crochet * 0.002 / playbackRate))
            end
        end
    end
end

function noteMiss(id, d, noteType, isSustainNote)
    if missSprite then
        local sprName = MODES.single and 'rating' or 'missrating' .. eh
        local x, y = getXandY(ratingPos, true) 
        makeLuaSprite(sprName, path.ratings .. missType, x, y) 
        setObjectCamera(sprName, camSet)
        scaleObject(sprName, scales.miss[1], scales.miss[2])
        addLuaSprite(sprName, true)
        runTimer(sprName..'Fade', (crochet * 0.001) / playbackRate)
    end
    brokeCombo = true
end

function noteMissPress() noteMiss() end

-- Fonctions utilitaires
function getRating(diff)
    diff = math.abs(diff)
    local windows = {'bad', 'good', 'sick'}
    if add5thRating then table.insert(windows, customRating.image) end
    local toReturn = 'shit'
    for i = 1, #windows do
        local hitWindow = (i < 4 and getPropertyFromClass('ClientPrefs', windows[i]..'Window') or customRating.hitWindow)
        if diff <= hitWindow then toReturn = windows[i] else break end
    end
    return toReturn
end

function setVelocity(thing, x, y)
    setProperty(thing..'.velocity.x', x * playbackRate)
    setProperty(thing..'.velocity.y', y * playbackRate)
end

function onTimerCompleted(t)
    if string.find(t, 'Fade') then doTweenAlpha('!'..t:gsub('Fade', ''), t:gsub('Fade', ''), 0, 0.2 / playbackRate) end
end

function onTweenCompleted(t)
    if string.find(t, '!') then removeLuaSprite(stringSplit(t, '!')[2], true) end
end

function getXandY(posTable, isRating)
    if onPlayerCombo and camSet == 'hud' then
        local off = (isRating and {1, 2} or {3, 4})
        return posTable.offset.x + mainOffset[off[1]], posTable.offset.y - mainOffset[off[2]]
    elseif camSet == 'game' then return posTable.game.x, posTable.game.y end
    return posTable.cam.x, posTable.cam.y
end

function splitNums(number, forev)
    local split, count = {}, 1
    local length = string.len(tostring(number)) 
    local looper = (number >= 999 and 3 or 2)
    for i = 0, looper do
        if (forev and length > i) or not forev then table.insert(split, math.floor(number / 10 ^ i % 10)) end
    end
    count = (forev and length or (number > 999 and 4 or 3))          
    return split, count
end