local trick = {img = 'healthbar_doki', x = 320, y = 578, yd = 18, s = 0.81}
local songConfig = {
    ['crash out']  = false,

    ['default']            = {img = 'healthbar_default', x = 225, y = 603, yd = 42,  s = 0.81},

    ['how to play']        = {img = 'healthbar_smash',   x = 320, y = 578, yd = 100, s = 0.41},
    ['metal reflection']   = {img = 'healthbar_smash',   x = 207, y = 608, yd = 90,  s = 0.66},
    ['criminal targets']   = {img = 'healthbar_smash',   x = 230, y = 594, yd = 33,  s = 0.81},
    ['trick or treat']     = trick,
    ['trick or treat old'] = trick,
    ['allocution']         = {img = 'healthbar_fr',      x = 215, y = 625, yd = 63,  s = 0.81},
    ['new game']           = {img = 'healthbar_madness', x = 252, y = 607, yd = 47,  s = 0.82},
}

function onCreatePost()
    local cleanName = string.lower(songName)
    
    local config = songConfig[cleanName]

    if config == false then 
        return 
    end

    config = config or songConfig['default']

    if config then
        local finalY = config.y
        if downscroll then
            finalY = config.yd
        end

        local tag = 'healthbarCustom'
        makeLuaSprite(tag, 'hud/healthbar/' .. config.img, config.x, finalY)
        scaleObject(tag, config.s, config.s)
        setObjectCamera(tag, 'camHUD')
        addLuaSprite(tag, true)

        local hbOrder = getObjectOrder('healthBarBG')
        setObjectOrder(tag, hbOrder - 1)
    end
end