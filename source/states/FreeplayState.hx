package states;

#if desktop
import Discord.DiscordClient;
#end

import substates.ArtworkSubstate;
import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import PlayState;
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var prewiewInst:FlxSound;
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	
	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

override function sectionHit()
{
    super.sectionHit();

    // Annule les tweens précédents pour éviter que ça bug
    FlxTween.cancelTweensOf(FlxG.camera);

    // Petit zoom de l’écran entier
    FlxG.camera.zoom = 1.02;

    // Retour progressif à la taille normale
    FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {ease: FlxEase.quadOut});
}

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

for (i in 0...songs.length)
{
    var spacing = 0; // essaie 80 ou 100 selon ton goût
	var songText:Alphabet = new Alphabet(60, 300 + (i * spacing), songs[i].songName, true);
    songText.isMenuItem = true;
    songText.targetY = i - curSelected;
    grpSongs.add(songText);

    var maxWidth = 600;
    if (songText.width > maxWidth)
    {
        songText.scaleX = maxWidth / songText.width;
    }
    songText.snapToPosition();

    Paths.currentModDirectory = songs[i].folder;
    var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
    icon.sprTracker = songText;

    // using a FlxGroup is too much fuss!
    iconArray.push(icon);
    add(icon);

    // songText.x += 40;
    // DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
    // songText.screenCenter(X);
}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
		
		FlxG.mouse.visible = true;

		// Ces deux lignes rendent le Freeplay capable de continuer à tourner
		// pendant que ton substate est affiché
		persistentUpdate = true;
		persistentDraw = true;
		var weekName:String = WeekData.weeksList[songs[curSelected].week];
		openSubState(new substates.ArtworkSubstate(weekName));
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}


	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/
// 
	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;

	// Convertit l'Int en String pour la difficulté
    public static function difficultyToString(diff:Int):String {
        switch(diff) {
            case 0: return "easy";
            case 1: return "normal";
            case 2: return "hard";
			case 3: return "erect";
			case 4: return "nightmare";
            default: return "normal"; // Valeur par défaut
        }
    }

override function update(elapsed:Float)
{
    if (FlxG.sound.music.volume < 0.7)
    {
        FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
    }

    lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
    lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

    if (Math.abs(lerpScore - intendedScore) <= 10)
        lerpScore = intendedScore;
    if (Math.abs(lerpRating - intendedRating) <= 0.01)
        lerpRating = intendedRating;

    var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
    if(ratingSplit.length < 2) { //No decimals, add an empty space
        ratingSplit.push('');
    }
    
    while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
        ratingSplit[1] += '0';
    }

    scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
    positionHighscore();

    var upP = controls.UI_UP_P;
    var downP = controls.UI_DOWN_P;
    var accepted = controls.ACCEPT;
    var ctrl = FlxG.keys.justPressed.CONTROL;

    var shiftMult:Int = 1;
    if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

    if(songs.length > 1)
    {
        if (upP)
        {
            changeSelection(-shiftMult);
            holdTime = 0;
        }
        if (downP)
        {
            changeSelection(shiftMult);
            holdTime = 0;
        }

        if(controls.UI_DOWN || controls.UI_UP)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
            {
                changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
                changeDiff();
            }
        }

        if(FlxG.mouse.wheel != 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
            changeSelection(-shiftMult * FlxG.mouse.wheel, false);
            changeDiff();
        }
    }

    if (controls.UI_LEFT_P)
        changeDiff(-1);
    else if (controls.UI_RIGHT_P)
        changeDiff(1);
    else if (upP || downP) changeDiff();

    if (controls.BACK)
    {
        persistentUpdate = false;
        if(colorTween != null) {
            colorTween.cancel();
        }
        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new MainMenuState());
        FlxG.sound.music.stop();
        FlxG.sound.playMusic(Paths.music('freakymenu'), 0.5);
    }

    if(ctrl)
    {
        persistentUpdate = false;
        openSubState(new GameplayChangersSubstate());
    }

    if (instPlaying != curSelected)
    {
        FlxG.sound.music.volume = 0;

        var songKey:String = songs[curSelected].songName.toLowerCase();
        var formattedSong:String = Highscore.formatSong(songKey, curDifficulty);

        try
        {
            PlayState.SONG = Song.loadFromJson(formattedSong, songKey);
            FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0);

            if (songKey == "new game" || songKey == "new-game") {
                FlxG.sound.music.time = 23170;
            }
			if (songKey == "metal reflection" || songKey == "metal-reflection") {
                FlxG.sound.music.time = 7500;
            }
            if (songKey == "periple" || songKey == "periple") {
                FlxG.sound.music.time = 17670;
            }
				// 🔥 On met à jour le BPM du Conductor
				Conductor.changeBPM(PlayState.SONG.bpm);

				if (subState != null && Std.is(subState, ArtworkSubstate)) {
				var artSub:ArtworkSubstate = cast(subState, ArtworkSubstate);

				// Vérifie si la sélection a changé
				if (curSelected != instPlaying) {

				artSub.updateArtworkForSong(songs[curSelected].songName);
				instPlaying = curSelected; // met à jour l’indicateur après changement
				}
			}
        }
		// évite les crash du jeux qui fais vraiment chier, surtout quand ta que sa à foutre de relancé le jeux
        catch (e:Dynamic)
		{
			trace("Erreur lors du chargement de la chanson : " + e);

			var errorText = new FlxText(0, 0, FlxG.width,
				"Impossible de charger :\n" + songs[curSelected].songName);
			errorText.setFormat(null, 16, 0xFFFF0000, "center");
			add(errorText);

			FlxTween.tween(errorText, { alpha: 0 }, 2, { onComplete: function(t) { remove(errorText); } });

			// NE PAS toucher à subState ici
		}
    }
    else if (accepted)
    {
        persistentUpdate = false;
        var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
        var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

        PlayState.SONG = Song.loadFromJson(poop, songLowercase);
        PlayState.isStoryMode = false;
        PlayState.storyDifficulty = curDifficulty;

        if(colorTween != null) {
            colorTween.cancel();
        }

        if (FlxG.keys.pressed.SHIFT){
            LoadingState.loadAndSwitchState(new ChartingState());
        }else{
            LoadingState.loadAndSwitchState(new PlayState());
        }

        FlxG.sound.music.volume = 0;
        destroyFreeplayVocals();
    }
    else if(controls.RESET)
    {
        persistentUpdate = false;
        openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    // ✅ Synchronisation du Conductor avec la musique
    if (FlxG.sound.music != null)
    {
        Conductor.songPosition = FlxG.sound.music.time;
    }

    super.update(elapsed);
}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}