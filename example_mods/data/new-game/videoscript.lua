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
    setObjectOrder('videoSprite', 100000)

    addHaxeLibrary('MP4Handler', 'vlc')
    addHaxeLibrary('Event', 'openfl.events')

    runHaxeCode([[
    var video = new MP4Handler();
    video.visible = false;

    video.readyCallback = function() {
        var sprite = game.getLuaObject('videoSprite');
        if (sprite != null) {
            sprite.loadGraphic(video.bitmapData);
            sprite.visible = true;
        }
    };

    setVar('video', video);
]])
end

function onSongStart()
    songStarted = true

    runHaxeCode([[
        try {
            var video = getVar('video');
            var name = "]] .. videoName .. [[";
            if (video != null) video.playVideo(Paths.video(name));
        } catch (e:Dynamic) {
            trace('Erreur playVideo: ' + e);
        }
    ]])
end

function onPause()
    if not songStarted then return end

    runHaxeCode([[
        try {
            var video = getVar('video');
            if (video != null) video.pause();
        } catch (e:Dynamic) {
            trace('Erreur onPause: ' + e);
        }
    ]])
end

function onResume()
    if not songStarted then return end

    runHaxeCode([[
        try {
            var video = getVar('video');
            if (video != null) video.resume();
        } catch (e:Dynamic) {
            trace('Erreur onResume: ' + e);
        }
    ]])
end

function onStepHit()
    if curStep == 352 then
        videoActive = false
        songStarted = false

        runHaxeCode([[
            try {
                var video = getVar('video');
                if (video != null) {
                    video.finishVideo();
                    setVar('video', null);
                }
            } catch (e:Dynamic) {
                trace('Erreur cleanup video: ' + e);
            }
        ]])

        removeLuaSprite('videoSprite', true)
    end
end