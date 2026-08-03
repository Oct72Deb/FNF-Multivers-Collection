local songStarted = false
local videoActive = true
local videoName = ''

function onCreatePost()
    if isStoryMode then
        videoName = 'itsme'
    else
        videoName = 'itsme_freeplay'
    end

    makeLuaSprite('videoSprite', '', 0, 0)
    setObjectCamera('videoSprite', 'game')
    addLuaSprite('videoSprite', true)
    setProperty('videoSprite.visible', false)

    addHaxeLibrary('VideoSprite', 'hxcodec')

    runHaxeCode([[
        var vid:VideoSprite = null;

        function videoInit() {
            try {
                vid = new VideoSprite(0, 0);
                vid.finishCallback = function() {
                    setProperty('videoSprite.visible', false);
                };
                game.add(vid);
            } catch (e:Dynamic) {
                trace('videoInit error: ' + e);
            }
        }

        function videoPlay(name:String) {
            if (vid == null) return;
            try {
                setVar('videoKicked', false);
                vid.playVideo(Paths.video(name));
            } catch (e:Dynamic) {
                trace('videoPlay error: ' + e);
            }
        }
    ]])

    runHaxeFunction('videoInit')
end

function onSongStart()
    songStarted = true
    runHaxeFunction('videoPlay', {videoName})
    setProperty('videoSprite.visible', true)
end

function onUpdatePost(elapsed)
    if not songStarted or not videoActive then return end

    runHaxeCode([[
        if (vid == null) return;

        var kicked = getVar('videoKicked');
        if (kicked != true) {
            try {
                if (vid.bitmap.isDisplaying) {
                    setVar('videoKicked', true);
                } else {
                    vid.bitmap.pause();
                    vid.bitmap.resume();
                }
            } catch (e:Dynamic) {}
        }

        var sprite = game.getLuaObject('videoSprite');
        if (sprite != null && vid.bitmap.bitmapData != null) {
            sprite.loadGraphic(vid.bitmap.bitmapData);
        }
    ]])
end

function onResume()
    if not songStarted then return end
    runHaxeCode([[ if (vid != null) vid.bitmap.resume(); ]])
end

function onDestroy()
    videoActive = false
    songStarted = false
    runHaxeCode([[
        if (vid != null) {
            vid.bitmap.stop();
            game.remove(vid, true);
            vid = null;
        }
    ]])
    removeLuaSprite('videoSprite', true)
end