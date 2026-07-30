function onCreate()

if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'metalnote' then
		setPropertyFromGroup('unspawnNotes',i,'texture','metal_NOTE_assets')
            setPropertyFromGroup('unspawnNotes',i,'ignoreNote',false)
     end
end