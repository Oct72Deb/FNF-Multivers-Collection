local songStarted = false
local videoActive = true
local videoName = ''

function onCreatePost()
        if isStoryMode then
        videoName = 'itsme'
    else
        videoName = 'itsme_freeplay'
        setPropertyFromClass('PlayState', 'startOnTime', 23670)
    end

    setProperty('skipCountdown', true)

    makeLuaSprite('black', '', 0, 0)
    makeGraphic('black', 2500, 2500, '000000')
    setObjectCamera('black', 'game')
    setObjectOrder('black', 99999)
    screenCenter('black')
    addLuaSprite('black', true)

    makeLuaSprite('videoSprite', '', 180, 50)
    scaleObject('videoSprite', 1.37, 1.37)
    setObjectCamera('videoSprite', 'game')
    addLuaSprite('videoSprite', true)
    setProperty('videoSprite.visible', false)

    addHaxeLibrary('VideoHandler', 'vlc')
    addHaxeLibrary('Event', 'openfl.events')

    runHaxeCode([[
        var video = new VideoHandler();
        video.visible = false;
        setVar('video', video);
    ]])
    
    setObjectOrder('videoSprite', 100000)
end

function onSongStart()
    songStarted = true

    runHaxeCode([[
        var video = getVar('video');
        var name = "]] .. videoName .. [[";

        if (video != null) {
            video.playVideo(Paths.video(name));

            // ⚡ astuce SAFE pour forcer la première frame
            video.pause();
            video.resume();

            FlxG.stage.removeEventListener('enterFrame', video.update);
        }
    ]])

    setProperty('videoSprite.visible', true)
end

function onUpdatePost(elapsed)
    if not songStarted or not videoActive then return end

    runHaxeCode([[
        var video = getVar('video');
        if (video == null) return;

        if (video.bitmapData == null) return;

        var sprite = game.getLuaObject('videoSprite');
        if (sprite == null) return;

        sprite.loadGraphic(video.bitmapData);

        video.volume = FlxG.sound.volume;
        if (game.paused) video.pause();
    ]])
end

function onResume()
    if not songStarted then return end

    runHaxeCode([[
        var video = getVar('video');
        if (video != null) video.resume();
    ]])
end

function onStepHit()
    if curStep == 352 then
        videoActive = false
        songStarted = false

        runHaxeCode([[
            var video = getVar('video');
            if (video != null) {
                video.stop();
                FlxG.stage.removeEventListener('enterFrame', video.update);
                setVar('video', null);
            }
        ]])

        removeLuaSprite('videoSprite', true)
    end
end