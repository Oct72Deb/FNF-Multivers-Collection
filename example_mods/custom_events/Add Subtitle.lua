function onEvent(name,v1,v2)
    if name == 'Add Subtitle' then
        if v1 ~= '' then
            if not luaTextExists('SubtitleEvent') then
                makeLuaText('SubtitleEvent',v1,screenWidth,0,screenHeight - 150)
                setTextSize('SubtitleEvent',30)
                setTextBorder('SubtitleEvent',2,'000000')
                setObjectCamera('SubtitleEvent','other')
                addLuaText('SubtitleEvent')
            else
                setTextString('SubtitleEvent',v1)
            end
            if v2 ~= '' then
                local color = string.lower(v2)
                if color == 'bf' then
                    color = '31b0d1'
                elseif color == 'red' then
                    color = 'FF0000'
                elseif color == 'gangsta' then
                    color = 'bb394f'
                elseif color == 'blue' then
                    color = '0d00ff'
                else
                    color = string.gsub(v2,'0xFF','')
                end
                setProperty('SubtitleEvent.color',getColorFromHex(color))
            end
        else
            removeLuaText('SubtitleEvent',true)
        end
    end
end