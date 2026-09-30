package states;

#if desktop
import Discord.DiscordClient;
#end

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSpriteUtil;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import openfl.geom.Rectangle;
import WeekData;
import substates.ArtworkSubstate;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	// ------------------------------------------------------------------
	// Repères de mise en page, basés sur le concept art (résolution 1280x720).
	// A ajuster si vos assets ont des dimensions différentes.
	// ------------------------------------------------------------------
	// Hauteur augmentée (56 -> 92) : l'ancienne valeur était trop basse pour contenir
	// à la fois les 2 lignes du HUD (score + stats) ET le titre de la semaine (qui peut
	// s'écrire sur 2 lignes) sans déborder sur le fond jaune en dessous. C'est cette
	// bande noire opaque qui empêchait tout chevauchement avec l'illustration/le fond
	// diagonal : la garder assez haute règle les chevauchements visibles en haut de l'écran.
	static inline var TOP_BAR_HEIGHT:Int = 92;
	static inline var LEFT_COL_X:Float = 135;      // centre de la colonne "semaine" (décalée vers la gauche à la demande, était 205)
	static inline var LEFT_COL_WIDTH:Float = 320;  // largeur de la zone gauche (jusqu'à la diagonale) — réduite
static inline var DIAGONAL_TOP_X:Float = 305;    // était 335
static inline var DIAGONAL_BOTTOM_X:Float = 255; // était 285
	static inline var YELLOW_HEIGHT:Int = 386;
	static inline var DIFF_SELECTOR_SCALE:Float = 0.8; // réduit (était 1) : le sprite de difficulté ("HARD" etc) était trop gros
	static inline var DIFF_DOTS_DROP:Float = 16; // décalage vertical fixe des points de difficulté sous la rangée flèches/difficulté
	static inline var DIFF_SELECTOR_RIGHT_MARGIN:Float = 24; // distance au bord droit de l'écran
	static inline var DIFF_SELECTOR_GAP:Float = 10; // espace entre flèches et sprite de difficulté

	var scoreText:FlxText;
	var txtStats:FlxText; // ligne "SFC, Accuracy, Miss"

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;
	var diagonalBg:FlxSprite;
	var diagonalLine:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;
	var txtBpmHeader:FlxText;
	var txtBpmList:FlxText;
	var txtLevelList:FlxText; // niveau de difficulté par piste, comme dans le Freeplay (ArtworkSubstate)

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var hexFrame:FlxSprite;
	var txtWeekLabel:FlxText;
	var txtWeekNumber:FlxText;
	var upArrow:FlxSprite;
	var downArrow:FlxSprite;
	var lockIcon:FlxSprite;

	var difficultySelectors:FlxGroup;
	var diffAreaY:Float; // rangée fixe flèches/difficulté, utilisée aussi comme ancre fixe pour les points (voir updateDifficultyDots)
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var grpDifficultyDots:FlxTypedGroup<FlxSprite>;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		// Bande HUD (score + stats) : décalée pour être juste APRÈS (à droite de) le trait bleu
		// diagonal, au lieu de coller au bord gauche de l'écran. On calcule la position du trait à
		// worldY = 0 (son point le plus à droite dans la bande du haut, vu la pente) avec la même
		// formule que buildDiagonalBackground(), pour que ça reste juste si la pente ou
		// TOP_BAR_HEIGHT changent plus tard. Les deux lignes s'empilent ensuite avec un petit
		// espacement constant et tiennent entièrement dans TOP_BAR_HEIGHT.
		var HUD_MARGIN:Float = 12;
		var HUD_LINE_GAP:Float = 4;
		var lineSlope:Float = (DIAGONAL_BOTTOM_X - DIAGONAL_TOP_X) / YELLOW_HEIGHT;
		var lineXAtScreenTop:Float = DIAGONAL_TOP_X - lineSlope * TOP_BAR_HEIGHT;
		var HUD_TEXT_X:Float = lineXAtScreenTop + 20; // petit espace après le trait

		scoreText = new FlxText(HUD_TEXT_X, HUD_MARGIN, 0, "SCORE: 0", 32);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtStats = new FlxText(HUD_TEXT_X, scoreText.y + scoreText.height + HUD_LINE_GAP, 0, "", 20);
		txtStats.setFormat("VCR OSD Mono", 20, FlxColor.WHITE);
		txtStats.alpha = 0.85;
		// Texte reconstruit dynamiquement par updateWeekStats() (données Highscore réelles),
		// appelée depuis changeWeek() et changeDifficulty().

		// Titre de semaine (haut droite) : centré verticalement dans TOP_BAR_HEIGHT et avec
		// une police légèrement réduite (32 -> 26) pour tenir sur 1 ou 2 lignes sans déborder
		// de la bande noire, quel que soit le nom de la semaine.
		txtWeekTitle = new FlxText(FlxG.width * 0.5, 0, FlxG.width * 0.5 - HUD_MARGIN, "", 26);
		txtWeekTitle.setFormat("VCR OSD Mono", 26, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		// --- Fond diagonal (zone jaune à droite, découpe façon concept art) ---
		buildDiagonalBackground();

		// bgSprite est une image RECTANGULAIRE simple (pas de découpe diagonale dans le fichier
		// lui-même). Comme la ligne/le fond jaune sont, eux, une vraie diagonale (le x de la
		// découpe varie selon la ligne, entre DIAGONAL_TOP_X en haut et DIAGONAL_BOTTOM_X en bas),
		// poser bgSprite au x le plus À DROITE des deux (DIAGONAL_TOP_X) laissait un bout de fond
		// jaune uni visible entre la ligne et l'image sur toutes les lignes où la découpe est plus
		// à gauche que ça. On pose donc bgSprite au x le plus À GAUCHE des deux, pour qu'il
		// recouvre bien toute la zone jaune, puis clipBgSpriteToDiagonal() (appelée après chaque
		// loadGraphic) rend transparents les pixels qui dépasseraient la diagonale côté haut.
		bgSprite = new FlxSprite(Math.min(DIAGONAL_TOP_X, DIAGONAL_BOTTOM_X), TOP_BAR_HEIGHT);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, TOP_BAR_HEIGHT, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			if(WeekData.weeksList[i] == WeekbUnlock.HIDDEN_WEEK_NAME) continue; // "weekb" jamais visible en Story Mode

			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, 0, WeekData.weeksList[i]);
				weekThing.targetY = num;
				grpWeekText.add(weekThing);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;

				// Certains logos de semaine (ex: "SMASH") sont bien plus grands que le cadre
				// hexagonal (210x140) et débordaient largement dessus. On réduit automatiquement
				// le logo pour qu'il tienne dans le cadre avec une petite marge, sans jamais
				// l'agrandir si son image d'origine est déjà plus petite (scale plafonné à 1).
				// Marges réduites (agrandissement demandé) : le logo remplit maintenant le cadre
				// de plus près qu'avant.
				var hexLogoMaxW:Float = 210 - 4;
				var hexLogoMaxH:Float = 140 - 4;
				var hexLogoFit:Float = Math.min(1, Math.min(hexLogoMaxW / weekThing.width, hexLogoMaxH / weekThing.height));
				weekThing.scale.set(hexLogoFit, hexLogoFit);
				weekThing.updateHitbox();
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		var zoneX:Float = DIAGONAL_TOP_X;
		var zoneW:Float = FlxG.width - zoneX;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter(zoneX + zoneW * (0.18 + 0.32 * char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		// --- Cadre hexagonal de la semaine (colonne gauche) ---
		hexFrame = new FlxSprite(LEFT_COL_X - 105, 255);
		styleHexagonFrame(hexFrame, 210, 140, FlxColor.WHITE, 4);

		// Les flèches haut/bas réutilisent le graphisme des flèches gauche/droite (juste tournées de 90°),
		// pour rester cohérent avec le style déjà présent dans campaign_menu_UI_assets.
		// Si le sens est inversé chez vous, inversez simplement les deux valeurs d'angle ci-dessous.
		//
		// Point important sur la rotation : FlxSprite tourne autour du centre de son cadre
		// (origin = width/2, height/2 en dimensions NON tournées), donc une fois à 90°, la boîte
		// visuelle a pour hauteur la LARGEUR native du sprite (upArrow.width) et pour largeur sa
		// HAUTEUR native (upArrow.height) — les deux sont inversées par rapport au sprite droit.
		// L'ancien code utilisait des positions Y fixes (195 / 415) totalement indépendantes de la
		// position réelle du cadre hexagonal : selon la taille de l'asset, ça pouvait désaligner
		// les flèches et faire chevaucher "WEEK 1" avec la flèche du bas. Tout est maintenant calculé
		// à partir de hexFrame, donc ça reste juste quelle que soit la taille de l'asset flèche.
		var arrowColumnGap:Float = 14; // espace fixe entre le cadre hexagonal et chaque flèche
		var labelGap:Float = 10; // espace fixe entre chaque flèche et le texte "WEEK" / "WEEK n" associé

		upArrow = new FlxSprite(LEFT_COL_X, 0);
		upArrow.frames = ui_tex;
		upArrow.animation.addByPrefix('idle', 'arrow left');
		upArrow.animation.addByPrefix('press', 'arrow push left');
		upArrow.animation.play('idle');
		upArrow.antialiasing = ClientPrefs.globalAntialiasing;
		upArrow.angle = 90;
		upArrow.x -= upArrow.width / 2; // centrage horizontal : correct quel que soit l'angle, car le pivot de rotation est (x + width/2)
		upArrow.y = hexFrame.y - arrowColumnGap - upArrow.height / 2 - upArrow.width / 2;
		// bord visuel supérieur de upArrow (utile pour placer txtWeekLabel juste au-dessus) :
		var upArrowTopEdge:Float = hexFrame.y - arrowColumnGap - upArrow.width;

		downArrow = new FlxSprite(LEFT_COL_X, 0);
		downArrow.frames = ui_tex;
		downArrow.animation.addByPrefix('idle', 'arrow left');
		downArrow.animation.addByPrefix('press', 'arrow push left');
		downArrow.animation.play('idle');
		downArrow.antialiasing = ClientPrefs.globalAntialiasing;
		downArrow.angle = -90;
		downArrow.x -= downArrow.width / 2;
		downArrow.y = hexFrame.y + hexFrame.height + arrowColumnGap - downArrow.height / 2 + downArrow.width / 2;
		// bord visuel inférieur de downArrow (utile pour placer txtWeekNumber juste en dessous) :
		var downArrowBottomEdge:Float = hexFrame.y + hexFrame.height + arrowColumnGap + downArrow.width;

		txtWeekLabel = new FlxText(0, 0, LEFT_COL_WIDTH, "WEEK", 40);
		txtWeekLabel.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER);
		txtWeekLabel.borderStyle = OUTLINE;
		txtWeekLabel.borderColor = FlxColor.BLACK;
		txtWeekLabel.borderSize = 2;
		txtWeekLabel.x = LEFT_COL_X - LEFT_COL_WIDTH / 2;
		txtWeekLabel.y = upArrowTopEdge - labelGap - txtWeekLabel.height;

		txtWeekNumber = new FlxText(0, 0, LEFT_COL_WIDTH, "", 40);
		txtWeekNumber.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER);
		txtWeekNumber.borderStyle = OUTLINE;
		txtWeekNumber.borderColor = FlxColor.BLACK;
		txtWeekNumber.borderSize = 2;
		txtWeekNumber.x = LEFT_COL_X - LEFT_COL_WIDTH / 2;
		txtWeekNumber.y = downArrowBottomEdge + labelGap;

		lockIcon = new FlxSprite(0, 0);
		lockIcon.frames = ui_tex;
		lockIcon.animation.addByPrefix('lock', 'lock');
		lockIcon.animation.play('lock');
		lockIcon.antialiasing = ClientPrefs.globalAntialiasing;
		lockIcon.visible = false;

		// --- Sélecteur de difficulté (bas droite), ancré au bord droit de l'écran ---
		// Taille d'origine conservée ; rightArrow est ancrée à DIFF_SELECTOR_RIGHT_MARGIN du bord
		// pour ne plus déborder de l'écran, quelle que soit la largeur du graphisme "HARD" etc.
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		// Ancrée à la même formule que "tracksSprite" plus bas (TOP_BAR_HEIGHT + YELLOW_HEIGHT + 40),
		// pour que la ligne "TRACKS" et le sélecteur de difficulté "HARD" restent alignés sur la
		// même rangée horizontale quelle que soit la valeur de TOP_BAR_HEIGHT (au lieu de deux
		// valeurs codées en dur indépendamment, source du désalignement précédent).
		diffAreaY = TOP_BAR_HEIGHT + YELLOW_HEIGHT + 40;

		rightArrow = new FlxSprite(0, diffAreaY);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.scale.set(DIFF_SELECTOR_SCALE, DIFF_SELECTOR_SCALE);
		rightArrow.updateHitbox();
		rightArrow.x = FlxG.width - DIFF_SELECTOR_RIGHT_MARGIN - rightArrow.width;
		difficultySelectors.add(rightArrow);

		leftArrow = new FlxSprite(0, diffAreaY);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.scale.set(DIFF_SELECTOR_SCALE, DIFF_SELECTOR_SCALE);
		leftArrow.updateHitbox();
		leftArrow.x = 0; // recalculée dans changeDifficulty() une fois la largeur réelle du sprite de difficulté connue
		difficultySelectors.add(leftArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		sprDifficulty = new FlxSprite(0, diffAreaY);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		grpDifficultyDots = new FlxTypedGroup<FlxSprite>();
		add(grpDifficultyDots);

		add(diagonalBg);
		add(bgSprite);
		// diagonalLine est ajouté APRÈS bgSprite : elle doit toujours rester au-dessus (bord bien
		// visible), même si le clip de bgSprite n'est pas pixel-perfect avec l'épaisseur du trait.
		add(diagonalLine);
		add(grpWeekCharacters);

		add(hexFrame);
		add(txtWeekLabel);
		add(txtWeekNumber);
		add(upArrow);
		add(downArrow);
		add(lockIcon);

		// --- Tracklist + BPM (bas gauche/centre) ---
		var tracksSprite:FlxSprite = new FlxSprite(DIAGONAL_TOP_X + 10, TOP_BAR_HEIGHT + YELLOW_HEIGHT + 40).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(tracksSprite);

		txtBpmHeader = new FlxText(tracksSprite.x + 340, tracksSprite.y, 150, "BPM", 32);
		txtBpmHeader.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		add(txtBpmHeader);

		txtTracklist = new FlxText(tracksSprite.x, tracksSprite.y + 60, 320, "", 32);
		txtTracklist.alignment = LEFT;
		txtTracklist.font = Paths.font("vcr.ttf");
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);

		txtBpmList = new FlxText(txtBpmHeader.x, txtTracklist.y, 150, "", 32);
		txtBpmList.alignment = CENTER;
		txtBpmList.font = Paths.font("vcr.ttf");
		txtBpmList.color = FlxColor.WHITE;
		add(txtBpmList);

		// Niveau de difficulté par piste (données ArtworkSubstate.ARTWORKS, comme en Freeplay),
		// recalculé à chaque changement de difficulté via updateLevelList().
		txtLevelList = new FlxText(txtBpmHeader.x + 170, txtTracklist.y, 90, "", 32);
		txtLevelList.alignment = CENTER;
		txtLevelList.font = Paths.font("vcr.ttf");
		txtLevelList.color = FlxColor.WHITE;
		add(txtLevelList);

		add(scoreText);
		add(txtStats);
		add(txtWeekTitle);

		changeWeek();
		changeDifficulty();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_UP)
				upArrow.animation.play('press');
			else
				upArrow.animation.play('idle');

			if (controls.UI_DOWN)
				downArrow.animation.play('press');
			else
				downArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		// Seule la semaine actuellement sélectionnée (targetY == 0) reste visible,
		// recentrée dans le cadre hexagonal — les autres MenuItem restent hors champ.
		for (item in grpWeekText.members)
		{
			if (item.targetY == 0)
			{
				item.visible = true;
				item.x = hexFrame.x + (hexFrame.width - item.width) / 2;
				item.y = hexFrame.y + (hexFrame.height - item.height) / 2;
			}
			else
			{
				item.visible = false;
			}
		}

		if (lockIcon.visible)
		{
			lockIcon.x = hexFrame.x + hexFrame.width - lockIcon.width - 6;
			lockIcon.y = hexFrame.y + hexFrame.height - lockIcon.height - 6;
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();

				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		var currentWeek = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(currentWeek);

		var diff:String = CoolUtil.difficulties[curDifficulty];

		var diffPath:String = "menudifficulties/";
		if (currentWeek.fileName == "weeka") // ← nom du fichier week (ex: Smash.json)
			diffPath = "menudifficulties/smash/";

		var newImage:FlxGraphic = Paths.image(diffPath + Paths.formatToSongPath(diff));

		if (sprDifficulty.graphic != newImage)
		{
			if (tweenDifficulty != null)
				tweenDifficulty.cancel();

			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.scale.set(DIFF_SELECTOR_SCALE, DIFF_SELECTOR_SCALE);
			sprDifficulty.updateHitbox();
			sprDifficulty.alpha = 0;

			// Ancré à gauche de rightArrow (qui elle reste collée au bord de l'écran) : le sprite
			// de difficulté et leftArrow se replacent donc automatiquement, quelle que soit sa largeur.
			var restY:Float = rightArrow.y + (rightArrow.height - sprDifficulty.height) / 2;
			sprDifficulty.x = rightArrow.x - DIFF_SELECTOR_GAP - sprDifficulty.width;
			sprDifficulty.y = restY - 15;
			leftArrow.x = sprDifficulty.x - DIFF_SELECTOR_GAP - leftArrow.width;

			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: restY, alpha: 1}, 0.07, {
				onComplete: function(twn:FlxTween)
				{
					tweenDifficulty = null;
				}
			});
		}

		lastDifficultyName = diff;

		updateDifficultyDots();
		updateLevelList();
		updateWeekStats();

		#if !switch
		intendedScore = Highscore.getWeekScore(currentWeek.fileName, curDifficulty);
		#end
	}

	// Ordre des rangs, du meilleur au pire (identique aux seuils ratingFC de PlayState.hx :
	// S+ >= 100%, S >= 95%, A >= 90%, B >= 80%, C >= 70%, E >= 50%, F en dessous).
	static var RANK_ORDER:Array<String> = ["S+", "S", "A", "B", "C", "E", "F"];

	// Reconstruit la ligne de stats sous le score, pour la semaine + difficulté actuellement
	// sélectionnées, à partir des données sauvegardées par piste dans Highscore
	// (getRank/getMisses/getRating). Accuracy fait la moyenne des "rating" par piste (fraction
	// 0-1 d'après PlayState.ratingPercent, d'où le *100) ; Miss additionne les miss enregistrés
	// par piste.
	// RANG : calculé en temps réel, exactement comme Accuracy/Miss, à partir des rangs
	// (S+/S/A/B/C/E/F) réellement obtenus et sauvegardés par Highscore.getRank() sur chaque
	// piste de la semaine. Le rang affiché est le PIRE des rangs obtenus parmi les pistes
	// jouées (une semaine n'est aussi bonne que sa piste la plus faible). Si aucune piste
	// de la semaine n'a encore été jouée à cette difficulté, on affiche "-" plutôt qu'un
	// rang inventé.
	function updateWeekStats():Void
	{
		var leWeek:WeekData = loadedWeeks[curWeek];
		var totalMiss:Int = 0;
		var ratingSum:Float = 0;
		var songCount:Int = leWeek.songs.length;

		var worstRankIndex:Int = -1;
		var anyPlayed:Bool = false;

		for (i in 0...songCount)
		{
			var songName:String = leWeek.songs[i][0];
			totalMiss += Highscore.getMisses(songName, curDifficulty);
			ratingSum += Highscore.getRating(songName, curDifficulty);

			var rank:String = Highscore.getRank(songName, curDifficulty);
			if (rank != null && rank.length > 0)
			{
				anyPlayed = true;
				var idx:Int = RANK_ORDER.indexOf(rank);
				if (idx < 0) idx = RANK_ORDER.length - 1; // rang inconnu/non reconnu -> traité comme le pire cas
				if (idx > worstRankIndex) worstRankIndex = idx;
			}
		}

		var avgAccuracy:Float = (songCount > 0) ? Highscore.floorDecimal((ratingSum / songCount) * 100, 2) : 0;
		var rankLabel:String = anyPlayed ? RANK_ORDER[worstRankIndex] : "-";

		txtStats.text = rankLabel + ' RANK   ' + avgAccuracy + '% ACCURACY   ' + totalMiss + ' MISS';
	}

	// Reconstruit les points sous le sélecteur de difficulté : un point par difficulté
	// disponible pour la semaine/musique courante, celui de la difficulté sélectionnée en cyan.
	function updateDifficultyDots():Void
	{
		grpDifficultyDots.clear();

		var total:Int = CoolUtil.difficulties.length;
		if (total <= 0) return;

		var dotSize:Float = 7;
		var spacing:Float = 6;
		var totalWidth:Float = (total * dotSize) + ((total - 1) * spacing);
		var startX:Float = sprDifficulty.x + (sprDifficulty.width - totalWidth) / 2;
		// Ancré sur diffAreaY + la hauteur (fixe) des flèches, PAS sur sprDifficulty.height :
		// certaines semaines (ex: "weeka"/Smash) chargent des images de difficulté d'une autre
		// taille (dossier "menudifficulties/smash/"), donc sprDifficulty.height varie et faisait
		// remonter/descendre les points selon la semaine. rightArrow, elle, garde toujours le
		// même graphisme (juste mis à l'échelle par DIFF_SELECTOR_SCALE), donc sa hauteur est un
		// repère stable pour que les points restent alignés de la même façon quelle que soit la semaine.
		var dotsY:Float = diffAreaY + rightArrow.height + DIFF_DOTS_DROP;

		for (i in 0...total)
		{
			var dot:FlxSprite = new FlxSprite(startX + i * (dotSize + spacing), dotsY);
			dot.makeGraphic(Std.int(dotSize), Std.int(dotSize), FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawCircle(dot, -1, -1, dotSize / 2, (i == curDifficulty) ? FlxColor.CYAN : FlxColor.WHITE);
			grpDifficultyDots.add(dot);
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		// Centrage vertical dans la bande noire du haut, que le titre tienne sur 1 ou 2 lignes.
		txtWeekTitle.y = (TOP_BAR_HEIGHT - txtWeekTitle.height) / 2;

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		lockIcon.visible = !unlocked;
		txtWeekNumber.text = "WEEK " + (curWeek + 1);

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
			clipBgSpriteToDiagonal();
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5
		difficultySelectors.visible = unlocked;
		grpDifficultyDots.visible = unlocked;

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
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		txtBpmList.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i].toUpperCase() + '\n';
			txtBpmList.text += getSongBPM(stringThing[i]) + '\n';
		}

		updateLevelList();
		updateWeekStats();

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	// Affiche, pour chaque piste, son niveau de difficulté pour la difficulté actuellement
	// sélectionnée — les mêmes données que celles utilisées en Freeplay (ArtworkSubstate.ARTWORKS).
	// Se recalcule à la fois quand on change de semaine et quand on change de difficulté.
	function updateLevelList():Void
	{
		if (txtLevelList == null || loadedWeeks.length == 0) return;

		var leWeek:WeekData = loadedWeeks[curWeek];
		var diffKey:String = Paths.formatToSongPath(CoolUtil.difficulties[curDifficulty]);

		txtLevelList.text = '';
		for (i in 0...leWeek.songs.length)
		{
			var songName:String = leWeek.songs[i][0];
			var entry = ArtworkSubstate.findEntry(Paths.formatToSongPath(songName));
			var levelStr:String = '-';
			if (entry != null && entry.levels != null && entry.levels.exists(diffKey))
				levelStr = Std.string(entry.levels.get(diffKey));
			txtLevelList.text += levelStr + '\n';
		}
	}

	// Récupère le BPM du morceau pour l'afficher dans la colonne BPM (comme sur le concept art).
	// Charge le chart JSON du morceau : peut créer un léger coût à chaque changement de semaine,
	// à mettre en cache si besoin de perf.
	function getSongBPM(songName:String):String
	{
		try
		{
			var diffSuffix:String = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffSuffix == null) diffSuffix = '';
			var songData = Song.loadFromJson(songName.toLowerCase() + diffSuffix, songName.toLowerCase());
			if (songData != null && songData.bpm > 0)
				return Std.string(songData.bpm);
		}
		catch (e:Dynamic) {}
		return '--';
	}

	// Dessine le contour hexagonal (coins coupés) autour du nom de la semaine, façon concept art.
	function styleHexagonFrame(spr:FlxSprite, w:Int, h:Int, lineColor:FlxColor = FlxColor.WHITE, thickness:Float = 4):Void
	{
		spr.makeGraphic(w, h, FlxColor.TRANSPARENT, true);
		var cut:Float = w * 0.16;
		var pts:Array<Array<Float>> = [
			[cut, 2], [w - cut, 2],
			[w - 2, h / 2],
			[w - cut, h - 2], [cut, h - 2],
			[2, h / 2], [cut, 2]
		];
		for (i in 0...pts.length - 1)
		{
			FlxSpriteUtil.drawLine(spr, pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1], {thickness: thickness, color: lineColor});
		}
	}

	// Construit le fond jaune avec découpe diagonale + liseré cyan, comme sur le concept art.
	// Dessiné ligne par ligne faute de fillPolygon dans FlxSpriteUtil : coût unique à la création.
	function buildDiagonalBackground():Void
	{
		var w:Int = FlxG.width;
		var h:Int = YELLOW_HEIGHT;
		diagonalBg = new FlxSprite(0, TOP_BAR_HEIGHT);
		diagonalBg.makeGraphic(w, h, FlxColor.TRANSPARENT, true);

		for (y in 0...h)
		{
			var t:Float = y / h;
			var cutX:Float = DIAGONAL_TOP_X + (DIAGONAL_BOTTOM_X - DIAGONAL_TOP_X) * t;
			FlxSpriteUtil.drawLine(diagonalBg, cutX, y, w, y, {thickness: 1, color: 0xFFF9CF51});
		}

		// Le trait cyan est maintenant sur son propre sprite, dimensionné pour couvrir TOUT
		// l'écran (0 -> FlxG.height) au lieu d'être limité à la hauteur de diagonalBg
		// (YELLOW_HEIGHT) : avant, il était donc coupé en haut et en bas de l'écran. On extrapole
		// la même pente que la découpe du fond jaune, pour que le trait reste bien aligné avec
		// elle tout en allant d'un bord de l'écran à l'autre.
		diagonalLine = new FlxSprite(0, 0);
		diagonalLine.makeGraphic(w, FlxG.height, FlxColor.TRANSPARENT, true);

		var slope:Float = (DIAGONAL_BOTTOM_X - DIAGONAL_TOP_X) / h; // variation de x par pixel de y
		var xAtScreenTop:Float = DIAGONAL_TOP_X - slope * TOP_BAR_HEIGHT; // extrapolé jusqu'à worldY = 0
		var xAtScreenBottom:Float = xAtScreenTop + slope * FlxG.height; // extrapolé jusqu'à worldY = FlxG.height

		FlxSpriteUtil.drawLine(diagonalLine, xAtScreenTop, 0, xAtScreenBottom, FlxG.height, {thickness: 4, color: FlxColor.CYAN});
	}

	// Rend transparente la portion de bgSprite qui déborde à gauche de la diagonale, ligne par
	// ligne, avec la même formule que buildDiagonalBackground(). bgSprite est posé au x le plus à
	// gauche des deux (DIAGONAL_TOP_X / DIAGONAL_BOTTOM_X) pour être sûr de couvrir toute la zone
	// jaune ; sans ce clip, l'image déborderait alors sur la colonne noire de gauche (ou par-dessus
	// le trait cyan) sur les lignes où la vraie découpe est plus à droite que ce bord gauche fixe.
	function clipBgSpriteToDiagonal():Void
	{
		if (bgSprite.graphic == null) return;

		var bmp = bgSprite.pixels;
		var h:Int = bmp.height;
		var slope:Float = (DIAGONAL_BOTTOM_X - DIAGONAL_TOP_X) / YELLOW_HEIGHT;

		for (localY in 0...h)
		{
			var worldY:Float = bgSprite.y + localY;
			var cutX:Float = DIAGONAL_TOP_X + slope * (worldY - TOP_BAR_HEIGHT);
			var localCutX:Int = Std.int(cutX - bgSprite.x);

			if (localCutX > 0)
			{
				var clearW:Int = Std.int(Math.min(localCutX, bmp.width));
				if (clearW > 0)
					bmp.fillRect(new Rectangle(0, localY, clearW, 1), FlxColor.TRANSPARENT);
			}
		}

		bgSprite.pixels = bmp;
		bgSprite.dirty = true;
	}
}
