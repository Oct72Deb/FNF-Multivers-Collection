package options;

import states.MusicBeatState;

import flixel.util.FlxStringUtil;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.group.FlxGroup;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class NoteOffsetState extends MusicBeatState
{
	var boyfriend:Character;
	var gf:Character;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	var barPercent:Float = 0;
	var delayMin:Int = 0;
	var delayMax:Int = 500;
	var timeBarBG:FlxSprite;
	var timeBar:FlxBar;
	var timeTxt:FlxText;
	var beatText:Alphabet;
	var beatTween:FlxTween;

	var changeModeText:FlxText;

	// ---------------------------------------------------------------
	// Play Test (mini-gameplay intégré, sans PlayState ni JSON)
	// ---------------------------------------------------------------
	// Chart [temps en ms, lane, type] - issu de offset.json (128 BPM, offsetSong.ogg)
	// type : 0 = note normale, 1 = note "Hey!" (déclenche l'animation Hey de BF)
	static var TEST_CHART:Array<Array<Float>> = [
		[0,0,0],[937.5,1,1],[1875,2,0],[2812.5,3,1],[3750,2,0],[4687.5,1,1],[5625,0,0],[6562.5,1,1],
		[7500,2,0],[8437.5,3,1],[9375,2,0],[10312.5,1,1],[11250,0,0],[12187.5,1,1],[13125,2,0],[14062.5,3,1],
		[15000,0,0],[15468.75,1,0],[15937.5,2,0],[16406.25,3,0],[16875,0,0],[17343.75,1,0],[17812.5,2,0],[18281.25,3,0],
		[18750,0,0],[19218.75,1,0],[19687.5,2,0],[20156.25,3,0],[20625,0,0],[21093.75,1,0],[21562.5,2,0],[22031.25,3,0],
		[22500,3,0],[22968.75,2,0],[23437.5,1,0],[23906.25,0,0],[24375,3,0],[24843.75,2,0],[25312.5,1,0],[25781.25,0,0],
		[26250,3,0],[26718.75,2,0],[27187.5,1,0],[27656.25,0,0],[28125,3,0],[28593.75,2,0],[29062.5,1,0],[29531.25,0,0],
		[30000,0,0],[30468.75,1,0],[30937.5,2,1],[31875,0,0],[32343.75,1,0],[32812.5,2,1],[33750,0,0],[34218.75,1,0],
		[34687.5,2,1],[35625,0,0],[36093.75,1,0],[36562.5,2,1],[37500,3,0],[37968.75,1,0],[38437.5,2,1],[39375,3,0],
		[39843.75,1,0],[40312.5,2,1],[41250,3,0],[41718.75,1,0],[42187.5,2,1],[43125,3,0],[43593.75,1,0],[44062.5,2,1],
		[45000,0,0],[45468.75,2,0],[45937.5,1,1],[46875,0,0],[47343.75,2,0],[47812.5,1,1],[48750,0,0],[49218.75,2,0],
		[49687.5,1,1],[50625,0,0],[51093.75,2,0],[51562.5,1,1],[52500,3,0],[52968.75,2,0],[53437.5,0,1],[54375,3,0],
		[54843.75,2,0],[55312.5,0,1],[56250,3,0],[56718.75,2,0],[57187.5,0,1],[58125,3,0],[58593.75,2,0],[59062.5,0,1],
		[59062.5,1,1]
	];
	static inline var COUNTDOWN_VOLUME:Float = 0.4; // volume des sons du countdown (PlayState : 0.6)
	static inline var PREVIEW_ALPHA:Float = 0.35;   // visibilité des flèches avant de cliquer sur Play Test
	static inline var BAR_H:Float = 28;            // hauteur de la barre noire du haut
	static inline var OFFSET_BAR_X:Float = 10;     // barre d'offset : en haut à gauche, sous la barre noire
	static inline var OFFSET_BAR_Y:Float = 34;
	static inline var STRUM_SIZE:Float = 112;      // 160 * 0.7 (Note.swagWidth)
	static inline var HIT_WINDOW:Float = 166;      // ms (Conductor.safeZoneOffset)
	static inline var SPAWN_TIME:Float = 1000;     // ms d'avance pour faire apparaître une note
	static inline var NOTE_SPEED:Float = 0.8;      // pixels par ms
	static var NOTE_PREFIX:Array<String> = ['purple', 'blue', 'green', 'red'];
	static var DIRECTIONS:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var testing:Bool = false;
	var leadIn:Bool = false;
	var leadInTime:Float = 0;   // durée avant la musique : 5 temps, comme PlayState (-crochet * 5)
	var countdownStep:Int = 0;
	var countdownSprs:Array<FlxSprite> = [];
	var testSongPos:Float = 0;
	var lastMusicTime:Float = 0;
	var spawnIdx:Int = 0;
	var strumY:Float = 50;

	var strums:Array<FlxSprite> = [];
	var strumGroup:FlxTypedGroup<FlxSprite>;
	var testNotes:FlxTypedGroup<TestNote>;
	var splashGroup:FlxTypedGroup<TestSplash>;
	var ratingGroup:FlxTypedGroup<FlxSprite>;
	var ratingSprs:Array<FlxSprite> = [];
	static inline var RATING_SCALE:Float = 0.7;

	// Atlas mis en cache UNE fois (sinon le XML est relu/parsé à chaque note = micro-freezes)
	public static var hudCamera:FlxCamera;
	public static var noteFrames:FlxAtlasFrames;
	public static var splashFrames:FlxAtlasFrames;

	var leaving:Bool = false;

	var playTestBtn:FlxSprite;
	var playTestTxt:FlxText;
	var hintTxt:FlxText;
	static inline var BTN_COLOR:Int = 0xFF2E7D32;
	static inline var BTN_COLOR_HOVER:Int = 0xFF4CAF50;
	static inline var BTN_STOP_COLOR:Int = 0xFFB71C1C;
	static inline var BTN_STOP_COLOR_HOVER:Int = 0xFFE53935;

	override public function create()
	{
		// Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		FlxG.camera.scroll.set(120, 130);

		persistentUpdate = true;
		FlxG.sound.pause();
		// Stage
		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);

		if(!ClientPrefs.lowQuality) {
			var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			add(stageLight);
			var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			stageLight.flipX = true;
			add(stageLight);

			var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			add(stageCurtains);
		}

		// Characters
		gf = new Character(400, 130, 'gf');
		gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
		gf.scrollFactor.set(0.95, 0.95);
		boyfriend = new Character(770, 100, 'bf', true);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(gf);
		add(boyfriend);

		// Note delay stuff
		
		beatText = new Alphabet(0, 0, 'Beat Hit!', true);
		beatText.scaleX = 0.6;
		beatText.scaleY = 0.6;
		beatText.x += 260;
		beatText.alpha = 0;
		beatText.acceleration.y = 250;
		add(beatText);
		
		timeTxt = new FlxText(10, BAR_H + 6, 0, "", 24);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.cameras = [camHUD];

		barPercent = ClientPrefs.noteOffset;
		updateNoteDelay();
		
		timeBarBG = new FlxSprite(OFFSET_BAR_X, OFFSET_BAR_Y).loadGraphic(Paths.image('timeBar'));
		timeBarBG.setGraphicSize(Std.int(timeBarBG.width * 1.2));
		timeBarBG.updateHitbox();
		timeBarBG.cameras = [camHUD];

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'barPercent', delayMin, delayMax);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.cameras = [camHUD];

		// Le texte "Current offset" est centré sur la barre, par-dessus (comme dans l'ancienne version)
		timeTxt.fieldWidth = timeBarBG.width;
		timeTxt.alignment = CENTER;
		timeTxt.x = timeBarBG.x;
		timeTxt.y = timeBarBG.y + (timeBarBG.height - timeTxt.height) / 2;

		add(timeBarBG);
		add(timeBar);
		add(timeTxt);

		///////////////////////

		// Strums + notes du Play Test (cachés tant que le test n'est pas lancé)
		strumY = ClientPrefs.downScroll ? (FlxG.height - 150) : 50; // 50 = STRUM_Y habituel de Psych
		var strumX:Float = (FlxG.width - STRUM_SIZE * 4) / 2;

		hudCamera = camHUD;
		noteFrames = Paths.getSparrowAtlas('NOTE_assets');
		splashFrames = Paths.getSparrowAtlas('noteSplashes');

		strumGroup = new FlxTypedGroup<FlxSprite>();
		for(i in 0...4)
		{
			var s:FlxSprite = new FlxSprite(strumX + STRUM_SIZE * i, strumY);
			s.frames = noteFrames;
			var lower:String = DIRECTIONS[i].toLowerCase();
			s.animation.addByPrefix('static', 'arrow' + DIRECTIONS[i]);
			s.animation.addByPrefix('pressed', lower + ' press', 24, false);
			s.animation.addByPrefix('confirm', lower + ' confirm', 24, false);
			s.setGraphicSize(Std.int(s.width * 0.7));
			s.updateHitbox();
			s.antialiasing = ClientPrefs.globalAntialiasing;
			s.scrollFactor.set();
			s.cameras = [camHUD];
			s.alpha = PREVIEW_ALPHA; // aperçu : atténué et non jouable tant qu'on n'a pas cliqué sur Play Test
			playStrumAnim(s, 'static');
			strums.push(s);
			strumGroup.add(s);
		}
		add(strumGroup);

		// Pool de notes : on les crée à l'avance pour éviter toute allocation pendant le jeu
		testNotes = new FlxTypedGroup<TestNote>();
		for(i in 0...24)
		{
			var n:TestNote = new TestNote();
			testNotes.add(n);
			n.kill();
		}
		add(testNotes);

		// Pool de splashes
		splashGroup = new FlxTypedGroup<TestSplash>();
		for(i in 0...8)
		{
			var sp:TestSplash = new TestSplash();
			splashGroup.add(sp);
			sp.kill();
		}
		splashGroup.visible = false;
		add(splashGroup);

		// Jugements (Sick / Good / Bad / Shit) en haut à droite, sous la barre noire
		ratingGroup = new FlxTypedGroup<FlxSprite>();
		for(name in ['sick', 'good', 'bad', 'shit'])
		{
			var r:FlxSprite = new FlxSprite().loadGraphic(Paths.image(name));
			r.scrollFactor.set();
			r.cameras = [camHUD];
			r.antialiasing = ClientPrefs.globalAntialiasing;
			r.scale.set(RATING_SCALE, RATING_SCALE);
			r.x = (FlxG.width - 20 - r.width * RATING_SCALE / 2) - r.width / 2;
			r.y = (BAR_H + 6 + r.height * RATING_SCALE / 2) - r.height / 2;
			r.alpha = 0;
			ratingSprs.push(r);
			ratingGroup.add(r);
		}
		ratingGroup.visible = false;
		add(ratingGroup);

		hintTxt = new FlxText(10, FlxG.height - 26, 0, "Play your note keys | Mouse wheel: +/-1 ms | ENTER: stop", 18);
		hintTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		hintTxt.scrollFactor.set();
		hintTxt.cameras = [camHUD];
		hintTxt.visible = false;
		add(hintTxt);

		// Précharge les assets du countdown (comme PlayState.cacheCountdown)
		Paths.image('ready');
		Paths.image('set');
		Paths.image('go');
		Paths.sound('intro3');
		Paths.sound('intro2');
		Paths.sound('intro1');
		Paths.sound('introGo');

		var blackBox:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(BAR_H), FlxColor.BLACK);
		blackBox.scrollFactor.set();
		blackBox.alpha = 0.6;
		blackBox.cameras = [camHUD];
		add(blackBox);

		changeModeText = new FlxText(0, 1, FlxG.width, "< NOTE/BEAT DELAY >", 24);
		changeModeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		changeModeText.scrollFactor.set();
		changeModeText.cameras = [camHUD];
		add(changeModeText);

		// Bouton "Play Test" (en haut à droite)
		playTestBtn = new FlxSprite(FlxG.width - 150, 2).makeGraphic(140, 24, FlxColor.WHITE);
		playTestBtn.color = BTN_COLOR;
		playTestBtn.scrollFactor.set();
		playTestBtn.cameras = [camHUD];
		add(playTestBtn);

		playTestTxt = new FlxText(playTestBtn.x, playTestBtn.y + 1, playTestBtn.width, "Play Test", 20);
		playTestTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		playTestTxt.scrollFactor.set();
		playTestTxt.cameras = [camHUD];
		add(playTestTxt);

		FlxG.mouse.visible = true;

		Conductor.changeBPM(128.0);
		FlxG.sound.playMusic(Paths.music('offsetSong'), 1, true);

		super.create();
	}

	var holdTime:Float = 0;

	override public function update(elapsed:Float)
	{
		// Bouton Play Test / Stop Test (clic ou ACCEPT)
		if(!leaving) FlxG.mouse.visible = true;

		// Test de survol "manuel" avec les coordonnées écran de la souris (fiable sur toutes les caméras)
		var mx:Float = FlxG.mouse.screenX;
		var my:Float = FlxG.mouse.screenY;
		var hovering:Bool = !leaving &&
			mx >= playTestBtn.x && mx <= playTestBtn.x + playTestBtn.width &&
			my >= playTestBtn.y && my <= playTestBtn.y + playTestBtn.height;
		if(testing) playTestBtn.color = hovering ? BTN_STOP_COLOR_HOVER : BTN_STOP_COLOR;
		else playTestBtn.color = hovering ? BTN_COLOR_HOVER : BTN_COLOR;

		if(!leaving && ((hovering && FlxG.mouse.justPressed) || controls.ACCEPT))
		{
			if(testing) stopTest();
			else startTest();
		}

		// Molette : ajuste l'offset de 1 ms (utile pendant le test)
		if(FlxG.mouse.wheel != 0)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset + FlxG.mouse.wheel, delayMax));
			updateNoteDelay();
		}

		// Pendant le test, les flèches servent aux notes : on désactive le réglage au clavier
		var allowAdjust:Bool = !testing;

		if(allowAdjust && controls.UI_LEFT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset - 1, delayMax));
			updateNoteDelay();
		}
		else if(allowAdjust && controls.UI_RIGHT_P)
		{
			barPercent = Math.max(delayMin, Math.min(ClientPrefs.noteOffset + 1, delayMax));
			updateNoteDelay();
		}

		var mult:Int = 1;
		if(allowAdjust && (controls.UI_LEFT || controls.UI_RIGHT))
		{
			holdTime += elapsed;
			if(controls.UI_LEFT) mult = -1;
		}

		if(controls.UI_LEFT_R || controls.UI_RIGHT_R) holdTime = 0;

		if(allowAdjust && holdTime > 0.5)
		{
			barPercent += 100 * elapsed * mult;
			barPercent = Math.max(delayMin, Math.min(barPercent, delayMax));
			updateNoteDelay();
		}

		if(controls.RESET)
		{
			holdTime = 0;
			barPercent = 0;
			updateNoteDelay();
		}

		if(controls.BACK && testing)
		{
			stopTest();
		}
		else if(controls.BACK)
		{
			leaving = true;
			FlxG.mouse.visible = false;
			if(zoomTween != null) zoomTween.cancel();
			if(beatTween != null) beatTween.cancel();

			persistentUpdate = false;
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new options.OptionsState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
		}

		// Boyfriend (joueur) : PlayState gère le retour à l'idle, ici c'est à nous de le faire
		var cur = boyfriend.animation.curAnim;
		if(cur != null)
		{
			if(cur.name.startsWith('sing') && !cur.name.endsWith('miss') &&
				boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration)
			{
				boyfriend.dance();
			}
			else if(cur.name.endsWith('miss') && cur.finished)
			{
				boyfriend.dance();
			}
		}

		updateTest(elapsed);
		if(testing && leadIn) Conductor.songPosition = testSongPos;
		else if(FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		super.update(elapsed);
	}

	var zoomTween:FlxTween;
	var lastBeatHit:Int = -1;
	override public function beatHit()
	{
		super.beatHit();

		if(lastBeatHit == curBeat)
		{
			return;
		}

		if(curBeat % 2 == 0)
		{
			var singing:Bool = boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('sing');
			if(!singing) boyfriend.dance();
			gf.dance();
		}
		
		if(curBeat % 4 == 2)
		{
			FlxG.camera.zoom = 1.15;

			if(zoomTween != null) zoomTween.cancel();
			zoomTween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.circOut, onComplete: function(twn:FlxTween)
				{
					zoomTween = null;
				}
			});

			beatText.alpha = 1;
			beatText.y = 350;
			beatText.velocity.y = -150;
			if(beatTween != null) beatTween.cancel();
			beatTween = FlxTween.tween(beatText, {alpha: 0}, 1, {ease: FlxEase.sineIn, onComplete: function(twn:FlxTween)
				{
					beatTween = null;
				}
			});
		}

		lastBeatHit = curBeat;
	}

	// ---------------------------------------------------------------
	// Play Test
	// ---------------------------------------------------------------
	function startTest()
	{
		testing = true;
		holdTime = 0;
		setTestVisible(true);
		playTestTxt.text = 'Stop Test';
		fadeStrums(1); // les flèches deviennent normales
		beginRun();
	}

	function stopTest()
	{
		testing = false;
		leadIn = false;
		clearTestNotes();
		setTestVisible(false);
		for(st in strums) playStrumAnim(st, 'static');
		fadeStrums(PREVIEW_ALPHA); // retour à l'aperçu : flèches atténuées et non jouables
		playTestTxt.text = 'Play Test';
		boyfriend.dance();
		gf.dance();

		// On relance la musique de l'écran (sans la recharger) et l'aperçu du chart avec
		if(FlxG.sound.music != null) FlxG.sound.music.play(true);
		resetPreview();
	}

	function fadeStrums(target:Float)
	{
		for(st in strums)
		{
			FlxTween.cancelTweensOf(st);
			FlxTween.tween(st, {alpha: target}, 0.25);
		}
	}

	// Remet l'aperçu (non jouable) au début du chart, synchronisé avec la musique
	function resetPreview()
	{
		clearTestNotes();
		spawnIdx = 0;
		testSongPos = (FlxG.sound.music != null) ? FlxG.sound.music.time : 0;
		lastMusicTime = testSongPos;
	}

	function setTestVisible(v:Bool)
	{
		splashGroup.visible = v;
		ratingGroup.visible = v;
		hintTxt.visible = v;
	}

	// (Re)démarre le chart depuis le début avec un petit lead-in
	function beginRun()
	{
		if(FlxG.sound.music != null) FlxG.sound.music.stop();
		clearTestNotes();
		spawnIdx = 0;
		leadInTime = Conductor.crochet * 5; // comme PlayState : Conductor.songPosition = -crochet * 5
		testSongPos = -leadInTime;
		countdownStep = 0;
		lastMusicTime = 0;
		leadIn = true;
		boyfriend.dance();
		gf.dance();
	}

	function clearTestNotes()
	{
		for(n in testNotes.members)
		{
			if(n != null) n.kill();
		}
		for(sp in splashGroup.members)
		{
			if(sp != null) sp.kill();
		}
		hideRatings();
		clearCountdown();
	}

	function clearCountdown()
	{
		for(spr in countdownSprs.copy())
		{
			FlxTween.cancelTweensOf(spr);
			remove(spr);
			spr.destroy();
		}
		countdownSprs = [];
	}

	function hideRatings()
	{
		for(r in ratingSprs)
		{
			FlxTween.cancelTweensOf(r);
			FlxTween.cancelTweensOf(r.scale);
			r.alpha = 0;
		}
	}

	// Fait tourner le chart en permanence :
	//  - aperçu (testing = false) : flèches atténuées, non jouables, calées sur la musique du menu
	//  - test (testing = true)    : countdown, puis gameplay normal
	function updateTest(elapsed:Float)
	{
		if(FlxG.sound.music == null) return;

		// --- Position dans la chanson ---
		if(testing && leadIn)
		{
			testSongPos += elapsed * 1000;

			// Mêmes ticks que le FlxTimer de PlayState : un par temps, à -4, -3, -2, -1 et 0 temps
			// (intro3 / ready+intro2 / set+intro1 / go+introGo / rien), puis la musique démarre à 0
			while(countdownStep < 5 && testSongPos >= -leadInTime + (countdownStep + 1) * Conductor.crochet)
			{
				countdownTick(countdownStep);
				countdownStep++;
			}

			if(testSongPos >= 0)
			{
				leadIn = false;
				testSongPos = 0;
				lastMusicTime = 0;
				FlxG.sound.music.play(true); // redémarre à 0 sans recharger le fichier
			}
		}
		else
		{
			var t:Float = FlxG.sound.music.time;
			if(t < lastMusicTime - 500)
			{
				// La musique a bouclé : on recommence le chart
				if(testing) beginRun();
				else resetPreview();
				return;
			}

			// Horloge interne (fluide, indépendante des "paliers" de music.time)...
			testSongPos += elapsed * 1000;

			// ...recalée en douceur sur l'horloge audio.
			// (t == 0 : l'audio n'a pas encore vraiment démarré, on ne corrige pas)
			if(t > 0)
			{
				var drift:Float = t - testSongPos;
				if(Math.abs(drift) > 60) testSongPos = t;                    // gros écart : resync direct
				else if(t != lastMusicTime) testSongPos += drift * 0.15;     // petit écart : correction progressive
			}
			lastMusicTime = t;
		}

		// --- Apparition des notes (pool, aucune allocation) ---
		while(spawnIdx < TEST_CHART.length &&
			TEST_CHART[spawnIdx][0] + ClientPrefs.noteOffset - testSongPos < SPAWN_TIME)
		{
			var data:Array<Float> = TEST_CHART[spawnIdx];
			var lane:Int = Std.int(data[1]);
			var note:TestNote = testNotes.recycle(TestNote);
			note.setup(lane, data[0], strums[lane].x, data.length > 2 && data[2] == 1);
			if(!testing) note.alpha = PREVIEW_ALPHA;
			spawnIdx++;
		}

		// --- Inputs (uniquement pendant le test) ---
		if(testing)
		{
			checkKey(0, controls.NOTE_LEFT_P, controls.NOTE_LEFT_R);
			checkKey(1, controls.NOTE_DOWN_P, controls.NOTE_DOWN_R);
			checkKey(2, controls.NOTE_UP_P, controls.NOTE_UP_R);
			checkKey(3, controls.NOTE_RIGHT_P, controls.NOTE_RIGHT_R);
		}

		// --- Déplacement / miss / nettoyage des notes ---
		var dir:Float = ClientPrefs.downScroll ? 1 : -1;
		for(n in testNotes.members)
		{
			if(n == null || !n.alive) continue;

			var diff:Float = testSongPos - (n.chartTime + ClientPrefs.noteOffset); // > 0 : la note est en retard
			n.y = strumY + diff * NOTE_SPEED * dir;

			if(testing)
			{
				if(!n.wasMissed && diff > HIT_WINDOW)
				{
					n.wasMissed = true;
					n.alpha = 0.3;
					boyfriend.playAnim('sing' + DIRECTIONS[n.lane] + 'miss', true);
					boyfriend.holdTimer = 0;
				}
			}
			else if(diff >= 0)
			{
				n.kill(); // aperçu : la note disparaît en arrivant sur la flèche
			}

			if(diff > 1500) n.kill();
		}

		// --- Fin du chart (test) : on recommence ---
		if(testing && spawnIdx >= TEST_CHART.length && testNotes.countLiving() <= 0 &&
			testSongPos > TEST_CHART[TEST_CHART.length - 1][0] + ClientPrefs.noteOffset + 2000)
		{
			beginRun();
		}
	}

	// Copie de PlayState.startCountdown (timer) : mêmes sons, mêmes images, même animation
	function countdownTick(step:Int)
	{
		var loopsLeft:Int = 4 - step; // équivalent de tmr.loopsLeft

		if(gf != null && loopsLeft % Math.round(gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null &&
			!gf.animation.curAnim.name.startsWith('sing') && !gf.stunned)
		{
			gf.dance();
		}
		if(loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null &&
			!boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}

		switch(step)
		{
			case 0:
				FlxG.sound.play(Paths.sound('intro3'), COUNTDOWN_VOLUME);
			case 1:
				showCountdownSprite('ready');
				FlxG.sound.play(Paths.sound('intro2'), COUNTDOWN_VOLUME);
			case 2:
				showCountdownSprite('set');
				FlxG.sound.play(Paths.sound('intro1'), COUNTDOWN_VOLUME);
			case 3:
				showCountdownSprite('go');
				FlxG.sound.play(Paths.sound('introGo'), COUNTDOWN_VOLUME);
			case 4:
		}
	}

	function showCountdownSprite(image:String)
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();
		spr.screenCenter();
		spr.antialiasing = ClientPrefs.globalAntialiasing;
		insert(members.indexOf(testNotes), spr); // derrière les notes, comme dans PlayState
		countdownSprs.push(spr);
		FlxTween.tween(spr, {alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				countdownSprs.remove(spr);
				remove(spr);
				spr.destroy();
			}
		});
	}

	function checkKey(lane:Int, pressed:Bool, released:Bool)
	{
		if(pressed)
		{
			if(!tryHit(lane)) playStrumAnim(strums[lane], 'pressed');
		}
		if(released) playStrumAnim(strums[lane], 'static');
	}

	// Retourne true si une note a été touchée
	function tryHit(lane:Int):Bool
	{
		var best:TestNote = null;
		var bestDiff:Float = 0;
		for(n in testNotes.members)
		{
			if(n == null || !n.alive || n.lane != lane || n.wasHit || n.wasMissed) continue;
			var d:Float = Math.abs(testSongPos - (n.chartTime + ClientPrefs.noteOffset));
			if(d <= HIT_WINDOW && (best == null || n.chartTime < best.chartTime))
			{
				best = n;
				bestDiff = d;
			}
		}

		if(best == null) return false; // ghost tapping : pas de pénalité

		best.wasHit = true;
		best.kill();

		// Jugement (mêmes fenêtres que Psych : ClientPrefs.sick/good/badWindow)
		var rating:Int = 3; // shit
		if(bestDiff <= ClientPrefs.sickWindow) rating = 0;
		else if(bestDiff <= ClientPrefs.goodWindow) rating = 1;
		else if(bestDiff <= ClientPrefs.badWindow) rating = 2;
		showRating(rating);

		// Splash uniquement sur un "Sick" (comme dans PlayState)
		if(rating == 0 && ClientPrefs.noteSplashes)
		{
			var sp:TestSplash = splashGroup.recycle(TestSplash);
			sp.setup(strums[lane].x, strums[lane].y, lane);
		}

		playStrumAnim(strums[lane], 'confirm');

		boyfriend.playAnim('sing' + DIRECTIONS[lane], true);
		boyfriend.holdTimer = 0;

		// Note "Hey!" : même logique que PlayState.goodNoteHit
		// (specialAnim = true : l'animation se joue en entier puis Character revient à l'idle tout seul)
		if(best.isHey)
		{
			if(boyfriend.animOffsets.exists('hey'))
			{
				boyfriend.playAnim('hey', true);
				boyfriend.specialAnim = true;
			}
			if(gf != null && gf.animOffsets.exists('cheer'))
			{
				gf.playAnim('cheer', true);
				gf.specialAnim = true;
			}
		}
		return true;
	}

	function showRating(idx:Int)
	{
		hideRatings();
		var r:FlxSprite = ratingSprs[idx];
		r.alpha = 1;
		r.scale.set(RATING_SCALE * 1.15, RATING_SCALE * 1.15);
		FlxTween.tween(r.scale, {x: RATING_SCALE, y: RATING_SCALE}, 0.1, {ease: FlxEase.quadOut});
		FlxTween.tween(r, {alpha: 0}, 0.25, {startDelay: 0.5});
	}

	function playStrumAnim(s:FlxSprite, anim:String)
	{
		s.animation.play(anim, true);
		s.centerOffsets();
		s.centerOrigin();
	}

	function updateNoteDelay()
	{
		ClientPrefs.noteOffset = Math.round(barPercent);
		timeTxt.text = 'Current offset: ' + Math.floor(barPercent) + ' ms';
	}
}

// Note minimaliste utilisée uniquement par le Play Test (recyclée via un pool)
class TestNote extends FlxSprite
{
	public var chartTime:Float = 0;
	public var lane:Int = 0;
	public var wasHit:Bool = false;
	public var wasMissed:Bool = false;
	public var isHey:Bool = false; // note "Hey!"

	public function new()
	{
		super();
		frames = NoteOffsetState.noteFrames; // atlas partagé, déjà en cache
		animation.addByPrefix('n0', 'purple0');
		animation.addByPrefix('n1', 'blue0');
		animation.addByPrefix('n2', 'green0');
		animation.addByPrefix('n3', 'red0');
		animation.play('n0');
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
		cameras = [NoteOffsetState.hudCamera];
	}

	public function setup(lane:Int, chartTime:Float, x:Float, isHey:Bool)
	{
		this.isHey = isHey;
		this.lane = lane;
		this.chartTime = chartTime;
		this.x = x;
		wasHit = false;
		wasMissed = false;
		alpha = 1;
		animation.play('n' + lane, true);
	}
}

// Splash affiché quand on touche une note "Sick" (équivalent de NoteSplash, sans dépendance à PlayState)
class TestSplash extends FlxSprite
{
	public function new()
	{
		super();
		frames = NoteOffsetState.splashFrames; // atlas partagé, déjà en cache
		for(i in 1...3)
		{
			animation.addByPrefix('note0-' + i, 'note splash purple ' + i, 24, false);
			animation.addByPrefix('note1-' + i, 'note splash blue ' + i, 24, false);
			animation.addByPrefix('note2-' + i, 'note splash green ' + i, 24, false);
			animation.addByPrefix('note3-' + i, 'note splash red ' + i, 24, false);
		}
		antialiasing = ClientPrefs.globalAntialiasing;
		scrollFactor.set();
		cameras = [NoteOffsetState.hudCamera];
	}

	public function setup(strumX:Float, strumY:Float, lane:Int)
	{
		setPosition(strumX - 112 * 0.95, strumY - 112); // 112 = largeur d'une note (160 * 0.7)
		alpha = 0.6;
		offset.set(10, 10);
		animation.play('note' + lane + '-' + FlxG.random.int(1, 2), true);
		if(animation.curAnim != null) animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	override public function update(elapsed:Float)
	{
		if(animation.curAnim != null && animation.curAnim.finished) kill();
		super.update(elapsed);
	}
}
