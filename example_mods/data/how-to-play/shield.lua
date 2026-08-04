-- Paramètres de base
local shieldActive = false
local shieldPower = 100
local shieldBroken = false
local shieldStunTimer = 0
local shieldBreakDuration = 5

-- Équilibrage
local shieldRegenRate = 3 
local shieldDrainRate = 8 
local shieldHitPenalty = 2 

function onCreate()
    -- Texte HUD
    makeLuaText('shieldText', 'Shield: 100%', 1250, 20, 20)
    setTextFont('shieldText', 'Kabel-Heavy Heavy.ttf')
    setTextSize('shieldText', 40)
    setTextColor('shieldText', '00BFFF')
    setObjectCamera('shieldText', 'camHUD')
    addLuaText('shieldText')

    -- Sprite du bouclier (Opaque)
    makeLuaSprite('redshield', 'bg/metacrystal/redshield', 400, 0)
    setObjectCamera('redshield', 'game')
    setProperty('redshield.visible', false)
    addLuaSprite('redshield', true)
end

function onUpdate(elapsed)
    local keyPressed = getPropertyFromClass('flixel.FlxG', 'keys.pressed.SPACE')
    local wasActive = shieldActive
    
    shieldActive = keyPressed and not shieldBroken

    -- Sons
    if shieldActive and not wasActive then
        playSound('shieldon', 1)
    elseif not shieldActive and wasActive and not shieldBroken then
        playSound('shieldoff', 1)
    end

    -- Gestion du Stun
    if shieldBroken then
        shieldStunTimer = shieldStunTimer - elapsed
        
        -- Force l'animation stun en boucle
        if getProperty('boyfriend.animation.curAnim.name') ~= 'stun' then
            characterPlayAnim('boyfriend', 'stun', true)
        end

        if shieldStunTimer <= 0 then
            shieldBroken = false
            shieldPower = 50
            setProperty('boyfriend.stunned', false)
        else
            setProperty('boyfriend.stunned', true)
        end
    else
        -- Gestion Energie
        if shieldActive then
            shieldPower = shieldPower - shieldDrainRate * elapsed
            if shieldPower <= 0 then breakShield() end
        else
            if shieldPower < 100 then
                shieldPower = shieldPower + shieldRegenRate * elapsed
                if shieldPower > 100 then shieldPower = 100 end
            end
        end
    end

    updateShieldVisuals()
end

function onKeyPress(key)
    if shieldBroken then return Function_Stop end
end

function breakShield()
    shieldPower = 0
    shieldBroken = true
    shieldStunTimer = shieldBreakDuration
    playSound('shieldbreak', 1)
    cameraShake('camGame', 0.06, 0.25)
    characterPlayAnim('boyfriend', 'stun', true)
end

function updateShieldVisuals()
    setTextString('shieldText', 'Shield: ' .. math.floor(shieldPower) .. '%')
    
    if shieldActive and not shieldBroken then
        setProperty('redshield.visible', true)
        
        -- Centrage sur BF
        local bfMidX = getMidpointX('boyfriend')
        local bfMidY = getMidpointY('boyfriend')
        setProperty('redshield.x', bfMidX - (getProperty('redshield.width') / 2))
        setProperty('redshield.y', bfMidY - (getProperty('redshield.height') / 2))
        
        -- CORRECTION ICI : Le scale suit l'énergie jusqu'à 1% (0.01)
        local scale = math.max(shieldPower / 100, 0.01)
        scaleObject('redshield', scale, scale)
    else
        setProperty('redshield.visible', false)
    end
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
   
   if noteType == "metalnote" then
   if not shieldActive then
    setProperty('health', getProperty('health') - 0.05)
  end
end

   
    if shieldActive and not shieldBroken then
        shieldPower = shieldPower - shieldHitPenalty
        if shieldPower <= 0 then breakShield() end
        
    end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if noteType == 'Shield Note' then
        if not shieldActive then
            setProperty('healthh', getProperty('health') - 0.5)
            characterPlayAnim('boyfriend', 'hurt', true)
            playSound('missnote', 0.5)
        end
    end
end