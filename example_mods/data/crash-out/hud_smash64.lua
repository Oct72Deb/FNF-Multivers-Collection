local iconScale = 0.6
function onUpdatePost()
    setProperty('iconP2.visible', false);
   setProperty('iconP1.visible', false);
    setProperty('healthBar.visible', false);
    setProperty('healthBarBG.visible', false);
    setProperty('scoreTxt.visible', false);
setProperty('timeTxt.visible',false)

end

function onBeatHit()
    -- Forcer la taille au moment où le moteur applique le boop
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
end