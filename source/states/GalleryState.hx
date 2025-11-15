package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.system.FlxSound;
import Paths;

using StringTools;

class GalleryState extends MusicBeatState {

    var musicInfoBG:FlxSprite;
    var musicInfoText:FlxText;

    var curCategory:String = "Images"; // "Images" ou "Music"

    var images:Array<GalleryImage> = [];
    var musics:Array<GalleryMusic> = [];

    private static var curSelected:Int = 0;

    var bg:FlxSprite;
    var imageDisplay:FlxSprite;
    var nameText:FlxText;
    var intendedColor:Int;
    var colorTween:FlxTween;

    var audioPlayer:FlxSound;

    // UI catégories
    var imagesTab:FlxText;
    var musicTab:FlxText;

    override function create() {
        super.create();
        FlxG.mouse.visible = true;

        persistentUpdate = true;

        FlxG.sound.playMusic(Paths.music("betamusic"), 0.8, true); 

        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF000000;
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.screenCenter();
        add(bg);

        // Onglets en haut
        imagesTab = new FlxText(50, 20, 0, "Images", 24);
        imagesTab.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
        add(imagesTab);

        musicTab = new FlxText(200, 20, 0, "Music", 24);
        musicTab.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.GRAY, LEFT);
        add(musicTab);

        // Images
        addImage("Sketch of Markiplier", "gallery/conceptmark", 0xFFFFFFFF);
        addImage("Artwork Metal Mario", "gallery/artworkmetal", 0xFF919191);
        addImage("Sketch of Metal Mario Idle", "gallery/sketchmetal", 0xFF919191);
        addImage("Artwork Thatou", "gallery/artworkthatou", 0xFFC200A8);
        addImage("Sketch of Thatou", "gallery/sketchthatou", 0xFFFFFFFF);
        addImage("Originally, Metal Reflection had a percentage system inspired by the original Super Smash Bros.
        when the opponent sang, our percentage would increase.
        If the player had 300%, he would die.
        A good accuracy would reduce the received percentage.
        The mechanic ended up being scrapped, as it seemed too complex and poorly balanced.", "gallery/metalconcept", 0xFFFFFFFF, 0, 630, 15);
        addImage("Here’s a very very old version of the song 'Periple'", "gallery/periple_test", 0xFF221357);
        addImage("?", "gallery/placeholder", 0xFFFFFFFF);

        // Musiques
        addMusic("Concept_Tes.ogg", "tes");
        addMusic("Concept_TrickorTreating.ogg", "dokis");
        addMusic("Old_GameOver.ogg", "gameoverold");
        addMusic("Old_Periple.ogg", "periple");
        addMusic("Old_NewGame.ogg", "newgame");

        // Sprite image
        imageDisplay = new FlxSprite(0, 0);
        imageDisplay.antialiasing = true;
        imageDisplay.screenCenter();
        add(imageDisplay);

        // Texte nom
        nameText = new FlxText(0, FlxG.height - 64, FlxG.width, "", 32);
        nameText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        add(nameText);

        // Texte en bas uniquement pour Music
        musicInfoBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
        musicInfoBG.alpha = 0.6;
        musicInfoBG.visible = false; // caché par défaut
        add(musicInfoBG);

        var leText:String = "Press SPACE to play the music ! / Press SPACE to pause your music.";
        var size:Int = 18;
        musicInfoText = new FlxText(musicInfoBG.x, musicInfoBG.y + 4, FlxG.width, leText, size);
        musicInfoText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
        musicInfoText.scrollFactor.set();
        musicInfoText.visible = false; // caché par défaut
        add(musicInfoText);

        if (images.length > 0) changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var left = controls.UI_LEFT_P;
        var right = controls.UI_RIGHT_P;
        var back = controls.BACK;
        var space = FlxG.keys.justPressed.SPACE;

        // Clic souris sur "Images"
        if (FlxG.mouse.justPressed && imagesTab.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            switchCategory("Images");
        }

        // Clic souris sur "Music"
        if (FlxG.mouse.justPressed && musicTab.overlapsPoint(FlxG.mouse.getWorldPosition())) {
            switchCategory("Music");
        }

        // Navigation
        if (curCategory == "Images") {
            if (left) changeSelection(-1);
            if (right) changeSelection(1);
        }
        else if (curCategory == "Music") {
            if (left) changeMusicSelection(-1);
            if (right) changeMusicSelection(1);

            if (space) toggleAudio();
        }

        if (back) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.sound.music.stop(); 
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
            FlxG.mouse.visible = false;
            MusicBeatState.switchState(new MainMenuState());
        }
    }

    function switchCategory(cat:String) {
    curCategory = cat;

    if (cat == "Images") {
        imagesTab.color = FlxColor.WHITE;
        musicTab.color = FlxColor.GRAY;

        // Stop la musique en cours si elle joue
        if (audioPlayer != null && audioPlayer.playing) {
            audioPlayer.stop();
            audioPlayer.destroy();
            audioPlayer = null;
        }

        // Relance la musique de fond de l’onglet Images si elle n’est pas déjà lancée
        if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
            FlxG.sound.playMusic(Paths.music("betamusic"), 0.8, true);
        }

        // Masquer le texte Music
        musicInfoBG.visible = false;
        musicInfoText.visible = false;

        if (images.length > 0) changeSelection(0);
    } 
    else { // Music
        musicTab.color = FlxColor.WHITE;
        imagesTab.color = FlxColor.GRAY;

        // Stop la musique de fond de l’onglet Images si elle joue
        if (FlxG.sound.music != null) {
            FlxG.sound.music.stop();
        }

        // Afficher le texte Music
        musicInfoBG.visible = true;
        musicInfoText.visible = true;

        if (musics.length > 0) changeMusicSelection(0);
    }
}



    // ---------- IMAGES ----------
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
        nameText.size = img.textSize;
        nameText.text = img.name;
        nameText.setFormat(Paths.font("vcr.ttf"), img.textSize, FlxColor.WHITE, CENTER);

        if (img.color != intendedColor) {
            if (colorTween != null) colorTween.cancel();
            intendedColor = img.color;
            colorTween = FlxTween.color(bg, 1, bg.color, intendedColor);
        }

        FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
    }

    // ---------- MUSIQUE ----------
    function addMusic(name:String, file:String) {
        musics.push(new GalleryMusic(name, file));
    }

    function changeMusicSelection(change:Int = 0) {
    curSelected += change;

    if (curSelected < 0) curSelected = musics.length - 1;
    if (curSelected >= musics.length) curSelected = 0;

    var mus = musics[curSelected];
    imageDisplay.visible = false; // pas d’image en mode musique
    nameText.text = "Music : " + mus.name;

    // Stop la musique actuelle si elle joue
    if (audioPlayer != null && audioPlayer.playing) {
        audioPlayer.stop();
        audioPlayer.destroy();
        audioPlayer = null;
    }

    FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
}


    function toggleAudio() {
        if (audioPlayer != null && audioPlayer.playing) {
            audioPlayer.stop();
            return;
        }

        var mus = musics[curSelected];

        if (audioPlayer != null) audioPlayer.destroy();

        var filePath:String = Paths.getPath('images/gallery/music/' + mus.file + '.ogg', SOUND);

        audioPlayer = new FlxSound().loadEmbedded(filePath, false, false);
        FlxG.sound.list.add(audioPlayer);
        audioPlayer.play();
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

    public function new(name:String, file:String) {
        this.name = name;
        this.file = file;
    }
}