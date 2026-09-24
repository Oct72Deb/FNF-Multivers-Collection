package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextFormat;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import Paths;
import StringTools;
import Highscore;
import states.FreeplayState;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;
#if MODS_ALLOWED
import sys.FileSystem;
#end

class GalleryState extends MusicBeatState {

    static inline var MUSIC_DESC_LINE_SPACING:Int = 8;
    static inline var OC_DESC_LINE_SPACING:Int = 8;

    static function loadGalleryGraphic(relPath:String):FlxGraphic {
        #if MODS_ALLOWED
        var modPath:String = Paths.modFolders(relPath);
        if (FileSystem.exists(modPath)) {
            if (!Paths.currentTrackedAssets.exists(modPath)) {
                var bmp:openfl.display.BitmapData = openfl.display.BitmapData.fromFile(modPath);
                var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bmp, false, modPath);
                graphic.persist = true;
                Paths.currentTrackedAssets.set(modPath, graphic);
            }
            Paths.localTrackedAssets.push(modPath);
            return Paths.currentTrackedAssets.get(modPath);
        }
        #end

        var path:String = Paths.getPath(relPath, IMAGE);
        if (OpenFlAssets.exists(path, IMAGE)) {
            if (!Paths.currentTrackedAssets.exists(path)) {
                var graphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
                graphic.persist = true;
                Paths.currentTrackedAssets.set(path, graphic);
            }
            Paths.localTrackedAssets.push(path);
            return Paths.currentTrackedAssets.get(path);
        }

        trace('[GalleryState] Graphique introuvable : $path');
        return null;
    }

    // Icônes des onglets principaux (en haut à droite) : toujours dans mods/<mod>/gallery/hud/
    static function loadHudGraphic(key:String):FlxGraphic {
        return loadGalleryGraphic('gallery/hud/$key.png');
    }

    static function listGalleryImagesInFolder(subfolder:String):Array<String> {
        var result:Array<String> = [];
        var seen:Map<String, Bool> = new Map();

        #if MODS_ALLOWED
        // Mods : on lit directement le système de fichiers, comme pour loadHudGraphic().
        var modDir:String = Paths.modFolders('gallery/images/' + subfolder);
        if (FileSystem.exists(modDir) && FileSystem.isDirectory(modDir)) {
            for (file in FileSystem.readDirectory(modDir)) {
                if (!StringTools.endsWith(file.toLowerCase(), ".png")) continue;
                var base:String = file.substr(0, file.length - 4);
                var key:String = subfolder + '/' + base;
                if (!seen.exists(key)) {
                    seen.set(key, true);
                    result.push(key);
                }
            }
        }
        #end

        // Jeu de base : OpenFlAssets.list() renvoie l'ID de TOUS les assets IMAGE connus,
        // qu'ils soient sur disque ou empaquetés. C'est la seule méthode qui fonctionne de
        // façon fiable sur toutes les cibles (contrairement à FileSystem, qui ne marche
        // que pour les mods, dont les fichiers restent toujours de vrais fichiers séparés).
        var prefix:String = 'gallery/images/' + subfolder + '/';
        for (id in OpenFlAssets.list(IMAGE)) {
            var idx:Int = id.indexOf(prefix);
            if (idx == -1) continue;

            var rest:String = id.substr(idx + prefix.length);
            if (rest.indexOf("/") != -1) continue; // ignore les sous-dossiers plus profonds
            if (!StringTools.endsWith(rest.toLowerCase(), ".png")) continue;

            var base:String = rest.substr(0, rest.length - 4);
            var key:String = subfolder + '/' + base;
            if (!seen.exists(key)) {
                seen.set(key, true);
                result.push(key);
            }
        }

        result.sort(function(a:String, b:String):Int return (a < b) ? -1 : ((a > b) ? 1 : 0));
        return result;
    }

    static function listGalleryMusicsInFolder(subfolder:String):Array<String> {
        var result:Array<String> = [];
        var seen:Map<String, Bool> = new Map();

        #if MODS_ALLOWED
        var modDir:String = Paths.modFolders('gallery/musics/' + subfolder);
        if (FileSystem.exists(modDir) && FileSystem.isDirectory(modDir)) {
            for (file in FileSystem.readDirectory(modDir)) {
                if (!StringTools.endsWith(file.toLowerCase(), ".ogg")) continue;
                var base:String = file.substr(0, file.length - 4);
                var key:String = subfolder + '/' + base;
                if (!seen.exists(key)) {
                    seen.set(key, true);
                    result.push(key);
                }
            }
        }
        #end

        var prefix:String = 'gallery/musics/' + subfolder + '/';
        for (id in OpenFlAssets.list(SOUND)) {
            var idx:Int = id.indexOf(prefix);
            if (idx == -1) continue;

            var rest:String = id.substr(idx + prefix.length);
            if (rest.indexOf("/") != -1) continue; // ignore les sous-dossiers plus profonds
            if (!StringTools.endsWith(rest.toLowerCase(), ".ogg")) continue;

            var base:String = rest.substr(0, rest.length - 4);
            var key:String = subfolder + '/' + base;
            if (!seen.exists(key)) {
                seen.set(key, true);
                result.push(key);
            }
        }

        result.sort(function(a:String, b:String):Int return (a < b) ? -1 : ((a > b) ? 1 : 0));
        return result;
    }

    static var IMAGE_AUTHORS:Map<String, String> = [
        "concepts/conceptmark" => "Dorix",
        "concepts/artworkmetal" => "Dorix",
        "concepts/artworkthatou" => "Dorix",
        "concepts/metalconcept" => "Dorix",
        "sketches/sketchmetal" => "Dorix",
        "sketches/sketchthatou" => "Thatou",
    ];

    static function authorForImage(key:String):String {
        return IMAGE_AUTHORS.exists(key) ? IMAGE_AUTHORS.get(key) : null;
    }

    static var MUSIC_AUTHORS:Map<String, String> = [
        "concepts/tes" => "Nanza",
        "concepts/dokis" => "Nanza",
        "early/gameoverold" => "Dorix",
        "early/newgame" => "TechnoBoy Musics",
        "early/periple" => "Nanza",
        "early/trick-or-treating" => "Dorix",
        "early/shrinkdown" => "Dorix",
        "early/metal-reflection" => "Dorix",
        "early/starlight" => "Dorix",
    ];

    static function authorForMusic(key:String):String {
        return MUSIC_AUTHORS.exists(key) ? MUSIC_AUTHORS.get(key) : null;
    }

    static var MUSIC_DESCRIPTIONS:Map<String, String> = [
        "concepts/tes" => "",
        "early/gameoverold" => "",
        "early/shrinkdown" => "Shrinkdown is a song that was removed from the mod. Originally, it was supposed to replace Periple, but we eventually ran out of inspiration and couldn't continue working on it. The opponent was meant to be somewhat similar to Mary, despite the fact that the song's concept was mainly based around BF shrinking.",
    ];

    static function descriptionForMusic(key:String):String {
        return MUSIC_DESCRIPTIONS.exists(key) ? MUSIC_DESCRIPTIONS.get(key) : null;
    }

    /**
     * Redimensionne un FlxSprite pour qu'il rentre dans une boîte (boxX, boxY, boxW, boxH)
     * SANS déformer l'image (une seule et même échelle est appliquée sur les deux axes),
     * puis le centre à l'intérieur de cette boîte. Utilisé pour les logos du menu Images,
     * qui n'ont pas forcément le même ratio largeur/hauteur que l'emplacement qui leur est réservé.
     */
    static function fitSpriteInBox(sprite:FlxSprite, boxX:Float, boxY:Float, boxW:Float, boxH:Float) {
        sprite.scale.set(1, 1);
        sprite.updateHitbox();

        var scale:Float = Math.min(boxW / sprite.width, boxH / sprite.height);
        sprite.scale.set(scale, scale);
        sprite.updateHitbox();

        sprite.x = boxX + (boxW - sprite.width) / 2;
        sprite.y = boxY + (boxH - sprite.height) / 2;
    }

    // Noms des musiques cachées (bonus), exclues de la condition de déblocage.
    // Ecris-les EXACTEMENT comme le nom de chanson tel qu'il apparaît dans la week (song[0]).
    static var HIDDEN_SONGS:Array<String> = ["Criminal Targets", "Crash Out"];

    var musicInfoBG:FlxSprite;
    var musicInfoText:FlxText;

    // Encart descriptif optionnel affiché au-dessus du titre pour les musiques (voir MUSIC_DESCRIPTIONS)
    var musicDescBG:FlxSprite;
    var musicDescText:FlxText;

    var curCategory:String = "Images"; // "Images" ou "Music"
    var curImagesSubCategory:String = "Characters"; // "Characters", "Concepts" ou "Sketches" (sous-catégorie de "Images")
    var curMusicsSubCategory:String = "Concepts"; // "Concepts" ou "Early" (sous-catégorie de "Music")

    // Initialisation déplacée dans create() pour éviter l'erreur de compilation
    // "images" pointe vers la liste actuellement affichée (conceptImages ou sketchImages selon
    // la sous-catégorie active) : cela permet de réutiliser changeSelection() sans le modifier.
    // Même principe pour "musics" -> conceptMusics ou earlyMusics selon la sous-catégorie active.
    var images:Array<GalleryImage>;
    var conceptImages:Array<GalleryImage>;  // toutes les images de mods/<mod>/gallery/images/concepts/
    var sketchImages:Array<GalleryImage>;   // toutes les images de mods/<mod>/gallery/images/sketches/
    var musics:Array<GalleryMusic>;
    var conceptMusics:Array<GalleryMusic>;  // toutes les musiques de mods/<mod>/gallery/musics/concepts/
    var earlyMusics:Array<GalleryMusic>;    // toutes les musiques de mods/<mod>/gallery/musics/early/
    var ocs:Array<GalleryOC>;

    // --- Système d'auteurs ---
    // Il n'y a plus de liste d'auteurs à déclarer ici : l'auteur passé à addImageToList()/addMusic()
    // est recherché directement dans CreditsState.creditsList (voir resolveAuthor()).
    // authorIcon / authorNameText sont juste les sprites qui affichent le résultat.
    var authorIcon:FlxSprite;
    var authorNameText:FlxText;
    var authorIconSize:Float = 64; // taille (en pixels) de l'icône d'auteur affichée en bas à droite

    var curSelected:Int = 0;
    var curOCSelected:Int = 0;

    var bg:FlxSprite;
    var imageDisplay:FlxSprite;
    var nameText:FlxText;
    var intendedColor:Int;
    var colorTween:FlxTween;

    var audioPlayer:FlxSound;

    // UI catégories (icônes cliquables, en haut à droite)
    var imagesTab:FlxSprite;
    var musicTab:FlxSprite;

    // --- Écran de sélection "Images" (menu avec les 3 logos) ---
    // Affiché dès qu'on entre dans la catégorie "Images" ; masqué dès qu'on clique sur un logo.
    // imagesMenuOpen == true  -> on voit les 3 logos, pas de contenu affiché
    // imagesMenuOpen == false -> on voit le contenu de curImagesSubCategory (Characters/Concepts/Sketches)
    var imagesMenuOpen:Bool = true;

    // Logos cliquables, chargés depuis mods/<mod>/gallery/images/characters.png, concepts.png, sketches.png
    // Disposition : Characters en haut (pleine largeur), Sketches en bas à gauche, Concepts en bas à droite
    var menuLogoCharacters:FlxSprite;
    var menuLogoConcepts:FlxSprite;
    var menuLogoSketches:FlxSprite;

    // --- Écran de sélection "Music" (menu avec les 2 logos) ---
    // Même principe que pour "Images" : affiché dès qu'on entre dans la catégorie "Music",
    // masqué dès qu'on clique sur un logo.
    var musicsMenuOpen:Bool = true;

    // Logos cliquables, chargés depuis mods/<mod>/gallery/musics/concepts.png et early.png
    // Disposition : Concepts à gauche, Early à droite (moitié de l'écran chacun)
    var musicMenuLogoConcepts:FlxSprite;
    var musicMenuLogoEarly:FlxSprite;

    // --- Présentation des OC (Original Characters) ---
    var ocInfoGroup:FlxSpriteGroup;    // conteneur unique pour tout le panneau OC (permet de tout animer en un bloc, sans dérive)
    var ocInfoPanelBG:FlxSprite;       // fond semi-transparent derrière les infos
    var ocNameText:FlxText;            // nom du personnage, en grand, coloré selon l'accent de l'OC
    var ocHeightText:FlxText;          // "Taille : ..."
    var ocDangerLabelText:FlxText;     // "Danger de l'adversaire :"
    var ocDangerBadgeBG:FlxSprite;     // pastille colorée selon le niveau de danger
    var ocDangerBadgeText:FlxText;     // texte à l'intérieur du badge (ex: "NORMAL")
    var ocDivider:FlxSprite;           // ligne de séparation entre les stats et la description
    var ocDescriptionText:FlxText;     // description du personnage
    var ocPageText:FlxText;            // pagination "1 / N"

    var OC_PANEL_X:Float;
    var OC_PANEL_Y:Float;
    var OC_PANEL_W:Float;
    var OC_PANEL_H:Float;
    var ocArtwork:FlxSprite; // colonne de droite : artwork, entièrement personnalisable par OC

    // Nouveaux éléments de barre de progression
    var progressBarBG:FlxSprite;
    var progressBar:FlxSprite;
    var timeText:FlxText;

    // Flèches de navigation gauche/droite
    var leftArrow:FlxText;
    var rightArrow:FlxText;

    // true dès que le retour au menu principal est lancé : ignore toute entrée pendant le fondu de sortie
    // (nécessaire depuis que l'état reste actif pendant les transitions, voir persistentUpdate dans create()).
    var leaving:Bool = false;

    override function create() {
        super.create();

        // --- Vérification de déblocage de la galerie ---
        // Si le joueur n'a pas encore complété toutes les musiques "non cachées",
        // on annule l'entrée dans la galerie et on revient au menu.
        if (!isGalleryUnlocked()) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            showLockedMessage();
            return;
        }

        // Garde cet état actif pendant le fondu d'entrée (CustomFadeTransition, ~0.7 s). Sans ça, Flixel fige
        // tout l'état tant que ce sous-état est ouvert : particules immobiles et aucune interaction possible.
        // C'est le même réglage que MainMenuState. Volontairement placé APRÈS le test de verrouillage, pour ne
        // pas modifier l'écran "galerie verrouillée" (où les éléments d'interface n'existent pas).
        persistentUpdate = true;

        // Initialisation des tableaux
        images = [];
        musics = [];
        ocs = [];

        FlxG.mouse.visible = true;

        FlxG.sound.playMusic(Paths.music("ludum_dare_prototype"), 0.8, true);

        // Même fond que celui affiché derrière le personnage dans le menu principal (mis en cache par MainMenuState)
        bg = new FlxSprite().loadGraphic(Paths.image(MainMenuState.lastBgGraphicPath));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.screenCenter();
        add(bg);

// Ajoute automatiquement les particules (cœurs et/ou cristaux) selon le personnage en cache
		MainMenuState.addMenuParticles(this);

        // UI catégories : icônes cliquables en haut à droite (remplacent les anciens textes "Images"/"Music")
        // Les fichiers sont attendus dans mods/<mod>/gallery/hud/images.png et mods/<mod>/gallery/hud/musics.png
        // -> adapte les noms de fichiers ci-dessous si tes graphiques portent un autre nom.
        var hudTabPadding:Float = 20;  // marge par rapport au bord droit et entre les deux icônes
        var hudTabY:Float = 0;        // distance par rapport au haut de l'écran
        var hudTabSize:Float = 46;     // <- change cette valeur pour réduire/agrandir les icônes (hauteur en pixels)

        musicTab = new FlxSprite().loadGraphic(loadHudGraphic('musics'));
        musicTab.antialiasing = ClientPrefs.globalAntialiasing;
        musicTab.scrollFactor.set();
        musicTab.setGraphicSize(0, Std.int(hudTabSize)); // 0 = largeur calculée automatiquement (ratio conservé)
        musicTab.updateHitbox(); // recalcule width/height après le resize, indispensable pour un positionnement correct
        musicTab.x = FlxG.width - musicTab.width - hudTabPadding;
        musicTab.y = hudTabY;
        add(musicTab);

        imagesTab = new FlxSprite().loadGraphic(loadHudGraphic('images'));
        imagesTab.antialiasing = ClientPrefs.globalAntialiasing;
        imagesTab.scrollFactor.set();
        imagesTab.setGraphicSize(0, Std.int(hudTabSize));
        imagesTab.updateHitbox();
        imagesTab.x = musicTab.x - imagesTab.width - hudTabPadding;
        imagesTab.y = hudTabY;
        add(imagesTab);

        // Écran de sélection "Images" : 3 gros logos cliquables, disposés comme sur ta maquette
        // (Characters en haut sur toute la largeur, Sketches en bas à gauche, Concepts en bas à droite).
        // Icônes attendues dans : mods/<mod>/gallery/images/characters.png, concepts.png, sketches.png
        var menuPadding:Float = 24;                          // marge extérieure et espace entre les logos
        var menuTop:Float = imagesTab.y + imagesTab.height + 30; // sous les icônes Images/Music en haut à droite
        var menuBottom:Float = FlxG.height - menuPadding;
        var menuAreaW:Float = FlxG.width - menuPadding * 2;
        var menuAreaH:Float = menuBottom - menuTop;

        // "Characters" est volontairement un peu plus petit que toute la largeur/hauteur
        // disponible (moins écrasant, mieux équilibré visuellement avec la rangée du bas).
        var menuCharactersW:Float = menuAreaW * 0.86;                         // largeur du bandeau "Characters"
        var menuCharactersH:Float = menuAreaH * 0.46;                        // hauteur du bandeau "Characters"
        var menuCharactersX:Float = menuPadding + (menuAreaW - menuCharactersW) / 2; // centré horizontalement

        var menuBottomY:Float = menuTop + menuCharactersH + menuPadding * 2;  // un peu plus d'espace entre les 2 rangées
        var menuBottomColW:Float = (menuAreaW - menuPadding) / 2;             // largeur de "l'emplacement" de chaque logo du bas
        var menuBottomColH:Float = menuBottom - menuBottomY;                  // hauteur de "l'emplacement" de chaque logo du bas

        // Sketches/Concepts occupent un peu moins que tout leur emplacement, et restent centrés dedans.
        var menuBottomShrink:Float = 0.88;
        var menuBottomW:Float = menuBottomColW * menuBottomShrink;
        var menuBottomH:Float = menuBottomColH * menuBottomShrink;
        var menuBottomOffsetX:Float = (menuBottomColW - menuBottomW) / 2;
        var menuBottomOffsetY:Float = (menuBottomColH - menuBottomH) / 2;

        menuLogoCharacters = new FlxSprite().loadGraphic(loadGalleryGraphic('gallery/images/characters.png'));
        menuLogoCharacters.antialiasing = ClientPrefs.globalAntialiasing;
        menuLogoCharacters.scrollFactor.set();
        fitSpriteInBox(menuLogoCharacters, menuCharactersX, menuTop, menuCharactersW, menuCharactersH);
        add(menuLogoCharacters);

        menuLogoSketches = new FlxSprite().loadGraphic(loadGalleryGraphic('gallery/images/sketches.png'));
        menuLogoSketches.antialiasing = ClientPrefs.globalAntialiasing;
        menuLogoSketches.scrollFactor.set();
        fitSpriteInBox(menuLogoSketches, menuPadding + menuBottomOffsetX, menuBottomY + menuBottomOffsetY, menuBottomW, menuBottomH);
        add(menuLogoSketches);

        menuLogoConcepts = new FlxSprite().loadGraphic(loadGalleryGraphic('gallery/images/concepts.png'));
        menuLogoConcepts.antialiasing = ClientPrefs.globalAntialiasing;
        menuLogoConcepts.scrollFactor.set();
        fitSpriteInBox(menuLogoConcepts, menuPadding + menuBottomColW + menuPadding + menuBottomOffsetX, menuBottomY + menuBottomOffsetY, menuBottomW, menuBottomH);
        add(menuLogoConcepts);

        // Écran de sélection "Music" : 2 logos cliquables, Concepts à gauche / Early à droite,
        // chacun occupant la moitié de la largeur disponible et toute la hauteur.
        // Icônes attendues dans : mods/<mod>/gallery/musics/concepts.png, early.png
        var musicMenuColW:Float = (menuAreaW - menuPadding) / 2;

        musicMenuLogoConcepts = new FlxSprite().loadGraphic(loadGalleryGraphic('gallery/musics/concepts.png'));
        musicMenuLogoConcepts.antialiasing = ClientPrefs.globalAntialiasing;
        musicMenuLogoConcepts.scrollFactor.set();
        fitSpriteInBox(musicMenuLogoConcepts, menuPadding, menuTop, musicMenuColW, menuAreaH);
        add(musicMenuLogoConcepts);

        musicMenuLogoEarly = new FlxSprite().loadGraphic(loadGalleryGraphic('gallery/musics/early.png'));
        musicMenuLogoEarly.antialiasing = ClientPrefs.globalAntialiasing;
        musicMenuLogoEarly.scrollFactor.set();
        fitSpriteInBox(musicMenuLogoEarly, menuPadding + musicMenuColW + menuPadding, menuTop, musicMenuColW, menuAreaH);
        add(musicMenuLogoEarly);

        // --- Images des sous-catégories "Concepts" et "Sketches" ---
        // Plus besoin de les déclarer une par une : TOUTES les images .png présentes dans
        // mods/<mod>/gallery/images/concepts/ et mods/<mod>/gallery/images/sketches/ sont chargées
        // automatiquement (et via le mod actif le cas échéant). Il suffit de déposer les
        // fichiers .png dans le bon dossier pour qu'ils apparaissent dans la galerie.
        // Le nom affiché est déduit du nom de fichier (underscores/tirets remplacés par des espaces) ;
        // si un rendu différent est voulu pour une image précise, utilise addImageToList() ci-dessous.
        conceptImages = buildImageListFromFolder("concepts");
        sketchImages = buildImageListFromFolder("sketches");

        // --- Musiques des sous-catégories "Concepts" et "Early" ---
        // Comme pour les images, TOUTES les musiques .ogg présentes dans
        // mods/<mod>/gallery/musics/concepts/ et mods/<mod>/gallery/musics/early/ sont chargées
        // automatiquement (et via le mod actif le cas échéant). Il suffit de déposer les
        // fichiers .ogg dans le bon dossier pour qu'ils apparaissent dans la galerie.
        // Le nom affiché est déduit du nom de fichier ; pour renseigner un auteur,
        // voir la table MUSIC_AUTHORS tout en haut du fichier.
        conceptMusics = buildMusicListFromFolder("concepts");
        earlyMusics = buildMusicListFromFolder("early");

        // --- OC (Original Characters) ---
        // addOC(nom, taille, danger de l'adversaire, description, nom du fichier artwork)
        // L'artwork est cherché dans mods/images/menuBG/<fichier>/<fichier>.png (voir MainMenuState.menuArtworkKey)
        // Paramètres optionnels (dans cet ordre) pour personnaliser précisément l'affichage
        // de l'artwork de CET OC en particulier :
        //   artX, artY        : position en pixels (-1 = centrage automatique dans la moitié droite)
        //   artScale          : échelle de l'image (1 = taille réelle)
        //   artFlipX, artFlipY: miroir horizontal / vertical
        //   artAngle          : rotation en degrés
        //   artAlpha          : opacité (0 à 1)
        //   artAntialiasing   : lissage activé ou non
        //   color             : couleur de fond de la galerie appliquée quand cet OC est affiché (optionnel)
        //   accentColor       : couleur du nom du personnage dans le panneau (par défaut un rose vif)
        // Le badge "Danger de l'adversaire" se colore automatiquement selon le texte
        // ("Faible" = bleu, "Normal" = vert, "Élevé" = orange, "Extrême" = rouge, sinon gris).
        addOC(
            "Océane",
            "1,80 m",
            "Normal",
            "C'est une fille plutôt mignonne, dotée d'une voix capable de transporter quiconque l'écoute jusque dans les étoiles. Elle semble être à la recherche de quelque chose… Peut-être d'aventures ? De rap battles ? Ou simplement de nouveaux horizons à explorer ? Difficile à dire.\nUne chose est certaine : elle est prête à affronter tout ce qui se dressera sur son chemin, toujours avec le sourire et, bien entendu, dans la plus grande bienveillance.",
            "oceane",
            -1, -1, 0.45, false, false, 0, 1, true, // réglages d'artwork par défaut
            0xFFB33A8C,  // color -> fond légèrement------ teinté rose/violet en accord avec Océane
            0xFFFF6EC7   // accentColor -> couleur du nom "Océane" dans le panneau
        );

        imageDisplay = new FlxSprite(0, 0);
        imageDisplay.antialiasing = true;
        imageDisplay.screenCenter();
        add(imageDisplay);

        nameText = new FlxText(0, FlxG.height - 80, FlxG.width, "", 32);
        nameText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        add(nameText);

        // Icône + nom de l'auteur détecté, affichés à côté du titre de l'image
        authorIcon = new FlxSprite();
        authorIcon.visible = false;
        add(authorIcon);

        authorNameText = new FlxText(0, 0, 0, "", 24);
        authorNameText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
        authorNameText.visible = false;
        add(authorNameText);

        // --- Présentation OC : colonne de gauche (panneau + infos + description) ---
        OC_PANEL_X = 100; // décalé vers la droite (était à 40)
        OC_PANEL_Y = 90;
        OC_PANEL_W = FlxG.width * 0.46;
        OC_PANEL_H = FlxG.height - OC_PANEL_Y - 60;

        var ocPadding:Float = 24;
        var ocContentX:Float = OC_PANEL_X + ocPadding;
        var ocContentW:Float = OC_PANEL_W - ocPadding * 2;

        // Tout le panneau est regroupé dans un seul FlxSpriteGroup : ça permet de
        // faire glisser nom/stats/badge/description/pagination ensemble, comme un
        // seul bloc cohérent, sans avoir à gérer la position de chaque élément
        // individuellement (et donc sans risque de dérive de l'un d'eux).
        ocInfoGroup = new FlxSpriteGroup();
        add(ocInfoGroup);

        ocInfoPanelBG = new FlxSprite(OC_PANEL_X, OC_PANEL_Y).makeGraphic(Std.int(OC_PANEL_W), Std.int(OC_PANEL_H), FlxColor.BLACK);
        ocInfoPanelBG.alpha = 0.55;
        ocInfoGroup.add(ocInfoPanelBG);

        ocNameText = new FlxText(ocContentX, OC_PANEL_Y + ocPadding, ocContentW, "", 30);
        ocNameText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT);
        ocInfoGroup.add(ocNameText);

        ocHeightText = new FlxText(ocContentX, ocNameText.y + 46, ocContentW, "", 20);
        ocHeightText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
        ocInfoGroup.add(ocHeightText);

        // Largeur 0 = le champ s'ajuste automatiquement à la longueur du texte,
        // ce qui permet de positionner le badge juste après le label.
        ocDangerLabelText = new FlxText(ocContentX, ocHeightText.y + 32, 0, "Danger de l'adversaire :", 20);
        ocDangerLabelText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);
        ocInfoGroup.add(ocDangerLabelText);

        ocDangerBadgeBG = new FlxSprite(0, 0);
        ocInfoGroup.add(ocDangerBadgeBG);

        ocDangerBadgeText = new FlxText(0, 0, 0, "", 18);
        ocDangerBadgeText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
        ocInfoGroup.add(ocDangerBadgeText);

        ocDivider = new FlxSprite(ocContentX, ocDangerLabelText.y + 44).makeGraphic(Std.int(ocContentW), 2, 0x88FFFFFF);
        ocInfoGroup.add(ocDivider);

        ocDescriptionText = new FlxText(ocContentX, ocDivider.y + 16, ocContentW, "", 18);
        ocDescriptionText.setFormat(Paths.font("vcr.ttf"), 18, 0xFFE3D9F5, LEFT);
        ocInfoGroup.add(ocDescriptionText);

        ocPageText = new FlxText(0, OC_PANEL_Y + OC_PANEL_H - ocPadding - 20, 0, "", 18);
        ocPageText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
        ocInfoGroup.add(ocPageText);

        ocInfoGroup.visible = false;

        // --- Présentation OC : colonne de droite (artwork personnalisable) ---
        ocArtwork = new FlxSprite(0, 0);
        ocArtwork.visible = false;
        add(ocArtwork);

        musicInfoBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
        musicInfoBG.alpha = 0.6;
        musicInfoBG.visible = false;
        add(musicInfoBG);

        var leText:String = "Press SPACE to play/stop the music";
        musicInfoText = new FlxText(musicInfoBG.x, musicInfoBG.y + 4, FlxG.width, leText, 18);
        musicInfoText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
        musicInfoText.scrollFactor.set();
        musicInfoText.visible = false;
        add(musicInfoText);

        // Barre de progression
        progressBarBG = new FlxSprite(0, FlxG.height - 100).makeGraphic(FlxG.width - 200, 20, FlxColor.BLACK);
        progressBarBG.screenCenter(X);
        progressBarBG.visible = false;
        add(progressBarBG);

        progressBar = new FlxSprite(progressBarBG.x, progressBarBG.y).makeGraphic(Std.int(progressBarBG.width), 20, FlxColor.WHITE);
        progressBar.origin.set(0, 0);
        progressBar.scale.x = 0;
        progressBar.visible = false;
        add(progressBar);

        timeText = new FlxText(0, progressBarBG.y - 50, FlxG.width, "0:00 / 0:00", 30);
        timeText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER);
        timeText.visible = false;
        add(timeText);

        // --- Encart descriptif pour les musiques ---
        // Volontairement différent du panneau OC (Characters) : ici, un simple petit encart
        // semi-transparent en haut à GAUCHE de l'écran (le centre reste libre pour un futur
        // graphique), texte italique, purement informatif.
        // Masqué par défaut ; rempli et redimensionné dynamiquement par updateMusicDescription().
        var musicDescWidth:Float = 620;
        var musicDescX:Float = 40;
        var musicDescY:Float = 55;
        var musicDescPadding:Float = 20;

        musicDescBG = new FlxSprite(musicDescX - musicDescPadding, musicDescY).makeGraphic(Std.int(musicDescWidth + musicDescPadding * 2), 10, 0x99000000);
        musicDescBG.scrollFactor.set();
        musicDescBG.visible = false;
        add(musicDescBG);

        musicDescText = new FlxText(musicDescX, musicDescY + musicDescPadding, musicDescWidth, "", 20);
        musicDescText.setFormat(Paths.font("vcr.ttf"), 20, 0xFFE3D9F5, LEFT);
        musicDescText.italic = true;
        musicDescText.scrollFactor.set();
        musicDescText.visible = false;
        add(musicDescText);

        // Flèches de navigation (gauche / droite)
        leftArrow = new FlxText(20, 0, 70, "<", 64);
        leftArrow.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER);
        leftArrow.screenCenter(Y);
        leftArrow.scrollFactor.set();
        add(leftArrow);

        rightArrow = new FlxText(FlxG.width - 90, 0, 70, ">", 64);
        rightArrow.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER);
        rightArrow.screenCenter(Y);
        rightArrow.scrollFactor.set();
        add(rightArrow);

        // Petite pulsation continue pour bien indiquer que ce sont des boutons de navigation
        FlxTween.tween(leftArrow, {alpha: 0.35}, 0.7, {type: PINGPONG, ease: FlxEase.quadInOut});
        FlxTween.tween(rightArrow, {alpha: 0.35}, 0.7, {type: PINGPONG, ease: FlxEase.quadInOut});

        // Au départ, on affiche l'écran de sélection (les 3 logos), pas de contenu de galerie
        showImagesMenu();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (leaving) return;

        var left = controls.UI_LEFT_P;
        var right = controls.UI_RIGHT_P;
        var back = controls.BACK;
        var space = FlxG.keys.justPressed.SPACE;

        if (FlxG.mouse.justPressed) {
            var mousePos = FlxG.mouse.getWorldPosition();
            if (imagesTab.overlapsPoint(mousePos)) switchCategory("Images");
            if (musicTab.overlapsPoint(mousePos)) switchCategory("Music");

            // L'écran de sélection "Images" (3 logos) ne réagit que dans la catégorie "Images"
            if (curCategory == "Images" && imagesMenuOpen) {
                if (menuLogoCharacters.overlapsPoint(mousePos)) selectImagesSubCategory("Characters");
                if (menuLogoConcepts.overlapsPoint(mousePos)) selectImagesSubCategory("Concepts");
                if (menuLogoSketches.overlapsPoint(mousePos)) selectImagesSubCategory("Sketches");
            }

            // L'écran de sélection "Music" (2 logos) ne réagit que dans la catégorie "Music"
            if (curCategory == "Music" && musicsMenuOpen) {
                if (musicMenuLogoConcepts.overlapsPoint(mousePos)) selectMusicsSubCategory("Concepts");
                if (musicMenuLogoEarly.overlapsPoint(mousePos)) selectMusicsSubCategory("Early");
            }

            var inMenu:Bool = (curCategory == "Images" && imagesMenuOpen) || (curCategory == "Music" && musicsMenuOpen);
            if (!inMenu) {
                if (leftArrow.overlapsPoint(mousePos)) {
                    if (curCategory == "Images") {
                        if (curImagesSubCategory == "Characters") changeOCSelection(-1); else changeSelection(-1);
                    } else changeMusicSelection(-1);
                }
                if (rightArrow.overlapsPoint(mousePos)) {
                    if (curCategory == "Images") {
                        if (curImagesSubCategory == "Characters") changeOCSelection(1); else changeSelection(1);
                    } else changeMusicSelection(1);
                }
            }
        }

        if (curCategory == "Images" && !imagesMenuOpen) {
            if (curImagesSubCategory == "Characters") {
                if (left) changeOCSelection(-1);
                if (right) changeOCSelection(1);
            } else {
                if (left) changeSelection(-1);
                if (right) changeSelection(1);
            }
        } else if (curCategory == "Music" && !musicsMenuOpen) {
            if (left) changeMusicSelection(-1);
            if (right) changeMusicSelection(1);
            if (space) toggleAudio();

            // Seek interactif
            if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(progressBarBG)) {
                if (audioPlayer != null && audioPlayer.length > 0) {
                    var pct:Float = FlxMath.bound((FlxG.mouse.x - progressBarBG.x) / progressBarBG.width, 0, 1);
                    var seekMs:Float = pct * audioPlayer.length;
                    audioPlayer.stop();
                    audioPlayer.play(false, seekMs);
                }
            }

            // Update barre et chrono
            if (audioPlayer != null && audioPlayer.playing) {
                progressBar.scale.x = FlxMath.bound(audioPlayer.time / audioPlayer.length, 0, 1);
                timeText.text = formatTime(audioPlayer.time) + " / " + formatTime(audioPlayer.length);
            }
        }

        if (back) {
            if (curCategory == "Images" && !imagesMenuOpen) {
                // On est dans le contenu d'une sous-catégorie (Characters/Concepts/Sketches) :
                // Back nous ramène à l'écran de sélection des 3 logos, sans quitter la galerie.
                FlxG.sound.play(Paths.sound('cancelMenu'));
                showImagesMenu();
            } else if (curCategory == "Music" && !musicsMenuOpen) {
                // Pareil pour "Music" : Back nous ramène à l'écran de sélection Concepts/Early.
                FlxG.sound.play(Paths.sound('cancelMenu'));
                showMusicsMenu();
            } else {
                leaving = true;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                if (FlxG.sound.music != null) FlxG.sound.music.stop();
                FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
                FlxG.mouse.visible = false;
                MusicBeatState.switchState(new MainMenuState());
            }
        }
    }

    /**
     * Découpe "text" en lignes qui tiennent dans la largeur réelle de "field" (mesurée
     * directement avec sa police et sa taille, plutôt qu'estimée via un nombre de caractères
     * à l'aveugle).
     *
     * L'espacement supplémentaire entre les lignes n'est PAS géré ici : FlxText n'a pas de
     * propriété "lineSpacing", mais FlxTextFormat (via addFormat) expose un champ "leading"
     * (interligne, en pixels) depuis Flixel 4.10.0. C'est donc addFormat/leading qui s'en
     * charge, côté appelant, une fois le texte final assigné (voir applyExtraLineSpacing).
     */
    static function wrapToFieldWidth(field:FlxText, text:String):String {
        var originalText:String = field.text;
        var maxWidth:Float = field.fieldWidth;

        var paragraphs:Array<String> = text.split("\n");
        var allLines:Array<String> = [];

        for (paragraph in paragraphs) {
            var words:Array<String> = paragraph.split(" ");
            var lines:Array<String> = [];
            var current:String = "";

            for (word in words) {
                var candidate:String = (current.length == 0) ? word : current + " " + word;
                field.text = candidate;
                if (field.width > maxWidth && current.length > 0) {
                    lines.push(current);
                    current = word;
                } else {
                    current = candidate;
                }
            }
            if (current.length > 0) lines.push(current);

            allLines = allLines.concat(lines);
        }

        // On restaure le texte d'origine : c'est l'appelant qui doit ensuite assigner
        // le résultat de cette fonction à field.text.
        field.text = originalText;

        return allLines.join("\n");
    }

    /**
     * Ajoute un interligne supplémentaire (en pixels, en plus de l'interligne normal de la
     * police) sur tout le texte actuellement affiché par "field".
     */
    static function applyExtraLineSpacing(field:FlxText, extraPixels:Int):Void {
        var format = new FlxTextFormat();
        format.leading = extraPixels;
        field.addFormat(format, 0, field.text.length);
    }

    /**
     * Force un recalcul complet de la hauteur d'un FlxText une frame plus tard, puis exécute
     * "onReady" (typiquement : repositionner/redimensionner un fond, appeler updateHitbox()).
     *
     * Pourquoi : sur ce moteur, juste après avoir changé field.text (et éventuellement appliqué
     * un format avec addFormat, ex: applyExtraLineSpacing), la hauteur mesurée immédiatement
     * après (field.height, textField.numLines, etc.) peut rester périmée pendant une frame —
     * d'où le texte coupé au tout premier affichage, qui se corrige dès qu'une frame s'est
     * écoulée (changer de sélection, quitter/revenir...). En repoussant le recalcul et le
     * repositionnement d'une frame, on laisse ce délai se résorber avant de mesurer quoi que
     * ce soit. On force aussi une vraie réassignation (via un texte temporaire différent,
     * plutôt que field.text = field.text qui ne changerait rien et pourrait ne rien déclencher
     * du tout si le setter ignore les réassignations identiques).
     */
    static function refreshTextNextFrame(field:FlxText, onReady:Void->Void):Void {
        var finalText:String = field.text;
        new flixel.util.FlxTimer().start(0, function(_) {
            field.text = "";
            field.text = finalText;
            onReady();
        });
    }

    /**
     * Affiche (ou masque) l'encart descriptif d'une musique. Contrairement au panneau OC
     * (Characters), ce n'est qu'un petit encart informatif, sans navigation ni pagination.
     */
    function updateMusicDescription(description:String) {
        if (description == null || description.length <= 0) {
            musicDescBG.visible = false;
            musicDescText.visible = false;
            return;
        }

        musicDescText.text = wrapToFieldWidth(musicDescText, description);
        applyExtraLineSpacing(musicDescText, MUSIC_DESC_LINE_SPACING);
        musicDescText.updateHitbox();
        musicDescText.visible = true;

        var padding:Float = 20;
        var resizeMusicDescBG = function() {
            musicDescBG.makeGraphic(Std.int(musicDescText.fieldWidth + padding * 2), Std.int(musicDescText.height + padding * 2), 0x99000000);
            musicDescBG.x = musicDescText.x - padding;
            musicDescBG.y = musicDescText.y - padding;
            musicDescBG.visible = true;
        };
        resizeMusicDescBG();
        refreshTextNextFrame(musicDescText, function() {
            applyExtraLineSpacing(musicDescText, MUSIC_DESC_LINE_SPACING);
            musicDescText.updateHitbox();
            resizeMusicDescBG();
        });
    }


    function switchCategory(cat:String) {
        curCategory = cat;
        var isMusic = (cat == "Music");

        imagesTab.alpha = (cat == "Images") ? 1 : 0.5;
        musicTab.alpha = isMusic ? 1 : 0.5;

        if (cat == "Images") {
            if (audioPlayer != null) {
                FlxTween.cancelTweensOf(audioPlayer);
                audioPlayer.stop();
                audioPlayer.destroy();
                audioPlayer = null;
            }
            // Relance la musique de fond de l'onglet Images si elle n'est pas déjà lancée
            if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
                FlxG.sound.playMusic(Paths.music("betamusic"), 0.8, true);
            }
            // On revient toujours sur l'écran de sélection (les 3 logos) en entrant dans "Images"
            showImagesMenu();
        } else {
            // On revient toujours sur l'écran de sélection (Concepts / Early) en entrant dans "Music"
            showMusicsMenu();
        }
    }

    /**
     * Affiche l'écran de sélection : les 3 logos "Characters" / "Concepts" / "Sketches",
     * et masque tout contenu de galerie (images, panneau OC, flèches de navigation...).
     * Appelé en entrant dans la catégorie "Images" et via la touche Back depuis le contenu.
     */
    function showImagesMenu() {
        imagesMenuOpen = true;

        menuLogoCharacters.visible = true;
        menuLogoConcepts.visible = true;
        menuLogoSketches.visible = true;

        imageDisplay.visible = false;
        nameText.visible = false;
        ocInfoGroup.visible = false;
        ocArtwork.visible = false;
        authorIcon.visible = false;
        authorNameText.visible = false;
        leftArrow.visible = false;
        rightArrow.visible = false;

        // Masque aussi l'interface propre à "Music", au cas où elle était affichée
        musicMenuLogoConcepts.visible = false;
        musicMenuLogoEarly.visible = false;
        musicInfoBG.visible = false;
        musicInfoText.visible = false;
        progressBarBG.visible = false;
        progressBar.visible = false;
        timeText.visible = false;
        musicDescBG.visible = false;
        musicDescText.visible = false;
    }

    /**
     * Équivalent de showImagesMenu(), mais pour "Music" : affiche les 2 logos
     * "Concepts" / "Early", et masque tout contenu (lecteur audio, flèches...).
     * Appelé en entrant dans la catégorie "Music" et via la touche Back depuis le contenu.
     */
    function showMusicsMenu() {
        musicsMenuOpen = true;

        musicMenuLogoConcepts.visible = true;
        musicMenuLogoEarly.visible = true;

        nameText.visible = false;
        imageDisplay.visible = false;
        ocInfoGroup.visible = false;
        ocArtwork.visible = false;
        authorIcon.visible = false;
        authorNameText.visible = false;
        leftArrow.visible = false;
        rightArrow.visible = false;

        musicInfoBG.visible = false;
        musicInfoText.visible = false;
        progressBarBG.visible = false;
        progressBar.visible = false;
        timeText.visible = false;
        musicDescBG.visible = false;
        musicDescText.visible = false;

        // Masque aussi l'interface propre à "Images", au cas où elle était affichée
        menuLogoCharacters.visible = false;
        menuLogoConcepts.visible = false;
        menuLogoSketches.visible = false;

        if (audioPlayer != null) {
            FlxTween.cancelTweensOf(audioPlayer);
            audioPlayer.stop();
            audioPlayer.destroy();
            audioPlayer = null;
        }
    }

    /**
     * Appelée quand le joueur clique sur "Concepts" ou "Early" dans le menu Music :
     * masque l'écran de sélection et affiche le lecteur avec la liste correspondante.
     */
    function selectMusicsSubCategory(sub:String) {
        curMusicsSubCategory = sub;
        musicsMenuOpen = false;

        // La musique de fond ne se coupe qu'à partir d'ici, pas dès l'entrée dans l'onglet "Music"
        // (l'écran de sélection Concepts/Early garde la musique de fond en cours).
        if (FlxG.sound.music != null) FlxG.sound.music.stop();

        musicMenuLogoConcepts.visible = false;
        musicMenuLogoEarly.visible = false;

        leftArrow.visible = true;
        rightArrow.visible = true;
        nameText.visible = true;

        musicInfoBG.visible = true;
        musicInfoText.visible = true;
        progressBarBG.visible = true;
        progressBar.visible = true;
        timeText.visible = true;

        // "musics" pointe vers la liste correspondant à la sous-catégorie choisie
        musics = (sub == "Concepts") ? conceptMusics : earlyMusics;
        curSelected = 0;

        if (musics.length > 0) {
            changeMusicSelection(0);
        } else {
            // Dossier vide (ou introuvable) : on l'indique clairement plutôt que
            // de laisser une musique de la précédente sous-catégorie affichée par erreur.
            imageDisplay.visible = false;
            nameText.x = 0;
            nameText.y = FlxG.height - 80;
            nameText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER);
            nameText.text = "No musics found in gallery/musics/" + (sub == "Concepts" ? "concepts" : "early") + "/";
            updateMusicDescription(null);
            progressBar.scale.x = 0;
            timeText.text = "0:00 / 0:00";
        }
    }

    /**
     * Appelée quand le joueur clique sur l'un des 3 logos : masque l'écran de sélection
     * et affiche le contenu correspondant (présentation OC, ou galerie Concepts/Sketches
     * scannée automatiquement dans son dossier).
     */
    function selectImagesSubCategory(sub:String) {
        curImagesSubCategory = sub;
        imagesMenuOpen = false;

        menuLogoCharacters.visible = false;
        menuLogoConcepts.visible = false;
        menuLogoSketches.visible = false;

        leftArrow.visible = true;
        rightArrow.visible = true;

        var isCharacters:Bool = (sub == "Characters");
        var isConcepts:Bool = (sub == "Concepts");

        imageDisplay.visible = !isCharacters;
        nameText.visible = !isCharacters;
        ocInfoGroup.visible = isCharacters;
        ocArtwork.visible = isCharacters;

        // L'affichage auteur (icône + nom) ne concerne que les galeries d'images classiques ;
        // il sera remis à jour par changeSelection() si besoin.
        authorIcon.visible = false;
        authorNameText.visible = false;

        if (isCharacters) {
            if (ocs.length > 0) changeOCSelection(0);
        } else {
            // "images" pointe vers la liste correspondant à la sous-catégorie choisie
            images = isConcepts ? conceptImages : sketchImages;
            curSelected = 0;

            if (images.length > 0) {
                changeSelection(0);
            } else {
                // Dossier vide (ou introuvable) : on l'indique clairement plutôt que
                // de laisser une image de la précédente sous-catégorie affichée par erreur.
                imageDisplay.visible = false;
                nameText.visible = true;
                nameText.x = 0;
                nameText.y = FlxG.height - 64;
                nameText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER);
                nameText.text = "No images found in gallery/images/" + (isConcepts ? "concepts" : "sketches") + "/";
            }
        }
    }

    // Ajoute une image à une liste donnée (conceptImages, sketchImages, ...). Utile si tu veux
    // personnaliser manuellement le nom affiché, l'auteur, la couleur ou la position du texte
    // d'une image précise plutôt que de laisser buildImageListFromFolder() tout déduire.
    function addImageToList(list:Array<GalleryImage>, name:String, path:String, ?author:String, color:Int, ?textX:Float = -1, ?textY:Float = -1, ?textSize:Int = 32) {
        list.push(new GalleryImage(name, path, author, color, textX, textY, textSize));
    }

    /**
     * Construit automatiquement la liste des GalleryImage pour une sous-catégorie
     * ("concepts" ou "sketches"), en scannant mods/<mod>/gallery/images/<subfolder>/.
     * Le nom affiché est déduit du nom de fichier (underscores/tirets -> espaces).
     */
    function buildImageListFromFolder(subfolder:String):Array<GalleryImage> {
        var list:Array<GalleryImage> = [];

        for (key in listGalleryImagesInFolder(subfolder)) {
            var fileBase:String = key.substr(key.lastIndexOf("/") + 1);
            var displayName:String = prettifyFileName(fileBase);
            list.push(new GalleryImage(displayName, key, authorForImage(key), 0xFFFFFFFF));
        }

        return list;
    }

    // Transforme "my_cool_sketch" ou "my-cool-sketch" en "my cool sketch" pour un affichage plus lisible.
    function prettifyFileName(base:String):String {
        return StringTools.replace(StringTools.replace(base, "_", " "), "-", " ");
    }

    // Voir le bloc de commentaires au-dessus des appels addOC() dans create()
    // pour le détail de chaque paramètre optionnel.
    function addOC(name:String, height:String, danger:String, description:String, artwork:String,
        ?artX:Float = -1, ?artY:Float = -1, ?artScale:Float = 1, ?artFlipX:Bool = false,
        ?artFlipY:Bool = false, ?artAngle:Float = 0, ?artAlpha:Float = 1,
        ?artAntialiasing:Bool = true, ?color:Int, ?accentColor:Int = 0xFFFF6EC7) {
        ocs.push(new GalleryOC(name, height, danger, description, artwork,
            artX, artY, artScale, artFlipX, artFlipY, artAngle, artAlpha, artAntialiasing, color, accentColor));
    }

    // L'artwork est rangé avec ceux du menu principal : images/menuBG/<key>/<key>.png
    // (et non gallery/images/). Le chemin vient de MainMenuState.menuArtworkKey().
    function ocArtworkPath(key:String):flixel.graphics.FlxGraphic {
        return Paths.image(MainMenuState.menuArtworkKey(key));
    }

    // Le dossier "gallery" est dans mods/<mod>/gallery/ (et non dans assets/images/),
    // donc on ne peut pas passer par Paths.image() qui ajoute toujours "images/" devant.
    // loadGalleryGraphic() lit directement le fichier sur disque (mods d'abord, assets/ en repli).
    function galleryImageGraphic(key:String):FlxGraphic {
        return loadGalleryGraphic('gallery/images/' + key + '.png');
    }

    /**
     * Fait glisser un sprite/texte depuis la gauche ou la droite vers sa position
     * finale actuelle, avec un fondu, pour donner une transition fluide lors du
     * changement d'image ou de musique.
     * dir = -1 (on vient de la gauche, on va vers la précédente)
     * dir =  1 (on vient de la droite, on va vers la suivante)
     * dir =  0 (pas d'animation, ex: premier affichage)
     */
    function slideIn(sprite:FlxSprite, dir:Int, distance:Float = 250, duration:Float = 0.35) {
        if (dir == 0) return;

        FlxTween.cancelTweensOf(sprite);

        var finalX:Float = sprite.x;
        sprite.x = finalX + (dir * distance);
        sprite.alpha = 0;

        FlxTween.tween(sprite, {x: finalX, alpha: 1}, duration, {ease: FlxEase.quintOut});
    }

    /**
     * Équivalent de slideIn(), mais pour un FlxSpriteGroup (ex: le panneau OC).
     * IMPORTANT : on ne touche PAS à l'alpha ici, uniquement à la position.
     * En effet, FlxSpriteGroup applique son "alpha" directement à tous ses
     * membres (il écrase leur propre alpha au lieu de le multiplier) : animer
     * l'alpha du groupe ferait perdre la transparence à 55% du fond du panneau
     * dès la fin de l'animation. On se contente donc d'un glissement de position.
     */
    function slideInGroup(group:FlxSpriteGroup, dir:Int, distance:Float = 250, duration:Float = 0.35) {
        if (dir == 0) return;

        FlxTween.cancelTweensOf(group);

        var finalX:Float = group.x;
        group.x = finalX + (dir * distance);

        FlxTween.tween(group, {x: finalX}, duration, {ease: FlxEase.quintOut});
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;
        if (curSelected < 0) curSelected = images.length - 1;
        if (curSelected >= images.length) curSelected = 0;

        var img = images[curSelected];
        imageDisplay.visible = true;
        var graphic:FlxGraphic = galleryImageGraphic(img.path);
        if (graphic != null) imageDisplay.loadGraphic(graphic);
        imageDisplay.scale.set(0.5, 0.5);
        imageDisplay.updateHitbox();
        imageDisplay.screenCenter();

        // Petite animation de glissement pour rendre la transition plus fluide
        slideIn(imageDisplay, change);

        // --- Résolution automatique de l'auteur via les crédits ---
        var author:GalleryAuthorInfo = resolveAuthor(img.author);

        // Position et taille du texte personnalisées si définies
        if (img.textX >= 0) nameText.x = img.textX; else nameText.x = 0;
        if (img.textY >= 0) nameText.y = img.textY; else nameText.y = FlxG.height - 64;
        nameText.text = stripAuthorTag(img.name, img.author);
        nameText.setFormat(Paths.font("vcr.ttf"), img.textSize, FlxColor.WHITE, CENTER);

        // Le texte doit glisser une fois sa position finale connue (x/y et texte fixés)
        slideIn(nameText, change);

        var targetColor:Int = (author != null) ? author.color : img.color;

        if (targetColor != intendedColor) {
            if (colorTween != null) colorTween.cancel();
            intendedColor = targetColor;
            colorTween = FlxTween.color(bg, 1, bg.color, intendedColor);
        }

        updateAuthorDisplay(author);

        FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
    }

    /**
     * Affiche (ou masque) le bloc icône + nom de l'auteur détecté.
     * Ce bloc est indépendant du titre principal et reste ancré en bas à
     * droite de l'écran.
     */
    function updateAuthorDisplay(author:GalleryAuthorInfo) {
        if (author == null || author.icon == null || author.icon.length <= 0) {
            authorIcon.visible = false;
            authorNameText.visible = false;
            return;
        }

        // Charge l'icône depuis les crédits associée à cet auteur
        try {
            authorIcon.loadGraphic(creditIconPath(author.icon));
            authorIcon.setGraphicSize(Std.int(authorIconSize), Std.int(authorIconSize));
            authorIcon.updateHitbox();
            authorIcon.antialiasing = ClientPrefs.globalAntialiasing;
            authorIcon.visible = true;
        } catch (e:Dynamic) {
            // Icône introuvable : on masque simplement l'icône sans planter
            authorIcon.visible = false;
        }

        authorNameText.text = "by " + author.name;
        authorNameText.visible = true;
        authorNameText.updateHitbox();

        // --- Ancrage du bloc en bas à droite de l'écran ---
        var margin:Float = 25;
        var spacing:Float = 12;

        var iconX:Float = FlxG.width - margin - (authorIcon.visible ? authorIcon.width : 0);
        var iconY:Float = FlxG.height - margin - authorIconSize;

        if (authorIcon.visible) {
            authorIcon.setPosition(iconX, iconY);
            authorNameText.setPosition(iconX - spacing - authorNameText.width, iconY + (authorIcon.height - authorNameText.height) / 2);
        } else {
            // Pas d'icône trouvée : on affiche uniquement le nom, ancré au même endroit
            authorNameText.setPosition(FlxG.width - margin - authorNameText.width, FlxG.height - margin - authorNameText.height);
        }
    }

    /**
     * Retire un éventuel tag d'auteur restant dans le titre (ex: "(by Dorix)"),
     * au cas où il aurait été laissé dans le nom affiché. Le nom de l'auteur
     * étant maintenant fourni explicitement à addImageToList()/addMusic(), il n'est
     * plus affiché dans le titre principal mais uniquement dans le bloc en
     * bas à droite.
     */
    function stripAuthorTag(name:String, authorName:String):String {
        if (authorName == null || authorName.length <= 0) return name;

        var pattern = new EReg("\\(?\\s*by\\s+" + authorName + "\\s*\\)?", "i");
        var cleaned:String = pattern.replace(name, "");
        return StringTools.trim(cleaned);
    }

    // --- Résolution de l'auteur via les crédits ---

    /**
     * Recherche les infos d'un auteur (couleur, icône) directement dans
     * CreditsState.creditsList — la seule et unique source de vérité.
     * Retourne null si le nom d'auteur est vide ou introuvable dans les crédits.
     */
    function resolveAuthor(authorName:String):GalleryAuthorInfo {
        if (authorName == null || authorName.length <= 0) return null;

        var entry:Array<String> = CreditsState.findCredit(authorName);
        if (entry == null) return null;

        var icon:String = (entry.length > 1) ? entry[1] : null;
        var color:Int = (entry.length > 4) ? CreditsState.parseColor(entry[4]) : FlxColor.WHITE;

        return new GalleryAuthorInfo(entry[0], color, icon);
    }

    // Les icônes de crédits sont chargées depuis assets/images/credits/<key>.png
    // -> Ajuste ce chemin si tes icônes se trouvent ailleurs.
    // Note : sous Psych Engine 0.6.3, Paths.image() renvoie directement un
    // FlxGraphic (pas un chemin String), on garde donc le type de retour ouvert.
    function creditIconPath(key:String):flixel.graphics.FlxGraphic {
        return Paths.image('credits/' + key);
    }

    // Ajoute une musique à une liste donnée (conceptMusics, earlyMusics, ...). Utile si tu veux
    // personnaliser manuellement le nom affiché, l'auteur ou la description d'une musique
    // précise plutôt que de laisser buildMusicListFromFolder() tout déduire.
    function addMusicToList(list:Array<GalleryMusic>, name:String, file:String, ?author:String, ?description:String) {
        var mus = new GalleryMusic(name, file, author, description);
        mus.durationMs = getAudioDuration(file);
        list.push(mus);
    }

    // Charge brièvement le fichier audio pour en lire la durée (FlxSound.length),
    // puis le détruit aussitôt. Évite d'avoir à renseigner la durée à la main.
    function getAudioDuration(file:String):Float {
        // Paths.returnSound() cherche d'abord dans mods/<mod>/gallery/musics/, puis dans assets/gallery/musics/
        var tempSound:FlxSound = new FlxSound().loadEmbedded(Paths.returnSound('gallery/musics', file), false, false);
        var length:Float = tempSound.length;
        tempSound.destroy();
        return length;
    }

    /**
     * Équivalent de buildImageListFromFolder(), mais pour les musiques : construit
     * automatiquement la liste des GalleryMusic pour une sous-catégorie ("concepts" ou "early"),
     * en scannant mods/<mod>/gallery/musics/<subfolder>/.
     */
    function buildMusicListFromFolder(subfolder:String):Array<GalleryMusic> {
        var list:Array<GalleryMusic> = [];

        for (key in listGalleryMusicsInFolder(subfolder)) {
            var fileBase:String = key.substr(key.lastIndexOf("/") + 1);
            var displayName:String = prettifyFileName(fileBase);
            addMusicToList(list, displayName, key, authorForMusic(key), descriptionForMusic(key));
        }

        return list;
    }

    function changeMusicSelection(change:Int = 0) {
        curSelected += change;
        if (curSelected < 0) curSelected = musics.length - 1;
        if (curSelected >= musics.length) curSelected = 0;

        var mus = musics[curSelected];
        imageDisplay.visible = false;

        // --- Résolution automatique de l'auteur, comme pour les images ---
        var author:GalleryAuthorInfo = resolveAuthor(mus.author);

        // Repositionnement systématique AVANT l'animation de glissement : sans ça, un
        // FlxTween annulé en plein vol (navigation rapide) peut laisser nameText.x légèrement
        // décalé, et ce décalage s'accumule au fil des changements de sélection.
        nameText.x = 0;
        nameText.y = FlxG.height - 80;
        nameText.text = "Music : " + stripAuthorTag(mus.name, mus.author);
        nameText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);

        updateMusicDescription(mus.description);

        // Petite animation de glissement, comme pour les images
        slideIn(nameText, change);

        // Si un auteur est détecté, on applique aussi sa couleur de fond.
        // Sinon on ne touche pas au fond (il garde sa couleur actuelle).
        if (author != null && author.color != intendedColor) {
            if (colorTween != null) colorTween.cancel();
            intendedColor = author.color;
            colorTween = FlxTween.color(bg, 1, bg.color, intendedColor);
        }

        updateAuthorDisplay(author);

        if (audioPlayer != null) {
            FlxTween.cancelTweensOf(audioPlayer);
            audioPlayer.stop();
            audioPlayer.destroy();
            audioPlayer = null;
        }

        progressBar.scale.x = 0;
        timeText.text = "0:00 / " + formatTime(mus.durationMs);

        FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
    }

    function changeOCSelection(change:Int = 0) {
        // S'il n'y a qu'un seul OC (ou aucun), il n'y a rien vers quoi naviguer :
        // on ignore la pression pour éviter de rejouer l'animation de glissement
        // sur un contenu qui ne change pas (effet de "décalage" étrange).
        if (change != 0 && ocs.length <= 1) return;

        curOCSelected += change;
        if (curOCSelected < 0) curOCSelected = ocs.length - 1;
        if (curOCSelected >= ocs.length) curOCSelected = 0;

        var oc = ocs[curOCSelected];

        // --- Panneau de gauche : on repart toujours de x=0/y=0 avant l'animation.
        // Comme tout le panneau est un seul groupe, cette origine est fixe par
        // construction : aucun risque de dérive, même en cas de navigation rapide.
        ocInfoGroup.x = 0;
        ocInfoGroup.y = 0;

        ocNameText.text = oc.name;
        ocNameText.color = oc.accentColor;

        ocHeightText.text = "Taille : " + oc.height;

        // --- Badge "Danger de l'adversaire", coloré selon le niveau ---
        ocDangerBadgeText.text = oc.danger.toUpperCase();
        ocDangerBadgeText.updateHitbox();

        var badgePadX:Float = 14;
        var badgePadY:Float = 6;
        var badgeW:Int = Std.int(ocDangerBadgeText.width + badgePadX * 2);
        var badgeH:Int = Std.int(ocDangerBadgeText.height + badgePadY * 2);

        ocDangerBadgeBG.makeGraphic(badgeW, badgeH, dangerBadgeColor(oc.danger));
        ocDangerBadgeBG.x = ocDangerLabelText.x + ocDangerLabelText.width + 10;
        ocDangerBadgeBG.y = ocDangerLabelText.y - (badgeH - ocDangerLabelText.height) / 2;

        ocDangerBadgeText.x = ocDangerBadgeBG.x + badgePadX;
        ocDangerBadgeText.y = ocDangerBadgeBG.y + badgePadY;

        // --- Description, sous la ligne de séparation ---
        ocDescriptionText.text = wrapToFieldWidth(ocDescriptionText, oc.description);
        applyExtraLineSpacing(ocDescriptionText, OC_DESC_LINE_SPACING);
        refreshTextNextFrame(ocDescriptionText, function() {
            applyExtraLineSpacing(ocDescriptionText, OC_DESC_LINE_SPACING);
        });

        // --- Pagination (ex: "1 / 3"), calée en bas à droite du panneau ---
        ocPageText.text = (curOCSelected + 1) + " / " + ocs.length;
        ocPageText.updateHitbox();
        ocPageText.x = OC_PANEL_X + OC_PANEL_W - 24 - ocPageText.width;

        slideInGroup(ocInfoGroup, change);

        // --- Colonne de droite : artwork, entièrement personnalisable pour cet OC ---
        ocArtwork.loadGraphic(ocArtworkPath(oc.artwork));
        ocArtwork.antialiasing = oc.artAntialiasing;
        ocArtwork.scale.set(oc.artScale, oc.artScale);
        ocArtwork.updateHitbox();
        ocArtwork.flipX = oc.artFlipX;
        ocArtwork.flipY = oc.artFlipY;
        ocArtwork.angle = oc.artAngle;
        ocArtwork.alpha = oc.artAlpha;

        // Position : si artX/artY ne sont pas précisés (-1), centrage automatique
        // dans la moitié droite de l'écran ; sinon on utilise exactement les
        // coordonnées fournies dans addOC().
        var rightAreaX:Float = FlxG.width * 0.5;
        var rightAreaW:Float = FlxG.width * 0.5;

        ocArtwork.x = (oc.artX >= 0) ? oc.artX : rightAreaX + (rightAreaW - ocArtwork.width) / 2;
        ocArtwork.y = (oc.artY >= 0) ? oc.artY : (FlxG.height - ocArtwork.height) / 2;

        slideIn(ocArtwork, change);

        // --- Couleur de fond thématique ---
        // Si l'OC ne précise pas de "color" explicite, on en déduit automatiquement
        // une version assombrie de son accentColor : chaque fiche reste ainsi
        // personnalisée visuellement même sans réglage manuel supplémentaire.
        var themeColor:Int = (oc.color != null) ? oc.color : autoThemeColor(oc.accentColor);

        if (themeColor != intendedColor) {
            if (colorTween != null) colorTween.cancel();
            intendedColor = themeColor;
            colorTween = FlxTween.color(bg, 1, bg.color, intendedColor);
        }

        FlxG.sound.play(Paths.sound('scrollMenu'), 0.5);
    }

    // Assombrit une couleur d'accent pour en faire un fond discret et cohérent,
    // utilisé quand un OC ne précise pas de "color" explicite dans addOC().
    function autoThemeColor(accent:Int):Int {
        var c:FlxColor = accent;
        return c.getDarkened(0.65);
    }

    // Associe une couleur au badge "Danger de l'adversaire" selon le texte fourni
    // dans addOC(). Reconnaît quelques valeurs courantes ; sinon couleur neutre.
    function dangerBadgeColor(danger:String):Int {
        var d:String = StringTools.trim(danger).toLowerCase();
        return switch (d) {
            case "faible": 0xFF29B6F6;             // bleu clair
            case "normal": 0xFF43A047;              // vert
            case "élevé", "eleve", "haut": 0xFFFB8C00; // orange
            case "extrême", "extreme": 0xFFE53935;  // rouge
            default: 0xFF757575;                    // gris neutre pour toute valeur non reconnue
        }
    }

    function toggleAudio() {
        if (audioPlayer != null && audioPlayer.playing) {
            audioPlayer.pause();
            return;
        }

        if (audioPlayer != null && audioPlayer.time > 0) {
            audioPlayer.resume();
        } else {
            var mus = musics[curSelected];
            if (audioPlayer != null) { FlxTween.cancelTweensOf(audioPlayer); audioPlayer.destroy(); }
            audioPlayer = new FlxSound().loadEmbedded(Paths.returnSound('gallery/musics', mus.file), false, false);
            FlxG.sound.list.add(audioPlayer);
            audioPlayer.play();
        }
    }

    function formatTime(ms:Float):String {
        var seconds:Int = Math.floor(ms / 1000);
        var min:Int = Math.floor(seconds / 60);
        var sec:Int = seconds % 60;
        return min + ":" + (sec < 10 ? "0" + sec : "" + sec);
    }

    // ==========================================================
    //  Verrouillage de la galerie
    // ==========================================================

    /**
     * Retourne true si toutes les musiques "non cachées" (voir HIDDEN_SONGS)
     * actuellement débloquées en Freeplay ont été complétées au moins une fois
     * (un score > 0 enregistré sur au moins une difficulté).
     */
    public static function isGalleryUnlocked():Bool {
        var allSongs:Array<String> = FreeplayState.getFreeplaySongNames();

        for (songName in allSongs) {
            if (isHiddenSong(songName)) continue; // musique bonus, ignorée
            if (!isSongCompleted(songName)) return false;
        }

        return true;
    }

    static function isHiddenSong(songName:String):Bool {
        for (hidden in HIDDEN_SONGS) {
            if (StringTools.trim(songName).toLowerCase() == StringTools.trim(hidden).toLowerCase())
                return true;
        }
        return false;
    }

    /**
     * Une chanson est considérée "complétée" si un score strictement positif
     * existe pour elle sur au moins une entrée sauvegardée (peu importe la
     * difficulté), en cherchant directement dans les clés de Highscore.songScores.
     */
    static function isSongCompleted(songName:String):Bool {
        var formatted:String = Paths.formatToSongPath(songName);

        for (key in Highscore.songScores.keys()) {
            if (StringTools.startsWith(key, formatted) && Highscore.songScores.get(key) > 0)
                return true;
        }

        return false;
    }

    /**
     * Affiche un court message "galerie verrouillée" puis revient au menu principal.
     * Adapte MainMenuState par l'état depuis lequel on accède normalement à la galerie
     * si ce n'est pas le menu principal chez toi.
     */
    function showLockedMessage():Void {
        FlxG.mouse.visible = true;

        var msg:String = "Please complete all the songs tracks to access the gallery.";

        var lockedText:FlxText = new FlxText(0, 0, 560, msg, 32);
        lockedText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);

        var padding:Float = 30;
        var lockedBG:FlxSprite = new FlxSprite().makeGraphic(Std.int(lockedText.width + padding * 2), Std.int(lockedText.height + padding * 2), 0xFF000000);
        lockedBG.screenCenter();
        add(lockedBG);

        lockedText.screenCenter();
        add(lockedText);

        var bgTargetAlpha:Float = 0.75;
        var fadeDuration:Float = 0.25;

        lockedBG.alpha = 0;
        lockedText.alpha = 0;

        FlxTween.tween(lockedBG, {alpha: bgTargetAlpha}, fadeDuration, {ease: FlxEase.quadOut});
        FlxTween.tween(lockedText, {alpha: 1}, fadeDuration, {ease: FlxEase.quadOut});

        new flixel.util.FlxTimer().start(2.2, function(tmr:flixel.util.FlxTimer) {
            FlxTween.tween(lockedBG, {alpha: 0}, fadeDuration, {ease: FlxEase.quadIn});
            FlxTween.tween(lockedText, {alpha: 0}, fadeDuration, {
                ease: FlxEase.quadIn,
                onComplete: function(twn:FlxTween) {
                    MusicBeatState.switchState(new states.MainMenuState());
                }
            });
        });
    }
}

class GalleryImage {
    public var name:String;
    public var path:String;
    public var author:String; // nom de l'auteur, résolu automatiquement via CreditsState
    public var color:Int;
    public var textX:Float;
    public var textY:Float;
    public var textSize:Int;

    public function new(name:String, path:String, ?author:String, color:Int, textX:Float = -1, textY:Float = -1, textSize:Int = 32) {
        this.name = name;
        this.path = path;
        this.author = author;
        this.color = color;
        this.textX = textX;
        this.textY = textY;
        this.textSize = textSize;
    }
}

class GalleryOC {
    public var name:String;
    public var height:String;      // "Taille"
    public var danger:String;      // "Danger de l'adversaire"
    public var description:String;
    public var artwork:String;     // nom du personnage : artwork dans images/menuBG/<nom>/<nom>.png (sans extension)

    // Paramètres d'affichage de l'artwork, personnalisables individuellement pour chaque OC.
    // artX / artY = -1 signifie "centrage automatique".
    public var artX:Float;
    public var artY:Float;
    public var artScale:Float;
    public var artFlipX:Bool;
    public var artFlipY:Bool;
    public var artAngle:Float;
    public var artAlpha:Float;
    public var artAntialiasing:Bool;
    public var color:Null<Int>; // couleur de fond appliquée pour cet OC (optionnel)
    public var accentColor:Int; // couleur du nom du personnage dans le panneau

    public function new(name:String, height:String, danger:String, description:String, artwork:String,
        artX:Float = -1, artY:Float = -1, artScale:Float = 1, artFlipX:Bool = false, artFlipY:Bool = false,
        artAngle:Float = 0, artAlpha:Float = 1, artAntialiasing:Bool = true, ?color:Int, accentColor:Int = 0xFFFF6EC7) {
        this.name = name;
        this.height = height;
        this.danger = danger;
        this.description = description;
        this.artwork = artwork;
        this.artX = artX;
        this.artY = artY;
        this.artScale = artScale;
        this.artFlipX = artFlipX;
        this.artFlipY = artFlipY;
        this.artAngle = artAngle;
        this.artAlpha = artAlpha;
        this.artAntialiasing = artAntialiasing;
        this.color = color;
        this.accentColor = accentColor;
    }
}

class GalleryAuthorInfo {
    public var name:String;
    public var color:Int;
    public var icon:String; // clé de l'icône dans assets/images/credits/

    public function new(name:String, color:Int, icon:String) {
        this.name = name;
        this.color = color;
        this.icon = icon;
    }
}

class GalleryMusic {
    public var name:String;
    public var file:String;
    public var durationMs:Float = 0; // détectée automatiquement, voir getAudioDuration()
    public var author:String; // nom de l'auteur, résolu automatiquement via CreditsState
    public var description:String; // texte informatif optionnel, voir MUSIC_DESCRIPTIONS

    public function new(name:String, file:String, ?author:String, ?description:String) {
        this.name = name;
        this.file = file;
        this.author = author;
        this.description = description;
    }
}
