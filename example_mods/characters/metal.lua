local intensity = 0.005
local duration = 0.1

function opponentNoteHit()
    camShake()
end

function camShake()
    cameraShake('hud', intensity, duration)
end