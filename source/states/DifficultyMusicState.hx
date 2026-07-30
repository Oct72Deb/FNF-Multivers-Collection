package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import PlayState;
import Song;
import CoolUtil;

class DifficultyMusicState extends FlxState
{
    public var nextSong:String;
    public var weekName:String;

    var difficultyChoices:Array<String> = [];
    var curSelected:Int = 0;
    var texts:Array<FlxText> = [];
    var bg:FlxSprite;

    public function new(nextSong:String, weekName:String)
    {
        super();
        this.nextSong = nextSong;
        this.weekName = weekName;

        for (diff in CoolUtil.difficulties)
            difficultyChoices.push(diff);
    }

    override public function create():Void
    {
        super.create();

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);
        FlxTween.tween(bg, { alpha:0.7 }, 0.4, { ease: FlxEase.quartInOut });

        var title:FlxText = new FlxText(0, 50, FlxG.width, "Choisis la difficulté pour " + weekName);
        title.setFormat(null, 24, FlxColor.WHITE, "center");
        add(title);

        for (i in 0...difficultyChoices.length)
        {
            var txt:FlxText = new FlxText(0, 120 + i*40, FlxG.width, difficultyChoices[i].toUpperCase());
            txt.setFormat(null, 20, FlxColor.WHITE, "center");
            add(txt);
            texts.push(txt);
        }

        curSelected = 1; // par défaut NORMAL si l'index correspond à ta config
        updateSelection();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.UP) curSelected--;
        if (FlxG.keys.justPressed.DOWN) curSelected++;
        if (curSelected < 0) curSelected = difficultyChoices.length - 1;
        if (curSelected >= difficultyChoices.length) curSelected = 0;

        updateSelection();

        if (FlxG.keys.justPressed.ENTER)
        {
            // Applique la difficulté choisie pour la première musique
            var diff:String = difficultyChoices[curSelected].toLowerCase();
            var songName = nextSong;
            if (diff != "normal") songName += "-" + diff;

            PlayState.storyDifficulty = curSelected;
            PlayState.SONG = Song.loadFromJson(songName, nextSong);

            // Lance le PlayState avec la musique choisie
            FlxG.switchState(new PlayState());
        }

        if (FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new PlayState()); // retour rapide sans changement
        }
    }

    private function updateSelection():Void
    {
        for (i in 0...texts.length)
            texts[i].color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
    }
}