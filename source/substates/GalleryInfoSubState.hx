package substates;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKeyList;
import flixel.sound.FlxSound;
import GalleryImage;
import Paths;
import states.GalleryState;

class GalleryInfoSubState extends FlxSubState {
    var image:GalleryImage;
    var bg:FlxSprite;
    var nameText:FlxText;
    var infoText:FlxText;

    public function new(img:GalleryImage) {
        super();
        image = img;
    }

    override public function create():Void {
        super.create();

        // Fond noir transparent
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x80000000);
        add(bg);

        // Nom de l'image
        nameText = new FlxText(0, FlxG.height / 4, FlxG.width, image.name, 36);
        nameText.setFormat(Paths.font("vcr.ttf"), 36, 0xFFFFFFFF, "center");
        add(nameText);

        // Description ou info (à personnaliser)
        infoText = new FlxText(40, FlxG.height / 2, FlxG.width - 80,
            "Description ou infos supplémentaires sur l'image \"" + image.name + "\".\n" +
            "Couleur dominante hex : 0x" + StringTools.hex(image.color, 6), 24);
        infoText.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, "left");
        add(infoText);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            closeSubState();
            cast(FlxG.state, GalleryState).infoSubState = null;
        }
    }

    public function updateInfo(img:GalleryImage):Void {
        image = img;
        nameText.text = image.name;
        infoText.text = "Description ou infos supplémentaires sur l'image \"" + image.name + "\".\n" +
            "Couleur dominante hex : 0x" + StringTools.hex(image.color, 6);
    }
}