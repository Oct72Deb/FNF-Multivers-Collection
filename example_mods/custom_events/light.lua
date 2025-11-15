function onEvent(name, v1, v2)
	if name == 'light' then
		if v1 == 'on' then
			if v2 == 'dad' then
                makeLuaSprite('black', 'stagespotlight/black', -300, 0);
	            scaleObject('black', 10, 10);
	            addLuaSprite('black', false);
				setObjectOrder('black',10)

                makeLuaSprite('light', 'stagespotlight/spotlight', 70, -100);
	            addLuaSprite('light', true);
			else 
			if v2 == 'bf' then
            removeLuaSprite('black', true);
	        removeLuaSprite('light', true);

	        makeLuaSprite('black2', 'stagespotlight/black', -300, 0);
        	scaleObject('black2', 10, 10);
        	addLuaSprite('black2', false);
  
            makeLuaSprite('light2', 'stagespotlight/spotlight', 700, -100);
        	addLuaSprite('light2', true);
            else

            if v2 == 'daderect' then
	        makeLuaSprite('blackerect', 'stagespotlight/black', -300, 0);
        	scaleObject('blackerect', 10, 10);
        	addLuaSprite('blackerect', false);
			
            makeLuaSprite('lighterect', 'stagespotlight/spotlighterect', 70, -100);
        	addLuaSprite('lighterect', true);
            else
            if v2 == 'bferect' then
            removeLuaSprite('blackerect', true);
	        removeLuaSprite('lighterect', true);

	        makeLuaSprite('blackerect2', 'stagespotlight/black', -300, 0);
        	scaleObject('blackerect2', 10, 10);
        	addLuaSprite('blackerect2', false);
  
            makeLuaSprite('lighterect2', 'stagespotlight/spotlighterect', 700, -100);
        	addLuaSprite('lighterect2', true);
            else
            if v2 == 'remove' then
            removeLuaSprite('black', true);
	        removeLuaSprite('light', true);
            removeLuaSprite('black2', true);
	        removeLuaSprite('light2', true);
            removeLuaSprite('blackerect', true);
	        removeLuaSprite('lighterect', true);
            removeLuaSprite('blackerect2', true);
	        removeLuaSprite('lighterect2', true);
			end
        end
    end
end
end
end
end
end