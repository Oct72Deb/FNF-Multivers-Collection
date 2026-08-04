package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import Paths;

class GalleryState extends MusicBeatState {

    var musicInfoBG:FlxSprite;
    var musicInfoText:FlxText;

    var curCategory:String = "Images"; // "Images" ou "Music"

    // Initialisation déplacée dans create() pour éviter l'erreur de compilation
    var images:Array<GalleryImage>;
    var musics:Array<GalleryMusic>;

    var curSelected:Int = 0;

    var bg:FlxSprite;
    var imageDisplay:FlxSprite;
    var nameText:FlxText;
    var intendedColor:Int;
    var colorTween:FlxTween;

    var audioPlayer:FlxSound;

    // UI catégories
    var imagesTab:FlxText;
    var musicTab:FlxText;

    // Nouveaux éléments de barre de progression
    var progressBarBG:FlxSprite;
    var progressBar:FlxSprite;
    var timeText:FlxText;

    override function create() {
        super.create();
        
        // Initialisation des tableaux
        images = [];
        musics = [];

        FlxG.mouse.visible = true;

        FlxG.sound.playMusic(Paths.music("betamusic"), 0.8, true); 

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF000000;
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.screenCenter();
        add(bg);

        // UI catégories
        imagesTab = new FlxText(50, 20, 0, "Images", 24);
        imagesTab.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
        add(imagesTab);

        musicTab = new FlxText(200, 20, 0, "Music", 24);
        musicTab.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.GRAY, LEFT);
        add(musicTab);

        // --- Tes données originales ---
        addImage("Sketch of Markiplier", "gallery/conceptmark", 0xFFFFFFFF);
        addImage("Artwork Metal Mario", "gallery/artworkmetal", 0xFF919191);
        addImage("Sketch of Metal Mario Idle", "gallery/sketchmetal", 0xFF919191);
        addImage("Artwork Thatou", "gallery/artworkthatou", 0xFFC200A8);
        addImage("Sketch of Thatou", "gallery/sketchthatou", 0xFFFFFFFF);
        addImage("Originally, Metal Reflection had a percentage system inspired by the original Super Smash Bros.
        When the opponent sang, our percentage would increase.
        If the player had 300%, he would die.
        A good accuracy would reduce the received percentage.
        The mechanic ended up being scrapped, as it seemed too complex and poorly balanced.", "gallery/metalconcept", 0xFFFFFFFF, 0, 575, 17);
        addImage("?", "gallery/placeholder", 0xFFFFFFFF);

        addMusic("Concept_Tes.ogg", "tes", "0:56");
        addMusic("Concept_TrickorTreating.ogg", "dokis", "0:32");
        addMusic("Old_GameOver.ogg", "gameoverold", "0:57");
        addMusic("Old_NewGame.ogg", "newgame", "1:39");

        imageDisplay = new FlxSprite(0, 0);
        imageDisplay.antialiasing = true;
        imageDisplay.screenCenter();
        add(imageDisplay);

        nameText = new FlxText(0, FlxG.height - 800, FlxG.width, "", 32);
        nameText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        add(nameText);

        musicInfoBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
        musicInfoBG.alpha = 0.6;
        musicInfoBG.visible = false;
        add(musicInfoBG);

        var leText:String = "Press SPACE to play the music / Press SPACE to stop the music";
        musicInfoText = new FlxText(musicInfoBG.x, musicInfoBG.y + 4, FlxG.width, leText, 18);
        musicInfoText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
        musicInfoText.scrollFactor.set();
        musicInfoText.visible = false;
        add(musicInfoText);

        // Barre de progression
        progressBarBG = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width - 200, 20, FlxColor.BLACK);
        progressBarBG.screenCenter(X);
        progressBarBG.visible = false;
        add(progressBarBG);

        progressBar = new FlxSprite(progressBarBG.x, progressBarBG.y).makeGraphic(Std.int(progressBarBG.width), 20, FlxColor.WHITE);
        progressBar.origin.set(0, 0);
        progressBar.scale.x = 0;
        progressBar.visible = false;
        add(progressBar);

        timeText = new FlxText(0, progressBarBG.y - 50, FlxG.width, "0:00 / 0:00", 30);
        timeText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER);
        timeText.visible = false;
        add(timeText);

        if (images.length > 0) changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var left = controls.UI_LEFT_P;
        var right = controls.UI_RIGHT_P;
        var back = controls.BACK;
        var space = FlxG.keys.justPressed.SPACE;

        if (FlxG.mouse.justPressed && imagesTab.overlapsPoint(FlxG.mouse.getWorldPosition())) switchCategory("Images");
        if (FlxG.mouse.justPressed && musicTab.overlapsPoint(FlxG.mouse.getWorldPosition())) switchCategory("Music");

        if (curCategory == "Images") {
            if (left) changeSelection(-1);
            if (right) changeSelection(1);
        } else if (curCategory == "Music") {
            if (left) changeMusicSelection(-1);
            if (right) changeMusicSelection(1);
            if (space) toggleAudio();

            // Seek interactif
            if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(progressBarBG)) {
                if (audioPlayer != null && audioPlayer.length > 0) {
                    var pct:Float = FlxMath.bound((FlxG.mouse.x - progressBarBG.x) / progressBarBG.width, 0, 1);
                    var seekMs:Float = pct * audioPlayer.length;
                    audioPlayer.stop();
                    audioPlayer.play(false, seekMs);
                }
            }

            // Update barre et chrono
            if (audioPlayer != null && audioPlayer.playing) {
                progressBar.scale.x = FlxMath.bound(audioPlayer.time / audioPlayer.length, 0, 1);
                timeText.text = formatTime(audioPlayer.time) + " / " + formatTime(audioPlayer.length);
            }
        }

        if (back) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            if (FlxG.sound.music != null) FlxG.sound.music.stop();
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
            FlxG.mouse.visible = false;
            MusicBeatState.switchState(new MainMenuState());
        }
    }

    function switchCategory(cat:String) {
        curCategory = cat;
        var isMusic = (cat == "Music");

        imagesTab.color = isMusic ? FlxColor.GRAY : FlxColor.WHITE;
        musicTab.color = isMusic ? FlxColor.WHITE : FlxColor.GRAY;

        musicInfoBG.visible = isMusic;
        musicInfoText.visible = isMusic;
        progressBarBG.visible = isMusic;
        progressBar.visible = isMusic;
        timeText.visible = isMusic;

        if (cat == "Images") {
            if (audioPlayer != null && audioPlayer.playing) {
                FlxTween.cancelTweensOf(audioPlayer);
                audioPlayer.stop();
                audioPlayer.destroy();
                audioPlayer = null;
            }
            // Relance la musique de fond de l'onglet Images si elle n'est pas déjà lancée
            if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
                FlxG.sound.playMusic(Paths.music("betamusic"), 0.8, true);
            }
            if (images.length > 0) changeSelection(0);
        } else {
            if (FlxG.sound.music != null) FlxG.sound.music.stop();
            if (musics.length > 0) changeMusicSelection(0);
        }
    }

    function addImage(name:String, path:String, color:Int, ?textX:Float = -1, ?textY:Float = -1, ?textSize:Int = 32) {
        images.push(new GalleryImage(name, path, color, textX, textY, textSize));
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if (curSelected < 0) curSelected = images.length - 1;
        if (curSelected >= images.length) curSelected = 0;

        var img = images[curSelected];
        imageDisplay.visible = true;
        imageDisplay.loadGraphic(Paths.image(img.path));
        imageDisplay.scale.set(0.5, 0.5); 
        imageDisplay.updateHitbox();
        imageDisplay.screenCenter();

        // Position et taille du texte personnalisées si définies
        if (img.textX >= 0) nameText.x = img.textX; else nameText.x = 0;
        if (img.textY >= 0) nameText.y = img.textY; else nameText.y = FlxG.height - 64;
        nameText.text = img.name;
        nameText.setFormat(Paths.font("vcr.ttf"), img.textSize, FlxColor.WHITE, CENTER);
        
        if (img.color != intendedColor) {
            if (colorTween != null) colorTween.cancel();
            intendedColor = img.color;
            colorTween = FlxTween.color(bg, 1, bg.color, intendedColor);
        }

        FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
    }

    function addMusic(name:String, file:String, duration:String) {
        musics.push(new GalleryMusic(name, file, duration));
    }

    function changeMusicSelection(change:Int = 0) {
        curSelected += change;
        if (curSelected < 0) curSelected = musics.length - 1;
        if (curSelected >= musics.length) curSelected = 0;

        var mus = musics[curSelected];
        imageDisplay.visible = false; 
        nameText.text = "Music : " + mus.name;

        if (audioPlayer != null) {
            FlxTween.cancelTweensOf(audioPlayer);
            audioPlayer.stop();
            audioPlayer.destroy();
            audioPlayer = null;
        }

        var mus = musics[curSelected];
        progressBar.scale.x = 0;
        timeText.text = "0:00 / " + mus.duration;

        FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
    }

    function toggleAudio() {
        if (audioPlayer != null && audioPlayer.playing) {
            audioPlayer.pause();
            return;
        }

        if (audioPlayer != null && audioPlayer.time > 0) {
            audioPlayer.resume();
        } else {
            var mus = musics[curSelected];
            if (audioPlayer != null) { FlxTween.cancelTweensOf(audioPlayer); audioPlayer.destroy(); }
            var filePath:String = Paths.getPath('images/gallery/music/' + mus.file + '.ogg', SOUND);
            audioPlayer = new FlxSound().loadEmbedded(filePath, false, false);
            FlxG.sound.list.add(audioPlayer);
            audioPlayer.play();
        }
    }

    function formatTime(ms:Float):String {
        var seconds:Int = Math.floor(ms / 1000);
        var min:Int = Math.floor(seconds / 60);
        var sec:Int = seconds % 60;
        return min + ":" + (sec < 10 ? "0" + sec : "" + sec);
    }
}

class GalleryImage {
    public var name:String;
    public var path:String;
    public var color:Int;
    public var textX:Float;
    public var textY:Float;
    public var textSize:Int;

    public function new(name:String, path:String, color:Int, textX:Float = -1, textY:Float = -1, textSize:Int = 32) {
        this.name = name;
        this.path = path;
        this.color = color;
        this.textX = textX;
        this.textY = textY;
        this.textSize = textSize;
    }
}

class GalleryMusic {
    public var name:String;
    public var file:String;
    public var duration:String;
    public function new(name:String, file:String, duration:String) {
        this.name = name;
        this.file = file;
        this.duration = duration;
    }
}