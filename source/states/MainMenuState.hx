package states;

#if desktop
import Discord.DiscordClient;
import StringTools;
#end

import states.MainMenuState;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimation;

using StringTools;

typedef MenuArtworkConfig = {
	var x:Float;
	var y:Float;
	var scale:Float;
}

// --- Réglages personnalisables pour CHAQUE bouton du menu ---
typedef MenuItemConfig = {
	?scale:Float,        
	?selectScale:Float,  
	?confirmScale:Float, 
	?offsetX:Float,      
	?offsetY:Float        
}

// --- Sprite de bouton de menu "intelligent" ---
class MenuButton extends FlxSprite
{
	public var idleScale:Float = 1;
	public var selectScale:Float = 1;
	public var confirmScale:Float = 1;
	public var offsetX:Float = 0; 
	public var centerY:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
	}

	public function applyScaleFor(state:String):Void
	{
		var targetScale:Float = idleScale;
		switch (state)
		{
			case 'select':
				targetScale = selectScale;
			case 'confirm':
				targetScale = confirmScale;
			default:
				targetScale = idleScale;
		}

		scale.set(targetScale, targetScale);
		updateHitbox();
		centerOffsets();
		y = centerY - height / 2;
	}
}

// --- Motif "heart" en arrière-plan : défilement continu (gauche/droite mélangés) + flottement organique ---
class FloatingHeart extends FlxSprite
{
	var patternPath:String;
	var goingRight:Bool;
	var canSpin:Bool; // si true, ce sprite a une chance de tourner sur lui-même en continu
	var higherOpacity:Bool; // si true, la plage d'opacité (base + respiration) est plus élevée que la normale

	public function new(patternPath:String, canSpin:Bool = false, higherOpacity:Bool = false)
	{
		super();
		this.patternPath = patternPath;
		this.canSpin = canSpin;
		this.higherOpacity = higherOpacity;
		// Chargé UNE SEULE fois ici (au lieu de le refaire à chaque respawn plus bas) :
		// l'image ne change jamais pour ce sprite pendant toute sa durée de vie.
		loadGraphic(Paths.image(patternPath));
		antialiasing = ClientPrefs.globalAntialiasing;
		respawn(true);
	}

	// (Ré)initialise l'apparence, la direction, la vitesse et le flottement du cœur.
	// initial = true pour le placement de départ (dispersé sur tout l'écran plutôt que hors-champ).
	public function respawn(initial:Bool = false):Void
	{
		angle = FlxG.random.float(-15, 15);

		if (higherOpacity)
			alpha = FlxG.random.float(0.5, 0.75); // plage plus élevée que les autres motifs
		else
			alpha = FlxG.random.float(0.15, 0.35);

		var randScale:Float = FlxG.random.float(0.25, 0.65);
		scale.set(randScale, randScale);
		updateHitbox();

		// Direction aléatoire : certains cœurs partent vers la droite, d'autres vers la gauche
		goingRight = FlxG.random.bool();
		var driftSpeed:Float = FlxG.random.float(20, 55);
		velocity.set(goingRight ? driftSpeed : -driftSpeed, 0);

		if (initial)
			x = FlxG.random.float(-width, FlxG.width);
		else
			x = goingRight ? -width : FlxG.width + width; // réapparaît du côté opposé à sa direction

		y = FlxG.random.float(-40, FlxG.height - height + 40);

		// Flottement vertical organique, indépendant du défilement horizontal
		FlxTween.cancelTweensOf(this, ["y"]);
		var moveY:Float = FlxG.random.float(15, 45) * (FlxG.random.bool() ? 1 : -1);
		FlxTween.tween(this, {y: y + moveY}, FlxG.random.float(2.5, 5.5), {
			ease: FlxEase.quadInOut,
			type: PINGPONG,
			startDelay: FlxG.random.float(0, 1.5)
		});

		// Légère "respiration" de la transparence (comme pour les autres motifs, mais sur une plage plus haute pour higherOpacity)
		FlxTween.cancelTweensOf(this, ["alpha"]);
		FlxTween.tween(this, {alpha: alpha + FlxG.random.float(0.1, 0.2)}, FlxG.random.float(1.5, 3), {
			ease: FlxEase.quadInOut,
			type: PINGPONG,
			startDelay: FlxG.random.float(0, 2)
		});

		// Rotation continue aléatoire (uniquement pour les sprites autorisés à tourner, ex: crystals) :
		// ~40% de chance à chaque (re)spawn, sens et vitesse tirés au sort à chaque fois.
		FlxTween.cancelTweensOf(this, ["angle"]);
		if (canSpin && FlxG.random.bool(40))
		{
			var spinDir:Int = FlxG.random.bool() ? 1 : -1;
			var spinDuration:Float = FlxG.random.float(4, 10); // durée d'un tour complet (plus petit = plus rapide)
			FlxTween.tween(this, {angle: angle + 360 * spinDir}, spinDuration, {
				ease: FlxEase.linear,
				type: LOOPING
			});
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Une fois totalement sorti de l'écran (à droite ou à gauche selon sa direction), on relance le cœur
		if (goingRight && x > FlxG.width + 60)
			respawn();
		else if (!goingRight && x + width < -60)
			respawn();
	}

	// IMPORTANT : les tweens créés dans respawn() sont en PINGPONG/LOOPING, donc à durée infinie.
	// Sans cet override, FlxState.destroy() détruit bien ce sprite, mais le FlxTweenManager global
	// continue de faire vivre les tweens qui le référencent encore -> le sprite ne peut jamais être
	// garbage-collecté, et un nouveau lot s'accumule à chaque aller-retour dans le menu (fuite mémoire).
	override public function destroy():Void
	{
		FlxTween.cancelTweensOf(this);
		super.destroy();
	}
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.3';
	public static var curSelected:Int = 0;
	public static var bgPattern:FlxTypedGroup<FlxSprite>;

	// --- Cache partagé avec les autres menus (Gallery, Options, Credits, ...) ---
	// Résolu une seule fois ici au lieu de refaire des vérifications disque dans chaque état.
	public static var lastBgGraphicPath:String = 'menuBG'; // chemin prêt à être passé à Paths.image()
	public static var lastHeartPath:String = null; // null si le personnage courant n'a pas de motif "heart"
	public static var lastCrystalPaths:Array<String> = []; // vide si le personnage courant n'a pas de motifs "crystal1/2/3"
	public static var bgPatternCrystal:FlxTypedGroup<FlxSprite>;
	public static var lastStarPaths:Array<String> = []; // vide si le personnage courant n'a pas de motifs "star1/2"
	public static var bgPatternStar:FlxTypedGroup<FlxSprite>;

	var menuItems:FlxTypedGroup<MenuButton>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var xOffset:Float = 300; 

	// --- Verrouillage de la galerie ---
	// Calculé une fois dans create(). true = le bouton "gallery" est grisé et inaccessible.
	var galleryLocked:Bool = false;
	var lockedMsgBG:FlxSprite;
	var lockedMsgText:FlxText;
	var lockedMsgTimer:FlxTimer;
	var lockedMsgVisible:Bool = false;
	static inline var GALLERY_LOCKED_TEXT:String = "Please complete all the songs tracks to access the gallery.";

	// --- Système d'image décorative aléatoire au menu ---
	// L'artwork de chaque personnage est rangé avec ses autres images de fond :
	//   images/menuBG/<nom>/<nom>.png   (ex: images/menuBG/metal/metal.png)
	// Chaque sous-dossier de menuBG contenant "<nom>.png" (ou .jpg/.jpeg) est un personnage.
	// menuArtworkKey() est la SEULE source de vérité pour ce chemin (aussi utilisée par GalleryState) :
	// pour changer le nom du fichier (ex: "artwork.png"), ne modifier que cette fonction.
	public static inline var MENU_ARTWORK_FOLDER:String = 'menuBG';
	public static function menuArtworkKey(name:String):String
	{
		return MENU_ARTWORK_FOLDER + '/' + name + '/' + name;
	}
	var artworkFolder:String = MENU_ARTWORK_FOLDER;
	// Liste des noms de personnages disponibles (ex: ['kat', 'sackboy', 'metal']), utilisée
	// comme cheat codes clavier pour forcer le chargement d'un fond précis (voir update()).
	var artworkCheatNames:Array<String> = [];

	// Cache statique du scan disque de artworkFolder : la liste des artworks ne change pas
	// en cours de session (hors changement de mod actif), donc on ne la calcule qu'une fois
	// au lieu de refaire un sys.FileSystem.readDirectory() à CHAQUE retour au menu principal.
	static var cachedArtworkNames:Array<String> = null;
	static var cachedArtworkFolder:String = null;

	var artworkSettings:Map<String, MenuArtworkConfig> = [
		'oceane' => {x: 700, y: 50, scale: 0.8},
		'sackboy' => {x: 750, y: 150, scale: 0.7},
		'metal' => {x: 650, y: 50, scale: 0.7},
	];

	var artworkDefaultX:Float = 450;
	var artworkDefaultY:Float = 50;
	var artworkDefaultScale:Float = 0.5;

	public static var chosenArtwork:String;
	// true = un nouveau personnage/fond/heart sera tiré au sort au prochain create().
	// Reste à false tant qu'on navigue simplement entre les menus (Gallery, Options, Credits, ...).
	// Remis à true uniquement au lancement du jeu (valeur par défaut) et quand une chanson démarre
	// (voir StoryMenuState.selectWeek(), et pareil à ajouter côté Freeplay le cas échéant).
	public static var shouldRerollArtwork:Bool = true;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'gallery',
		'options',
		'credits'
	];

	var menuItemSettings:Map<String, MenuItemConfig> = [
		'story_mode' => {},
		'freeplay'   => {},
		'gallery'    => {},
		'options'    => {},
		'credits'    => {}
	];

	var menuItemGlobalScale:Float = 0.65;
	var menuItemDefaultScale:Float = 0.7;               
	var menuItemSelectScaleMultiplier:Float = 1.1;       
	var menuItemConfirmScaleMultiplier:Float = 1.15;     

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	// --- Affichage "nom + icône" du personnage sélectionné (haut droite) ---
	var selectedCharText:FlxText;
	var selectedCharIcon:FlxSprite;
	var selectedCharIconFolder:String = 'icons'; // dossier attendu : assets/images/icons/icon-<perso>.png
	var selectedCharMargin:Float = 12;
	var selectedCharIconSize:Float = 65; // hauteur cible de l'icône, en pixels

	// Noms d'affichage personnalisés : si un perso n'est pas listé ici, son nom de fichier
	// est utilisé tel quel (1ère lettre en majuscule). Ajoute une ligne par perso au besoin.
	var selectedCharDisplayNames:Map<String, String> = [
		'metal' => 'Metal Mario',
		'oceane' => 'Océane',
		'sackboy' => 'Sackboy',
	];

	// Construit un groupe de cœurs flottants identiques à ceux du menu principal, à partir
	// du motif déjà détecté pour le personnage courant (lastHeartPath). Retourne null si ce
	// personnage n'a pas de motif "heart" -- à vérifier avant d'appeler add() dans l'état appelant.
	public static function createHeartGroup(count:Int = 14):FlxTypedGroup<FlxSprite>
	{
		if (lastHeartPath == null)
			return null;

		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		for (i in 0...count)
			group.add(new FloatingHeart(lastHeartPath));
		return group;
	}

	// Idem que createHeartGroup(), mais pour les 3 motifs "crystal1/2/3" détectés pour le
	// personnage courant (lastCrystalPaths). Retourne null si aucun n'a été trouvé -- à
	// vérifier avant d'appeler add() dans l'état appelant.
	public static function createCrystalGroup(countEach:Int = 5):FlxTypedGroup<FlxSprite>
	{
		if (lastCrystalPaths.length == 0)
			return null;

		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		for (path in lastCrystalPaths)
			for (i in 0...countEach)
				group.add(new FloatingHeart(path, true));
		return group;
	}

	// Idem que createHeartGroup(), mais pour les 2 motifs "star1/2" détectés pour le
	// personnage courant (lastStarPaths). Retourne null si aucun n'a été trouvé -- à
	// vérifier avant d'appeler add() dans l'état appelant.
	public static function createStarGroup(countEach:Int = 7):FlxTypedGroup<FlxSprite>
	{
		if (lastStarPaths.length == 0)
			return null;

		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		for (path in lastStarPaths)
		{
			// "star2" doit rester à 100% d'opacité en permanence, sans variation
			var isStar2:Bool = StringTools.endsWith(path, "/star2");
			for (i in 0...countEach)
				group.add(new FloatingHeart(path, false, isStar2)); // même fonctionnement que "heart" : pas de rotation continue
		}
		return group;
	}

	// Ajoute automatiquement les cœurs, cristaux et/ou étoiles au State passé en paramètre
	public static function addMenuParticles(state:flixel.FlxState):Void
	{
		var heartGroup = createHeartGroup();
		if (heartGroup != null)
			state.add(heartGroup);

		var crystalGroup = createCrystalGroup();
		if (crystalGroup != null)
			state.add(crystalGroup);

		var starGroup = createStarGroup();
		if (starGroup != null)
			state.add(starGroup);
	}

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		// Liste à jour des personnages disponibles, pour les cheat codes de sélection manuelle du fond
		// (passe par le cache statique, voir scanMenuArtworkNamesCached())
		artworkCheatNames = scanMenuArtworkNamesCached(artworkFolder);

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		// --- 1. SÉLECTION DU PERSONNAGE (en premier pour déterminer le fond) ---
		// On ne retire un personnage au sort que si shouldRerollArtwork est vrai (redémarrage du jeu
		// ou nouvelle chanson lancée). En simple navigation entre les menus, on réutilise le même.
		var artworkName:String = (shouldRerollArtwork || chosenArtwork == null) ? getRandomMenuArtwork(artworkFolder) : chosenArtwork;
		shouldRerollArtwork = false;

		// --- 2. DÉTECTION AUTOMATIQUE DU FOND SPÉCIFIQUE ---
		var customBgPath:String = 'menuBG/' + artworkName + '/menuBG_' + artworkName;
		var hasCustomBg:Bool = false;
		
		#if sys
		// Vérifie si le fond existe dans les assets ou dans un potentiel dossier de mod
		if (sys.FileSystem.exists('assets/images/' + customBgPath + '.png') || sys.FileSystem.exists('mods/images/' + customBgPath + '.png')) {
			hasCustomBg = true;
		}
		#end

		// Mis en cache pour que Gallery/Options/Credits/... réutilisent le même fond sans re-scanner le disque
		lastBgGraphicPath = hasCustomBg ? customBgPath : 'menuBG';

		var yScroll:Float = Math.max(0.15 - (0.05 * (optionShit.length - 4)), 0.05);

		// --- 3. CHARGEMENT DU FOND (Base ou Custom) ---
		var bg:FlxSprite = new FlxSprite(-80);
		if (hasCustomBg) {
			bg.loadGraphic(Paths.image(customBgPath)); // Charge automatiquement le fond du personnage
		} else {
			bg.loadGraphic(Paths.image('menuBG')); // Fond par défaut si le personnage n'en a pas
		}

		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		// On met également à jour le flash de sélection (magenta) avec le bon fond
		magenta = new FlxSprite(-80);
		if (hasCustomBg) {
			magenta.loadGraphic(Paths.image(customBgPath));
		} else {
			magenta.loadGraphic(Paths.image('menuDesat'));
		}
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// --- 4. DÉTECTION DU MOTIF (HEART) EN ARRIÈRE-PLAN ANIMÉ (dispersion organique) ---
lastHeartPath = null; // reset : si ce personnage n'a pas de heart, les autres menus n'en afficheront pas non plus
bgPattern = null; // évite de garder une référence obsolète vers le groupe du personnage précédent
#if sys
var patternPath:String = 'menuBG/' + artworkName + '/heart';
if (sys.FileSystem.exists('assets/images/' + patternPath + '.png') || sys.FileSystem.exists('mods/images/' + patternPath + '.png')) {
    lastHeartPath = patternPath; // mis en cache pour Gallery/Options/Credits/...
    bgPattern = new FlxTypedGroup<FlxSprite>();

    var heartCount:Int = 14; // <-- nombre de cœurs affichés à l'écran : augmente/diminue cette valeur à volonté

    for (i in 0...heartCount) {
        var heart:FloatingHeart = new FloatingHeart(patternPath);
        heart.scrollFactor.set(0, yScroll);
        bgPattern.add(heart);
    }

    add(bgPattern);
}
#end

// --- 4bis. DÉTECTION DES MOTIFS (CRYSTAL1/2/3) EN ARRIÈRE-PLAN ANIMÉ -----------------
// Exactement le même fonctionnement que le motif "heart" ci-dessus (classe FloatingHeart
// réutilisée telle quelle), mais pour 3 images distinctes mélangées dans un seul groupe.
lastCrystalPaths = [];
bgPatternCrystal = null;
#if sys
var crystalNames:Array<String> = ['crystal1', 'crystal2', 'crystal3'];
var foundCrystalPaths:Array<String> = [];
for (name in crystalNames)
{
    var cPath:String = 'menuBG/' + artworkName + '/' + name;
    if (sys.FileSystem.exists('assets/images/' + cPath + '.png') || sys.FileSystem.exists('mods/images/' + cPath + '.png'))
        foundCrystalPaths.push(cPath);
}

if (foundCrystalPaths.length > 0)
{
    lastCrystalPaths = foundCrystalPaths; // mis en cache pour Gallery/Options/Credits/...
    bgPatternCrystal = new FlxTypedGroup<FlxSprite>();

    var crystalCountEach:Int = 5; // <-- nombre de cristaux affichés PAR image (x3 images) : augmente/diminue à volonté

    for (path in foundCrystalPaths)
    {
        for (i in 0...crystalCountEach)
        {
            var crystal:FloatingHeart = new FloatingHeart(path, true);
            crystal.scrollFactor.set(0, yScroll);
            bgPatternCrystal.add(crystal);
        }
    }

    add(bgPatternCrystal);
}
#end

// --- 4ter. DÉTECTION DES MOTIFS (STAR1/2) EN ARRIÈRE-PLAN ANIMÉ -----------------------
// Exactement le même fonctionnement que le motif "heart" ci-dessus (classe FloatingHeart
// réutilisée telle quelle, sans rotation continue), mais pour 2 images distinctes mélangées
// dans un seul groupe.
lastStarPaths = [];
bgPatternStar = null;
#if sys
var starNames:Array<String> = ['star1', 'star2'];
var foundStarPaths:Array<String> = [];
for (name in starNames)
{
    var sPath:String = 'menuBG/' + artworkName + '/' + name;
    if (sys.FileSystem.exists('assets/images/' + sPath + '.png') || sys.FileSystem.exists('mods/images/' + sPath + '.png'))
        foundStarPaths.push(sPath);
}

if (foundStarPaths.length > 0)
{
    lastStarPaths = foundStarPaths; // mis en cache pour Gallery/Options/Credits/...
    bgPatternStar = new FlxTypedGroup<FlxSprite>();

    var starCountEach:Int = 7; // <-- nombre d'étoiles affichées PAR image (x2 images) : augmente/diminue à volonté

    for (path in foundStarPaths)
    {
        // "star2" doit rester à 100% d'opacité en permanence, sans variation
        var isStar2:Bool = (path == 'menuBG/' + artworkName + '/star2');

        for (i in 0...starCountEach)
        {
            var star:FloatingHeart = new FloatingHeart(path, false, isStar2); // pas de canSpin=true : comportement identique à "heart"
            star.scrollFactor.set(0, yScroll);
            bgPatternStar.add(star);
        }
    }

    add(bgPatternStar);
}
#end

		// --- 5. AJOUT DE L'ARTWORK DU PERSONNAGE ---
		var artworkCfg:MenuArtworkConfig = artworkSettings.exists(artworkName) ?
			artworkSettings.get(artworkName) :
			{x: artworkDefaultX, y: artworkDefaultY, scale: artworkDefaultScale};

		var menuArtwork:FlxSprite = new FlxSprite(artworkCfg.x, artworkCfg.y);
		menuArtwork.loadGraphic(Paths.image(menuArtworkKey(artworkName)));
		menuArtwork.setGraphicSize(Std.int(menuArtwork.width * artworkCfg.scale));
		menuArtwork.updateHitbox();
		menuArtwork.antialiasing = ClientPrefs.globalAntialiasing;
		menuArtwork.scrollFactor.set(); // reste fixe à l'écran, ne suit pas le défilement du menu
		add(menuArtwork);

		// --- 6. CRÉATION DES BOUTONS DU MENU ---
		// Doit être calculé avant la boucle de création des boutons, pour pouvoir griser "gallery"
		galleryLocked = !GalleryState.isGalleryUnlocked();

		menuItems = new FlxTypedGroup<MenuButton>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var name:String = optionShit[i];

			var yOffset:Float = -210; 
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80 + yOffset;
			var baseY:Float = (i * 140) + offset; 

			var cfg:MenuItemConfig = menuItemSettings.exists(name) ? menuItemSettings.get(name) : {};

			var idleScale:Float = ((cfg.scale != null) ? cfg.scale : menuItemDefaultScale) * menuItemGlobalScale;
			var selScale:Float = (cfg.selectScale != null) ? cfg.selectScale * menuItemGlobalScale : idleScale * menuItemSelectScaleMultiplier;
			var confScale:Float = (cfg.confirmScale != null) ? cfg.confirmScale * menuItemGlobalScale : idleScale * menuItemConfirmScaleMultiplier;
			var offX:Float = (cfg.offsetX != null) ? cfg.offsetX : 0;
			var offY:Float = (cfg.offsetY != null) ? cfg.offsetY : 0;

			var menuItem:MenuButton = new MenuButton(0, baseY);
			menuItem.idleScale = idleScale;
			menuItem.selectScale = selScale;
			menuItem.confirmScale = confScale;
			menuItem.offsetX = offX;

			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + name);

			// Assure-toi de charger tes animations avec les bons préfixes
menuItem.animation.addByIndices('idle', 'idle', [0], "", 24, false);
menuItem.animation.addByPrefix('select', 'select', 24, false); // false = PAS de bouclage auto : on la relance nous-mêmes ci-dessous
menuItem.animation.addByPrefix('confirm', 'confirm', 24, false); // false pour ne pas boucler l'animation de confirmation

			// Le bouclage auto étant désactivé, "select" se termine réellement à chaque cycle -> le
			// finishCallback se déclenche bien (contrairement à une anim en boucle native, où Flixel
			// ne l'appelle jamais). On en profite pour tirer une nouvelle framerate aléatoire AVANT
			// de relancer le cycle manuellement, tant que ce bouton est toujours celui sélectionné.
			menuItem.animation.finishCallback = function(animName:String):Void
			{
				if (animName == 'select' && curSelected == menuItem.ID)
				{
					var selectAnim:FlxAnimation = menuItem.animation.getByName('select');
					if (selectAnim != null)
						selectAnim.frameRate = FlxG.random.int(12, 30); // <-- plage de FPS aléatoire, ajuste à volonté
					menuItem.animation.play('select', true);
				}
			};

			menuItem.scale.set(idleScale, idleScale);
			menuItem.updateHitbox();
			menuItem.centerY = baseY + (menuItem.height / 2) + offY;
			menuItem.applyScaleFor('idle');

			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x -= xOffset;
			menuItem.x += offX;
			menuItems.add(menuItem);

			// Grise visuellement le bouton "gallery" tant qu'il est verrouillé
			if (name == 'gallery' && galleryLocked)
			{
				menuItem.color = 0xFF5A5A5A;
				menuItem.alpha = 0.55;
			}

			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		// --- 7. NOM + ICÔNE DU PERSONNAGE SÉLECTIONNÉ (haut droite de l'écran) ---
		// "artworkName" est le personnage déterminé à l'étape 1 (aléatoire ou cheat code).
		// L'icône est recherchée automatiquement via "icon-" + artworkName, sans jamais planter
		// si le fichier n'existe pas (le texte s'affiche alors seul).
		var charDisplayName:String = selectedCharDisplayNames.exists(artworkName)
			? selectedCharDisplayNames.get(artworkName)
			: (artworkName.length > 0 ? artworkName.substr(0, 1).toUpperCase() + artworkName.substr(1) : artworkName);

		selectedCharIcon = loadCharacterIcon(artworkName);
		if (selectedCharIcon != null)
		{
			selectedCharIcon.setGraphicSize(0, Std.int(selectedCharIconSize));
			selectedCharIcon.updateHitbox();
			selectedCharIcon.x = FlxG.width - selectedCharMargin - selectedCharIcon.width;
			selectedCharIcon.y = selectedCharMargin;
		}

		selectedCharText = new FlxText(0, 0, 0, charDisplayName, 28);
		selectedCharText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		selectedCharText.scrollFactor.set();

		if (selectedCharIcon != null)
		{
			selectedCharText.x = selectedCharIcon.x - selectedCharText.width - 10;
			selectedCharText.y = selectedCharIcon.y + (selectedCharIcon.height - selectedCharText.height) / 2;
		}
		else
		{
			selectedCharText.x = FlxG.width - selectedCharMargin - selectedCharText.width;
			selectedCharText.y = selectedCharMargin;
		}

		// --- Fond noir semi-transparent derrière le texte + l'icône, pour la lisibilité ---
		var bgPadding:Float = 8;
		var bgLeft:Float = selectedCharText.x - bgPadding;
		var bgTop:Float = Math.min(selectedCharText.y, (selectedCharIcon != null ? selectedCharIcon.y : selectedCharText.y)) - bgPadding;
		var bgRight:Float = (selectedCharIcon != null ? selectedCharIcon.x + selectedCharIcon.width : selectedCharText.x + selectedCharText.width) + bgPadding;
		var bgBottom:Float = Math.max(selectedCharText.y + selectedCharText.height, (selectedCharIcon != null ? selectedCharIcon.y + selectedCharIcon.height : selectedCharText.y + selectedCharText.height)) + bgPadding;

		var selectedCharBG:FlxSprite = new FlxSprite(bgLeft, bgTop);
		selectedCharBG.makeGraphic(Std.int(bgRight - bgLeft), Std.int(bgBottom - bgTop), 0xFF000000);
		selectedCharBG.alpha = 0.35; // <-- ajuste la transparence ici si besoin
		selectedCharBG.scrollFactor.set();
		add(selectedCharBG);

		add(selectedCharText);
		if (selectedCharIcon != null)
			add(selectedCharIcon);

		var versionShit:FlxText = new FlxText(0, FlxG.height - 44, FlxG.width - 12, "Based on Psych Engine v" + psychEngineVersion, 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit2:FlxText = new FlxText(0, FlxG.height - 24, FlxG.width - 12, "Multivers Collection " + Application.current.meta.get('version'), 16);
		versionShit2.scrollFactor.set();
		versionShit2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit2);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	var secretBuffer:String = "";
	var secretCode:String = "pipotam";

	override function update(elapsed:Float)
	{
		var key:FlxKey = FlxG.keys.firstJustPressed();
		if (key != FlxKey.NONE)
		{
			var keyName:String = FlxKey.toStringMap.get(key);
			if (keyName != null && keyName.length == 1) 
			{
				secretBuffer += keyName.toLowerCase();

				// Le buffer doit être assez long pour contenir le plus long code possible
				// (le mot secret "pipotam" OU le plus long nom de personnage/cheat de fond)
				var maxBufferLen:Int = secretCode.length;
				for (name in artworkCheatNames)
					if (name.length > maxBufferLen)
						maxBufferLen = name.length;

				if (secretBuffer.length > maxBufferLen)
					secretBuffer = secretBuffer.substr(secretBuffer.length - maxBufferLen);

				if (secretBuffer == secretCode)
				{
					FlxG.sound.play(Paths.sound('pipotam'));
					secretBuffer = "";
				}
				else
				{
					// --- CHEAT CODE : tape le nom d'un personnage (ex: "metal", "kat", "sackboy")
					// pour forcer le chargement immédiat de son fond, sans relancer le jeu ---
					for (name in artworkCheatNames)
					{
						if (name.length > 0 && secretBuffer.endsWith(name.toLowerCase()))
						{
							FlxG.sound.play(Paths.sound('confirmMenu'));
							chosenArtwork = name;
							shouldRerollArtwork = false;
							secretBuffer = "";
							MusicBeatState.switchState(new MainMenuState());
							break;
						}
					}
				}
			}
		}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'gallery' && galleryLocked)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					showGalleryLockedMessage();
				}
				else if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:MenuButton)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							spr.animation.play('confirm');
							spr.applyScaleFor('confirm');

							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'gallery':
										LoadingState.loadAndSwitchState(new GalleryState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:MenuButton)
		{
			spr.screenCenter(X);
			spr.x -= xOffset;
			spr.x += spr.offsetX;
		});
	}

	function getRandomMenuArtwork(folder:String):String
	{
		// J'AI RETIRÉ LA MÉMORISATION ICI (if chosenArtwork != null...)
		// Le jeu va maintenant choisir un personnage différent à CHAQUE FOIS
		// qu'on quitte un sous-menu ou au démarrage !

		var files:Array<String> = scanMenuArtworkNamesCached(folder);

		if (files.length == 0)
		{
			trace('[MainMenuState] Aucun personnage trouvé : il faut mods/images/' + folder + '/<nom>/<nom>.png (ou dans assets/images/), vérifie le chemin.');
			chosenArtwork = 'kat';
			return chosenArtwork;
		}

		chosenArtwork = files[FlxG.random.int(0, files.length - 1)];
		return chosenArtwork;
	}

	// Recherche automatiquement "icons/icon-<name>.png" (convention Psych Engine) et renvoie
	// un FlxSprite prêt à l'emploi, ou null si le fichier n'existe pas (aucun crash).
	// Gère aussi bien une icône simple (150x150) qu'une icône "double frame" classique
	// (normal + losing, largeur = 2x la hauteur) : dans ce cas seule la 1ère frame est affichée.
	function loadCharacterIcon(name:String):FlxSprite
	{
		var iconPath:String = selectedCharIconFolder + '/icon-' + name;
		var iconExists:Bool = false;

		#if sys
		if (sys.FileSystem.exists('assets/images/' + iconPath + '.png') || sys.FileSystem.exists('mods/images/' + iconPath + '.png'))
			iconExists = true;
		#end

		if (!iconExists)
		{
			trace('[MainMenuState] Aucune icône trouvée pour "' + name + '" (assets/images/' + iconPath + '.png), le texte s\'affichera sans icône.');
			return null;
		}

		var icon:FlxSprite = new FlxSprite();
		var graphic = Paths.image(iconPath);
		icon.loadGraphic(graphic);

		// Détecte le format "double frame" (normal / losing) et n'affiche que la 1ère frame
		if (icon.frameWidth == icon.frameHeight * 2)
		{
			icon.loadGraphic(graphic, true, Std.int(icon.frameHeight), icon.frameHeight);
			icon.animation.add('icon', [0]);
			icon.animation.play('icon');
		}

		icon.antialiasing = ClientPrefs.globalAntialiasing;
		icon.scrollFactor.set();
		return icon;
	}

	// Version mise en cache de scanMenuArtworkNames() : le scan disque réel n'est fait
	// qu'une seule fois par dossier (premier appel), puis le résultat est réutilisé pour
	// tous les create() suivants du menu principal. Se réinitialise automatiquement si
	// jamais le dossier demandé change (changement de mod, etc.).
	function scanMenuArtworkNamesCached(folder:String):Array<String>
	{
		if (cachedArtworkNames == null || cachedArtworkFolder != folder)
		{
			cachedArtworkNames = scanMenuArtworkNames(folder);
			cachedArtworkFolder = folder;
		}
		return cachedArtworkNames;
	}

	// Scanne le dossier des artworks et renvoie la liste de tous les noms de personnages
	// disponibles (sans extension), en minuscules. Utilisé par le tirage aléatoire ci-dessus
	// ET par les cheat codes de sélection manuelle du fond (voir update()).
	// NE PLUS APPELER DIRECTEMENT ailleurs que depuis scanMenuArtworkNamesCached() ci-dessus :
	// c'est un vrai accès disque, à réserver au premier scan.
	function scanMenuArtworkNames(folder:String):Array<String>
	{
		var files:Array<String> = [];

		#if sys
		// Un personnage = un sous-dossier <folder>/<nom>/ qui contient son artwork "<nom>.png"
		// (voir menuArtworkKey()). Les sous-dossiers sans artwork (ex: fond seul) sont ignorés.
		// Racines "images/" scannées, par ordre de priorité (les doublons de nom sont ignorés) :
		//  1. mods/images/                -> emplacement voulu
		//  2. mods/<mod actif>/images/    -> via Paths.modFolders (si le dossier est dans un mod)
		//  3. assets/images/              -> repli sur l'ancien emplacement
		var imageRoots:Array<String> = ['mods/images/'];
		#if MODS_ALLOWED
		imageRoots.push(Paths.modFolders('images') + '/');
		#end
		imageRoots.push('assets/images/');

		for (imgRoot in imageRoots)
		{
			var dirPath:String = imgRoot + folder + '/';
			if (!sys.FileSystem.exists(dirPath) || !sys.FileSystem.isDirectory(dirPath))
				continue;

			for (name in sys.FileSystem.readDirectory(dirPath))
			{
				if (files.indexOf(name) != -1)
					continue;

				for (ext in ['png', 'jpg', 'jpeg'])
				{
					if (sys.FileSystem.exists(imgRoot + menuArtworkKey(name) + '.' + ext))
					{
						files.push(name);
						break;
					}
				}
			}
		}
		#end

		return files;
	}

function changeItem(huh:Int = 0)
{
	curSelected += huh;

	if (curSelected >= menuItems.length)
		curSelected = 0;
	if (curSelected < 0)
		curSelected = menuItems.length - 1;

	// Utilise MenuButton ici au lieu de FlxSprite
	menuItems.forEach(function(spr:MenuButton)
	{
		if (spr.ID == curSelected)
		{
			spr.animation.play('select');
			spr.applyScaleFor('select'); // Déclenche ta logique de centrage et de taille

			var add:Float = 0;
			if (menuItems.length > 4) add = menuItems.length * 8;

			camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
		}
		else
		{
			spr.animation.play('idle');
			spr.applyScaleFor('idle'); // Déclenche ta logique de centrage et de taille
		}
	});
}

	/**
	 * Affiche "Please complete all the songs tracks to access the gallery."
	 * sur un carré noir semi-transparent, par-dessus le menu, pendant quelques secondes.
	 * Empêche l'empilement si le joueur spam la touche ACCEPT sur "gallery".
	 */
	function showGalleryLockedMessage():Void
	{
		if (lockedMsgVisible) return;
		lockedMsgVisible = true;

		if (lockedMsgTimer != null) lockedMsgTimer.cancel();

		if (lockedMsgText == null)
		{
			lockedMsgText = new FlxText(0, 0, 560, GALLERY_LOCKED_TEXT, 32);
			lockedMsgText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
			lockedMsgText.scrollFactor.set();

			var padding:Float = 30;
			lockedMsgBG = new FlxSprite().makeGraphic(Std.int(lockedMsgText.width + padding * 2), Std.int(lockedMsgText.height + padding * 2), 0xFF000000);
			lockedMsgBG.scrollFactor.set();

			add(lockedMsgBG);
			add(lockedMsgText);
		}

		FlxTween.cancelTweensOf(lockedMsgBG);
		FlxTween.cancelTweensOf(lockedMsgText);

		lockedMsgBG.screenCenter();
		lockedMsgText.screenCenter();

		// Toujours au-dessus du reste (menu, particules, etc.)
		lockedMsgBG.cameras = [FlxG.camera];
		lockedMsgText.cameras = [FlxG.camera];

		var bgTargetAlpha:Float = 0.75; // "légèrement transparent" tout en restant lisible sur un fond clair/chargé
		var fadeDuration:Float = 0.25;

		lockedMsgBG.visible = true;
		lockedMsgText.visible = true;
		lockedMsgBG.alpha = 0;
		lockedMsgText.alpha = 0;

		FlxTween.tween(lockedMsgBG, {alpha: bgTargetAlpha}, fadeDuration, {ease: FlxEase.quadOut});
		FlxTween.tween(lockedMsgText, {alpha: 1}, fadeDuration, {ease: FlxEase.quadOut});

		lockedMsgTimer = new FlxTimer().start(2.2, function(tmr:FlxTimer)
		{
			FlxTween.tween(lockedMsgBG, {alpha: 0}, fadeDuration, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween)
				{
					lockedMsgBG.visible = false;
				}
			});
			FlxTween.tween(lockedMsgText, {alpha: 0}, fadeDuration, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween)
				{
					lockedMsgText.visible = false;
					lockedMsgVisible = false;
				}
			});
		});
	}
}