package substates;

import CheckboxThingie;
import ClientPrefs;
import Alphabet;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.group.FlxGroup.FlxTypedGroup;
import Paths;
import PlayState;
import Conductor;
import openfl.utils.AssetType;

class ArtworkSubstate extends FlxSubState {
    
    private var _pressingPractice:Bool = false;
    private var _pressingBot:Bool = false;

    var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
    var labelGroup:FlxTypedGroup<FlxText>;

    var checkboxPractice:CheckboxThingie;
    var checkboxBot:CheckboxThingie;
    var labPractice:FlxText;
    var labBot:FlxText;

    var targetX:Float;
    // Géométrie de la colonne de droite : calculée UNE fois (create() + layoutColumn()), jamais en dur.
    var axisX:Float;        // axe vertical commun : poster, barre et checkboxes sont centrés dessus
    var columnW:Float;      // largeur de la colonne, symétrique autour de l'axe
    var posterTopY:Float;   // haut de la zone du poster
    var posterZoneH:Float;  // hauteur de la zone du poster (s'adapte à la place restante)

    // Zone des graphiques de difficulté, SOUS le poster : calculée par layoutColumn(), lue par
    // FreeplayState (qui dessine les graphiques) pour les placer pile entre le poster et la barre.
    public var diffZoneReady:Bool = false;   // true une fois layoutColumn() exécutée
    public var diffZoneCenterX:Float = 0;    // axe vertical de la colonne (= axisX)
    public var diffZoneTopY:Float = 0;       // haut de la zone (juste sous le poster + GAP_Y)
    public var diffZoneWidth:Float = 0;      // largeur de la zone (= largeur de la colonne)
    public var diffZoneHeight:Float = 0;     // hauteur de la zone (= FreeplayState.DIFF_ZONE_HEIGHT)
    var bg:FlxSprite;
    var artImage:FlxSprite;
    var descBg:FlxSprite;
    var artDesc:FlxText;
    var artText:FlxText;
    var panelW:Int;
    var panelH:Int;
    var currentAccent:FlxColor = DESC_ACCENT;
    static inline var DESC_ACCENT:FlxColor = 0xFFF5C542; // doré, couleur d'accent par défaut du panneau

    // Grille d'espacement du panneau description : valeurs fixes et réutilisées
    // partout (création ET recalcul), pour que padding/marges restent toujours
    // identiques quel que soit le texte affiché.
    static inline var PANEL_MARGIN_LEFT:Float = 20;   // distance au bord gauche de l'écran
    static inline var PANEL_MARGIN_BOTTOM:Float = 20; // distance au bord bas de l'écran
    static inline var PANEL_WIDTH_RATIO:Float = 0.46; // largeur du panneau = % de FlxG.width
    static inline var PANEL_PAD_X:Float = 20;         // padding horizontal intérieur
    static inline var PANEL_PAD_TOP:Float = 16;        // padding avant la 1ère ligne
    static inline var PANEL_PAD_BOTTOM:Float = 16;     // padding après la dernière ligne
    static inline var PANEL_GAP_Y:Float = 8;          // espace entre les 2 lignes de texte
    static inline var PANEL_CORNER_RADIUS:Float = 14;
    static inline var PANEL_BORDER_THICKNESS:Float = 2;

    // Difficulty bar
    // Graphiques : mods/images/freeplay/bar/ (bar.png = fond, color.png = remplissage, star.png = étoile)
    // Empilement (du fond vers l'avant) : bar -> color blanc (toute la longueur) -> color coloré (rogné) ; étoiles à l'EXTÉRIEUR.
    static inline var BAR_DIR:String = 'freeplay/bar/';
    var barBg:FlxSprite;          // bar.png : fond de la barre
    var barWhite:FlxSprite;       // copie de color.png (déjà blanc), non modifiée, sur TOUTE la longueur : la partie pas encore remplie
    var barFill:FlxSprite;        // 2e copie de color.png, teintée, même position/taille, rognée (clipRect) selon la progression dans la tranche
    var barNumber:Alphabet = null; // chiffre de la difficulté (niveau) sous la barre : même police que les titres de chansons (Alphabet)
    var barNumberText:String = ''; // texte actuellement affiché (le chiffre n'est recréé que s'il change)
    var barStars:Array<FlxSprite> = [];  // star.png : BAR_STAR_MAX sprites ; moitié à gauche de la barre, moitié à droite
    var barMaxWidth:Int;
    var barScale:Float = 1;       // échelle appliquée à bar.png / color.png
    var barCenterY:Float = 0;     // centre vertical de la barre (= centre de l'ancienne barre dessinée en code)
    var barTargetLevel:Float = 0;  // niveau réel de la difficulté courante (0-20)
    var barTgtTranche:Int = 0;     // tranche (0-3) et progression (0-1) visées
    var barTgtProgress:Float = 0;
    var barShownTranche:Int = 0;   // tranche et progression actuellement AFFICHÉES (animées)
    var barShownProgress:Float = 0;

    // --- Réglages de la barre (tout se règle ici) ---
    static inline var BAR_STAR_MAX:Int = 4;             // nombre maximum d'étoiles (moitié de chaque côté)
    static inline var BAR_STAR_THRESHOLD:Float = 10;    // niveau à partir duquel on passe de 2 à 4 étoiles
    static inline var BAR_STAR_HEIGHT_RATIO:Float = 1.1; // hauteur d'une étoile = x la hauteur de la barre (les étoiles grandissent donc avec la barre)
    static inline var BAR_STAR_SPACING:Float = 2;       // espace (px) entre deux étoiles du même côté
    static inline var BAR_STAR_GAP:Float = 6;           // espace (px) entre la barre et la 1re étoile de chaque côté
    static inline var NUMBER_HEIGHT:Float = 32;         // hauteur (px) du chiffre sous la barre
    static inline var NUMBER_GAP:Float = 9;             // espace (px) entre le bas de la barre et le chiffre
    static inline var NUMBER_LIGHTEN:Float = 0.45;      // 0 = exactement la couleur de la difficulté ; 1 = blanc (éclaircit pour rester lisible sur les couleurs sombres)
    static inline var BAR_SIDE_OVERFLOW:Float = 24;     // les étoiles peuvent dépasser de la colonne de ce nombre de px de chaque côté (barre plus grande)
    static inline var BAR_SCREEN_MARGIN:Float = 8;      // marge minimale (px) entre les étoiles et le bord de l'écran
    static inline var BAR_DRAIN_SPEED:Float = 3.5;      // vitesse de vidage quand on DESCEND de tranche (largeurs de barre / seconde)
    static inline var BAR_WRAP_SPEED:Float = 3.5;       // vitesse de remplissage jusqu'au bout quand on MONTE de tranche (largeurs de barre / seconde)
    static inline var TRANCHE_SIZE:Float = 5;           // la barre se remplit puis repasse à vide tous les 5 niveaux
    // Couleur de départ de chaque tranche (0-5, 5-10, 10-15, 15-20) + une 5e valeur = cible de la dernière tranche
    static final BAR_COLORS:Array<Int> = [
        0xFF3CD246, // tranche 0-5   : vert
        0xFFFFA000, // tranche 5-10  : orange
        0xFFE61E1E, // tranche 10-15 : rouge
        0xFF6E000A, // tranche 15-20 : rouge très foncé
        0xFF32003C  // (cible)       : violet très sombre
    ];
    // Part de la couleur SUIVANTE atteinte quand la tranche est pleine (0 = aucune, 1 = couleur suivante complète)
    static final BAR_TRANCHE_MIX:Array<Float> = [0.25, 0.40, 0.85, 0.85];

    // Colonne de droite (poster + barre de difficulté + graphiques de difficulté) : tout est CENTRÉ sur le
    // même axe (COLUMN_AXIS_RATIO) et empilé avec UN SEUL espacement vertical (GAP_Y).
    // Les checkboxes (Practice Mode / Botplay) ne sont plus dans la colonne : elles sont en haut à gauche.
    // Les positions sont calculées dans create() / layoutColumn() : aucune coordonnée X/Y en dur.
    static inline var COLUMN_AXIS_RATIO:Float = 0.825;  // axe de la colonne = % de FlxG.width (colonne plus large : l'axe recule un peu pour garder ~la marge d'écran à droite)
    static inline var COLUMN_WIDTH_RATIO:Float = 0.30;  // largeur de la colonne (poster + difficultés + barre) = % de FlxG.width (avant : 0.25)
    static inline var COLUMN_TOP:Float = 80;            // haut de l'espace libre = juste sous Score / Misses / Rank (avant : 105)
    static inline var POSTER_AREA_RATIO:Float = 0.80;   // surface occupée par un poster = % de la surface de sa zone (voir showArtwork) : tous les posters ont ainsi à peu près la même taille apparente, quel que soit leur format
    static inline var POSTER_MAX_HEIGHT:Float = 330;    // hauteur de la zone du poster (avant : 420) ; réduite si la place manque
    static inline var DIFF_TOP_GAP:Float = 76;          // espace entre la barre de difficulté et les graphiques de difficulté (descendre les graphiques = augmenter cette valeur)
    static inline var GAP_Y:Float = 18;                 // espace vertical unique : poster -> barre -> difficultés (avant : 22, puis 14)
    static inline var BAR_HEIGHT:Float = 18;
    static inline var BAR_DROP:Float = 20;              // la barre de difficulté descend de ce nombre de px (seule : le poster et les graphiques ne bougent pas)
    static inline var CHECKBOX_GAP_X:Float = 40;        // espace horizontal entre la fin du libellé d'une checkbox et la checkbox suivante

    private var optionsArray:Array<ArtworkGameplayOption> = [];
    public var currentWeek:String;

    private var _initSongName:String = "";
    private var _initDifficulty:Int = 1;
    private var _initColor:FlxColor = DESC_ACCENT; // couleur de la chanson passée au constructeur (fallback doré si absente)

    var songKey:String = null; 
    var entry:ArtworkEntry = null;
    var currentDifficultyName:String = "normal";

    var clickMargin:Float = 8;  
    var labelOffsetX:Float = 42; 
    var labelOffsetY:Float = 10;

    var checkboxSizeMult:Float = 0.6;

    var gapY:Float = 100;         
    // ----------------------------

    public function new(week:String, songName:String = "", difficulty:Int = 1, ?color:FlxColor) {
        super();
        currentWeek = week;
        _initSongName = songName;
        _initDifficulty = difficulty;
        if (color != null) _initColor = color;
        persistentUpdate = true;
        persistentDraw = true;
    }

    public static final ARTWORKS:Map<String, ArtworkEntry> = [

        "how to play" => {
            text: "Don't know how to play? No problem! The Mario Bros. are here for you!",
            desc: "BPM: 124 / VS. Mario Bros.",
            levels: ["veryeasy" => 1, "easy" => 2, "normal" => 2, "hard" => 3, "veryhard" => 4]
        },

        "metal reflection" => {
            text: "An opponent who reflects mystery...",
            desc: "BPM: 120 / VS. Metal Mario",
            levels: ["veryeasy" => 2, "easy" => 3, "normal" => 5, "hard" => 7, "veryhard" => 9]
        },

        "criminal targets" => {
            text: "Ayuwoki?",
            desc: "BPM: 118 / BONUS STAGE",
            levels: ["easy" => 2, "normal" => 3, "hard" => 5]
        },

        "crash out" => {
            text: "A little pink ball crashing out on a fox to the beat.",
            desc: "BPM: 180 / VS. FUCKING Fox McCloud",
            levels: ["easy" => 2, "normal" => 3, "hard" => 4]
        },

        "trick or treat" => {
            text: "A candy hunt connected to the real world.",
            desc: "BPM: 125 > 145 > 210 > 145 / VS. ???",
            levels: ["easy" => 4, "normal" => 6, "hard" => 8]
        },

        "periple" => {
            text: "tiny guy",
            desc: "BPM: 163 / VS. Mary",
            levels: ["easy" => 3, "normal" => 5, "hard" => 6]
        },

        "starlight" => {
            text: "Fly to the stars to the sound of her voice.",
            desc: "BPM: 173 / VS. Océane",
            levels: ["easy" => 3, "normal" => 5, "hard" => 7]
        },

        "allocution" => {
            text: "Fight it out in beeps and boops without getting overruled.",
            desc: "BPM: 155 / VS. Emmanuel Macron",
            levels: ["easy" => 4, "normal" => 7, "hard" => 10]
        },

        "gangstabattle" => {
            text: "???",
            desc: "BPM: 180 / VS. Gangsta Mario",
            levels: ["easy" => 2, "normal" => 3, "hard" => 4,
                     "erect" => 10, "nightmare" => 12,
                     "b-side" => 5, "corruption" => 6, "minus" => 4, "pico-mix" => 6,
                     "in-game-version" => 4, "in-game-mix" => 3],
            variants: [
                "erect" => { text: "???", desc: "BPM: 190 / VS. Gangsta Mario" },
                "nightmare" => { text: "???", desc: "BPM: 190 / VS. Gangsta Mario" },
                "corruption" => { text: "???", desc: "BPM: 205 / VS. Gangsta Mario" },
                "in-game-version" => { text: "???", desc: "BPM: 180 / VS. ???" }
            ]
        },

        "new game" => {
            text: "Mario get you next time!",
            desc: "BPM: 145 / VS. Super Horror Mario",
            levels: ["easy" => 5, "normal" => 9, "hard" => 14]
        },
    ];

    // Valeurs affichées pour une chanson inconnue
    static inline var PLACEHOLDER:String = "freeplay/artworks/placeholder";
    static inline var DEFAULT_TEXT:String = "???";
    static inline var DEFAULT_DESC:String = "???Dummy_placeholder???";
    static inline var MAX_LEVEL:Float = 20; // niveau qui remplit toute la barre

    // Table de recherche : clés normalisées une seule fois avec Paths.formatToSongPath,
    // pour que "How To Play", "how to play" et "how-to-play" soient équivalents.
    static var lookup:Map<String, ArtworkEntry> = null;

    public static function findEntry(key:String):ArtworkEntry {
        if (lookup == null) {
            lookup = new Map<String, ArtworkEntry>();
            for (name => e in ARTWORKS)
                lookup.set(Paths.formatToSongPath(name), e);
        }
        return lookup.get(key);
    }

    static function imageExists(path:String):Bool {
        return path != null && Paths.fileExists('images/$path.png', AssetType.IMAGE);
    }

    override function create() {
        super.create();

        // Axe + largeur de la colonne : tout est symétrique autour de l'axe.
        // Les Y sont fixés par layoutColumn().
        axisX = FlxG.width * COLUMN_AXIS_RATIO;
        columnW = FlxG.width * COLUMN_WIDTH_RATIO;
        var columnX:Float = axisX - columnW / 2;

        // Étoiles : créées d'abord car leur taille décide de la largeur de la barre (la place des étoiles est
        // réservée DANS la colonne, de chaque côté : à droite il n'y a pas assez de marge d'écran pour les mettre dehors).
        // Les étoiles dépassent un peu de la colonne (sans coller au bord de l'écran) : la barre est ainsi plus grande.
        var overflow:Float = Math.max(0, Math.min(BAR_SIDE_OVERFLOW, FlxG.width - (axisX + columnW / 2) - BAR_SCREEN_MARGIN));
        var totalW:Float = columnW + 2 * overflow; // largeur disponible pour : étoiles de gauche + barre + étoiles de droite

        // La taille des étoiles est proportionnelle à celle de la barre ; comme la barre dépend de la place prise par
        // les étoiles, on résout les deux ensemble : starW = r x barW, et barW = totalW - 2 x (espace d'un côté).
        barBg = loadBarSprite('bar', 856, 91, FlxColor.fromRGB(40, 40, 40));
        var starRef:FlxSprite = loadBarSprite('star', 96, 97, FlxColor.YELLOW);
        var perSide:Int = Std.int(BAR_STAR_MAX / 2);
        var r:Float = BAR_STAR_HEIGHT_RATIO * (barBg.frameHeight / barBg.frameWidth) * (starRef.frameWidth / starRef.frameHeight);
        var fixedSide:Float = BAR_STAR_GAP + (perSide - 1) * BAR_STAR_SPACING; // part de l'espace d'un côté qui ne dépend pas de la taille des étoiles
        var barW:Float = (totalW - 2 * fixedSide) / (1 + 2 * perSide * r);
        barMaxWidth = Std.int(barW); // largeur de bar.png / color.png
        var starH:Float = BAR_STAR_HEIGHT_RATIO * barMaxWidth * (barBg.frameHeight / barBg.frameWidth);

        for (i in 0...BAR_STAR_MAX) {
            var st:FlxSprite = (i == 0) ? starRef : loadBarSprite('star', 96, 97, FlxColor.YELLOW);
            var starScale:Float = starH / st.frameHeight;
            st.scale.set(starScale, starScale);
            st.updateHitbox();
            st.visible = false;
            barStars.push(st);
        }

        bg = new FlxSprite(columnX, 0)
            .makeGraphic(Std.int(columnW), FlxG.height, FlxColor.fromRGB(0, 0, 0, 0));
        add(bg);

        artImage = new FlxSprite(0, 0);
        add(artImage);

        // Barre de difficulté SOUS le poster, centrée sur l'axe de la colonne, étoiles de chaque côté.
        // bar.png + color.png : même échelle, hauteur proportionnelle à l'image. Le Y est donné par layoutColumn().
        barWhite = loadBarSprite('color', 856, 91, FlxColor.WHITE);
        barFill = loadBarSprite('color', 856, 91, FlxColor.WHITE);
        barScale = barMaxWidth / barBg.frameWidth;
        for (spr in [barBg, barWhite, barFill]) {
            spr.scale.set(barScale, barScale);
            spr.updateHitbox();
            spr.x = axisX - barMaxWidth / 2;
        }
        // color.png est blanc : barWhite le garde tel quel (fond), barFill est teinté (blanc x couleur = la couleur)
        barFill.color = FlxColor.fromInt(BAR_COLORS[0]);
        add(barBg);
        add(barWhite);
        add(barFill);
        barFill.visible = false; // affiché dès que la progression dans la tranche est > 0
        for (st in barStars) add(st);

        // --- Bandeau description en bas à gauche de l'écran (VS/BPM + texte), ---
        // --- séparé du poster comme sur le concept art papier.                 ---
        panelW = Std.int(FlxG.width * PANEL_WIDTH_RATIO);
        var textWidth:Int = panelW - Std.int(PANEL_PAD_X * 2);

        descBg = new FlxSprite();
        add(descBg);

        artDesc = new FlxText(0, 0, textWidth, "", 18);
        artDesc.setFormat(null, 18, FlxColor.WHITE, "left");
        add(artDesc);

        artText = new FlxText(0, 0, textWidth, "", 16);
        artText.setFormat(null, 16, FlxColor.WHITE, "left");
        add(artText);

        layoutDescPanel(); // position/taille initiales (texte encore vide à ce stade)
        // ------------------------------------------------------------------------

        checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
        add(checkboxGroup);

        labelGroup = new FlxTypedGroup<FlxText>();
        add(labelGroup);

        getOptions();

        var id:Int = 0;
        for (opt in optionsArray) {
            if (opt.type == "bool") {
                // IMPORTANT : on NE touche PLUS à cb.scale ici. Les offsets faits-main dans
                // CheckboxThingie (offset.set(34,25) etc.) sont calibrés pour la taille que
                // le CONSTRUCTEUR établit lui-même (setGraphicSize(0.9 * width), comme dans
                // le menu Options). Rescaler la checkbox plus loin (ex. à 0.4) rend ces
                // corrections en pixels fixes disproportionnées par rapport à sa taille réduite,
                // ce qui causait le petit "saut" visuel. On garde donc la checkbox à sa taille
                // native, et on ajuste juste le layout autour (gapY dynamique ci-dessous).
                var cb:CheckboxThingie = new CheckboxThingie(0, 0, opt.getValue() == true, checkboxSizeMult);
                cb.ID = id; // la position (x, y) est donnée par layoutColumn()
                checkboxGroup.add(cb);

                var lbl:FlxText = new FlxText(0, 0, 300, opt.name);
                lbl.setFormat(null, 16, FlxColor.WHITE, "left");
                lbl.x = cb.x + cb.width + labelOffsetX;
                lbl.y = cb.y + (cb.height - lbl.size) / 2 + labelOffsetY;
                labelGroup.add(lbl);

                if (opt.variable == "practice") {
                    checkboxPractice = cb;
                    labPractice = lbl;
                } else if (opt.variable == "botplay") {
                    checkboxBot = cb;
                    labBot = lbl;
                }
            }
            id++;
        }

        reloadCheckboxes();
        layoutColumn(); // positions de toute la colonne : une seule source de vérité
        applyOptions();

        // create() est différé par openSubState() : FreeplayState ne peut pas appeler
        // updateArtworkForSong() juste après. On applique donc ici les valeurs reçues par
        // le constructeur, quand tous les sprites existent.
        if (_initSongName != "")
            updateArtworkForSong(_initSongName, _initColor);
        setDifficulty(_initDifficulty);
    }

    // Calcule la mise en page à partir de l'axe, de GAP_Y et de SCREEN_MARGIN :
    //  - COLONNE DE DROITE : poster -> barre -> graphiques de difficulté, tous centrés sur le même axe
    //    (axisX), avec UN seul espacement vertical (GAP_Y). La pile entière est centrée dans l'espace libre
    //    (entre COLUMN_TOP et le message "victoire") et la hauteur du poster s'adapte à la place restante
    //    (plafonnée à POSTER_MAX_HEIGHT). Les graphiques de difficulté, en bas de la pile,
    //    ont une zone de hauteur fixe (FreeplayState.DIFF_ZONE_HEIGHT) : le poster et la barre ne bougent
    //    donc pas d'une chanson à l'autre.
    //  - CHECKBOXES (Practice Mode / Botplay) : sur UNE SEULE ligne, en haut à gauche, à partir de la marge
    //    d'écran. Elles gardent leur taille et leur apparence d'origine ; CHECKBOX_GAP_X sépare deux paires
    //    (case + libellé).
    function layoutColumn():Void {
        // --- Colonne de droite : poster -> barre -> difficultés ---
        // Bas de la colonne : juste au-dessus du message "victoire" de FreeplayState (la barre ne doit
        // pas le recouvrir) ; à défaut (valeur pas encore calculée), la marge d'écran habituelle.
        var bottomY:Float = (states.FreeplayState.columnBottomY > 0)
            ? states.FreeplayState.columnBottomY
            : FlxG.height - states.FreeplayState.SCREEN_MARGIN;
        var availH:Float = bottomY - COLUMN_TOP;
        var diffH:Float = states.FreeplayState.DIFF_ZONE_HEIGHT;
        var fixedH:Float = GAP_Y + BAR_HEIGHT + GAP_Y + diffH;
        posterZoneH = Math.min(POSTER_MAX_HEIGHT, Math.max(120, availH - fixedH));

        var stackH:Float = posterZoneH + fixedH;
        posterTopY = COLUMN_TOP + Math.max(0, (availH - stackH) / 2); // pile centrée : même marge au-dessus et au-dessous

        var barY:Float = posterTopY + posterZoneH + GAP_Y; // position de référence (les graphiques s'y accrochent)
        // Même centre que l'ancienne barre (barY + BAR_DROP, hauteur BAR_HEIGHT) ; la nouvelle est plus haute,
        // elle déborde donc de façon égale au-dessus et en dessous.
        barCenterY = barY + BAR_DROP + BAR_HEIGHT / 2;
        barBg.y = barCenterY - barBg.height / 2;
        barWhite.y = barBg.y;
        barFill.y = barBg.y;
        updateBarStars();
        updateBarNumber(true);

        diffZoneCenterX = axisX;
        diffZoneWidth = columnW;
        diffZoneTopY = barY + BAR_HEIGHT + DIFF_TOP_GAP; // la zone réservée (fixedH) reste calculée avec GAP_Y : poster et barre ne bougent pas
        // Les graphiques descendent d'autant : on raccourcit leur zone pour que leur bas reste au même endroit
        // (au-dessus du message "victoire"), même avec beaucoup de difficultés.
        diffZoneHeight = Math.max(60, diffH - (DIFF_TOP_GAP - GAP_Y));

        diffZoneReady = true; // FreeplayState peut maintenant placer ses graphiques de difficulté

        // --- Checkboxes en haut à gauche ---
        // On mesure le coin HAUT-GAUCHE réellement visible de la case (son offset de dessin est fait-main)
        // pour que ce qu'on voit soit collé à la marge d'écran.
        var visDX:Float = 0;
        var visDY:Float = 0;
        for (cb in checkboxGroup) {
            var vb = cb.getScreenBounds();
            visDX = vb.x - cb.x;
            visDY = vb.y - cb.y;
            vb.put();
            break;
        }
        var margin:Float = states.FreeplayState.SCREEN_MARGIN;

        // Les cases s'enchaînent de gauche à droite : le bord gauche VISIBLE de la 1re est à la marge,
        // chaque suivante démarre CHECKBOX_GAP_X après la fin du libellé précédent.
        var nextVisX:Float = margin;
        for (cb in checkboxGroup) {
            var lbl:FlxText = labelGroup.members[cb.ID];
            // Le libellé est créé avec une largeur fixe de 300 px : sa zone cliquable dépasserait sur la case
            // voisine maintenant qu'elles sont côte à côte. On la réduit à la largeur réelle du texte
            // (le texte est aligné à gauche : rien ne bouge visuellement).
            if (lbl != null) lbl.fieldWidth = Math.ceil(lbl.textField.textWidth) + 4;

            cb.x = nextVisX - visDX;
            cb.y = margin - visDY;
            if (lbl != null) {
                lbl.x = cb.x + cb.width + labelOffsetX;
                lbl.y = cb.y + (cb.height - lbl.size) / 2 + labelOffsetY;
                nextVisX = lbl.x + lbl.textField.textWidth + CHECKBOX_GAP_X;
            } else {
                nextVisX = cb.x + visDX + cb.width + CHECKBOX_GAP_X;
            }
        }
    }

    function getOptions():Void {
        optionsArray = [];
        optionsArray.push(new ArtworkGameplayOption("Practice Mode", "practice", "bool", false));
        optionsArray.push(new ArtworkGameplayOption("Botplay", "botplay", "bool", false));
    }

    // NOTE : setCheckboxVisual() a été retirée. CheckboxThingie pilote toute la chaîne
    // d'animation ("checking"->"checked" / "unchecking"->"unchecked") ET l'offset fait-main
    // de chaque frame directement dans son setter set_daValue() (voir CheckboxThingie.hx).
    // Il suffit donc partout d'assigner cb.daValue = value; — ne JAMAIS appeler
    // cb.animation.play(...) ni cb.updateHitbox() sur un CheckboxThingie après sa création,
    // sous peine de casser la transition ou d'écraser l'offset et de faire "sauter" la case.

    function reloadCheckboxes():Void {
        for (cb in checkboxGroup) {
            var idx = cb.ID;
            if (idx >= 0 && idx < optionsArray.length) {
                var v = optionsArray[idx].getValue() == true;
                cb.daValue = v; // déclenche déjà, via le setter, la bonne animation + le bon offset
                var lbl:FlxText = labelGroup.members[idx];
                if (lbl != null) {
                    lbl.x = cb.x + cb.width + labelOffsetX;
                    lbl.y = cb.y + (cb.height - lbl.size) / 2 + labelOffsetY;
                }
            }
        }
    }

    // Appelé par FreeplayState quand la chanson sélectionnée change
    public function updateArtworkForSong(songName:String, ?color:FlxColor):Void {
        var key = Paths.formatToSongPath(songName);

        // Même chanson et image déjà chargée : on évite de relancer le slide et le rechargement.
        if (key == songKey && artImage.graphic != null) return;

        songKey = key;
        entry = findEntry(key);
        showArtwork();

        currentAccent = (color != null) ? color : DESC_ACCENT;
        layoutDescPanel();
    }

    // Appelé par FreeplayState à chaque changement de difficulté : la couleur du panneau suit la couleur
    // de fond propre à la difficulté (ou celle de la chanson si aucune n'est définie).
    public function setAccentColor(color:FlxColor):Void {
        var newAccent:FlxColor = color;
        if (newAccent == currentAccent) return;
        currentAccent = newAccent;
        if (descBg != null && artDesc != null && artText != null) layoutDescPanel();
    }

    // Recalcule taille + position du panneau à partir de la hauteur RÉELLE du texte
    // actuellement affiché (artDesc/artText), en appliquant toujours le même padding
    // (PANEL_PAD_*). Le panneau reste donc ajusté au contenu (jamais plus gros que
    // nécessaire) sans que le texte ne bouge d'un pixel d'un appel à l'autre.
    function layoutDescPanel():Void {
        panelH = Std.int(PANEL_PAD_TOP + artDesc.height + PANEL_GAP_Y + artText.height + PANEL_PAD_BOTTOM);

        var panelX:Float = PANEL_MARGIN_LEFT;
        var panelY:Float = FlxG.height - PANEL_MARGIN_BOTTOM - panelH;

        descBg.setPosition(panelX, panelY);
        descBg.makeGraphic(panelW, panelH, FlxColor.TRANSPARENT, true);
        FlxSpriteUtil.drawRoundRect(descBg, 0, 0, panelW, panelH, PANEL_CORNER_RADIUS, PANEL_CORNER_RADIUS,
            FlxColor.fromRGB(12, 14, 26, 190), // opaque (avant : alpha 190, semi-transparent)
            { thickness: PANEL_BORDER_THICKNESS, color: currentAccent });

        artDesc.x = panelX + PANEL_PAD_X;
        artDesc.y = panelY + PANEL_PAD_TOP;

        artText.x = panelX + PANEL_PAD_X;
        artText.y = artDesc.y + artDesc.height + PANEL_GAP_Y;
    }

    // Surcharge éventuelle (art/text/desc) pour la difficulté courante
    function getVariant():ArtworkVariant {
        if (entry != null && entry.variants != null)
            return entry.variants.get(currentDifficultyName);
        return null;
    }

    // Chemin de l'artwork, dans l'ordre :
    //   1. variants[difficulté].art
    //   2. <art>-<difficulté>   (ex: star-hard)   <- automatique
    //   3. <art>                (art de l'entrée, ou freeplay/artworks/<chanson> par défaut)
    //   4. placeholder
    function getArtworkPath():String {
        var v = getVariant();
        if (v != null && imageExists(v.art)) return v.art;

        var base = (entry != null && entry.art != null) ? entry.art : 'freeplay/artworks/$songKey';
        var perDiff = '$base-$currentDifficultyName';
        if (imageExists(perDiff)) return perDiff;
        if (imageExists(base)) return base;
        return PLACEHOLDER;
    }

    function getTextForDiff():String {
        var v = getVariant();
        if (v != null && v.text != null) return v.text;
        if (entry != null && entry.text != null) return entry.text;
        return DEFAULT_TEXT;
    }

    function getDescForDiff():String {
        var v = getVariant();
        if (v != null && v.desc != null) return v.desc;
        if (entry != null && entry.desc != null) return entry.desc;
        return DEFAULT_DESC;
    }

    // Niveau (0-20) de la difficulté courante, retrouvé par NOM de difficulté
    function getLevel():Float {
        if (entry == null || entry.levels == null) return 0;
        if (entry.levels.exists(currentDifficultyName))
            return entry.levels.get(currentDifficultyName);
        #if debug
        trace('[ArtworkSubstate] "$songKey" : pas de niveau pour la difficulté "$currentDifficultyName"');
        #end
        return 0;
    }

    // Appelé par FreeplayState après chaque changeDiff() — source unique de vérité
    public function setDifficulty(diff:Int):Void {
        // On mémorise les anciennes valeurs AVANT de changer la difficulté
        var oldPath = getArtworkPath();
        var oldText = getTextForDiff();
        var oldDesc = getDescForDiff();

        // Le nom de difficulté vient directement de CoolUtil.difficulties
        if (diff >= 0 && diff < CoolUtil.difficulties.length)
            currentDifficultyName = StringTools.trim(CoolUtil.difficulties[diff].toLowerCase());

        var newPath = getArtworkPath();
        var newText = getTextForDiff();
        var newDesc = getDescForDiff();

        // Si l'artwork a changé, on déclenche le slide — sinon on met juste à jour la barre
        if (newPath != oldPath)
            showArtwork();
        else
            updateDifficultyBar();

        // Met à jour text/desc uniquement si différents, indépendamment de l'artwork
        if (newText != oldText) artText.text = newText;
        if (newDesc != oldDesc) artDesc.text = newDesc;

        if (newText != oldText || newDesc != oldDesc)
            layoutDescPanel();
    }

    var isAnimating:Bool = false;
    var startX:Float = 0;
    var barLastClipW:Float = -1; // cache pour ne recréer le clipRect que si le remplissage a changé

    // ---------- BEAT-SYNC (bop de l'artwork sur la musique) ----------
    var baseArtScale:Float = 0.33;   // recalculé pour chaque artwork dans showArtwork() (valeur de repli avant le 1er chargement)
    var lastBeat:Int = -1;           // dernier beat detecte, evite de re-trigger plusieurs fois
    // Le bop reste coupe tant que FreeplayState n'a pas confirme que l'inst est lancee ET que le Conductor
    // (BPM + position) correspond a cette musique. Avant ca, Conductor.crochet/songPosition sont ceux du menu.
    public var bopSynced:Bool = false;

    public function resyncBop():Void {
        lastBeat = -1;
        bopSynced = true;
    }

    var bopStrength:Float = 0.06;    // amplitude du "pop" sur le beat (0.12 = +12%)
    var bopEaseSpeed:Float = 0.20;   // vitesse de retour au scale normal (plus haut = plus rapide)

    public function showArtwork():Void {
        artImage.loadGraphic(Paths.image(getArtworkPath()));
        artImage.scale.set(1, 1);
        artImage.updateHitbox();

        // Mise à l'échelle pour tenir dans la zone poster (largeur de colonne x hauteur
        // max réservée), proportions conservées : chaque artwork, quelle que soit sa
        // résolution source, occupe le même espace visuel et reste aligné avec la
        // barre/les checkboxes en dessous.
        // Deux limites : (1) l'artwork doit tenir dans la zone ; (2) sa SURFACE ne dépasse pas
        // POSTER_AREA_RATIO x la surface de la zone. Sans (2), un artwork carré remplirait toute la zone alors
        // qu'un artwork large (bridé par la largeur) en occuperait moitié moins : l'écart de taille apparente
        // grandissait avec la taille de la zone. Avec (2), les formats proches du carré sont légèrement
        // réduits, les formats larges restent bridés par la largeur de la colonne.
        var fitScale:Float = Math.min(columnW / artImage.width, posterZoneH / artImage.height);
        var areaScale:Float = Math.sqrt(POSTER_AREA_RATIO * columnW * posterZoneH / (artImage.width * artImage.height));
        baseArtScale = Math.min(fitScale, areaScale);

        artImage.scale.set(baseArtScale, baseArtScale);
        artImage.updateHitbox();

        // Centré sur l'axe de la colonne, centré verticalement dans la zone poster
        targetX = axisX - artImage.width / 2;
        artImage.y = posterTopY + (posterZoneH - artImage.height) / 2;

        startX = targetX;
        artImage.x = FlxG.width + artImage.width; // départ hors écran, glisse vers targetX

        updateDifficultyBar();

        artDesc.text = getDescForDiff();
        artText.text = getTextForDiff();
        isAnimating = true;
    }

    public function updateDifficultyBar():Void {
        barTargetLevel = Math.max(0, Math.min(getLevel(), MAX_LEVEL));
        barTgtTranche = getTranche(barTargetLevel);
        barTgtProgress = getTrancheProgress(barTargetLevel, barTgtTranche);
        updateBarStars(); // le nombre d'étoiles dépend du niveau réel (pas de l'animation)
        if (diffZoneReady) updateBarNumber(false);
    }

    // Charge un graphique de mods/images/freeplay/bar/<name>.png (ou un rectangle de secours s'il est absent)
    function loadBarSprite(name:String, fbW:Int, fbH:Int, fbColor:FlxColor):FlxSprite {
        var spr:FlxSprite = new FlxSprite(0, 0);
        if (imageExists(BAR_DIR + name))
            spr.loadGraphic(Paths.image(BAR_DIR + name));
        else
            spr.makeGraphic(fbW, fbH, fbColor);
        spr.antialiasing = ClientPrefs.globalAntialiasing;
        return spr;
    }

    // Chiffre de la difficulté (niveau) SOUS la barre, centré sur l'axe de la colonne. Police : Alphabet en gras,
    // exactement comme les titres de chansons de FreeplayState. Le chiffre est recréé seulement s'il change
    // (ou si force = true après une nouvelle mise en page).
    function updateBarNumber(force:Bool):Void {
        if (barBg == null) return;
        var txt:String = Std.string(Std.int(barTargetLevel));
        if (!force && txt == barNumberText && barNumber != null) return;

        if (barNumber != null) {
            remove(barNumber, true);
            barNumber.destroy();
        }
        barNumber = new Alphabet(0, 0, txt, true);
        barNumberText = txt;

        // Taille mesurée à l'échelle 1, puis réduite pour que le chiffre fasse NUMBER_HEIGHT px de haut
        var w0:Float = barNumber.width;
        var h0:Float = barNumber.height;
        var sc:Float = (h0 > 0) ? NUMBER_HEIGHT / h0 : 1;
        barNumber.scaleX = sc;
        barNumber.scaleY = sc;
        // Couleur proche de celle de la difficulté, éclaircie vers le blanc pour rester lisible (difficultés sombres)
        var tr:Int = getTranche(barTargetLevel);
        barNumber.color = FlxColor.interpolate(getBarColor(tr, getTrancheProgress(barTargetLevel, tr)), FlxColor.WHITE, NUMBER_LIGHTEN);
        barNumber.x = axisX - (w0 * sc) / 2;
        barNumber.y = barBg.y + barBg.height + NUMBER_GAP;
        add(barNumber);
    }

    // Tranche d'un niveau : 0-5 -> 0, ]5-10] -> 1, ]10-15] -> 2, ]15-20] -> 3. Un niveau pile sur un multiple de 5
    // (5, 10, 15, 20) reste donc dans la tranche qui vient de se remplir : barre PLEINE, pas vide.
    function getTranche(level:Float):Int {
        if (level <= 0) return 0;
        return Std.int(Math.max(0, Math.min(Math.ceil(level / TRANCHE_SIZE) - 1, BAR_TRANCHE_MIX.length - 1)));
    }

    // Progression (0-1) à l'intérieur de la tranche actuelle
    function getTrancheProgress(level:Float, tranche:Int):Float {
        return Math.max(0, Math.min((level - tranche * TRANCHE_SIZE) / TRANCHE_SIZE, 1));
    }

    // Couleur d'un niveau de difficulté, identique à celle du chiffre sous la barre en Freeplay.
    // Publique et statique pour pouvoir être réutilisée ailleurs (ex. le Story Mode).
    public static function getLevelColor(level:Float, lighten:Float = NUMBER_LIGHTEN):FlxColor {
        var lvl:Float = Math.max(0, Math.min(level, MAX_LEVEL));
        var tr:Int = (lvl <= 0) ? 0 : Std.int(Math.max(0, Math.min(Math.ceil(lvl / TRANCHE_SIZE) - 1, BAR_TRANCHE_MIX.length - 1)));
        var progress:Float = Math.max(0, Math.min((lvl - tr * TRANCHE_SIZE) / TRANCHE_SIZE, 1));
        var c:FlxColor = FlxColor.interpolate(BAR_COLORS[tr], BAR_COLORS[tr + 1], progress * BAR_TRANCHE_MIX[tr]);
        return FlxColor.interpolate(c, FlxColor.WHITE, lighten);
    }

    // Couleur de la partie remplie : couleur de base de la tranche, qui glisse vers la couleur suivante au fur et à
    // mesure que la tranche se remplit (vert -> un peu d'orange, orange -> un peu de rouge, rouge -> rouge très foncé...)
    function getBarColor(tranche:Int, progress:Float):FlxColor {
        return FlxColor.interpolate(BAR_COLORS[tranche], BAR_COLORS[tranche + 1], progress * BAR_TRANCHE_MIX[tranche]);
    }

    // Étoiles : 2 si niveau < BAR_STAR_THRESHOLD, sinon 4. Moitié à GAUCHE de la barre (orientation normale),
    // moitié à DROITE (flip X), côte à côte, à l'extérieur de bar.png, centrées verticalement sur la barre.
    function updateBarStars():Void {
        if (barStars.length == 0 || barBg == null) return;
        var perSide:Int = Std.int(((getLevel() < BAR_STAR_THRESHOLD) ? 2 : BAR_STAR_MAX) / 2);
        var half:Int = Std.int(BAR_STAR_MAX / 2);
        var barRight:Float = barBg.x + barBg.width;

        for (i in 0...barStars.length) {
            var st:FlxSprite = barStars[i];
            var onRight:Bool = i >= half;
            var idx:Int = onRight ? i - half : i; // 0 = étoile collée à la barre, 1 = celle d'après vers l'extérieur
            st.visible = idx < perSide;
            if (!st.visible) continue;
            st.flipX = onRight;
            var offset:Float = BAR_STAR_GAP + idx * (st.width + BAR_STAR_SPACING);
            st.x = onRight ? barRight + offset : barBg.x - offset - st.width;
            st.y = barCenterY - st.height / 2;
        }
    }

    public function applyOptions():Void {
        for (opt in optionsArray) {
            if (opt != null) {
                ClientPrefs.gameplaySettings.set(opt.variable, opt.getValue());
            }
        }
        ClientPrefs.saveSettings();

        if (PlayState.instance != null) {
            try { PlayState.instance.cpuControlled = ClientPrefs.gameplaySettings.get("botplay"); } catch(e:Dynamic) {}
            try { PlayState.instance.practiceMode = ClientPrefs.gameplaySettings.get("practice"); } catch(e:Dynamic) {}
        }
    }

    // IMPORTANT : on ne teste PLUS cb.x/cb.width/cb.height (la hitbox brute), car celle-ci
    // ignore totalement "offset" (qui ne décale QUE le rendu visuel, pas la hitbox). Résultat
    // avec l'ancienne méthode : la zone cliquable réelle était décalée par rapport à ce que le
    // joueur voit — clic "sous" la checkbox qui l'active quand même, clic "dans" la checkbox
    // mais trop à droite qui ne fait rien. getScreenBounds() calcule le vrai rectangle visible
    // à l'écran (offset + scale + caméra pris en compte), donc la détection colle enfin au
    // dessin, quel que soit checkboxSizeMult.
    function isMouseInExpandedRect(cb:CheckboxThingie, mouseX:Float, mouseY:Float, margin:Float):Bool {
        var bounds = cb.getScreenBounds();
        var hit = mouseX >= (bounds.x - margin) && mouseX <= (bounds.x + bounds.width + margin) &&
                  mouseY >= (bounds.y - margin) && mouseY <= (bounds.y + bounds.height + margin);
        bounds.put(); // FlxRect vient d'un pool, on le rend pour éviter les fuites
        return hit;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Animation artwork
        if (isAnimating) {
            artImage.x = FlxMath.lerp(artImage.x, targetX, 1 - Math.pow(0.000001, elapsed));
            if (Math.abs(artImage.x - targetX) < 1) {
                artImage.x = targetX;
                isAnimating = false;
            }
        }

        // Animation de la barre, TRANCHE PAR TRANCHE :
        //  - même tranche que la cible : la progression glisse (ease-out) vers la valeur visée, dans les deux sens ;
        //  - tranche SUPÉRIEURE à celle affichée : la barre se remplit jusqu'au bout, REVIENT AU DÉBUT directement
        //    dans la tranche visée (les tranches intermédiaires sont sautées : un seul tour, jamais plusieurs) et
        //    recommence à se remplir jusqu'à la cible ;
        //  - tranche INFÉRIEURE (ex. difficile -> facile) : la barre se VIDE d'abord dans l'ancienne couleur, puis on
        //    passe directement à la tranche visée et elle se remplit jusqu'à la cible (pas de défilé à l'envers).
        if (barShownTranche < barTgtTranche) {
            barShownProgress += elapsed * BAR_WRAP_SPEED;
            if (barShownProgress >= 1) {
                barShownProgress = 0;
                barShownTranche = barTgtTranche; // saute les tranches intermédiaires
            }
        } else if (barShownTranche > barTgtTranche) {
            barShownProgress -= elapsed * BAR_DRAIN_SPEED;
            if (barShownProgress <= 0) {
                barShownProgress = 0;
                barShownTranche = barTgtTranche;
            }
        } else if (Math.abs(barTgtProgress - barShownProgress) > 0.002) {
            barShownProgress += (barTgtProgress - barShownProgress) * (1 - Math.pow(0.0001, elapsed));
        } else {
            barShownProgress = barTgtProgress; // snap final, sinon on n'atteint jamais exactement la cible
        }

        // Remplissage : color.png (coloré) est rogné selon la progression dans la tranche ;
        // le reste de la barre est le color.png blanc, toujours présent sur toute la longueur (aucun vide)
        var tranche:Int = barShownTranche;
        var progress:Float = barShownProgress;
        var clipW:Float = barFill.frameWidth * progress;
        if (clipW != barLastClipW) {
            barFill.visible = clipW >= 1;
            if (barFill.visible)
                barFill.clipRect = new FlxRect(0, 0, clipW, barFill.frameHeight);
            barLastClipW = clipW;
        }
        barFill.color = getBarColor(tranche, progress);

        // ---------- Bop de l'artwork sur le beat de la musique ----------
        if (bopSynced && Conductor.crochet > 0) {
            var curBeat:Int = Math.floor(Conductor.songPosition / Conductor.crochet);
            if (curBeat != lastBeat) {
                lastBeat = curBeat;
                artImage.scale.set(baseArtScale * (1 + bopStrength), baseArtScale * (1 + bopStrength));
            }
        }

        // Retour progressif vers la taille normale (ease-out), independant du beat
        artImage.scale.x = FlxMath.lerp(artImage.scale.x, baseArtScale, bopEaseSpeed);
        artImage.scale.y = FlxMath.lerp(artImage.scale.y, baseArtScale, bopEaseSpeed);

        // LEFT/RIGHT supprimes ici — FreeplayState appelle setDifficulty() a la place

        var mouseScreen = FlxG.mouse.getScreenPosition();
        var mx = mouseScreen.x, my = mouseScreen.y;

        var justP = FlxG.mouse.justPressed;
        var justR = FlxG.mouse.justReleased;
        var pressed = FlxG.mouse.pressed;

        var changed:Bool = false;
        for (i in 0...checkboxGroup.members.length) {
            var cb:CheckboxThingie = checkboxGroup.members[i];
            if (cb == null) continue;

            var hover:Bool = isMouseInExpandedRect(cb, mx, my, clickMargin);

            var lbl:FlxText = labelGroup.members[i];
            if (lbl != null) hover = hover || lbl.overlapsPoint(mouseScreen);

            if (justP && hover) {
                if (checkboxPractice == cb) _pressingPractice = true;
                if (checkboxBot == cb) _pressingBot = true;

                var optImmediate = optionsArray[i];
                if (optImmediate != null) {
                    var newVal = !(optImmediate.getValue() == true);
                    optImmediate.setValue(newVal);
                    optImmediate.change();
                    cb.daValue = newVal; // déclenche déjà, via le setter, la bonne animation + le bon offset
                    var lbl2:FlxText = labelGroup.members[i];
                    if (lbl2 != null) {
                        lbl2.x = cb.x + cb.width + labelOffsetX;
                        lbl2.y = cb.y + (cb.height - lbl2.size) / 2 + labelOffsetY;
                    }
                    changed = true;
                    if (checkboxPractice == cb) _pressingPractice = false;
                    if (checkboxBot == cb) _pressingBot = false;
                }
            }

            if (justR) {
                if (checkboxPractice == cb && _pressingPractice) {
                    var optP = optionsArray[i];
                    if (optP != null) {
                        var curP = optP.getValue() == true;
                        if (cb.daValue == curP) {
                            var newValP = !curP;
                            optP.setValue(newValP);
                            optP.change();
                            cb.daValue = newValP; // déclenche déjà, via le setter, la bonne animation + le bon offset
                            var lblp:FlxText = labelGroup.members[i];
                            if (lblp != null) {
                                lblp.x = cb.x + cb.width + labelOffsetX;
                                lblp.y = cb.y + (cb.height - lblp.size) / 2 + labelOffsetY;
                            }
                            changed = true;
                        }
                    }
                    _pressingPractice = false;
                }

                if (checkboxBot == cb && _pressingBot) {
                    var optB = optionsArray[i];
                    if (optB != null) {
                        var curB = optB.getValue() == true;
                        if (cb.daValue == curB) {
                            var newValB = !curB;
                            optB.setValue(newValB);
                            optB.change();
                            cb.daValue = newValB; // déclenche déjà, via le setter, la bonne animation + le bon offset
                            var lblb:FlxText = labelGroup.members[i];
                            if (lblb != null) {
                                lblb.x = cb.x + cb.width + labelOffsetX;
                                lblb.y = cb.y + (cb.height - lblb.size) / 2 + labelOffsetY;
                            }
                            changed = true;
                        }
                    }
                    _pressingBot = false;
                }
            }
        }

        if (!changed && (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER)) {
            for (i in 0...checkboxGroup.members.length) {
                var cbk:CheckboxThingie = checkboxGroup.members[i];
                if (cbk == null) continue;
                var hoverK:Bool = isMouseInExpandedRect(cbk, mx, my, clickMargin);
                var lblK:FlxText = labelGroup.members[i];
                if (lblK != null) hoverK = hoverK || lblK.overlapsPoint(mouseScreen);
                if (hoverK) {
                    var optK = optionsArray[i];
                    if (optK != null) {
                        var newValK = !(optK.getValue() == true);
                        optK.setValue(newValK);
                        optK.change();
                        cbk.daValue = newValK; // déclenche déjà, via le setter, la bonne animation + le bon offset
                        changed = true;
                    }
                    break;
                }
            }
        }

        if (changed) {
            FlxG.sound.play(Paths.sound("scrollMenu"));
            applyOptions();
            reloadCheckboxes();
        }
    }
}

/* --------------------------
   Artwork-local GameplayOption
   -------------------------- */
class ArtworkGameplayOption {
    public var name:String;
    public var variable:String;
    public var type:String;
    public var defaultValue:Dynamic;
    public var curOption:Int = 0;
    public var options:Array<String>;
    public var changeValue:Dynamic = 1;
    public var minValue:Dynamic = null;
    public var maxValue:Dynamic = null;
    public var decimals:Int = 1;
    public var displayFormat:String = "%v";
    public var onChange:Void->Void = null;

    public function new(name:String, variable:String, type:String = "bool", defaultValue:Dynamic = 'null variable value', ?opts:Array<String> = null) {
        this.name = name;
        this.variable = variable;
        this.type = type;
        this.defaultValue = defaultValue;
        this.options = opts;

        if (defaultValue == 'null variable value') {
            switch(type) {
                case 'bool': defaultValue = false;
                case 'int' | 'float': defaultValue = 0;
                case 'percent': defaultValue = 1;
                case 'string':
                    defaultValue = '';
                    if (opts != null && opts.length > 0) defaultValue = opts[0];
            }
            this.defaultValue = defaultValue;
        }

        if (ClientPrefs.gameplaySettings.get(variable) == null) {
            setValue(this.defaultValue);
        }

        switch(type) {
            case 'string':
                if (options != null) {
                    var num = options.indexOf(getValue());
                    if (num > -1) curOption = num;
                }
            case 'percent':
                displayFormat = "%v%";
                changeValue = 0.01;
                minValue = 0;
                maxValue = 1;
                decimals = 2;
        }
    }

    public function getValue():Dynamic {
        return ClientPrefs.gameplaySettings.get(variable);
    }
    public function setValue(v:Dynamic):Void {
        ClientPrefs.gameplaySettings.set(variable, v);
    }
    public function change():Void {
        if (onChange != null) onChange();
    }
}


/* --------------------------
   Données d'artwork (voir ARTWORKS)
   -------------------------- */
typedef ArtworkVariant = {
    ?art:String,
    ?text:String,
    ?desc:String
}

typedef ArtworkEntry = {
    ?art:String,
    ?text:String,
    ?desc:String,
    ?levels:Map<String, Int>,
    ?variants:Map<String, ArtworkVariant>
}