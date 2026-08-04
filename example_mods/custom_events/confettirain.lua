local confettiIndex = 0
local confettiRate = 0
local confettiSpeed = 2
local spawnTimer = 0

function onEvent(name, value1, value2)
    if name == 'confettirain' then
        confettiRate = tonumber(value1) or 0
        confettiSpeed = tonumber(value2) or 2

        if confettiRate <= 0 then
            confettiRate = 0
            -- On ne force pas la suppression massive ici, 
            -- on laisse les confettis tomber pour un effet naturel.
        end
    end
end

function onUpdate(elapsed)
    if confettiRate > 0 then
        spawnTimer = spawnTimer + elapsed
        local interval = 1 / confettiRate

        while spawnTimer >= interval do
            spawnConfetti(confettiSpeed)
            spawnTimer = spawnTimer - interval
            
            -- Sécurité anti-crash : limite par frame
            if confettiIndex > 10000 then confettiIndex = 0 end 
        end
    end
end

function spawnConfetti(speed)
    confettiIndex = confettiIndex + 1
    local tag = 'confetti' .. confettiIndex
    local size = math.random(4, 8)

    makeLuaSprite(tag, nil, math.random(-20, screenWidth + 20), -50)
    makeGraphic(tag, size, size, randomColor())
    setObjectCamera(tag, 'hud')
    addLuaSprite(tag, false)

    doTweenY(tag .. 'Y', tag, screenHeight + 100, speed + math.random(), 'linear')
    -- Les autres tweens sont cosmétiques, on ne les écoute pas dans onTweenCompleted
    doTweenAngle(tag .. 'A', tag, math.random(-360, 360), speed, 'linear')
end

function onTweenCompleted(tag)
    -- On supprime l'objet seulement quand le mouvement Y est fini
    if string.endsWith(tag, 'Y') and string.find(tag, 'confetti') then
        removeLuaSprite(tag:sub(1, -2), true)
    end
end

function randomColor()
    local colors = {'FF3B3B', 'FFD93B', '3BFF6F', '3BD9FF', 'B83BFF', 'FF3BD9'}
    return colors[math.random(#colors)]
end