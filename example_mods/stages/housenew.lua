-- Stage défilant style marche FNF - Psych Engine 0.6.3



local scrollSpeed = 100 -- vitesse du défilement (pixels par seconde)

local bg1X = 0

local bg2X = 2563 -- Position initiale du deuxième fond



function onCreate()

    makeLuaSprite('HUD', 'fmShade', 0, 0)

	setLuaSpriteScrollFactor('HUD', 1, 1)

	scaleObject('HUD', 1, 1)

    setObjectCamera('HUD', 'camOther')

    

	--THE TOP BAR

	makeLuaSprite('UpperBarr', 'empty', -150, -50)

	makeGraphic('UpperBarr', 1580, 120, '000000')

	setObjectCamera('UpperBarr', 'hud')

	addLuaSprite('UpperBarr', false)



	--THE BOTTOM BAR

	makeLuaSprite('LowerBarr', 'empty', -150, 650)

	makeGraphic('LowerBarr', 1580, 120, '000000')

	setObjectCamera('LowerBarr', 'hud')

	addLuaSprite('LowerBarr', false)



    -- Premier fond

    makeLuaSprite('bg1', 'bg//doki/house', bg1X, 0)

    setScrollFactor('bg1', 1, 1)

    scaleObject('bg1', 1, 1)

    addLuaSprite('bg1', false)



    -- Deuxième fond (pour la boucle)

    makeLuaSprite('bg2', 'bg//doki/house', bg2X, 0)

    setScrollFactor('bg2', 1, 1)

    scaleObject('bg2', 1, 1)

    addLuaSprite('bg2', false)
  
end




function onUpdate(elapsed)

    local moveAmount = scrollSpeed * elapsed



    -- Déplacement des backgrounds vers la droite (effet de marche vers la gauche)

    bg1X = bg1X + moveAmount

    bg2X = bg2X + moveAmount



    -- Réassignation des positions

    setProperty('bg1.x', bg1X)

    setProperty('bg2.x', bg2X)



    -- Boucle infinie du scroll

    if bg1X >= 2563 then

        bg1X = bg2X - 2563

    end

    if bg2X >= 2563 then

        bg2X = bg1X - 2563

    end

end