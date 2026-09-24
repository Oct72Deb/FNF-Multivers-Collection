package substates;

import CheckboxThingie;
import ClientPrefs;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
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
    var bg:FlxSprite;
    var artImage:FlxSprite;
    var artDesc:FlxText;
    var artText:FlxText;

    // Difficulty bar
    var barBg:FlxSprite;
    var barFill:FlxSprite;
    var barMaxWidth:Int;
    var barCurrentPercent:Float = 0;
    var barTargetPercent:Float = 0;

    private var optionsArray:Array<ArtworkGameplayOption> = [];
    public var currentWeek:String;

    private var _initSongName:String = "";
    private var _initDifficulty:Int = 1;

    var songKey:String = null; 
    var entry:ArtworkEntry = null;
    var currentDifficultyName:String = "normal";

    var clickMargin:Float = 8;  
    var labelOffsetX:Float = 42; 
    var labelOffsetY:Float = 10;

    var checkboxSizeMult:Float = 0.5;

    var gapY:Float = 100;         
    // ----------------------------

    public function new(week:String, songName:String = "", difficulty:Int = 1) {
        super();
        currentWeek = week;
        _initSongName = songName;
        _initDifficulty = difficulty;
        persistentUpdate = true;
        persistentDraw = true;
    }

    static final ARTWORKS:Map<String, ArtworkEntry> = [

        "how to play" => {
            text: "Don't know how to play? No problem! The Mario Bros. are here for you!",
            desc: "BPM: 124 / VS. Mario Bros.",
            levels: ["veryeasy" => 2, "easy" => 6, "normal" => 10, "hard" => 17, "veryhard" => 20]
        },

        "metal reflection" => {
            text: "An opponent who reflects mystery...",
            desc: "BPM: 120 / VS. Metal Mario",
            levels: ["veryeasy" => 0, "easy" => 4, "normal" => 8, "hard" => 12, "veryhard" => 20]
        },

        "criminal targets" => {
            text: "Ayuwoki ?",
            desc: "BPM: 118 / BONUS STAGE"
            // pas de "levels" = barre vide
        },

        "crash out" => {
            text: "A little pink ball crashing out on a fox to the beat.",
            desc: "BPM: 180 / VS. FUCKING Fox McCloud",
            levels: ["easy" => 3, "normal" => 6, "hard" => 10]
        },

        "trick or treat" => {
            text: "A candy hunt connected to the real world.",
            desc: "BPM: 125 > 145 > 210 > 145 / VS. ???",
            levels: ["easy" => 3, "normal" => 6, "hard" => 10]
        },

        "periple" => {
            text: "tiny guy",
            desc: "BPM: 163 / VS. Mary",
            levels: ["easy" => 3, "normal" => 7, "hard" => 12]
        },

        "starlight" => {
            text: "Fly to the stars to the sound of her voice.",
            desc: "BPM: 173 / VS. Océane",
            levels: ["easy" => 3, "normal" => 7, "hard" => 12]
        },

        "allocution" => {
            text: "Fight it out in beeps and boops without getting overruled.",
            desc: "BPM: 155 / VS. Emmanuel Macron",
            levels: ["easy" => 6, "normal" => 10, "hard" => 20]
        },

"gangstabattle" => {
    text: "???",
    desc: "BPM: 180 / VS. Gangsta Mario",
    // TODO: valeurs à ajuster selon le vrai ressenti de chaque variante (prototype)
    levels: ["easy" => 6, "normal" => 10, "hard" => 15,
             "erect" => 18, "nightmare" => 20, "pico-mix" => 12, "b-side" => 14,
             "corruption" => 16, "minus" => 8, "in-game-version" => 10, "in-game-mix" => 11],
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
            levels: ["easy" => 5, "normal" => 10, "hard" => 15]
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

    static function findEntry(key:String):ArtworkEntry {
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

        bg = new FlxSprite(Std.int(FlxG.width * 0.65), 0)
            .makeGraphic(Std.int(FlxG.width * 0.35), FlxG.height, FlxColor.fromRGB(0, 0, 0, 0));
        add(bg);

        artImage = new FlxSprite(bg.x + 60, 180);
        add(artImage);

        barMaxWidth = Std.int(bg.width - 120);

        barBg = new FlxSprite(bg.x + 45, 110)
            .makeGraphic(barMaxWidth, 20, FlxColor.fromRGB(40, 40, 40));
        add(barBg);

        barFill = new FlxSprite(bg.x + 45, 110)
            .makeGraphic(1, 20, FlxColor.GREEN);
        add(barFill);

        artDesc = new FlxText(bg.x + 25, 495, bg.width - 80, "", 16);
        artDesc.setFormat(null, 16, FlxColor.WHITE, "center");
        add(artDesc);

        artText = new FlxText(bg.x + 25, 525, bg.width - 80, "", 20);
        artText.setFormat(null, 15, FlxColor.WHITE, "center");
        add(artText);

        checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
        add(checkboxGroup);

        labelGroup = new FlxTypedGroup<FlxText>();
        add(labelGroup);

        getOptions();

        var baseX:Float = bg.x + 40 - 20;   // +10px vers la droite
        var baseY:Float = bg.y + 580 - 20;  // -20px vers le haut
        var id:Int = 0;
        var cbGapY:Float = 56; // valeur de repli, écrasée dès la 1ère checkbox créée (voir plus bas)
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
                cb.x = baseX;
                cb.y = baseY + id * cbGapY;
                cb.ID = id;
                checkboxGroup.add(cb);

                // Espace vertical entre checkboxes = hauteur réelle de la checkbox (native) + marge,
                // calculé une fois sur la 1ère checkbox plutôt qu'une valeur en dur qui suppose
                // une taille fixe.
                if (id == 0) cbGapY = cb.height + 20;

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
        applyOptions();

        // create() est différé par openSubState() : FreeplayState ne peut pas appeler
        // updateArtworkForSong() juste après. On applique donc ici les valeurs reçues par
        // le constructeur, quand tous les sprites existent.
        if (_initSongName != "")
            updateArtworkForSong(_initSongName);
        setDifficulty(_initDifficulty);
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
    public function updateArtworkForSong(songName:String):Void {
        var key = Paths.formatToSongPath(songName);

        // Même chanson et image déjà chargée : on évite de relancer le slide et le rechargement.
        if (key == songKey && artImage.graphic != null) return;

        songKey = key;
        entry = findEntry(key);
        showArtwork();
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
    }

    var isAnimating:Bool = false;
    var startX:Float = 0;
    var barLastFillWidth:Int = -1; // cache pour eviter de regenerer le graphic inutilement

    // ---------- BEAT-SYNC (bop de l'artwork sur la musique) ----------
    var baseArtScale:Float = 0.33;   // scale de repos de l'artwork (repris de showArtwork)
    var lastBeat:Int = -1;           // dernier beat detecte, evite de re-trigger plusieurs fois
    var bopStrength:Float = 0.06;    // amplitude du "pop" sur le beat (0.12 = +12%)
    var bopEaseSpeed:Float = 0.20;   // vitesse de retour au scale normal (plus haut = plus rapide)

    public function showArtwork():Void {
        artImage.loadGraphic(Paths.image(getArtworkPath()));
        artImage.scale.set(baseArtScale, baseArtScale);
        artImage.updateHitbox();
        artImage.screenCenter();
        artImage.x += 400;
        artImage.y += -40;
        startX = artImage.x;
        artImage.x = FlxG.width + artImage.width;
        targetX = startX;

        updateDifficultyBar();

        artDesc.text = getDescForDiff();
        artText.text = getTextForDiff();
        isAnimating = true;
    }

    public function updateDifficultyBar():Void {
        barTargetPercent = Math.max(0, Math.min(getLevel() / MAX_LEVEL, 1));
    }

    function getBarColor(percent:Float):FlxColor {
        if (percent < 0.5)
            return FlxColor.interpolate(FlxColor.GREEN, FlxColor.fromRGB(255, 165, 0), percent * 2);
        else
            return FlxColor.interpolate(FlxColor.fromRGB(255, 165, 0), FlxColor.RED, (percent - 0.5) * 2);
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

        // Animation barre de difficulte (ease-out)
        if (Math.abs(barTargetPercent - barCurrentPercent) > 0.0005) {
            barCurrentPercent += (barTargetPercent - barCurrentPercent) * (1 - Math.pow(0.0001, elapsed));
        } else if (barCurrentPercent != barTargetPercent) {
            barCurrentPercent = barTargetPercent; // snap final, sinon on n'atteint jamais exactement la cible
        }

        var fillWidth:Int = Std.int(barMaxWidth * barCurrentPercent);
        if (fillWidth < 1) fillWidth = 1;

        // On ne regenere le bitmap que si sa largeur a reellement change (evite le makeGraphic() a chaque frame)
        if (fillWidth != barLastFillWidth) {
            barFill.makeGraphic(fillWidth, 20, getBarColor(barCurrentPercent));
            barLastFillWidth = fillWidth;
        }

        // ---------- Bop de l'artwork sur le beat de la musique ----------
        if (Conductor.crochet > 0) {
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