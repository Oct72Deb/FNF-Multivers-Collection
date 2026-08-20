package states;

#if desktop
import Discord.DiscordClient;
#end

import substates.ArtworkSubstate;
import substates.GameplayChangersSubstate;

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
import flixel.util.FlxTimer;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Assets as OpenFlAssets;
import sys.thread.Thread;
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
	var cheatHintText:FlxText;
	static inline var CHEAT_HINT_MESSAGE:String = 'Type "victoire" on your keyboard to reset the score.';
	static inline var CHEAT_SUCCESS_MESSAGE:String = 'Reset completed successfully.';
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	// --- Cheat code pour reset le score (remplace l'ancien sous-menu de confirmation) ---
	var cheatBuffer:String = "";
	static inline var CHEAT_RESET_CODE:String = "victoire";
	// -----------------------------------------------------------------------------------

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	// Debounce pour éviter que les fondus s'empilent quand on scroll vite :
	// on attend un court instant sans changement avant de vraiment charger/fondre le fond
	var bgUpdateTimer:FlxTimer;
	var bgTween:FlxTween; // le fondu du fond actuellement en cours (pour pouvoir l'annuler)
	var pendingNewBg:FlxSprite; // sprite en cours de fondu, pas encore validé comme "bg" final

	// Nom du fond actuellement affiché (sans extension), utilisé pour savoir
	// si on doit charger une nouvelle image ou juste retween la couleur
	var curBgPath:String = 'menuDesat';

	// ==============================================
	// FONDS HARDCODÉS PAR CHANSON
	// Clé = nom de la chanson FORMATÉ, c'est-à-dire le nom du dossier
	// dans data/<musicName>/ et songs/<musicName>/ (même clé que celle
	// utilisée plus bas pour charger l'Inst : Paths.formatToSongPath).
	// En pratique : minuscules, espaces remplacés par des tirets.
	// Valeur = nom du fichier image (sans extension) dans images/ du mod.
	// Ex : "Periple" -> data/periple/ -> clé 'periple' -> HellBG
	// ==============================================
	static var hardcodedBackgrounds:Map<String, String> = [
		'periple' => 'freeplayBG/defaultBG',
		'starlight' => 'freeplayBG/defaultBG',
		'allocution' => 'freeplayBG/allocution',
		'new-game' => 'freeplayBG/new_game',
		// 'nom-de-la-chanson' => 'NomDuFond',
	];

	override function sectionHit()
	{
		super.sectionHit();

		// Annule les tweens précédents pour éviter que ça bug
		FlxTween.cancelTweensOf(FlxG.camera);

		// Petit zoom de l'écran entier
		FlxG.camera.zoom = 1.02;

		// Retour progressif à la taille normale
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {ease: FlxEase.quadOut});
	}

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			// --- Condition custom pour "weekb" ---
						if(WeekData.weeksList[i] == WeekbUnlock.HIDDEN_WEEK_NAME)
			{
				var savedDifficulties:Array<String> = CoolUtil.difficulties; // sauvegarde l'état courant

				if(WeekData.weeksLoaded.exists("weeka"))
				{
					CoolUtil.difficulties = getDifficultiesForWeek(WeekData.weeksLoaded.get("weeka"));
				}

				var unlocked:Bool = WeekbUnlock.isUnlocked(CoolUtil.difficulties.length);

				CoolUtil.difficulties = savedDifficulties; // restaure l'état d'origine

				if(!unlocked) continue;
			}
			// --- Fin condition custom ---

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

				var diffIcons:Map<String, String> = new Map();
				var rawDiffIcons = song[3];
				if(rawDiffIcons != null)
				{
					var fields = Reflect.fields(rawDiffIcons);
					for(f in fields)
					{
						diffIcons.set(f, Reflect.field(rawDiffIcons, f));
					}
				}

				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), diffIcons);
			}
		}
		WeekData.loadTheFirstEnabledMod();

		// Précharge tous les fonds (par défaut + hardcodés) dans le cache d'assets
		// AVANT que le joueur ne puisse scroller. Sans ça, le premier Paths.image()
		// sur un gros PNG se fait au moment du scroll et provoque un hoquet/délai
		// perceptible avant que le fondu ne démarre.
		Paths.image('nglaupokbg');
		for (song in songs)
		{
			Paths.currentModDirectory = song.folder;
			var songKey:String = Paths.formatToSongPath(song.songName);
			var bgName:String = hardcodedBackgrounds.get(songKey);
			if (bgName != null)
				Paths.image(bgName);
		}

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

		// Calcul des chemins sur le thread principal
		var instPaths:Array<String> = [];
		for (song in songs)
		{
			Paths.currentModDirectory = song.folder;
			var songKey:String = Paths.formatToSongPath(song.songName);
			var file:String = Paths.modsSounds('songs', songKey + '/Inst');
			if (sys.FileSystem.exists(file) && !Paths.currentTrackedSounds.exists(file))
				instPaths.push(file);
		}

		// Chargement asynchrone en arrière-plan
		Thread.create(function() {
			for (file in instPaths)
			{
				if (!Paths.currentTrackedSounds.exists(file))
					Paths.currentTrackedSounds.set(file, flash.media.Sound.fromFile(file));
			}
		});

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.0;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		// --- Message d'astuce pour le cheat code de reset (bas droite) ---
		cheatHintText = new FlxText(0, 0, 300, CHEAT_HINT_MESSAGE, 16);
		cheatHintText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		cheatHintText.scrollFactor.set();
		cheatHintText.x = FlxG.width - cheatHintText.width - 10;
		cheatHintText.y = FlxG.height - cheatHintText.height - 10;
		add(cheatHintText);
		// -------------------------------------------------------------

		if(curSelected >= songs.length) curSelected = 0;

		// Applique directement le fond (et la couleur) de la chanson sélectionnée,
		// sans fondu puisqu'on est à l'ouverture du state
		curBgPath = 'menuDesat';
		updateBackground(curSelected, false);
		intendedColor = songs[curSelected].color;

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
		// FIX 1 — On passe songName et curDifficulty au constructeur.
		// openSubState() diffère create() au tick suivant : appeler updateArtworkForSong()
		// ou setDifficulty() ici causerait un Null Object Reference (artImage pas encore créé).
		// ArtworkSubstate.create() applique ces valeurs lui-même en fin d'initialisation.
		openSubState(new substates.ArtworkSubstate(weekName, songs[curSelected].songName, curDifficulty));
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, ?diffIcons:Map<String, String>)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, diffIcons));
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
	var diffPlaying:Int = -1; // difficulté actuellement en lecture
	var instNamePlaying:String = ''; // nom de l'inst actuellement en lecture
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;

	// Convertit l'Int en String pour la difficulté
    public static function difficultyToString(diff:Int):String {
        switch(diff) {
            case 0: return "easy";
            case 1: return "normal";
            case 2: return "hard";
            default: return "normal"; // Valeur par défaut
        }
    }

	// Retourne le nom du personnage/icône selon la difficulté actuelle
	function getIconCharForDiff(songIndex:Int):String
	{
		var song = songs[songIndex];
		var diffName = CoolUtil.difficulties[curDifficulty].toLowerCase().trim();

		if(song.difficultyIcons.exists(diffName))
			return song.difficultyIcons.get(diffName);

		return song.songCharacter; // fallback sur l'icône de base
	}

	// Recharge l'icône d'une entrée de la liste selon la difficulté courante
	function refreshIcon(songIndex:Int):Void
	{
		var icon = iconArray[songIndex];
		var charName = getIconCharForDiff(songIndex);

		Paths.currentModDirectory = songs[songIndex].folder;

		// Réplique exactement la logique de recherche de HealthIcon
		var name:String = 'icons/' + charName;
		if (!Paths.fileExists('images/' + name + '.png', IMAGE))
			name = 'icons/icon-' + charName;
		if (!Paths.fileExists('images/' + name + '.png', IMAGE))
			name = 'icons/face'; // fallback ultime

		// Charge la spritesheet et la découpe en 2 frames (normale + mort)
		var graphic = Paths.image(name);
		icon.loadGraphic(graphic, true, Math.floor(graphic.width / 2), graphic.height);

		// Enregistre et joue l'animation sur la frame 0 (icône normale, pas la mort)
		icon.animation.add(charName, [0, 1], 0, false);
		icon.animation.play(charName);

		icon.antialiasing = ClientPrefs.globalAntialiasing;
		icon.updateHitbox();
	}

	// Point d'entrée appelé à chaque changement de sélection.
	// Debounce : on attend un court instant sans nouveau changement avant de
	// vraiment charger/fondre le fond, pour éviter que les fondus s'empilent
	// quand on scroll vite (le fond "traînait" en retard sur la sélection).
	function updateBackground(index:Int, playTween:Bool = true):Void
	{
		if (bgUpdateTimer != null)
		{
			bgUpdateTimer.cancel();
			bgUpdateTimer = null;
		}

		if (!playTween)
		{
			// Cas de l'ouverture du state : pas de debounce, application directe
			doUpdateBackground(index, false);
			return;
		}

		bgUpdateTimer = new FlxTimer().start(0.06, function(twn:FlxTimer)
		{
			bgUpdateTimer = null;
			doUpdateBackground(index, true);
		});
	}

	function doUpdateBackground(index:Int, playTween:Bool):Void
	{
		var song = songs[index];

		// Priorité 1 : fond hardcodé pour cette chanson (map ci-dessus)
		// Priorité 2 : fond par défaut (le JSON de la week n'est plus consulté)
		// La clé utilisée est la même que celle utilisée pour charger l'Inst
		// (Paths.formatToSongPath), donc le nom du dossier dans data/<musicName>
		var bgPath:String = 'nglaupokbg';
		var songKey:String = Paths.formatToSongPath(song.songName);
		var hardcoded:String = hardcodedBackgrounds.get(songKey);
		if (hardcoded != null)
		{
			bgPath = hardcoded;
		}

		Paths.currentModDirectory = song.folder;
		var graphic = Paths.image(bgPath);

		if(graphic == null)
		{
			// Le fond spécifique n'existe pas (mauvais nom, fichier manquant...), on fallback
			bgPath = 'nglaupokbg';
			graphic = Paths.image(bgPath);
		}

		// Si c'est le même fond que celui déjà affiché, on ne fait que retween la couleur
		if(bgPath == curBgPath)
		{
			if(colorTween != null) colorTween.cancel();
			intendedColor = song.color;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) { colorTween = null; }
			});
			return;
		}

		curBgPath = bgPath;
		intendedColor = song.color;

		if(playTween)
		{
			// Annule un éventuel fondu de fond encore en cours (au cas où deux
			// changements arrivent malgré le debounce) pour éviter l'empilement
			// de sprites/tweens qui causait le décalage
			if (bgTween != null)
			{
				bgTween.cancel();
				bgTween = null;
			}
			if (pendingNewBg != null)
			{
				remove(pendingNewBg, true);
				pendingNewBg.destroy();
				pendingNewBg = null;
			}

			var newBg:FlxSprite = new FlxSprite().loadGraphic(graphic);
			newBg.antialiasing = ClientPrefs.globalAntialiasing;
			newBg.screenCenter();
			newBg.color = song.color;
			newBg.alpha = 0;
			pendingNewBg = newBg;

			// insère le nouveau fond juste AU-DESSUS de l'ancien (index+1) pour
			// qu'il se révèle progressivement par-dessus pendant le fondu,
			// au lieu d'être caché dessous (ce qui donnait l'impression
			// d'un délai puis d'un swap brutal sans fondu visible)
			var oldIndex:Int = members.indexOf(bg);
			insert(oldIndex + 1, newBg);

			if(colorTween != null) colorTween.cancel();

			bgTween = FlxTween.tween(newBg, {alpha: 1}, 0.5, {
				onComplete: function(twn:FlxTween)
				{
					remove(bg, true);
					bg.destroy();
					bg = newBg;
					pendingNewBg = null;
					bgTween = null;
				}
			});
		}
		else
		{
			bg.loadGraphic(graphic);
			bg.screenCenter();
			bg.color = song.color;
		}
	}

	override function update(elapsed:Float)
	{
		checkResetCheatCode();

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

if (instPlaying != curSelected || diffPlaying != curDifficulty)
{
	var baseSongKey:String = Paths.formatToSongPath(songs[curSelected].songName);
	var diffFormattedName:String = Highscore.formatSong(baseSongKey, curDifficulty);

	var targetTrack:String = baseSongKey;
	var loadedSong:Dynamic = null;

	try {
		loadedSong = Song.loadFromJson(diffFormattedName, baseSongKey);
		if (loadedSong != null && loadedSong.song != null) {
			targetTrack = Paths.formatToSongPath(loadedSong.song);
		}
	} catch(e:Dynamic) {
		loadedSong = null;
	}

var diffSuffix:String = Paths.songDiffSuffix(loadedSong, curDifficulty);
var actualInstSuffix:String = Paths.resolveDiffSuffix(targetTrack, 'Inst', diffSuffix);
var trackKey:String = targetTrack + actualInstSuffix; // clé basée sur le fichier RÉELLEMENT joué

if (trackKey != instNamePlaying)
{
	FlxG.sound.music.volume = 0;
	FlxG.sound.playMusic(Paths.inst(targetTrack, diffSuffix), 0);
	instNamePlaying = trackKey;

		if (targetTrack == "new game" || targetTrack == "new-game")
			FlxG.sound.music.time = 23170;
		if (targetTrack == "metal reflection" || targetTrack == "metal-reflection")
			FlxG.sound.music.time = 7500;

		var bpm:Int = (loadedSong != null) ? Std.int(loadedSong.bpm) : 120;
		PlayState.SONG = loadedSong != null ? loadedSong : cast { song: targetTrack, notes: [], bpm: bpm };

		Conductor.changeBPM(bpm);
		Conductor.mapBPMChanges(PlayState.SONG);

		curStep = 0;
		curBeat = 0;
		curDecStep = 0;
		curDecBeat = 0;
		curSection = 0;
		stepsToDo = 0;
	}

			if (subState != null && Std.isOfType(subState, ArtworkSubstate)) {
				var artSub:ArtworkSubstate = cast(subState, ArtworkSubstate);
				artSub.updateArtworkForSong(songs[curSelected].songName);
			}

			instPlaying = curSelected;
			diffPlaying = curDifficulty;
		}
		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.actualSongName = songLowercase; // On mémorise le nom original

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
		// --- TON CODE AJOUTÉ ICI ---
		// Ancien système (sous-menu "Yes/No") remplacé par un cheat code (voir checkResetCheatCode()).
		// ---------------------------

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

	// Notifie ArtworkSubstate du changement de difficulte
	function notifyArtworkDifficulty():Void {
		if (subState != null && Std.isOfType(subState, ArtworkSubstate)) {
			var artSub:ArtworkSubstate = cast(subState, ArtworkSubstate);
			artSub.setDifficulty(curDifficulty);
		}
	}
// Reproduit la logique de parsing de "difficulties" utilisée dans changeSelection(),
	// pour compter le nombre de difficultés propres à une week donnée (ici "weeka").
function getDifficultiesForWeek(week:WeekData):Array<String>
	{
		var diffs:Array<String> = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = week.difficulties;
		if(diffStr != null) diffStr = diffStr.trim();

		if(diffStr != null && diffStr.length > 0)
		{
			var parsed:Array<String> = diffStr.split(',');
			var i:Int = parsed.length - 1;
			while (i > 0)
			{
				if(parsed[i] != null)
				{
					parsed[i] = parsed[i].trim();
					if(parsed[i].length < 1) parsed.remove(parsed[i]);
				}
				--i;
			}

			if(parsed.length > 0 && parsed[0].length > 0)
				diffs = parsed;
		}

		return diffs;
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
		notifyArtworkDifficulty();

		refreshIcon(curSelected); // Mise à jour de l'icône selon la difficulté
	}

	/**
	 * Ecoute les touches tapées au clavier et compare le buffer avec le cheat code
	 * "niveau3". Si il correspond, reset direct du score de la chanson sélectionnée,
	 * sans passer par un sous-menu de confirmation.
	 */
	function checkResetCheatCode():Void
	{
		var pressedKey:FlxKey = FlxG.keys.firstJustPressed();
		if (pressedKey == FlxKey.NONE)
			return;

		var c:String = keyToChar(pressedKey);
		if (c == null)
			return;

		cheatBuffer += c;
		// On ne garde que les derniers caractères utiles pour comparer au code
		if (cheatBuffer.length > CHEAT_RESET_CODE.length)
			cheatBuffer = cheatBuffer.substr(cheatBuffer.length - CHEAT_RESET_CODE.length);

		if (cheatBuffer == CHEAT_RESET_CODE)
		{
			Highscore.resetSong(songs[curSelected].songName, curDifficulty);

			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
			#end

			FlxG.sound.play(Paths.sound('victoire'), 0.3);
			cheatBuffer = "";

			// Affiche le message de confirmation, puis revient au message d'astuce
			cheatHintText.text = CHEAT_SUCCESS_MESSAGE;
			cheatHintText.x = FlxG.width - cheatHintText.width - 10;
			cheatHintText.y = FlxG.height - cheatHintText.height - 10;
			new FlxTimer().start(2, function(_)
			{
				cheatHintText.text = CHEAT_HINT_MESSAGE;
				cheatHintText.x = FlxG.width - cheatHintText.width - 10;
				cheatHintText.y = FlxG.height - cheatHintText.height - 10;
			});
		}
	}

	/**
	 * Convertit une touche clavier (lettre ou chiffre) en caractère minuscule.
	 * Retourne null si la touche ne fait pas partie de l'alphabet/chiffres.
	 */
	function keyToChar(key:FlxKey):String
	{
		return switch (key)
		{
			case A: "a"; case B: "b"; case C: "c"; case D: "d"; case E: "e";
			case F: "f"; case G: "g"; case H: "h"; case I: "i"; case J: "j";
			case K: "k"; case L: "l"; case M: "m"; case N: "n"; case O: "o";
			case P: "p"; case Q: "q"; case R: "r"; case S: "s"; case T: "t";
			case U: "u"; case V: "v"; case W: "w"; case X: "x"; case Y: "y";
			case Z: "z";
			case ZERO, NUMPADZERO: "0";
			case ONE, NUMPADONE: "1";
			case TWO, NUMPADTWO: "2";
			case THREE, NUMPADTHREE: "3";
			case FOUR, NUMPADFOUR: "4";
			case FIVE, NUMPADFIVE: "5";
			case SIX, NUMPADSIX: "6";
			case SEVEN, NUMPADSEVEN: "7";
			case EIGHT, NUMPADEIGHT: "8";
			case NINE, NUMPADNINE: "9";
			default: null;
		}
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// Met à jour le fond (image + couleur) selon la nouvelle chanson sélectionnée
		updateBackground(curSelected, true);

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
	public var difficultyIcons:Map<String, String> = new Map(); // Icônes par difficulté

	public function new(song:String, week:Int, songCharacter:String, color:Int, ?diffIcons:Map<String, String>)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
		if(diffIcons != null) this.difficultyIcons = diffIcons;
	}
}