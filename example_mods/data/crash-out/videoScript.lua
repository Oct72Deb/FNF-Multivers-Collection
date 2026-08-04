local songStarted = false
local videoReady = false

function onCreate()
    makeLuaSprite('videoSprite', '', 0, 0)
    setObjectCamera('videoSprite', 'game')
    addLuaSprite('videoSprite', false)
    setProperty('videoSprite.visible', false) -- Invisible tant qu'on n'est pas sûr

    addHaxeLibrary('MP4Handler', 'vlc')
    
    runHaxeCode([[
        var video = new MP4Handler();
        video.visible = false;
        setVar('video', video);
    ]])
end

function onSongStart()
    runHaxeCode([[
        var video = getVar('video');
        if (video != null) {
            video.playVideo(Paths.video('puff'));
            // On ne retire PAS l'event listener tout de suite, 
            // c'est souvent ça qui cause le Null Object Reference sur VlcBitmap
        }
    ]])
    
    -- On attend un tout petit peu (0.1s) avant d'autoriser l'affichage
    runTimer('startVideoDelay', 0.1)
end

function onTimerCompleted(tag)
    if tag == 'startVideoDelay' then
        songStarted = true
        videoReady = true
        setProperty('videoSprite.visible', true)
    end
end

function onUpdatePost(elapsed)
    if not songStarted or not videoReady then return end

    runHaxeCode([[
        var video = getVar('video');
        var sprite = game.getLuaObject('videoSprite');

        // LA PROTECTION ULTIME
        if (video != null && video.bitmapData != null && sprite != null) {
            
            if (sprite.pixels != video.bitmapData) {
                sprite.loadGraphic(video.bitmapData);
            } else {
                sprite.dirty = true;
            }

            video.volume = FlxG.sound.volume;
            if (game.paused) video.pause();
        }
    ]])
end

function onResume()
    if not songStarted then return end
    runHaxeCode([[
        var video = getVar('video');
        if (video != null) video.resume();
    ]])
end