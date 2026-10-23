package states;

#if desktop
import Discord.DiscordClient;
#end

import substates.ArtworkSubstate;
import substates.GameplayChangersSubstate;

import PlayState;
import editors.ChartingState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSpriteUtil;
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
	var missesText:FlxText;
	var rankText:FlxText;
	var cheatHintText:FlxText;
	var cheatHintBg:FlxSprite;
	static inline var CHEAT_HINT_PAD:Float = 8; // marge autour du texte pour le fond
	static inline var CHEAT_HINT_GAP:Float = 12; // espace libre entre le message et le bas de la colonne poster / difficultés / barre
	// Bas de la colonne de droite d'ArtworkSubstate : haut du fond du message "victoire" moins CHEAT_HINT_GAP.
	// Renseigné par setCheatHintMessage() (donc avant l'ouverture du substate) ; 0 = pas encore calculé.
	public static var columnBottomY:Float = 0;

	// -----------------------------------------------------------------------

	// --- Marge d'écran commune ---------------------------------------------------------
	// Une seule marge d'écran pour les checkboxes Practice Mode / Botplay (haut / gauche) et la colonne
	// poster / difficultés / barre d'ArtworkSubstate (côté droit) : pas de coordonnées indépendantes.
	public static inline var SCREEN_MARGIN:Float = 30;
	static inline var SONG_UNSELECTED_ALPHA:Float = 0.35; // opacité des musiques (titre + icône) non sélectionnées (avant : 0.6)
	static inline var SONG_VISIBLE_RANGE:Int = 1;         // nombre de musiques affichées au-dessus ET au-dessous de la sélection (1 = précédente + suivante) ; les autres sont masquées
	static inline var SONG_FADE_SPEED:Float = 20;         // vitesse du fondu des titres / icônes qui apparaissent ou disparaissent
	var songAlphaSnapped:Bool = false;                    // true une fois les opacités initiales appliquées (pas de fondu au premier affichage)

	// --- Graphiques de difficulté (images/menudifficulties/<difficulté>.png) -------------
	// Comme dans le Story Mode : SEULE la difficulté actuelle est affichée (SOUS LA BARRE DE DIFFICULTÉ, colonne de
	// droite d'ArtworkSubstate : poster -> barre -> graphique), centrée sur l'axe de la colonne, avec en dessous une
	// rangée de POINTS (un par difficulté disponible, celui de la difficulté actuelle en cyan, les autres en blanc),
	// et les deux FLÈCHES bleues de chaque côté (mêmes sprites / animations que le Story Mode).
	// Au changement de difficulté, l'ancien graphique s'efface et le nouveau apparaît au même endroit.
	var diffGraphicsGroup:FlxTypedGroup<DiffMenuItem>;
	var diffItems:Array<DiffMenuItem> = [];       // graphiques actuellement affichés (1 par difficulté)
	var dyingDiffItems:Array<DiffMenuItem> = [];  // anciens graphiques en train de disparaître en fondu
	var diffGraphicsKey:String = '';              // identifie la liste affichée (évite de tout recréer pour rien)
	var diffDotsGroup:FlxTypedGroup<FlxSprite>;   // points sous le graphique : un par difficulté disponible
	var diffArrowLeft:FlxSprite;                  // flèches bleues de part et d'autre du graphique (comme le Story Mode)
	var diffArrowRight:FlxSprite;
	var lastShownDifficulty:Int = -1;
	// Position et largeur de la zone : calculées par ArtworkSubstate.layoutColumn() et recopiées ici par
	// syncDiffZone() (aucune coordonnée en dur). Tant que le substate n'a pas fini son create(), rien n'est affiché.
	var diffZoneReady:Bool = false;
	var diffZoneCX:Float = 0;        // axe vertical de la colonne (centre de la zone)
	var diffZoneTop:Float = 0;       // haut de la zone (sous la barre de difficulté)
	var diffZoneHeight:Float = DIFF_ZONE_HEIGHT;  // hauteur de la zone, recopiée d'ArtworkSubstate
	var diffZoneWidth:Float = 320;   // largeur TOTALE de la zone (px) = largeur de la colonne du poster
	public static inline var DIFF_ZONE_HEIGHT:Float = 180;  // hauteur FIXE de la zone sous la barre (si plusieurs lignes, tout est réduit pour tenir) ; lue par ArtworkSubstate
	static inline var DIFF_SELECTOR_SCALE:Float = 0.8;   // échelle du graphique par rapport à sa taille d'origine (même valeur que le Story Mode)
	static inline var DIFF_SLOT_HEIGHT:Float = 80;       // hauteur FIXE de l'emplacement du graphique (px) : les points restent alignés quelle que soit l'image
	static inline var DIFF_ARROW_GAP:Float = 10;         // espace entre le graphique et chaque flèche (comme le Story Mode)
	static inline var DIFF_DOTS_DROP:Float = 14;         // espace entre l'emplacement du graphique et les points
	static inline var DIFF_DOT_SIZE:Float = 7;           // diamètre d'un point (comme le Story Mode)
	static inline var DIFF_DOT_SPACING:Float = 6;        // espace entre deux points (comme le Story Mode)
	static inline var DIFF_DROP:Float = 15;              // le nouveau graphique descend de ce nombre de px en apparaissant (comme le Story Mode)
	static inline var DIFF_IN_SPEED:Float = 22;          // vitesse de l'apparition du nouveau graphique (plus grand = plus rapide)
	static inline var DIFF_SLIDE_X:Float = 60;           // distance du glissement d'entrée / sortie (depuis / vers la gauche) lors d'un changement de liste

	// Dossier de graphiques par défaut, et dossiers spécifiques à certaines Weeks (nom du fichier de
	// la week en minuscules -> sous-dossier de menudifficulties). Pour ajouter une autre week, ajoute une ligne.
	static inline var DIFF_FOLDER_DEFAULT:String = 'menudifficulties';
	static inline var DIFF_FOLDER_FREEPLAY:String = 'menudifficulties/freeplay'; // dossier PRIORITAIRE pour toutes les weeks sans dossier spécifique
	static final DIFF_WEEK_FOLDERS:Map<String, String> = [
		"weeka" => "smash"   // images/menudifficulties/smash/<difficulté>.png
	];

	// ------------------------------------------------------------------------------------
	static inline var CHEAT_HINT_MESSAGE:String = 'Type "victoire" on your keyboard to reset the score.';
	static inline var CHEAT_SUCCESS_MESSAGE:String = 'Reset completed successfully.';
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var intendedMisses:Int = 0;
	var intendedRank:String = '';

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
	var bgFadingLayers:Array<FlxSprite> = []; // couches de fond en cours de fondu (de la plus ancienne à la plus récente)
	var bgLookupCache:Map<String, String> = new Map(); // résultats de findSongBackground() (évite de refaire les tests de fichiers à chaque scroll) ; '' = aucun fond trouvé

	// Nom du fond actuellement affiché (sans extension), utilisé pour savoir
	// si on doit charger une nouvelle image ou juste retween la couleur
	var curBgPath:String = 'menuDesat';

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

		// Coupe la musique du menu principal en arrivant dans le Freeplay
		// (sauf si un fondu de sortie de chanson est en cours : on le laisse finir)
		if (FlxG.sound.music != null && (FlxG.sound.music.fadeTween == null || FlxG.sound.music.fadeTween.finished))
			FlxG.sound.music.stop();

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

				// 5e élément optionnel : liste de difficultés propre à CETTE chanson
				// (même format que week.difficulties : "Easy,Normal,Hard,Erect,..."),
				// utilisée uniquement en Freeplay. Si absent, on retombe sur
				// week.difficulties (donc Easy/Normal/Hard par défaut).
				var songDifficulties:String = null;
				if(song.length > 4 && song[4] != null)
				{
					songDifficulties = Std.string(song[4]);
				}

				// 6e élément optionnel : couleur de fond PAR DIFFICULTÉ, au format
				// { "hard": [255, 0, 0], "erect": [10, 20, 30] } (clé = nom de la difficulté en minuscules).
				// Si une difficulté n'y figure pas, la couleur de la chanson (3e élément) est utilisée.
				var diffColors:Map<String, Int> = new Map();
				var rawDiffColors:Dynamic = (song.length > 5) ? song[5] : null;
				if(rawDiffColors != null)
				{
					for(f in Reflect.fields(rawDiffColors))
					{
						var c:Array<Int> = Reflect.field(rawDiffColors, f);
						if(c != null && c.length >= 3)
							diffColors.set(f.toLowerCase().trim(), FlxColor.fromRGB(c[0], c[1], c[2]));
					}
				}

				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), diffIcons, songDifficulties, diffColors);
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
			// Fond de base (sans difficulté) puis un fond par difficulté possible de la chanson
			var diffNames:Array<String> = getSongDifficultyNames(song);
			diffNames.unshift(null);
			for (diffName in diffNames)
			{
				var bgName:String = findSongBackground(song, diffName);
				if (bgName != null)
					Paths.image(bgName);
			}
		}

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

		// --- Nombre de misses sur la musique sélectionnée (la difficulté n'a plus de texte :
		// elle est affichée par les graphiques de menudifficulties, voir updateDifficultyGraphics) ---
		missesText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		missesText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
		add(missesText);

		// --- Rang obtenu sur la musique sélectionnée (SFC, GFC, etc.), collé à droite ---
		rankText = new FlxText(scoreText.x, missesText.y, 0, "", 24);
		rankText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
		add(rankText);
		// -----------------------------------------------------

		diffGraphicsGroup = new FlxTypedGroup<DiffMenuItem>();
		add(diffGraphicsGroup);

		diffDotsGroup = new FlxTypedGroup<FlxSprite>();
		add(diffDotsGroup);

		// Flèches du sélecteur de difficulté : même atlas et mêmes animations que le Story Mode.
		// Cachées tant que la zone sous le poster n'est pas connue (placées par placeDiffArrows()).
		var uiTex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		diffArrowRight = new FlxSprite(0, 0);
		diffArrowRight.frames = uiTex;
		diffArrowRight.animation.addByPrefix('idle', 'arrow right');
		diffArrowRight.animation.addByPrefix('press', 'arrow push right', 24, false);
		diffArrowRight.animation.play('idle');
		diffArrowRight.antialiasing = ClientPrefs.globalAntialiasing;
		diffArrowRight.scale.set(DIFF_SELECTOR_SCALE, DIFF_SELECTOR_SCALE);
		diffArrowRight.updateHitbox();
		diffArrowRight.visible = false;
		add(diffArrowRight);

		diffArrowLeft = new FlxSprite(0, 0);
		diffArrowLeft.frames = uiTex;
		diffArrowLeft.animation.addByPrefix('idle', 'arrow left');
		diffArrowLeft.animation.addByPrefix('press', 'arrow push left');
		diffArrowLeft.animation.play('idle');
		diffArrowLeft.antialiasing = ClientPrefs.globalAntialiasing;
		diffArrowLeft.scale.set(DIFF_SELECTOR_SCALE, DIFF_SELECTOR_SCALE);
		diffArrowLeft.updateHitbox();
		diffArrowLeft.visible = false;
		add(diffArrowLeft);

		add(scoreText);

		// --- Message d'astuce pour le cheat code de reset (bas droite) ---
		cheatHintBg = new FlxSprite();
		cheatHintBg.scrollFactor.set();
		add(cheatHintBg);

		cheatHintText = new FlxText(0, 0, 0, CHEAT_HINT_MESSAGE, 13);
		cheatHintText.setFormat(Paths.font("vcr.ttf"), 13, FlxColor.WHITE, RIGHT);
		cheatHintText.scrollFactor.set();
		add(cheatHintText);

		setCheatHintMessage(CHEAT_HINT_MESSAGE);
		// -------------------------------------------------------------

		if(curSelected >= songs.length) curSelected = 0;

		// Applique directement le fond (et la couleur) de la chanson sélectionnée,
		// sans fondu puisqu'on est à l'ouverture du state
		curBgPath = 'menuDesat';
		updateBackground(curSelected, false);
		intendedColor = getSongColor(songs[curSelected]);

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		changeSelection();
		changeDiff();

		// La difficulté est maintenant connue : on réapplique le fond (au cas où il en existe un
		// propre à cette difficulté), directement et sans fondu puisqu'on est à l'ouverture du state
		updateBackground(curSelected, false);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

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
		openSubState(new substates.ArtworkSubstate(weekName, songs[curSelected].songName, curDifficulty, getSongColor(songs[curSelected])));
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, ?diffIcons:Map<String, String>, ?songDifficulties:String, ?diffColors:Map<String, Int>)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, diffIcons, songDifficulties, diffColors));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/**
	 * Retourne la liste des noms de toutes les chansons actuellement débloquées / accessibles
	 * en Freeplay, en reproduisant exactement la logique de construction du menu dans create().
	 * Utilisée par GalleryState pour savoir quelles musiques doivent être complétées avant de
	 * débloquer la galerie, sans dépendre d'une instance de FreeplayState déjà créée.
	 */
	public static function getFreeplaySongNames():Array<String>
	{
		var result:Array<String> = [];

		WeekData.reloadWeekFiles(false);

		for (i in 0...WeekData.weeksList.length)
		{
			var weekName:String = WeekData.weeksList[i];
			var leWeek:WeekData = WeekData.weeksLoaded.get(weekName);

			// Même condition de verrouillage que weekIsLocked()
			var locked:Bool = (!leWeek.startUnlocked && leWeek.weekBefore.length > 0
				&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
			if (locked) continue;

			// Même condition custom que pour la week cachée ("weekb")
			if (weekName == WeekbUnlock.HIDDEN_WEEK_NAME)
			{
				var savedDifficulties:Array<String> = CoolUtil.difficulties;

				if (WeekData.weeksLoaded.exists("weeka"))
				{
					var diffStr:String = WeekData.weeksLoaded.get("weeka").difficulties;
					var diffs:Array<String> = CoolUtil.defaultDifficulties.copy();
					if (diffStr != null && diffStr.trim().length > 0)
						diffs = diffStr.split(",");
					CoolUtil.difficulties = diffs;
				}

				var unlocked:Bool = WeekbUnlock.isUnlocked(CoolUtil.difficulties.length);
				CoolUtil.difficulties = savedDifficulties;

				if (!unlocked) continue;
			}

			for (song in leWeek.songs)
			{
				result.push(song[0]);
			}
		}

		return result;
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
	var lastMusicTime:Float = 0; // sert à détecter le bouclage de l'inst (le temps retombe brutalement vers 0)

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
	// (forceDefault = true : remet l'icône par défaut de la chanson, sans tenir compte de la difficulté)
	function refreshIcon(songIndex:Int, forceDefault:Bool = false):Void
	{
		var icon = iconArray[songIndex];
		var charName = forceDefault ? songs[songIndex].songCharacter : getIconCharForDiff(songIndex);

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

	// Dossier (dans images/ du mod) où le jeu cherche automatiquement un fond par chanson.
	static inline var AUTO_BG_FOLDER:String = 'freeplay/freeplayBG/';

	// Liste toutes les difficultés possibles d'une chanson (celles de la chanson, celles de sa week, et les
	// difficultés par défaut). Sert au préchargement des fonds par difficulté.
	function getSongDifficultyNames(song:SongMetadata):Array<String>
	{
		var names:Array<String> = CoolUtil.defaultDifficulties.copy();
		var sources:Array<String> = [song.difficulties];

		var weekFileName:String = WeekData.weeksList[song.week];
		var week:WeekData = (weekFileName != null) ? WeekData.weeksLoaded.get(weekFileName) : null;
		if (week != null) sources.push(week.difficulties);

		for (src in sources)
		{
			if (src == null || src.trim().length < 1) continue;
			for (d in parseDifficultiesString(src))
			{
				if (!names.contains(d)) names.push(d);
			}
		}
		return names;
	}

	// Trouve tout seul le fond d'une chanson, sans aucune liste à maintenir. Il suffit de déposer des images
	// dans images/freeplay/freeplayBG/ du mod :
	//   - <nom>.png              : fond de la chanson (toutes difficultés)
	//   - <nom>-<difficulté>.png : fond propre à une difficulté (ex : periple-hard.png), prioritaire sur le précédent
	// <nom> est essayé dans cet ordre : le nom formaté de la chanson (ex : crash-out), le même avec des _
	// (crash_out), puis le nom brut de la chanson tel qu'écrit dans la week (avec espaces, puis avec des _).
	// diffName = nom de la difficulté (ex : "Hard"), null pour ne chercher que le fond de base.
	// Retourne null si rien n'est trouvé (le fond par défaut sera alors utilisé).
	function findSongBackground(song:SongMetadata, ?diffName:String):String
	{
		var songKey:String = Paths.formatToSongPath(song.songName);
		var diffKey:String = (diffName != null) ? diffName.trim() : '';

		var cacheKey:String = song.folder + '|' + songKey + '|' + diffKey.toLowerCase();
		if (bgLookupCache.exists(cacheKey))
		{
			var cached:String = bgLookupCache.get(cacheKey);
			return (cached == '') ? null : cached;
		}

		Paths.currentModDirectory = song.folder;
		var bases:Array<String> = [
			songKey,
			songKey.replace('-', '_'),
			song.songName,
			song.songName.replace(' ', '_')
		];

		var result:String = null;

		// 1) fond propre à la difficulté : <nom>-<difficulté>.png
		if (diffKey != '')
		{
			var diffVariants:Array<String> = [Paths.formatToSongPath(diffKey), diffKey];
			for (base in bases)
			{
				for (dv in diffVariants)
				{
					if (result == null && Paths.fileExists('images/' + AUTO_BG_FOLDER + base + '-' + dv + '.png', IMAGE))
						result = AUTO_BG_FOLDER + base + '-' + dv;
				}
			}
		}

		// 2) sinon fond de base de la chanson : <nom>.png
		if (result == null)
		{
			for (base in bases)
			{
				if (result == null && Paths.fileExists('images/' + AUTO_BG_FOLDER + base + '.png', IMAGE))
					result = AUTO_BG_FOLDER + base;
			}
		}

		bgLookupCache.set(cacheKey, (result == null) ? '' : result);
		return result;
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

		bgUpdateTimer = new FlxTimer().start(0.03, function(twn:FlxTimer)
		{
			bgUpdateTimer = null;
			doUpdateBackground(index, true);
		});
	}

	// Couleur de fond d'une chanson pour la difficulté ACTUELLE : la couleur propre à la difficulté
	// (6e élément du JSON, réglée dans le Weeks Editor) si elle existe, sinon la couleur de la chanson.
	function getSongColor(song:SongMetadata):Int
	{
		if (curDifficulty >= 0 && curDifficulty < CoolUtil.difficulties.length)
		{
			var key:String = CoolUtil.difficulties[curDifficulty].toLowerCase().trim();
			if (song.difficultyColors.exists(key))
				return song.difficultyColors.get(key);
		}
		return song.color;
	}

	function doUpdateBackground(index:Int, playTween:Bool):Void
	{
		var song = songs[index];
		var targetColor:Int = getSongColor(song);

		// Priorité 1 : fond détecté automatiquement pour la difficulté actuelle (<chanson>-<difficulté>.png)
		// Priorité 2 : fond détecté automatiquement pour la chanson (<chanson>.png)
		// Priorité 3 : fond par défaut (le JSON de la week n'est plus consulté)
		var bgPath:String = 'nglaupokbg';
		var curDiffName:String = (curDifficulty >= 0 && curDifficulty < CoolUtil.difficulties.length) ? CoolUtil.difficulties[curDifficulty] : null;
		var found:String = findSongBackground(song, curDiffName);
		if (found != null)
		{
			bgPath = found;
		}

		Paths.currentModDirectory = song.folder;
		var graphic = Paths.image(bgPath);

		if(graphic == null)
		{
			// Le fond spécifique n'existe pas (mauvais nom, fichier manquant...), on fallback
			bgPath = 'nglaupokbg';
			graphic = Paths.image(bgPath);
		}

		// Couche la plus haute actuellement affichée / en fondu (sinon le fond de base).
		// C'est elle qui représente "le dernier fond demandé".
		var topBg:FlxSprite = (bgFadingLayers.length > 0) ? bgFadingLayers[bgFadingLayers.length - 1] : bg;

		// Si c'est le même fond que celui déjà demandé, on ne fait que retween la couleur
		// (sur la couche du dessus, pas sur l'ancien fond qui est en train de disparaître)
		if(bgPath == curBgPath)
		{
			if(colorTween != null) colorTween.cancel();
			intendedColor = targetColor;
			if(!playTween)
			{
				// Ouverture du state : pas de fondu de couleur
				topBg.color = intendedColor;
				colorTween = null;
				return;
			}
			colorTween = FlxTween.color(topBg, 1, topBg.color, intendedColor, {
				onComplete: function(twn:FlxTween) { colorTween = null; }
			});
			return;
		}

		curBgPath = bgPath;
		intendedColor = targetColor;

		if(playTween)
		{
			// Fondu enchaîné EMPILÉ : on ne détruit plus le fond à moitié fondu quand un nouveau
			// changement arrive (c'était ça qui faisait "sauter" l'image quand on scrolle vite).
			// Chaque nouveau fond démarre à alpha 0 AU-DESSUS de la couche la plus haute et monte
			// à 1 ; les couches en dessous finissent leur propre fondu sans être coupées.
			var newBg:FlxSprite = new FlxSprite().loadGraphic(graphic);
			newBg.antialiasing = ClientPrefs.globalAntialiasing;
			newBg.screenCenter();
			newBg.color = targetColor;
			newBg.alpha = 0;
			bgFadingLayers.push(newBg);
			pendingNewBg = newBg;

			insert(members.indexOf(topBg) + 1, newBg);

			if(colorTween != null) colorTween.cancel();

			bgTween = FlxTween.tween(newBg, {alpha: 1}, 0.38, {
				onComplete: function(twn:FlxTween)
				{
					var idx:Int = bgFadingLayers.indexOf(newBg);
					if (idx == -1) return;

					// newBg est maintenant totalement opaque : tout ce qui est dessous est caché,
					// on peut le libérer sans aucun effet visible.
					for (i in 0...idx)
					{
						var covered:FlxSprite = bgFadingLayers[i];
						FlxTween.cancelTweensOf(covered);
						remove(covered, true);
						covered.destroy();
					}
					bgFadingLayers.splice(0, idx + 1);

					FlxTween.cancelTweensOf(bg);
					remove(bg, true);
					bg.destroy();
					bg = newBg;

					if (pendingNewBg == newBg) pendingNewBg = null;
					if (bgFadingLayers.length == 0) bgTween = null;
				}
			});
		}
		else
		{
			bg.loadGraphic(graphic);
			bg.screenCenter();
			bg.color = targetColor;
		}
	}

	/**
	 * Ouvre l'Inst en STREAMING (même technique que la Gallery) : lime lit et décode le .ogg par
	 * petits morceaux pendant la lecture, au lieu de tout décoder en RAM avant de pouvoir jouer
	 * (ce que fait Sound.fromFile / Paths.returnSound). Démarrage instantané, RAM minimale.
	 * Retourne null si le streaming n'est pas possible (l'appelant utilise alors le cache classique).
	 */
	function loadInstStreamed(instFullKey:String):openfl.media.Sound
	{
		#if (MODS_ALLOWED && lime_vorbis)
		var path:String = Paths.modsSounds('songs', instFullKey);
		if (!FileSystem.exists(path))
		{
			path = Paths.getPath('songs/' + instFullKey + '.ogg', SOUND);
			path = path.substring(path.indexOf(':') + 1);
			if (!FileSystem.exists(path)) return null;
		}

		try {
			var vorbis = lime.media.vorbis.VorbisFile.fromFile(path);
			if (vorbis != null)
			{
				var buffer = lime.media.AudioBuffer.fromVorbisFile(vorbis);
				if (buffer != null) return openfl.media.Sound.fromAudioBuffer(buffer);
			}
		} catch (e:Dynamic) {}
		#end
		return null;
	}

	// Positions de loop personnalisées (en ms) pour certaines insts.
	function getLoopPoint(track:String):Float
	{
		switch (track)
		{
			case "new game" | "new-game":                 return 23170;
			case "crash out" | "crash-out":               return 330;
			case "metal reflection" | "metal-reflection": return 7500;
			default:                                      return 0;
		}
	}

	override function update(elapsed:Float)
	{
		checkResetCheatCode();
		updateSongAlphas(elapsed);

		// ArtworkSubstate.create() est différé d'un tick : dès que la zone sous le poster est connue,
		// on affiche les graphiques de difficulté (voir syncDiffZone()).
		if (!diffZoneReady)
		{
			syncDiffZone();
			if (diffZoneReady) updateDifficultyGraphics();
		}

		var musicFading:Bool = FlxG.sound.music.fadeTween != null && !FlxG.sound.music.fadeTween.finished;
		if (!musicFading && FlxG.sound.music.volume < 0.7)
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

		missesText.text = 'MISSES: ' + intendedMisses;

		var rankStr:String = intendedRank;
		if (rankStr == null || rankStr.length == 0)
			rankStr = '-';
		rankText.text = 'RANK: ' + rankStr;

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

		// Les flèches s'enfoncent tant que la touche est maintenue (comme le Story Mode)
		if (diffArrowRight != null && diffArrowLeft != null)
		{
			diffArrowRight.animation.play(controls.UI_RIGHT ? 'press' : 'idle');
			diffArrowLeft.animation.play(controls.UI_LEFT ? 'press' : 'idle');
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
	var info = resolveInstInfo(curSelected, curDifficulty);
	var targetTrack:String = info.targetTrack;
	var loadedSong:Dynamic = info.loadedSong;
	var diffSuffix:String = info.diffSuffix;
	var trackKey:String = targetTrack + info.actualInstSuffix; // clé basée sur le fichier RÉELLEMENT joué

// On ne considère la sélection comme "réglée" (instPlaying/diffPlaying mis à jour
// à la fin) que si l'inst à jouer est bien prête. Tant qu'elle ne l'est pas, on
// laisse ces variables telles quelles : ce bloc sera retenté au tick suivant, sans
// jamais bloquer le thread principal entre-temps. prefetchNearbyInsts() (appelé
// depuis changeSelection()/changeDiff()) a normalement déjà lancé ce chargement
// bien avant qu'on arrive ici.
var instFullKey:String = info.instFullKey;
// Lecture en STREAMING (comme la Gallery) : le .ogg n'est pas décodé en entier avant de jouer,
// donc le démarrage est instantané. Si le streaming est impossible (fichier introuvable sur le
// disque, build sans lime_vorbis...), on retombe sur l'ancien système basé sur le cache décodé.
var streamedInst:openfl.media.Sound = (trackKey == instNamePlaying) ? null : loadInstStreamed(instFullKey);
var instReady:Bool = (trackKey == instNamePlaying) || streamedInst != null || Paths.isSoundCached('songs', instFullKey);

if (trackKey != instNamePlaying)
{
	if (!instReady)
	{
		// Le fichier n'est pas encore décodé en mémoire : on lance son
		// chargement en tâche de fond et on repasse au tick suivant sans
		// toucher à la musique actuelle (donc sans freeze).
		Paths.cacheSoundAsync('songs', instFullKey);
	}
	else
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
			FlxG.sound.music.fadeTween = null;
		}
		FlxG.sound.music.volume = 0;
		FlxG.sound.playMusic(streamedInst != null ? streamedInst : Paths.inst(targetTrack, diffSuffix), 0);
		instNamePlaying = trackKey;

		// Point de départ ET point de retour à chaque boucle (loopTime).
		// Sans loopTime, FlxSound reboucle toujours à 0 à la fin de la piste.
		var loopPoint:Float = getLoopPoint(targetTrack);
		FlxG.sound.music.time = loopPoint;
		FlxG.sound.music.loopTime = loopPoint;

		var bpm:Int = (loadedSong != null) ? Std.int(loadedSong.bpm) : 120;
		PlayState.SONG = loadedSong != null ? loadedSong : cast { song: targetTrack, notes: [], bpm: bpm };

		Conductor.changeBPM(bpm);
		Conductor.mapBPMChanges(PlayState.SONG);
		Conductor.songPosition = FlxG.sound.music.time;

		curStep = 0;
		curBeat = 0;
		curDecStep = 0;
		curDecBeat = 0;
		curSection = 0;
		stepsToDo = 0;
	}
}

			if (subState != null && Std.isOfType(subState, ArtworkSubstate)) {
				var artSub:ArtworkSubstate = cast(subState, ArtworkSubstate);
				artSub.updateArtworkForSong(songs[curSelected].songName, getSongColor(songs[curSelected]));
				artSub.setAccentColor(getSongColor(songs[curSelected]));
			}

			if (trackKey == instNamePlaying)
			{
				instPlaying = curSelected;
				diffPlaying = curDifficulty;
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
			PlayState.actualSongName = songLowercase; // On mémorise le nom original

			// Nouvelle chanson lancée : le prochain retour au menu principal tirera un nouveau personnage/fond
			MainMenuState.shouldRerollArtwork = true;

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

		// Active le boop uniquement quand l'inst de la selection est lancee (Conductor a jour)
		if (instPlaying == curSelected && diffPlaying == curDifficulty && subState != null && Std.isOfType(subState, ArtworkSubstate))
		{
			var bopSub:ArtworkSubstate = cast(subState, ArtworkSubstate);
			if (!bopSub.bopSynced) bopSub.resyncBop();
		}

		// ✅ Synchronisation du Conductor avec la musique
		if (FlxG.sound.music != null)
		{
			// Détecte le bouclage de l'inst (le temps retombe brutalement vers 0
			// quand FlxSound relance la piste toute seule en fin de lecture).
			// Sans ça, curStep/curBeat restent bloqués sur leur valeur max et
			// stepHit()/beatHit() (donc le boop) ne se redéclenchent plus jamais.
			if (FlxG.sound.music.time < lastMusicTime - 500)
			{
				curStep = 0;
				curBeat = 0;
				curDecStep = 0;
				curDecBeat = 0;
				curSection = 0;
				stepsToDo = 0;
			}
			lastMusicTime = FlxG.sound.music.time;

			Conductor.songPosition = FlxG.sound.music.time;
		}

		super.update(elapsed);

		// Supprime les anciens graphiques de difficulté une fois totalement fondus
		var d:Int = dyingDiffItems.length;
		while (d-- > 0)
		{
			var dead:DiffMenuItem = dyingDiffItems[d];
			if (dead.alpha < 0.02)
			{
				dyingDiffItems.splice(d, 1);
				diffGraphicsGroup.remove(dead, true);
				dead.destroy();
			}
		}
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
			artSub.setAccentColor(getSongColor(songs[curSelected]));
		}
	}
// Reproduit la logique de parsing de "difficulties" utilisée dans changeSelection(),
	// pour compter le nombre de difficultés propres à une week donnée (ici "weeka").
function getDifficultiesForWeek(week:WeekData):Array<String>
	{
		return parseDifficultiesString(week.difficulties);
	}

	// Parse une chaîne "Easy,Normal,Hard,Erect,..." en tableau de difficultés.
	// Retourne CoolUtil.defaultDifficulties si la chaîne est vide/nulle.
	// Utilisée pour les difficultés de Week (compat) ET de chanson (nouveau).
	function parseDifficultiesString(diffStr:String):Array<String>
	{
		var diffs:Array<String> = CoolUtil.defaultDifficulties.copy();
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
		intendedMisses = Highscore.getMisses(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		updateDifficultyDisplay();
		positionHighscore();
		notifyArtworkDifficulty();

		// Fond propre à la difficulté (si une image <chanson>-<difficulté>.png existe) ; sinon rien ne change
		updateBackground(curSelected, true);

		refreshIcon(curSelected); // Mise à jour de l'icône selon la difficulté

		prefetchNearbyInsts();
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
			intendedMisses = Highscore.getMisses(songs[curSelected].songName, curDifficulty);
			intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);
			#end

			FlxG.sound.play(Paths.sound('victoire'), 0.4);
			cheatBuffer = "";

			// Affiche le message de confirmation, puis revient au message d'astuce
			setCheatHintMessage(CHEAT_SUCCESS_MESSAGE);
			new FlxTimer().start(2, function(_)
			{
				setCheatHintMessage(CHEAT_HINT_MESSAGE);
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

	// Opacité cible d'une musique selon sa distance à la sélection : pleine pour la sélectionnée, estompée
	// pour les SONG_VISIBLE_RANGE voisines de chaque côté, nulle au-delà (elles ne gênent plus en haut / en bas).
	function songTargetAlpha(targetY:Float):Float
	{
		var d:Float = Math.abs(targetY);
		if (d < 0.5) return 1;
		if (d <= SONG_VISIBLE_RANGE + 0.5) return SONG_UNSELECTED_ALPHA;
		return 0;
	}

	// Rapproche en douceur l'opacité de chaque titre (et de son icône) de sa valeur cible.
	function updateSongAlphas(elapsed:Float):Void
	{
		if (grpSongs == null) return;
		var t:Float = CoolUtil.boundTo(elapsed * SONG_FADE_SPEED, 0, 1);

		for (i in 0...grpSongs.members.length)
		{
			var item:Alphabet = grpSongs.members[i];
			var a:Float = FlxMath.lerp(item.alpha, songTargetAlpha(item.targetY), t);
			item.alpha = a;
			if (i < iconArray.length) iconArray[i].alpha = a;
		}
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var prevSelected:Int = curSelected;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// La chanson qu'on quitte retrouve son icône par défaut (sinon elle gardait l'icône
		// personnalisée de la difficulté). La nouvelle chanson reçoit la sienne via changeDiff().
		if (prevSelected != curSelected && prevSelected >= 0 && prevSelected < iconArray.length)
			refreshIcon(prevSelected, true);

		// Met à jour le fond (image + couleur) selon la nouvelle chanson sélectionnée
		updateBackground(curSelected, true);

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		intendedMisses = Highscore.getMisses(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		// L'opacité des titres et des icônes (sélection pleine, précédente / suivante estompées, les autres
		// masquées) est gérée en douceur par updateSongAlphas().
		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
		}

		// Premier appel : on applique les opacités tout de suite (sinon tout apparaîtrait en fondu)
		if (!songAlphaSnapped)
		{
			songAlphaSnapped = true;
			updateSongAlphas(1000);
		}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		// Difficultés spécifiques à CETTE chanson en priorité (5e élément du song[] JSON),
		// mais UNIQUEMENT si la Week à laquelle appartient la chanson a déjà été
		// terminée au moins une fois en Story Mode (StoryMenuState.weekCompleted).
		// Tant que ce n'est pas le cas, on retombe sur week.difficulties (donc
		// Easy/Normal/Hard, comme en Story Mode) même si la chanson définit des
		// difficultés supplémentaires.
		var songDiffStr:String = songs[curSelected].difficulties;
		var weekFileName:String = WeekData.weeksList[songs[curSelected].week];
		var weekAlreadyCompleted:Bool = StoryMenuState.weekCompleted.exists(weekFileName) && StoryMenuState.weekCompleted.get(weekFileName);

		if(songDiffStr != null && songDiffStr.trim().length > 0 && weekAlreadyCompleted)
		{
			CoolUtil.difficulties = parseDifficultiesString(songDiffStr);
		}
		else
		{
			CoolUtil.difficulties = parseDifficultiesString(WeekData.getCurrentWeek().difficulties);
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

		updateDifficultyDisplay();

		prefetchNearbyInsts();
	}

	/**
	 * Reproduit la résolution de piste utilisée dans update() (JSON du chart,
	 * remap éventuel du nom de piste, suffixe de difficulté) pour un couple
	 * (index de chanson, index de difficulté) donné. Centralise cette logique
	 * pour que update() ET le préchargement prioritaire restent cohérents.
	 */
	function resolveInstInfo(songIndex:Int, diffIndex:Int):{targetTrack:String, diffSuffix:String, actualInstSuffix:String, instFullKey:String, loadedSong:Dynamic}
	{
		var baseSongKey:String = Paths.formatToSongPath(songs[songIndex].songName);
		var diffFormattedName:String = Highscore.formatSong(baseSongKey, diffIndex);

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

		var diffSuffix:String = Paths.songDiffSuffix(loadedSong, diffIndex);
		var actualInstSuffix:String = Paths.resolveDiffSuffix(targetTrack, 'Inst', diffSuffix);
		var instFullKey:String = targetTrack + '/Inst' + actualInstSuffix;

		return {targetTrack: targetTrack, diffSuffix: diffSuffix, actualInstSuffix: actualInstSuffix, instFullKey: instFullKey, loadedSong: loadedSong};
	}

	/**
	 * Lance en tâche de fond le chargement des Inst de la chanson sélectionnée
	 * et de ses voisines immédiates (précédente/suivante dans la liste), pour
	 * la difficulté courante. Comble le trou du préchargement séquentiel de
	 * create() quand on scrolle vite : le temps qu'on arrive réellement sur
	 * une chanson, son chargement a souvent déjà commencé (voire terminé).
	 * N'a aucun effet si le fichier est déjà en cache ou déjà en cours de
	 * chargement (cacheSoundAsync() s'en charge).
	 */
	function prefetchNearbyInsts():Void
	{
		if (songs.length == 0) return;

		var indices:Array<Int> = [curSelected];
		if (songs.length > 1)
		{
			indices.push((curSelected + 1) % songs.length);
			indices.push((curSelected - 1 + songs.length) % songs.length);
		}

		var savedModDir:String = Paths.currentModDirectory;

		for (i in indices)
		{
			Paths.currentModDirectory = songs[i].folder;
			var info = resolveInstInfo(i, curDifficulty);
			Paths.cacheSoundAsync('songs', info.instFullKey);
		}

		Paths.currentModDirectory = savedModDir;
	}

	/**
	 * Met à jour le texte du message d'astuce/cheat ET repositionne+redimensionne
	 * son fond noir semi-transparent en conséquence (le texte n'a jamais une taille
	 * fixe, donc le fond doit être recalculé à chaque changement de message).
	 */
	private function setCheatHintMessage(msg:String):Void
	{
		cheatHintText.text = msg;
		cheatHintText.x = FlxG.width - cheatHintText.width - 10;
		cheatHintText.y = FlxG.height - cheatHintText.height - 10;

		cheatHintBg.makeGraphic(
			Std.int(cheatHintText.width + CHEAT_HINT_PAD * 2),
			Std.int(cheatHintText.height + CHEAT_HINT_PAD * 2),
			FlxColor.fromRGB(0, 0, 0, 140)
		);
		cheatHintBg.x = cheatHintText.x - CHEAT_HINT_PAD;
		cheatHintBg.y = cheatHintText.y - CHEAT_HINT_PAD;

		columnBottomY = cheatHintBg.y - CHEAT_HINT_GAP;
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);

		// Misses + Rank centrés ensemble (comme un seul bloc), juste sous le score
		// (ils occupent la place de l'ancien texte de difficulté).
		var gap:Float = 20; // espace entre "MISSES: x" et "RANK: y"
		var groupWidth:Float = missesText.width + gap + rankText.width;
		var groupStartX:Float = scoreBG.x + (scoreBG.width / 2) - (groupWidth / 2);

		missesText.x = groupStartX;
		rankText.x = groupStartX + missesText.width + gap;

		missesText.y = scoreText.y + 36;
		rankText.y = missesText.y;

	}

	/**
	 * Met à jour l'affichage de la difficulté (graphiques de menudifficulties) et le bloc
	 * Score / Misses / Rank. Appelée à chaque changement de chanson (changeSelection) et de
	 * difficulté (changeDiff), puisque la liste des difficultés peut varier d'une chanson à l'autre.
	 */
	function updateDifficultyDisplay():Void
	{
		positionHighscore();
		updateDifficultyGraphics();
	}

	// ---------------------------------------------------------------------------------------
	// Graphiques de difficulté
	// ---------------------------------------------------------------------------------------

	// Dossier PRIORITAIRE (relatif à images/) où chercher les graphiques de la chanson sélectionnée :
	//   - Week avec dossier spécifique (voir DIFF_WEEK_FOLDERS, ex: "weeka" -> "menudifficulties/smash") :
	//     ce dossier, comme avant (comportement inchangé).
	//   - Toutes les autres : "menudifficulties/freeplay".
	// Dans les deux cas, createDiffItem() retombe ensuite sur "menudifficulties/" si l'image est absente.
	function getDiffGraphicsFolder():String
	{
		var folder:String = DIFF_FOLDER_FREEPLAY;

		if (curSelected >= 0 && curSelected < songs.length)
		{
			var weekIdx:Int = songs[curSelected].week;
			if (weekIdx >= 0 && weekIdx < WeekData.weeksList.length)
			{
				var weekName:String = WeekData.weeksList[weekIdx].toLowerCase().trim();
				if (DIFF_WEEK_FOLDERS.exists(weekName))
					folder = DIFF_FOLDER_DEFAULT + '/' + DIFF_WEEK_FOLDERS.get(weekName);
			}
		}
		return folder;
	}

	// Charge un graphique de difficulté : atlas animé si un .xml du même nom existe, image fixe sinon.
	function loadDiffGraphic(item:DiffMenuItem, key:String):Void
	{
		if (Paths.fileExists('images/' + key + '.xml', openfl.utils.AssetType.TEXT))
		{
			item.frames = Paths.getSparrowAtlas(key);

			// On déduit le préfixe d'animation depuis le nom de la 1re frame du XML
			// (ex : "night0000" -> "night"), donc rien à écrire en dur.
			var firstName:String = item.frames.frames[0].name;
			var prefix:String = ~/\d+$/.replace(firstName, '');

			item.animation.addByPrefix('idle', prefix, 24, true);
			item.animation.play('idle');
		}
		else
		{
			item.loadGraphic(Paths.image(key));
		}
	}

	// Crée le graphique d'une difficulté : images/<folder>/<difficulté en minuscules>.png
	// (ex: "Very Hard" -> very-hard.png). Ordre de recherche :
	//   1. le dossier prioritaire (menudifficulties/freeplay/, ou menudifficulties/smash/ pour la Week A)
	//   2. le dossier de secours (menudifficulties/)
	//   3. le nom de la difficulté dessiné en texte, pour qu'elle ne disparaisse jamais de la liste.
	function createDiffItem(diffName:String, folder:String):DiffMenuItem
	{
		var item:DiffMenuItem = new DiffMenuItem();
		var fileName:String = Paths.formatToSongPath(diffName.trim());
		var keyWeek:String = folder + '/' + fileName;
		var keyDefault:String = DIFF_FOLDER_DEFAULT + '/' + fileName;

		if (Paths.fileExists('images/' + keyWeek + '.png', openfl.utils.AssetType.IMAGE))
		{
			loadDiffGraphic(item, keyWeek);
		}
		else if (Paths.fileExists('images/' + keyDefault + '.png', openfl.utils.AssetType.IMAGE))
		{
			loadDiffGraphic(item, keyDefault);
		}
		else
		{
			var t:FlxText = new FlxText(0, 0, 0, diffName.toUpperCase(), 32);
			t.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.borderSize = 2;
			item.fallback = true; // pas d'image : voir diffItemScale()
			t.drawFrame(true);
			item.loadGraphic(flixel.graphics.FlxGraphic.fromBitmapData(t.pixels.clone()));
			t.destroy();
		}

		item.antialiasing = ClientPrefs.globalAntialiasing;
		return item;
	}

	// Échelle d'un graphique : DIFF_SELECTOR_SCALE (comme le Story Mode), réduite seulement si l'image
	// dépasse de la zone (largeur) ou de l'emplacement (hauteur). Un texte de secours (image manquante)
	// n'est jamais agrandi.
	function diffItemScale(it:DiffMenuItem):Float
	{
		// la largeur disponible pour le graphique laisse la place des deux flèches (+ leur écart)
		var arrowsW:Float = (diffArrowRight != null) ? 2 * (diffArrowRight.width + DIFF_ARROW_GAP) : 0;
		var fit:Float = Math.min(
			(diffZoneWidth - arrowsW) / Math.max(1, it.frameWidth),
			DIFF_SLOT_HEIGHT / Math.max(1, it.frameHeight));
		return Math.min(it.fallback ? 1 : DIFF_SELECTOR_SCALE, fit);
	}

	// Récupère auprès d'ArtworkSubstate la zone située sous le poster (une seule fois : elle ne change plus).
	function syncDiffZone():Void
	{
		if (diffZoneReady) return;
		if (subState != null && Std.isOfType(subState, ArtworkSubstate))
		{
			var artSub:ArtworkSubstate = cast(subState, ArtworkSubstate);
			if (artSub.diffZoneReady)
			{
				diffZoneCX = artSub.diffZoneCenterX;
				diffZoneTop = artSub.diffZoneTopY;
				diffZoneWidth = artSub.diffZoneWidth;
				diffZoneHeight = artSub.diffZoneHeight;
				diffZoneReady = true;
			}
		}
	}

	// Appelée par updateDifficultyDisplay(), donc à chaque changement de chanson ET de difficulté.
	//  - Si la liste des difficultés (ou le dossier d'images) a changé : l'ancienne ligne glisse vers
	//    la gauche en fondu, la nouvelle arrive depuis la gauche.
	//  - Sinon : on se contente de déplacer la sélection (agrandissement + "pop" + fondu).
	function updateDifficultyGraphics():Void
	{
		if (diffGraphicsGroup == null) return;

		syncDiffZone();
		if (!diffZoneReady) return; // le substate n'a pas encore calculé la zone sous le poster : repris dans update()

		var names:Array<String> = CoolUtil.difficulties;
		var folder:String = getDiffGraphicsFolder();
		var key:String = Paths.currentModDirectory + '|' + folder + '|' + names.join('|');
		var rebuilt:Bool = false;

		if (key != diffGraphicsKey)
		{
			diffGraphicsKey = key;
			rebuilt = true;

			// Les anciens graphiques partent en fondu (supprimés dans update() une fois invisibles)
			for (old in diffItems)
			{
				old.dying = true;
				old.targetAlpha = 0;
				old.targetX -= DIFF_SLIDE_X;
				dyingDiffItems.push(old);
			}
			diffItems = [];

			for (name in names)
			{
				var item:DiffMenuItem = createDiffItem(name, folder);
				item.alpha = 0;
				item.targetAlpha = 0;
				diffGraphicsGroup.add(item);
				diffItems.push(item);
			}

		}

		layoutDifficultyGraphics();

		if (rebuilt)
		{
			// Placement de départ : à la bonne place, décalé à gauche, légèrement plus petit
			for (it in diffItems)
			{
				it.setPosition(it.targetX - DIFF_SLIDE_X - it.frameWidth / 2, it.targetY - it.frameHeight / 2);
				it.scale.set(it.targetScale * 0.9, it.targetScale * 0.9);
			}
		}
		else if (lastShownDifficulty != curDifficulty && curDifficulty >= 0 && curDifficulty < diffItems.length)
		{
			// Comme le Story Mode : l'ancien graphique disparaît tout de suite (plus de fondu croisé où deux
			// images se superposent), et le nouveau apparaît en fondu en descendant légèrement.
			for (it in diffItems)
				it.alpha = 0;

			var sel:DiffMenuItem = diffItems[curDifficulty];
			sel.scale.set(sel.targetScale, sel.targetScale);
			sel.setPosition(sel.targetX - sel.frameWidth / 2, sel.targetY - DIFF_DROP - sel.frameHeight / 2);
			sel.speed = DIFF_IN_SPEED;
		}

		lastShownDifficulty = curDifficulty;

		placeDiffArrows();
		updateDifficultyDots();
	}

	// Place les flèches de part et d'autre du graphique actuel (comme le Story Mode, où la flèche gauche suit la
	// largeur de l'image), centrées verticalement sur l'emplacement fixe du graphique.
	function placeDiffArrows():Void
	{
		if (diffArrowLeft == null || diffArrowRight == null) return;
		if (curDifficulty < 0 || curDifficulty >= diffItems.length) return;

		var sel:DiffMenuItem = diffItems[curDifficulty];
		var halfW:Float = sel.frameWidth * sel.targetScale / 2;
		var cy:Float = diffZoneTop + DIFF_SLOT_HEIGHT / 2;

		diffArrowLeft.x = diffZoneCX - halfW - DIFF_ARROW_GAP - diffArrowLeft.width;
		diffArrowRight.x = diffZoneCX + halfW + DIFF_ARROW_GAP;
		diffArrowLeft.y = cy - diffArrowLeft.height / 2;
		diffArrowRight.y = cy - diffArrowRight.height / 2;

		diffArrowLeft.visible = true;
		diffArrowRight.visible = true;
	}

	// Reconstruit les points sous le graphique, comme le Story Mode : un point par difficulté disponible,
	// celui de la difficulté actuelle en cyan. Ancrés sur l'emplacement FIXE du graphique (DIFF_SLOT_HEIGHT),
	// PAS sur la hauteur de l'image : les images de certaines weeks (ex : Smash) ont une autre taille, et les
	// points ne doivent pas monter / descendre d'une chanson à l'autre.
	function updateDifficultyDots():Void
	{
		if (diffDotsGroup == null) return;
		diffDotsGroup.clear();

		var total:Int = CoolUtil.difficulties.length;
		if (total <= 0) return;

		var totalWidth:Float = (total * DIFF_DOT_SIZE) + ((total - 1) * DIFF_DOT_SPACING);
		var startX:Float = diffZoneCX - totalWidth / 2;
		var dotsY:Float = diffZoneTop + DIFF_SLOT_HEIGHT + DIFF_DOTS_DROP;

		for (i in 0...total)
		{
			var dot:FlxSprite = new FlxSprite(startX + i * (DIFF_DOT_SIZE + DIFF_DOT_SPACING), dotsY);
			dot.makeGraphic(Std.int(DIFF_DOT_SIZE), Std.int(DIFF_DOT_SIZE), FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawCircle(dot, -1, -1, DIFF_DOT_SIZE / 2, (i == curDifficulty) ? FlxColor.CYAN : FlxColor.WHITE);
			dot.antialiasing = ClientPrefs.globalAntialiasing;
			diffDotsGroup.add(dot);
		}
	}

	// Calcule la position/taille/opacité CIBLE de chaque graphique (les DiffMenuItem s'y rendent en
	// douceur). Tous les graphiques partagent le MÊME emplacement, centré sur l'axe de la colonne du poster,
	// juste sous la barre de difficulté : seul celui de la difficulté actuelle est visible, les autres sont
	// transparents (l'ancien s'efface pendant que le nouveau apparaît).
	function layoutDifficultyGraphics():Void
	{
		var n:Int = diffItems.length;
		if (n == 0) return;

		var centerY:Float = diffZoneTop + DIFF_SLOT_HEIGHT / 2;

		for (i in 0...n)
		{
			var it:DiffMenuItem = diffItems[i];
			var isSel:Bool = (i == curDifficulty);

			it.targetScale = diffItemScale(it);
			it.targetAlpha = isSel ? 1 : 0;
			it.targetX = diffZoneCX;
			it.targetY = centerY;
		}
	}
}

/**
 * Graphique de difficulté du Freeplay. Il se déplace / se redimensionne / change d'opacité
 * tout seul vers ses valeurs "target" (interpolation exponentielle, indépendante du framerate).
 * targetX / targetY désignent le CENTRE du graphique ; le sprite est mis à l'échelle autour de
 * son centre (updateHitbox() n'est volontairement jamais appelé).
 */
class DiffMenuItem extends FlxSprite
{
	public var targetX:Float = 0;
	public var targetY:Float = 0;
	public var targetScale:Float = 1;
	public var targetAlpha:Float = 1;
	public var dying:Bool = false;
	public var fallback:Bool = false; // true = texte de secours dessiné faute d'image
	public var speed:Float = 12;      // vitesse de rapprochement vers les valeurs target

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var t:Float = CoolUtil.boundTo(elapsed * speed, 0, 1);

		var cx:Float = FlxMath.lerp(x + frameWidth / 2, targetX, t);
		var cy:Float = FlxMath.lerp(y + frameHeight / 2, targetY, t);
		x = cx - frameWidth / 2;
		y = cy - frameHeight / 2;

		var sc:Float = FlxMath.lerp(scale.x, targetScale, t);
		scale.set(sc, sc);

		alpha = FlxMath.lerp(alpha, targetAlpha, t);
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
	public var difficulties:String = ''; // Difficultés propres à cette chanson (Freeplay uniquement)
	public var difficultyColors:Map<String, Int> = new Map(); // Couleur de fond par difficulté (clé en minuscules)

	public function new(song:String, week:Int, songCharacter:String, color:Int, ?diffIcons:Map<String, String>, ?songDifficulties:String, ?diffColors:Map<String, Int>)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
		if(diffIcons != null) this.difficultyIcons = diffIcons;
		if(songDifficulties != null) this.difficulties = songDifficulties;
		if(diffColors != null) this.difficultyColors = diffColors;
	}
}