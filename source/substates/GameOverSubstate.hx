package substates;

import states.MusicBeatState;
import states.StoryMenuState;
import states.FreeplayState;

import flixel.FlxG;
import flixel.FlxObject;
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

		boyfriend.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
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
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
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
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			// On annule le timer de sous-titres si le joueur relance avant la fin.
			if (subtitleTimer != null) subtitleTimer.cancel();
			subtitleText.alpha = 0;

			boyfriend.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
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