function onEvent(name, value1, value2)
if name == "Hide hud" then
local targetAlpha = tonumber(value1) or 0
local tweenTime = tonumber(value2) or 1

doTweenAlpha('HUD', 'camHUD', targetAlpha, tweenTime, 'linear')
end
end