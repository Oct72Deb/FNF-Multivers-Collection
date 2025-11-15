/*
package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import openfl.utils.AssetType;
import flixel.math.FlxMath;
import Paths;

class ArtworkSubstate extends FlxSubState {

    var targetX:Float;
    var targetY:Float;
    var scale:Float;

    var bg:FlxSprite;
    var artImage:FlxSprite;
    var artName:FlxText;
    var artDesc:FlxText;

    public var curIndex:Int = 0; 
    public var currentWeek:String; 

    public function new(week:String) {
        super();
        currentWeek = week;
        persistentUpdate = true;
        persistentDraw = true;
    }

    // Tableau qui gère les data des artwork, si néssesaire, copié collé une ligne et modiffier la
    var artworks:Array<{name:String, path:String, desc:String}> = [
        { name: "Poster Placeholder", path: "artworks/placeholder", desc: "Un pur test comme les autres." }, // 0 Default
        { name: "Pixel Brothers", path: "artworks/HOW_TO_PLAY", desc: "Apprenez a raper contre les frères Mario et Luigi !" },
        { name: "Poster Mario", path: "artworks/new_game", desc: "Un classique du jeux rétro !" },
        { name: "Funky Gangsta", path: "artworks/SilvaGunner_Banner", desc: "Tu fous quoi ici ??" } // 3 
    ];

    override function create() {
        super.create();

        // Fond semi-transparent (inutilisé)
        bg = new FlxSprite(Std.int(FlxG.width * 0.65), 0)
            .makeGraphic(Std.int(FlxG.width * 0.35), FlxG.height, FlxColor.fromRGB(0, 0, 0, 0));
        add(bg);

       // Image principale
        artImage = new FlxSprite(bg.x + 60, 180);
        add(artImage);

        // Titre
        artName = new FlxText(bg.x + 25, 150, bg.width - 80, "", 24);
        artName.setFormat(null, 24, FlxColor.WHITE, "center");
        add(artName);

        // Description
        artDesc = new FlxText(bg.x + 25, 540, bg.width - 80, "", 16);
        artDesc.setFormat(null, 16, FlxColor.GRAY, "center");
        add(artDesc);

        // Choisir l'image à afficher selon le song au départ
        updateArtworkForSong(PlayState.SONG.song);
    }

    public function updateArtworkForSong(songName:String):Void {
    curIndex = switch(songName.toLowerCase()) { // assure la casse

        case "how to play": 1; // Pixel Brothers
        case "new game": 2; // Poster Mario
        case "gangstabattle": 3; // Funky Gangsta
        default: 0; // Placeholder
    };
    showArtwork(curIndex);
    }

var isAnimating:Bool = false;
var startX:Float = 0;

public function showArtwork(index:Int):Void {
    var a = artworks[index];

    // Charge l'image
    var path = (a.path == "" || a.path == null) ? "artworks/placeholder" : a.path;
    artImage.loadGraphic(Paths.image(path));

    // Scale et hitbox
    artImage.scale.set(0.33, 0.33);
    artImage.updateHitbox();

    // Centre horizontalement
    artImage.screenCenter();
    artImage.x += 400;

    // Position de départ pour l'animation (depuis la gauche)
    startX = artImage.x; // on garde la position finale
    artImage.x = FlxG.width + artImage.width; // commence complètement à droite
    targetX = startX; // vise la position finale normale

    // Texte
    artName.text = a.name;
    artDesc.text = a.desc;

    // Déclenche l'animation
    isAnimating = true;
}

override function update(elapsed:Float) {
    super.update(elapsed);

    if (isAnimating) {
        // Animation horizontale (lerp sur X)
        artImage.x = FlxMath.lerp(artImage.x, targetX, 0.15);

        // Stop quand on est assez proche
        if (Math.abs(artImage.x - targetX) < 1) {
            artImage.x = targetX;
            isAnimating = false;
        }
    }
}
}
*/