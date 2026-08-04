local defaultOrders = {bf = 0, dad = 0, gf = 0}
local ordersSaved = false
local eventSetupDone = false
local discoActive = {false, false, false}

-- ==========================================
-- POSITIONS PAR DÉFAUT
-- ==========================================
local basePos = {
    dad = {-120, -270},
    bf  = {10, -270},
    gf  = {-160, -320}
}

function onEvent(name, value1, value2)
    if name == 'Spotlight' then
        -- 1. Sauvegarde des calques d'origine
        if not ordersSaved then
            defaultOrders.bf = getObjectOrder('boyfriendGroup')
            defaultOrders.dad = getObjectOrder('dadGroup')
            defaultOrders.gf = getObjectOrder('gfGroup')
            ordersSaved = true
        end

        -- 2. Création des sprites
        if not eventSetupDone then
            makeLuaSprite('darkScreen', '', -1500, -1000)
            makeGraphic('darkScreen', 5000, 5000, '000000')
            setProperty('darkScreen.alpha', 0)
            addLuaSprite('darkScreen', false)

            for i = 1, 3 do
                local tag = 'spotlightSprite' .. i
                makeLuaSprite(tag, 'stagespotlight/spotlight', 0, 0)
                setBlendMode(tag, 'add')
                setProperty(tag .. '.alpha', 0)
                addLuaSprite(tag, false)
            end
            eventSetupDone = true
        end

        local target = string.lower(value1)
        discoActive = {false, false, false}

        -- --- RESET SYSTÉMATIQUE ---
        -- On renvoie TOUT LE MONDE à son calque d'origine avant de traiter la commande
        setObjectOrder('boyfriendGroup', defaultOrders.bf)
        setObjectOrder('dadGroup', defaultOrders.dad)
        setObjectOrder('gfGroup', defaultOrders.gf)

        -- 3. Mode OFF
        if target == 'off' or target == '' then
            doTweenAlpha('darkFadeOut', 'darkScreen', 0, 0.2, 'linear')
            for i = 1, 3 do 
                doTweenAlpha('spotFadeOut'..i, 'spotlightSprite'..i, 0, 0.2, 'linear')
                setProperty('spotlightSprite'..i..'.color', getColorFromHex('FFFFFF'))
            end
            
        -- 4. Modes ON
        else
            local offsets = stringSplit(value2, ',')
            local o = {} 
            for i = 1, 6 do o[i] = tonumber(offsets[i]) or 0 end

            local baseOrder = 600 
            setObjectOrder('darkScreen', baseOrder)
            for i = 1, 3 do setProperty('spotlightSprite'..i..'.alpha', 0) end
            
            if target == 'dad' or target == 'disco-dad' then
                setupSpot(1, 'dad', basePos.dad[1] + o[1], basePos.dad[2] + o[2], baseOrder + 10)
                if target == 'disco-dad' then discoActive[1] = true end

            elseif target == 'bf' or target == 'disco-bf' then
                setupSpot(2, 'boyfriend', basePos.bf[1] + o[3], basePos.bf[2] + o[4], baseOrder + 10)
                if target == 'disco-bf' then discoActive[2] = true end

            elseif target == 'gf' or target == 'disco-gf' then
                setupSpot(3, 'gf', basePos.gf[1] + o[5], basePos.gf[2] + o[6], baseOrder + 10)
                if target == 'disco-gf' then discoActive[3] = true end

            elseif target == 'duo' or target == 'disco-duo' then
                setupSpot(1, 'dad', basePos.dad[1] + o[1], basePos.dad[2] + o[2], baseOrder + 5)
                setupSpot(2, 'boyfriend', basePos.bf[1] + o[3], basePos.bf[2] + o[4], baseOrder + 10)
                if target == 'disco-duo' then discoActive[1], discoActive[2] = true, true end

            elseif target == 'trio' or target == 'disco-trio' then
                setupSpot(3, 'gf', basePos.gf[1] + o[5], basePos.gf[2] + o[6], baseOrder + 2)
                setupSpot(1, 'dad', basePos.dad[1] + o[1], basePos.dad[2] + o[2], baseOrder + 5)
                setupSpot(2, 'boyfriend', basePos.bf[1] + o[3], basePos.bf[2] + o[4], baseOrder + 10)
                if target == 'disco-trio' then discoActive = {true, true, true} end
            end

            doTweenAlpha('darkFadeIn', 'darkScreen', 0.3, 0.2, 'linear')
        end
    end
end

-- (onUpdate et setupSpot restent les mêmes)
local discoTimer = 0
function onUpdate(elapsed)
    local anyDisco = false
    for i=1,3 do if discoActive[i] then anyDisco = true end end
    if anyDisco then
        discoTimer = discoTimer + elapsed
        if discoTimer > 0.15 then
            discoTimer = 0
            for i = 1, 3 do
                if discoActive[i] then
                    local randomCol = string.format('%02x%02x%02x', math.random(0, 255), math.random(0, 255), math.random(0, 255))
                    setProperty('spotlightSprite'..i..'.color', getColorFromHex(randomCol))
                end
            end
        end
    end
end

function setupSpot(num, char, finalX, finalY, layerPriority)
    local tag = 'spotlightSprite' .. num
    local group = (char == 'gf' and 'gfGroup' or char .. 'Group')
    local sw = getProperty(tag .. '.width')
    local sh = getProperty(tag .. '.height')
    setProperty(tag .. '.x', getMidpointX(char) - (sw / 2) + finalX)
    setProperty(tag .. '.y', getMidpointY(char) - (sh / 2) + finalY)

    setObjectOrder(group, layerPriority)
    setObjectOrder(tag, layerPriority + 1)
    doTweenAlpha('spotFadeIn'..num, tag, 0.6, 0.2, 'linear')
end