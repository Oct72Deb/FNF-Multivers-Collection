local iconScale = 0.8

local totalSongLength = 0

local shieldActive = false
local shieldPower = 100
local shieldBroken = false
local shieldStunTimer = 0
local shieldBreakDuration = 5

local shieldRegenRate = 3 -- %/sec
local shieldDrainRate = 8 -- %/sec (while active)
local shieldHitPenalty = 2 -- % per note hit while shielding

function onCreate()
    setProperty('healthBar.x', 400)
    setProperty('healthBar.y', 450)
    scaleObject('healthBar', 0.8, 0.8);
    scaleObject('healthBarBG', 0.8, 0.8);
	setProperty('healthBarBG.visible', false)
	setProperty('healthBar.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)

    setProperty('iconP1.x', getProperty('iconP1.x') + 200)
    setProperty('iconP1.y', getProperty('iconP1.y') -200)

    setProperty('iconP2.x', getProperty('iconP2.x') + 200)
    setProperty('iconP2.y', getProperty('iconP2.y') -210)
    scaleObject('iconP2', 0.6, 0.6)
    -- Timer
    makeLuaText('smashTimer', '00:00', 0, screenWidth - 340, 430)
    setTextFont('smashTimer', 'Kabel-Heavy Heavy.ttf')
    setTextSize('smashTimer', 60)
    setObjectCamera('smashTimer', 'camHUD')
    addLuaText('smashTimer')

    -- Texte bouclier
    makeLuaText('shieldText', 'Shield: 100%', 1250, 20, 20)
    setTextFont('shieldText', 'Kabel-Heavy Heavy.ttf')
    setTextSize('shieldText', 40)
    setTextColor('shieldText', '00BFFF')
    setObjectCamera('shieldText', 'camHUD')
    addLuaText('shieldText')

    -- Sprite bouclier
    makeLuaSprite('redshield', 'meta/redshield', 400, 0)
    addLuaSprite('redshield', true)
    setObjectCamera('redshield', 'game')
    setProperty('redshield.visible', false)

    -- Masquer HUD FNF
    setProperty('timeTxt.visible', false)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('scoreTxt.visible', false);
end

function onBeatHit()
    -- Forcer la taille au moment où le moteur applique le boop
    setProperty('iconP1.scale.x', iconScale)
    setProperty('iconP1.scale.y', iconScale)

    setProperty('iconP2.scale.x', iconScale)
    setProperty('iconP2.scale.y', iconScale)
end

function onSongStart()
    totalSongLength = getProperty('songLength') -- durée totale de la chanson en ms
end

function onUpdate(elapsed)
    setProperty('iconP1.scale.x', iconScale)
    setProperty('iconP1.scale.y', iconScale)

    setProperty('iconP2.scale.x', iconScale)
    setProperty('iconP2.scale.y', iconScale)

    -- Timer
    local remaining = totalSongLength - getSongPosition()
    if remaining < 0 then remaining = 0 end -- éviter les valeurs négatives

    local seconds = math.floor(remaining / 1000)
    local minutes = math.floor(seconds / 60)
    seconds = seconds % 60

    local timeString = string.format("%02d:%02d", minutes, seconds)
    setTextString('smashTimer', timeString)

    -- Bouclier
    local wasShieldActive = shieldActive
    shieldActive = getPropertyFromClass('flixel.FlxG', 'keys.pressed.SPACE')

    if shieldActive and not wasShieldActive and not shieldBroken then
        playSound('shieldon', 1)
    elseif not shieldActive and wasShieldActive and not shieldBroken then
        playSound('shieldoff', 1)
    end

    if not shieldBroken then
        if shieldActive then
            shieldPower = shieldPower - shieldDrainRate * elapsed
            if shieldPower <= 0 then
                shieldPower = 0
                shieldBroken = true
                shieldStunTimer = shieldBreakDuration
                playSound('shieldbreak', 1)
                cameraShake('camGame', 0.06, 0.25)
                playAnim('boyfriend', 'shieldbreak', true)
            end
        else
            if shieldPower < 100 then
                shieldPower = shieldPower + shieldRegenRate * elapsed
                if shieldPower > 100 then shieldPower = 100 end
            end
        end
    else
        shieldStunTimer = shieldStunTimer - elapsed
        if shieldStunTimer <= 0 then
            shieldBroken = false
            shieldPower = 50
        else
            if getProperty('boyfriend.animation.curAnim.name') ~= 'shieldbreak' then
                characterPlayAnim('boyfriend', 'shieldbreak', true)
            end
        end
        
        if shieldBroken then
        setProperty('boyfriend.stunned',true)
        elseif not shieldBroken then
        setProperty('boyfriend.stunned',false)
       end
    end

    setTextString('shieldText', 'Shield: ' .. math.floor(shieldPower) .. '%')

    -- Affichage sprite bouclier
    if shieldActive and not shieldBroken then
        setProperty('redshield.visible', true)
        local scale = math.max(shieldPower / 100, 0.05)
        scaleObject('redshield', scale, scale)

        local bfX = getProperty('boyfriend.x')
        local bfY = getProperty('boyfriend.y')
        local bfW = getProperty('boyfriend.width')
        local bfH = getProperty('boyfriend.height')
        local shieldSize = 512 * scale

        setProperty('redshield.x', bfX + bfW/2 - shieldSize/2)
        setProperty('redshield.y', bfY + bfH/2 - shieldSize/2)
    else
        setProperty('redshield.visible', false)
    end
end

function opponentNoteHit()

	if shieldActive then
    setProperty('health', getProperty('health') - 0)
    elseif not shieldActive then
    setProperty('health', getProperty('health') - 0.00)
   end
    if shieldActive and not shieldBroken then
        shieldPower = shieldPower - shieldHitPenalty
        if shieldPower <= 0 then
            shieldPower = 0
            shieldBroken = true
            shieldStunTimer = shieldBreakDuration
            playSound('shieldbreak', 1)
            cameraShake('camGame', 0.06, 0.25)
            playAnim('boyfriend', 'shieldbreak', true)
        end
    end
end