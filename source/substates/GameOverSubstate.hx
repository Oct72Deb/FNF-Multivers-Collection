package substates;

import states.MusicBeatState;
import states.StoryMenuState;
import states.FreeplayState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxCamera;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	var scaryDad:Character;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var instance:GameOverSubstate;
	var subtitleData:Array<Array<{text:String, duration:Float}>> = [
		[], // index 0 inutilisé
		[{text: "What you're proposing, as usual,\nis just snake oil.", duration: 3.2}],
		[{text: "Oh shit, second time, fuck!", duration: 2.3}],
		[{text: "The French people will understand\nthat you have nothing to offer.", duration: 2.2}],
		[{text: "I'm not putting words in your mouth,\nI don't need a… a… ventriloquist.", duration: 2.7}],
		[{text: "Sorry, I don't have any friends.", duration: 1.3}],
		[{text: "We are at war.", duration: 1.0}],
		[{text: "MACRON EXPLOSION!", duration: 2.0}]
	];
	var subtitleText:FlxText;
	var subtitleTimer:FlxTimer;
	var camSubtitle:FlxCamera;

	// --- Écran "Continue / Yes / No" dédié uniquement à la musique Starlight ---
	var isStarlight:Bool = false;
	var continueSprite:FlxSprite;
	var yesSprite:FlxSprite;
	var noSprite:FlxSprite;
	var gameOverSprite:FlxSprite;
	var showingChoice:Bool = false;
	var selectedYes:Bool = true;
	var baseZoom:Float = 1;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);
		Conductor.songPosition = 0;

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);
		camFollow = new FlxPoint(
    boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0],
    boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]
);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		// --- Contenu exclusif à la musique Starlight ---
		isStarlight = (PlayState.SONG != null && PlayState.SONG.song != null && PlayState.SONG.song.toLowerCase() == 'test');

		if (isStarlight)
		{
			// Léger dézoom de la caméra, déclenché environ 1 seconde après la mort (pas immédiatement).
			baseZoom = FlxG.camera.zoom;
			new FlxTimer().start(1.0, function(tmr:FlxTimer)
			{
				FlxTween.tween(FlxG.camera, {zoom: baseZoom * 0.88}, 0.8, {ease: FlxEase.quadOut});
			});
		}

		// --- Effet "scary" de l'adversaire, déclenché dès la mort du joueur ---
		// On instancie un NOUVEAU Character ici (celui de PlayState n'est plus dessiné
		// une fois le substate ouvert), positionné plein écran façon jump-scare.
		// On lit le nom RÉELLEMENT actif via curCharacter (et non SONG.player2), pour
		// gérer correctement le switch de phase macron -> macron-scream en jeu.
		if (PlayState.SONG.stage == 'elysee')
		{
			var scaryCharName:String = (PlayState.instance != null && PlayState.instance.dad != null)
				? PlayState.instance.dad.curCharacter
				: PlayState.SONG.player2;

			scaryDad = new Character(0, 0, scaryCharName, false);
			scaryDad.playAnim('scary', true);
			scaryDad.screenCenter();
			scaryDad.scrollFactor.set(0, 0); // reste fixe à l'écran, indépendant du scroll caméra
			add(scaryDad);

			// Fondu + léger rétrécissement sur 2 secondes pour donner un effet d'éloignement.
			FlxTween.tween(scaryDad, {alpha: 0, "scale.x": scaryDad.scale.x * 0.85, "scale.y": scaryDad.scale.y * 0.85}, 1, {ease: FlxEase.quadOut});
		}

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		if (isStarlight)
		{
			// Dès la mort, la caméra est directement fixée sur le joueur : aucun délai, aucun mouvement de rattrapage.
			camFollowPos.setPosition(camFollow.x, camFollow.y);
			FlxG.camera.follow(camFollowPos, LOCKON, 1);
			updateCamera = true;
			isFollowingAlready = true;
		}
		// --- Caméra dédiée aux sous-titres ---
		// Zoom forcé à 1 : complètement immunisée contre le defaultCamZoom du jeu.
		camSubtitle = new FlxCamera();
		camSubtitle.bgColor = FlxColor.TRANSPARENT;
		camSubtitle.zoom = 1;
		FlxG.cameras.add(camSubtitle, false);
		// --- Création du texte de sous-titre ---
		subtitleText = new FlxText(0, 0, FlxG.width, "", 28);
		subtitleText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		subtitleText.borderSize = 4;
		subtitleText.scrollFactor.set(0, 0);
		subtitleText.alpha = 0;
		// Position en bas de l'écran avec une petite marge
		subtitleText.y = FlxG.height - subtitleText.height - 40;
		subtitleText.cameras = [camSubtitle];
		add(subtitleText);

		if (isStarlight)
		{
			// Facteur d'agrandissement appliqué aux graphiques Continue/Yes/No.
			var uiScale:Float = 2.6;

			// "Continue" : centré horizontalement, partie haute de l'écran.
			continueSprite = new FlxSprite().loadGraphic(Paths.image("bg/targets/gameover/Continue"));
			continueSprite.setGraphicSize(Std.int(continueSprite.width * uiScale));
			continueSprite.updateHitbox();
			continueSprite.screenCenter(X);
			continueSprite.y = 70;
			continueSprite.alpha = 0;
			continueSprite.scrollFactor.set(0, 0);
			continueSprite.cameras = [camSubtitle];
			add(continueSprite);

			// "Yes" / "No" : centrés horizontalement en tant que paire, un peu plus bas. Yes à gauche, No à droite.
			yesSprite = new FlxSprite().loadGraphic(Paths.image("bg/targets/gameover/Yes"));
			noSprite = new FlxSprite().loadGraphic(Paths.image("bg/targets/gameover/No"));
			yesSprite.setGraphicSize(Std.int(yesSprite.width * uiScale));
			yesSprite.updateHitbox();
			noSprite.setGraphicSize(Std.int(noSprite.width * uiScale));
			noSprite.updateHitbox();

			var spacing:Float = 200;
			var pairWidth:Float = yesSprite.width + spacing + noSprite.width;
			var startX:Float = (FlxG.width - pairWidth) / 2;

			yesSprite.x = startX;
			noSprite.x = startX + yesSprite.width + spacing;
			yesSprite.y = noSprite.y = FlxG.height - yesSprite.height - 60;

			yesSprite.alpha = noSprite.alpha = 0;
			yesSprite.scrollFactor.set(0, 0);
			noSprite.scrollFactor.set(0, 0);
			yesSprite.cameras = [camSubtitle];
			noSprite.cameras = [camSubtitle];

			add(yesSprite);
			add(noSprite);

			// "gameover" : caché au départ, révélé en fondu uniquement si le joueur choisit "No".
			// Taille propre à "GameOver" : modifie uniquement gameOverScale pour la changer.
			// Le sprite reste centré sur le même point que "Continue", quelle que soit sa taille.
			var gameOverScale:Float = 0.6;
			gameOverSprite = new FlxSprite().loadGraphic(Paths.image("bg/targets/gameover/GameOver"));
			gameOverSprite.setGraphicSize(Std.int(gameOverSprite.width * gameOverScale));
			gameOverSprite.updateHitbox();
			gameOverSprite.x = continueSprite.x + (continueSprite.width - gameOverSprite.width) / 2;
			gameOverSprite.y = continueSprite.y + (continueSprite.height - gameOverSprite.height) / 2;
			gameOverSprite.alpha = 0;
			gameOverSprite.scrollFactor.set(0, 0);
			gameOverSprite.cameras = [camSubtitle];
			add(gameOverSprite);

			updateSelectionColors();
		}
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			if (isStarlight)
			{
				// Aucune interpolation : la caméra reste collée au joueur en permanence.
				camFollowPos.setPosition(camFollow.x, camFollow.y);
			}
			else
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
				camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			}
		}

		if (isStarlight)
		{
			// Sur Starlight, ACCEPT ne fait rien tant que "Continue"/"Yes"/"No" ne sont pas affichés ;
			// une fois affichés, il valide la sélection courante (Yes = retry, No = comportement normal).
			if (showingChoice && !isEnding)
			{
				if (controls.UI_LEFT_P && !selectedYes)
				{
					selectedYes = true;
					updateSelectionColors();
				}
				else if (controls.UI_RIGHT_P && selectedYes)
				{
					selectedYes = false;
					updateSelectionColors();
				}

				if (controls.ACCEPT)
				{
					if (selectedYes)
						endBullshit();
					else
						playNoOutro();
				}
			}
		}
		else if (controls.ACCEPT)
		{
			endBullshit();
		}

		// Sur la musique "test" (Starlight), la touche retour est désactivée.
		if (controls.BACK && !isStarlight)
		{
			goBackToMenu();
		}
		
		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (PlayState.SONG.stage == 'elysee')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					var voiceIndex:Int;

					// Vérifie si le joueur en est exactement à sa deuxième mort
					if (PlayState.deathCounter == 2)
					{
						voiceIndex = 2; // Force la ligne "Oh shit, second time, fuck!"
					}
					else
					{
						exclude.push(2); // Empêche la ligne 2 de se lancer au hasard lors des autres morts
						// On capture l'index tiré au sort parmi le reste
						voiceIndex = FlxG.random.int(1, 7, exclude);
					}

					FlxG.sound.play(Paths.sound('macronGameover/macronGameover-' + voiceIndex), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
					// Lancement des sous-titres correspondant à la voice line tirée.
					playSubtitles(voiceIndex);
				}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;

				if (isStarlight)
				{
					startContinueSequence();
				}
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	// Affiche les sous-titres de la voice line donnée en les enchaînant séquentiellement.
	function playSubtitles(voiceIndex:Int):Void
	{
		if (voiceIndex < 1 || voiceIndex >= subtitleData.length) return;

		var entries = subtitleData[voiceIndex];
		if (entries == null || entries.length == 0) return;

		showNextSubtitle(entries, 0);
	}

	// Affiche récursivement chaque sous-titre de la liste à l'index donné.
	function showNextSubtitle(entries:Array<{text:String, duration:Float}>, index:Int):Void
	{
		if (index >= entries.length)
		{
			// Tous les sous-titres ont été affichés : on fait disparaître le texte.
			FlxTween.tween(subtitleText, {alpha: 0}, 0.3);
			return;
		}

		var entry = entries[index];

		// Mise à jour du texte et apparition instantanée.
		subtitleText.text = entry.text;
		// Recalcul de la position Y au cas où la hauteur du texte changerait.
		subtitleText.y = FlxG.height - subtitleText.height - 40;
		subtitleText.alpha = 1;
		// Timer pour passer au sous-titre suivant après la durée définie.
		subtitleTimer = new FlxTimer().start(entry.duration, function(tmr:FlxTimer)
		{
			showNextSubtitle(entries, index + 1);
		});
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		if (isStarlight)
			FlxG.sound.playMusic(Paths.music('gameOver-smash'), volume, false);
		else
			FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	// Starlight uniquement : gameOver-smash -> 0,8 s -> "Continue" -> 1 s -> "Yes"/"No".
	// Appelée au moment où la musique gameOver-smash est déclenchée.
	var continueDelay:Float = 0.9; // délai entre le début de la musique et "Continue"
	var choiceDelay:Float = 1.0;   // délai entre "Continue" et "Yes"/"No"

	function startContinueSequence():Void
	{
		new FlxTimer().start(continueDelay, function(tmr:FlxTimer)
		{
			if (isEnding) return;
			FlxTween.tween(continueSprite, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

			new FlxTimer().start(choiceDelay, function(tmr2:FlxTimer)
			{
				if (isEnding) return;
				FlxTween.tween(yesSprite, {alpha: 1}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(noSprite, {alpha: 1}, 0.4, {ease: FlxEase.quadOut});
				showingChoice = true;
				updateSelectionColors();
			});
		});
	}

	// Colore en rouge la réponse actuellement sélectionnée (Yes ou No).
	function updateSelectionColors():Void
	{
		if (yesSprite == null || noSprite == null) return;
		yesSprite.color = selectedYes ? FlxColor.RED : FlxColor.WHITE;
		noSprite.color = !selectedYes ? FlxColor.RED : FlxColor.WHITE;
	}

	// Comportement normal de l'écran de mort : retour au menu (Freeplay/Story), identique à l'ancien BACK.
	function goBackToMenu():Void
	{
		FlxG.sound.music.stop();
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		PlayState.chartingMode = false;

		WeekData.loadTheFirstEnabledMod();
		if (PlayState.isStoryMode)
			MusicBeatState.switchState(new StoryMenuState());
		else
			MusicBeatState.switchState(new FreeplayState());

		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
	}

	// Séquence jouée quand le joueur choisit "No" (Starlight/test uniquement) :
	// lance gameOverEndGameover-smash, dézoome progressivement la caméra et fait disparaître
	// le personnage pendant que l'audio joue, affiche "gameover" en fondu, puis revient au menu
	// (comme un appui sur "retour" dans l'écran de mort original) une fois l'audio terminé.
	function playNoOutro():Void
	{
		if (isEnding) return;
		isEnding = true;

		if (subtitleTimer != null) subtitleTimer.cancel();
		subtitleText.alpha = 0;

		FlxTween.cancelTweensOf(continueSprite);
		FlxTween.cancelTweensOf(yesSprite);
		FlxTween.cancelTweensOf(noSprite);
		continueSprite.alpha = 0;
		yesSprite.alpha = 0;
		noSprite.alpha = 0;

		FlxTween.tween(gameOverSprite, {alpha: 1}, 0.6, {ease: FlxEase.quadOut});

		FlxG.sound.music.stop();

		var noSound = FlxG.sound.play(Paths.music('gameOverEndGameover-smash'), 1, false, null, true, function()
		{
			goBackToMenu();
		});

		var outroDuration:Float = (noSound != null && noSound.length > 0) ? (noSound.length / 1000) : 2.5;

		FlxTween.tween(FlxG.camera, {zoom: baseZoom * 0.4}, outroDuration, {ease: FlxEase.quadOut});
		FlxTween.tween(boyfriend, {alpha: 0}, outroDuration, {ease: FlxEase.quadOut});
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			// On annule le timer de sous-titres si le joueur relance avant la fin.
			if (subtitleTimer != null) subtitleTimer.cancel();
			subtitleText.alpha = 0;
			if (scaryDad != null)
			{
				FlxTween.cancelTweensOf(scaryDad);
				scaryDad.alpha = 0;
			}
			if (isStarlight)
			{
				FlxTween.cancelTweensOf(continueSprite);
				FlxTween.cancelTweensOf(yesSprite);
				FlxTween.cancelTweensOf(noSprite);
				continueSprite.alpha = 0;
				yesSprite.alpha = 0;
				noSprite.alpha = 0;
			}

			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(isStarlight ? 'gameOverEnd-smash' : endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}