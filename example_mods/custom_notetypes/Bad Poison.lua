function onCreate()
    makeLuaSprite('poisonFog','mario/BadMario/poisonVG',0,0)
    setObjectCamera('poisonFog','hud')
    setProperty('poisonFog.alpha',0.001)
    addLuaSprite('poisonFog',false)
    for i = 0,getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Bad Poison' then
            setPropertyFromGroup('unspawnNotes',i,'texture','badMario_NOTE_assets')
            setPropertyFromGroup('unspawnNotes',i,'ignoreNote',true)
            setPropertyFromGroup('unspawnNotes',i,'hitHealth',0)
        end
    end
end
function goodNoteHit(id,data,type,sus)
    if type == 'Bad Poison' then
        doTweenAlpha('poisonAlpha','poisonFog',getProperty('poisonFog.alpha')+0.1,0.5,'circOut')
    end
end
function onUpdate(el)
    if getProperty('poisonFog.alpha') >= 0 then
        setProperty('poisonFog.alpha',math.max(0,getProperty('poisonFog.alpha') - (el/10)))
        setHealth(getHealth()-(el*getProperty('poisonFog.alpha')))
    end
end